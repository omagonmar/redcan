#$Header: /home/pros/xray/xplot/imcontour/RCS/imcontour.x,v 11.0 1997/11/06 16:38:14 prosb Exp $
#$Log: imcontour.x,v $
#Revision 11.0  1997/11/06 16:38:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:09:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:53  prosb
#General Release 2.3
#
#Revision 6.2  93/12/17  08:57:16  janet
#jd - 'free'd x/y pos allocated in the src read routines.
#
#Revision 6.1  93/07/02  15:09:48  mo
#MC	7/2/93		Correct the type for 'clopset' and remove
#			redundant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:41:24  prosb
#General Release 2.2
#
#Revision 5.2  93/05/13  11:30:13  janet
#fixed ascii list/table identification after TABLES update broke code.
#
#Revision 5.1  93/04/06  11:57:56  janet
#updated to accept non-square data.  Src list display skipped if no sources.
#
#Revision 5.0  92/10/29  22:35:26  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:33:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/24  16:45:58  janet
#changed wcspars to gridpars becauese of naming conflict.
#
#Revision 3.2  92/01/15  13:31:21  janet
#added pset param file.
#
#Revision 3.1  92/01/15  10:45:38  janet
#added source table input.
#
#Revision 3.0  91/08/02  01:24:08  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:48  wendy
#Initial revision
#
#Revision 2.3  91/07/03  09:55:55  janet
#preliminary updates for wcslab interface.
#
#Revision 2.2  91/05/30  12:39:38  janet
#rearranged a few calls so that graphics device is open when the 
#src data is read.  Added out of range check in src_data that required
#open graphics.
#
#Revision 2.0  91/03/06  23:21:20  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:	IMCONTOUR.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Task to contour an image on either a Celestial or Pixel Grid
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- October 1989 -- initial version
#		{1} JD -- May 1991 -- Update 'QUIT' comment to only
#                         	      display when cgraph = no
#		{2} JD -- Jun 1991 -- preliminary updates for wcslab interface
#               {3} JD -- Sep 1991 -- added Src table input
#               {4} JD -- Dec 1992 -- updated so that default scale is based
#				      on the longest side of the image if they
#				      are not equal.
#		{#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
include <gset.h>
include <imhdr.h>
include <ext.h>
include <mach.h>
include "imcontour.h"
include "clevels.h"

procedure t_imcontour()

pointer buff			# temporary buffer
pointer device                  # display device
pointer gbuff			# temporary buffer
pointer err_fname		# error image filename
pointer img_fname		# image filename
pointer plt_title		# plot title
pointer plt_files		# plot filename(s)
pointer src_fname		# source table filename
pointer maptype                 # map grid type: SKY or PIXEL
pointer er                      # error image handle
pointer gp			# graphics pointer
pointer im                      # image handle
pointer photons
pointer plt_const               # constants struct ptr
pointer pp                      # pkgpar handle
pointer sdevice                 # scale device
pointer sp			# memory pointer
pointer xpos			# source x positions
pointer ypos			# source y positions

bool    cgraph                  # close graph option - y or n
bool    dosrcs			# display sources
bool    doimg			# contour an image

int	display			# diplay level (0=none;5=max)
int	gr_label		# grid label - IN or OUT or NONE
int     i                       # loop counter
int     key                     # kestroke returned from clgcur
int     map    			# map is SKY or PIXEL
int     num_srcs		# number of sources
int	ty_grid			# grid type - FULL or TICS or NONE
int     wcs			# wcs of cursor

real    devgc[4]		# device mm in x & y and aspect ratio 
				# from graphcap
real    wx, wy			# cursor position
real    posdiff                 # position difference

pointer immap()
bool    clgetb()
pointer clopset()
bool    streq()
int     clgcur()
int     clgeti()
#int     tbtacc()
int     access()

include "clevels.com"

begin

#   Allocate space for buffers
	call smark (sp)
	call salloc (err_fname, SZ_PATHNAME, TY_CHAR)
	call salloc (img_fname, SZ_PATHNAME, TY_CHAR)
	call salloc (src_fname, SZ_PATHNAME, TY_CHAR)
	call salloc (buff,      SZ_LINE,     TY_CHAR)
	call salloc (gbuff,     SZ_LINE,     TY_CHAR)
	call salloc (maptype,   SZ_LINE,     TY_CHAR)
	call salloc (plt_title, SZ_LINE,     TY_CHAR)
	call salloc (plt_files, SZ_LINE,     TY_CHAR)
	call salloc (device,    SZ_LINE,     TY_CHAR)
	call salloc (sdevice,   SZ_LINE,     TY_CHAR)
	call calloc (sptr,      LEN_CLEVELS, TY_STRUCT)
	call malloc (plt_const, LEN_PL_CNST, TY_STRUCT)

#  Open pset parameter file with general imcontour params
        pp = clopset("gridpars")

#  Get image filename - can default to no image output 
	doimg = true
        call clgstr("image", Memc[img_fname], SZ_PATHNAME)
#	call rootname ("", Memc[img_fname], EXT_IMG, SZ_PATHNAME)
 	if ( streq ("NONE", Memc[img_fname]) | streq("", Memc[img_fname]) ) {
#	   call printf ("No image to graph\n")
#	   doimg = false
	   call error(1, "Must specify input image")
	} else {
	   im = immap (Memc[img_fname], READ_ONLY, 0)
	   call strcpy (IM_TITLE(im), Memc[plt_title], SZ_LINE)
	   call strcpy (Memc[img_fname], Memc[plt_files], SZ_LINE)
	}
        
#  Get source filename - can default to no sources output if doesn't exist
        dosrcs = true 
        call clgstr("src_list", Memc[src_fname], SZ_PATHNAME)
	call rootname ("", Memc[src_fname], "", SZ_PATHNAME)
   	if (streq ("NONE", Memc[src_fname]) | streq("", Memc[src_fname]) ) {
  	   dosrcs = false
  	}
        if ( dosrcs ) {
           if ( access (Memc[src_fname],0,0) == NO ) {
	      call sprintf (Memc[buff], SZ_LINE, "Src_list %s Does NOT Exist!!")
                call pargstr (Memc[src_fname])
	      call error (1, Memc[buff]) 
           }
	}
	
#  Get graph device - if not stdplot or stdgraph 
#                     closing the device at end of imcontour will be forced
	call clgstr ("graph_device", Memc[device], SZ_LINE)
        call rootname ("", Memc[device], "", SZ_LINE)

#  If plot device is stdgraph then graphics can be left open, else close.
        if (streq(Memc[device],"stdgraph") | streq(Memc[device],"STDGRAPH")){
	   cgraph = clgetb ("gclose")
        } else {
           cgraph = TRUE
	}

#  Get map grid type for STDPLOT scale device : either SKY or PIXEL
	call clgstr ("scale_device", Memc[sdevice], SZ_LINE)
        call rootname ("", Memc[sdevice], "", SZ_LINE)
#	if ( streq("stdplot", Memc[sdevice] ) | 
#             streq("STDPLOT", Memc[sdevice] ) ) {
	   call clgstr ("map_type", Memc[maptype], SZ_LINE)
	   call rootname ("", Memc[maptype], "", SZ_LINE)
	   if (streq("NONE", Memc[maptype]) | streq("", Memc[maptype]) ){
	      call error(1, "requires Map Type input: SKY or PIXEL")
	   } else if ( streq("SKY", Memc[maptype]) | 
		       streq("sky", Memc[maptype]) ) {
	      map = SKY
	   } else if ( streq("PIXEL", Memc[maptype]) | 
		       streq("pixel", Memc[maptype]) ) {
	      map = PIXEL
	   } else {
	      call error (1, "Choose SKY or PIXEL for Map Type")
	   }
#  Get scale devices - set map to PIXEL for scl dev other that STDPLOT
#	} else {
#          map = PIXEL
#	   call printf ("-- Only PIXEL map available")
#          call printf (" for %s Scale Device -- \n")
#	     call pargstr  (Memc[sdevice])
#	}

# Read the chart parameters
	display = clgeti("display")
	call map_parms (doimg, map, im, plt_const, display, posdiff)

#  The following Grid and Grid label parameters are only for the 
#  PIXEL grid ... Skymap parameters are input through wcslab code
        if ( map == PIXEL ) {

#  Grid type options are FULL (dashed lines drawn across plot) or 
#                        TICS (short lines drawn at perimieter of plot)
           call clgstr ("pixgrid", Memc[gbuff], SZ_LINE)
           call rootname ("", Memc[gbuff], "", SZ_LINE)
	   if (streq("NONE", Memc[gbuff]) | streq("", Memc[gbuff]) ){
              ty_grid = NO_GRID
           } else if ( streq("TICS", Memc[gbuff]) |
                       streq("tics", Memc[gbuff]) ) {
              ty_grid = TICS
           } else if ( streq("FULL", Memc[gbuff]) |
                       streq("full", Memc[gbuff]) ) {
              ty_grid = FULL
           } else {
              call error (1, "Choose TICS | FULL | NONE for Grid Type")
           }
        

#  Grid labels options are IN  (labels with plot perimeter) or
#                          OUT (labels outside of plot perimeter)
           call clgstr ("pixlabels", Memc[gbuff], SZ_LINE)
           call rootname ("", Memc[gbuff], "", SZ_LINE)
           if (streq("NONE", Memc[gbuff]) | streq("", Memc[gbuff]) ){
              gr_label = NO_LABEL
           } else if ( streq("IN", Memc[gbuff]) |
                       streq("in", Memc[gbuff]) ) {
              gr_label = IN
           } else if ( streq("OUT", Memc[gbuff]) |
                       streq("out", Memc[gbuff]) ) {
              gr_label = OUT
           } else {
              call error (1, "Choose IN | OUT | NONE for Grid Type")
           }
        }
	

# ---- Read IMAGE & get CONTOUR LEVELS ----

	if ( doimg ) { 
# Input contour levels
	   call get_contour_levels (sptr, display)

# Input image data
	   call get_image_data (im, display, photons)

	   if (UNITS(sptr) == SIGMA) { 

#  Get image error filename 
             call clgstr("error_image", Memc[err_fname], SZ_PATHNAME)
	     call rootname ("", Memc[err_fname], "", SZ_PATHNAME)
	     if ( streq("NONE",Memc[err_fname]) | streq("",Memc[err_fname])){
	        call error (1, "Need Error Image input for SIGMA levels")
	     } else {
	        er = immap (Memc[err_fname], READ_ONLY, 0)
	        call get_sigma_data (er, im, photons)
	        call strcat (" / sqrt ( ", Memc[plt_files], SZ_LINE)
	        call strcat (Memc[err_fname], Memc[plt_files], SZ_LINE)
	        call strcat (" )", Memc[plt_files], SZ_LINE)
	     }
	  }

# Determine the individual contour levels by interpreting the input
	  call interp_clevels (sptr, photons, plt_const, display)
	}

# Input src positions
	if ( dosrcs ) {
              
#             if ( tbtacc (Memc[src_fname]) == YES ) {
              if ( access (Memc[src_fname], 0, TEXT_FILE) == YES ) {
 	         call get_ascii_src_data (display, doimg, Memc[src_fname], 
                                          Memc[img_fname], num_srcs, xpos, ypos)
	      } else {
  	         call get_tab_src_data (display, doimg, Memc[src_fname], 
                                        Memc[img_fname], num_srcs, xpos, ypos)
	      }
	}

# Open graphics and allocate struct space
        call graph_open (Memc[device], Memc[sdevice], display, gp, devgc)


# Set Scales for the plot
	call grid_scale (gp, im, plt_const, display, devgc)

 	call imunmap (im)

# ---- SKYMAP ----
# Draw a sky map
	if ( map == SKY ) {
           call wcs_skymap(gp, Memc[img_fname], display)
 
# ---- PIXEL MAP ----
# Draw a pixel map
	} else if ( map == PIXEL ) {
	   call pix_grid(gp, ty_grid, gr_label)
	}

# Draw the Plot Title
	if ( clgetb("dotitle") ) {
	   call identify_plt (gp, Memc[plt_title], Memc[plt_files])
	}

# Draw the Plot Legend and Title
	if ( clgetb("dolegend") ) {
	   call sky_legend (gp, plt_const, Memc[sdevice], map)
	}

# Mark Sources from source list
        if ( dosrcs && (num_srcs > 0) ) { 
	   call mrk_srcs (gp, num_srcs, xpos, ypos)
           call mfree (xpos, TY_REAL)
           call mfree (ypos, TY_REAL)
	}

# Draw Contours
        if ( doimg ) {
	   call draw_contours (gp, Memr[photons], int (IMPIXX(plt_const)),
			       int (IMPIXY(plt_const)), display)
	   call mfree (photons, TY_REAL)
	}

# Interactive Graphics Mode
        call gflush (gp)
	if ( !cgraph ) {
           if (streq(Memc[device],"STDGRAPH") | streq(Memc[device],"stdgraph")){
	      do i= 1, 30 {
                call printf ("\n")
              }
              call printf ("TYPE 'q' to QUIT\n")
           }
	   while (clgcur("cursor",wx,wy,wcs,key,Memc[buff],SZ_LINE) != EOF){
	      if ( key == 'q' ) {
		  break
	      }
	   }
	}

#  Close down graphics and structures
	call gflush (gp)
 	call gclose (gp)

# Deallocate the memory and structures
	call mfree (sptr, TY_STRUCT)
	call mfree (plt_const, TY_STRUCT)
	call sfree (sp)

end
