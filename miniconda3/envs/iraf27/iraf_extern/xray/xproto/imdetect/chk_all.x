# JCC(7/97)- convert resolve_src.f to resolve_src.x, call resolve_src()
#          - convert ck_blob_size.f to ck_blob_size.x, call ck_blob_size()
#          - convert calc_pos.f to calc_pos.x
#          - initialize   peak_pos()
#          - pass mxsrc to out_rough()  (= max_src_num from user)
##JCC(6/24/97)- display message when calling resolve_srcs
##JCC(6/23/97)- remove field_ul_x, field_ul_y when calling resolv_src()
##            - and cposra()
##JCC(3/20/97)- calculate_position_and_radius() --> cposra()
#             - init_blob_info() --> intbb()
#             - resolve_srcs()   --> rlvsrc()
#             - max_num_blobs --> usr_max_bb
#             - x_cell_size --> xcellsize 
#             - y_cell_size -->  removed
#
#JCC(3/20/97)- convert checks.f to chk_all.x
#JCC(3/13/97)- Rename check_blob_size() to ckb_size2() --> ckksiz()
#
#JCC(3/7/97) - add "implicit undefined (a-z)"
#
#JCC(2/18/97)- add "xshift  yshift"
#JCC(2/10/97)- remove "bk_window  bim" (with # in the front )
#            - use "type *" instead of "wrlog"
#            - save fd for the output file (*.reg) ;
#              save rough_pos[2] ;
#              save itp for out_ruf.tab
#JCC (1/23/97) - print out checks when display >=   6
#JCC (12/6/96) - "call resolve_src" also change "display", save it first.
#JCC (12/4/96) - for some reason "call resolve_src" changes the value
#                of xcellsize (ie. cellx  celly in output table).
#                (Note: it does not change y_cell_size).
#                Save xcellsize first to fix the problem.
#
#Revision 1.1  1996/11/04  20:25:27  prosb
#Initial revision
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/checks.f
#               - updated to pass "sim  comp_fact_src"
#c
#cC  Find complete blobs, calculate the position, and output the info
#c
#c************************ FFORM VERSION 0.2 **************************
#c   author : JD                date: 9-JUN-1986 09:24
#c   general description:
#cG  Find blobs that haven't been updated after scanning the current line
#cG  or have reached our set limits and call them 'complet'.  Calculate
#cG  the position, and see if the blob is 'big'(has dimensions larger than
#cG  that set as a parameter), if it is 'big' resolve the blob for peaks
#cG  and output the peak positions if they were found or the calculated
#cG  centroid if there were non found. If the blob was not 'big', the
#cG  centroid position is saved.
#c***********************************************************************
#
##  evt_window, field_ul_x, field_ul_y, usr_max_bb, num_xsubcells, 
include "detect.h"
procedure chk_all(sim, usr_bb_size, usr_xbox, usr_ybox, display, 
    evt_window, usr_max_bb, num_xsubcells, num_ysubcells, itp , 
    fd, colptr, y_subcell, xcellsize, x_zoom, y_zoom, 
    blob_limits_rec, bb_out, rowcnt, blob_pos_sums_rec,
    xcomp_fact_src,ycomp_fact_src,xshift,yshift, mxsrc )
#
int usr_bb_size                   # blob size limit from user
int usr_xbox, usr_ybox            #c max size of a box in X  Y
#c display level
int display, display2
#
#c zoomed and smoothed image
int num_xsubcells, num_ysubcells
  
##real*4 evt_window[num_xsubcells, *]
pointer  evt_window
  
#c upper left X  Y field position
##  int field_ul_x, field_ul_y
  
#c max # of blobs allowed : an input from user
int  usr_max_bb 
  
#c rough output logical unit
pointer  itp , itp_tmp    # output root_ruf.tab
pointer  fd, fd_tmp       # output *.reg
  
#c current line we are working on
pointer colptr[ARB]
  
int y_subcell
#c size of a detect cell in X, Y
  
int xcellsize
int tmp
  
#c zoom in X, Y
int x_zoom, y_zoom
  
#c zoomed and smoothed bkgd map
  
#   real bk_window[NUM_XSUBCELLS, *]
#c   min  max blob positions
  
int blob_limits_rec[BLOB_LIMITS_FIELDS, MAX_BLOBS]
#c current blob written out
  
int bb_out      ####blobs_out
# sources within a blob counter
  
int rowcnt      ##rough_pos_out  : row count in root_ruf.tab
#c centroid calc position sums
  
real blob_pos_sums_rec[BLOB_SUM_FIELDS, MAX_BLOBS]
  
#c index thru blob buffers
int blob_num
#c
#c length of a blob in Y subcells
int bb_ylen      ##blob_y_length
#c
#c size of box in X  Y
int box_x_dim, box_y_dim
#c
#c 1st detect cell position in X
int box_x_ul , box_y_ul 
#c
#c # of sources to output
int num_sources
#c
#c # peaks found in a source
int peaks_found
#c
#c flag indicating whether a source
#c is big enough to contain > 1 src
bool  big_blob
#c
#c finished flag
bool  complet 
#c
#c minimum radius of the source
real min_radius
#c
#c peak positions of a source 
real peak_pos[2, MAX_POS]
#c
#c computed rough position of a source
real rough_pos[2], rough_pos2[2]
#c
# JCC (10/30/96) - updated to pass "sim  comp_fact_src"
int  sim                             #!source image pointer
int  xcomp_fact_src, ycomp_fact_src  #!compress factor for src
real     xshift, yshift
int  ttt, ii, jj
int  mxsrc  # max_src_num from user par (replace MAX_SRCS)

begin
  if (display >=  6) {
     call printf("\n chk_all \n")     # JCC  print (checks\n)
  }     

# JCC (12/4/96) - save xcellsize first
  tmp = xcellsize
  display2 = display
  itp_tmp = itp
  fd_tmp = fd

  do blob_num = 1, usr_max_bb {
     complet  = FALSE

#c  Check for blobs that haven't been updated in last pass - they are 
#c  completed  OR those still active after processing the last line
     peaks_found = 0

#jcc - reset peak_pos[2,250] 
    do ii = 1,2
    {  
       do jj=1, MAX_POS
       {  
         peak_pos[ii,jj] = 0.0
       }
    }   
    rough_pos[1] = 0.0
    rough_pos[2] = 0.0


     if (blob_limits_rec[STATUS,blob_num] == ON ){
        if ((blob_limits_rec[Y_MAX,blob_num] <  y_subcell) 
   	     || (num_ysubcells == y_subcell))    {
            complet  = TRUE
        }     

#c    The blob is also completed  if it has reached our size limit
        bb_ylen  = (blob_limits_rec[Y_MAX,blob_num] - 
                        blob_limits_rec[Y_MIN,blob_num]) + 1

        if (bb_ylen  >  usr_bb_size) {
           complet  = TRUE
        }     

#c    Calculate the position and radius of completed blobs
        if (complet ) {
           if (display >=   4) {
              call printf("chk_all: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
              call printf("~~~~~~~~~~~~~~BLOB= %d \n")
              call pargi(bb_out+1) 
           }     
# JCC(3/20/97) - calculate_position_and_radius() --> cposra()
           ###call cposra(sim,blob_limits_rec[1,blob_num], 
           call cc_position_and_radius(sim,blob_limits_rec[1,blob_num], 
                display,x_zoom, y_zoom, blob_pos_sums_rec[1,blob_num], 
                rough_pos, min_radius, xcomp_fact_src, ycomp_fact_src, 
                xshift, yshift)

           rough_pos2[1] = rough_pos[1]
           rough_pos2[2] = rough_pos[2]

           big_blob = FALSE
           ###call ckksiz(blob_limits_rec[1,blob_num], usr_xbox,
           call ck_blob_size(blob_limits_rec[1,blob_num], usr_xbox, 
               usr_ybox,box_x_dim,box_x_ul,box_y_dim,box_y_ul,
               big_blob, display)

# JCC (12/4/96) - put xcellsize back after calling resolve_srcs
# JCC (10/30/96) - updated to pass "sim  comp_fact_src"
#c JCC(3/20/97) - rename resolve_srcs() to rlvsrc()
# for a big blob, it is possibly contain > 1 source
##   Memr[evt_window],field_ul_x, field_ul_y, x_zoom, y_zoom, 
           if (big_blob) {
             if (display2 > 1 )
             {  call printf(" big_blob = true, calling resolve_src \n")
                call printf("  box_x_dim,box_x_ul,box_y_dim,box_y_ul= %d  %d  %d  %d \n")
                call pargi(box_x_dim)
                call pargi(box_x_ul)
                call pargi(box_y_dim)
                call pargi(box_y_ul)
             }

               # resolve_src() uses ck_smoothed_blob_for_peaks() to 
               # get peak_pos[2,MAX_POS]
               call resolve_src(sim,box_x_dim,box_x_ul,box_y_dim,
                 box_y_ul, display, num_xsubcells, num_ysubcells, 
                 Memr[evt_window], x_zoom, y_zoom, 
                 peaks_found, peak_pos, xcomp_fact_src, ycomp_fact_src, 
                 xshift, yshift )

               if (display2 > 1 )
               { 
                  call printf("  after resolve_src....peaks_found=%d\n")
                  call pargi(peaks_found)
                  do ttt=1, peaks_found
                  {   call printf("  peak_pos=  %d %f %f  \n")
                      call pargi(ttt)
                      call pargr(peak_pos[1,ttt])
                      call pargr(peak_pos[2,ttt])
                  }
               }

              xcellsize = tmp
              display = display2
           }     

           rough_pos[1] = rough_pos2[1]
           rough_pos[2] = rough_pos2[2]
           itp = itp_tmp
           fd = fd_tmp

           bb_out = bb_out + 1

#c Output Peak Positions                                                 
#c             
           if (peaks_found > 1) {
              num_sources = peaks_found
              call out_rough(display, num_sources, bb_out, itp, fd, 
              colptr, xcellsize, min_radius, peak_pos, rowcnt, mxsrc )
           }

#c Output Centroid Calculation                                            
          else  {
              num_sources = 1
              call out_rough(display, num_sources, bb_out, itp, fd, 
              colptr,xcellsize, min_radius, rough_pos, rowcnt, mxsrc )
          }     
#c Now reset the blob position and limit info - buffer will be reused
#c init_blob_info() --> intbb()
          call intbb(blob_limits_rec[1,blob_num], 
     		blob_pos_sums_rec[1,blob_num])
      }     #end if (blob_limits_rec[STATUS,blob_num] == ON 
   }        #end if (complet )

#jcc - reset  peak_pos[2,250]  
    do ii = 1,2
    {  
       do jj=1, MAX_POS
       {
         peak_pos[ii,jj] = 0.0
       }
    }
    rough_pos[1] = 0.0
    rough_pos[2] = 0.0

    if (rowcnt > mxsrc )    # replace MAX_SRCS with mxsrc
      break

 }          # end do 
end
