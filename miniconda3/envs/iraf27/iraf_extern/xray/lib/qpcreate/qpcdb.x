#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcdb.x,v 11.0 1997/11/06 16:21:54 prosb Exp $
#$Log: qpcdb.x,v $
#Revision 11.0  1997/11/06 16:21:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:51  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:14  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:40  pros
#General Release 1.0
#
#
#  QPCDB.X -- user routines to access the qpcreate "data base"
#		i.e., qpcreate.com
#

include "qpcreate.h"

#
#  QPC_TYPE -- return 1 for QPOE, 2 for A3D
#
int procedure qpc_type()
include "qpcreate.com"
begin
	return(otype)
end
