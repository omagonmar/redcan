# MKOBJTAB -- Make a GSC format table for input to tfinder from a table
# containing measured object coordinates as output from tfinder.

procedure mkgsctab (input, output)

string	input		{prompt="Table with measured and fitted objects"}
string	output		{prompt="Output GSC format table"}

int	region = 0	{prompt="Region number for new entries"}
string	plate = "NONE"	{prompt="Plate name for new entries"}

string  cdfile = "finder$lib/cdfile.gsc" {prompt="Column definition file"}

begin
	string	linput, loutput, tmp1, tmp2, buf
	real	ra_deg, dec_deg
	int	len, gsc_id

	tmp1 = mktemp ("tmp$tmp1.")
	tmp2 = mktemp ("tmp$tmp2.")

	linput = input
	loutput = output

	len = strlen (linput)
	if (substr (linput, len-3, len) != ".tab")
	    linput //= ".tab"

	if (! access (linput))
	    error (1, "No input table of measured objects")

	len = strlen (loutput)
	if (substr (loutput, len-3, len) != ".tab")
	    loutput //= ".tab"

	if (access (loutput)) {
	    printf ("Output table %s already exists, ", loutput)
	    if (_qpars.overwrite)
		tdelete (loutput, ver-, >& "dev$null")
	    else
		error (1, "You must rename the file before trying again")
	}

        buf = catpars.cen_col // " == 1 && " // catpars.obj_col // " == 1"
	tselect (linput, tmp1, buf)

	tinfo (tmp1, ttout-)
	if (tinfo.nrows <= 0) {
	    tdelete (tmp1, ver-, >& "dev$null")
	    error (1, "No objects in input table")
	}

	tchcol (tmp1, "RA_DEG", "", "%12.8f", "", verbose=no)
	tchcol (tmp1, "DEC_DEG", "", "%12.8f", "", verbose=no)

	tprint (tmp1, columns="RA_DEG,DEC_DEG,GSC_ID", prparam-, prdata+,
	    pwidth=80, plength=0, showrow-, showhdr-, showunits-, rows="-",
	    option="plain", sp_col="", lgroup=0, > tmp2)

	tdelete (tmp1, ver-, >& "dev$null")

	mkgsctab (tmp2, loutput, ra_units="degrees", startid=1,
	    region=region, plate=plate, cdfile=cdfile)

	delete (tmp2, ver-, >& "dev$null")
end
