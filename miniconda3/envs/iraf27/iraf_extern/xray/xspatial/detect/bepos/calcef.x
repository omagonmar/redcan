# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/calcef.x,v 11.0 1997/11/06 16:32:00 prosb Exp $
# $Log: calcef.x,v $
# Revision 11.0  1997/11/06 16:32:00  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:42  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:04  prosb
#General Release 2.2
#
#Revision 5.1  93/05/13  11:53:49  janet
#jd - included xexamine debug level in printout conditional.
#
#Revision 5.0  92/10/29  21:31:28  prosb
#General Release 2.1
#
#Revision 1.5  92/10/21  17:08:18  janet
#specified units in print statement.
#
#Revision 1.4  92/10/14  09:52:12  janet
#added alpha and beta calcs, replaced cell_efficientcy with alpha.
#
#Revision 1.3  92/09/25  11:21:59  janet
#*** empty log message ***
#
#Revision 1.2  92/09/25  11:05:52  janet
#New src_sigma expression based on calibration, table input of coeffs, added error function to calc cell_efficiency.
#
#Revision 1.1  92/09/25  11:04:47  janet
#Initial revision
#
#
# Module:       calcef.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      calc a good approximation for the intergral of the prf
#               over the det cell
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version  -- 9/92
#               {n} <who> -- <does what> -- <when>
#
#-------------------------------------------------------------------------

include "bepos.h"
include <mach.h>

#-------------------------------------------------------------------------
# calc good approximation for the intergral of the prf over the det cell
#-------------------------------------------------------------------------

procedure calcef (yx_cell_size, p_rough_xy, asperpix, det_center, 
		  eqkey, aa, bb, cc, dd, ee, prf_sigma, debug, 
		  src_sigma, alpha, beta)

#************************ fform version 0.2 **************************
#
# author : jd                date: 2-mar-1987 15:43
#  				   jd - converted to SPP 7/92
#
#***********************************************************************

int	yx_cell_size[ARB]	# i: det cell size in x & y in pixels

real	p_rough_xy[ARB] 	# i: rough pos in pixels
real    asperpix		# i: arcsecs per pixel
real    det_center[ARB]		# i: detector center
real    aa, bb, cc, dd, ee	# l: prf calc coeffs
real    prf_sigma

int     eqkey			# l: prf sigma equation key
int     debug			# i: debug level

real	src_sigma 		# i/o: src sigma
real	alpha			# o: calc cell efficiency
real	beta			# o: calc cell efficiency

int	cell_size 		# l: detect cell size
real    offang			# l: computed off-axis angle

double  erfarg
# double  eff

double  test_eff
double  derf()

begin

#    specification:

      if ( yx_cell_size[x] != yx_cell_size[y] ) {
         call printf (" Warning - detect cell size is not square\n") 
         cell_size = min(yx_cell_size[x], yx_cell_size[y])

      # both are the same - pick one
      } else {
         cell_size = yx_cell_size[x]
      }

      if ( prf_sigma <= EPSILONR ) {

         # compute the Source sigma if not specified by the user

         # compute the offaxis angle in pixels
         call compute_offaxis_ang (p_rough_xy[x], p_rough_xy[y], 
				   det_center[x], det_center[y], offang)

         # convert from pixels to arcminutes
         offang = (offang * asperpix) / 60.0

	 # eqkey corresponds to prf coeff equation to apply to the coefficients.
         # they must be id'd in the table and known by the code.
	 switch (eqkey) {
           	
  	   case 1:
              src_sigma = 
		(sqrt (aa**2 + bb**2 + (cc + dd * offang**ee)**2))/ asperpix
          
           default:
	      call error (1, "Cannot recognize eq_code Not Equal to 1")
	 }

      } else {
         # assign user-specified value ... convert to pixels
         src_sigma = prf_sigma / asperpix
      }

#   - the following equation is in HOPR, opt_radius_sigma = 1.8
#         src_sigma = cell_size / (2.0 * opt_radius_sigma)

#   The cell efficiency provides a good approximation for the integral
#   of the prf over the detect cell.  the argument of the exponential is
#   simply the negative of the square of the detect-cell half-width
#   divided by 1.6 * sigma**2. the appearance of the factor 1.6 occurs
#   instead of the usual 2 because the integral is over a square instead
#   of a circle.

#     eff = 1.0 - exp((- (yx_cell_size[x]/2)*(yx_cell_size[y]/2))/
#     		        (cell_eff_factor * src_sigma**2))

#   We're using the cell efficiency as computed by the error function (derf)
      erfarg = (cell_size/2.0) / (src_sigma*sqrt(2.0))
      test_eff =  derf(erfarg) 
      alpha = test_eff * test_eff

      erfarg = ((5.0*cell_size/3.0)/2.0) / (src_sigma*sqrt(2.0))
      test_eff = derf(erfarg)
      beta =  test_eff * test_eff

      if ( debug >= 3 && debug != 10 ) {
         call printf ("\nsrc_sigma= %0.5f pixels, alpha= %0.5f, beta= %0.5f\n")
            call pargr (src_sigma)
            call pargr (alpha)
            call pargr (beta)
      }
end
