#$Header: /home/pros/xray/xtiming/period/RCS/period.x,v 11.0 1997/11/06 16:44:47 prosb Exp $
#$Log: period.x,v $
#Revision 11.0  1997/11/06 16:44:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:52  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  12:32:19  janet
#jd - added poiserr header input and type of error calc decision.
#
#Revision 6.1  93/07/16  14:29:53  janet
#moved check for timing qpoe closer to file open.
#
#Revision 6.0  93/05/24  16:57:56  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:16:54  janet
#jd - added display level to t_cntrate call.
#
#Revision 5.0  92/10/29  22:49:28  prosb
#General Release 2.1
#
#Revision 4.2  92/09/29  14:10:32  mo
#MC	9/29/92		Updated calling sequences for begs and ends rather`
#			than 2 dimensional GTIS
#
#Revision 4.1  92/09/28  17:01:51  janet
#add pdot to calling sequences.
#
#Revision 4.0  92/04/27  15:33:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/04/23  17:44:13  janet
#added chisq thresh and check before writing rows to chi table.
#
#Revision 3.3  91/09/24  14:40:04  janet
#added exposure screens made available in iraf 2.9.3
#
#Revision 3.2  91/09/24  12:48:50  janet
#updated chi table header with image hdr info.
#
#Revision 3.1  91/09/19  15:45:08  mo
#MC	9/19/91		Update calling sequences to allow passing
#			the QPOE filter string to the subroutines
#
#Revision 2.1  91/04/04  17:22:32  janet
#Rewrite of this code didn't properly handle bkgrd.  Updated dobkgd, bknorm,
#and qpopen in case of bkgrd.
#
#Revision 2.0  91/03/06  22:48:28  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:	Period
# Project:	PROS -- ROSAT RSDC
# Purpose:	Determine the period of a lightcurve by computing
#               the chisq over a range of periods
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek initial version  Jan 1987	
#		{1} Janet DePonte updated version  April 1989
#		{2} JD - Aug 1991 - Updated to work with time filters on qpoe
#		{3} JD - Dec 1991 - change t_outtable to fld_outtable
#		{n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include  <tbset.h>
include	 <gset.h>
include  <qpset.h>
include  <qpioset.h>
include  <mach.h>
include  <math.h>
include  <qpoe.h>
include  <ext.h>
include  "../timlib/timstruct.h"
include  "../timlib/timing.h"
#include  "/pros/xray/timing/timlib/timstruct.h"
#include  "/pros/xray/timing/timlib/timing.h"

procedure  t_period ()

bool     clobber		# clobber old file
bool     dobkgd			# subtract bkgd yes/no
bool     none

double   bkarea			# background area sum
double   bin_length		# bin length in seconds
double   bst_binlen		# bin length in secs with best chisq calc
double   bst_per		# period with best chisq calc
double   curper			# current period in secs
double   increment		# increment of period
double   pdot                   # period rate of change
double   pstart                 # period start in secs
double   pstop                  # period stop in secs
double   src_area		# source area
double   search_density	        # search density        
double   start_time		# start time for binning
double   stop_time		# stop time for binning

int      boffset		# offset (src and bkgd) of named parameter
int      display		# display level (0-5)
int      errtype                                # poisson (1) or gaus (0)
int	 num_of_bins		# number of timing bins
int      num_gintvs		# number of good time intvs
int      row			# current chisq row pointer
int      rowtally               # tally of all possible rows to be written
int	 soffset 		# offset (src and bkgd) of named parameter
int      totcnts                # total number of net (src-bkgd) counts
 
pointer  bk_ptr			# bkgd input pointer
pointer	 bkgd_file		# name of input file
pointer  bqp			# bkgd qpoe handle
pointer  binptr			# struct pointer to bin data
pointer  bst			# struct pointer to best stats
pointer  bstmm			# struct pointer to best min & max's
pointer  chi_cp[10]             # output column pointer
pointer	 chi_file		# name of output chisq table
pointer  bevlist		# background event list
pointer  sevlist		# source event list
pointer  gbegs			# good time intervals
pointer  gends			# good time intervals
pointer  ctp			# chisq table ptr 
pointer  mmptr			# min/max/mu  struct ptr
pointer	 photon_file		# name of input file
pointer	 ctempname 		# temp name of output file
pointer	 table_file             # temp name of output file
pointer	 tempname 		# temp name of output file
pointer	 sp			# stack pointer
pointer  src_ptr		# src input pointer
pointer  sqp			# src qpoe pointer
pointer  qphd                   # ptr to qpoe header structure

real     bknorm			# bkgd normalization factor
real     bst_chisq		# best chisq calc
real     chisq			# computed chisq
real     chithresh

bool	 clgetb()				
int	 clgeti()
real     clgetr()				
double   compute_next_period ()
pointer  qpio_open()

begin
	call smark (sp)
	call salloc (bkgd_file,    SZ_PATHNAME, TY_CHAR)
	call salloc (bevlist,      SZ_EXPR,     TY_CHAR)
	call salloc (sevlist,      SZ_EXPR,     TY_CHAR)
	call salloc (photon_file,  SZ_PATHNAME, TY_CHAR)
	call salloc (ctempname,    SZ_PATHNAME, TY_CHAR)
  	call salloc (tempname,     SZ_PATHNAME, TY_CHAR)
        call salloc (table_file,   SZ_PATHNAME, TY_CHAR)

	call malloc (mmptr,        LEN_MMM,     TY_STRUCT)
	call malloc (bstmm,        LEN_MMM,     TY_STRUCT)
	call malloc (binptr,       LEN_BIN,     TY_STRUCT)
	call malloc (bst, 	   LEN_BIN,     TY_STRUCT)
	call malloc (chi_file, 	   SZ_PATHNAME, TY_CHAR)

	display = clgeti(DISPLAY)
	clobber = clgetb(CLOBBER)
	bknorm = clgetr(BKNORM)
        chithresh = clgetr("chisq_thresh")

#  Get input/output filenames for source and background
	call t_openqp (SOURCEFILENAME, EXT_STI, Memc[sevlist], 
                       Memc[photon_file], none, sqp)
        src_ptr = qpio_open (sqp, Memc[sevlist], READ_ONLY)
        call tim_cktime(sqp,"source",soffset)
        call tim_getarea(sqp,src_area)

	call t_openqp (BKGRDFILENAME, EXT_BTI, Memc[bevlist],
		         Memc[bkgd_file], dobkgd, bqp)
        dobkgd = !dobkgd
	if ( dobkgd ) {
           bk_ptr = qpio_open (bqp, Memc[bevlist], READ_ONLY)
           call tim_cktime(bqp,"bkgd",boffset)
           call tim_getarea(bqp,bkarea)
	}

#   Check the poiserr setting to determine the type of errors we'll calculate.
        call get_qphead (sqp, qphd)
        errtype = QP_POISSERR(qphd)
        call mfree (qphd, TY_STRUCT)

#  Get filename & open and initialize tables columns
        call tim_outtable (OUTTABLES, EXT_FLD, photon_file, table_file,
                           tempname, clobber)

#  Setup chisq output table
	call chi_outtable(OUTTABLES, EXT_CHI, table_file, chi_file,
                          ctempname, clobber)
	call chi_inittab (Memc[ctempname], clobber, chi_cp, ctp)

#  Retrieve and init values
 	call per_startup (sqp, Memc[sevlist], soffset, dobkgd, bqp, display, 
                          src_ptr, gbegs, gends, num_gintvs, start_time, 
                          stop_time, pstart, pstop, increment, search_density, 
                          num_of_bins, pdot)
 	curper = pstart
 	row = 0
        rowtally = 0
 	bst_chisq= 0.0
        bst_per = 0.0
	bst_binlen = 0.0
        do while ( curper <= pstop ) {

#   Initialize data structures and files before each fold
          call t_initbin (mmptr, sqp, bqp, Memc[sevlist], Memc[bevlist], 
  		         dobkgd, display, src_ptr, bk_ptr, binptr, curper, 
  		         num_of_bins, bin_length)

#   Bin the Source, Background, and Exposure Data
          call t_bindata (src_ptr, bk_ptr, start_time, stop_time, curper, 
			 num_of_bins, pdot, dobkgd, display, soffset, 
                         boffset, num_gintvs, Memd[gbegs], Memd[gends], binptr)

#   Compute the count rate of each bin and average count rate of period
  	  call t_cntrate (binptr, mmptr, num_of_bins, errtype, src_area, 
			  bkarea, bknorm, display)
	
#   Determine the chisq for folded data, row is incremented in the routine
#   if the computed chisq exceeds the chisq thresh value 
  	  call per_chisq(mmptr,num_of_bins,binptr,curper,row,chi_cp,ctp,
                         chithresh,display,chisq)  
	
#   Save the best chisq if we are writing one output table
  	  if ((chisq >= chithresh) && (chisq > bst_chisq)) {
             bst_chisq = chisq
             bst_per = curper
	     bst_binlen = bin_length
  	     call t_savbest (binptr, mmptr, bst, bstmm, num_of_bins, display)
   	  }
          curper = compute_next_period (curper, increment, search_density, 
			 	        start_time, stop_time, num_of_bins)
          rowtally = rowtally + 1
       }

#   Write out best chisq data to fold table ... first check that at least
#   one chisq passed the chi_thresh test and was written to the chisq table.
       if ( row > 0 ) {
          call fld_outtable (display, photon_file,bkgd_file,clobber, sqp, bqp,
                        dobkgd, start_time, stop_time, src_area, bkarea,
                        bst_binlen, bst_per, num_of_bins, pdot, bst, bstmm,
                        tempname, table_file)
       }

#   Write Chisq Table header
       call tim_hdr (ctp,sqp,bqp,Memc[photon_file],Memc[bkgd_file],dobkgd)
       totcnts = BNTOT(bstmm) 
#   If we didn't write out all of the rows, the perincr is not valid for
#   the table ... a 0 in perincr will default the chiplot to only bin plots
       if ( rowtally != row ) increment=0.0
       call chi_hdr (display, ctp, start_time, stop_time, src_area,
                     bkarea, bst_binlen, num_of_bins, pstart, pstop,
                     increment, bst_chisq, bst_per, totcnts, ctempname, 
                     chi_file)

#   Close qpoe file
	call tim_qpclose (sqp,src_ptr)
	if ( dobkgd ) {
	  call tim_qpclose (bqp,bk_ptr)
	}

#   Free allocated space
	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
  	call mfree (mmptr,  TY_STRUCT)
  	call mfree (bstmm,  TY_STRUCT)
  	call mfree (binptr, TY_STRUCT)
 	call mfree (bst,    TY_STRUCT)
        call mfree (chi_file, SZ_PATHNAME)
	call sfree (sp)

end
