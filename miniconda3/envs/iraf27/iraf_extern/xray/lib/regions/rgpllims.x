#$Header: /home/pros/xray/lib/regions/RCS/rgpllims.x,v 11.0 1997/11/06 16:19:19 prosb Exp $
#$Log: rgpllims.x,v $
#Revision 11.0  1997/11/06 16:19:19  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:30  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:07  pros
#General Release 1.0
#
#
# Module:	RGPLLIMS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	draw the pl mask regions on a character terminal
# Includes:	rg_pllims() rg_plvallims()
# Includes:	rg_vlims(), rg_xlims()
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	13 March 1989	initial version
#		{1} MVH	check for no data in rgpllims/rgvallims	13 Dec 1989
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include <plset.h>

#
# Function:	rg_pllims
# Purpose:	Get the minimum and maximum region values, and coordinates
# Parameters:	See argument declarations
# Uses:		rg_plvlims(), rg_plxlims() below
# Uses:		pl_gsize, pl_glrl, and pl_linenotempty in plio
# Pre-state:	open pl or pm handle
# Post-state:	vmin and vmax set to minimum and maximum region ID respectively
# Method:	Read a mask line by line as range lists, updating limits if
#		previous ones are exceeded.
# Notes:	Resolves codes for xmin and ymin:
#		 if -1 return full image field,
#		 if 0 return limits in image field,
#		 if >1 use xmin and xmax (and/or ymin and ymax) to describe
#		  subsection and find the value limits within that subsection.
#
procedure rg_pllims ( pl, vmin, vmax, xmin, xmax, ymin, ymax )

pointer	pl		# i: handle to open pixel list
int	vmin, vmax	# o: minimum and maximum region id values
int	xmin, xmax	# o: minimum and maximum x coords of non-zero pixels
int	ymin, ymax	# o: minimum and maximum y coords of non-zero pixels

long	axlen[PL_MAXDIM]	# l: length of each exis (PL_MAXDIM is 7)
long	v[PL_MAXDIM]		# l: starting index in each axis
pointer	sp			# l: stack pointer
pointer rl_out			# l: buffer for line range-list
int	depth			# l: depth of mask (set by pl_gsize)
int	i			# l: loop counter
int	npix			# l: estimated length of longest range list
int	naxes			# l: number of axes used
int	x1			# l: limits of checking in the x direction
int	y1, y2			# l: limits of checking in the y direction
int	width			# l: width of each line read
bool	dox, doy		# l: flags for checking x and y limits

bool	pl_linenotempty()

begin
	call smark (sp)
	# get basic dimensions and initialize input parameters
	call pl_gsize (pl, naxes, axlen, depth)
	call amovkl (1, v, PL_MAXDIM)
	# set up desired x range and action
	x1 = 1
	width = axlen[1]
	if( xmin == 0 )
	    {
	    xmin = axlen[1]+1
	    xmax = 0
	    dox = true
	    }
	else
	    {
	    if( xmin > 0 )
		{
	 	x1 = xmin
		width = 1 + xmax - xmin
		}
	    else
		{
		xmin = x1
		xmax = width
		}
	    dox = false
	    }
	v[1] = x1
	# set up desired y range and action
	y1 = 1
	y2 = axlen[2]
	if( ymin == 0 )
	    {
	    ymin = axlen[2]+1
	    ymax = 0
	    doy = true
	    }
	else
	    {
	    if( ymin > 0 )
		{
		y1 = ymin
		y2 = ymax
		}
	    else
		{
		ymin = y1
		ymax = y2
		}
	    doy = false
	    }
	# allocate space for range list
	npix = min(RL_MAXLEN(pl), width * 3)
	call salloc (rl_out, npix, TY_LONG)
	# a value greater than 2**27, a value less than 0
	vmin = 200000000
	vmax = -1
	do i = y1, y2
	    {
	    v[2] = i
	    if( pl_linenotempty (pl, v) )
		{
		call pl_glrl (pl, v, Meml[rl_out], depth, width, 0)
		# update val limits
		call rg_vlims (Meml[rl_out], vmin, vmax)
		# update x limits if checking
		if( dox )
		    call rg_xlims (Meml[rl_out], xmin, xmax)
		# update y limits if checking
		if( doy )
		    {
		    if( i < ymin )
			ymin = i
		    if( i > ymax )
			ymax = i
		    }
		}
	    }
	call sfree (sp)
	# added 12/89 for case of no regions
        if( xmin > xmax )
        {
            xmin = 1
            xmax = 1
        }
        if( ymin > ymax )
        {
            ymin = 1
            ymax = 1
        }
        if( vmin > vmax )
        {
            vmin = 0
            vmax = 0
        }
end

#
# Function:	rg_plvallims
# Purpose:	Get the minimum and maximum region values
# Parameters:	See argument declarations
# Uses:		rg_vlims() below
# Pre-state:	open pl or pm handle
# Post-state:	vmin and vmax set to minimum and maximum region ID respectively
# Method:	Read a mask line by line as range lists, calling rg_vallim
#		for each line to update the vmin and vmax.
#
procedure rg_plvallims ( pl, vmin, vmax )

pointer	pl		# i: handle to open pixel list
int	vmin, vmax	# o: where minimum and maximum will be placed

pointer	sp			# l: stack pointer
pointer rl_out			# l: buffer for line range-list
int	depth			# l: depth of mask (from pl_gsize)
int	i			# l: loop counter
int	npix			# l: maximum expected rangelist length
int	naxes			# l: number of axes used
long	axlen[PL_MAXDIM]	# l: length of each exis (PL_MAXDIM is 7)
long	v[PL_MAXDIM]		# l: starting index in each axis

bool	pl_linenotempty()

begin
	call smark (sp)
	call pl_gsize (pl, naxes, axlen, depth)
	call amovkl (1, v, PL_MAXDIM)
	npix = min(RL_MAXLEN(pl), axlen[1] * 3)
	call salloc (rl_out, npix, TY_LONG)
	# a value greater than 2**27, a value less than 0
	vmin = 200000000
	vmax = -1
	do i = 1, axlen[2]
	    {
	    v[2] = i
	    if( pl_linenotempty (pl, v) )
		{
		call pl_glrl (pl, v, Meml[rl_out], depth, axlen[1], 0)
		call rg_vlims (Meml[rl_out], vmin, vmax)
		}
	    }
	call sfree (sp)
	# added 12/89 for case of no regions
        if( vmin > vmax )
        {
            vmin = 0
            vmax = 0
        }
end

#
# Function:	rg_vlims
# Purpose:	Update record of minimum and maximum region values if values
#		outside previous limits are found on the given line.
# Parameters:	See argument declarations
# Called by:	rg_pllims() above
# Pre-state:	Range list of one line of mask, vmin and vmax with prior values
# Post-state:	vmin and vmax updated if new line has values which exceed them
# Method:	Each range scan entry gives its region value and length in
#		pixels.
#
procedure rg_vlims ( rl, vmin, vmax )

long	rl[3,ARB]	# i: the rangelist
int	vmin, vmax	# i:o: current min and max range value

int	i		# l: loop counter

begin
	if( RL_LEN(rl) < RL_FIRST )
	    return
	# get first run with a nonzero value (presumably the first run)
	do i = RL_FIRST, RL_LEN(rl)
	    {
	    if( RL_V(rl,i) < vmin )
		vmin = RL_V(rl,i)
	    if( RL_V(rl,i) > vmax )
		vmax = RL_V(rl,i)
	    }
end

#
# Function:	rg_xlims
# Purpose:	Update record of minimum and maximum x coordinates if
#		coords outside previous limits are found on the given line.
# Parameters:	See argument declarations
# Called by:	rg_pllims() above
# Pre-state:	Range list of one line of mask, xmin and xmax with prior values
# Post-state:	xmin and xmax updated if new line has coords which exceed them.
# Method:	Each range scan entry gives its region value and length in
#		pixels.
#
procedure rg_xlims ( rl, xmin, xmax )

long	rl[3,ARB]	# i: the rangelist
int	xmin, xmax	# i:o: current min and max x coordinate

int	xlast		# l: calculated last x coordinate

begin
	if( RL_LEN(rl) < RL_FIRST )
	    return
	if( RL_X(rl,RL_FIRST) < xmin )
	    xmin = RL_X(rl,RL_FIRST)
	xlast = RL_X(rl,RL_LEN(rl)) + RL_N(rl,RL_LEN(rl))
	if( xlast > xmax )
	    xmax = xlast
end
