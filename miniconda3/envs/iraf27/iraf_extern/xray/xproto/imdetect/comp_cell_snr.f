c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c JCC(3/4/97) - comment out unused variables and redocument 
c
c#Revision 1.1  1996/11/04  20:50:11  prosb
c#Initial revision
cJCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c************************ FFORM VERSION 0.2 **************************
c Retrieve the signal to noise ratio for specified cell size and back
c ground.
c If the input field bk density is 0.0 or the computed snr is less than
c the snr_thresh_min the final snr is set to the snr_thresh_min.
c
c   call_var.                   type I/O  description
cP  NUM_COEFFICIENTS              I4  I   # of snr coefficients 
cP  FIELD_BK_DENSITY              R4  I   bk density in cts/sq arc min 
cP  SNR_COEFFICIENTS              R4  I   coefficients of the polynomial
cP  SNR_THRESH_MIN                R4  I   snr thresh for min bk density 
cP  SNR_THRESH                    R4  O   threshold for given parameters
c***********************************************************************
      subroutine compcr(num_coefficients, field_bk_density, 
     &snr_coefficients, snr_thresh_min, snr_thresh)
c
c#    implicit undefined (a-z)
c # of snr coefficients                                                 
      integer*4 num_coefficients
c                 
c bk density in cts/sq arc min                                          
      real field_bk_density
c                 
c coefficients of the polynomial                                        
      real snr_coefficients(0:*)
      real snr_thresh_min
      real snr_thresh
c                
c the power of the polynomial                                           
      integer*4 power
c                
c ln(background cnts)                                                   
      real bk_factor
c                
cso we don't take the log of 0                                          
c                
      if (field_bk_density .eq. 0.0) then
         snr_thresh = snr_thresh_min
      else
         bk_factor = alog(field_bk_density)
c                      
c a clean slate                                                         
c let's not to forget to start with                                     
c                      
         snr_thresh = 0.0
         do power = 0, num_coefficients - 1
            snr_thresh=snr_thresh+(snr_coefficients(power)*
     & (bk_factor ** power))
         end do
         if (snr_thresh.lt.snr_thresh_min) then
            snr_thresh=snr_thresh_min
         end if
      end if
      return 
      end
