#$Log: imcalc.x,v $
#Revision 11.0  1997/11/06 16:27:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:43  prosb
#General Release 2.4
#
#Revision 8.2  1995/10/10  17:17:06  prosb
#added #$Log: imcalc.x,v $
#added #Revision 11.0  1997/11/06 16:27:36  prosb
#added #General Release 2.5
#added #
#added #Revision 9.0  1995/11/16 18:33:43  prosb
#added #General Release 2.4
#added # and #$Header: /home/pros/xray/ximages/imcalc/RCS/imcalc.x,v 11.0 1997/11/06 16:27:36 prosb Exp $ lines
#
#$Header: /home/pros/xray/ximages/imcalc/RCS/imcalc.x,v 11.0 1997/11/06 16:27:36 prosb Exp $

include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>

include	"imcalc.h"

define	yyparse	imc_parse
define	yylex   imc_lex

define	EQUALS		257
define	SEMICOLON		258
define	NEWLINE		259
define	FLOAT		260
define	INTEGER		261
define	IDENTIFIER		262
define	YYEOF		263
define	QUIT		264
define	PRINT		265
define	CMD		266
define	BNOT		267
define	BAND		268
define	BOR		269
define	BXOR		270
define	PLUS		271
define	MINUS		272
define	STAR		273
define	SLASH		274
define	EXPON		275
define	QUEST		276
define	COLON		277
define	LT		278
define	GT		279
define	LE		280
define	EQ		281
define	NE		282
define	LAND		283
define	LOR		284
define	LNOT		285
define	GE		286
define	UMINUS		287
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 269 "imcalc.yy"


# IMCALC -- Main routine for the image calculator.

procedure t_imcalc()

char	input[SZ_LINE]		# input file name or "-" for STDIN
int	status			# returned status from imc_parse
int	fin			# channel for input file
int	y_debug			# yacc debug flag
int	clgeti()		# get int parameter
int	access()		# file access routine
bool	clgetb()		# get a bool parameter
bool	streq()			# str compare
int	open()			# open a file
int	imc_parse()		# parser
real	clgetr()		# get a real parameter
pointer grandsp			# overall stack pointer
pointer sp			# stack pointer
extern	imc_lex()		# lexical analyzer

include "lex.com"
include "imcalc.com"
include "errfcn.com"

begin
	# Set up the standard output to flush on a newline
	call fseti (STDOUT, F_FLUSHNL, YES)
	call fseti (STDERR, F_FLUSHNL, YES)
	# get parameters
	call clgstr("input", input, SZ_LINE)
	if( streq(input, "") )
	    call strcpy("-", input, SZ_LINE)
	# get divide by 0 value
	errfcn = clgetr("zero")
	c_delete = clgetb ("clobber")
	c_debug = clgeti ("debug")
	if( c_debug >= 10 )
	    y_debug = 1
	else
	    y_debug = 0
	# check for "-" => STDIN
	if( streq(input, "-") )
	    fin = STDIN
	# else check for accessible file
	else if( access(input, 0, 0) == YES )
	    fin = open(input, READ_ONLY, TEXT_FILE)
	# else its a direct command - fake a file
	else{
	    # create a spool file for the command string
	    fin = open("spool", READ_WRITE, SPOOL_FILE)
	    # write the string to it
	    call fprintf(fin, "%s\n")
		call pargstr(input)
	    # rewind the spool file
	    call seek(fin, BOF)
	}

	# allocate buffers and init some pointers, etc.
	call smark(grandsp)
	call salloc( c_registers, MAX_REGISTERS*LEN_REGISTER, TY_STRUCT)
	call salloc( c_images, MAX_IMAGES*LEN_IMAGE, TY_STRUCT)
	call salloc( c_sbuf, SZ_SBUF, TY_CHAR)
	if( c_debug >= 5 ){
		call printf("c_registers=%d, c_images=%d\n")
		call pargi(c_registers)
		call pargi(c_images)
	}

	# init the parser
	lptr = 0
	lbuf[1] = EOS

	# compile and execute
	repeat {
	    call smark(sp)
	    # reset pointers
	    call imc_reset()
	    # parse and compile meta-code
	    status = imc_parse (fin, y_debug, imc_lex)
	    if (status == ERR){
		call eprintf ("line: %s")
		call pargstr(lbuf)
		call sfree(sp)
		next
	    }
	    if (c_error == YES ){
		call sfree(sp)
		next
	    }
	    # finish up the compilation
	    call imc_endcompile()
	    # execute the meta-code for each line of output image
	    call imc_execute()
	    # close images
	    call imc_close()
	    # and rename the temp file, if necessary
	    call imc_rename()
	    # free up temp storage space
	    call sfree(sp)
	} until (status == EOF)

	# free up the allocated space
	call sfree(grandsp)
end

# IMC_LEX -- Lexical input routine.  Return next token from the input
# stream.

int procedure imc_lex (fd, yylval)

int	fd			# i: input file channel
pointer	yylval			# o: output value for parser stack
int	i			# l: loop variable
int	nchars			# l: number of chars in lexnum
int	ch			# l: just a char
int	token			# l: token type
int	junk			# l: for grabbing unneeded function values
int	type			# l: type of token - returned by function
double	dval			# l: numeric value of string
int	lexnum(), getline(), gctod()
bool	streq()			# l: string compare
int	imc_follow()		# l: check following char

include "lex.com"
include "imcalc.com"

begin
	# end parsing and force a new getline, if we get an error
	# don't set type to NEWLINE, to avoid confusion with OPNL syntax
	if( c_error == YES ){
		type = SEMICOLON
		lptr = 0
		return(type)
	}

	# Fetch a nonempty input line, or advance to start of next token
	# if within a line.  Newline is a token.
	while (lptr == 0) {
	    if( fd == STDIN ){
		call printf("IMC) ")
		call flush(STDOUT)
	    }
	    if (getline (fd, lbuf) == EOF) {
		lptr = 0
		return (YYEOF)
	    } else{
		lptr = 1
		# skip white space
		while (IS_WHITE (lbuf[lptr]))
			lptr = lptr + 1
		# skip blank lines and lines beginning with "#"
		ch = lbuf[lptr]
		if( (ch != '\n') && (ch != '#') && (ch != EOS) )
#		    call strlwr(lbuf)
		else
		    lptr = 0
	    }
	}

	# skip white space
	while (IS_WHITE (lbuf[lptr]))
	    lptr = lptr + 1

	# Determine type of token.  If numeric constant, convert to binary
	# and return value in op structure (yylval). Otherwise, check for
	# operators, identifiers, etc.

	if (IS_DIGIT (lbuf[lptr])){
	    # get type of numberal
	    token = lexnum (lbuf, lptr, nchars)
	}
	else{
	    # grab the next character
	    token = lbuf[lptr]
	    # bump lbuf pointer
	    lptr = lptr+1
	    # seed the return value - this might be overwritten
            O_VALI(yylval) = token
	}

	# process the token
	switch (token) {

	case LEX_OCTAL, LEX_DECIMAL, LEX_HEX:
	    # convert ASCII to number
	    junk = gctod (lbuf, lptr, dval)
	    O_TYPE(yylval) = TY_INT
	    O_VALI(yylval) = int (dval)
	    type = INTEGER

	case LEX_REAL:
	    # convert ASCII to number
	    junk = gctod (lbuf, lptr, dval)
	    O_TYPE(yylval) = TY_REAL
	    O_VALR(yylval) = dval
	    type = FLOAT
	 
        case '=':
	    type = imc_follow(lbuf, lptr, '==', EQUALS, EQ)

	case ';':
	    type = SEMICOLON

	case '\n':
	    type = NEWLINE
	    # grab new line on next loop
	    lptr = 0

	# comment character fakes a new line
	case '#':
	    type = NEWLINE
	    # grab new line on next loop
	    lptr = 0

	case '+':
	    type = PLUS

	case '-':
	    type = MINUS

	case '/':
	    type = SLASH

	case '?':
	    type = QUEST

	case ':':
	    type = COLON

	case '(':
	    type = '('

	case ')':
	    type = ')'

	case ',':
	    type = ','

	case '*':
	    type = imc_follow(lbuf, lptr, '*', STAR, EXPON)

	case '<':
	    type = imc_follow(lbuf, lptr, '=', LT, LE)

	case '>':
	    type = imc_follow(lbuf, lptr, '=', GT, GE)

	case '&':
	    type = imc_follow(lbuf, lptr, '&', BAND, LAND)

	case '|':
	    type = imc_follow(lbuf, lptr, '|', BOR, LOR)

	case '!':
	    # if its the first token, its the escape character
	    if( c_tokens ==0 ){
		type = CMD
		# point return yylval value to current place in string buffer
		O_LBUF(yylval) = c_nextch

		# get characters up to next end of statement
		while( (lbuf[lptr] != EOS) && (lbuf[lptr] != '\n') &&
		       (lbuf[lptr] != ';') ){
		    # add the char to the string
		    Memc[c_nextch] = lbuf[lptr]
		    c_nextch = c_nextch + 1
		    lptr = lptr+1
		}
		# finish up the string
		Memc[c_nextch] = EOS
		# and point to next available place in buffer
		c_nextch = c_nextch + 1
	    }
	    # otherwise its a logical of some sort
	    else{
		type = imc_follow(lbuf, lptr, '!', BNOT, LNOT)
		if( type == BNOT )
		    type = imc_follow(lbuf, lptr, '=', BNOT, NE)
	    }

	case '^':
	    type = BXOR

	case ']':
	    # force syntax error
	    type = '('
#	    type = NEWLINE
	    call imc_error("dangling ']'")
	    return(type)

	case '[':
	    type = '('
#	    type = NEWLINE
	    call imc_error("dangling '['")
	    return(type)

	# ^D to exit
	case 4:
	    type = YYEOF

	# quoted string
	case '"':
	    type = IDENTIFIER
	    # point return yylval value to current place in string buffer
	    O_LBUF(yylval) = c_nextch

	    # get chars in name up to closing "
	    while( lbuf[lptr] != '"' ){
		    # add the char to the string
		    Memc[c_nextch] = lbuf[lptr]
		    c_nextch = c_nextch + 1
		    lptr=lptr+1
		    if( lbuf[lptr] == EOS ){
			type = '('
			call imc_error("missing end quote in string")
			return(type)

		    }
	    }
	    # point past the final quote
	    lptr=lptr+1

	    # join common code with unquoted strings
	    goto 99

	# identifier
	default:
	    type = IDENTIFIER

	    # point return yylval value to current place in string buffer
	    O_LBUF(yylval) = c_nextch
	    Memc[c_nextch] = token
	    c_nextch = c_nextch + 1

	    # get chars in the file name
	    while( IS_ALNUM(lbuf[lptr]) || (lbuf[lptr] == '.') ||
		    (lbuf[lptr] == '_') || (lbuf[lptr] == '/') ||
		    (lbuf[lptr] == '$') ){
		    # add the char to the string
		    Memc[c_nextch] = lbuf[lptr]
		    c_nextch = c_nextch + 1
		    lptr=lptr+1
	    }

	    # look for possibly two bracket specifications
	    # skip white space
	    for(i=1; i<=2; i=i+1){

	    while (IS_WHITE (lbuf[lptr]))
	        lptr = lptr + 1

	    # and see if very next char was open bracket
	    if( lbuf[lptr] == '[' ){
		# collect up to the closing bracket
		for(; lbuf[lptr] != ']'; lptr = lptr+1){
		    if( lbuf[lptr] == EOS ){
			# force syntax error
			type = '('
#	    		type = NEWLINE
		        call imc_error("missing ']' on image specification")
			return(type)
		    }
		    else{
			Memc[c_nextch] = lbuf[lptr]
			c_nextch = c_nextch + 1
		    }
		}
		# get final bracket
		Memc[c_nextch] = lbuf[lptr]
		c_nextch = c_nextch + 1
		lptr = lptr + 1
	    }

	    } # end of for loop

#	    common code for quoted and unquoted strings
99	    # finish up the string
	    Memc[c_nextch] = EOS
	    # and point to next available place in buffer
	    c_nextch = c_nextch + 1

	    # check for a special identifiers
	    if( streq(Memc[O_LBUF(yylval)], "bye") ||
		streq(Memc[O_LBUF(yylval)], "BYE") )
		type = QUIT
	    else if( streq(Memc[O_LBUF(yylval)], "exit") ||
		streq(Memc[O_LBUF(yylval)], "EXIT") )
		type = QUIT
	    else if( streq(Memc[O_LBUF(yylval)], "quit") ||
		streq(Memc[O_LBUF(yylval)], "QUIT") )
		type = QUIT
	    else if( streq(Memc[O_LBUF(yylval)], "print") ||
		streq(Memc[O_LBUF(yylval)], "PRINT") )
		type = PRINT

	}

	# inc the number of tokens parsed in this expression
	c_tokens = c_tokens+1

	# return the type
	return(type)
end

#
#  IMC_FOLLOW -- check the following character for different types
#
int procedure imc_follow(lbuf, lptr, ch, type1, type2)

char	lbuf[ARB]		# input char buffer
int	lptr			# index for lbuf
int	ch			# char to check "next char" against
int	type1			# this type if "next char" doesn't match
int	type2			# this type if "next char" does match

begin
 	if( lbuf[lptr] == ch ){
		lptr = lptr+1
		return(type2)
	}
	else{
		return(type1)
	}
end

#
# IMC_RESET - reset pointers for next compilation
#
procedure imc_reset()
include "imcalc.com"
begin
	# no tokens parsed yet
	c_tokens = 0
	# not at end of output image
	c_ateof = NO
	# set curretn string pointer back to beginning
	c_nextch = c_sbuf
	# no images as yet
	c_nextimage = 1
	# no registers as yet
	c_nextreg = 1
	# no instructions as yet
	c_nextinst = 1
	# really no instructions
	call amovki(0, c_metacode, LEN_INSTRUCTION*MAX_INSTRUCTIONS)
	# no image opened on rhs as yet
	c_ndim = 0
	# no images being processed
	c_imageno = 0
	# no errors as yet
	c_error = NO
	# zero out the register and image arrays
	call amovki( 0, Memi[c_registers], MAX_REGISTERS*LEN_REGISTER)
	call amovki( 0, Memi[c_images], MAX_IMAGES*LEN_IMAGE)
	# no temp file names as yet
	call strcpy("", c_imtemp, SZ_FNAME)
	# no functions as yet
	c_callno = 0
	# no image handle as yet
	c_imhandle = 0
end

#
# IMC_CLOSE -- close all image files
#
procedure imc_close()

int im				# l: image descriptor
int i				# l: loop counter
include "imcalc.com"
begin
	for(i=1; i<c_nextimage; i=i+1){
	    im = I_IM(I_IMPTR(c_images, i))
	    call imunmap(im)
	}
end

procedure imc_rename()

bool strne()			# l: string compare
include "imcalc.com"
begin
	# see if we had to make a temp file
	if( strne("", c_imtemp) ){
		# if so, delete the old image file
		iferr(call imdelete(c_imname)){
                    call imc_error("Can't delete old copy of output image")
		    call printf("Image is saved in file %s\n")
		    call pargstr(c_imtemp)
		    return
		}
		# and rename the temp file
		iferr(call imrename(c_imtemp, c_imname)){
                    call imc_error("Can't rename output image")
		    call printf("Image is saved in file %s\n")
		    call pargstr(c_imtemp)
		}
	}
end

define	YYNPROD		44
define	YYLAST		300
# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

# Parser for yacc output, translated to the IRAF SPP language.  The contents
# of this file form the bulk of the source of the parser produced by Yacc.
# Yacc recognizes several macros in the yaccpar input source and replaces
# them as follows:
#	A	user suppled "global" definitions and declarations
# 	B	parser tables
# 	C	user supplied actions (reductions)
# The remainder of the yaccpar code is not changed.

define	yystack_	10		# statement labels for gotos
define	yynewstate_	20
define	yydefault_	30
define	yyerrlab_	40
define	yyabort_	50

define	YYFLAG		(-1000)		# defs used in user actions
define	YYERROR		goto yyerrlab_
define	YYACCEPT	return (OK)
define	YYABORT		return (ERR)


# YYPARSE -- Parse the input stream, returning OK if the source is
# syntactically acceptable (i.e., if compilation is successful),
# otherwise ERR.  The parameters YYMAXDEPTH and YYOPLEN must be
# supplied by the caller in the %{ ... %} section of the Yacc source.
# The token value stack is a dynamically allocated array of operand
# structures, with the length and makeup of the operand structure being
# application dependent.

int procedure yyparse (fd, yydebug, yylex)

int	fd			# stream to be parsed
bool	yydebug			# print debugging information?
int	yylex()			# user-supplied lexical input function
extern	yylex()

short	yys[YYMAXDEPTH]		# parser stack -- stacks tokens
pointer	yyv			# pointer to token value stack
pointer	yyval			# value returned by action
pointer	yylval			# value of token
int	yyps			# token stack pointer
pointer	yypv			# value stack pointer
int	yychar			# current input token number
int	yyerrflag		# error recovery flag
int	yynerrs			# number of errors

short	yyj, yym		# internal variables
pointer	yysp, yypvt
short	yystate, yyn
int	yyxi, i
errchk	salloc, yylex


include	"imcalc.com"
short	yyexca[70]
data	(yyexca(i),i=  1,  8)	/  -1,   1,   0,  -1,  -2,   0,  -1,  82/
data	(yyexca(i),i=  9, 16)	/ 278,   0, 279,   0, 280,   0, 286,   0/
data	(yyexca(i),i= 17, 24)	/  -2,  29,  -1,  83, 278,   0, 279,   0/
data	(yyexca(i),i= 25, 32)	/ 280,   0, 286,   0,  -2,  30,  -1,  84/
data	(yyexca(i),i= 33, 40)	/ 278,   0, 279,   0, 280,   0, 286,   0/
data	(yyexca(i),i= 41, 48)	/  -2,  31,  -1,  85, 278,   0, 279,   0/
data	(yyexca(i),i= 49, 56)	/ 280,   0, 286,   0,  -2,  32,  -1,  86/
data	(yyexca(i),i= 57, 64)	/ 281,   0, 282,   0,  -2,  33,  -1,  87/
data	(yyexca(i),i= 65, 70)	/ 281,   0, 282,   0,  -2,  34/
short	yyact[300]
data	(yyact(i),i=  1,  8)	/  34,  35,  36,  29,  30,  31,  32,  33/
data	(yyact(i),i=  9, 16)	/  45,  91,  39,  40,  41,  43,  44,  37/
data	(yyact(i),i= 17, 24)	/  38,  70,  42,  34,  35,  36,  29,  30/
data	(yyact(i),i= 25, 32)	/  31,  32,  33,  45,  33,  39,  40,  41/
data	(yyact(i),i= 33, 40)	/  43,  44,  37,  38,  18,  42,  34,  35/
data	(yyact(i),i= 41, 48)	/  36,  29,  30,  31,  32,  33,  27,  49/
data	(yyact(i),i= 49, 56)	/  39,  40,  41,  43,  44,  37,  27,  68/
data	(yyact(i),i= 57, 64)	/  42,  34,  35,  36,  29,  30,  31,  32/
data	(yyact(i),i= 65, 72)	/  33,   8,   9,  39,  40,  41,  43,  44/
data	(yyact(i),i= 73, 80)	/  20,  10,  34,  42,  36,  29,  30,  31/
data	(yyact(i),i= 81, 88)	/  32,  33,   5,   4,  39,  40,  41,  43/
data	(yyact(i),i= 89, 96)	/  44,   3,  34,   1,  42,  29,  30,  31/
data	(yyact(i),i= 97,104)	/  32,  33,   0,   0,  39,  40,  41,  43/
data	(yyact(i),i=105,112)	/  44,  31,  32,  33,  42,  29,  30,  31/
data	(yyact(i),i=113,120)	/  32,  33,   0,   0,  39,  40,  41,  43/
data	(yyact(i),i=121,128)	/  44,   0,   0,   0,  42,  29,  30,  31/
data	(yyact(i),i=129,136)	/  32,  33,   0,  19,  39,  40,  41,  29/
data	(yyact(i),i=137,144)	/  30,  31,  32,  33,  42,   8,   9,   0/
data	(yyact(i),i=145,152)	/   0,  13,   7,   6,  11,  12,  28,  89/
data	(yyact(i),i=153,160)	/   0,   0,  90,  46,  47,  48,   2,  50/
data	(yyact(i),i=161,168)	/   0,   0,  14,  15,  16,  17,   0,   0/
data	(yyact(i),i=169,176)	/   0,  51,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=177,184)	/   0,   0,   0,   0,   0,  69,   0,  71/
data	(yyact(i),i=185,192)	/  73,  74,  75,  76,  77,  78,  79,  80/
data	(yyact(i),i=193,200)	/  81,  82,  83,  84,  85,  86,  87,  88/
data	(yyact(i),i=201,208)	/  52,  53,  54,  55,  56,  57,  58,  59/
data	(yyact(i),i=209,216)	/  60,  61,  62,  63,  64,  65,  66,  67/
data	(yyact(i),i=217,224)	/   0,   0,   0,   0,   0,   0,  92,   0/
data	(yyact(i),i=225,232)	/   0,  94,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=233,240)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=241,248)	/   0,   0,   0,   0,  34,  35,  36,  29/
data	(yyact(i),i=249,256)	/  30,  31,  32,  33,  45,   0,  39,  40/
data	(yyact(i),i=257,264)	/  41,  43,  44,  37,  38,  93,  42,   0/
data	(yyact(i),i=265,272)	/   0,  72,  21,  22,  26,   0,   0,   0/
data	(yyact(i),i=273,280)	/   0,  24,  21,  22,  26,   0,  23,   0/
data	(yyact(i),i=281,288)	/   0,  24,   0,   0,   0,   0,  23,   0/
data	(yyact(i),i=289,296)	/   0,   0,   0,  25,   0,   0,   0,   0/
data	(yyact(i),i=297,300)	/   0,   0,   0,  25/
short	yypact[95]
data	(yypact(i),i=  1,  8)	/-117,-1000,-1000,-193,-193,-193,-193,-1000/
data	(yypact(i),i=  9, 16)	/-1000,-1000,-221,  14,-1000,-1000,-1000,-1000/
data	(yypact(i),i= 17, 24)	/-1000,-1000,  14,-249,-1000,-1000,-1000,  14/
data	(yypact(i),i= 25, 32)	/  14,  14,   7,  14,-249,-1000,-1000,-1000/
data	(yypact(i),i= 33, 40)	/-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000/
data	(yypact(i),i= 41, 48)	/-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000/
data	(yypact(i),i= 49, 56)	/-1000,  14, -24,   6,   6,   6,   6,   6/
data	(yypact(i),i= 57, 64)	/   6,   6,   6,   6,   6,   6,   6,   6/
data	(yypact(i),i= 65, 72)	/   6,   6,   6,   6, 110,-249,-1000,-168/
data	(yypact(i),i= 73, 80)	/-1000,-168,-247,-247,-1000,-162,-194,-178/
data	(yypact(i),i= 81, 88)	/-211,-230,-136,-136,-136,-136,-146,-146/
data	(yypact(i),i= 89, 95)	/-268,-1000,  14,-1000,-249,   6,-249/
short	yypgo[10]
data	(yypgo(i),i=  1,  8)	/   0,  91, 158,  89,  83,  82, 131,  72/
data	(yypgo(i),i=  9, 10)	/ 169,  55/
short	yyr1[44]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   1,   1/
data	(yyr1(i),i=  9, 16)	/   5,   4,   3,   2,   2,   6,   6,   6/
data	(yyr1(i),i= 17, 24)	/   6,   6,   6,   6,   6,   6,   6,   6/
data	(yyr1(i),i= 25, 32)	/   6,   6,   6,   6,   6,   6,   6,   6/
data	(yyr1(i),i= 33, 40)	/   6,   6,   6,   6,   6,   6,   9,   9/
data	(yyr1(i),i= 41, 44)	/   9,   7,   8,   8/
short	yyr2[44]
data	(yyr2(i),i=  1,  8)	/   0,   0,   1,   2,   2,   2,   2,   1/
data	(yyr2(i),i=  9, 16)	/   1,   2,   3,   1,   1,   1,   1,   1/
data	(yyr2(i),i= 17, 24)	/   2,   2,   2,   4,   4,   4,   4,   4/
data	(yyr2(i),i= 25, 32)	/   4,   4,   4,   4,   4,   4,   4,   4/
data	(yyr2(i),i= 33, 40)	/   4,   4,   4,   7,   4,   3,   0,   1/
data	(yyr2(i),i= 41, 44)	/   3,   1,   0,   2/
short	yychk[95]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2,  -3,  -4,  -5, 264, 263/
data	(yychk(i),i=  9, 16)	/ 258, 259,  -7, 265, 266, 262,  -2,  -2/
data	(yychk(i),i= 17, 24)	/  -2,  -2, 257,  -6,  -7, 260, 261, 272/
data	(yychk(i),i= 25, 32)	/ 267, 285, 262,  40,  -6, 271, 272, 273/
data	(yychk(i),i= 33, 40)	/ 274, 275, 268, 269, 270, 283, 284, 278/
data	(yychk(i),i= 41, 48)	/ 279, 280, 286, 281, 282, 276,  -6,  -6/
data	(yychk(i),i= 49, 56)	/  -6,  40,  -6,  -8,  -8,  -8,  -8,  -8/
data	(yychk(i),i= 57, 64)	/  -8,  -8,  -8,  -8,  -8,  -8,  -8,  -8/
data	(yychk(i),i= 65, 72)	/  -8,  -8,  -8,  -8,  -9,  -6,  41,  -6/
data	(yychk(i),i= 73, 80)	/ 259,  -6,  -6,  -6,  -6,  -6,  -6,  -6/
data	(yychk(i),i= 81, 88)	/  -6,  -6,  -6,  -6,  -6,  -6,  -6,  -6/
data	(yychk(i),i= 89, 95)	/  -6,  41,  44, 277,  -6,  -8,  -6/
short	yydef[95]
data	(yydef(i),i=  1,  8)	/   1,  -2,   2,   0,   0,   0,   0,   7/
data	(yydef(i),i=  9, 16)	/  11,  12,   0,   0,   8,  41,   3,   4/
data	(yydef(i),i= 17, 24)	/   5,   6,   0,   9,  13,  14,  15,   0/
data	(yydef(i),i= 25, 32)	/   0,   0,  41,   0,  10,  42,  42,  42/
data	(yydef(i),i= 33, 40)	/  42,  42,  42,  42,  42,  42,  42,  42/
data	(yydef(i),i= 41, 48)	/  42,  42,  42,  42,  42,  42,  16,  17/
data	(yydef(i),i= 49, 56)	/  18,  38,   0,   0,   0,   0,   0,   0/
data	(yydef(i),i= 57, 64)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yydef(i),i= 65, 72)	/   0,   0,   0,   0,   0,  39,  37,  19/
data	(yydef(i),i= 73, 80)	/  43,  20,  21,  22,  23,  24,  25,  26/
data	(yydef(i),i= 81, 88)	/  27,  28,  -2,  -2,  -2,  -2,  -2,  -2/
data	(yydef(i),i= 89, 95)	/   0,  36,   0,  42,  40,   0,  35/

begin
	call smark (yysp)
	call salloc (yyv, (YYMAXDEPTH+2) * YYOPLEN, TY_STRUCT)

	# Initialization.  The first element of the dynamically allocated
	# token value stack (yyv) is used for yyval, the second for yylval,
	# and the actual stack starts with the third element.

	yystate = 0
	yychar = -1
	yynerrs = 0
	yyerrflag = 0
	yyps = 0
	yyval = yyv
	yylval = yyv + YYOPLEN
	yypv = yylval

yystack_
	# SHIFT -- Put a state and value onto the stack.  The token and
	# value stacks are logically the same stack, implemented as two
	# separate arrays.

	if (yydebug) {
	    call printf ("state %d, char 0%o\n")
		call pargs (yystate)
		call pargi (yychar)
	}
	yyps = yyps + 1
	yypv = yypv + YYOPLEN
	if (yyps > YYMAXDEPTH) {
	    call sfree (yysp)
	    call eprintf ("yacc stack overflow\n")
	    return (ERR)
	}
	yys[yyps] = yystate
	YYMOVE (yyval, yypv)

yynewstate_
	# Process the new state.
	yyn = yypact[yystate+1]

	if (yyn <= YYFLAG)
	    goto yydefault_			# simple state

	# The variable "yychar" is the lookahead token.
	if (yychar < 0) {
	    yychar = yylex (fd, yylval)
	    if (yychar < 0)
		yychar = 0
	}
	yyn = yyn + yychar
	if (yyn < 0 || yyn >= YYLAST)
	    goto yydefault_

	yyn = yyact[yyn+1]
	if (yychk[yyn+1] == yychar) {		# valid shift
	    yychar = -1
	    YYMOVE (yylval, yyval)
	    yystate = yyn
	    if (yyerrflag > 0)
		yyerrflag = yyerrflag - 1
	    goto yystack_
	}

yydefault_
	# Default state action.

	yyn = yydef[yystate+1]
	if (yyn == -2) {
	    if (yychar < 0) {
		yychar = yylex (fd, yylval)
		if (yychar < 0)
		    yychar = 0
	    }

	    # Look through exception table.
	    yyxi = 1
	    while ((yyexca[yyxi] != (-1)) || (yyexca[yyxi+1] != yystate))
		yyxi = yyxi + 2
	    for (yyxi=yyxi+2;  yyexca[yyxi] >= 0;  yyxi=yyxi+2) {
		if (yyexca[yyxi] == yychar)
		    break
	    }

	    yyn = yyexca[yyxi+1]
	    if (yyn < 0) {
		call sfree (yysp)
		return (OK)			# ACCEPT -- all done
	    }
	}


	# SYNTAX ERROR -- resume parsing if possible.

	if (yyn == 0) {
	    switch (yyerrflag) {
	    case 0, 1, 2:
		if (yyerrflag == 0) {		# brand new error
		    call eprintf ("syntax error\n")
yyerrlab_
		    yynerrs = yynerrs + 1
		    # fall through...
		}

	    # case 1:
	    # case 2: incompletely recovered error ... try again
		yyerrflag = 3

		# Find a state where "error" is a legal shift action.
		while (yyps >= 1) {
		    yyn = yypact[yys[yyps]+1] + YYERRCODE
		    if ((yyn >= 0) && (yyn < YYLAST) &&
			(yychk[yyact[yyn+1]+1] == YYERRCODE)) {
			    # Simulate a shift of "error".
			    yystate = yyact[yyn+1]
			    goto yystack_
		    }
		    yyn = yypact[yys[yyps]+1]

		    # The current yyps has no shift on "error", pop stack.
		    if (yydebug) {
			call printf ("error recovery pops state %d, ")
			    call pargs (yys[yyps])
			call printf ("uncovers %d\n")
			    call pargs (yys[yyps-1])
		    }
		    yyps = yyps - 1
		    yypv = yypv - YYOPLEN
		}

		# ABORT -- There is no state on the stack with an error shift.
yyabort_
		call sfree (yysp)
		return (ERR)


	    case 3: # No shift yet; clobber input char.

		if (yydebug) {
		    call printf ("error recovery discards char %d\n")
			call pargi (yychar)
		}

		if (yychar == 0)
		    goto yyabort_		# don't discard EOF, quit
		yychar = -1
		goto yynewstate_		# try again in the same state
	    }
	}


	# REDUCE -- Reduction by production yyn.

	if (yydebug) {
	    call printf ("reduce %d\n")
		call pargs (yyn)
	}
	yyps  = yyps - yyr2[yyn+1]
	yypvt = yypv
	yypv  = yypv - yyr2[yyn+1] * YYOPLEN
	YYMOVE (yypv + YYOPLEN, yyval)
	yym   = yyn

	# Consult goto table to find next state.
	yyn = yyr1[yyn+1]
	yyj = yypgo[yyn+1] + yys[yyps] + 1
	if (yyj >= YYLAST)
	    yystate = yyact[yypgo[yyn+1]+1]
	else {
	    yystate = yyact[yyj+1]
	    if (yychk[yystate+1] != -yyn)
		yystate = yyact[yypgo[yyn+1]+1]
	}

	# Perform action associated with the grammar rule, if any.
	switch (yym) {
	    
case 2:
# line 88 "imcalc.yy"
{
			return (OK)
		    }
case 3:
# line 91 "imcalc.yy"
{
			return (OK)
		    }
case 4:
# line 94 "imcalc.yy"
{
			return (OK)
		    }
case 5:
# line 97 "imcalc.yy"
{
			return (OK)
		    }
case 6:
# line 100 "imcalc.yy"
{
			return (EOF)
		    }
case 7:
# line 103 "imcalc.yy"
{
			return (EOF)
		    }
case 8:
# line 108 "imcalc.yy"
{
			call imc_cmd(O_VALC(yypvt))
		}
case 9:
# line 112 "imcalc.yy"
{
			call imc_print(O_REGISTER(yypvt), yyval)
		    }
case 10:
# line 117 "imcalc.yy"
{
			# Put a line to the output image.
			call imc_store (O_VALC(yypvt-2*YYOPLEN), O_REGISTER(yypvt), yyval)
		    }
case 13:
# line 127 "imcalc.yy"
{
			# Load the next line of an input image.
			call imc_load (O_VALC(yypvt), yyval)
		    }
case 14:
# line 131 "imcalc.yy"
{
			# floating constant.
			call imc_float (O_VALR(yypvt), yyval)
		    }
case 15:
# line 135 "imcalc.yy"
{
			# integer constant.
			call imc_int (O_VALI(yypvt), yyval)
		    }
case 16:
# line 139 "imcalc.yy"
{
			# Unary arithmetic minus.
			call imc_unop (OP_NEG, O_REGISTER(yypvt), yyval)
		    }
case 17:
# line 143 "imcalc.yy"
{
			# Boolean not.
			call imc_unop (OP_BNOT, O_REGISTER(yypvt), yyval)
		    }
case 18:
# line 147 "imcalc.yy"
{
			# Logical not.
			call imc_unop (OP_LNOT, O_REGISTER(yypvt), yyval)
		    }
case 19:
# line 151 "imcalc.yy"
{
			# Addition.
			call imc_binop (OP_ADD, O_REGISTER(yypvt-3*YYOPLEN),
						O_REGISTER(yypvt), yyval)
		    }
case 20:
# line 156 "imcalc.yy"
{
			# Subtraction.
			call imc_binop (OP_SUB, O_REGISTER(yypvt-3*YYOPLEN),
						O_REGISTER(yypvt), yyval)
		    }
case 21:
# line 161 "imcalc.yy"
{
			# Multiplication.
			call imc_binop (OP_MUL, O_REGISTER(yypvt-3*YYOPLEN),
						O_REGISTER(yypvt), yyval)
		    }
case 22:
# line 166 "imcalc.yy"
{
			# Division.
			call imc_binop (OP_DIV, O_REGISTER(yypvt-3*YYOPLEN),
						O_REGISTER(yypvt), yyval)
		    }
case 23:
# line 171 "imcalc.yy"
{
			# Exponentiation.
			call imc_binop (OP_POW, O_REGISTER(yypvt-3*YYOPLEN),
						O_REGISTER(yypvt), yyval)
		    }
case 24:
# line 176 "imcalc.yy"
{
			# Boolean and.
			call imc_boolop (OP_BAND, O_REGISTER(yypvt-3*YYOPLEN),
						  O_REGISTER(yypvt), yyval)
		    }
case 25:
# line 181 "imcalc.yy"
{
			# Boolean or.
			call imc_boolop (OP_BOR, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 26:
# line 186 "imcalc.yy"
{
			# Boolean or.
			call imc_boolop (OP_BXOR, O_REGISTER(yypvt-3*YYOPLEN),
						  O_REGISTER(yypvt), yyval)
		    }
case 27:
# line 191 "imcalc.yy"
{
			# Logical and.
			call imc_logicop (OP_LAND, O_REGISTER(yypvt-3*YYOPLEN),
						   O_REGISTER(yypvt), yyval)
		    }
case 28:
# line 196 "imcalc.yy"
{
			# Logical or.
			call imc_logicop (OP_LOR, O_REGISTER(yypvt-3*YYOPLEN),
						  O_REGISTER(yypvt), yyval)
		    }
case 29:
# line 201 "imcalc.yy"
{
			# Logical less than.
			call imc_logicop (OP_LT, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 30:
# line 206 "imcalc.yy"
{
			# Logical greater than.
			call imc_logicop (OP_GT, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 31:
# line 211 "imcalc.yy"
{
			# Logical less than or equal.
			call imc_logicop (OP_LE, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 32:
# line 216 "imcalc.yy"
{
			# Logical greater than or equal.
			call imc_logicop (OP_GE, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 33:
# line 221 "imcalc.yy"
{
			# Logical equal.
			call imc_logicop (OP_EQ, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 34:
# line 226 "imcalc.yy"
{
			# Logical not equal.
			call imc_logicop (OP_NE, O_REGISTER(yypvt-3*YYOPLEN),
						 O_REGISTER(yypvt), yyval)
		    }
case 35:
# line 231 "imcalc.yy"
{
			# Conditional expression.
			call imc_quest (O_REGISTER(yypvt-6*YYOPLEN),
					O_REGISTER(yypvt-3*YYOPLEN), O_REGISTER(yypvt), yyval)
		    }
case 36:
# line 236 "imcalc.yy"
{
			# Function call.
			call imc_call (O_VALC(yypvt-3*YYOPLEN), O_VALI(yypvt-YYOPLEN), yyval)
		    }
case 37:
# line 240 "imcalc.yy"
{
			YYMOVE (yypvt-YYOPLEN, yyval)
		    }
case 38:
# line 245 "imcalc.yy"
{
			# Empty.
			call imc_startarglist (NULL, yyval)
		    }
case 39:
# line 249 "imcalc.yy"
{
			# First arg; start a nonnull list.
			call imc_startarglist (O_REGISTER(yypvt), yyval)
		    }
case 40:
# line 253 "imcalc.yy"
{
			# Add an argument to an existing list.
			call imc_addarg (O_VALI(yypvt-2*YYOPLEN), O_REGISTER(yypvt), yyval)
		    }
case 41:
# line 259 "imcalc.yy"
{
			# Image or image section.
			YYMOVE (yypvt, yyval)
		    }	}

	goto yystack_				# stack new state and value
end
