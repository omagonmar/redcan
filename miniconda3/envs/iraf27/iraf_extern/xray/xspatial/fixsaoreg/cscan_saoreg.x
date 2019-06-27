# $Header: /home/pros/xray/xspatial/fixsaoreg/RCS/cscan_saoreg.x,v 11.0 1997/11/06 16:33:24 prosb Exp $
# $Log: cscan_saoreg.x,v $
# Revision 11.0  1997/11/06 16:33:24  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:56:01  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:22:08  prosb
#General Release 2.2
#
#Revision 5.2  93/05/03  18:55:41  dennis
#Changed the call to rg_lookup() to match its new argument list;
#brought up to date the use of the variables in the former arg list
#
#Revision 5.1  93/03/05  01:31:07  dennis
#Corrected conversion of measures of extension (radius, width, etc.).
#
#Revision 5.0  92/10/29  21:35:33  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:36  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  16:36:55  dennis
#Initial version
#
#
# Module:	cscan_saoreg
# Project:	PROS -- ROSAT RSDC
# Purpose:	Scan and convert a region descriptor file, the main work of 
#		task fixsaoreg.
# Local:	saoregshapes(), setphys(), setlogi()
# Description:	Transforms from logical to physical coordinates 
#		in a regions file of SAOimage cursors, or from 
#		physical to logical coordinates in a regions file 
#		to become SAOimage cursors
#
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Dennis Schmidt -- initial version -- 3/92
#		{n} <who> -- <does what> -- <when>
#
#--------------------------------------------------------------------------

include <ctype.h>
include	<regparse.h>
include <error.h>
include <printf.h>		# defines SZ_OBUF

define	TO_PROS		0
define	TO_SAOIM	1

define	ANN_NRADII_LINE_1	13
define	ANN_NRADII_LINE_N	16
define	POLY_NCOORDS_LINE_1	16
define	POLY_NCOORDS_LINE_N	16

define	ARROW		120
define	TEXT		121

define	MAX_TEXT	126	# Max TEXT string that will fit in SZ_LINE
define	LONG_TEXT_MSG	"Text too long to convert"

#
# cscan_saoreg -- (This is based on rg_lex() and rg_region().)
#
procedure cscan_saoreg (infd, outfd, regi_buf, imw)

int	infd			# i: input file channel
int	outfd			# i: output file channel
char	regi_buf[ARB]		# i: regions input line buffer
pointer	imw			# i: MWCS descriptor on image named in infd

pointer	sp			# l: stack pointer
int	regi_buf_x		# l: index into regi_buf[]
bool	echo_input		# l: whether to put out input line as 
				#	comment (no if continuation line)
pointer	rego_buf		# l: output buffer of length SZ_LINE
int	llen			# l: length of input string chunk just put out
int     plen                    # l: length of input line already put out
int     len                     # l: length of complete input line; or 
				#	strlen("ARROW") or strlen("TEXT")
bool	text_too_long		# l: Text string length > MAX_TEXT
char	ch			# l: character being tested
pointer	test_string		# l: string to test
int	ii			# l: increment of test_string
bool	first_cmd		# l: looking for first region shape or 
				#	coordinate system specification
int	direction		# l: conversion TO_PROS or TO_SAOIM
pointer	ict			# l: coordinate transformation descriptor
int	kwi			# l: index into region shape keyword table
int	code			# l: region shape code
int	minargs			# l: min # args for region type
int	nargs_done		# l: # args already processed for region
int	nargs_to_nl		# l: if TO_PROS, # ANNULUS or POLYGON args 
				#	till new line required
bool	will_save		# l: save current arg to pair with next
bool	did_save		# l: saved previous arg to pair with this one
bool	will_convert		# l: transform this arg (rather than pass thru)
double	dval			# l: numeric value of shape parameter string
double	dsaved			# l: saved numeric value of preceding string
double	xtrand			# l: transformed (physical) x coord
double	ytrand			# l: transformed (physical) y coord
int	junk			# l: receives unneeded function value

int	strlen()
bool	streq()
int	getlline()              # l: input line from regions file
int	gstrcpy()
int	gctod()			# l: decode ASCII to double
double	mw_c1trand()		#  : transform a measure of extension
int	rg_lookup()		# l: look up region name in table

include <regions/regparse.com>	# contains rg_installed, rg_eflag
				#  (used by rg_install(), rg_lookup())

begin

    call smark(sp)
    call salloc(test_string, SZ_LINE, TY_CHAR)
    call salloc(rego_buf, SZ_LINE, TY_CHAR)

    rg_eflag = NO
    rg_installed = 0
    call saoregshapes()	# set up table of SAOimage cursor shapes

    echo_input = false
    first_cmd = true
    code = 0
    did_save = false	# nec. here, to enable printing special chars
    regi_buf_x = 0

    repeat {

#=========================================================================
#	Process next character (or number or region name); 
#	this may involve reading a new line from infd into regi_buf.
#=========================================================================

	if (regi_buf_x == 0) {

#-------------------------------------------------------------------------
#	    # Read next line.
#-------------------------------------------------------------------------
	    if (getlline (infd, regi_buf, SZ_MASKTITLE + SZ_LINE) == EOF) {
		call sfree(sp)
		return
	    } else {
		if (echo_input && regi_buf[1] != '#' && !first_cmd) {
		    # If not continuation, comment, or first non-comment 
		    #	line, print out the input line as comment
		    # (Don't let any line exceed SZ_LINE)

		    len = strlen(regi_buf)
		    plen = 0
		    while (plen < len) {	# print lines <= SZ_LINE
			call fprintf(outfd, "##")
			llen = gstrcpy(regi_buf[plen+1], Memc[rego_buf], 
							SZ_LINE - 3)
			call fprintf(outfd, "%s")
			call pargstr(Memc[rego_buf])
			if (Memc[rego_buf + llen - 1] != '\n') {
			    call fprintf(outfd, "\n")
			}
			plen = plen + SZ_LINE - 3
		    }
		}
		echo_input = true
		# point regi_buf_x to the first character
		regi_buf_x = 1
	    }
	}

#=========================================================================
#	If digit, '.', or "-<digit>[...]":
#=========================================================================
	ch = regi_buf[regi_buf_x]
	if (   IS_DIGIT(ch) || ch == '.'    ||
	     ( ch == '-' && IS_DIGIT(regi_buf[regi_buf_x + 1]) ) ) {

	    if (code == 0) {
		call error(EA_FATAL, 
			"regions file has parameter without region name")
	    }

#-------------------------------------------------------------------------
#	    # Decide what to do with this number:
#	    # Save, waiting for other coordinate of pair, or
#	    # convert to physical measure(s), or pass through unconverted.
#-------------------------------------------------------------------------
	    switch (nargs_done) {
		case 0:					# x position
		    will_save = true
		    if (direction == TO_PROS) {
			if (code == ANNULUS) {
			    nargs_to_nl = ANN_NRADII_LINE_1
			} else if (code == POLYGON) {
			    nargs_to_nl = POLY_NCOORDS_LINE_1
			}
		    }
		case 1:					# y position
		    ;
		case 2:
		    switch (code) {
			case TEXT:			# number of characters
			    will_convert = false
			case CIRCLE, ANNULUS, ELLIPSE, BOX, ARROW:   # radius, 
							#     width, or length
			    will_convert = true
			case POLYGON:			# 2nd x
			    will_save = true
			default:			# POINT
			    call error(EA_FATAL, 
	"regions file has unknown region type or POINT with 3 parameters")
		    }
		case 3:
		    switch (code) {
			case ARROW:			# ??
			    will_convert = false
			case ANNULUS, ELLIPSE, BOX:	# radius or height
			    will_convert = true
			case POLYGON:			# 2nd y
			    ;
			default:			# CIRCLE, TEXT
			    call error(EA_FATAL, 
	"regions file has CIRCLE or TEXT with 4 (numeric) parameters")
		    }
		case 4:
		    switch (code) {
			case ARROW, BOX, ELLIPSE:	# angle
			    will_convert = false
			case ANNULUS:			# radius
			    will_convert = true
			case POLYGON:			# 3rd x
			    will_save = true
			default:
			    call error(EA_FATAL, 
	"regions file has unknown region with 5 or more parameters")
		    }
		default:
		    switch (code) {
			case ANNULUS:			# radius
			    will_convert = true
			case POLYGON:
			    if (!did_save) {		# x (1st of pair)
				will_save = true
			    }
			default:			# ARROW, BOX, ELLIPSE
			    call error(EA_FATAL, 
	"regions file has ARROW, BOX, or ELLIPSE with 6 parameters")
		    }
	    }

#-------------------------------------------------------------------------
#	    # Decode to double precision real, using gctod(); 
#	    #	the result is dval.
#-------------------------------------------------------------------------
	    junk = gctod (regi_buf, regi_buf_x, dval)	# Crunch the number

#-------------------------------------------------------------------------
#	    # Save till get next coordinate, or convert, or convert pair.
#	    # Print out measure(s).
#-------------------------------------------------------------------------
	    if (will_save) {
		dsaved = dval
		will_save = false
		did_save = true
	    } else {
		if (did_save) {
		    call mw_c2trand (ict, dsaved, dval, xtrand, ytrand)

		    # Print it out
		    # If necessary, break long polygon line
		    if (direction == TO_PROS) {
			if (code == POLYGON) {
			    if (nargs_to_nl <= 1) {
				call fprintf(outfd, "\\\n")
				nargs_to_nl = POLY_NCOORDS_LINE_N
			    }
			nargs_to_nl = nargs_to_nl - 2
			}
		    }
		    call fprintf(outfd, "%.2f,%.2f")
		    call pargd(xtrand)
		    call pargd(ytrand)
		    did_save = false

		} else {
		    if (will_convert) {
			dval = abs(mw_c1trand (ict, dval) - 
			           mw_c1trand (ict, 0.  )   )
		    } else if (code == TEXT && nargs_done == 2) {
			if (dval > MAX_TEXT) {
			    text_too_long = true
##			    dval = strlen(LONG_TEXT_MSG)
			} else {
			    text_too_long = false
			}
		    }
		    # Print it out
		    # If necessary, break long annulus line
		    if (direction == TO_PROS) {
			if (code == ANNULUS) {
			    if (nargs_to_nl <= 0) {
				call fprintf(outfd, "\\\n")
				nargs_to_nl = ANN_NRADII_LINE_N
			    }
			nargs_to_nl = nargs_to_nl - 1
			}
		    }
		    call fprintf(outfd, "%.3f")
		    call pargd(dval)
		}
	    }

	    nargs_done = nargs_done + 1
	    next
	}

#=========================================================================
#	Else (not a number):
#=========================================================================

#-------------------------------------------------------------------------
#	Check whether special char:
#	# '\\':	reset regi_buf_x, so next pass will read continuation line, 
#	#	and turn off input line echoing (since we're in the middle 
#	#	of an output line).  (Should happen only if direction == 
#	#	TO_SAOIM.)
#	# newline:  Reset code.  Print out '\n'; reset regi_buf_x (so next 
#	#	pass will read a new line).
#	# '#':  Reset code.  If ARROW or TEXT SAOimage command, set code, 
#	#	and set up to process the args.  Print out the 
#	#	comment & '\n', and reset regi_buf_x (so next pass will 
#	#	read a new line).
#	# '"':  This begins 4th (last) arg of TEXT command; reset code, 
#	#	print out the rest of the line & '\n', and reset regi_buf_x 
#	#	(so next pass will read a new line).
#	# '-', '!', '&', '(', ')', ',', ' ', '\t':  Print it out (unless 
#	#	not to first region shape or coord system spec) and 
#	#	step past it.  On ')' or '&', end arg list processing, and 
#	#	check that that's OK.
#-------------------------------------------------------------------------
	switch (ch) {		# process the current char

	case '\\':
	    regi_buf_x = 0
	    echo_input = false
	    call printf("Continuation line not echoed in output file\n")

	case '\n':
	    # Test for premature end of arg list; error if so
	    # (rg_lookup() set minargs except for TEXT, ARROW)
	    if ((code != 0 && nargs_done < minargs) || (code == POLYGON && 
				(nargs_done / 2) * 2 != nargs_done)) {
		call error(EA_FATAL, 
			"regions file has region with too few parameters")
	    }
	    code = 0
	    call fprintf(outfd, "\n") 
	    regi_buf_x = 0

	case '#', '"':
	    code = 0

	    # If '#', check for ARROW or TEXT
	    if (regi_buf_x == 1 && regi_buf[1] == '#' && 
			regi_buf[2] == ' ' && strlen(regi_buf) > 15) {
		regi_buf_x = 3
		if (regi_buf[3] == 'A') {
		    len = strlen ("ARROW")
		} else if (regi_buf[3] == 'T') {
		    len = strlen ("TEXT")
		} else {
		    len = 0
		}
		for (ii = 0;  ii < len;  ii = ii + 1) {
		    Memc[test_string + ii] = regi_buf[regi_buf_x]
		    regi_buf_x = regi_buf_x + 1
		}
		Memc[test_string + ii] = EOS
		if (streq(Memc[test_string], "ARROW")) {
		    if (first_cmd) {
			direction = TO_PROS
			call setphys(imw, ict, outfd)
			first_cmd = false
			echo_input = true
		    }
		    call fprintf(outfd, "##")
		    code = ARROW
		    minargs = 5
		    nargs_done = 0
		} else if (streq(Memc[test_string], "TEXT")) {
		    if (first_cmd) {
			direction = TO_PROS
			call setphys(imw, ict, outfd)
			first_cmd = false
			echo_input = true
		    }
		    call fprintf(outfd, "##")
		    code = TEXT
		    minargs = 4
		    nargs_done = 0
		}
		regi_buf_x = 1
	    }

	    # Print out the (rest of the) line
	    # (Treat appended region header as ordinary comment)

### Don't let any TO-PROS line exceed SZ_LINE.  This is incomplete.  
###  See also comment beginning "##" above.
### The only likely culprit is TEXT (commented and converted, both), 
###	not other comment.

	    while (regi_buf[regi_buf_x] != '\n') {
		# Print out the character
		call fprintf(outfd, "%c")
		call pargc(regi_buf[regi_buf_x])
		regi_buf_x = regi_buf_x + 1
	    }
	    call fprintf(outfd, "\n") 
	    regi_buf_x = 0

	    if (code == ARROW || code == TEXT) {
		call fprintf(outfd, "# %s")
		call pargstr(Memc[test_string])
		regi_buf_x = 3 + len
	    }

	case '-', '!', '&', '(', ')', ',', ' ', '\t':
	    if (ch == ')' || ch == '&') {
		# Test for premature end of arg list; error if so
		# (rg_lookup() set minargs except for TEXT, ARROW)
		if ((code != 0 && nargs_done < minargs) || (code == POLYGON && 
				(nargs_done / 2) * 2 != nargs_done)) {
		    call error(EA_FATAL, 
			"regions file has region with too few parameters")
		}
		code = 0
	    }
	    if (!first_cmd && !did_save) {
		# Print out the character
		call fprintf(outfd, "%c")
		call pargc(ch)
	    }
	    regi_buf_x = regi_buf_x + 1

	default:
#=========================================================================
#	(Not a number, not a special char) Check for region name:
#=========================================================================
	    if (code != 0) {
		call error(EA_FATAL, 
			"region has strange character in parameter list")
	    }
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
#-------------------------------------------------------------------------
#	    Scan, copying to test_string, until char not alphanumeric, 
#	    	nor {'.' | '_' | '/' | '$'}.  [Could be empty string -- bug.]
#-------------------------------------------------------------------------
	    ii = 0
	    while( IS_ALNUM(regi_buf[regi_buf_x]) || 
	            (regi_buf[regi_buf_x] == '.') ||
		    (regi_buf[regi_buf_x] == '_') || 
	            (regi_buf[regi_buf_x] == '/') ||
		    (regi_buf[regi_buf_x] == '$') ) {

		Memc[test_string + ii] = regi_buf[regi_buf_x]

		ii         = ii + 1		# bump the pointers
		regi_buf_x = regi_buf_x + 1
	    }
	    Memc[test_string + ii] = EOS		# finish the string
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#-------------------------------------------------------------------------
#	    If test_string matches any region type name (or abbreviation 
#	    	of one):
#	    # rg_lookup() finds which keyword table entry matches.
#	    # If the first such match in the run is to "PHYSICAL", set up 
#	    #	physical-to-logical conversion; else, logical-to-physical.
#-------------------------------------------------------------------------
	    # check for keyword
	    if( rg_lookup(Memc[test_string], kwi) == YES ) {

		code    = rg_codes  [kwi]
		minargs = rg_minargs[kwi]

		if (first_cmd) {

		    # Set up transformation
		    if (code == PHYS) {
			direction = TO_SAOIM
			call setlogi(imw, ict, outfd)
		    } else {
			direction = TO_PROS
			call setphys(imw, ict, outfd)

			# Print out the input line as a comment
			# (Don't let any line exceed SZ_LINE)

			len = strlen(regi_buf)
			plen = 0
			while (plen < len) {	# print lines <= SZ_LINE
			    call fprintf(outfd, "##")
			    llen = gstrcpy(regi_buf[plen+1], Memc[rego_buf], 
							SZ_LINE - 3)
			    call fprintf(outfd, "%s")
			    call pargstr(Memc[rego_buf])
			    if (Memc[rego_buf + llen - 1] != '\n') {
				call fprintf(outfd, "\n")
			    }
			    plen = plen + SZ_LINE - 3
			}

			# Print out the 1st char on the line
			call fprintf(outfd, "%c")
			call pargc(regi_buf[1])
		    }

		    first_cmd = false
		    echo_input = true

		} else if (code == PHYS) {
		    call error(EA_FATAL, 
	"regions input file has mixed logical and physical coordinates")
		}

		if (code != PHYS) {
#-------------------------------------------------------------------------
#		    # Print out name.
#-------------------------------------------------------------------------
		    call fprintf(outfd, "%s")
		    call pargstr(Memc[rg_names[kwi]])
		    nargs_done = 0
		}
	    }

#=========================================================================
#	    Else (not number, not special char, not region name):
#=========================================================================

	    else {
		call error(EA_FATAL, 
			"regions file has something strange for a region name")
	    }
	}

#=========================================================================
#   Ready for next character
#=========================================================================

    } until (false)

end


##########################################################################
##########################################################################

define       REGION          258
define       PIXSYS          259

#
# saoregshapes -- install the default shapes' min and max args
#	(This is based on rg_defshapes().)
#
procedure saoregshapes()

begin

# Add keyword type parameter to distinguish shapes from coordinate commands
#
	# install region names, with min and max args
	call rg_install("ANNULUS", 	 ANNULUS, 	REGION,		4, -1)
	call rg_install("BOX", 		 BOX, 		REGION,		4, 5)
	call rg_install("CIRCLE", 	 CIRCLE, 	REGION,		3, 3)
	call rg_install("ELLIPSE", 	 ELLIPSE, 	REGION,		5, 5)
	call rg_install("POINT", 	 POINT, 	REGION,		2, 2)
	call rg_install("POLYGON", 	 POLYGON, 	REGION,		6, -1)

# Pixel system commands.	John : July 90
#
	call rg_install("PHYSICAL", 	 PHYS,	PIXSYS,		0, 0)
	call rg_install("LOGICAL", 	 LOGI,	PIXSYS,		0, 0)
end


##########################################################################
##########################################################################

procedure setphys(imw, ict, outfd)

pointer	imw			# i: MWCS descriptor on image named in infd
pointer	ict			# l: coordinate transformation descriptor
int	outfd			# i: output file channel

pointer mw_sctran()             # l: open coordinate transformation descriptor

begin
	# Set up logical-to-physical transformation
	#	(3B is 1st 2 bits, for x & y axes)
	ict = mw_sctran(imw, "logical", "physical", 3B)

	# Prepare output .reg file for physical coordinates
	call fprintf(outfd, " PHYSICAL\n")
	call fprintf(outfd, 
		"## converted from LOGICAL, for export from SAOimage\n")
		# (This line ends in '\n', while the comment for 
		# conversion from logical doesn't.  This is 
		# correct; in this case we have a region name 
		# yet to print on the next line.)
end


##########################################################################
##########################################################################

procedure setlogi(imw, ict, outfd)

pointer	imw			# i: MWCS descriptor on image named in infd
pointer	ict			# l: coordinate transformation descriptor
int	outfd			# i: output file channel

pointer mw_sctran()             # l: open coordinate transformation descriptor

begin
	# Set up physical-to-logical transformation
	#	(3B is 1st 2 bits, for x & y axes)
	ict = mw_sctran(imw, "physical", "logical", 3B)

	# Prepare output .reg file for logical coordinates
	call fprintf(outfd, "#* LOGICAL\n")
	call fprintf(outfd, 
		"##   converted from PHYSICAL, for input to SAOimage")
		# (This line doesn't end in '\n', while the comment for 
		# conversion from physical does.  This is 
		# correct; in that case we have a region name 
		# yet to print on the next line.)
end
