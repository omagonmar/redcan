procedure objlog (table)

string	table			{prompt="Input table name"}

string	ra_units = "hours"	{prompt="Units for RA column",
				    enum="|hours|degrees"}

bool	showxy = yes		{prompt="Print X_CENTER,Y_CENTER columns?"}
bool	showgsc = yes		{prompt="Print GSC_ID column?"}
bool	showhdr = yes		{prompt="Print column names?"}

begin
	string	sp_col  = ""
	string	ltable, tmp1, columns
	bool	hms
	int	num

	cache ("tinfo")

	tmp1 = mktemp ("tmp$obj")

	ltable = table

	tlcol (ltable, nlist=1) | match ("OBJ_FLAG", stop-) | count | scan (num)
	if (num != 1) {
	    printf ("no object flag - is this finder output?\n")
	    return
	}

	tselect (ltable, tmp1, "OBJ_FLAG == 1")
	tinfo (tmp1, ttout-)

	if (tinfo.nrows <= 0) {
	    printf ("no program objects found\n")
	    tdelete (tmp1, ver-, >& "dev$null")
	    return
	}

	tcalc (tmp1, "RA_HRS", "RA_DEG / 15.", datatype="double",
	    colunits="", colfmt="%14.3h")

	tchcol (tmp1, "RA_HRS", "", "", "hours", verbose=no)
	tchcol (tmp1, "RA_DEG", "", "%13.2h", "degrees", verbose=no)
	tchcol (tmp1, "DEC_DEG", "", "%13.2h", "degrees", verbose=no)
	tchcol (tmp1, "GSC_ID", "", "", "index", verbose=no)

	if (ra_units == "hours")
	    columns = "RA_HRS,DEC_DEG"
	else
	    columns = "RA_DEG,DEC_DEG"

	if (showxy)
	    columns = "X_CENTER,Y_CENTER," // columns

	if (showgsc)
	    columns = columns // ",GSC_ID"

	tprint (tmp1, prparam-, prdata+, showrow-, showhdr=showhdr, showunits-,
	    pwidth=80, plength=0, lgroup=0, columns=columns, rows="-",
	    option="plain", align=yes, sp_col=sp_col)

	tdelete (tmp1, ver-, >& "dev$null")
end
