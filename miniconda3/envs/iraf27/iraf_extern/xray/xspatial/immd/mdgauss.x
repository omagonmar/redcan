#$Header: /home/pros/xray/xspatial/immd/RCS/mdgauss.x,v 11.0 1997/11/06 16:32:54 prosb Exp $
#$Log: mdgauss.x,v $
#Revision 11.0  1997/11/06 16:32:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:07  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:03  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:40  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:19  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:11  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:42  pros
#General Release 1.0
#
#
# Module:       MDGAUSS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using Gaussian function
# External:     md_gauss()
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
# md_gauss
#
# add values to 2d image buffer using Gaussian function
# gauss = e**( -(radius**2)/(2.*sigma**2) )
# area under curve = 2.*PI*(sigma**2)
# sigma must be positive and non-zero
#
##################################################################

procedure md_gauss ( buf, width, height, xcen, ycen, sigma, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of gaussian
real	sigma		# i: sigma of gaussian
real	val		# i: value by which to multiply function
int	cmplx		# i: fill real part of array of complex elements

double	divtwosigsq	# l: inverse of exponent denominator
double	exponent	# l: exponent of the exponential
real	radlimit	# l: range at which function is effectively 0
real	yrad, xrad	# l: offsets from function center
real	yradsq		# l: partial used to calculate radius
int	ystart, ystop	# l: vertical range
int	xstart, xstop	# l: horizontal range on a given line
int	bufwidth	# l: size of array row
int	inc		# l: increment between successive reals
int	rowoffset	# l: index offset of row in 2D buffer
int	x, y		# l: index of column, index of row
int	rx		# l: index of real value in buffer

begin
	# check parameters
	if( sigma <= 0.0 )
	    call error (1, "zero area gaussian")
	# determine range of affected lines (gaussian<1E-32 at 12 sigma)
	radlimit = 12 * sigma
	ystart = ycen - radlimit
	ystop = ycen + radlimit
	if( ystart < 1 )
	    ystart = 1
	if( ystop > height )
	    ystop = height
	# check y limits
	if( ystart > ystop )
	    return

	# calculate and initialize internal parameters
	if( cmplx == 0 ) {
	    inc = 1
	    bufwidth = width
	} else {
	    inc = 2
	    bufwidth = width * 2
	}
	# inverse of exponent denominator for single multiply in inner loop
	divtwosigsq = -1.0 / (sigma * sigma * 2.0)
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
		    exponent = divtwosigsq * ((xrad * xrad) + yradsq)
		    buf[rx] = buf[rx] + (val * exp(exponent))
		    rx = rx + inc
		}
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
