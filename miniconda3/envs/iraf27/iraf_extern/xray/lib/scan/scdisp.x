#$Header: /home/pros/xray/lib/scan/RCS/scdisp.x,v 11.0 1997/11/06 16:23:33 prosb Exp $
#$Log: scdisp.x,v $
#Revision 11.0  1997/11/06 16:23:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:11:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:52:46  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:01  pros
#General Release 1.0
#
#
#
# Module:	scdisp.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Draw the pixel list in table form scaled to fit a terminal.
# Includes:	sc_disp(), sc_oneline(), sc_digits(), sc_dispparams()
# Description:
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>
define LABELSZ 6

#
# Function:	sc_disp
# Purpose:	Draw the pixel list in table form scaled to fit a terminal.
# Parameters:	See argument declarations
# Uses:		sc_oneline() below, sc_dispparams() below
# Uses:		sc_glpl() in scget.x
# Exceptions:	Given dimensions cannot be greater than those of opened image.
# Method:	Convert each scan line to a range list with sc_glri and call
#		pm_plri to install it in the pm.
# Notes:	Scan list array is neither freed nor cleared by this routine.
#
procedure sc_disp ( scan, width, height, cols )

int	width, height	# l: dimensions of scan list array image
pointer	scan[height]	# i: scan list array
int	cols		# i: number of columns in display

pointer	sp		# l: stack pointer
pointer lbuf		# l: line buffer
int	y		# l: loop counter
int	digits, inc	# l: digits needed for heighest val, subsample inc

begin
	call smark (sp)
	# calculate display parameters
	call sc_dispparams (scan, width, height, cols - LABELSZ, inc, digits)
	call salloc (lbuf, width, TY_LONG)
	call printf("\n")
	do y = height, 1, -inc {
	    call sc_glpl (scan[y], Meml[lbuf], width)
	    call sc_oneline (Meml[lbuf], width, y, inc, digits, cols)
	}
	call sfree (sp)
end

#
# Function:	sc_oneline
# Purpose:	Output one formatted line for sc_disp.
# Parameters:	See argument declarations
# Method:	Assemble formatted line and print it to terminal.
# Notes:	Format of line label at end must correspond to LABELSIZE
#
procedure sc_oneline ( lbuf, width, index, inc, digits, strwid )

int	width		# i: line width
long	lbuf[width]	# i: pixel list line
int	index		# i: line number to print in front of line
int	inc, digits	# i: subsample spacing, single pixel field width
int	strwid		# i: available output string width

int	i, j		# l: loop counters
int	wid		# l: output line length not used by index label
int	dot		# l: count for dot padding
char	space		# l: token to put char sized ' ' in arg list
char	strbuf[200]	# l: buf for formatted output line
char	frmt[5]		# l: string for format statement
char	dotbuf[20]	# l: buf for row of dots

begin
	# create passable character for ASCII space
	space = ' '
	# space out line
	call amovkc (space, strbuf, strwid)
	# set up string to fill in dots
	call amovkc (space, dotbuf, 18)
	dotbuf[19] = '.'
	dotbuf[20] = EOS
	dot = 20 - digits
	# set up format for digits
	frmt[1] = '%'
	frmt[2] = '0' + digits
	frmt[3] = 'd'
	frmt[4] = EOS
	j = 1
	wid = strwid - LABELSZ
	do i = 1, width, inc {
	    if( wid > 0 ) {
		if( lbuf[i] == 0 ) {
		    call sprintf (strbuf[j], wid, "%s")
		     call pargstr (dotbuf[dot])
		} else {
		    call sprintf (strbuf[j], wid, frmt)
		     call pargl (lbuf[i])
		}
		j = j + digits
		wid = wid - digits
	    }
	}
	strbuf[strwid-LABELSZ-1] = EOS
# this must match LABELSZ ...
	call printf ("%4d: %s\n")
	 call pargi (index)
	 call pargstr (strbuf)
end

#
# Function:	sc_digits
# Purpose:	Determine how many spaces to allow for each table column.
# Parameters:	See argument declarations
# Returns:	Number of digits needed to print largest number
# Exceptions:	Assumes no negative numbers.
# Method:	
# Notes:	
#
int procedure sc_digits ( maxval )

int	maxval		# i: maximum value

begin
	if (maxval > 1000000000)
	    return(10)
	else if (maxval >= 100000000)
	    return (9)
	else if (maxval >= 10000000)
	    return (8)
	else if (maxval >= 1000000)
	    return (7)
	else if (maxval >= 100000)
	    return (6)
	else if (maxval >= 10000)
	    return (5)
	else if (maxval >= 1000)
	    return (4)
	else if (maxval >= 100)
	    return (3)
	else if (maxval >= 10)
	    return (2)
	else
	    return (1)
end

#
# Function:	sc_dispparams
# Purpose:	Determine increment for subsampling and spacing of columns
# Parameters:	See argument declarations
# Uses:		sc_digits() above, sc_vallims() in scget.x
# Called by:	sc_disp() above
# Exceptions:
# Method:	
# Notes:	
#
procedure sc_dispparams ( scan, width, height, cols, inc, digits )

int	width, height	# i: dimensions of scan list array image
pointer scan[height]	# i: scan list array
int	cols		# i: number of columns in output display
int	inc		# o: subsampling increment
int	digits		# o: number of digits per pixel for output display

int	minval, maxval		# l: minimum and maximum values
int	sc_digits()

begin
	# calculate number of digits for max
	call sc_vallims (scan, height, minval, maxval)
	digits = sc_digits (maxval)
	inc = (width * digits - 1) / cols + 1
end

