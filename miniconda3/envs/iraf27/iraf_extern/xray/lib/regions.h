#$Header: /home/pros/xray/lib/RCS/regions.h,v 11.0 1997/11/06 16:25:36 prosb Exp $
#$Log: regions.h,v $
#Revision 11.0  1997/11/06 16:25:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:37  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/19  15:01:13  dennis
#Added reference file/coordinate system type codes.
#
#Revision 8.0  94/06/27  13:43:17  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:05  prosb
#General Release 2.2
#
#Revision 5.1  93/04/26  23:27:44  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:23:08  prosb
#General Release 2.1
#
#Revision 4.2  92/09/29  20:59:57  dennis
#Defined new keyword codes CONTOUR, REFFILE
#Commented out define EQUATO 48 -- gets overridden by xyacc's definition
#Improved comments
#
#Revision 4.1  92/08/07  17:15:24  dennis
#(No change; intended changes were moved to regparse.h)
#
#Revision 4.0  92/04/27  14:06:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  09:25:17  mo
#ADD comment symbol
#
# * Revision 3.0  91/08/02  00:46:50  prosb
# * General Release 1.1
# * 
#Revision 2.0  91/03/07  00:14:33  pros
#General Release 1.0
#
#
# reference file or coordinate system type codes
#
define REFTY_PL	0
define REFTY_PM	1
define REFTY_QP	2
define REFTY_IM	3
#
# region (etc.) codes set into table in rg_defkeywords(), in regacts.x
#
define MAX_RGKEYWORDS 17	# number of entries in table

define ANNULUS  20
define BOX      21
define CIRCLE   22
define ELLIPSE  23
define FIELD    24
define FILENAME 25
define PIE      26
define POINT    27
define POLYGON  28
define ROTBOX   29
define COMPOUND 30

# Coordinate system token numbers John : Oct 89
#
define NONE	 39

include <precess.h>		# Get expected #'s for coords/precess.x

define EQUIX	46
# define EQUATO	48		# (Gets overridden by xyacc's definition)

# Pixel system code numbers
#
define RELA     50
define LOGI     51
define PHYS     52

define REFFILE	55

# CONTOUR code number	(Dennis, September 1992)
#
define CONTOUR	60

# Boolean operations on plio areas
#
define	OP_NOT		1
define	OP_AND	        2
define	OP_OR		3
define  OP_XOR          4

# size of plio title
define SZ_MASKTITLE 8192
