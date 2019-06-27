#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcreate.com,v 11.0 1997/11/06 16:22:03 prosb Exp $
#$Log: qpcreate.com,v $
#Revision 11.0  1997/11/06 16:22:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:35  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:19  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:28:25  mo
#MC/JM	12/22/93	Update for auto EVENTDEF copy
#
#Revision 5.0  92/10/29  21:18:58  prosb
#General Release 2.1
#
#Revision 4.1  92/10/05  12:49:30  jmoran
#JMORAN changed nmacros from pointer to int
#
#Revision 4.0  92/04/27  13:52:36  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:15  pros
#General Release 1.0
#
#
#	qpcreate.com - common for qpcreate
#	some of this is here because zcall allows only 9 args max and
#	we can't pass all args by calling sequence
#

int	qpcdb				# dummy for start of data base
pointer	file				# file structure
int	nfiles				# number of files in struct
pointer	getparam			# get parameter routine
pointer	hist				# write history routine
pointer	grand_finale			# grand finale routine
int	otype				# A3DFITS or QPOE
int	inrecs				# number of records in data file
int	oevtype				# event type -- se qpoe.h
int	oevsize				# output qpoe event size in SPP shorts
int	revsize				# rounded size in bytes of event record
int	sort				# YES if we sort
pointer	sortstr				# sort to do or done
int	sortsize			# max events in a sort buffer
pointer	sortname			# pointer to names to be sorted
pointer	sortcmp				# pointer to compare routines for sort
pointer	sortoff				# pointer to offsets for sort
pointer	sorttype			# pointer to types of elements sorted
pointer	nsort				# number of sort routines
pointer	prosdef_in			# PROS event def for input file
pointer prosdef_out			# PROS event def for output file
pointer	irafdef_in			# IRAF event def for output file
pointer irafdef_out			# IRAF event def for output file
pointer	msymbols			# array of macro symbol names
pointer	mvalues				# array of macro symbol values
int	nmacros				# number of macros

common/qpcdbcom/qpcdb, file, nfiles, getparam, hist, grand_finale,
		otype, inrecs, oevtype, oevsize, revsize,
		sort, sortstr, sortsize,
		sortname, sortcmp, sortoff, sorttype, nsort,
		prosdef_in, prosdef_out, irafdef_in, irafdef_out, 
		msymbols, mvalues, nmacros
