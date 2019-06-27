#$Header: /home/pros/xray/lib/regions/RCS/rgpoint.x,v 11.0 1997/11/06 16:19:22 prosb Exp $
#$Log: rgpoint.x,v $
#Revision 11.0  1997/11/06 16:19:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:37  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:37  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:17  pros
#General Release 1.0
#

#  rgpoint.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_point()


include <pmset.h>
include "rgset.h"


########################################################################
#
# rg_point
#
# Mark (as per rgop) each pixel in a pixel list or pixel mask ...
#   which contains the given point coordinates
#
# For each point coord pair, set the pixel which contains those coords to id
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: number of arguments in argv list
# Input: real array of point coordinates, paired x,y
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_point ( pl, argc, argv, id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
int	argc		# i: number of arguments (2 per point)
real	argv[ARB]	# i: pairs of coordinates (x then y)
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	xcen, ycen		# l: real coordinates of point
int	i, j			# l: loop counters
int	yval, xval		# l: pixel coords of a point
int	width, height		# l: dimensions of pixel mask
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	ranges[RL_LENELEM,3]	# l: line coded as runlist for rg_plpi()
int	match			# l: flag that line being used for 2nd time
pointer	buf			# l: int buffer for use by rg_plpi()
pointer	ydone			# l: int list of y coords of lines touched
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
	# allocate pixel array buffer
	call salloc (buf, width * RL_LENELEM , TY_INT)
	# allocate lines used buf (we only use even indexes)
	call salloc (ydone, argc, TY_INT)
	# initialize all dimensions to start at 1
	call amovki (1, v, PM_MAXDIM)
	# set line width parameter, one run per line
	RL_AXLEN(ranges) = width
	RL_LEN(ranges) = 2
	# each point has width 1, value is given
	RL_N(ranges,2) = 1
	RL_V(ranges,2) = id
	do i = 1, argc, 2 {
	    xcen = argv[i]
	    ycen = argv[i+1]
	    # rounding to determine bin: 0.5 - 1.5 = 1, 1.5 - 2.5 = 2
	    yval = PIXNUM(ycen)
	    xval = PIXNUM(xcen)
	    # remember this line
	    Memi[ydone] = yval
	    # if point is within image
	    if ((yval > 0) && (yval <= height) &&
		(xval > 0) && (xval <= width)) {
		# set point's location and row number
		RL_X(ranges,2) = xval
		v[2] = yval
		# see if we did this line once before
		match = NO
		if( (i > 2) && (rgop == RG_ROP) ) {
		    do j = i - 3, 0, -2 {
			if( yval == memi[ydone + j] )
			    match = YES
		    }
		}
		# call routine to stencil region onto existing pixel mask
		if( match == YES )
		    # second pass on PIX_SRC line should be painted
		    call rg_plpi (pl, v, ranges, memi[buf], depth, width,
				  RG_PAINT, 1, pltype)
		else
		    call rg_plpi (pl, v, ranges, Memi[buf], depth, width,
				  rgop, rop, pltype)
	    }
	}
	call sfree (sp)
end
