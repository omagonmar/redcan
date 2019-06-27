# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calcor.x,v 11.0 1997/11/06 16:32:01 prosb Exp $
# $Log: calcor.x,v $
# Revision 11.0  1997/11/06 16:32:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:44  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:14  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:33  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:20:35  janet
#Initial revision
#
#
# Module:       calcor.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      calculate the radius of the bin over which we will
#		search for the bepos
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------

procedure calcor (bkden, init_s0, opt_radius_sigma, src_sigma, b_to_s_factor,
     		  bin_efficiency, bin_radius)

real	bkden 			# i: bkgd density in pixels
real	init_s0 		# i: initial src cnts guess
real	opt_radius_sigma 	# i: optimum radius sigma
real	src_sigma 		# i: calc src sigma

real	b_to_s_factor 		# o: b/s factor
real	bin_efficiency 		# o: calc bin efficiency
real	bin_radius 		# o: bin circle radius

begin

#   select the optimum radius of a bin depending upon relative strengths
#   of source and background densities
      bin_radius = opt_radius_sigma * src_sigma

#   calculate the b_to_s_factor
      b_to_s_factor = (2.0*src_sigma**2) / bin_radius**2

#   calculate the bin_efficiency
      bin_efficiency = 1.0 - exp ( -1.0 / b_to_s_factor )


end
