procedure dssfinder (image)

string	image              {prompt="DSS image name"}
string  rootname     = ""  {prompt="Alternate root name for output files"}
string	objects      = ""  {prompt="List of program object X,Y coords\n"}

bool	update       = no  {prompt="Update image header WCS following fit?"}
bool	interactive  = yes {prompt="Enter interactive image cursor loop?"}
bool	autocenter   = no  {prompt="Center at the catalog coords when entering task?"}
bool	reselect     = yes {prompt="Apply selectpars when entering task?"}
bool	autodisplay  = yes {prompt="Redisplay after all-source keystroke command?\n"}

real	scale        = 1.7 {prompt="Image scale in arcsec/pixel"}
real	rotate       = 0.  {prompt="Relative position angle (CCW positive)"}
int	boxsize      = 9   {prompt="Centering box full width",min=1}

begin
	string	north = "top"
	string	east = "left"
	string	date_obs = ""
	real	edge = 200.
	real	equinox = 2000.
	real	xref = INDEF
	real	yref = INDEF
	bool	opaxis = no

	real	pi = 3.14159265358979
	bool	firsttime = yes
	bool	newobjects = yes
	bool	rawtable = no

	string	table, database, logfile, cdecsign
	real	ra, dec, rah, ram, ras, decd, decm, decs
	real	cra, cdec, crah, cram, cras, cdecd, cdecm, cdecs
	real	del_ra, del_dec

	string	ra_ref, dec_ref
	real	eq_ref

	real	lscale

	string	limage, tmp1, tmp2, tmpraw, lobjects, lroot
	bool	lautocenter, lautodisplay, lreselect
	real	naxis1, naxis2, width

	real	ut, epoch
	int	year, dd, mm, yy, daynum, leapday
	bool	leapyear

	cache ("tinfo", "tvmark_", "imgets", "keypar")

	tmp1 = mktemp ("tmp$tmp1")
	tmp2 = mktemp ("tmp$tmp2")
	tmpraw = mktemp ("tmp$tmpraw") // ".tab"

	limage = image
	if (! (access (limage) || access (limage // ".imh")))
	    error (1, "image not found")

        lroot = rootname
	if (stridx (" ", lroot) != 0)
	    error (1, "no whitespace allowed in rootname parameter")
	if (lroot == "")
	    lroot = limage

	table = lroot // ".tab"
	database = lroot // ".db"
	logfile = lroot // ".log"

	lobjects = objects
	if (stridx (" ", lobjects) != 0)
	    error (1, "no whitespace allowed in objects parameter")
	if (lobjects != "" && ! access (lobjects))
	    error (1, "object file not found")

	lautocenter = autocenter
	lautodisplay = autodisplay
	lreselect = reselect

	lscale = scale

	imgets (limage, "naxis1", >& "dev$null"); naxis1 = int (imgets.value)
	imgets (limage, "naxis2", >& "dev$null"); naxis2 = int (imgets.value)

	if (naxis1 <= 0 || naxis2 <= 0)
	    error (1, "Problem reading image size from header")

	# support Quick V headers that have EPOCH, but not DATE-OBS
	imgets (limage, "date-obs", >& "dev$null")
	if (imgets.value == "0" || strlen(imgets.value) < 8) {
	    printf ("No DATE-OBS in header, trying EPOCH\n")

	    imgets (limage, "epoch", >& "dev$null"); epoch = real (imgets.value)
	    if (epoch <= 0.0)
		error (1, "No EPOCH in header")

	    year = epoch
	    leapyear =(mod(year,4)==0 && (mod(year,100)!=0 || mod(year,400)==0))

	    daynum = (epoch - year) * 365.25
	    daynum = max (daynum, 0)

	    # add a day back if we lost one to integer truncation
	    ut = ((epoch - year) * 365.25 - daynum) * 24.0
	    ut = int (ut * 360000.0 + 0.5) / 360000.0
	    if (ut >= 24.0)
		daynum += 1

	    # day of year is one-indexed
	    daynum += 1

	    leapday = 0
	    if (leapyear && daynum > 59)
		leapday = 1

	    if (daynum > 365+leapday) {
		mm = 12; dd = 31
	    } else if (daynum > 334+leapday) {
		mm = 12; dd = daynum - (334+leapday)
	    } else if (daynum > 304+leapday) {
		mm = 11; dd = daynum - (304+leapday)
	    } else if (daynum > 273+leapday) {
		mm = 10; dd = daynum - (273+leapday)
	    } else if (daynum > 243+leapday) {
		mm = 9; dd = daynum - (243+leapday)
	    } else if (daynum > 212+leapday) {
		mm = 8; dd = daynum - (212+leapday)
	    } else if (daynum > 181+leapday) {
		mm = 7; dd = daynum - (181+leapday)
	    } else if (daynum > 151+leapday) {
		mm = 6; dd = daynum - (151+leapday)
	    } else if (daynum > 120+leapday) {
		mm = 5; dd = daynum - (120+leapday)
	    } else if (daynum > 90+leapday) {
		mm = 4; dd = daynum - (90+leapday)
	    } else if (daynum > 59+leapday) {
		mm = 3; dd = daynum - (59+leapday)
	    } else if (daynum > 31) {
		mm = 2; dd = daynum - 31
	    } else if (daynum > 0) {
		mm = 1; dd = daynum
	    } else {
		mm = 1; dd = 1
	    }

#	    yy = mod (year, 100)
#	    printf ("%02d/%02d/%02d\n", dd, mm, yy) | scan (date_obs)

	    printf ("%4d-%02d-%02d\n", year, mm, dd) | scan (date_obs)

	    printf ("using DATE-OBS=%s from EPOCH=%f\n", date_obs, epoch)
	}

# would have to invert the phenomenological solution to retrieve correctly
#	imgets (limage, "amdx1", >& "dev$null"); amdx1 = real (imgets.value)
#	imgets (limage, "amdx2", >& "dev$null"); amdx2 = real (imgets.value)
#	imgets (limage, "amdy1", >& "dev$null"); amdy1 = real (imgets.value)
#	imgets (limage, "amdy2", >& "dev$null"); amdy2 = real (imgets.value)
#	# average the two sine terms from the rotation matrix using the
#	# small angle approximation for sine, and letting cos(rotate) ~ 1
#	rotate = -90. * ((amdx2/amdy1) - (amdy2/amdx1)) / pi
#	rotate = 90. * ((amdx2/amdy1) - (amdy2/amdx1)) / pi
#printf ("rotate = %.4f degrees\n", rotate)

	imgets (limage, "objctra", >& "dev$null")
	print (imgets.value) | scan (rah, ram, ras)
	ra = rah + (ram + ras/60.) / 60.

	imgets (limage, "objctdec", >& "dev$null")
	print (imgets.value) | scan (decd, decm, decs)
	dec = abs(decd) + (decm + decs/60.) / 60.
	if (decd < 0)
	    dec = -dec

	hselect (limage, "pltrah,pltram,pltras", yes) |
	    scan (crah, cram, cras)
	cra = crah + (cram + cras/60.) / 60.

	hselect (limage, "pltdecd,pltdecm,pltdecs", yes) |
	    scan (cdecd, cdecm, cdecs)
	hselect (limage, "pltdecsn", yes) | scan (cdecsign)
	cdec = cdecd + (cdecm + cdecs/60.) / 60.
	if (cdecsign == "-")
	    cdec = -cdec

	ra_ref = cra
	dec_ref = cdec
	eq_ref = equinox

	del_ra = 15. * (ra - cra) * cos (dec*pi/180.)
	del_dec = dec - cdec

	width = lscale * (max (naxis1, naxis2) + edge) / 3600.

	if (access (table) || access (table // ".tab")) {
	    printf ("Catalog table %s exists, ", table)
	    if (_qpars.overwrite) {
		tdelete (table, ver-, >& "dev$null")

	    } else {
		keypar (table, "REGION", silent+)
		tinfo (table, ttout-)
		rawtable = (keypar.found || tinfo.ncols < 19)

		if (lautocenter)
		    lautocenter = _qpars.recenter

		firsttime = no
	    }
	}

        if (access (logfile)) {
            printf ("Log file %s exists, ", logfile)
	    if (_qpars.overwrite)
                delete (logfile, ver-, >& "dev$null")
        }

        if (logfile != "" && ! access (logfile))
            printf ("", > logfile)

	if (firsttime) {
	    if (interactive)
		print ("\nSearching the Guide Star Catalog index...")

	    gscfind (ra, dec, equinox, width, > tmp1)

	    if (interactive) {
		print ("\nReading the Guide Star Catalog regions:")
		type (tmp1)
	    }

	    cdrfits ("@" // tmp1, "1", "aka", template="", long_header=no,
		short_header=no, datatype="", blank=0., scale=yes, xdimtogf=no,
		oldirafname=yes, offset=0, > tmp2)

	    delete (tmp1, ver-, >& "dev$null")

	    if (interactive) {
		print ("\nExtracting overlapping sources from regions:")
		type (tmp2)
	    }

	    tfield ("@" // tmp2, table, image=limage, catpars="", ra=ra,
		dec=dec, equinox=equinox, date_obs=date_obs, width=width,
		xref=xref, yref=yref, opaxis=opaxis, del_ra=del_ra,
		del_dec=del_dec, north=north, east=east, rotate=rotate,
		scale=lscale, edge=edge)

	    tdelete ("@" // tmp2, ver-, >& "dev$null")
	    delete (tmp2, ver-, >& "dev$null")

	} else if (rawtable) {
	    printf ("\nCatalog table %s appears to be in raw GSC format,\n",
		table)
	    printf ("  running TFIELD to generate predicted X/Y coords\n\n")

#	    trename (table, tmpraw, verbose-)
	    rename (table, tmpraw, field="all")

	    tfield (tmpraw, table, image=limage, catpars="", ra=ra,
		dec=dec, equinox=equinox, date_obs=date_obs, width=width,
		xref=xref, yref=yref, opaxis=opaxis, del_ra=del_ra,
		del_dec=del_dec, north=north, east=east, rotate=rotate,
		scale=lscale, edge=edge)
	}

	tinfo (table, ttout-)
	if (tinfo.nrows <= 0) {
	    beep
	    print ("\nNo Guide Stars selected for this field!")
	    print ("Check the input parameters and images...")
	    return
	}

	if (firsttime)
	    tsort (table, "plate_id,region,gsc_id", ascend+, casesens+)

	# Provide reasonable defaults for the mark sizes, the extra
	# contour is for bolding (mostly for subsampling in saoimage).
	# This can be overridden within TPEAK by `:eparam tvmark_'.
	tvmark_.radii = (boxsize/2) // "," // (boxsize/2 + 1)
	tvmark_.lengths = (boxsize - 1) // "," // (boxsize + 1)

	if (interactive) {
	    printf ("\nInteractive centering using TPEAK:\n")
	    printf ( "  The size of the markers matches the centering box ")
		printf ("(%d pixels).\n", boxsize)
	    printf ("  Change the size with the command `:eparam tvmark'.\n")
	}

	if (! firsttime) {
	    if (lobjects != "") {
		printf ("\nRead/reread objects '%s' into table '%s' ",
		    lobjects, table)
		newobjects = _qpars.go_ahead
		if (! newobjects)
		    lobjects = ""
	    }

	    if (lreselect) {
		printf ("\nSelect a new catalog subset ")
		lreselect = _qpars.go_ahead
	    }
	}

	tpeak (limage, table, database=database, objects=lobjects,
	    ra_ref=ra_ref, dec_ref=dec_ref, eq_ref=eq_ref,
	    update=update, interactive=interactive, autocenter=lautocenter,
	    reselect=lreselect, autodisplay=lautodisplay, boxsize=boxsize,
	    rotate=0., xscale=100., yscale=100., xshift=0, yshift=0, imcur="")

	if (logfile != "")
	    finderlog (table, logfile, append+)

	if (rawtable) {
	    printf ("Overwrite original input table, %s, with changes ", table)
	    if (_qpars.go_ahead) {
		tdelete (tmpraw, ver-, >& "dev$null")
	    } else {
		tdelete (table, ver-, >& "dev$null")
#		trename (tmpraw, table, verbose-)
		rename (tmpraw, table, field="all")
	    }
	}
end
