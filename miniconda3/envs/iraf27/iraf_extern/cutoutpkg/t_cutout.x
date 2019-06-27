include <mach.h>
include <math.h>
include <imhdr.h>
include <mwset.h>
include <pkg/dttext.h>
include "skywcs.h"
include "cutout.h"

define  CD     Memd[cd+(($2)-1)*ndim+($1)-1]

# T_CUTOUT -- Deep Wide Survey cutout task.

procedure t_cutout()

real	blank
pointer	sp, imtemplate, database, tmpdatabase, image, coords, record, index
pointer	str, dt, im, clst, csym, filter, imst, imptrs, imroot, str2, fildict
pointer	kwfilter, output
int	i, j, k, opmode, dbupdate, dbappend, imlist, rec, imno, coostat, cl
int	nfields, novlap, nim, cutmode, cutstat, pixin, outlist
bool	update, listout, verbose, trim

real	clgetr()
pointer	dtmap(), immap(), stfind(), stopen()
int	clgwrd(), access(), imtopen(), imtgetim(), dtlocate(), imtlen()
int	ct_wrecord(), open(), ct_mklist(), ct_ovlap(), ct_gimptrs(), sk_wrdstr()
int	ct_ltrim(), ct_lnotrim(), ct_collage(), strmatch()
bool	clgetb(), streq()
errchk	dtlocate(), open()

begin
	# Get some working space.
	call smark (sp)
	call salloc (imtemplate, SZ_FNAME, TY_CHAR)
	call salloc (database, SZ_FNAME, TY_CHAR)
	call salloc (tmpdatabase, SZ_FNAME, TY_CHAR)
	call salloc (image, SZ_FNAME, TY_CHAR)
	call salloc (output, SZ_FNAME, TY_CHAR)
	call salloc (coords, SZ_FNAME, TY_CHAR)
	call salloc (record, SZ_FNAME, TY_CHAR)
	call salloc (imroot, SZ_FNAME, TY_CHAR)
	call salloc (filter, SZ_FNAME, TY_CHAR)
	call salloc (kwfilter, SZ_FNAME, TY_CHAR)
	call salloc (fildict, SZ_FNAME, TY_CHAR)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call salloc (str2, SZ_FNAME, TY_CHAR)

	# Determine the operations mode.

	opmode = clgwrd ("opmode", Memc[str], SZ_FNAME, "|scan|list|cutout|")
	call clgstr ("dbfile", Memc[database], SZ_FNAME)

	# Get the scan mode parameters.

	if (opmode == CT_SCAN) {

	    call clgstr ("input", Memc[imtemplate], SZ_FNAME)
	    call clgstr ("kwfilter", Memc[kwfilter], SZ_FNAME)
	    update = clgetb ("update")

	    cl = NULL
	    clst = NULL
	    listout = false

	# Get the list and cutout mode parameters.

	} else {

	    call clgstr ("output", Memc[output], SZ_FNAME)
	    call clgstr ("regions", Memc[coords], SZ_FNAME)
	    call clgstr ("imroot", Memc[imroot], SZ_FNAME)

	    # Open the coordinates file.

	    if (streq (Memc[coords], "none"))
		cl = NULL
	    else  {
	        iferr (cl = open (Memc[coords], READ_ONLY, TEXT_FILE))
		    cl = NULL
	    }

	    # Create the field center symbol table
	    nfields = ct_mklist (cl, clst)

	    cutmode = clgwrd ("cutmode", Memc[str], SZ_FNAME,
	        "|largest|collage|")
	    trim = clgetb ("trim")
	    blank = clgetr ("blank")
	    listout = clgetb ("listout")
	}
	if (listout)
	    verbose = false
	else
	    verbose = clgetb ("verbose")

	# Run the cutout task in scan mode.

	if (opmode == CT_SCAN) {

	    # Open the image database file as a new file, as a new copy of
	    # an existing file, or in append mode.

	    if (access (Memc[database], 0, 0) == NO) {
		if (verbose) {
		    call printf ("Creating new image database %s\n")
			call pargstr (Memc[database])
		}
		dt = dtmap (Memc[database], NEW_FILE)
		dbupdate = NO
		dbappend = NO

	    } else if (update) {
		if (verbose) {
		    call printf ("Creating new version of image database %s\n")
			call pargstr (Memc[database])
		}
		call mktemp ("imdb", Memc[tmpdatabase], SZ_FNAME)
		dt = dtmap (Memc[tmpdatabase], NEW_FILE)
		dbupdate = YES
		dbappend = NO

	    } else {
		if (verbose) {
		    call printf ("Appending to image database %s\n")
			call pargstr (Memc[database])
		}
		dbupdate = NO
		dt = dtmap (Memc[database], READ_ONLY)
		dbappend = YES
	    }

	    # Open the list of images

	    imlist = imtopen (Memc[imtemplate])

	    # Open the database in append mode.
	    if (dbappend == YES) {

		# Loop through the image names determining which images
		# are aready records in the database. Close the database.

		call salloc (index, imtlen(imlist) + 1, TY_INT)
		imno = 0
	        while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {
		    call ct_imroot (Memc[image], Memc[record], SZ_FNAME)
		    ifnoerr {
		        rec = dtlocate (dt, Memc[record])
		    } then {
			Memi[index+imno] = YES
		    } else {
			Memi[index+imno] = NO
		    }
		    imno = imno + 1
		}
		call dtunmap (dt)

		# Remap the database in append mode, rewind the image list,
		# and add the appropriate  records to the database.

		dt = dtmap (Memc[database], APPEND)
		call imtrew (imlist)
		imno = 0
	        while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {
		    if (Memi[index+imno] == YES) {
			if (verbose) {
			    call printf (
			        "    Record for image %s already exists\n")
			        call pargstr (Memc[image])
			}
		    } else {
		        im = immap (Memc[image], READ_ONLY, 0)
			call ct_imroot (Memc[image], Memc[record], SZ_FNAME)
			coostat = ct_wrecord (im, dt, Memc[record],
			    Memc[kwfilter])
			if (coostat == ERR) {
			    if (verbose) {
			        call printf (
				    "    Error writing record for image %s\n")
			            call pargstr (Memc[image])
			    }
			} else {
			    if (verbose) {
			        call printf (
				    "    Appending record for image %s\n")
			            call pargstr (Memc[image])
			    }
			}
		        call imunmap (im)
		    }
		    imno = imno + 1
		}

	    # Open the database as a new file.

	    } else {
	        while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {
		    im = immap (Memc[image], READ_ONLY, 0)
		    call ct_imroot (Memc[image], Memc[record], SZ_FNAME)
		    coostat = ct_wrecord (im, dt, Memc[record], Memc[kwfilter])
		    if (coostat == ERR) {
		        if (verbose) {
			    call printf (
			        "    Error writing record for image %s\n")
			        call pargstr (Memc[image])
		        }
		    } else {
		        if (verbose) {
			    call printf ("    Writing record for image %s\n")
			        call pargstr (Memc[image])
		        }
		    }
		    call imunmap (im)
		}
	    }

	    # Close the list of images.
	    call imtclose (imlist)

	    # Close the image database file. Delete the original and rename
	    # the new one to the original name if appropriate.

	    call dtunmap (dt)
	    if (dbupdate == YES) {
		call delete (Memc[database])
		call rename (Memc[tmpdatabase], Memc[database])
	    }

	# Run the task in cutout mode.
	} else if (access (Memc[database], READ_ONLY, TEXT_FILE) == YES) {

	    # Open the database.
	    if (verbose) {
		call printf ("Opening image database %s\n")
		    call pargstr (Memc[database])
	    }
	    dt = dtmap (Memc[database], READ_ONLY)

	    # Open the output image list.
	    outlist = imtopen (Memc[output])


	    # Loop over the field centers.
	    do i = 1, nfields {

		# Get the first field center.
		call sprintf (Memc[str], SZ_FNAME, "%s%d")
		    call pargstr (DEF_CTFC_ROOTNAME)
		    call pargi (i)
		csym = stfind (clst, Memc[str]) 
		if (csym == NULL)
		    next
		if (CT_FCXWIDTH(csym) <= 0 && CT_FCYWIDTH(csym) <= 0)
		    pixin = NO
		else
		    pixin = YES

		# Print the field center info.
		if (verbose || opmode == CT_LIST) {
		    call printf ("Objname: '%s'\n")
			call pargstr (CT_FCOBJNAME(csym))
		    call printf ("Field %d: %0.3H %0.2h %s %s\n")
			call pargi (i)
			call pargd (CT_FCRA(csym))
			call pargd (CT_FCDEC(csym))
			call pargstr (CT_FCSYSTEM(csym))
			call pargstr (CT_FCFILTERS(csym))
		}

		# Open the image symbol table
        	imst = stopen ("imlist", 2 * DEF_LEN_CTIM, DEF_LEN_CTIM,
            	    10 * DEF_LEN_CTIM)

		# Scan the database collecting all the images which overlap the
		# desired user field. Output the filter dictionary which is
		# either the input filter dictionary or the internal filter
		# dictionary is the input filter dictionary is undefined.
		# The idea here is that there be sufficient information in
		# the image database record so that the task does not
		# have to open every image in the database. The technique
		# used here only works for simple projections i.e those
		# for which there are no projection parameters.

		novlap = ct_ovlap (dt, rec, csym, imst, Memc[fildict], SZ_FNAME)

		# Loop over the requested filter list collecting images taken
		# in the same filter.

		call malloc (imptrs, novlap + 1, TY_POINTER) 

		for (j = 1; sk_wrdstr (j, Memc[filter], SZ_FNAME,
		    Memc[fildict]) > 0; j = j + 1) {

		    # Collect the image symbols and sort them in order of
		    # increasing overlap area.

		    if (novlap <= 0)
			nim = 0
		    else
		        nim = ct_gimptrs (imst, Memc[filter], Memi[imptrs],
			    novlap)
		    if (verbose) {
			call printf (
			    "%d %s band images overlap requested field\n")
			    call pargi (nim)
			    call pargstr (Memc[filter])
		    }

		    if (verbose || opmode == CT_LIST) {
			do k = 1, nim {
			    if (pixin == NO) {
			        call printf (
			        "    Image: %s  Ra Dec Offset: %0.3f %0.3f")
				    call pargstr (CT_IMNAME(Memi[imptrs+k-1]))
				    call pargd (CT_IMXIOFF(Memi[imptrs+k-1]) *
				        60.0d0)
				    call pargd (CT_IMETAOFF(Memi[imptrs+k-1]) *
				        60.0d0)
			        call printf (" arcmin  Filter: %s\n")
				    call pargstr (CT_IMFILTER(Memi[imptrs+k-1]))
			    } else {
			        call printf (
			        "    Image: %s  X Y Offset: %0.2f %0.2f")
				    call pargstr (CT_IMNAME(Memi[imptrs+k-1]))
				    call pargd (CT_IMXIOFF(Memi[imptrs+k-1]))
				    call pargd (CT_IMETAOFF(Memi[imptrs+k-1]))
			        call printf (" pixels  Filter: %s\n")
				    call pargstr (CT_IMFILTER(Memi[imptrs+k-1]))
			    }
			}
		    }
		    if (opmode == CT_LIST || nim <= 0)
			next

		    # Create the output image name. Will probably need to
		    # change this code later.
		    if (imtgetim (outlist, Memc[str2], SZ_FNAME) != EOF) {
			if (streq ("default", Memc[str2]))
			    call ct_mkfname (csym, Memc[imroot], Memc[filter],
			        Memc[str2], SZ_FNAME)
		    } else {
			call ct_mkfname (csym, Memc[imroot], Memc[filter],
			    Memc[str2], SZ_FNAME)
		    }

		    # Make sure the ".fits" extension is present. This
		    # way of doing it is not quite right but should work
		    # for now.
		    if (strmatch (Memc[str2], ".fits$") == 0)
		        call strcat (".fits", Memc[str2], SZ_FNAME)

		    if (verbose) {
			call printf ("    Creating output image %s ...\n")
			    call pargstr (Memc[str2])
		    }

		    # Do the cutouts. If cutmode is largest then the image with
		    # the largest overlap area is chosen to create the cutout.
		    # Otherwise the output image is a collage of the input
		    # images where images with larger overlap areas cover
		    # images with smaller overlap areas.

		    if (cutmode == CT_LARGEST) {
			if (trim)
			    cutstat = ct_ltrim (csym, Memi[imptrs], nim,
			        Memc[str2], pixin)
			else
			    cutstat = ct_lnotrim (csym, Memi[imptrs], nim,
			        Memc[str2], blank, pixin)
		    } else {
			cutstat = ct_collage (csym, Memi[imptrs], nim,
			    Memc[str2], trim, blank, pixin)
		    }

		    # List the output file.
		    if (listout && cutstat == OK) {
			call printf ("%s\n")
			    call pargstr (Memc[str2])
		    }
		}

		if (verbose || opmode == CT_LIST) {
		    call printf ("\n")
		}


		# Free the image pointers array.
		call mfree (imptrs, TY_POINTER)

		# Close the image symbol table.
		call stclose (imst)

	    }

	    # Close the output image list
	    call imtclose (outlist)

	    # Unmap the database.
	    call dtunmap (dt)

	} else {
	    if (verbose) {
		call printf ("Error opening image database %s\n")
		    call pargstr (Memc[database])
	    }
	}

	# Close the coordinates symbol table.
	if (clst != NULL)
	    call stclose (clst)

	# Close the coordinates file
	if (cl != NULL) {
	    call close (cl)
	}

	call sfree (sp)
end


# CT_WRECORD -- Write the database record for the image. The record name
# is the name of the image with the directory information removed. The
# quantities listed in the record are the full image name, the filter id, the
# ra and dec of the center of the image in hours and degrees, the coordinate
# system of the image wcs, and the size of the image in pixels. The WCS
# related quantities including the projection type, ra and dec of the reference
# pixel, and the image size in projected coordinates, are also written to
# the database.

int procedure ct_wrecord (im, dt, recname, kwfilter)

pointer	im		#I the input image pointer
pointer	dt		#I the database file pointer
char	recname[ARB]	#I the record name
char	kwfilter[ARB]	#I the image keyword filter name

double	xc, yc, wxc, wyc
pointer	sp, str, coo, mw, ct
pointer	mw_sctran()
int	sk_decim(), sk_stati()
errchk	imgstr()

begin
	# Return if the image is not 2D.
	if (IM_NDIM(im) != 2)
	    return (ERR)

	# Open the image coordinate system and make sure that the coordinate
	# system is a legal celestial coordinate system.
	if (sk_decim (im, "logical", mw, coo) == ERR) {
	    if (mw != NULL)
		call mw_close (mw)
	    call sk_close (coo)
	    return (ERR)
	}

	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Evaluate the coordinates at the center in degrees
	ct = mw_sctran (mw, "logical", "world", 03B)
	xc = (IM_LEN(im,1) + 1.0d0) / 2.0d0
	yc = (IM_LEN(im,1) + 1.0d0) / 2.0d0
	call mw_c2trand (ct, xc, yc, wxc, wyc)
	call mw_ctfree (ct)

	# Write the record name.
	call dtptime (dt)
	call dtput (dt,"begin\t%s\n")
	    call pargstr (recname)

	# Write out the full image name. Not sure if this is useful at the
	# moment or not.
	call dtput (dt, "image %s\n")
	    call pargstr (IM_HDRFILE(im))

	# Write out the full filter name.
	#call clgstr ("kwfilter", Memc[str], SZ_FNAME)
	iferr {
	    call imgstr (im, kwfilter, Memc[str], SZ_FNAME)
	} then {
	    call dtput (dt, "    filter %s\n")
		call pargstr ("INDEF")
	} else {
	    call dtput (dt, "    filter %s\n")
		call pargstr (Memc[str])
	}
	# Write out the coordinate of the image center in hours and degrees
	# if the coordinate system is equatorial, or in degrees and degrees
	# if it is not. At present we are assuming the mosaic images are
	# in equatorial coordinates but in future they may not be. Note that
	# we have to be careful about which axis describes the longitude
	# coordinate and which describes the latitude coordinate.

	if (sk_stati (coo, S_CTYPE) == CTYPE_EQUATORIAL) {
	    call dtput (dt, "    ra %0.5H\n")
	    if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	        call pargd (wxc)
	    } else {
	        call pargd (wyc)
	    }
	    call dtput (dt, "    dec %0.4h\n")
	    if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	        call pargd (wyc)
	    } else {
	        call pargd (wxc)
	    }
	} else {
	    call dtput (dt, "    ra %g\n")
	    if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	        call pargd (wxc)
	    } else {
	        call pargd (wyc)
	    }
	    call dtput (dt, "    dec %g\n")
	    if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	        call pargd (wyc)
	    } else {
	        call pargd (wxc)
	    }
	}

	# Write out the coordinate system as an encoded string. For simplicty
	# we could decide to write "J2000" or "ICRS" instead but the encode
	# routine writes a fuller description so we will use it.

	call sk_enwcs (coo, Memc[str], SZ_FNAME)
	call dtput (dt, "    ccsystem %s\n")
	    call pargstr (Memc[str])

	# Write out the image size in pixels

	call dtput (dt, "    nx %d\n")
	    call pargi (IM_LEN(im,1))
	call dtput (dt, "    ny %d\n")
	    call pargi (IM_LEN(im,2))

	# Write out the important parts of the image WCS system including the
	# projection type, the ra and dec of the reference point which may not
	# be the ra and dec of the center and the images limits in projected
	# coordinates.

	call ct_wmwcs (im, dt, mw, coo)

	call dtput (dt, "\n")

	# Cleanup.
	call mw_close (mw)
	call sk_close (coo)
	call sfree (sp)

	return (OK)
end


# CT_MKLIST  -- Create the coordinate list symbol table using a coordinate
# file which contains the ra, dec, rawidth, decwidth, and optionally the
# coordinate system, and filters of the cutout region centers, or the task
# parameters ra, dec, rawidth, decwidth, fcsystem, and filters.

int procedure ct_mklist (cl, st)

int	cl		#I the coordinate list file descriptor
pointer st		#O the field center coordinate list descriptor

double	ra, dec, rawidth, decwidth
pointer	sp, str, str2, sym, coo
int	nfields, nfilters, ip

int	pixels
pointer	stopen(), stenter()
int	ctod(), ct_mkdic(), sk_decwstr(), fscan(), nscan()
bool	streq()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call salloc (str2, SZ_FNAME, TY_CHAR)

	# Open the symbol table.
        st = stopen ("fclist", 2 * DEF_LEN_CTFC, DEF_LEN_CTFC,
            10 * DEF_LEN_CTFC)

	# Read in single field center from the parameters.
	if (cl == NULL) {

	    pixels = NO

	    # Read in ra in hours.
	    call clgstr ("ra", Memc[str], SZ_FNAME)
	    ip = 1
	    if (ctod (Memc[str], ip, ra) <= 0)
		ra = INDEFD

	    # Read in dec in degrees.
	    call clgstr ("dec", Memc[str], SZ_FNAME)
	    ip = 1
	    if (ctod (Memc[str], ip, dec) <= 0)
		dec = INDEFD
	
	    # Read in the ra and dec width in arc minutes.
	    call clgstr ("rawidth", Memc[str], SZ_FNAME)
	    ip = 1
	    if (ctod (Memc[str], ip, rawidth) <= 0)
		rawidth = INDEFD
	    if (Memc[str+ip-1] == 'p')
		pixels = YES

	    call clgstr ("decwidth", Memc[str], SZ_FNAME)
	    if (streq (Memc[str], "INDEF") || Memc[str] == EOS) {
		decwidth = rawidth
	    } else {
	        ip = 1
	        if (ctod (Memc[str], ip, decwidth) <= 0)
	            decwidth = INDEFD
	        if (Memc[str+ip-1] == 'p')
	            pixels = YES
	    }

	    # Check for nonsensical values field center and width values.
	    if (IS_INDEFD(ra) || ra < 0.0d0 || ra > 24.0d0) {
		nfields = 0
	    } else if (IS_INDEFD(dec) || dec < -90.0d0 || dec > 90.0d0) {
		nfields = 0
	    } else if (IS_INDEFD(rawidth) || rawidth <= 0.0d0) {
		nfields = 0
	    } else if (pixels == NO && rawidth / 60.0d0 > 360.0d0 ) {
		nfields = 0
	    } else if (IS_INDEFD(decwidth) || decwidth <= 0.0d0) {
		nfields = 0
	    } else if (pixels == NO && decwidth / 60.0d0 > 360.0d0 ) {
		nfields = 0
	    } else {
		call sprintf (Memc[str], SZ_FNAME, "%s1")
		    call pargstr (DEF_CTFC_ROOTNAME)
		sym = stenter (st, Memc[str], LEN_CTFC_STRUCT)
		CT_FCRA(sym) = ra * 15.0d0
		CT_FCDEC(sym) = dec 
		if (pixels == YES) {
		    CT_FCRAWIDTH(sym) = rawidth 
		    CT_FCDECWIDTH(sym) = decwidth 
		    CT_FCXWIDTH(sym) = nint (rawidth)
		    CT_FCYWIDTH(sym) = nint (decwidth)
		} else {
		    CT_FCRAWIDTH(sym) = rawidth / 60.0d0
		    CT_FCDECWIDTH(sym) = decwidth / 60.0d0 
		    CT_FCXWIDTH(sym) = 0
		    CT_FCYWIDTH(sym) = 0
		}
		CT_FCRAUNITS(sym) = SKY_DEGREES
		CT_FCDECUNITS(sym) = SKY_DEGREES
		call clgstr ("fcsystem", Memc[str], SZ_FNAME)
		if (sk_decwstr (Memc[str], coo, NULL) == ERR) {
		    call strcpy (DEF_FCSYSTEM, CT_FCSYSTEM(sym), SZ_FNAME)
		} else {
		    call strcpy (Memc[str], CT_FCSYSTEM(sym), SZ_FNAME)
		}
		call sk_close (coo)
		call clgstr ("filters", Memc[str], SZ_FNAME)
		if (streq (Memc[str], "all"))
		    nfilters = 0
		else
		    nfilters = ct_mkdic (Memc[str], Memc[str2], SZ_FNAME)
		if (nfilters > 0) {
		    call strcpy (Memc[str2], CT_FCFILDICT(sym), SZ_FNAME)
		    call strcpy (Memc[str2+1], CT_FCFILTERS(sym), SZ_FNAME)
		} else {
		    call strcpy ("", CT_FCFILDICT(sym), SZ_FNAME)
		    call strcpy ("", CT_FCFILTERS(sym), SZ_FNAME)
		}

	        # Create the object name from the class "NDWFS" in this case,
		# the ra and dec in degrees, and the equatorial system.
		call ct_objname ("NDWFS", CT_FCRA(sym), CT_FCDEC(sym),
		    CT_FCSYSTEM(sym), CT_FCOBJNAME(sym), SZ_OBJNAME)

		nfields = 1

	    }

	} else {

	    pixels = NO
	    nfields = 0

	    while (fscan (cl) != EOF) {

		call gargd (ra)
		call gargd (dec)
		if (nscan() < 2)
		    next
	        if (ra < 0.0d0 || ra > 24.0d0)
		    next
	        if (dec < -90.0d0 || dec > 90.0d0)
		    next

		call gargwrd (Memc[str], SZ_FNAME)
		if (nscan() < 3)
	    	    call clgstr ("rawidth", Memc[str], SZ_FNAME)
	        ip = 1
	        if (ctod (Memc[str], ip, rawidth) <= 0)
		    rawidth = INDEFD
	        if (Memc[str+ip-1] == 'p')
		    pixels = YES

		call gargwrd (Memc[str2], SZ_FNAME)
		if (nscan() < 4) {
		    decwidth = rawidth
	        } else if (streq (Memc[str2], "INDEF") || Memc[str2] == EOS) {
		    decwidth = rawidth
		} else {
	            ip = 1
	            if (ctod (Memc[str2], ip, decwidth) <= 0)
		        decwidth = INDEFD
	            if (Memc[str2+ip-1] == 'p')
		        pixels = YES
		}

	        if (IS_INDEFD(rawidth) || rawidth <= 0.0d0)
		    next
		if (pixels == NO && (rawidth / 60.0d0 > 360.0d0))
		    next
	        if (IS_INDEFD(decwidth) || decwidth <= 0.0d0)
		    next
		if (pixels == NO && (decwidth / 60.0d0 > 360.0d0))
		    next
		nfields = nfields + 1

		call sprintf (Memc[str], SZ_FNAME, "%s%d")
		    call pargstr (DEF_CTFC_ROOTNAME)
		    call pargi (nfields)
		sym = stenter (st, Memc[str], LEN_CTFC_STRUCT)
		CT_FCRA(sym) = ra * 15.0d0
		CT_FCDEC(sym) = dec 
		if (pixels == YES) {
		    CT_FCRAWIDTH(sym) = rawidth 
		    CT_FCDECWIDTH(sym) = decwidth
		    CT_FCXWIDTH(sym) = nint (rawidth)
		    CT_FCYWIDTH(sym) = nint (decwidth)
		} else {
		    CT_FCRAWIDTH(sym) = rawidth / 60.0d0
		    CT_FCDECWIDTH(sym) = decwidth / 60.0d0 
		    CT_FCXWIDTH(sym) = 0
		    CT_FCYWIDTH(sym) = 0
		}
		CT_FCRAUNITS(sym) = SKY_DEGREES
		CT_FCDECUNITS(sym) = SKY_DEGREES
		call gargwrd (Memc[str], SZ_FNAME)
		if (nscan() < 5)
		    call clgstr ("fcsystem", Memc[str], SZ_FNAME)
		if (sk_decwstr (Memc[str], coo, NULL) == ERR) {
		    call strcpy (DEF_FCSYSTEM, CT_FCSYSTEM(sym), SZ_FNAME)
		} else {
		    call strcpy (Memc[str], CT_FCSYSTEM(sym), SZ_FNAME)
		}
		call sk_close (coo)
		call gargstr (Memc[str], SZ_FNAME)
		if (nscan() < 6)
		    call clgstr ("filters", Memc[str], SZ_FNAME)
		if (streq (Memc[str], "all"))
		    nfilters = 0
		else
		    nfilters = ct_mkdic (Memc[str], Memc[str2], SZ_FNAME)
		if (nfilters > 0) {
		    call strcpy (Memc[str2], CT_FCFILDICT(sym), SZ_FNAME)
		    call strcpy (Memc[str2+1], CT_FCFILTERS(sym), SZ_FNAME)
		} else {
		    call strcpy ("", CT_FCFILDICT(sym), SZ_FNAME)
		    call strcpy ("", CT_FCFILTERS(sym), SZ_FNAME)
		}

	        # Create the object name from the class "NDWFS" in this case,
		# the ra and dec in degrees, and the equatorial system.
		call ct_objname ("NDWFS", CT_FCRA(sym), CT_FCDEC(sym),
		    CT_FCSYSTEM(sym), CT_FCOBJNAME(sym), SZ_OBJNAME)
	    }

	}


	call sfree (sp)

	return (nfields)
end


# CT_OVLAP -- Find the images which overlap the current field center and
# record them in the image symbol table.

int procedure ct_ovlap (dt, rec, csym, imst, fildict, maxch)

pointer	dt			#I the database descriptor
int	rec			#I the current record number 
int	csym			#I the current field center symbol
pointer	imst			#I the image sybol table
char	fildict[ARB]		#O the output filter dictionary
int	maxch			#I the maximum size of the string dictionary

int	novlap
int	ct_sovlap(), ct_povlap()

begin
	if (CT_FCXWIDTH(csym) <= 0 && CT_FCYWIDTH(csym) <= 0)
	    novlap = ct_sovlap (dt, rec, csym, imst, fildict, maxch)
	else
	    novlap = ct_povlap (dt, rec, csym, imst, fildict, maxch)

	return (novlap)
end


# CT_SOVLAP -- Find the images which overlap the current field center and
# record them in the image symbol table. The overlap widths are defined in
# projected coordinates.

int procedure ct_sovlap (dt, rec, csym, imst, fildict, maxch)

pointer	dt			#I the database descriptor
int	rec			#I the current record number 
int	csym			#I the current field center symbol
pointer	imst			#I the image sybol table
char	fildict[ARB]		#O the output filter dictionary
int	maxch			#I the maximum size of the string dictionary

double	imra, imdec, imximin, imximax, imrawidth, imetamax, imetamin, imdecwidth
double	cosadiff, cosimdec, sinimdec, radiff, decdiff, xic, etac, ximin, ximax
double	etamin, etamax, oximin, oximax, oetamin, oetamax, cosfcdec, sinfcdec
double	sinadiff, adiff, pa, fcra, fcdec
pointer	sp, str, str2, filter, mw, ct, isym, incoo, outcoo
int	i, ip, novlap

double	dtgetd()
pointer	ct_projwcs(), mw_sctran(), stenter()
int	dtlocate(), ctowrd(), strdic(), sk_decwstr()
bool	strne()
errchk	dtgstr()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call salloc (str2, SZ_FNAME, TY_CHAR)
	call salloc (filter, SZ_FNAME, TY_CHAR)

	# Compute and store the spherical trig parameters of the region center.

	# Loop over the data base records.

	novlap = 0
	fildict[1] = EOS
	do i = 1, DT_NRECS(dt) {

	    # Locate the next database record.

	    iferr (rec = dtlocate (dt, DT_NAME(dt,i)))
		next

	    # Get the image filter id. If the filter is is missing skip
	    # to the next record.

	    iferr (call dtgstr (dt, rec, "filter", Memc[str], SZ_FNAME))
		next
	    ip = 1
	    if (ctowrd (Memc[str], ip, Memc[str2], SZ_FNAME) <= 0)
		next

	    # Go to next image if this filter does not match one in the
	    # dictionary. Skip this step when dealing  with the all filters
	    # case, i.e. the filter dictionary is the NULL string.

	    if (CT_FCFILDICT(csym) != EOS) {
	        if (strdic (Memc[str2], Memc[filter], SZ_FNAME,
	            CT_FCFILDICT(csym)) <= 0)
		    next
	        if (strne (Memc[str2], Memc[filter]))
		    next
	    } else {
		call strcpy (Memc[str2], Memc[filter], SZ_FNAME)
	    }

	    # Get the image reference point coordinates in degrees, and the
	    # image size in ra and dec in degrees. Note the assumption the
	    # image coordinates are equatorial coordinates in hours and
	    # degrees.

	    imra = 15.0d0 * dtgetd (dt, rec, "ra")
	    imdec = dtgetd (dt, rec, "dec")
	    imximax = dtgetd (dt, rec, "ximax")
	    imximin = dtgetd (dt, rec, "ximin")
	    imrawidth = abs (imximax - imximin)
	    imetamax = dtgetd (dt, rec, "etamax")
	    imetamin = dtgetd (dt, rec, "etamin")
	    imdecwidth = abs (imetamax - imetamin)

	    # Transform the field center coordinates to the image
	    # coordinate system. For now the assumption is that
	    # all coordinate systems are equatorial coordinate systems.

	    if (sk_decwstr (CT_FCSYSTEM(csym), incoo, NULL) == OK)
		;
	    call sk_seti (incoo, S_NLNGUNITS, CT_FCRAUNITS(csym))
	    call sk_seti (incoo, S_NLATUNITS, CT_FCDECUNITS(csym))
	    iferr (call dtgstr (dt, rec, "ccsystem", Memc[str], SZ_FNAME))
		call strcpy ("ICRS", Memc[str], SZ_FNAME)
	    if (sk_decwstr (Memc[str], outcoo, NULL) == OK)
		;
	    call sk_seti (outcoo, S_NLNGUNITS, SKY_DEGREES)
	    call sk_seti (outcoo, S_NLATUNITS, SKY_DEGREES)
	    call sk_ultran (incoo, outcoo, CT_FCRA(csym), CT_FCDEC(csym),
		fcra, fcdec, 1)
	    call sk_close (incoo)
	    call sk_close (outcoo)

	    # Compute and store the field center and image spherical trig
	    # parameters.

	    cosfcdec = cos (DDEGTORAD(fcdec))
	    sinfcdec = sin (DDEGTORAD(fcdec))
	    cosadiff = cos (DDEGTORAD (fcra - imra))
	    sinadiff = sin (DDEGTORAD (fcra - imra))
	    cosimdec = cos (DDEGTORAD(imdec))
	    sinimdec = sin (DDEGTORAD(imdec))

	    # Do a quick check on the ra and dec overlap by computing the
	    # arc distance between the field center and the image center
	    # and ra and dec.

	    # Compute the arc distance and position angle.
	    adiff = DRADTODEG (acos (sinfcdec * sinimdec + cosfcdec *
	        cosimdec * cosadiff)) 
	    pa = atan2 (-cosimdec * sinadiff,  cosfcdec * sinimdec -
	        sinfcdec * cosimdec * cosadiff)
	    if (pa < 0.0d0)
		pa = pa + DTWOPI
	    if (pa >= DTWOPI)
		pa = pa - DTWOPI

	    # Check the ra and dec width constraints. This assumes that
	    # the arc difference is not too big.
	    radiff = adiff * sin (pa)
	    if (radiff < 0.0)
	        radiff = - DRADTODEG (acos (sinfcdec * sinfcdec + cosfcdec *
	            cosfcdec * cosadiff))
	    else
	        radiff =DRADTODEG (acos (sinfcdec * sinfcdec + cosfcdec *
	            cosfcdec * cosadiff))
	    if (abs (radiff) > (imrawidth + CT_FCRAWIDTH(csym)) / 2.0d0)
		next

	    decdiff = adiff * cos (pa)
	    if (decdiff < 0.0)
	        decdiff = -DRADTODEG (acos (sinfcdec * sinimdec + cosfcdec *
	            cosimdec)) 
	    else
	        decdiff = DRADTODEG (acos (sinfcdec * sinimdec + cosfcdec *
	            cosimdec)) 
	    if (abs (decdiff) > (imdecwidth + CT_FCDECWIDTH(csym)) / 2.0d0)
		next

	    # Determine what part of the image projected ra and dec coordinate
	    # space the cutout image occupies.

	    iferr (call dtgstr (dt, rec, "projection", Memc[str], SZ_FNAME))
		call strcpy ("tan", Memc[str], SZ_FNAME)
	    imra = dtgetd (dt, rec, "raref")
	    imdec = dtgetd (dt, rec, "decref")
	    mw = ct_projwcs (Memc[str], imra, imdec, SKY_DEGREES, SKY_DEGREES)
	    ct = mw_sctran (mw, "world", "logical", 03B)
	    call mw_c2trand (ct, fcra, fcdec, xic, etac)
	    ximin = xic - CT_FCRAWIDTH(csym) / 2.0d0
	    ximax = xic + CT_FCRAWIDTH(csym) / 2.0d0
	    etamin = etac - CT_FCDECWIDTH(csym) / 2.0d0
	    etamax = etac + CT_FCDECWIDTH(csym) / 2.0d0
	    call mw_ctfree (ct)
	    call mw_close (mw)

	    # Determine if there is any overlap at all between the output
	    # image region and the input image.

	    if (ximax < imximin || ximin > imximax || etamax < imetamin ||
	        etamin > imetamax)
		next
	    novlap = novlap + 1

	    # Enter a new symbol into the image symbol table.

	    call sprintf (Memc[str], SZ_FNAME, "%s%d")
	        call pargstr (DEF_CTIM_ROOTNAME)
		call pargi (novlap)
	    isym = stenter (imst, Memc[str], LEN_CTIM_STRUCT)
	    call dtgstr (dt, rec, "image", Memc[str], SZ_FNAME)
	    call strcpy (Memc[str], CT_IMNAME(isym), SZ_FNAME)
	    call strcpy (Memc[filter], CT_IMFILTER(isym), SZ_FNAME)
	    CT_IMXIOFF(isym) = radiff
	    CT_IMETAOFF(isym) = decdiff

	    # Compute the cutout region in projected ra and dec space.

	    CT_IMXIC(isym) = xic
	    CT_IMETAC(isym) = etac
	    CT_IMXIMIN(isym) = ximin
	    CT_IMXIMAX(isym) = ximax
	    CT_IMETAMIN(isym) = etamin
	    CT_IMETAMAX(isym) = etamax

	    # Compute the overlap region in projected ra and dec space.

	    oximin = max (ximin, imximin)
	    oximax = min (ximax, imximax)
	    oetamin = max (etamin, imetamin)
	    oetamax = min (etamax, imetamax)
	    CT_IMOXIMIN(isym) = oximin
	    CT_IMOXIMAX(isym) = oximax
	    CT_IMOETAMIN(isym) = oetamin
	    CT_IMOETAMAX(isym) = oetamax
	    CT_IMOAREA(isym) = (oximax - oximin) * (oetamax - oetamin)

	    # Create the internal filter dictionary.

	    if (novlap == 1) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    } else if (strdic (Memc[filter], Memc[str], SZ_FNAME,
	        fildict) <= 0) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    } else if (strne (Memc[filter], Memc[str])) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    }
	}

	# If the filter dictionary is defined overwrite the internal
	# filter dictionary.
	if (CT_FCFILDICT(csym) != EOS) {
	    call strcpy (CT_FCFILDICT(csym), fildict, maxch)
	}

	call sfree (sp)

	return (novlap)
end



# CT_POVLAP -- Find the images which overlap the current field center and
# record them in the image symbol table. The overlap widths are defined in
# projected coordinates.

int procedure ct_povlap (dt, rec, csym, imst, fildict, maxch)

pointer	dt			#I the database descriptor
int	rec			#I the current record number 
int	csym			#I the current field center symbol
pointer	imst			#I the image sybol table
char	fildict[ARB]		#O the output filter dictionary
int	maxch			#I the maximum size of the string dictionary

double	imxmin, imxmax, imymax, imymin
double	imra, imdec, xref, yref, xscale, yscale, xrot, yrot
double	xic, etac, ximin, ximax, etamin, etamax, fcra, fcdec
double	oximin, oximax, oetamin, oetamax
pointer	sp, str, str2, filter, mw, ct, isym, incoo, outcoo
int	i, ip, novlap, raax, decax

double	dtgetd()
pointer	ct_mkwcs(), mw_sctran(), stenter()
int	dtlocate(), ctowrd(), strdic(), sk_decwstr(), dtgeti()
bool	strne()
errchk	dtgstr()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call salloc (str2, SZ_FNAME, TY_CHAR)
	call salloc (filter, SZ_FNAME, TY_CHAR)

	# Compute and store the spherical trig parameters of the region center.

	# Loop over the data base records.

	novlap = 0
	fildict[1] = EOS
	do i = 1, DT_NRECS(dt) {

	    # Locate the next database record.

	    iferr (rec = dtlocate (dt, DT_NAME(dt,i)))
		next

	    # Get the image filter id. If the filter is is missing skip
	    # to the next record.

	    iferr (call dtgstr (dt, rec, "filter", Memc[str], SZ_FNAME))
		next
	    ip = 1
	    if (ctowrd (Memc[str], ip, Memc[str2], SZ_FNAME) <= 0)
		next

	    # Go to next image if this filter does not match one in the
	    # dictionary. Skip this step when dealing  with the all filters
	    # case, i.e. the filter dictionary is the NULL string.

	    if (CT_FCFILDICT(csym) != EOS) {
	        if (strdic (Memc[str2], Memc[filter], SZ_FNAME,
	            CT_FCFILDICT(csym)) <= 0)
		    next
	        if (strne (Memc[str2], Memc[filter]))
		    next
	    } else {
		call strcpy (Memc[str2], Memc[filter], SZ_FNAME)
	    }

	    # Get the reference point coordinates in degrees and the image
	    # size in pixels. Note the assumption that the image coordinates
	    # are equatorial coordinates in hours and degrees.

	    imxmax = dtgetd (dt, rec, "nx")
	    imxmin = 1.0d0
	    imymax = dtgetd (dt, rec, "ny")
	    imymin = 1.0d0

	    # Transform the field center coordinates to the image  coordinate
	    # system. For now the assumption is that all coordinate systems are
	    # equatorial coordinate systems.

	    if (sk_decwstr (CT_FCSYSTEM(csym), incoo, NULL) == OK)
		;
	    call sk_seti (incoo, S_NLNGUNITS, CT_FCRAUNITS(csym))
	    call sk_seti (incoo, S_NLATUNITS, CT_FCDECUNITS(csym))
	    iferr (call dtgstr (dt, rec, "ccsystem", Memc[str], SZ_FNAME))
		call strcpy ("ICRS", Memc[str], SZ_FNAME)
	    if (sk_decwstr (Memc[str], outcoo, NULL) == OK)
		;
	    call sk_seti (outcoo, S_NLNGUNITS, SKY_DEGREES)
	    call sk_seti (outcoo, S_NLATUNITS, SKY_DEGREES)
	    call sk_ultran (incoo, outcoo, CT_FCRA(csym), CT_FCDEC(csym),
		fcra, fcdec, 1)
	    call sk_close (incoo)
	    call sk_close (outcoo)

	    # Now compute the location of the field center in the input
	    # image pixel space by extracting the appropriate quantities
	    # from the database, creating the wcs, and locating the
	    # center of the field.

	    iferr (call dtgstr (dt, rec, "projection", Memc[str], SZ_FNAME))
		call strcpy ("tan", Memc[str], SZ_FNAME)
	    raax = dtgeti (dt, rec, "raax")
	    decax = dtgeti (dt, rec, "decax")
	    imra = dtgetd (dt, rec, "raref")
	    imdec = dtgetd (dt, rec, "decref")
	    xref = dtgetd (dt, rec, "xref")
	    yref = dtgetd (dt, rec, "yref")
	    xscale = dtgetd (dt, rec, "xscale")
	    yscale = dtgetd (dt, rec, "yscale")
	    xrot = dtgetd (dt, rec, "xrot")
	    yrot = dtgetd (dt, rec, "yrot")

	    mw = ct_mkwcs (Memc[str], imra, imdec, xref, yref, xscale,
		yscale, xrot, yrot, raax, decax)
	    ct = mw_sctran (mw, "world", "logical", 03B)
	    call mw_c2trand (ct, fcra, fcdec, xic, etac)
	    call mw_ctfree (ct)
	    call mw_close (mw)

	    # Determine if there is any overlap at all between the output
	    # image region and the input image.

	    ximin = nint(xic) - (CT_FCXWIDTH(csym) - 1.0d0) / 2.0d0
	    ximax = nint(xic) + (CT_FCXWIDTH(csym) - 1.0d0) / 2.0d0
	    etamin = nint(etac) - (CT_FCYWIDTH(csym) - 1.0d0) / 2.0d0
	    etamax = nint(etac) + (CT_FCYWIDTH(csym) - 1.0d0) / 2.0d0
	    if (ximax < imxmin || ximin > imxmax || etamax < imymin ||
	        etamin > imymax)
		next
	    novlap = novlap + 1

	    # Enter a new symbol into the image symbol table.

	    call sprintf (Memc[str], SZ_FNAME, "%s%d")
	        call pargstr (DEF_CTIM_ROOTNAME)
		call pargi (novlap)
	    isym = stenter (imst, Memc[str], LEN_CTIM_STRUCT)
	    call dtgstr (dt, rec, "image", Memc[str], SZ_FNAME)
	    call strcpy (Memc[str], CT_IMNAME(isym), SZ_FNAME)
	    call strcpy (Memc[filter], CT_IMFILTER(isym), SZ_FNAME)
	    CT_IMXIOFF(isym) = ((imxmax + 1.0d0) / 2.0d0 - xic)
	    CT_IMETAOFF(isym) = ((imymax + 1.0d0) / 2.0d0 - etac)

	    # Compute the cutout region in pixels. Adjust the endpoints
	    # until the correct number of pixels is obtained.

	    CT_IMXIC(isym) = xic 
	    CT_IMETAC(isym) = etac
	    CT_IMXIMIN(isym) = nint (ximin)
	    CT_IMXIMAX(isym) = nint (ximax)
	    CT_IMETAMIN(isym) = nint (etamin)
	    CT_IMETAMAX(isym) = nint (etamax)

	    while ((CT_IMXIMAX(isym) - CT_IMXIMIN(isym) + 1.0d0) >
	        (CT_FCXWIDTH(csym) + 0.5d0)) {
		CT_IMXIMAX(isym) = CT_IMXIMAX(isym) - 1.0d0
	    }
	    while ((CT_IMXIMAX(isym) - CT_IMXIMIN(isym) + 1.0d0) <
	        (CT_FCXWIDTH(csym) - 0.5d0)) {
		CT_IMXIMAX(isym) = CT_IMXIMAX(isym) + 1.0d0
	    }

	    while ((CT_IMETAMAX(isym) - CT_IMETAMIN(isym) + 1.0d0) >
	        (CT_FCYWIDTH(csym) + 0.5d0)) {
		CT_IMETAMAX(isym) = CT_IMETAMAX(isym) - 1.0d0
	    }
	    while ((CT_IMETAMAX(isym) - CT_IMETAMIN(isym) + 1.0d0) <
	        (CT_FCYWIDTH(csym) - 0.5d0)) {
		CT_IMETAMAX(isym) = CT_IMETAMAX(isym) + 1.0d0
	    }

	    # Compute the overlap region in projected ra and dec space.

	    oximin = max (CT_IMXIMIN(isym), imxmin)
	    oximax = min (CT_IMXIMAX(isym), imxmax)
	    oetamin = max (CT_IMETAMIN(isym), imymin)
	    oetamax = min (CT_IMETAMAX(isym), imymax)
	    CT_IMOXIMIN(isym) = oximin
	    CT_IMOXIMAX(isym) = oximax
	    CT_IMOETAMIN(isym) = oetamin
	    CT_IMOETAMAX(isym) = oetamax
	    CT_IMOAREA(isym) = (oximax - oximin) * (oetamax - oetamin)

	    # Create the internal filter dictionary.

	    if (novlap == 1) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    } else if (strdic (Memc[filter], Memc[str], SZ_FNAME,
	        fildict) <= 0) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    } else if (strne (Memc[filter], Memc[str])) {
		call strcat (",", fildict, maxch)
		call strcat (Memc[filter], fildict, maxch)
	    }
	}

	# If the filter dictionary is defined overwrite the internal
	# filter dictionary.
	if (CT_FCFILDICT(csym) != EOS) {
	    call strcpy (CT_FCFILDICT(csym), fildict, maxch)
	}

	call sfree (sp)

	return (novlap)
end



# CT_GIMPTRS -- Find the images which overlap a particular filter and then 
# sort the images based on the overlap area.

int procedure ct_gimptrs (imst, filter, imptrs, novlap)

pointer	imst				#I the image symbol tables
char	filter[ARB]			#I the filter id to be extracted
pointer	imptrs[ARB]			#O the matching image symbols
int	novlap				#I the maximum number of overlaps

pointer	sp, tmpimptrs, area, index, str, sym
int	i, nim

pointer	stfind()
bool	strne()

begin
	nim = 0

	# Allocate working space.

	call smark (sp)
	call salloc (tmpimptrs, novlap, TY_INT)
	call salloc (area, novlap, TY_DOUBLE)
	call salloc (index, novlap, TY_INT)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Loop over the images which overlap the output image region.

	do i = 1, novlap {

	    # Get the image symbol.

	    call sprintf (Memc[str], SZ_FNAME, "%s%d")
		call pargstr (DEF_CTIM_ROOTNAME)
		call pargi (i)
	    sym = stfind (imst, Memc[str])
	    if (sym == NULL)
		next

	    # Check the filter name. 

	    if (strne (CT_IMFILTER(sym), filter))
		next

	    # Extract the image symbol and the overlap area.

	    Memi[tmpimptrs+nim] = sym
	    Memd[area+nim] = CT_IMOAREA(sym)
	    nim = nim + 1
	}

	# Sort on the overlap array and reorder the output image symbol
	# list.

	call ct_qsortd (Memd[area], Memi[index], Memi[index], nim)
	do i = 1, nim
	   imptrs[i] = Memi[tmpimptrs+Memi[index+i-1]-1] 

	call sfree (sp)

	return (nim)
end


# CT_LTRIM -- Create the output image by selecting the input image with the
# largest overlap region and outputting the overlap region only.

int procedure ct_ltrim (csym, imptrs, nim, outimage, pixin)

pointer	csym			#I the field center symbol
pointer	imptrs[ARB]		#I the array of overlapping image symbols
int	nim			#I the number of overlapping images
char	outimage[ARB]		#I the output image name
int	pixin			#I is the region defined in pixels ?

double	area, x1, x2, x3, x4, y1, y2, y3, y4, xmin, xmax, ymin, ymax
real	shifts[2]
pointer	im, mw, pmw, ct, outim, obuf, ibuf, coo
int	i, ol1, refno, ncols, nlines

pointer	immap(), ct_pmw(), mw_sctran()
pointer	imps2x(), imgs2x(), imps2d(), imgs2d(), imps2r(), imgs2r()
pointer	imps2l(), imgs2l()
int	sk_decim(), sk_stati()
errchk	immap()


begin
	# Find the reference image by determining which image has the largest
	# overlap area. This is not really necessary since the image symbols
	# were sorted in a previous step but ...

	area = -MAX_REAL
	refno = 0
	do i = 1, nim {
	    if (CT_IMOAREA(imptrs[i]) < area)
		next
	    refno = i
	    area = CT_IMOAREA(imptrs[i])
	}
	if (refno <= 0)
	    return (ERR)

	# Open the reference image.

	iferr (im = immap (CT_IMNAME(imptrs[refno]), READ_ONLY, 0))
	    return (ERR)

	# Open the reference image WCS. Don't need to check this because the
	# image is not in the database if the WCS is invalid.

	if (sk_decim (im, "logical", mw, coo) == OK)
	    ;

	# Determine the position of the overlap region in the input image.
	# If pixin = yes this was computed in a previous step otherwise
	# the image WCS must be used to compute the pixel overlap from the
	# overlap in projected coordinates.

	if (pixin == YES) {

	    xmin = CT_IMOXIMIN(imptrs[refno])
	    xmax = CT_IMOXIMAX(imptrs[refno])
	    ymin = CT_IMOETAMIN(imptrs[refno])
	    ymax = CT_IMOETAMAX(imptrs[refno])

	} else {


	    # Compute the linear part of the transformation and determine the
	    # input image pixel coordinates of the corners of the overlap
	    # region defined in projected coordinates. 


	    pmw = ct_pmw (mw)
	    ct = mw_sctran (pmw, "world", "logical", 03B)
	    if (sk_stati (coo, S_PLNGAX) < sk_stati(coo, S_PLATAX)) {
	        call mw_c2trand (ct, CT_IMOXIMIN(imptrs[refno]),
	            CT_IMOETAMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMOXIMAX(imptrs[refno]),
	            CT_IMOETAMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMOXIMAX(imptrs[refno]),
	            CT_IMOETAMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMOXIMIN(imptrs[refno]),
	            CT_IMOETAMAX(imptrs[refno]), x4, y4)
	    } else {
	        call mw_c2trand (ct, CT_IMOETAMIN(imptrs[refno]),
	            CT_IMOXIMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMOETAMAX(imptrs[refno]),
	            CT_IMOXIMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMOETAMAX(imptrs[refno]),
	            CT_IMOXIMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMOETAMIN(imptrs[refno]),
	            CT_IMOXIMAX(imptrs[refno]), x4, y4)
	    }
	    call mw_ctfree (ct)
	    call mw_close (pmw)
	    call sk_close (coo)

	    # Compute the min and max x and y values of the overlap region.
	    # in the input image.
	    xmin = min (x1, x2, x3, x4)
	    xmax = max (x1, x2, x3, x4)
	    ymin = min (y1, y2, y3, y4)
	    ymax = max (y1, y2, y3, y4)
	}

	# Convert the min and max values to integer pixel coordinates.

	CT_IMIX1(imptrs[refno]) = max (1, min (nint (xmin), IM_LEN(im,1)))
	CT_IMIX2(imptrs[refno]) = max (1, min (nint (xmax), IM_LEN(im,1)))
	CT_IMIY1(imptrs[refno]) = max (1, min (nint (ymin), IM_LEN(im,2)))
	CT_IMIY2(imptrs[refno]) = max (1, min (nint (ymax), IM_LEN(im,2)))

	# Open the output image.

	outim = immap (outimage, NEW_COPY, im)

	# Determine the size of the output image.

	ncols = CT_IMIX2(imptrs[refno]) - CT_IMIX1(imptrs[refno]) + 1
	nlines = CT_IMIY2(imptrs[refno]) - CT_IMIY1(imptrs[refno]) + 1
	IM_LEN(outim,1) = ncols
	IM_LEN(outim,2) = nlines

	# Copy the data being careful to preserve the pixel type.

	switch (IM_PIXTYPE(im)) {
	case TY_COMPLEX:
	    ol1 = 1
	    do i = CT_IMIY1(imptrs[refno]), CT_IMIY2(imptrs[refno]) {
	        obuf = imps2x (outim, 1, ncols, ol1, ol1)
	        ibuf = imgs2x (im, CT_IMIX1(imptrs[refno]),
	            CT_IMIX2(imptrs[refno]), i, i)
	        call amovx (Memx[ibuf], Memx[obuf], ncols)
	        ol1 = ol1 + 1
	    }

	case TY_REAL:
	    ol1 = 1
	    do i = CT_IMIY1(imptrs[refno]), CT_IMIY2(imptrs[refno]) {
	        obuf = imps2r (outim, 1, ncols, ol1, ol1)
	        ibuf = imgs2r (im, CT_IMIX1(imptrs[refno]),
	            CT_IMIX2(imptrs[refno]), i, i)
		call amovr (Memr[ibuf], Memr[obuf], ncols)
		ol1 = ol1 + 1
	    }

	case TY_DOUBLE:
	    ol1 = 1
	    do i = CT_IMIY1(imptrs[refno]), CT_IMIY2(imptrs[refno]) {
	        obuf = imps2d (outim, 1, ncols, ol1, ol1)
	        ibuf = imgs2d (im, CT_IMIX1(imptrs[refno]),
	            CT_IMIX2(imptrs[refno]), i, i)
		call amovd (Memd[ibuf], Memd[obuf], ncols)
		ol1 = ol1 + 1
	    }

	default:
	    ol1 = 1
	    do i = CT_IMIY1(imptrs[refno]), CT_IMIY2(imptrs[refno]) {
	        obuf = imps2l (outim, 1, ncols, ol1, ol1)
	        ibuf = imgs2l (im, CT_IMIX1(imptrs[refno]),
	            CT_IMIX2(imptrs[refno]), i, i)
		call amovl (Meml[ibuf], Meml[obuf], ncols)
		ol1 = ol1 + 1
	    }
	}

	# Compute the WCS for the output image.

	shifts[1] = real (1 - CT_IMIX1(imptrs[refno]))
	shifts[2] = real (1 - CT_IMIY1(imptrs[refno]))
	call mw_shift (mw, shifts, 03B)
	call mw_saveim (mw, outim)

	# Delete extra WCS keywords assuming for now a 2D image. Make this
	# into a header editing routine at some point ?
	iferr (call imdelf (outim, "WCSDIM"))
	    ;
	iferr (call imdelf (outim, "LTV1"))
	    ;
	iferr (call imdelf (outim, "LTV2"))
	    ;
	iferr (call imdelf (outim, "LTM1_1"))
	    ;
	iferr (call imdelf (outim, "LTM1_2"))
	    ;
	iferr (call imdelf (outim, "LTM2_1"))
	    ;
	iferr (call imdelf (outim, "LTM2_2"))
	    ;
	iferr (call imdelf (outim, "WAT0_001"))
	    ;
	iferr (call imdelf (outim, "WAT1_001"))
	    ;
	iferr (call imdelf (outim, "WAT2_001"))
	    ;

	# Add other keywords. FIELDNAM is automatically inherited but OBJECT
	# (TITLE), OBJNAME, and OBJTYPE must be modified.

	call sprintf (IM_TITLE(outim), SZ_OBJNAME, "%s %s-band")
	    call pargstr (CT_FCOBJNAME(csym))
	    call pargstr (CT_IMFILTER(imptrs[refno]))
	call imastr (outim, "OBJNAME", "junk")
	call imastr (outim, "OBJNAME", CT_FCOBJNAME(csym))
	call imastr (outim, "OBJTYPE", "cutout") 

	# Cleanup.

	call imunmap (outim)
	call mw_close (mw)
	call imunmap (im)

	return (OK)
end


# CT_LNOTRIM -- Create the output image by selecting the input image with the
# largest overlap region and copying the overlap region into the output image.
# Undefined pixels are set to blank.

int procedure ct_lnotrim (csym, imptrs, nim, outimage, blank, pixin)

pointer	csym			#I the field center symbol
pointer	imptrs[ARB]		#I the array of overlapping image symbols
int	nim			#I the number of overlapping images
char	outimage[ARB]		#I the output image name
real	blank			#I the undefined pixel value.
int	pixin			#I is the region defined in pixels ?

double	area, x1, x2, x3, x4, y1, y2, y3, y4, xmin, xmax, ymin, ymax
real	shifts[2]
pointer	im, outim, mw, coo, pmw, ct, obuf, ibuf
int	i, ol1, refno, ixmin, ixmax, iymin, iymax, ncols, nlines, itemp
int	ixshift, iyshift

pointer	immap(), ct_pmw(), mw_sctran(), imps2l(), imgs2l(), imps2r(), imgs2r()
pointer	imps2d(), imgs2d(), imps2x(), imgs2x()
int	sk_decim(), sk_stati()
errchk	immap()

begin
	# Find the reference image by determining which image has the largest
	# overlap area. This is not really necessary since the image symbols
	# were sorted in a previous step but ...

	area = -MAX_REAL
	refno = 0
	do i = 1, nim {
	    if (CT_IMOAREA(imptrs[i]) < area)
		next
	    refno = i
	    area = CT_IMOAREA(imptrs[i])
	}
	if (refno <= 0)
	    return (ERR)

	# Open the reference image.

	iferr (im = immap (CT_IMNAME(imptrs[refno]), READ_ONLY, 0))
	    return (ERR)

	# Open the reference image WCS. Don't need to check this because the
	# image is not in the database if the WCS is invalid.

	if (sk_decim (im, "logical", mw, coo) == OK)
	    ;

	# Compute and extract the overlap region filling undefined pixels
	# with blanks. If pixin = yes the overlap region has already been
	# computed in a previous step, otherwise if is computed using the
	# input image WCS.

	if (pixin == YES) {

	    xmin = CT_IMOXIMIN(imptrs[refno])
	    xmax = CT_IMOXIMAX(imptrs[refno])
	    ymin = CT_IMOETAMIN(imptrs[refno])
	    ymax = CT_IMOETAMAX(imptrs[refno])
	    CT_IMIX1(imptrs[refno]) = max (1, min (nint (xmin), IM_LEN(im,1)))
	    CT_IMIX2(imptrs[refno]) = max (1, min (nint (xmax), IM_LEN(im,1)))
	    CT_IMIY1(imptrs[refno]) = max (1, min (nint (ymin), IM_LEN(im,2)))
	    CT_IMIY2(imptrs[refno]) = max (1, min (nint (ymax), IM_LEN(im,2)))

	    ixmin = nint (CT_IMXIMIN(imptrs[refno]))
	    ixmax = nint (CT_IMXIMAX(imptrs[refno]))
	    iymin = nint (CT_IMETAMIN(imptrs[refno]))
	    iymax = nint (CT_IMETAMAX(imptrs[refno]))

	} else {

	    # Compute the linear part of the transformation.

	    pmw = ct_pmw (mw)
	    ct = mw_sctran (pmw, "world", "logical", 03B)

	    # Determine the input image pixel coordinates of the corners of the
	    # overlap region defined in projected coordinates.  

	    if (sk_stati (coo, S_PLNGAX) < sk_stati(coo, S_PLATAX)) {
	        call mw_c2trand (ct, CT_IMOXIMIN(imptrs[refno]),
	            CT_IMOETAMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMOXIMAX(imptrs[refno]),
	            CT_IMOETAMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMOXIMAX(imptrs[refno]),
	            CT_IMOETAMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMOXIMIN(imptrs[refno]),
	            CT_IMOETAMAX(imptrs[refno]), x4, y4)
	    } else {
	        call mw_c2trand (ct, CT_IMOETAMIN(imptrs[refno]),
	            CT_IMOXIMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMOETAMAX(imptrs[refno]),
	            CT_IMOXIMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMOETAMAX(imptrs[refno]),
	            CT_IMOXIMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMOETAMIN(imptrs[refno]),
	            CT_IMOXIMAX(imptrs[refno]), x4, y4)
	    }
	    xmin = min (x1, x2, x3, x4)
	    xmax = max (x1, x2, x3, x4)
	    ymin = min (y1, y2, y3, y4)
	    ymax = max (y1, y2, y3, y4)
	    CT_IMIX1(imptrs[refno]) = max (1, min (nint (xmin), IM_LEN(im,1)))
	    CT_IMIX2(imptrs[refno]) = max (1, min (nint (xmax), IM_LEN(im,1)))
	    CT_IMIY1(imptrs[refno]) = max (1, min (nint (ymin), IM_LEN(im,2)))
	    CT_IMIY2(imptrs[refno]) = max (1, min (nint (ymax), IM_LEN(im,2)))

	    # Determine the input image pixel coordinates of the corners of the
	    # user field which is defined in projected coordinates.  Do the
	    # computation in double and convert to integers at the end.

	    if (sk_stati (coo, S_PLNGAX) < sk_stati(coo, S_PLATAX)) {
	        call mw_c2trand (ct, CT_IMXIMIN(imptrs[refno]),
	            CT_IMETAMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMXIMAX(imptrs[refno]),
	            CT_IMETAMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMXIMAX(imptrs[refno]),
	            CT_IMETAMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMXIMIN(imptrs[refno]),
	            CT_IMETAMAX(imptrs[refno]), x4, y4)
	    } else {
	        call mw_c2trand (ct, CT_IMETAMIN(imptrs[refno]),
	            CT_IMXIMIN(imptrs[refno]), x1, y1)
	        call mw_c2trand (ct, CT_IMETAMAX(imptrs[refno]),
	            CT_IMXIMIN(imptrs[refno]), x2, y2)
	        call mw_c2trand (ct, CT_IMETAMAX(imptrs[refno]),
	            CT_IMXIMAX(imptrs[refno]), x3, y3)
	        call mw_c2trand (ct, CT_IMETAMIN(imptrs[refno]),
	            CT_IMXIMAX(imptrs[refno]), x4, y4)
	    }
	    xmin = min (x1, x2, x3, x4)
	    xmax = max (x1, x2, x3, x4)
	    ymin = min (y1, y2, y3, y4)
	    ymax = max (y1, y2, y3, y4)
	    ixmin = nint (xmin)
	    ixmax = nint (xmax)
	    iymin = nint (ymin)
	    iymax = nint (ymax)

	    # Cleanup the coordinate transformation pointers.
	    call mw_ctfree (ct)
	    call mw_close (pmw)
	    call sk_close (coo)
	}


	# Compute the size of the output image.

	ncols = ixmax - ixmin + 1
	nlines = iymax - iymin + 1

	# Compute the shift required to make the first output image pixel
	# be located at pixel 1,1.

	ixshift = 1 - ixmin
	iyshift = 1 - iymin

	# Compute the coordinates of the overlap region in the output image.
	# Check for out of bounds conditions and adjust the input and output
	# overlap coordinates accordingly.

	CT_IMOX1(imptrs[refno]) = CT_IMIX1(imptrs[refno]) + ixshift
	if (CT_IMOX1(imptrs[refno]) < 1) {
	    itemp = 1 - CT_IMOX1(imptrs[refno])
	    CT_IMIX1(imptrs[refno]) = CT_IMIX1(imptrs[refno]) + itemp
	    CT_IMOX1(imptrs[refno]) = CT_IMOX1(imptrs[refno]) + itemp
	}
	CT_IMOX2(imptrs[refno]) = CT_IMIX2(imptrs[refno]) + ixshift 
	if (CT_IMOX2(imptrs[refno]) > ncols) {
	    itemp = ncols - CT_IMOX2(imptrs[refno])
	    CT_IMIX2(imptrs[refno]) = CT_IMIX2(imptrs[refno]) + itemp
	    CT_IMOX2(imptrs[refno]) = CT_IMOX2(imptrs[refno]) + itemp
	}
	CT_IMOY1(imptrs[refno]) = CT_IMIY1(imptrs[refno]) + iyshift
	if (CT_IMOY1(imptrs[refno]) < 1) {
	    itemp = 1 - CT_IMOY1(imptrs[refno])
	    CT_IMIY1(imptrs[refno]) = CT_IMIY1(imptrs[refno]) + itemp
	    CT_IMOY1(imptrs[refno]) = CT_IMOY1(imptrs[refno]) + itemp
	}
	CT_IMOY2(imptrs[refno]) = CT_IMIY2(imptrs[refno]) + iyshift 
	if (CT_IMOY2(imptrs[refno]) > nlines) {
	    itemp = nlines - CT_IMOY2(imptrs[refno])
	    CT_IMIY2(imptrs[refno]) = CT_IMIY2(imptrs[refno]) + itemp
	    CT_IMOY2(imptrs[refno]) = CT_IMOY2(imptrs[refno]) + itemp
	}

	# Open the output image.
	outim = immap (outimage, NEW_COPY, im)
	IM_NDIM(outim) = 2

	# Set the output image size.
	IM_LEN(outim,1) = ncols
	IM_LEN(outim,2) = nlines

	# Copy the data being careful to preserve the pixel type and setting
	# undefined pixels as appropriate.
	switch (IM_PIXTYPE(im)) {

	case TY_COMPLEX:
	    do i = 1, CT_IMOY1(imptrs[refno]) - 1 {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovx (complex(blank), Memx[obuf], ncols)
	    }
	    ol1 = CT_IMIY1(imptrs[refno])
	    do i = CT_IMOY1(imptrs[refno]), CT_IMOY2(imptrs[refno]) {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovkx (complex (blank), Memx[obuf],
		    CT_IMOX1(imptrs[refno]) - 1)
		ibuf = imgs2x (im, CT_IMIX1(imptrs[refno]),
		    CT_IMIX2(imptrs[refno]), ol1, ol1)
		call amovx (Memx[ibuf], Memx[obuf+CT_IMOX1(imptrs[refno])-1],
		    CT_IMOX2(imptrs[refno]) - CT_IMOX1(imptrs[refno]) + 1)
		call amovkx (complex(blank), Memx[obuf+CT_IMOX2(imptrs[refno])],
		    ncols - CT_IMOX2(imptrs[refno]))
		ol1 = ol1 + 1
	    }
	    do i =  CT_IMOY2(imptrs[refno]) + 1, nlines {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovkx (complex(blank), Memx[obuf], ncols)
	    }

	case TY_DOUBLE:
	    do i = 1, CT_IMOY1(imptrs[refno]) - 1 {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovd (double(blank), Memd[obuf], ncols)
	    }
	    ol1 = CT_IMIY1(imptrs[refno])
	    do i = CT_IMOY1(imptrs[refno]), CT_IMOY2(imptrs[refno]) {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovkd (double(blank), Memd[obuf],
		    CT_IMOX1(imptrs[refno]) - 1)
		ibuf = imgs2d (im, CT_IMIX1(imptrs[refno]),
		    CT_IMIX2(imptrs[refno]), ol1, ol1)
		call amovd (Memd[ibuf], Memd[obuf+CT_IMOX1(imptrs[refno])-1],
		    CT_IMOX2(imptrs[refno]) - CT_IMOX1(imptrs[refno]) + 1)
		call amovkd (double(blank), Memd[obuf+CT_IMOX2(imptrs[refno])],
		    ncols - CT_IMOX2(imptrs[refno]))
		ol1 = ol1 + 1
	    }
	    do i =  CT_IMOY2(imptrs[refno]) + 1, nlines {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovkd (double(blank), Memd[obuf], ncols)
	    }

	case TY_REAL:
	    do i = 1, CT_IMOY1(imptrs[refno]) - 1 {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovr (blank, Memr[obuf], ncols)
	    }
	    ol1 = CT_IMIY1(imptrs[refno])
	    do i = CT_IMOY1(imptrs[refno]), CT_IMOY2(imptrs[refno]) {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovkr (blank, Memr[obuf], CT_IMOX1(imptrs[refno]) - 1)
		ibuf = imgs2r (im, CT_IMIX1(imptrs[refno]),
		    CT_IMIX2(imptrs[refno]), ol1, ol1)
		call amovr (Memr[ibuf], Memr[obuf+CT_IMOX1(imptrs[refno])-1],
		    CT_IMOX2(imptrs[refno]) - CT_IMOX1(imptrs[refno]) + 1)
		call amovkr (blank, Memr[obuf+CT_IMOX2(imptrs[refno])],
		    ncols - CT_IMOX2(imptrs[refno]))
		ol1 = ol1 + 1
	    }
	    do i =  CT_IMOY2(imptrs[refno]) + 1, nlines {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovkr (blank, Memr[obuf], ncols)
	    }

	default:
	    do i = 1, CT_IMOY1(imptrs[refno]) - 1 {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf], ncols)
	    }
	    ol1 = CT_IMIY1(imptrs[refno])
	    do i = CT_IMOY1(imptrs[refno]), CT_IMOY2(imptrs[refno]) {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf],
		    CT_IMOX1(imptrs[refno]) - 1)
		ibuf = imgs2l (im, CT_IMIX1(imptrs[refno]),
		    CT_IMIX2(imptrs[refno]), ol1, ol1)
		call amovl (Meml[ibuf], Meml[obuf+CT_IMOX1(imptrs[refno])-1],
		    CT_IMOX2(imptrs[refno]) - CT_IMOX1(imptrs[refno]) + 1)
		call amovkl (long(blank), Meml[obuf+CT_IMOX2(imptrs[refno])],
		    ncols - CT_IMOX2(imptrs[refno]))
		ol1 = ol1 + 1
	    }
	    do i =  CT_IMOY2(imptrs[refno]) + 1, nlines {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf], ncols)
	    }
	}

	# Compute the WCS for the output image.

	shifts[1] = real (CT_IMOX1(imptrs[refno]) - CT_IMIX1(imptrs[refno]))
	shifts[2] = real (CT_IMOY1(imptrs[refno]) - CT_IMIY1(imptrs[refno]))
	call mw_shift (mw, shifts, 03B)
	call mw_saveim (mw, outim)

	# Delete extra WCS keywords assuming for now a 2D image. Make this
	# into a header editing routine at some point ?
	iferr (call imdelf (outim, "WCSDIM"))
	    ;
	iferr (call imdelf (outim, "LTV1"))
	    ;
	iferr (call imdelf (outim, "LTV2"))
	    ;
	iferr (call imdelf (outim, "LTM1_1"))
	    ;
	iferr (call imdelf (outim, "LTM1_2"))
	    ;
	iferr (call imdelf (outim, "LTM2_1"))
	    ;
	iferr (call imdelf (outim, "LTM2_2"))
	    ;
	iferr (call imdelf (outim, "WAT0_001"))
	    ;
	iferr (call imdelf (outim, "WAT1_001"))
	    ;
	iferr (call imdelf (outim, "WAT2_001"))
	    ;

	# Add other keywords. FIELDNAM is automatically inherited but OBJECT
	# (TITLE), OBJNAME, and OBJTYPE must be modified.

	call sprintf (IM_TITLE(outim), SZ_OBJNAME, "%s %s-band")
	    call pargstr (CT_FCOBJNAME(csym))
	    call pargstr (CT_IMFILTER(imptrs[refno]))
	call imastr (outim, "OBJNAME", "junk")
	call imastr (outim, "OBJNAME", CT_FCOBJNAME(csym))
	call imastr (outim, "OBJTYPE", "cutout") 

	# Cleanup.

	call imunmap (outim)
	call mw_close (mw)
	call imunmap (im)

	return (OK)
end


# CT_COLLAGE -- Create the output image by selecting the input image with the
# largest overlap region and copying the overlap region in a section of the
# specified user region. Undefined pixels are set to blank.

int procedure ct_collage (csym, imptrs, nim, outimage, trim, blank, pixin)

pointer	csym			#I pointer to the field center structure	
pointer	imptrs[ARB]		#I the array of overlapping image symbols
int	nim			#I the number of overlapping images
char	outimage[ARB]		#I the output image name
bool	trim			#I trim the output image
real	blank			#I the undefined pixel value.
int	pixin			#I is the cutout region defined in pixels ?

double	area, x1, x2, x3, x4, y1, y2, y3, y4, xmin, xmax, ymin, ymax
real	shifts[2]
pointer	sp, imfd, ol1, im, mw, pmw, coo, ct, outim, obuf, ibuf
int	i, j, refno, ixshift, iyshift, itemp, ncols, nlines
int	oxmin, oxmax, oymin, oymax

pointer	immap(), ct_pmw(), mw_sctran(), mw_openim()
pointer	imgs2l(), imps2l(), imgs2r(), imps2r(), imps2d(), imgs2d()
pointer	imgs2x(), imps2x()
int	sk_decim(), sk_stati()
errchk	immap(), imdelf()

begin
	# Find the reference image by determining which image has the largest
	# overlap area. The overlap area is in square degrees and was
	# determined in a previous step.

	area = -MAX_REAL
	refno = 0
	do i = 1, nim {
	    if (CT_IMOAREA(imptrs[i]) < area)
		next
	    refno = i
	    area = CT_IMOAREA(imptrs[i])
	}
	if (refno <= 0)
	    return (ERR)

	# Allocate some working space.
	call smark (sp)
	call salloc (imfd, nim, TY_POINTER)
	call salloc (ol1, nim, TY_INT)

	# Open all the input images.

	do i = 1, nim {
	    iferr (Memi[imfd+i-1] = immap (CT_IMNAME(imptrs[i]), READ_ONLY,
	        0)) {
		do j = 1, nim - 1 
		    call imunmap (Memi[imfd+j-1])
		call sfree (sp)
	        return (ERR)
	    }
	}

	# Loop over the images determine the pixel coordinates of the
	# overlap regions in the input image and the pixel coordinates
	# of the cutout regions.

	do i = 1, nim {

	    # Open the input image.

	    im = Memi[imfd+i-1]

	    # Compute the overlap region in input image pixels. If pixin = yes
	    # the overlap region was already computed in a previous step,
	    # otherwise it must be computed using the image WCS.

	    if (pixin == YES) {

	        xmin = CT_IMOXIMIN(imptrs[i])
	        xmax = CT_IMOXIMAX(imptrs[i])
	        ymin = CT_IMOETAMIN(imptrs[i])
	        ymax = CT_IMOETAMAX(imptrs[i])

	        CT_IMIX1(imptrs[i]) = max (1, min (nint (xmin), IM_LEN(im,1)))
	        CT_IMIX2(imptrs[i]) = max (1, min (nint (xmax), IM_LEN(im,1)))
	        CT_IMIY1(imptrs[i]) = max (1, min (nint (ymin), IM_LEN(im,2)))
	        CT_IMIY2(imptrs[i]) = max (1, min (nint (ymax), IM_LEN(im,2)))

	        CT_IMXMIN(imptrs[i]) = nint (CT_IMXIMIN(imptrs[i]))
	        CT_IMXMAX(imptrs[i]) = nint (CT_IMXIMAX(imptrs[i]))
	        CT_IMYMIN(imptrs[i]) = nint (CT_IMETAMIN(imptrs[i]))
	        CT_IMYMAX(imptrs[i]) = nint (CT_IMETAMAX(imptrs[i]))

	    } else {

	        # Open the reference image WCS. Don't need to check this because
	        # the image is not in the database if the WCS is invalid.

	        if (sk_decim (im, "logical", mw, coo) == OK)
	            ;

	        # Compute the linear part of the transformation.

	        pmw = ct_pmw (mw)
	        ct = mw_sctran (pmw, "world", "logical", 03B)

	        # Determine the input image pixel coordinates of the corners
		# of the overlap region defined in projected coordinates.  

	        if (sk_stati (coo, S_PLNGAX) < sk_stati(coo, S_PLATAX)) {
	            call mw_c2trand (ct, CT_IMOXIMIN(imptrs[i]),
	                CT_IMOETAMIN(imptrs[i]), x1, y1)
	            call mw_c2trand (ct, CT_IMOXIMAX(imptrs[i]),
	                CT_IMOETAMIN(imptrs[i]), x2, y2)
	            call mw_c2trand (ct, CT_IMOXIMAX(imptrs[i]),
	                CT_IMOETAMAX(imptrs[i]), x3, y3)
	            call mw_c2trand (ct, CT_IMOXIMIN(imptrs[i]),
	                CT_IMOETAMAX(imptrs[i]), x4, y4)
	        } else {
	            call mw_c2trand (ct, CT_IMOETAMIN(imptrs[i]),
	                CT_IMOXIMIN(imptrs[i]), x1, y1)
	            call mw_c2trand (ct, CT_IMOETAMAX(imptrs[i]),
	                CT_IMOXIMIN(imptrs[i]), x2, y2)
	            call mw_c2trand (ct, CT_IMOETAMAX(imptrs[i]),
	                CT_IMOXIMAX(imptrs[i]), x3, y3)
	            call mw_c2trand (ct, CT_IMOETAMIN(imptrs[i]),
	                CT_IMOXIMAX(imptrs[i]), x4, y4)
	        }
	        xmin = min (x1, x2, x3, x4)
	        xmax = max (x1, x2, x3, x4)
	        ymin = min (y1, y2, y3, y4)
	        ymax = max (y1, y2, y3, y4)
	        CT_IMIX1(imptrs[i]) = max (1, min (nint (xmin), IM_LEN(im,1)))
	        CT_IMIX2(imptrs[i]) = max (1, min (nint (xmax), IM_LEN(im,1)))
	        CT_IMIY1(imptrs[i]) = max (1, min (nint (ymin), IM_LEN(im,2)))
	        CT_IMIY2(imptrs[i]) = max (1, min (nint (ymax), IM_LEN(im,2)))

	        # Determine the input image pixel coordinates of the corners of
		# the  user field which is defined in projected coordinates.
		# Do the computation in double and convert to integers at the
		# end.

	        if (sk_stati (coo, S_PLNGAX) < sk_stati(coo, S_PLATAX)) {
	            call mw_c2trand (ct, CT_IMXIMIN(imptrs[i]),
	                CT_IMETAMIN(imptrs[i]), x1, y1)
	            call mw_c2trand (ct, CT_IMXIMAX(imptrs[i]),
	                CT_IMETAMIN(imptrs[i]), x2, y2)
	            call mw_c2trand (ct, CT_IMXIMAX(imptrs[i]),
	                CT_IMETAMAX(imptrs[i]), x3, y3)
	            call mw_c2trand (ct, CT_IMXIMIN(imptrs[i]),
	                CT_IMETAMAX(imptrs[i]), x4, y4)
	        } else {
	            call mw_c2trand (ct, CT_IMETAMIN(imptrs[i]),
	                CT_IMXIMIN(imptrs[i]), x1, y1)
	            call mw_c2trand (ct, CT_IMETAMAX(imptrs[i]),
	                CT_IMXIMIN(imptrs[i]), x2, y2)
	            call mw_c2trand (ct, CT_IMETAMAX(imptrs[i]),
	                CT_IMXIMAX(imptrs[i]), x3, y3)
	            call mw_c2trand (ct, CT_IMETAMIN(imptrs[i]),
	                CT_IMXIMAX(imptrs[i]), x4, y4)
	        }
	        xmin = min (x1, x2, x3, x4)
	        xmax = max (x1, x2, x3, x4)
	        ymin = min (y1, y2, y3, y4)
	        ymax = max (y1, y2, y3, y4)
	        CT_IMXMIN(imptrs[i]) = nint (xmin)
	        CT_IMXMAX(imptrs[i]) = nint (xmax)
	        CT_IMYMIN(imptrs[i]) = nint (ymin)
	        CT_IMYMAX(imptrs[i]) = nint (ymax)

	        # Cleanup the coordinate descriptors.

	        call mw_ctfree (ct)
	        call mw_close (pmw)
	        call mw_close (mw)
	        call sk_close (coo)
	    }
	}

	# Use the reference image to determine the size of the output 
	# image.

	ncols = CT_IMXMAX(imptrs[refno]) - CT_IMXMIN(imptrs[refno]) + 1
	nlines = CT_IMYMAX(imptrs[refno]) - CT_IMYMIN(imptrs[refno]) + 1

	# Now loop through the images and compute the position of the
	# overlap region in the output image.

	oxmin = MAX_INT
	oxmax = -MAX_INT
	oymin = MAX_INT
	oymax = -MAX_INT
	do i = 1, nim {

	    # Compute the shift required to make the first output image pixel
	    # be located at pixel 1,1.

	    ixshift = 1 - CT_IMXMIN(imptrs[i])
	    iyshift = 1 - CT_IMYMIN(imptrs[i])

	    # Compute the coordinates of the overlap region in the output image.
	    # Check for out of bounds conditions and adjust the input and output
	    # overlap coordinates accordingly.

	    CT_IMOX1(imptrs[i]) = CT_IMIX1(imptrs[i]) + ixshift
	    if (CT_IMOX1(imptrs[i]) < 1) {
	        itemp = 1 - CT_IMOX1(imptrs[i])
	        CT_IMIX1(imptrs[i]) = CT_IMIX1(imptrs[i]) + itemp
	        CT_IMOX1(imptrs[i]) = CT_IMOX1(imptrs[i]) + itemp
	    }
	    CT_IMOX2(imptrs[i]) = CT_IMIX2(imptrs[i]) + ixshift 
	    if (CT_IMOX2(imptrs[i]) > ncols) {
	        itemp = ncols - CT_IMOX2(imptrs[i])
	        CT_IMIX2(imptrs[i]) = CT_IMIX2(imptrs[i]) + itemp
	        CT_IMOX2(imptrs[i]) = CT_IMOX2(imptrs[i]) + itemp
	    }
	    CT_IMOY1(imptrs[i]) = CT_IMIY1(imptrs[i]) + iyshift
	    if (CT_IMOY1(imptrs[i]) < 1) {
	        itemp = 1 - CT_IMOY1(imptrs[i])
	        CT_IMIY1(imptrs[i]) = CT_IMIY1(imptrs[i]) + itemp
	        CT_IMOY1(imptrs[i]) = CT_IMOY1(imptrs[i]) + itemp
	    }
	    CT_IMOY2(imptrs[i]) = CT_IMIY2(imptrs[i]) + iyshift 
	    if (CT_IMOY2(imptrs[i]) > nlines) {
	        itemp = nlines - CT_IMOY2(imptrs[i])
	        CT_IMIY2(imptrs[i]) = CT_IMIY2(imptrs[i]) + itemp
	        CT_IMOY2(imptrs[i]) = CT_IMOY2(imptrs[i]) + itemp
	    }

	    oxmin = min (oxmin, CT_IMOX1(imptrs[i]))
	    oxmax = max (oxmax, CT_IMOX2(imptrs[i]))
	    oymin = min (oymin, CT_IMOY1(imptrs[i]))
	    oymax = max (oymax, CT_IMOY2(imptrs[i]))
	}

	# Trim the output image.

	if (trim) {
	    ixshift = 1 - oxmin
	    iyshift = 1 - oymin
	    do i = 1, nim {
	        CT_IMOX1(imptrs[i]) = CT_IMOX1(imptrs[i]) + ixshift
	        CT_IMOX2(imptrs[i]) = CT_IMOX2(imptrs[i]) + ixshift
	        CT_IMOY1(imptrs[i]) = CT_IMOY1(imptrs[i]) + iyshift
	        CT_IMOY2(imptrs[i]) = CT_IMOY2(imptrs[i]) + iyshift
	    }
	    ncols = oxmax - oxmin + 1
	    nlines = oymax - oymin + 1
	    oxmin = 1
	    oxmax = ncols
	    oymin = 1
	    oymax = nlines
	}

	# Open the output image. This should probably be a subroutine
	# at some point.

	outim = immap (outimage, NEW_COPY, Memi[imfd+refno-1])
	IM_NDIM(outim) = 2

	# Set the output image size.
	IM_LEN(outim,1) = ncols
	IM_LEN(outim,2) = nlines

	# Create the output image.
	switch (IM_PIXTYPE(Memi[imfd+refno-1])) {

	case TY_COMPLEX:
	    do i = 1, oymin - 1 {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovkx (complex(blank), Memx[obuf], ncols)
	    }
	    do i = 1, nim
		Memi[ol1+i-1] = CT_IMIY1(imptrs[i])
	    do i = oymin, oymax {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovkx (complex(blank), Memx[obuf], ncols)
		do j = 1, nim {
		    if (i < CT_IMOY1(imptrs[j]) || i > CT_IMOY2(imptrs[j]))
			next
		    im = Memi[imfd+j-1]
		    ibuf = imgs2x (im, CT_IMIX1(imptrs[j]), CT_IMIX2(imptrs[j]),
		        Memi[ol1+j-1], Memi[ol1+j-1])
		    call amovx (Memx[ibuf], Memx[obuf+CT_IMOX1(imptrs[j])-1],
		        CT_IMOX2(imptrs[j]) - CT_IMOX1(imptrs[j]) + 1)
		    Memi[ol1+j-1] = Memi[ol1+j-1] + 1
		}
	    }
	    do i = oymax + 1, nlines {
		obuf = imps2x (outim, 1, ncols, i, i)
		call amovkx (complex(blank), Memx[obuf], ncols)
	    }

	case TY_DOUBLE:
	    do i = 1, oymin - 1 {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovkd (double(blank), Memd[obuf], ncols)
	    }
	    do i = 1, nim
		Memi[ol1+i-1] = CT_IMIY1(imptrs[i])
	    do i = oymin, oymax {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovkd (double(blank), Memd[obuf], ncols)
		do j = 1, nim {
		    if (i < CT_IMOY1(imptrs[j]) || i > CT_IMOY2(imptrs[j]))
			next
		    im = Memi[imfd+j-1]
		    ibuf = imgs2d (im, CT_IMIX1(imptrs[j]), CT_IMIX2(imptrs[j]),
		        Memi[ol1+j-1], Memi[ol1+j-1])
		    call amovd (Memd[ibuf], Memd[obuf+CT_IMOX1(imptrs[j])-1],
		        CT_IMOX2(imptrs[j]) - CT_IMOX1(imptrs[j]) + 1)
		    Memi[ol1+j-1] = Memi[ol1+j-1] + 1
		}
	    }
	    do i = oymax + 1, nlines {
		obuf = imps2d (outim, 1, ncols, i, i)
		call amovkd (double(blank), Memd[obuf], ncols)
	    }

	case TY_REAL:
	    do i = 1, oymin - 1 {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovkr (real(blank), Memr[obuf], ncols)
	    }
	    do i = 1, nim
		Memi[ol1+i-1] = CT_IMIY1(imptrs[i])
	    do i = oymin, oymax {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovkr (real(blank), Memr[obuf], ncols)
		do j = 1, nim {
		    if (i < CT_IMOY1(imptrs[j]) || i > CT_IMOY2(imptrs[j]))
			next
		    im = Memi[imfd+j-1]
		    ibuf = imgs2r (im, CT_IMIX1(imptrs[j]), CT_IMIX2(imptrs[j]),
		        Memi[ol1+j-1], Memi[ol1+j-1])
		    call amovr (Memr[ibuf], Memr[obuf+CT_IMOX1(imptrs[j])-1],
		        CT_IMOX2(imptrs[j]) - CT_IMOX1(imptrs[j]) + 1)
		    Memi[ol1+j-1] = Memi[ol1+j-1] + 1
		}
	    }
	    do i = oymax + 1, nlines {
		obuf = imps2r (outim, 1, ncols, i, i)
		call amovkr (real(blank), Memr[obuf], ncols)
	    }

	default:
	    do i = 1, oymin - 1 {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf], ncols)
	    }
	    do i = 1, nim
		Memi[ol1+i-1] = CT_IMIY1(imptrs[i])
	    do i = oymin, oymax {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf], ncols)
		do j = 1, nim {
		    if (i < CT_IMOY1(imptrs[j]) || i > CT_IMOY2(imptrs[j]))
			next
		    im = Memi[imfd+j-1]
		    ibuf = imgs2l (im, CT_IMIX1(imptrs[j]), CT_IMIX2(imptrs[j]),
		        Memi[ol1+j-1], Memi[ol1+j-1])
		    call amovl (Meml[ibuf], Meml[obuf+CT_IMOX1(imptrs[j])-1],
		        CT_IMOX2(imptrs[j]) - CT_IMOX1(imptrs[j]) + 1)
		    Memi[ol1+j-1] = Memi[ol1+j-1] + 1
		}
	    }
	    do i = oymax + 1, nlines {
		obuf = imps2l (outim, 1, ncols, i, i)
		call amovkl (long(blank), Meml[obuf], ncols)
	    }
	}

	# Create the output image WCS.
	mw = mw_openim (Memi[imfd+refno-1])
	shifts[1] = real (CT_IMOX1(imptrs[refno]) - CT_IMIX1(imptrs[refno]))
	shifts[2] = real (CT_IMOY1(imptrs[refno]) - CT_IMIY1(imptrs[refno]))
	call mw_shift (mw, shifts, 03B)
	call mw_saveim (mw, outim)
	call mw_close (mw)

	# Delete extra WCS keywords assuming for now a 2D image. Make this
	# into a header editing routine at some point ?
	iferr (call imdelf (outim, "WCSDIM"))
	    ;
	iferr (call imdelf (outim, "LTV1"))
	    ;
	iferr (call imdelf (outim, "LTV2"))
	    ;
	iferr (call imdelf (outim, "LTM1_1"))
	    ;
	iferr (call imdelf (outim, "LTM1_2"))
	    ;
	iferr (call imdelf (outim, "LTM2_1"))
	    ;
	iferr (call imdelf (outim, "LTM2_2"))
	    ;
	iferr (call imdelf (outim, "WAT0_001"))
	    ;
	iferr (call imdelf (outim, "WAT1_001"))
	    ;
	iferr (call imdelf (outim, "WAT2_001"))
	    ;

	# Add other keywords. FIELDNAM is automatically inherited but OBJECT
	# (TITLE), OBJNAME, and OBJTYPE must be modified.

	call sprintf (IM_TITLE(outim), SZ_OBJNAME, "%s %s-band")
	    call pargstr (CT_FCOBJNAME(csym))
	    call pargstr (CT_IMFILTER(imptrs[refno]))
	call imastr (outim, "OBJNAME", "junk")
	call imastr (outim, "OBJNAME", CT_FCOBJNAME(csym))
	call imastr (outim, "OBJTYPE", "cutout") 

	# Unmap the output image.
	call imunmap (outim)

	# Unmap the input images.
	do i = 1, nim
	    call imunmap (Memi[imfd+i-1])

	call sfree (sp)

	return (OK)
end



# CT_WMWCS -- Compute and record the important WCS parameters in the database
# records. These include the projection type which is always TAN at present,
# the coordinates of the reference point in degrees, and the min and max of
# the projected ra coordinates xi and projected dec coordinates eta in degrees.

procedure ct_wmwcs (im, dt, mw, coo)

pointer	im			#I the input image descriptor
pointer	dt			#I pointer to the database file
pointer	mw			#I the image wcs descriptor
pointer	coo			#I the celestial coordinate descriptor

double	x1, y1, x2, y2, x3, y3, x4, y4, ximin, ximax, etamin, etamax
double	xrot, yrot
pointer	sp, crpix, crval, cd, str, pmw, axes, ct
int	ndim, axmap, wtype, naxes, ax1, ax2
pointer	ct_pmw(), mw_sctran()
int	mw_stati(), sk_stati()

begin
	# Get the dimensionality of the WCS.

	ndim = mw_stati (mw, MW_NPHYSDIM)

	# Allocate working memory.

	call smark (sp)
	call salloc (crpix, ndim, TY_DOUBLE)
	call salloc (crval, ndim, TY_DOUBLE)
	call salloc (cd, ndim * ndim, TY_DOUBLE)
	call salloc (axes, IM_MAXDIM, TY_INT)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Get the axes mapping parameters.

	call mw_gaxlist (mw, 03B, Memi[axes], naxes)
	axmap = mw_stati(mw, MW_USEAXMAP)
	call mw_seti (mw, MW_USEAXMAP, NO)
	ax1 = Memi[axes]
	ax2 = Memi[axes+1]

	# Get the FITS term.

	call ct_gftermd (mw, Memd[crpix], Memd[crval], Memd[cd], ndim)

	# Write out the projection type.

	wtype = sk_stati (coo, S_WTYPE)
	call sk_wrdstr (wtype, Memc[str], SZ_FNAME, WTYPE_LIST)
	call dtput (dt, "    projection %s\n")
	    call pargstr (Memc[str])

	# Write out the reference coordinates in degrees. 
	if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	    call dtput (dt, "    raax %d\n")
		call pargi (ax1)
	    call dtput (dt, "    decax %d\n")
		call pargi (ax2)
	    call dtput (dt, "    raref %g\n")
	        call pargd (Memd[crval+ax1-1])
	    call dtput (dt, "    decref %g\n")
	        call pargd (Memd[crval+ax2-1])
	} else {
	    call dtput (dt, "raax %d\n")
		call pargi (ax2)
	    call dtput (dt, "decax %d\n")
		call pargi (ax1)
	    call dtput (dt, "    raref %g\n")
	        call pargd (Memd[crval+ax2-1])
	    call dtput (dt, "    decref %g\n")
	    call pargd (Memd[crval+ax1-1])
	}


	# Write out the reference coordinates in pixels.

	call dtput (dt, "    xref %g\n")
	    call pargd (Memd[crpix+ax1-1])
	call dtput (dt, "    yref %g\n")
	    call pargd (Memd[crpix+ax2-1])

	# Write out the x and y scale factors.

	call dtput (dt, "    xscale %g\n")
	    call pargd (3600.0d0 * sqrt (CD(ax1,ax1) ** 2 + CD(ax1,ax2) ** 2))
	call dtput (dt, "    yscale %g\n")
	    call pargd (3600.0d0 * sqrt (CD(ax2,ax1) ** 2 + CD(ax2,ax2) ** 2))

	# Write out the x and y rotation angles factors.

	xrot = DRADTODEG (atan2 (-CD(ax1,ax2), CD(ax1,ax1)))
	if (xrot < 0.0d0)
	    xrot = xrot + 360.0d0
	call dtput (dt, "    xrot %g\n")
	    call pargd (xrot)
	yrot = DRADTODEG (atan2 (CD(ax2,ax1), CD(ax2,ax2)))
	if (yrot < 0.0d0)
	    yrot = yrot + 360.0d0
	call dtput (dt, "    yrot %g\n")
	    call pargd (yrot)

	# Open a new coordinate system which describes the linear part
	# of the transformation.

	pmw = ct_pmw (mw)

	# Compute the minimum and maximum projected coordinates by computing
	# the projected coordinates at the 4 corners of the image.

	ct = mw_sctran (pmw, "logical", "world", 03B)
	call mw_c2trand (ct, 1.0d0, 1.0d0, x1, y1)
	call mw_c2trand (ct, double(IM_LEN(im,1)), 1.0d0, x2, y2)
	call mw_c2trand (ct, double (IM_LEN(im,1)), double (IM_LEN(im,2)),
	    x3, y3)
	call mw_c2trand (ct, 1.0d0, double(IM_LEN(im,2)), x4, y4)
	call mw_ctfree (ct)
	
	# Compute the range of the projected coordinates.

	if (sk_stati (coo, S_PLNGAX) < sk_stati (coo, S_PLATAX)) {
	    ximin = min (x1, x2, x3, x4)
	    ximax = max (x1, x2, x3, x4)
	    etamin = min (y1, y2, y3, y4)
	    etamax = max (y1, y2, y3, y4)
	} else {
	    etamin = min (x1, x2, x3, x4)
	    etamax = max (x1, x2, x3, x4)
	    ximin = min (y1, y2, y3, y4)
	    ximax = max (y1, y2, y3, y4)
	}

	call mw_close (pmw)

	# Write out the min and max projected coordinates.
	call dtput (dt, "    ximin %g\n")
	    call pargd (ximin)
	call dtput (dt, "    ximax %g\n")
	    call pargd (ximax)
	call dtput (dt, "    etamin %g\n")
	    call pargd (etamin)
	call dtput (dt, "    etamax %g\n")
	    call pargd (etamax)

	call mw_seti (mw, MW_USEAXMAP, axmap)
	call sfree (sp)
end


# CT_PMW -- Compute the linear part of the wcs.

pointer	procedure ct_pmw (mw)

pointer mw			#I the input image wcs

pointer	sp, str, axno, axval, crpix, crval, cd, pmw
int	ndim
pointer	mw_open()
int	mw_stati()
errchk	mw_newsystem()

begin
	ndim = mw_stati (mw, MW_NPHYSDIM)

	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)
	call salloc (axno, IM_MAXDIM, TY_INT)
	call salloc (axval, IM_MAXDIM, TY_INT)
	call salloc (crpix, ndim, TY_DOUBLE)
	call salloc (crval, ndim, TY_DOUBLE)
	call salloc (cd, ndim * ndim, TY_DOUBLE)

	pmw = mw_open (NULL, ndim)
        call mw_gsystem (mw, Memc[str], SZ_FNAME)
        iferr (call mw_newsystem (pmw, Memc[str], ndim))
            call mw_ssystem (pmw, Memc[str])

	call mw_gaxmap (mw, Memi[axno], Memi[axval], ndim)
	call mw_saxmap (pmw, Memi[axno], Memi[axval], ndim)

	call ct_gftermd (mw, Memd[crpix], Memd[crval], Memd[cd], ndim)
	call amovkd (0.0d0, Memd[crval], ndim)
	call mw_swtermd (pmw, Memd[crpix], Memd[crval], Memd[cd], ndim)

	call sfree (sp)

	return (pmw)
end


# CT_PROJWCS -- Set up a projection wcs given the projection type, the
# coordinates of the reference point, and the reference point units.

pointer procedure ct_projwcs (projection, reflng, reflat, lngunits, latunits)

char    projection[ARB]         #I the projection type
double  reflng                  #I the ra / longitude reference point
double  reflat                  #I the dec / latitude reference point
int     lngunits                #I the ra / longitude units
int     latunits                #I the dec / latitude units

pointer	mw, sp, axes, projstr, projpars, wpars, ltv, ltm, r, w, cd
int     ndim

pointer mw_open()

begin
        ndim = 2

        # Allocate working space.
        call smark (sp)
        call salloc (axes, IM_MAXDIM, TY_INT)
        call salloc (projstr, SZ_FNAME, TY_CHAR)
        call salloc (projpars, SZ_LINE, TY_CHAR)
        call salloc (wpars, SZ_LINE, TY_CHAR)
        call salloc (ltm, ndim * ndim, TY_DOUBLE)
        call salloc (ltv, ndim, TY_DOUBLE)
        call salloc (cd, ndim * ndim, TY_DOUBLE)
        call salloc (r, ndim, TY_DOUBLE)
        call salloc (w, ndim, TY_DOUBLE)

        # Open the wcs.
        mw = mw_open (NULL, ndim)

        # Set the axes and projection type.
        Memi[axes] = 1
        Memi[axes+1] = 2
        if (projection[1] == EOS)
            call mw_swtype (mw, Memi[axes], ndim, "linear", "")
        else {
            call sscan (projection)
                call gargwrd (Memc[projstr], SZ_FNAME)
                call gargstr (Memc[projpars], SZ_LINE)
            call sprintf (Memc[wpars], SZ_LINE,
                "axis 1: axtype = ra %s axis 2: axtype = dec %s")
                call pargstr (Memc[projpars])
                call pargstr (Memc[projpars])
            call mw_swtype (mw, Memi[axes], ndim, Memc[projstr], Memc[wpars])
        }

        # Set the lterm.
        call mw_mkidmd (Memd[ltm], ndim)
        call aclrd (Memd[ltv], ndim)
        call mw_sltermd (mw, Memd[ltm], Memd[ltv], ndim)

        # Set the wterm.
        call mw_mkidmd (Memd[cd], ndim)
        call aclrd (Memd[r], ndim)
        switch (lngunits) {
        case SKY_DEGREES:
            Memd[w] = reflng
        case SKY_RADIANS:
            Memd[w] = DRADTODEG(reflng)
        case SKY_HOURS:
            Memd[w] = 15.0d0 * reflng
        default:
            Memd[w] = reflng
        }
        switch (latunits) {
        case SKY_DEGREES:
            Memd[w+1] = reflat
        case SKY_RADIANS:
            Memd[w+1] = DRADTODEG(reflat)
        case SKY_HOURS:
            Memd[w+1] = 15.0d0 * reflat
        default:
            Memd[w+1] = reflat
        }
        call mw_swtermd (mw, Memd[r], Memd[w], Memd[cd], ndim)

        call sfree (sp)

        return (mw)
end



# CT_MKWCS -- Compute the image wcs from the user parameters.

pointer procedure ct_mkwcs (projection, lngref, latref, xref, yref, xscale,
	yscale, xrot, yrot, raax, decax)

char    projection[ARB]         #I the sky projection geometry
double  lngref, latref          #I the reference point in degrees
double  xref, yref              #I the reference point in pixels
double  xscale, yscale          #I the x and y scale in arcsec / pixel
double  xrot, yrot              #I the x and y axis rotation angles in degrees
int	raax, decax		#I the ra and dec axes

pointer sp, r, w, cd, axes
pointer mw, projstr, projpars, wpars
int     ndim, ax1, ax2

pointer mw_open()

begin
        ndim = 2

        # Allocate working memory for the vectors and matrices.
        call smark (sp)
        call salloc (projstr, SZ_FNAME, TY_CHAR)
        call salloc (projpars, SZ_LINE, TY_CHAR)
        call salloc (wpars, SZ_LINE, TY_CHAR)
        call salloc (axes, IM_MAXDIM, TY_INT)
        call salloc (w, ndim, TY_DOUBLE)
        call salloc (r, ndim, TY_DOUBLE)
        call salloc (cd, ndim * ndim, TY_DOUBLE)

        # Open the new wcs
        mw = mw_open (NULL, ndim)
        call mw_newsystem (mw, "image", ndim)

        # Set the axes and projection type.
	ax1 = 1
	ax2 = 2
	Memi[axes] = 1
	Memi[axes+1] = 2
        if (projection[1] == EOS) {
            call mw_swtype (mw, Memi[axes], ndim, "linear", "")
        } else {
            call sscan (projection)
                call gargwrd (Memc[projstr], SZ_FNAME)
                call gargstr (Memc[projpars], SZ_LINE)
	    if (raax < decax) {
                call sprintf (Memc[wpars], SZ_LINE,
                    "axis 1: axtype = ra %s axis 2: axtype = dec %s")
                    call pargstr (Memc[projpars])
                    call pargstr (Memc[projpars])
	    } else {
                call sprintf (Memc[wpars], SZ_LINE,
                    "axis 1: axtype = dec %s axis 2: axtype = ra %s")
                    call pargstr (Memc[projpars])
                    call pargstr (Memc[projpars])
	    }
            call mw_swtype (mw, Memi[axes], ndim, Memc[projstr], Memc[wpars])
        }

	# Set the reference point in degrees
	if (raax < decax) {
            Memd[w+ax1-1] = lngref
            Memd[w+ax2-1] = latref
	} else {
            Memd[w+ax2-1] = lngref
            Memd[w+ax1-1] = latref
	}

        # Set the reference point pixel coordinates.
        Memd[r+ax1-1] = xref
        Memd[r+ax2-1] = yref

        # Compute the new CD matrix.
        CD(ax1,ax1) = xscale * cos (DEGTORAD(xrot)) / 3600.0d0
        CD(ax2,ax1) = -yscale * sin (DEGTORAD(yrot)) / 3600.0d0
        CD(ax1,ax2) = xscale * sin (DEGTORAD(xrot)) / 3600.0d0
        CD(ax2,ax2) = yscale * cos (DEGTORAD(yrot)) / 3600.0d0

        # Store the new Wterm.
        call mw_swtermd (mw, Memd[r], Memd[w], Memd[cd], ndim)

        call sfree (sp)

	return (mw)
end


# CT_OBJNAME -- Create an IAU style name from the field center parameters.

procedure ct_objname (class, ra, dec, system, objname, maxch)

char	class[ARB]		#I the input class string.
double	ra			#I the right ascension in degrees
double	dec			#I the declination in degrees
char	system[ARB]		#I the equatorial system
char	objname[ARB]		#O the output object name
int	maxch			#I maximum size of the object name

pointer	sp, str
int	i, op, slen
int	gstrcpy (), strlen()
bool	streq()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Copy in the class name.
	op = 1
	op = op + gstrcpy (class, objname[op], maxch)

	# Add a blank.
	op = op + gstrcpy (" ", objname[op], maxch - op + 1)

	# Add the coordinate type letter. The system options are B1950,
	# J2000, and ICRS.
	if (streq (system, "B1950")) {
	    op = op + gstrcpy ("B", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("J", objname[op], maxch - op + 1)
	}

	# Encode the RA string. Remove the ':' delimiters and chop off
	# the last digit of precision to conform to IAU standards ,i.e.
	# truncation not rounding.
	call sprintf (Memc[str], SZ_FNAME, "%012.3H")
	    call pargd (ra)
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	# Encode the dec sign.
	if (dec >= 0.0d0) {
	    op = op + gstrcpy ("+", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("-", objname[op], maxch - op + 1)
	}

	# Encode the DEC string. Remove the ':' delimiters and chop off
	# the last digit of precision to conform to IAU standards ,i.e.
	# truncation not rounding.
	call sprintf (Memc[str], SZ_FNAME, "%011.2h")
	    call pargd (abs(dec))
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	call sfree (sp)
end


# CT_MKFNAME -- Create a default output name.

procedure ct_mkfname (csym, imroot, filter, output, maxch)

pointer	csym				#I pointer to the field center
char	imroot[ARB]			#I the root output image name
char	filter[ARB]			#I the filter name
char	output[ARB]			#O the output file name
int	maxch				#I the maximum number of characters

pointer	sp, str
int	fnldir()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	if (fnldir (imroot, output, maxch) <= 0)
	    output[1] = EOS
	call ct_fname (imroot, CT_FCRA(csym), CT_FCDEC(csym), CT_FCSYSTEM(csym),
	    filter, Memc[str], SZ_FNAME)
	call ct_oimname (Memc[str], output, "", output, maxch)

	call sfree (sp)
end


# CT_FNAME -- Create an pseudo IAU style image root name from the field
# center parameters.

procedure ct_fname (class, ra, dec, system, filter, objname, maxch)

char	class[ARB]		#I the input class string.
double	ra			#I the right ascension in degrees
double	dec			#I the declination in degrees
char	system[ARB]		#I the equatorial system
char	filter[ARB]		#I the filter name
char	objname[ARB]		#O the output object name
int	maxch			#I maximum size of the object name

pointer	sp, str
int	i, op, slen
int	gstrcpy (), strlen()
bool	streq()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Copy in the class name.
	op = 1
	op = op + gstrcpy (class, objname[op], maxch)

	# Add an underscore.
	op = op + gstrcpy ("_", objname[op], maxch - op + 1)

	# Add the coordinate type letter. The system options are B1950,
	# J2000, and ICRS.
	if (streq (system, "B1950")) {
	    op = op + gstrcpy ("B", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("J", objname[op], maxch - op + 1)
	}

	# Encode the RA string. Remove the ':' delimiters and the period
	# and chop off the last digit of precision.
	call sprintf (Memc[str], SZ_FNAME, "%011.2H")
	    call pargd (ra)
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':' || Memc[str+i-1] == '.')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	# Encode the dec sign as a p or n.
	if (dec >= 0.0d0) {
	    op = op + gstrcpy ("p", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("n", objname[op], maxch - op + 1)
	}

	# Encode the DEC string. Remove the ':' delimiters and the period
	# the last digit of precision.
	call sprintf (Memc[str], SZ_FNAME, "%010.1h")
	    call pargd (abs(dec))
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':' || Memc[str+i-1] == '.')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	# Add the filter name.
	op = op + gstrcpy ("_", objname[op], maxch - op + 1)
	op = op + gstrcpy (filter, objname[op], maxch - op + 1)

	call sfree (sp)
end
