#$Header: /home/pros/xray/ximages/imcalc/RCS/lex.com,v 11.0 1997/11/06 16:27:42 prosb Exp $
#$Log: lex.com,v $
#Revision 11.0  1997/11/06 16:27:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:00  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:18  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:50  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:43  pros
#General Release 1.0
#
#
# common block for lexical analyzer and anyone else who needs it
#
char	lbuf[SZ_LINE]		# current line
int	lptr			# current index into line
common /lexcom/lbuf, lptr

