# MKGSCTAB -- Make a pseudo-GSC table for TPEAK and TFINDER.
# The input is a list of celestial coordinates in hours or degrees for RA
# and in degrees for Dec - an optional third column is an integer ID number.

# GSC table format:
#     GSC_ID           I[2]          %5d  ""
#     RA_DEG           R[2]        %9.5f  ""
#     DEC_DEG          R[2]        %9.5f  ""
#     POS_ERR          R[2]        %5.1f  ""
#     MAG              R[2]        %5.2f  ""
#     MAG_ERR          R[2]        %4.2f  ""
#     MAG_BAND         I[2]          %2d  ""
#     CLASS            I[2]          %1d  ""
#     PLATE_ID         CH*4[2]      %-4s  ""
#     MULTIPLE         CH*1         %-1s  ""

procedure mkgsctab (input, output)

string	input			{prompt="Input coordinate list (RA Dec [ID])"}
string	output			{prompt="Output GSC format table"}

string	ra_units = "hours"	{prompt="Input RA units", enum="|hours|degrees"}
int	startid = 1		{prompt="Starting ID number (if not provided)"}
int	region = 0		{prompt="Region number for new entries"}
string	plate = "NONE"		{prompt="Plate name for new entries"}

string	cdfile = "finder$lib/cdfile.gsc" {prompt="Column definition file"}

string	*list

begin
	string	linput, loutput, tmp
	real	ra
	int	newid, len
	bool	hms

	int	gsc_id
	real	ra_deg, dec_deg, pos_err, mag, mag_err
	int	mag_band, class
	string	plate_id, multiple

	tmp = mktemp ("tmp$tmp")

	linput = input
	loutput = output

	if (! access (linput))
	    error (1, "No input list of coordinates to make GSC format table")

	len = strlen (loutput)
	if (substr (loutput, len-3, len) != ".tab")
	    loutput //= ".tab"

	if (access (loutput)) {
	    printf ("Output file %s already exists, ", loutput)
	    if (_qpars.overwrite)
		delete (loutput, verify-, >& "dev$null")
	    else
		error (1, "You must rename the file before trying again")
	}

	hms = (ra_units == "hours")

	# defaults for missing values
	pos_err = 0.
	mag = 0.
	mag_err = 0.
	mag_band = 0

	class = 0		# stellar
	plate_id = plate
	multiple = "F"

	gsc_id = startid

	list = linput
	while (fscan (list, ra, dec_deg, newid) != EOF) {
	    if (nscan () < 2)
		next
	    else if (nscan() == 2)
		gsc_id += 1
	    else
		gsc_id = newid
	    
	    if (hms)
		ra_deg = ra * 15.
	    else 
		ra_deg = ra

	    printf ("%4d %11.7f %11.7f %6.2f %5.2f %4.2f %2d %1d %-4s %-1s\n",
		gsc_id, ra_deg, dec_deg, pos_err, mag, mag_err, mag_band,
		class, plate_id, multiple, >> tmp)

	    gsc_id += 1
	}

	tcreate (loutput, cdfile, tmp, uparfile="", nskip=0, nlines=1,
	    nrows=0, hist+, extrapar=8, tbltype="default", extracol=0)

	parkey (region, loutput, "REGION", add+)

	delete (tmp, verify-, >& "dev$null")
end
