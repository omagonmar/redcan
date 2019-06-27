#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_binphots.x,v 11.0 1997/11/06 16:45:10 prosb Exp $
#$Log: tim_binphots.x,v $
#Revision 11.0  1997/11/06 16:45:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:09  prosb
#General Release 2.3
#
#Revision 6.1  93/07/16  14:25:22  janet
#jd - true/false updates for release, also removed tim_getnxtime from '&&' conditional.
#
#Revision 6.0  93/05/24  16:59:22  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:10:23  janet
#jd - changed bin_length to a double in all timing procedures.
#
#Revision 5.0  92/10/29  23:05:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:36:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:02:28  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:39  pros
#General Release 1.0
#
# --------------------------------------------------------------------------
#
# Module:	TIM_BINPHOTS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Routines to Bin Source and Background photons
# External:	tim_srcbin(), tim_bkbin()
# Local:	tim_getnextime()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek inital version  Jan 1987	
#		{1} Janet DePonte updated version April 1989
#		{n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------

include <mach.h>
include <qpset.h>
include <qpioset.h>
include "timing.h"
include <qpoe.h>

# --------------------------------------------------------------------------
#
# Function:	tim_srcbin
# Purpose:	read & sum 1 bin of source data
# Pre-cond:     qpoe file opened using qp_open & qpio_open.
#
# --------------------------------------------------------------------------
procedure  tim_srcbin (qp, start_time, bin_length, curbin, display, 
		       qrec, offset, tally)

pointer  qp			# i: file descriptor
double   start_time		# i: start time for binning
double   bin_length		# i: duration of single bin
int	 curbin			# i: current bin number
int      display		# i: display level
int      qrec                   # i/o: current qpoe record
int	 offset			# i: offset of the time element in qrec
real	 tally			# o: photon total for this bin


double	 phot_time		# l: photon time
int	 bin			# l: assigned bin for photon
int	 mval			# l: mask value returned by qpio_getevent
int	 nev			# l: num of events returned by qpio_getevent
pointer  evl			# l: event list buffer
pointer  sp			# l: space alloc pointer
bool     qp_eof                 # l: eof qpoe indicator

bool     tim_getnxtime()

begin

	bin = 0
	tally = 0.0
	qp_eof = FALSE

#   Must initialize the photon pointer the first time
	if( curbin == 1 ){
            call smark (sp)
            call calloc (evl, LEN_EVBUF, TY_POINTER)
	    nev = 0
	    qrec = 0
	}
#   Bin Source photons into current bin 
        while (bin <= curbin && !qp_eof ) {

	   if (tim_getnxtime (qp,mval,nev,Memi[evl],qrec,offset,phot_time)) {

	      bin = nint(((phot_time-start_time)/bin_length + 0.5) + EPSILOND)

	      if ( bin < curbin ) {		
	         call error(1,"Source Bin smaller than prev bin")

	      } else if ( bin == curbin )  {
	         tally = tally + 1.0

# Set qpoe rec back 1 so we can get this one next time
	      } else if ( bin > curbin ) {  
	         qrec = qrec - 1
	      }
	   } else {
	      qp_eof = TRUE
              call sfree (sp)
	   }
	}

end

# --------------------------------------------------------------------------
#
# Function:	tim_bkbin
# Purpose:	read & sum 1 bin of background data
# Pre-cond:     qpoe file opened using qp_open & qpio_open.
#
# ------------------------------------------------------------------------
procedure  tim_bkbin (qp, start_time, bin_length,curbin, display, 
		      qrec, offset, tally)

pointer  qp			# i: file descriptor
double   start_time		# i: start time for binning
double   bin_length		# i: duration of single bin
int	 curbin			# i: current bin number
int      display		# i: display level
int      qrec                   # i/o: current qpoe record
int	 offset			# i: offset of the time element
real	 tally			# o: photon total for this bin

double	 phot_time		# l: photon time
int	 bin			# l: assigned bin for photon
int	 mval			# l: mask value returned by qpio_getevent
int	 nev			# l: num of events returned by qpio_getevent
pointer  evl                    # l: event list buffer
pointer  sp			# l: space alloc pointer
bool     qp_eof                 # l: eof qpoe indicator

bool     tim_getnxtime()

begin

	bin = 0
	tally = 0.0
        qp_eof = FALSE

#   Must initialize the photon pointer the first time
	if( curbin == 1 ){
            call smark (sp)
            call calloc (evl, LEN_EVBUF, TY_POINTER)
	    nev = 0
	    qrec = 0
	}
#   Bin Bkgd photons into current bin 
        while ( bin <= curbin && !qp_eof ) {
           if (tim_getnxtime (qp,mval,nev,Memi[evl],qrec,offset,phot_time) ) {
# *** quick fix ***
	      if ( phot_time >= start_time ) {
	         bin = nint(((phot_time-start_time)/bin_length + 0.5)+EPSILOND)

	         if (bin < curbin ) {
	            call error(1,"Bkgd Bin smaller than prev bin")
	         } else if ( bin == curbin )  {
	            tally = tally + 1.0
# Set qpoe rec back 1 so we can get this one next time
	         } else if ( bin > curbin ) {
	            qrec = qrec - 1
	         }
	      }
	   } else {
	      qp_eof = TRUE
              call sfree (sp)
           }
	}
end

# --------------------------------------------------------------------------
#
# Function:	tim_getnexttime
# Purpose:	read the next qpoe record and return the time 
# Uses:		qpoe library
#
# --------------------------------------------------------------------------
bool procedure tim_getnxtime (io, mval, nev, evl, crec, offset, time)

pointer io			# i: event list handle
int     mval 			# i: mask value returned by qpio_getevent
int 	nev			# i: number of events returned by qpio_getevent
pointer evl[ARB]		# i: event list buffer
int  	crec			# i/o: current record pointer
int	offset			# i: offset of time element
double  time			# o: photon event time

int     qpio_getevents()

begin

	if ( crec >= nev ) {
#   Get another bucket of photons
	   if (qpio_getevents(io, evl, mval, LEN_EVBUF, nev) == EOF) {
	      return (FALSE)
	   } else {
#   Reinit pointer to start of the buffer
	      crec = 1
    	   }
	} else {
#   Point to next record
	     crec = crec + 1
	}
#   Copy out the time
	time = Memd[(evl[crec]+offset-1)/SZ_DOUBLE+1]
	return(TRUE)

end
