#$Header: /home/pros/xray/lib/scan/RCS/scpaint.x,v 11.0 1997/11/06 16:23:39 prosb Exp $
#$Log: scpaint.x,v $
#Revision 11.0  1997/11/06 16:23:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:11:00  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:16  pros
#General Release 1.0
#

# Module:	scpaint.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Paint a scan over an existing scan line
# Subroutines:	sc_paint()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989  You may do anything you like with this file except
#		remove this copyright.
# Modified:	{0} Michael VanHilst	2 June 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

# Function:		sc_paint
# Purpose:		paint a scan over an existing scan line
# Uses:			sc_newedge()
# Post-condition:	scan line with new scan "painted"
# Method:		Check scan edge records in the line.  Install new
#			scans, shorten or delete old scans where they overlap
#			the new scan.
# Notes:		Start_x and stop_x are not checked for being within
#			any defined range of line length.
#
procedure sc_paint ( line, start_x, stop_x, val )

pointer line		# i: beginning of scan line link list
int	start_x		# i: starting coord of scan to be added
int	stop_x		# i: point after last included in scan to be added
int	val		# i: value to be added

pointer paint		# l: pointer to starting edge of paint scan
pointer here		# l: pointer to currently referenced edge record
pointer nxt		# l: pointer to edge record after here
pointer temp		# l: temporary pointer to a new edge record

pointer sc_newedge()	# return initialized edge

begin
	# if line has no scans or paint starts before first scan
	if( (line == SCNULL) || (stop_x < SC_X(line)) ) {
	    # install entire scan at head of line
	    paint = sc_newedge(stop_x, val, SCSTOP, line)
	    line = sc_newedge(start_x, val, SCSTART, paint)
	    return
	}
	# if line starts in mid paint
	if( start_x <= SC_X(line) ) {
	    here = line
	    nxt = SC_NEXT(here)
	    paint = sc_newedge(start_x, val, SCSTART, here)
	    line = paint
	} else {
	    nxt = line
	    while( (nxt != SCNULL) && (start_x > SC_X(nxt)) ) {
		here = nxt
		nxt = SC_NEXT(here)
	    }
	    # now here edge is before paint start nxt edge is at or beyond
# possibilities are:
# (note add dummy start to avoid single old scan stradling both start and stop)
# paint begins mid scan:
#   test (here == START && next_x > start_x)
#  same val as paint: (merge) point paint at start, add dummy start
#  different val: add stop,start paint,add dummy start -all between here & next
# paint begins at end of scan: (contiguous next start is no issue)
#   test (next_x == start_x && (here == START || next == STOP))
#  same val as paint: (merge) point paint at start, free stop
#  different val: start paint after scan
# paint begins after scan: start paint after scan
#   test (here == STOP)
#  next scan begins with paint: switch start, add dummy start
#   test (next_x == start_x && next == START)
#  no scan begins with paint: start paint after scan
# paint begins after everything
#   test (next == NULL || next_x > stop_x)

	    if( SC_TYPE(here) == SCSTOP ) {
		# scan begins after a stop
		paint = sc_newedge(start_x, val, SCSTART, nxt)
		SC_NEXT(here) = paint
		# check for easy finish before nxt
		if( (nxt == SCNULL) || (SC_X(nxt) > stop_x) ) {
		    SC_NEXT(paint) = sc_newedge(stop_x, val, SCSTOP, nxt)
		    return
		}
		if( SC_X(nxt) == stop_x ) {
		    if( SC_VAL(nxt) == val ) {
			call sc_freeedge(nxt)
		    } else {
			SC_NEXT(paint) = sc_newedge(stop_x, val, SCSTOP, nxt)
		    }
		    return
		}
		# advance pointers
		here = nxt
		nxt = SC_NEXT(nxt)
	    } else {
		if( SC_X(nxt) > start_x ) {
		    # paint begins mid-scan
		    if( SC_VAL(here) == val ) {
			# merge: point paint at start, add dummy start
			paint = here
			here = sc_newedge(start_x, val, SCSTART, nxt)
			SC_NEXT(paint) = here
		    } else {
			# splice: add stop, add start, add dummy start
			temp = here
			here = sc_newedge(start_x, SC_VAL(nxt), SCSTART, nxt)
			paint = sc_newedge(start_x, val, SCSTART, here)
			SC_NEXT(temp) =
			 sc_newedge(start_x, SC_VAL(here), SCSTOP, paint)
		    }
		} else {
		    # paint begins at end of scan (marked by nxt)
		    if( SC_VAL(here) == val ) {
			# merge: point paint at start, make stop dummy start
			paint = here
			here = nxt
			nxt = SC_NEXT(nxt)
			# finish if this is the end
			if( nxt == SCNULL ) {
			    SC_X(here) = stop_x
			    return
			}
		    } else {
			# start new after next(STOP)
			here = SC_NEXT(nxt)
			paint = sc_newedge(start_x, val, SCSTART, here)
			SC_NEXT(nxt) = paint
			if( here == SCNULL ) {
			    SC_NEXT(paint) =
			     sc_newedge(stop_x, val, SCSTOP, here)
			    return
			} else
			    nxt = SC_NEXT(here)
		    }
		    # since we advanced, we might be able to finish here
		    if( SC_X(here) >= stop_x ) {
			if( (SC_X(here) > stop_x) || (SC_VAL(here) != val) ) {
			    SC_NEXT(paint) =
			     sc_newedge(stop_x, val, SCSTOP, here)
			} else {
			    call sc_freeedge(here)
			}
			return
		    }
		}
	    }
	}
# at this point we have the three pointers:
# paint - paint != SCNULL, SC_TYPE(paint) == SCSTART, SC_NEXT(paint) == here
# here - here != SCNULL, SC_X(here) >= start_x, SC_X(here) < stop_x
# nxt - nxt != SCNULL, SC_NEXT(here) == nxt, SC_X(nxt) >= SC_X(here)
# walk down the line freeing everything until we reach stop_x
	# advance to last edge within merge, freeing intermediate edges
	while( (nxt != SCNULL) && (stop_x > SC_X(nxt)) ) {
	    call sc_freeedge(here)
	    here = nxt
	    nxt = SC_NEXT(nxt)
	}
	# now here is an edge before stop_x, nxt is at or beyond stop_x or NULL
# possible situations are:
# A) here is a stop(before x_stop)
# A1)  next is NULL
# A2)  next is start beyond x_stop
# A3)  next is start at x_stop
# A3i)   next has SC_VAL same as val
# A3ii)  next has SC_VAL different from val
# B) here is start(before x_stop), next is stop
# B2)  next is stop beyond x_stop
# B2i)   next&here have SC_VAL==val
# B2ii)  next&here have SC_VAL!=val
# B3)  next is stop at x_stop
# B3x)   next is followed by start at x_stop with SC_VAL==val
# B3xx)  next is not followed by start at x_stop w/ SC_VAL==val
# possible actions are:
# a) free here:				A1,A2,A3i,A3ii	B2i,    B3x,B3xx
# b) change SC_X of here:				   B2ii
# c) free next:				      A3i,		B3x
# d) free link after next:					B3x
# e) change SC_VAL of next:					    B3xx
# I)  install new stop between paint/here:		   B2ii
# II) install new stop before next:	A1,A2,	  A3ii
# III)point paint at nxt:		  		B2i,	    B3xx
# IV) point paint after nxt:		      A3i
# V)  point paint after after nxt:				B3x
# resulting logic:
# (here.type==stop)
#   free here
#   (nxt.x==stop_x && nxt.val==val)
#     free nxt, point paint at nxt.next				A3i
#   (else)
#     new stop between paint/nxt				A1,A2,A3ii
# (else)
#   (nxt.x==stop_x)
#     free here
#     (nxt.next!=NULL && nxt.next.x==stop_x && nxt.next.val==val)
#	free nxt, free nxt.next, point paint at nxt.next.next	B3x
#     (else)
#	change nxt.val, point paint at nxt			B3xx
#   (else)
#     (here.val==val)
#	free here, point paint at nxt					B2i
#     (else)
#	here.x=stop_x, new stop between paint/here		B2ii


	if( SC_TYPE(here) == SCSTOP ) {
	    call sc_freeedge(here)
	    if( (nxt != SCNULL) && (SC_X(nxt) == stop_x) &&
	      (SC_VAL(nxt) == val) ) {
		# paint continues into next contiguous scan (same val)
		SC_NEXT(paint) = SC_NEXT(nxt)
		call sc_freeedge(nxt)
	    } else {
		# paint stops before next scan, if any, begins
		SC_NEXT(paint) = sc_newedge(stop_x, val, SCSTOP, nxt)
	    }
	} else {
	    if( SC_X(nxt) == stop_x ) {
		# stop of existing scan and paint align
		call sc_freeedge(here)
		if( (SC_NEXT(nxt) != SCNULL) &&
		  (SC_X(SC_NEXT(nxt)) == stop_x) &&
		  (SC_VAL(SC_NEXT(nxt)) == val) ) {
		    # the next scan is contiguous with same val as paint
		    SC_NEXT(paint) = SC_NEXT(SC_NEXT(nxt))
		    call sc_freeedge(SC_NEXT(nxt))
		    call sc_freeedge(nxt)
		} else {
		    # paint ends before any next scan (remark existing stop)
		    SC_NEXT(paint) = nxt
		    SC_VAL(nxt) = val
		}
	    } else {
		# existing scan straddles end of paint
		if( SC_VAL(here) == val ) {
		    # same val, continue paint into tail of existing scan
		    call sc_freeedge(here)
		    SC_NEXT(paint) = nxt
		} else {
		    # different vals, restart scan after paint
		    SC_NEXT(paint) = sc_newedge(stop_x, val, SCSTOP, here)
		    SC_X(here) = stop_x
		}
	    }
	}
	return
end
