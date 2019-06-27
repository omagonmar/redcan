# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calc_ncstat.x,v 11.0 1997/11/06 16:31:54 prosb Exp $
# $Log: calc_ncstat.x,v $
# Revision 11.0  1997/11/06 16:31:54  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:35  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:18  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:10:58  janet
#Initial revision
#
#
# Module:       calc_nstat.x 
# Project:      PROS -- ROSAT RSDC
# Purpose:      calculate the c-statistic given the current values
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 10/92 
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include <mach.h>
include <math.h>

# ---------------------------------------------------------------------------
# calculate the c-statistic given the current values
# ---------------------------------------------------------------------------

procedure calc_ncstat (cnts_in_bin, cstat_sum_term, src_sigma, trial_s0, 
                       new_c0)

int 	cnts_in_bin		# i: cnts in the bin

real 	cstat_sum_term 		# i: running sum for cstat
real	trial_s0 		# i: trial src cnts
real	src_sigma 		# i: source sigma
real	new_c0 			# o: new c-statistic

real	log_of_s0 		# l: log of src cnts

begin

#   avoid alog error in case s0 is 0
      if ( trial_s0 != 0.0 ) {
         log_of_s0 = alog(abs(trial_s0 / (2 * PI * src_sigma**2) ))
      } else {
         log_of_s0 = - MAX_REAL
      }

#   calculate new c-statistic using current values  -  cstat_sum_term
      new_c0 = cstat_sum_term + ( cnts_in_bin * log_of_s0 )

end
