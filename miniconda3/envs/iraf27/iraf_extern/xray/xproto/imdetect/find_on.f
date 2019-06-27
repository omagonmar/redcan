c#JCC(1/16/98)- remove "implicit a-z" for alpha
C#JCC(3/20/97)- blob_size_limit  -> usr_bb_size
c#            - max_num_blobs --> usr_max_bb
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#JCC (2/13/97) - remove "type *"
c#JCC(2/6/97) - remove bk_strip (with #&& in the front)
cJCC(1/23/97) - truncate the subroutine name to 6 letters
c              (ie. use "locats" )
c
cC   Identify regions of contiguous 'on' detect cells
c
c************************ FFORM VERSION 0.2 **************************
c   general description:
cG   Identify regions of contiguous 'on' detect cells and update the blo b
cG   information associated with that region
c
c   call_var.                   type I/O  description
cP  BLOB_PTRS                     I4  I   beg and end blob ptrs buffer 
cP  BLOB_SIZE_LIMIT               I4  I   max size of a blob 
cP  CWF_TYPE                      I4  I   ct weighting factor key 
cP  EVT_STRIP                     I4  I   line of det cell img cts 
cP  MAX_NUM_BLOBS                 I4  I   max # of blobs allowed 
cP  NUM_BLOBS_IN_LINE             I4  I   # of blobs found in 1 line 
cP  NUM_X_SUBCELLS                I4  I   # of subcells on the Y axis 
cP  Y_SUBCELL                     I4  I   current line we are working on
c 
cP  BK_STRIP                      R4  I   line of bkgd detect cells 
cP  BLOB_LIMITS_REC               I4  U   
cP  PREV_LINE                     I4  U   
cP  BLOB_POS_SUMS_REC             R4  U   
c***********************************************************************
c
c#JCC - the orginal name "locate_regions_of_on_det_cells"
c#    subroutine locate_regions_of_on_det_cells(blob_ptrs, 
c#&&  &num_blobs_in_line, num_x_subcells, y_subcell, bk_strip, 
      subroutine locats(blob_ptrs,
     &usr_bb_size, cwf_type, evt_strip, usr_max_bb, 
     &num_blobs_in_line, num_x_subcells, y_subcell, 
     &blob_limits_rec, prev_line, blob_pos_sums_rec)
c
c#    implicit undefined (a-z)
      include 'detect.inc'
c
cptr to start of blob
      integer*4 blob_ptrs(2, max_blobs)
c                
c  blob size limit from user
      integer*4 usr_bb_size
c                
c ct weighting factor key                                                
      integer*4 cwf_type
c                
c line of det cell img cts                                               
c                
c     integer*4 evt_strip(max_subcells)
      real*4 evt_strip(max_subcells)
c                
c max # of blobs allowed per field : input from user
      integer*4 usr_max_bb
c                
c # of blobs found in 1 line                                             
      integer*4 num_blobs_in_line
c                
c # of subcells on the Y axis                                            
      integer*4 num_x_subcells
c                
c current line we are working on                                         
      integer*4 y_subcell
c
c#&& line of bkgd detect cells                                              
c#&&   real bk_strip(max_subcells)
c rec of blob position max and mins                                      
c                
      integer*4 blob_limits_rec(blob_limits_fields, max_blobs)
c last line we processed; ptrs to blobs                                  
c                
      integer*4 prev_line(max_subcells)
c centroid calc position blob sums                                       
c                
      real blob_pos_sums_rec(blob_sum_fields, max_blobs)
c blobs on prev line contig to cur line                                  
c            
      integer*4 blob_branches(0:max_blobs - 1)
c index to blob info buffers                                             
c                
      integer*4 blob_index
c current blob number                                                    
c                
      integer*4 blob_num
c start ptr to blob in line                                              
c                
      integer*4 blob_x_beg
c stop ptr to blob in line                                               
c                
      integer*4 blob_x_end
c blob ptrs in                                                           
c              
c current line we are storing                                            
c            
      integer*4 current_line(max_subcells)
c # of blobs to merge into 1                                             
c                
      integer*4 merges
c ptr to subcell in Y                                                    
c                
      integer*4 x_subcell
c
c#JCC type *,"find_on.f"

c     call mvzlng(current_line, max_subcells )
      call aclrl(current_line, max_subcells )

c    Compute blob pointers for checking for contiguous regions with
c    prev_line including diagonally.
      do blob_index = 1, num_blobs_in_line
         if (blob_ptrs(beg,blob_index) .gt. beg) then
            blob_x_beg = blob_ptrs(beg,blob_index) - 1
         else
            blob_x_beg = blob_ptrs(beg,blob_index)
         end if
         if (blob_ptrs(end,blob_index) .lt. num_x_subcells) then
            blob_x_end = blob_ptrs(end,blob_index) + 1
         else
            blob_x_end = blob_ptrs(end,blob_index)
c    CHECK that Y width of current blob is within limit:
         end if
c#hopr   if (((blob_x_end - blob_x_beg) + 1) .gt. usr_bb_size) then
c#hopr   end if
         call chk_if_blob_overlaps_prev_line(blob_x_beg, blob_x_end, 
     &prev_line, blob_branches, blob_num, merges)

c    We have no merges, so this is a new blob
         if (merges .eq. 0) then
            call set_up_a_new_blob(usr_max_bb, y_subcell, 
     &blob_limits_rec, blob_num)

c    We have more than one match--combine them into one record
         else if (merges .gt. 1) then
      call merge_overlapping_blobs(blob_branches, blob_num, blob_ptrs(
     &beg,blob_index), blob_ptrs(end,blob_index), merges, num_x_subcells
     &, prev_line, blob_limits_rec, blob_pos_sums_rec)
         end if

c    Update the current blob line with the current blob_#
      do x_subcell=blob_ptrs(beg,blob_index),blob_ptrs(end,blob_index)
            current_line(x_subcell) = blob_num
      end do
c#&&  &bk_strip, blob_limits_rec(1,blob_num), blob_pos_sums_rec(1,
         call update_centroid_calculation(blob_ptrs(beg,blob_index), 
     &blob_ptrs(end,blob_index), cwf_type, evt_strip, y_subcell, 
     &blob_limits_rec(1,blob_num), blob_pos_sums_rec(1,blob_num))
      end do
c      call mvbyt(current_line, prev_line, max_subcells * 4)
      call amovl(current_line, prev_line, max_subcells)

      return 
      end
