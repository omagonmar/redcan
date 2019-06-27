#$Header: /home/pros/xray/ximages/imcalc/RCS/imcfunc.h,v 11.0 1997/11/06 16:27:38 prosb Exp $
#$Log: imcfunc.h,v $
#Revision 11.0  1997/11/06 16:27:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:07  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:51  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:39  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:48  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:31  pros
#General Release 1.0
#
#
#	IMCFUNC.H - function codes
#

#
#	define the classes of functions
#
define FUNC_1		1		# 1 arg
define FUNC_2		2		# 2 args
define FUNC_1_2		3		# 1 or two args
define FUNC_N		4		# multiple args
define FUNC_CHT         5               # change type
define PROJ_N		6		# multiple args on proj
define FUNC_CMPLX       7               # functions on complex values
define PROJ_CONST       8               # projections returning a constant

#
#	define the intrinsic functions
#       the hundreds gives the type
#
define FUNC_ABS         101
define FUNC_ACOS	102
define FUNC_AIMAG	703
define FUNC_AREAL       704
define FUNC_ASIN	105
define FUNC_ATAN	306
define FUNC_ATAN1       307            # must be 1 more than ATAN
define FUNC_ATAN2       308            # must be 2 more than ATAN
define FUNC_COMPLEX	509
define FUNC_CONJG	710
define FUNC_COS		111
define FUNC_DOUBLE	512
define FUNC_EXP		113
define FUNC_INT		514
define FUNC_LOG		115
define FUNC_LOG10	116
define FUNC_LONG	517
define FUNC_MAX		418
define FUNC_MIN		419
define FUNC_MOD		220
define FUNC_NINT	121
define FUNC_REAL	522
define FUNC_SHORT	523
define FUNC_SIN		124
define FUNC_SQRT	125
define FUNC_TAN		126
define FUNC_ZERO        127

#
#	define the projections
#

define PROJ_AVG		601
define PROJ_MED		602
define PROJ_LOW		603
define PROJ_HIGH	604
define PROJ_SUM		605
define PROJ_LEN		806
