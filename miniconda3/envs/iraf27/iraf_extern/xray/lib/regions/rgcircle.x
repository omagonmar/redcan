#$Header: /home/pros/xray/lib/regions/RCS/rgcircle.x,v 11.0 1997/11/06 16:19:10 prosb Exp $
#$Log: rgcircle.x,v $
#Revision 11.0  1997/11/06 16:19:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:42  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:05  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:20  pros
#General Release 1.0
#

#  rgcircle.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_circle()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_circle
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified circle
#
# The circle is defined by a real center and real radius
# If a pixel center is included, the pixel is marked
# If the pixel center is exactly on the edge, rg_enter_sym and rg_exit_sym
#   decide (see rgsymmetry.x)
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of circle
# Input: y coordinate of center of circle
# Input: radius of circle
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_circle ( pl, xcen, ycen, radius, id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of box center
real	radius		# i: radius of circle (not inclusive)
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	radsq			# l: radius squared
real	xoff, yoff		# l: offsets from center for effective radius
int	yval			# l: pixel y coord of a line
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
	call amovki (1, v, PM_MAXDIM)
	# set line width parameter, one run per line
	RL_AXLEN(ranges) = width
	RL_V(ranges,2) = id
	# allocate pixel array buffer
	call salloc (buf, width, TY_INT)

	# rounding for y start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	ystart = rg_enter_sym (ycen - radius)
	# PIXINCL(stop) is the first pixel not counted
	ystop = rg_exit_sym (ycen + radius) - 1
	# if circle is out of the picture (vertically), return
	if ((ystart > height) || (ystop < 1)) {
	    # if no region, just go through the image for rop's sake
	    ystart = height + 1
	} else {
	    # adjust circle limits to image limits
	    if (ystart < 1) ystart = 1
	    if (ystop > height) ystop = height
	    radsq = radius * radius
	}
	if (ystart > 1) {
	    # go through preceding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do yval = 1, ystart - 1 {
		v[2] = yval
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	    if (ystart > height) return		# return if no region
	}
	RL_LEN(ranges) = 2
	do yval = ystart, ystop {
	    yoff = PIXCEN(yval) - ycen
	    xoff = sqrt (radsq - (yoff * yoff))
	    # rounding for x start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	    xstart = rg_enter_sym (xcen - xoff)
	    # stop is in the first bin not counted
	    xstop = rg_exit_sym (xcen + xoff)
	    # check for within limits and actual run
	    if ((xstart < width) && (xstop > 1) && (xstop > xstart)) {
		if (xstart < 1) xstart = 1
		if (xstop > width) xstop = width + 1
		v[2] = yval
		RL_X(ranges,2) = xstart
		RL_N(ranges,2) = xstop - xstart
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	}
	if (ystop < height) {
	    # go through succeeding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do yval = ystop + 1, height {
		v[2] = yval
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	}
	call sfree (sp)
end
