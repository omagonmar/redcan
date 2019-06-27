c#JCC(1/16/98)- remove "implicit a-z" for alpha
c#JCC(3/20/97)- init_blob_info() --> intbb()
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c
cC   Initialize blob buffers to 0
c************************ FFORM VERSION 0.2 **************************
cG  Zero blob limits and blob position buffers
c
c   call_var.                   type I/O  description
cP  BLOB_LIMITS                   I4  U   blob min & max coord 
cP  BLOB_POS_SUMS                 R4  U   centroid calc factors 
cI  H$INCLUDE:DETECT.INC                  detect global params 
c***********************************************************************
c
      subroutine intbb(blob_limits, blob_pos_sums)
c                   
c#    implicit undefined (a-z)
      include 'detect.inc'
c
cptr to start of blob
      integer*4 blob_limits(blob_limits_fields)
ccentroid calc factors                                                  
c       
      real blob_pos_sums(blob_sum_fields)
c              
c    Initialize  Blob Limits:
      blob_limits(status) = not_in_use
      blob_limits(x_min) = 0
      blob_limits(x_max) = 0
      blob_limits(y_min) = 0

c    Initialize Blob Position Sums:
      blob_limits(y_max) = 0
      blob_pos_sums(x_sum) = 0.0
      blob_pos_sums(y_sum) = 0.0
c
      blob_pos_sums(total_cwf) = 0.0
      return 
      end
