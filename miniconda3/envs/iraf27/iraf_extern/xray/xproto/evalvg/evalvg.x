# $Header: /home/pros/xray/xproto/evalvg/RCS/evalvg.x,v 11.0 1997/11/06 16:38:58 prosb Exp $
# $Log: evalvg.x,v $
# Revision 11.0  1997/11/06 16:38:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:44  prosb
# General Release 2.4
#
#Revision 1.2  1994/07/20  12:02:22  chen
#jchen - use "rootname" to identify eph & obi tables.
#
#Revision 1.1  94/07/14  14:04:07  chen
#Initial revision
#
# -------------------------------------------------------------------------
# Module:       evalvg 
# Project:      PROS -- ROSAT RSDC
# Description:  Compute the SES & EST angles from the RDF ephemeris file. 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen initial version January 1994
#               {1} Judy Chen - 6/28/94 -
#                   calculate RDF true jd in each record (i.e. djul) from
#                   RDF ephemeris table : remove "get_launch_jd.x", 
#                   update "evalvg.x, det_sat_ang.x, conv_sat_units.x";
#                   variable "launch_jd" is no longer needed;
#                   Also, input the root name for eph & obi tables.
# -------------------------------------------------------------------------
include    "evalvg.h"
include    <imhdr.h>
include    <tbset.h>
include    <clk.h>
include    <ext.h>

procedure t_evalvg() 

pointer  sp
pointer  tbroot               #input tables root name
pointer  itp_eph              #pointer for *_eph.tab
pointer  ephname              #input *_eph.tab filename
pointer  col_eph[NCOLS]       #tabel column pointer 

pointer  itp_obi              #pointer for *_obi.tab
pointer  obiname              #input *_obi.tab filename
pointer  col_obi[NCOLS]       #tabel column pointer
pointer  itp_otab             #pointer for output table file
pointer  otbname              #output table name
pointer  col_otab[NCOLS]
pointer  tempname             #temp name of output table file
pointer  utclk                #pointer to clk structure
pointer  bdate, btime, edate, etime

int      display              #display level (0-5)
int      obi_num              #obi number
int      row_cnt              #loop counter
int      row_eph              #number of rows in eph table
int      row_obi              #number of rows in *_obi.tab
int      imjd_int             #integer julian day
int      imjdrefi             #reference julian day
int      isun_pos[3]          #sun position in unit vector
int      isat_pos[3]          #satellite position in meter
int      sc_time[2]           #SC start/stop time in each OBI
int      sc_rec               #space-craft time of current orb record
int      clgeti()

double   dmjd_frac            #fractional julian day
double   jd_rec               #data start time in mission julian days
double   ut_secs_day          #second of day
##      double   launch_jd            #JD of satellite launch
double   mod_utjd             #function mod_utjd
double   jd_time[2]           #JD start/stop time in each OBI

real     rtarget_pos[3]       #unit vector earth to target
real     est_ang              #earth satellite pointing
real     ses_ang              #sun earth satellite angle

bool     first                #logical indicating the first record
bool     clobber              #clobber old file
bool     clgetb()


begin
#  get the table name, open the table file and get the value of row_eph.
   call smark(sp)
   call salloc(tbroot,SZ_PATHNAME, TY_CHAR)
   call calloc(ephname, SZ_PATHNAME, TY_CHAR)
   call calloc(obiname, SZ_PATHNAME, TY_CHAR)
   call salloc(otbname, SZ_PATHNAME, TY_CHAR)
   call salloc(tempname, SZ_PATHNAME, TY_CHAR)
   call salloc(bdate, SZ_LINE, TY_CHAR)
   call salloc(btime, SZ_LINE, TY_CHAR)
   call salloc(edate, SZ_LINE, TY_CHAR)
   call salloc(etime, SZ_LINE, TY_CHAR)

   display = clgeti(DISPLAY)
   clobber = clgetb(CLOBBER)

#  allocate the mem for the structure  
   call malloc (utclk, SZ_CLK, TY_STRUCT)

#  get the input root name for eph & obi tables 
   call clgstr ("tab_root", Memc[tbroot], SZ_PATHNAME)
   call rootname(Memc[tbroot],Memc[ephname],EXT_EPH,SZ_PATHNAME)
   call rootname(Memc[tbroot],Memc[obiname],EXT_OBI,SZ_PATHNAME)
   if (display >= 5) {
      call printf ("input table root name is %s\n")
      call pargstr (Memc[tbroot])
      call printf ("ephemeris table name is %s\n")
      call pargstr (Memc[ephname])
      call printf ("obi table name is %s\n")
      call pargstr (Memc[obiname]) 
   }

#  set up the output file
   call vg_outtable("otb_name", EXT_ANG, ephname, otbname,
                     tempname, clobber)

#  open a table file & init columns to read
   call eph_inittab (Memc[ephname], itp_eph, col_eph, row_eph)
   call obi_inittab (Memc[obiname], itp_obi, col_obi, row_obi)

#  open a table file & init columns to write
   call out_inittab (Memc[tempname], itp_otab, col_otab, clobber) 

#  read the target position and reference julian day from OBI file
   call get_obihd_inf (itp_obi, rtarget_pos, imjdrefi)

## get JD of satellite launch 
## call get_launch_jd(display, itp_obi, launch_jd)

#  copy OBI header to output table file
   call tbhcal(itp_obi, itp_otab)

#  beginning loop counter
   do row_cnt = 1, row_eph   {

      # check to see if the current record is the first in each OBI.
      # If TRUE, get all necessary information from OBI file.
      call check_first( itp_eph, row_cnt, col_eph, first, obi_num)
      if ( first )   {
         # get information from OBI file
         call obi_rdtab (display, itp_obi, col_obi, obi_num, sc_time,
                         Memc[bdate], Memc[btime], Memc[edate],
                         Memc[etime])

         #convert character string to date & time integers
         call get_date_tim(display, bdate, btime, utclk)

         #convert UT to JD
         jd_time[START] = mod_utjd (utclk)

         #convert character string to date & time integers
         call get_date_tim(display, edate, etime, utclk)

         #convert UT to JD
         jd_time[STOP]  = mod_utjd (utclk)
      }  # end "if (check_first)"

      #read data from the table one row at a time
      call eph_rdtab (display, itp_eph, col_eph, row_cnt, imjdrefi,
                      imjd_int, dmjd_frac, isun_pos, isat_pos, jd_rec,
                      ut_secs_day)

      #convert JD to SC
      call resolve_time (display, jd_time, sc_time, jd_rec, sc_rec)

      #calculate the est & ses angles
##      call det_sat_ang (display, launch_jd, jd_rec, ut_secs_day, isun_pos,
##                        isat_pos, rtarget_pos, est_ang, ses_ang)
      call det_sat_ang (display, imjd_int, dmjd_frac, ut_secs_day, isun_pos,
                        isat_pos, rtarget_pos, est_ang, ses_ang)

      #fill out the output table file
      call out_filltab(itp_otab, col_otab, row_cnt, sc_rec,
                       est_ang, ses_ang, obi_num)

      #write data to output file if display greater than 5 
      call write_screen (display, sc_rec, est_ang, ses_ang, obi_num)

   }  # end "do row_cnt"

#  finalize the output table name
   if (display >= 1)   {
      call printf("Creating output file: %s \n")
      call pargstr(Memc[otbname])
   }
   call finalname(Memc[tempname], Memc[otbname])

#  close all table files
   call tbtclo(itp_eph)
   call tbtclo(itp_obi)
   call tbtclo(itp_otab)

#  free the space
   call mfree(utclk, TY_STRUCT)
   call sfree(sp)
end
