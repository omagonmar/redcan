#Header:
#Log:
#
# ---------------------------------------------------------------------
#
# Module:       DETREG.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Read the lpeaks and bepos output tables, convert the
#               coords from physical to logical, and right a regions
#		file.  The bepos positions are region circles and
#               the rough positions are region boxes.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Mar 1992 -- initial version 
#               {1} JD -- May 93 -- added match region option
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
#
# ---------------------------------------------------------------------
include <imhdr.h>
include <ext.h>
include <mach.h>

define  DEGTOSA                 (3600.0*($1))

procedure t_detmkreg()

int     display                 # display level

bool    clobber                 # clobber file if it exists
bool    have_rpos               # yes if rpos table to convert
bool    have_bpos               # yes if bepos table to convert
bool    have_mch		# yes if mch table to convert
  
pointer bp_tab                  # bepos table name
pointer btabtemp		# temporary table file name
pointer ict			# wcs coord  conversion pointer
pointer im                      # image handle 
pointer imname		  	# image name buffer
pointer imw			# image wcs pointer
pointer mch_tab                 # mch src table name
pointer ofile                   # output region file name
pointer optr                    # output region file pointer
pointer region			# output region 
pointer rtabtemp		# temporary table file name
pointer rp_tab			# rpos table name	
pointer sp			# space allocation pointer
pointer tempname                # temp name for region output file

real	xpixsize		# pixel size in x in degrees
real	ypixsize		# pixel size in y in degrees
real    arcsecs_per_pix		# arc-seconds per pixel

bool    ck_none()
bool    imaccf()
bool    clgetb()
int	clgeti()
pointer open()
pointer immap()
pointer mw_sctran()
pointer mw_openim()
real    imgetr()

begin

#   Allocate buffer space
        call smark(sp)
        call salloc (bp_tab, SZ_PATHNAME, TY_CHAR)
        call salloc (btabtemp, SZ_PATHNAME, TY_CHAR)
        call salloc (imname, SZ_PATHNAME, TY_CHAR)
        call salloc (mch_tab, SZ_PATHNAME, TY_CHAR)
        call salloc (ofile, SZ_PATHNAME, TY_CHAR)
        call salloc (region, SZ_LINE, TY_CHAR)
        call salloc (rp_tab, SZ_PATHNAME, TY_CHAR)
        call salloc (rtabtemp, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname, SZ_PATHNAME, TY_CHAR)

        display = clgeti ("display")
        clobber = clgetb ("clobber")

#   Open the image file & get WCS pointer
        call clgstr("image", Memc[imname], SZ_PATHNAME) 
      	if ( ck_none (Memc[imname]) ) {
           call error (1, "Reference image filename required!!")
        }
      	call rootname ("", Memc[imname], EXT_IMG, SZ_PATHNAME)
  	im = immap(Memc[imname], READ_ONLY, 0) 
	imw = mw_openim(im)
        ict = mw_sctran (imw, "physical", "logical", 3B)

#   determine the arcsecs per pixel
        if ( imaccf (im, "cdelt1" ) ) {
           xpixsize = DEGTOSA(abs(imgetr (im, "cdelt1")))
        } else {
           call error (1, "Image must have WCS")
        }
        if ( imaccf (im, "cdelt2" ) ) {
           ypixsize = DEGTOSA(abs(imgetr (im, "cdelt2")))
        } else {
           call error (1, "Image must have WCS")
        }
        if ( ( xpixsize - ypixsize ) > EPSILONR ) {
          call error (1, "Input must have square pixels")
        }
        arcsecs_per_pix = xpixsize

        if ( display >= 2 ) {
          call printf ("arcsecs_per_pix= %f\n")
            call pargr (arcsecs_per_pix)
        }

#   Open the rpos table
      	call clgstr ("lpeaks_tab", Memc[rp_tab], SZ_PATHNAME)
      	have_rpos = !(ck_none (Memc[rp_tab]))
	if( have_rpos) 
      	    call rootname (Memc[imname], Memc[rp_tab], EXT_RUF, SZ_PATHNAME)
        if ( display >= 4 ) {
           call printf ("lpeaks file= %s\n")
             call pargstr (Memc[rp_tab])
	}

#   Open the bpos table
      	call clgstr ("bepos_tab", Memc[bp_tab], SZ_PATHNAME)
      	have_bpos = !(ck_none (Memc[bp_tab]))
	if( have_bpos)
      	    call rootname (Memc[imname], Memc[bp_tab], EXT_POS, SZ_PATHNAME)
        if ( display >= 4 ) {
           call printf ("bepos file= %s\n")
             call pargstr (Memc[bp_tab])
	}

#   Open the match table
      	call clgstr ("mch_tab", Memc[mch_tab], SZ_PATHNAME)
      	have_mch = !(ck_none (Memc[mch_tab]))
	if( have_mch)
      	    call rootname (Memc[imname], Memc[mch_tab], EXT_MCH, SZ_PATHNAME)
        if ( display >= 4 ) {
           call printf ("mch file= %s\n")
             call pargstr (Memc[mch_tab])
	}

#   Open ascii output region file and initialize the the first line with
#   the reference image name
      	call clgstr ("reg_file", Memc[ofile], SZ_PATHNAME)
      	call rootname (Memc[imname], Memc[ofile], ".reg" , SZ_PATHNAME)
      	if ( ck_none (Memc[ofile]) ) {
           call error (1, "Reference Ascii Output filename required!!")
        }
        call clobbername(Memc[ofile], Memc[tempname], clobber, SZ_PATHNAME)
        optr=open(Memc[tempname], NEW_FILE, TEXT_FILE)

#   Write the reference image name on the first line of the reg file
        call fprintf (optr, "# reference image: %s\n")
           call pargstr (Memc[imname])

#   Read rough positions, convert the coords, and write to the region file
      	if ( have_rpos ) {

           call sprintf (Memc[region], SZ_LINE, "box")
           call regout (Memc[rp_tab], ict, optr, arcsecs_per_pix, 
                        Memc[region], display)

	}

#   Read best positions, convert the coords, and write to the region file
	if ( have_bpos ) {

           call sprintf (Memc[region], SZ_LINE, "circle")
           call regout (Memc[bp_tab], ict, optr, arcsecs_per_pix, 
                        Memc[region], display)

	}

#   Read mch src positions, convert the coords, and write to the region file
	if ( have_mch ) {

           call sprintf (Memc[region], SZ_LINE, "rotbox")
           call regout (Memc[mch_tab], ict, optr, arcsecs_per_pix, 
                        Memc[region], display)

	}

#   Wrap it up; close wcs, table & image files, free space
        call mw_close(imw)
        call imunmap(im)

        call finalname(Memc[tempname], Memc[ofile])
        call close (optr)

        if ( display > 0 ) {
           call printf ("\nWriting to Output file:  %s\n")
             call pargstr (Memc[ofile])
        }

	call sfree(sp)
end
