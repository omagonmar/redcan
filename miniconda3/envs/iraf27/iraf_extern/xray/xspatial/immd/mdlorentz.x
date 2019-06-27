# $Header: /home/pros/xray/xspatial/immd/RCS/mdlorentz.x,v 11.0 1997/11/06 16:32:57 prosb Exp $
# $Log: mdlorentz.x,v $
# Revision 11.0  1997/11/06 16:32:57  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:52:31  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:15  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:54  prosb
#General Release 2.2
#
#Revision 1.1  93/04/07  13:38:10  orszak
#Initial revision
#
#
#
# Module:       MDLORENTZ.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using Lorentzian function
# External:     md_lorentz()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JSO initial version 	1 April 1993
#               {n} <who> -- <does what> -- <when>
#

##################################################################
#
# md_lorentz
#
# add values to 2d image buffer using Lorentzian function
# lorentz = 0.5*gamma / ( radius**2 + (0.5*gamma)**2 )
# area under curve = PI**2
# gamma must be positive and non-zero
#
##################################################################

include <math.h>

procedure md_lorentz ( buf, width, height, xcen, ycen, gamma, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of lorentzian
real	gamma		# i: FWHM of lorentzian
real	val		# i: value by which to multiply function
int	cmplx		# i: fill real part of array of complex elements

double	gammadivtwo	# l: inverse of exponent denominator
double	dem		# l: exponent of the exponential
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
	if( gamma <= 0.0 )
	    call error (1, "zero area lorentzian")
	# to be safe all lines are affected
	ystart = 1
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
	gammadivtwo = double(gamma) /  2.0
	rowoffset = (ystart - 1) * bufwidth
	# loop through affected rows of image
	do y = ystart, ystop {
	    # determine range on this line
	    yrad = y - ycen
	    yradsq = yrad * yrad
	    xstart = 1
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
		    dem = ((xrad * xrad) + yradsq) + gammadivtwo*gammadivtwo
		    buf[rx] = buf[rx] + (val * gammadivtwo * gammadivtwo / dem)
		    rx = rx + inc
		}
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
