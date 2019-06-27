procedure tfinder (image)

string	image                {prompt="Image name"}
string	rootname     = ""    {prompt="Alternate root name for output files"}
string	objects      = ""    {prompt="List of program object X,Y coords\n"}

real	scale                {prompt="Plate or image scale (\"/pixel)"}
string	north       = "top"  {prompt="Direction of North in the field",
			       enum="top|left|bottom|right"}
string	east        = "left" {prompt="Direction of East in the field\n",
			       enum="top|left|bottom|right"}

real	ra           = INDEF {prompt="RA  of the reference point (hours)",
				min=0., max=24.}
real	dec          = INDEF {prompt="Dec of the reference point (degrees)",
				min=-90., max=90.}
real	equinox      = INDEF {prompt="Reference coordinate equinox\n"}

real	xref         = INDEF {prompt="X coordinate of the reference point"}
real	yref         = INDEF {prompt="Y coordinate of the reference point"}
string	date_obs     = ""    {prompt="Date of the observation (YYYY-MM-DD)\n"}

bool	update       = no    {prompt="Update image header WCS following fit?"}
bool	interactive  = yes   {prompt="Enter interactive image cursor loop?"}
bool	autocenter   = no    {prompt="Center at the catalog coords when entering task?"}
bool	reselect     = yes   {prompt="Apply selectpars when entering task?"}
bool	autodisplay  = yes   {prompt="Redisplay after all-source keystroke command?"}
bool	verbose      = yes   {prompt="Print a running commentary?\n"}

real	rotate       = 0.    {prompt="Relative position angle (CCW positive)"}
int	boxsize      = 9     {prompt="Centering box full width",min=1}
real	edge         = 200.  {prompt="Edge buffer width (pixels)\n"}

bool	opaxis  = no {prompt="Is the reference point on the optical axis?"}
real	del_ra  = 0. {prompt="RA offset of the field center (degrees)"}
real	del_dec = 0. {prompt="Dec offset of the field center (degrees)\n"}

string	*list

begin
	real	pi = 3.14159265358979
	bool	firsttime = yes
	bool	newobjects = yes
	bool	rawtable = no
	bool	noidate_obs = no

	string	table, database, logfile, idate_obs

	string	ra_ref, dec_ref
	real	eq_ref

	string	limage, tmp1, tmp2, tmpraw, lobjects, lroot
	bool	lautocenter, lautodisplay, lreselect
	real	naxis1, naxis2, width, ira, idec, iequinox, lscale

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

	lscale = scale

	lautocenter = autocenter
	lautodisplay = autodisplay
	lreselect = reselect

        imgets (limage, "naxis1", >& "dev$null"); naxis1 = int (imgets.value)
        imgets (limage, "naxis2", >& "dev$null"); naxis2 = int (imgets.value)

        if (naxis1 <= 0 || naxis2 <= 0)
            error (1, "Problem reading image size from header")

	imgets (limage, "date-obs", >& "dev$null"); idate_obs = imgets.value
	if (idate_obs == "0" || strlen(idate_obs) < 8) {
	    printf ("Warning: no DATE-OBS in %s image header\n", limage)
	    noidate_obs = yes
	}

	if (noidate_obs && (date_obs == "" || strlen (date_obs) < 8))
	    error (1, "The date_obs parameter is not readable.")

	if (ra == INDEF) {
	    imgets (limage, "ra", >& "dev$null")
	    if (imgets.value == "0")
		error (1, "No RA in image header or parameter file.")
	    ira = real (imgets.value)
	} else
	    ira = ra

	if (dec == INDEF) {
	    imgets (limage, "dec", >& "dev$null")
	    if (imgets.value == "0")
		error (1, "No declination in image header or parameter file.")
	    idec = real (imgets.value)
	} else
	    idec = dec

	if (equinox == INDEF) {
	    imgets (limage, "equinox", >& "dev$null")
	    iequinox = real (imgets.value)
	    if (imgets.value == "0") {
		imgets (limage, "epoch", >& "dev$null")
		iequinox = real (imgets.value)
		if (imgets.value == "0")
		    error (1, "No equinox in image header or parameter file.")
	    }
	} else
	    iequinox = equinox

	ra_ref = ira
	dec_ref = idec
	eq_ref = iequinox

	width = lscale * (max (naxis1, naxis2) + edge) / 3600.

#printf ("[%d,%d]\n", naxis1, naxis2)
#printf ("%h  %h  %f\n", ira, idec, iequinox)
#printf ("width=%f\n", width)
#printf ("%s / %s\n", date_obs, idate_obs)

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

	    gscfind (ira, idec, iequinox, width, > tmp1)

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

	    tfield ("@" // tmp2, table, image=limage, catpars="", ra=ira,
		dec=idec, equinox=iequinox, date_obs=date_obs, width=width,
		xref=xref, yref=yref, opaxis=opaxis, del_ra=del_ra,
		del_dec=del_dec, north=north, east=east, rotate=rotate,
		scale=lscale, edge=edge)

	    tdelete ("@" // tmp2, ver-, >& "dev$null")
	    delete (tmp2, ver-, >& "dev$null")

	} else if (rawtable) {
	    printf ("\nCatalog table %s appears to be in raw GSC format,\n",
		table)
	    printf ("  running TFIELD to generate predicted X/Y coords\n")

#	    trename (table, tmpraw, verbose-)
	    rename (table, tmpraw, field="all")

	    tfield (tmpraw, table, image=limage, catpars="", ra=ira,
		dec=idec, equinox=iequinox, date_obs=date_obs, width=width,
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
#               trename (tmpraw, table, verbose-)
                rename (tmpraw, table, field="all")
            }
        }
end
