#$Header: /home/pros/xray/lib/regions/RCS/rgpolygon.x,v 11.0 1997/11/06 16:19:22 prosb Exp $
#$Log: rgpolygon.x,v $
#Revision 11.0  1997/11/06 16:19:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:39  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:21  pros
#General Release 1.0
#

#  rgpolygon.x
#
#  Smithsonian Astrophysical Observatory
#  2 December 1988
#  Michael VanHilst
#
#  rg_polygon()
#  rgs_segment()
#  rgs_mark()
#  rgs_line()


include <error.h>
include <pmset.h>
include "rgset.h"


# parameter structure for a scan entry
define	LS_SCAN		2
define	SCAN_X		Memi[($1)]	# x position of scan
define	SCAN_NEXT	Memi[($1)+1]	# next scan entry in link list


########################################################################
#
# rg_polygon
#
# Mark (as per rgop) all pixels in a pixel list or pixel mask ...
#   which are inside the specified polygon
#
# The edges of the polygon are defined in real coordinates
# If a pixel center is included, the pixel is set to id
# If the pixel center is exactly on the edge, PIXINCL macro decides
#  (see rgset.h)
#
# Algorithm places each edge (between consecutive vertices) in scan-lists
# A scan list is a link list for one line, each link describes a line crossing
# Edges outside the image area are listed as on the image edge
# A line's scan-list is processed, alternating enter, exit as edges are crossed
# The scan list is then used to make the run-list for rg_plpi()
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: number of arguments in argv list
# Input: real array of vertex x coordinates
# Input: real array of vertex y coordinates
# Input: value to use for marking (as per rgop and rop)
# Input: depth of mask in bits (e.g. 16)
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_polygon ( pl, count, vx, vy, id, depth, rgop, rop, pltype )

pointer	pl		# i: handle for open pl or pm
int	count		# i: number of vertices
real	vx[ARB]		# i: array of vertex x coordinates
real	vy[ARB]		# i: array of vertex y coordinates
int	id, depth	# i: value to write, depth in bits
int	rgop		# i: rg paint operator
int	rop		# i: rop function (if selected by paint operator)
int	pltype		# i: code to select between pl and pm

real	xmin, xmax		# l: x limits from all vertices
real	ymin, ymax		# l: y limits from all vertices
int	i, j			# l: loop counters
int	ystart, ystop		# l: first and last affected row
int	xstart, xstop		# l: first and last affected column
int	width, height		# l: dimensions of pixel mask
int	bufmax			# l: length of longest possible rangelist
int	naxes, axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
pointer	scanlist		# l: base of scanlist link list
pointer	ranges			# l: line coded as runlist for rg_plpi()
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
	call amovki (1, v, PL_MAXDIM)
	bufmax = RL_MAXLEN(pl)
	call salloc (ranges, bufmax, TY_INT)
	call salloc (buf, width, TY_INT) 
	bufmax = bufmax / RL_LENELEM
	# set line width parameter, one run per line
	RLI_AXLEN(ranges) = width

	# find the limits
	xmin = vx[1]
	xmax = xmin
	ymin = vy[1]
	ymax = ymin
	do i = 2, count {
	    if (vx[i] > xmax) xmax = vx[i]
	    if (vx[i] < xmin) xmin = vx[i]
	    if (vy[i] > ymax) ymax = vy[i]
	    if (vy[i] < ymin) ymin = vy[i]
	}
	# get limits of polygon (note: PIXINCL(stop) is 1st pixel not counted)
	xstart = PIXINCL(xmin)
	xstop = PIXINCL(xmax) - 1
	ystart = PIXINCL(ymin)
	ystop = PIXINCL(ymax) - 1
	# ignore if all vertices are to one side of the image
	if ((ystop < 1) || (ystart > height) ||
	    (xstop < 1) || (xstart > width)) {
	    ystart = height + 1
	} else {
	    if (ystart < 1) ystart = 1
	    if (ystop > height) ystop = height
	}
	if (ystart > 1) {
	    # go through preceding rows in case rop wants to do something
	    RLI_LEN(ranges) = 1
	    do i = 1, ystart - 1 {
		v[2] = i
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, Memi[ranges], Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	    if (ystart > height) return		# return if no region
	}

	# allocate and zero an array of linked horizontal scan crossings
	call salloc (scanlist, ystop, TY_INT)
	call amovki (0, Memi[scanlist], ystop)
	# mark all horizontal segment crossings
	# start with segment between last and first point
	j = count
	do i = 1, count {
	    # make segments always run from lower y to higher y
	    if (vy[i] > vy[j]) {
		call rgs_segment (Memi[scanlist], width, height,
				   vx[j], vy[j], vx[i], vy[i])
	    } else {
		call rgs_segment (Memi[scanlist], width, height,
				   vx[i], vy[i], vx[j], vy[j])
	    }
	    j = i
	}
	do i = ystart, ystop {
	    # match up pairs of crossings to make start and stop passages
	    call rgs_line (Memi[scanlist + i - 1], Memi[ranges], bufmax, id)
	    v[2] = i
	    # call routine to stencil region onto existing pixel mask
	    call rg_plpi (pl, v, Memi[ranges], Memi[buf],
			  depth, width, rgop, rop, pltype)
	}

	if (ystop < height) {
	    # go through succeeding rows in case rop wants to do something
	    RLI_LEN(ranges) = 1
	    do i = ystop + 1, height {
		v[2] = i
		# call routine to stencil region onto existing pixel mask
		call rg_plpi (pl, v, Memi[ranges], Memi[buf],
			      depth, width, rgop, rop, pltype)
	    }
	}
	call sfree (sp)
end


########################################################################
#
# rgs_segment
#
# Install scan-list entries for all crossings of the given segment
#   mark only the x pixel of the crossing of a pixel y center line
#   lines which do not traverse a y center line are not marked
#   both enter and exit mark pixel whose center is beyond the crossing point
#   lines which cross edges of image area are clipped on y and flattened on x
#
# Input: array of scan lists, one list for each image line
# Input: width and height of image
# Input: x,y coordinates of vertex end of segment with lower y
# Input: x,y coordinates of vertex end of segment with higher y
#
########################################################################

procedure rgs_segment ( scan, width, height, x1, y1, x2, y2 )

pointer	scan[ARB]		   
int	width, height
real	x1, y1, x2, y2

int	ystart, ystop, yval, xval
real	invslope, xoffset

begin
	ystart = PIXINCL(y1)
	if( ystart < 1 ) ystart = 1
	# note: PIXINCL(stop) is 1st pixel not counted
	ystop = PIXINCL(y2) - 1
	if( ystop > height ) ystop = height
	# ignore segment if there is no positive slope in integer coords
	if( (ystart > ystop) || (ystop < 1) )
	    return
	# use inverse slope (run/rise) to get x given y with a multiply
	invslope = (x1 - x2) / (y1 - y2)
	xoffset = x1 + ((ystart - y1) * invslope)
	do yval = ystart, ystop {
	    xval = PIXINCL(xoffset)
	    # clip line to edges of image area (actually bend line)
	    if (xval < 1) xval = 1
	    if (xval > width) xval = width + 1
	    call rgs_mark (scan, xval, yval)
	    xoffset = xoffset + invslope
	}
end

########################################################################
#
# rgs_mark
#
# Install on entry in scanlist to indicate crossing of an edge
#   Link must be placed in list for appropriate line
#   Links are ordered by x coordinate
#
# Input: array of scan lists (one for each line)
# Input: x coordinate of entry
# Input: y coordinate of entry
#
########################################################################

procedure rgs_mark ( scan, x, y )

pointer	scan[ARB]	# i: array of scan lists
int	x, y

pointer	scanmark, mark

begin
	call salloc (mark, LS_SCAN, TY_STRUCT)
	SCAN_X(mark) = x

	# starts are installed at back of list for given x
	if( (scan[y] == NULL) || (SCAN_X(scan[y]) > x) ) {
	    SCAN_NEXT(mark) = scan[y]
	    scan[y] = mark
	} else {
	    scanmark = scan[y]
	    while( (SCAN_NEXT(scanmark) != NULL) &&
		   (SCAN_X(SCAN_NEXT(scanmark)) < x) )
		scanmark = SCAN_NEXT(scanmark)
	    SCAN_NEXT(mark) = SCAN_NEXT(scanmark)
	    SCAN_NEXT(scanmark) = mark
	}
end

########################################################################
#
# rgs_line
#
# make a rangelist given a scanlist
#
# Input: base of scanlist
# Input: buffer for rangelist
# Input: 
# Input: value assigned by ranglist
#
########################################################################

procedure rgs_line ( scan, ranges, maxmark, val )

pointer	scan				# i: base of scanlist
int	ranges[RL_LENELEM,ARB]		# i: scratch runlist line
int	maxmark				# i: limit of mark space in ranges
int	val

pointer	mark		# l: pointer to scanlist link
int	xstart		# l: x coord of first crossing inside image
int	index		# l: rangelist index

begin
	# check that there are any segments
	if (scan == NULL) {
	    RL_LEN(ranges) = 1
	    return
	}
	mark = scan
	xstart = 0
	index = 1
	while (mark != NULL) {
	    if (xstart == 0) {
		xstart = SCAN_X(mark)
	    } else {
		if (SCAN_X(mark) > xstart) {
		    index = index + 1
		    if (index > maxmark)
			call error (1, "too many polygon crossings")
		    RL_X(ranges,index) = xstart
		    RL_N(ranges,index) = SCAN_X(mark) - xstart
		    RL_V(ranges,index) = val
		}
		xstart = 0
	    }
	    mark = SCAN_NEXT(mark)
	}
	if (xstart > 0)
	    call error (1, "odd number of polygon crossings")
	RL_LEN(ranges) = index
end
