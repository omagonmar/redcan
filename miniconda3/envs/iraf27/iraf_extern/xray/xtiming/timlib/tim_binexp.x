#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_binexp.x,v 11.0 1997/11/06 16:45:09 prosb Exp $
#$Log: tim_binexp.x,v $
#Revision 11.0  1997/11/06 16:45:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:05:51  prosb
#General Release 2.1
#
#Revision 4.1  92/10/08  09:11:56  mo
#MC	10/8/92		Fixed the GINTVS calling sequence to use 2 arrays
#			instead of 1 2-D array
#
#Revision 4.0  92/04/27  15:36:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:02:27  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:35  pros
#General Release 1.0
#
# ---------------------------------------------------------------------------
#
# Module:	TIM_BINEXP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to bin exposure and return the exposure for 1 bin
# External:	tim_binexp()
# Local:	aligngap(), next_gap()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:     {0} Adam Szczypek inital version  Jan 1987	
#		{1} Janet DePonte updated version April 1989
#		{n} <who> -- <does what> -- <when>
# ---------------------------------------------------------------------------

include  <mach.h>
include	 "timing.h"

# ---------------------------------------------------------------------------
#
# Function:	tim_binexp
# Purpose:	return a bin of exposure seconds aligned with the photon data
# Description:	Compare gap boundaries and bin boundaries to determine 
#               the length of exposure time for the bin.
#
# ---------------------------------------------------------------------------
procedure  tim_binexp (display, num_intvs, qp, start_bin, stop_bin, 
		       gbegs, gends, exposure, totexp)

int      display			# i: display level
int      num_intvs			# i: number of intervals
pointer  qp				# i: qpoe file descriptor
double   start_bin			# i: first time of timing data
double   stop_bin			# i: first time of timing data
double   gbegs[ARB]			# i: intervals buffer
double   gends[ARB]			# i: intervals buffer
real	 exposure			# o: seconds of exposure in 1 bin
real	 totexp				# o: total exposure over all bins

bool	 done				# l: flag whether bin exposure computed
double	 start_gap,  stop_gap		# l: begin and end of data interval
int      gap

int      aligngap()

begin

	if ( num_intvs > 0 ) {
	    exposure = 0.0
	    gap = 0
	    start_gap = -1.0
	    stop_gap  = -1.0
	    done = FALSE

	    while ( !done )  {
    	       switch (aligngap (start_gap,stop_gap,start_bin,stop_bin)) {
		  case 0:		#  gap after bin
		     done = TRUE

		  case 1:		#  bin entirely before gap
		     call next_gap (display, gap, gbegs, gends, num_intvs, 
				    start_gap, stop_gap)

		  case 2:		#  bin entirely in gap
		     exposure = stop_bin - start_bin
		     done = TRUE

		  case 3:		# bin starts before & ends in bin
		     exposure = exposure + (stop_gap-start_bin)
		     call next_gap (display, gap, gbegs, gends, num_intvs, 
				    start_gap, stop_gap)

		  case 4: 	        #  gap lies entirely in the bin
		     exposure = exposure + (stop_gap-start_gap)
		     call next_gap (display, gap, gbegs, gends, num_intvs, 
				    start_gap, stop_gap)

		  case 5: 	        #  gap starts in bin & ends afterwards
		     exposure = exposure + (stop_bin-start_gap)
		     done = TRUE
	       }
	    }
	    totexp = totexp + exposure
	}
end

# ---------------------------------------------------------------------------
#
# Function:	aligngap
# Purpose:	Return alignment code indicating relationship between intvs
# Description:	Compare gap boundaries to bin boundaries and determine 
#               where the gap boundaries lie in relation to the bin.  
#		Return code to indicate their position.
# Notes: 	Alignment Codes & definition:
#			0 -> gap lies entirely after bin 
#			1 -> gap lies entirely before bin 
#			2 -> bin lies entirely in gap 
#			3 -> gap starts before bin & ends in bin 
#			4 -> gap lies entirely in bin 
#			5 -> gap starts in bin & ends after
#
# ---------------------------------------------------------------------------
int  procedure  aligngap ( start_gap, stop_gap, start_bin, stop_bin)

double	 start_gap,  stop_gap		#  begin & end time of data interval
double   start_bin,  stop_bin		#  begin & end time of bin
int	 alignment

begin
	if ( start_gap >= stop_bin ) {
	   alignment = 0		#  gap lies entirely after bin

	} else if ( start_gap >= start_bin )  {

	   if ( stop_gap > stop_bin ) {
	      alignment = 5		#  gap starts in bin & ends after
	   } else {
	      alignment = 4		#  gap lies entirely in the bin
	   }

	} else if ( stop_gap > start_bin )  {

	   if ( stop_gap > stop_bin ) {
	      alignment = 2		#  bin lies entirely in the gap
	   } else {
	      alignment = 3		#  gap starts before bin & ends in bin
	   }

        } else {
	   alignment = 1		#  gap lies entirely before 
					#     the bin
	}
	return (alignment)
end


# ---------------------------------------------------------------------------
#
# Function:	next_gap
# Purpose:	return the next gap from the buffer of time pairs
#
# ---------------------------------------------------------------------------
procedure  next_gap (display, gap, btimes, etimes, ntimes, start_gap, stop_gap )

int	 display			# i: display level
int	 gap 				# i: array ptr to current intv
double   btimes[ARB]			# i: interval times
double   etimes[ARB]			# i: interval times
int      ntimes				# i: number of time pairs in buffer
double	 start_gap,  stop_gap		# o: begin & end of interval time

begin

	gap = gap + 1
	if ( gap <= ntimes )  {
	    start_gap = btimes[gap]
	    stop_gap = etimes[gap]
	} else  {
	    start_gap = MAX_REAL
	    stop_gap  = MAX_REAL
	}

	if ( display >= 4 ) {
	   call printf ("intv start = %f, stop = %f\n")
	    call pargd(start_gap)
	    call pargd(stop_gap)
	}

end

