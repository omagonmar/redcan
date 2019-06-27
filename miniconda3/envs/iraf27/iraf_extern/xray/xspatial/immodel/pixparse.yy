#$Header: /home/pros/RCS/pixparse.yy,v 9.0 1995/11/16 18:47:22 prosb Rel $
#$Log: pixparse.yy,v $
#Revision 9.0  1995/11/16  18:47:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:18  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:31:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:26  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:43  pros
#General Release 1.0
#
#
# Module:       PIXPARSE.YY
# Project:      PROS -- ROSAT RSDC
# Purpose:      parse a pixel/intensity specification and return 3 arrays
#		containing x, y, and intensity
# External:     pix_parse()
# Local:        yylex()
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Eric Mandel  initial version whoknows<when>
#               {n} <who> -- <does what> -- <when>
#

%{
include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>

include	"pixparse.h"

%L
include	"pixparse.com"
%}

%token		COMMA SEMICOLON NEWLINE YYEOF LPAREN RPAREN
%token		TABLE LIST COLUMN
%token		FLOAT

%%

command	:	# Empty.
	|	eost {
			return (OK)
		    }
	|	dolist eost {
			return (OK)
		    }
	|	dotable eost {
			return (OK)
		    }
	|	dopixel eost {
			return (OK)
		    }
	|	YYEOF {
			return (EOF)
		    }
	;

eost	:	SEMICOLON
	|	NEWLINE
	;

dolist	:	LIST {
			# Load the next line of an input image.
			call pix_list (O_VALC($1), $$)
		    }
	;

dotable:	TABLE {
			# Process this table file - default args
			call pix_table (O_VALC($1), DEFX, DEFY, DEFCNTS, $$)
		}
	|	TABLE COLUMN {
			# Process this table file - default args for x and y
			call pix_table (O_VALC($1), DEFX, DEFY, O_VALC($2), $$)
		}
	|	TABLE LPAREN COLUMN  RPAREN {
			# Process this table file - default args for x and y
			call pix_table (O_VALC($1), DEFX, DEFY, O_VALC($3), $$)
		}
	|	TABLE COLUMN opcom COLUMN opcom COLUMN {
			# Process this table file - no default args
			call pix_table (O_VALC($1), O_VALC($2), O_VALC($4),
							    O_VALC($6), $$)
		}
	|	TABLE LPAREN COLUMN opcom COLUMN opcom COLUMN  RPAREN {
			# Process this table file - no default args
			call pix_table (O_VALC($1), O_VALC($3), O_VALC($5),
							    O_VALC($7), $$)
		}
	;

dopixel:	FLOAT opcom FLOAT opcom FLOAT {
			call pix_pixel(O_VALR($1), O_VALR($3), O_VALR($5), $$)
		}
	;

opcom:		#
        |	COMMA
        ;

%%

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
