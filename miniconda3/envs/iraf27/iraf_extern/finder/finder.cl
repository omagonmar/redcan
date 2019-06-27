#{ FINDER.CL -- Script to set up tasks in the FINDER package

# complains about motd parameter if tables is already loaded
# tables motd-

printf ("loading tables package:\n")
tables

cl < "finder$lib/zzsetenv.def"
package	finder, bin = finderbin$

task	dssfinder	=	"finder$src/dssfinder.cl"
task	finderlog	=	"finder$src/finderlog.cl"
task	mkgscindex	=	"finder$src/mkgscindex.cl"
task	mkgsctab	=	"finder$src/mkgsctab.cl"
task	mkobjtab	=	"finder$src/mkobjtab.cl"
task	objlist		=	"finder$src/objlist.cl"
task	tastrom		=	"finder$src/tastrom.cl"
task	tfinder		=	"finder$src/tfinder.cl"
task	tpltsol		=	"finder$src/tpltsol.cl"
task	tvmark_		=	"finder$src/tvmark_.cl"
hidetask tvmark_

task	catpars		=	"finder$src/catpars.par"
task	disppars	=	"finder$src/disppars.par"
task	selectpars	=	"finder$src/selectpars.par"
task	_qpars		=	"finder$src/_qpars.par"
hidetask _qpars

task	cdrfits,
	gscfind,
	tfield,
	tpeak		=	"finder$src/x_finder.e"

clbye()
