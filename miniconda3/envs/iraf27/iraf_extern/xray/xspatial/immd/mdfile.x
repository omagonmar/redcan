#$Header: /home/pros/xray/xspatial/immd/RCS/mdfile.x,v 11.0 1997/11/06 16:32:53 prosb Exp $
#$Log: mdfile.x,v $
#Revision 11.0  1997/11/06 16:32:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:17  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:10  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:38  pros
#General Release 1.0
#

#
# Module:	MDFILE.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to read a data file for use in modeling
# External:	md_file(), md_addr(), md_addx()
# Local:
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	5 Dec 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include <imhdr.h>


#
# Function:	md_file
# Purpose:	read a data file and add it to the model
# Parameters:	See argument declarations
# Returns:	
# Uses:		immap(), imgnlr(), imgnlx(), mdaddx(), mdaddr()
# Pre-cond:	File must exist at this point
# Post-cond:	data from file is added to existing data in buffer
# Exceptions:
# Method:	File from data is added with file center being placed
#		at buffer center given.  Data is scaled by "val" argument.
#		imgnlr and imgnlx are used to read file data depending
#		on whether buffer contains real data or complex data.
# Notes:	File size need not match buffer size.  Non-overlap remains
#		unaffected.
#
procedure md_file (buf, width, height, xcen, ycen, file, val, cmplx)

real	buf[ARB]	# i: image buffer
int	width, height	# i: image buffer dimensions
real	xcen, ycen	# i: where to center input file in the buffer
char	file[ARB]	# i: name of input file
real	val		# i: value by which to multiply input values
int	cmplx		# i: buf is complex (else real)

long	v[IM_MAXDIM]	# l: number of dimensions permitted of IRAF images
int	ixoff, iyoff	# l: offset from center pixel to edge in input file
int	oxstart, oxstop	# l: limits of image commonality on x axis of buf
int	oystart, oystop	# l: limits of image commonality on y axis of buf
int	iystart		# l: first row needed from file
int	ostart		# l: index in 1D equivalent buf
int	oxcen, oycen	# l: buffer index of center
int	xspan		# l: number of common pixels in one row
int	iwidth, iheight	# l: dimensions of input file
int	i		# l: loop index
pointer	mdim		# l: handle for input file
pointer	inbuf		# l: buffer for reading image

int	imgnlr(), imgnlx()
pointer	immap()

begin
	mdim = immap(file, READ_ONLY, 0)
	# get image's dimensions
	iwidth = IM_LEN(mdim,1)
	iheight = IM_LEN(mdim,2)
	# get integer centers
	if( xcen > 0.0 )
	    oxcen = int(xcen + 0.4999)
	else
	    oxcen = int(xcen - 0.5001)
	if( ycen > 0.0 )
	    oycen = int(ycen + 0.4999)
	else
	    oycen = int(ycen - 0.5001)

	# set initial indices to 1
	call amovkl (long(1), v, IM_MAXDIM)

	# determine center of input image
	if( cmplx == 0 ) {
	    # for real, assume model application, use standard IRAF center
	    ixoff = (iwidth + 1) / 2
	    iyoff = (iheight + 1) / 2
	} else {
	    # for complex, assume fft application, put center +1,+1
	    ixoff = 1 + (iwidth / 2)
	    iyoff = 1 + (iheight / 2)
	}

	# determine fit and extent of y axis fit
	# output y coords of input image centered at oycen
	oystart = 1 + oycen - iyoff
	oystop = oystart + iheight - 1
	# clip to actual output image dimensions and adjust input starting y
	if (oystart < 1) {
	    # offset 2 (if oystart was 0, that is -1 from 1, so iystar=2)
	    iystart = 2 - oystart
	    oystart = 1
	} else
	    iystart = 1
	v[2] = iystart
	if (oystop > height)
	    oystop = height

	# determine fit and extent of x axis fit
	oxstart = 1 + oxcen - ixoff
	oxstop = oxstart + iwidth
	if (oxstart < 1) {
	    v[1] = 2 - oxstart
	    oxstart = 1
	} else
	    v[1] = 1
	if (oxstop > width)
	    oxstop = width
	xspan = (oxstop - oxstart)
	if (cmplx == 0) {
	    # set initial starting poiint in output file
	    ostart = ((oystart - 1) * width) + oxstart
	    do i = oystart, oystop {
		# read in one line
		if( imgnlr (mdim, inbuf, v) == EOF ) {
		    call error (1, "unexpected EOF")
		}
		if (val == 1.0)
		    call aaddr(buf[ostart], Memr[inbuf], buf[ostart], xspan)
		else
		    call mdaddr (buf[ostart], Memr[inbuf], buf[ostart],
				 val, xspan)
		ostart = ostart + width
	    }
	} else {
	    # set initial starting poiint in output file
	    ostart = ((oystart - 1) * (width * 2)) + (oxstart * 2) - 1
	    do i = oystart, oystop {
		# read in one line
		if( imgnlx (mdim, inbuf, v) == EOF ) {
		    call error (1, "unexpected EOF")
		}
		if (val == 1.0)
		    call aaddx(buf[ostart], Memx[inbuf], buf[ostart], xspan)
		else
		    call mdaddx (buf[ostart], Memr[inbuf], buf[ostart],
				 val, xspan)
		ostart = ostart + width + width
	    }
	}
end


#
# Function:	md_addr
# Purpose:	add one array with another scaling the second array by
#		a constant
# Parameters:	See argument declarations
# Returns:	
# Uses:		
# Pre-cond:	
# Post-cond:	
# Exceptions:
# Method:	
# Notes:	Arrays may be the same, but offset overlaps may not work
#
procedure mdaddr ( a, b, c, k, cnt )

real	a[ARB]		# i: input array, not being scaled
real	b[ARB]		# i: input array to be scaled before summing
real	c[ARB]		# o: array to receive results
real	k		# i: constant by which to scale array b
int	cnt		# i: length of arrays

int	i		# l: loop counter

begin
	do i = 1, cnt
	    c[i] = a[i] + (b[i] * k)
end


#
# Function:	md_addx
# Purpose:	add one array with another scaling the second array by
#		a real constant
# Parameters:	See argument declarations
# Returns:	
# Uses:		
# Pre-cond:	
# Post-cond:	
# Exceptions:
# Method:
# Notes:	Arrays may be the same, but offset overlaps may not work
#
procedure mdaddx ( a, b, c, k, cnt )

complex	a[ARB]		# i: input array, not being scaled
complex	b[ARB]		# i: input array to be scaled before summing
complex	c[ARB]		# o: array to receive results
real	k		# i: constant by which to scale array b
int	cnt		# i: length of arrays

int	i		# l: loop counter

begin
	do i = 1, cnt
	    c[i] = a[i] + (b[i] * k)
end


