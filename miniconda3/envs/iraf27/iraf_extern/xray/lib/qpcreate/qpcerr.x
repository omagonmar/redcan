#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcerr.x,v 11.0 1997/11/06 16:21:56 prosb Exp $
#$Log: qpcerr.x,v $
#Revision 11.0  1997/11/06 16:21:56  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:50  pros
#General Release 1.0
#
#
#	QPCERR.X -- error routines
#

include "qpcreate.h"

#
# QPC_MISSINGPROC -- give "missing procedure" error
#
procedure qpc_missingproc(s)

char	s[ARB]
char	tbuf[SZ_LINE]

begin
	call printf(tbuf, SZ_LINE, "Missing qpcreate procedure:\t%s")
	call pargstr(s)
	call error(1, s)
end

