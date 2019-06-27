# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/comp_eqsums.x,v 11.0 1997/11/06 16:32:03 prosb Exp $
# $Log: comp_eqsums.x,v $
# Revision 11.0  1997/11/06 16:32:03  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:48  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:19  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:54:52  janet
#jd - included xexamine debug level in printout conditional.
#
#Revision 5.0  92/10/29  21:31:40  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  10:51:21  janet
#Initial revision
#
#
# Module:       comp_eqsums.x
# Project:      PROS -- ROSAT RSDC
# Purpose:	calculate the minimum terms in the equations
#		over the bin circle
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

include "bepos.h"
define min 1
define max 2

# --------------------------------------------------------------------
procedure comp_eqsums ( bin_coords, debug, windo_dim, src_windo, b_to_s, 
			bin_radius, src_sigma, trial_xy, cnts_in_bin, 
                        cstat_sum_term, sum_wxy, sum_xy)

int	bin_coords[2,ARB] 	 # i: coords in element of the square 
				 #    around the bin circle
int	debug 			 # i: debug level
int	windo_dim 		 # i: dim of src_windo
int	src_windo[windo_dim,ARB] # i: array of poe photons centered on 
				 #    the rough position
real	b_to_s 			 # i: background to source cnts factor
real	bin_radius 		 # i: radius of the position search circle
real	src_sigma 		 # i: computed src_sigma
real	trial_xy[ARB] 		 # i: trial position in array element coords

int	cnts_in_bin 		# o: total phtons in bin circle

real	cstat_sum_term 		# o: running sum for cstat
real	sum_wxy
real	sum_xy[ARB]


int	cnts_in_this_pix 	# num of cnts at current pos
int	xpos 			# x pos in bin
int	ypos 			# y pos in bin

real	distance_sq 		# dist computed with trial pos 
real	src_cts_denom		# est src cnts denominator
real	src_cts_numerator       # est src cnts numerator
real	src_cts_wxy 		# est src cnts for the pixel

begin

# ***if making changes to the loops or equations also check routines ***
# ***   comp_cstat_terms.for  &  comp_cstat_terms_for_pos_conf.for   ***

#  init variables
      sum_xy[x] = 0.0
      sum_xy[y] = 0.0
      sum_wxy = 0.0
      cstat_sum_term = 0.0
      cnts_in_bin = 0

#   loop over the bin area
      do xpos = bin_coords[x,min], bin_coords[x,max] {

         do ypos = bin_coords[y,min], bin_coords[y,max] {

#   get the next pixel counts and coordinates
            cnts_in_this_pix = src_windo[xpos,ypos]

#   check if there are counts in the pixel - loop if not
            if ( cnts_in_this_pix != 0 ) {

#   check if we are within bin_radius of the trial position - loop if not
               distance_sq = (xpos - trial_xy[x] )**2 +
                             (ypos - trial_xy[y] )**2
               if ( distance_sq <= bin_radius**2 ) {

#   sum the counts in this bin
                  cnts_in_bin = cnts_in_bin + cnts_in_this_pix

#   calculate the src_cts_numerator, src_cts_denominator, and src_cts_wxy 
#   for this pixel iterative equation to compute src counts:
#   s0ij = sum(i=1,n) [exp(-ri**2/2sigma**2) / (b/s + exp(-ri**2/2sigma**2)]
#        = sum(i=1,n) wij
#   where b=b/a, s=s/2*pi*sigma, b=bkgd_cts, a=area, s=source_cnts

                  src_cts_numerator = exp (-distance_sq /
                                          (2.0*src_sigma**2) )
                  src_cts_denom = b_to_s + src_cts_numerator

                  src_cts_wxy = cnts_in_this_pix * src_cts_numerator / 
                                src_cts_denom

#   calculate the next term for the cstatistic equation
#   confidence equation:
#   c = 2 * [e - sum(i=1,n)ln(ii)]
#   where ii = b/a + s/2*pi*sigma + exp(ri**2/2sigma**2), and e = b+s

#   compute a summation of logarithms for the confidence calculation
                  cstat_sum_term = cstat_sum_term +
                        (alog(src_cts_denom) * cnts_in_this_pix)
                  if ( debug >= 5 && debug != 10 ) {
                     call printf ("cstat_sum_term = %14.4f\n")
                       call pargr (cstat_sum_term)
                  }


#    calculate the next term for the position equation
#    eq:
#    x0j+1 = 1/soj * sum(i=1,n) [wij * xij]
#    where xij is position of photon

#    add pixel position multiplied by the weight to the sums

                  sum_xy[x] = sum_xy[x] + (xpos * src_cts_wxy)
                  sum_xy[y] = sum_xy[y] + (ypos * src_cts_wxy)

                  sum_wxy = sum_wxy + src_cts_wxy

               }

            }

         }

      }

end
