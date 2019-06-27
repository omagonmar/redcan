#$Header: /home/pros/xray/lib/RCS/qpoe.h,v 11.2 2001/03/26 21:06:27 prosb Exp $
#$Log: qpoe.h,v $
#Revision 11.2  2001/03/26 21:06:27  prosb
#Y2K fixes
#
#Revision 11.1  1999/09/21 15:01:29  prosb
#JCC(7/98)- y2k: add for "DATE"  "ZERODATE" "RDF_DATE" "PROCDATE"
#
#Revision 11.0  1997/11/06 16:24:39  prosb
#General Release 2.5
#
#Revision 9.2  1996/02/13 15:31:47  prosb
#JCC - Add new keywords for telescope.
#
#Revision 9.0  1995/11/16  18:25:35  prosb
#General Release 2.4
#
#Revision 8.2  1994/09/16  15:58:19  dvs
#Added QP_INDEXX and QP_INDEXY to QPOE structure.
#
#Revision 8.1  94/08/04  10:01:41  dvs
#Added Einstein Rev 1 header information for TSI records, since
#their records differ so strongly from Rev 0 TSIs.
#
#Revision 8.0  94/06/27  13:43:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:22:13  prosb
#General Release 2.3
#
#Revision 6.5  93/12/22  17:26:24  mo
#Update for RDF
#
#Revision 6.4  93/11/16  09:32:48  mo
#MC	11/15/93		Update BLT record structure for new IPC
#				event cdroms
#
#Revision 6.3  93/10/26  18:25:29  mo
#MC	10/26/93		Add 'FORMAT' entry to current BLT record
#				without affecting the length of the
#				data structure
#
#Revision 6.2  93/09/30  23:38:10  dennis
#Added QP_FORMAT field.
#
#Revision 6.1  93/09/30  16:11:03  dennis
#(Maureen)  New RDF header parameters.
#
#Revision 6.0  93/05/24  15:37:02  prosb
#General Release 2.2
#
#Revision 5.3  93/04/30  02:43:55  dennis
#Changed defined constant POINT to POINTED, to avoid collision with 
#POINT defined in regions.h.
#
#Revision 5.2  93/04/26  16:28:28  jmoran
#JMORAN added QP_REVISION
#
#Revision 5.1  93/01/27  14:23:58  mo
#MC	1/28/93		Add Einstein IPC tsi definitions
#
#Revision 5.0  92/10/29  21:23:06  prosb
#General Release 2.1
#
#Revision 4.2  92/10/14  17:01:04  mo
#MC	10/14/92	Changed WCS keywords to double precision
#
#Revision 4.1  92/08/27  11:25:34  mo
#MC		Correct size of SEQPI to be 80 characters
#
#Revision 3.3  92/04/13  15:31:25  mo
#MC	4/13/92		Parameterize the GTI,BLT and TGR pros event string
#
#Revision 3.2  92/03/30  18:07:08  mo
#MC	3/30/92		Add qphead entry for EXPTIME
#
#Revision 3.1  92/03/09  15:36:36  mo
#MC	3/9/92		Add an entry for Einstein HUT to facilitate BLT conversion			Only used internally.
#
#Revision 3.0  91/08/02  00:46:49  prosb
#General Release 1.1
#
#Revision 2.3  91/08/01  21:49:42  mo
#MC	8/1/91		Add minimum and maximum channel numbers to qpheader
#			structure
#
#Revision 2.2  91/04/16  16:09:03  mo
#MC	4/16/91		 Added new parameters for SEQ_PI in qphead.
#
#Revision 2.1  91/04/10  19:32:35  mo
#	MC	4/1/91	Reverse BSCALE and BZERO to be compatible with input
#
#Revision 2.0  91/03/07  00:03:57  pros
#General Release 1.0
#
#
# Module:       QPOE.H
# Project:      PROS -- ROSAT RSDC
# Purpose:      Structure of PROS internal QPOE header
# External:     This structure is filled by xhead.x
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   Original  	1989
#               {1} MC -- Adds image dimensions as well as detector 
#			  dimensions				12/27/90
#
#
#  QPOE.H -- include file for qpoe access
#

#
#  the X-ray header for a qpoe file
#
# NB: the header pointer should be TY_STRUCT

# already in hlib$IRAF.h
#define	YES	1
#define	NO	0
define  UNKNOWN -1
define SZ_QPHEAD	2000			# size of header, in SZ_STRUCT

# FITS, pseudo-FITS and WCS parameters
define QP_MISSION	Memi[($1)+0] 		# Mission ID - arbitrary
define QP_MISSTR	Memc[P2C(($1)+1)]	# mission name (e.g. Einstein)
#JCC - the entry of QP_TELE & QP_TELESTR starts at $1+460
define QP_INST		Memi[($1)+11]		# Instrument 
define QP_INSTSTR	Memc[P2C(($1)+12)]	# instrument name (e.g. HRI)
define QP_RADECSYS	Memc[P2C(($1)+22)]	# WCS for this file (e.g., FK4)
define QP_EQUINOX	Memr[($1)+32] 		# Epoch
define QP_CTYPE1	Memc[P2C(($1)+40)]	# axis type (e.g. RA----TAN)
define QP_CTYPE2	Memc[P2C(($1)+50)]	# axis type (e.g. DEC----TAN)
define QP_CRVAL1	Memd[P2D(($1)+100)] 	# Sky coord of first axis
define QP_CRVAL2	Memd[P2D(($1)+102)]	# Sky coord of second axis
define QP_CRPIX1	Memd[P2D(($1)+104)]	# X pixel of tangent plane dir.
define QP_CRPIX2	Memd[P2D(($1)+106)]	# X pixel of tangent plane dir.
define QP_CDELT1	Memd[P2D(($1)+108)] 	# X arc seconds per pixel
define QP_CDELT2	Memd[P2D(($1)+110)]	# Y arc seconds per pixel
define QP_CROTA2	Memd[P2D(($1)+112)]	# Binned roll (degrees)
define	SZ_OBJECT	38
define QP_OBJECT	Memc[P2C(($1)+120)]	# FITS 'object' name
define QP_MJDOBS	Memr[($1)+140]		# MJD of start of obs
define QP_DATEOBS	Memc[P2C(($1)+141)]	# start date of obs
define QP_TIMEOBS	Memc[P2C(($1)+161)]	# start time of obs
define QP_DATEEND	Memc[P2C(($1)+181)]	# end date of obs
define QP_TIMEEND	Memc[P2C(($1)+201)]	# end time of obs

#  The 'bkwcs' routine stores these, derived from CDELT and CROTA
#	ONLY used for FITS writing TASK!
#  Not recommended for USERS! - not always UPDATED
define QP_CD11          Memd[P2D(($1)+1180)]    # Rotation matrix
define QP_CD12          Memd[P2D(($1)+1182)]    # Rotation matrix
define QP_CD21          Memd[P2D(($1)+1184)]    # Rotation matrix
define QP_CD22          Memd[P2D(($1)+1186)]    # Rotation matrix
define QP_ISCD          Memi[($1)+1188]     	# Rotation matrix

# PROS Observation Identification Parameters
define QP_OBSID		Memc[P2C(($1)+1190)]	# Observation ID
define SZ_OBSID		34
define QP_SUBINST	Memi[($1)+1207] 	# Sub instrument 
define QP_OBSERVER	Memi[($1)+1208]		# Observer ID
define QP_COUNTRY	Memc[P2C(($1)+1209)]	# Country
define QP_FILTER	Memi[($1)+1219]		# filter code (1=PSPC boron)
define QP_MODE		Memi[($1)+1220]		# pointed, slew, etc.

# PROS Definitive event/image reference quantities
define	SZ_TIMEREF	20
define QP_TIMEREF	Memc[P2C(($1)+1221)]	# time-system
define QP_DETANG	Memr[($1)+1232]		# Nominal roll (radians)
define QP_MJDRDAY	Memi[($1)+1233]		# int mod. JD for SC clk start
define QP_MJDRFRAC	Memd[P2D(($1)+1234)]	# frac mod. JD for SC clk start
define QP_EVTREF	Memi[($1)+1236]		# day offset from mjdr-- to
       						# event start times
define QP_CLOCKCOR	Memi[($1)+1237]		# 1 = clock drift corrected
						# 0 = uncorrected for drift
define QP_TBASE		Memd[P2D(($1)+1238)]	# s/c start to obs start
define QP_XDIM		Memi[($1)+1240]		# IMAGE size ( or AXLEN )
define QP_YDIM		Memi[($1)+1241]		# IMAGE size ( or AXLEN )
#  The following 2 locations are for INTERNAL EINSTEIN use only and
#  are NOT written out to the file.  They are necessary for BLT time
#	conversions into PROS
define QP_HUT		Memi[($1)+1242]		# Einstein hut from SCID 
						# corresponds to TBASE
define	SZ_TIMESYS	32
define QP_TIMESYS	Memc[P2C(($1)+1244)]	# Name of time-system

# PROS Observation reference parameters defining standard processing results
define QP_EXPTIME	Memd[P2D(($1)+1260)]	# On time seconds through time filter
define QP_POISSERR	Memi[($1)+1262]
define QP_ONTIME	Memd[P2D(($1)+1264)]	# Sec. of accepted data in obs.
define QP_LIVETIME	Memd[P2D(($1)+1266)]	# Sec. of livetime in obs.
define QP_DEADTC	Memr[($1)+1268]		# Dead-time correction factor
define QP_BKDEN		Memr[($1)+1269]		# bkgd ct density (cts/amin**2)
define QP_MINLTF	Memr[($1)+1270]		# min live time factor
define QP_MAXLTF	Memr[($1)+1271]		# max live time factor
define QP_XAOPTI	Memr[($1)+1272]		# x asec offset, avg opt axis
define QP_YAOPTI	Memr[($1)+1273]		# y asec offset, avg opt axis
define QP_XAVGOFF	Memr[($1)+1274]		# x asec offset, aspect
define QP_YAVGOFF	Memr[($1)+1275]		# y asec offset, aspect
define QP_RAVGROT	Memr[($1)+1276]		# avg aspect rotation (degrees)
define QP_XASPRMS	Memr[($1)+1277]		# x avg aspect rms
define QP_YASPRMS	Memr[($1)+1278]		# y avg aspect rms
define QP_RASPRMS	Memr[($1)+1279]		# rot avg aspect rms

# PROS static instrument parameters
define QP_RAPT		Memr[($1)+1280] 	# Nominal RA (degrees)
define QP_DECPT		Memr[($1)+1281]		# Nominal DEC (degrees)
define QP_XPT		Memi[($1)+1282]		# obs orig x pointing pixel
define QP_YPT		Memi[($1)+1283]		# obs orig y pointing pixel
define QP_XDET		Memi[($1)+1284]		# number of x inst pixels
#define QP_XDIM		Memi[($1)+1284]		# not so - nice alias
define QP_YDET		Memi[($1)+1285]		# number of y inst pixels
#define QP_YDIM		Memi[($1)+1285]		# not so - nice alias
define QP_FOV		Memr[($1)+1286]		# field of view radius (a min.)
#define QP_INSTPIX	Memr[($1)+1287]		# inst pixel size (asec)
define QP_XDOPTI	Memr[($1)+1288]		# x offset in asec from ref.
       						# pixel for opt. axis
       						# in det. coords
define QP_YDOPTI	Memr[($1)+1289]		# x offset in asec from ref.
       						# pixel for opt. axis
       						# in det. coords
define QP_CHANNELS	Memi[($1)+1290]		# Number of energy channels
define QP_INSTPIX	Memr[($1)+1291]		# alias for QP_IPXX inst pixel size (asec)
define QP_INPXX		Memr[($1)+1291]		# inst pixel size (asec)
define QP_INPXY		Memr[($1)+1292]		# inst pixel size (asec)
define QP_MINCHANS	Memi[($1)+1293]		# Number of energy channels
define QP_MAXCHANS	Memi[($1)+1294]		# Number of energy channels
define QP_MINPHA	Memi[($1)+1295]		# Number of energy channels
define QP_MAXPHA	Memi[($1)+1296]		# Number of energy channels
define QP_MINPI		Memi[($1)+1297]		# Number of energy channels
define QP_MAXPI		Memi[($1)+1298]		# Number of energy channels
define QP_PHACHANS	Memi[($1)+1299]		# Number of energy channels
define QP_PICHANS	Memi[($1)+1300]		# Number of energy channels

# file information
define QP_CRETIME	Memi[($1)+1310]		# Creation time of QPOE file
define QP_MODTIME	Memi[($1)+1311]		# Time of last mods to data
define QP_LIMTIME	Memi[($1)+1312]		# Time when limits were updated

# optional info for arrays
define	QP_BSCALE	Memr[($1)+1320]		# zero offset for FITS array
define  QP_BZERO	Memr[($1)+1321]		# scale factor for FITS array

define	QP_SEQPI	Memc[P2C(($1)+1330)]	# name of observation PI 
define	SZ_SEQPI	80 			# name of observation PI 
define	QP_EDUMMY	Memi[($1)+1379]		# just mark that SEQPI is 80 characters

define	QP_MODESTR	Memc[P2C(($1)+1380)]	# name of observation PI 
define	SZ_MODESTR	10 			# name of observation PI 
define	QP_FILTSTR	Memc[P2C(($1)+1385)]	# name of observation PI 
define	SZ_FILTSTR	10 			# name of observation PI 
define	QP_FORMAT	Memi[($1)+1399]
define	QP_REVISION 	Memi[($1)+1400]

# keywords to define the TIME SYSTEM
define  SZ_CLOCKCOR     20
define  SZ_TASSIGN	20
define	QP_TASSIGN	Memc[P2C(($1)+1420)]	# reference point for time
define  SZ_TIMEUNIT	20
define	QP_TIMEUNIT	Memc[P2C(($1)+1430)]	# reference point for time

# keywords for x & y indices (in case they aren't 'x' and 'y')
define  SZ_INDEXX       20
define  QP_INDEXX       Memc[P2C(($1)+1440)]
define  SZ_INDEXY       20
define  QP_INDEXY       Memc[P2C(($1)+1450)]

# JCC - Add new keywords for telescope
define QP_TELE          Memi[($1)+1460]            # telescope ID 
define QP_TELESTR       Memc[P2C(($1)+1461)]       # telescope name 

#JCC(7/98)- y2k - add for "DATE"  "ZERODATE" 
define QP_DATE          Memc[P2C(($1)+1471)]     #FITS creation date
define QP_ZERODATE      Memc[P2C(($1)+1491)]     #UT date of SC start
define QP_RDFDATE  Memc[P2C(($1)+1511)] #Rationalized Data Format release date
define QP_PROCDATE Memc[P2C(($1)+1591)] #SASS SEQ processing start date

# Next entry should be at $1+1671

# tgr records
# NB: the tgr pointer should be  TY_STRUCT!!
#
define	SZ_QPTGR	8		# size of TGR struct in SZ_STRUCT
  					# includes padding for QPOE

# define pointer into array of event records
define	TGR		(($1)+(($2-1)*SZ_QPTGR))

# tgr record structure
define	TGR_TIME	Memd[P2D($1)+0]
define	TGR_HUT		Memi[($1)+2]
define	TGR_STAT1	Memi[($1)+3]
define	TGR_STAT2	Memi[($1)+4]
define	TGR_STAT3	Memi[($1)+5]
define	TGR_STAT4	Memi[($1)+6]
define  XS_TGR	"{d:start,i:hut,i:stat1,i:stat2,i:stat3,i:stat4,i:align1}"

#
# tsh records
# NB: the tsh pointer should be  TY_STRUCT!!
#
define	SZ_QPTSH	4		# size of TSH struct in SZ_STRUCT

# define pointer into array of event records
define	TSH		(($1)+(($2-1)*SZ_QPTSH))

# tsh record structure
define	TSH_TIME	Memd[P2D($1)+0]
define	TSH_ID		Memi[($1)+2]
define	TSH_STATUS	Memi[($1)+3]

#
# blt records
# NB: the blt pointer should be  TY_STRUCT!!
#
define	SZ_QPBLT	16		# size of BLT struct in SZ_STRUCT
  					# includes padding for QPOE

# define pointer into array of event records
define	BLT		(($1)+(($2-1)*SZ_QPBLT))

# blt record structure
define	BLT_START	Memd[P2D(($1)+0)]
define	BLT_STOP	Memd[P2D(($1)+2)]
define  BLT_ASPX	Memr[($1)+4]
define  BLT_ASPY	Memr[($1)+5]
define  BLT_ROLL	Memr[($1)+6]
define  BLT_BAL		Memr[($1)+7]
define	BLT_BOREROT	Memr[($1)+8]
define	BLT_BOREX	Memr[($1)+9]
define	BLT_BOREY	Memr[($1)+10]
define	BLT_NOMROLL	Memr[($1)+11]
define	BLT_BINROLL	Memr[($1)+12]
define	BLT_QUALITY	Memi[($1)+13]
define	BLT_FORMAT	Memi[($1)+14]
define  XS_BLT	"{d:start,d:stop,r:aspx,r:aspy,r:roll,r:bal,r:borerot,r:borex,r:borey,r:nomroll,r:binroll,i:quality}"

#
# gti (good time interval) records
# NB: the gti pointer should be  TY_STRUCT!!
#
define	SZ_QPGTI	4		# size of GTI struct in SZ_STRUCT
  					# includes padding for QPOE

# define pointer into array of event records
define	GTI		(($1)+(($2-1)*SZ_QPGTI))

# gti record structure
define	GTI_START	Memd[P2D(($1)+0)]
define	GTI_STOP	Memd[P2D(($1)+2)]
define	XS_GTI	"{d:start,d:stop}"

#
# stdscr (ROSAT/HRI stdscr) records
# NB: the scr pointer should be  TY_STRUCT!!
#
define	SZ_QPSCR	19		# size of GTI struct in SZ_STRUCT
  					# includes padding for QPOE

# define pointer into array of event records
define	SCR		(($1)+(($2-1)*SZ_QPSCR))

# scr record structure
define	SCR_START	Memd[P2D(($1)+0)]
define	SCR_DURATION	Memd[P2D(($1)+2)]
define	SCR_PASSED	Memi[($1)+4]
define	SCR_FAILED	Memi[($1)+5]
define	SCR_LOGICALS	Memi[($1)+6]
define	SCR_HIBK	Memi[($1)+7]
define	SCR_HVLEV	Memi[($1)+8]
define	SCR_VG		Memi[($1)+9]
define	SCR_ASPSTAT	Memi[($1)+10]
define	SCR_ASPERR	Memi[($1)+11]
define	SCR_HQUAL	Memi[($1)+12]
define	SCR_SAADIND	Memi[($1)+13]
define  SCR_SAADA	Memi[($1)+14]
define	SCR_SAADB	Memi[($1)+15]
define	SCR_TEMP1	Memi[($1)+16]
define	SCR_TEMP2	Memi[($1)+17]
define	SCR_TEMP3	Memi[($1)+18]

#
# tsi (temporal status interval) records
# NB: the tsi pointer should be  TY_STRUCT!!
#
define	SZ_PQPTSI	6		# size of TSI struct in SZ_STRUCT
  					# includes padding for QPOE

define	SZ_HQPTSI	16		# size of TSI struct in SZ_STRUCT
  					# includes padding for QPOE

define	SZ_EQPTSI	12		# size of Einstein TSI struct in SZ_STRUCT
  					# includes padding for QPOE

define  SZ_EREV1_QPTSI  8               # size of Einstein Rev 1 TSI struct 
	                                # in SZ_STRUCT

# define pointer into array of event records
define	PTSI		(($1)+(($2-1)*SZ_PQPTSI))
define	HTSI		(($1)+(($2-1)*SZ_HQPTSI))
define	ETSI		(($1)+(($2-1)*SZ_EQPTSI))
define  EREV1_TSI       (($1)+(($2-1)*SZ_EREV1_QPTSI))

# tsi record structure
define	TSI_START	Memd[P2D(($1)+0)]
define	TSI_FAILED	Memi[($1)+2]
define	TSI_LOGICALS	Memi[($1)+3]
#  Following are ROSAT/HRI specific
define	TSI_HIBK	Memi[($1)+4]
define	TSI_HVLEV	Memi[($1)+5]
define	TSI_VG		Memi[($1)+6]
define	TSI_ASPSTAT	Memi[($1)+7]
define	TSI_ASPERR	Memi[($1)+8]
define	TSI_HQUAL	Memi[($1)+9]
define	TSI_SAADIND	Memi[($1)+10]
define  TSI_SAADA	Memi[($1)+11]
define	TSI_SAADB	Memi[($1)+12]
define	TSI_TEMP1	Memi[($1)+13]
define	TSI_TEMP2	Memi[($1)+14]
define	TSI_TEMP3	Memi[($1)+15]
# Following are ROSAT/PSPC specific and 'replace' the above HRI values
define	TSI_RMB		Memi[($1)+4]
define  TSI_DFB		Memi[($1)+5]
# Following are Einstein specific and 'replace' the above HRI values
define	TSI_ATTCODE	Memi[($1)+9]
define  TSI_VGFLAG	Memi[($1)+10]
define  TSI_ANOM	Memi[($1)+11]

# The following are Einstein specific for Rev 1 TSI records
define  TSI_EREV1_TIME          Memd[P2D(($1)+0)]
define  TSI_EREV1_FAILED        Memi[($1)+2]
define  TSI_EREV1_LOGICALS      Memi[($1)+3]
define  TSI_EREV1_BKCODE        Mems[P2S($1)+8]
define  TSI_EREV1_HVLEV         Mems[P2S($1)+9]
define  TSI_EREV1_VIEWGEOM      Mems[P2S($1)+10]
define  TSI_EREV1_ASPSTAT       Mems[P2S($1)+11]
define  TSI_EREV1_ASPERR        Mems[P2S($1)+12]
define  TSI_EREV1_ATTCODE       Mems[P2S($1)+13]
define  TSI_EREV1_VGCODE        Mems[P2S($1)+14]
define  TSI_EREV1_ANOM          Mems[P2S($1)+15]
 
define  XS_ETSI	"{d:tstart,i:failed,i:logicals,i:hibk,i:hvlev,i:vg,i:aspstat,i:asperr,i:attcode,i:vgflag,i:anon}"
define  XS_EREV1_TSI  "{d:time,i:failed,i:logicals,s:bkcode,s:hvlev,s:viewgeom,s:aspstat,s:asperr,s:attcode,s:vgcode,s:anom}"
define  XS_RHTSI	"{d:tstart,i:failed,i:logicals,i:hibk,i:hvlev,i:vg,i:aspstat,i:asperr,i:hqual,i:saadind,i:saada,i:saadb,i:temp1,i:temp2,i:temp3}"
define  XS_RPTSI	"{d:tstart,i:failed,i:logicals,i:rmb,i:dfb}"
#
# data conversion flag values for the "convert" variable in qpcreate
#
define NO_CONVERT	0
define CONVERT_DG	1
define CONVERT_VAX	2

# pointing modes
define POINTED		1
define SLEW		2
define SCAN		3
define TRAUMA		4

# define some misc. WCS values
define  SZ_QPSTR	10			# max length of string
define  SZ_WCSSTR	SZ_QPSTR		# nice alias

# this is the Y2K size of QP_DATEOBS, QP_TIMEOBS, QP_DATEEND, QP_TIMEEND
define  SZ_DATESTR	20			# max length of string

