c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
cC   Scan the prev line to see if cells are contig to the current blob 
c************************ FFORM VERSION 0.2 **************************
cG   Looks for cells on the previous line that are contiguous to the
cG   cells of the current blob. (including diagonally; already
cG   considered in the BLOB_Y_BEG and BLOB_Y_END indexes.)
cG   It is important to remember that PREV_LINE (and therefore 
cG   BLOB_BRANCHES) do not contain simply 0's and 1's but rather
cG   integer references to blob they are assigned to.
c
c   call_var.                   type I/O  description
cP  BLOB_Y_BEG                    I4  I   1st 'on' cell in the blob 
cP  BLOB_Y_END                    I4  I   Last 'on' cell in the blob 
cP  PREV_LINE                     I4  I   prev line to current line 
cP  BLOB_BRANCHES                 I4  O   ptrs to blobs on prev line contig
cP  BLOB_NUM                      I4  O   the number of the current blob
cP  MERGES                        I4  O   # of blobs found to be contig 
c***********************************************************************
      subroutine chk_if_blob_overlaps_prev_line(blob_y_beg, blob_y_end, 
     &prev_line, blob_branches, blob_num, merges)
c
c#    implicit undefined (a-z)
cglobal program parameters                                              
c                   
      include 'detect.inc'
c
cptr to start of blob
      integer*4 blob_y_beg
cLast 'on' cell in the blob                                             
c                 
      integer*4 blob_y_end
c    Outputs:
cprev line to current line                                              
c                 
      integer*4 prev_line(max_subcells)
cto current line                                                        
c                 
cptrs to blobs on prev line conig                                       
      integer*4 blob_branches(0:max_blobs - 1)

cthe number of the current blob                                         
      integer*4 blob_num

c# of blobs found to be contig to                                       
      integer*4 merges
c                 
cptr to blob pos on prev_line                                           
      integer*4 blob_cell
c    Initialize variables
      merges = 0
c  Search the section of the previous line that is in the limits of the
c    current blob 
c      call mvzlng(blob_branches, max_blobs )
      call aclrl(blob_branches, max_blobs )
c    If the cell is flagged in the previous line
      do blob_cell = blob_y_beg, blob_y_end
c    Is this previous cell contiguous to others in the same line?
      if (prev_line(blob_cell) .gt. 0) then
c    No, it isn't, we have another blob in previous line that is now 
c    within our current line blob limits
      if (prev_line(blob_cell) .ne. blob_branches(merges)) then
      merges = merges + 1
      blob_branches(merges) = prev_line(blob_cell)
      end if
      end if
      end do
c
      blob_num = blob_branches(1)
      return 
      end
