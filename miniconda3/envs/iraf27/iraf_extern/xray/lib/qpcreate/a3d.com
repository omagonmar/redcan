#$Header: /home/pros/xray/lib/qpcreate/RCS/a3d.com,v 11.0 1997/11/06 16:21:23 prosb Exp $
#$Log: a3d.com,v $
#Revision 11.0  1997/11/06 16:21:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:55:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:06  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:11  pros
#General Release 1.0
#
#
# A3D.COM - common block for a3d tables
#

int	a3dcol				# column number
int	a3dmaxcol			# expected # of columns
common/a3dtabcom/a3dcol, a3dmaxcol
