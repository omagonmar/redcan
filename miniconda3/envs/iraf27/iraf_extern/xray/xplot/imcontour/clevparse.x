include <error.h>
include <ctype.h>
include <lexnum.h>
include <finfo.h>
include	"clevparse.h"

define	LOG		257
define	LINEAR		258
define	INCL		259
define	PARAM		260
define	MINUS		261
define	UNKNOWN		262
define	YYEOF		263
define	NEWLINE		264
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 103 "clevparse.yy"


#
# CLEV_PARSE -- parse contour level set string
#
int procedure clev_parse(s, ptr, debug)

char	s[ARB]			# i: contour level string
pointer	ptr			# o: pointer to structs
int	debug			# i: debug flag

int	tdebug			# l: temp debug flag for clev_yyparse
int	status			# l: return from clev_yyparse
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	clev_yyparse()		# l: parser
extern	clev_lex()		# l: lexical analyzer

include "clevparse.com"

begin
	# mark the stack
	call smark(sp)

	# set the clev_yyparse debug flag
	if( debug >= 10 )
	    tdebug = 1
	else
	    tdebug = 0

	# allocate a string buffer for file names
	call salloc(clev_sbuf, SZ_SBUF, TY_CHAR)

	# free up clev_ptr, just in case
	call mfree(clev_ptr, TY_STRUCT)

	# create a spool file for the command string
	clev_fd = open("spool1", READ_WRITE, SPOOL_FILE)
	# write the s buffer to the file & rewind file
	call fprintf(clev_fd, "%s\n")
	call pargstr(s)
	call seek(clev_fd, BOF)

	# set it up as first in fd list
	clev_fdlev = 1
	clev_fds[clev_fdlev] = clev_fd

	# compile and execute specifications
	repeat {
	    # reset current string pointer back to beginning
	    clev_nextch = clev_sbuf
	    # parse next clev file
	    status = clev_yyparse (clev_fd, tdebug, clev_lex)
	} until( status != OK )

	# free up the allocated space
	call sfree(sp)

	# check final status
	if( status == EOF ){
	    ptr = clev_ptr
	    return(YES)
	}
	else{
	    ptr = 0
	    call mfree(clev_ptr, TY_STRUCT)
	    call flush(STDOUT)
	    return(NO)
	}
end

#
# CLEV_LEX -- Lexical input routine.  
#             Return next token from the input stream
#
int procedure clev_lex (fd, yylval)

int	fd			# i: input file channel
pointer	yylval			# o: output value for parser stack

int	nchars			# l: number of chars in lexnum
int	token			# l: token type
int	junk			# l: for grabbing unneeded function values
int	type			# l: type of token - returned by function
double	dval			# l: numeric value of string
pointer	s			# l: pointer to input table or include name

int     access()
int     lexnum()
int     getline()
int	gctod()			# l: ASCII to decimal
int	strlen()		# l: string length
bool    streq()

include "clevparse.com"

begin
	# Fetch a nonempty input line, or advance to start of next token
	# if within a line.  Newline is a token.
	while( clev_lptr == 0) {

	    # read next line
	    if (getline (fd, clev_lbuf) == EOF) {
		# on end of file, check for a pushed file
		if( clev_fdlev == 1 ){
		  return (YYEOF)
		}
		# and pop it, if necessary
		else
		  call popfd()
	    } else{
		# skip white space
		while (IS_WHITE (clev_lbuf[clev_lptr]))
			clev_lptr = clev_lptr + 1
		# skip blank lines and lines beginning with "#"
		if( (strlen(clev_lbuf) >1) && (clev_lbuf[1] != '#') ){
		    # point the lptr to the first character
		    clev_lptr = 1
		}
	    }
	}

	# skip white space
	while (IS_WHITE (clev_lbuf[clev_lptr]))
		clev_lptr = clev_lptr + 1

	# Determine type of token.  If numeric constant, convert to binary
	# and return value in op structure (yylval).
	# Otherwise, check for punctuation, regions, and files
	if( IS_DIGIT(clev_lbuf[clev_lptr]) ){
	    # get type of numeral
	    token = lexnum (clev_lbuf, clev_lptr, nchars)
	}
	else{
	    # grab the next character
	    token = clev_lbuf[clev_lptr]
	    # bump clev_lptr
	    clev_lptr = clev_lptr+1
	    # seed the return value - this might be overwritten
	    VALI(yylval) = token
	}

	# process the token
	switch (token) {

	case LEX_OCTAL, LEX_DECIMAL, LEX_HEX, LEX_REAL:
	    # convert ASCII to number
	    junk = gctod (clev_lbuf, clev_lptr, dval)
	    VALR(yylval) = dval
	    type = PARAM 
	 
	case '\n':
	    type = NEWLINE
	    clev_lptr = 0

	case '#':
	    type = NEWLINE
	    clev_lptr = 0

	case '-':
	    type = MINUS

	case ',':
	    type = ','

	case '(':
	    type = '('

	case ')':
	    type = ')'

	# identifier
	default:
	    # start grabbing chars into the string buffer
	    s = clev_nextch
	    Memc[clev_nextch] = token
	    clev_nextch = clev_nextch + 1

	    # get identifier
	    while( IS_ALNUM(clev_lbuf[clev_lptr]) ||
# jd - 4/93 - uncommented line below for clev input test
 			   (clev_lbuf[clev_lptr] == '.') ||
			   (clev_lbuf[clev_lptr] == '_') ||
			   (clev_lbuf[clev_lptr] == '/') ||
			   (clev_lbuf[clev_lptr] == '$') ){
		    # add the char to the string & bump ptrs
		    Memc[clev_nextch] = clev_lbuf[clev_lptr]
		    clev_nextch = clev_nextch + 1
		    clev_lptr=clev_lptr+1
	    }
	    # finish up the string
	    Memc[clev_nextch] = EOS
	    # bump the "next available" pointer
	    clev_nextch = clev_nextch + 1

	    if ( streq ("linear", Memc[s]) ) {
	       type = LINEAR 
	       LBUF(yylval) = s
	    } else 
	       if ( streq ("log", Memc[s]) ) {
	          type = LOG
	          LBUF(yylval) = s
	    } else 
	       if ( streq ("lin", Memc[s]) ) {
	          type = LINEAR 
	          LBUF(yylval) = s
	    } else 
	    # check that file exists 
	       if( access (Memc[s], 0, 0) == YES) {
		  type = INCL
		  LBUF(yylval) = s
	    # it's an unknown keyword
	    } else {
		call printf("undefined token: %s\n")
		call pargstr(Memc[s])
		call flush(STDOUT)
		type = ')'		# cause syntax error
# 		return
	    }
	}

	# return what we found
	return(type)
end

#
# CLEV_INC -- process a new include file by pushing the old fd
#	      and opening the new file
#
procedure clev_inc(a, yyval)

pointer a			# i: input parser register
pointer yyval			# o: parser output value

include "clevparse.com"

begin
	# push the fd
	call pushfd(VALC(a))
	# return value to parser
	VALI(yyval) = VALI(a)
end

#
# PUSHFD --	open a file and make the new fd current
#		push the previous fd on the stack
#
procedure pushfd(fname)

char fname[ARB]			# i: file name to open

int open()			# l: open a file

include "clevparse.com"

begin
	# inc the number of fd's we have nested
	clev_fdlev = clev_fdlev + 1

	# check for overflow
	if( clev_fdlev >= MAX_NESTS ){
	    call printf("include file stack overflow - skipping file %s\n")
	    call pargstr(fname)
	    return
	}

	# open the new file
	clev_fds[clev_fdlev] = open(fname, READ_ONLY, TEXT_FILE)
	# and make it the current fd (for next read)
	clev_fd = clev_fds[clev_fdlev]
end

#
# POPFD --	close a file
#		pop the previous fd on the stack, if there is one
#
procedure popfd()

include "clevparse.com"

begin
	# close the current file
	call close(clev_fd)
	# dec the number of fd's we have nested
	clev_fdlev = clev_fdlev - 1
	# level <= 0 - underflow
	if( clev_fdlev <= 0 ){
	    call printf("internal error: include file stack underflow")
	    return
	}
	# level > 0 - restore previous fd
	else
	    clev_fd = clev_fds[clev_fdlev]
end

#
# CLEV_DATASET --  	print out data
#
procedure clev_dataset(fname, range, scale, a)
char	fname[ARB]
char	range[ARB]
real	scale
pointer	a

begin
	call printf("dataset=%s; range=%s; scale=%.2f\n")
	call pargstr(fname)
	call pargstr(range)
	call pargr(scale)
end
define	YYNPROD		21
define	YYLAST		227
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

int procedure clev_yyparse (fd, yydebug, yylex)

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


include	"clevparse.com"
short	yyexca[12]
data	(yyexca(i),i=  1,  8)	/  -1,   0,   0,   1,  -2,   6,  -1,   1/
data	(yyexca(i),i=  9, 12)	/   0,  -1,  -2,   0/
short	yyact[227]
data	(yyact(i),i=  1,  8)	/  13,   7,   3,  15,  16,  13,  22,  24/
data	(yyact(i),i=  9, 16)	/  25,  14,  21,   9,   4,   8,   6,   5/
data	(yyact(i),i= 17, 24)	/   2,   1,  17,  18,  19,   0,   0,  20/
data	(yyact(i),i= 25, 32)	/   0,  23,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 33, 40)	/  26,   0,  23,  27,   0,   0,   0,   0/
data	(yyact(i),i= 41, 48)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 49, 56)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 57, 64)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 65, 72)	/   0,   0,   0,   0,   0,   0,   0,   0/
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
data	(yyact(i),i=217,224)	/   0,  11,  12,  10,  15,  16,  15,  16/
data	(yyact(i),i=225,227)	/   7,  15,  16/
short	yypact[28]
data	(yypact(i),i=  1,  8)	/-261,-1000, -40,-1000,-1000,-263,-263,-1000/
data	(yypact(i),i=  9, 16)	/ -35,-1000,-1000,-1000,-1000,-257,-1000, -38/
data	(yypact(i),i= 17, 24)	/-253,-1000,-1000,-1000, -33,-1000,-257,-1000/
data	(yypact(i),i= 25, 28)	/ -38,-1000,-1000,-1000/
short	yypgo[10]
data	(yypgo(i),i=  1,  8)	/   0,  17,  16,  12,  15,  14,  13,  11/
data	(yypgo(i),i=  9, 10)	/   9,  10/
short	yyr1[21]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   2,   4/
data	(yyr1(i),i=  9, 16)	/   4,   6,   6,   7,   7,   8,   8,   8/
data	(yyr1(i),i= 17, 21)	/   9,   9,   9,   5,   3/
short	yyr2[21]
data	(yyr2(i),i=  1,  8)	/   0,   0,   2,   3,   3,   1,   0,   2/
data	(yyr2(i),i=  9, 16)	/   1,   1,   1,   3,   1,   2,   3,   0/
data	(yyr2(i),i= 17, 21)	/   2,   1,   0,   1,   1/
short	yychk[28]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2, 263,  -3,  -4,  -5, 264/
data	(yychk(i),i=  9, 16)	/  -6,  -7, 259, 257, 258,  40,  -8, 260/
data	(yychk(i),i= 17, 24)	/ 261,  -3,  -3,  -7,  -8,  -9,  44,  -8/
data	(yychk(i),i= 25, 28)	/ 260,  41,  -8,  -9/
short	yydef[28]
data	(yydef(i),i=  1,  8)	/  -2,  -2,   0,   5,   2,   0,   0,  20/
data	(yydef(i),i=  9, 16)	/  15,   8,  19,   9,  10,  15,  12,  15/
data	(yydef(i),i= 17, 24)	/   0,   3,   4,   7,   0,  13,  15,  17/
data	(yydef(i),i= 25, 28)	/  15,  11,  16,  14/

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
# line 48 "clevparse.yy"
{
				return (OK) }
case 3:
# line 50 "clevparse.yy"
{
				return (OK) }
case 4:
# line 52 "clevparse.yy"
{
				return (OK) }
case 5:
# line 54 "clevparse.yy"
{
				return (EOF) }
case 6:
# line 58 "clevparse.yy"
{ 
			  call init_params ()
			}
case 7:
# line 63 "clevparse.yy"
{}
case 8:
# line 64 "clevparse.yy"
{
 				    call set_levels() 	
				    }
case 9:
# line 69 "clevparse.yy"
{
 				call set_log()
				}
case 10:
# line 72 "clevparse.yy"
{
 				call set_linear() 
				}
case 11:
# line 77 "clevparse.yy"
{}
case 12:
# line 78 "clevparse.yy"
{}
case 13:
# line 81 "clevparse.yy"
{ 
				      call set_param(VALR(yypvt-YYOPLEN))
				      }
case 14:
# line 84 "clevparse.yy"
{
					   call set_negparam(VALR(yypvt-YYOPLEN))
					   }
case 16:
# line 90 "clevparse.yy"
{}
case 17:
# line 91 "clevparse.yy"
{}
case 19:
# line 95 "clevparse.yy"
{
				call clev_inc(yypvt, yyval) 
				}	}

	goto yystack_				# stack new state and value
end
