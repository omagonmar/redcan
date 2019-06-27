#$Header: /home/pros/xray/xplot/imcontour/RCS/clevels.h,v 11.0 1997/11/06 16:38:00 prosb Exp $
#$Log: clevels.h,v $
#Revision 11.0  1997/11/06 16:38:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:40  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/12/12  11:45:22  janet
#added definition for 'LIN'.
#
#Revision 3.0  91/08/02  01:23:54  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:05:14  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:20:31  pros
#General Release 1.0
#
#
# CLEVELS.H -- definitions for contour level set parsing
#
define  PIXELS		0
define  PEAK		1
define  SIGMA		2

define  LEVELS		0
define  LINEAR		1
define  LOG		2
define  LIN		3

define  LO              3
define  HI              2
define  STEPS           1


# ----------------------------------------------------------------

define	LEN_CLEVELS	104			# size of structure

define  UNITS		Memi[$1]		# units code
define  FUNC		Memi[$1+1]           	# function code 
define	NUM_PARAMS	Memi[$1+2]		# num args
define	PARAMS		Memr[$1+2+$2]		# parameter list

