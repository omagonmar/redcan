# IMLINFIT  --  perform a pixel by pixel, linear least squares fit
#            to a set of images.

#	The function is:  y = a + b*x
#
#	The coeffs are:	  a = (SUMY * sumx2 - sumx * SUMXY) / delta
#			  b = (nimg * SUMXY - sumx * SUMY)  / delta
#	where:	      delta = (nimg * sumx2 - sumx * sumx)
#
#       UPPERCASE are coadded images, lowercase are scalars.

procedure imlinfit (images, intercept, slope)

string	images		{prompt="Images to fit"}
string	intercept	{prompt="Output intercept image"}
string	slope		{prompt="Output slope image"}

string	keyword	= ""	{prompt="Keyword for x values"}

struct	*ilist
struct	*xlist

begin
	string	img, slp, intcpt, sumy, sumxy
	string	ifile, xfile, tfile, tmp1, tmp2
	real	x, delta

	real	sumx  = 0.0
	real	sumx2 = 0.0
	int	nimg  = 0

	# Make names for temporary images
	sumy	= mktemp ("tmp$imf")
	sumxy	= mktemp ("tmp$imf")
	tmp1	= mktemp ("tmp$imf")
	tmp2	= mktemp ("tmp$imf")

	# Make names for temporary files
	ifile	= mktemp ("tmp$imf")
	tfile	= mktemp ("tmp$imf")
	xfile	= mktemp ("tmp$imf")

	# Prompt for the images and expand the template
	sections (images, option="fullname", > ifile)

	# Prompt for the other query parameters
	intcpt	= intercept
	slp	= slope

	# Open the
	ilist = ifile; xlist = xfile
	while (fscan (ilist, img) != EOF) {
	    # Temporary images, 1 per input image
	    print (mktemp ("tmp$imf"), >> tfile)

	    hselect (img, keyword, yes, >> xfile)
	    if (fscan (xlist, x) != 1)
		error (1, "Keyword `" // keyword // "' not found in " // img)

	    sumx  += x
	    sumx2 += x * x
	    nimg  += 1
	}
	ilist = ""; xlist = ""

	delta = nimg * sumx2 - sumx * sumx

	# Calculate SUMY
	imcombine ("@" // ifile, sumy, option="sum", outtype="real",
	    logfile="", exposure-, scale-, offset-, weight-)

	# Calculate SUMXY
	imarith ("@" // ifile, "*", "@" // xfile, "@" // tfile,
	    pixtype="real", calctype="real", verbose-, noact-)
	imcombine ("@" // tfile, sumxy, option="sum", outtype="real",
	    logfile="", exposure-, scale-, offset-, weight-)
	imdelete ("@" // tfile, ver-, >& "dev$null")

	# Calculate the intercept
	imarith (sumy, "*", sumx2, tmp1, pix="r", calc="r", verb-, noact-)
	imarith (sumxy, "*", sumx, tmp2, pix="r", calc="r", verb-, noact-)
	imarith (tmp1, "-", tmp2, intcpt, pix="r", calc="r", verb-, noact-)
	imarith (intcpt, "/", delta, intcpt, pix="r", calc="r", verb-, noact-)
	imdelete (tmp1//","//tmp2, ver-, >& "dev$null")

	# Calculate the slope
	imarith (sumxy, "*", nimg, tmp1, pix="r", calc="r", verb-, noact-)
	imarith (sumy, "*", sumx, tmp2, pix="r", calc="r", verb-, noact-)
	imarith (tmp1, "-", tmp2, slp, pix="r", calc="r", verb-, noact-)
	imarith (slp, "/", delta, slp, pix="r", calc="r", verb-, noact-)
	imdelete (tmp1//","//tmp2, ver-, >& "dev$null")

	# Clean up
	imdelete (sumy//","//sumxy, ver-, >& "dev$null")
	delete (ifile//","//tfile//","//xfile, ver-, >& "dev$null")
end
