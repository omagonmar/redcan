# -------------------------------------------------------------------------
# Module:	Fold
# Project:	PROS -- ROSAT RSDC
# Purpose:      Task to Bin Src & Bkgd time data and compute count rates
#               at folded intervals. 
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek initial version  Jan 1987	
#		{1} Janet DePonte updated version  April 1989
#		{2} JD -- Oct 1991 -- added bin_length to fold hdr
#		{3} JD -- Jul 1992 -- added pdot
#
# -------------------------------------------------------------------------
include  <tbset.h>
include	 <gset.h>
include  <qpset.h>
include  <qpioset.h>
include  <mach.h>
include  <qpoe.h>
include  <ext.h>
include  "../timlib/timstruct.h"
include  "../timlib/timing.h"
#include  "timstruct.h"
#include  "timing.h"

procedure  t_fold()

bool     clobber		# clobber old file
bool     dobkgd			# subtract bkgd yes/no
bool     none

double   bin_length		# bin length in seconds
double   bkarea			# background area sum
double   period			# period in secs
double   pdot                   # period rate of change 
double   src_area		# source area
double   start_time		# start time for binning
double   stop_time		# stop time for binning

int      boffset		# offset (src and bkgd) of named parameter
int      display		# display level (0-5)
int      errtype                                # poisson (1) or gaus (0)
int	 num_of_bins		# number of timing bins
int      num_gintvs		# number of good time intvs
int	 soffset 		# offset (src and bkgd) of named parameter
 
pointer  bk_ptr			# bkgd input pointer
pointer	 bkgd_file		# name of input file
pointer  bqp			# bkgd qpoe handle
pointer  bevlist
pointer  sevlist
pointer  gbegs			# good time intervals
pointer  gends			# good time intervals
pointer  mmptr			# min/max/mu  struct ptr
pointer	 photon_file		# name of input file
pointer	 table_file             # temp name of output file
pointer	 tempname 		# temp name of output file
pointer	 sp			# stack pointer
pointer  src_ptr		# src input pointer
pointer  sqp
pointer  qphd                   # ptr to qpoe header structure

real     bknorm			# bkgd normalization factor

bool	 clgetb()				
int	 clgeti()
real     clgetr()				

pointer qpio_open()

pointer  binptr

begin
	call smark (sp)
	call salloc (bkgd_file,    SZ_PATHNAME, TY_CHAR)
	call salloc (bevlist,      SZ_EXPR,     TY_CHAR)
	call salloc (sevlist,      SZ_EXPR,     TY_CHAR)
	call salloc (photon_file,  SZ_PATHNAME, TY_CHAR)
  	call salloc (tempname,     SZ_PATHNAME, TY_CHAR)
        call salloc (table_file,   SZ_PATHNAME, TY_CHAR)

	call malloc (mmptr,        LEN_MMM,     TY_STRUCT)
	call malloc (binptr,       LEN_BIN,     TY_STRUCT)

	display = clgeti(DISPLAY)
	clobber = clgetb(CLOBBER)
	bknorm = clgetr("bk_norm_factor")

#  Get input/output filenames for source and background
	call t_openqp (SOURCEFILENAME, EXT_STI, Memc[sevlist], 
                         Memc[photon_file], none, sqp)
        src_ptr = qpio_open (sqp, Memc[sevlist], READ_ONLY)
        call tim_cktime(sqp,"source",soffset)
        call tim_getarea(sqp,src_area)

	call t_openqp (BKGRDFILENAME, EXT_BTI, Memc[bevlist], Memc[bkgd_file], 
                      dobkgd, bqp)
        dobkgd = !dobkgd
        if ( dobkgd ) {
           bk_ptr = qpio_open (bqp, Memc[bevlist], READ_ONLY)
           call tim_getarea(bqp,bkarea)
           call tim_cktime(bqp,"bkgd",boffset)
	}

#   Check the poiserr setting to determine the type of errors we'll calculate.
        call get_qphead (sqp, qphd)
        errtype = QP_POISSERR(qphd)
        call mfree (qphd, TY_STRUCT)

#   Get filename & open and initialize tables columns
        call tim_outtable (OUTTABLES, EXT_FLD, photon_file, table_file,
                           tempname, clobber)

#  Retrieve and init values
        call fld_startup (sqp, Memc[sevlist], soffset, dobkgd, bqp, display, 
			src_ptr, gbegs, gends, num_gintvs, start_time, 
			stop_time, period, num_of_bins, pdot)

#   Initialize data structures and files before each fold
        call t_initbin (mmptr, sqp, bqp, Memc[sevlist], Memc[bevlist], dobkgd, 
                       display, src_ptr, bk_ptr, binptr, period, num_of_bins, 
                       bin_length)

#   Bin the Source, Background, and Exposure Data
        call t_bindata (src_ptr, bk_ptr, start_time, stop_time, period, 
                       num_of_bins, pdot, dobkgd, display, soffset, boffset, 
                       num_gintvs, Memd[gbegs], Memd[gends], binptr)

#   Compute the count rate of each bin and average count rate of period
  	call t_cntrate (binptr, mmptr, num_of_bins, errtype, src_area,
                        bkarea, bknorm, display)

#   Write out fold data to table
 	call fld_outtable (display, photon_file, bkgd_file, clobber, sqp, 
		     bqp, dobkgd, start_time, stop_time, src_area, bkarea, 
		     bin_length, period, num_of_bins, pdot, binptr, mmptr, 
                     tempname, table_file)

#   Close qpoe file
	call tim_qpclose (sqp,src_ptr)
	if ( dobkgd ) {
	  call tim_qpclose (bqp,bk_ptr)
	}

#   Free allocated space
	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
  	call mfree (mmptr,  TY_STRUCT)
  	call mfree (binptr, TY_STRUCT)
	call sfree (sp)

end
