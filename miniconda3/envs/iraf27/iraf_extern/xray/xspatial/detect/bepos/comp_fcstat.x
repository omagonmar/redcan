# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/comp_fcstat.x,v 11.0 1997/11/06 16:32:03 prosb Exp $
# $Log: comp_fcstat.x,v $
# Revision 11.0  1997/11/06 16:32:03  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:50  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:24  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:43  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  10:52:27  janet
#Initial revision
#
#
# Module:       comp_fcstat.x
# Project:      PROS -- ROSAT RSDC
# Purpose: 	calculate the c-statistic with the best source position
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------

procedure comp_fcstat (bin_coords, cnts_in_bin, windo_dim, src_windo, 
	         b_to_s_factor, bin_efficiency, bin_radius, e_bepos_xy, 
		 src_sigma, s0_final, b_to_s, c0_final)

int	bin_coords[2,ARB] 	 # i: x & y bin coords
int	cnts_in_bin 		 # i: num cnts in bin circle
int	windo_dim 		 # i: src_windo dimension
int	src_windo[windo_dim,ARB] #i: poe photon array at rough pos

real	b_to_s_factor 		# i: bkgd to src cnts factor
real	bin_efficiency 		# i: calculated bin efficiency
real	bin_radius 		# i: bin circle radius
real	e_bepos_xy[ARB]         # i: best pos in element coords
real	src_sigma 		# i: calculated pt response sigma
real	s0_final 		# i: final src cnts

real	b_to_s 			# o: term in est src cnts eq
real	c0_final 		# o: final c-statistic

real	b0_final 		# l: final bkgd amplitude
real	cstat_sum_term 		# l: running sum for cstat

begin

      b0_final = cnts_in_bin - ( s0_final * bin_efficiency )

#   calculate new b/s based on current b0 & s0 values
      b_to_s = b_to_s_factor * b0_final / s0_final

#   calculate the cstatistics equation terms over the bin circle
      call cstat_terms (bin_coords, windo_dim, src_windo, b_to_s, 
		  bin_radius, e_bepos_xy, src_sigma, cstat_sum_term)

#   and calculate the new value
      call calc_ncstat (cnts_in_bin, cstat_sum_term, src_sigma, s0_final, 
                        c0_final)


end
