c#JCC(5/5/98) - change 'type *' to 'print *' for linux
c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
cJCC(2/10/97) - add display and redocument it
c 
cJCC(1/23/97) - truncate the subroutine name to 6 letters
c              (ie. use "scanls" ) 
c
c#Revision 1.1  1996/11/04  20:46:27  prosb
c#Initial revision
c#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/
c
cC   Scan the line and locate groups of cells above threshold
c
c************************ FFORM VERSION 0.2 **************************
cG  Scan 1 line of detect cells and save start and stop pointers in line
cG  to regions of continuous 'on' cells.
c
c   call_var.                   type I/O  description
cP  FLAGGED_LINE                  I4  I   line of subcells flagged above
cP  NUM_X_SUBCELLS                I4  I   # of subcells on the Y axis 
cP  BLOB_PTRS                     I4  O   buffer of ptrs to blobs in lin
cP  NUM_BLOBS_IN_LINE             I4  O   # of blobs found in this line 
c***********************************************************************
c
c#JCC - rename "scan_line_for_grps_of_on_cells" to "scanls"
      subroutine scanls(flagged_line,
     &num_x_subcells, blob_ptrs, num_blobs_in_line, display )
c                  
c#      implicit undefined (a-z)
      include 'detect.inc'
C
cptr to start of blob
      integer*4 flagged_line(max_subcells)
c
c# of subcells on the Y axis                                            
      integer*4 num_x_subcells
c                
cbuffer of ptrs to blobs in line                                        
      integer*4 blob_ptrs(2, max_blobs)
c                
c# of blobs found in this line                                          
      integer*4 num_blobs_in_line
c                
cindex to blob_ptrs buffer                                              
      integer*4 blob_index, display
c                
cptr to detect cell in Y axis                                           
      integer*4 x_subcell
c the end of a blob region                                              
c                
cflag to indicate if looking for                                        
c                
      logical*4 in_blob

c     type *,"scan_on.f"

      blob_index = 1
      num_blobs_in_line = 0
      x_subcell = 1
      in_blob = .false.

c    Store ptrs to groups of 'on' cells in line
c     call mvzlng(blob_ptrs, (2 * max_blobs))
      call aclrl(blob_ptrs, (2 * max_blobs)) 
c    If 1st in group of 'on' cells; save 1 before for diagonal checking 
c   
      do while (x_subcell .le. num_x_subcells)

        if ((flagged_line(x_subcell).eq.on).and.(.not.in_blob)) then
           blob_ptrs(beg,blob_index) = x_subcell
           num_blobs_in_line = num_blobs_in_line + 1
           in_blob = .true.
c    If 1st 'off' cell after a group of 'on' cells
        else
           if ((flagged_line(x_subcell) .eq. off) .and. in_blob) then
                blob_ptrs(end,blob_index) = x_subcell - 1
                blob_index = blob_index + 1
                in_blob = .false.
           end if
        end if
        x_subcell = x_subcell + 1
c    If at end of the line and still in a blob
      end do

      if (in_blob .eq. .true.) then
        blob_ptrs(end,blob_index) = num_x_subcells
      end if

c#JCC(2/10/97) - display blob information
      if (display.ge.3) then
        print *, "scan_on.f:  #BlobInLine, BlobIndx,xSubcel= "
     &, num_blobs_in_line, blob_index,x_subcell
      end if

      return 
      end
