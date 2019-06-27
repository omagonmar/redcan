#$Header: /home/pros/xray/lib/scan/RCS/scrotbox.x,v 11.0 1997/11/06 16:23:45 prosb Exp $
#$Log: scrotbox.x,v $
#Revision 11.0  1997/11/06 16:23:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:17  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:09:09  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:31  pros
#General Release 1.0
#
#
#
# Module:	scrotbox.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Create a scan list for a given rotatable rectangle
# Includes:	sc_rotbox()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_rotbox
# Purpose:	Put scans on a scan list for region inside a given rotatable
#		rectangle
# Parameters:	See argument declarations
# Uses:		sc_setslope() below
# Uses:		sc_op() in scop.x
# Exceptions:
# Method:	Rotate four corners of the rectangle.  Loop from lowest to
#		highest point, sc_op'ing the scan between the left and right
#		edges.
# Notes:	The left and right edges are known by checking the quadrant of
#		rotation.
#		If a pixel center is included, the pixel is included.  If the
#		pixel center is exactly on the edge, the SC_INCL macro decides.
#
procedure sc_rotbox ( xcen, ycen, xwdth, yhght, angle, val,
		      imwdth, imhght, scan, op )

real	xcen, ycen	# i: coordinates of box center
real	xwdth, yhght	# i: box width and height
real	angle		# i: angle in degrees, rotation is counter clockwise
int	val		# i: value to associate with this region
int	imwdth, imhght	# i: dimensions of image field
pointer	scan[imhght]	# i: scan list array to which to atach region
int	op		# i: code for kind of operation to perform

real	half_width, half_height	# l: radii (1/2 width and height, resp.)
real	cosangle, sinangle	# l: sine and cosine of the angle
real	hw_cos, hw_sin		# l: products of half_width with sin and cos
real	hh_cos, hh_sin		# l: products of half_height with sin and cos
real	pt_x[4], pt_y[4]	# l: arrays of x and y coords of 4 corners
real	tangle			# i: temporary variable for angle of rotation
int	top, bottom		# l: indexes for top and bottom vertex
int	left, right		# l: indexes for left and right vertex
int	this_y, nxt, next_y
real	left_x, left_inc
real	right_x, right_inc
int	start_x, stop_x

begin
    # put angle in normal form
	tangle = angle
	# convert to a Cartesian angle
	tangle = tangle + 90.0
	while (tangle >= 360.0) tangle = tangle - 360.0
    # determine role of each vertex
	if( tangle >= 270.0 ) {
	    bottom = 3	# minimum y position
	    left = 4	# minimum x position
	    top = 1	# maximum y position
	    right = 2	# maximum x position
	} else if( tangle >= 180.0 ) {
	    bottom = 2
	    left = 3
	    top = 4
	    right = 1
	} else if( tangle >= 90.0 ) {
	    bottom = 1
	    left = 2
	    top = 3
	    right = 4
	} else {
	    bottom = 4
	    left = 1
	    top = 2
	    right = 3
	}
    # calculate trig parameters
	# convert to radians
	tangle = (tangle / 180.0) * PI
	sinangle = sin (tangle)
	cosangle = cos (tangle)
	# since we rotate by 90.0 degrees to get from astro angle to cartesian,
	# we also need to switch the width and height. we do this secretly so
	# that the display will turn out right, by doing it in the half terms
	half_width = yhght / 2.0
	half_height = xwdth / 2.0
	hw_cos = half_width * cosangle
	hw_sin = half_width * sinangle
	hh_cos = half_height * cosangle
	hh_sin = half_height * sinangle
    # assign values to corners
	pt_x[1] = xcen - hw_cos - hh_sin
	pt_y[1] = ycen - hw_sin + hh_cos
	pt_x[2] = xcen + hw_cos - hh_sin
	pt_y[2] = ycen + hw_sin + hh_cos
	pt_x[3] = xcen + hw_cos + hh_sin
	pt_y[3] = ycen + hw_sin - hh_cos
	pt_x[4] = xcen - hw_cos + hh_sin
	pt_y[4] = ycen - hw_sin - hh_cos
    # test for being within image area
	if( (bottom > imhght) || (top < 1) || (left > imwdth) || (right < 1) )
	    return
    # break into three simple sections
	this_y = SC_INCL(pt_y[bottom])
	if( this_y < 1 ) this_y = 1
	if( pt_y[left] > pt_y[right] )
	    nxt = right
	else
	    nxt = left
	# set slopes (change in x per unit y) and initial x crossings
	call sc_setslope (pt_x[bottom], pt_y[bottom], pt_x[left], pt_y[left],
			  this_y, left_x, left_inc)
	call sc_setslope (pt_x[bottom], pt_y[bottom], pt_x[right], pt_y[right],
			  this_y, right_x, right_inc)
	next_y = SC_INCL(pt_y[nxt])
	if( next_y > imhght ) next_y = imhght + 1
	while( this_y < next_y ) {
	    start_x = SC_INCL(left_x)
	    if( start_x < 1 ) start_x = 1
	    stop_x = SC_INCL(right_x)
	    if( stop_x > imwdth ) stop_x = imwdth + 1
	    call sc_op (scan[this_y], start_x, stop_x, val, op)
	    left_x = left_x + left_inc
	    right_x = right_x + right_inc
	    this_y = this_y + 1
	}
	if( nxt == right ) {
	    call sc_setslope (pt_x[right], pt_y[right], pt_x[top], pt_y[top],
			      this_y, right_x, right_inc)
	    nxt = left
	} else {
	    call sc_setslope (pt_x[left], pt_y[left], pt_x[top], pt_y[top],
			      this_y, left_x, left_inc)
	    nxt = right
	}
	next_y = SC_INCL(pt_y[nxt])
	if( next_y > imhght ) next_y = imhght + 1
	while( this_y < next_y ) {
	    start_x = SC_INCL(left_x)
	    if( start_x < 1 ) start_x = 1
	    stop_x = SC_INCL(right_x)
	    if( stop_x > imwdth ) stop_x = imwdth + 1
	    call sc_op (scan[this_y], start_x, stop_x, val, op)
	    left_x = left_x + left_inc
	    right_x = right_x + right_inc
	    this_y = this_y + 1
	}
	if( nxt == right ) {
	    call sc_setslope (pt_x[right], pt_y[right], pt_x[top], pt_y[top],
			      this_y, right_x, right_inc)
	} else {
	    call sc_setslope (pt_x[left], pt_y[left], pt_x[top], pt_y[top],
			      this_y, left_x, left_inc)
	}
	next_y = SC_INCL(pt_y[top])
	if( next_y > imhght ) next_y = imhght + 1
	while( this_y < next_y ) {
	    start_x = SC_INCL(left_x)
	    if( start_x < 1 ) start_x = 1
	    stop_x = SC_INCL(right_x)
	    if( stop_x > imwdth ) stop_x = imwdth + 1
	    call sc_op (scan[this_y], start_x, stop_x, val, op)
	    left_x = left_x + left_inc
	    right_x = right_x + right_inc
	    this_y = this_y + 1
	}
end

#
# Function:	sc_setslope
# Purpose:	Determine slope and initial x coordinate for crossing a line
# Parameters:	See argument declarations
# Uses:		
# Called by:	sc_rotbox() above
# Exceptions:
# Method:	
# Notes:	
#
procedure sc_setslope( x1, y1, x2, y2, start_y, x, xinc )

real	x1, y1	# i: coordinates of lower end of segment
real	x2, y2	# i: coordinates of higher end of segment
int	start_y # i: initial y coordinate
real	x	# o: x coordinate at start_y
real	xinc	# o: run/rise gives change in x for unit change in y

begin
	# if this line is horizontal, it won't be used anyway
	if( y1 == y2 ) {
	    xinc = x1 - x2
	} else {
	    xinc = (x1 - x2) / (y1 - y2)
	}
	x = x1 + ((start_y - y1) * xinc)
end
