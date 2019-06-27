#$Header: /home/pros/xray/xspatial/immd/RCS/mdhipass.x,v 11.0 1997/11/06 16:32:54 prosb Exp $
#$Log: mdhipass.x,v $
#Revision 11.0  1997/11/06 16:32:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:43  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:21  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:11  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:45  pros
#General Release 1.0
#
#
# Module:       MDHIPASS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values of 2d image buffer using inverse of tophat function
# External:     md_hipass
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

##################################################################
#
# md_hipass
#
# add values to 2d image buffer using inverse of tophat function
# radius must be positive and non-zero
#
##################################################################

procedure md_hipass ( buf, width, height, xcen, ycen, radius, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of tophat
real	radius		# i: radius of tophat
real	val		# i: value to give inside tophat
int	cmplx		# i: fill real part of array of complex elements

real	yrad, xrad	# l: offsets from tophat center
real	radsq		# l: partial used to calculate radius
int	ystart, ystop	# l: vertical range
int	xstart, xstop	# l: horizontal range on a given line
int	bufwidth	# l: size of array row
int	inc		# l: increment between successive reals
int	rowoffset	# l: index offset of row in 2D buffer
int	x, y		# l: index of column, index of row
int	rx		# l: index of real value in buffer

begin
	# check parameters
	if( radius <= 0.0 )
	    call error (1, "zero area tophat")
	# determine range of affected lines
	ystart = 1 + (ycen - radius)
	ystop = ycen + radius
	if( ystart < 1 )
	    ystart = 1
	if( ystop > height )
	    ystop = height
	# check y limits
	if( ystart > ystop )
	    return

	# calculate and initialize internal parameters
	radsq = radius * radius
	if( cmplx == 0 ) {
	    inc = 1
	    bufwidth = width
	} else {
	    inc = 2
	    bufwidth = width * 2
	}

	rowoffset = 0
	# add function outside hole
	if( ystart >= 1 )
	{
	    do y = 1, ystart - 1 {
		rx = rowoffset + 1
		do x = 1, width {
		    buf[rx] = buf[rx] + val
		    rx = rx + inc
		}
		rowoffset = rowoffset + bufwidth
	    }
	}
	# loop through affected rows of image
	do y = ystart, ystop {
	    # determine range of hole on this line
	    yrad = ycen - y
	    xrad = sqrt (radsq - (yrad * yrad))
	    xstart = (xcen - xrad)
	    xstop = 1 + (xcen + xrad)
	    if( xstart >= 1 ) {
		rx = rowoffset + 1
		do x = 1, xstart {
		    buf[rx] = buf[rx] + val
		    rx = rx + inc
		}
	    }
	    if( xstop <= width ) {
		# determine first buffer index
		if( cmplx == 0 )
		    rx = rowoffset + xstop
		else
		    rx = rowoffset + (2 * xstop) - 1
		# fill in values for this line
		do x = xstop, width {
		    buf[rx] = buf[rx] + val
		    rx = rx + inc
		}
	    }
	    rowoffset = rowoffset + bufwidth
	}
	if( ystop < height )
	{
	    do y = ystop + 1, height {
		rx = rowoffset + 1
		do x = 1, width {
		    buf[rx] = buf[rx] + val
		    rx = rx + inc
		}
		rowoffset = rowoffset + bufwidth
	    }
	}
end
