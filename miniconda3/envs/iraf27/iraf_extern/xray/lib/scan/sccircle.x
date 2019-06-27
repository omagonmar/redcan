#$Header: /home/pros/xray/lib/scan/RCS/sccircle.x,v 11.0 1997/11/06 16:23:30 prosb Exp $
#$Log: sccircle.x,v $
#Revision 11.0  1997/11/06 16:23:30  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:11:45  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:54:56  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:17:54  pros
#General Release 1.0
#
#
# Module:	sccircle.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Create a scan list for a given circle
# Includes:	sc_circle(), sc_enter_sym(), and sc_exit_sym()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_circle
# Purpose:	Put scans on a scan list for region inside a given circle.
# Parameters:	See argument declarations
# Uses:		sc_enter_sym() and sc_exit_sym() below
# Uses:		sc_op() in scop.x
# Exceptions:
# Method:	
# Notes:	
#
procedure sc_circle ( xcen, ycen, radius, val, imwdth, imhght, scan, op )

real	xcen, ycen	# i: coordinates of box center
real	radius		# i: radius of circle (not inclusive)
int	val		# i: value to associate with this region
int	imwdth, imhght	# i: dimensions of image field
pointer	scan[imhght]	# i: scan list array to which to atach region
int	op		# i: code for kind of operation to perform

real	radsq			# l: radius squared
real	xoff, yoff		# l: offsets from center for effective radius
int	y			# l: pixel y coord of a line
int	start_y, stop_y		# l: first and last affected row
int	start_x, stop_x		# l: first and last affected column

int	sc_enter_sym(), sc_exit_sym()

begin
	# rounding for y start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	start_y = sc_enter_sym (ycen - radius)
	stop_y = sc_exit_sym (ycen + radius) - 1
	# if circle is out of the picture (vertically), return
	if( (start_y > imhght) || (stop_y < 1) ) {
	    # if no region, just go through the image for rop's sake
	    start_y = imhght + 1
	} else {
	    # adjust circle limits to image limits
	    if( start_y < 1 ) start_y = 1
	    if( stop_y > imhght ) stop_y = imhght
	    radsq = radius * radius
	}
	do y = start_y, stop_y {
	    yoff = real(y) - ycen
	    xoff = sqrt (radsq - (yoff * yoff))
	    # rounding for x start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	    start_x = sc_enter_sym (xcen - xoff)
	    # stop is in the first bin not counted
	    stop_x = sc_exit_sym (xcen + xoff)
	    # check for within limits and actual run
	    if( (start_x < imwdth) && (stop_x > 1) && (stop_x > start_x) ) {
		if( start_x < 1 ) start_x = 1
		if( stop_x > imwdth ) stop_x = imwdth + 1
		call sc_op (scan[y], start_x, stop_x, val, op)
	    }
	}
end


#
# Function:	sc_enter_sym, sc_exit_sym
# Purpose:	Determine pixel to mark on the edge of a symmetric shape
# Parameters:	See argument declarations
# Uses:		
# Called by:	sc_circle() above
# Exceptions:
# Method:	
# Notes:	
#
# When a pixel center is exactly on the edge, the pixel assignment rule is:
#   > the outer edge of a symmetric shape does not include such pixels
#   > the inner edge of a symmetric shape (annulus) includes such pixels
# In this way, an annulus with radius from 0 to 1, centered exactly on
#   a pixel, includes the pixel on which it is centerd, but none of its
#   neighbors.
#
# These rules ensure that when defining concentric shapes, no pixels are
#   ommitted between concentric regions and no pixels are claimed by two
#   regions.  When applied to small symmetric shapes, the shape is less
#   likely to be skewed, as would happen with non-radially-symmetric rules.
# These rules differ from the rules for box-like shapes, which are more
#   likely to be positioned adjacent to one another.  Radially-ymmetric
#   shapes placed side by side whose real edges touch at a pixel center
#   will leave that pixel unclaimed.
#
# Call rg_enter_sym() for crossing an edge while entering a radially-
#   symmetric region's outer edge, or leaving one's inner edge
#
# Call rg_exit_sym() for crossing an edge while leaving a radially-
#   symmetric region's outer edge, or entering one's inner edge
#
int procedure sc_exit_sym ( val )

real	val	# i: real coordinate
int	ival	# o: corresponding integer value

begin
	ival = val
	if (real(ival) == val)
	    return (ival)
	else
	    return (ival + 1)
end

int procedure sc_enter_sym ( val )

real	val	# i: real coordinate
int	ival	# o: corresponding integer value

begin
	ival = val
	return (ival + 1)
end
