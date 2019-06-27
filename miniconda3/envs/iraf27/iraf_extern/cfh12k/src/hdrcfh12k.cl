# HDRCFH12K -- Convert raw header to something that can be used by MSCRED.

procedure hdrcfh12k (input)

string	input			{prompt="List of raw CFH12K MEF files"}
file	wcsdb = "cfh12k$lib/db/Rwcs.db"  {prompt="WCS database"}
bool	redo = no		{prompt="Redo?"}

struct	*fd

begin
	file	inlist, extlist
	file	in, ext
	int	i, j
	string	key
	struct	value
	bool	done

	set fkinit = envget ("fkinit") // ",padlines=30,ehulines=30"
	inlist = mktemp ("tmp$iraf")
	extlist = mktemp ("tmp$iraf")

	sections (input, option="fullname", > inlist)

	fd = inlist
	while (fscan (fd, in) != EOF) {
	    if (!imaccess (in//"[0]"))
		next
	    hselect (in//"[0]", "FIXHDR", yes) | scan (key)
	    if (nscan() == 1)
		done = yes
	    else
		done = no
	    if (!redo && done)
		next

	    hselect (in//"[0]", "title", yes) | scan (value)
	    printf ("%s: %s\n", in, value)

	    # Pad the headers in one pass rather than letting the FITS
	    # kernel do it.
	    if (!done) {
		msccmd ("imcopy $input $output verbose-", in, in)
		for (i=1; i<=12; i+=1) {
		    printf ("%s[%d]\n", in, i) | scan (ext)
		    hselect (ext, "EXTNAME", yes) | scan (key)
		    if (nscan() == 0) {
			j = i - 1
			printf ("chip%02d\n", j) | scan (key)
			hedit (ext, "EXTNAME", key,
			    add+, del-, verify-, show-, update+)
		    }
		}
	    }

	    # Fix typos in DETSEC.
	    hedit (in//"[chip00]", "DETSEC", "[1:2044,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip01]", "DETSEC", "[2082:4125,1:4096]",
		add+, del-, verify-, show-, update+)
# V1
#	    hedit (in//"[chip07]", "DETSEC", "[2092:4135,4114:8209]",
#		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip07]", "DETSEC", "[2092:4135,8209:4114]",
		add+, del-, verify-, show-, update+)

	    # Set physical coordinates.
	    hedit (in//"[chip00]", "CCDSEC", "[1:2044,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip01]", "CCDSEC", "[1:2044,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip02]", "CCDSEC", "[2044:1,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip03]", "CCDSEC", "[2044:1,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip04]", "CCDSEC", "[1:2044,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip05]", "CCDSEC", "[1:2044,1:4096]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip06]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip07]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip08]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip09]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip10]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)
	    hedit (in//"[chip11]", "CCDSEC", "[1:2044,4096:1]",
		add+, del-, verify-, show-, update+)

	    mscextensions (in, output="file", index="1-", extname="", extver="",
		lindex+, lname-, lver-, ikparams="", > extlist)
	    hedit ("@"//extlist, "LTV1", 5, add+, del-, verify-, show-, update+)
	    hedit ("@"//extlist, "LTV2", 4, add+, del-, verify-, show-, update+)
	    delete (extlist, verify-)

	    # Set WCS.
	    if (access (wcsdb))
		mscsetwcs (in, wcsdb, ra="ra", dec="dec",
		    ra_offset=0., dec_offset=0.)
	    else {
		printf ("WARNING: WCS database not found (%s)", wcsdb)
		printf (" - WCS not set\n")
	    }

	    time | scan (value)
	    hedit (in//"[0]", "FIXHDR", value,
		add+, del-, verify-, show-, update+)

	}
	fd = ""; delete (inlist, verify-)
end
