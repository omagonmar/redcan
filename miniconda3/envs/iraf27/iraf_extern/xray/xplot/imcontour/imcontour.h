#$Header: /home/pros/xray/xplot/imcontour/RCS/imcontour.h,v 11.0 1997/11/06 16:38:14 prosb Exp $
#$Log: imcontour.h,v $
#Revision 11.0  1997/11/06 16:38:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:09:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:41:20  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:23  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:33:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:24:08  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:05:48  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:21:18  pros
#General Release 1.0
#
# Plate constants structure
define	LEN_PL_CNST	35
define	SIN_A		Memd[P2D($1)]		# sin(a), a=RA at plate center
define	COS_A		Memd[P2D($1+2)]		# cos(a)
define	SIN_D		Memd[P2D($1+4)]		# sin(d), d=Dec at plate center
define	COS_D		Memd[P2D($1+6)]		# cos(d)
define	COSA_SIND	Memd[P2D($1+8)]		# cos(a)*sin(d)
define	SINA_SIND	Memd[P2D($1+10)]	# sin(a)*sin(d)
define	COSA_COSD	Memd[P2D($1+12)]	# cos(a)*cos(d)
define	SINA_COSD	Memd[P2D($1+14)]	# sin(a)*cos(d)
define	CEN_RA		Memd[P2D($1+16)]	# R.A. of plate center (radians)
define	CEN_DEC		Memd[P2D($1+18)]	# Dec. of plate center (radians)
define	PLATE_SCALE_X	Memd[P2D($1+20)]	# Plate scale in rad/mm in x
define	PLATE_SCALE_Y	Memd[P2D($1+22)]	# Plate scale in rad/mm in y
define  SAPERPIXX 	Memr[($1+24)]	# Seconds of arc per pix
define  SAPERPIXY 	Memr[($1+25)]	# Seconds of arc per pix
define  SAPERMMX	Memr[($1+26)]	# Seconds of arc per mm in x
define  SAPERMMY	Memr[($1+27)]	# Seconds of arc per mm in y
define  IMPIXX		Memr[($1+28)]	# image length in pix
define  IMPIXY		Memr[($1+29)]	# image length in pix
define  IMBLKX		Memr[($1+30)]	# image blocking
define  IMBLKY		Memr[($1+31)]	# image blocking
define  PIXMMX          Memr[($1+32)]
define  PIXMMY          Memr[($1+33)]
define  DEFSCALE        Memi[($1+34)]

# Units conversion macros
define	RADTOST		(240.0*RADTODEG($1))	# Radians to seconds of time
define	RADTOSA		(3600.0*RADTODEG($1))	# Radians to seconds of arc
define	STTORAD		(DEGTORAD(($1)/240.0))	# Seconds of time to radians
define	SATORAD		(DEGTORAD(($1)/3600.0))	# Seconds of arc to radians
define	RADTOHRS	(RADTODEG(($1)/15.0))	# Radians to hours
define	HRSTORAD	(DEGTORAD(15.0*($1)))	# Hours to radians
define  DEGTOSA         (3600.0*($1))           # degrees to seconds of arc
define  SATODEG		(($1)/3600.0)           # sec of arc to degrees 
define	STPERDAY	86400			# Seconds per day
define	MAX_WIDTH	PI/4.0

# WCS numbers
define  PIX_WCS         1
define	IM_WCS		2
define	LEGEND_WCS	3
define	MM_R_WCS	4
define	ID_WCS		5
define	TITLE_WCS	6
define	WARN_WCS	7

# Miscellaneous definitions
define	RA_INCR		25
define	RA_NUM_TRY	6
define	DEC_NUM_TRY	6
define	ALMOST_POLE	(DEGTORAD(86))
define	EDGE_FACTOR	50
define	TEXT_LINES	30

define	SUPER_SCRIPT	1
define	NORMAL_SCRIPT	0
define	SUB_SCRIPT	-1
define	SS_FACTOR	.4

define  SKY		0
define  PIXEL           1

define  NO_GRID		0
define  TICS		1
define  FULL		2

define  NO_LABEL	0
define  IN		1
define  OUT		2

define  XMM 		1
define  YMM             2
define  AR              3
define  DEV             4

define  SCREEN          0
define  PAPER           1

define  USER		0
define  DEFAULT		1

define  BEG             0
define  DONE            1

