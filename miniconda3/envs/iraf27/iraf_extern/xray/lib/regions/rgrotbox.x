#$Header: /home/pros/xray/lib/regions/RCS/rgrotbox.x,v 11.0 1997/11/06 16:19:23 prosb Exp $
#$Log: rgrotbox.x,v $
#Revision 11.0  1997/11/06 16:19:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:45  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/22  08:46:02  mo
#MC/DS	4/22/92		Fix bug that input angle argument was
#				being modified.  New variable created
#				for local 'angle' conversions
#				( bug reported by Diane Gilmore at ST
#				  error of rotbox with annulli )
#
#Revision 3.0  91/08/02  01:06:35  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:25  pros
#General Release 1.0
#

#  rgrotbox.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_rotbox()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_rotbox
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified rotated box
#
# Rotation is per sky conventions, counter-clockwise from positive Y
# The edges of the box are defined in real coordinates
# If a pixel center is included, the pixel is set to id
# If the pixel center is exactly on the edge, PIXINCL macro decides
#  (see rgset.h)
#
# Algorithm calculate the four corners and calls rg_polygon to make shape
#  as a four point polygon
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of box
# Input: y coordinate of center of box
# Input: x dimension (width) of box
# Input: y dimension (height) of box
# Input: angle of rotation in degrees (0 is positive on Y axis, rotates CC)
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_rotbox ( pl, xcen, ycen, xwidth, yheight, angle,
		      id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of box center
real	xwidth, yheight	# i: box width and height
real	angle		# i: angle in degrees, rotation is counter clockwise
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	angl			# l: Cartesian angle in radians
real	half_width, half_height	# l: radii (1/2 width and height, resp.)
real	cosangl, sinangl	# l: sine, cosine of the Cartesian angle
real	hw_cos, hw_sin		# l: products of half_width with sin and cos
real	hh_cos, hh_sin		# l: products of half_height with sin and cos
real	cornerx[4], cornery[4]	# l: arrays of x and y coords of 4 corners

begin
	# convert to a Cartesian angle; save angle for use in multi or slices
	angl = angle + 90.0
	while (angl >= 360.0) angl = angl - 360.0
	# convert to radians
	angl = (angl / 180.0) * PI
	sinangl = sin (angl)
	cosangl = cos (angl)
	# since we rotate by 90.0 degrees to get from astro angle to cartesian,
	# we also need to switch the width and height. we do this secretly so
	# that the display will turn out right, by doing it in the half terms
	half_width = yheight / 2.0
	half_height = xwidth / 2.0
	hw_cos = half_width * cosangl
	hw_sin = half_width * sinangl
	hh_cos = half_height * cosangl
	hh_sin = half_height * sinangl
	cornerx[1] = xcen - hw_cos - hh_sin
	cornery[1] = ycen - hw_sin + hh_cos
	cornerx[2] = xcen + hw_cos - hh_sin
	cornery[2] = ycen + hw_sin + hh_cos
	cornerx[3] = xcen + hw_cos + hh_sin
	cornery[3] = ycen + hw_sin - hh_cos
	cornerx[4] = xcen - hw_cos + hh_sin
	cornery[4] = ycen - hw_sin - hh_cos
	call rg_polygon (pl, 4, cornerx, cornery, id, depth, rgop, rop, pltype)
end

