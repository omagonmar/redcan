#$Header: /home/pros/RCS/clevparse.yy,v 9.0 1995/11/16 19:08:46 prosb Rel $
#$Log: clevparse.yy,v $
#Revision 9.0  1995/11/16  19:08:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:57  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:50  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:28:52  janet
#jd - enabled '.' delimeter in input ascii src list names.
#
#Revision 5.0  92/10/29  22:34:58  prosb
#General Release 2.1
#
#Revision 4.1  92/06/17  16:00:43  mo
#Moved to xobsolete
#
#Revision 4.0  92/04/27  17:32:17  prosb
#General Release 2.0:  April 1992

#Revision 1.2  92/04/24  16:49:04  janet
#added LIN abbrev for LINEAR.

#Revision 1.1  91/12/12  09:43:31  janet
#Initial revision
#
#Revision 3.0  91/08/02  01:23:05  prosb
#General Release 1.1
#
#Revision 2.1  91/03/26  10:29:48  janet
#Added beg_stmt definition that clears the structure each time a line is parsed.
#
#Revision 2.0  91/03/06  23:20:40  pros
#General Release 1.0
#
#
#	CLEVPARSE.YY - xyacc grammer for contour levels
#
%{
include <error.h>
include <ctype.h>
include <lexnum.h>
include <finfo.h>
include	"clevparse.h"

%L
include	"clevparse.com"
%}

%token		LOG LINEAR INCL PARAM MINUS UNKNOWN
%token		YYEOF
%token		NEWLINE

%%

command 	:	
		|	bost eost {
				return (OK) }
		|	bost stmt eost {
				return (OK) }
		|	bost incl eost {
				return (OK) }
		|	YYEOF {
				return (EOF) }
		;

bost		:       { 
			  call init_params ()
			}
		;

stmt    	:	function param_stmt 	{}
		|	param_stmt  {
 				    call set_levels() 	
				    }
        	;

function	:	LOG     {
 				call set_log()
				}
		|	LINEAR  {
 				call set_linear() 
				}
		;

param_stmt	:	'(' param_lst ')'	{}
		|	param_lst		{}
		;

param_lst	:	PARAM params { 
				      call set_param(VALR($1))
				      }
		|       MINUS PARAM params {
					   call set_negparam(VALR($2))
					   }
		|        
		;

params		:	',' param_lst		{}
		|	param_lst		{}
		|
		;

incl		:	INCL 	{
				call clev_inc($1, $$) 
				}
		;

eost		:	NEWLINE
		;

%%

#
# CLEV_PARSE -- parse contour level set string
#
int procedure clev_parse(s, ptr, debug)

char	s[ARB]			# i: contour level string
pointer	ptr			# o: pointer to structs
int	debug			# i: debug flag

int	tdebug			# l: temp debug flag for yyparse
int	status			# l: return from yyparse
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	yyparse()		# l: parser
extern	clev_lex()		# l: lexical analyzer

include "clevparse.com"

begin
	# mark the stack
	call smark(sp)

	# set the yyparse debug flag
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
	    status = yyparse (clev_fd, tdebug, clev_lex)
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
