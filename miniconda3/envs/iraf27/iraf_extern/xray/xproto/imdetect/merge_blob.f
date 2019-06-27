c#JCC(1/16/98)- remove "implicit a-z" for alpha
C#JCC(3/20/97)- rename init_blob_info() to intbb()
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c
cC   Merge blobs from the previous line contiguous with the current blob
c
c************************ FFORM VERSION 0.2 **************************
cG   Find all the branches of the blob in the previous line and assign
cG   them the same blob number. Update rough position sums and the blob
cG   limits with the additional area.
c
c   call_var.                   type I/O  description
cP  BLOB_BRANCHES                 I4  I   ptrs to blobs on prev line 
cP  BLOB_NUM                      I4  I   current blob number 
cP  BLOB_BEG                      I4  I   1st 'on' cell of the blob 
cP  BLOB_END                      I4  I   last 'on' cell of the blob 
cP  MERGES                        I4  I   # of blobs found to be contig 
cP  NUM_X_SUBCELLS                I4  I   # of subcells on the Z axis 
cP  PREV_LINE                     I4  I   previous line to current line 
cP  BLOB_LIMITS_REC               I4  U   
cP  BLOB_POS_SUMS_REC             R4  U   
c***********************************************************************
c
      subroutine merge_overlapping_blobs(blob_branches, blob_num, 
     &blob_beg, blob_end, merges, num_x_subcells, prev_line, 
     &blob_limits_rec, blob_pos_sums_rec)
c    
c#    implicit undefined (a-z)
      include 'detect.inc'
c
cptr to start of blob
      integer*4 blob_branches(0:max_blobs - 1)
ccurrent blob number                                                    
c                
      integer*4 blob_num
c1st 'on' cell of the blob                                              
c                
      integer*4 blob_beg
clast 'on' cell of the blob                                             
c                
      integer*4 blob_end
cto the current blob                                                    
c                
c# of blobs found to be contig                                          
c                
      integer*4 merges
c# of subcells on the Z axis                                            
c                
      integer*4 num_x_subcells
c    I/O:
cprevious line to current line                                          
c                
      integer*4 prev_line(max_subcells)
cblob max & min buffer                                                  
c                
      integer*4 blob_limits_rec(blob_limits_fields, max_blobs)
cblob pos sums for centroid calc                                        
c                
      real blob_pos_sums_rec(blob_sum_fields, max_blobs)
c                
cindex thru blob_branches                                               
c                
      integer*4 branch_index
cptr to the branch blob                                                 
c                
      integer*4 branch_num
cptr to subcell in Z                                                    
c                
      integer*4 x_subcell
c
      do branch_index = 2, merges
c    Find all the branches of this blob and assign them the same blob nu
cmber:
      branch_num = blob_branches(branch_index)
      do x_subcell = blob_limits_rec(x_min,branch_num), blob_limits_rec(
     &x_max,branch_num)
      prev_line(x_subcell) = blob_num
c    Update rough position sums:
      end do
      blob_pos_sums_rec(x_sum,blob_num) = blob_pos_sums_rec(x_sum,
     &blob_num) + blob_pos_sums_rec(x_sum,branch_num)
      blob_pos_sums_rec(y_sum,blob_num) = blob_pos_sums_rec(y_sum,
     &blob_num) + blob_pos_sums_rec(y_sum,branch_num)
c    Update blob limits:
      blob_pos_sums_rec(total_cwf,blob_num) = blob_pos_sums_rec(
     &total_cwf,blob_num) + blob_pos_sums_rec(total_cwf,branch_num)
      blob_limits_rec(y_min,blob_num) = min(blob_limits_rec(y_min,
     &blob_num),blob_limits_rec(y_min,branch_num))
      blob_limits_rec(y_max,blob_num) = max(blob_limits_rec(y_max,
     &blob_num),blob_limits_rec(y_max,branch_num))
      blob_limits_rec(x_min,blob_num) = min(blob_limits_rec(x_min,
     &blob_num),blob_limits_rec(x_min,branch_num))
c      Recycle this blob record
      blob_limits_rec(x_max,blob_num) = max(blob_limits_rec(x_max,
     &blob_num),blob_limits_rec(x_max,branch_num))
      call intbb(blob_limits_rec(1,branch_num), 
     &blob_pos_sums_rec(1,branch_num))
c
      end do
      return 
      end
