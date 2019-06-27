#{ GMISC.CL -- Script to set up tasks in the GMISC package

# load necessary packages here

cl < "gmisc$lib/zzsetenv.def"
package	gmisc, bin = gmiscbin$

# directory definitions
set ldispdemo = "gmisc$src/ldispdemo/"

# define the various types of tasks

# native IRAF (spp) tasks:
task	gdispcor,
	gstandard,
	gscombine,
	ldisplay,
	nhedit,
	skymask = "gmisc$src/x_gmisc.e"

# CL scripts with parameters:

# CL scripts without parameters:

# IMFORT and other host programs:

clbye()
