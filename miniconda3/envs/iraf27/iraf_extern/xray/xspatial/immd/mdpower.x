#$Header: /home/pros/xray/xspatial/immd/RCS/mdpower.x,v 11.0 1997/11/06 16:33:01 prosb Exp $
#$Log: mdpower.x,v $
#Revision 11.0  1997/11/06 16:33:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:35  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:44  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:18  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:16  pros
#General Release 1.0
#
#
# Module:       MDPOWER.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add values to 2d image buffer using a power function
# External:     md_power()
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
# md_power
#
# add values to 2d image buffer using a power function
# radius must be positive and non-zero
# Power		R0,P	1./(1.+(R/R0))**P
#
##################################################################

procedure md_power (buf, width, height, xcen, ycen, radius, power, val, cmplx)

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of function
real	radius		# i: base radius of power function
real	power		# i: power to raise
real	val		# i: value by which to multiply function
int	cmplx		# i: fill real part of array of complex elements

double	divrad		# l: inverse of base radius
double	base		# l: base to be raised to power
double	yradsq		# l: partial used to calculate radius
double	yrad, xrad	# l: offsets from function center
int	bufwidth	# l: size of array row
int	inc		# l: increment between successive reals
int	rowoffset	# l: index offset of row in 2D buffer
int	x, y		# l: index of column, index of row
int	rx		# l: index of real value in buffer

begin
	# check parameters
	if( radius <= 0.0 )
	    call error (1, "zero area power function")
	# arrange indexing parameters
	if( cmplx == 0 ) {
	    inc = 1
	    bufwidth = width
	} else {
	    inc = 2
	    bufwidth = width * 2
	}
	# inverse of denominator for single multiply in inner loop
	divrad = 1.0 / radius
	rowoffset = 1
	# loop through affected rows of image
	do y = 1, height {
	    yrad = y - ycen
	    yradsq = yrad * yrad
	    # fill in values for this line
	    rx = rowoffset
	    do x = 1, width {
		xrad = x - xcen
		base = 1.0 + divrad * sqrt((xrad * xrad) + yradsq)
		buf[rx] = buf[rx] + (val / (base**power))
		rx = rx + inc
	    }
	    rowoffset = rowoffset + bufwidth
	}
end
