#$Header: /home/pros/xray/xspatial/immd/RCS/mdimpulse.x,v 11.0 1997/11/06 16:32:55 prosb Exp $
#$Log: mdimpulse.x,v $
#Revision 11.0  1997/11/06 16:32:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:45  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:12  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:47  pros
#General Release 1.0
#
#
# Module:       MDIMPULSE.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      add value to 2d image buffer at pixel nearest given point coords
# External:     md_impulse()
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
# md_impulse
#
# add value to 2d image buffer at pixel nearest given point coords
#
##################################################################

procedure md_impulse ( buf, width, height, xcen, ycen, val, cmplx )

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of boxcar
real	val		# i: value to give inside boxcar
int	cmplx		# i: fill real part of array of complex elements

int	x, y		# l: index of column, index of row
int	bufx		# l: index of point in equivalent 1D real array

begin
	x = int(xcen + 0.5)
	y = int(ycen + 0.5)
	# check parameters
	if( (x < 1) || (x > width) || (y < 1) || (y > height) )
	    return;
	# calculate 1d index
	if( cmplx == 0 ) {
	    bufx = ((y - 1) * width) + x
	} else {
	    bufx = ((y - 1) * width) + (x * 2) - 1
	}
	# make assignment
	buf[bufx] = buf[bufx] + val
end
