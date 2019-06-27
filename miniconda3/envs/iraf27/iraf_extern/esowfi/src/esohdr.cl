# ESOHDR -- Convert raw header to something that can be used by MSCRED.

procedure esohdr (input)

string	input			{prompt="List of raw ESO MEF files"}
bool	querytype = yes		{prompt="Query for observation type?"}
int	namps = 1		{prompt="Number of amps per CCD"}
int	ntransient = 2		{prompt="Number of bad transient columns"}
file	wcsdb = "esodb$wcs.db"  {prompt="WCS database"}
bool	redo = no		{prompt="Redo?"}
string	obstype			{prompt="Observation type", mode="q",
				 enum="zero|dark|flat|object"}

struct	*fd1, *fd2

begin
	file	inlist, extlist, hdr
	file	in, ext
	string	key
	struct	value
	int	chipindex,chipnx, chipny, chipx, chipy,win1binx,win1biny
	int	outnx, outny, outx, outy, outindex
	int	outprscx, outovscx, outprscy, outovscy
	int	x1, x2, y1, y2, cx1, cx2, cy1, cy2
	real	ltm11, ltm22, ltv1, ltv2
	bool	done

	set fkinit = envget ("fkinit") // ",padlines=30,ehulines=30"
	inlist = mktemp ("tmp$iraf")
	extlist = mktemp ("tmp$iraf")
	hdr = mktemp ("tmp$iraf")

	sections (input, option="fullname", > inlist)

	fd1 = inlist
	while (fscan (fd1, in) != EOF) {
	    if (!imaccess (in//"[0]"))
		next
	    hselect (in//"[0]", "ESOHDR", yes) | scan (key)
	    if (nscan() == 1)
		done = yes
	    else
		done = no
	    if (!redo && done)
		next

	    hselect (in//"[0]", "title", yes) | scan (value)
	    printf ("%s: %s\n", in, value)

	    mscextensions (in, output="file", index="1-", extname="", extver="",
		lindex+, lname-, lver-, ikparams="", > extlist)

	    # Convert HIERARCH keywords to normal keywords.
	    if (!done) {
		# This step is to pad the headers in one pass rather
		# than letting the FITS kernel do it.
		msccmd ("imcopy $input $output verbose-", in, in)

		hfix (in//"[0]", command="esohdrfix $fname $fname", update+)
		fd2 = extlist
		while (fscan (fd2, ext) != EOF) {
		    hfix (ext, command="esohdrfix $fname $fname", update+)
		    hedit (ext, "INHERIT", "T", add+,
			del-, verify-, show-, update+)
		}
		fd2 = ""
	    }

	    # Setup mosaic processing keywords.

	    # Observation type.
	    if (querytype)
		ccdhedit (in, "imagetyp", obstype, extname="",
		    type="string")

	    fd2 = extlist
	    while (fscan (fd2, ext) != EOF) {
		hselect (ext,
		"CHIPINDE,CHIPX,CHIPY,CHIPNX,CHIPNY,WIN1BINX,WIN1BINY", yes) |
		    scan (chipindex,chipx,chipy,chipnx,chipny,win1binx,win1biny)
		hselect (ext, "OUTINDEX,OUTX,OUTY,OUTNX,OUTNY", yes) |
		    scan (outindex, outx, outy, outnx, outny)
		hselect (ext, "OUTPRSCX,OUTOVSCX,OUTPRSCY,OUTOVSCY", yes) |
		    scan (outprscx,outovscx,outprscy,outovscy)

		# IMAGEID
		if (namp == 1)
		    printf ("%d\n", chipindex) | scan (value)
		else
		    printf ("%d%d\n", chipindex, outindex) | scan (value)
		hedit (ext, "IMAGEID", value, add+,
		    del-, verify-, show-, update+)

		# EXTNAME
		if (namp == 1)
		    printf ("im%d\n", chipindex) | scan (value)
		else
		    printf ("im%d%d\n", chipindex, outindex) | scan (value)
		hedit (ext, "EXTNAME", value, add+,
		    del-, verify-, show-, update+)

		# CCDSIZE
		printf ("[1:%d,1:%d]\n", chipnx, chipny) | scan (value)
		hedit (ext, "CCDSIZE", value, add+,
		    del-, verify-, show-, update+)

		# CCDSUM
		printf ("%d %d\n", win1binx, win1biny) | scan (value)
		hedit (ext, "CCDSUM", value, add+,
		    del-, verify-, show-, update+)

		# DETSEC
		if (chipy == 1) {
		    y1 = outy
		    if (outindex == 1) {
			x1 = outx - outnx * win1binx + 1
		    } else if (outindex == 2) {
			x1 = outx
		    }
		} else if (chipy == 2) {
		    y1 = outy - outny * win1biny + 1
		    if (outindex == 1) {
			x1 = outx
		    } else if (outindex == 2) {
			x1 = outx - outnx * win1binx + 1
		    }
		}
		x2 = x1 + outnx * win1binx - 1
		y2 = y1 + outny * win1biny - 1
		printf ("[%d:%d,%d:%d]\n", x1, x2, y1, y2) | scan (value)
		hedit (ext, "DETSEC", value, add+,
		    del-, verify-, show-, update+)

		# CCDSEC
		cx1 = 1
		cy1 = 1
		cx2 = outnx * win1binx
		cy2 = outny * win1biny
		printf ("[%d:%d,%d:%d]\n", cx1, cx2, cy1, cy2) | scan (value)
		hedit (ext, "CCDSEC", value, add+,
		    del-, verify-, show-, update+)

		# AMPSEC
		if (chipy == 1) {
		    y1 = 1
		    y2 = outny * win1biny
		    if (outindex == 1) {
			x1 = outnx * win1binx
			x2 = 1
		    } else if (outindex == 2) {
			x1 = 1
			x2 = outnx * win1binx
		    }
		} else if (chipy == 2) {
		    y1 = outny * win1biny
		    y2 = 1
		    if (outindex == 1) {
			x1 = 1
			x2 = outnx * win1binx
		    } else if (outindex == 2) {
			x1 = outnx * win1binx
			x2 = 1
		    }
		}
		printf ("[%d:%d,%d:%d]\n", x1, x2, y1, y2) | scan (value)
		hedit (ext, "AMPSEC", value, add+,
		    del-, verify-, show-, update+)

		# DATASEC
		if (chipy == 1) {
		    y1 = 1 + outprscy
		    if (outindex == 1)
			x1 = 1 + outovscx
		    else if (outindex == 2)
			x1 = 1 + outprscx
		} else if (chipy == 2) {
		    y1 = 1 + outovscy
		    if (outindex == 1)
			x1 = 1 + outprscx
		    else if (outindex == 2)
			x1 = 1 + outovscx
		}
		x2 = x1 + outnx - 1
		y2 = y1 + outny - 1
		printf ("[%d:%d,%d:%d]\n", x1, x2, y1, y2) | scan (value)
		hedit (ext, "DATASEC", value, add+,
		    del-, verify-, show-, update+)

		# LTV/LTM
		ltm11 = real (x2 - x1 + 1) / real (cx2 - cx1 + 1)
		ltm22 = real (y2 - y1 + 1) / real (cy2 - cy1 + 1)
		ltv1 = x1 - ltm11 * cx1 - 0.5 * (1 - ltm11)
		ltv2 = y1 - ltm22 * cy1 - 0.5 * (1 - ltm22)
		hedit (ext, "LTV1", ltv1, add+, del-, verify-, show-, update+)
		hedit (ext, "LTV2", ltv2, add+, del-, verify-, show-, update+)
		printf ("ltm11=%g, ltm22=%g\n", ltm11, ltm22)
		hedit (ext, "LTM1_1", ltm11,
		    add+, del-, verify-, show-, update+)
		hedit (ext, "LTM2_2", ltm22,
		    add+, del-, verify-, show-, update+)

		# BIASSEC
		if (chipy == 1) {
		    if (outindex == 1)
			x1 = 1
		    else if (outindex == 2)
			x1 = 1 + outprscx + outnx
		} else if (chipy == 2) {
		    if (outindex == 1)
			x1 = 1 + outprscx + outnx
		    else if (outindex == 2)
			x1 = 1
		}
		x2 = x1 + outovscx - 1
		printf ("[%d:%d,*]\n", x1, x2, y1, y2) | scan (value)
		hedit (ext, "BIASSEC", value, add+,
		    del-, verify-, show-, update+)

		# TRIMSEC
		if (chipy == 1) {
		    y1 = 1 + outprscy
		    if (outindex == 1) {
			x1 = 1 + outovscx
			x2 = outovscx + outnx - ntransient
		    } else if (outindex == 2) {
			x1 = 1 + outprscx + ntransient
			x2 = outprscx + outnx
		    }
		} else if (chipy == 2) {
		    y1 = 1 + outovscy
		    if (outindex == 1) {
			x1 = 1 + outprscx + ntransient
			x2 = outprscx + outnx
		    } else if (outindex == 2) {
			x1 = 1 + outovscx
			x2 = outovscx + outnx - ntransient
		    }
		}
		y2 = y1 + outny - 1
		printf ("[%d:%d,%d:%d]\n", x1, x2, y1, y2) | scan (value)
		hedit (ext, "TRIMSEC", value, add+,
		    del-, verify-, show-, update+)

		# AMPNAME
		hedit (ext, "AMPNAME", "(CHIPID//OUTNAME)", add+,
		    del-, verify-, show-, update+)

	    }
	    fd2 = ""
	    delete (extlist, verify-)

	    # WCS
	    if (access (wcsdb)) {
		match ("WCSASTRM", wcsdb, stop-) | scan (key, key, key, value)
		if (nscan() > 3)
		    hedit (in//"[0]", "WCSASTRM", value, add+,
			del-, verify-, show-, update+)
		if (!done)
		    hedit (in//"[0]", "RA", "(RA/15)", add+,
			del-, verify-, show-, update+)
		mscsetwcs (in, wcsdb, ra="ra", dec="dec",
		    ra_offset=0., dec_offset=0.)
	    } else {
		printf ("WARNING: WCS database not found (%s)", wcsdb)
		printf (" - WCS not set\n")
	    }

	    time | scan (value)
	    hedit (in//"[0]", "ESOHDR", value, add+,
		    del-, verify-, show-, update+)

	}
	fd1 = ""; delete (inlist, verify-)
end
