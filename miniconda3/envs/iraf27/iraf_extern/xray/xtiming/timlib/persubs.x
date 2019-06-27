#$Header: /home/pros/xray/xtiming/timlib/RCS/persubs.x,v 11.0 1997/11/06 16:45:05 prosb Exp $
#$Log: persubs.x,v $
#Revision 11.0  1997/11/06 16:45:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:56  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:21  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/02  10:31:32  mo
#MC	5/2/94		Remove the obsolete routine t_outtable.  It's
#			no longer used and therefore uses out-of-date
#			calling sequences.  (reported in MAC/AUX port)
#
#Revision 7.0  93/12/27  19:02:57  prosb
#General Release 2.3
#
#Revision 6.4  93/12/22  12:34:23  janet
#jd - updated error calcs, added call to one_sigma lib.
#
#Revision 6.3  93/12/02  16:59:54  janet
#*** empty log message ***
#
#Revision 6.2  93/06/28  16:01:04  prosb
#jso - NO CHANGES.  flint caught a bad call in the routine t_outtable to
#      fld_fillhdr, but t_outtable is not used and was replaced by
#      fld_outtable, which has the correct call.
#
#Revision 6.1  93/06/28  15:53:32  prosb
#jso - i think these are janets changes (maureen changed the clobber line,
#      janet is on vacation).  i am checking them in before making my change.
#
#Revision 6.0  93/05/24  16:59:09  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:09:42  janet
#jd - added duration to tim_gintvs call.
#
#Revision 5.0  92/10/29  23:05:42  prosb
#General Release 2.1
#
#Revision 4.2  92/09/29  14:07:48  mo
#MC	9/29/92		Updated calling sequence for begs and ends rather
#			than 2 dimensional GTI's
#
#Revision 4.1  92/09/28  16:28:13  janet
#added pdot.
#
#Revision 4.0  92/04/27  15:36:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/23  17:51:01  janet
#update chisq calc, period increment calc, exposure binning, added chisq thresh.
#
#Revision 3.2  92/01/08  12:14:29  janet
#update plot headers; num_bins, formatting.
#
#Revision 3.1  91/09/24  14:45:18  janet
#added exposure screens made available in iraf 2.9.3
#
#Revision 2.1  91/07/25  12:34:37  janet
#fixed order of sprintf args.
#
#Revision 2.0  91/03/06  22:50:28  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	PERSUBS
# Project:	PROS -- ROSAT RSDC
# Purpose:	subroutines associated with the period task
# External:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version Apr 1989	
#		{1} JD -- 9/91  -- update chi_hdr routine to output
#                                  image hdr + table info
#		{2} JD -- 10/91 -- header updates for plots
#		{3} JD -- 11/91 -- write num original bins to hdr when
#                                  do_twice=yes & not 2*num_bins
#               {4} JD -- 3/92  -- added compute increment function
#               {5} JD -- 3/92  -- made fix to chisq calc, div by 1
#                                  when no contribution from bin
#               {6} JD -- 7/92  -- Added pdot
#
# ----------------------------------------------------------------------------

include  <tbset.h>
include	 <gset.h>
include  <qpset.h>
include  <qpioset.h>
include  <mach.h>
include  <qpoe.h>
include  <ext.h>
include  "timing.h"
include  "timstruct.h"
include  "../fold/fold.h"

#------------------------------------------------------------------------
procedure chi_inittab (tabname, clobber, col_cp, tp)

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
           if ( clobber)
           {
              iferr ( call tbtdel(tp) )
                 call eprintf("Can't delete old Table\n")
           }
           else
              call eprintf("Table file already exists\n")
        }
        tp = tbtopn (tabname, NEW_FILE, 0)

#    Define Columns
        call tbcdef (tp, col_cp[1], "chisq", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[2], "period", "", "%20.10f", TY_DOUBLE, 1, 1)

#    Now actually create it
        call tbtcre (tp)

end

# ---------------------------------------------------------------------
procedure chi_hdr (display, ctp, start_time, stop_time, srcarea,
                   bkarea, binlen, numbins, pbeg, pend, increment,
                   chisq, period, totcnts, tname, fname)


int     display         # i: display level 
pointer ctp             # i: output chisq file handle
double  start_time      # i: save start time in hdr
double  stop_time       # i: save stop time in hdr
double  srcarea         # i: save source area in hdr
double  bkarea          # i: save bkgd area in hdr
double  binlen          # i: save the num of secs/bin in hdr
int     numbins         # i: save number of bins
double  pbeg		# i: start period in seconds
double  pend		# i: stop period in seconds
double  increment	# i: increment of period
real    chisq           # i: best chisq
double  period		# i: period in secs with best chisq
int     totcnts         # i: number of counts 
pointer tname		# i: temp table name
pointer fname		# i: final table name
 
begin

        call tbhadd (ctp, "beg_time", start_time)
        call tbhadd (ctp, "end_time", stop_time)
        call tbhadd (ctp, "srcarea",  srcarea)
        call tbhadd (ctp, "bkarea",   bkarea)
#        call tbhadd (ctp, "binlen",   binlen)
        call tbhadi (ctp, "numbins",  numbins)

        call tbhadt (ctp, "taskinfo", "This Info reflects run of the Period task :")

        call tbhadd (ctp, "BEG_PER", pbeg)
        call tbhadd (ctp, "END_PER", pend)
        call tbhadd (ctp, "PERINCR", increment)
        call tbhadr (ctp, "BSTCHISQ", chisq)
        call tbhadd (ctp, "BSTPER", period)
        call tbhadi (ctp, "TOTCNTS", totcnts)
	if ( display > 0 ) {
	   call printf ("Creating Chisq file : %s \n")
	      call pargstr(Memc[fname])
	}
        call finalname (Memc[tname], Memc[fname])
        call mfree(fname, TY_CHAR)
 	call tbtclo (ctp)
end

# ---------------------------------------------------------------------
procedure per_startup (sqp, evlist, soffset, dobkgd, bqp, display, 
                      src_ptr, gbegs, gends, num_gintvs, start, stop, pstart, 
                      pstop, incr, search_density, numbins,pdot)

pointer 	sqp		# i: src qpoe ptr
char		evlist[ARB]	# i: user specified filter for events
int		soffset		# o: source time offset 
bool		dobkgd		# i: indicate whether to run bkgd
pointer		bqp		# o: bkgd qpoe ptr
int		display		# i: display level
pointer 	src_ptr		# o: qpoe src event ptr
pointer         gbegs		# o: good intervals buffer
pointer         gends		# o: good intervals buffer
int   		num_gintvs	# o: number of good intervals
double		start		# o: start time of data
double		stop		# o: stop time of data
double		pstart		# o: start period interval
double		pstop		# o: stop period interval
double          incr		# o: step between start & stop
double          search_density  # o: search density
int             numbins         # o: number of bins for data
double          pdot            # o: period rate of change param

double          duration        # l: sum of gti's

int             clgeti()
double          clgetd()

begin

# Make sure time is in the src event struct (and save offset of event element)
#        call tim_cktime(sqp,"source",soffset)
#        call tim_getarea(sqp,srcarea)
#        if ( dobkgd ) {
#            call tim_getarea(bqp,bkarea)
#            call tim_cktime(bqp,"bkgd",boffset)
#        }

#   Get good time intervals and start and stop times
         call tim_gintvs (display, sqp, src_ptr, soffset, evlist, 
                          start, stop, gbegs, gends, num_gintvs, duration)

#   Retrieve the period range and increment
         call per_incr (pstart, pstop, incr, search_density)

  	 numbins = clgeti(NUMOFBINS)
	 pdot = clgetd ("pdot")
         if (numbins > MAX_BINS) {
           call error (1,"Exceeded Max # Bins - requested %d when max is %d\n")
             call pargi(numbins)
             call pargi(MAX_BINS)
         } else if ( numbins <= 0 ) {
            numbins = 1
         }
 
end

# ---------------------------------------------------------------------
procedure per_incr (pstart,pstop,incr,search_density)

double  pstart                  # o: period start
double  pstop                   # o: period stop
double  incr                    # o: period increment
double  search_density          # o: search density


double  clgetd()

begin

#   Retrieve some parameters
        pstart = clgetd("period_start")
        pstop = clgetd("period_stop")
	incr = clgetd("incr")
        search_density = clgetd("search_density")

end

# ---------------------------------------------------------------------
procedure per_chisq (minmax, numbins, bdata, curper, row, col_cp, tp, 
                     chithresh, display, chisq)  

pointer minmax			# i: min/max struct ptr
pointer bdata
int     numbins			# i: number of data bins
double  curper			# i: current period
int     row                     # i: table row pointer
pointer col_cp[ARB]             # i: counts column pointer
pointer tp                      # i: table pointer
real    chithresh               # i: chisq threshold value from param input
int     display			# i: display level
real    chisq			# o: computed chisq 

int     curbin			# l: bin pointer
real    denom                   # l: chisq statistic equation denominator

begin

#   Compute the chi-squared statistic for the current trial fold period.

	  chisq = 0.0
 	  do curbin = 1, numbins {

#   If we have counts in the bin the denominator is the error squared
#   else, If no counts in the bin, the denominator is 1.
             if (CR(bdata,curbin) > 0.0) {
                denom = CRERR(bdata,curbin)**2

	     } else {
		denom = 1.0
	     }

#   There is a contribution to chisq from every bin given the above 
#   conditional on the denominator.
	     chisq = chisq + (CR(bdata,curbin) - CRMU(minmax))**2 / denom
	  }

	  if ( chisq >= chithresh ) {

	     if ( display >= 3 ) {
                call printf("ctrt_mu = %f, chisq = %f \n")
	          call pargr(CRMU(minmax))
	          call pargr(chisq)
	     }
	     row = row + 1
	     call tbrptr (tp, col_cp[1], chisq, 1, row)
	     call tbrptd (tp, col_cp[2], curper, 1, row)

	  } else {
             if ( display >= 3 ) {
		call printf ("Not saving chisq %f\n")
                   call pargr (chisq)
	     }
	  }

end

# ----------------------------------------------------------------------------
#
# Function:	fld_fillhdr
# Purpose:	write info to table header
# Notes:	saved header values are:
#			start_time, stop_time, src_area, bkgd_area, bin_length
#
# ----------------------------------------------------------------------------
procedure fld_fillhdr (tp, start_time, stop_time, srcarea, bkarea, 
		       binlen, period, numbins, pdot, cycles, bstmm)

pointer	tp				# i: table pointer
double  start_time			# i: save start time in hdr
double  stop_time			# i: save stop time in hdr
double  srcarea				# i: save source area in hdr
double  bkarea				# i: save bkgd area in hdr
double  binlen				# i: save the num of secs/bin in hdr
double  period                          # i: fold period
int     numbins				# i: save number of bins
double  pdot                            # i: period rate of change
int     cycles                          # i: save number of fold cycles
pointer bstmm				# i: pointer to best minmax

begin

#   Some useful numbers associated with timing task
	call tbhadt (tp, "taskinfo", "This Info reflects run of the Fold task:")
	call tbhadd (tp, "beg_time", start_time)
	call tbhadd (tp, "end_time", stop_time)
	call tbhadd (tp, "srcarea",  srcarea)
	call tbhadd (tp, "bkarea",   bkarea)
	call tbhadd (tp, "binlen",   binlen)
	call tbhadi (tp, "numbins",  numbins)
	call tbhadi (tp, "cycles",  cycles)
        call tbhadd (tp, "period", period)
        call tbhadd (tp, "pdot", pdot)
	call t_updhdr (bstmm, tp, numbins)

end
# -------------------------------------------------------------------------
#
# Function:     t_openqp
# Purpose:      Open a requested qpoe file and its event list
# Uses:         Uses the IRAF/QPOE library routines
# Pre-cond:     The input filename can be a path or any abbreviation of
#               None ( in any combination of caps and lower case )
# Post-cond:    The qp and qpio file handles are returned OR
#               The none boolean is set to TRUE if a 'None' input was
#               recognized.
#
# -------------------------------------------------------------------------
procedure t_openqp( param, ext, evlist, file_name, none, qp)

char    param[ARB]      # i: pointer to parameter name string
char    ext[ARB]        # i: pointer to required file extension string
char    evlist[ARB]     # i: name of evlist to open
char    file_name[ARB]  # i/o: name of qpoe file to open
bool    none            # o: was none the input filename
pointer qp              # o: returned qpoe file handle

pointer sp              # l: stack pointer
pointer file_root       # l: root name of input file
pointer sbuf		# l: string buffer

pointer qp_open()
bool    ck_none()
bool    streq()

begin
        call smark (sp)
        call salloc (sbuf,      SZ_LINE,     TY_CHAR)
        call salloc (file_root, SZ_PATHNAME, TY_CHAR) 

        call clgstr (param, file_name, SZ_PATHNAME)
        call rootname (file_name,file_name,ext,SZ_PATHNAME)
        none = ck_none( file_name )
        if (streq("", file_name) ) {
            call sprintf(sbuf,SZ_LINE,"requires *%s file as input\n")
            call pargstr(ext)
            call error(1, sbuf) 
        }
        if ( !none ) {
            call qpparse (file_name, Memc[file_root], SZ_PATHNAME,
                          evlist, SZ_EXPR)
            qp = qp_open (Memc[file_root], READ_ONLY, NULL)
        } else {
            call strcpy( file_name, evlist, SZ_PATHNAME)
	}

        call sfree(sp)
end


# -------------------------------------------------------------------------
#
# Function:     t_initbin
# Purpose:      Set up the first time bin and zero the total exposure
# Uses:         tim_initmm
# Pre-cond:     Needs a starting point and bin length
# Post-cond:    Returns the bin limits and exposure
#
# -------------------------------------------------------------------------
procedure t_initbin (minmax, sqp, bqp, sevlist, bevlist, dobkgd, display, 
	              src_ptr, bk_ptr, bdata, period, numbins, binlen)


pointer minmax          # i: min and max values
pointer sqp		# i: qpoe src pointer
pointer bqp		# i: qpoe bkgd pointer
char    sevlist[ARB]	# i: src event list
char    bevlist[ARB]    # i: bkgd event list
bool    dobkgd		# i: logical for background
int     display         # i: display level
pointer src_ptr		# o: qpio src pointer
pointer bk_ptr		# o: qpio bkgd pointer
pointer bdata           # o: bin data ptr
double  period          # o: period in secs to fold data
int     numbins         # o: returned number of bins
double  binlen		# o: seconds per bin

int     foo[2]

begin

#   Init minmax structure
        call tim_initmm (minmax)

#   Clear source, background, and exposure buffers for reuse
	call aclrr (SRC(bdata,1), BIN_MAX)
        call aclrr (BK(bdata,1),  BIN_MAX)
        call aclrr (EXP(bdata,1), BIN_MAX)

#   Reset the qpoe io filesection
#   --- the following routine resets the qpoe pointer to the beginning
#   --- of the file, and the range is the entire data set.  
        call qpio_setrange (src_ptr, foo, foo, 0)
#	call qpio_rewind(src_ptr)

        if ( dobkgd )  {
           call qpio_setrange (bk_ptr, foo, foo, 0)
#          call qpio_rewind(bk_ptr)
        }

#   Compute Number and Length of Bins
        binlen = period / real (numbins)
 
        if ( display > 1 ) {
           call printf("Binning %d Intervals with binsize of %25.10f secs\n")
             call pargi(numbins)
             call pargd(period)
           call flush(STDOUT)
        }
end

# --------------------------------------------------------------------------
#
# Function:	t_cntrate
# Purpose:	Compute the count rate for 1 bin of data
#
# --------------------------------------------------------------------------
procedure  t_cntrate (bdata, minmax, numbins, errtype, srcarea, bkarea, 
		      bknorm, display)

pointer  bdata			# i: bin data structure
pointer  minmax			# i: minmax structure
int	 numbins		# i: current timing bin 
int      errtype                # i: error type; pois or gaus
double   srcarea		# i: source area
double   bkarea			# i: bkgrd area
real     bknorm			# i: bkgd normalization factor
int      display

int      curbin			# l: loop cntr

begin

        do curbin = 1, numbins {

	   call t_netcts (bdata, curbin, srcarea, bkarea, bknorm, errtype)

           call t_adjexp (bdata, curbin, display) 

 	   call t_minmax (minmax, bdata, curbin)

	}
	call tim_compmu (minmax, real(numbins))

end

# --------------------------------------------------------------------------
#
# Function:	t_netcnts
# Purpose:	Compute the net counts & statistical error for 1 bin of data
#
# --------------------------------------------------------------------------
procedure t_netcts (bdata, bin, srcarea, bkarea, bknorm, errtype)

pointer  bdata			# i: bin data struct ptr
int      bin			# i: current bin
double   srcarea		# i: source area
double   bkarea			# i: bkgrd area
real     bknorm			# i: bkgd normalization factor
int      errtype                # i: error type; pois or gaus

real     berr, serr             # l: bk and src error
real	 stob			# l: (source area)/(bkgrd area)

begin

#   First divide source area by bkgd area.  The default bknorm is 1.
	if ( bkarea > EPSILONR ) {
	    stob =  srcarea/bkarea * bknorm
	} else {
	    stob = 0.0
	}

#       call printf ("errtype = %d\n")
#         call pargi (errtype)
#	call flush (STDOUT)

#   Compute the Net source counts and Statistical error
        if ( EXP(bdata,bin) > EPSILONR ) {
           NETCTS(bdata,bin) = SRC(bdata,bin) - stob*BK(bdata,bin)

           call one_sigma(SRC(bdata,bin),1,errtype,serr)
           call one_sigma(BK(bdata,bin),1,errtype,berr)
           NETERR(bdata,bin) = sqrt(serr**2 + (stob**2)*berr**2) 
	} else {
	   NETCTS(bdata,bin) = 0.0
	   NETERR(bdata,bin) = 0.0
	}

        # - old error calc -
        # NETERR(bdata,bin) = sqrt(SRC(bdata,bin) + stob*stob*BK(bdata,bin))
        # - old error calc -
end

# --------------------------------------------------------------------------
#
# Function:	t_adjexp
# Purpose:	compute cntrate & it's error 
#
# --------------------------------------------------------------------------
procedure t_adjexp (bdata, bin, display) 

pointer  bdata		# i: bin data struct ptr
int      bin		# i: current bin for data
int      display

begin


#     Compute the count rate and count rate error
	
	if ( EXP(bdata,bin) > EPSILONR ) {
	   CR(bdata,bin) = NETCTS(bdata,bin) / EXP(bdata,bin)
	   CRERR(bdata,bin) = NETERR(bdata,bin) / EXP(bdata,bin)
	} else  {
	   CR(bdata,bin) = 0.0
	   CRERR(bdata,bin) = 0.0
	   if ( NETCTS(bdata,bin) > EPSILONR )  {
              if ( display >= 2 ) {
	        call printf("Bin %d has %f counts but no exposure! \n")
		  call pargi (bin)
		  call pargr (CR(bdata,bin))
	      }
	   }
	}
end

# ----------------------------------------------------------------------------
#
# Function:	t_minmax
# Purpose:	determine column min & max values
# Notes:	column names are: 
#			ctrt, ctrt_err, exp, cnts, bkgd, net, neterr
#
# ----------------------------------------------------------------------------
procedure t_minmax (minmax, bdata, bin)

pointer minmax		# i: min/max struct ptr
pointer bdata		# i: bin data struct
int     bin		# i: current bin

begin

	CRMIN(minmax)  = min (CR(bdata,bin), CRMIN(minmax))
	CRMAX(minmax)  = max (CR(bdata,bin), CRMAX(minmax))
	CRMU(minmax)   = CRMU(minmax) + CR(bdata,bin)

	CREMIN(minmax) = min (CRERR(bdata,bin), CREMIN(minmax))
	CREMAX(minmax) = max (CRERR(bdata,bin), CREMAX(minmax))
	CREMU(minmax)  = CREMU(minmax) + CRERR(bdata,bin)

	EXPMIN(minmax) = min (EXP(bdata,bin), EXPMIN(minmax))
	EXPMAX(minmax) = max (EXP(bdata,bin), EXPMAX(minmax))
	EXPMU(minmax)  = EXPMU(minmax) + EXP(bdata,bin)

	SMIN(minmax)   = min (SRC(bdata,bin), SMIN(minmax))
	SMAX(minmax)   = max (SRC(bdata,bin), SMAX(minmax))
	SMU(minmax)    = SMU(minmax) + SRC(bdata,bin)

	BMIN(minmax)   = min (BK(bdata,bin), BMIN(minmax))
	BMAX(minmax)   = max (BK(bdata,bin), BMAX(minmax))
	BMU(minmax)    = BMU(minmax) + BK(bdata,bin)

	NMIN(minmax)   = min (NETCTS(bdata,bin), NMIN(minmax))
	NMAX(minmax)   = max (NETCTS(bdata,bin), NMAX(minmax))
	NMU(minmax)    = NMU(minmax) + NETCTS(bdata,bin)

	NEMIN(minmax)   = min (NETERR(bdata,bin), NEMIN(minmax))
	NEMAX(minmax)   = max (NETERR(bdata,bin), NEMAX(minmax))
	NEMU(minmax)    = NEMU(minmax) + NETERR(bdata,bin)

	NTOT(minmax)    = NTOT(minmax) + NETCTS(bdata,bin)
end

# -------------------------------------------------------------------------
#
# Function:     chi_outtable
# Purpose:      Read filename and clobber parameters and create output filename
# Uses:         clobbername, rootname, etc.
# Pre-cond:     Needs the template to build the output filename
# Post-cond:    The temporary and final output filename
# Method:       Uses the standard PROS rootname,clobbername
# -------------------------------------------------------------------------
procedure chi_outtable(param,ext,master_name,output_name,tempname,clobber)

char    param[ARB]		# i: file name
char    ext[ARB]                # i: output file extension
pointer master_name             # i: input template name
pointer output_name             # o: output filename
pointer tempname                # o: temp filename
bool    clobber                 # o: clobber value

bool    streq()

begin

#   Get input/output filenames
#        call clgstr (param, Memc[output_name], SZ_PATHNAME)

#        call malloc(output_name,SZ_PATHNAME,TY_CHAR)
        call strcpy("", Memc[output_name],SZ_PATHNAME)

        call rootname(Memc[master_name],Memc[output_name], ext, SZ_PATHNAME)
        if (streq("NONE", Memc[output_name]) ) {
           call error(1, "requires table file as output")
        }
        call clobbername(Memc[output_name],Memc[tempname],clobber,SZ_PATHNAME)
end


# -------------------------------------------------------------------------
procedure t_savbest(bdata, mmptr, bst, bstmm, numbins, display)

pointer bdata		# i: bin data struct ptr
pointer mmptr		# i: minmax struct ptr
pointer bst		# i: best bin data struct ptr
pointer bstmm		# i: best minmax struct ptr
int     numbins		# i: number of data bins
int     display		# i: display level

begin

#   Save the bin data in Best Structure
	call amovr (SRC(bdata,1),    BST_SRC(bst,1),    numbins)
	call amovr (BK(bdata,1),     BST_BK(bst,1),     numbins)
	call amovr (EXP(bdata,1),    BST_EXP(bst,1),    numbins)
	call amovr (CR(bdata,1),     BST_CR(bst,1),     numbins)
	call amovr (CRERR(bdata,1),  BST_CRERR(bst,1),  numbins)
	call amovr (NETCTS(bdata,1), BST_NETCTS(bst,1), numbins)
	call amovr (NETERR(bdata,1), BST_NETERR(bst,1), numbins)

#   Save the Minmax data in Best Structure
	call amovr (CRMIN(mmptr), BCRMIN(bstmm), LEN_MMM)
end

# -------------------------------------------------------------------------
procedure t_bindata (sqp, bqp, start, stop, ref_period, numbins, pdot, dobkgd, 
                     display, soffset, boffset, num_gintvs, gbegs, gends, binptr)

pointer sqp		#i: source qpoe pointer
pointer bqp		#i: background qpoe pointer
double  start		#i: start time
double  stop		#i: stop time
double  ref_period      #i: reference period for current fold
int     numbins		#i: number of bins
double  pdot		#i: period rate of change
bool    dobkgd		#i: logical whether to use bkgd
int     display		#i: display level
int     soffset		#i: source time offset
int     boffset		#i: background time offset
int     num_gintvs	#i: num of good intervals
double  gbegs[ARB]	#i: good intervals buffer
double  gends[ARB]	#i: good intervals buffer
pointer binptr		#i/o: pointer to bin structure


begin

#   Bin the source photons
          call t_srcbin (sqp, start, ref_period, numbins, display,
			 soffset, pdot, binptr)

#   Bin the background photons
          if ( dobkgd )  {
              call t_bkbin (bqp, start, ref_period, numbins, display,
                            boffset, pdot, binptr)
          }

#   Bin the exposure as determined by the good time intervals
          call t_exp (display, num_gintvs, start, stop, gbegs, gends, numbins, 
                      ref_period, pdot, binptr)

end

# ----------------------------------------------------------------------------
#
# Function:     fld_filltab
# Purpose:      write 1 table row to the file
#
# ----------------------------------------------------------------------------
procedure fld_filltab (binptr, firstrow, lastrow, col_cp, tp)


pointer binptr			# i: bin data struct ptr
int     firstrow		# i: start row to write data 
int     lastrow			# i: end row to write data 
pointer col_cp[ARB]             # i: column pointers
pointer tp                      # i: table pointer

int     i,j

begin

	j = 0
	do i = firstrow, lastrow {
	   j = j+1
           call tbrptr (tp, col_cp[1], CR(binptr,j),    1, i)
           call tbrptr (tp, col_cp[2], CRERR(binptr,j), 1, i) 
           call tbrptr (tp, col_cp[3], EXP(binptr,j),   1, i)
           call tbrptr (tp, col_cp[4], SRC(binptr,j),   1, i)
           call tbrptr (tp, col_cp[5], BK(binptr,j),    1, i)
           call tbrptr (tp, col_cp[6], NETCTS(binptr,j),1, i)
           call tbrptr (tp, col_cp[7], NETERR(binptr,j),1, i)
        }
end

# ----------------------------------------------------------------------------
#
# Function:     t_updhdr
# Purpose:      write min/max info to table header
# Notes:        saved header values are:
#               ctrt min, ctrt max, err min, err max, exp min, exp max,
#               cnts min, cnts max, bkgd min, bkgd max, net min, net max,
#               neterr min, neterr max
#
# ----------------------------------------------------------------------------
procedure t_updhdr (bstmm, tp, bins)
 
pointer bstmm		# i: min/max struct pointer
pointer tp              # i: table pointer
int     bins            # i: number of bins 

begin
#   Some useful numbers when plotting

        call tbhadr (tp, "ctrtmn",   BCRMIN(bstmm))
        call tbhadr (tp, "ctrtmx",   BCRMAX(bstmm))
        call tbhadr (tp, "ctrtmu",   BCRMU(bstmm))
 
        call tbhadr (tp, "errmn",    BCREMIN(bstmm))
        call tbhadr (tp, "errmx",    BCREMAX(bstmm))
        call tbhadr (tp, "errmu",    BCREMU(bstmm))
 
        call tbhadr (tp, "expmn",    BEXPMIN(bstmm))
        call tbhadr (tp, "expmx",    BEXPMAX(bstmm))
        call tbhadr (tp, "expmu",    BEXPMU(bstmm))
 
        call tbhadr (tp, "srcmn",    BSMIN(bstmm))
        call tbhadr (tp, "srcmx",    BSMAX(bstmm))
        call tbhadr (tp, "srcmu",    BSMU(bstmm))

        call tbhadr (tp, "bkgdmn",   BBMIN(bstmm))
        call tbhadr (tp, "bkgdmx",   BBMAX(bstmm))
        call tbhadr (tp, "bkgdmu",   BBMU(bstmm))
 
        call tbhadr (tp, "netmn",    BNMIN(bstmm))
        call tbhadr (tp, "netmx",    BNMAX(bstmm))
        call tbhadr (tp, "netmu",    BNMU(bstmm))
 
        call tbhadr (tp, "neterrmn", BNEMIN(bstmm))
        call tbhadr (tp, "neterrmx", BNEMAX(bstmm))
        call tbhadr (tp, "neterrmu", BNEMU(bstmm))

        call tbhadi (tp, "totcnts",  int(BNTOT(bstmm)))
 
end


# ---------------------------------------------------------------------
procedure fld_startup (sqp, evlist, soffset, dobkgd, bqp, display, src_ptr, 
              gbegs, gends, num_gintvs, start, stop, period, numbins, pdot)

pointer 	sqp		# i: src qpoe ptr
char		evlist[ARB]	# i: user filter specifier for evlist
int		soffset		# o: source time offset 
bool		dobkgd		# i: indicate whether to run bkgd
pointer		bqp		# o: bkgd qpoe ptr
int		display		# i: display level
pointer 	src_ptr		# o: qpoe src event ptr
pointer         gbegs		# o: good intervals buffer
pointer         gends		# o: good intervals buffer
int   		num_gintvs	# o: number of good intervals
double		start		# o: start time of data
double		stop		# o: stop time of data
double          period          # o: fold period in secs
int             numbins         # o: number of bins for data
double          pdot            # o: period rate of change

double          duration        # l: sum of gti's

int             clgeti()
double          clgetd()

begin

# Make sure time is in the src event struct (and save offset of event element)
#        call tim_cktime(sqp,"source",soffset)
#        call tim_getarea(sqp,srcarea)
#        if ( dobkgd ) {
#            call tim_getarea(bqp,bkarea)
#            call tim_cktime(bqp,"bkgd",boffset)
#        }

#   Get good time intervals
         call tim_gintvs (display, sqp, src_ptr, soffset, evlist, 
                          start, stop, gbegs, gends, num_gintvs, duration)

#   Retrieve the fold period 
         period = clgetd(FOLDPERIOD)

         pdot = clgetd("pdot")

  	 numbins = clgeti(NUMOFBINS)
         if (numbins > MAX_BINS) {
           call error (1,"Exceeded Max # Bins - requested %d when max is %d\n")
             call pargi(numbins)
             call pargi(MAX_BINS)
         } else if ( numbins <= 0 ) {
            numbins = 1
         }

         if ( period < EPSILOND ) {
            period = (stop - start) / double(numbins)
	    call eprintf ("Note: 0.0 period specified, Setting Period to %f\n")
              call pargd(period)
	 }
 
end

# -------------------------------------------------------------------------
procedure fld_outtable (display, pfile,bfile,clobber, sqp, bqp, dobkgd, 
                        start, stop, srcarea, bkarea, binlen, period,
                        numbins, pdot, bst, bstmm, tempname, table_file)

int     display         # i: display level
pointer pfile		# i: photon file name
pointer bfile		# i: bkgd file name
bool    clobber		# i: clobber file logical
pointer sqp		# i: src qpoe ptr
pointer bqp		# i: bkgd qpoe ptr
bool    dobkgd		# i: logical for bkgd
double  start		# i: start time
double  stop		# i: stop time
double  srcarea		# i: src area
double  bkarea		# i: bkgd area
double  binlen		# i: len of bin in secs
double  period          # i: period in seconds
int     numbins		# i: number of bins
double  pdot            # i: period rate of change
pointer bst		# i: best bin data struct ptr
pointer bstmm		# i: best min max struct ptr
pointer table_file      # i: name of output file
pointer tempname	# i: temp name for out file

pointer col_cp[10]	# l: table pointer buff
pointer sp		# l: space allocation pointer
pointer tp		# l: table pointer

int     cycles          # l: number of cycles in output table

bool    clgetb()

begin

        call smark(sp)

#   Initialize tables columns
        call tim_inittab (Memc[tempname], clobber, col_cp, tp)
 
#   Write Qpoe info to output table hdr 
	call tim_hdr (tp,sqp,bqp,Memc[pfile],Memc[bfile],dobkgd)

#   Write data to table
	call fld_filltab (bst, 1, numbins, col_cp, tp)
        cycles=1

	if ( clgetb(DOTWICE) ) {

#  Fill table again and Write task specific params to table hdr
	   call fld_filltab (bst, numbins+1, numbins*2, col_cp, tp)
           cycles=cycles+1
        }

#  updated to remove numbins*2 at fds request 11/91
#	   call fld_fillhdr (tp, start, stop, srcarea, bkarea, binlen, 
#                             period, numbins*2, bstmm)
#       } else {

	call fld_fillhdr (tp, start, stop, srcarea, bkarea, binlen, 
                          period, numbins, pdot, cycles, bstmm)
        call tbtclo(tp)
	if ( display > 0 ) {
	   call printf ("Creating Fold file : %s \n")
	      call pargstr(Memc[table_file])
	}
	call finalname (Memc[tempname], Memc[table_file])
	call sfree(sp)

end

# ------------------------------------------------------------------------
double procedure compute_next_period (curper, increment, search_density,
                                      start_time, stop_time, num_of_bins)

double   curper                 # current period in secs
double   increment              # increment of period
double   search_density         # search density
double   start_time             # start time for binning
double   stop_time              # stop time for binning
int      num_of_bins            # number of data bins

double   nextper                # the next search period

begin

#   When the increment is specified, we add it to the current period to
#   compute the next one.
          if ( increment > EPSILOND ) {
             nextper = curper + increment

#   When the increment is 0, the user want us to choose the increment.
#   The value of the period being used and must have an explicit
#   dependence on the number of bins being used.
          } else  {
             nextper = curper + (search_density * curper**2) /
                                (num_of_bins * (stop_time - start_time))
          }
          return (nextper)

end

# ---------------------------------------------------------------------
