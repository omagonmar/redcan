#$Header: /home/pros/xray/lib/qpcreate/RCS/reg2qp.h,v 11.0 1997/11/06 16:22:14 prosb Exp $
#$Log: reg2qp.h,v $
#Revision 11.0  1997/11/06 16:22:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:08  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:23  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:30  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:45  pros
#General Release 1.0
#
#
#  REG2QP.H -- defines for qpoe data being read through a region mask
#  as input tp qpcreate
#

# define the record structure for the argv argument list
# the user can use argv slots after this for his own purposes
define SZ_REGARGV 2

define	REGIONS	Memi[$1]
define	TITLE	Memi[$1+1]

# length of a qpoe filter expression
define SZ_EXPR 1024

