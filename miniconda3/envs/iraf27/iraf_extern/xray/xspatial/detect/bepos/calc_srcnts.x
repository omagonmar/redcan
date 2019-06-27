# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calc_srcnts.x,v 11.0 1997/11/06 16:31:57 prosb Exp $
# $Log: calc_srcnts.x,v $
# Revision 11.0  1997/11/06 16:31:57  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:39  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:59  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:52:14  janet
#updated debug to accomodate xexamine level.
#
#Revision 5.0  92/10/29  21:31:23  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:15:21  janet
#Initial revision
#
#
# Module:       calc_srcnts.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      calculate the source counts
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 10/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------
# calc_srcnts
# --------------------------------------------------------------------------
procedure calc_srcnts (debug, cnts_in_bin, bin_efficiency, sum_of_wxy, 
     		       trial_s0, new_trial_s0)

#    Inputs:
int     debug                   # debug level
int 	cnts_in_bin		# total photons in bin circle

real	bin_efficiency          # fraction of src falling in bin circle
real	sum_of_wxy		# eq term
real	trial_s0		# trial source counts

#    Outputs:
real	new_trial_s0		# new trial source counts

begin

#   for debugging purposes, we need to know if the sums for Wxy are larger
#   than the # of photons in the bin_size, or smaller than 0.  In either
#   case a kludge is used to help out the convergence.

      if ( debug >= 5 && debug != 10 ) {
         call printf ("cnts_in_bin=%d, sum_of_wxy=%f, trial_s0=%f\n")
           call pargi (cnts_in_bin)
           call pargr (sum_of_wxy)
           call pargr (trial_s0)
      }

      if ( sum_of_wxy > cnts_in_bin ) {
	 new_trial_s0 = sum_of_wxy / bin_efficiency
         call printf ("Warning - Weight to high! - new_trial_s0=%f, sum_of_wxy=%f\n")
	    call pargr(new_trial_s0)
	    call pargr(sum_of_wxy)


      }  else if ( sum_of_wxy < 0 ) {
         new_trial_s0 = trial_s0 * 2 - (sum_of_wxy / bin_efficiency)
         call printf ("Warning - Weight to low! - new_trial_s0=%f, sum_of_wxy=%f\n")
	    call pargr(new_trial_s0)
	    call pargr(sum_of_wxy)

#   just right
      } else {
         new_trial_s0 = sum_of_wxy / bin_efficiency
      }

end
