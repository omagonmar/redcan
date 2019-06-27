#$Header: /home/pros/xray/xspatial/immd/RCS/mdboxcar.x,v 11.0 1997/11/06 16:32:52 prosb Exp $
#$Log: mdboxcar.x,v $
#Revision 11.0  1997/11/06 16:32:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:56  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:13  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:32  pros
#General Release 1.0
#
#
# Module:       MDBOXCAR.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using boxcar function
# External:     md_boxcar()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#		{1} D.Meleedy	fixed boundary problem  16 January  1991
#               {n} <who> -- <does what> -- <when>
#


procedure md_boxcar ( buf, width, height, xcen, ycen, wdth, hght, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of boxcar
real	wdth, hght	# i: dimensions of boxcar
real	val		# i: value to give inside boxcar
int	cmplx		# i: fill real part of array of complex elements

int	ystart, ystop	# l: vertical range
int	xstart, xstop	# l: horizontal range on a given line
int	bufwidth	# l: size of array row
int	inc		# l: increment between successive reals
int	rowoffset	# l: index offset of row in 2D buffer
int	x, y		# l: index of column, index of row
int	rx, rxstart	# l: index of real value in buffer

begin
	# check parameters
	if( (wdth <= 0.0) || (hght <= 0.0) )
	    call error (1, "zero area boxcar")
	# determine range of affected rows
	ystart = 1 + (ycen - (0.5 * hght))
	ystop = ystart + hght - 0.5
	if( ystart < 1 )
	    ystart = 1
	if( ystop > height )
	    ystop = height
	# check y limits
	if( ystart > ystop )
	    return

	# determine range of affected columns
	xstart = 1 + (xcen - (0.5 * wdth))
	xstop = xstart + wdth - 0.5
	if( xstart < 1 )
	    xstart = 1
	if( xstop > height )
	    xstop = height
	# check y limits
	if( xstart > xstop )
	    return

	# arrange indexing
	if( cmplx == 0 ) {
	    inc = 1
	    bufwidth = width
	    rxstart = xstart
	} else {
	    inc = 2
	    bufwidth = width * 2
	    rxstart = (xstart * 2) - 1
	}

	rowoffset = (ystart - 1) * bufwidth
	# loop through affected rows of image
	do y = ystart, ystop {
	    # fill in values for this line
	    rx = rxstart + rowoffset
	    do x = xstart, xstop {
		buf[rx] = buf[rx] + val
		rx = rx + inc
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
