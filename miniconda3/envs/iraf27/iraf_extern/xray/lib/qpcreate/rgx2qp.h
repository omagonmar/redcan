#$Header: /home/pros/xray/lib/qpcreate/RCS/rgx2qp.h,v 11.0 1997/11/06 16:22:16 prosb Exp $
#$Log: rgx2qp.h,v $
#Revision 11.0  1997/11/06 16:22:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:13  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:28  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:22  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:48  pros
#General Release 1.0
#
#
#  RGX2QP.H -- defines for qpoe data being read through a region mask
#  and exposure mask as input to qpcreate
#

# define the record structure for the argv argument list
# the user can use argv slots after this for his own purposes
define SZ_RGXARGV 4

define	REGIONS		Memi[$1]
define	TITLE		Memi[($1)+1]
define  EXPOSURE        Memi[($1)+2]
define  THRESH		Memr[($1)+3]

# length of a qpoe filter expression
define SZ_EXPR 1024

