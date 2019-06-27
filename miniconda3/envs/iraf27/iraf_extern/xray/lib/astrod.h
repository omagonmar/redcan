#$Header: /home/pros/xray/lib/RCS/astrod.h,v 11.0 1997/11/06 16:24:42 prosb Exp $
#$Log: astrod.h,v $
#Revision 11.0  1997/11/06 16:24:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:42  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:26:01  mo
#Update for RDF
#
#Revision 6.0  93/05/24  15:36:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:36  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:06:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:46:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:02:20  pros
#General Release 1.0
#
#
# ASTRO-D PARAMETERS
#

# the following are assigned and must not be changed:
define ASTROD		30
define ASUKA		30
define ASCA		30

# ASTROD instruments
define ASTROD_SIS	31
define ASTROD_GIS	32

# This corresponds to 1/1/1978 0:0:0 and all event seconds for PROS are
#	relative to this time
define ASTROD_MJDRDAY			43509.0
define ASTROD_MJDRFRAC			0.0
define ASTROD_EQUINOX	       		2000.0
define ASTROD_EVTREF			0

# detector dimensions
define ASTROD_SIS_XDIM			840
define ASTROD_SIS_YDIM			844
define ASTROD_SIS_ARC_SEC_PER_PIXEL	1.6
define ASTROD_SIS_PULSE_CHANNELS	4096
define ASTROD_SIS_DET_XDIM		840
define ASTROD_SIS_DET_YDIM		844
define ASTROD_SIS_FOV	       		0.0
define ASTROD_SIS_OPTI_X		420
define ASTROD_SIS_OPTI_Y		422
define ASTROD_SIS_TANGENT_X		420
define ASTROD_SIS_TANGENT_Y		422

# Astrod data modes
define ASTROD_POINT	0
define ASTROD_SLEW	1
define ASTROD_NOMODE	2
define ASTROD_TRAUMA	3

# define the FITS cordinate system
define  RADECSYS "FK5"
define  CTYPE1 "RA---TAN"
define  CTYPE2 "DEC--TAN"


