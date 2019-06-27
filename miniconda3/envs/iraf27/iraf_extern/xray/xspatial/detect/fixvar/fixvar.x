# Header$
# Log$
#
# ---------------------------------------------------------------------
#
# Module:       FIXVAR.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      determine the frame counts for small number regime.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Jan 1993 -- initial version
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <ext.h>
include <imhdr.h>
include <fset.h>

define  x  1
define  y  2

procedure t_fixvar()

bool    clobber			# indicates whether to replace 
				#   existing file
pointer inbuff, outbuff		# 1 dim array of image data
pointer in, out			# image input pointer
pointer in_image		# name of input image
pointer out_image		# name of output image
pointer tempname		# temporary file name
pointer varbuff                 # varience buffer
pointer sp			# space allocation pointer

int     display                 # display level
int     j			# loop counter
int     xdim, ydim		# image dimension in x & y

long    one_l
long    v1[IM_MAXDIM], v2[IM_MAXDIM]

bool    ck_none()
bool    clgetb()
bool    streq()
int     clgeti()
pointer immap()			
pointer imgnlr()
pointer impnlr()

begin
	call fseti (STDOUT, F_FLUSHNL, YES)

#   Allocate buffer space
        call smark(sp)
        call salloc (in_image, SZ_PATHNAME, TY_CHAR)
        call salloc (out_image, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname, SZ_PATHNAME, TY_CHAR)

#   Open the input & output image files
	call clgstr("in_image", Memc[in_image], SZ_PATHNAME)

        in = immap(Memc[in_image], READ_ONLY, 0)

        call clgstr ("out_image", Memc[out_image], SZ_PATHNAME)
        call rootname (Memc[in_image],Memc[out_image], EXT_IMG, SZ_PATHNAME)
        if ( (ck_none (Memc[out_image])) || ( streq("", Memc[out_image])) ) {
           call error(1, "Output filename missing")
        }
        clobber = clgetb ("clobber")
        call clobbername (Memc[out_image], Memc[tempname], clobber, SZ_PATHNAME)

        display = clgeti("display")

#   Open output image and copy input image header
        call new_imcopy (in, Memc[tempname], out)

        xdim = IM_LEN(in,1)
        ydim = IM_LEN(in,2)

        one_l = 1
        call amovkl (one_l, v1, IM_MAXDIM)
        call amovkl (one_l, v2, IM_MAXDIM)

        call salloc (varbuff, xdim, TY_REAL)

#   -----------------------------------------------------------------
#   Loop over the cells and replace elements that meet our test
#   -----------------------------------------------------------------
     
        while (imgnlr(in, inbuff, v1) != EOF) {

           for (j=1; j<=xdim; j=j+1) {
               call setvar (Memr[inbuff+j-1], Memr[varbuff+j-1])
 	   }

	   if (impnlr(out, outbuff, v2) != EOF) {
              call amovr (Memr[varbuff], Memr[outbuff], xdim)
           }
	}

#   Close files and free space
	call imunmap (in)
	call imunmap (out)
	call sfree (sp)
end
