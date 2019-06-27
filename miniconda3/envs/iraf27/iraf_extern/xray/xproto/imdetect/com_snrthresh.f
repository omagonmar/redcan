c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#JCC(2/10/97) - remove bk counts (ie.  det_cell_bk_cts )
c#JCC(1/23/97) - truncate name to 6 letters
c#               (ie. compute_detect_cell_snr_thresh --> cmpsnr )
c#
c#Revision 1.1  1996/11/04  20:51:05  prosb
c#Initial revision
c#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c
cC  Compute the signal to noise ratio threshold for a detect cell
c************************ FFORM VERSION 0.2 **************************
cG  Compute the SNR for a detect cell
c
c   call_var.                   type I/O  description
cP  DET_CELL_POE_CTS              I4  I   image counts in 1 detect cell 
cP  DET_CELL_BK_CTS               R4  I   bk counts in 1 detect cell 
cP  DET_CELL_SNR                  R4  O   computed snr for the detect cell 
c***********************************************************************
c#JCC(1/23/97) - truncate name to 6 letters
c#               (ie. rename "compute_detect_cell_snr_thresh -> cmpsnr")
c#&&  subroutine cmpsnr(det_cell_poe_cts,det_cell_bk_cts,det_cell_snr)
      subroutine cmpsnr(det_cell_poe_cts,det_cell_snr)
c#    implicit undefined (a-z)
c
c image counts in 1 detect cell
c     integer*4 det_cell_poe_cts
      real*4 det_cell_poe_cts
c
c bk counts in 1 detect cell
c#&&  real det_cell_bk_cts
c
c computed snr for the detect cell
      real det_cell_snr
c              
      if (det_cell_poe_cts .gt. 0) then
c#&&     det_cell_snr = (det_cell_poe_cts - det_cell_bk_cts) / sqrt(
         det_cell_snr = (det_cell_poe_cts) / sqrt(det_cell_poe_cts)
      else
         det_cell_snr = 0.0
      end if
c
      return 
      end
