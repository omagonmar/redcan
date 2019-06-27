#$Header: /home/pros/xray/xplot/imcontour/RCS/clevels.com,v 11.0 1997/11/06 16:38:00 prosb Exp $
#$Log: clevels.com,v $
#Revision 11.0  1997/11/06 16:38:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:23:53  prosb
#General Release 1.1
#
#Revision 1.1  91/07/25  17:47:24  janet
#Initial revision
#
#Revision 2.0  91/03/06  23:20:29  pros
#General Release 1.0
#
pointer  	sptr

common /clevptr/ sptr
