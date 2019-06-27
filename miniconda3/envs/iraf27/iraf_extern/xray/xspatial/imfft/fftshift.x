#$Header: /home/pros/xray/xspatial/imfft/RCS/fftshift.x,v 11.0 1997/11/06 16:33:11 prosb Exp $
#$Log: fftshift.x,v $
#Revision 11.0  1997/11/06 16:33:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:55  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:08  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:27:58  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:15:47  pros
#General Release 1.0
#

#
# Module:	FFTSHIFT.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to shift the coordinate axes with fft's
# External:	fft_shift(), fft_xroll(), fft_yroll()
# Local:
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	5 Dec 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include <imhdr.h>


#
# Function:	fft_shift
# Purpose:	shift the data between the center of the buffer to its corners
# Parameters:	See argument declarations
# Returns:	
# Uses:		amovx()
# Pre-cond:	Complex data centered in exact image center or on very edge
#		at corner
# Post-cond:	Data center shifted 90 degrees on both axes.
# Exceptions:
# Method:	Shift of origin performed by transposing diagonal quadrants
# Notes:	fourn fft assumes 0,0 of quadrent system is exactly on the
#		edge in a corner.  Most textbooks show functions with
#		coordinate origin in the center.  Scientists expect to see
#		their functions looking like that.  To avoid confusion, the
#		center can be in either place, using this routine to shift
#		it as needed.  Since fft assumes 2d wraparound, origin on
#		one corner is really origin on all corners.  The center is
#		not the center by convention but really the center.  On an
#		array of 64 elements (1-64), the center is the edge between
#		elements 32 and 33.
#
procedure fft_shift ( xbuf, axlen )

complex	xbuf[ARB]		# i: 2D buffer with complex data
int	axlen[IM_MAXDIM]	# i: array of im dimensions for fft

int	width			# l: width of buffer
int	i			# l: loop counter
int	halfhght, halfwdth	# l: half of the buffer dimensions
int	topleft, topright	# l: index of half lines from top
int	midleft, midright	# l: index of half lines from middle
pointer	tbuf			# l: temporary half line buffer
pointer	sp			# l: stack pointer

begin
	call smark(sp)
	# set dimension variables and allocate temp buffer
	width = axlen[1]
	halfwdth = width / 2
	halfhght = axlen[2] / 2
	call salloc(tbuf, halfwdth, TY_COMPLEX)
	# loop through one quadrant and switch quadrant lines diagonally
	topleft = 1
	midleft = halfhght * width + 1
	do i = 1, halfhght {
	    topright = topleft + halfwdth
	    midright = midleft + halfwdth
	    call amovx (xbuf[topleft], Memx[tbuf], halfwdth)
	    call amovx (xbuf[midright], xbuf[topleft], halfwdth)
	    call amovx (Memx[tbuf], xbuf[midright], halfwdth)
	    call amovx (xbuf[topright], Memx[tbuf], halfwdth)
	    call amovx (xbuf[midleft], xbuf[topright], halfwdth)
	    call amovx (Memx[tbuf], xbuf[midleft], halfwdth)
	    topleft = topleft + width
	    midleft = midleft + width
	}
	call sfree(sp)
end
	

#
# Function:	fft_xroll
# Purpose:	roll the data on the x axis (shift with wrap-around)
# Parameters:	See argument declarations
# Returns:	
# Uses:		amovx()
# Pre-cond:	Complex data centered somewhere
# Post-cond:	Data center shifted "shift" pixels to the right
# Exceptions:
# Method:	Shift of origin performed line by line
# Notes:	A general move of the x axis based on the idea of fft_shift
#
procedure fft_xroll ( xbuf, axlen, shift )

complex	xbuf[ARB]		# i: 2D buffer with complex data
int	axlen[IM_MAXDIM]	# i: array of im dimensions for fft
int	shift			# i: column count of shift (to right)

int	width			# l: width of buffer
int	y			# l: loop counter
int	xshift			# l: shift in form (0 < xshift < width)
int	shiftlen		# l: length from shift to edge for rollover
int	line			# l: index at start of a row
pointer	tbuf			# l: temporary half line buffer
pointer	sp			# l: stack pointer

begin
	call smark(sp)
	# set dimension variables and allocate temp buffer
	width = axlen[1]
	xshift = shift
	call salloc(tbuf, width, TY_COMPLEX)
	# make all xshifts positive
	while( xshift < 0 ) {
	    xshift = xshift + width
	}
	# do xshift mod the width
	while( xshift > width ) {
	    xshift = xshift - width
	}
	# point at which rollover occurs
	shiftlen = width - xshift
	# roll each line of complex image
	line = 1
	do y = 1, axlen[2] {
	    call amovx (xbuf[line], Memx[tbuf], width)
	    call amovx (Memx[tbuf], xbuf[line + xshift], shiftlen)
	    call amovx (Memx[tbuf + shiftlen], xbuf[line], xshift)
	    line = line + width
	}
	call sfree(sp)
end


#
# Function:	fft_yroll
# Purpose:	roll the data on the y axis (shift with wrap-around)
# Parameters:	See argument declarations
# Returns:	
# Uses:		amovx()
# Pre-cond:	Complex data centered somewhere
# Post-cond:	Data center shifted "shift" upward with wrap-around
# Exceptions:
# Method:	Shift of origin performed by row swapping
#		Row swaps occur in distinct cycles a->b->...->a
#		In an odd sized shift, all rows are moved before the cycle
#		returns to the starting line.  On even sized shifts, two or
#		more distinct cycles may exist.  In the worst case, a shift
#		of exactly n/2, n/2 distinct cycles exist.  Each step of a
#		cycle is to move data into the current line.  After the
#		first cycle, the number of remaining cycles (if any) can be
#		determined from the length of that first cycle.
# Notes:	A general move of the y axis based on the idea of fft_shift
#
procedure fft_yroll ( xbuf, axlen, shift )

complex	xbuf[ARB]		# i: 2D buffer with complex data
int	axlen[IM_MAXDIM]	# i: array of im dimensions for fft
int	shift			# i: row count of shift (upward)

int	height			# l: height of buffer
int	y			# l: loop counter
int	nexty			# l: row number where y will be shifted
int	yshift			# l: shift in form (0 < yshift < width)
int	line			# l: xbuf index of row y
int	oldline			# l: xbuf index of last row nexty
int	nextline		# l: xbuf index of row nexty
int	cycles			# l: number of unique cycles in shift
int	cycle			# l: number of replacments in one cycle
pointer	tbuf			# l: temporary line buffer
pointer	sp			# l: stack pointer

begin
	call smark(sp)
	# set dimension variables and allocate temp buffer
	height = axlen[2]
	# make all shifts positiveo
	yshift = shift
	# start with a positive yshift
	while( yshift < 0 ) {
	    yshift = yshift + height
	}
	# then make yshift just negative
	while( yshift > height ) {
	    yshift = yshift - height
	}
	# roll lines through each unique cycle of replacements
	cycles = height
	cycle = 1
	line = 1
	y = 1
	call salloc(tbuf, axlen[1], TY_COMPLEX)
	while( y <= cycles ) {
	    oldline = line
	    call amovx (xbuf[oldline], Memx[tbuf], axlen[1])
	    nexty = y - yshift
	    if( nexty < 1 )
		nexty = nexty + height
	    repeat {
		nextline = ((nexty - 1) * axlen[1]) + 1
		call amovx (xbuf[nextline], xbuf[oldline], axlen[1])
		nexty = nexty - yshift
		if( nexty < 1 )
		    nexty = nexty + height
		cycle = cycle + 1
		oldline = nextline
	    } until( nexty == y )
	    # close the cycle
	    call amovx (Memx[tbuf], xbuf[oldline], axlen[1])
	    # if not yet done, determine number of cycles needed to do all rows
	    if( cycles == height )
		cycles = height / cycle
	    line = line + axlen[1]
	    y = y + 1
	}
	call sfree(sp)
end
