#$Header: /home/pros/RCS/imcalc.yy,v 9.0 1995/11/16 18:33:45 prosb Rel $
#$Log: imcalc.yy,v $
#Revision 9.0  1995/11/16  18:33:45  prosb
#General Release 2.4
#
#Revision 8.1  1995/08/07  18:14:23  prosb
#jcc - ci for pros2.4.
#
#Revision 8.0  94/06/27  14:44:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:58  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:33:56  mo
#MC	7/2/93		Correct string initialization to use index=1
#
#Revision 6.0  93/05/24  16:05:48  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:36  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:46  prosb
#General Release 1.1
#
#Revision 2.1  91/05/07  16:00:25  pros
#changed input param buf size from SZ_FNAME to SZ_LINE (64 to 160)
#to allow long commands to be input directly via the input parameter.
#also make a check for missing closed quote on strings (I just noticed
#it in passing!)
#Eric
#
#Revision 2.0  91/03/06  23:31:28  pros
#General Release 1.0
#

#
# SPP/Yacc parser for the image calculator task.  The function of the parser is
# to parse statements from the input until end of file is reached.  The inner
# machine of the image calculator is a virtual cpu with vector instructions and
# registers for all SPP datatypes.  Each input statement as it is parsed is
# compiled into a sequence of metacode instructions later used to drive the
# virtual cpu.  Compile time constant expressions are evaluated at compile
# time.  The operand image files are opened as they are encounted in the input.
# Vector registers are allocated as necessary during compilation.  No attempt
# is presently made to reuse vector registers.  All string data, e.g., image
# section names, is stored in a string buffer and accessed by pointer.
#

%{
include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>

include	"imcalc.h"

define	yyparse	imc_parse
define	yylex   imc_lex

%L
include	"imcalc.com"
%}

%token		EQUALS SEMICOLON NEWLINE FLOAT INTEGER IDENTIFIER YYEOF
%token		QUIT PRINT CMD
%token		BNOT BAND BOR BXOR
%token		PLUS MINUS STAR SLASH EXPON QUEST COLON
%token		LT GT LE GT EQ NE LAND LOR LNOT

%nonassoc	QUEST
%left		LOR
%left 		LAND
%left		BOR
%left		BXOR
%left 		BAND
%nonassoc	EQ NE 
%nonassoc	LT GT LE GE
%left		PLUS MINUS
%left		STAR SLASH
%left		EXPON
%right		UMINUS BNOT LNOT

%%

command	:	# Empty.
	|	eost {
			return (OK)
		    }
	|	assign eost {
			return (OK)
		    }
	|	print eost {
			return (OK)
		    }
	|	cmd eost {
			return (OK)
		    }
	|	QUIT eost {
			return (EOF)
		    }
	|	YYEOF {
			return (EOF)
		    }
	;

cmd	:	CMD {
			call imc_cmd(O_VALC($1))
		}

print	:	PRINT expr {
			call imc_print(O_REGISTER($2), $$)
		    }
	;

assign	:	image EQUALS expr {
			# Put a line to the output image.
			call imc_store (O_VALC($1), O_REGISTER($3), $$)
		    }
	;

eost	:	SEMICOLON
	|	NEWLINE
	;

expr	:	image {
			# Load the next line of an input image.
			call imc_load (O_VALC($1), $$)
		    }
	|	FLOAT {
			# floating constant.
			call imc_float (O_VALR($1), $$)
		    }
	|	INTEGER {
			# integer constant.
			call imc_int (O_VALI($1), $$)
		    }
	|	MINUS expr %prec UMINUS {
			# Unary arithmetic minus.
			call imc_unop (OP_NEG, O_REGISTER($2), $$)
		    }
	|	BNOT expr {
			# Boolean not.
			call imc_unop (OP_BNOT, O_REGISTER($2), $$)
		    }
	|	LNOT expr {
			# Logical not.
			call imc_unop (OP_LNOT, O_REGISTER($2), $$)
		    }
	|	expr PLUS opnl expr {
			# Addition.
			call imc_binop (OP_ADD, O_REGISTER($1),
						O_REGISTER($4), $$)
		    }
	|	expr MINUS opnl expr {
			# Subtraction.
			call imc_binop (OP_SUB, O_REGISTER($1),
						O_REGISTER($4), $$)
		    }
	| 	expr STAR opnl expr {
			# Multiplication.
			call imc_binop (OP_MUL, O_REGISTER($1),
						O_REGISTER($4), $$)
		    }
	|	expr SLASH opnl expr {
			# Division.
			call imc_binop (OP_DIV, O_REGISTER($1),
						O_REGISTER($4), $$)
		    }
	|	expr EXPON opnl expr {
			# Exponentiation.
			call imc_binop (OP_POW, O_REGISTER($1),
						O_REGISTER($4), $$)
		    }
	|	expr BAND opnl expr {
			# Boolean and.
			call imc_boolop (OP_BAND, O_REGISTER($1),
						  O_REGISTER($4), $$)
		    }
	|	expr BOR opnl expr {
			# Boolean or.
			call imc_boolop (OP_BOR, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr BXOR opnl expr {
			# Boolean or.
			call imc_boolop (OP_BXOR, O_REGISTER($1),
						  O_REGISTER($4), $$)
		    }
	|	expr LAND opnl expr {
			# Logical and.
			call imc_logicop (OP_LAND, O_REGISTER($1),
						   O_REGISTER($4), $$)
		    }
	|	expr LOR opnl expr {
			# Logical or.
			call imc_logicop (OP_LOR, O_REGISTER($1),
						  O_REGISTER($4), $$)
		    }
	|	expr LT opnl expr {
			# Logical less than.
			call imc_logicop (OP_LT, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr GT opnl expr {
			# Logical greater than.
			call imc_logicop (OP_GT, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr LE opnl expr {
			# Logical less than or equal.
			call imc_logicop (OP_LE, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr GE opnl expr {
			# Logical greater than or equal.
			call imc_logicop (OP_GE, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr EQ opnl expr {
			# Logical equal.
			call imc_logicop (OP_EQ, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr NE opnl expr {
			# Logical not equal.
			call imc_logicop (OP_NE, O_REGISTER($1),
						 O_REGISTER($4), $$)
		    }
	|	expr QUEST opnl expr COLON opnl expr {
			# Conditional expression.
			call imc_quest (O_REGISTER($1),
					O_REGISTER($4), O_REGISTER($7), $$)
		    }
	|	IDENTIFIER '(' arglist ')' {
			# Function call.
			call imc_call (O_VALC($1), O_VALI($3), $$)
		    }
	|	'(' expr ')' {
			YYMOVE ($2, $$)
		    }
	;

arglist	:	{
			# Empty.
			call imc_startarglist (NULL, $$)
		    }
	|	expr {
			# First arg; start a nonnull list.
			call imc_startarglist (O_REGISTER($1), $$)
		    }
	|	arglist ',' expr {
			# Add an argument to an existing list.
			call imc_addarg (O_VALI($1), O_REGISTER($3), $$)
		    }
	;

image	:	IDENTIFIER {
			# Image or image section.
			YYMOVE ($1, $$)
		    }
	;

opnl	:	# 
	|	opnl NEWLINE
	;

%%

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

