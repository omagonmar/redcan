# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calcfs.x,v 11.0 1997/11/06 16:32:00 prosb Exp $
# $Log: calcfs.x,v $
# Revision 11.0  1997/11/06 16:32:00  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:43  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:07  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:54:13  janet
#jd - included xexamine debug level in printout conditional.
#
#Revision 5.0  92/10/29  21:31:31  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:19:06  janet
#Initial revision
#
#
# Module:       calcfs.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      calculate the final snr, src and bk cnts, pos_confidence & psno
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"

# --------------------------------------------------------------------
# calculate the final snr, src and bk cnts, pos_confidence & psno
# --------------------------------------------------------------------

procedure calcfs (bin_coords, cnts_in_bin, debug, max_conf_iter, num_of_conf, 
		 windo_dim, src_windo,yx_cell_size, b_to_s_factor, 
		 bin_efficiency, bin_radius, conf_levels, e_bepos_xy, 
		 p_bepos_xy, src_sigma, s0_final, b0_final, snr_thresh, 
		 reason_for_failure, error_code, bepos_bk, 
     		 bepos_src, pos_confidences, prob_src_nonzero, pcflag, snr)

int     bin_coords[2,ARB] 	# i: outer bin range coords
int	cnts_in_bin 		# i: # photons in bin circle
int	debug 			# i: debug level
int	max_conf_iter 		# i: max iter for conf calc
int	num_of_conf 		# i: number of confidence levels
int	windo_dim 		# i: dimension of src_windo
int	src_windo[windo_dim,ARB] # i: photon arr from pos around rpos
int	yx_cell_size[ARB] 	# i: det cell size in x & y
int	pcflag 			# i: position confidence flag; 
                                #    0=confidence-, 1=confidence+

real	b_to_s_factor 		# i: b/s factor
real	bin_efficiency 		# i: calculated bin efficiency
real	bin_radius 		# i: radius of the bin circle
real	conf_levels[ARB] 	# i: specified confidence levels 
real	e_bepos_xy[ARB] 	# i: best pos in element coords
real	p_bepos_xy[ARB] 	# i: best pos in pixel coords
real	src_sigma        	# i: calculated pt response sigma
real	s0_final 		# i: final src cnts
real	b0_final   		# i: final bk cnts
real	snr_thresh 		# i: snr threshold

int	reason_for_failure[ARB] # i/o:  debug array with failure tallies

int	error_code 		# o: code for error failure

real	b_to_s 			# o: b/s
real	bepos_bk		# o: bkgd cnts in det cell around the bpos
real	bepos_src		# o: src cnts in det cell around the bpos
real	c0_final 		# o: final c-statistic
real	pos_confidences[ARB] 	# o: calculated pos confidences
real	prob_src_nonzero 	# o: psno statistic
real	snr 			# o: calculated snr

bool	confident_with_pos 	# o: indicates if pos confident

begin

#
#      call calcsr (bin_coords, debug, windo_dim, src_windo,
#    &               yx_cell_size, e_bepos_xy, p_bepos_xy,
#    &               bepos_bk, bepos_src, snr)
#     if ( debug .gt. 2 ) then
#        write (wrbuff,1000) bepos_bk, bepos_src
#        call wrlog (rtname, wrbuff)
#        write (wrbuff,1500) snr, snr_thresh
#        call wrlog (rtname, wrbuff)
#     endif
#     ******  jd added calc below for dec89 conversion to iraf ******
#      bepos_bk= b0_final
#      bepos_src = s0_final
#      snr = (bepos_src - bepos_bk)/ sqrt (bepos_src)
#     ******  jd added calc above for dec89 conversion to iraf ******
#
#      bepos_bk = b0_final
#      call calcsr (im, debug, yx_cellsize, p_bepos_xy, 
#     &             bepos_bk, bepos_src, snr)


      if ( snr >= snr_thresh ) {
         call comp_fcstat (bin_coords, cnts_in_bin, windo_dim,
                src_windo, b_to_s_factor, bin_efficiency, bin_radius,
                e_bepos_xy, src_sigma, s0_final, b_to_s, c0_final)

         if ( debug > 2 && debug != 10 ) {
	    call printf ("s0_final = %14.4f,   c0_final = %14.4f\n")
                call pargr (s0_final)
                call pargr (c0_final)
         }

         call posconf (bin_coords, cnts_in_bin, debug, max_conf_iter,
		num_of_conf,windo_dim,src_windo,b_to_s, bin_radius,
		c0_final, conf_levels, e_bepos_xy, src_sigma, s0_final, 
		confident_with_pos, pos_confidences)

         if ( confident_with_pos ) {
            call comp_nonzero (bin_coords, cnts_in_bin, windo_dim, src_windo, 
		b_to_s_factor, bin_efficiency, bin_radius, c0_final, 
		e_bepos_xy, src_sigma, s0_final, prob_src_nonzero)

            pcflag=1
         } else {
            reason_for_failure[pc] = reason_for_failure[pc] + 1
            pcflag=0
#           error_code = pc

         }

      } else {

         reason_for_failure[st] = reason_for_failure[st] + 1
         error_code = st
      }

end
