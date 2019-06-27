#JCC(12/10/97)- bugfixed to remove the "extra" parameter when calling
#               ck_smoothed_blob_for_peaks()
#JCC(6/27/97) - convert from fortran to spp
#JCC(6/23/97)- remove field_ul_x, field_ul_y
#JCC(3/20/97)- Rename resolve_srcs() to rlvsrc()
#JCC(3/13/97)- Rename check_smoothed_blob_for_peaks() to ckdet_peak()
#
#JCC(3/7/97) - add "implicit undefined (a-z)"
#
#JCC(2/18/97)- add "xshift & yshift"
#JCC(2/6/97) - remove bk_window 
#
#Revision 1.1  1996/11/04  20:24:34  prosb
#Initial revision
#JCC (10/31/96)- copied from /pros/xray/xlocal/imdetect/resolve_srcs.f
#              - updated to pass "sim, xcomp_fact_src, ycomp_fact_src"
#C   Resolve sources in a blob box for peak positions
#************************ FFORM VERSION 0.2 **************************
#G  Get the net counts in a box around a blob and scan that area for
#G  peaks, and return peak information.
#
#   call_var.                   type I/O  description
#P  BOX_X_DIM                     I4  I   size of box in X 
#P  BOX_X_FIRST                   I4  I   1st subcell of box in X 
#P  BOX_Y_DIM                     I4  I   size of box in Y 
#P  BOX_Y_FIRST                   I4  I   1st subcell of box in Y 
#P  DEBUG                         I4  I   debug level 
#P  EVT_WINDOW                    I4  I   
#P  FIELD_UL_X                    I4  I   upper left coord of field in Y
#P  FIELD_UL_Y                    I4  I   upper left coord of field in Y
#P  X_ZOOM                        I4  I   zoom in X 
#P  Y_ZOOM                        I4  I   zoom in Y 
#P  BK_WINDOW                     R4  I   
#P  PEAKS_FOUND                   I4  O   # of peaks located 
#P  PEAK_POS                      R4  O   peak positions buffer 
#***********************************************************************
#
include "detect.h"
procedure resolve_src(sim,box_x_dim, box_x_ul, box_y_dim, 
      box_y_ul, debug, outxdim, outydim, evt_window, 
      x_zoom, y_zoom, peaks_found, 
      peak_pos,xcomp_fact_src, ycomp_fact_src, xshift, yshift)
#
# 1st subcell of box in X, Y 
int  box_x_ul, box_y_ul 
#                 
#size of box in X, Y                                                       
int   box_x_dim, box_y_dim
int   debug
#                 
# zoomed & smoothed image                                                
real  evt_window[outxdim, *]
int   outxdim, outydim
#                 
#  zoom in X, Y                                              
int   x_zoom, y_zoom
#                 
#    Outputs:
#zoomed & smoothed bkgd                                                  
##real bk_window[outxdim, outxdim]
#                 
#  # of peaks located                                                     
int   peaks_found
#                 
real peak_pos[2, MAX_POS]
#                 
# net counts in a box around a blob                                      
real net_cts_in_box[0:MAX_BOX, 0:MAX_BOX]

int   sim                             #source image pointer
int   xcomp_fact_src, ycomp_fact_src  #compress factor for source
real  xshift, yshift

begin
## bk_window, net_cts_in_box, debug)
     call get_net_counts_in_blob_box(box_x_dim, box_x_ul,box_y_dim,
          box_y_ul, outxdim, outydim, evt_window, 
          net_cts_in_box, debug)

# JCC (10/30/96) - updated to pass "sim, xcomp_fact_src, ycomp_fact_src"
# JCC (3/13/97) - Rename  check_smoothed_blob_for_peaks  to  ckdet_peak
#      call check_smoothed_blob_for_peaks(sim,box_x_dim, box_x_ul, 
#box_y_dim, box_y_ul, debug, field_ul_x, field_ul_y, x_zoom, 

###call printf("calling ck_smoothed_blob_for_peaks....\n") 

     call ck_smoothed_blob_for_peaks (sim,box_x_dim, box_x_ul, 
          box_y_dim, box_y_ul, debug, x_zoom, 
          y_zoom, net_cts_in_box, peaks_found, peak_pos,
          xcomp_fact_src, ycomp_fact_src, xshift, yshift )

###call printf("after ck_smmothed_blob_for_peaks..\n")
 
end
