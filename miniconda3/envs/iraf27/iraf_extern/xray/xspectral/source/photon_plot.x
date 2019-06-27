#$Header: /home/pros/xray/xspectral/source/RCS/photon_plot.x,v 11.0 1997/11/06 16:43:05 prosb Exp $
#$Log: photon_plot.x,v $
#Revision 11.0  1997/11/06 16:43:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:17  prosb
#General Release 2.3
#
#Revision 6.2  93/11/02  02:23:42  dennis
#Replaced 2 sprintf() calls that would cause an error termination if given 
#long model strings.  strcat() truncates, protecting against the abort.
#
#Revision 6.1  93/07/02  14:43:58  mo
#MC	7/2/93		Correct boolean test for syntax
#
#Revision 6.0  93/05/24  16:52:07  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:52  prosb
#General Release 2.1
#
#Revision 4.1  92/10/01  11:55:34  prosb
#jso - changed the name so that it was compatible with predicated=append.
#
#Revision 4.0  92/04/27  18:17:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/07  16:08:33  prosb
#jso - added min and max parameters for both HRI's.
#
#Revision 3.2  92/04/06  15:09:59  jmoran
#JMORAN no changes
#
#Revision 3.1  91/09/22  19:06:50  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:55  prosb
#General Release 1.1
#
#Revision 2.4  91/07/24  18:43:19  prosb
#jso - comment out lines that put absoprtion on graphic because of
#      where it is put and that it is put there when there is no absorption.
#      This should be done correctly latter.
#
#Revision 2.3  91/07/19  16:02:00  prosb
#dmm: fixed X axis stuff (will be obsolete when iraf fixes LOG clipping
#bug).  to get rid of these changes, check out previous version.
#
#Revision 2.2  91/07/12  16:32:56  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/20  13:03:45  dmm
#made numerous bug fixes including fixing extra line that went across screen,
#fixed up looks of output, and fixed xmin,ymin setting problems.
#
#Revision 2.0  91/03/06  23:06:32  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  PHOTON_PLOT.X   ---  plots the observed with errors & predicted curve

include  <gset.h>
include  <pkg/gtools.h>
include  <spectral.h>
include  "photon_plot.h"
include  <mach.h>


#  --------------------------------------------------------------------------
#
procedure  photon_plot (fp, gp, pl)

pointer	fp					# parameter structure
pointer	ds					# dataset structure
pointer	gp					# graphics structure
pointer	pl					# plot structure
#--

pointer	observed				# observed spectrum
pointer energies				# bin energy bounds
pointer filename				#
pointer title					#
pointer xtitle					#
pointer ytitle					#
pointer	root					# root of file name
pointer	chanstr					# string of channels
pointer	abs

real	xcoord, ycoord

int	nbins					# bins in spectrum
int	in_log_mode				# are we in log mode?
bool	streq()					# string compare

pointer	sp					# stack pointer

include "photon_plot.com"

begin
	call smark (sp)
	call salloc(title,    SZ_LINE,  TY_CHAR)
	call salloc(xtitle,   SZ_LINE,  TY_CHAR)
	call salloc(ytitle,   SZ_LINE,  TY_CHAR)
	call salloc(root, SZ_PATHNAME, TY_CHAR)
	call salloc(chanstr, SZ_PATHNAME, TY_CHAR)
#	call salloc(filename, SZ_PATHNAME, TY_CHAR)
	call salloc(abs, SZ_LINE, TY_CHAR)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	filename = DS_FILENAME(ds)
	nbins    = DS_NPHAS(ds)
	observed = DS_OBS_DATA(ds)
	call salloc (energies, (nbins+1), TY_REAL)
	call pha_energy (ds, Memr[energies], (nbins+1))

	# get title information
	call strcpy(Memc[PL_TITLE[pl]], Memc[title], SZ_LINE)
	call strcpy(Memc[PL_XTITLE[pl]], Memc[xtitle], SZ_LINE)
	call strcpy(Memc[PL_YTITLE[pl]], Memc[ytitle], SZ_LINE)

	# see if we use defaults
	if(streq("", Memc[xtitle]))
	    call strcpy("keV", Memc[xtitle], SZ_LINE)
	if(streq("", Memc[ytitle])){
	    switch(c_mode){
	    case C_OBS:
		call strcpy("counts", Memc[ytitle], SZ_LINE)
	    case C_DIFF:
		call strcpy("difference", Memc[ytitle], SZ_LINE)
	    case C_SIGMA:
		call strcpy("sigma", Memc[ytitle], SZ_LINE)
	    }
	}
	if(streq("", Memc[title])){
	    switch(c_mode){
	    case C_OBS:
		call strcpy("Photon Counts", Memc[title], SZ_LINE)
	    case C_DIFF:
		call strcpy("Obs-Pred",
				Memc[title], SZ_LINE)
	    case C_SIGMA:
		call strcpy("(Obs-Pred)/Err",
				Memc[title], SZ_LINE)
	    }
	}
	    
#	# calculate the plot limits
#	call pl_lims(fp, pl)

	# clear screen and set window size, axis type, etc.
	call gclear (gp)

	# put up filename and time along bottom
	if( c_label == YES ){
	    # strip off directory path name

	    call gsetr(gp, G_TXSIZE, 0.8)
#	    call ds_gmodstr(ds, "ifile", Memc[filename], SZ_LINE)
	    # get root of obs file name
	    call fnroot(Memc[filename], Memc[root], SZ_PATHNAME)
	    # get channels
	    call ds_channels(Memi[DS_CHANNEL_FIT(ds)], DS_NPHAS(ds),
			     Memc[chanstr], SZ_PATHNAME)
	    # copy them to the obs file string
	    call strcat(Memc[chanstr], Memc[root], SZ_PATHNAME)
	    call gfile_label (gp, Memc[root])
#	    call gtime_label (gp)
	    call gsetr(gp, G_TXSIZE, 1.0)
	}

	call gseti (gp, G_XTRAN, PL_XTRAN[pl])
	call gseti (gp, G_YTRAN, PL_YTRAN[pl])
	call gswind (gp, PL_XMIN[pl], PL_XMAX[pl], PL_YMIN[pl], PL_YMAX[pl])

	# put up labels, if necessary
	if( c_label == YES ) {
            call gsview(gp, .15, .85, .23, .94)

	    # Upper right corner.
	    #
	    if (PL_XTRAN[pl] == GW_LOG)
		if (PL_XMIN[pl] <= 0.0)
			PL_XMIN[pl] = 0.1

	    if (c_mode == C_OBS) {
	    	if (PL_YMIN[pl] <= 0.0)
			PL_YMIN[pl] = 0.1

	    } else
	    	if (PL_YTRAN[pl] == GW_LOG)
			if (PL_YMIN[pl] <= 0.0)
				PL_YMIN[pl] = 0.1


	    if ( PL_XTRAN[pl] != GW_LOG ) {
	        xcoord = PL_XMIN[pl] + ( 0.1 * ( PL_XMAX[pl] - PL_XMIN[pl] ))
	    } else {
	        xcoord = 10**(alog10(PL_XMIN[pl]) + 
		     ( 0.1 * ( alog10(PL_XMAX[pl]) - alog10(PL_XMIN[pl] ))))
	    }

	    if ( PL_YTRAN[pl] != GW_LOG ) {
		in_log_mode = 0;
	        ycoord = PL_YMIN[pl] + ( 0.9 * ( PL_YMAX[pl] - PL_YMIN[pl] ))
	    } else {
		in_log_mode = 1;
	        ycoord = 10**(alog10(PL_YMIN[pl]) + 
		     ( 0.9 * ( alog10(PL_YMAX[pl]) - alog10(PL_YMIN[pl] ))))
	    }
#
#	commented out until written outside of data
#
#	    call ds_gmodstr(ds, "abs", Memc[abs], SZ_LINE)
#	      switch ( Memc(abs) )
#	       if ( streq("morrison_maccammon", Memc[abs]) )
#	    	   call gtext(gp, xcoord, ycoord,
#			 "Morrison-McCammon absorption", "")
#	       else if ( streq("brown_gould", Memc[abs]) )
#		    	   call gtext(gp, xcoord, ycoord,
#			 "Brown & Gould absorption", "")
#	       else
#	           call gtext(gp, xcoord, ycoord,
#		         "unknown absorption", "")
	    call glabax (gp, Memc[title], Memc[xtitle], Memc[ytitle])
	} else {
	    call gsview(gp, .15, .85, .15, .94)
	    call glabax (gp, "", Memc[xtitle], Memc[ytitle])
	}

	# put up the plot
	switch(c_mode){
	case C_OBS:
	    call photon_obs(fp, gp)
	    if( PL_ERRORS[pl] == YES )
		call photon_err (fp, gp, in_log_mode)
	    if( PL_PREDICTED[pl] == YES )
		call photon_pred (fp, gp)
	case C_DIFF:
	    call photon_diff(fp, gp, pl, in_log_mode)
	case C_SIGMA:
	    call photon_sigma(fp, gp, pl, in_log_mode)
	default:
	    call error(1, "unknown plotting mode")
	}
	call sfree (sp)
end

#
#  PHOTON_OBS -- plot observed data
#
procedure  photon_obs (fp, gp)

pointer	fp					# parameter structure
pointer	ds					# dataset structure

pointer	gp					#
pointer	sp					# stack pointer
pointer observed				# observed spectrum
pointer energies				# spectrum bin bounds
pointer	channels				# channels used in fit
int	nbins					#
int	i					# spectrum index
int	mark					# data mark type
real	xcoord, ycoord				# coords of data point

include "photon_plot.com"

begin
	call smark (sp)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins    = DS_NPHAS(ds)
	observed = DS_OBS_DATA(ds)
	channels = DS_CHANNEL_FIT(ds)
	call salloc (energies, (nbins+1), TY_REAL)
	call pha_energy (ds, Memr[energies], (nbins+1))

	# mark the pha channels that were fit with asterisk
	# others with a plus
	do i = 1, nbins  {
	    xcoord = 0.5*(Memr[energies+i-1]+Memr[energies+i])
	    ycoord = Memr[observed+i-1]
	    if( Memi[channels+i-1] !=0 )
		mark = GM_BOX+GM_HLINE
	    else
		mark = GM_HLINE
	    call gmark(gp, xcoord, ycoord, mark, MARK_SIZE, MARK_SIZE)
	}

	call sfree (sp)
end

# 
#  ---------------------------------------------------------------------------
#
procedure  photon_pred (fp, gp)

pointer	fp					# parameter structure
pointer	ds					# dataset structure
pointer	gp					#
pointer	sp					# stack pointer
pointer predicted				# predicted spectrum
pointer energies				# spectrum bin bounds
int	nbins					#
int	i					# spectrum index

include "photon_plot.com"

begin
	call smark (sp)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins    = DS_NPHAS(ds)
	predicted= DS_PRED_DATA(ds)
	call salloc (energies, (nbins+1), TY_REAL)
	call pha_energy (ds, Memr[energies], (nbins+1))

	if( nbins >= 1 )  {
		# reset to dashed line
		call gseti(gp, G_PLTYPE, 2)
		if (Memr[energies] < 0.0)
			call gamove (gp, 0.00000001, 0.00000001)
		else
			call gamove (gp, Memr[energies], 0.00000001)
		# mark the predicted data
		do i = 1, nbins  {
			# draw the vertical line
			if ((Memr[energies+i-1] > 0.0) &&
			    (Memr[predicted+i-1] > 0.0))
				call gadraw (gp,
				     Memr[energies+i-1], Memr[predicted+i-1])
			# draw the horiz. line
			if ((Memr[energies+i] > 0.0) &&
			    (Memr[predicted+i-1] > 0.0))
				call gadraw (gp,
				     Memr[energies+i], Memr[predicted+i-1])
		}
		call gadraw (gp, Memr[energies+nbins], 0.00000001)
	}

	# plot some labels assoc. with predicted data
	call plot_models(fp, gp)

	call sfree (sp)
end

# 
#  ---------------------------------------------------------------------------
#
procedure  photon_err (fp, gp, in_log_mode)

pointer	fp					# parameter structure
pointer	ds					# dataset structure
pointer	gp					#
pointer	sp
pointer observed				# observed spectrum
pointer errors					#
pointer energies				# spectrum bin bounds
int	nbins					#
int	i					# spectrum index
#int	markit					# do we put bars?
bool	markit					# do we put bars?
int	in_log_mode				# are we in log mode?
real	xcoord,  ycoord, ycoord1, ycoord2		# coordinates

include "photon_plot.com"

begin
	call smark (sp)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins    = DS_NPHAS(ds)
	observed = DS_OBS_DATA(ds)
	errors   = DS_OBS_ERROR(ds)
	call salloc (energies, (nbins+1), TY_REAL)
	call pha_energy (ds, Memr[energies], (nbins+1))

	if( nbins > 1 ){
	    do i = 1, nbins  {
		xcoord = 0.5*(Memr[energies+i-1]+Memr[energies+i])
		ycoord1 = Memr[observed+i-1] - Memr[errors+i-1]
		ycoord2 = Memr[observed+i-1] + Memr[errors+i-1]
		if (xcoord <= 0.0)
			xcoord = 0.01
		if (ycoord1 <= 0.0)
			ycoord1 = 0.01
		if (ycoord2 <= 0.0)
			ycoord2 = 0.01

		# in log mode the bigger the number the smaller it appears
		if (in_log_mode == 1)
			markit = ((ycoord2 - ycoord1) < 22)
		else
			markit = ((ycoord2 - ycoord1) > 25)

		ycoord = ycoord2 - ycoord1

#		if (markit == 1)
		if (markit)
		  call gmark (gp, xcoord, ycoord1, GM_HLINE, MARK_SIZE, MARK_SIZE)
		if (xcoord > 0.0) {
			call gamove (gp, xcoord, ycoord1)
			call gadraw (gp, xcoord, ycoord2)
		}
#		if (markit == 1)
		if (markit)
		  call gmark (gp, xcoord, ycoord2, GM_HLINE, MARK_SIZE, MARK_SIZE)
	    }
	}

	call sfree (sp)
end

# 
#  -------------------------------------------------------------------
#
procedure  plot_models ( fp, gp )

pointer	fp					# parameter structure
pointer	gp					#

pointer	sp					# stack pointer
pointer	textline				# output text
pointer	ds					# dataset structure
pointer predicted				# predicted spectrum
pointer energies				# spectrum bin bounds
pointer	channels				# channels to fit
pointer	omodel					# output model
int	nbins					#
real	xcoord,  ycoord				# coordinates
real	chisq

real	ds_getmr()

include "photon_plot.com"

begin
	# just return if we are not labelling
	if( c_label == NO )
	    return

	call smark(sp)
	call salloc(textline, SZ_LINE, TY_CHAR)
	call salloc(omodel, SZ_LINE, TY_CHAR)

	call gsetr(gp, G_TXSIZE, 0.8)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins    = DS_NPHAS(ds)
	predicted= DS_PRED_DATA(ds)
	channels = DS_CHANNEL_FIT(ds)
	call salloc(energies, (nbins+1), TY_REAL)
	call pha_energy(ds, Memr[energies], nbins + 1)

	chisq = ds_getmr(ds, "chisq")
        call sprintf(Memc[textline], SZ_LINE, "min Chi-Squared =%6.2f")
	 call pargr(chisq)
        call gctran (gp, 0.01, 0.09, xcoord, ycoord, 0, 1)
	call gtext(gp, xcoord, ycoord, Memc[textline], "")

	call ds_gmodstr(ds, "best", Memc[omodel], SZ_LINE)
	call strcpy("for ", Memc[textline], SZ_LINE)
	call strcat(Memc[omodel], Memc[textline], SZ_LINE)
	call gctran(gp, 0.35, 0.09, xcoord, ycoord, 0, 1)
	call gtext(gp, xcoord, ycoord, Memc[textline], "")

	call ds_gmodstr(ds, "imod", Memc[omodel], SZ_LINE)
	call strcpy("using ", Memc[textline], SZ_LINE)
	call strcat(Memc[omodel], Memc[textline], SZ_LINE)
	call gctran(gp, 0.01, 0.046, xcoord, ycoord, 0, 1)
	call gtext(gp, xcoord, ycoord, Memc[textline], "")

	call gsetr(gp, G_TXSIZE, 1.0)

	call sfree(sp)
end

#
#  PHOTON_DIFF -- plot difference between observed and predicted
#
procedure  photon_diff (fp, gp, pl, in_log_mode)

pointer	fp					# parameter structure
pointer	gp					#
pointer	pl					# plot params

pointer	ds					# dataset structure
pointer	sp					# stack pointer
pointer predicted				# predicted spectrum
pointer	observed				# observed spectrum
pointer	errors					# errors on obs data
pointer	diff					# diff between obs and pred
pointer energies				# spectrum bin bounds
pointer	channels				# channels used in fit
int	nbins					#
int	i					# spectrum index
int	mark					# type of mark
#int	markit					# do we mark?
bool	markit					# do we mark?
int	dosigma					# sigma plot?
int	in_log_mode				# are we in log mode?
real	xcoord, ycoord, ycoord1, ycoord2	# x, y coords for marking

include "photon_plot.com"

begin
	dosigma = NO
	goto 99
					# If this ain't just a pisser.
entry photon_sigma (fp, gp, pl, in_log_mode)
	dosigma = YES
	goto 99

99	call smark (sp)

	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins    = DS_NPHAS(ds)
	predicted= DS_PRED_DATA(ds)
	observed = DS_OBS_DATA(ds)
	errors = DS_OBS_ERROR(ds)
	channels = DS_CHANNEL_FIT(ds)
	call salloc(diff, nbins, TY_REAL)
	call salloc (energies, (nbins+1), TY_REAL)
	call pha_energy (ds, Memr[energies], (nbins+1))
	
	if( nbins > 1 )  {
		# calculate the difference between observed and predicted
		do i = 1, nbins{
		    Memr[diff+i-1] = Memr[observed+i-1] - Memr[predicted+i-1]
		    if( dosigma == YES ){
			if( Memr[errors+i-1] > EPSILON )
			    Memr[diff+i-1] = Memr[diff+i-1]/Memr[errors+i-1]
			else{
			    call printf(
				"warning: error == 0, sigma plot will wrong\n")
			    call flush(STDOUT)
			}
		    }
		}

		# plot the difference
		call gseti(gp, G_PLTYPE, 1)
		if (Memr[energies] < 0.0)
			call gamove (gp, 0.00000001, 0.00000001)
		else
			call gamove (gp, Memr[energies], 0.00000001)
		do i = 1, nbins  {
		    xcoord = 0.5*(Memr[energies+i-1]+Memr[energies+i])
		    ycoord = Memr[diff+i-1]
		    if( Memi[channels+i-1] !=0 )
			mark = GM_BOX+GM_HLINE
		    else
			mark = GM_HLINE
		    call gmark(gp, xcoord, ycoord, mark, MARK_SIZE, MARK_SIZE)
		}

		# draw the error bars for diff plot
		if( dosigma == NO ){
		    do i = 1, nbins  {
			xcoord = 0.5*(Memr[energies+i-1]+Memr[energies+i])
			ycoord1 = Memr[diff+i-1] - Memr[errors+i-1]
			ycoord2 = Memr[diff+i-1] + Memr[errors+i-1]
		# in log mode the bigger the number the smaller it appears
		if (in_log_mode == 1) {
			if (xcoord <= 0.0)
				xcoord = 0.01
			if (ycoord1 <= 0.0)
				ycoord1 = 0.01
			if (ycoord2 <= 0.0)
				ycoord2 = 0.01

			markit = ((ycoord2 - ycoord1) < 22)
		} else
			markit = ((ycoord2 - ycoord1) > 25)

#		if (markit == 1)
		if (markit)
		 call gmark (gp, xcoord, ycoord1, GM_HLINE, MARK_SIZE, MARK_SIZE)
		if ((ycoord1 < 0.0) && (ycoord2 > 0.0)) {
			call gamove (gp, xcoord, ycoord1)
			call gadraw (gp, xcoord, -0.00000000001)
			call gamove (gp, xcoord, 0.00000000001)
			call gadraw (gp, xcoord, ycoord2)
		} else {
			call gamove (gp, xcoord, ycoord1)
			call gadraw (gp, xcoord, ycoord2)
		}
#		if (markit == 1)
		if (markit )
		 call gmark (gp, xcoord, ycoord2, GM_HLINE, MARK_SIZE, MARK_SIZE)
		    }
	        }
	}

	# plot some labels assoc. with predicted data
	call plot_models(fp, gp)

	call sfree (sp)
end
