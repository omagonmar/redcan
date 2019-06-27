#$Header: /home/pros/xray/lib/pros/RCS/xhead.com,v 11.0 1997/11/06 16:21:21 prosb Exp $
#$Log: xhead.com,v $
#Revision 11.0  1997/11/06 16:21:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:18  prosb
#General Release 2.3
#
#Revision 6.1  93/05/24  17:06:32  prosb
#Added newline at end of file 
#(complained about this during RCS update).
#
#Revision 6.0  93/05/24  15:54:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:26  wendy
#General
#
#Revision 2.0  91/03/07  00:07:51  pros
#General Release 1.0
#
# xhead.com -- common for general header routines

int	xheadtype			# type of header
char	xparam[SZ_LINE]			# translated param name for FITS
char	xcomment[SZ_LINE]		# comment for FITS
common/xheadcom/xheadtype, xparam, xcomment

