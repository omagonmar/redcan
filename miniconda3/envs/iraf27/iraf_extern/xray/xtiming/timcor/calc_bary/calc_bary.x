# $Header: /home/pros/xray/xtiming/timcor/calc_bary/RCS/calc_bary.x,v 11.0 1997/11/06 16:45:36 prosb Exp $
# $Log: calc_bary.x,v $
# Revision 11.0  1997/11/06 16:45:36  prosb
# General Release 2.5
#
# Revision 9.2  1997/09/24 18:42:57  prosb
# JCC(9/97) - change the comments only. (JDLEAP -> JD)
#
# Revision 9.1  1997/07/21 21:17:38  prosb
# JCC(7/21/97) - change jdleap :  int -> double
#
# Revision 9.0  1995/11/16 19:36:05  prosb
# General Release 2.4
#
#Revision 8.2  1995/09/18  19:14:50  prosb
#JCC - The data "jdleap[NLEAPS]" are no longer hardwired in the codes.
#    - Instead, it is stored in a new table "jdleap.tab". When adding
#    - a leap second, no need to update the header file and to
#    - recompile the codes anymore. Just simply create another new
#    - table "jdleap.tab" will make it work.
#    - Two new parameters "jdleap,NLEAPS" are passed to ss_bar, ephem,
#    - and a1utcf. One new routine "jdleap_init.x" is added.
#
#Revision 8.0  1994/06/27  17:44:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:17  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  17:12:29  janet
#jd - updated for rdf.
#
#Revision 6.0  93/05/24  17:00:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:40:06  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/26  13:27:46  prosb
#Initial revision
#
# Module:       calc_bary.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      Produce a barycenter correction table from orbit data.
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MPE -- initial version -- in EXSAS
#               {1} J Moran -- initial PROS port -- <when>
#               {2} J DePonte -- 9/93 -- 
#                      a) updated to work on new RDF format, rev0 files
#			    are converted to RDF before calling this task
#			    is a higher level macro... calc_bary.
#		       b) updated to delete duplicate ephemenris records,
#		       c) updated to declare arrays in memory.
#***********************************************************************
#  Produce a barycenter correction table from orbit data.
#***********************************************************************
include <tbset.h>
include <error.h>
include <ext.h>
include <math.h>
include <bary.h>

procedure calc_bary()

bool    skip_row        # indicates whether to skip row cause of double entry
pointer col_d1		# column pointer for day
pointer col_d2		# column pointer for seconds
pointer col_x		# column pointer for x-satellite
pointer col_y		# column pointer for y-satellite
pointer col_z		# column pointer for z-satellite
int     ireae[3]        # sat vector is int in table
int     soffset         # number of rows to skip 
int     prev_int        # mjd int from previous input row
int     row             # output table row
double  swlong		# west longitude of sat. from grnwch(rad)
double  swlat		# latitude of satelitte (rad)
double  radius		# radius of sat. from geocenter (light-s)
double  siter		# distance of sat. in the eq. plane (light-s)
double  ph 		# hour angle of the sat. (rad) 
double  st		# mean sidereal time (rad) 
double  st0 		# 
double  ttt 		# time used for precessing
double  eeq[3]		# earth sat. vec in sid. coord (light-s)
double  prc[3, 3]	# precession matrix
double  timnew		# corrected   time (in jd)
double  frc		# current fraction of day
double  rea[3]		# earth sat. vec in 2000 coord (light-s)
double  reae[3]		# geocentric vector with x-axis pointing to 0 long that
			# is written in the orbit data as x,y,z of satellite.
double  rca[3]		# vector from SSBC to spacecraft (light-s)
double  etut		# tdb-utc in seconds
double  alpha		# RA  of the source
double  delta		# DEC of the source
double  dir[3]		# unit vector from sun to source
double  rce[3]		# vector from ssbc to geocenter (light-s)
double  rcs[3]		# vector from ssbc to suncenter (light-s)
double  vce[3]		# time derivetive of rce
double  bary		# sum of propagation delays (seconds)
double  barnew		# 
double  prev_frc        # mjd frc from previous input row
pointer tp_in		# input table 
pointer tp_out		# output table
pointer tp_eph
pointer out_cp[4]
long    nrows		# number of rows in orbit file
long    timold          # uncorrected time (in jd)
long    jd              # current julian day (integer part)
int     ii		# loop index
int     jj		# loop index
char  	day_col[15]	# column name for day
char  	sec_col[15]	# column name for seconds
char  	xsat_col[15]	# column name for x-satellite
char  	ysat_col[15]    # column name for y-satellite
char  	zsat_col[15]	# column name for z-satellite
bool    streq()
bool    ck_none()
bool    clobber                         # clobber old file
bool    clgetb()                        # get bool from cl
double  clgetd()
int     tbtacc(), tbpsta()
int 	clgeti(), display, tbhgti()

pointer tbtopn(), sp
pointer orb_fname, corr_fname, ephem_fname, tempname
pointer tbl_fname       # jdleap.tab

#long   jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab
double  jdleap[LEAPMAX]     # array for the column "JD" in jdleap.tab

long    NLEAPS              # total row# in jdleap.tab

int     mjdint
double  mjdfrc

include "ephem.com"

begin
	call smark (sp)
        call salloc (orb_fname,   SZ_PATHNAME, TY_CHAR)
        call salloc (corr_fname,  SZ_PATHNAME, TY_CHAR)
        call salloc (ephem_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname,    SZ_PATHNAME, TY_CHAR)
        call salloc (tbl_fname, SZ_PATHNAME, TY_CHAR)        #jcc

#-------------------------
# Get hidden cl parameters
#-------------------------
        clobber = clgetb("clobber")
        display = clgeti("display")
        call clgstr("tbl_fname", Memc[tbl_fname], SZ_PATHNAME)  #jcc

        call clgstr("split_orb", Memc[orb_fname], SZ_PATHNAME)
        call clgstr("orb_corr", Memc[corr_fname], SZ_PATHNAME)
        call clgstr("ephem_fname", Memc[ephem_fname], SZ_PATHNAME)

        alpha = clgetd("st_alp")
        delta = clgetd("st_dec")

        call clgstr("day_col", day_col, SZ_LINE)
        call clgstr("sec_col", sec_col, SZ_LINE)
        call clgstr("xsat_col", xsat_col, SZ_LINE)
        call clgstr("ysat_col", ysat_col, SZ_LINE)
        call clgstr("zsat_col", zsat_col, SZ_LINE)

        if (ck_none(day_col) || streq("", day_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(sec_col) || streq("", sec_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(xsat_col) || streq("", xsat_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(ysat_col) || streq("", ysat_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(zsat_col) || streq("", zsat_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        call rootname(Memc[orb_fname], Memc[orb_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[orb_fname]) | streq("", Memc[orb_fname]))
           call error (EA_FATAL, "Requires *.tab file as input.")

        if (tbtacc(Memc[orb_fname]) == YES)
           tp_in = tbtopn (Memc[orb_fname], READ_ONLY, 0)
        else
           call error(EA_FATAL, "Split orbit table not found.")

        if (display >= 0) {
          call printf("Opening file: %s\n")
          call pargstr(Memc[orb_fname])
          call flush(STDOUT)
        }

#-------------------------------------------------
# jcc - initialize and read column from jdleap.tab
#-------------------------------------------------
        call jdleap_init(Memc[tbl_fname],jdleap,NLEAPS,display)

#----------------------
# Check for empty table
#----------------------
        nrows = tbpsta (tp_in, TBL_NROWS)

        if (nrows <= 0)
           call error (EA_FATAL, "Table file empty.")

	alpha = DEGTORAD(alpha * 15.D0)
	delta = DEGTORAD(delta)

#--------------------
# get column pointers 
#--------------------
        call tim_initcol(tp_in, day_col, col_d1)
        call tim_initcol(tp_in, sec_col, col_d2)
        call tim_initcol(tp_in, xsat_col, col_x)
        call tim_initcol(tp_in, ysat_col, col_y)
        call tim_initcol(tp_in, zsat_col, col_z)

        call rootname(Memc[orb_fname],Memc[corr_fname],EXT_COR,SZ_PATHNAME)
        if (ck_none(Memc[corr_fname]) | streq("", Memc[corr_fname]))
           call error (EA_FATAL, "Output file requires *.tab as filename.")

        call clobbername(Memc[corr_fname], Memc[tempname], clobber, SZ_PATHNAME)

        tp_out = tbtopn (Memc[tempname], NEW_FILE, 0)

#------------------
# column definition
#------------------
        call tbcdef (tp_out, out_cp[1], "IT1","jd","%10d",TY_INT,1,1)
        call tbcdef (tp_out, out_cp[2], "RT1","days","%20.16f",TY_DOUBLE,1,1)
        call tbcdef (tp_out, out_cp[3], "IT2","jd","%10d",TY_INT,1,1)
        call tbcdef (tp_out, out_cp[4], "RT2","days","%20.16f",TY_DOUBLE,1,1)

#------------------------
# Create the output table
#------------------------
        call tbtcre(tp_out)

	tp_eph = tbtopn(Memc[ephem_fname], READ_ONLY, 0)

        call tim_initcol(tp_eph, "earx", ear_cp[1])
        call tim_initcol(tp_eph, "eary", ear_cp[2])
        call tim_initcol(tp_eph, "earz", ear_cp[3])
        call tim_initcol(tp_eph, "eardx1", eard1_cp[1])
        call tim_initcol(tp_eph, "eardy1", eard1_cp[2])
        call tim_initcol(tp_eph, "eardz1", eard1_cp[3])
        call tim_initcol(tp_eph, "eardx2", eard2_cp[1])
        call tim_initcol(tp_eph, "eardy2", eard2_cp[2])
        call tim_initcol(tp_eph, "eardz2", eard2_cp[3])
        call tim_initcol(tp_eph, "eardx3", eard3_cp[1])
        call tim_initcol(tp_eph, "eardy3", eard3_cp[2])
        call tim_initcol(tp_eph, "eardz3", eard3_cp[3])
        call tim_initcol(tp_eph, "sunx", sun_cp[1])
        call tim_initcol(tp_eph, "suny", sun_cp[2])
        call tim_initcol(tp_eph, "sunz", sun_cp[3])
        call tim_initcol(tp_eph, "rtmcor", tdbtdt_cp)
	jdch0 = 0
        jd0 = tbhgti(tp_eph, "STARTJD")
        jd1 = tbhgti(tp_eph, "ENDJD")

# --------------------------
# init prev mjd int and frc
# --------------------------
        prev_int = 0
        prev_frc = 0.0D0

#---------------------------	
# main loop on orbit records
#---------------------------
	do ii = 1, nrows
	{
           skip_row = FALSE

           # ----------------------------------------------
           # read rdf time in format mjd_int, mjd_frac
           # ----------------------------------------------
           call tbegti(tp_in, col_d1, ii, mjdint)
           call tbegtd(tp_in, col_d2, ii, mjdfrc)

           # -------------------------------------------------------------
           # check if the same row is written twice in the ephem table.
	   # We skip the second occurance and don't write it out.
	   # -------------------------------------------------------------
           if ( ( mjdint == prev_int ) && ( mjdfrc == prev_frc ) ) {
	      skip_row = TRUE
              soffset = soffset + 1
           }
           prev_int = mjdint
           prev_frc = mjdfrc

           # ---------------------
           # convert to mjd to jd 
	   # ---------------------
           jd = JDDAY + mjdint
           frc = JDFRAC + mjdfrc 

           if (frc >= 1.0D0) {
               jd  = jd + 1
               frc = frc - 1.0D0
            }

           if ( display >= 5 ) {
              call printf ("mjdint=%d; mjdfrc=%f; jd=%d; frc=%f\n")
                call pargi (mjdint)
                call pargd (mjdfrc)
                call pargi (jd)
                call pargd (frc)
              call flush(STDOUT)
	   }

	   #------------------------------------------------------------
	   # read in (x,y,z) position (geocentric) of spacectraft
	   # fixed on the earth( x axis points to lat=long=0) reae in m.
	   #------------------------------------------------------------
           call tbegti(tp_in, col_x, ii, ireae[1])
           call tbegti(tp_in, col_y, ii, ireae[2])
           call tbegti(tp_in, col_z, ii, ireae[3])

           reae[1] = double(ireae[1])
           reae[2] = double(ireae[2])
           reae[3] = double(ireae[3])

	   #---------------------------------------------------
	   # convert it to: 
	   #    swlong (longitude of sat- west of greenw.(rad))
	   #    swlat (latitude of sat.(rad))
	   #    radius (distance from center in light-s)
	   #    siter (distance from rotation axis in l-s)
	   #---------------------------------------------------
           radius = dsqrt(reae[1]**2 + reae[2]**2 + reae[3]**2)
           siter  = dsqrt(reae[1]**2 + reae[2]**2)  
           swlong = dacos(reae[1] / siter)

	   #-----------------------------------------------------------
	   # there is a bit of reverse logic here. swlong as calculated
	   # above is positive eastward. the following if statement
	   # tries to make it positive westward. it should be checked.
	   #-----------------------------------------------------------
           if (reae[2] > 0.D0) {
              swlong = -swlong
           } 
           swlat  = dasin(reae[3] / radius)
           radius = radius / SPEED_OF_LIGHT
           siter  = siter / SPEED_OF_LIGHT

	   #-----------------------------------------
	   # compute the greenwich mean sidereal time
	   #-----------------------------------------
           st0 = GT2000*DAYS_IN_SEC + (jd - JD2000)*(SIDDAY - 1.D0)
           st0 = st0 + frc*SIDDAY
           st  = TWOPI*dmod(st0, -1.0D0)

	   #----------------------------------------
	   # compute sidereal x,y,z of the satellite
	   #----------------------------------------
           ph     = st - swlong
           eeq[1] = siter*dcos(ph)
           eeq[2] = siter*dsin(ph)
           eeq[3] = radius*dsin(swlat)

	   #--------------------------
	   # compute precession matrix
	   #--------------------------
           ttt      = ((jd - JD2000) + frc) / 365.25D+2
           prc[1,1] = 1.D0
           prc[2,1] = -2.236172D-2*ttt
           prc[3,1] = -9.717173D-3*ttt
           prc[1,2] = -prc[2,1]
           prc[2,2] = 1.D0
           prc[3,2] = 0.D0
           prc[1,3] = -prc[3,1]
           prc[2,3] = 0.D0
           prc[3,3] = 1.D0

	   #--------------------------------------------------
	   # precess sat vec and compute earth-cent to sat vec
	   # in 2000 coord.
	   #--------------------------------------------------
           do jj = 1, 3 {
             rea[jj] = prc[jj,1]*eeq[1] + prc[jj,2]*eeq[2] + prc[jj,3]*eeq[3]
           } 
# jcc - add jdleap,NLEAPS
	   call ss_bar(tp_eph,jd,frc,rea,rca,etut,rce,rcs,vce,jdleap,NLEAPS)

	   #---------------------------------------------
	   # transform alpha-delta in unit vector from bc 
	   # to pulsar
	   #---------------------------------------------
           dir[1] = dcos(delta)*dcos(alpha)
           dir[2] = dcos(delta)*dsin(alpha)
           dir[3] = dsin(delta)

           bary = barnew(rea,dir,rce,rcs)

	   #---------------------------------
	   # get original and corrected times
	   #---------------------------------
           timnew = frc + bary / SECS_IN_DAY

           if (timnew >= 1.0) {
               timold = jd + 1
               timnew = timnew - 1.0D0
           }
	   else {
              timold = jd
           } 

	   #--------------------------------
	   # write to output table
	   #--------------------------------
           row = ii-soffset
           if ( !skip_row ) {
	      call tbepti (tp_out, out_cp[1], row, jd)
	      # call tbeptd (tp_out, out_cp[2], ii, frc)
	      call tbrptd (tp_out, out_cp[2], frc, 1, row)
              call tbepti (tp_out, out_cp[3], row, timold)
              call tbeptd (tp_out, out_cp[4], row, timnew)
	   } else {

           # ----------------------------------------
           # we have a duplicate _eph record, skip it
           # ----------------------------------------
      call eprintf ("Row %5d matches previous row, Not writing row %5d to correction table\n")
                    call pargi (row)
		    call pargi (row)
	   }
        } # end loop

#---------------------------------------------
# write alpha and delta to output table header
#---------------------------------------------
	alpha = RADTODEG(alpha)/15.D0
	delta = RADTODEG(delta)

	call tbhadd (tp_out, "alpha_source", alpha)
        call tbhadd (tp_out, "delta_source", delta)

        if ( display >= 2 ) {
	   call printf("%d rows written to correction table.\n")
	   call pargi(row)
	   call flush(STDOUT)
        }
        call finalname(Memc[tempname], Memc[corr_fname])

#------------------------------
# close input and output tables
#------------------------------
        call tbtclo(tp_out)
        call tbtclo(tp_in)
	call tbtclo(tp_eph)

        if ( display > 0 ) {
           call printf ("Output Correction table: %s\n")
	     call pargstr (Memc[corr_fname])
        }

        call sfree (sp)
end
