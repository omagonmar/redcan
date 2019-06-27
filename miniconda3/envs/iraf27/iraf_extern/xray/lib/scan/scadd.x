#$Header: /home/pros/xray/lib/scan/RCS/scadd.x,v 11.0 1997/11/06 16:23:28 prosb Exp $
#$Log: scadd.x,v $
#Revision 11.0  1997/11/06 16:23:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:11:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:53:12  mo
#MC   8/2/91          Updated dependencies`
#
#Revision 2.0  91/03/07  00:17:50  pros
#General Release 1.0
#
#
#
# Module:	scadd.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Add a scan to an existing scan line (performs arithmetic add).
# Includes:	sc_add()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:		sc_add
# Purpose:		add a scan to an existing scan line
# Parameters:		See argument declarations
# Uses:			sc_newedge()
# Pre-condition:
# Post-condition:	scan line with new scan added to existing scan vals
# Exceptions:
# Method:		Check scan edge records in the line.  Install new
#			scans, cut up old scans, and add to scan vals as
#			appropriate.
# Notes:		Start_x and stop_x are not checked for being within
#			any defined range of line length.
#
procedure sc_add ( line, start_x, stop_x, val )

pointer line		# i: beginning of scan line link list
int	start_x		# i: starting coord of scan to be added
int	stop_x		# i: point after last included in scan to be added
int	val		# i: value to be added

pointer veryold		# l: pointer to edge record 2nd before addition
pointer old		# l: pointer to edge record before addition
pointer here		# l: pointer to currently referenced edge record
pointer nxt		# l: pointer to edge record after here
pointer temp		# l: temporary pointer to a new edge record

pointer sc_newedge()	# return initialized edge

begin
	veryold = line
	old = line
	# if line has no scans or add starts before first scan
	if( (line == SCNULL) || (start_x < SC_X(line)) ) {
	    # install a scan at head of line
	    line = sc_newedge(start_x, val, SCSTART, old)
	    # if line has no scans or entire merge is before first scan
	    if( (old == SCNULL) || (stop_x <= SC_X(old)) ) {
		# if this creates adjacent scans of same val, merge
		if( (old != SCNULL) &&
		    (SC_X(old) == stop_x) && (SC_VAL(old) == val) ) {
		    SC_NEXT(line) = SC_NEXT(old)
		    call sc_freeedge (old)
		} else {
		    SC_NEXT(line) = sc_newedge(stop_x, val, SCSTOP, old)
		}
		return
	    } else {
		here = line
		nxt = old
		old = line
	    }
	} else {
	    here = line
	    nxt = SC_NEXT(here)
	    # advance to last edge before add
	    while( (nxt != SCNULL) && (start_x >= SC_X(nxt)) ) {
		veryold = old
		old = here
		here = nxt
		nxt = SC_NEXT(here)
	    }
	    # if last edge is a start edge
	    if( SC_TYPE(here) == SCSTART ) {
		# if last edge lines up with start of add
		if( start_x == SC_X(here) ) {
		    SC_VAL(here) = SC_VAL(here) + val
		    # if this will make two adjacent regions of the same val
		    if( (veryold != old) && (old != here) &&
			(SC_VAL(here) == SC_VAL(old)) &&
			(SC_X(here) == SC_X(old)) ) {
			# merge the two adjacent scans
			call sc_freeedge(old)
			call sc_freeedge(here)
			SC_NEXT(veryold) = nxt
			here = veryold
		    }
		# else starting add in the middle of a scan
		} else {
		    temp = sc_newedge(start_x, SC_VAL(here)+val, SCSTART, nxt)
		    SC_NEXT(here) =
		      sc_newedge(start_x, SC_VAL(here), SCSTOP, temp)
		    here = temp
		}
	    # if last edge is a stop
	    } else {
		# while would not stop at a stop with already adjacent start
		# if we would create an adjacent start of same val, merge
		if( (SC_X(here) == start_x) && (SC_VAL(here) == val) ) {
		    SC_NEXT(old) = nxt
		    call sc_freeedge (here)
		    here = old
		# else we can safely put in the first start edge
		} else {
		    SC_NEXT(here) = sc_newedge(start_x, val, SCSTART, nxt)
		    here = SC_NEXT(here)
		}
		# if add can also be finished here
		if( (nxt == SCNULL) || (stop_x <= SC_X(nxt)) ) {
		    # if this creates adjacent scans of same val, merge
		    if( (nxt != SCNULL) &&
			(stop_x == SC_X(nxt)) && (val == SC_VAL(nxt)) ) {
			SC_NEXT(here) = SC_NEXT(nxt)
			call sc_freeedge (nxt)
		    } else {
			SC_NEXT(here) = sc_newedge(stop_x, val, SCSTOP, nxt)
		    }
		    return
		}
	    }
	}
	# at this point "here" points to a start edge at the beginning of ...
	# ... the add scan, and next has an X greater than that of here.
	# walk down the line adding val to everything until we reach stop_x
	while( (nxt != SCNULL) && (stop_x > SC_X(nxt)) ) {
	    old = here
	    here = nxt
	    nxt = SC_NEXT(nxt)
	    # if this is a STOP edge ...
	    if( SC_TYPE(here) == SCSTOP ) {
		# note that scan's val was augmented by the add
		SC_VAL(here) = SC_VAL(here) + val
		# if this is the end, quit
		if( SC_X(here) == stop_x ) {
    # error
    call printf ("Add error 1\n")
		    # if this creates adjacent scans of same val, merge
		    if( (nxt != SCNULL) &&
			(SC_X(here) == SC_X(nxt)) &&
			(SC_VAL(here) == SC_VAL(nxt)) ) {
			SC_NEXT(old) = SC_NEXT(nxt)
			call sc_freeedge (here)
			call sc_freeedge (nxt)
		    }
		    return
		}
		# install a start unless stop already has a contiguous start
		if( (nxt == SCNULL) || (SC_X(nxt) > SC_X(here)) ) {
		    SC_NEXT(here) = sc_newedge(SC_X(here), val, SCSTART, nxt)
		    old = here
		    here = SC_NEXT(here)
		} else {
		    # if there is a contiguous start, augment it and move on
		    SC_VAL(nxt) = SC_VAL(nxt) + val
		    old = here
		    here = nxt
		    nxt = SC_NEXT(nxt)
		}
	    # if this is a START edge (we know it can't have a contiguous stop)
	    } else {
		# put a stop in front of the start and augment the start
		SC_NEXT(old) = sc_newedge(SC_X(here), val, SCSTOP, here)
		SC_VAL(here) = SC_VAL(here) + val
	    }
	}
	# exit'd while loop at NULL link or when next X was >= stop_x
	# if NULL link or next link is a start, end add scan and quit
	if( (nxt == SCNULL) || (SC_TYPE(nxt) == SCSTART) ) {
	    # if at the end of the line, put in stop edge
	    if( (nxt != SCNULL) &&
		(SC_X(nxt) == stop_x) && (SC_VAL(nxt) == val) ) {
		SC_NEXT(here) = SC_NEXT(nxt)
		call sc_freeedge (nxt)
	    } else {
		SC_NEXT(here) = sc_newedge(stop_x, val, SCSTOP, nxt)
	    }
	# if next link is a stop ...
	} else {
	    if( SC_X(nxt) > stop_x ) {
		temp = sc_newedge(stop_x, SC_VAL(nxt), SCSTART, nxt)
		SC_NEXT(here) =
		  sc_newedge(stop_x, SC_VAL(nxt) + val, SCSTOP, temp)
	    } else if( SC_X(nxt) == stop_x ) {
		old = here
		here = nxt
		nxt = SC_NEXT(nxt)
		# if there is a contiguous start, check for equalizing
		if( (nxt != NULL) &&
		    (stop_x == SC_X(nxt)) && (SC_VAL(nxt) == SC_VAL(old)) ) {
		    SC_NEXT(old) = SC_NEXT(nxt)
		    call sc_freeedge(here)
		    call sc_freeedge(nxt)
		} else {
		    SC_VAL(here) = SC_VAL(here) + val
		}
	    }
	}
	return
end

		
