# File Rvsao/Makespec/sum.com
# March 23, 2005

# Task parameters for SUMSPEC and LINESPEC
 
common /suser/ velocity, velhc, minwav0, maxwav0, dw, texp, ymin, ymax, tsmooth, save_names, copyhead
 
double	velocity	# Desired velocity for output spectrum
double	velhc		# Desired heliocentric velocity correction for output
double 	minwav0		# Starting wavelength from parameter file or overlap
double 	maxwav0		# Ending wavelength from parameter file or overlap
double	dw		# Wavelength per pixel in Angstroms
double	texp		# Total exposure time
real	ymin		# Minimum y value for graphs
real	ymax		# Maximum y value for graphs
int	tsmooth		# Number of times to smooth final template plot
bool	save_names	# Yes to save names in header, else no
bool	copyhead	# Yes to copy header information from first file

# Feb  4 1997	New labelled common
# Apr 14 1997	Move PLTTEMP to rvsao.com
# Apr 21 1997	Add wavelength limits
# Apr 29 1997	Change names from template-oriented to spectrum-oriented
# May 16 1997	Add delta wavelength
# Jul 22 1997	Add flag to make saving filenames optional

# Jun 10 1999	Add total exposure time
# Jul 19 2000	Add output heliocentric velocity correction

# Mar 23 2005	Add ymin and ymax to scale all graphs the same
# Aug 30 2005	Add copyhead to copy header information from first input file
