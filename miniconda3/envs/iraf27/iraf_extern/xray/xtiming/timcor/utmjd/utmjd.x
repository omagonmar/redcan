# $Header: /home/pros/xray/xtiming/timcor/utmjd/RCS/utmjd.x,v 11.0 1997/11/06 16:45:48 prosb Exp $
# $Log: utmjd.x,v $
# Revision 11.0  1997/11/06 16:45:48  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:36:23  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:41  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:13:05  janet
#Initial revision
#
#
# Module:       utmjd
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
#******************************************************************************
#  Read the rev1 ephemeris table and create a table with mjd (2 col int & frc).
#******************************************************************************
include <tbset.h>
include <error.h>
include <ext.h>
include <bary.h>

procedure utmjd()

pointer col_d1		# column pointer for day
pointer col_d2		# column pointer for seconds
double  frc		# current fraction of day
			# is written in the orbit data as x,y,z of satellite.
real    date1		# current date
real    date2		# current seconds of date
pointer tp_in		# input table 
pointer tp_out		# output table
pointer out_cp[2]
long    nrows		# number of rows in orbit file
long    year		# current year  (from orbit file)
long    month		# current month (from orbit file)
long    day		# current day   (from orbit file)
long    jd              # current julian day (integer part)
int     ii		# loop index
char  	day_col[15]	# column name for day
char  	sec_col[15]	# column name for seconds
bool    streq()
bool    ck_none()
bool    clobber                         # clobber old file
bool    clgetb()                        # get bool from cl
int     tbtacc()
int     tbpsta()
int 	clgeti()
int	display
pointer tbtopn()
char 	orb_fname[SZ_PATHNAME]
char 	mjd_fname[SZ_PATHNAME]
char    tempname[SZ_PATHNAME]

int     mjdint
double  jdd
double  mjdfrc


begin

#-------------------------
# Get hidden cl parameters
#-------------------------
        clobber = clgetb("clobber")
        display = clgeti("display")

        call clgstr("orb_fname", orb_fname, SZ_PATHNAME)
        call clgstr("mjd_fname", mjd_fname, SZ_PATHNAME)

        call clgstr("day_col", day_col, SZ_LINE)
        call clgstr("sec_col", sec_col, SZ_LINE)

        if (ck_none(day_col) || streq("", day_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(sec_col) || streq("", sec_col))
           call error(EA_FATAL, "Table is missing column name in param file")

        call rootname("", orb_fname, EXT_TABLE, SZ_PATHNAME)
        if (ck_none(orb_fname) | streq("", orb_fname))
           call error (EA_FATAL, "Requires *.tab file as input.")

        if (tbtacc(orb_fname) == YES)
           tp_in = tbtopn (orb_fname, READ_ONLY, 0)
        else
           call error(EA_FATAL, "Split orbit table not found.")

        if (display > 0)
        {
          call printf("Opening file: %s\n")
          call pargstr(orb_fname)
          call flush(STDOUT)
        }

#----------------------
# Check for empty table
#----------------------
        nrows = tbpsta (tp_in, TBL_NROWS)

        if (nrows <= 0)
           call error (EA_FATAL, "Table file empty.")

#--------------------
# get column pointers 
#--------------------
        call tim_initcol(tp_in, day_col, col_d1)
        call tim_initcol(tp_in, sec_col, col_d2)

        call rootname("", mjd_fname, EXT_TABLE, SZ_PATHNAME)
        if (ck_none(mjd_fname) | streq("", mjd_fname))
           call error (EA_FATAL, "Output file requires *.tab as filename.")

        call clobbername(mjd_fname, tempname, clobber, SZ_PATHNAME)

        tp_out = tbtopn (tempname, NEW_FILE, 0)

#------------------
# column definition
#------------------
        call tbcdef(tp_out,out_cp[1],"MJD_INT","mjd","%10d",TY_INT,1,1)
        call tbcdef(tp_out,out_cp[2],"MJD_FRAC","days","%20.16f",TY_DOUBLE,1,1)

#------------------------
# Create the output table
#------------------------
        call tbtcre(tp_out)

#---------------------------	
# main loop on orbit records
#---------------------------
	do ii = 1, nrows
	{

# -------------- vvvvv handles old fits file format vvvvv ------------

	   #------------------------
	   # read in date (yy:mm:dd)
	   #------------------------
            call tbegtr(tp_in, col_d1, ii, date1)
	   #-----------------------------------
	   # get year, month and day from date1
	   #-----------------------------------
            year  = int(date1 / 1.E4)
            date1 = date1 - year * 1.E4
            month = int(date1 / 1.E2)
            day   = int(date1 - month * 1.E2)
	   #--------------------------
	   # convert it to julian date
	   #--------------------------
            call ar_jdc(day, month, year, jdd)
	   #------------------------
	   # get rid of the half day
	   #------------------------
            jd = int(jdd)
	   #---------------------------------------------------------
	   # initialize fraction of the day to the removed half a day
	   #---------------------------------------------------------
            frc = HALF
	   #------------------------
	   # read in seconds of date
	   #------------------------
            call tbegtr(tp_in, col_d2, ii, date2)
	   #-----------------------------
	   # assemble fraction of the day
	   #-----------------------------
            frc = frc + (date2  / SECS_IN_DAY)
	   #------------------------------
	   # correct if new day is reached
	   #------------------------------
            if (frc >= 1.0D0) 
 	    {
               jd  = jd  + 1
               frc = frc - 1.0D0
            } 

# -------------- ^^^^^ handles old fits file format ^^^^^ --------------

            # --------------
	    # convert to mjd
            # --------------
	    mjdint = int (jd) - JDDAY
            mjdfrc = frc - JDFRAC

	    If ( mjdfrc <= 0.0D0 ) {
	       mjdint = mjdint - 1
               mjdfrc = 1.0D0 + mjdfrc
	    }

            if ( display >= 3 ) {
               call printf ("jd=%d; frc= %f\n")
                  call pargi (jd)
                  call pargd (frc)

	       call printf ("mjdint= %d; mjdfrc=%f\n")
                  call pargi (mjdint)
                  call pargd (mjdfrc)

	    }

	    #--------------------------------
	    # write to output table
	    #--------------------------------
	    call tbepti (tp_out, out_cp[1], ii, mjdint)
	    call tbeptd (tp_out, out_cp[2], ii, mjdfrc)

        } # end loop

	call printf("%d rows written to output table.\n")
	call pargi(nrows)
	call flush(STDOUT)

        call finalname(tempname, mjd_fname)

#------------------------------
# close input and output tables
#------------------------------
        call tbtclo(tp_out)
        call tbtclo(tp_in)
end

