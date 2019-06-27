# $Header: /home/pros/xray/xtiming/vartst/RCS/var_subs.x,v 11.0 1997/11/06 16:45:24 prosb Exp $
# $Log: var_subs.x,v $
# Revision 11.0  1997/11/06 16:45:24  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:35:26  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:43  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  12:51:02  janet
#jd - updated to include pointer to table header (tbhead).
#
#Revision 6.1  93/07/02  15:03:41  mo
#MC	7/2/93	change float to real
#		(RS6000 port)
#
#Revision 6.0  93/05/24  16:59:58  prosb
#General Release 2.2
#
#Revision 1.1  93/05/20  10:20:09  janet
#Initial revision
#
#
# -------------------------------------------------------------------------
# Module:	Vartst
# Project:	PROS -- ROSAT RSDC
# Purpose:	vartst utility routines
# Includes: 	ksone (), ks_thresh(), ks_prob(), cvm_prob(), ks_inittab(), 
#	    	wr_varout(), get_nphots(), var_fillhdr(), wr_pltcmds(), 
#           	wr_ovrlycmds(), lineout()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - Mar 1993 - Initial Version
#
# -------------------------------------------------------------------------
include  <error.h>
include  <tbset.h>
include  <qpoe.h>
include  <qpset.h>
include  "vartst.h"

# ---------------------------------------------------------------------
#
# Function:       ksone.X
# Purpose:        Perform the ks-test on the input data.         
#		  This code is a combination of 'Numerical Methods'
#		  routine ksone, Fielgelson PROS spec, and MPE PSPC
#		  code ks.for.
#
# -------------------------------------------------------------------------
procedure ksone (qp, tp, col_cp, display, offset, nphots, ngtis, 
		 gtibeg, gtiend, acctime, thresh, d, cvm)

pointer  qp                     # i: file descriptor
pointer  tp			# i: output table pointer
pointer  col_cp[ARB]		# i: table column pointers
int      display                # i: display level
int      offset                 # i: offset of the time element in qrec
int      nphots			# i: number of source photons
int      ngtis			# i: number of good time intvs
double   gtibeg[ARB]		# i: gti begin times
double   gtiend[ARB]		# i: gti end times
double   acctime		# i: accepted time - sum of gtis
real     thresh			# i: variability threshold for conf bands
real     d			# o: ks-test supremum
double   cvm			# o: CvM tally

double   phot_time              # l: photon time
double   degap_time		# l: degapped event time
double   gapsum			# l: sum of gaps till curr photon
double   gtistart		# l: 1st gti start
real	 dt			# l: current diff
real	 prevcdf		# l: previous cdf
real 	 cdf			# l: data's cdf at current step
real	 model			# l: model's cdf at current step
real     cdfplus, cdfminus      # l: confidence bands
int      mval                   # l: mask value returned by qpio_getevent
int      nev                    # l: num of events returned by qpio_getevent
int      qrec                   # l: current qpoe record
int      i			# l: gti pointer
int      cur_phot		# l: photon counter
pointer  evl[LEN_EVBUF]         # l: event list buffer

bool     tim_getnxtime()

begin


        # variable initialization
        i=1
        gapsum=0
        gtistart = gtibeg[1]
	d = 0.0
	prevcdf = 0.0
        degap_time = 0.0d0
        cvm = 0.0d0

        nev=0
        qrec=0
        cur_phot=0

	# loop thru the qpoe file and return the time-ordered event times
        while (tim_getnxtime (qp, mval, nev, evl, qrec, offset, phot_time)) {

           cur_phot = cur_phot + 1

	   # update sum of the gaps previous to the current photon time
#           if ( phot_time > gtiend[i] ) {

           do while ( phot_time > gtiend[i] ) {
              i = i+1
              gapsum = gapsum + (gtibeg[i] - gtiend[i-1])
	   }

	   # degap and normalize the event times 
	   degap_time = (phot_time - gtistart - gapsum) 

           if ( display >= 5 ) {
               call printf ("%d; time= %.3f, gapsum=%.3f, degap_time=%.3f \n")
                  call pargi (cur_phot)
                  call pargd (phot_time)
                  call pargd (gapsum)
                  call pargd (degap_time)
	   }

           # Determine the data's cdf at this step 
	   cdf = float (cur_phot) / float (nphots)

           # compute the confidence band limits for the given threshold
           cdfplus = amin1 ((cdf+thresh),1.0)
           cdfminus = amax1 ((cdf-thresh),0.0)

           # Determine the Model's cdf at this step
#	   model = float (degap_time / acctime)
	   model = real(degap_time / acctime)

           # Compare the model and the data
	   dt = amax1(abs(prevcdf-model), abs(cdf-model))

	   # ... and save the maximum distance.
	   if ( dt > d ) {
               d = dt
           }

	   prevcdf = cdf

	   # while we`re here computing ks-test, we'll compute the CvM too.
           cvm = cvm + (double (model) - (2.0*double(cur_phot)-1.0)/
                                         (2.0*double(nphots)))**2

           if ( display >= 4 ) {
	      call printf ("cdf=%.3f, model=%.3f, dt=%.3f, cvm=%.3f plus=%.3f minus=%.3f\n")
	         call pargr (cdf)
	         call pargr (model)
	         call pargr (dt)
                 call pargd (cvm)
                 call pargr (cdfplus)
                 call pargr (cdfminus)
           }

           # write current row of data to the output table
           call wr_varout (tp, cur_phot, col_cp, degap_time, dt, model, 
                           cdf, cdfplus, cdfminus)
        }

        # final CvM calc
        cvm = cvm + 1.0/(12.0*double(nphots))
end

# ---------------------------------------------------------------------
#
# Function:       ks_thresh.X
# Purpose:        Determine the ks thresholds for 90, 95, and 99% 
#		  confidence.  KS probability Constants define in 
#		  vartst.h.  Along with the equation for 'f' they 
#		  are taken from MPE PSPC code ks.for.         
#
# -------------------------------------------------------------------------
procedure ks_thresh (nphots, band, t90, t95, t99, bthresh)

int	nphots			# i: number of photons
real    band			# i: band for cdfplus/minus calc (90|95|99)
real	t90			# o: 90 percent threshold
real	t95			# o: 95 percent threshold
real    t99 			# o: 99 percent threshold
real    bthresh                 # o: band threshold

real    f			# i: thresh factor

begin
        # Determine the thresholds 
        f = 1.0 / sqrt (float(nphots) + sqrt(float(nphots)/10.0))

	t90 = C90_KS * f
	t95 = C95_KS * f
	t99 = C99_KS * f

        if ( band == 90.0 ) {
 	   bthresh = t90
        } else if ( band == 95.0 ) {
           bthresh = t95
        } else if ( band == 99.0 ) {
           bthresh = t99
	} else {
	   call printf ("Bandwidth undefined, assigning 90%%\n")
           bthresh = t90
	}
end

# ---------------------------------------------------------------------
#
# Function:       ks_prob.X
# Purpose:	  With the maximum distribution of the data (d), determine
#                 which confidence range (if any) variablilty is detected.
# -------------------------------------------------------------------------
procedure ks_prob (d, t90, t95, t99)

real    d			# i: maximum distribution
real	t90			# i: 90 percent threshold
real	t95			# i: 95 percent threshold
real    t99 			# i: 99 percent threshold

begin

	call printf ("\n  Ks-test Thresh. :  90%% = %.3f,  95%% = %.3f,  99%% = %.3f\n")
	   call pargr (t90)
	   call pargr (t95)
	   call pargr (t99)

        # ... and test for goodness of fit.
        if ( d >= t99 ) {
           call printf ("  Max diff = %.5f, Variability detected with 99%% confidence level\n")
	} else if ( d >= t95 ) {
           call printf ("  Max diff = %.5f, Variability detected with 95%% confidence level\n")
	} else if ( d >= t90 ) {
           call printf ("  Max diff = %.5f, Variability detected with 90%% confidence level\n")
	} else { 
           call printf ("  Max diff = %.5f, No Variability detected\n")
        }
        call pargr (d)

end

# -------------------------------------------------------------------------
#
# Function:       cvm_prob.X
# Purpose:	  With the computed CvM of the data, determine
#                 which confidence range (if any) variablilty is detected.
#                 CVM confidences set in include file vartst.h
# -------------------------------------------------------------------------
procedure cvm_prob (cvm)

double	cvm		# CvM probability

begin
	
	call printf ("\n\n  CvM Thresh. :  90%% = %.3f,  95%% = %.3f,  99%% = %.3f\n")
	   call pargr (C90_CVM)
	   call pargr (C95_CVM)
	   call pargr (C99_CVM)

        # ... and test for goodness of fit.
        if ( cvm >= double(C99_CVM)) {
           call printf ("  CvM = %.5f, Variability detected with 99%% confidence level\n\n")
	} else if ( cvm >= double(C95_CVM)) {
           call printf ("  CvM = %.5f, Variability detected with 95%% confidence level\n\n")
	} else if ( cvm >= double(C90_CVM)) {
           call printf ("  CvM = %.5f, Variability detected with 90%% confidence level\n\n")
	} else { 
           call printf ("  CvM = %.5f, No Variability detected\n\n")
        }
        call pargd (cvm)

end

# -------------------------------------------------------------------------
#
# Function:       ks_inittab
# Purpose:	  Init the output table and copy qp header into tab hdr
#		  cols : time  dist  model  cdf  cdfplus  cdfminus
# --------------------------------------------------------------------------
procedure ks_inittab (tabname, clobber, sqp, photon_file, col_cp, tp)

char    tabname[ARB]		# i: table pointer
bool    clobber         	# i: clober old table file
pointer sqp			# i: qpoe handle
char    photon_file[ARB]	# i: input qpoe name

pointer col_cp[ARB]             # o: counts column pointer
pointer tp                      # o: table pointer

pointer qphd

int     tbtacc()                # l: table access function
pointer tbtopn()		# l: table open function

begin

        #  Clobber old file if it exists
        if ( tbtacc(tabname) == YES ) {
           if ( clobber ) {
              iferr ( call tbtdel(tabname) )
                 call eprintf("Can't delete old Table\n")
           } else {
              call eprintf("Table file already exists\n")
           }
        }
        tp = tbtopn (tabname, NEW_FILE, 0)

        #  Define Columns
        call tbcdef (tp, col_cp[1], "time", "", "%12.5f", TY_DOUBLE, 1, 1)
        call tbcdef (tp, col_cp[2], "dist", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[3], "model", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[4], "cdf", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[5], "cdfplus", "", "%12.5f", TY_REAL, 1, 1)
        call tbcdef (tp, col_cp[6], "cdfminus", "", "%12.5f", TY_REAL, 1, 1)

        #  Now actually create it
        call tbtcre (tp)

        #  Init the header with qp hdr info
        call get_qphead (sqp, qphd)
        call put_tbhead (tp, qphd)
        call tim_addmsk(tp, sqp, photon_file, "s")
        call mfree(qphd, TY_STRUCT)

end

# -------------------------------------------------------------------------
#
# Function:       wr_varout
# Purpose:	  write 1 row of data to output table at the current row  
# -------------------------------------------------------------------------
procedure wr_varout (tp, curbin, col_cp, time, dist, model, 
		     cdf, cdfplus, cdfminus)

pointer tp			# i: output table handle
int     curbin			# i: current row to write
pointer col_cp[ARB]             # i: counts column pointer
double  time			# i: degapped time
double  dist			# i: distribution
real    model			# i: model's cdf
real    cdf			# i: data's cdf
real    cdfplus			# i: data's cdf pos conf band
real    cdfminus		# i: data's cdf neg conf band

begin

        call tbrptd (tp, col_cp[1], time,     1, curbin)
        call tbrptr (tp, col_cp[2], dist,     1, curbin)
        call tbrptr (tp, col_cp[3], model,    1, curbin)
        call tbrptr (tp, col_cp[4], cdf,      1, curbin)
        call tbrptr (tp, col_cp[5], cdfplus,  1, curbin)
        call tbrptr (tp, col_cp[6], cdfminus, 1, curbin)

end

# -------------------------------------------------------------------------
#
# Function:       get_nphots
# Purpose:	  Read through the qpoe event list summing up the number
#		  of events.  This method looks lame, but there isn't 
#		  another way to do it since time filters are allowed on
#		  the command line.
# -------------------------------------------------------------------------
procedure get_nphots (qp, display, offset, nphots)

pointer  qp                     # i: file descriptor
int      display                # i: display level
int      offset                 # i: offset of the time element in qrec
int      nphots                 # o: returned number of photons

double   phot_time              # l: photon time
int      mval                   # l: mask value returned by qpio_getevent
int      nev                    # l: num of events returned by qpio_getevent
int      qrec                   # i/o: current qpoe record
pointer  evl[LEN_EVBUF]         # l: event list buffer

int      foo[2]

bool     tim_getnxtime()

begin

        nphots = 0
        nev=0
        qrec=0

        # loop through the events and sum the number of photons
        while (tim_getnxtime (qp, mval, nev, evl, qrec, offset, phot_time)) {
           nphots=nphots+1
        }

        if ( display > 0 ) {
          call printf ("Number of Events = %d\n")
            call pargi (nphots)
	}

        call qpio_setrange (qp, foo, foo, 0)

end

# ---------------------------------------------------------------------
#
# Function:       var_fillhdr.X
# Purpose:        Write task header info to output table.  They're some
#		  useful number to have around        
#
# ----------------------------------------------------------------------------
procedure var_fillhdr (tp, start_time, stop_time, acctime, sarea, cvm, d, 
                       t90, t95, t99, band, nphots)

pointer tp                      # i: table pointer
double  start_time              # i: save start time in hdr
double  stop_time               # i: save stop time in hdr
double  acctime                 # i: sum of filtered gti's
double  sarea                   # i: save source area in hdr
double  cvm			# i: CvM 

real    d			# i: max diff
real    t90, t95, t99		# i: ks-test thresholds
real    band			# i: thresh at which cdf +/- is computed

int     nphots			# i: number of photons

begin

        # Some useful numbers associated with timing task
        call tbhadt (tp,"taskinfo","This Info reflects run of the Vartst task:")
        call tbhadd (tp, "beg_time", start_time)
        call tbhadd (tp, "end_time", stop_time)
        call tbhadd (tp, "val_secs", acctime)
        call tbhadd (tp, "srcarea", sarea)

        call tbhadi (tp, "nphots", nphots)

        call tbhadr (tp, "ks_90", t90)
        call tbhadr (tp, "ks_95", t95)
        call tbhadr (tp, "ks_99", t99)
        call tbhadr (tp, "max_diff", d)
        call tbhadr (tp, "cdf_band", band)

        call tbhadr (tp, "cvm_90", C90_CVM)
        call tbhadr (tp, "cvm_95", C95_CVM)
        call tbhadr (tp, "cvm_99", C99_CVM)
        call tbhadd (tp, "cvm_stat", cvm)
end

# ---------------------------------------------------------------------
#
# Function:       wr_pltcmds.X
# Purpose:        Write ksplot commands to an ascii command file.         
#		  These commands are input to stsdas igi task to plot
#		  the ks-test plot.
# ----------------------------------------------------------------------------
procedure wr_pltcmds (tp, plt_file, clob, nphots, tstart, tstop, acctime,
                      d, t90, t95, t99, display)

pointer  tp			# i: table pointer
int      nphots                 # i: number of photons in qpoe
int      display                # i: display level
char     plt_file[ARB]		# i: output table file name
bool     clob			# i: clobber ascii file if it exists?
real     d			# i: Max diff between the cdf and model
real	 t90, t95, t99		# i: thresholds at 90, 95, and 99 %
double   acctime		# i: accepted time (sum of gtis)
double   tstart, tstop		# i: observation start and stop times

pointer  line			# l: output line buffer
pointer  sp			# l: alloc pointer
pointer  sregion		# l: source region
pointer  iginame                # l: temp name of output file
pointer  igitemp
pointer  tbhead                 # l: input table header structure pointer

int      fd			# l: ascii file handle
int      day			# l: for conversion to mjd

double   mjd			# l: modified julian days
double   secs			# l: for mjd conversion
double   valsecs		# l: valid seconds

int      open()

begin

        call smark (sp)
        call salloc (line,     SZ_LINE, TY_CHAR)
        call salloc (sregion,  SZ_LINE, TY_CHAR)
        call salloc (iginame,  SZ_PATHNAME, TY_CHAR)
        call salloc (igitemp,  SZ_PATHNAME, TY_CHAR)

        # open the ascii output file
        call strcpy("",Memc[iginame],SZ_PATHNAME)
        call rootname (plt_file, Memc[iginame], "_ig1.cmd", SZ_PATHNAME)
        call clobbername(Memc[iginame],Memc[igitemp],clob,SZ_PATHNAME)
        fd = open (Memc[igitemp], NEW_FILE, TEXT_FILE)

        #  Write to the ascii igi command file
#        call sprintf(Memc[line], SZ_LINE, "data %s\n")
#           call pargstr (plt_file)
#        call lineout (fd, Memc[line])
        call lineout (fd, "erase; justify 8\n")

        # -- label plot with title and header info
        call lineout (fd, "prelocate 0.5 1.0; expand 1.25\n")

        call sprintf(Memc[line], SZ_LINE, "label ks-test : %s\n")
           call pargstr (plt_file)
        call lineout (fd, Memc[line])

        call lineout(fd, "justify 6; expand 1.0\n")
        call lineout(fd, "prelocate 0.005 0.96\n")

        call get_tbhead (tp, tbhead)
        call calc_tbmjdtime (tbhead, tstart, mjd)
        call mfree (tbhead, TY_STRUCT)

        day = int ( mjd )
        secs = (mjd - float ( day )) * 3600 * 24
        call sprintf (Memc[line], SZ_LINE, "label MJD Start:  %6d %9.3fs\n")
             call pargi (day)
             call pargd (secs)
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.005 0.92\n")
        call sprintf(Memc[line], SZ_LINE, "label Clock Start: %.3fs \n")
           call pargd (tstart)
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.005 0.88\n")

        valsecs = tstop - tstart
        call sprintf(Memc[line], SZ_LINE, "label Valid-time span: %.3fs\n")
           call pargd(valsecs)
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.005 0.84\n")
        call sprintf(Memc[line], SZ_LINE, "label Tot Cnts: %d\n")
           call pargi (nphots)
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.5 0.96\n")
        iferr ( call tbhgtt (tp, "S_A", Memc(sregion), SZ_LINE) ) {
           call sprintf (Memc[line], SZ_LINE, "label Src Region:  NONE")
        } else {
           call cr_to_blk(Memc(sregion))
           call sprintf (Memc[line], SZ_LINE, "label Src Region:  %s\n")
             call pargstr (Memc[sregion])
        }
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.5 0.92\n")
        call sprintf(Memc[line], SZ_LINE, "label Tot Valid Secs: %.3f\n")
           call pargd(acctime)
        call lineout(fd, Memc[line])

        # --  Plot upper 'Integral Curve' data, overlay model and cdf
        call lineout(fd, "expand 1; justify 8\n")
        call lineout(fd, "xcolumn time; ycolumn cdf\n")
        call lineout(fd, "vpage 0.1 1.0 0.40 0.75\n")

        call sprintf(Memc[line], SZ_LINE, 
		     "limits 0.0 %.3f 0.0 1.0; box; step\n")
           call pargd(acctime)
        call lineout(fd, Memc[line]) 

        call sprintf(Memc[line], SZ_LINE, 
	             "ltype dash; move 0.0 0.0; draw %.3f 1.0 \n")
           call pargd(acctime)
        call lineout(fd, Memc[line]) 

        call lineout(fd, "justify 8; angle 90\n")
        call lineout(fd, "prelocate 0.0 0.58; label Integral Curve\n")

        # -- Plot lower 'Max Dist' data
        call lineout(fd, "xcolumn time; ycolumn dist\n")
        call lineout(fd, "vpage 0.1 1.0 0.25 0.40\n")

        call sprintf(Memc[line], SZ_LINE, 
		     "limits 0.0 %.3f 0.0 %.3f; box; step\n")
           call pargd(acctime)
           call pargr(d)
        call lineout(fd, Memc[line]) 
        call lineout(fd, "ltype solid; box; step\n")

        call lineout(fd, "justify 8; angle 90; prelocate 0.0 0.27; label Max Dist\n")
        call lineout(fd, "angle 0; expand 1\n")
        call lineout(fd, "prelocate 0.5 0.10; label Observation Time [s]\n")

        # -- Label plot with ks-test results at bottom 
        call lineout(fd, "angle 0; justify 6; expand 1.0\n")
        call lineout(fd, "prelocate 0.1 0.05\n")
        call sprintf(Memc[line], SZ_LINE,
           "label Ks-test Thresh. : 90%% = %.3f, 95%% = %.3f, 99%% =%.3f\n")
           call pargr(t90)
           call pargr(t95)
           call pargr(t99)
        call lineout(fd, Memc[line])

        call lineout(fd, "prelocate 0.1 0.02\n")
        call sprintf(Memc[line], SZ_LINE, "label Max diff = %.5f\n")
           call pargr(d)
        call lineout(fd, Memc[line])

        call finalname (Memc[igitemp], Memc[iginame])
        if ( display >= 1 ) {
           call printf ("Creating igi Ksplot cmd file: %s\n")
              call pargstr (Memc[iginame])
        }
        # close file and free space
        call close(fd)
        call sfree(sp)
end

# ---------------------------------------------------------------------
#
# Function:       wr_ovrlycmds.X
# Purpose:        Write ksplot commands to an ascii command file.         
#		  These commands are input to stsdas igi task to plot
#                 and will overlay the cdf band onto the Integral plot
# ----------------------------------------------------------------------------
procedure wr_ovrlycmds (plt_file, acctime, display, clob)

char     plt_file[ARB]		# i: output table file
double   acctime                # i: tot valid secs for for setting plot bnds
bool     clob			# i: clobber existing file if it exists?
int      display		# i: display level

pointer  iginame		# l: output filename
pointer  igitemp                # l: temp output file
pointer  line			# l: write line buffer
pointer  sp			# l: allocation pointer
int      fd			# l: ascii file output handle

int      open()

begin

        call smark (sp)
        call salloc (line,     SZ_LINE, TY_CHAR)
        call salloc (iginame,  SZ_PATHNAME, TY_CHAR)
        call salloc (igitemp,  SZ_PATHNAME, TY_CHAR)

        # open the igi overlay command file
        call strcpy("",Memc[iginame],SZ_PATHNAME)
        call rootname (plt_file, Memc[iginame], "_ig2.cmd", SZ_PATHNAME)
        call clobbername(Memc[iginame],Memc[igitemp],clob,SZ_PATHNAME)
        fd = open (Memc[igitemp], NEW_FILE, TEXT_FILE)

        # write the plot commands to the ascii file
#        call sprintf(Memc[line], SZ_LINE, "data %s\n")
#           call pargstr (plt_file)
#        call lineout (fd, Memc[line])

        call lineout (fd, "xcolumn time; ycolumn cdf\n")

        call sprintf(Memc[line], SZ_LINE, 
		     "limits 0.0 %.3f 0.0 1.0\n")
           call pargd(acctime)
        call lineout(fd, Memc[line]) 

        call lineout (fd, "xcolumn time; ycolumn cdfminus\n")
        call lineout (fd, "vpage 0.1 1.0 0.40 0.75\n")
        call lineout (fd, "ltype dotdash; step\n")
        call lineout (fd, "xcolumn time; ycolumn cdfplus\n")
        call lineout (fd, "step\n")

        call finalname (Memc[igitemp], Memc[iginame])
        if ( display >= 1 ) {
           call printf ("Creating igi Conf band cmd file: %s\n")
              call pargstr (Memc[iginame])
        }

        call close(fd)
        call sfree(sp)

end

# ---------------------------------------------------------------------
#
# Function:       linout
# Purpose:  	  Write a line to the ascii output file and check the
#                 return status for an error      
# --------------------------------------------------------------------------
procedure lineout (fd, line)

int  	fd			# i: ascii file handle
char	line[ARB]		# i: line to write

int      stat			# l: write status
int      putline()

begin

        stat = putline (fd, line)
	if ( stat == 1 ) {
	   call error (EA_ERROR, "Can't write line to ascii output file\n")
        }

end

