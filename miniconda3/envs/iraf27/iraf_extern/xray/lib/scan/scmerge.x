#$Header: /home/pros/xray/lib/scan/RCS/scmerge.x,v 11.0 1997/11/06 16:23:36 prosb Exp $
#$Log: scmerge.x,v $
#Revision 11.0  1997/11/06 16:23:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:55  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:10:23  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:07  pros
#General Release 1.0
#
#
#
# Module:	scmerge.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Merge a scan into an existing scan line (performs logical or).
# Includes:	sc_merge()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:		sc_merge
# Purpose:		merge a scan into an existing scan line
# Parameters:		See argument declarations
# Uses:			sc_newedge(), sc_freeedge()
# Pre-condition:	scan line with all scans of same val as new scan
# Post-condition:	scan line with new scan merged in
# Exceptions:
# Method:		Check scan edge records in the line.  Place, move,
#			free, or add edges as appropriate for merge.
# Notes:	
#
procedure sc_merge ( line, start_x, stop_x, val )

pointer line		# i: beginning of scan line link list
int	start_x		# i: starting coord of scan to be merged
int	stop_x		# i: point after last included in scan to be merged
int	val		# i: value associated with merge

pointer old		# l: pointer to edge record before merge
pointer here		# l: pointer to currently referenced edge record
pointer nxt		# l: pointer to edge record after here

pointer sc_newedge()	# return initialized edge

begin
	# if line has no scans or entire merge is before first scan
	if( (line == SCNULL) || (stop_x < SC_X(line)) ) {
	    # install merge scan at head of line
	    nxt = sc_newedge(stop_x, val, SCSTOP, line)
	    line = sc_newedge(start_x, val, SCSTART, nxt)
	    return
	}
	old = line
	here = line
	# if merge starts before first scan (we know it doesn't end before)
        if( start_x <= SC_X(here) ) {
	    # stretch first scan to begin at merge
	    SC_X(here) = start_x
	    # if merge ends  before end of first scan
	    nxt = SC_NEXT(here)
	    if( stop_x <= SC_X(nxt) )
		return
	# if merge starts later than first scan
	} else {
	    # advance line to a point that stradles the scan start
	    while( (SC_NEXT(here) != SCNULL) &&
		   (start_x >= SC_X(SC_NEXT(here))) ) {
		old = here
		here = SC_NEXT(here)
	    }
	    nxt = SC_NEXT(here)
	    # if merge goes at end of the line
	    if( nxt == SCNULL ) {
		# if merge extends from the last scan
		if( start_x == SC_X(here) ) {
		    SC_X(here) = stop_x
		} else {
		    nxt = sc_newedge(stop_x, val, SCSTOP, SCNULL)
		    SC_NEXT(here) = sc_newedge(start_x, val, SCSTART, nxt)
		}
		return
	    }
	    # if merge starts between line edge marks
	    # if start_x is between a stop and a start edge mark
	    if( SC_TYPE(here) == SCSTOP ) {
		# if stop is before the next start (we can finish here)
		if( stop_x <= SC_X(nxt) ) {
		    if( start_x == SC_X(here) ) {
			# if perfect fit, fill in gap
			if( stop_x == SC_X(nxt) ) {
			    SC_NEXT(old) = SC_NEXT(nxt)
			    call sc_freeedge(here)
			    call sc_freeedge(nxt)
			# if extends from the last stop
			} else {
			    SC_X(here) = stop_x
			}
		    # if extends to the next start
		    } else if( stop_x == SC_X(nxt) ) {
			SC_X(nxt) = start_x
		    # insert non-contiguous scan
		    } else {
			nxt = sc_newedge(stop_x, val, SCSTOP, nxt)
			SC_NEXT(here) = sc_newedge(start_x, val, SCSTART, nxt)
		    }
		    return
		# if scan ends somewhere beyond next start edge
		} else {
		    # if scan starts at last stop, bridge the gap
		    if( start_x == SC_X(here) ) {
			SC_NEXT(old) = SC_NEXT(nxt)
			call sc_freeedge(here)
			call sc_freeedge(nxt)
			here = old
		    # if starts after last stop, move next start back
		    } else {
			SC_X(nxt) = start_x
			here = nxt
		    }
		    nxt = SC_NEXT(here)
		}
	    }
	    # if start_x is between a start and a stop edge ...
	    # ... there is no need to mark start edge and ...
	    # ... if stop_x is before next stop edge, we can finish here
	    if( (SC_TYPE(here) == SCSTART) && (stop_x <= SC_X(nxt)) )
		return
	}
	# if still here, merge ends after the end of the first region
	# set old to beginning of scan and advance here to next (stop) edge
	old = here
	here = nxt
	nxt = SC_NEXT(here)
	# advance to last edge within merge, freeing intermediate edges
	while( (nxt != SCNULL) && (stop_x >= SC_X(nxt)) ) {
	    call sc_freeedge(here)
	    here = nxt
	    nxt = SC_NEXT(nxt)
	}
	# if last included edge is a stop, extend to edge of merge
	if( SC_TYPE(here) == SCSTOP ) {
	    SC_X(here) = stop_x
	    SC_NEXT(old) = here
	# if last included edge is a start, free it and merge with last scan
	} else {
	    call sc_freeedge(here)
	    SC_NEXT(old) = nxt
	}
end
