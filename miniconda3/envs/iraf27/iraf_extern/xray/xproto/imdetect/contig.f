c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/20/97)- blob_size_limit -> usr_bb_size
c#            - max_num_blobs --> usr_max_bb
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#JCC(2/6/97) - remove bk_strip (with #&& in the front)
c#            - add and pass "display" to scanls 
c#            - document
c#JCC(1/23/97) - truncate subroutine name to 6 letters
c#               (ie.  scanls  &  locats  )
c
cC  Consolidate contiguous regions of 'on' detect cells
c************************ FFORM VERSION 0.2 **************************
cG  Scans the current line horizontally for regions of continuous 'on'
cG  detect cells and consolidates the horizontal regions with vertical
cG  continuous regions which comprise a 'blob'.
c
c   call_var.                   type I/O  description
cP  BLOB_SIZE_LIMIT               I4  I   max size of a blob 
cP  CWF_TYPE                      I4  I   ct weight factor type key 
cP  EVT_STRIP                     I4  I   1 line of det cell img cts 
cP  FLAGGED_LINE                  I4  I   1 line of flagged det cells 
cP  MAX_NUM_BLOBS                 I4  I   max blobs allowed 
cP  NUM_X_SUBCELLS                I4  I   # subcells on X axis 
cP  PREV_LINE                     I4  I   buffer of blob ptrs - prev line
cP  Y_SUBCELL                     I4  I   current line we are working on
cP  BK_STRIP                      R4  I   1 line of det cell bkgd cts 
cP  BLOB_LIMITS_REC               I4  U   
cP  BLOB_POS_SUMS_REC             R4  U   
c***********************************************************************
c#&&  &prev_line, y_subcell, bk_strip, blob_limits_rec, blob_pos_sums_rec
c
      subroutine contig(usr_bb_size, cwf_type
     &, evt_strip, flagged_line, usr_max_bb, num_x_subcells, 
     &prev_line, y_subcell, blob_limits_rec, blob_pos_sums_rec,
     &display)
c                   
c#    implicit undefined (a-z)
      include 'detect.inc'
c
c  blob size limit from user 
      integer*4 usr_bb_size
c               
c ct weight factor type key                                              
      integer*4 cwf_type
c               
c 1 line of det cell img cts                                             
c     integer*4 evt_strip(max_subcells)
      real*4 evt_strip(max_subcells)
c               
c 1 line of flagged det cells                                            
      integer*4 flagged_line(max_subcells)
c               
c max blobs allowed per field : input from user
      integer*4 usr_max_bb
c               
c # subcells on X axis                                                   
      integer*4 num_x_subcells
c               
c buffer of blob ptrs - prev line                                        
      integer*4 prev_line(max_subcells)
c               
c current line we are working on                                         
      integer*4 y_subcell
c               
c 1 line of det cell bkgd cts                                            
c#&&   real bk_strip(max_subcells)
c               
c buffer of blobs max & mins                                             
      integer*4 blob_limits_rec(blob_limits_fields, max_blobs)
c               
c rec of blobs centroid calc sums                                        
      real blob_pos_sums_rec(blob_sum_fields, max_blobs)
c                    
ctotal # of blobs in the line                                           
      integer*4 num_blobs_in_line
c               
cbuffer of ptrs to blobs beg & ends                                     
      integer*4 blob_ptrs(2, max_blobs)
      integer*4  display

c#JCC call scan_line_for_grps_of_on_cells(flagged_line, num_x_subcells, 

      call scanls(flagged_line, num_x_subcells, 
     &blob_ptrs, num_blobs_in_line, display )

      if (num_blobs_in_line .gt. 0) then

c#JCC call locate_regions_of_on_det_cells(blob_ptrs, usr_bb_size, 
c#&&  &num_x_subcells, y_subcell, bk_strip, blob_limits_rec, prev_line, 
          call locats(blob_ptrs, usr_bb_size, cwf_type, evt_strip, 
     &usr_max_bb, num_blobs_in_line, num_x_subcells, y_subcell, 
     &blob_limits_rec, prev_line, blob_pos_sums_rec)

      else
c         call mvzlng(prev_line, max_subcells )
          call aclrl(prev_line, max_subcells )
c
      end if
      return 
      end
