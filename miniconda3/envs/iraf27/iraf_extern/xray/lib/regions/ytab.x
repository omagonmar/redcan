include <error.h>
include <ctype.h>
include <lexnum.h>
include <fset.h>
include <fio.h>
include <printf.h>		# defines SZ_OBUF

define NOP -23

include	<regparse.h>

define	NUMERAL		257
define	REGION		258
define	PIXSYS		259
define	COORDS		260
define	EQUATO		261
define	EQEQUIX		262
define	REGFIL		263
define	CLEVELS		264
define	REFFIL		265
define	ID		266
define	YYEOF		267
define	yyclearin	yychar = -1
define	yyerrok		yyerrflag = 0
define	YYMOVE		call amovi (Memi[$1], Memi[$2], YYOPLEN)
define	YYERRCODE	256

# line 269 "regparse.yy"


#
# RG_PARSE_F -- No-reference-image, no-mask-creation, front end to rg_parse()
#               (to be superseded by more general purpose interface; 
#               unused at present (8/19/94))
#
bool procedure rg_parse_f(parsing, s, debug)

pointer parsing                 # i,o: parsing control structure
char    s[ARB]                  # i: region descriptor string
int     debug                   # i: debug flag

bool	rg_parse()		# main routine to parse region descriptor

include "regparse.com"
include "rgwcs.com"

begin
	# init the wcs stuff
	rg_ctwcs = NULL
	rg_imsystem = NONE
	rg_system = NONE
	return(rg_parse(parsing, s, debug))
end


#
# RG_PARSE -- Main routine for parsing a region descriptor for any purpose
#
bool procedure rg_parse(parsing, s, debug)

pointer	parsing			# i,o: parsing control structure
char	s[ARB]			# i: region descriptor string
int	debug			# i: debug flag

int     len                     # l: length of a string
int     clen                    # l: length of command string already spooled
pointer	shortstrs		# l: buffer for sequence of short strings 
				#    from rg_lbuf[], including multi region 
				#    dummy variables, keyword names or abbrevs,
				#    file names; rg_lex() loads the strings, 
				#    and returns a pointer to any buffered 
				#    file name, in O_FNPTR(yylval);
				#    cleared for each new command

int	status			# l: returned status from yyparse
bool	parsed_ok		# l: rg_parse() return code
int	tdebug			# l: yyparse debug flag
pointer sp			# l: stack pointer

int	exclfd			# l: file handle for EXCLUDE regions' 
				#    (deferred) virtual CPU programs, for 
				#    OPENMASK option

bool	rg_any_q()		#  : whether called with any requests
int	envgets()
bool	streq()			#  : string compare
int	strlen()		#  : string length
int	open()			#  : open a file
bool	rg_none()		#  : is region "NONE"?
bool	rg_coords_q()		#  : whether to interpret coordinate values
bool	rg_compile_q()		#  : whether to compile virtual CPU programs
bool	rg_execute_q()		#  : whether to execute virtual CPU programs
bool	rg_make_mask_q()	#  : whether to create a mask
int	yyparse()		#  : xyacc-generated parser
extern	rg_lex()		#  : lexical analyzer
long	note()			#  : get file position
int	rg_recallcpu()		#  : get a saved cpu for execution

char	pixsys[10]

pointer	mw_sctran()

include "regparse.com"
include "rgwcs.com"

begin
#=========================================================================
#	Return false if no action has been requested
#=========================================================================
	if (!rg_any_q(parsing))
	    return(false)

#=========================================================================
#	Do option-specific setup
#=========================================================================
	# mark the stack
	call smark(sp)

#-------------------------------------------------------------------------
#	Set or reset whether any requested option calls for interpreting 
#	coordinates in the descriptor
#-------------------------------------------------------------------------
	rg_coording = rg_coords_q(parsing)
	if (rg_coording) {
	    # -------------------------------------------
	    # Set up default coordinate system parameters
	    # -------------------------------------------

	    # get the default pixel transform
	    len = envgets("PIXSYS", pixsys, 10)
	    if ( streq(pixsys, "PHYSICAL") )
		rg_pixsys = PHYS
	    else
		rg_pixsys = LOGI

	    # if there's a reference image with a WCS, set up transformation 
	    #  matrix to convert physical coordinates to logical
	    if ( rg_imsystem != NONE ) {
		if (rg_imwcs != NULL)
		    rg_ctpix = mw_sctran(rg_imwcs, "physical", "logical", 0)
		else
		    call error(1, 
		     "rg_imsystem but no rg_imwcs; direct call to rg_parse()?")
	    }

	    rg_ref_active = false	# no ref file in descriptor yet
	}

#-------------------------------------------------------------------------
#	Set or reset whether any requested option calls for compiling 
#	virtual CPU programs
#-------------------------------------------------------------------------
	rg_compiling = rg_compile_q(parsing)
	if (rg_compiling) {
	    # ----------------------------------------
	    # Allocate multi region control structures
	    # ----------------------------------------
	    call salloc(rg_slices, LEN_MULTI, TY_STRUCT)  # multi slice struct
	    call salloc(rg_annuli, LEN_MULTI, TY_STRUCT)  # multi annuli struct
	}

#-------------------------------------------------------------------------
#	Set or reset whether any requested option calls for executing 
#	virtual CPU programs
#-------------------------------------------------------------------------
	rg_executing = rg_execute_q(parsing)

#-------------------------------------------------------------------------
#	Set or reset whether creating a mask -- i.e., whether OPENMASK 
#	is requested and the mask isn't already open
#-------------------------------------------------------------------------
	rg_making_mask = rg_make_mask_q(parsing)
	if (rg_making_mask) {
	    # -----------------------------------------------
	    # initialize the pm to flush to and flag the type
	    # -----------------------------------------------
	    call rg_init(MASKPTR(parsing), SELPLPM(parsing))

	    # --------------------------------------------------
	    # create temp file for deferred virtual CPU programs
	    #  (for EXCLUDE regions)
	    # --------------------------------------------------
	    exclfd = open("spool2", READ_WRITE, SPOOL_FILE)
	}

#=========================================================================
#	Do option-independent setup
#=========================================================================

#-------------------------------------------------------------------------
#	Copy the command string to a temp file; the descriptor is a tree 
#	of files (since a descriptor file may reference other descriptor 
#	files), with the command string file as the root
#-------------------------------------------------------------------------
	rg_fd = open("spool1", READ_WRITE, SPOOL_FILE)
	# write the s buffer (or "FIELD\n", in special cases) to the file
	# first look for an abbreviation of "NONE"
	if( rg_none(s) ){
	    call fprintf(rg_fd, "%s\n")
	    call pargstr("FIELD")
	}
	else if( streq("", s) ){
	    call fprintf(rg_fd, "%s\n")
	    call pargstr("FIELD")
	}
	else{	# SZ_OBUF code adapted from disp_plhead() [Dennis]
            len = strlen(s)
            clen = 0
            while( clen < len ){    # print in lumps of SZ_OBUF
	        call fprintf(rg_fd, "%s")
	        call pargstr(s[clen+1])
                clen = clen + SZ_OBUF  # SZ_OBUF is an IRAF string limit
            }
	    call fprintf(rg_fd, "\n")
	}
	# rewind the spool file
	call seek(rg_fd, BOF)
	# set it up as first in fd stack
	rg_fdlev = 1
	rg_fds[rg_fdlev] = rg_fd

#-------------------------------------------------------------------------
#	Prepare for the parsing loop
#-------------------------------------------------------------------------

	# set up the keyword lookup table
	call rg_defkeywords()

	# give the lexical analyzer and xyacc action routines access to 
	#  the parsing control structure (via common)
	rg_parsing = parsing

	# allocate buffer for short strings for lexical analysis
	call salloc(shortstrs, SZ_SBUF, TY_CHAR)	# string scratch buffer

	# initialize parsing variables
	parsed_ok = true		# OK so far
	rg_eflag = NO			# no errors as yet	[never used]
	rg_lptr = 0 			# no string to parse yet

	# set the yyparse debug flag
	if( debug >= 10 )
	    tdebug = 1
	else
	    tdebug = 0

#=========================================================================
#	Parse the descriptor file tree, one command per pass through the 
#	loop, carrying out actions according to the options selected
#=========================================================================
	repeat {
	    # reset rg_nextshortstr and, if compiling, the virtual CPU, 
	    #  for the next command
	    call rg_reset(shortstrs)

	    # parse the command
	    status = yyparse (rg_fd, tdebug, rg_lex)

	    switch ( status ) {

	    	case OK	:
		    if (rg_executing) {
			if (rg_inclreg == YES)	# if INCLUDE region
						# act on the compiled command
	    		    call rg_execute(parsing, debug)
			else			# if EXCLUDE region
			    if (rg_making_mask)	#   and if making mask
						# defer compiled command
				call rg_savecpu(exclfd)
		    }

		case EOF, NOP :
		    ;				# nothing to do

		default : { 	# ERR case is included here
		    call eprintf("line: %s")
		    call pargstr(rg_lbuf)
		    call flush(STDOUT)
		    parsed_ok = false
		}
	    }
	# Now we go until status == EOF
	#
	} until ((status == EOF) || (rg_eflag == YES))

	# If making mask, recall the deferred virtual CPU programs, one by one,
	#  and reset these EXCLUDE regions' pixels in the mask
	if( (rg_making_mask) && (status != ERR) && (rg_eflag != YES) )
	    if( note(exclfd) != BOF )  {
		call seek(exclfd, BOF)
		rg_inclreg = NO	# tell rg_exe1() that these are EXCLUDE regions
		while( rg_recallcpu(exclfd) == YES )
		    call rg_execute(parsing, debug)
	    }

	# Done with the spool files

	if (rg_making_mask)
	    call close(exclfd)

	call close(rg_fd)
	rg_fdlev = 0

	# [Previously, if the parse didn't finish OK, we wouldn't pass back 
	#  the expanded descriptor.  Now we do.  The calling program must 
	#  verify the return code before using the expanded descriptor.  
	# (EXPDESCPTR(parsing) points to the expanded descriptor, 
	#  if RGPARSE_OPT(EXPDESC, parsing) != NULL.)]

	if (rg_coording) {
	    if (rg_ref_active)
		# close .reg-specified ref file MWCS
		call mw_close(rg_refimw)
	}

	# free allocated stack space
	call sfree(sp)

	# return completion flag
	return(parsed_ok)
end

#
# RG_NONE -- look for "none" (or abbrev) (case not significant), optionally 
#            preceded by whitespace; or for only whitespace
#
bool procedure rg_none(s)

char	s[ARB]				# i: string in question
char	t[5]				# l: "NONE" string
int	i				# l: loop variable

begin
	# seed the reference string
	call strcpy("NONE", t, 5)	
	i = 1

	# skip white space
	while ( IS_WHITE(s[i]) && s[i] != EOS )
		i = i + 1
	# white space only => NONE
	if ( s[i] == EOS )
		return(true)

	# check for some abbrev of "NONE"
	while( s[i] != EOS && t[i] != EOS ){
	    if( IS_LOWER(s[i]) ){
		if( TO_UPPER(s[i]) != t[i] )
		    return(false)
	    }
	    else if( s[i] != t[i] )
		    return(false)
	    i = i+1
	}
	return(true)
end

#
# RG_LEX -- Lexical input routine.  Return next token from the input stream.
#           Set associated values in yylval structure.
#
int procedure rg_lex (fd, yylval)

int	fd			# i: region descriptor file handle
				#    (received from rg_yyparse(), but 
				#    unnecessary, as we always read from 
				#    /regcom/ variable rg_fd (which is the 
				#    location fd is bound to, and whose 
				#    contents may be changed by rg_popfd())
pointer	yylval			# i: pointer to semantic value structure 
				#    for lexical token
				# o: data characterizing the token found, in 
				#    fields of the semantic value structure

int	it			# l: temp index into rg_lbuf, in prescan for 
				#    degrees format, and in prescan for 
				#    equinox shortcut spec
int	junk			# l: for grabbing unneeded function values
double	dval			# l: decoded value of numeric string
char	cbuf[SZ_LINE]		# l: temp char buffer
int	token			# l: token returned by rg_lex() to rg_yyparse()
pointer	shortstr		# l: pointer to newest string appended to 
				#    rg_parse()'s shortstrs buffer; may be a 
				#    multi region dummy variable, keyword 
				#    name or abbreviation, or file name, 
				#    buffered from within rg_lbuf
pointer	nextch			# l: pointer to space after shortstr so far
int	kwi			# l: matched keyword's index into lookup table
int	nchar			# l: length of numeric string; or
				#    length of ref image file spec
int	numtype			# l: lexical type of numeric string

int	getanyline()		#  : get a line
int	strlen()		#  : string length
int	lexnum()		#  : numeric (or non-numeric) type of string
int	gctod()			#  : ASCII to double
int	rg_isn()		#  : check for "n=<num>" syntax
int	rg_lookup()		#  : check whether Memc[shortstr] is a keyword 
				#    or abbreviation of a keyword
int	rg_refspec()		#  : buffer ref image file spec
int	rg_isfile()		#  : check whether Memc[shortstr], or 
				#    Memc[shortstr].reg, specifies an 
				#    existing file

include "regparse.com"

begin

#=========================================================================
#	Advance rg_lptr to start of next token; this may involve reading 
#	from rg_fd into rg_lbuf, until have a nonempty non-comment input 
#	line.  (Newline is a token.)
#=========================================================================

	while( rg_lptr == 0) {

#-------------------------------------------------------------------------
#	    # Read next line.  On EOF, if there's a pushed file, pop it.
#-------------------------------------------------------------------------
	    if (getanyline (rg_fd, rg_lbuf, SZ_REGINPUTLINE) == EOF) {
		# check for a pushed file
		if( rg_fdlev == 1 ){
		  return (YYEOF)
		}
		# and pop it
		else
		  call rg_popfd()
	    } else{
		# skip blank lines and lines beginning with "#"
		if( (strlen(rg_lbuf) >1) && (rg_lbuf[1] != '#') ){
		    # point the lptr to the first character
		    rg_lptr = 1
		}
	    }
	}

#-------------------------------------------------------------------------
#	(Skip white space.)
#-------------------------------------------------------------------------
	while (IS_WHITE (rg_lbuf[rg_lptr]))
		rg_lptr = rg_lptr + 1

#=========================================================================
#	If digit, '.', or "-<digit>[...]":
#=========================================================================
	if (   IS_DIGIT(rg_lbuf[rg_lptr]) ||
	       rg_lbuf[rg_lptr] == '.'    ||
	     ( rg_lbuf[rg_lptr] == '-' && IS_DIGIT(rg_lbuf[rg_lptr + 1]) ) ) {

#-------------------------------------------------------------------------
#	    # Preload O_NTYPE(yylval) as TY_REAL, but then prescan ahead 
#	    #	enough to distinguish TY_HMS or TY_DEG.
#-------------------------------------------------------------------------
 	    O_NTYPE(yylval) = TY_REAL

	    # Look ahead for a ':', indicating HMS format.
	    #
	    if ( rg_lbuf[rg_lptr+1] == ':' || 
		 rg_lbuf[rg_lptr+2] == ':' || 
		 rg_lbuf[rg_lptr+3] == ':' )
		O_NTYPE(yylval) = TY_HMS

	    else {
		# Look ahead for terminal 'D' or 'd', indicating Degrees.
		# Upper case or lower case 'D' or 'E' followed by an 
		# optionally signed number is an exponent.  gctod() would 
		# take a terminal 'D' or 'd' as an exponent marker, and 
		# take the next number on the line, following whitespace, 
		# as the exponent.  So we must zap the terminal 'D' or 'd'.
		# [This lexical spec is kludgy, accepting many forms that 
		#  should be illegal.]
		#
		it = rg_lptr
		while ( IS_DIGIT(rg_lbuf[it])  || 
			rg_lbuf[it] == '.'     ||
			rg_lbuf[it] == '+'     ||
			rg_lbuf[it] == '-'     ||
			rg_lbuf[it] == 'D'     ||
			rg_lbuf[it] == 'd'     ||
			rg_lbuf[it] == 'E'     ||
			rg_lbuf[it] == 'e' ) it = it + 1;

		if ( rg_lbuf[it - 1] == 'D' || 
		     rg_lbuf[it - 1] == 'd' ) {
		    O_NTYPE(yylval) = TY_DEG
		    rg_lbuf[it - 1] = ' '
		}
	    }

#-------------------------------------------------------------------------
#	    # Decode to double precision real, using gctod(); 
#	    #	store the result dval in O_VALR(yylval).
#-------------------------------------------------------------------------
	    junk = gctod (rg_lbuf, rg_lptr, dval)	# Crunch the number
	    O_VALR(yylval) = dval

#-------------------------------------------------------------------------
#	    # If there's a units code following, use it to change 
#	    #   O_NTYPE(yylval) (to TY_PIX, TY_RAD, TY_SEC, TY_MIN), 
#	    #   and set rg_lptr past it.
#-------------------------------------------------------------------------
	    switch ( rg_lbuf[rg_lptr] ) {
	    	case 'p', 'P':
		    O_NTYPE(yylval) = TY_PIX	# These are Marking delimiters
	    	    rg_lptr = rg_lptr + 1	# Move past the marker
	    	case 'r', 'R':
		    O_NTYPE(yylval) = TY_RAD
	    	    rg_lptr = rg_lptr + 1
	    	case '"':
		    O_NTYPE(yylval) = TY_SEC
	    	    rg_lptr = rg_lptr + 1
	    	case '\'':
		    O_NTYPE(yylval) = TY_MIN
	    	    rg_lptr = rg_lptr + 1
	    	default:
	    }

#-------------------------------------------------------------------------
#	    # Encode O_VALR(yylval) into local buffer cbuf, with a units code 
#	    #	following.  (If unknown O_NTYPE(yylval), call error, 
#	    #	"unknown number format".)
#-------------------------------------------------------------------------
	    switch ( O_NTYPE(yylval) ) {

	    case TY_DEG :
		call sprintf(cbuf, SZ_LINE, "%gd")
	    case TY_HMS :
		call sprintf(cbuf, SZ_LINE, "%h")
	    case TY_PIX :
		call sprintf(cbuf, SZ_LINE, "%gp")
	    case TY_REAL:
		call sprintf(cbuf, SZ_LINE, "%g")
	    case TY_RAD :
		call sprintf(cbuf, SZ_LINE, "%gr")
	    case TY_SEC :
		call sprintf(cbuf, SZ_LINE, "%g\"")
	    case TY_MIN :
		call sprintf(cbuf, SZ_LINE, "%g'")
	    default:
		call error(1, "unknown number format")
	    }

	    call pargr(O_VALR(yylval))

#-------------------------------------------------------------------------
#	    # Append the encoding in cbuf, followed by a space, to 
#	    # EXPDESCLBUF(rg_parsing).  Return NUMERAL.
#-------------------------------------------------------------------------
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL) {
		call strcat(cbuf, EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
		call strcat(" ", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	    }

	    return NUMERAL
	}

#=========================================================================
#	Else (not a number):
#	Copy the first char into token.
#=========================================================================

	token = rg_lbuf[rg_lptr]	# preload token

#-------------------------------------------------------------------------
#	Check whether token is a special char:
#	# '=':  Append it to EXPDESCLBUF(rg_parsing), step past it 
#	#	(in rg_lbuf).
#	# newline or '#' (comment out rest of line):  Reset rg_lptr (so 
#	#	next call will read a new line).
#	# '+' | '-':  Append it to EXPDESCLBUF(rg_parsing) and step past it, 
#	#	also setting O_VALI(yylval) to INCLUDE | EXCLUDE.
#	# '!' | '&' | '|' | '^':  Append it to EXPDESCLBUF(rg_parsing) 
#	#	(using rg_addop() to get canonical spacing, etc.), and step 
#	#	past it.
#	# '(' | ')':  Append it to EXPDESCLBUF(rg_parsing) (using 
#	#	rg_addparen() to get canonical spacing), and step past it.
#	# ',' | ';' | '\':  Just step past it.
#	If any of these, return token (at end of program).
#-------------------------------------------------------------------------
	switch ( token ) {		# process the current char

	case '=':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call strcat("=", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	    rg_lptr = rg_lptr + 1

	case '\n', '#':
	    rg_lptr = 0

	case '-':
	    O_VALI(yylval) = EXCLUDE
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call strcat("-", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	    rg_lptr = rg_lptr + 1

	case '+':
	    O_VALI(yylval) = INCLUDE
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call strcat("+", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
	    rg_lptr = rg_lptr + 1

	case '!':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addop("!")
	    rg_lptr = rg_lptr + 1
	case '&':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addop("&")
	    rg_lptr = rg_lptr + 1
	case '|':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addop("|")
	    rg_lptr = rg_lptr + 1
	case '^':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addop("^")
	    rg_lptr = rg_lptr + 1

	case '(':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addparen("(")
	    rg_lptr = rg_lptr + 1

	case ')':
	    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		call rg_addparen(")")
	    rg_lptr = rg_lptr + 1

	case ',', ';', '\\':
	    rg_lptr = rg_lptr + 1

	default:
#=========================================================================
#	(Not a number, not a 1-char special code) Check for other things:
#
#	    First, 'J' | 'j' | 'B' | 'b', followed by a decimal number 
#	    between 1899.0 and 2101.0  (Equinox short cut spec):
#=========================================================================
	    if ( ( token == 'J' || token == 'j' || 
		   token == 'B' || token == 'b'    ) )  {
		it = rg_lptr + 1
		numtype = lexnum(rg_lbuf, it, nchar)
		it = rg_lptr + 1
		junk = gctod (rg_lbuf, it, dval)
		if ((IS_DIGIT(rg_lbuf[rg_lptr + 1] )) && 
		    (numtype == LEX_DECIMAL || numtype == LEX_REAL) &&
		    (dval > 1899.0 && dval < 2101.0))  {

#-------------------------------------------------------------------------
#		    # All right, we think this is an equinox shortcut spec.
#		    #
#		    # Step past the letter and the number, and store the 
#		    # decoded value of the number (dval) in O_VALR(yylval).
#-------------------------------------------------------------------------
		    rg_lptr = it
	            O_VALR(yylval) = dval


		    # Is this a Major Equinox?
		    #
#-------------------------------------------------------------------------
#		    # Set O_ECODE(yylval) to J2000, FK5, B1950, or FK4, 
#		    #	according to token and O_VALR(yylval).
#-------------------------------------------------------------------------
		    if ( token == 'J' || token == 'j' )  {
			if ( O_VALR(yylval) == 2000.00 )
			    O_ECODE(yylval) = J2000
			else
			    O_ECODE(yylval) = FK5
		    } else {
			if ( O_VALR(yylval) == 1950.00 )
			    O_ECODE(yylval) = B1950
			else
			    O_ECODE(yylval) = FK4
		    }

#-------------------------------------------------------------------------
#		    # Encode "EQUATORIAL cyyyy.yy" into cbuf (where 'c' is 
#		    #	'J' or 'B', and "yyyy.yy" is O_VALR(yylval).
#-------------------------------------------------------------------------
		    call sprintf(cbuf, SZ_LINE, "%s %c%.2f")
		     call pargstr("EQUATORIAL")
		     if ( ( O_ECODE(yylval) == J2000 ) || 
		          ( O_ECODE(yylval) == FK5   )    )
			 call pargi('J')
		     else
			 call pargi('B')
	             call pargr(O_VALR(yylval))

#-------------------------------------------------------------------------
#		    # Append the encoding in cbuf to EXPDESCLBUF(rg_parsing).
#		    # Return EQEQUIX.
#-------------------------------------------------------------------------
		    if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
			call strcat(cbuf, EXPDESCLBUF(rg_parsing), 
							SZ_REGOUTPUTLINE)
		    return EQEQUIX
		}
	    }

#=========================================================================
#	    Else (not number, not 1-char special code, 
#	    	not Equinox short cut spec):
#=========================================================================

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#-------------------------------------------------------------------------
#	    Point shortstr to next space in rg_parse()'s shortstrs buffer, 
#	    	and initialize nextch (where to put the next character 
#	    	of Memc[shortstr]) to the same place.
#-------------------------------------------------------------------------
	    shortstr = rg_nextshortstr
	    nextch = shortstr

#-------------------------------------------------------------------------
#	    Scan, copying to Memc[nextch] (next loc in shortstr buffer), 
#	    	until char not alphanumeric, nor {'.' | '_' | '/' | '$'}.
#	    	[Could be empty string -- bug.]
#-------------------------------------------------------------------------
	    while( IS_ALNUM(rg_lbuf[rg_lptr]) || (rg_lbuf[rg_lptr] == '.') ||
		    (rg_lbuf[rg_lptr] == '_') || (rg_lbuf[rg_lptr] == '/') ||
		    (rg_lbuf[rg_lptr] == '$') ){

		    Memc[nextch] = rg_lbuf[rg_lptr]

		    nextch  = nextch + 1	    # bump the pointers
		    rg_lptr = rg_lptr + 1
	    }

#-------------------------------------------------------------------------
#	    Terminate the shortstr string with EOS.
#-------------------------------------------------------------------------
	    Memc[nextch] = EOS			# finish the string
	    rg_nextshortstr = nextch + 1    	# set shortstrs buffer pointer 
						#  past this shortstr string
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#-------------------------------------------------------------------------
#	    Check for "n=<num>" syntax:
#	    If shortstr string is a single alpha and rg_lbuf continues after 
#	    	the recent scan with "[<whitespace>]=", it's 
#	    	the "n=<num>" syntax:
#	    # Append the shortstr string (1 letter) to EXPDESCLBUF(rg_parsing),
#	    	change token to ID.
#-------------------------------------------------------------------------
	    if( rg_isn(Memc[shortstr], rg_lbuf[rg_lptr]) == YES){
		token = ID
		if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
		    call strcat(Memc[shortstr], EXPDESCLBUF(rg_parsing), 
							SZ_REGOUTPUTLINE)
	    }

#=========================================================================
#	    Else (not number, not 1-char special code, 
#	    	not Equinox short cut spec, not "n=<num>" syntax):
#=========================================================================

#-------------------------------------------------------------------------
#	    If the shortstr string matches any shape name or other keyword 
#	    	(or abbreviation of one), rg_lookup() returns the index into 
#		the keyword table.
#-------------------------------------------------------------------------
	    else if( rg_lookup(Memc[shortstr],	kwi) == YES ) {
		token = rg_ktype[kwi]
		O_VALI(yylval) = kwi
		O_KCODE(yylval) = rg_codes[kwi]		# needed if COORDS

#-------------------------------------------------------------------------
#		# Unless token is EQUATO, append the keyword's name string, 
#		#	followed by a space, to EXPDESCLBUF(rg_parsing).  
#		#	("EQUATORIAL" is put into EXPDESCLBUF(rg_parsing) 
#		#	when the equinox code is processed; see above.)
#-------------------------------------------------------------------------
		if ( token != EQUATO && 
			RGPARSE_OPT(EXPDESC, rg_parsing) != NULL ) {
		    call strcat(Memc[rg_names[kwi]], EXPDESCLBUF(rg_parsing), 
							SZ_REGOUTPUTLINE)
		    call strcat(" ", EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
		}
#-------------------------------------------------------------------------
#		# If token is REFFIL, or keyword code is LOGI, try to 
#		#	scan a reference file spec, return 
#		#	it as value associated with the token.
#-------------------------------------------------------------------------
		if ( token == REFFIL || rg_codes[kwi] == LOGI ) {
		    while(IS_WHITE (rg_lbuf[rg_lptr]))
			rg_lptr = rg_lptr + 1
		    nchar = rg_refspec(rg_lbuf[rg_lptr], Memc[rg_nextshortstr])

		    # Assigning to O_FNPTR(yylval), we overwrite 
		    # O_KCODE(yylval); we'll use O_VALI(yylval) and 
		    # O_FNPTR(yylval) for REFFIL and PIXSYS tokens, 
		    # not O_KCODE(yylval).

		    if (nchar > 0) {
			O_FNPTR(yylval) = rg_nextshortstr
			if (RGPARSE_OPT(EXPDESC, rg_parsing) != NULL)
			    call strcat(Memc[rg_nextshortstr], 
				    EXPDESCLBUF(rg_parsing), SZ_REGOUTPUTLINE)
			rg_nextshortstr = rg_nextshortstr + nchar + 1
			rg_lptr = rg_lptr + nchar
		    } else {
			O_FNPTR(yylval) = NULL
		    }
		}
	    }

#=========================================================================
#	    Else (not number, not 1-char special code, not Equinox 
#	    	short cut spec, not "n=<num>" syntax, not region name):
#=========================================================================

#-------------------------------------------------------------------------
#	    If the shortstr string, or the shortstr string with REGEXT 
#	    	appended, accesses a file, change token to REGFIL and set 
#		O_FNPTR(yylval) to shortstr.
#-------------------------------------------------------------------------
	    else if ( rg_isfile(Memc[shortstr]) == YES ) {
		token = REGFIL
		O_FNPTR(yylval) = shortstr
	    }

#=========================================================================
#	    Else (not number, not 1-char special code, not Equinox 
#	    	short cut spec, not "n=<num>" syntax, not region name, 
#	    	not a file specification):
#=========================================================================

	    else {
#-------------------------------------------------------------------------
#		# Buffer error message in cbuf, call error with cbuf.
#		# Set token to ')', to cause a syntax error.
#		# Return.
#-------------------------------------------------------------------------
		call sprintf(cbuf, SZ_LINE, "unknown token: %s")
		call pargstr(Memc[shortstr])
		call error(1, cbuf)
		token = ')'		# cause syntax error
		return
	    }
	}

#=========================================================================
#	return token (all cases except YYEOF, NUMERAL, EQEQUIX)
#=========================================================================
	return(token)			# return what we found
end
define	YYNPROD		41
define	YYLAST		258
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

short	yyexca[26]
data	(yyexca(i),i=  1,  8)	/  -1,   1,   0,  -1,  -2,   0,  -1,  40/
data	(yyexca(i),i=  9, 16)	/  10,  18,  59,  18,  -2,  34,  -1,  45/
data	(yyexca(i),i= 17, 24)	/ 257,  34, 266,  34,  92,  34,  35,  34/
data	(yyexca(i),i= 25, 26)	/  -2,  27/
short	yyact[258]
data	(yyact(i),i=  1,  8)	/  12,  63,  43,  44,  14,  39,  66,  41/
data	(yyact(i),i=  9, 16)	/  42,  12,  64,  15,  27,  27,  27,  51/
data	(yyact(i),i= 17, 24)	/  48,  65,  12,  62,  27,  46,  54,  14/
data	(yyact(i),i= 25, 32)	/  54,  60,  57,   3,  54,  53,  15,  40/
data	(yyact(i),i= 33, 40)	/  13,  25,  16,  24,   8,  27,   7,   6/
data	(yyact(i),i= 41, 48)	/   5,   4,  36,  37,  38,   1,   0,   0/
data	(yyact(i),i= 49, 56)	/   0,  11,  49,  50,   0,   0,   0,  45/
data	(yyact(i),i= 57, 64)	/   2,   0,  11,   0,  26,  30,  31,  32/
data	(yyact(i),i= 65, 72)	/  33,  34,  35,  11,  29,  29,  29,  52/
data	(yyact(i),i= 73, 80)	/   0,  47,  56,  61,  55,  58,  59,   0/
data	(yyact(i),i= 81, 88)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i= 89, 96)	/   0,   0,   0,   0,   0,  29,   0,   0/
data	(yyact(i),i= 97,104)	/   0,   0,  28,  28,   0,   0,   0,   0/
data	(yyact(i),i=105,112)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=113,120)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=121,128)	/   0,   0,   0,  28,   0,   0,   0,   0/
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
data	(yyact(i),i=217,224)	/   0,   0,   0,   0,  41,   0,  41,   0/
data	(yyact(i),i=225,232)	/   0,   0,   0,   0,   0,  23,   0,   0/
data	(yyact(i),i=233,240)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=241,248)	/   0,   0,   0,   0,   0,   0,   0,   0/
data	(yyact(i),i=249,256)	/  23,  19,  20,  22,  21,   9,  17,  18/
data	(yyact(i),i=257,258)	/   0,  10/
short	yypact[67]
data	(yypact(i),i=  1,  8)	/ -10,-1000,-1000,  -1,   8,   8,   8,   8/
data	(yypact(i),i=  9, 16)	/   8,   8,-1000,-1000,-1000,-1000, -29, -29/
data	(yypact(i),i= 17, 24)	/ -29, -35,-1000,-1000,-249,-1000,-260, -37/
data	(yypact(i),i= 25, 32)	/-1000,-1000,-1000, -19, -19, -19,-1000,-1000/
data	(yypact(i),i= 33, 40)	/-1000,-1000,-1000,-1000,-1000, -26, -25,-250/
data	(yypact(i),i= 41, 48)	/ -20,-1000,-1000,-1000,-250, -20, -29,  16/
data	(yypact(i),i= 49, 56)	/-1000, -29, -29,-1000, -16, -19,-1000, -22/
data	(yypact(i),i= 57, 64)	/-1000,-1000, -24, -18,-1000,-256,-1000,-1000/
data	(yypact(i),i= 65, 67)	/ -44,-251,-1000/
short	yypgo[14]
data	(yypgo(i),i=  1,  8)	/   0,  45,  56,  27,  41,  40,  39,  38/
data	(yypgo(i),i=  9, 14)	/  36,  31,  34,  32,  21,  29/
short	yyr1[41]
data	(yyr1(i),i=  1,  8)	/   0,   1,   1,   1,   1,   1,   1,   1/
data	(yyr1(i),i=  9, 16)	/   1,   1,   1,   6,   7,   8,   8,   8/
data	(yyr1(i),i= 17, 24)	/   8,   5,   5,   4,   3,   3,   3,   3/
data	(yyr1(i),i= 25, 32)	/   3,   3,  11,  11,  11,   9,   9,   9/
data	(yyr1(i),i= 33, 40)	/  10,  10,  13,  13,  12,  12,  12,   2/
data	(yyr1(i),i= 41, 41)	/   2/
short	yyr2[41]
data	(yyr2(i),i=  1,  8)	/   0,   0,   1,   2,   2,   2,   2,   2/
data	(yyr2(i),i=  9, 16)	/   2,   2,   1,   1,   1,   1,   2,   1/
data	(yyr2(i),i= 17, 24)	/   2,   4,   2,   2,   1,   2,   4,   4/
data	(yyr2(i),i= 25, 32)	/   4,   3,   4,   2,   1,   1,   4,   6/
data	(yyr2(i),i= 33, 40)	/   1,   1,   0,   1,   0,   2,   1,   1/
data	(yyr2(i),i= 41, 41)	/   1/
short	yychk[67]
data	(yychk(i),i=  1,  8)	/-1000,  -1,  -2,  -3,  -4,  -5,  -6,  -7/
data	(yychk(i),i=  9, 16)	/  -8, 263, 267,  59,  10, -11,  33,  40/
data	(yychk(i),i= 17, 24)	/ -10, 264, 265, 259, 260, 262, 261, 258/
data	(yychk(i),i= 25, 32)	/  45,  43,  -2,  38, 124,  94,  -2,  -2/
data	(yychk(i),i= 33, 40)	/  -2,  -2,  -2,  -2,  -3,  -3,  -3,  40/
data	(yychk(i),i= 41, 48)	/  -9, 257, 257, 262,  40,  -9, -12,  92/
data	(yychk(i),i= 49, 56)	/  35, -12, -12,  41,  -9, -13,  44,  -9/
data	(yychk(i),i= 57, 64)	/  -3,  10,  -3,  -3,  41, -12,  41, 257/
data	(yychk(i),i= 65, 67)	/ 266,  61, 257/
short	yydef[67]
data	(yydef(i),i=  1,  8)	/   1,  -2,   2,   0,   0,   0,   0,   0/
data	(yydef(i),i=  9, 16)	/   0,   0,  10,  39,  40,  20,   0,   0/
data	(yydef(i),i= 17, 24)	/   0,   0,  11,  12,  13,  15,   0,  28/
data	(yydef(i),i= 25, 32)	/  32,  33,   3,  36,  36,  36,   4,   5/
data	(yydef(i),i= 33, 40)	/   6,   7,   8,   9,  21,   0,  19,   0/
data	(yydef(i),i= 41, 48)	/  -2,  29,  14,  16,   0,  -2,   0,   0/
data	(yydef(i),i= 49, 56)	/  38,   0,   0,  25,  34,  36,  35,  34/
data	(yydef(i),i= 57, 64)	/  22,  37,  23,  24,  17,   0,  26,  30/
data	(yydef(i),i= 65, 67)	/   0,   0,  31/

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
# line 101 "regparse.yy"
{
			return OK
		}
case 3:
# line 104 "regparse.yy"
{
			call rg_endexpr()
			return OK
		}
case 4:
# line 108 "regparse.yy"
{
			call rg_endexpr()
			return OK
		}
case 5:
# line 112 "regparse.yy"
{
			call rg_saveexpr()
			return NOP
		}
case 6:
# line 116 "regparse.yy"
{
			call rg_saveexpr()
			return NOP
		}
case 7:
# line 120 "regparse.yy"
{
			call rg_saveexpr()
			return NOP
		}
case 8:
# line 124 "regparse.yy"
{
			call rg_saveexpr()
			return NOP
		}
case 9:
# line 128 "regparse.yy"
{
			# New region descriptor file called from old one
			call rg_newregfile(yypvt-YYOPLEN)
			return OK
		}
case 10:
# line 133 "regparse.yy"
{
			return EOF
		}
case 11:
# line 139 "regparse.yy"
{
			# Set up coordinate system of reference image
			call rg_reffil(yypvt)
		}
case 12:
# line 146 "regparse.yy"
{
			# Set up pixel conversion system
			call rg_setpixsys(yypvt)
		}
case 13:
# line 153 "regparse.yy"
{				# Coordinate system
			call rg_setcoord(O_KCODE(yypvt))
 		}
case 14:
# line 156 "regparse.yy"
{
			if ( O_KCODE(yypvt-YYOPLEN) != ECL ) 
				call error(1, "Invalid use of equinox")
			call rg_setcoord(O_KCODE(yypvt-YYOPLEN))
			call rg_setequix(O_VALR(yypvt))
		}
case 15:
# line 162 "regparse.yy"
{		# These are necessary because 
					# EQUATORIAL is an optional key word.
			call rg_setcoord(O_ECODE(yypvt))
			call rg_setequix(O_VALR(yypvt))
		}
case 16:
# line 167 "regparse.yy"
{
			call rg_setcoord(O_ECODE(yypvt))
			call rg_setequix(O_VALR(yypvt))
		}
case 17:
# line 174 "regparse.yy"
{
		}
case 18:
# line 176 "regparse.yy"
{
		}
case 19:
# line 181 "regparse.yy"
{
			# If iflag is '-', reset rg_inclreg, to defer execution
			#  (for EXCLUDE region)
			call rg_exclincl(O_VALI(yypvt-YYOPLEN))
		}
case 20:
# line 189 "regparse.yy"
{
			# New temp mask
			call rg_newop (O_REG(yypvt))
		}
case 21:
# line 193 "regparse.yy"
{
			# Boolean NOT
			call rg_unop ()
		}
case 22:
# line 197 "regparse.yy"
{
			# Boolean AND
			call rg_binop (OP_AND)
		}
case 23:
# line 201 "regparse.yy"
{
			# Boolean OR
			call rg_binop (OP_OR)
		}
case 24:
# line 205 "regparse.yy"
{
			# Boolean XOR
			call rg_binop (OP_XOR)
		}
case 25:
# line 209 "regparse.yy"
{
		}
case 26:
# line 214 "regparse.yy"
{
			# Convert args to pixels, expand accelerators, 
			#  move processed arg list to own space, clr arg bufs
			call rg_region(O_VALI(yypvt-3*YYOPLEN), yyval)
		}
case 27:
# line 219 "regparse.yy"
{
			# Convert args to pixels, expand accelerators, 
			#  move processed arg list to own space, clr arg bufs
			call rg_region(O_VALI(yypvt-YYOPLEN), yyval)
		}
case 28:
# line 224 "regparse.yy"
{
			# No args: clear rg_nargs
			call rg_startarglist (NULL, 0)
			# Set up reg structure
			call rg_region(O_VALI(yypvt), yyval)
		}
case 29:
# line 233 "regparse.yy"
{
			# First arg: buffer it in rg_args[1], rg_types[1]
			call rg_startarglist (yypvt, O_NTYPE(yypvt))
		}
case 30:
# line 237 "regparse.yy"
{
			# Extend rg_args[], rg_types[], buffering new arg
			call rg_addarg (yypvt, O_NTYPE(yypvt))
		}
case 31:
# line 241 "regparse.yy"
{
			# Extend rg_args[], rg_types[], buffering multi count
			call rg_addarg (yypvt, TY_INC)
		}	}

	goto yystack_				# stack new state and value
end
