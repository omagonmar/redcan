c#JCC(1/16/98)- remove "implicit (a-z)" for alpha
c#JCC(3/7/97) - add "implicit undefined (a-z)"
c#
c#JCC(2/6/97) - remove bk_strip (with #&& in the front)
c JCC(1/23/97) - truncate subroutine name to 6 letters
c               (ie  compute_detect_cell_snr_thresh -->  cmpsnr )
c
cC   Scan 1 line & flag detect cells with a computed snr above threshold
c************************ FFORM VERSION 0.2 **************************
cG  Scan 1 line of detect cells and compute snr for each cell.  Flag
cG  the cells with a computed snr above the threshold for the current
cG  cell size by setting the position to 1.
c
c   call_var.                   type I/O  description
cP  DEBUG                         I4  I   debug level 
cP  EVT_STRIP                     I4  I   1 line of det cell img cts 
cP  NUM_X_SUBCELLS                I4  I   # of subcell in Z direction 
cP  BK_STRIP                      R4  I   1 line of det cell bk cts 
cP  CELL_SIZE_SNR_THRESH          R4  I   snr thresh for a detect cell 
cP  FLAGGED_LINE                  I4  O   1 line of detect cells flagged
c***********************************************************************
c
      subroutine flag1s(debug, evt_strip, 
     &num_x_subcells, cell_size_snr_thresh, flagged_line)
c#&& &num_x_subcells, bk_strip, cell_size_snr_thresh, flagged_line)
c                   
c#    implicit undefined (a-z)
      include 'detect.inc'
c
c ptr to start of blob
      integer*4 debug
c 1 line of det cell img cts                                             
c              
c      integer*4 evt_strip(max_subcells)
      real*4 evt_strip(max_subcells)
c # of subcell in Z direction                                            
c              
      integer*4 num_x_subcells
c 1 line of det cell bk cts                                              
c              
c #&&   real bk_strip(max_subcells)
c    Outputs:
c snr thresh for a detect cell                                           
c              
      real cell_size_snr_thresh
c above or below threshold                                               
c              
c 1 line of detect cells flagged                                         
c              
      integer*4 flagged_line(max_subcells)
c              
cindex along z-axis                                                     
c              
      integer*4 x_subcell
ccomputed det cell snr                                                  
c              
      real det_cell_snr
c
c    Slide horizontally along z
      do x_subcell = 1, num_x_subcells

c    Flag position if our detect cell snr exceeds the threshold for
c    the current cell size

c#JCC(1/23/97) - rename "compute_detect_cell_snr_thresh to cmpsnr" 
c#&& JCC(2/10/97) - remove bk-strip
c#&&  call cmpsnr(evt_strip(x_subcell),bk_strip(x_subcell),det_cell_snr)
          call cmpsnr(evt_strip(x_subcell), det_cell_snr)

      if (det_cell_snr .gt. cell_size_snr_thresh) then
          flagged_line(x_subcell) = on
      else
          flagged_line(x_subcell) = off
      end if
c
      end do
      return 
      end
