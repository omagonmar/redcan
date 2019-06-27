#Header:
#Log:
#
#JCC(2/98) - move the messages for pixsize(x,y)
#
# ---------------------------------------------------------------------
#
# Module:       BKDEN.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      determine the bkden of a selected image region
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Feb 1992 -- initial version
#               {1} JD -- Sept 92 -- write the bkden to the cl param 'value'
#               {2} JD -- Oct 92 -- write the bkden to the cl param 
#			            'bepos.bkden'
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <coords.h>
include <ext.h>
include <imhdr.h>
include <mach.h>
include <math.h>
include <qpoe.h>
include <pmset.h>
include <fset.h>

define  DEGTOSA         (3600.0*($1))           # degrees to seconds of arc
define  x  1
define  y  2

procedure t_bkden()

bool 	rejected		# indicates whether elements were rejected

int     bufflen			# 1 dim length of image (xlen * ylen) 
int	display			# display levels (0->5)
int     iter			# iteration counter
int	max_iter		# maximum number of iteration param
int 	num_cells		# total number of elements in region
int     tcnts			# total counts within threshold

pointer cellbuff		# 1 dim array of image data
pointer im			# image input pointer
pointer imhead
pointer imname			# name of input image
pointer mp			# mio pointer
pointer rejbuff			# reject buffer with below thresh element marked
pointer regname			# input string for region specifier
pointer pm			# pmio pointer (exposure-filtered region mask)
pointer sp			# space allocation pointer
pointer title			# (exposure-filtered region) mask title

real	avg_cnts		# average of counts in the region
real    bkden			# background density in cts/arcmin**2
real 	fconst			# fluctuation constant for thresh calc
real	fluct			# fluctuation parameter
real    pixsiz[2]		# x pixel size in arcsecs
double  thresh			# computed threshhold


int	clgeti()		# get an integer from the cl
pointer immap()			# open and return an image pointer
pointer msk_imopen()		# open and return a mask pointer
pointer mio_openo()		# open and return a region pointer
real    clgetr()		# get an real from the cl
bool    streq()

begin

	call fseti (STDOUT, F_FLUSHNL, YES)

#   Allocate buffer space
        call smark(sp)
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (regname, SZ_LINE, TY_CHAR)

#   Open the image file & region
	call clgstr("image", Memc[imname], SZ_PATHNAME)
	call clgstr("region", Memc[regname], SZ_LINE)
        display = clgeti ("display")

        im = immap(Memc[imname], READ_ONLY, 0)

        call get_imhead (im, imhead)
        pixsiz[x] = DEGTOSA (abs(QP_CDELT1(imhead)))
        pixsiz[y] = DEGTOSA (abs(QP_CDELT2(imhead)))

#JCC(2/98)
        if ( display >= 3 ) {
           call printf ("x,y  pixsize = %.3f %.3f\n")
             call pargr (pixsiz[x])
             call pargr (pixsiz[y])
        }

#   Check if we are setting up our default region
        if (streq (Memc[regname], "default") ) {
           call define_defreg ( im, Memc[regname] )
        }

        if ( display >= 1 ) {
           call printf ("\nBkden region is %s\n")
             call pargstr (Memc[regname])
           call flush (STDOUT)
	}

#   Open the mask region read 
	pm = msk_imopen (NULL, Memc[regname], "NONE", -1.0, im, title)
	mp = mio_openo (pm,im)

#   We make a pass through the data to count the number of cells.  The
#   counts array will be defined based on this number
        call cnt_msked_pixels (mp, display, bufflen)

#   Close the files and open them again to rewind them
	call mio_close(mp)
	call pm_close(pm)
	call imunmap (im)

        im = immap(Memc[imname], READ_ONLY, 0)
	pm = msk_imopen (NULL, Memc[regname], "NONE", -1.0, im, title)
	mp = mio_openo (pm,im)

#   Input param values
	fluct = clgetr ("fluctuation")
	max_iter = clgeti ("max_iter")

#   Allocate buffer space based on size of input image, if the region is
#   to large we won't allocate the space.
        ifnoerr ( call calloc (cellbuff, bufflen, TY_REAL) ) {
        } else {
           call error (0, 
             "Area of region exceeds array size - choose smaller region")
        }

#   Read the pixels through the mask and store in 1 dim array cellbuff
	call get_msked_pixels (mp, display, Memr[cellbuff], num_cells)
        if ( display > 2 ) {
	   call msk_disp ("", Memc[imname], Memc[title])
	}

#   Init reject buff that marks cells below threshold
	ifnoerr ( call calloc (rejbuff, num_cells, TY_SHORT) ) {
        } else {
           call error (0, 
             "Area of region exceeds array size - choose smaller region")
        }
	call aclrs (Mems[rejbuff], num_cells)
	
        iter = 0
        rejected = true
	fconst = (float(num_cells)-fluct)/float(num_cells)

#   -----------------------------------------------------------------
#   Loop over the cells until no cells are rejected or we've hit the 
#   maximum number of iterations
#   -----------------------------------------------------------------
	while ( (rejected) && (iter < max_iter) ) {
     
	   iter = iter + 1
           rejected = false
	 
	   if ( display >= 3 ) {
	      call printf ("\n")
	      call printf ("Iter=%d\n")
	         call pargi (iter) 
	   }

#   Compute the average counts from all good bins
	   call get_avg_cnts (Memr[cellbuff], Mems[rejbuff], num_cells, 
			      display, avg_cnts)

#   Compute the threshold value  
	   call compute_thresh (avg_cnts, fconst, display, thresh, tcnts)
	
#   Screen the cells above threshold
	   call screen_cells (Memr[cellbuff], Mems[rejbuff], tcnts, 
		              num_cells, display, rejected)

	}

#   Convert units to counts / arcmin**2
 	bkden = avg_cnts * 3600.0 / (pixsiz[x]*pixsiz[y])
 	call printf ("\nBkden = %f counts/arcmin**2 \n")
 	   call pargr (bkden)

#   Write the bkden we computed to the cl
        call clputr ("value", bkden)

        call clputr ("bepos.bkden", bkden)

#   Close files and free space
	call mio_close(mp)
	call pm_close(pm)
	call imunmap (im)

	call mfree(title, TY_CHAR)

	call sfree (sp)

end
