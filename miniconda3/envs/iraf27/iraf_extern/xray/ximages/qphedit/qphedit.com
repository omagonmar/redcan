#$Header: /home/pros/xray/ximages/qphedit/RCS/qphedit.com,v 11.0 1997/11/06 16:28:42 prosb Exp $
#$Log: qphedit.com,v $
#Revision 11.0  1997/11/06 16:28:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:27:00  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:30:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:39  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:26  pros
#General Release 1.0
#
# qphedit.com -- common block of flags needed for qpoe processing
int	isqpoe				# YES if its a qpoe file
int	qpupdate			# YES if we update a qpoe file
common/qphedcom/isqpoe, qpupdate
