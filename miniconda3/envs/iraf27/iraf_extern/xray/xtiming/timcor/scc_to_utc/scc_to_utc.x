# $Header: /home/pros/xray/xtiming/timcor/scc_to_utc/RCS/scc_to_utc.x,v 11.0 1997/11/06 16:45:32 prosb Exp $
# $Log: scc_to_utc.x,v $
# Revision 11.0  1997/11/06 16:45:32  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:54  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:05:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:00:36  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:06  prosb
#General Release 2.1
#
#Revision 4.0  92/06/26  14:36:07  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/06/17  10:47:29  mo
#MC/Jmoran	6/16/92		Update the output formats for the times
#
#Revision 1.1  92/03/26  13:28:59  prosb
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
include <ext.h>
include <error.h>

procedure scc_to_utc()

double	scc				# spacecraft clock time
double  utcr				# UTC real part of time
long	utci				# UTC integer part of time
pointer sp				# stack pointer
pointer tbl_fname			# table fname pointer

bool    ck_none()                       # check none function
bool    streq()                         # string equals function
double  clgetd()			# cl get double

begin
	call smark(sp)
	call salloc(tbl_fname, SZ_PATHNAME, TY_CHAR)

#------------------
# Get cl parameters
#------------------
        call clgstr("tbl_fname", Memc[tbl_fname], SZ_PATHNAME)
        scc = clgetd("scc_time")

        call rootname("", Memc[tbl_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[tbl_fname]) | streq("", Memc[tbl_fname]))
           call error (EA_FATAL, "Requires *.tab file as input.")

#---------------------------
# Initialize local variables
#---------------------------
	utcr = 0.D0
	utci = 0

#----------------------------------------------
# Initialize and read info from SCC_TO_UT table
#----------------------------------------------
	call sccut2_init(Memc[tbl_fname])

#-----------------------------------------------------------------
# Calculate UTC time, extrapolating from end of table if necessary
#-----------------------------------------------------------------
	call sccut2(scc, utci, utcr)

#----------------
# Print out times
#----------------
	call printf("SCC time = %16.16f\n")
	call pargd(scc)
	call printf("UTC time (integer part) %d  (real part) %16.16f\n")
        call pargl(utci)
	call pargd(utcr)
	call flush(STDOUT)

	call sfree(sp)
end
