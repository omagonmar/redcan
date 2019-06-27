c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#JCC(2/6/97) - remove bk_strip and set bk_counts to zero
c#
c#Revision 1.1  1996/11/04  20:51:42  prosb
c#Initial revision
c#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c
c************************ FFORM VERSION 0.2 **************************
cG  Update blob position and centroid calculation sums of the current
cG  blob
c
c   call_var.                   type I/O  description
cP  BLOB_BEG                      I4  I   1st 'on' cell of the blob 
cP  BLOB_END                      I4  I   last 'on' cell of the blob 
cP  CWF_TYPE                      I4  I   ct weight factor key 
cP  EVT_STRIP                     I4  I   line of img detect cells 
cP  Y_SUBCELL                     I4  I   current line we are on 
cP  BK_STRIP                      R4  I   line of bk detect cells 
cP  BLOB_LIMITS                   I4  U   
cP  BLOB_POS_SUMS                 R4  U   
c***********************************************************************
c
c#&&  &cwf_type, evt_strip, y_subcell, bk_strip, blob_limits, 
      subroutine update_centroid_calculation(blob_beg, blob_end, 
     &cwf_type, evt_strip, y_subcell, blob_limits, 
     &blob_pos_sums)
c                   
c#   implicit undefined (a-z)
      include 'detect.inc'
c
cptr to start of blob
      integer*4 blob_beg
c                 
clast 'on' cell of the blob                                             
      integer*4 blob_end
c                 
cct weight factor key                                                   
      integer*4 cwf_type
c                 
cline of img detect cells                                               
c      integer*4 evt_strip(max_subcells)
      real*4 evt_strip(max_subcells)
c                 
ccurrent line we are on                                                 
      integer*4 y_subcell
c                 
cline of bk detect cells                                                
c#&&   real bk_strip(max_subcells)
c                 
cblob max and mins                                                      
      integer*4 blob_limits(blob_limits_fields)
c                 
cblob centroid sums                                                     
      real blob_pos_sums(blob_sum_fields)
c                 
cX axis subcell ptr                                                     
c                 
      integer*4 x_subcell
cdetect cell bk counts                                                  
c                 
      real bk_counts
cdetect celll img counts                                                
c                 
      real counts
c  calculating the centroid                                             
c                 
ccount weight factor used in                                            
c                 
      real ct_weight_fac
c
c    Update blob position info:
      blob_limits(y_max) = y_subcell
c Get min X if a value is already being saved and get z_beg if 1st value
      blob_limits(x_max) = max(blob_limits(x_max),blob_end)

      if (blob_limits(x_min) .gt. 0) then
         blob_limits(x_min) = min(blob_limits(x_min),blob_beg)
      else
         blob_limits(x_min) = blob_beg
c    Update blob position sum info:
      end if

      do x_subcell = blob_beg, blob_end
         counts = evt_strip(x_subcell)
c    Determine which weighting factor we are using 
c#&&     bk_counts = bk_strip(x_subcell)
         bk_counts = 0.0 

         if (cwf_type .eq. net) then
            ct_weight_fac = counts - bk_counts
         else if (cwf_type .eq. sig_sqrd) then
            ct_weight_fac = ((counts - bk_counts) / counts) ** 2
         else
            ct_weight_fac = 1
         end if

         blob_pos_sums(x_sum)=blob_pos_sums(x_sum)+(x_subcell* 
     &ct_weight_fac)
         blob_pos_sums(y_sum)=blob_pos_sums(y_sum)+(y_subcell* 
     &ct_weight_fac)
         blob_pos_sums(total_cwf) = blob_pos_sums(total_cwf) + 
     &ct_weight_fac
c
      end do

      return 
      end
