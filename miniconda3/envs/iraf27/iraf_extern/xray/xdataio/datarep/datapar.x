#$Header: /home/pros/xray/xdataio/datarep/RCS/datapar.x,v 11.0 1997/11/06 16:33:52 prosb Exp $
#$Log: datapar.x,v $
#Revision 11.0  1997/11/06 16:33:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:29  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:36  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  15:05:26  mo
#MC	7/2/93		Change bool != TRUE to !bool	(RS6000 port)
#
#Revision 6.0  93/05/24  16:23:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:10  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:39  pros
#General Release 1.0
#

include <ctype.h>
include "datarep.h"

define	YYMAXDEPTH	200
define	YYOPLEN		LEN_SYMBOL

define	DRPP		-100
define	STRUCT		257
define	IDENTIFIER		258
define	PRIMARY		259
define	INTEGER		260
define	YYEOF		261
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 87 "datapar.y"


# The main compiler procedure.
#
pointer procedure datacom(template)

char	template[ARB]
#--

pointer	text, junk

pointer	psh(), pop()
int	yyparse()
extern datalex()

include	"datapar.com"

begin
	call malloc(text, 1000, TY_INT)
	textstack = psh(0, text)
	filestack = psh(0, template)

	junk = yyparse(template, 0, datalex)
	junk = pop(textstack)

	return text
end

procedure datainit()
#--

pointer	stopen()

int	locpr()
extern  rreeppeeaatt()
extern  jumpinto()
extern  jumpret()

include	"datapar.com"

extern pshfile()

begin
	symbols = stopen("datarep", 256, 4096, 4096)

	call enter("struct",	STRUCT,	 0)
#	call enter("include",	DRPP,	 pshfile)

        op_loop = locpr(rreeppeeaatt)
        op_call = locpr(jumpinto)
        op_ret =  locpr(jumpret)

	line = 1
end


procedure enter(str, token, func)

char	str[ARB]
int	token
pointer func
#--

include "datapar.com"
pointer	sym, stenter()
int	locpr()

begin
	sym = stenter(symbols, str, LEN_SYMBOL)

	 call pargstr(str)
	 call pargi(func)

	if ( func != 0 ) S_FUNC(sym)  = locpr(func)
	S_TOKEN(sym) = token
	S_REPT(sym)  = 1
	S_TEXT(sym)  = 0
end


procedure datatype(str, func)

char	str[ARB]
int	func
#--

begin
	call enter(str, PRIMARY, func)
end


int procedure datalex(fs, rp)

int	fs
pointer	rp				# return pointer
#--

int	i
char	ch, junk
char	token[SZ_LINE]
pointer	sym

pointer	str

char	getc()
pointer	pop(), stfind()

include	"datapar.com"

define TOP	ST_VALUE(filestack)
define again	91

begin

again
	repeat {
		ch = getc(TOP, junk)
		if ( ch == '\n' ) line = line + 1
	} until ( !IS_WHITE(ch) && ch != '\n' )

	switch ( ch ) {
	 case EOF: {
		filestack = pop(filestack)
		if ( filestack != NULL ) goto again
		else			 return YYEOF
	 }
	 case '#': {
		while ( ch != '\n' ) ch = getc(TOP, junk)
		line = line + 1
		goto again
	 }
	 case '{':	return '{'
	 case '}':	return '}'
	 case '[':	return '['
	 case ']':	return ']'
	 case ',':      return ','
	 default:
	}

	# Must be a word

	token[1] = ch
	i = 1
	repeat { i = i + 1
		 token[i] = getc(TOP, junk)
	} until ( !IS_ALNUM(token[i])		&&
			    token[i] != '_'	&&
			    token[i] != '$'	||
				 i >= MAXTOKEN )

	call ungetc(TOP, token[i])
	token[i] = EOS

	sym = stfind(symbols, token)
	if ( sym == NULL ) {
		switch ( token[1] ) {
		 case '1', '2', '3', '4', '5', '6', '7', '8', '9', '0': {
			i = 1
			call ctoi(token, i, S_REPT(rp))
			return INTEGER
		 }
		 default:
			call malloc(str, i, TY_CHAR)
			call strcpy(token, Memc[str], i)
			S_TEXT(rp) = str
			return IDENTIFIER
		}
	}

	# Is the word a datarep preprecessor symbol ?
	#
	if ( S_TOKEN(sym) == DRPP ) {
		ch = getc(TOP, junk)
		while ( IS_WHITE(ch) || ch == '\n' ) ch = getc(TOP, junk)

		token[1] = ch
		i = 1
		repeat { i = i + 1
			 token[i] = getc(TOP, junk)
		} until ( token[i] == '\n' || i > SZ_LINE )

		call zcall1(S_FUNC(sym), token)
		goto again
	}

	S_FUNC(rp) = S_FUNC(sym)
	S_TEXT(rp) = S_TEXT(sym)
	S_REPT(rp) = 1
	return S_TOKEN(sym)
end


procedure dataer(str)

char	str[ARB]

#--

include "datapar.com"

begin

	call printf("syntax error %s - at line %d\n")
	 call pargstr(str)
	 call pargi(line)
	call error(1, "datarep")
end


procedure pshtext(str)

pointer	str
#--

pointer	sym

include	"datapar.com"

pointer	stenter(), psh()

begin
	sym = stenter(symbols, Memc[str], LEN_SYMBOL)
	
	S_FUNC(sym) = op_call
	S_REPT(sym) = 1
	call malloc(S_TEXT(sym), 1000, TY_INT)
	S_TOKEN(sym) = PRIMARY

	call mfree(str, TY_CHAR)

	textstack = psh(textstack, S_TEXT(sym))
end


procedure poptext()
#--

pointer	pop()

include	"datapar.com"

begin
	call compile(op_ret)

	textstack = pop(textstack)
end


pointer procedure pshfile(filestack, name)

pointer	filestack
char	name[ARB]
#--

pointer	open(), psh()

begin
	return psh(filestack, open(name))
end



procedure compile(op)

int	op
#--

include	"datapar.com"

begin
	I_FUNC(ST_VALUE(textstack)) = op

	ST_VALUE(textstack) = ST_VALUE(textstack) + 1
end


procedure compilerep(n)

int	n
#--

include "datapar.com"

begin
	call compile(op_loop)
	call compile(n)
end


procedure datazap(text)

pointer	text			# a piece of text to free
#--

pointer	sym, sthead(), stnext()

include "datapar.com"

begin
	call mfree(text, TY_STRUCT)

	if ( symbols != NULL ) {
		for ( sym = sthead(symbols); sym != NULL; sym = stnext(symbols, sym) )
			call mfree(S_TEXT(sym), TY_STRUCT)

		call stclose(symbols)
	}
end



# Datarep PreProcessor "include" statement is unimplimented
#
#  the argument to this function is the rest of a line from the 
#  input line "include..."
#
#  To impliment this command open the file and push the file stack.
#
#
procedure inc_file(line)

char	line[ARB]
#--

#int	idx
#char	name[SZ_LINE]

begin

end
define	YYNPROD		17
define	YYLAST		42
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

short	yyexca[12]
data	(yyexca(i),i=  1,  8)	/  -1,   1,   0,  -1,  -2,   0,  -1,   3/
data	(yyexca(i),i=  9, 12)	/   0,   2,  -2,   8/
short	yyact[42]
data	(yyact(i),i=  1,  8)	/  11,   6,   9,   7,   3,   6,  23,   7/
data	(yyact(i),i=  9, 16)	/  25,   7,  13,  17,  18,  19,  14,  20/
data	(yyact(i),i= 17, 24)	/   5,  21,   2,   8,  16,  15,   4,  10/
data	(yyact(i),i= 25, 32)	/  12,   1,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 33, 40)	/   0,   0,   0,  22,   0,   0,   0,  22/
data	(yyact(i),i= 41, 42)	/  26,  24/
short	yypact[27]
data	(yypact(i),i=  1,  8)	/-252,-1000,-259,-1000,-256,-256,-248, -77/
data	(yypact(i),i=  9, 16)	/-1000,-1000,-1000,-1000,-1000,-1000,-249,-111/
data	(yypact(i),i= 17, 24)	/ -80, -29,-250,-1000,-249,-117,-250,-1000/
data	(yypact(i),i= 25, 27)	/-1000,-1000,-1000/
short	yypgo[9]
data	(yypgo(i),i=  1,  8)	/   0,  25,  18,  22,  16,  21,  17,  19/
data	(yypgo(i),i=  9,  9)	/  20/
short	yyr1[17]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   2,   2,   2,   5,   3/
data	(yyr1(i),i=  9, 16)	/   3,   6,   6,   4,   4,   7,   7,   8/
data	(yyr1(i),i= 17, 17)	/   8/
short	yyr2[17]
data	(yyr2(i),i=  1,  8)	/   0,   2,   1,   0,   2,   2,   0,   6/
data	(yyr2(i),i=  9, 16)	/   1,   0,   2,   1,   1,   4,   1,   1/
data	(yyr2(i),i= 17, 17)	/   3/
short	yychk[27]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2, 256,  -3,  -4, 257, 259/
data	(yychk(i),i=  9, 16)	/  -7, 261,  -2, 256,  -2, 258,  91,  -5/
data	(yychk(i),i= 17, 24)	/  -8, 260, 123,  93,  44,  -6,  -4, 256/
data	(yychk(i),i= 25, 27)	/  -8, 125,  -6/
short	yydef[27]
data	(yydef(i),i=  1,  8)	/   3,  -2,   0,  -2,   3,   3,   0,  11/
data	(yydef(i),i=  9, 16)	/  12,   1,   4,   8,   5,   6,   0,   0/
data	(yydef(i),i= 17, 24)	/   0,  15,   9,  13,   0,   0,   9,  14/
data	(yydef(i),i= 25, 27)	/  16,   7,  10/

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
	    
case 1:
# line 26 "datapar.y"
{
			call compile(0)
			return
		}
case 2:
# line 31 "datapar.y"
{
			call dataer("")
		}
case 6:
# line 42 "datapar.y"
{	call pshtext(S_TEXT(yypvt))	}
case 7:
# line 44 "datapar.y"
{	call poptext()			}
case 8:
# line 46 "datapar.y"
{
			call dataer("in structure definition")
		}
case 11:
# line 56 "datapar.y"
{	
			call compile(S_FUNC(yypvt))
			if ( S_TEXT(yypvt) != NULL )
				call compile(S_TEXT(yypvt))
		}
case 12:
# line 62 "datapar.y"
{	call compilerep(S_REPT(yypvt))
			call compile(S_FUNC(yypvt))
			if ( S_TEXT(yypvt) != NULL )
				call compile(S_TEXT(yypvt))
		}
case 13:
# line 70 "datapar.y"
{	
			S_FUNC(yyval) = S_FUNC(yypvt-3*YYOPLEN)
			S_TEXT(yyval) = S_TEXT(yypvt-3*YYOPLEN)
			S_REPT(yyval) = S_REPT(yypvt-YYOPLEN)
		}
case 14:
# line 76 "datapar.y"
{
			call dataer("in array index definition")
		}
case 16:
# line 84 "datapar.y"
{	S_REPT(yyval) = S_REPT(yypvt-2*YYOPLEN) * S_REPT(yypvt)	}	}

	goto yystack_				# stack new state and value
end
