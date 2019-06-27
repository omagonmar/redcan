#$Header: /home/pros/xray/xspatial/immd/RCS/mdset.h,v 11.3 2000/01/04 22:29:04 prosb Exp $
#$Log: mdset.h,v $
#Revision 11.3  2000/01/04 22:29:04  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:14  prosb
#General Release 2.2
#
#Revision 5.1  93/04/07  13:37:36  orszak
#jso - changes to add lorentzian model.
#
#Revision 5.0  92/10/29  21:34:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:17  pros
#General Release 1.0
#

define NUM_CODES 15

define MDBOXCAR	1	# boxcar rectangular flat profile function
define MDEXPO	2	# exponential profile function
define MDGAUSS	3	# gaussian profile function
define MDIMPULS	4	# point with no extent
define MDKING	5	# king profile function
define MDPOWER	6	# power profile function
define MDTOPHAT	7	# tophat circular flat profile function
define MDLORENT	8	# lorentzian profile function
define MDPRF_A	10	# point response function
define MDFILE	50	# input user file for function
define MDFUNC	70	# call user routine for function
define MDLOPASS	106	# k space flat profile around origin
define MDHIPASS	107	# k space flat profile away from origin
define MDKFILE	150	# k space input user file
define MDKFUNC	170	# k space call user function

define MD_SZFNAME	128		# maximum name of filename for record
define MD_LEN		70		# length of record to allocate (ints)
define MD_NEXT		Memi[$1]	# pointer to next function
define MD_FUNCTION	Memi[$1+1]	# function code
define MD_VAL		Memr[$1+2]	# value to scale or normalize function
define MD_XCEN		Memr[$1+3]	# x coordinate of function center
define MD_YCEN		Memr[$1+4]	# y coordinate of function center
define MD_FILENAME	Memc[P2C($1+5)]	# file name for MDFILE,MDKFILE
define MD_RADIUS	Memr[$1+5]	# function radius
define MD_SIGMA		Memr[$1+5]	# sigma of gauss, gamma of lorentz
define MD_WIDTH		Memr[$1+5]	# boxcar width
define MD_POWER		Memr[$1+6]	# exponent for king,expo,power
define MD_HEIGHT	Memr[$1+6]	# boxcar height
