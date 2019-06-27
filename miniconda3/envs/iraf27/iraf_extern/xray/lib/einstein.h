#$Header: /home/pros/xray/lib/RCS/einstein.h,v 11.0 1997/11/06 16:24:57 prosb Exp $
#$Log: einstein.h,v $
#Revision 11.0  1997/11/06 16:24:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:53  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:36  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:46  prosb
#General Release 2.1
#
#Revision 4.2  92/10/14  17:00:36  mo
#MC	10/14/92		Added corrected Einstein Tangent Pixels
#
#Revision 4.1  92/08/27  11:23:57  mo
#MC		7/13/92		COrrect the Einstein reference start day
#
#Revision 4.0  92/04/27  14:06:27  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/10/11  09:45:41  jmoran
#Changed EINSTEIN_HRI_PULSE_CHANNELS from 0 to 16
#
#Revision 3.0  91/08/02  00:46:24  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:02:26  pros
#General Release 1.0
#
#
# EINSTEIN PARAMETERS
#

# the following are assigned and must not be changed:
define EINSTEIN		10			# mission number

# Einstein instruments
define EINSTEIN_HRI	11
define EINSTEIN_FPCS	12
define EINSTEIN_IPC	13
define EINSTEIN_SSS	14
define EINSTEIN_MPC	15

# This corresponds to 1/1/1978 0:0:0 and all event seconds for PROS are
#	relative to this time
#define EINSTEIN_MJDRDAY			43509.0
# This corresponds to day 0 of 1978, which is the correct reference
#   ( changed 7/13/92 )
define EINSTEIN_MJDRDAY			43508.0
define EINSTEIN_MJDRFRAC		0.0
define EINSTEIN_EQUINOX	       		1950.0
define EINSTEIN_EVTREF			0

# Einstein detector dimensions
define EINSTEIN_HRI_DIM			4096
define EINSTEIN_HRI_ARC_SEC_PER_PIXEL	0.5
define EINSTEIN_HRI_PULSE_CHANNELS	16
define EINSTEIN_HRI_DET_DIM		3160
define EINSTEIN_HRI_FOV	       		0.0
# the following comes from DMW, 2/1/89:
# y = 2400.2, z=2121.6
# converted to IRAF coords:
define EINSTEIN_HRI_OPTI_X		2401.2
define EINSTEIN_HRI_OPTI_Y		1975.4
#  The 'EIN' values are incorrect but used until 10/11/92 / Rev 2.1 PROS
define EIN_HRI_TANGENT_X		2048
define EIN_HRI_TANGENT_Y		2048
define EINSTEIN_HRI_TANGENT_X		2048
define EINSTEIN_HRI_TANGENT_Y		2049

define EINSTEIN_IPC_DIM			1024
define EINSTEIN_IPC_ARC_SEC_PER_PIXEL	8.0
# we compress 32 channels into 16
define EINSTEIN_IPC_PULSE_CHANNELS	16
define EINSTEIN_IPC_DET_DIM		1024
define EINSTEIN_IPC_FOV	       		0.0
# the following comes from Mo, 2/16/89:
# y = 508.5, z=499.3
# converted to IRAF coords:
define EINSTEIN_IPC_OPTI_X		509.5
define EINSTEIN_IPC_OPTI_Y		524.7
#  The 'EIN' values are incorrect but used until 10/11/92 / Rev 2.1 PROS
define EIN_IPC_TANGENT_X		512
define EIN_IPC_TANGENT_Y		512
define EINSTEIN_IPC_TANGENT_X		512
define EINSTEIN_IPC_TANGENT_Y		513

# Einstein data modes
define EINSTEIN_POINT	0
define EINSTEIN_SLEW	1
define EINSTEIN_NOMODE	2
define EINSTEIN_TRAUMA	3

# bit value to mask to get inst from uhead
define EINSTEIN_INSTMASK 2
# bit value to mask to get sub-inst from uhead
define EINSTEIN_MODEMASK (4+8)
define EINSTEIN_FILTMASK (256+512)
define EINSTEIN_SUBMASK (4096+8192)

# define the FITS cordinate system
define  RADECSYS "FK4"
define  CTYPE1 "RA---TAN"
define  CTYPE2 "DEC--TAN"

#
# The Universal Header
#
define SZ_UHEAD 256

#
# define offsets (starting from 1) of uhead
# to use this, read the uhead into a short array of dim SZ_UHEAD
# real values must be moved with amovr, etc.
#

define U_DATATYPE	$1[1]
define U_GZOOMTYPE	$1[3]
define U_STARTYEAR	$1[4]
define U_STARTDAY	$1[6]
define U_STARTTIME	$1[7]
define U_STOPYEAR	$1[9]
define U_STOPDAY	$1[10]
define U_STOPTIME	$1[11]
define U_DECOM		$1[29]
define U_DECOMREEL	$1[32]
define U_MAJFRAMES	$1[34]
define U_SYNCERR	$1[35]
define U_ZEROFILLED	$1[37]
define U_DATAFORMAT	$1[39]
define U_STARTSCID	$1[41]
define U_STOPSCID	$1[43]
define U_ACDS		$1[45]
define U_MPC		$1[46]
define U_EXPERIMENT	$1[47]
define U_STARTHUT1	$1[48]
define U_SEQNO		$1[50]
define U_STARTMICRO	$1[52]
define U_DAYCNT		$1[55]
define U_STARTHUT	$1[56]
define U_STOPHUT	$1[58]

define U_RA		$1[64]
define U_DEC		$1[66]
define U_ROLL		$1[68]

define U_HRIARCSECPIX	$1[70]
define U_IPCARCSECPIX	$1[72]
define U_MINFRRES	$1[74]
define U_REFBAL		$1[76]

define U_VALIDEVENTS	$1[84]
define U_BINNEDRA	$1[86]
define U_BINNEDDEC	$1[88]
define U_BINNEDROLL	$1[90]
define U_IPCGAIN	$1[93]

define U_SSVALID	$1[94]
define U_SSBKGD		$1[96]
define U_SSTOTAL	$1[98]
define U_SSCBLANK	$1[100]

define U_OBSLEN		$1[102]
define U_MASKEDOUT	$1[104]
define U_ONTIME		$1[106]
define U_PSCNTS		$1[108]

define U_BOREROT	$1[136]
define U_BOREYOFF	$1[138]
define U_BOREZOFF	$1[140]

define U_AVGYOFF	$1[144]
define U_AVGZOFF	$1[146]
define U_AVGROT		$1[148]

define U_TOTOBSDUR	$1[150]
define U_LIVETIME	$1[152]
define U_LIVETCOR	$1[154]

define U_AVGBAL		$1[156]

define U_ASPRMSY	$1[164]
define U_ASPRMSZ	$1[166]
define U_ASPRMSROT	$1[168]

define U_TARGETRA	$1[180]
define U_TARGETDEC	$1[182]
define U_TARGETELAT	$1[184]
define U_TARGETELONG	$1[186]

define U_KILOSEC	$1[188]
define U_INSTID		$1[189]
define U_OBSERVER	$1[190]

# following are definition for GZOOM array files
define U_YDIM		$1[201]
define U_ZDIM		$1[202]
define U_YCENTER	$1[203]
define U_ZCENTER	$1[204]
define U_YRES		$1[205]
define U_ZRES		$1[206]
define U_ENERGY		$1[207]
define U_MAXVALI	$1[208]
define U_MAXVALR	$1[208]

define U_VERTSCALE	$1[210]	# file entry = Vertical scale * Data + Bias
define U_BIAS		$1[212]
define U_ARCSECPIX	$1[214]
define U_ORIGCENTER	$1[216]

# following are definitions for EXPosure array
define U_MAXVALUE	$1[221] # maximum ALLOWED value in exposure array
define U_EXPSCALE	$1[223] # value used to scale the integer entries
				# ( on-time )

# define the record structure for the argv argument list
# used by xpr2qp and uhead2qp
define  UTTIME	Memd[P2D($1)]
define	TITLE	Memi[($1)+2]

# define the UDA offsets
define	UD_DATAFORMAT	$1[39]
define	UD_SEQNO	$1[31]
define	UD_RA		$1[4]
define	UD_DEC		$1[6]
define	UD_ROLL		$1[8]
define	UD_BINNEDRA	$1[10]
define	UD_BINNEDDEC	$1[12]
define	UD_BINNEDROLL	$1[14]
define	UD_ONTIME	$1[18]
define	UD_BOREROT	$1[56]
define	UD_BOREYOFF	$1[58]
define	UD_BOREZOFF	$1[60]

define	UD_AVGYOFF	$1[121]
define	UD_AVGZOFF	$1[123]
define	UD_AVGROT	$1[125]

define	UD_LIVETIME	$1[152]
define	UD_INSTID	$1[29]
define	UD_OBSERVER	$1[30]

# following are definition for GZOOM array files
define UD_YDIM		$1[41]
define UD_ZDIM		$1[42]
define UD_YCENTER	$1[43]
define UD_ZCENTER	$1[44]
define UD_YRES		$1[45]
define UD_ZRES		$1[46]
define UD_ENERGY	$1[47]
define UD_MAXVALI	$1[48]
define UD_MAXVALR	$1[48]

define UD_VERTSCALE	$1[50]	# file entry = Vertical scale * Data + Bias
define UD_BIAS		$1[52]
define UD_ARCSECPIX	$1[54]
define UD_ORIGCENTER	$1[119]

define	UHEAD	0
define	UDA	1

