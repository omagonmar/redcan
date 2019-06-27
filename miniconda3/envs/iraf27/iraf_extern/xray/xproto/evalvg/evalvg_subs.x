# $Header: /home/pros/xray/xproto/evalvg/RCS/evalvg_subs.x,v 11.1 1999/09/21 13:54:49 prosb Exp $
# $Log: evalvg_subs.x,v $
# Revision 11.1  1999/09/21 13:54:49  prosb
# JCC(8/11/98) - Added 'format_date' in 'get_date' to have YEAR in the
#                format of YYYY ;  Updated YEAR in 'yymmdd_to_jd'.
#
# Revision 11.0  1997/11/06 16:38:59  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:45  prosb
# General Release 2.4
#
#Revision 1.2  1994/07/20  13:40:59  chen
#jchen - retrieve JDDAY from <bary.h>
#
#Revision 1.1  94/07/14  14:11:22  chen
#Initial revision
#
# ------------------------------------------------------------------------
# Module:       evalvg_subs
# Project:      PROS -- ROSAT RSDC
# Description:  Viewing Geometry subroutines 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen  initial version January 1994 
#               {1} Judy Chen - July 1994 - update "conv_sat_units.x
#                   & det_sat_ang.x"; include <bary.h> for JDDAY
#               {n} <who> -- <does what> -- <when>
# All procedures included:
#    check_first.x, chkvector.x, comp_grt_cir_ang.x, conv_sat_units.x,
#    det_sat_ang.x, get_jd_ref_date.x, hms_to_rad.x, mod_utjd.x,
#    normalize_3vector.x, resolve_time.x, rotate_coords.x,
#    sphere_to_cart.x, vg_outtable.x, write_screen.x, yymmdd_to_jd.x
# ------------------------------------------------------------------------
include   "evalvg.h"
include   <math.h>
include   <iraf.h>
include   <clk.h>
include   <bary.h>

# ------------------------------------------------------------------------
# Module:       check_first 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  check to see whether the current record in ephemeris file 
#               is the first one for each OBI.
# -------------------------------------------------------------------------
procedure check_first( itp_eph, row_cnt, col, first, obi_curr )

pointer itp_eph               #i: pointer for *_eph.tab
pointer col[ARB]              #i: eph table column pointer

int     obi_prev              #l: the previous OBI number
int     obi_curr              #l: the current OBI number 
int     row_cnt               #i: the current record # 

bool    nullflag[10]          #l: for table input 
bool    first                 #l: logical indicating the first record
                              #   for each OBI.

data    obi_prev /1/          #l: indicate the beginning of eph file

save    obi_prev

begin
   call tbrgti (itp_eph, col[9], obi_curr, nullflag, 1, row_cnt)

   # It is the first record of each OBI, if the OBI number is changed;
   # or if it is right at the beginning of the eph file.

   if (row_cnt == 1)   {
      first = true 
   }
   else   {
      if (obi_curr == obi_prev)   {
         first = false 
      }
      else   {
         first = true 
      }
   }

   obi_prev = obi_curr

#   return (first)

end

# ------------------------------------------------------------------------
# Module:       chkvector 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  checks to see if a vector is zero. 
# -------------------------------------------------------------------------
bool procedure chkvector(vector)

real        vector[ARB]         # vector to check
real        unit  
bool        result

begin
      unit = vector[X] + vector[Y] + vector[Z]

      if ( unit == 0 ) {
         result = FALSE 
      }
      else {
         result = TRUE
      }
      return(result)
end

# ------------------------------------------------------------------------
# Module:       comp_grt_cir_ang 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  compute the great circle angle between two unit vectors
#               and returns an angle in radians.
# ------------------------------------------------------------------------
real procedure comp_grt_cir_ang(vector_one ,vector_two)

real    vector_one[ARB]         # 1st vector ( from )
real    vector_two[ARB]         # 2nd vector ( to )

real    diff_x                  # differance in x components
real    diff_y                  # differance in y components
real    diff_z                  # differance in z components
real    dot                     # dot product of the differance vector
real    result                  # the great circle angle betw' two unit vectors

begin
      diff_x = vector_one[X] - vector_two[X]
      diff_y = vector_one[Y] - vector_two[Y]
      diff_z = vector_one[Z] - vector_two[Z]

      dot = ( diff_x ** 2 ) + ( diff_y ** 2 ) + ( diff_z ** 2 ) 

      if ( dot .ge. COLINEAR_SQUARE )  {
            result = PI
      } 
      else  {
            result = 2.0 * atan( sqrt(dot) / sqrt(4.0 - dot))
      }
      return(result)
end     

# ------------------------------------------------------------------------
# Module:       conv_sat_units 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  convert the sun and satellite positions from units
#               based on an earth-centered rotating frame of reference
#               to units based on a frame of reference fixed on inertial
#               space.
# Modified:     {1} Judy Chen - July 1994 - calculate RDF true jd directly
#                   from RDF ephemeris table file instead of using
#                   launch_jd & jd_mission. 
#               {n} <who> -- <does what> -- <when>
# ------------------------------------------------------------------------
##procedure conv_sat_units(launch_jd, jd_mission, ut_secs_day, sat_vector,
procedure conv_sat_units(display, imjd_int, dmjd_frac, ut_secs_day,
                         sat_vector, sun_vector)

##double jd_mission               #data start time in mission julian day 
double    ut_secs_day              #secs of day
double    dc                       #julian day in century
double    djul                     #julian date for given time
double    dsid1                    #sidereal time component
double    dsid2                    #sidereal time in seconds
double    dsid3                    #sidereal time in hours
##double    launch_jd                #julian day of rosat launch
double   dmjd_frac                 #fractional julian day

int       display                  #i: display level (0-5)
int       imjd_int                 #integer julian day
int       sidh                     #hours of sidereal time
int       sidm                     #minutes of sidereal time
int       vidx                     #index to vector arrays

real      sat_vector  [ARB]        #normalized satellite position
real      sun_vector  [ARB]        #normalized sun unit vector [x,y,z]
real      dsid                     #sidereal time in hours
real      hms_to_rad               #computes radians from h-m-s
real      sat_fspace[3]            #satellite pos-fixed,inertial
real      smin                     #sidereal time in minutes 
real      sids                     #seconds for sidereal time
real      sun_fspace[3]            #sun vector-fixed,inertial frame
real      theta                    #angle in radians


begin
# calculate current julian day and sidereal time. the x-axis is
# pointing from the center of the earth out through the earth's
# surface at 0,0 longitude,latitude in the ecf frame.
# this transforms the fixed frame to a rotating frame.
      
      djul = JDDAY + imjd_int + dmjd_frac - 0.5
##      djul = launch_jd + jd_mission
##    call printf("conv_sat:jd_mission=%10.6f launch_jd=%11.2f djul=%15.6f\n")
##      call pargd (jd_mission)
##      call pargd (launch_jd)
      if (display >= 5)   {
         call printf("conv_sat_units: djul=%15.6f\n")
         call pargd (djul)
      }

      dc = ( djul - JD_1900 )/DAY_CENTURY
      dsid1 = dc*( VE_CENTURY + ( PRECSS_CORR*dc ))
      dsid2 = ( dsid1 + VE_ANGLE +  ut_secs_day )/SEC_HR
      dsid3 = mod( dsid2,HR_DAY )
      dsid  = real(dsid3)

# convert hours to h-m-s and then to radians

      sidh = int(dsid)
      smin = (dsid - sidh)*60.0
      sidm = int(smin)
      sids = (smin - sidm)*60.0
      theta = hms_to_rad(sidh,sidm,sids)

# transform rotating(on the sky) coord system to a fixed system
# where the x-axis points towards ra,dec = 0,0

      call rotate_coords(sat_vector[X],sat_vector[Y],theta,
                         sat_fspace[X],sat_fspace[Y])
      sat_fspace[Z] = sat_vector[Z]
      call rotate_coords(sun_vector[X],sun_vector[Y],theta,
                         sun_fspace[X],sun_fspace[Y])
      sun_fspace[Z] = sun_vector[Z]

      for(vidx=1; vidx<=3; vidx=vidx+1) {
        sat_vector[vidx] = sat_fspace[vidx]
        sun_vector[vidx] = sun_fspace[vidx]
      }
end

# -------------------------------------------------------------------------
# Module:       det_sat_angles
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  Compute the angles from objects' positions.
# Modified:     {1} Judy Chen - July 1994 - "launch_jd, jd_mission" are
#                   not needed since "conv_sat_units.x" is updated.
#               {n} <who> -- <does what> -- <when>
# -------------------------------------------------------------------------
##procedure det_sat_ang (display, launch_jd, jd_mission, ut_secs_day,
procedure det_sat_ang (display, imjd_int,dmjd_frac, ut_secs_day,
                       sun_pos, sat_pos, target_vector, est_angle,
                       ses_angle)

int      display                #i: display level (0-5)
int      sat_pos[ARB]           # satellite position in meter
int      sun_pos[ARB]           # sun position in unit vector
int      vidx                   # index to vector arrays
int      imjd_int             #integer julian day

double   dmjd_frac            #fractional julian day
##double   launch_jd              # JD of satellite launch
##double   jd_mission             #data start time in mission julian day.
double   ut_secs_day            # secs of day

bool     chkvector              # function t->vector is zero

real     target_vector[ARB]     # unit vector earth to target
real     est_angle              # earth satellite pointing
real     ses_angle              # sun earth satellite angle
real     comp_grt_cir_ang       # function return gc angle
real     est_radians            # est in radians
real     sat_vector[3]          # unit vector earth to sat
real     ses_radians            # ses in radians
real     sun_vector[3]          # unit vector earth to sun

begin
   for (vidx=1; vidx<=3; vidx=vidx+1) {
      sun_vector[vidx] = real(sun_pos[vidx])
      sat_vector[vidx] = real(sat_pos[vidx])
   }

#  if vectors are not zero then convert them to unit vectors
   if (chkvector(sun_vector) && chkvector(sat_vector)) {
      call normalize_3vector(sun_vector,sun_vector)
      call normalize_3vector(sat_vector,sat_vector)

      #convert frame of reference from rotating earth-centered to
      #fixed on inertial space
##      call conv_sat_units(launch_jd, jd_mission, ut_secs_day,
      call conv_sat_units(display, imjd_int, dmjd_frac, ut_secs_day,
                          sat_vector, sun_vector)

      #compute SES & EST angles after the sun and sat vectors are defined
      ses_radians = comp_grt_cir_ang (sun_vector,sat_vector)
      est_radians = PI - comp_grt_cir_ang (target_vector,sat_vector)
   }
#  if one of the read vectors is zero ( possible bad data file )
   else   {
       est_radians = 0.0
       ses_radians = 0.0
   }
#  convert the angels to degrees and return
   est_angle = RADTODEG(est_radians)
   ses_angle = RADTODEG(ses_radians)

#  display information
   if (display >= 2)   {
      call printf("det_sat_ang:  est_angle=%12.6f,ses_angle=%12.6f\n\n")
      call pargr (est_angle)
      call pargr (ses_angle)
  }
end

# ------------------------------------------------------------------------
# Module:       get_jd_ref_date 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get the space craft clock start time, rosat julian
#               day will use this as a reference
# ------------------------------------------------------------------------
procedure get_jd_ref_date(ref_yr,ref_dd)

int     ref_yr           # returned start year of space-craft clock
int     ref_dd           # returned start day of space-craft clock
int     loc_ref_year     # the local reference year
int     loc_ref_day      # the local reference day 

bool    first            # flag for first call
data    first/true/
save    loc_ref_year, loc_ref_day, first

begin
# get start date of space-craft clock and rosat modified julian day
# will be from this reference
      if( first )  { 
         loc_ref_year = SYS_REF_YEAR
         loc_ref_day = SYS_REF_DAY
         loc_ref_year = loc_ref_year - 1900   #JCC-no change
         first = false
      }
      ref_yr = loc_ref_year
      ref_dd = loc_ref_day
end     

# ------------------------------------------------------------------------
# Module:       hms_to_rad 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  convert hours minutes seconds to radians
# ------------------------------------------------------------------------
real procedure hms_to_rad(hours, minutes, seconds)

int      hours     # hours = integer number of hours
int      minutes   # minutes = integer number of minutes

real     seconds   # seconds = real number of seconds
real     result

begin
      result = seconds * 0.00007272205208
      result = result + real(minutes) * 0.004363323125
      result = result + real(hours) * 0.2617993875
      return(result)
end     

# ------------------------------------------------------------------------
# Module:       mod_utjd 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  return modified julian day using space-craft 
#               clock reference time 
# ------------------------------------------------------------------------
double procedure mod_utjd(utclk)

int     ref_yy     # reference year for computing modified julian day
int     ref_dy     # reference day for computing modified julian day

bool    first      # flag for the first call

double  yymmdd_to_jd # routine to calculate modified julian date
double  jd         # returned modified julian day

pointer utclk      # pointer to clk structure

data    first/true/
save    first

begin
# get the reference date for the modified julian day
      if( first ) { 
         call get_jd_ref_date(ref_yy, ref_dy)
         first = false
      }

# calculate the modified julian day
      jd = yymmdd_to_jd(ref_yy, ref_dy, utclk)
      return(jd)
end     

# ------------------------------------------------------------------------
# Module:       normalize_3vector 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  normalize an input three vector 
# ------------------------------------------------------------------------
procedure      normalize_3vector(vector,norm_vector)

real            vector[ARB]           # input vector ( non-zero )
real            norm_vector[ARB]      # normalized output vector (unit)
real            sum                   # sum of the component squares
real            v1square              # x component **2
real            v2square              # y component **2
real            v3square              # z component **2

begin
      v1square = vector[X] ** 2
      v2square = vector[Y] ** 2
      v3square = vector[Z] ** 2

      sum = v1square + v2square + v3square

      sum = sqrt ( sum )

      norm_vector[X] = vector[X] / sum 
      norm_vector[Y] = vector[Y] / sum 
      norm_vector[Z] = vector[Z] / sum
end     

# ------------------------------------------------------------------------
# Module:       resolve_time 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  interpolate the space-craft time for each orbit
#               record in ut time. 
# ------------------------------------------------------------------------
procedure resolve_time( display, jd_time, sc_time, jd_rec, sc_rec)

int    display         #i: display level (0-5)
int    sc_time[ARB]    # start and stop of obi in space-craft seconds
int    sc_rec          # space-craft time of current orb record

double jd_time[ARB]    # start and stop of obi in julian date
double jd_rec          # julian date of current orb record
double denom_jd        # denominator of jd ratio
double denom_sc        # denominator of sc ratio
double num_jd          # numerator of jd ratio
double num_sc          # numerator of sc ratio
double num_sc_sign     # compare num_sc with zero


begin
#  following are the correspondences between the times. we will form
#  a ratio on each side by taking the difference of the top two values
#  and dividing by the difference between the top and bottom values
#  and then equating the ratios from both sides
#  jd_time[START] < ------- > sc_time[START]
#  jd_rec < ------- > sc_rec(output)
#  jd_time[STOP] < ------- > sc_time[STOP]

   num_jd = jd_rec - jd_time[START]

   denom_jd = jd_time[STOP] - jd_time[START]
   denom_sc = dfloat( sc_time[STOP] - sc_time[START] )

   if (denom_jd != 0.0D0) {
      num_sc = num_jd * (denom_sc / denom_jd)
   }
   else   {
      num_sc = 0.0
   }

   if (num_sc < 0.0D0) {
      num_sc_sign = -1.0D0
   }
   else   {
      num_sc_sign = 1.0D0
   }

   sc_rec = sc_time[START] + int( num_sc + 0.5 * num_sc_sign )

   if (display >= 2)   {
      call printf ("resolve_time: jd_rec=%12.6f,sc_rec=%10d\n")
      call pargd (jd_rec)
      call pargi (sc_rec)
      }
      
end

# ------------------------------------------------------------------------
# Module:       rotate_coords 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  applies a rotation matrix of theta radians to 
#               coordinates yin, zin.
# ------------------------------------------------------------------------
procedure rotate_coords(yin, zin, theta, yout, zout)

real yin                   # input y coordinate
real zin                   # input z coordinate
real theta                 # rotation angle in radians

real yout                  # rotated y coordinate
real zout                  # rotated z coordinate

begin
      yout = yin * cos(theta) - zin * sin(theta)
      zout = yin * sin(theta) + zin * cos(theta)
end     

# ------------------------------------------------------------------------
# Module:       sphere_to_cart 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  convert from sphereical coordinates to cartesian
#               coordinates 
# ------------------------------------------------------------------------
procedure sphere_to_cart(ra_rad,dec_rad,cart)

real    ra_rad 
real    dec_rad 
real    cart[ARB]

begin
      cart[X]   = cos(ra_rad) * cos(dec_rad)
      cart[Y]   = sin(ra_rad) * cos(dec_rad)
      cart[Z]   = sin(dec_rad)
end     

# ------------------------------------------------------------------------
# Module:       vg_outtable 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  Read filename and clobber parameters and create output
#               filename 
# ------------------------------------------------------------------------
procedure vg_outtable(param,ext,master_name,output_name,tempname,clobber)

char    param[ARB]              # i: parameter name
char    ext[ARB]                # i: output file extension

pointer master_name             # i: input template name
pointer output_name             # o: output filename
pointer tempname                # o: temp filename
pointer sp

bool    clobber                 # o: clobber value
bool    streq()

begin

#   Get input/output filenames
        call smark(sp)
        call clgstr (param, Memc[output_name], SZ_PATHNAME)
        call rootname(Memc[master_name],Memc[output_name], ext, SZ_PATHNAME)
        if (streq("NONE", Memc[output_name]) ) {
           call error(1, "requires table file as output")
        }
        call clobbername(Memc[output_name],Memc[tempname],clobber,SZ_PATHNAME)
        call sfree(sp)
end

# ------------------------------------------------------------------------
# Module:       write_screen 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  display data on the screen 
# ------------------------------------------------------------------------
procedure   write_screen (display, sc_rec, est_ang, ses_ang, obi_num)

int      display              #i: display level (0-5)
int      sc_rec               #i: space-craft time of current orb record
int      obi_num              #i: obi number 

real     est_ang              #i: earth satellite pointing
real     ses_ang              #i: sun earth satellite angle

begin
#  print out angles when display level is greater than 5 
   if (display >= 5)   {
      call printf("SC_TIM=%10d,EST_ANG=%12.6f,SES_ANG=%12.6f,OBI_NUM=%2d\n\n")
      call pargi (sc_rec)
      call pargr (est_ang)
      call pargr (ses_ang)
      call pargi (obi_num)
   }

end

# ------------------------------------------------------------------------
# Module:       yymmdd_to_jd 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  convert UT to JD with input format yymmdd. 
# ------------------------------------------------------------------------
double procedure yymmdd_to_jd(refyear,nrefday,utclk)

pointer	utclk			# i: pointer to clk structure

int	refyear			# i: reference year for JD
int	nrefday			# i: reference day for JD
int	nday			# l: input day
int	leap			# l: number of leap years in input year
int	nleap			# l: number of leap years in reference year
int	month			# l: input month
int	mon[12,2]		# l: day number at beginning of each month
int	nyear			# l: input year

double	day			# l: input day
double	jd			# l: returned julian day
double	refday			# l : reference julian day

char	msg[15]                 # UR: avoid xc producing invalid ForTran

COMMON/BBLK1/MON
DATA MON/0,31,59,90,120,151,181,212,243,273,304,334,
         0,31,60,91,121,152,182,213,244,274,305,335 /

begin
   #JCC(8/11/98) - nyear is #years relative to 1900. And YEAR 
   #               has been updated to 4 digits (YYYY)
   #nyear = YEAR(utclk)  ## JCC
   nyear = YEAR(utclk) - 1900

   # UR: silly workaround to avoid xc producing invalid ForTran by adding
   # variable declarations after the DATA statement.
   # Encoded string is: "  nyear = %d\n "
   msg[0]=32; msg[1]=32; msg[2]=110; msg[3]=121; msg[4]=101; msg[5]=97
   msg[6]=114; msg[7]=32; msg[8]=61; msg[9]=32; msg[10]=37; msg[11]=100
   msg[12]=10; msg[13]=32; msg[14]=0
   call printf(msg)
   call pargi(nyear)

   month = MONTH(utclk)
   nday  = MDAY(utclk)
	
#  Convert the time ( in seconds ) to a fraction of a day
   day = dfloat(SECOND(utclk)) + FRACSEC(utclk)

#  Add the fractional day to the number of whole days
   day = day + dfloat(MINUTE(utclk)*SEC_PER_MIN) + 
         dfloat(HOUR(utclk)*SEC_PER_HOUR)
   day = day / dfloat(SECONDS_PER_DAY) + dfloat(nday)

#  Determine the number of leap years in input year
   leap = nyear / 4

#  These three lines define the reference date
   nleap = refyear / 4   # number of leap days since reference year
   refday = dfloat(nrefday) + .5D0

   nleap = leap - nleap  # number of leap years between ref year and cur yr

#  Convert to Julian day
   jd = dfloat(365*(nyear-refyear))-refday + day + 
        dfloat(nleap+mon[month,1])
   if((((4*leap)-nyear)==0)&&(month<=2))
   jd = jd-1.0D0
   return(jd)
end
