#$Header: /home/pros/xray/xdataio/datarep/RCS/datarep.com,v 11.0 1997/11/06 16:33:54 prosb Exp $
#$Log: datarep.com,v $
#Revision 11.0  1997/11/06 16:33:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:31  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:16  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:13  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:35:44  pros
#General Release 1.0
#
# datarep common block
#


pointer	ip		# Current code space
pointer	file		# pointer to the file stack
