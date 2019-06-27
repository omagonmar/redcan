#$Header: /home/pros/xray/lib/pros/RCS/time.x,v 11.1 1999/01/29 20:21:35 prosb Exp $
#$Log: time.x,v $
#Revision 11.1  1999/01/29 20:21:35  prosb
#JCC(5/98) - comment : qp_upbary is used by apply_bary
#
#Revision 11.0  1997/11/06 16:21:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:27  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/18  10:30:53  mo
#MC	no changes
#
#Revision 7.1  94/05/09  09:54:28  mo
#MC	5/9/94		Move error message string to DATA statement
#			to avoid incorrect SPP conversion of adding
#			a declaration AFTER the data statement.  (Problem
#			reported in MAC/AUX port (4/94 eureka)
#
#Revision 7.0  93/12/27  18:10:53  prosb
#General Release 2.3
#
#Revision 6.2  93/11/30  18:44:56  prosb
#MC	11/30/93		Add UPBARY routine
#
#Revision 6.1  93/10/21  11:33:20  mo
#MC	10/5/93		Update these routines to accept input xhead
#			structure rather than just file handle.  This
#			insulates them from the exact header keyword names.
#
#Revision 6.0  93/05/24  15:54:22  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:36  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:18  wendy
#General
#
#Revision 2.0  91/03/07  00:07:37  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       time
# Project:      PROS -- ROSAT RSDC
# Purpose:      Support all UT/MJD/SCLK time conversions
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------

include	<mach.h>
include	<clk.h>
include <qpoe.h>
#include <bary.h>


define	HOUR_PER_DAY	24
define	LEAP		2
define	MIN_PER_HOUR	60
define	NON_LEAP	1
define	SEC_PER_MIN	60
define	SEC_PER_HOUR	(SEC_PER_MIN * MIN_PER_HOUR)
define	SECONDS_PER_DAY	(SEC_PER_MIN * MIN_PER_HOUR * HOUR_PER_DAY)
define	SECONDS_PER_HOUR	(SEC_PER_MIN * MIN_PER_HOUR)
define	DAYS_PER_YEAR	365
define	DAYS_PER_4YEAR	( DAYS_PER_YEAR * 4 + 1)


#  Convert space craft time to Universal Time
#  author : JOHN              date: 30-JUL-1986 13:48 
#  update : AMM               date: 04-MAR-1988 15:30
#   general description:
#  Convert the SPACE-CRAFT clock seconds to date and time
#     This requires knowing the second,minute,hour,day and year
#     at which the SPACE-CRAFT clock was started.  This was saved
#     in HRISYS.
#  Updated to remove adjust_drift variable which was not used and
#  to call dget_filename.

procedure sclk_to_ut(sclk_time,refclk,utclk)

double	sclk_time		# i: Space craft seconds
pointer refclk			# i: pointer to reference clock settings
pointer utclk			# O: pointer to returned clock settings

int	year			# l: output year ( ex. '1990')
int 	month			# l: output month
int	day			# l: output day number in year ( ex. '93')
int	hour			# l: hours of day
int	minute			# l: minutes in hour

double	second			# l: seconds in minute

int	day_per_year[2]		
int	ref_second
int	seconds_per_year[2]

int	test
int	type
#  Make this error string a DATA initialized string to get round
#	the problem of SPP adding the string declaration AFTER
#	DATA statement and thus not being portable (see MAC/AUX)
char	errmsg[29]

int	mon[12,2]
      COMMON/BBLK1/MON

      DATA MON/0,31,59,90,120,151,181,212,243,273,304,334,
	       0,31,60,91,121,152,182,213,244,274,305,335 /

      DATA day_per_year/365,366/ # Days in NON-LEAP and LEAP-YEAR
      DATA seconds_per_year/31536000,31622400/
      DATA errmsg/'M','J','D','U','T',':',' ','T','I','M','E',' ','C','O','N','V','E','R','S','I','O','N',' ','E','R','R','O','R',EOS,EOS/ 

#    Seconds in NON-LEAP and LEAP-YEAR
#    sec_per_min * min_per_hour * hour_per_day * day_per_year(non-leap)
#    sec_per_min * min_per_hour * hour_per_day * day_per_year(leap)

begin
	second = sclk_time



#  Test for a leap year ( Doesn't worry about special CENTURY boundaries )
	year = YEAR(refclk)     #jcc - eg. YEAR(refclk) = 1998
	test = year / 4
	if( test * 4 == year ) 
	    type = LEAP
	else
	    type = NON_LEAP

#  Convert BASE parameters into the number of seconds from start of year
      ref_second = SECOND(refclk) + MINUTE(refclk)*SEC_PER_MIN +
		   HOUR(refclk) * SEC_PER_HOUR +
		   (DAY(refclk)-1)*SECONDS_PER_DAY

#  Make second count relative to beginning of base year
	second = second + dfloat(ref_second)

# Determine the Year
	while( second > seconds_per_year(type) )
	{
           second = second - dfloat( seconds_per_year(type))
           year = year + 1
           test = year / 4
	   if( test * 4 == year )
	      type = LEAP
	   else
	      type = NON_LEAP
	}


# Determine the day  - second is now second of the year
#  add one because even 1 second into a day makes it the current day
	day = idint( second / (SECONDS_PER_DAY)) + 1
	second = second - dfloat( (day-1) * (SECONDS_PER_DAY))

#  Determine the hour - second is now second of the day
	hour = second / (SECONDS_PER_HOUR)
	second = second - dfloat(hour * (SECONDS_PER_HOUR))

#  Determine the minute - second is now second of the hour
	minute = second / (SEC_PER_MIN)
	second = second - dfloat(minute* (SEC_PER_MIN))
      

#  The second is what's left

	YEAR(utclk)=year    #jcc - eg. YEAR(utclk) = 1998
	DAY(utclk)=day
	HOUR(utclk)=hour
	MINUTE(utclk)=minute
	SECOND(utclk)=idint(second)
	FRACSEC(utclk)=second - dfloat(SECOND(utclk))

	month=1
#  There was an error report at some point (appears to be lost) that
#     might imply that this should be <=, rather than <????
#  Need to wait for the test case before trying to make th change
#	MC	5/2/94  (originally done ??)
#	while( day  > mon[month+1,type] && month <= 12)
	while( day  > mon[month+1,type] && month < 12)
	{
	    month = month+1
	}
	if( month > 12 )
	    call error(1,errmsg )
	day = day - mon[month,type]
	MONTH(utclk) = month
	MDAY(utclk) = day

end


#
#  Convert date and time to UT ( Noon, of given reference day and year)
#
#  author : MO                date: 26-JAN-1988 14:51 
#
#  status: not tested
#
#   general description:
#  Convert date and time to UT ( Noon, of given reference day and year)
#
# JCC(5/98) - convert UT (utclk in yyyymmdd) to Julian Day (jd) of
#             given reference day(nrefday=87) and year (refyear=1975)
#

double procedure mutjd(refyear,nrefday,utclk)

int	refyear			# i: reference year for JD
int	nrefday			# i: reference day for JD
pointer	utclk			# i: pointer to clk structure
double	jd			# o: returned julian day


int	nday			# l: input day
int	leap			# l: number of leap years in input year
int	nleap			# l: number of leap years in reference year
int	month			# l: input month
int	mon[12,2]		# l: day number at beginning of each month
int	nyear			# l: input year
int	testyear

double	day			# l: input day
double	refday			# l : reference julian day

      COMMON/BBLK1/MON


begin

#  Strip out the input month, year and day
	nyear = YEAR(utclk)     #jcc- eg:  1998
	month = 1
	nday = DAY(utclk)
	testyear = nyear / 4
	if( testyear * 4 == nyear )
	    leap = LEAP
	else
	    leap = NON_LEAP
	while( nday  > mon[month+1,leap] && month < 12)
	    month = month+1
	if( month > 12 )
	    call error(1,"MJDUT: TIME CONVERSION ERROR" )
	nday = nday - mon[month,leap]

# save for posterity
	MONTH(utclk) = month
	MDAY(utclk) = nday
	
#  Convert the time ( in seconds ) to a fraction of a day
	day = dfloat(SECOND(utclk)) + FRACSEC(utclk)
#  Add the fractional day to the number of whole days
	day = day + dfloat(MINUTE(utclk)*SEC_PER_MIN) + 
		    dfloat(HOUR(utclk)*SEC_PER_HOUR)
	day = day / dfloat(SECONDS_PER_DAY) + dfloat(nday)
#  Determine the number of leap years in input year
	leap = nyear / 4

#  These three lines define the reference date
#      REF_YEAR = 90          # 1990
	nleap = refyear / 4   # number of leap days since reference year
#      REF_DAY = 87.5D0       # day of normal year March 28, noon
	refday = dfloat(nrefday) + .5D0

	nleap = leap - nleap  # number of leap years between ref year and cur yr
#  Adjust the reference day by the number of leap years in the reference year
#	refday = refday + dfloat(nleap)

#  Convert to Julian day
	jd = dfloat(365*(nyear-refyear))-refday + day + 
		        dfloat(nleap+mon[month,1])
	if((((4*leap)-nyear)==0)&&(month<=2))
	    jd = jd-1.0D0
	return(jd)
end

#
#  Convert D.P. Julian day to year,month,day, second and fractional second
#
#  author : MO                date: 2-FEB-1988 09:09  
#
#  status: not tested
#
#   general description:
#  Convert D.P. Julian day to year,month,day, second and fractional second
#
# JCC (5/98)-refyear=MJDREFYEAR=1975;
#            nrefday=MJDREFDAY=87 (March 28) ;
#
procedure mjdut(refyear,nrefday,ajul,utclk)

int	refyear 	# i: ref year for JD
int	nrefday		# i: ref day for JD

double	ajul		# i: julian day
pointer	utclk		# o: output UT clock record

int	days		# l: number of leap years in reference year
#int	idate[3]	# l: month,day, year
int	irem		# l: remaining days in year
int	month		# l: month index
int	nflag		# l: flag for julian date in reference year
int	nleap		# l: number of leap year cycles in julian day
int	noleap		# l: number of leap years in reference year
int	nyear		# l: year corresponding to julian day

double	fsec		# l: fractional seconds
double	refday		# l: reference day for julain day
double	rem		# l: local computed remaining days
double	tjul		# l: temporary julain day for computations
double	xdays		# l: reference day adjusted for leap years
double	xleap		# l: number of leap year cycles in julian day
double	year		# l: year corresponding to julian day

int	mon[12,2]
      COMMON/BBLK1/MON



begin

#  These three lines define the reference date
# JCC (5/98)-refyear=MJDREFYEAR=1975;
#            nrefday=MJDREFDAY=87 (March 28) ;
#      REF_YEAR = 90          # 1990
	noleap = refyear/4    # 1975/4=493
#      REF_DAY = 87.5D0       # day of normal year March 28, noon
	refday = dfloat(nrefday) + .5D0

#  Calculate the number of days from the last leap year to reference day
	days = refyear - (refyear/4) * 4    # 1975-1972=3years 
	xdays = dfloat((days*DAYS_PER_YEAR)) + refday  #new ref. to 3/28/1973
	tjul = ajul + xdays    #jcc -new julian days ref. to 1973,3,28, noon
#  Determine the number of leap year cycles ( 1461 = 4*365 + 1 )
	xleap = tjul / dfloat(DAYS_PER_4YEAR)
	nleap = int(xleap)    #jcc- #leap cycle since 1972
	if( abs(xleap) < EPSILOND ) 
	    nleap = nleap - 1
#  determine number of years since reference year
	tjul = tjul - dfloat(DAYS_PER_4YEAR * nleap)
	nleap = nleap + noleap    #jcc-get total leap yrs(noleap=1975/4=493)
	year = ( tjul/dfloat(DAYS_PER_YEAR))
	nflag = NON_LEAP 
	if( idint(year) == 0 ) 
	    nflag = LEAP
	nyear = idint(year)+nleap*4   #jcc- eg.  nyear = 1998
      
# Calculate the month
	rem = tjul - dfloat(idint(year)*DAYS_PER_YEAR)
	rem = rem+dfloat(nflag-1)
	irem = rem
	rem = rem - dfloat(irem)
	month = 1
	while( irem  > mon[month+1,nflag] && month < 12)
	    month = month+1
	if( month > 12 )
	    call error(1,"MJDUT: TIME CONVERSION ERROR" )
#  Calculate the day of the month
	DAY(utclk) = irem
	irem = irem-mon[month,nflag]
	YEAR(utclk) = nyear   #jcc- eg. YEAR(utclk) = 1998
#	MONTH(utclk) = 13-month
	MONTH(utclk) = month
	MDAY(utclk) = irem
#	idate[3] = nyear

#  Reformat
#	YYMMDD = IDATE(3) * 10000 + IDATE(1) * 100 + IDATE(2)
#  Convert a fractional day to seconds
	fsec = rem *dfloat(HOUR_PER_DAY)
	HOUR(utclk) = fsec
	fsec = (fsec - dfloat(HOUR(utclk))) * dfloat(MIN_PER_HOUR)
	MINUTE(utclk) = fsec
	fsec = (fsec - dfloat(MINUTE(utclk))) * dfloat(SEC_PER_MIN)
	SECOND(utclk) = fsec
	FRACSEC(utclk) = fsec - dfloat(SECOND(utclk))
end

procedure gt_qprefclk(qphead,refclk)
pointer	qphead		# i: pointer to qphead struct
pointer	refclk          # o: YEAR(refclk)=YYYY (jcc-eg. 1998)
int	jdref
int	dayoff
real	jdoff
double	jd

#int	x_geti()
#real	x_getr()
include	"xhead.com"

begin
	xheadtype = 1
	goto 99
entry	gt_imrefclk(qphead,refclk)
	xheadtype = 2
entry	gt_tbrefclk(qphead,refclk)
	xheadtype = 4
	goto 99

# 99	jdref = x_geti(qp,"XS-MJDRD")
#	jdoff = x_getr(qp,"XS-MJDRF")
#	dayoff = x_geti(qp,"XS-EVREF")
 99	jdref = QP_MJDRDAY(qphead)
	jdoff = QP_MJDRFRAC(qphead)
	dayoff = QP_EVTREF(qphead)
	jd = double(dayoff) + double(jdref)+double(jdoff)- MJDREFOFFSET
# all computations are done relative to a newer reference point to maintain
#	precision
	call mjdut(MJDREFYEAR,MJDREFDAY,jd,refclk) #jcc-eg. YEAR(refclk)=1998
end	

procedure calc_qpmjdtime(qphead,dpsecs,mjd)
pointer qphead			# i: input header handle 
double	dpsecs			# i: double precision seconds to convert to mjd
pointer	refclk,utclk		# l: structures for reference clock and UT
double  mutjd()			
double	mjd			# o: returned function value of Modified JD
include	"xhead.com"

begin
	xheadtype = 1
	goto 99
entry	calc_immjdtime(qphead,dpsecs,mjd)
	xheadtype = 2
entry	calc_tbmjdtime(qphead,dpsecs,mjd)
	xheadtype = 4
	goto 99

 99	call calloc(refclk,SZ_CLK,TY_STRUCT)  # or salloc
	call calloc(utclk,SZ_CLK,TY_STRUCT)   # or salloc

	switch(xheadtype){

	case 1:
	    call gt_qprefclk(qphead,refclk) #jcc: eg. YEAR(refclk)=1998
	case 2:
	    call gt_imrefclk(qphead,refclk)
	case 4:
	    call gt_tbrefclk(qphead,refclk)
	default:
	    call error(1,"Unknown header handle type")
	}
	call sclk_to_ut(dpsecs,refclk,utclk)

	mjd = mutjd(MJDREFYEAR,MJDREFDAY,utclk) + MJDREFOFFSET

	call mfree(refclk,TY_STRUCT)
	call mfree(utclk,TY_STRUCT)
end

#-----------------------------------------------------------------
# write out bary correction RDF parameters to the header of the
# output QPOE file
#-----------------------------------------------------------------
procedure qp_upbary(qp,qphead)
pointer	qp			#i: qpoe file handle
pointer	qphead		# i/o:	qphead structure to update
#pointer	qp_accessf()
begin
#       if( qp_accessf(qp, "BARYTIME") == YES )
#       {
#            call qp_deletef(qp, QP_BARCOR_PARAM)
#       }

#JCC(1/99)-these are the result from apply_bary : 
# TIMESYS  = QP_TIMESYS  = 'MJD     '
# TIMEREF  = QP_TIMEREF  = 'SOLARSYSTEM'
# CLOCKAPP = QP_CLOCKCOR =  T
       call strcpy("MJD",QP_TIMESYS(qphead),SZ_TIMESYS)
       call strcpy("SOLARSYSTEM",QP_TIMEREF(qphead),SZ_TIMEREF)
       QP_CLOCKCOR(qphead) = YES
end

