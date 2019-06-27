#$Header: /home/pros/RCS/ytab.x,v 9.0 1995/11/16 19:31:19 prosb Rel $
#$Log: ytab.x,v $
# Revision 9.0  1995/11/16  19:31:19  prosb
# General Release 2.4
#
# Revision 1.2  1995/08/08  14:27:19  prosb
# jcc - ci for pros2.4.
#
include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>
include <fio.h>

include	"modparse.h"

define	NUMERAL		257
define	MODEL		258
define	ABSORPTION		259
define	FILE		260
define	LINK		261
define	FUNC		262
define	ABSTYPE		263
define	YYEOF		264
define	SEMICOLON		265
define	NEWLINE		266
define	LIST		267
define	PLUS		268
define	STAR		269
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 184 "modparse.yy"


#
# MOD_PARSE -- Main routine for the parsing a model descriptor
#
int procedure mod_parse(fp, s, debug)

pointer	fp			# i: spectral frame pointer
char	s[ARB]			# i: model descriptor string
int	debug			# i: debug flag

int	got			# l: return from mod_parser
int	mod_parser()		# l: common code

begin
	got = mod_parser(fp, s, debug, YES)
	return(got)
end

#
# MOD_PARSER -- common code for mod_parse and mod_notes
#
int procedure mod_parser(fp, s, debug, domodel)

pointer	fp			# i: spectral frame pointer
char	s[ARB]			# i: model descriptor string
int	debug			# i: debug flag
int	domodel			# i: YES=do it, NO=reserved for future use

int	status			# l: returned status from mod_yyparse
int	complete		# l: completion flag = 1 if no errors
int	tdebug			# l: mod_yyparse debug flag
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	mod_yyparse()		# l: parser
bool	streq()			# l: string compare
extern	mod_lex()		# l: lexical analyzer

include "modparse.com"

begin
	# mark the stack
	call smark(sp)

	# the domodel flag is for future use and should be YES
	if( domodel != YES )
	    call error(1, "internal model error: domodel is NO!!??")

	# init some values
	mod_fp = fp			# used in mod_create
	mod_fdlev = 0			# no nested includes yet
	mod_installed = 0		# no installed models yet
	mod_lptr = 0 			# no string to parse yet
	mod_debug = debug		# set global debug flag
	mod_eflag = NO			# no errors as yet
	mod_namelen = NAMEINC		# init the size of the name buffer
	mod_nmodels = 0			# no models yet
	# first link value is > total number of params
	# which in turn is the number of models times params/model
	mod_link = MAX_LINKS + 1
	complete = YES			# assume the best
	# set the mod_yyparse debug flag
	if( debug >= 10 )
	    tdebug = 1
	else
	    tdebug = 0
	# allocate some buffers
	call salloc(mod_sbuf, SZ_SBUF, TY_CHAR)		# string buffer
	call salloc(mod_name, SZ_LINE, TY_CHAR)		# current model name
	call salloc(mod_allnames, mod_namelen, TY_CHAR)	# all models
	call strcpy("", Memc[mod_name], SZ_LINE)
	call strcpy("", Memc[mod_allnames], mod_namelen)

	# install the default shapes
	call mod_def()

	# null string is an error
	if( streq("", s) )
	    call error(1, "no models specified")

	# create a spool file for the command string
	mod_fd = open("spool1", READ_WRITE, SPOOL_FILE)
	# write the s buffer to the file
	call fprintf(mod_fd, "%s\n")
	call pargstr(s)
	# rewind the spool file
	call seek(mod_fd, BOF)
	# set it up as first in fd list
	mod_fdlev = 1
	mod_fds[mod_fdlev] = mod_fd

	# compile and execute model specifications
	repeat {
	    # reset pointers
	    call mod_reset()
	    # parse and compile meta-code
	    status = mod_yyparse (mod_fd, tdebug, mod_lex)
	    # on a syntax error, drop out
	    if( status == ERR ){
		call printf("line: %s")
		call pargstr(mod_lbuf)
		call flush(STDOUT)
		complete = NO		
	    }
	} until(status != OK)

	# finish up
	if( complete == YES ){
	    # resolve links
	    call mod_resolve_links(fp)
	    # check for a free absorption param in first model
	    # and change to a CALC_PARAM (do this after resolving links!)
	    call mod_free_alpha(fp)
	    # fill in the delta defaults
#	    call mod_dlt_defs(fp)
	    # allocate space for the model string
	    call calloc(FP_MODSTR(fp), mod_namelen, TY_CHAR)
	    # strip the last <CR>s`'s, if necessary
	    # John and Eric played with this code until it waved the white flag
	    # and then we went home and told our friends!  11:59 AM
	    # AND THEN WE COMMENTED IT OUT!!! 12:01 PM
#	    if( mod_namelen >0 ){
#		while( Memc[mod_allnames+mod_namelen-1] == '\n' ){
#		    Memc[mod_allnames+mod_namelen-1] = EOS
#		    mod_namelen = mod_namelen - 1
#		    if( mod_namelen ==0 )
#			break
#	        }
#	    }
	    # move the model string into the frame
	    call amovc(Memc[mod_allnames], Memc[FP_MODSTR(fp)], mod_namelen)
	}

	call close(mod_fd)

	# free up the allocated space
	call sfree(sp)

	# return the news
	return(complete)
end

#
# MOD_LEX -- Lexical input routine.  Return next token from the input stream
#
int procedure mod_lex (fd, yylval)

int	fd			# i: input file channel
pointer	yylval			# o: output value for parser stack

char	cbuf[SZ_LINE]		# l: temp char buffer
int	nchars			# l: number of chars in lexnum
int	token			# l: token type
int	junk			# l: for grabbing unneeded function values
int	type			# l: type of token - returned by function
int	index			# l: index into string
int	ival			# l: temp integer value
real	rval			# l: temp real value
double	dval			# l: numeric value of string
pointer	s			# l: pointer to model name or file name

int	mod_isfile()		# l: check whether s is a valid file name
int	mod_lookup()		# l: check whether s is a valid model
int	mod_islink()		# l: check for a link
int	mod_isabund()		# l: check for abundance string
int	mod_isfunc()		# l: check for function
int	mod_isabsty()		# l: check for absorption type
int	lexnum()		# l: lex number analyzer
int	getline()		# l: get a line
int	gctod()			# l: ASCII to decimal
int	strlen()		# l: string length
int	stridx()		# l: index into string

include "modparse.com"

begin
	# Fetch a nonempty input line, or advance to start of next token
	# if within a line.  Newline is a token.
	while( mod_lptr == 0) {
	    # read next line
	    if (getline (fd, mod_lbuf) == EOF) {
		# on end of file, check for a pushed file
		if( mod_fdlev == 1 ){
		  return (YYEOF)
		}
		# and pop it
		else
		  call mod_popfd()
	    } else{
		# skip white space
		while (IS_WHITE (mod_lbuf[mod_lptr])){
			mod_lptr = mod_lptr + 1
			call mod_addspace()
		}
		# skip blank lines and lines beginning with "#"
		if( (strlen(mod_lbuf) >1) && (mod_lbuf[1] != '#') ){
		    # point the lptr to the first character
		    mod_lptr = 1
		}
	    }
	}

	# skip white space
	while (IS_WHITE (mod_lbuf[mod_lptr])){
		mod_lptr = mod_lptr + 1
		call mod_addspace()
	}

	# Determine type of token.  If numeric constant, convert to binary
	# and return value in op structure (yylval).
	# Otherwise, check for punctuation, models, and files
	if( (IS_DIGIT(mod_lbuf[mod_lptr]))	|| 
	    (mod_lbuf[mod_lptr] == '-')		||
	    (mod_lbuf[mod_lptr] == '.') ){
	    # get type of numeral
	    token = lexnum (mod_lbuf, mod_lptr, nchars)
	}
	else{
	    # grab the next character
	    token = mod_lbuf[mod_lptr]
	    # bump mod_lptr
	    mod_lptr = mod_lptr+1
	    # seed the return value - this might be overwritten
	    O_VALI(yylval) = token
	}

	# process the token
	switch (token) {

	case LEX_OCTAL, LEX_DECIMAL, LEX_HEX, LEX_REAL:
	    # remove any ":" temporarily
	    # since gctod thinks its part of a number
	    index = stridx(":", mod_lbuf[mod_lptr])
	    if( index !=0 ){
		# get real index, since we are about to lose mod_lptr!
		index = index + mod_lptr - 1
		mod_lbuf[index] = '#'
	    }
	    # convert ASCII to number
	    junk = gctod (mod_lbuf, mod_lptr, dval)
	    # restore the ":"
	    if( index !=0 )
		mod_lbuf[index] = ':'
	    O_VALR(yylval) = dval
	    type = NUMERAL
	    # if last character is not space (from a function), add one
#	    call mod_addspace()
	    call sprintf(cbuf, SZ_LINE, "%.3f")
	    call pargr(O_VALR(yylval))
	    call strcat(cbuf, Memc[mod_name], SZ_LINE)
	    # check for modifiers on the value
	    call mod_modifiers(yylval)
	    # add a space to finish argument
	 
	case ';':
	    type = SEMICOLON

	case '\n':
	    type = NEWLINE
	    mod_lptr = 0

	case '#':
	    # skip to end of statement
	    while( (mod_lbuf[mod_lptr] != ';' ) &&
		   (mod_lbuf[mod_lptr] != '\n') &&
		   (mod_lbuf[mod_lptr] != EOS ) )
		mod_lptr = mod_lptr + 1
	    # get correct type for terminator
	    switch(mod_lbuf[mod_lptr]){
	    case ';':
		mod_lptr = mod_lptr + 1
		type = SEMICOLON
	    case '\n':
		mod_lptr = 0
		type = NEWLINE
	    case EOS:
		mod_lptr = 0
		type = NEWLINE
	    }

	case '+':
	    type = PLUS
	    call mod_addtoken("+")

	case '*':
	    type = STAR
	    call mod_addtoken("*")

	case '(':
	    type = '('
	    call mod_addtoken("(")

	case ')':
	    type = ')'
	    call mod_addtoken(")")

	case ',':
	    type = ','
	    call mod_addtoken(",")

	case 'L', 'l':
	    if( mod_islink(yylval) == YES ){
		type = LINK
		O_VALR(yylval) = 0.0
	    }
	    else
		goto 10

	case '"':
	    # point the s string at the next available buffer space
	    s = mod_nextch
	    # grab characters up to closed quote
	    while( mod_lbuf[mod_lptr] != '"' ){
		# add the char to the string
		Memc[mod_nextch] = mod_lbuf[mod_lptr]
		# and bump the pointers
		mod_nextch = mod_nextch + 1
		mod_lptr=mod_lptr+1
	    }
	    # bump past the close quote
	    mod_lptr = mod_lptr + 1
	    # join common code
	    goto 20

	# identifier
	default:
	    # point the s string at the next available buffer space
10	    s = mod_nextch
	    # put this token into the next available buffer space
	    Memc[mod_nextch] = token
	    # and bump the next available buffer space
	    mod_nextch = mod_nextch + 1

	    # grab string up to delimiter
	    while( !IS_WHITE(mod_lbuf[mod_lptr]) &&
		   (mod_lbuf[mod_lptr] != ';')   &&
		   (mod_lbuf[mod_lptr] != ',')   &&
		   (mod_lbuf[mod_lptr] != '(')   &&
		   (mod_lbuf[mod_lptr] != ')')   &&
		   (mod_lbuf[mod_lptr] != '#')   &&
		   (mod_lbuf[mod_lptr] != EOS)   &&
		   (mod_lbuf[mod_lptr] != '\n') ){
		    # add the char to the string
		    Memc[mod_nextch] = mod_lbuf[mod_lptr]
		    # and bump the pointers
		    mod_nextch = mod_nextch + 1
		    mod_lptr=mod_lptr+1
	    }

	    # finish up the string
20	    Memc[mod_nextch] = EOS
	    # bump the "next available" pointer
	    mod_nextch = mod_nextch + 1

	    # check for model keyword
	    if( mod_lookup(Memc[s],
		O_NAME(yylval), O_CODE(yylval),
		O_MINARGS(yylval), O_MAXARGS(yylval), type) == YES ){
		# just copy the first 3 letters!
		call strcpy(Memc[O_NAME(yylval)], cbuf, 3)
		call strcat(cbuf, Memc[mod_name], SZ_LINE)
	    }
	    # check for file
	    else if( mod_isfile(Memc[s]) == YES ){
		type = FILE
		O_LBUF(yylval) = s
	    }
	    # perhaps its an abundance argument (cosmic or meyer)
	    else if( mod_isabund(Memc[s], cbuf, rval) == YES ){
		type = NUMERAL
		O_VALR(yylval) = rval
		# this can be hardwired in
		O_FIXED(yylval) = FIXED_PARAM
		O_LINK(yylval) = 0
		# add a space if necessary
		call strcat(cbuf, Memc[mod_name], SZ_LINE)
	    }
	    # or perhaps its a function
	    else if( mod_isfunc(Memc[s], cbuf, ival) == YES ){
		O_VALI(yylval) = ival
		type = FUNC
		# add a space if necessary
		call strcat(cbuf, Memc[mod_name], SZ_LINE)
	    }
	    # or perhaps its an absorption type
	    else if( mod_isabsty(Memc[s], cbuf, ival) == YES ){
		O_VALI(yylval) = ival
		type = ABSTYPE
		call strcat(cbuf, Memc[mod_name], SZ_LINE)
	    }
	    # it's an unknown keyword
	    else{
		call sprintf(cbuf, SZ_LINE, "unknown token: %s")
		call pargstr(Memc[s])
		call mod_error(cbuf)
		type = ')'		# cause syntax error
	    }
	}
	# return what we found
	return(type)
end
define	YYNPROD		31
define	YYLAST		242
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

int procedure mod_yyparse (fd, yydebug, yylex)

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


include	"modparse.com"
short	yyexca[30]
data	(yyexca(i),i=  1,  8)	/  -1,   1,   0,  -1,  -2,   0,  -1,  24/
data	(yyexca(i),i=  9, 16)	/ 257,  27, 261,  27, 262,  27,  92,  27/
data	(yyexca(i),i= 17, 24)	/  -2,  15,  -1,  30, 257,  27, 261,  27/
data	(yyexca(i),i= 25, 30)	/ 262,  27,  92,  27,  -2,  17/
short	yyact[242]
data	(yyact(i),i=  1,  8)	/  11,   8,   7,  35,  17,  18,  18,  21/
data	(yyact(i),i=  9, 16)	/   8,   7,  42,  29,  15,  47,  27,  32/
data	(yyact(i),i= 17, 24)	/  27,  23,  50,  28,  26,  28,  11,  25/
data	(yyact(i),i= 25, 32)	/  48,  45,  39,  38,  38,  38,  51,  31/
data	(yyact(i),i= 33, 40)	/   3,  24,  10,   2,  37,   9,   5,  16/
data	(yyact(i),i= 41, 48)	/  19,  20,   4,   1,  22,   0,   0,   0/
data	(yyact(i),i= 49, 56)	/   0,  30,  33,   0,   0,  34,   0,   0/
data	(yyact(i),i= 57, 64)	/   0,  36,   0,   0,   0,   0,   0,  40/
data	(yyact(i),i= 65, 72)	/  41,   0,   0,  44,  43,  46,  49,   0/
data	(yyact(i),i= 73, 80)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 81, 88)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 89, 96)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 97,104)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=105,112)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=113,120)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=121,128)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=129,136)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=137,144)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=145,152)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=153,160)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=161,168)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=169,176)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=177,184)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=185,192)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=193,200)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=201,208)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=209,216)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=217,224)	/   0,   0,  14,  15,  13,   0,   0,  12/
data	(yyact(i),i=225,232)	/   6,   8,   7,   0,  27,   0,  17,  18/
data	(yyact(i),i=233,240)	/  26,  28,  27,   0,   0,   0,  26,  28/
data	(yyact(i),i=241,242)	/  14,  15/
short	yypact[52]
data	(yypact(i),i=  1,  8)	/ -40,-1000,-1000,-264,-257,-257,-1000,-1000/
data	(yypact(i),i=  9, 16)	/-1000,-1000,-262, -18,-1000,-1000, -23, -29/
data	(yypact(i),i= 17, 24)	/-1000, -77, -77,-1000,-1000, -77, -38,-241/
data	(yypact(i),i= 25, 32)	/ -15,-1000,-1000,-1000, -14,-241, -15, -18/
data	(yypact(i),i= 33, 40)	/-256,-247, -18,-1000, -16, -77,-1000,-244/
data	(yypact(i),i= 41, 48)	/ -17,-263,-1000,-1000,-1000,-1000,-243, -11/
data	(yypact(i),i= 49, 52)	/-1000,-1000,-1000,-1000/
short	yypgo[12]
data	(yypgo(i),i=  1,  8)	/   0,  43,  35,  32,  42,  38,  37,  31/
data	(yypgo(i),i=  9, 12)	/  34,  33,  23,  36/
short	yyr1[31]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   1,   3/
data	(yyr1(i),i=  9, 16)	/   3,   3,   3,   3,   4,   5,   6,   6/
data	(yyr1(i),i= 17, 24)	/   8,   8,   9,   9,   9,   9,   9,  10/
data	(yyr1(i),i= 25, 31)	/  10,   7,   7,  11,  11,   2,   2/
short	yyr2[31]
data	(yyr2(i),i=  1,  8)	/   0,   0,   1,   2,   2,   2,   1,   1/
data	(yyr2(i),i=  9, 16)	/   4,   4,   4,   3,   1,   1,   4,   2/
data	(yyr2(i),i= 17, 24)	/   4,   2,   0,   1,   4,   1,   4,   1/
data	(yyr2(i),i= 25, 31)	/   4,   0,   2,   0,   1,   1,   1/
short	yychk[52]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2,  -3,  -4,  -5, 264, 266/
data	(yychk(i),i=  9, 16)	/ 265,  -6,  -8,  40, 263, 260, 258, 259/
data	(yychk(i),i= 17, 24)	/  -2, 268, 269,  -2,  -2, 269,  -3,  40/
data	(yychk(i),i= 25, 32)	/  -9, -10, 261, 257, 262,  40,  -9,  -7/
data	(yychk(i),i= 33, 40)	/  92,  -7,  -7,  41,  -9, -11,  44,  40/
data	(yychk(i),i= 41, 48)	/  -9,  -3, 266,  -8,  -3,  41,  -7, 257/
data	(yychk(i),i= 49, 52)	/  41, -10, 261,  41/
short	yydef[52]
data	(yydef(i),i=  1,  8)	/   1,  -2,   2,   0,   0,   0,   6,  29/
data	(yydef(i),i=  9, 16)	/  30,   7,   0,   0,  12,  13,  18,  18/
data	(yydef(i),i= 17, 24)	/   3,  25,  25,   4,   5,  25,   0,  18/
data	(yydef(i),i= 25, 32)	/  -2,  19,  21,  23,   0,  18,  -2,   0/
data	(yydef(i),i= 33, 40)	/   0,   0,   0,  11,  27,  25,  28,   0/
data	(yydef(i),i= 41, 48)	/  27,   8,  26,  10,   9,  14,   0,   0/
data	(yydef(i),i= 49, 52)	/  16,  20,  22,  24/

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
# line 71 "modparse.yy"
{
			return (OK)
		    }
case 3:
# line 74 "modparse.yy"
{
			call mod_endexpr(yypvt-YYOPLEN, yyval)
			return (OK)
		    }
case 4:
# line 78 "modparse.yy"
{
			call mod_endexpr(yypvt-YYOPLEN, yyval)
			return(OK)
		    }
case 5:
# line 82 "modparse.yy"
{
			return (OK)
		    }
case 6:
# line 85 "modparse.yy"
{
			return (EOF)
		    }
case 7:
# line 90 "modparse.yy"
{
			# New model
			call mod_setup_list(yypvt, yyval)
		    }
case 8:
# line 94 "modparse.yy"
{
			# add two models
			call mod_merge_lists(yypvt-3*YYOPLEN, yypvt, yyval)
		    }
case 9:
# line 98 "modparse.yy"
{
			# apply absorption
			call mod_apply_absorption(yypvt-3*YYOPLEN, yypvt, yyval)
		    }
case 10:
# line 102 "modparse.yy"
{
			# apply absorption
			call mod_apply_absorption(yypvt, yypvt-3*YYOPLEN, yyval)
		    }
case 11:
# line 106 "modparse.yy"
{
			YYMOVE (yypvt-YYOPLEN, yyval)
		    }
case 12:
# line 112 "modparse.yy"
{
			call mod_abstype(yypvt, yyval)
		    }
case 13:
# line 116 "modparse.yy"
{
			# New file
			call mod_newfile(yypvt, yyval)
		    }
case 14:
# line 122 "modparse.yy"
{
			# set up new model
			call mod_setup_model(yypvt-3*YYOPLEN, yypvt-YYOPLEN, yyval)
		    }
case 15:
# line 126 "modparse.yy"
{
			# set up new model
			call mod_setup_model(yypvt-YYOPLEN, yypvt, yyval)
		    }
case 16:
# line 132 "modparse.yy"
{
			# set up new absorption
			call mod_setup_absorption(yypvt-3*YYOPLEN, yypvt-YYOPLEN, yyval)
		    }
case 17:
# line 136 "modparse.yy"
{
			# set up new absorption
			call mod_setup_absorption(yypvt-YYOPLEN, yypvt, yyval)
		    }
case 18:
# line 142 "modparse.yy"
{
			# Empty
			call mod_startarglist (NULL, 0, yyval)
		    }
case 19:
# line 146 "modparse.yy"
{
			# First arg; start a nonnull list.
			call mod_startarglist (yypvt, NUMERAL, yyval)
		    }
case 20:
# line 150 "modparse.yy"
{
			# Add an argument to an existing list.
			call mod_addarg (yypvt-3*YYOPLEN, yypvt, NUMERAL, yyval)
		    }
case 21:
# line 154 "modparse.yy"
{
			# First arg; start a nonnull list.
			call mod_startarglist (yypvt, LINK, yyval)
		    }
case 22:
# line 158 "modparse.yy"
{
			# Add an argument to an existing list.
			call mod_addarg (yypvt-3*YYOPLEN, yypvt, LINK, yyval)
		    }
case 23:
# line 164 "modparse.yy"
{
		    YYMOVE (yypvt, yyval)
		}
case 24:
# line 167 "modparse.yy"
{
		    call mod_function(yypvt-3*YYOPLEN, yypvt-YYOPLEN, yyval)
		}	}

	goto yystack_				# stack new state and value
end
