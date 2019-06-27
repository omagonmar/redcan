#$Header: /home/pros/xray/lib/regions/RCS/rgannulus.x,v 11.0 1997/11/06 16:19:07 prosb Exp $
#$Log: rgannulus.x,v $
#Revision 11.0  1997/11/06 16:19:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:13:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:22  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:20  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:09  pros
#General Release 1.0
#

#  rgannulus.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_annulus()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_annulus
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified circular annulus
#
# The annulus is defined by a real center and real inner and outer radii
# If a pixel center is included, the pixel is marked
# If the pixel center is exactly on an edge, rg_enter_sym and rg_exit_sym
#   decide (see rgsymmetry.x)
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: x coordinate of center of circular annulus
# Input: y coordinate of center of circular annulus
# Input: inner radius of annulus
# Input: outer radius of annulus
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_annulus ( pl, xcen, ycen, inner_rad, outer_rad,
		       id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
real	xcen, ycen	# i: coordinates of circle center
real	inner_rad	# i: inner radius of annulus (inclusive)
real	outer_rad	# i: outer radius of annulus (exclusive)
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	irad, orad		# l: inner and outer radius for internal use
real	inner_radsq		# l: inner radius squared
real	outer_radsq		# l: outer radius squared
real	yoff			# l: y offset of line from center
real	xi_off, xo_off		# l: x offsets from center of edges at yoff
int	yval			# l: pixel y coord of a line
int	yo_start, yo_stop	# l: first and last affected row
int	xi_start, xi_stop	# l: first and last affected column
int	xo_start, xo_stop	# l: first and last affected column
int	width, height		# l: dimensions of pixel mask
int	index			# l: entry index in range list
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	ranges[RL_LENELEM,5]	# l: line coded as runlist for rg_plpi()
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
	RL_V(ranges,3) = id
	# allocate pixel array buffer
	call salloc (buf, width, TY_INT)

	# make sure inner and outer are correct
	if( inner_rad <= outer_rad ) {
	    irad = inner_rad
	    orad = outer_rad
	} else {
	    orad = inner_rad
	    irad = outer_rad
	}
	# rounding for y start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	yo_start = rg_enter_sym (ycen - orad)
	yo_stop = rg_exit_sym (ycen + orad) - 1
	# if circle is out of the picture (vertically), return
	if( (yo_start > height) || (yo_stop < 1) ) {
	    # if no region, just go through the image for rop's sake
	    yo_start = height + 1
	} else {
	    # adjust circle limits to image limits
	    if (yo_start < 1) yo_start = 1
	    if (yo_stop > height) yo_stop = height
	    outer_radsq = orad * orad
	    inner_radsq = irad * irad
	}
	if( yo_start > 1 ) {
	    # go through preceding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do yval = 1, yo_start - 1 {
		v[2] = yval
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	    if( yo_start > height ) return		# return if no region
	}
	do yval = yo_start, yo_stop {
	    yoff = PIXCEN(yval) - ycen
	    # determine outer x intersections
	    xo_off = sqrt (outer_radsq - (yoff * yoff))
	    # rounding for x start and stop: 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
	    # start is the first marker into the ring
	    xo_start = rg_enter_sym (xcen - xo_off)
	    # stop is the last exit of the ring (on the far side)
	    xo_stop = rg_exit_sym (xcen + xo_off)
	    # if some of ring on this line is within image
	    if( (xo_start < width) && (xo_stop > 1) ) {
		# start range list entry index for preparing rangelist
		index = 1
		# if inner edge of ring crosses this line
		if( (yoff < irad) && (yoff > (-irad)) ) {
		    xi_off = sqrt (inner_radsq - (yoff * yoff))
		    # rounding for start and stop, 0.5 - 1.0 = 1, 1.0 - 2.0 = 2
		    # stop ends the first crossing of the ring
		    xi_stop = rg_enter_sym (xcen - xi_off)
		    # start is the re-marker into the ring on the far side
		    xi_start = rg_exit_sym (xcen + xi_off)
		    # if first crossing of inner edge is within image
		    if( xi_stop > 1 ) {
			if (xo_start < 1) xo_start = 1
			if (xi_stop > width) xi_stop = width + 1
			index = index + 1
			RL_X(ranges,index) = xo_start
			RL_N(ranges,index) = xi_stop - xo_start
		    }
		    # if second crossing of inner edge is within image
		    if( xi_start <= width ) {
			if( xi_start < 1 ) xi_start = 1
			if( xo_stop > width ) xo_stop = width + 1
			index = index + 1
			RL_X(ranges,index) = xi_start
			RL_N(ranges,index) = xo_stop - xi_start
		    }
		} else if( xo_stop > xo_start ) {
		    # passing measurably through ring above or below inner edge
		    if( xo_start < 1 ) xo_start = 1
		    if( xo_stop > width ) xo_stop = width + 1
		    index = index + 1
		    RL_X(ranges,index) = xo_start
		    RL_N(ranges,index) = xo_stop - xo_start
		}
		# if a run was set up, put it in
		if( index > 1 ) {
		    v[2] = yval
		    RL_LEN(ranges) = index
		    call rg_plpi (pl, v, ranges, Memi[buf],
				  depth, width, rgop, rop, pltype)
		}
	    }
	}
	if( yo_stop < height ) {
	    # go through succeeding rows in case rop wants to do something
	    RL_LEN(ranges) = 1
	    do yval = yo_stop + 1, height {
		v[2] = yval
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, ranges, Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	}
	call sfree (sp)
end
