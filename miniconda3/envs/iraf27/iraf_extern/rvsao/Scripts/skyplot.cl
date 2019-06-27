# File archive/Scripts/xcplot.cl
# July 7, 2008
# By Doug Mink, Harvard-Smithsonian Center for Astrophysics

# SKYPLOT -- Use XCSAO to plot emission lines in a night sky spectrum
#           from a spectrum file or list of spectra

procedure skyplot (spectra)

string	spectra=""	{prompt="Spectrum RFN or file"}
int	specband=3	{prompt="Spectrum band to plot (3 in IRAF multispec)"}
string	specnum=""	{prompt="Spectrum aperture range to plot"}
string	specdir=""	{prompt="Directory for spectrum to plot"}
string	skylines="mmtsky.dat"	{prompt="File of emission lines to label"}
string	linedir="rvsao$lib/"	{prompt="Directory for lines to label"}

begin

string skl

skl = "+" // skylines

xcsao (spectra,specnum=specnum,specband=specband,ablines="",emlines=skl,specdir=specdir,correlate=no,curmode=yes,dispmode=2,logfiles="",save_vel=no,vel_plot="emission",displot=yes)
 
end

# Jul  7 2008	New script based on xcplot
