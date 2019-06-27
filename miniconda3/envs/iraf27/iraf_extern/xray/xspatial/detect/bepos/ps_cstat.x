# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/ps_cstat.x,v 11.0 1997/11/06 16:32:08 prosb Exp $
# $Log: ps_cstat.x,v $
# Revision 11.0  1997/11/06 16:32:08  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:51:02  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:13:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:17:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:32:04  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  11:11:09  janet
#Initial revision
#
#
# Module:       .x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	calculate the minimum terms in the ctsatistic equation
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"
define   min 1
define   max 2

procedure ps_cstat ( bin_coords, windo_dim, src_windo, b_to_s, bin_radius, 
		     e_bepos_xy, src_sigma, trial_xy, cstat_sum_term)


int	bin_coords[2,ARB] 	# i: coords in element of the square 
				# i: around the bin circle

int	windo_dim 		# i: dim of src_windo
int	src_windo[windo_dim,ARB] # i: array of poe photons centered on the 
                                # i: rough position

real	b_to_s 			# i: background to source cnts factor
real	bin_radius 		# i: radius of the position search circle
real	e_bepos_xy[ARB]		# i: best position in array element coords
real	src_sigma 		# i: computed src_sigma
real	trial_xy[ARB]		# i: trial position in array element coords

real	cstat_sum_term 		# o: running sum for cstat

int	cnts_in_bin 		# sum of cnts in bin_radius size circle
int	cnts_in_this_pix 	# num of cnts at current pos
int	xpos 			# x pos in bin
int	ypos 			# y pos in bin

real	final_dist_sq 		# distance computed with best pos 
real	trial_dist_sq 		# distance computed with trial position

begin 

#  init variables
      cstat_sum_term = 0.0
      cnts_in_bin = 0

# ** if making changes to loops or equations in this routine also check ***
# **   comp_eq_sums_over_bin_circle.for & comp_cstat_term.for  ***

#   loop over the bin area
      do xpos = bin_coords[x,min], bin_coords[x,max] {

         do ypos = bin_coords[y,min], bin_coords[y,max] {

#   get the next pixel counts and coordinates
            cnts_in_this_pix = src_windo[xpos,ypos]

#   check if there are counts in the pixel - loop if not
            if ( cnts_in_this_pix != 0 ) {

#   check if we are within bin_radius of the trial position - loop if not
               final_dist_sq = (xpos - e_bepos_xy[x] )**2 +
                               (ypos - e_bepos_xy[y] )**2
               if ( final_dist_sq .le. bin_radius**2 ) {

#   sum the counts in this bin
                  cnts_in_bin = cnts_in_bin + cnts_in_this_pix

                  trial_dist_sq = ( xpos-trial_xy[x] )**2 +
                                  ( ypos-trial_xy[y] )**2

#   calculate the next term for the cstatistic equation
#   confidence equation:
#   c = 2 * [e - sum(i=1,n)ln(ii)]
#   where ii = b/a + s/2*pi*sigma + exp(ri**2/2sigma**2), and e = b+s

                  cstat_sum_term = cstat_sum_term + (alog (b_to_s +
                       (exp  (-trial_dist_sq / (2.0*src_sigma**2)))) *
                        cnts_in_this_pix)

               }

            }

         }

      }

end
