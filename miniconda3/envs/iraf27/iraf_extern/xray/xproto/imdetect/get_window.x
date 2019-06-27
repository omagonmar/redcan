#$Header: /home/pros/xray/xproto/imdetect/RCS/get_window.x,v 11.0 1997/11/06 16:39:54 prosb Exp $
#$Log: get_window.x,v $
#Revision 11.0  1997/11/06 16:39:54  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:17:49  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:02  prosb
#Initial revision
#
#Revision 1.5  1997/03/21  21:55:49  prosb
#*** empty log message ***
#
#JCC(3/21/97) - detect_slide  -> usr_smooth
#             - x_cell_size*  --> xcellsize*
#             - y_cell_size*  --> ycellsize*
#             - num_x_subcells  -> outxdim
#             - num_y_subcells  -> outydim
#             - no_bkx_subcells -> bkg_outxdim
#             - no_bky_subcells -> bkg_outydim
#
#Revision 1.4  1997/03/05  14:52:29  prosb
#JCC(3/5/97) - display the source info for a higer debugger level.
#
#Revision 1.3  1997/02/19  15:14:06  prosb
#JCC(2/18/97) - add and pass "xshift & yshift"
#
#Revision 1.2  1997/02/10  21:57:22  prosb
#JCC(2/10/97) - remove "bk_window & bim" (with #&& in the front )
#
#Revision 1.1  1996/11/04  21:51:28  prosb
#Initial revision
#JCC (10/31/96)- copied from /pros/xray/xlocal/imdetect/get_window.x (rev9.0)
#              - remove xcenter/ycenter and xdetsize/ydetsize from parameter
#              - get comp_fact for source and bkgd out of from smooth_image
#              - no need to compare "outxdim (for source)" 
#                with "bkg_outxdim (for bkgd)"  because we implemet
#                a new way to calculate "current_block" in imcomp
#
include		"detect.h"

define	DET_ERROR		1

#   Determine the coordinates of the corners of the field; the zoom;
#   and the # of subcells in the arrays that will store the smoothed
#   and zoomed poe and bkmaps. Finally read the poe and bkmap with
#   these inputs and the 2 dimensional arrays are returned as the
#   programs windows in looking at the field.

#JCC(2/10/97) - remove "bim & bk_window"
procedure get_window(display, usr_smooth, sim, xcellsize, ycellsize, 
     arcsec_per_pix, outxdim, outydim, evt_window, field_ul_x, 
     field_ul_y, x_zoom, y_zoom, xcomp_fact_src, ycomp_fact_src, 
     xshift, yshift )

int  display                #i: display level	
int  sim                    #i: pointer to source image file
int  usr_smooth	            #i: user input for smooth factor ("subcells") 

#&& int	bim	                #i:   pointer to bkgd image file
#&& pointer bk_window	        #i/o: pointer to background data array
#&& int	bkg_outxdim             #o: output dim of bk_window from imcomp.x
#&& int	bkg_outydim             #o: output dim of bk_window from imcomp.x
#&& int xcomp_fact_bk           #l: compress factor of x for bkgd  
#&& int ycomp_fact_bk           #l: compress factor of y for bkgd  
#JCC int x_det_cen		# i: x detector center
#JCC int y_det_cen		# i: y detector center
#JCC int x_det_size		# i: x detector size
#JCC int y_det_size		# i: y detector size
#JCC int lfield_lr_x		# l: lower right corner in x
#JCC int lfield_lr_y		# l: lower right corner in t

int xcellsize              # user input: size of a detect cell in the y dir
int ycellsize              # user input: size of a detect cell in the Y dir
real  arcsec_per_pix		#

pointer	evt_window	   #i/o: pointer to source data array
int   outxdim              #o: output dim of evt_window from imcomp.x 
int   outydim              #o: output dim of evt_window from imcomp.x


int   field_ul_x		# o: upper left corner in x
int   field_ul_y		# o: upper left corner in y
int   x_zoom			# o: compress factor in x
int   y_zoom			# o: compress factor in y

#JCC (10/30/96) - new pars out of from smooth_image.x
int   xcomp_fact_src      #o: compress factor of x for source
int   ycomp_fact_src      #o: compress factor of y for source
real  xshift, yshift

begin

#    Calculate upper left field and lower right field coordinates
#       field_ul_x = x_det_cen - ((x_det_size - 1) / 2)
#       field_ul_y = y_det_cen - ((y_det_size - 1) / 2)
	field_ul_x = 1
	field_ul_y = 1
#       lfield_lr_x = field_ul_x + x_det_size  

#    Determine the zoom of our window
#       lfield_lr_y = field_ul_y + y_det_size 
        x_zoom = xcellsize / usr_smooth
        y_zoom = ycellsize / usr_smooth
        if (display >  2)
	{
	    #call printf("get_window : lr_x= %d lr_y= %d ul_x= %d ul_y= %d \n")
	    call printf("get_window : ul_x= %d ul_y= %d \n")
	    #call pargi(lfield_lr_x)
	    #call pargi(lfield_lr_y)
	    call pargi(field_ul_x)
	    call pargi(field_ul_y)
      	    call printf("xzoom: %d yzoom: %d")
	    call pargi(x_zoom)
	    call pargi(y_zoom)
	}

#    Check if bounds fall on subcell boundaries
#        if ( (mod(lfield_lr_y- field_ul_y, y_zoom) != 0 ) ||
#         (mod(lfield_lr_x- field_ul_x, x_zoom) != 0 ) ) 
#	{
#    call eprintf("lr_x: %d lr_y: %d ul_x: %d ul_y: %d xzoom: %d yzoom: %d\n")
#	      call pargi(lfield_lr_x)
#	      call pargi(lfield_lr_y)
#	      call pargi(field_ul_x)
#	      call pargi(field_ul_y)
#	      call pargi(x_zoom)
#	      call pargi(y_zoom)
#	    call error(DET_ERROR,"dimension not a multiple of zoom")
#	    call eprintf("WARNING: dimension not a multiple of zoom")
#	}

# **** Moved this calculation to IMCOMP ***
#    Determine the dimensions of out window
#        outxdim = x_det_size / x_zoom +  
#		min(1,min(x_det_size,x_zoom)) - (usr_smooth-1)
#        
#	outydim = y_det_size / y_zoom +  
#		min(1,min(y_det_size,y_zoom)) - (usr_smooth-1)

# **** ARRAYS no longer static dimension - check not needed *****
#        if ( (outxdim > MAX_SUBCELLS) || 
#	     (outydim > MAX_SUBCELLS) ) 
#	{
#	     call eprintf("Max number of subcells: %d  exceeded: %d %d\n")
#		call pargi(MAX_SUBCELLS)
#		call pargi(outxdim)
#		call pargi(outydim)
#	     call error(DET_ERROR,"Too many SUBCELLS")
#      	}
 
# ----------   for source      ----------------------
        if (display.ge.3) call eprintf("\n\n****** SOURCE ******\n")
# JCC (10/30/96) - get outxdim and comp_fact for source
# JCC   call smooth_image(sim, outxdim, outydim, usr_smooth, 
# JCC        x_det_size, y_det_size, xcellsize, ycellsize, evt_window,
        call smooth_image(sim, outxdim, outydim, usr_smooth, 
           xcellsize, ycellsize, evt_window,
           xcomp_fact_src, ycomp_fact_src, display, xshift,yshift )
        if (display.ge.3) call eprintf("\n**********************\n")

# -----------  for background  ----------------------
# JCC (10/30/96) - get bkg_outxdim and comp_fact for bkgd
# JCC   call smooth_image(bim, bkg_outxdim, bkg_outydim, 
# JCC      usr_smooth, x_det_size, y_det_size, xcellsize, ycellsize, 
#
#JCC (2/10/97) - remove the background from the user input
#&&     call smooth_image(bim, bkg_outxdim, bkg_outydim, 
#&&     usr_smooth, xcellsize, ycellsize, 
#&&     bk_window, xcomp_fact_bk, ycomp_fact_bk, display)
# ---------------------------------------------------

#JCC (10/29/96)- No need to compare *x_subcells between source and bkgd 
	#if( outxdim != bkg_outxdim  ||
	#   outydim != bkg_outydim    ) 
	#{
        if (display >= 2 )
        {
#&& call eprintf("\nget_window:  source dimension : %d %d, bkgd dim : %d %d\n")
    call eprintf("\nget_window:  source dimension : %d %d \n")
           call pargi(outxdim)
	   call pargi(outydim)
#&&        call pargi(bkg_outxdim)
#&&        call pargi(bkg_outydim)

           call eprintf("get_window: compress factor for source: %d %d \n")
           call pargi(xcomp_fact_src)
           call pargi(ycomp_fact_src)

#&&        call eprintf("get_window: compress factor for bkgd  : %d %d \n")
#&&        call pargi(xcomp_fact_bk )
#&&        call pargi(ycomp_fact_bk )
	   # call error(DET_ERROR,"Bad background file dimension")
	}
end
