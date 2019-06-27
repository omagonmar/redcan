# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/posconf.x,v 11.0 1997/11/06 16:32:07 prosb Exp $
# $Log: posconf.x,v $
# Revision 11.0  1997/11/06 16:32:07  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:51:01  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:17:49  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:32:02  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  11:10:02  janet
#Initial revision
#
#
# Module:       posconf.x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	compute the confidence in the computed best position
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"

# ------------------------------------------------------------------
procedure posconf (bin_coords, cnts_in_bin, debug, max_conf_iter, 
		num_of_conf, windo_dim, src_windo, b_to_s, bin_radius, 
		c0_final, conf_levels, e_bepos_xy, src_sigma, s0_final, 
		conf_with_pos, pos_confidences)

int	bin_coords[ARB]		# i: coords of bin area 
int	cnts_in_bin 		# i: counts in the bin circle
int	debug 			# i: debug level
int	max_conf_iter 		# i: max # of confidence iterations
int	num_of_conf 		# i: num of confidence levels
int	windo_dim 		# i: src windo dimension
int	src_windo[windo_dim,ARB] # i: array of photons from poe

real	b_to_s 			# i: b/s ratio
real	bin_radius 		# i: bin circle radius
real	c0_final 		# i: final c-statistic
real	conf_levels[ARB]	# i: levels to get confidence values for
real	e_bepos_xy[ARB]		# i: best position in array element coords
real	src_sigma 		# i: computed pt resp sigma
real	s0_final 		# i: final src counts

bool	conf_with_pos 		# o: indicates whether there'e confidence 
				#    in the pos

real	pos_confidences[ARB]	# o: returned computed confidences 


int	conf_iters 		# num iterations to compute confidence
int	cptr 			# confidence array pointer
int	direction 		# code for pos or neg, x or y dir

bool	conf_iter_ok 		# indicates if max_conf_iter reached 
bool	more_conf_to_calc 	# indicates if there are more confidences 
			        # to calculate
bool	more_dir_to_chk 	# indicates if we've run over all directions
bool	quad_conf_ok 		# indicates if quad conf .gt. 0

real	c0_new 			# newly calc c-statistic
real	conf_dif 		# confidence difference
real	cur_conf 		# current confidence being calculated
real	delta_c 		# change in the c-statistc value
real	cstat_sum_term 		# running sum for cstat 
real	prev_conf_dif 		# confidence difference of prev loop
real	quadconf[4,10] 		# quadrant confidences
real	trial_xy[2]             # trial x & y position


begin

      direction = 0
      more_dir_to_chk = TRUE
      conf_iter_ok = TRUE
      quad_conf_ok = TRUE

      do while ( more_dir_to_chk ) {

         direction = direction + 1
         trial_xy[x] = e_bepos_xy[x]
         trial_xy[y] = e_bepos_xy[y]

         more_conf_to_calc = TRUE
         cptr = 0

         do while ( more_conf_to_calc ) {

            cptr = cptr + 1
            cur_conf = conf_levels[cptr]
            conf_dif = cur_conf
            conf_iters = 0

            do while ((conf_dif >= 0.0) && (conf_iters <= max_conf_iter)) {

               conf_iters = conf_iters + 1
               prev_conf_dif = conf_dif

#   get the next trial position according to the direction we are moving
               call trial_pos (direction, pix_incr, trial_xy)

#   compute the c-statistic minimum value based on the final calculated inputs
               call ps_cstat (bin_coords, windo_dim, src_windo, b_to_s, 
			      bin_radius, e_bepos_xy, src_sigma, trial_xy, 
                              cstat_sum_term)

               call calc_ncstat (cnts_in_bin, cstat_sum_term,
                                src_sigma, s0_final, c0_new)

#   calculate the change in c-statistic
               delta_c = abs (  2.0 * (c0_final - c0_new) )

#   update the confidence difference
               conf_dif = cur_conf - delta_c

#     conf dif and iterations
            }

            if ( conf_iters > max_conf_iter ) {
               more_conf_to_calc = FALSE
               more_dir_to_chk = FALSE
               conf_iter_ok = FALSE
            } else {

               call calc_conf (direction, e_bepos_xy, conf_dif, pix_incr, 
                         prev_conf_dif, trial_xy, quadconf[direction,cptr])

               if ( quadconf[direction,cptr] == 0.0 ) {
                  more_conf_to_calc = FALSE
                  more_dir_to_chk = FALSE
                  quad_conf_ok = FALSE

               } else if ((cptr >= num_of_conf) && (direction < 4)) {
                  more_conf_to_calc = FALSE

               } else if ((cptr >= num_of_conf) && (direction >= 4)) {
                  more_conf_to_calc = FALSE
                  more_dir_to_chk = FALSE
               }
            }
#     number of confidences
         }
#     number of directions
      }

      if ( (quad_conf_ok) && (conf_iter_ok) ) {
         do cptr = 1, num_of_conf {
            pos_confidences[cptr] =
                  (quadconf[pos_x,cptr] + quadconf[neg_x,cptr] +
                  quadconf[pos_y,cptr] + quadconf[neg_y,cptr]) / 4.0
         }
         conf_with_pos = TRUE

      } else {
         conf_with_pos = FALSE
      }

end
