#$Header: /home/pros/xray/lib/RCS/coords.h,v 11.0 1997/11/06 16:24:49 prosb Exp $
#$Log: coords.h,v $
#Revision 11.0  1997/11/06 16:24:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:42:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:36:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:44  prosb
#General Release 2.1
#
#Revision 1.2  92/10/25  16:43:27  mo
#no change
#
#Revision 1.1  92/08/24  16:55:18  janet
#Initial revision
#

# Units conversion macros
define  RADTOST         (240.0*RADTODEG($1))    # Radians to seconds of time
define  RADTOSA         (3600.0*RADTODEG($1))   # Radians to seconds of arc
define  STTORAD         (DEGTORAD(($1)/240.0))  # Seconds of time to radians
define  SATORAD         (DEGTORAD(($1)/3600.0)) # Seconds of arc to radians
define  RADTOHRS        (RADTODEG(($1)/15.0))   # Radians to hours
define  HRSTORAD        (DEGTORAD(15.0*($1)))   # Hours to radians
define  DEGTOSA         (3600.0*($1))           # degrees to seconds of arc
define  SATODEG         (($1)/3600.0)           # sec of arc to degrees
