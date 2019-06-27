# $Header: /home/pros/xray/xspatial/detect/bepos/RCS/celsnr.x,v 11.0 1997/11/06 16:32:02 prosb Exp $
# $Log: celsnr.x,v $
# Revision 11.0  1997/11/06 16:32:02  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:50:46  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:12:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:32:16  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:14:13  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:35  prosb
#General Release 2.1
#
#Revision 1.1  92/10/06  09:22:55  janet
#Initial revision
#
#
# Module:       celcnr.x
# Project:      PROS -- ROSAT RSDC
# Purpose:	retrieve the signal to noise ratio for specified cell
#               size and background
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} JD -- initial version - converted to SPP -- 7/92
#               {n} <who> -- <does what> -- <when>
#
# ---------------------------------------------------------------------------
 
procedure celsnr ( num_coefficients, field_bk_density, snr_coefficients, 
                   snr_thresh_min, snr_thresh )

#***********************************************************************
#
#a  author : amm,jd           date: 5-jun-1986 15:43  
#
#***********************************************************************

int	num_coefficients         # i: # of snr coefficients
real	field_bk_density         # i: bk density in cts/sq arc min
real	snr_coefficients[0:ARB]  # i: coefficients of the polynomial
real	snr_thresh_min           # i: snr thresh for min bk density

real	snr_thresh               # o: threshold for given parameters

int	power                    # l: the power of the polynomial

real	bk_factor                # l: ln(background cnts)


begin

# so we don't take the log of 0
      if ( field_bk_density == 0.0 ) {

         snr_thresh = snr_thresh_min

      } else {

         bk_factor = alog ( field_bk_density )

         snr_thresh = 0.0             

         do power = 0, num_coefficients - 1 {

            snr_thresh = snr_thresh + snr_coefficients (power) *
                         bk_factor **power      
         }

         if (snr_thresh < snr_thresh_min) { 
            snr_thresh = snr_thresh_min
	 }
      }

      
end     
