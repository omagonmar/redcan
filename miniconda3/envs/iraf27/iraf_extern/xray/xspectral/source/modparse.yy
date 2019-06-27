#$Header: /home/pros/RCS/modparse.yy,v 9.0 1995/11/16 19:30:25 prosb Rel $
#$Log: modparse.yy,v $
#Revision 9.0  1995/11/16  19:30:25  prosb
#General Release 2.4
#
#Revision 8.1  1995/08/08  14:28:15  prosb
#jcc - ci for pros2.4.
#
#Revision 8.0  94/06/27  17:33:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:39  prosb
#General Release 2.3
#
#Revision 6.1  93/10/16  00:51:51  dennis
#Changed canonical format of numeric values to include 3 decimal places 
#instead of 2.
#
#Revision 6.0  93/05/24  16:51:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:19  prosb
#General Release 2.1
#
#Revision 4.1  92/07/09  11:19:16  prosb
#jso - closed a file to be compatable with grid_fit changes.
#
#Revision 4.0  92/04/27  18:16:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/03/25  11:18:40  orszak
#jso - removed profanity
#
#Revision 3.0  91/08/02  01:58:40  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  16:25:50  prosb
#jso - wanted to change date when making spectral.h system wide
#
#Revision 2.1  91/05/24  11:47:11  pros
#some format change bye jr/eric
#
#Revision 2.0  91/03/06  23:05:35  pros
#General Release 1.0
#
#
#	MODELS.YY - xyacc grammer for spectral model descriptors
#

%{
include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>
include <fio.h>

include	"modparse.h"

%L
include	"modparse.com"
%}

%token		NUMERAL MODEL ABSORPTION
%token		FILE LINK FUNC ABSTYPE
%token		YYEOF
%token		SEMICOLON NEWLINE
# LIST is not used in the grammer, but is used modacts.x
# we define it here so that it gets into ytab.h with the others:
%token		LIST

%left		PLUS
%left		STAR

%%

command	:	# Empty
	|	eost {
			return (OK)
		    }
	|	expr eost {
			call mod_endexpr($1, $$)
			return (OK)
		    }
	|	abstype eost {
			call mod_endexpr($1, $$)
			return(OK)
		    }
	|	file eost {
			return (OK)
		    }
	|	YYEOF {
			return (EOF)
		    }
	;

expr	:	mod {
			# New model
			call mod_setup_list($1, $$)
		    }
	|	expr PLUS opnl expr {
			# add two models
			call mod_merge_lists($1, $4, $$)
		    }
	|	abs STAR opnl expr {
			# apply absorption
			call mod_apply_absorption($1, $4, $$)
		    }
	|	expr STAR opnl abs {
			# apply absorption
			call mod_apply_absorption($4, $1, $$)
		    }
	|	'(' expr ')' {
			YYMOVE ($2, $$)
		    }
	;


abstype	:	ABSTYPE {
			call mod_abstype($1, $$)
		    }

file	:	FILE {
			# New file
			call mod_newfile($1, $$)
		    }
	;

mod	:	MODEL '(' arglist ')' {
			# set up new model
			call mod_setup_model($1, $3, $$)
		    }
	|	MODEL arglist {
			# set up new model
			call mod_setup_model($1, $2, $$)
		    }
	;

abs	:	ABSORPTION '(' arglist ')' {
			# set up new absorption
			call mod_setup_absorption($1, $3, $$)
		    }
	|	ABSORPTION arglist {
			# set up new absorption
			call mod_setup_absorption($1, $2, $$)
		    }
	;

arglist	:	{
			# Empty
			call mod_startarglist (NULL, 0, $$)
		    }
	|	param {
			# First arg; start a nonnull list.
			call mod_startarglist ($1, NUMERAL, $$)
		    }
	|	arglist opcomma opnl param {
			# Add an argument to an existing list.
			call mod_addarg ($1, $4, NUMERAL, $$)
		    }
	|	LINK {
			# First arg; start a nonnull list.
			call mod_startarglist ($1, LINK, $$)
		    }
	|	arglist opcomma opnl LINK {
			# Add an argument to an existing list.
			call mod_addarg ($1, $4, LINK, $$)
		    }
	;

param   :	NUMERAL {
		    YYMOVE ($1, $$)
		}
	|	FUNC '(' NUMERAL ')' {
		    call mod_function($1, $3, $$)
		}	
	;

opnl	:	# 
	|	'\\' NEWLINE
	;

opcomma	:	# 
	|	','
	;

eost	:	NEWLINE
	|	SEMICOLON
	;

%%

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

int	status			# l: returned status from yyparse
int	complete		# l: completion flag = 1 if no errors
int	tdebug			# l: yyparse debug flag
pointer sp			# l: stack pointer

int	open()			# l: open a file
int	yyparse()		# l: parser
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
	# set the yyparse debug flag
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
	    status = yyparse (mod_fd, tdebug, mod_lex)
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
