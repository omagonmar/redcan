c JCC(3/3/97) - change max_subcells from 4100 to 4097 
c
c#Revision 1.2  1997/02/10  21:57:16  prosb
c JCC(2/10/97) - increase max_subcells from 1024 to 4100
c
c#Revision 1.1  1996/11/05  15:00:26  prosb
c#Initial revision
cJCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c
cC  DETECT global paramters
c
cptr to start of blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 beg
      parameter (beg = 1)
c# of fields for blob limits info
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 blob_limits_fields
      parameter (blob_limits_fields = 5)
c# of fields for blob pos sum info
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 blob_sum_fields
      parameter (blob_sum_fields = 3)
cptr to end of blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 end
      parameter (end = 2)
cindicates blob rec is storing data
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 in_use
      parameter (in_use = 1)
cmax subcells for array dim; was 1024 (JCC)
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 max_subcells
      parameter (max_subcells = 4097 )
cmax subcells for array dim of a blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 max_blobs
cwas 100                                                                
      parameter (max_blobs = 500)
cmax subcells for array dim of a box
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 max_box
c2 larger than max_blobs; was 102                                       
      parameter (max_box = 502)
      integer*4 MAX_BOX_SIZE
      parameter (MAX_BOX_SIZE = (max_box+1)*(max_box+1))
cpos array delimiter
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 max_pos
      parameter (max_pos = 250)
cct weight factor is net counts
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 net
      parameter (net = 1)
cindicates blob rec not storing data
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 not_in_use
      parameter (not_in_use = 0)
cindicates subcell is below thresh
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 off
      parameter (off = 0)
cindicates subcell is above thresh
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 on
      parameter (on = 1)
cct weight factor is sigma sqrd type
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 sig_sqrd
      parameter (sig_sqrd = 2)
cptr to status of blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 status
      parameter (status = 1)
cptr to total cwf for blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 total_cwf
      parameter (total_cwf = 3)
cptr to cwf for X
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 x_sum
      parameter (x_sum = 1)
cptr to max X coord in blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 x_max
      parameter (x_max = 3)
cptr to min X coord in blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 x_min
      parameter (x_min = 2)
cX cordinate ptr
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 x_pos
      parameter (x_pos = 1)
cptr to cwf for Y
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 y_sum
      parameter (y_sum = 2)
cptr to max Y coord of blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 y_max
      parameter (y_max = 5)
cptr to min Y coord of blob
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 y_min
      parameter (y_min = 4)
cY coordinate ptr
*F77CVT -- Sun extension:  INTEGER*n declaration
      integer*4 y_pos
      parameter (y_pos = 2)
