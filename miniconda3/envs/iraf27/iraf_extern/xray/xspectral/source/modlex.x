#$Header: /home/pros/xray/xspectral/source/RCS/modlex.x,v 11.0 1997/11/06 16:42:46 prosb Exp $
#$Log: modlex.x,v $
#Revision 11.0  1997/11/06 16:42:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:17  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:26  prosb
#General Release 2.3
#
#Revision 6.1  93/10/16  00:54:55  dennis
#Changed canonical format of numeric values to include 3 decimal places 
#instead of 2.
#
#Revision 6.0  93/05/24  16:51:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:07  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:15  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/07  16:07:45  prosb
#jso - fixed arguement call found by flint.
#
#Revision 3.1  91/09/22  19:06:35  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:35  prosb
#General Release 1.1
#
#Revision 2.1  91/05/24  11:41:44  pros
#jso/eric - changed to allow for fixed linked parameters
#
#Revision 2.0  91/03/06  23:05:19  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# MODLEX.X -- support for the model lexical analyzer
# these routines are called from the lexical analyzer
#

include <lexnum.h>
include <ctype.h>
include "modparse.h"

#
# MOD_LOOKUP -- lookup a string in the model lookup table
#
int procedure mod_lookup(s, name, code, minargs, maxargs, type)

char s[ARB]				# i: string to lookup
pointer name				# o: name of model
int  code				# o: function code
int  minargs				# o: min args for model
int  maxargs				# o: max args for model
int  type				# o: MODEL or ABSORPTION

int  i					# l: loop counter
int match				# l: flag if we matched this time
int matches				# l: number of matches
char t[SZ_LINE]				# l: string to match against
int  mod_abbrev()			# l: match string routine

include "modparse.com"

begin
	# make up the string we have to match against
	call strcpy(s, t, SZ_LINE)
	# in lower case
	call strlwr(t)

	# look for matches
	matches = 0
	for(i=1; i<=mod_installed; i=i+1){
	    match = mod_abbrev(Memc[mod_strings[i]], t)
	    if( match > 0 ){
		name = mod_strings[i]
		code = mod_codes[i]
		minargs = mod_minargs[i]
		maxargs = mod_maxargs[i]
		type = MODEL
		# look for exact match
		if( match == 2 )
		    return(YES)
		else
		    matches = matches + 1
	    }
	}
	# now check for absorption, a special keyword
	match = mod_abbrev(Memc[mod_strings[MAX_MODDEFS+1]], t)
	if( match > 0 ){
	    name = mod_strings[MAX_MODDEFS+1]
	    code = mod_codes[MAX_MODDEFS+1]
	    minargs = mod_minargs[MAX_MODDEFS+1]
	    maxargs = mod_maxargs[MAX_MODDEFS+1]
	    type = ABSORPTION
	    # look for exact match
	    if( match == 2 )
	        return(YES)
	    else
		matches = matches + 1
	}

	# check number of matches
	if( matches == 0 )
	    return(NO)
	else if( matches == 1 )
	    return(YES)
	# non-unique abbreviation
	else
	    return(NO)
end

#
# MOD_ABBREV -- look for a pattern match of a string from the beginning
# of another string, i.e., is one string an abbrev of another?
# NB: returns the first string that matches
#
int procedure mod_abbrev(s, t)

char s[ARB]				# i: mother string in which we are
char t[ARB]				# i: trying to match this string

int i					# l: string offset

begin
	i = 1
	# look for an (abbreviated) match
	while( t[i] != EOS ){
	    if( s[i] != t[i] )
		return(0)
	    i = i+1
	}
	# check for exact match
	if( s[i] == EOS )
	    return(2)
	# otherwise its an abbreviation
	else
	    return(1)
end

#
# MOD_ISFILE -- determine if a string is the name of an existing file
#

int procedure mod_isfile(s)

char s[ARB]			# i: string

char t[SZ_FNAME]		# l: string + extension
bool got			# l: access flag
bool access()			# l: check for file existence

include "modparse.com"

begin
	# first check the string as is
	got = access(s, 0, 0)
	if( got )
	    return(YES)
	else{
	    # then add an extension and try again
	    call strcpy(s, t, SZ_FNAME)
	    call strcat(MOD_EXT, t, SZ_FNAME)
	    got = access(t, 0, 0)
	    if( got )
		return(YES)
	    else
		return(NO)
	}
end

#
# MOD_ADDTOKEN -- add a token to the name string
#
procedure mod_addtoken(s)

char	s[ARB]			# i: string to add
include "modparse.com"

begin
	call strcat(s, Memc[mod_name], SZ_LINE)
end

##
## MOD_ADDOP -- add an operator string to end of mod_name
##
#procedure mod_addop(s)
#
#char	s[ARB]			# i: op string to add
#int	len			# l: length of string
#int	strlen()		# l: string length
#
#include "modparse.com"
#
#begin
#	# change last comma to a space
#	call mod_nullcomma()
#	# make sure there is a space at end
#	len = strlen(Memc[mod_name])
#	if( Memc[mod_name+len-1] != ' ')
#	    call strcat(" ", Memc[mod_name], SZ_LINE)
#	# add the ending ")" to close previous model
##	call strcat(") ", Memc[mod_name], SZ_LINE)
#	# add the operator
#	call strcat(s, Memc[mod_name], SZ_LINE)
#	# add a space after the operator
#	call strcat(" ", Memc[mod_name], SZ_LINE)
#end
#
##
##  MOD_ADDPAREN -- put a paren into the name string
##
#procedure mod_addparen(par)
#
#char	par[ARB]			# l: paren string
#int	len				# l: length of string so far
#int	strlen()			# l: string length
#bool	streq()				# l: string compare
#include "modparse.com"
#
#begin
#	# get rid of last space before a close paren, if necessary
#	if( streq(")", par) ){
#	    len = strlen(Memc[mod_name])
#	    if( Memc[mod_name+len-1] == ' ')
#		Memc[mod_name+len-1] = EOS
#	}
#	# add the open paren
#	call strcat(par, Memc[mod_name], SZ_LINE)
#end

#
# MOD_MODIFIERS -- determine the modifiers for this
#
procedure mod_modifiers(yylval)

pointer	yylval					# o: lex struct

int	token					# l: from lexnum
int	nchars					# l: from lexnum
int	junk					# l: from gctod
double	dval					# l: from gctod
char	tbuf[SZ_LINE]				# l: temp buffer

int	lexnum()				# l: check for number
int	gctod()					# l: char to double
int	mod_islink()				# l: check for a link
int	mod_hack()				# l: look for log after ":"

include "modparse.com"

begin
	# assume fixed, no link
	O_FIXED(yylval) = FIXED_PARAM
	O_LINK(yylval) = 0
	# set upper to 0, in case its fixed
	O_UPPER(yylval) = 0.0

	# check for range value, with syntax lower:upper
	# if no ":" go right to link check
	if( mod_lbuf[mod_lptr] == ':' ){
	    # its a free param!
	    O_FIXED(yylval) = FREE_PARAM
	    # add the free param indicator
	    call strcat(":", Memc[mod_name], SZ_LINE)
	    # point past the colon
	    mod_lptr = mod_lptr+1
	    # make sure we have an upper range
	    if( IS_WHITE(mod_lbuf[mod_lptr]) )
		call mod_error("missing upper range")
	    # analyze the following token for number-ness
	    # at this point we should have a number
	    token = lexnum (mod_lbuf, mod_lptr, nchars)
	    # process the token
	    switch (token) {
	    # any sort of number will do
	    case LEX_OCTAL, LEX_DECIMAL, LEX_HEX, LEX_REAL:
		# convert ASCII to number
		junk = gctod (mod_lbuf, mod_lptr, dval)
		O_UPPER(yylval) = dval
		# add value to the name string
		call sprintf(tbuf, SZ_LINE, "%.3f")
		call pargd(dval)
		call strcat(tbuf, Memc[mod_name], SZ_LINE)
	    # missing upper limit
	    default:
		# hack to check for log function
		junk = mod_lptr
		if( mod_hack(mod_lbuf, mod_lptr, dval) == YES ){
		    O_UPPER(yylval) = dval
		    call strcpy(mod_lbuf[junk], tbuf, (mod_lptr-junk))
		    call strcat(tbuf, Memc[mod_name], SZ_LINE)
		}
		else{
		    call sprintf(tbuf, SZ_LINE, "illegal upper range - %s")
		    call pargstr(mod_lbuf[mod_lptr])
		    call mod_error(tbuf)
		}
	    }
	}
	# check for a link specifier
	if( (mod_lbuf[mod_lptr] == 'L') || (mod_lbuf[mod_lptr] == 'l') ){
	    # bump past the "L"
	    mod_lptr = mod_lptr + 1
	    # see if its a legal link
	    if( mod_islink(yylval) == YES )
		# this is the link base, so change sign on link value
		O_LINK(yylval) = - O_LINK(yylval)
	    else
		# this should not happen
		call mod_error("not a legal link")
	}
	# check for fix flag at end
	if( (mod_lbuf[mod_lptr] == 'F') || (mod_lbuf[mod_lptr] == 'f') ){
	    O_FIXED(yylval) = FIXED_PARAM
	    mod_lptr = mod_lptr + 1
	    call strcat("F", Memc[mod_name], SZ_LINE)
	}
end

#
# MOD_ISLINK -- determine if a string is a link specifier
#
int procedure mod_islink(yylval)

pointer	yylval					# o: lex struct

int	token					# l: from lexnum
int	nchars					# l: from lexnum
int	junk					# l: from gctol
int	olptr					# l: saved lptr
long	lval					# l: from gctol
char	tbuf[SZ_LINE]				# l: temp buffer

int	lexnum()				# l: check for number
int	gctol()					# l: char to double
int	access()				# l: check for file existence

include "modparse.com"

begin
	# save the mod_lptr
	olptr = mod_lptr

	# make sure there is no whitespace right here
	if( IS_WHITE(mod_lbuf[mod_lptr]) ){
	    # not a link
	    O_LINK(yylval) = 0
	    return(NO)
	}

	# make sure this isn't a file!
	if( access(mod_lbuf[mod_lptr-1], 0, 0) == YES ){
	    # not a link
	    O_LINK(yylval) = 0
	    return(NO)
	}

	# analyze the following token
	token = lexnum (mod_lbuf, mod_lptr, nchars)
	# process the token
	switch (token) {
	case LEX_DECIMAL:
	    # convert ASCII to number
	    junk = gctol (mod_lbuf, mod_lptr, lval, 10)
	    # negate
	    lval = -lval
	    # and store in link
	    O_LINK(yylval) = lval
	default:
	    # not a link
	    O_LINK(yylval) = 0
	    mod_lptr = olptr
	    return(NO)
	}
	# add this stuff to the name string
	call sprintf(tbuf, SZ_LINE, "L%d")
	call pargl(abs(lval))
	call strcat(tbuf, Memc[mod_name], SZ_LINE)
#	# its a free param!
#	O_FIXED(yylval) = FREE_PARAM
	# its a link
	return(YES)
end

#
# MOD_ISABUND -- check for an abundance string
#
int procedure mod_isabund(s, t, val)

char	s[ARB]				# i: input string
char	t[ARB]				# o: output string (SZ_LINE)
real	val				# o: output value
int	strdic()

string	abstr "|cosmic|meyer|"

begin
	switch (strdic( s, t, SZ_LINE, abstr ) )  {
	case 1:
		val = real(COSMIC_ABUNDANCE)
		return(YES)
	case 2:
		val = real(MEYER_ABUNDANCE)
		return(YES)
	default:
		val = -1.0
		call strcpy("unknown", t, SZ_LINE)
		return(NO)
	}
end

#
# MOD_ISFUNC -- check for a function
#
int procedure mod_isfunc(s, t, func)

char	s[ARB]				# i: input string
char	t[ARB]				# o: output string (SZ_LINE)
int	func				# o: function code
int	strdic()

string	funcstr "|log|"

begin
	switch (strdic( s, s, SZ_LINE, funcstr ) )  {
	case 1:
		call strcpy("log", t, SZ_LINE)
		func = MOD_LOG
		return(YES)
	default:
		return(NO)
	}
end

#
#  MOD_ADDSPACE -- add a space to the name string if last char is not one
#
#
procedure mod_addspace()

int	len				# l: string length
int	strlen()			# l: string length
include "modparse.com"

begin
	len = strlen(Memc[mod_name])
	if( len !=0 ){
	    if( Memc[mod_name+len-1] != ' ' ){
		Memc[mod_name+len] = ' '
		Memc[mod_name+len+1] = EOS
	    }
	}
end

#
# MOD_ISABSTY -- check for a type of absorption
#
int procedure mod_isabsty(s, t, abstype)

char	s[ARB]				# i: input string
char	t[ARB]				# o: output string (SZ_LINE)
int	abstype				# o: absorption type code
int	strdic()

string	abstypestr "|morrison_mccammon|brown_gould|"

begin
	switch (strdic( s, s, SZ_LINE, abstypestr ) )  {
	case 1:
		abstype = MORRISON_MCCAMMON
		call strcpy("morrison_maccammon", t, SZ_LINE)
		return(YES)
	case 2:
		abstype = BROWN_GOULD
		call strcpy("brown_gould", t, SZ_LINE)
		return(YES)
	default:
		return(NO)
	}
end

#
#  MOD_HACK -- hack code to check for log function after ":"
# this should be replaced by a change in the modeparse grammer!!!
#
int procedure mod_hack(str, ip, val)

char	str[ARB]			# i: input string
int	ip				# i: index into string
double	val				# o: return value

int	i,				# l: index into string after log
int	junk				# l: junk return from ctod
int	strmatch()
int	ctod()

begin
	# look for a match
	i = strmatch(str[ip], "^{log(}")
	# if we found the log string ...
	if( i!=0 ){
	    # bump ip past log string
	    ip = ip + i-1
	    # try yo convert value to double
	    junk = ctod(str, ip, val)
	    # if we have a number ...
	    if( junk !=0 ){
		# convert to log value
		if( str[ip] == ')' ){
		    if( val >0.0 )
			val = log10(val)
		    else
			call errord(1, "bad value for log", val)
		    # and bump past the ')'
		    ip = ip+1
		    # return the good news
		    return(YES)
		}
		# missing ')'
		else
		    call error(1, "missing ')' after log function")
	    }		
	    # missing value for log
	    else
		call error(1, "missing value for log function")
	}
	else
	    return(NO)
end
