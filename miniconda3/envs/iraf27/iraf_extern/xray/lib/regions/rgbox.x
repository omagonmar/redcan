#$Header: /home/pros/xray/lib/regions/RCS/rgbox.x,v 11.0 1997/11/06 16:19:09 prosb Exp $
#$Log: rgbox.x,v $
#Revision 11.0  1997/11/06 16:19:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:03  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:31  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:16  pros
#General Release 1.0
#

#  rgbox.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_box()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_box
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified orthogonal box
#
# The edges of the box are defined in real coordinates
# If a pixel center is included, the pixel is set to id
# If the pixel center is exactly on the edge, PIXINCL macro decides
#  (see rgset.h)
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of box
# Input: y coordinate of center of box
# Input: x dimension (width) of box
# Input: y dimension (height) of box
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_box ( pl, xcen, ycen, xdim, ydim, id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of box center
real	xdim, ydim	# i: box width and height
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	half_width, half_height	# l: radii (1/2 width and height, resp.)
int	yval			# l: pixel y coord of a line
int	ystart, ystop		# l: first and last affected row
int	xstart, xstop		# l: first and last affected column
int	width, height		# l: dimensions of pixel mask
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	ranges[RL_LENELEM,3]	# l: line coded as runlist for rg_plpi()
pointer	buf			# l: int buffer for use by rg_plpi()
pointer	sp			# l: stack pointer

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

	half_height = ydim / 2.0
	half_width = xdim / 2.0
	# get the limits
	ystart = PIXINCL(ycen - half_height)
	# PIXINCL(stop) is the first pixel not counted
	ystop = PIXINCL(ycen + half_height) - 1
	xstart = PIXINCL(xcen - half_width)
	xstop = PIXINCL(xcen + half_width)
	# rule out cases of entire box outside of image
	if ((ystart > height) || (ystop < 1) ||
	    (xstart > width) || (xstop < 1)) {
	    # if no region, just go through the image for rop's sake
	    ystart = height + 1
	} else {
	    # clip limits at edge of image
	    if (ystart < 1) ystart = 1
	    if (ystop > height) ystop = height
	    if (xstart < 1) xstart = 1
	    if (xstop > width) xstop = width + 1
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
	    if (ystart > height) return		# no region
	}
	# install box scan points
	RL_X(ranges,2) = xstart
	RL_N(ranges,2) = xstop - xstart
	RL_LEN(ranges) = 2
	do yval = ystart, ystop {
	    v[2] = yval
	    # call routine to stencil region onto existing pixel mask
	    call rg_plpi (pl, v, ranges, Memi[buf],
			  depth, width, rgop, rop, pltype)
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


