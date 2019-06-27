#$Header: /home/pros/xray/lib/regions/RCS/rgpldisp.x,v 11.0 1997/11/06 16:19:17 prosb Exp $
#$Log: rgpldisp.x,v $
#Revision 11.0  1997/11/06 16:19:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:28  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:01  pros
#General Release 1.0
#
#
# Module:	RGPLDISP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	draw the pl mask regions on a character terminal
# Includes:	rg_pldisp()
# Includes:	rg_lndisp(), rg_lnlabel(), rg_digits()
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	2 December 1988	initial version
#		{1} MVH	13 March 1989	display only prescribed subsection
#		{2} MVH 29 Sep 1989	sprintf gets "excess" in rg_lndisp()
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include <plset.h>

define LABELSZ 6	# define number of characters reserved for row label
define BUFSZ 200

#
# Function:	rg_pldisp
# Purpose:	draw the pl mask regions on a character terminal
# Parameters:	See argument declarations
# Returns:	-
# Uses:		rg_lndisp(), rg_digits() below
# Pre-state:	pl (or pm) handle opened on mask with regions
# Post-state:	no change
# Exceptions:
# Method:	Display is subsampled to fit on given terminal size.
# Notes:	If x1 is -1, full width is used; if x1 is 0, the non-zero width
#		is used; if x1 is >0, the subsection from x1 to x2 is used.
#		If y1 is -1, full height is used, if 0 non-zero height is used;
#		if y1 is >0, the subsection from y1 to y2 is used.
#
procedure rg_pldisp ( pl, cols, rows, x1, x2, y1, y2 )

pointer pl		# i: handle for pl access
int	cols		# i: number of columns in display
int	rows		# i: number of rows to use for display
int	x1, x2		# i: subsection specified or as per code in x1
int	y1, y2		# i: subsection specified or as per code in y1

long	v[PL_MAXDIM]	# l: array of axis starting indeces (PL_MAXDIM is 7)
pointer	sp		# l: stack pointer
pointer lbuf		# l: line buffer
int	vmin, vmax	# l: lowest and highest region values in mask
int	xmin, xmax	# l: actual range of x values to be used
int	ymin, ymax	# l: actual range of y values to be used
int	xinc, yinc	# l: subsample rates in x and y directions
int	width, height	# l: pl width and height
int	digits		# l: digits needed for highest region val
int	i		# l: loop counter

int	rg_digits()

begin
	# check for bad input
	if( (x1 != -1) && (x2 < x1) )
	    call error(1, "display with x2 < x1 specification")
	if( (y1 != -1) && (y2 < y1) )
	    call error(1, "display with y2 < y1 specification")
	# calculate display parameters
	# move subsample input to locally usable variables
	xmin = x1
	xmax = x2
	ymin = y1
	ymax = y2
	# limit the coloumn size to work with internal buffers
	if( cols >= BUFSZ )
	    cols = BUFSZ - 1
	# determine mask limits (measured or assigned)
	call rg_pllims (pl, vmin, vmax, xmin, xmax, ymin, ymax)
	width = 1 + xmax - xmin
	height = 1 + ymax - ymin
	# get number of digits needed per table column
	digits = rg_digits (vmax)
	# compute subsampling rates
	xinc = ((width * digits - 1) / (cols - LABELSZ)) + 1
	yinc = ((height - 1) / rows) + 1
	# allocate pixel list buffer for one row
	call smark(sp)
	call salloc(lbuf, width, TY_LONG)
	# initialize axis starting values
	call amovki(1, v, PL_MAXDIM)
	v[1] = xmin
	call printf("\n")
#  put column numbers at the top above table
	call rg_lnlabel(xmin, xmax, xinc, digits, cols)
#  loop through subsampled lines from top (screen scrolls up)
	do i = ymax, ymin, -yinc
	{
	    v[2] = i
	    # get a line as a pixel list
	    call pl_glpl(pl, v, Meml[lbuf], 27, width, 0)
	    # represent that line as an ascii string to STDOUT
	    call rg_lndisp(Meml[lbuf], width, i, xinc, digits, cols)
	}
	call sfree (sp)
end

#
# Function:	rg_lndisp
# Purpose:	print a formatted ascii display of one line for rg_pldisp
# Parameters:	See argument declarations
# Uses:		
# Pre-state:	pixel list filled by pl_glpl
# Exceptions:
# Method:	< optional >
# Notes:	
#
procedure rg_lndisp ( lbuf, width, index, inc, digits, cols )

int	width		# i: line width
long	lbuf[width]	# i: pixel list line
int	index		# i: line number to print in front of line
int	inc, digits	# i: subsample spacing, single pixel field width
int	cols		# i: available output string width

int	i, j		# l: loop counters
int	wid		# l: output line length not used by index label
int	excess		# l: buffer size beyond that needed
int	dot		# l: count for dot padding
pointer	sp		# l: stack pointer
pointer	strbuf		# l: buf for formatted output line
char	space		# l: token to put char sized ' ' in arg list
char	frmt[5]		# l: string for format statement
char	dotbuf[20]	# l: buf for row of dots

begin
	call smark(sp)
	call salloc(strbuf, BUFSZ, TY_CHAR)
	# create passable character for ASCII space
	space = ' '
	# space out line
	call amovkc(space, Memc[strbuf], cols)
	# set up string to fill in dots
	call amovkc(space, dotbuf, 18)
	dotbuf[19] = '.'
	dotbuf[20] = EOS
	dot = 20 - digits
	# set up format for digits
	frmt[1] = '%'
	frmt[2] = '0' + digits
	frmt[3] = 'd'
	frmt[4] = EOS
	j = 1
	excess = BUFSZ - cols
	wid = cols - LABELSZ
	do i = 1, width, inc
	{
	    # only write if you can fit the whole value on the line
	    if( (wid > 0) && (wid >= digits) )
	    {
		if( lbuf[i] == 0 )
		{
		    call sprintf(Memc[strbuf + j - 1], wid + excess, "%s")
		     call pargstr(dotbuf[dot])
		}
		else
		{
		    call sprintf(Memc[strbuf + j - 1], wid + excess, frmt)
		     call pargl(lbuf[i])
		}
		j = j + digits
		wid = wid - digits
	    }
	}
	# this solves any string-too-long problems
	Memc[strbuf + (cols-LABELSZ-1) - 1] = EOS
# this must match LABELSZ ...
	call printf("%4d: %s\n")
	 call pargi(index)
	 call pargstr(Memc[strbuf])
	call sfree(sp)
end


define MOD	(($1)-(int(($1)/($2))*($2)))

#
# Function:	rg_lnlabel
# Purpose:	label the columns across the bottom
# Parameters:	See argument declarations
# Uses:		MOD defined above
# Method:	< optional >
# Notes:	
#
procedure rg_lnlabel ( xmin, xmax, xinc, digits, cols )

int	xmin, xmax	# i: starting and ending indices
int	xinc		# i: subsample rate
int	digits		# i: ascii digits allowed per column
int	cols		# i: available output string width

int	i, j		# l: loop counters
int	wid		# l: output line length not used by index label
int	excess		# l: added buffer length not really needed
int	xstart		# l: an index
int	tcols		# l: locally used cols
pointer	sp		# l: stack pointer
pointer	abuf		# l: buf for formatted output line of 1's
pointer	bbuf		# l: buf for formatted output line of 10's
pointer	cbuf		# l: buf for formatted output line of 100's
pointer	dbuf		# l: buf for formatted output line of 1000's
char	frmt[5]		# l: string for format statement

begin
	call smark(sp)
	call salloc(abuf, BUFSZ, TY_CHAR)
	call salloc(bbuf, BUFSZ, TY_CHAR)
	call salloc(cbuf, BUFSZ, TY_CHAR)
	call salloc(dbuf, BUFSZ, TY_CHAR)
#  set up format for digits
	frmt[1] = '%'
	frmt[2] = '0' + digits
	frmt[3] = 'd'
	frmt[4] = EOS
#  set up loop and index counters
	j = 1
	wid = cols - LABELSZ
	excess = BUFSZ - wid
	tcols = 0
#  create four strings for values 0001 through 9999 to label columns vertically
	do i = xmin, xmax, xinc
	{
	    # only write if the whole column fits on the line
	    if( (wid > 0) && (wid >= digits) )
	    {
		call sprintf(Memc[abuf + j - 1], wid + excess, frmt)
		 call pargi(MOD(i,10))
		call sprintf(Memc[bbuf + j - 1], wid + excess, frmt)
		 call pargi(MOD(i,100)/10)
		if( i > 99 )
		{
		    call sprintf(Memc[cbuf + j - 1], wid + excess, frmt)
		     call pargi(MOD(i,1000)/100)
		}
		else
		{
		    call sprintf(Memc[cbuf + j - 1], wid + excess, frmt)
		     call pargi(0)
		}
		if( i > 999 )
		{
		    call sprintf(Memc[dbuf + j - 1], wid + excess, frmt)
		     call pargi(MOD(i,10000)/1000)
		}
		else
		{
		    call sprintf(Memc[dbuf + j - 1], wid + excess, frmt)
		     call pargi(0)
		}
		j = j + digits
		wid = wid - digits
		tcols = tcols + 1
	    }
	}
	# make sure string can't be too long
	Memc[abuf + (cols-LABELSZ-1) - 1] = EOS
	Memc[bbuf + (cols-LABELSZ-1) - 1] = EOS
	Memc[cbuf + (cols-LABELSZ-1) - 1] = EOS
	Memc[dbuf + (cols-LABELSZ-1) - 1] = EOS
#  print column values vertically, using as many lines as needed
	if( xmax > 999 )
	{
	    # this must match LABELSZ ...
	    call printf("      %s\n")
	     call pargstr(Memc[dbuf])
	}
	if( xmax > 99 )
	{
	    # this must match LABELSZ ...
	    call printf("      %s\n")
	     call pargstr(Memc[cbuf])
	}
	# this must match LABELSZ ...
	call printf("      %s\n")
	 call pargstr(Memc[bbuf])
	# this must match LABELSZ ...
	call printf("      %s\n")
	 call pargstr(Memc[abuf])
#  put in line with dashes and column (x) limits
	# use 3 or 5 spaces for first column number label
	if( xmin > 100 )
	{
	    call sprintf(Memc[abuf], BUFSZ, "from%5d     ")
	     call pargi(xmin)
	    xstart = 11
	}
	else
	{
	    call sprintf(Memc[abuf], BUFSZ, "from%3d     ")
	     call pargi(xmin)
	    xstart = 9
	}
	# figure out where table actually ends
	if( tcols < (cols - LABELSZ - 2) )
	    tcols = tcols + LABELSZ + 2
	else
	    tcols = cols
	# fill in middle with dashes (OK if runs too ling, will overwrite end)
	do i = xstart, tcols
	    Memc[abuf + i - 1] = '-'
	# use 3 or 5 spaces for last column number label
	if( xmax > 100 )
	{
	    call sprintf(Memc[abuf + (tcols - 9) - 1], BUFSZ - (tcols - 8),
	     " to%5d")
	     call pargi(xmax)
	}
	else
	{
	    call sprintf(Memc[abuf + (tcols - 7) - 1], BUFSZ - (tcols - 8),
	     " to%3d")
	     call pargi(xmax)
	}
	call printf("%s\n")
	 call pargstr(Memc[abuf])
	call sfree(sp)
end

#
# Function:	rg_digits
# Purpose:	determine the number of digits needed to print the given number
# Parameters:	See argument declarations
# Returns:	the determined number of digits
# Exceptions:	Numbers are not checked for requiring more than 10 digits.
# Method:	Look for minimum number of digits needed.
# Notes:	If val was negative, returns number of digits plus 1 for sign
#
int procedure rg_digits ( val )

int	val	# i: value to be printed (largest region in pl)

int	vmax	# l: number used in test (made positive if val was negative)

begin
	if( val < 0 )
	    vmax = -10 * val
	else
	    vmax = val
	if (vmax > 1000000000)
	    return(11)
	else if (vmax >= 100000000)
	    return (10)
	else if (vmax >= 10000000)
	    return (9)
	else if (vmax >= 1000000)
	    return (8)
	else if (vmax >= 100000)
	    return (7)
	else if (vmax >= 10000)
	    return (6)
	else if (vmax >= 1000)
	    return (5)
	else if (vmax >= 100)
	    return (4)
	else if (vmax >= 10)
	    return (3)
	else
	    return (1)
end
