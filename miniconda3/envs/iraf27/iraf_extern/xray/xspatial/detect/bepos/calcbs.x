# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calcbs.x,v 11.0 1997/11/06 16:31:58 prosb Exp $
# $Log: calcbs.x,v $
# Revision 11.0  1997/11/06 16:31:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:40  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:02  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:52:43  janet
#included xexamine debug level in printout conditional.
#
#Revision 5.0  92/10/29  21:31:25  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:17:08  janet
#Initial revision
#
#
# Module:       calcbs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      calculate the best source position
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 10/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"

# ---------------------------------------------------------------------
# calculate the best source position
# ---------------------------------------------------------------------

procedure calcbs ( debug, max_iter, windo_dim, src_windo, b_to_s_factor, 
		   bin_efficiency, bin_radius, conv_epsilon, e_rough_xy, 
                   init_b0, init_c0, init_s0, src_sigma, bin_coords, 
                   cnts_in_bin, hit_max_iter, out_of_bnds, c0_final, 
                   e_bepos_xy, s0_final)

int	debug 			 # i: debug level
int	max_iter 		 # i: max iteration for convergence
int	windo_dim 		 # i: dimension of src_windo
int	src_windo[windo_dim,ARB] # i: photon arr around rpos at zm 1

real	b_to_s_factor 		# i: b/s factor
real	bin_efficiency 		# i: calculated bin efficiency
real	bin_radius 		# i: radius of bin circle
real	conv_epsilon[ARB] 	# i: convergence tolerance for cs
real	e_rough_xy[ARB] 	# i: rough pos in array element coords
real	init_b0 		# i: initial src bkgd cnts
real	init_c0 		# i: initial c-statistic
real	init_s0 		# i: initial src cnts
real	src_sigma 		# i: calculated pt response sigma

int	bin_coords[2,ARB] 	# o: array coords of bin circle
int	cnts_in_bin  		# o: cnts in bin circle

bool    hit_max_iter 		# o: indicates if max iterations hit
bool    out_of_bnds 		# o: indicates if out of array bnds

real	c0_final 		# o: final c-statistic
real	e_bepos_xy[ARB]		# o: best pos in element coords
real	s0_final 		# o: final src cnts


int	half_bin_size[2]        # half of the bin size
int     num_of_iter 		# tallies # of iterations

bool    searching_for_bepos 	# indicates if bepos found

real	b_to_s 			# b/s ratio
real	change_in_c 		# change in c0
real	change_in_s 		# change in s0
real	cstat_sum_term
real	b0_new_trial
real	c0_new_trial		# new trial cstatistic
real	s0_new_trial		# new trial src counts
real	new_trial_xy[2] 	# new trial xy pos
real	b0_trial		# trial bkgd cnts
real	c0_trial		# trial cstatistic
real	s0_trial		# trial src cnts
real	trial_xy[2] 		# trial xy pos
real	sum_wxy 		# est pos term
real	sum_xy[2] 		# est pos term

begin

#   init variables
      hit_max_iter = false
      searching_for_bepos = TRUE
      e_bepos_xy[x] = 0.0
      e_bepos_xy[y] = 0.0
      num_of_iter = 0
      half_bin_size[x] = bin_radius
      half_bin_size[y] = bin_radius

#   init trial variables
      new_trial_xy[x] = e_rough_xy[x]
      new_trial_xy[y] = e_rough_xy[y]
      c0_new_trial = init_c0
      b0_new_trial = init_b0
      s0_new_trial = init_s0

      do while ( searching_for_bepos ) { 

         num_of_iter = num_of_iter + 1
         trial_xy[x] = new_trial_xy[x]
         trial_xy[y] = new_trial_xy[y]
         c0_trial = c0_new_trial
         b0_trial = b0_new_trial
         s0_trial = s0_new_trial

#   compute bin coords of window around the trial position
         call minmax_coords (half_bin_size, windo_dim, trial_xy, 
                             bin_coords, out_of_bnds)

         if ( ! out_of_bnds ) {

#     so we don't div-by-0
            if ( s0_trial <= 0.0 ) {
                s0_trial = 1.0
	    }
            b_to_s = b_to_s_factor * b0_trial / s0_trial

#   minimize the equation terms
            call comp_eqsums (bin_coords, debug, windo_dim, src_windo, 
		     b_to_s, bin_radius, src_sigma, trial_xy, cnts_in_bin, 
		     cstat_sum_term, sum_wxy, sum_xy)

            if ( cnts_in_bin > 0 ) {

#   calculate new trial positions
               new_trial_xy[x] = sum_xy[x] / sum_wxy
               new_trial_xy[y] = sum_xy[y] / sum_wxy

#   calculate the new src cnts based on current parameters and compute the
#   change since the last pass
               call calcss (debug, cnts_in_bin, bin_efficiency, sum_wxy, 
			    s0_trial, s0_new_trial)

               change_in_s = abs (s0_new_trial - s0_trial)

#   calculate the c-statistic based on current parameters and compute the
#   change since the last pass
               call calc_ncstat (cnts_in_bin, cstat_sum_term, src_sigma, 
                                s0_trial, c0_new_trial)

               change_in_c = 2.0 * (c0_new_trial - c0_trial)

               if ( debug > 3 && debug != 10 ) {

 		  call printf (" %2d %5d %8.2f %8.2f\n")
		     call pargi (num_of_iter)
		     call pargi (cnts_in_bin)
		     call pargr (new_trial_xy[x])
		     call pargr (new_trial_xy[y])
                  call printf (" %10.3f %10.3f %10.3f %10.3f\n")
		     call pargr (s0_new_trial)
		     call pargr (c0_new_trial)
		     call pargr (change_in_s)
		     call pargr (change_in_c)
               }

               if ( num_of_iter > max_iter ) {
                  searching_for_bepos = FALSE
                  hit_max_iter = TRUE
               } else {
                  if ( ( abs(change_in_c) <= conv_epsilon[c]) ||
                       ( abs(change_in_s) <= conv_epsilon[s] ) ) {
                     searching_for_bepos = FALSE
                  }
               }
            } else {
               searching_for_bepos = FALSE
            }
         } else {
            searching_for_bepos = FALSE
         }
      }

      if ( ! out_of_bnds ) {
         e_bepos_xy[x] = new_trial_xy[x]
         e_bepos_xy[y] = new_trial_xy[y]
         c0_final = c0_new_trial
         s0_final = s0_new_trial
      }

      end
