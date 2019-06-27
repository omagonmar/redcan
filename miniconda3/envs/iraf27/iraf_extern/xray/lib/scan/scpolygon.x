#$Header: /home/pros/xray/lib/scan/RCS/scpolygon.x,v 11.0 1997/11/06 16:23:43 prosb Exp $
#$Log: scpolygon.x,v $
#Revision 11.0  1997/11/06 16:23:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:08  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:24  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:11:40  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:24  pros
#General Release 1.0
#
#
#
# Module:	scpolygon.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Create a scan list for a given polygon
# Includes:	sc_polygon(), scp_segment(), scp_mark(), scp_line()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include <error.h>
include	<scset.h>

# to assure that geometrically adjoining regions touch but don't overlap
# when edge is exactly on a pixel center it goes to right or upper region
define PIXINCL int(($1)+1.0)	# first pixel counted when scanning low to high
# parameter structure for a scan entry
define	LS_SCAN		2
define	SCAN_X		Memi[($1)]	# x position of scan
define	SCAN_NEXT	Memi[($1)+1]	# next scan entry in link list

#
# Function:	sc_polygon
# Purpose:	Put scans on a scan list for region inside a given polygon
# Parameters:	See argument declarations
# Uses:		sc_newedge(), sc_freeedge()
# Pre-condition:scan line with all scans of same val as new scan
# Post-condition:scan line with new scan merged in
# Exceptions:
# Method:	Algorithm places each edge (between consecutive vertices) in
#		an array scan-lists.  A scan list is a link list for one line,
#		each link describes an edge crossing on that line.  Edges
#		outside the image area are listed as on the image edge.  The
#		line's scan-list is processed, alternating enter and exit as
#		edges are crossed.
# Notes:	The edges of the polygon are defined in real coordinates.
#		If a pixel center is included, the pixel is included.  If the
#		pixel center is exactly on the edge, PIXINCL macro decides.
#
procedure sc_polygon ( count, vx, vy, id, width, height )

int	count		# i: number of vertices
real	vx[ARB]		# i: array of vertex x coordinates
real	vy[ARB]		# i: array of vertex y coordinates
int	val		# i: value to write
int	width, height	# i: dimensions of image file

real	xmin, xmax		# l: x limits from all vertices
real	ymin, ymax		# l: y limits from all vertices
int	i, j			# l: loop counters
int	ystart, ystop		# l: first and last affected row
int	xstart, xstop		# l: first and last affected column
int	bufmax			# l: length of longest possible rangelist
pointer	scanlist		# l: base of scanlist link list
pointer	buf			# l: int buffer for use by rg_plpi()

begin
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
	    return
	} else {
	    if (ystart < 1) ystart = 1
	    if (ystop > height) ystop = height
	}
	# allocate and zero an array of linked horizontal scan crossings
	if( bufsz < hght ) {
	    if( scanlist != SCNULL )
		call mfree(scanlist)
	    call malloc(scanlist, height, TY_INT)
	}
	call amovki (0, Memi[scanlist], height)
	# mark all horizontal segment crossings
	# start with segment between last and first point
	j = count
	do i = 1, count {
	    # make segments always run from lower y to higher y
	    if (vy[i] > vy[j]) {
		call scp_segment (Memi[scanlist], width, height,
				   vx[j], vy[j], vx[i], vy[i])
	    } else {
		call scp_segment (Memi[scanlist], width, height,
				   vx[i], vy[i], vx[j], vy[j])
	    }
	    j = i
	}
	do i = ystart, ystop {
	    # match up pairs of crossings to make start and stop passages
	    call rgs_line (Memi[scanlist + i - 1], Memi[ranges], bufmax, id)
	}
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

procedure scp_segment ( scan, width, height, x1, y1, x2, y2 )

pointer	scan[ARB]		   
int	width, height
real	x1, y1, x2, y2

int	start_y, stop_y
int	line_y, edge_x
real	invslope, xoffset

begin
	start_y = PIXINCL(y1)
	if( start_y < 1 ) start_y = 1
	# note: PIXINCL(stop) is 1st pixel not counted
	stop_y = PIXINCL(y2) - 1
	if( stop_y > height ) stop_y = height
	# ignore segment if there is no positive slope in integer coords
	if( (start_y > stop_y) || (stop_y < 1) )
	    return
	# use inverse slope (run/rise) to get x given y with a multiply
	invslope = (x1 - x2) / (y1 - y2)
	xoffset = x1 + ((start_y - y1) * invslope)
	do line_y = start_y, stop_y {
	    edge_x = PIXINCL(xoffset)
	    # clip line to edges of image area (actually bend line)
	    if (edge_x < 1) edge_x = 1
	    if (edge_x > width) edge_x = width + 1
	    call scp_mark (scan[line_y], edge_x, val)
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

procedure scp_mark ( scan, edge_x, val )

pointer	scan	# i: element from array of scan lists
int	edge_x	# i: x coordinate of edge
int	val	# i: val being applied in scan

pointer	mark

begin
	if( (scan == NULL) || (SC_X(scan) > x) ) {
	    scan = sc_newedge(edge_x, val, SCTEMP, scan)
	} else {
	    mark = scan
	    while( (SC_NEXT(mark) != NULL) && (SC_X(SC_NEXT(mark)) < edge_x) )
		mark = SC_NEXT(mark)
	    SC_NEXT(mark) = sc_newedge(edge_x, val, SCTEMP, SC_NEXT(mark))
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
	if( scan == NULL ) {
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
