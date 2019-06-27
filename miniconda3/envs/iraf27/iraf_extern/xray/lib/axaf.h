#$Header: /home/pros/xray/lib/RCS/axaf.h,v 11.0 1997/11/06 16:24:33 prosb Exp $
#$Log: axaf.h,v $
#Revision 11.0  1997/11/06 16:24:33  prosb
#General Release 2.5
#
#Revision 9.3  1996/02/13 15:30:46  prosb
#*** empty log message ***
#
#Revision 9.2  96/02/13  14:48:46  prosb
#JCC - Add new id's for AXAF telescopes and AXAF instruments.
#
#Revision 9.0  1995/11/16  18:25:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:06:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:46:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:02:23  pros
#General Release 1.0
#
#
# AXAF PARAMETERS
#

# the following are assigned and must not be changed:
define AXAF		40			# mission number

#JCC - add new id's for AXAF telescopes
define XRCF_HRMA        80
define SAO_HRC          81
define MIT_CCD          82

# AXAF instruments
define AXAF_HRC		41

#JCC - add new id's for AXAF instruments
define AXAF_HRC_I       42
define AXAF_HRC_I_1     43
define AXAF_HRC_I_2     44
define AXAF_HRC_S       45 
define AXAF_HRC_S_DB    46
define AXAF_HRC_PST     47
define AXAF_HETG        48
define AXAF_HETGS_AS    49
define AXAF_HETGS_AI    60 
define AXAF_HETGS_HS    61 
define AXAF_HETGS_HI    62 
define AXAF_LETG        63 
define AXAF_LETGS_AS    64 
define AXAF_LETGS_AI    65 
define AXAF_LETGS_HS    66 
define AXAF_LETGS_HI    67 
define AXAF_ACIS        68 
define AXAF_ACIS_I      69
define AXAF_ACIS_S      70 
define AXAF_SSD         71 
define AXAF_FPC         72 

# This corresponds to 1/1/1990 0:0:0 and all event seconds for PROS are
#	relative to this time
define AXAF_MJDRDAY			47891.5
define AXAF_MJDRFRAC			0.0
define AXAF_EQUINOX	       		2000.0
define AXAF_EVTREF			0

# AXAF detector dimensions
# faked by multiplying Einstein HRI dims by 4
define AXAF_HRC_DIM			16384
define AXAF_HRC_ARC_SEC_PER_PIXEL	0.5
define AXAF_HRC_PULSE_CHANNELS		0
define AXAF_HRC_DET_DIM			12640
define AXAF_HRC_FOV	       		0.0
# the following comes from DMW, 2/1/89:
# y = 2400.2, z=2121.6 for Einstein HRI
# converted to IRAF coords:
define AXAF_HRC_OPTI_X			9604.8
define AXAF_HRC_OPTI_Y			7901.6
define AXAF_HRC_TANGENT_X		8192
define AXAF_HRC_TANGENT_Y		8192

# AXAF data modes
define AXAF_POINT	0
define AXAF_SLEW	1
define AXAF_NOMODE	2
define AXAF_TRAUMA	3

# define the FITS cordinate system
define  RADECSYS "FK5"
define  CTYPE1 "RA---TAN"
define  CTYPE2 "DEC--TAN"

