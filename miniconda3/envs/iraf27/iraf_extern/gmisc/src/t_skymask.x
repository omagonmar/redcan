include <imhdr.h>
include <pmset.h>

define	GEO_POINT	1
define	GEO_CIRCLE	2
define	GEO_RECTANGLE	3

# T_SKYMASK -- Task for creating starmasks from an input star list where
# each star consists of an input x and y coordinate and an optional radius.

procedure t_skymask()

real	x1, y1, x2, y2
pointer	sp, fixfile, refimage, maskimage, im, msk, str
int	ip, flist, ilist, mlist, ncols, nlines, fd, defshape, defradius
int	defwidth, defheight, badval, goodval, verbose
int	axes[PL_MAXDIM], nstars, naxes, depth, shape, ix1, iy1, ix2, iy2, ir
char	period
pointer	immap(), pm_newmask(), pm_create()
int	clpopnu(), clplen(), clgwrd(), imtopenp(), imtlen(), clgfil(), clgeti()
int	imtgetim(), strldx(), strmatch(), open(), fscan(), nscan(), btoi()
bool	clgetb()
data    period /'.'/

begin
	# Open the fix file list.
	flist = clpopnu ("fixfiles")
	if (clplen (flist) <= 0) {
	    call clpcls (flist)
	    call eprintf ("The input fix file list is empty\n")
	    return
	}

	# Open the reference image list. The number of reference images
	# must be 0, 1, or equal to the number of input star lists.
	ilist = imtopenp ("refimages")
	if (imtlen (ilist) > 1 && imtlen (ilist) != clplen (flist)) {
	    call imtclose (ilist)
	    call clpcls (flist)
	    call eprintf ("The reference image list has too few images\n")
	    return
	}

	# Open the maks image list. The number of mask images must be 0, or
	# equal to the number of input star lists.
	mlist = imtopenp ("masks")
	if (imtlen (mlist) > 0 && imtlen (mlist) != clplen (flist)) {
	    call imtclose (mlist)
	    call imtclose (ilist)
	    call clpcls (flist)
	    call eprintf ("The mask image list has too few images\n")
	    return
	}

	call smark (sp)
	call salloc (fixfile, SZ_FNAME, TY_CHAR)
	call salloc (refimage, SZ_FNAME, TY_CHAR)
	call salloc (maskimage, SZ_FNAME, TY_CHAR)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Get the rest of the parameters.
	defshape = clgwrd ("defshape", Memc[str], SZ_FNAME,
	    "|point|circle|rectangle")
	defradius = clgeti ("defradius")
	defwidth = clgeti ("defwidth")
	defheight = clgeti ("defheight")
	ncols = clgeti ("ncols")
	nlines = clgeti ("nlines")
	badval = clgeti ("badvalue")
	goodval = clgeti ("goodvalue")
	verbose = btoi(clgetb("verbose"))

	# Loop over the input star files.
	im = NULL
	while (clgfil (flist, Memc[fixfile], SZ_FNAME) != EOF) {

	    # Open the star file.
	    fd = open (Memc[fixfile], READ_ONLY, TEXT_FILE)

	    # Open the reference image and get the reference image name.
	    if (imtlen (ilist) > 0) {
	        if (imtgetim (ilist, Memc[refimage], SZ_FNAME) != EOF) {
		     if (im != NULL)
		        call imunmap (im)
		    im = immap (Memc[refimage], READ_ONLY, 0)
		    ip = strldx (period, IM_HDRFILE(im))
		    if (ip > 0)
		        call strcpy (IM_HDRFILE(im), Memc[refimage], ip - 1)
		} else
		    Memc[refimage] = EOS
	    } else {
		Memc[refimage] = EOS
		im = NULL
	    }

	    # Get the output pixel mask name.
	    if (imtlen (mlist) > 0) {
	        if (imtgetim (mlist, Memc[maskimage], SZ_FNAME) != EOF)
		    ;
	        if (strmatch (Memc[maskimage], ".pl$") == 0)
	            call strcat (".pl", Memc[maskimage], SZ_FNAME)
	    } else if (Memc[refimage] != EOS) {
		call strcpy (Memc[refimage], Memc[maskimage], SZ_FNAME)
	        if (strmatch (Memc[maskimage], ".pl$") == 0)
	            call strcat (".pl", Memc[maskimage], SZ_FNAME)
	    } else {
		call strcpy (Memc[fixfile], Memc[maskimage], SZ_FNAME)
	        call strcat (".pl", Memc[maskimage], SZ_FNAME)
	    }


	    # Open the output image mask using the image template to
	    # determine the size of the mask if one is defined and it
	    # is 2D.
	    if (im != NULL) {
		if (IM_NDIM(im) != 2) {
		    axes[1] = ncols
		    axes[2] = nlines
		    msk = pm_create (2, axes, 1)
		} else {
		    msk = pm_newmask (im, 1)
		    call pm_gsize (msk, naxes, axes, depth)
		}
	    } else {
		axes[1] = ncols
		axes[2] = nlines
		msk = pm_create (2, axes, 1)
	    }

	    if (verbose == YES) {
		call printf ("Creating %d x %d sky mask %s\n")
		    call pargi (axes[1])
		    call pargi (axes[2])
		    call pargstr (Memc[maskimage])
		if (Memc[refimage] == EOS) {
		    call printf ("    Using fixfile %s\n")
		        call pargstr (Memc[fixfile])
		} else {
		    call printf ("    Using fixfile %s and image template\n")
		        call pargstr (Memc[fixfile])
		        call pargstr (Memc[refimage])
		}
		call flush (STDOUT)
	    }

	    # Initialize the mask if the background value is not 0
	    if (goodval > 0)
		call pm_box (msk, 1, 1, axes[1], axes[2], PIX_SET +
		    PIX_VALUE(goodval)) 

	    # Scan the coordinate lists.
	    nstars = 0
	    while (fscan (fd) != EOF) {

		# Check for x and y coordinates.
		call gargr (x1)
		call gargr (y1)
		call gargr (x2)
		call gargr (y2)
		if (nscan () < 2)
		    next

		# Determine the geometry.
		switch (nscan()) {
		case 2:
		    shape = defshape
		    switch (shape) {
		    case GEO_POINT:
		        ix1 = nint (x1)
		        iy1 = nint (y1)
		    case GEO_CIRCLE:
		        ix1 = nint (x1)
		        iy1 = nint (y1)
			ir = defradius
		    case GEO_RECTANGLE:
			ix1 = nint (x1 - defwidth / 2.0)
			ix2 = nint (x1 + defwidth / 2.0)
			iy1 = nint (y1 - defheight / 2.0)
			iy2 = nint (y1 + defheight / 2.0)
		    }
		case 3:
		    shape = GEO_CIRCLE
		    ix1 = nint (x1)
		    iy1 = nint (y1)
		    ir = nint (x2)
		case 4:
		    shape = GEO_RECTANGLE
		    ix1 = nint (min (x1, x2))
		    iy1 = nint (min (y1, y2))
		    ix2 = nint (max (x1, x2))
		    iy2 = nint (max (y1, y2))
		}

		# Update the mask.
		switch (shape) {
		case GEO_POINT:
		    if (ix1 < 1 || ix1 > axes[1])
		        next
		    if (iy1 < 1 || iy1 > axes[2])
		        next
		    call pm_point (msk, ix1, iy1, PIX_SET + PIX_VALUE(badval))
		case GEO_CIRCLE:
		    if ((ix1 + ir) < 1 || (ix1 - ir) > axes[1])
		        next
		    if ((iy1 + ir) < 1 || (iy1 - ir) > axes[2])
		        next
		    call pm_circle (msk, ix1, iy1, ir, PIX_SET +
		        PIX_VALUE(badval))
		case GEO_RECTANGLE:
		    if (ix2 < 1 || ix1 > axes[1])
		        next
		    if (iy2 < 1 || iy1 > axes[2])
		        next
		    call pm_box (msk, ix1, iy1, ix2, iy2, PIX_SET +
		        PIX_VALUE(badval))
		}

		# Count the stars.
		nstars = nstars + 1

	    }

	    # Save the mask in a file.
	    call pm_savef (msk, Memc[maskimage], Memc[maskimage], 0)

	    call pm_close (msk)
	    call close (fd)

	}

	if (im != NULL)
	    call imunmap (im)

	# Cleanup
	call sfree (sp)
	call imtclose (mlist)
	call imtclose (ilist)
	call clpcls (flist)
end
