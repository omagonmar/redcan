#$Header: /home/pros/xray/xspatial/immd/RCS/mdtophat.x,v 11.0 1997/11/06 16:33:04 prosb Exp $
#$Log: mdtophat.x,v $
#Revision 11.0  1997/11/06 16:33:04  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:37  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:20  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:22  pros
#General Release 1.0
#
#
# Module:       MDTOPHAT.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using tophat function
# External:     md_tophat()
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
# md_tophat
#
# add values to 2d image buffer using tophat function
# radius must be positive and non-zero
#
##################################################################

procedure md_tophat ( buf, width, height, xcen, ycen, radius, val, cmplx )

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

	rowoffset = (ystart - 1) * bufwidth
	# loop through affected rows of image
	do y = ystart, ystop {
	    # determine range on this line
	    yrad = ycen - y
	    xrad = sqrt (radsq - (yrad * yrad))
	    xstart = 1 + (xcen - xrad)
	    xstop = xcen + xrad
	    if( xstart < 1 )
		xstart = 1
	    if( xstop > width )
		xstop = width
	    # check x limits
	    if( xstart <= xstop ) {
		# determine first buffer index
		if( cmplx == 0 )
		    rx = rowoffset + xstart
		else
		    rx = rowoffset + (2 * xstart) - 1
		# fill in values for this line
		do x = xstart, xstop {
		    buf[rx] = buf[rx] + val
		    rx = rx + inc
		}
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
