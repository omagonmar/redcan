#$Header: /home/pros/xray/lib/RCS/qpc.h,v 11.0 1997/11/06 16:25:12 prosb Exp $
#$Log: qpc.h,v $
#Revision 11.0  1997/11/06 16:25:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:58  prosb
#General Release 2.2
#
#Revision 5.1  93/04/12  15:03:38  jmoran
#*** empty log message ***
#
#Revision 5.0  92/10/29  21:23:03  prosb
#General Release 2.1
#
#Revision 4.1  92/10/05  14:40:38  jmoran
#JMORAN added support for argv structure in qp_create
#
#Revision 4.0  92/04/27  14:06:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  15:32:53  mo
#MC	4/13/92		Extend the ARGV structure so that the TITLE
#			string and the REGSUM strings can be separated
#
#Revision 3.0  91/08/02  00:46:48  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:03:51  pros
#General Release 1.0
#
#
#  QPC.H -- defines for qpcreate that the user should know about
#

# define the types of files we can make with this qpcreate
define	QPOE		1
define  A3D		2

# define the record structure for the argv argument list
# the user can use argv slots after this for her own purposes
#
# NOTE: Please ensure that this variable is always even so byte
# alignment/boundary problems don't occur
define SZ_DEFARGV 16

define	REGIONS		Memi[($1)+0]
define	TITLE		Memi[($1)+1]
define  REGSUM		Memi[($1)+2]
define  EXPOSURE        Memi[($1)+3]
define  THRESH		Memr[($1)+4]

define	IN_MSYM		Memi[($1)+5]
define  IN_MVAL         Memi[($1)+6]
define  IN_MNUM         Memi[($1)+7]
define	IB_START	Memi[($1)+8]
define	OB_START        Memi[($1)+9]
define  SWAP_LEN        Memi[($1)+10]
define  IN_F_TO_L       Memb[($1)+11]
define  IN_L_TO_F       Memb[($1)+12]

define	SWAP_CNT	Memi[($1)+13]
define  SWAP_PTR        Memi[($1)+14]

# length of a qpoe filter expression
define SZ_EXPR 1024

# define the max number of channels
define MAX_ICHANS	32
