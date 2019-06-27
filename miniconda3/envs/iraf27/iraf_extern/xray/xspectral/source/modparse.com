#$Header: /home/pros/xray/xspectral/source/RCS/modparse.com,v 11.0 1997/11/06 16:42:54 prosb Exp $
#$Log: modparse.com,v $
#Revision 11.0  1997/11/06 16:42:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:37  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:05:25  pros
#General Release 1.0
#
#
# The spectral model parser common
#
int	mod_fp					# frame pointer
int	mod_nmodels				# number of models

int	mod_frame				# call frame number
real	mod_lower[MAX_ARGS, MAX_CALLS]		# model lower bounds
real	mod_upper[MAX_ARGS, MAX_CALLS]		# model upper bounds
int	mod_types[MAX_ARGS, MAX_CALLS]		# model argument types
int	mod_fixed[MAX_ARGS, MAX_CALLS]		# model arg free/fixed flag
int	mod_links[MAX_ARGS, MAX_CALLS]		# model arg links
int	mod_link				# next available link number

int	mod_nargs[MAX_CALLS]			# number of args per frame

int 	mod_fd					# current file descriptor
int	mod_fds[MAX_NESTS]			# pushed file descriptors
int	mod_fdlev				# next available fd spot
int	mod_sfd					# save cpu fd

char	mod_lbuf[SZ_LINE]			# line being parsed
int	mod_lptr				# current lptr into line
pointer	mod_sbuf				# temp string buffer
pointer mod_nextch				# next char in string buffer

int	mod_strings[MAX_MODDEFS+1]		# pointers to region names
int	mod_codes[MAX_MODDEFS+1]		# array of function codes
int	mod_minargs[MAX_MODDEFS+1]		# min args for reg
int	mod_maxargs[MAX_MODDEFS+1]		# max args for reg
int	mod_installed				# last model installed

int	mod_namelen				# size of plio name buffer
pointer	mod_allnames				# pointer to plio str
pointer	mod_name				# current region name

int	mod_eflag				# flag that an error occured
int	mod_tflag				# temp plio number

int	mod_debug				# global debug flag

common	/regcom/ mod_fp, mod_nmodels,
	mod_frame, mod_lower, mod_upper, mod_types, mod_fixed, mod_links,
	mod_link, mod_nargs,
	mod_fd, mod_fds, mod_fdlev, mod_sfd,
	mod_lptr, mod_lbuf, mod_sbuf, mod_nextch,
	mod_allnames, mod_codes, mod_minargs, mod_maxargs, mod_installed,
	mod_namelen, mod_strings, mod_name,
	mod_eflag, mod_tflag,
	mod_debug

