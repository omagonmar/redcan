# File rvsao/emplot.cl
# August 13, 2009
# By Doug Mink, Harvard-Smithsonian Center for Astrophysics

# EMPLOT -- Use EMSAO to plot emission and absorption lines already found
#           in a spectrum file or list of spectra

procedure emplot (spectra)

string	spectra=""	{prompt="RFN or file"}
int     specband=1	{prompt="Spectrum band to plot (in IRAF multispec)"}
string  specnum=""	{prompt="Spectrum aperture range to plot"}
string  specdir=""	{prompt="Directory for spectrum to plot"}
string  ablines="ablines.dat"	{prompt="File of absorption lines to label"}
string  emlines="emlines.dat"	{prompt="File of emission lines to label"}
string  linedir="rvsao$lib/"	{prompt="Directory for lines to label"}
string	velplot="combination"	{prompt="Velocity to plot",
				 enum="combination|emission|correlation"}
string	device="stdgraph"	{prompt="Display device"}

begin
string	eml

eml = "+" // emlines

emsao (spectra,specband=specband,specnum=specnum,specdir=specdir,vel_init="combination",linefit=no,curmode=yes,ablines=ablines,emlines=eml,emcomb="",linedir=linedir,logfiles="",save_vel=no,vel_plot=velplot,displot=yes,dispmode=3,device=device)
 
end

# May 13 2008	New script based on qplot
# May 29 2008	Change name from eplot to emplot for consistency with xcplot
# Jul  7 2008	Add specband, specnum, specdir, ablines, emlines, linedir
# Jul  7 2008	Prepend + to emission line file to force line labelling
# Jul 28 2008	Set all emsao parameters from input parameters

# Aug 13 2009	Add device parameter
