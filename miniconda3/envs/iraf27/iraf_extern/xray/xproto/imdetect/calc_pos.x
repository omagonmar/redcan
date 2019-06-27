# test - convert from fortran  to  spp
#JCC(6/23/97)- remove field_ul_x, field_ul_y
#Revision 1.1  1996/11/04  20:16:25  prosb
#Initial revision
#JCC (12/2/96) - just delete some TYPE statements
#JCC (10/31/96)- copied from /pros/xray/xlocal/imdetect/calc_pos.f
#              - updated to pass "sim and comp_fact_src"
#
#   Compute the centroid and minimum radius of a source
#************************ FFORM VERSION 0.2 **************************
#G  Calculate the centroid position of the blob in subcell units and 
#G  convert it to pixels.  Also calculate the minimum radius
#P  ROUGH_POS                     R4  O   rough Y & X position 
#P  MINIMUM_RADIUS                R4  O   minimum radius of the source 
#***********************************************************************
#
include "detect.h"
procedure cc_position_and_radius(sim,blob_limits, debug, 
     x_zoom, y_zoom, blob_pos_sums, rough_pos, min_radius, 
     xcomp_fact_src, ycomp_fact_src,xshift,yshift )
                   
int blob_limits[BLOB_LIMITS_FIELDS]
int debug, x_zoom, y_zoom
            
#blob centroid calc sums                                                
real blob_pos_sums[BLOB_SUM_FIELDS]

#rough Y and X position                                                   
real rough_pos[2]
 
## JCC (10/30/96) - updated to pass "sim, xcomp_fact_src, ycomp_fact_src"
int  sim                             #source image pointer
int  xcomp_fact_src, ycomp_fact_src  #compress factor for source
real     xphy, yphy                  # xy physical coord
real     xshift, yshift

#minimum radius of the source                                           
real min_radius
                
#rough X position in subcells                                           
real blob_x_centroid, blob_y_centroid

#1/2 box dimension in X                                                 
real half_x_len, half_y_len

begin
#   type *,'calc_pos.f/BlobLimit: xmin, xmax, ymin, ymax = '
#   type *, (blob_limits(kk),kk=2,blob_limits_fields)
#   type *,'calc_pos.f/BlobPosSum: xsum, ysum, cwf_tot ='
#   type *, (blob_pos_sums(kk),kk=1,blob_sum_fields)
 
#   First do a centroid calculation on the blob:
    blob_x_centroid = blob_pos_sums[X_SUM] / blob_pos_sums[TOTAL_CWF]

#   Now find the blob position with reference to the whole field:
    blob_y_centroid = blob_pos_sums[Y_SUM] / blob_pos_sums[TOTAL_CWF]

##  JCC (10/30/96) - replace sub_to_pix with log2phy
##  JCC rough_pos(x_pos)=sub_to_pix(x_zoom,blob_x_centroid,float(field_ul_y))

#   Now calculate the radius of the circle that will include all
#   elements of the blob:
#   JCC (10/30/96) - replace sub_to_pix with log2phy
#   JCC rough_pos(y_pos)=sub_to_pix(y_zoom,blob_y_centroid,float(field_ul_x))
#
    call log2py(debug,sim,blob_x_centroid,blob_y_centroid,xphy,yphy,
         xcomp_fact_src, ycomp_fact_src, xshift, yshift)
 
    rough_pos[X_POS] = xphy
    rough_pos[Y_POS] = yphy

    half_x_len=(((blob_limits[X_MAX] - blob_limits[X_MIN]) +1.0)*x_zoom)/2.0 
    half_y_len=(((blob_limits[Y_MAX] - blob_limits[Y_MIN]) +1.0)*y_zoom)/2.0 
 
    min_radius = sqrt((half_x_len ** 2) + (half_y_len ** 2))
end
