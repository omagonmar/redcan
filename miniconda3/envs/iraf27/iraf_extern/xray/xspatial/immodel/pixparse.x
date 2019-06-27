#$Header: /home/pros/xray/xspatial/immodel/RCS/pixparse.x,v 11.0 1997/11/06 16:30:27 prosb Exp $
#$Log: pixparse.x,v $
#Revision 11.0  1997/11/06 16:30:27  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:44  prosb
#General Release 2.1
#
#Revision 3.0  91/08/02  01:28:25  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:40  pros
#General Release 1.0
#
include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>

include	"pixparse.h"

define	COMMA		257
define	SEMICOLON		258
define	NEWLINE		259
define	YYEOF		260
define	LPAREN		261
define	RPAREN		262
define	TABLE		263
define	LIST		264
define	COLUMN		265
define	FLOAT		266
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 85 "pixparse.yy"


#  -- Main routine for the pixel parser

int procedure pix_parse(input, x, y, cnts, debug)

char	input[SZ_FNAME]		# i: pixel specification
pointer	x			# o: x values
pointer	y			# o: y values
pointer	cnts			# o: intensities
int	debug			# i: debug level

int	status			# returned status from yyparse
int	fin			# channel for input file
int	y_debug			# yacc debug flag
int	open()			# open a file
int	yyparse()		# parser
pointer sp			# stack pointer
extern	yylex()			# lexical analyzer

include "pixlex.com"
include "pixparse.com"

begin
	# mark the stack
	call smark(sp)
	call salloc( c_sbuf, SZ_SBUF, TY_CHAR)

	# init some pointers, etc.
	c_npix = 0
	c_max = BUFINC
	
	# init the lexical analyzer
	call strcpy("", lbuf, SZ_LINE)
	lptr = 0

	# allocate buffers
	call calloc (c_x, c_max, TY_REAL)
	call calloc (c_y, c_max, TY_REAL)
	call calloc (c_cnts, c_max, TY_REAL)

	# set debug flag
	c_debug = debug
	if( c_debug >= 10 )
	    y_debug = 1
	else
	    y_debug = 0

	# create a spool file for the command string
	fin = open("spool", READ_WRITE, SPOOL_FILE)
	# write the string to it
	call fprintf(fin, "%s\n")
	    call pargstr(input)
	# rewind the spool file
	call seek(fin, BOF)

	# compile and execute
	repeat {
	    # no tokens parsed yet
	    c_tokens = 0
	    # set current string pointer back to beginning
	    c_nextch = c_sbuf
	    # parse the pixel spec
	    status = yyparse (fin, y_debug, yylex)
	    if (status == ERR){
		call eprintf ("line: %s")
		call pargstr(lbuf)
		break
	    }
	    if (c_error == YES ){
		break
	    }
	} until (status == EOF)

	# check for errors
	if( (c_error == YES) || (status == ERR) ){
	    # free up any stored space
	    call mfree (c_x, TY_REAL)
	    call mfree (c_y, TY_REAL)
	    call mfree (c_cnts, TY_REAL)
	    # we didn't really get any pixels
	    c_npix = 0
	}
	else{
	    # reallocate buffers just to needed size
	    call realloc (c_x, c_npix, TY_REAL)
	    call realloc (c_y, c_npix, TY_REAL)
	    call realloc (c_cnts, c_npix, TY_REAL)
	    # and store pointers where they belong
	    x = c_x
	    y = c_y
	    cnts = c_cnts
	}

	# free up the allocated space
	call sfree(sp)

	# return the number of pixels
	return(c_npix)
end

# YYLEX -- Lexical input routine.  Return next token from the input
# stream.

int procedure yylex (fd, yylval)

int	fd			# i: input file channel
pointer	yylval			# o: output value for parser stack
int	nchars			# l: number of chars in lexnum
int	ch			# l: just a char
int	token			# l: token type
int	junk			# l: for grabbing unneeded function values
int	type			# l: type of token - returned by function
double	dval			# l: numeric value of string
int	lexnum(), getline(), gctod()
int	access()

include "pixlex.com"
include "pixparse.com"

begin
	# end parsing and force a new getline, if we get an error
	if( c_error == YES ){
		type = SEMICOLON
		lptr = 0
		return(type)
	}

	# Fetch a nonempty input line, or advance to start of next token
	# if within a line.  Newline is a token.
	while (lptr == 0) {
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

	# all numbers are converted to float
	case LEX_OCTAL, LEX_DECIMAL, LEX_HEX, LEX_REAL:
	    # convert ASCII to number
	    junk = gctod (lbuf, lptr, dval)
	    O_TYPE(yylval) = TY_REAL
	    O_VALR(yylval) = dval
	    type = FLOAT
	 
	case ';':
	    type = SEMICOLON

	case '(':
	    type = LPAREN

	case ')':
	    type = RPAREN

	case ',':
	    type = COMMA

	case '\n':
	    type = NEWLINE
	    # grab new line on next loop
	    lptr = 0

	# comment character fakes a new line
	case '#':
	    type = NEWLINE
	    # grab new line on next loop
	    lptr = 0

	# quoted string
	case '"':
	    # point return yylval value to current place in string buffer
	    O_LBUF(yylval) = c_nextch

	    # get chars in name up to closing "
	    while( lbuf[lptr] != '"' ){
		    # add the char to the string
		    Memc[c_nextch] = lbuf[lptr]
		    c_nextch = c_nextch + 1
		    lptr=lptr+1
	    }
	    # point past the final quote
	    lptr=lptr+1

	    # join common code with unquoted strings
	    goto 99

	# identifier
	default:
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

#	    common code for quoted and unquoted strings
99	    # finish up the string
	    Memc[c_nextch] = EOS
	    # and point to next available place in buffer
	    c_nextch = c_nextch + 1

	    # check type
	    if( access(Memc[O_LBUF(yylval)], 0, TEXT_FILE) == YES )
		type = LIST
	    else if( access(Memc[O_LBUF(yylval)], 0, BINARY_FILE) == YES )
		type = TABLE
	    else
		type = COLUMN
	}

	# inc the number of tokens parsed in this expression
	c_tokens = c_tokens+1

	# return the type
	return(type)
end
define	YYNPROD		18
define	YYLAST		50
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


include	"pixparse.com"
short	yyexca[12]
data	(yyexca(i),i=  1,  8)	/  -1,   1,   0,  -1,  -2,   0,  -1,  15/
data	(yyexca(i),i=  9, 12)	/ 265,  16,  -2,  11/
short	yyact[50]
data	(yyact(i),i=  1,  8)	/   7,   8,   6,  28,  21,  10,   9,  16/
data	(yyact(i),i=  9, 16)	/  11,  31,  29,  15,  27,  22,  20,  18/
data	(yyact(i),i= 17, 24)	/  32,   7,   8,  18,  23,  17,   2,   5/
data	(yyact(i),i= 25, 32)	/   4,   3,  12,  13,  14,   1,   0,   0/
data	(yyact(i),i= 33, 40)	/   0,   0,   0,   0,   0,  19,   0,   0/
data	(yyact(i),i= 41, 48)	/   0,   0,  24,  25,  26,   0,   0,   0/
data	(yyact(i),i= 49, 50)	/   0,  30/
short	yypact[33]
data	(yypact(i),i=  1,  8)	/-258,-1000,-1000,-241,-241,-241,-1000,-1000/
data	(yypact(i),i=  9, 16)	/-1000,-1000,-254,-238,-1000,-1000,-1000,-238/
data	(yypact(i),i= 17, 24)	/-251,-262,-1000,-252,-242,-238,-238,-1000/
data	(yypact(i),i= 25, 32)	/-253,-263,-255,-238,-1000,-1000,-256,-246/
data	(yypact(i),i= 33, 33)	/-1000/
short	yypgo[7]
data	(yypgo(i),i=  1,  7)	/   0,  29,  22,  25,  24,  23,  21/
short	yyr1[18]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   1,   2/
data	(yyr1(i),i=  9, 16)	/   2,   3,   4,   4,   4,   4,   4,   5/
data	(yyr1(i),i= 17, 18)	/   6,   6/
short	yyr2[18]
data	(yyr2(i),i=  1,  8)	/   0,   0,   1,   2,   2,   2,   1,   1/
data	(yyr2(i),i=  9, 16)	/   1,   1,   1,   2,   4,   6,   8,   5/
data	(yyr2(i),i= 17, 18)	/   0,   1/
short	yychk[33]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2,  -3,  -4,  -5, 260, 258/
data	(yychk(i),i=  9, 16)	/ 259, 264, 263, 266,  -2,  -2,  -2, 265/
data	(yychk(i),i= 17, 24)	/ 261,  -6, 257,  -6, 265, 266, 265, 262/
data	(yychk(i),i= 25, 32)	/  -6,  -6,  -6, 265, 266, 265,  -6, 265/
data	(yychk(i),i= 33, 33)	/ 262/
short	yydef[33]
data	(yydef(i),i=  1,  8)	/   1,  -2,   2,   0,   0,   0,   6,   7/
data	(yydef(i),i=  9, 16)	/   8,   9,  10,  16,   3,   4,   5,  -2/
data	(yydef(i),i= 17, 24)	/   0,   0,  17,   0,  16,  16,  16,  12/
data	(yydef(i),i= 25, 32)	/   0,   0,   0,  16,  15,  13,   0,   0/
data	(yydef(i),i= 33, 33)	/  14/

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
# line 25 "pixparse.yy"
{
			return (OK)
		    }
case 3:
# line 28 "pixparse.yy"
{
			return (OK)
		    }
case 4:
# line 31 "pixparse.yy"
{
			return (OK)
		    }
case 5:
# line 34 "pixparse.yy"
{
			return (OK)
		    }
case 6:
# line 37 "pixparse.yy"
{
			return (EOF)
		    }
case 9:
# line 46 "pixparse.yy"
{
			# Load the next line of an input image.
			call pix_list (O_VALC(yypvt), yyval)
		    }
case 10:
# line 52 "pixparse.yy"
{
			# Process this table file - default args
			call pix_table (O_VALC(yypvt), DEFX, DEFY, DEFCNTS, yyval)
		}
case 11:
# line 56 "pixparse.yy"
{
			# Process this table file - default args for x and y
			call pix_table (O_VALC(yypvt-YYOPLEN), DEFX, DEFY, O_VALC(yypvt), yyval)
		}
case 12:
# line 60 "pixparse.yy"
{
			# Process this table file - default args for x and y
			call pix_table (O_VALC(yypvt-3*YYOPLEN), DEFX, DEFY, O_VALC(yypvt-YYOPLEN), yyval)
		}
case 13:
# line 64 "pixparse.yy"
{
			# Process this table file - no default args
			call pix_table (O_VALC(yypvt-5*YYOPLEN), O_VALC(yypvt-4*YYOPLEN), O_VALC(yypvt-2*YYOPLEN),
							    O_VALC(yypvt), yyval)
		}
case 14:
# line 69 "pixparse.yy"
{
			# Process this table file - no default args
			call pix_table (O_VALC(yypvt-7*YYOPLEN), O_VALC(yypvt-5*YYOPLEN), O_VALC(yypvt-3*YYOPLEN),
							    O_VALC(yypvt-YYOPLEN), yyval)
		}
case 15:
# line 76 "pixparse.yy"
{
			call pix_pixel(O_VALR(yypvt-4*YYOPLEN), O_VALR(yypvt-2*YYOPLEN), O_VALR(yypvt), yyval)
		}	}

	goto yystack_				# stack new state and value
end
