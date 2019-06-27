#$Header: /home/pros/xray/xspatial/immodel/RCS/pixlex.com,v 11.0 1997/11/06 16:30:25 prosb Exp $
#$Log: pixlex.com,v $
#Revision 11.0  1997/11/06 16:30:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:07  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:30:56  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:23  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:31  pros
#General Release 1.0
#
#
# common block for lexical analyzer and anyone else who needs it
#
char	lbuf[SZ_LINE]		# current line
int	lptr			# current index into line
common /pixlexcom/lbuf, lptr

