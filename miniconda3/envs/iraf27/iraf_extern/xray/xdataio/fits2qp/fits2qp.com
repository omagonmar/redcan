#$Header: /home/pros/xray/xdataio/fits2qp/RCS/fits2qp.com,v 11.0 1997/11/06 16:34:26 prosb Exp $
#$Log: fits2qp.com,v $
#Revision 11.0  1997/11/06 16:34:26  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:37  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:32:26  dvs
#Added fields evext, evfields, evotype, evitype to common variables.
#Fixed minor bug: qpoename should be SZ_CARDVSTR, not SZ_KEY.
#
#Revision 8.0  94/06/27  15:20:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:40  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:24:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:36  prosb
#General Release 2.1
#
#Revision 4.3  92/09/23  11:19:15  jmoran
#JMORAN - added tfields for MPE ASCII FITS
#
#Revision 4.2  92/07/13  11:03:13  jmoran
#*** empty log message ***
#
#Revision 4.1  92/07/07  17:25:20  jmoran
#JMORAN Changed SZ_LINE to SZ_TYPEDEF for two strings
#
#Revision 4.0  92/04/27  15:01:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:13:54  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:21  pros
#General Release 1.0
#
#
#  FITS2QP.COM
#
int	naxis				# number of image axes in FITS
int	tnaxis				# total dimensions of image (to skip)
int	naxlen				# number of qpoe axes
int	axlen1				# dim. of axlen 1
int	axlen2				# dim. of axlen 2
int	bitpix				# bits/pixel
int	tfields				# number of ext records
int	evpos				# position at which event start
int	evnrecs				# number of records in extension
int	evbytes				# number of bytes per column
int	evfptr				# pointer to start of event data
int	evfields			# number of fields in event record
int	pagesize			# qpoe pagesize
int	bucketlen			# qpoe bucketlen
int	blockfactor			# default imio block factor
int	debug				# qpoe debug level
bool	mkindex				# true if we make an index
bool	qpoe				# flag to use QPOENAME key for output
pointer evext				# EXT structure for event record
pointer fitwcs
char	evname[SZ_LINE]			# name of event table
char	evitype[SZ_TYPEDEF]		# extension type definition (input)
char	evotype[SZ_TYPEDEF]		# extension type definition (output)
char	prostype[SZ_TYPEDEF]		# pros event type definition
char	key[SZ_KEY]			# key for qpoe index
char	qpoename[SZ_CARDVSTR]		# name for output qpoe file

common/fits2qpcom/naxis, tnaxis, naxlen, axlen1, axlen2,
		  bitpix, tfields, evpos, evnrecs, evbytes, 
		  evfptr, evfields, pagesize, bucketlen, blockfactor,
		  debug, mkindex, qpoe, evext, fitwcs, evname, 
		  evitype, evotype, prostype, key, qpoename
