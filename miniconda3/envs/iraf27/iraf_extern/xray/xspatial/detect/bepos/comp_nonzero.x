# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/comp_nonzero.x,v 11.0 1997/11/06 16:32:04 prosb Exp $
# $Log: comp_nonzero.x,v $
# Revision 11.0  1997/11/06 16:32:04  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:51  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:26  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:45  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  10:54:45  janet
#Initial revision
#
#
# Module:       comp_nonzero.x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	calculate the probability source nonzero statistic 
#		for the best pos
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

procedure comp_nonzero (bin_coords, cnts_in_bin, windo_dim, src_windo, 
		b_to_s_factor, bin_efficiency, bin_radius, c0_final, 
		e_bepos_xy, src_sigma, s0_final, prob_src_nonzero)

int	bin_coords[ARB]		  # i: x & y bin coords
int	cnts_in_bin 		  # i: num cts in bin circle
int	windo_dim 		  # i: dim of src windo
int	src_windo[windo_dim,ARB]  # i: poe file photons

real	b_to_s_factor 		# i: b/s factor
real	bin_efficiency    	# i: calculated bin efficiency
real	bin_radius 		# i: radius of bin circle
real	c0_final 		# i: final c-statistic value
real	e_bepos_xy[ARB]		# i: best pos in element coords
real	src_sigma 		# i: calculated point resp sigma
real	s0_final 		# i: final source counts

real	prob_src_nonzero 	# o: statistical probabiity src is nonzero

real	b_to_s 			# l: b/s ratio
real	delta_c 		# l: calc change in c-statistic
real	cstat_sum_term 		# l: sum term for cstat
real	new_c0 			# l: computed c-statistic 
real	s0_small 		# l: small src cnts value
real	trial_b0 		# l: trial bkgd counts

begin

#   set to a small value
      s0_small = 0.1

#   compute bkgd amplitude
      trial_b0 = cnts_in_bin - (s0_small * bin_efficiency)

#   compute new b/s based on new values of b and s
      b_to_s = b_to_s_factor * trial_b0 / s0_small

#   compute the c-statistic minimum value based on the current inputs
      call cstat_terms (bin_coords, windo_dim, src_windo, b_to_s, bin_radius, 
		        e_bepos_xy, src_sigma, cstat_sum_term)

      call calc_ncstat (cnts_in_bin, cstat_sum_term, src_sigma, s0_small, 
		        new_c0)

#   compute the resulting change in the c-statistic
      delta_c = abs (2.0 * (c0_final - new_c0))

#   and map this value of delta c through avni's delc vs. probability curve
#   to get the probability that the source is nonzero.  the mapping is done
#   using a quadratic exponential approximation to the monte carlo results
#   presented in avni(1976),ap.j.,210,642.

      if ( delta_c < 10.0 ) {
         prob_src_nonzero =
         1.0 - exp(delta_c*(delta_c*(0.2642 - 0.024 * delta_c) - 1.389))

      } else {
         prob_src_nonzero = 1.0

      }

end
