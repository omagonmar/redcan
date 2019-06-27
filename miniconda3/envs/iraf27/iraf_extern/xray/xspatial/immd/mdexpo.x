#$Header: /home/pros/xray/xspatial/immd/RCS/mdexpo.x,v 11.0 1997/11/06 16:32:52 prosb Exp $
#$Log: mdexpo.x,v $
#Revision 11.0  1997/11/06 16:32:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:35  pros
#General Release 1.0
#
#
# Module:       MDEXPO.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using exponential function
# External:     md_expo()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M. VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

##################################################################
#
# md_expo
#
# add values to 2d image buffer using exponential function
# radius must be positive and non-zero
# Exponential	R0	EXP(-R/R0)
#
##################################################################

procedure md_expo ( buf, width, height, xcen, ycen, radius, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of gaussian
real	radius		# i: base radius of exponential
real	val		# i: value by which to scale exponential
int	cmplx		# i: fill real part of array of complex elements

double	divrad		# l: inverse of exponent denominator
double	exponent	# l: exponent of the exponential
double	yradsq		# l: partial used to calculate radius
real	radlimit	# l: range at which function is effectively 0
real	yrad, xrad	# l: offsets from function center
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
	    call error (1, "zero area exponential")
	# determine range of affected lines (expo<1E-32 at 75x base radius)
	radlimit = 75 * radius
	ystart = ycen - radlimit
	ystop = ycen + radlimit
	if( ystart < 1 )
	    ystart = 1
	if( ystop > height )
	    ystop = height
	# check y limits
	if( ystart > ystop )
	    return

	# arrange indexing parameters
	if( cmplx == 0 ) {
	    inc = 1
	    bufwidth = width
	} else {
	    inc = 2
	    bufwidth = width * 2
	}
	# inverse of exponent denominator for single multiply in inner loop
	divrad = -1.0 / radius
	rowoffset = (ystart - 1) * bufwidth
	# loop through affected rows of image
	do y = ystart, ystop {
	    # determine range on this line
	    yrad = y - ycen
	    yradsq = yrad * yrad
	    xstart = xcen - radlimit
	    xstop = xcen + radlimit
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
		    xrad = x - xcen
		    exponent = divrad * sqrt(double(xrad * xrad) + yradsq)
		    buf[rx] = buf[rx] + (val * exp(exponent))
		    rx = rx + inc
		}
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
