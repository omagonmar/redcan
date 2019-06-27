#$Header: /home/pros/xray/xtiming/timlib/RCS/fld_phots.x,v 11.0 1997/11/06 16:45:02 prosb Exp $
#$Log: fld_phots.x,v $
#Revision 11.0  1997/11/06 16:45:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:48  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  12:33:38  janet
#jd - updated error calculation to pois error (pros 2.3).
#
#Revision 6.1  93/11/22  11:46:55  janet
#jd - updated exposure binning cause of bug report.
#
#Revision 6.0  93/05/24  16:58:59  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:07:38  janet
#fixed exposure binning.
#
#Revision 5.0  92/10/29  23:05:35  prosb
#General Release 2.1
#
#Revision 4.3  92/10/21  17:40:34  janet
#bugfix: updated t_exp to assign the last fractional bin ebin_frac. (was
#assigning 1.0 ... wrong).
#
#Revision 4.2  92/09/29  14:07:24  mo
#MC	9/29/92		Updated calling sequence for begs and ends rather
#			than 2 dimensional GTI's
#
#Revision 4.1  92/09/28  16:26:54  janet
#added pdot to added pdot function, reworte t_exp.
#
#Revision 4.0  92/04/27  15:35:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/23  17:52:07  janet
#recoded exposure assignment into phase bins.
#
#Revision 3.1  92/04/01  14:29:33  janet
#changes .lt. to .le. for phase check in t_srcbin, t_bkbin, t_exp
#
#Revision 3.0  91/08/02  02:02:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:18  pros
#General Release 1.0
#
# --------------------------------------------------------------------------
#
# Module:	FLD_PHOTS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Routines to Bin Source and Background photons
# External:	t_srcbin(), t_bkbin(), t_exp(), calc_phase()
# Local:	tim_getnextime()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek inital version  Jan 1987	
#		{1} Janet DePonte updated version April 1989
#		{2} JD -- April 1992 -- new exposure binning routine (t_exp).
#                                       kept old t_exp but renamed to t_exp_old.
#		{3} JD -- July 1992 -- added pdot function, reworte t_exp.
#		{n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------

include <mach.h>
include <qpset.h>
include <qpioset.h>
include <qpoe.h>
include "timing.h"
include "timstruct.h"

# --------------------------------------------------------------------------
#
# Function:	tim_srcbin
# Purpose:	read & sum 1 bin of source data
# Pre-cond:     qpoe file opened using qp_open & qpio_open.
#
# --------------------------------------------------------------------------
procedure t_srcbin (qp, start_time, ref_period, numbins, display, offset, 
                    pdot, bdata)

pointer  qp			# i: file descriptor
double   start_time		# i: start time for binning
double   ref_period             # i: reference period for current fold
int      numbins		# i: num bin intervals
int      display		# i: display level
int	 offset			# i: offset of the time element in qrec
double   pdot                   # i: pdot parameter
pointer  bdata			# i/o: ptr to binned data struct

pointer  evl			# l: event list buffer
pointer  sp                     # l: space allocation marker
int	 fldbin			# l: assigned bin for photon
int	 mval			# l: mask value returned by qpio_getevent
int	 nev			# l: num of events returned by qpio_getevent
int      qrec                   # l: current qpoe record
double   exp
double   phi
double	 phot_time		# l: photon time
double   phase
double   tref                   # l: reference time of current bin from start

bool     tim_getnxtime()

begin
        call smark (sp)
        call calloc (evl, LEN_EVBUF, TY_POINTER)
        qrec = 0
        nev = 0

#   Bin Source photons into current bin 
	while ( tim_getnxtime (qp,mval,nev,Memi[evl],qrec,offset,phot_time)){

#   determine which bin the photon belongs in, put photons that fall
#   on the edges (have phase = 0) into bin 1.
           tref = phot_time - start_time
           call calc_phase (ref_period, pdot, tref, display, phase, phi, exp)

           fldbin = int(phi*double(numbins) + 1.0D0 + EPSILOND)
           if ( fldbin == numbins+1 ) {
              fldbin = 1
           }

	   if ( display >= 5 ) {
              call printf("%d, phot_time= %15.4f, bin = %d\n")
                call pargi (qrec)
                call pargd (phot_time)
                call pargi (fldbin)
	   }

	   if ( fldbin > numbins ) {		
              call eprintf ("Src bin %d not within range, time= %.5f\n")
                call pargi (fldbin)
                call pargd (phot_time)

	   } else {
	      SRC(bdata,fldbin) = SRC(bdata,fldbin) + 1.0
	   }
	}
        call sfree(sp)

end

# --------------------------------------------------------------------------
#
# Function:	tim_bkbin
# Purpose:	read & sum 1 bin of background data
# Pre-cond:     qpoe file opened using qp_open & qpio_open.
#
# ------------------------------------------------------------------------
procedure  t_bkbin (qp, start_time, ref_period, numbins, display, 
			offset, pdot, bdata)

pointer  qp			# i: file descriptor
double   start_time		# i: start time for binning
double   ref_period		# i: duration of single bin
int      numbins
int      display		# i: display level
int	 offset			# i: offset of the time element
double   pdot                   # i: pdot parameter
pointer  bdata

pointer  evl			# l: event list buffer
pointer  sp                     # l: space allocation marker
int	 fldbin			# l: assigned bin for photon
int	 mval			# l: mask value returned by qpio_getevent
int	 nev			# l: num of events returned by qpio_getevent
int      qrec                   # i/o: current qpoe record
double	 phot_time		# l: photon time
double   phi
double   phase
double   tref                   # l: reference time of current bin from start
double   exp

bool     tim_getnxtime()


begin

        call smark (sp)
        call calloc (evl, LEN_EVBUF, TY_POINTER)
        nev = 0
        qrec = 0

#   Bin Bkgd photons into current bin 
	while (tim_getnxtime (qp,mval,nev,Memi[evl],qrec,offset,phot_time)){

	   if ( phot_time >= start_time ) {

              tref = phot_time - start_time
              call calc_phase (ref_period, pdot, tref, display, phase, phi, exp)

              fldbin = int(phi*double(numbins) + 1.0D0 + EPSILOND)
              if ( fldbin == numbins+1 ) {
                fldbin = 1
              }

	      if ( fldbin > numbins ) {		
                 call eprintf ("Bk bin %d not within range, time= %.5f\n")
                   call pargi (fldbin)
                   call pargd (phot_time)

	      } else {
	         BK(bdata,fldbin) = BK(bdata,fldbin) + 1.0

	      }
	   }
	}
        call sfree(sp)

end

# -------------------------------------------------------------------------
procedure  t_exp (display, num_intvs, start_time, stop_time, gbegs, gends,
                  numbins, ref_period, pdot, bdata)

int      display                        # i: display level
int      num_intvs                      # i: number of intervals
double   start_time                     # i: first time of timing data
double   stop_time                      # i: first time of timing data
double   gbegs[ARB]                   # i: intervals buffer
double   gends[ARB]                   # i: intervals buffer
int      numbins                        # i: number of bins
double   ref_period                     # i: bin size in secs
double   pdot                           # i: pdot parameter
pointer  bdata                          # i: ptr to bin data struct

int      i, j                           # l: loop counter
int      sbin, ebin			# l: start & end bin
int      phasecnt			# l: phase tally for bins
int      num_phases			# l: num phases for current gintv

double   binexp				# l: exposure in 1 bin
#double   binfrac			# l: phase assignment for bin
double   binsize			# l: bin size as frac on 1
double   ebin_frac			# l: bin assignment for end of gintv
double   ephase         		# l: end phase of period
double   ephi             		# l: end phase bin
double   eexp				# l: period of end gintv
double   exposure			# l: bin time assignment
double   sbin_frac			# l: bin assignment for end start of gintv
double   sphase				# l: start phase of period
double   sphi				# l: start phase bin
double   sexp				# l: period of start gintv
double   tdiff				# l: time difference from start
double   totexp                         # l: total exposure over all bins

bool     clgetb()

pointer  temp
pointer  sp

begin

        binsize = 1.0d0 / double ( numbins )
        phasecnt = 0
        totexp = 0.0d0

	call smark (sp)
        call salloc (temp, numbins, TY_DOUBLE)

        if ( clgetb(GETGOODINTV) ) {

	   do i = 1, num_intvs {
	      
#   Initialize the array of phase tallies for the current gintv
              call aclrd (Memd[temp], numbins)

#   compute the phase at the start of the current good interval
	      tdiff = gbegs[i] - start_time
              call calc_phase (ref_period, pdot, tdiff, display, 
			       sphase, sphi, sexp)

#   compute the phase at the end of the current good interval
	      tdiff = gends[i] - start_time
              call calc_phase (ref_period, pdot, tdiff, display, 
			       ephase, ephi, eexp)

#   compute the number of complete phases
	      num_phases = int (ephase) - int(sphase) - 1

#   determine the partial bin at the start of the exposure interval
	      sbin = int ( sphi / binsize ) + 1
	      sbin_frac = (binsize - dmod ( sphi, binsize)) / binsize

              if ( display >= 3 ) {
                 call printf ("sbin=%d, sbin_frac=%.3f\n")
                   call pargi (sbin)
                   call pargd (sbin_frac)
              }

#   determine the partial bin at the end of the exposure interval
	      ebin = int ( ephi / binsize ) + 1
	      ebin_frac = dmod (ephi, binsize) / binsize

              if ( display >= 3 ) {
                 call printf ("ebin=%d, ebin_frac=%.3f\n")
                   call pargi (ebin)
                   call pargd (ebin_frac)
                 call printf ("Num_phases= %d\n")
	           call pargi (num_phases)
              }

#   check whether the exposure is within 1 phase
	      if ( num_phases <= 0 ) {
		
#   check whether the exposure is within 1 bin of 1 phase
		if ( sbin == ebin && num_phases < 0 ) {

                    if ( sbin_frac > EPSILONR ) {
                       Memd[temp+sbin-1] = Memd[temp+sbin-1] + 
                                           ebin_frac-(1.0d0-sbin_frac)
	            } else {
                       Memd[temp+sbin-1] = Memd[temp+sbin-1] + ebin_frac
		    }

		} else { 

                   Memd[temp+sbin-1] = Memd[temp+sbin-1] + sbin_frac
                   Memd[temp+ebin-1] = Memd[temp+ebin-1] + ebin_frac

#   if we have less than 1 phase bin of data to assign ...
#   ... we assign exposure from the start to end within the same phase
                   if ( sbin < ebin && num_phases < 0 ) {

                      do j = sbin+1, ebin-1 {
                         Memd[temp+j-1] = Memd[temp+j-1] + 1.0d0
                      }

                   } else {

                      do j = sbin+1, numbins {
                         Memd[temp+j-1] = Memd[temp+j-1] + 1.0d0
                      }
                      do j = 1, ebin-1 {
                         Memd[temp+j-1] = Memd[temp+j-1] + 1.0d0
                      }
                   }
		}
                if ( num_phases < 0 ) {
                   num_phases = 0
                }

#   if we have exposure to assign to > 1 phase, then the start goes
#   to the end of the phase.
	      } else {

#   Assign partial bin ...
                 Memd[temp+sbin-1] = Memd[temp+sbin-1] + sbin_frac

#   ... then assign 1 to reset of bins in the phase
	         do j = sbin+1, numbins {
                    Memd[temp+j-1] = Memd[temp+j-1] + 1.0d0
	         }

		 if ( display >= 4 ) {
                    call printf ("Start: EXP[%d] = %f\n")
                      call pargi (sbin)
                      call pargd (sbin_frac) 
                    call printf ("       EXP[%d:%d] = 1.0d0\n")
                       call pargi (sbin+1)
                       call pargi (numbins)
	         }

#   and the end exposure starts at the beginning and goes to the stop
#   Assign 1 to bins in the phase ...
	         do j = 1, ebin-1 {
                    Memd[temp+j-1] = Memd[temp+j-1] + 1.0d0
	         }

#   ... up to end bin where we assign a partial bin  
                 Memd[temp+ebin-1] = Memd[temp+ebin-1] + ebin_frac

		 if ( display >= 4 ) {
                    call printf ("End:   EXP[1:%d] = 1.0d0\n")
                       call pargi (ebin-1)
                    call printf ("       EXP[%d] = %f\n")
		      call pargi (ebin)
                      call pargd (ebin_frac)
	         }

	      }
#   Sum complete phases and add to the exposure at end of gintv scan
              binexp = sexp / double (numbins)
              do j = 1, numbins {
                 exposure = (Memd[temp+j-1]+num_phases)*binexp
                 EXP(bdata,j) = EXP(bdata,j) + exposure 
	         totexp = totexp + exposure
              }
	   }
           if ( display >= 3 ) {
              call printf ("binexp= %.3f\n")
                 call pargd (binexp)
              do j = 1, numbins {
                 call printf ("bin=%d, EXP= %f\n")
                    call pargi (j)
                    call pargr (EXP(bdata,j))
                 call flush (STDOUT)
	      }
	   }

#   No gintvs - Assign even exposure across all bins 
	} else {
           totexp = gends[num_intvs] - gbegs[1]
           binexp = totexp / double ( numbins )
           do i = 1, numbins {
	      EXP(bdata,i) = binexp
	   }
	}

        if ( display >= 2 ) {
           call printf ("totexp = %f\n")
             call pargd (totexp)
        }

        call sfree(sp)

end

# -------------------------------------------------------------------------
procedure calc_phase (ref_period, pdot, tdiff, display, phase, phi, exp)

double   ref_period                     # i: bin size in secs
double   pdot                           # i: pdot parameter
double   tdiff				# i: time offset from start
int      display
double   phase				# o: computed phase
double   phi				# o: fractional place in phase
double   exp

begin

#       phase = tdiff/ref_period + pdot * tdiff

#   compute exposure of current phase
        exp = ref_period + pdot * tdiff

#   compute phase
        phase = (tdiff/ref_period) + 
                 0.5 * (-1.0d0*pdot/ref_period**2) * (tdiff**2)

#   compute phi ... the fractional position within the phase
	phi = dmod (phase, 1.0d0)
        if ( phi .lt. 0.0d0 ) phi = phi + 1.0d0

	if ( display >= 5 ) {
	   call printf ("phase = %.4f, phi = %.4f, exp = %.4f\n")
             call pargd (phase)
             call pargd (phi)
             call pargd (exp)
	}
end
# -------------------------------------------------------------------------
