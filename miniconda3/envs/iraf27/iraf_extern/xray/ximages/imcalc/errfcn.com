#$Header: /home/pros/xray/ximages/imcalc/RCS/errfcn.com,v 11.0 1997/11/06 16:26:59 prosb Exp $
#$Log: errfcn.com,v $
#Revision 11.0  1997/11/06 16:26:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:34  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:18  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:40  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:00  pros
#General Release 1.0
#
#
#  ERRFCN.COM -- store value for error return
#
real errfcn
common/errfcncom/errfcn
