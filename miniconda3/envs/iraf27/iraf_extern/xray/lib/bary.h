#$Header: /home/pros/xray/lib/RCS/bary.h,v 11.0 1997/11/06 16:24:45 prosb Exp $
#$Log: bary.h,v $
#Revision 11.0  1997/11/06 16:24:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:17  prosb
#General Release 2.4
#
#Revision 8.2  1995/09/18  19:44:47  prosb
#JCC - Remove NLEAPS and add a new parameter LEAPMAX (=50).
#
#Revision 8.1  1994/09/07  17:55:42  janet
#jd - updated NLEAPS 19 when 2 leap seconds were added to bary code.
#
#Revision 8.0  94/06/27  13:42:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:46  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  17:26:13  mo
#MC	update for RDF
#
#Revision 6.1  93/11/29  15:21:40  mo
#MC (JD?)	add JDDAY/JDFRAC constants
#
#Revision 6.0  93/05/24  15:36:27  prosb
#General Release 2.2
#
#Revision 5.2  93/05/07  13:41:38  jmoran
#JMORAN changed SCC_ADD -> SCCADD
#
#Revision 5.1  93/04/27  13:26:47  jmoran
#JMORAN new param added
#
#Revision 5.0  92/10/29  21:22:40  prosb
#General Release 2.1
#
#Revision 4.1  92/10/05  16:27:46  jmoran
#JMORAN bumped NLEAPS to 17 for new leap second
#
#Revision 4.0  92/04/27  14:06:20  prosb
#General Release 2.0:  April 1992
#
#Revision 1.4  92/04/13  15:32:13  mo
#MC	4/13/92		Increment the SZ_ARGV size to accomodate separating
#			the TITLE and REGSUM strings
# 
#
define	DEVIAT  10.0D0
define	SECS_IN_DAY	86400.D0
define  DAYS_IN_SEC	(1.0D0/86400.D0)
define  LEN_EVBUF	1024
define  NCOMP           50
define  PCOEFF          10
define	JD0		2415019.5D0
define  JD90            2447892.5D0
define	QP_SORT_PARAM	"XS-SORT"
# superceded by RDF parameters in XHEAD
#define  QP_BARCOR_PARAM "BARYTIME"	  
define	START_NAME	"START"
define	END_NAME	"END"
define	TYPE_NAME	"TYPE"
#define	NCOEFF_NAME	"NCOEFF"
define	NCOEFF_NAME	"NCOE"
define  REFTIM_NAME     "REF_DATE"
define	SCCADD_NAME	"SCCADD"
define	NUM_CP		6
define  SZ_ARGV 5
define  SZ_EVBUF        1024
define  AULTSC          499.00478364D0	# astronomical unit (light-s)
define  GAUSS           0.01720209895D0 # gravitational constant
define  SUNRAD          2.315D0	  	# polar radius of the sun (light-s)
#define  NLEAPS  	19		# num. of leap secs in utc, from 1972
define  LEAPMAX  	50	#max num of leap secs in utc, from 1972
define  A1UTC		10.0343817D0	# a1-utc offset at the begining of 1972
define	ONE		1
define	ONED		1.0D0
define	HALF		0.5D0
define  NDAYCH      	16      	# num days of ephem to keep in memory
define  ETATC           (32.184D0 - 0.0343817D0) # time difference tdt-a1
define  SIDDAY          1.00273790934D0 # sidereal day (in days)
define  GT2000          67310.54841D0
define  JD2000          2451545
define  SPEED_OF_LIGHT	2.99792458D+8
define	ORBIT_GAP_VALUE 120.0D0
define  MJD_OFFSET      2442500

define  JDDAY           2400000         # jd reference day
define  JDFRAC          0.5D0		# jd referece day frac

