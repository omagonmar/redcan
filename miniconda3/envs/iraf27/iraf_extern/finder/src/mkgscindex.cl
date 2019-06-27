#  GSCINDEX -- Stage the GSC index table from CD to disk and convert
#  from FITS to a machine dependent STSDAS table.

# This is a modified version of the GASP task stgindx.
# FITSIO and TTOOLS must be loaded (automatically with STSDAS).

# This will be obsolete when the tables package FITS support is available.

procedure gscindex (cdfile, index, overwrite)

string	cdfile  = "/cdrom0/tables/regions.tbl"	{prompt="GSC index FITS file"}
string	index   = "finder$lib/index"	{prompt="output table root pathname"}
bool	header  = yes			{prompt="preserve table hhh header?"}

bool	overwrite = yes			{prompt="overwrite?"}

begin
	string	intab, root
	int	len

	intab = cdfile
	root = index

	len = strlen (root)
	if (substr (root, len-3, len) == ".tab")
	    root = substr (root, 1, len-4)

	if (access (root//".tab") || access (root//".hhh")) {
	    printf ("index file %s already exists, ", root)
	    if (overwrite) {
		delete (root//".tab", verify-, >& "dev$null")
		delete (root//".hhh", verify-, >& "dev$null")
	    } else
		return
	}

	set imtype = "hhh"
	strfits (intab, "", root, oldirafname-)

	if (! header)
	    delete (root//".hhh")
end
