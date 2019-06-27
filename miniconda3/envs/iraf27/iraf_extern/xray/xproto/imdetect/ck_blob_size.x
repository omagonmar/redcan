#JCC(7/3/97)- convert from fortran to spp
#Revision 1.1  1996/11/04  20:24:06  prosb
#Initial revision
#
#JCC (10/31/96)- copied from /pros/xray/xlocal/imdetect/ck_blob_size.f
#              - add "debug level"
#
#   Check if blob is big enough to possibly contain > 1 source
#
#************************ FFORM VERSION 0.2 **************************
#   general description:
#  Compute the size of the box around a blob and compare those dimensions
#  to our max size parameters.  A box larger than the parameters is 
#  labeled 'big' and is thought to possibly contain more than one source.
#
#   call_var.                   type I/O  description
#P  BOX_X_DIM                     I4  O   size of box in X 
#P  BOX_X_FIRST                   I4  O   1st position of box in X 
#P  BOX_Y_DIM                     I4  O   size of box in Y 
#P  BOX_Y_FIRST                   I4  O   1st position of box in Y 
#P  BIG_BLOB                      L4  O  indicates if blob may contain 1 src 
#***********************************************************************
#
include "detect.h"
procedure ck_blob_size(blob_limits, usr_xbox, usr_ybox, 
     box_x_dim, box_x_ul, box_y_dim, box_y_ul, big_blob,debug)
                  
int blob_limits[BLOB_LIMITS_FIELDS]
                
# max box limit in X, Y from user par 
int usr_xbox, usr_ybox 
                
# size of box in X, Y                                        
int box_x_dim, box_y_dim
                
# 1st position of box in X                                               
int box_x_ul,box_y_ul 
int debug
 
# indicates if blob may contain > 1 src                                  
bool  big_blob
 
begin
    big_blob = FALSE 
    box_y_dim = (blob_limits[Y_MAX] - blob_limits[Y_MIN]) + 1
    box_x_dim = (blob_limits[X_MAX] - blob_limits[X_MIN]) + 1

#   Now compare the size of this blob 'box' to the limits (parameters):
    if (((box_x_dim >= usr_xbox) && (box_y_dim >= usr_ybox))
        || ((box_x_dim >= usr_ybox) && (box_y_dim >= usr_xbox)))
    { 
#    Find the upper left corner of the box (the first cell in it):
         big_blob = TRUE 
         box_y_ul = blob_limits[Y_MIN]
         box_x_ul = blob_limits[X_MIN]
    }
    else
    {  big_blob = FALSE  }
end
