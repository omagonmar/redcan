#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcirecs.x,v 11.0 1997/11/06 16:21:58 prosb Exp $
#$Log: qpcirecs.x,v $
#Revision 11.0  1997/11/06 16:21:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:29  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:03  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:18  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:45  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:18  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:59  pros
#General Release 1.0
#
#
#	QPCIRECS -- determine the number of data records in a data file
#

include <finfo.h>
include <mach.h>
include "qpcreate.h"

procedure qpc_irecs(fname, sizerec, hsize, inrecs)

char	fname[ARB]			# i: file name
int	sizerec				# i: size in chars of a record
int	hsize				# i: size in chars of header
int	inrecs				# o: number of records in file

long	ostruct[LEN_FINFO]		# l: info structure
int	junk				# l: return from finfo()
int	finfo()				# l: get file into

begin
	    # check on the file size
	    junk = finfo(fname, ostruct)
	    inrecs = ((FI_SIZE(ostruct)/SZB_CHAR) - hsize)/sizerec
end

