#$Header: /home/pros/xray/xproto/imdetect/RCS/smooth_image.x,v 11.0 1997/11/06 16:39:55 prosb Exp $
#$Log: smooth_image.x,v $
#Revision 11.0  1997/11/06 16:39:55  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:18:49  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:08  prosb
#Initial revision
#
#Revision 1.3  1997/03/21  21:55:55  prosb
#*** empty log message ***
#
#JCC(3/21/97) 
#             - x_cell_size*  --> xcellsize*
#             - y_cell_size*  --> ycellsize*
#             - smooth_factor -> usr_smooth
#             - num_x_subcells  -> outxdim
#             - num_y_subcells  -> outydim
#             - window  -> evt_bk_window
#             - x_res  --> req_blkx
#             - y_res  --> req_blky
#
#Revision 1.2  1997/02/19  15:14:15  prosb
#JCC(2/18/97) - add and pass "xshift & yshift"
#
#Revision 1.1  1996/11/04  21:54:31  prosb
#Initial revision
#
#JCC (10/31/96)- copied from /pros/xray/xlocal/imdetect/smooth_image.x(rev9.0)
#              - get comp_fact out of from imcomp.x & 
#                remove xdetsize/ydetsize from parameters
#              - add comp_fact, display and remove xdetsize from parameter
#
# Compress and smooth an imagefile and return result in a array

procedure smooth_image(sbim, outxdim, outydim, usr_smooth, xcellsize, 
        ycellsize, evt_bk_window,xcomp_fact, ycomp_fact, display,xshift,yshift)

int sbim		# i: source or bkgd image 
int usr_smooth	        # i: user input for smooth factor ("subcells")
int xcellsize           # i: user input: size of a detect cell in the y dir
int ycellsize           # i: user input: size of a detect cell in the Y dir

pointer evt_bk_window	# i/o:  evt_window or bk_window in get_window.x 
int outxdim	        # o: output dim of evt_window from imcomp.x 
int outydim	        # o: output dim of evt_window from imcomp.x 
int loutxdim		# l: local output x dim of evt_window or bk_window
int loutydim		# l: local output y dim of evt_window or bk_window

int req_blkx            # l: request block in x dir 
int req_blky		# l: request block in y dir 

#JCC (10/29/96)
int    xcomp_fact, ycomp_fact       #compress factors used in log2phy.x
int    display 
real   xshift, yshift

begin

#    Read the image files at y_zoom*z_zoom pixels per array element
#    and smooth the elements over usr_smooth in each coordinate

#    Set up the center of the field 
#    Set up the resolution factor  (request block:  req_blk)

        req_blkx = xcellsize / usr_smooth
        req_blky = ycellsize / usr_smooth

	call imcomp(sbim, req_blkx, req_blky, usr_smooth, evt_bk_window, 
          loutxdim, loutydim, xcomp_fact, ycomp_fact, display, xshift, yshift)

	outxdim = loutxdim
	outydim = loutydim
end
