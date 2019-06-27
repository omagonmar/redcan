#$Header: /home/pros/xray/lib/RCS/rosat.h,v 11.0 1997/11/06 16:24:44 prosb Exp $
#$Log: rosat.h,v $
#Revision 11.0  1997/11/06 16:24:44  prosb
#General Release 2.5
#
#Revision 9.1  1996/02/13 15:26:47  prosb
#*** empty log message ***
#
#Revision 9.0  95/11/16  18:25:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:18  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  11:44:23  mo
#MC	5/20/93		Eliminate duplicate 'qpcreate/argv' definitions
#
#Revision 5.0  92/10/29  21:23:19  prosb
#General Release 2.1
#
#Revision 4.2  92/10/14  17:03:05  mo
#MC	10/14/92		Added corrected ROSAT tangent points
#
#Revision 4.1  92/10/11  16:39:50  mo
#JM/MC	10/11/92		Update the MJDRDAY to correct time
#					This is needed for MPE files
#
#Revision 4.0  92/04/27  14:07:17  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  15:33:46  mo
#MC	4/13/92		Update the argv structure definition with
#			the new deffault ( with REGSUM) then the
#			special additional elements
#
#Revision 3.0  91/08/02  00:46:53  prosb
#General Release 1.1
#
#Revision 2.2  91/08/01  21:50:33  mo
#MC	8/1/91		Add PSPC2 code, MIN and MAX energy channel
#
#Revision 2.1  91/04/16  16:08:24  mo
#MC	4/16/91		Added new parameters for input ROSAT FILTER and SEQ_PI
#
#Revision 2.0  91/03/07  00:04:03  pros
#General Release 1.0
#
#
# Module:       ROSAT.H
# Project:      PROS -- ROSAT RSDC
# Purpose:      Define ROSAT parameters for QPOE header, however, whenever
#		possible these will be acquired from the individual observation
#		input files
# External:     NONE
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm	  -- initial version	-- 1988
#               {1} mc    -- add support for detector coords  -- 1/91
#               {n} <who> -- <does what> -- <when>
#

#
# ROSAT PARAMETERS
#

# the following are assigned and must not be changed:
define ROSAT		20			# mission number
# ROSAT instruments
define ROSAT_HRI	21
define ROSAT_PSPC	22
define ROSAT_WFC	23

define HRI_CODE         3
define PSPC_CODE        1
define PSPC2_CODE       2 

## This corresponds to 1/1/1990 0:0:0 and all event seconds for PROS are
##	relative to this time
# This corresponds to Day 152/21:06:50.2 which is the current value for
#       S/C start time - and all ROSAT time is relative to this number
#define ROSAT_MJDRDAY			47892
#define ROSAT_MJDRFRAC			0.879747685D0
# These values are used for the MPE ASCII fits reader
define ROSAT_MJDRDAY                  	48043 
define ROSAT_MJDRFRAC                 	0.879745370370D0

define ROSAT_EQUINOX	       		2000.0
define ROSAT_EVTREF			0

# ROSAT detector dimensions
define ROSAT_HRI_DIM			8192
define ROSAT_HRI_PULSE_CHANNELS		16
define ROSAT_HRI_DET_DIM		4096
define ROSAT_HRI_INSTPXX		.6E0	
define ROSAT_HRI_INSTPXY		.6E0	
define ROSAT_HRI_FOV	       		0.0
# NB: THESE ARE EINSTEIN HRI VALUES AND MUST BE CHANGED WHEN WE KNOW
#THE REAL VALS
# the following comes from DMW e-mail, 2/1/89:
# y = 4448.2, z=4169.6
# converted to IRAF coords:
define ROSAT_HRI_OPTI_X			4449.2
define ROSAT_HRI_OPTI_Y			4022.4
# NB: CHANGE THESE WHEN THE REAL VALUES ARE AVAILABLE
#  The 'ROS' values are from Rev 0, and are incorrect
define ROS_HRI_TANGENT_X		4096.0D0
define ROS_HRI_TANGENT_Y		4096.0D0
#  Corrected for REV 1 processing 10/11/92
define ROSAT_HRI_TANGENT_X		4096.0D0
define ROSAT_HRI_TANGENT_Y		4097.0D0

define ROSAT_PSPC_DIM			15360
define ROSAT_PSPC_PULSE_CHANNELS	256
define ROSAT_PSPC_DET_DIM		8192	
define ROSAT_PSPC_INSTPXX		.934077	
define ROSAT_PSPC_INSTPXY		.934077	
define ROSAT_PSPC_FOV	       		0.0
# NB: THESE ARE EINSTEIN HRI VALUES AND MUST BE CHANGED WHEN WE KNOW
#THE REAL VALS
# the following comes from DMW e-mail, 2/1/89:
# y = 4448.2, z=4169.6
# converted to IRAF coords:
#define ROSAT_PSPC_OPTI_X		4449.2
#define ROSAT_PSPC_OPTI_Y		4022.4
# NB: CHANGE THESDE WHEN THE REAL VALUES ARE AVAILABLE
#  The 'ROS' values are from Rev 0, and are incorrect
define ROS_PSPC_TANGENT_X		7680.0D0
define ROS_PSPC_TANGENT_Y		7680.0D0
define ROSAT_PSPC_TANGENT_X		7681.0D0
define ROSAT_PSPC_TANGENT_Y		7681.0D0

# ROSAT data modes
define ROSAT_POINT	0
define ROSAT_SLEW	1
define ROSAT_NOMODE	2
define ROSAT_TRAUMA	3

# define the FITS cordinate system
define  RADECSYS "FK5"
define  CTYPE1 "RA---TAN"
define  CTYPE2 "DEC--TAN"

# define the country in which the data is processed
define  COUNTRY "USA"

#
#  define the structure of the ROSAT HRI header
#
define	R_KEYNO			Memi[($1)+0]
define  R_NOM_RA		Memi[($1)+20]
define  R_NOM_DEC		Memi[($1)+21]
define	R_NOM_ROLL		Memi[($1)+22]
define	R_SEQ_BEG		Memi[($1)+23]
define	R_SEQ_END		Memi[($1)+24]
define	R_SEQ_TIT		Memi[($1)+25]
define	R_PROP_ID		Memi[($1)+45]
define	R_SEQ_PI		Memi[($1)+46]
define  R_DETECTOR		Memi[($1)+66]
define	R_BINNED_RA		Memr[($1)+67]
define	R_BINNED_DEC		Memr[($1)+68]
define	R_BINNED_ROLL		Memr[($1)+69]
define	R_OPTICAL_AXIS_X	Memd[P2D(($1)+70)]
define	R_OPTICAL_AXIS_Y	Memd[P2D(($1)+72)]
define  R_BKDEN			Memr[($1)+74]
define	R_INSTPXX		Memr[($1)+75]
define	R_INSTPXY		Memr[($1)+76]
define	R_ARCSECS_PER_PIXEL	Memr[($1)+77]
define	R_POE_CENTER		Memd[P2D(($1)+78)]
define	R_POE_CENTER_X		Memd[P2D(($1)+78)]
define	R_POE_CENTER_Y		Memd[P2D(($1)+80)]
#define	R_OPTICAL_AXIS		Memd[P2D(($1)+80)]
define	R_X_POE_SIZE		Memi[($1)+82]
define	R_Y_POE_SIZE		Memi[($1)+83]
define	R_X_DETECTOR_SIZE	Memi[($1)+84]
define	R_Y_DETECTOR_SIZE	Memi[($1)+85]
#  SC_CLOCK values moved to end of structure to allow expansion of 
#     seconds to DP   12/18/90  Detector Optical Axis replaced them
define	R_OPTICAL_AXIS_DX	Memd[P2D(($1)+86)]
define	R_OPTICAL_AXIS_DY	Memd[P2D(($1)+88)]
#define	R_DUMMY2		Memi[($1)+90]
define	R_FILTER		Memi[($1)+90]
define	R_VARIABLE_LFT		Memi[($1)+91]
define	R_ONTIME_FOR_LIVETIME	Memr[($1)+92]
define	R_LIVE_TIME		Memr[($1)+93]
define	R_LIVE_TIME_CORR	Memr[($1)+94]
define	R_MAX_LTF		Memr[($1)+95]
define	R_MIN_LTF		Memr[($1)+96]
define	R_DUMMY3		Memr[($1)+97]
define	R_AVG_ASP_X_OFF		Memd[P2D(($1)+98)]
define	R_AVG_ASP_Y_OFF		Memd[P2D(($1)+100)]
define	R_AVG_ASP_ROLL		Memd[P2D(($1)+102)]
define	R_FIRST_SC_OBI_START	Memd[P2D(($1)+104)]
define	R_FIRST_JD_OBI_START	Memd[P2D(($1)+106)]
define	R_LAST_SC_OBI_STOP	Memd[P2D(($1)+108)]
define	R_LAST_UT_OBI_STOP	Memd[P2D(($1)+110)]
#  Moved to end of structure to allow expansion of seconds to DP   12/18/90
define	R_SC_CLOCK_SECOND	Memd[P2D(($1)+112)]
define	R_SC_CLOCK_MINUTE	Memi[($1)+114]
define	R_SC_CLOCK_HOUR		Memi[($1)+115]
define	R_SC_CLOCK_DAY		Memi[($1)+116]
define	R_SC_CLOCK_YEAR		Memi[($1)+117]
define	R_MIN_CHAN		Memi[($1)+118]
define  R_MAX_CHAN		Memi[($1)+119]

#  Optional, used only for ARRAYS
define  R_BSCALE		Memr[($1)+130]
define  R_BZERO			Memr[($1)+131]

# define the record structure for the argv argument list
# this is used by rhead2qp and toe2qp
###  This should now be replaced by QPC.H
define	SZ_ROSATARGV	SZ_DEFARGV+4
#define	REGIONS	Memi[($1)]
#define	TITLE	Memi[($1)+1]
#define	EXPOSURE	Memi[($1)+2]
#define  THRESH   Memi[($1)+3]
#define  REGSUM	Memi[($1)+4]
#define  CLEAN	Memi[$1+5]
#define  INST	Memi[$1+6]
define  CLEAN   Memi[$1+SZ_DEFARGV+1]
define  INST    Memi[$1+SZ_DEFARGV+2]
#
