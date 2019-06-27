#$Header: /home/pros/xray/xdataio/qpaddaux/RCS/qpaddaux.x,v 11.0 1997/11/06 16:35:50 prosb Exp $
#$Log: qpaddaux.x,v $
#Revision 11.0  1997/11/06 16:35:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:42:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:26:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:32:42  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:02:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:14:05  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:14  pros
#General Release 1.0
#
#
# QPADDAUX.X -- add auxiliary data to a qpoe file
# This routine just calls the qpaddaux routine in lib$qpcreate
#

procedure t_qpaddaux()

begin
	call qpcaddaux()
end
