#$Header: /home/pros/xray/xdataio/fits2qp/RCS/cards.com,v 11.0 1997/11/06 16:34:25 prosb Exp $
#$Log: cards.com,v $
#Revision 11.0  1997/11/06 16:34:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:34  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:24:16  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:01:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:13:53  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:12  pros
#General Release 1.0
#

# CARDS.COM
#
##


pointer	stp
pointer	typ
pointer pap

common /cards/ stp, typ, pap

