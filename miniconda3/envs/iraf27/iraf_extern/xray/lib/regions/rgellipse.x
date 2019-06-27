#$Header: /home/pros/xray/lib/regions/RCS/rgellipse.x,v 11.0 1997/11/06 16:19:12 prosb Exp $
#$Log: rgellipse.x,v $
#Revision 11.0  1997/11/06 16:19:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:41  prosb
#General Release 2.2
#
#Revision 5.1  93/04/30  03:16:03  dennis
#Corrected old error of changing the angle input parameter; the regions 
#rewrite flushed this one out.
#
#Revision 5.0  92/10/29  21:14:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:48  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:33  pros
#General Release 1.0
#

#  rgellipse.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_ellipse()
#  rg_quadeq()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_ellipse
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified ellipse
#
# The edges of the ellipse are defined in real coordinates
# If a pixel center is included, the pixel is marked
# If the pixel center is exactly on an edge, rg_enter_sym and rg_exit_sym
#   decide (see rgsymmetry.x)
# Rotation is per sky conventions, counter-clockwise from positive Y
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of circular annulus
# Input: y coordinate of center of circular annulus
# Input: radius on pre-rotated x axis
# Input: radius on pre-rotated y axis
# Input: angle of rotation in degrees (0 is positive on Y axis, rotates CC)
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_ellipse ( pl, xcen, ycen, xrad, yrad, angle,
		       id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of circle center
real	xrad, yrad	# i: radii of ellipse (on pre-rotated axes)
real	angle		# i: angle in degrees, rotation is counter clockwise
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	angl			# l: Cartesian angle in radians
real	cosangl, sinangl	# l: cosine, sine of the Cartesian angle
real	cossq, sinsq		# l: cosangl squared, sinangl squared
real	xradsq, yradsq		# l: radii squared
real	yoff			# l: y offset of line from center
real	ymax			# l: used to choose effective ystart ystop
real	xboff, xfoff		# l: x offsets from center of edges at yoff
real	b_partial, c_partial	# l: precomputed partials of quadratic
real	a, b, c			# l: line specific pieces of the quadratic
int	nr, nc			# l: line specific pieces of the quadratic
int	y			# l: pixel y coord of a line
int	ystart, ystop		# l: first and last affected row
int	xstart, xstop		# l: first and last affected column
int	width, height		# l: dimensions of pixel mask
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	ranges[RL_LENELEM,3]	# l: line coded as runlist for rg_plpi()
pointer	buf			# l: int buffer for use by rg_plpi()
pointer	sp			# l: stack pointer

int	rg_enter_sym(), rg_exit_sym()

begin
	call smark (sp)
	# get the image size
	if( pltype == 1 )
	    call pm_gsize (pl, naxes, axlen, depth)
	else
	    call pl_gsize (pl, naxes, axlen, depth)
	width = axlen[1]
	height = axlen[2]
	# initialize all dimensions to start at 1
	call amovki (1, v, PL_MAXDIM)
	# set line width parameter, one run per line
	RL_AXLEN(ranges) = width
	RL_V(ranges,2) = id
	# allocate pixel array buffer
	call salloc (buf, width, TY_INT)

	# check for error
	if( (xrad < SMALL_NUMBER) || (yrad < SMALL_NUMBER) ) {
	    call printf ("WARNING: ellipse specified with no dimension\n")
	    return
	}
	# set worst case limits (xrad axis parallel to vertical axis)
	# convert to a Cartesian angle; save "angle" for use by other routines
	angl = angle + 90.0
	while( angl >= 360.0 )
	    angl = angl - 360.0
	# convert to radians
	angl = (angl / 180.0) * PI
	sinangl = sin(angl)
	cosangl = cos(angl)
	# calculate approximate y limits
	# choose lesser of containing rotbox and circle
	ymax = abs(sinangl * yrad) + abs(cosangl * xrad)
	ymax = min(ymax, max(yrad, xrad))
	ystart = rg_enter_sym (ycen - ymax)
	# pix__(stop) gives first pixel not counted
	ystop = rg_exit_sym (ycen + ymax) - 1
	# adjust ellipse limits to image limits
	if( ystart < 1 ) ystart = 1
	if( ystop > height ) ystop = height
	# if circle is out of the picture (vertically), or too small return
	if( (ystart > ystop) || (ystop < 1) )
	    ystart = height + 1
	if( ystart > 1 ) {
	    # go through preceding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do y = 1, ystart - 1 {
		v[2] = y
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	    # return if no region
	    if( ystart > height ) return
	}
	RL_LEN(ranges) = 2

	# prepare partials for quadratic equation solutions to coordinates
	cossq = cosangl * cosangl
	sinsq = sinangl * sinangl
	# because we rotate by 90.0 degrees to get from astro angle to
	# cartesian, we also need to switch the x and y axes. we do this
	# secretly so that the display will turn out right, by doing it in
	# the sq terms
	xradsq = yrad * yrad
	yradsq = xrad * xrad
	# fill in as much of a,b,c as we can
	a = (cossq / xradsq) + (sinsq / yradsq)
	b_partial =
	    (2.0 * sinangl) * ((cosangl / xradsq) - (cosangl / yradsq))
	c_partial = (sinsq / xradsq) + (cossq / yradsq)

	do y = ystart, ystop {
	    v[2] = y
	    yoff = y - ycen
	    b = b_partial * yoff
	    c = (c_partial * yoff * yoff) - 1.0
	    # solve quadratic
	    call rg_quadeq (a, b, c, xboff, xfoff, nr, nc)
	    # if real roots
	    if( nr != 0 ) {
		# translate x coordinates
		xstart = rg_enter_sym (xcen + xboff)
		xstop = rg_exit_sym (xcen + xfoff)
		# check limits
		if( (xstart < width) && (xstop > 1) && (xstop > xstart) ) {
		    if( xstart < 1 ) xstart = 1
		    if( xstop > width ) xstop = width + 1
		    RL_X(ranges,2) = xstart
		    RL_N(ranges,2) = xstop - xstart
		    # call routine to stencil region onto existing pixel mask
		    call rg_plpi (pl, v, ranges, Memi[buf],
				  depth, width, rgop, rop, pltype)
		}
	    }
	}
	if( ystop < height ) {
	    # go through succeeding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do y = ystop + 1, height {
		v[2] = y
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	}
	call sfree (sp)
end


#
# subroutine:	 quadeq
# purpose: 	solve the quadradic equation
# Author:	Leon Van Speybroeck
# Rev.		1.00	22 April, 1987
# Calling sequence:
#	call quadeq(a,b,c,x1,x2,nr,nc)
# the equation is:
#	a x**2 + b x + c = 0
# a,b, and c are real
# the possible returned cases are:
#	case			nr	nc	roots	(condition)
#	no roots		0	0	(x1 = x2 = 0.0)
# 	one real root		1	0	x1 = x2 = root	
#	two real roots		2	0	roots = x1,x2; x1 < x2
#	two complex roots	0	2	roots = x1 +- i x2
# procedure sets x1, x2, nr, and nc

# parameters to make type conversion easy
define zero 0.0
define half 0.5
define four 4.0

procedure rg_quadeq ( a, b, c, x1, x2, nr, nc )

real	a, b, c, x1, x2
int	nr, nc

# internal arguments:
# dis = b*b - 4*a*c or sqrt(b*b - 4*a*c)
# q = temporary, sometimes = b + sgn(b) sqrt(b*b-4*a*c)

real	dis, q

begin
	if (a == zero) {
	    nc = 0
	    if (b == zero) {
		nr = 0
		x1 = zero
	    } else {
		nr = 1
		x1 = -c / b
	    }
	    x2 = x1
	} else {
	    dis = b * b - four * a * c
	    if (dis > zero) {
		nr = 2
		nc = 0
		dis = sqrt(dis)
		if (b < zero) dis = -dis
		q = -half * (b + dis)
		x1 = q / a
		x2 = c / q
		if (x1 > x2) {
		    q = x1
		    x1 = x2
		    x2 = q
		}
	    } else if (dis == zero) {
		nr = 1
		nc = 0
		x1 = - half * b / a
		x2 = x1
	    } else {
		nr = 0
		nc = 2
		x1 = - half * b / a
		x2 = half * sqrt(-dis) / a
	    }
	}
end
