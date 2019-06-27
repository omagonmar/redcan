c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#Revision 1.1  1996/11/04  20:52:18  prosb
c#Initial revision
c#
cJCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c
cC   Find unused blob rec for blob info storage and inititialize y_min
c************************ FFORM VERSION 0.2 **************************
cG  Search blob info records for a 
c   call_var.                   type I/O  description
cP  MAX_NUM_BLOBS                 I4  I   max number of blobs 
cP  Y_SUBCELL                     I4  I   current line we are scanning 
cP  BLOB_LIMITS_REC               I4  U   
cP  BLOB_NUM                      I4  O   current blob number 
cI  H$INCLUDE:DETECT.INC                  program global parameters 
c***********************************************************************
      subroutine set_up_a_new_blob(max_num_blobs, y_subcell, 
     &blob_limits_rec, blob_num)
c                   
c#    implicit undefined (a-z)
      include 'detect.inc'
c
cptr to start of blob
      integer*4 max_num_blobs
c    I/O:
ccurrent line we are scanning                                           
c                 
      integer*4 y_subcell
cblob max & min buffer                                                  
c                 
c    Outputs:
      integer*4 blob_limits_rec(blob_limits_fields, max_blobs)
ccurrent blob number                                                    
c                 
      integer*4 blob_num
c                 
cptr to the current blob rec                                            
c                 
      integer*4 blob_index
ctrue when we find an empty blob rec                                    
c                 
      logical*4 found
c                 
c    Initialize:
      found = .false.
c    Search for an empty entry to start the new blob info:
      blob_index = 1
      do while (.not. found)
      if (blob_limits_rec(status,blob_index) .eq. not_in_use) then
      blob_num = blob_index
      blob_limits_rec(status,blob_index) = in_use
      found = .true.
      else
      blob_index = blob_index + 1
c               CALL HERRCHK (RTNAME, 'Blob Max Limit Exceeded', 
c     &                       HRI_ERR_BLOBLIMEX)
      if (blob_index .gt. max_num_blobs) then
      end if
      end if
c    Initialize for the current line:
      end do
c
      blob_limits_rec(y_min,blob_index) = y_subcell
      return 
      end
