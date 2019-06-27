procedure tastrom (input)

string	input			{prompt="Input table or root name"}
string	rootname = ""	{prompt="Alternate root name for ASTROM input/output"}
string	equinox = "J2000"	{prompt="Report equinox"}
string	geometry = "ASTR"	{prompt="Telescope geometry type\n",
				 enum="ASTR|SCHM|AAT2|AAT3|AAT8|JKT8"}

real	ra_tan = INDEF		{prompt="RA of the tangent point"}
real	dec_tan = INDEF		{prompt="Dec of the tangent point"}
string	tequinox = "J2000"	{prompt="Equinox for the tangent coordinates\n"}

bool	silent = yes	{prompt="Silently delete previous ASTROM files?"}
pset	catpars	= ""		{prompt="Catalog description pset\n"}

string	*list

begin
	string	linput, loutput, tmp1, tmp2, buf
	string	infile, outfile, astfile, inosfn
	string	ltequinox
	int	ra_hrs, ra_min, dec_deg, dec_min, dec_sec, dec_sign, len
	real	ra_sec, ldec_tan
	struct	line

	tmp1 = mktemp ("tmp$tmp")
	tmp2 = mktemp ("tmp$tmp")

	linput = input
	loutput = rootname

	if (loutput == "") {
	    loutput = linput
	    len = strlen (loutput)
	    if (substr (loutput, len-3, len) == ".tab")
		loutput = substr (loutput, 1, len-4)
	    else if (substr (loutput, len-4, len) == ".fits")
		loutput = substr (loutput, 1, len-5)
	    else if (substr (loutput, len-3, len) == ".fit")
		loutput = substr (loutput, 1, len-4)
	}
	
	infile = loutput // ".in"
	outfile = loutput // ".out"
	astfile = loutput // ".ast"
	inosfn = osfn (loutput//".in")

# Should no longer be needed since astfile is now passed explicitly to ASTROM.
#	if (access ("astrom.lis")) {
#	    printf ("Temporary file astrom.lis exists, ")
#	    if (_qpars.replace) {
#		delete ("astrom.lis", ver-, >& "dev$null")
#	    } else {
#		printf ("\nYou must rename the file before trying again.\n")
#		return
#	    }
#	}

	if (silent) {
	    delete (outfile, ver-, >& "dev$null")
	    delete (astfile, ver-, >& "dev$null")

	} else if ( access (outfile) || access (astfile)) {
	    printf ("ASTROM output file %s or %s exists, ", outfile, astfile)
	    if (_qpars.overwrite) {
		delete (outfile, ver-, >& "dev$null")
		delete (astfile, ver-, >& "dev$null")
	    } else {
		printf ("\nYou must rename the files before trying again.\n")
		return
	    }
	}

	if (access (infile)) {
	    printf ("ASTROM input file %s exists, ", infile)
	    if (_qpars.overwrite) {
		delete (infile, ver-, >& "dev$null")

	    } else {
		printf ("!astrom.x . %s %s .\n", inosfn, astfile) |
		    cl (> outfile)
		return
	    }
	}

	print (equinox, >> tmp1)
	print (geometry, >> tmp1)

	ltequinox = tequinox	# to avoid generating two prompts

	ra_hrs = int (ra_tan)
	ra_min = int (60. * (ra_tan - ra_hrs))
	ra_sec = 60. * (60. * (ra_tan - ra_hrs) - ra_min)

	if (dec_tan < 0.) {
	    ldec_tan = - dec_tan
	    dec_sign = -1
	} else {
	    ldec_tan = dec_tan
	    dec_sign = 1
	}

	dec_deg = int (ldec_tan)
	dec_min = int (60. * (ldec_tan - dec_deg))
	dec_sec = int (60. * (60. * (ldec_tan - dec_deg) - dec_min))

	if (dec_sign == -1)
	    dec_deg = - dec_deg

	printf ("%2d %02d %04.1f", ra_hrs, ra_min, ra_sec, >> tmp1)
	printf ("  %3d %02d %02d", dec_deg, dec_min, dec_sec, >> tmp1)
	printf ("  %s %s\n", ltequinox, ltequinox, >> tmp1)

	buf =	catpars.sub_col // " == 1 && " //
		catpars.cen_col // " == 1 && " //
		catpars.obj_col // " == 0"

	tselect (linput, tmp2, buf)

	tcalc (tmp2, "RA_HRS", "RA_DEG / 15.", datatype="double",
	    colunits="", colfmt="%13.3h")

	# leave a "#" placeholder for "%" format later 
	# (even escaped, the "%" bothers tprint with reentrant printf's)
	tchcol (tmp2, "DEC_DEG", "", "%12.2h#s", "", verbose=no)
	tchcol (tmp2, "X_CENTER", "", "%8.2f", "", verbose=no)
	tchcol (tmp2, "Y_CENTER", "", "%8.2f *", "", verbose=no)
	tchcol (tmp2, "GSC_ID", "", "%5d\n", "", verbose=no)

#	tchcol (tmp2, "REGION", "", "%5d\n", "", verbose=no)
#	tprint (tmp2, columns="ra_hrs,dec_deg,region,x_center,y_center,gsc_id",
#	    prparam-, prdata+, pwidth=80, plength=0, showrow-, showhdr-,
#	    rows="-", option="plain", sp_col="", lgroup=0, >> tmp1)

#	tprint (tmp2, columns="ra_hrs,dec_deg,gsc_id,x_center,y_center,region",
#	    prparam-, prdata+, pwidth=80, plength=0, showrow-, showhdr-,
#	    rows="-", option="plain", sp_col="", lgroup=0, >> tmp1)
#
# Jan 24, 2000, Inger Jorgensen
# changed this print statement to deal with 2nd INDEF element of arrays
# necessary after tables v2.1 update that prints both elements
        tprint (tmp2, columns="ra_hrs,dec_deg,gsc_id,x_center,y_center,region",
            prparam-, prdata+, pwidth=80, plength=0, showrow-, showhdr-,
            showunits-, rows="-", option="plain", sp_col="", lgroup=0) | \
        match("INDEF","STDIN",stop+,print_file_n-,metacharacte+, >> tmp1)

	tdelete (tmp2, ver-, >& "dev$null")

	print ("*", >> tmp1)
	print ("0.0 0.0 * JUNK", >> tmp1)

	buf =	catpars.sub_col // " == 1 && " //
		catpars.cen_col // " == 1 && " //
		catpars.obj_col // " == 1"

	tselect (linput, tmp2, buf)

	tchcol (tmp2, "Y_CENTER", "", "%8.2f *", "", verbose=no)
	tchcol (tmp2, "GSC_ID", "", "%5d", "", verbose=no)

	tprint (tmp2, columns="x_center,y_center,gsc_id",
	    prparam-, prdata+, pwidth=80, plength=0, showrow-, showhdr-,
	    rows="-", option="plain", sp_col="", lgroup=0, showunits-,
	    >>& "dev$null", >> tmp1)

	tdelete (tmp2, ver-, >& "dev$null")

# instead of sed use grotty, but portable, formatting commands below
#	print ("s/:/\ /g", > tmp2)
#	print ("s/@/\ 0.0\ 0.0\ ", catpars.cat_epoch, "\ *\ /", >> tmp2)
#	print ("s/#/\ \ *\ /", >> tmp2)
#	printf ("!sed -f %s %s > %s\n", osfn(tmp2), osfn(tmp1), infile) | cl

	# replace colons with spaces in RA and Dec
	translit (tmp1, ":", " ", del-, coll-, > tmp2)
	delete (tmp1, ver-, >& "dev$null")

	# replace the placeholder "#" with "%" and print to resulting format
	translit (tmp2, "#", "%", del-, coll-, > tmp1)
	delete (tmp2, ver-, >& "dev$null")

	buf = " 0.0 0.0 " // catpars.cat_epoch // " * "

	# note that lines lengths are constrained by the struct
	list = tmp1
	while (fscan (list, line) != EOF)
	    printf (line//"\n", buf, >> infile)
	list = ""
	delete (tmp1, ver-, >& "dev$null")

	printf ("!astrom.x . %s %s .\n", inosfn, astfile) | cl (> outfile)
end
