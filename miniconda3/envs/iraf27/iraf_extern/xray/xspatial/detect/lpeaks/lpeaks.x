#Header:
#Log:
#
# ---------------------------------------------------------------------
#
# Module:       LPEAKS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Determine the above threshold peaks in an snrmap 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Dec 1991 -- initial version 
#				     converted from fap's lpeaks.c prog
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
#
#  lpeaks reads an iraf image file and detects all local peaks which
#  exceed a threshold. Three image lines at a time are examined, and
#  scrolled to cover the entire image.
#
#   fap  7/1/91     This version only deals with real arrays and assumes
#                   the image is square.
#
#   fap  7/3/91     This version copies image lines to local storage, and
#                   is limited to image dimensions of 512x512 or less.
#
# ---------------------------------------------------------------------
include <imhdr.h>
include <mach.h>
include <tbset.h>
include <ext.h>

procedure t_lpeaks()


int 	cells[2]		# x/y cell size in pixels
int     display                 # display level
int 	im                      # image handle 
  
pointer imname		  	# image name buffer
pointer ocolptr[10]		# output table column pointer buff
pointer otp			# output rpos table pointer
pointer rp_tab			# rpos table name	
pointer sp			# space allocation pointer
pointer tabtemp			# temporary table file name
pointer ict			# wcs coord  conversion pointer
pointer imw			# image wcs pointer

real thresh                     # value threshold, from command line

pointer immap()
pointer mw_sctran()
pointer mw_openim()
int     imgeti()
int	clgeti()
real    clgetr()

begin

#   Allocate buffer space
        call smark(sp)
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (rp_tab, SZ_PATHNAME, TY_CHAR)
        call salloc (tabtemp, SZ_PATHNAME, TY_CHAR)

#   Open the image file & get WCS pointer
        call clgstr("image", Memc[imname], SZ_PATHNAME) 
  	im = immap(Memc[imname], READ_ONLY, 0) 
	imw = mw_openim(im)
        ict = mw_sctran (imw, "logical", "physical", 3B)

#   Initialize the Output Table file
      call init_rpos_tab (Memc[rp_tab], Memc[imname], Memc[tabtemp], 
			  ocolptr, otp)

#   Read threshold for flagging peaks
    	thresh = clgetr("thresh")
        display = clgeti ("display")

	cells[1] = imgeti (im, "cellsize")
	cells[2] = imgeti (im, "cellsize")

#   Determine the peaks above threshold in the image
	call find_peaks (im, otp, ocolptr, ict, thresh, cells, display)

#   Write table header info
        call wr_rhead (otp, display, Memc[imname], thresh)

#   Wrap it up; close wcs, table & image file, rename table, free space
        call mw_close(imw)
        call tbtclo(otp)
        call imunmap(im)

        call finalname (Memc[tabtemp], Memc[rp_tab])
        if ( display > 0 ) {
           call printf ("\nWriting to Output file:  %s\n")
             call pargstr (Memc[rp_tab])
        }

	call sfree(sp)
end
