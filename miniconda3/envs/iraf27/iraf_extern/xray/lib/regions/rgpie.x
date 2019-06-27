#$Header: /home/pros/xray/lib/regions/RCS/rgpie.x,v 11.0 1997/11/06 16:19:17 prosb Exp $
#$Log: rgpie.x,v $
#Revision 11.0  1997/11/06 16:19:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:25  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:15  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:30  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:56  pros
#General Release 1.0
#

#  rgpie.x
#
#  install a pie slice region in a pixel mask
#  pie slice extends to edge of image area,
#  application to a particular shape must take the intersection
#
#  Smithsonian Astrophysical Observatory
#  22 August 1988
#  Michael VanHilst
#
#  Basic method of making a pie is to create a polygon of each pie slice
#  extended to the edges of the field.  The polygon is defined within a
#  field from 0 to size+1 (1 beyond edge of image field in all directions)
#  to be sure that the polygon code does not miss pixels on the edge due to
#  rounding conventions.  The angle convention has the slice sweeping from
#  angle1 to angle2, counter-clockwise
#
#  rg_pie()
#  corner_vertex()
#  pie_intercept()


include <error.h>
include <pmset.h>
include "rgset.h"

########################################################################
#
# mark_pie
#
# install a set of start and stop links in a scan array for a pie wedge
#
# first compute the side of the image intercepted by the two angles
# start with the first angle, mark the center and its edge intercept
# then mark each corner going counter-clockwise,
# until reaching the side intercepted by the second angle
# mark the intercept of the second angle and draw the resulting polygon
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of box
# Input: y coordinate of center of box
# Input: first cut angle in degrees (0 is positive on Y axis, rotates CC)
# Input: second cut angle in degrees (slice from 1 to 2 counter-clockwise)
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_pie ( pl, xcen, ycen, angle1, angle2,
		   id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of box center
real	angle1, angle2	# i: 1st and 2nd angles to define wedge in degrees
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

int	width, height		# l: image mask width and height
real	sweep			# l: sweep between cut angles
real	vx[7], vy[7]		# l: arrays of vertices for polygon
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	count			# l: number of polygon vertices
int	intrcpt1, intrcpt2	# l: side intercepted by each cut
real	x2, y2			# l: coordinates of second intercept

int	pie_intercept(), corner_vertex()

begin
	# get the image size
	if( pltype == 1 )
	    call pm_gsize (pl, naxes, axlen, depth)
	else
	    call pl_gsize (pl, naxes, axlen, depth)
	width = axlen[1]
	height = axlen[2]
	# start listing vertices of polygon
	vx[1] = xcen
	vy[1] = ycen
	sweep = angle2 - angle1
	# if sweep is too small to be noticed, don't bother
	if (abs(sweep) < SMALL_NUMBER)
	    return
	if (sweep < 0.0) sweep = sweep + 360.0
	intrcpt1 =
	    pie_intercept (width, height, xcen, ycen, angle1, vx[2], vy[2])
	intrcpt2 = pie_intercept (width, height, xcen, ycen, angle2, x2, y2)
	count = 3
	# if angles intercept same side and slice is between them, no corners
	# else, mark corners until reaching side with second angle intercept
	if ((intrcpt1 != intrcpt2) || (sweep > 180.0)) {
	    repeat {
		intrcpt1 = corner_vertex (intrcpt1, width, height,
					  vx[count], vy[count])
		count = count + 1
	    } until (intrcpt1 == intrcpt2)
	}
	vx[count] = x2
	vy[count] = y2
	call rg_polygon (pl, count, vx, vy, id, depth, rgop, rop, pltype)
end

########################################################################
#
# corner_vertex
#
# set points just beyond corner to mark the corner in a polygon
# note: 1=top, 2=left, 3=bottom, 4=right, corner is between current and next
# advance index to next side and also return its value
#
# Input: code for side before corner
# Input: dimensions of the image field
# Input: reals to receive coords of corner
# Output: code of next side
#
########################################################################

int procedure corner_vertex ( index, width, height, x, y )

int	index		# i: code of side before corner
int	width, height	# i: dimensions of image field
real	x, y		# o: coords of corner

begin
	switch (index) {
	case 1:
	    x = 0.0
	    y = height + 1
	case 2:
	    x = 0.0
	    y = 0.0
	case 3:
	    x = width + 1
	    y = 0.0
	case 4:
	    x = width + 1
	    y = height + 1
	default:
	    call error (1, "index error in mark_corner")
	}
	index = index + 1
	if (index > 4) index = 1
	return (index)
end

########################################################################
#
# pie_intercept
#
# determine which side is intercepted by a vertex (given center and angle)
# set edge intercept point and return index of side
#
# Input: dimensions of image field
# Input: coords of pivot of wedge
# Input: angle describing ray being traced
# Input: reals to receive coordinates of intercept with edge
# Output: code for side intercepted
#
########################################################################

int procedure pie_intercept ( width, height, xcen, ycen, angle, xcept, ycept )

int	width, height	# i: dimensions of image field
real	xcen, ycen	# i: base pivot point of ray
real	angle		# i: angle of ray
real	xcept, ycept	# o: coordinates of intercept with edge of image field

real	angl, slope	# l: angle and slope of ray

begin
	angl = angle
	# put angles in normal range
	while (angl < 0.0)
	    angl = angl + 360.0
	while (angl >= 360.0)
	    angl = angl - 360.0
	# check for a horizontal angle
	if (abs(angl - 90.0) < SMALL_NUMBER) {
	    xcept = 0.0
	    ycept = ycen
	    return (2)
	}
	if (abs(angl - 270.0) < SMALL_NUMBER) {
	    xcept = width + 1
	    ycept = ycen
	    return (4)
	}
	# convert to a Cartesian angle
	angl = angl + 90.0
	if (angl >= 360.0)
	    angl = angl - 360.0
	if (angl < 180.0) {
	    ycept = height + 1
	    # rule out vertical line
	    if (abs(angl - 90.0) < SMALL_NUMBER) {
		x_cept = xcen
		return (1)
	    }
	} else {
	    ycept = 0.0
	    # rule out vertical line
	    if (abs(angl - 270.0) < SMALL_NUMBER) {
		xcept = xcen
		return (3)
	    }
	}
	# convert to radians
	angl = (angl / 180.0) * PI
	# calculate slope
	slope = tan (angl)
	# calculate intercept with designated y edge
	xcept = xcen + ((ycept - ycen) / slope)
	if (xcept < 0) {
	    ycept = (ycen - (xcen * slope))
	    xcept = 0.0
	    return (2)
	} else if (xcept > (width + 1)) {
	    ycept = (ycen + ((width + 1 - xcen) * slope))
	    xcept = width + 1
	    return (4)
	} else {
	    if (ycept < height)
		return (3)
	    else
		return (1)
	}
end

