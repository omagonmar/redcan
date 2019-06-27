#JCC(6/27/97) - convert from fortran to spp
#JCC(3/7/97) - add "implicit undefined (a-z)"
#
#JCC(2/6/97) - remove bk_window (with #&& in the front)
#
#Revision 1.1  1996/11/04  20:18:42  prosb
#Initial revision
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/get_net_cts.f
#************************ FFORM VERSION 0.2 **************************
#G  Get the net counts ( poe - bkgd ) of a box around a blob and return 
#G  the array of background subtracted counts.
#P  NET_CTS_IN_BOX                R4  O   
#***********************************************************************
##&&  &bk_window, net_cts_in_box, debug)
include "detect.h"
procedure get_net_counts_in_blob_box(box_x_dim, box_x_ul, 
     box_y_dim, box_y_ul, outxdim, outydim, evt_window, 
     net_cts_in_box, debug)
#
#dimensions of the box in X & Y                                             
int  box_x_dim, box_y_dim
#                 
#ptr to first box cell in X & Y                                             
int  box_x_ul, box_y_ul
#                 
#zoomed and smoothed image counts                                       
real evt_window[outxdim, *]
#                 
#zoomed and smoothed bkgd                                               
##&&   real bk_window[outxdim, *]

int outxdim, outydim
#                 
real net_cts_in_box[0:MAX_BOX, 0:MAX_BOX]

#index to last X cell of box                                            
int box_x_last, box_y_last
#                 
int norm_x, norm_y

int x_subcell, y_subcell
#                 
int  debug
begin
      call aclrr(net_cts_in_box, (MAX_BOX+1)*(MAX_BOX+1) )

      #call printf("get_net_cnt: box_x_ul, box_y_ul= %d %d\n")
      #call pargi(box_x_ul)
      #call pargi(box_y_ul)

      #call printf("get_net_cnt: box_x_dim, box_y_dim= %d %d\n")
      #call pargi(box_x_dim)
      #call pargi(box_y_dim)

      box_y_last = (box_y_ul+ box_y_dim) - 1
      box_x_last = (box_x_ul+ box_x_dim) - 1
      do y_subcell = box_y_ul, box_y_last
      {
        do x_subcell = box_x_ul, box_x_last
        {
          norm_x = (x_subcell - box_x_ul) + 1
          norm_y = (y_subcell - box_y_ul) + 1
          net_cts_in_box[norm_x,norm_y]= evt_window[x_subcell,y_subcell] 
##&&                                    - bk_window[x_subcell,y_subcell)
        }
     }
end
