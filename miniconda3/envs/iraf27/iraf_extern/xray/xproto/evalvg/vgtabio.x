# $Header: /home/pros/xray/xproto/evalvg/RCS/vgtabio.x,v 11.0 1997/11/06 16:39:01 prosb Exp $
# $Log: vgtabio.x,v $
# Revision 11.0  1997/11/06 16:39:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:50  prosb
# General Release 2.4
#
#Revision 1.1  1994/07/15  13:45:12  chen
#Initial revision
#
# ------------------------------------------------------------------------
# Module:       vgtabio 
# Project:      PROS -- ROSAT RSDC
# Description:  routines to read/write table files. 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen  initial version January 1994 
#               {n} <who> -- <does what> -- <when>
# All procedures included:
#    eph_inittab.x, eph_rdtab.x, obi_inittab.x, obi_rdtab.x,
#    out_inittab.x, out_filltab.x
# ------------------------------------------------------------------------
include   "evalvg.h"
include   <iraf.h>
include   <tbset.h>

# ------------------------------------------------------------------------
# Module:       eph_inittab 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  open the ephemeris table file & init columns 
# -------------------------------------------------------------------------
procedure  eph_inittab (ephname, itp_eph, col_eph, row_eph)

char     ephname[ARB]           #ephemeris table filename

int      row_eph                #number of rows in eph table
int      tbpsta()

pointer  itp_eph                #table pointer
pointer  col_eph[ARB]           #table column pointer
pointer  tbtopn()

begin
# open the ephemeris table file, and get the row number
      itp_eph = tbtopn (ephname, READ_ONLY, 0)
      row_eph = tbpsta (itp_eph, TBL_NROWS)

#init the columns
      call tbcfnd (itp_eph, "mjd_int", col_eph[1], 1)
      call tbcfnd (itp_eph, "mjd_frac", col_eph[2], 1)
      call tbcfnd (itp_eph, "sun_x", col_eph[3], 1)
      call tbcfnd (itp_eph, "sun_y", col_eph[4], 1)
      call tbcfnd (itp_eph, "sun_z", col_eph[5], 1)
      call tbcfnd (itp_eph, "sat_x", col_eph[6], 1)
      call tbcfnd (itp_eph, "sat_y", col_eph[7], 1)
      call tbcfnd (itp_eph, "sat_z", col_eph[8], 1)
      call tbcfnd (itp_eph, "obi_num", col_eph[9], 1)
end

# ------------------------------------------------------------------------
# Module:       eph_rdtab 
# Project:      PROS -- ROSAT RSDC
# Description:  Read the information from the RDF ephemeris file. 
# Author:       Judy Chen    (20-JAN-1994)
# Description:  get data from the ephemeris table file 
# -------------------------------------------------------------------------
procedure eph_rdtab (display, itp_eph, col, row_cnt, imjdrefi, 
                     imjd_int, dmjd_frac, isun_pos, isat_pos, 
                     jd_mission, ut_secs_day)

pointer   itp_eph             #i: table pointer
pointer   col[ARB]            #i: table column pointer

bool      nullflag[10]        #l: for table input

int       display             #i: display level (0-5)
int       row_cnt             #i: loop counter
int       imjdrefi            #i: reference julian day
int       imjd_int            #o: integer julian day
int       isun_pos[ARB]       #o: sun position in unit vector
int       isat_pos[ARB]       #o: satellite position in meter

double    dmjd_frac           #o: fractional julian day
double    dsun_pos[3]         #l: sun position in unit vector
double    jd_mission          #o: data start time in mission julian days
double    ut_secs_day         #o: second of day

begin
#  get data from the ephemeris table
   call tbrgti (itp_eph, col[1], imjd_int, nullflag, 1, row_cnt)
   call tbrgtd (itp_eph, col[2], dmjd_frac, nullflag, 1, row_cnt)
   call tbrgtd (itp_eph, col[3], dsun_pos[X], nullflag, 1, row_cnt)
   call tbrgtd (itp_eph, col[4], dsun_pos[Y], nullflag, 1, row_cnt)
   call tbrgtd (itp_eph, col[5], dsun_pos[Z], nullflag, 1, row_cnt)
   call tbrgti (itp_eph, col[6], isat_pos[X], nullflag, 1, row_cnt)
   call tbrgti (itp_eph, col[7], isat_pos[Y], nullflag, 1, row_cnt)
   call tbrgti (itp_eph, col[8], isat_pos[Z], nullflag, 1, row_cnt)

   isun_pos[X] = nint(dsun_pos[X]*1.0D8)
   isun_pos[Y] = nint(dsun_pos[Y]*1.0D8)
   isun_pos[Z] = nint(dsun_pos[Z]*1.0D8)

#  convert MJD to Mission JD where the start of the mission
#  is jd_mission = 0
   jd_mission = imjd_int - imjdrefi + dmjd_frac - 0.5
   ut_secs_day = dmjd_frac * SEC_HR * HR_DAY

#  display information
   if (display >= 2)   {
      call printf ("eph_rdtab: jdfrac=%12.6f, sat_x=%10d\n")
      call pargd (dmjd_frac)
      call pargi (isat_pos[X])
      call printf ("eph_rdtab: jd_rec=%12.6f, ut_sec=%12.2f\n")
      call pargd (jd_mission)
      call pargd (ut_secs_day)
   }
end     

# -------------------------------------------------------------------------
# Module:       obi_inittab 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  open a table file & init columns
# -------------------------------------------------------------------------
procedure  obi_inittab (obiname, itp_obi, col_obi, row_obi)

char     obiname[ARB]           #obi table filename

int      row_obi                #number of rows in obi table
int      tbpsta()

pointer  itp_obi                #table pointer
pointer  col_obi[ARB]           #table column pointer
pointer  tbtopn()

begin
# open the obi table file, and get the row number
      itp_obi = tbtopn (obiname, READ_ONLY, 0)
      row_obi = tbpsta (itp_obi, TBL_NROWS)

#init the columns
      call tbcfnd (itp_obi, "obib", col_obi[1], 1)
      call tbcfnd (itp_obi, "obie", col_obi[2], 1)
      call tbcfnd (itp_obi, "start_date", col_obi[3], 1)
      call tbcfnd (itp_obi, "start_time", col_obi[4], 1)
      call tbcfnd (itp_obi, "stop_date",  col_obi[5], 1)
      call tbcfnd (itp_obi, "stop_time",  col_obi[6], 1)
end

# ------------------------------------------------------------------------
# Module:       obi_rdtab
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  Read the information from the RDF OBI file.
# -------------------------------------------------------------------------
procedure  obi_rdtab (display, itp_obi, col_obi, obi_num, sc_time,
                      bdate, btime, edate, etime)

int      display              #i: display level (0-5)
int      obi_num              #i: obi number
int      sc_time[ARB]         #o: start/stop time for each OBI

pointer  itp_obi              #i: pointer for *_obi.tab
pointer  col_obi[ARB]         #i: tabel column pointer

char     bdate[ARB]           #o: start date 
char     btime[ARB]           #o: start time
char     edate[ARB]           #o: stop date
char     etime[ARB]           #o: stop time

bool     nullflag[10]         #l: for table input

begin
#  get data from OBI file 
   call tbrgti (itp_obi, col_obi[1], sc_time[START], nullflag,
                1, obi_num)
   call tbrgti (itp_obi, col_obi[2], sc_time[STOP], nullflag,
                1, obi_num)
   call tbrgtt (itp_obi, col_obi[3], bdate,
                nullflag, SZ_LINE, 1, obi_num)
   call tbrgtt (itp_obi, col_obi[4], btime,
                nullflag, SZ_LINE, 1, obi_num)
   call tbrgtt (itp_obi, col_obi[5], edate, 
                nullflag, SZ_LINE, 1, obi_num)
   call tbrgtt (itp_obi, col_obi[6], etime,
                nullflag, SZ_LINE, 1, obi_num)

#  print out sc_time
   if (display >= 2)   {
      call printf("***************************************************\n")
      call printf("obi_rdtab: obinum=%2d, sc_btime=%10d, sc_etime=%10d\n")
      call pargi(obi_num)
      call pargi(sc_time[START])
      call pargi(sc_time[STOP])
   }
end

# -------------------------------------------------------------------------
# Module:       out_inittab 
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  open a table file & init columns to write 
# -------------------------------------------------------------------------
procedure  out_inittab (outname, itp_out, col_out, clobber)

char     outname[ARB]           #output table filename
bool     clobber                # clobber old file
int      tbtacc()               #l: table access function
pointer  itp_out                #table pointer
pointer  col_out[ARB]           #table column pointer
pointer  tbtopn()

begin

# Clobber old file if it exists
   if (tbtacc(itp_out) == YES )   {
      if ( clobber )   {
         iferr ( call tbtdel(itp_out) )
            call eprintf("Can't delete old Table \n")
      }
      else   {
         call eprintf("Table file already exists \n")
      }
   }

# open the output table file
   itp_out = tbtopn(outname, NEW_FILE, 0) 

# define columns
   call tbcdef(itp_out,col_out[1],"SC_TIME","S","%10d",TY_INT,1,1)
   call tbcdef(itp_out,col_out[2],"EST_ANGLE","DEG","%12.5f",TY_REAL,1,1)
   call tbcdef(itp_out,col_out[3],"SES_ANGLE","DEG","%12.5f",TY_REAL,1,1)
   call tbcdef(itp_out,col_out[4],"OBI_NUM","NONE","%4d",TY_INT,1,1)

# Now actually create it
   call tbtcre(itp_out)

end

# -------------------------------------------------------------------------
# Module:       out_filltab
# Project:      PROS -- ROSAT RSDC
# Author:       Judy Chen    (20-JAN-1994)
# Description:  write time and two angles to the output table file 
# -------------------------------------------------------------------------
procedure  out_filltab (itp_out, col_out, row_num, sc_rec,
                        est_angle, ses_angle, obi_num)

pointer  itp_out                #i: table pointer
pointer  col_out[ARB]           #i: table column pointer
int      row_num                #i: current table row to write
int      sc_rec                 #i: space-craft time of current orb record
int      obi_num                #i: obi number
real     est_angle              #i: earth satellite pointing
real     ses_angle              #i: sun earth satellite angle

begin

   call tbrpti(itp_out, col_out[1], sc_rec, 1, row_num)
   call tbrptr(itp_out, col_out[2], est_angle, 1, row_num)
   call tbrptr(itp_out, col_out[3], ses_angle, 1, row_num)
   call tbrpti(itp_out, col_out[4], obi_num, 1, row_num)

end 
