# $Header: /home/pros/xray/xtiming/timcor/calc_bary/RCS/clcbary_subs.x,v 11.0 1997/11/06 16:45:37 prosb Exp $
# $Log: clcbary_subs.x,v $
# Revision 11.0  1997/11/06 16:45:37  prosb
# General Release 2.5
#
# Revision 9.3  1997/09/24 18:40:41  prosb
# JCC(9/97) - change the comments only.  (JDLEAP -> JD)
#
# Revision 9.2  1997/07/21 21:19:40  prosb
# JCC(7/21/97) - change jdleap :  int  ->  double.
#
# Revision 9.0  1995/11/16 19:36:07  prosb
# General Release 2.4
#
#Revision 8.3  1995/09/18  19:29:02  prosb
#JCC - jdleap[NLEAPS] is not hardwired in the code anymore.
#    - It is stored in a new table "jdleap.tab" instead.
#    - The new code "jdleap_init.x" reads jdleap[NLEAPS]
#    - from jdleap.tab.
#
#Revision 8.1  1994/09/07  17:49:32  janet
#jd - added leap seconds for Jul 1993 & Jul 1994.
#
#Revision 8.0  94/06/27  17:44:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:19  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:00:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:22  prosb
#General Release 2.1
#
#Revision 4.2  92/10/06  11:39:35  jmoran
#JMORAN changed last digit of leap second for 1-JUL-1992 from a 4 to 
# a 5 to be consistent with the other data points (i.e. 0.5 higher
# than the actual JD)
#
#Revision 4.1  92/10/05  17:02:29  jmoran
#JMORAN added new leap second for data list (JUL 1, 1992)
#
#Revision 4.0  92/04/27  15:40:11  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/26  13:27:49  prosb
#Initial revision
#
#
# Module:       < file name >
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>
#               {n} <who> -- <does what> -- <when>
#
#***********************************************************************
#
# PROCEDURE A1UTCF
#
#  This function computes the difference between atomic time (a1)
#  and utc for any date since the beginning of 1972.
#
#  jdleap[NLEAPS]   array with dates of leap seconds (at 0h UT):
#    1    2441500    1-Jul-1972
#    2    2441684    1-Jan-1973
#    3    2442049    1-Jan-1974
#    4    2442414    1-Jan-1975
#    5    2442779    1-Jan-1976
#    6    2443145    1-Jan-1977
#    7    2443510    1-Jan-1978
#    8    2443875    1-Jan-1979
#    9    2444240    1-Jan-1980
#   10    2444787    1-Jul-1981
#   11    2445152    1-Jul-1982
#   12    2445517    1-Jul-1983
#   13    2446248    1-Jul-1985
#   14    2447162    1-Jan-1988
#   15    2447893    1-Jan-1990
#   16    2448258    1-Jan-1991
#   17	  2448805    1-Jul-1992	      
#   18	  2449169    1-Jul-1993	      
#   19	  2449534    1-Jul-1994	      
#
# Must update the constant NLEAPS in the header file when adding a leap
# second.  (No need to do this any more - jcc (9/18/95)
#
# jcc(9/18/95)-
#The data "jdleap[NLEAPS]" are no longer hardwired in the codes.  
#Instead, it is stored in a new table "jdleap.tab". When adding 
#a leap second, no need to update the header file and to
#recompile the codes anymore. Just simply create another new 
#table "jdleap.tab" will make it work. 
#
#***********************************************************************
include <tbset.h>
include <error.h>
include <ext.h>
include <math.h>
include	<bary.h>

double	procedure a1utcf(jdutc, jdleap, NLEAPS)

long    jdutc		 # time difference a1-utc (in seconds)

#long   jdleap[LEAPMAX]  # i: array for the column "JD" in jdleap.tab
double  jdleap[LEAPMAX]  # i: array for the column "JD" in jdleap.tab
long    NLEAPS           # i: total row# in jdleap.tab

int	ii
bool    getout
double	retval
 
begin
	getout = false
 
#-------------------------
#     loop over leap years
#-------------------------
	do ii = NLEAPS, 1, -1 {
           if ((jdutc >= jdleap[ii]) && (!getout)) {
              retval = A1UTC + ii
              getout = true
           } 
        } 

      	if (!getout) 
          retval = A1UTC

	return retval
end     

#***********************************************************************
# PROCEDURE AR_JDC
#  Converts day,month,year (nd,nm,ny:last two digits) to julian day
#  WARNING: only valid between 1980 and 1999
#***********************************************************************
procedure ar_jdc(nd, nm, ny, jd)

double  jd			# Julian day
long    nd			# day of date
long    nm			# month of date
long    ny			# year of date
long    mdn[12]			# starting days of months in a year for Feb 28
long    mdl[12]			# starting days of months in a year for Feb 29
long    iy			# years since 1980
long    nl			# internal use
long    js[20]			# days since 1980
long    four

data    js   /29219 ,29585 ,29950 ,30315 ,30680,
              31046 ,31411 ,31776 ,32141 ,32507,
              32872 ,33237 ,33602 ,33968 ,34333,
              34698 ,35063 ,35429 ,35794 ,36159/

data     mdn  /    0,    31,    59,    90,  120,
                 151,   181,   212,   243,  273,
                 304,   334                    /

data     mdl  /     0,    31,    60,    91,  121,
                  152,   182,   213,   244,  274,
                  305,   335                    /

begin
	four = 4
	if (nd != 0) {
	   iy  =  ny  - 79
	   jd  =  JD0 + dfloat(js[iy])
	   nl  =  ny  / four
	   nl  =  nl  * four

	   if (nl == ny)
	      jd= jd + dfloat(mdl[nm] + nd)
	   else
	      jd = jd + dfloat(mdn[nm] + nd)
	}
end

#***********************************************************************
# PROCEDURE BARNEW
#  compute the magnitude of propagation effects which change the
#  arrival time of a photon from that expected at the solar system
#  barycenter (SSBC) in a vacuum.
#***********************************************************************
double procedure barnew(rea, dir, rce, rcs)

double  rea[3]		#i/o: vector from geaocenter to site (light-s)
double  dir[3]		#i: unit vector from sun to pulsar (J2000)
double  rce[3]		#i: vector from SSBC to geocenter (light-s)
double  rcs[3]		#i: vector from SSBC to sun center (light-s)

double  rsa[3] 		# vector from sun to site (light-sec)	
double  rca[3]		# vector from SSBC to site (light-sec)
double  bclt		# projection of vector from SSBC to site
			# on the direction of the source (light-s)
double  sundis		# distance from sun to site (light-s)
double  sunsiz		# apparent radius of the sun (radians)
double  cth		# cosine of site-sun-source angle
double  dtgr		# relativistic (Shapiro) delay (s)
double 	rschw		# Schwarzschild radius of the sun in light seconds
double	retval		# sum of propagation delays (seconds)
bool	sun		# flag for source occultation by the sun

begin
	sun = false
	rschw = (GAUSS**2) * (AULTSC**3) * (DAYS_IN_SEC**2)

#-----------------------------------------------------------------
#     calculate light-travel time to barycenter in euclidean space              
#-----------------------------------------------------------------
      	rca[1] = rce[1] + rea[1]
      	rca[2] = rce[2] + rea[2]
      	rca[3] = rce[3] + rea[3]
      	bclt = dir[1]*rca[1] + dir[2]*rca[2] + dir[3]*rca[3]

#-----------------------------------------------------------------------
#     now calculate the time delay due to the gravitational field of the
#     sun (I.I. Shapiro, Phys. Rev. Lett. 13, 789 (1964)).
#-----------------------------------------------------------------------
      	rsa[1] = rca[1] - rcs[1]
      	rsa[2] = rca[2] - rcs[2]
      	rsa[3] = rca[3] - rcs[3]
      	sundis = dsqrt(rsa[1]*rsa[1] + rsa[2]*rsa[2] + rsa[3]*rsa[3])
      	sunsiz = SUNRAD/sundis
      	cth = (dir[1]*rsa[1] + dir[2]*rsa[2] + dir[3]*rsa[3])/sundis

        if ((cth+1.D0) < (0.5D0*sunsiz*sunsiz))
	   sun = true

      	if (sun) {
            retval = bclt
        }
	else {
           dtgr = -2D0 * rschw * dlog(1.D0 + cth)
           retval = bclt - dtgr   
        } 

	return retval
end     

#***********************************************************************
# PROCEDURE EPHEM
#  reads and interpolates ephemeris file (jpl data), returning
#   positions of the earth and sun with respect to the solar system
#   barycenter (SSBC) and the difference between ephemeris time (tdb)
#   and universal time (utc) at the same epoch.
#***********************************************************************
procedure ephem(tp_eph,jdutc,frc,rce,rcs,etut,vce,jdleap,NLEAPS)

pointer tp_eph
long    jdutc                   # julian day number of ephemeris lookup
double  frc                     # day fraction (between -0.5 and 0.5)
double  rce[3]                  # vector from SSBC to earth (light-s)
double  rcs[3]                  # vector from SSBC to sun   (light-s)
double  etut                    # time difference tdb-utc (seconds)
double  vce[3]                  # time derivative of rce

#double  earth[3,4,NDAYCH]	# earth position and its first three
				# derivatives for each day
#double  sun[3,NDAYCH]		# sun positions for each day in memory
#double  tdbtdt[NDAYCH]		# relativistic time correction (tdb-tdt)
#double  tdbdot[NDAYCH]		# rate of change of tdbtdt
#double  tdtut[NDAYCH]		# time difference tdt-utc
double  a1utcf()		# function returning atomic time - utc
double  dt			# temporary variable for taylor series
double  dt2			# temporary variable for taylor series
double  dt3			# temporary variable for taylor series
long    nset			# loop index
long    nrec			# pointer to current record in ephemeris file
long    i, j			# loop index

# jcc 
#long   jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab
double  jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab

long    NLEAPS              # total row# in jdleap.tab

include "ephem.com"

begin

#---------------------------------------
# check if date is in range of ephemeris
#---------------------------------------
        if ((jdutc < jd0) || (jdutc > jd1))
           call error(1, "Julian date is outside of ephemeris table")

#-------------------------------------------------------------------
# choose set of coefficents to use; if out of range, read new chunk.
#-------------------------------------------------------------------
	nset = 1 + (jdutc - jdch0)
	if (nset > NDAYCH || nset < 1) {
#-----------------------------------------------------------------------
#           read earth and sun positions and tdb-tdt from the ephemeris.
#           get at-ut from the leap second table in a1utcf.
#-----------------------------------------------------------------------
	   jdch1 = min(jdutc + (NDAYCH - 1), jd1)
	   jdch0 = jdch1 - (NDAYCH - 1)

	   do nset = 1, NDAYCH {
#	      nrec = nset + (jdch0 - jd0) + 1
# Since the header record is now in the header, don't add the "1"
#
              nrec = nset + (jdch0 - jd0)

	      do j = 1, 4 {
  	        do i = 1, 3 {
    		   if (j == 1)
       		     call tbegtd (tp_eph, ear_cp[i], nrec, earth[i, j, nset])
  
    		   if (j == 2)
       		     call tbegtd (tp_eph, eard1_cp[i], nrec, earth[i, j, nset])

    		   if (j == 3)
       		      call tbegtd (tp_eph, eard2_cp[i], nrec, earth[i, j, nset])

    		   if (j == 4)
       		      call tbegtd (tp_eph, eard3_cp[i], nrec, earth[i, j, nset])
   	        }
	      }

	      do i = 1, 3 {
   	         call tbegtd (tp_eph, sun_cp[i], nrec, sun[i, nset])
	      }

	      call tbegtd (tp_eph, tdbtdt_cp, nrec, tdbtdt[nset])

	      tdtut[nset] = ETATC + a1utcf(jdch0+nset-1,jdleap,NLEAPS)
	   } # end loop

#-------------------------------------------------------------------
#              make rough computation of time derivative of tdb-tdt.
#-------------------------------------------------------------------
	   do nset = 1, NDAYCH - 1 {
	      tdbdot[nset] = tdbtdt[nset + 1] - tdbtdt[nset]
	   } 
	   tdbdot[NDAYCH] = tdbdot[NDAYCH - 1]
	   nset = 1 + (jdutc - jdch0)
	} 

#----------------------------------------------------------------------
#     now use taylor series to get the coordinates at the desired time.
#----------------------------------------------------------------------
	dt = frc + tdtut[nset] * DAYS_IN_SEC
	dt2 = dt*dt
	dt3 = dt2*dt
	etut = tdbtdt[nset] + dt*tdbdot[nset] + tdtut[nset]

	do i = 1, 3 {
	   rcs[i] = sun[i,nset]   
	   rce[i] = earth[i,1,nset] + dt*earth[i,2,nset] + 
               	    0.5D0*dt2*earth[i,3,nset] + (1.D0/6.D0)*dt3*earth[i,4,nset]

	   vce[i] = (earth[i, 2, nset] + dt*earth[i, 3, nset])*DAYS_IN_SEC
	} 
end

#***********************************************************************
# PROCEDURE SS_BAR
#  this function calculates the vector from the spacecraft to the 
#  solar system barycenter, as well as the correction between 
#  ephemeris time and UTC.
#
#  routines_called    type     description
#  ephem               sr      read and interpolate ephemeris file
#
#*************************************************************************
procedure ss_bar(tp_eph,jd,frc,rea,rca,etut,rce,rcs,vce,jdleap,NLEAPS)

pointer tp_eph
long    jd		# julian day number
double  frc		# fraction of day at observation time in range (0, 1)
double  rea[3]		# vector from earth center to spacecraft (light-s)
double  rca[3]		# vector from SSBC to spacecraft in light seconds
double  etut		# tbd-UTC in seconds
double  rce[3]		# vector from SSBC to geocenter (light-s)
double  rcs[3]		# vector from SSBC to sun center (light-s)
double  vce[3]		# time derivative of rce

double  frc_2		# fraction of day at ob time in range (0,1) (corrected)
long    jd_2		# julian day number (corrected)
int	i

#long   jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab
double  jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab

long    NLEAPS              # total row# in jdleap.tab

begin

#----------------------------------------
#        convert frc to range (-0.5,+0.5)
#----------------------------------------
        if (frc > HALF) {
           jd_2  = jd  + ONE
           frc_2 = frc - ONED
        }
	else { 
           jd_2  = jd
           frc_2 = frc
        } 

#------------------
#        call ephem 
#------------------
       	call ephem(tp_eph,jd_2,frc_2,rce,rcs,etut,vce,jdleap,NLEAPS)

#---------------------------------------------------
#        compute rca and convert it to light-seconds
#---------------------------------------------------
        do i = 1, 3 {
            rca[i] = rce[i] + rea[i]
        } 
end     
