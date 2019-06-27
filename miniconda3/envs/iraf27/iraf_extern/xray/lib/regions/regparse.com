#$Header: /home/pros/xray/lib/regions/RCS/regparse.com,v 11.0 1997/11/06 16:19:05 prosb Exp $
#$Log: regparse.com,v $
#Revision 11.0  1997/11/06 16:19:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:10  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:06  prosb
#General Release 2.2
#
#Revision 5.1  93/04/27  00:03:12  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:13:44  prosb
#General Release 2.1
#
#Revision 4.3  92/09/29  20:55:35  dennis
#new common /regreffilcom/: variables for region descriptor-specified
#				reference file
#added comments describing the common blocks
#
#Revision 4.2  92/09/02  03:04:59  dennis
#Expanded rg_lbuf[] from SZ_LINE to SZ_REGINPUTLINE.
#Moved double precision variables to beginning of common block, to avoid 
#alignment problems.
#
#Revision 4.1  92/08/07  17:19:55  dennis
#Added rg_stribase to /regnotcom/ (used in protecting against notes string
#buffer overrun);
#Improved comments.
#
#Revision 4.0  92/04/27  17:19:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:14:40  pros
#General Release 1.0
#
#
# The region parser common
#  (The variables are stored in a different order than they are declared in; 
#  I order the declarations according to my logic; I order the storage to 
#  avoid alignment problems.)
#
pointer	rg_parsing			# pointer to parsing control struct
bool	rg_making_mask			# whether OPENMASK is selected and 
					#  the mask isn't already open
bool	rg_executing			# whether any option selected causes 
					#  executing of virtual CPU programs
bool	rg_compiling			# whether any option selected causes 
					#  compiling of virtual CPU programs
bool	rg_coording			# whether any option selected requires 
					#  interpreting coords in descriptor

int	rg_installed			# number of keywords installed
int	rg_names[MAX_RGKEYWORDS]	# pointers to keyword strings
int	rg_codes[MAX_RGKEYWORDS]	# keyword codes
int	rg_ktype[MAX_RGKEYWORDS]	# keyword types (tokens)
int	rg_minargs[MAX_RGKEYWORDS]	# min args for reg
int	rg_maxargs[MAX_RGKEYWORDS]	# max args for reg

int 	rg_fd				# current region descriptor file handle
int	rg_fdlev			# index for top of rg_fds[] stack
int	rg_fds[MAX_NESTS]		# region descriptor file handle stack

int	rg_lptr				# current lptr into line
char	rg_lbuf[SZ_REGINPUTLINE]	# line being parsed
pointer rg_nextshortstr			# next place in rg_parse()'s shortstrs 
					#  buffer for rg_lex() to buffer a 
					#  short string for testing

double 	rg_equix			# current equinox
double	rg_epoch			# FK4 epoch
int 	rg_system			# current coordinate system
int	rg_pixsys			# current pixel system

int	rg_nargs			# number of args buffered for shape
real	rg_args[MAX_ARGS]		# shape spec arg value list buffer
int	rg_types[MAX_ARGS]		# shape spec arg type list buffer

int	rg_inclreg			# flag to execute immediately (i.e., 
					#  INCLUDE region, not EXCLUDE)

# rg_slices and rg_annuli are dynamic (while rg_metacode[] isn't) so that we 
#  can use the same macros to access the fields of both

pointer	rg_slices			# multiple slices control structure
pointer	rg_annuli			# multiple annuli control structure

int	rg_nextinst			# next free spot in metacode
int	rg_metacode[LEN_INST, MAX_INST]	# virtual CPU program


int	rg_eflag			# flag that an error occurred
					#  [never set; maybe to use later]




pointer	rg_refimw			# MWCS from ref file
pointer	rg_refctpix			# pixel transform from ref file
bool	rg_ref_active			# whether ref file in effect




# common variables for most regions processing
#  (Placing the "double" variables first avoids alignment-dependent 
#   "performance degradation" warning messages.)
common	/regcom/ rg_equix, rg_epoch, 		# these are double
	rg_system, rg_pixsys,
	rg_parsing, rg_making_mask, rg_executing, rg_compiling, rg_coording, 
	rg_installed, rg_names, rg_codes, rg_ktype, rg_minargs, rg_maxargs, 
	rg_fd, rg_fdlev, rg_fds, 
	rg_lptr, rg_lbuf, rg_nextshortstr,
	rg_nargs, rg_args, rg_types, 
	rg_inclreg, rg_slices, rg_annuli, rg_nextinst, rg_metacode, 
	rg_eflag

# common variables for region descriptor-specified reference file
common	/regreffilcom/	rg_refimw, rg_refctpix, rg_ref_active
