#$Header: /home/pros/xray/xtiming/ltcurv/RCS/ltcurv.x,v 11.0 1997/11/06 16:45:21 prosb Exp $
#$Log: ltcurv.x,v $
#Revision 11.0  1997/11/06 16:45:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:19  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:34  prosb
#General Release 2.3
#
#Revision 6.3  93/12/22  12:29:47  janet
#jd - added poiserr header input and type of error calc decision.
#
#Revision 6.2  93/12/02  17:16:28  janet
#jd - added sc time column to output.
#
#Revision 6.1  93/07/16  14:27:57  janet
#jd - put file opens closer to filename gets.
#
#Revision 6.0  93/05/24  16:59:50  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  10:14:45  janet
#jd - added duration to tim_gintvs call.
#
#Revision 5.1  93/03/23  15:27:45  janet
#changed bin_length from real to double.
#
#Revision 5.0  92/10/29  23:06:13  prosb
#General Release 2.1
#
#Revision 4.1  92/09/29  14:08:25  mo
#MC 9/29/92		Updated calling sequence for begs and ends rather
#			than 2 dimensional GTIs.
#
#Revision 4.0  92/04/27  15:37:36  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/23  17:42:44  janet
#added header params for plots.
#
#Revision 3.2  92/02/20  15:36:21  mo
#MC (JD)	2/20/92		Add num of bins to output table header
#
#Revision 3.1  91/09/24  14:35:01  janet
#updated to add exposure screens.
#
#Revision 2.1  91/04/03  18:04:21  janet
#
#fixed incorrect handling of bk subtraction ... logic of var dobkd
#
#could never be true.  Now handles bk subtraction.
#
#Revision 2.0  91/03/06  22:47:54  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:	Ltcurv
# Project:	PROS -- ROSAT RSDC
# Purpose:	Task to Bin Src & Bkgd time data and compute count rates. 
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Adam Szczypek initial version  Jan 1987	
#		{1} Janet DePonte updated version  April 1989
#		{2} JD - Aug 1991 - updated to add time filters
#		{3} JD - Oct 1991 - added num_of_bins to table header for plots
#		{4} JD - Dec 1992 - changed bin_length from real to double
#
# -------------------------------------------------------------------------
include  <tbset.h>
include	 <gset.h>
include  <qpset.h>
include  <qpioset.h>
include  <qpoe.h>
include  <ext.h>
include  "ltcurv.h"

procedure  t_ltcurv ()

bool     clobber				# clobber old file
bool     dobkgd					# subtract bkgd yes/no
bool     none

double   bin_length				# bin length in seconds
double   bkarea					# background area sum
double   duration                               # sum of gti's
double   src_area				# source area
double   start_bin				# start time for binning
double   stop_bin				# stop time for binning
double   start_time				# start time for binning
double   stop_time				# stop time for binning

int      curbin					# current bin loop pointer
int      display				# display level (0-5)
int      errtype				# poisson (1) or gaus (0)
int	 num_of_bins				# number of timing bins
int      num_gintvs				# number of good time intvs
int      srec					# src qpoe rec cntr
int 	 brec					# bkgd qpoe rec cntr
 
pointer  bk_ptr					# bkgd input pointer
pointer	 bkgd_file				# name of input file
pointer  bqp
pointer  col_cp[10]                             # output column pointer
pointer	 gbegs
pointer	 gends
pointer  tp					# table ptr 
pointer	 ltcurv_file				# name of output file
pointer  minmax					# min/max/mu  struct ptr
pointer	 photon_file				# name of input file
pointer	 evlist					# name of input file
pointer	 bevlist					# name of input file
pointer	 sp					# stack pointer
pointer  src_ptr				# src input pointer
pointer  sqp
pointer	 tempname 				# temp name of output file
pointer  qphd					# ptr to qpoe header structure

real	 bkgrd					# bkgd pgoton cnt for 1 bin
real     bknorm					# bkgd normalization factor
real     cnt_rate				# computed for 1 bin
real 	 cnt_rate_err				# cnt_rate error for 1 bin
real	 exposure				# secs of exp for 1 bin
real 	 net_cts				# net counts for 1 bin
real 	 net_err				# net error for 1 bin
real	 source					# photon cnt for 1 bin
real	 total_exposure				# exposure across all bins

bool	 clgetb()				
int	 clgeti()
real     clgetr()				
int	 soffset, boffset	# offset (src and bkgd) of named parameter

begin
	call smark (sp)
	call salloc (bkgd_file,    SZ_PATHNAME, TY_CHAR)
	call salloc (photon_file,  SZ_PATHNAME, TY_CHAR)
	call salloc (evlist,  SZ_PATHNAME, TY_CHAR)
	call salloc (bevlist,  SZ_PATHNAME, TY_CHAR)
	call salloc (ltcurv_file,  SZ_PATHNAME, TY_CHAR)
	call salloc (tempname,     SZ_PATHNAME, TY_CHAR)
	call salloc (minmax,       LEN_MMM,     TY_STRUCT)

	display = clgeti(DISPLAY)
	clobber = clgetb(CLOBBER)
        bknorm = clgetr(BKNORM)

#   Get input filenames for source 
	call tim_openqp(SOURCEFILENAME,EXT_STI,Memc[photon_file],Memc[evlist],
			none, sqp,src_ptr)

#   Check input files for correct type ( must have TIME ) and get region areas
	call tim_cktime(sqp,"source",soffset)
	call tim_getarea(sqp,src_area)

#   Get input filenames for background 
	call tim_openqp(BKGRDFILENAME,EXT_BTI,Memc[bkgd_file],Memc[bevlist],
			dobkgd, bqp,bk_ptr)
        dobkgd = !dobkgd

#   Check input files for correct type ( must have TIME ) and get region areas
	if( dobkgd){
	    call tim_getarea(bqp,bkarea)
	    call tim_cktime(bqp,"bkgd",boffset)
	}

#   Check the poiserr setting to determine the type of errors we'll calculate.
	call get_qphead (sqp, qphd)
	errtype = QP_POISSERR(qphd)
	call mfree (qphd, TY_STRUCT)

#   Set up the output file
	call tim_outtable(LTCURVFILENAME,EXT_LTC,photon_file,ltcurv_file,
			  tempname,clobber)
	call ltc_inittab(Memc[tempname], clobber, col_cp, tp)

#  Setup the bin sizes and lengths
        call tim_gintvs (display, sqp, src_ptr, soffset, Memc[evlist], 
		start_time, stop_time, gbegs, gends, num_gintvs, duration)

#  Make sure these are initialized to zero or else the subroutine won't read
#       in new parameter values
	num_of_bins=0
	bin_length=0.0d0
	call ltc_setbins ( display, start_time, stop_time, num_of_bins, 
			   bin_length)

#   Fill Ltcurv Table header with reference file names, times and areas
	call tim_hdr (tp,sqp,bqp,Memc[photon_file],Memc[bkgd_file],dobkgd)
	call ltc_fillhdr (tp, start_time, stop_time, src_area, 
		          bkarea, bin_length, num_of_bins)

#   Initialize some variables
	call tim_initbin (start_time,bin_length,minmax,start_bin,stop_bin,
			  total_exposure)

#   Bin the Data and compute the Count Rate
        source = 0.0
	bkgrd = 0.0
	do curbin = 1, num_of_bins  {

	   call tim_srcbin (src_ptr, start_time, bin_length,
			    curbin, display, srec, soffset, source)

 	   if ( dobkgd )  {
  	      call tim_bkbin (bk_ptr, start_time, bin_length, 
			      curbin, display, brec, boffset, bkgrd)
	   }
	
 	   call tim_binexp (display, num_gintvs, sqp, start_bin, stop_bin, 
 			    Memd[gbegs], Memd[gends], exposure, total_exposure)

 	   call tim_cntrate (source, bkgrd, exposure, curbin, errtype, 
			     src_area, bkarea, bknorm, cnt_rate, cnt_rate_err, 
			     net_cts, net_err) 

 	   call ltc_filltab (curbin, col_cp, tp, start_bin, cnt_rate, 
			     cnt_rate_err, exposure, source, bkgrd, net_cts, 
                             net_err)

 	   call tim_minmax (minmax, cnt_rate, cnt_rate_err, exposure, source, 
			    bkgrd, net_cts, net_err)

	   start_bin = start_time + curbin*bin_length
	   stop_bin = start_bin + bin_length
	}

#  Update the output header with the min,max info
	call tim_compmu (minmax, float(num_of_bins))
	call tim_updhdr (minmax, tp, num_of_bins)

#  Close the input source and bkgd files
	call tim_qpclose(sqp,src_ptr)
	if( dobkgd)
	    call tim_qpclose(bqp,bk_ptr)
	
#  Close the output file
	call tbtclo (tp)

#  Finalize the names
	if ( display >= 1 ) {
	   call printf ("Creating ltcurv file: %s\n")
	      call pargstr (Memc[ltcurv_file])
	}
	call finalname (Memc[tempname], Memc[ltcurv_file])

#  Free the space
	call mfree (gbegs, TY_DOUBLE)
	call mfree (gends, TY_DOUBLE)
	call sfree (sp)
end

# ----------------------------------------------------------------------------
#
# Function:     ltc_inittab
# Purpose:      open a table file & init columns
# Notes:        column names are:
#                       time, ctrt, err, exp, src, bkgd, net, neterr
#
# ----------------------------------------------------------------------------
procedure ltc_inittab (tabname, clobber, col_cp, tp)

char    tabname[ARB]                    # i: table pointer
bool    clobber                         # i: clober old table file

pointer col_cp[ARB]                     # o: counts column pointer
pointer tp                              # o: table pointer

int     tbtacc()                        # l: table access function
pointer tbtopn()

begin

#    Clobber old file if it exists
        if ( tbtacc(tp) == YES )
        {
           if ( clobber )
           {
              iferr ( call tbtdel(tp) )
                 call eprintf("Can't delete old Table\n")
           }
           else
              call eprintf("Table file already exists\n")
        }
        tp = tbtopn (tabname, NEW_FILE, 0)

#    Define Columns
        call tbcdef (tp, col_cp[1], "time", "", "%15.5f", TY_DOUBLE, 1, 1)
        call tbcdef (tp, col_cp[2], "ctrt", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[3], "err", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[4], "exp", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[5], "src", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[6], "bkgd", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[7], "net", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[8], "neterr", "", "%12.5f", TY_REAL, 1, 1)

#    Now actually create it
        call tbtcre (tp)

end
# ----------------------------------------------------------------------------
#
# Function:     ltc_filltab
# Purpose:      write 1 table row to the file
#
# ----------------------------------------------------------------------------
procedure ltc_filltab (curbin, col_cp, tp, time, cnt_rate, ctrt_err, exp,
                       src_cnts, bk_cnts, net_cnts, net_err)
int     curbin                          # i: current table row to write
pointer col_cp[ARB]                     # i: column pointers
pointer tp                              # i: table pointer
double  time                            # i: sc time of bin
real    cnt_rate                        # i: cnt rate for 1 bin
real    ctrt_err                        # i: statistical error for 1 bin
real    exp                             # i: exposure for 1 bin
real    src_cnts                        # i: src photons in 1 bin
real    bk_cnts                         # i: bkgd photons in 1 bin
real    net_cnts                        # i: net cnts
real    net_err                         # i: error on src and bkgd cnts

begin

        {
           call tbrptd (tp, col_cp[1], time,     1, curbin)
           call tbrptr (tp, col_cp[2], cnt_rate, 1, curbin)
           call tbrptr (tp, col_cp[3], ctrt_err, 1, curbin)
           call tbrptr (tp, col_cp[4], exp,      1, curbin)
           call tbrptr (tp, col_cp[5], src_cnts, 1, curbin)
           call tbrptr (tp, col_cp[6], bk_cnts,  1, curbin)
           call tbrptr (tp, col_cp[7], net_cnts, 1, curbin)
           call tbrptr (tp, col_cp[8], net_err,  1, curbin)
        }
end
