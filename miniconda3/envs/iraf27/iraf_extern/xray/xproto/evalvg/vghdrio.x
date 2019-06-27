# $Header: /home/pros/xray/xproto/evalvg/RCS/vghdrio.x,v 11.1 1999/09/21 13:57:47 prosb Exp $
# $Log: vghdrio.x,v $
# Revision 11.1  1999/09/21 13:57:47  prosb
# JCC (8/11/98) - Added the call to format_date/libpros.a in get_date()
#                 before calling 'decode_int'; format_date is used to
#                 convert DD/MM/YY to YYYY-MM-DD or to keep YYYY-MM-DD.
#
# Revision 11.0  1997/11/06 16:39:00  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:48  prosb
# General Release 2.4
#
#Revision 1.1  1994/07/15  13:46:50  JCC 
#Initial revision
#
# ------------------------------------------------------------------------
# Module:       vghdrio 
# Project:      PROS -- ROSAT RSDC
# Description:  routines to get i/o from obi header 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen  initial version January 1994 
#               {1} Judy Chen - July 1994 - remove "get_launch_jd.x"
#               {n} <who> -- <does what> -- <when>
# All procedures included:
#    get_date_tim.x, get_date.x, get_time.x, decode_int.x, get_obihd_inf.x
# ------------------------------------------------------------------------
include    "evalvg.h"
include    <ctype.h>
include    <math.h>
include    <iraf.h>
include    <clk.h>

# ------------------------------------------------------------------------
# Module:       get_date_tim 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get date and time from OBI file
# -------------------------------------------------------------------------
procedure get_date_tim(display, bedate, betime, utclk)

int      display              #i: display level (0-5)
pointer  bedate               #i: character string for date
pointer  betime               #i: character string for time
pointer  utclk                #o: pointer to clk structure

begin

    call get_date (display, Memc[bedate], utclk)
    call get_time (display, Memc[betime], utclk)

end

# ------------------------------------------------------------------------
# Module:       get_date 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get the date from OBI file  
# -------------------------------------------------------------------------
procedure get_date(display, cstring, utclk)

int      display              #i: display level (0-5)
int      num_tot              #l: number of retured array
int      ret_int[10]          #l: returned integer value

char     cstring[ARB]         #i: character string
pointer  utclk                #o: pointer to clk structure
char     outstr[25]          #l: out string(YYYY-MM-DD) from format_date

begin

    #JCC(8/11/98) - add the call to format_date();
    #  cstring can be 'DD/MM/YY' or 'YYYY-MM-DD' ;
    #  but outstr will be always 'YYYY-MM-DD'
    call format_date(cstring, outstr)

    #JCC(8/11/98) - Replace cstring with outstr (YYYY-MM-DD)
    call decode_int(display, outstr, num_tot, ret_int)

    #JCC(8/11/98) - YEAR from 1st elem, MDAY from 3rd elem. 
    #YEAR(utclk) = ret_int[3]
    #MDAY(utclk) = ret_int[1]
    YEAR(utclk) = ret_int[1]
    MONTH(utclk) = ret_int[2]
    MDAY(utclk) = ret_int[3]

    if (display >= 2)   {
       call printf("get_date: cstring=%15s, outstr=%15s, YEAR=%d\n")
       call pargstr(cstring)
       call pargstr(outstr)
       call pargi(YEAR(utclk))
    }
end

# ------------------------------------------------------------------------
# Module:       get_time 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get the time from OBI file   
# -------------------------------------------------------------------------

procedure get_time(display, cstring, utclk)

int      display              #i: display level (0-5)
int      num_tot              #l: number of retured array
int      ret_int[10]          #l: returned integer value

char     cstring[ARB]         #i: character string

pointer  utclk                #o: pointer to clk structure

double   fract                #l: fractional second

begin

    call decode_int(display, cstring, num_tot, ret_int)

    if (num_tot < 4)   {
       fract = 0.0D0
    }
    else   {
       fract = dfloat(ret_int[4])
    }

    HOUR(utclk) = ret_int[1]
    MINUTE(utclk) = ret_int[2]
    SECOND(utclk) = ret_int[3]
    FRACSEC(utclk) = fract

    if (display >= 2)   {
       call printf("get_time:  hr:min:sec.frsec =%15s\n")
       call pargstr(cstring)
    }
end

# ------------------------------------------------------------------------
# Module:       get_time
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  convert character string to integers and put them
#               into an array. any character other than "0-9" is 
#               considered as a delimiter. 
# -------------------------------------------------------------------------

procedure  decode_int (display, cstring, num_tot, ret_int)

char    cstring[ARB]   #i: character string 

int     display        #i: display level (0-5)
int     num_tot        #o: number of retured array
int     ilen           #l: the length of the string
int     idx            #l: starting position for conversion
int     ret_int[ARB]   #l: returned integer value
int     num_char       #l: number of characters to be converted
int     ctoi()
int     strlen()

begin
#  get the length of character string 
   ilen = strlen(cstring)

   idx = 1
   num_tot = 1

#  convert string to integers
   while ( idx<= ilen )  {
      num_char = ctoi (cstring, idx, ret_int[num_tot])
      idx = idx + 1

      if (display >= 5)  {
         call printf("idx=%d,ilen=%d,string=%s,num_char=%d,ret_int=%d \n ")
         call pargi(idx)
         call pargi(ilen)
         call pargstr(cstring)
         call pargi(num_char)
         call pargi(ret_int[num_tot])
      }
      num_tot = num_tot + 1
   }
   num_tot = num_tot - 1
end

# ------------------------------------------------------------------------
# Module:       get_obihd_inf
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get the target vector from the nominal ra&dec in the
#               OBI file and get the reference julian day 
# -------------------------------------------------------------------------

procedure get_obihd_inf (itp_obi, target_vector, imjdrefi)

pointer itp_obi             # table pointer

double  ra_nom              # RA in degree
double  dec_nom             # DEC in degree
double  tbhgtd()            # get data from table header

int     imjdrefi            # reference julian day
int     tbhgti()

real    target_vector[ARB]  # unit vector earth to tar
real    nom_ra_radians      # nominal right ascension
real    nom_dec_radians     # nominal declination

begin

# get the nominal pointing direction from OBI file,
# these are in units of degree.
      ra_nom = tbhgtd (itp_obi, "ra_nom")
      dec_nom = tbhgtd (itp_obi, "dec_nom")
 
#  get the reference JD from the OBI header
      imjdrefi = tbhgti (itp_obi, "mjdrefi")

# convert integer .1 arc secs to real radians
      nom_ra_radians = DEGTORAD(real(ra_nom))
      nom_dec_radians = DEGTORAD(real(dec_nom))

# convert it to a vector
      call sphere_to_cart(nom_ra_radians,nom_dec_radians,
                          target_vector)

end 
