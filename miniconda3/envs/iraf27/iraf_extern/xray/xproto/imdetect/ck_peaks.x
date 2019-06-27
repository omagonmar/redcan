#JCC(7/3/97) - peaks_found more than MAX_POS, then don't write
#              to peak_pos[2, MAX_POS]
#JCC(6/24/97) - convert fortran to spp
#JCC(6/24/97) - remove rtname
#JCC(6/23/97) - remove the calls to wrlog()
#             - remove field_ul_x, field_ul_y
#JCC(3/13/97) - Rename check_smoothed_blob_for_peaks() to ckdet_peak().
#JCC(3/7/97)  - add "implicit undefined (a-z)"
#JCC(2/18/97) - add "xshift & yshift"
#JCC(1/23/96) - updated to pass "debug" to log2py
#
#Revision 1.1  1996/11/04  20:09:59  prosb
#Initial revision
#JCC(10/31/96)- copied from /pros/xray/xlocal/imdetect/ck_peaks.f
#              - replace sub_to_pix with a new code "log2phy" 
#              - updated to pass "sim, xcomp_fact_src, ycomp_fact_src"
#************************ FFORM VERSION 0.2 **************************
#   general description:
#G  Identify peaks by comparing the center element of each detect cell 
#G  of our background subtracted array to its neighbors and saving info
#G  on those with a center value greater than that of those around it
#
#P  PEAKS_FOUND                   I4  O   # of peaks located in the box 
#P  PEAK_POS                      I4  O   positions of the peaks found 
#***********************************************************************
#
include "detect.h"
procedure ck_smoothed_blob_for_peaks(sim,box_x_dim, 
     box_x_ul, box_y_dim, box_y_ul, debug,
     x_zoom, y_zoom, ncnt_in_box, peaks_found, peak_pos,
     xcomp_fact_src, ycomp_fact_src, xshift, yshift )
#
#size of the box in Y                                                   
int   box_x_dim, box_y_dim
#                 
int   box_x_ul, box_y_ul
#                 
int   debug
#                 
#jcc  int field_ul_x, field_ul_y
#                 
int x_zoom, y_zoom
#                 
# net counts in box
real   ncnt_in_box[0:MAX_BOX, 0:MAX_BOX]
#                 
# number of peaks located in the box                                          
int   peaks_found
#
#positions of the peaks found                                           
real peak_pos[2, MAX_POS]
#
int    x, y
#                 
#net counts in a detect cell                                            
real   cnt
#                 
#X subcell position in field                                            
real   x_position, y_position

int    sim           #source image
real   xphy, yphy    #xy physical coord
int    xcomp_fact_src, ycomp_fact_src
real   xshift, yshift

begin
#  CHECK our bkgd subtracted array for peaks by comparing the center 
#  element of each detect cell to its neighbors. 
  peaks_found = 0
  call aclrr(peak_pos, (2 * MAX_POS) )
  do y = 1, box_y_dim
  {
    do x = 1, box_x_dim
    {
       cnt= ncnt_in_box[x,y]
       if (cnt > 0) 
       {
          if ((((((((cnt > ncnt_in_box[x-1, y-1]) && (
            cnt > ncnt_in_box[x-1, y])) && (cnt >  
            ncnt_in_box[x-1, y+1])) && (cnt > ncnt_in_box[
            x, y-1])) && (cnt > ncnt_in_box[x, y+1])) && (
            cnt > ncnt_in_box[x+1, y-1])) && (cnt >  
            ncnt_in_box[x+1, y])) && (cnt > ncnt_in_box[x+1, y+1]))
          { 
              peaks_found = peaks_found + 1

              x_position = (x + box_x_ul) - 1

#JCC (1/23/96) - updated to pass "debug" to log2py
#JCC (10/24/96) - replace sub_to_pix with log2phy
#peak_pos(X_POS,peaks_found]=sub_to_pix(x_zoom,x_position,float(field_ul_y))
#peak_pos(Y_POS,peaks_found]=sub_to_pix(y_zoom,y_position,float(field_ul_y))

              y_position = (y + box_y_ul) - 1   #don't comment this out 
              call log2py(debug,sim,x_position,y_position,xphy,yphy,
                   xcomp_fact_src,ycomp_fact_src, xshift, yshift)

              if (peaks_found <= MAX_POS)
              {
                   peak_pos[X_POS, peaks_found] = xphy
                   peak_pos[Y_POS, peaks_found] = yphy
              }

           }   # end if
        }   # end if

        if (peaks_found > MAX_POS )
           break

     }   # end do 

        if (peaks_found > MAX_POS )
        {
           call printf ("Max peaks limit ( %d ) exceeded\n")
           call pargi(MAX_POS) 
           break
        }

   }   # end do 
end
