#$Header: /home/pros/xray/xspatial/imcnts/RCS/imcnts.h,v 11.0 1997/11/06 16:32:47 prosb Exp $
#$Log: imcnts.h,v $
#Revision 11.0  1997/11/06 16:32:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:09  prosb
#General Release 2.2
#
#Revision 5.1  93/04/27  00:18:29  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:33:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:41:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/04  01:02:36  dennis
#New type MATCHED to allow matching background regions to source regions
#
#Revision 3.0  91/08/02  01:27:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:38  pros
#General Release 1.0
#
#
#  imcnts.h -- include file for imcnts.x, imcntsubs.x
#

# define possible relationships between source and bkgd file
define NO_SOURCE 0
define SAME_SAME 1
define SAME_OTHER 2
define OTHER_SAME 3
define OTHER_OTHER 4
define CONSTANT_BKGD 5
define MATCHED 6

# define max number of table columns
define  MAX_CP 15

# define table column
define	SIGNAL_CP	$1[1]
define	BKGD_CP		$1[2]
define	SOURCE_CP	$1[3]
define	ERROR_CP	$1[4]
define	BERROR_CP	$1[5]
define	PIXELS_CP	$1[6]
define	CTSPIXEL_CP	$1[7]
define	ERRPIXEL_CP	$1[8]
define	REGIONS_CP	$1[9]
define	RAD1_CP		$1[10]
define	RAD2_CP		$1[11]
define	ANG1_CP		$1[12]
define	ANG2_CP		$1[13]
define  PROFILE_CP	$1[14]
define  NSTRING_CP	$1[15]
