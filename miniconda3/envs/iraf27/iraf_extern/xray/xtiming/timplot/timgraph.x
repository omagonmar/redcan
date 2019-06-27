#$Header: /home/pros/xray/xtiming/timplot/RCS/timgraph.x,v 11.0 1997/11/06 16:44:50 prosb Exp $
#$Log: timgraph.x,v $
#Revision 11.0  1997/11/06 16:44:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:02  prosb
#General Release 2.3
#
#Revision 6.2  93/10/21  11:32:02  mo
#MC		10/5/93		Update code to get header parameters vai
#				get_tbhead rather than directly from
#				named keywords
#
#Revision 6.1  93/07/02  15:01:17  mo
#MC	7/2/93		Correct int->double conversion from double to dfloat
#
#Revision 6.0  93/05/24  16:58:07  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  10:30:09  janet
#jd - made updates to plot headers, new labels and format.
#
#Revision 5.1  93/01/04  12:07:17  janet
#added 2nd x-axis label format.  Used when x-axis label < 0.999999.
#
#Revision 5.0  92/10/29  22:49:39  prosb
#General Release 2.1
#
#Revision 4.1  92/09/28  17:03:02  janet
#Add pdot to hdr, add precision to phase axis labels
#
#Revision 4.0  92/06/26  14:22:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/06/17  11:22:27  janet
#updated header formats to include > precision, added cycles for fold plot
#
#Revision 3.0  91/08/02  02:02:41  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  14:39:53  janet
#got rid of vars not being used any more
#
#
#Revision 2.1  91/07/21  14:26:53  janet
#updated graph header.
#
#Revision 2.0  91/03/06  22:51:38  prosb
#General Release 1.0
#
# ------------------------------------------------------------------------
#
# Module:	TIMGRAPH.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	< opt, brief description of whole family, if many routines>
# External:	tim_labels(), tim_mkplt()
# Local:	tim_histo(), tim_ebar(), tim_drlabels(), 
#		tim_pltbox(), tim_xtics(), tim_ytics()
# Description:	group of plotting routines for timing plots
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version July 1989
#		{1} JD -- Jul 1991 -- Updated graph header
#		{2} JD -- Oct 1991 -- Updated graph header w/ totcnts & period
#		{3} JD -- Nov 1991 -- Updated period format from .3 to .6
#		{4} JD -- Dec 1991 -- Added cycles for fold plots
#		{5} JD -- Jul 1992 -- Add pdot to hdr, add precision to phase
#				      axis labels
#               {6} JD -- Dec 1992 -- Updated x-axis handling to double prec.
#
# ------------------------------------------------------------------------

include  <gset.h>
include  <tbset.h>
include  <mach.h>
include  <qpoe.h>
include  "timplot.h"

# ------------------------------------------------------------------------
#
# Function:	tim_labels
# Purpose:	Label plot with heading and x & y axis labels
# Pre-cond:	Graphics device open and constants structure initalized
# Post-cond:	Graphics text size set 
#
# ------------------------------------------------------------------------
procedure tim_labels (gp, tp, file, xaxis, yaxis, const)

pointer gp                      # i: graphics device handle
pointer tp                      # i: input table handle
char    file[ARB]               # i: header file label
char    xaxis[ARB]              # i: x-axis label
char    yaxis[ARB]              # i: y-axis label
pointer const                   # i: constant struct pointer

pointer buf                     # l: tempory buffer
pointer sregion                 # l: src region buffer
pointer bregion                 # l: bkgd region buffer
pointer sp                      # l: space allocation pointer
pointer titstr                  # l: title string
pointer	tbhead			# l: input table header structure pointer
int     numbins                 # l: number of data bins
int     totcnts                 # l: total number of counts
real    time                    # l: fft: total valid secs
#double  dpsecs                  # l: spacecraft seconds from hdr
double  begsecs                 # l: beg spacecraft seconds from hdr
double  binlen                  # l: length of each bin in secs
double  endsecs                 # l: end spacecraft seconds from hdr
double  dursecs                 # l: duration spacecraft seconds
double  intv			# l: fft: fourier interval
double  mjd                     # l: modified julian day
double  period                  # l: fld: period in seconds
double  pdot			# l: fld: period rate of change
int     day			# l: julian day
int     cycles 			# l: cycles of data for fold
int     fld_hdr                 # l: indicates if table hdr is from fold task
double  secs

int     tbhgti()
real    tbhgtr()
double  tbhgtd()

begin

        call smark(sp)
        call salloc (buf, SZ_LINE, TY_CHAR)
        call salloc (titstr, SZ_LINE, TY_CHAR)
        call salloc (sregion, SZ_LINE, TY_CHAR)
        call salloc (bregion, SZ_LINE, TY_CHAR)

#   Set the header viewspace and Label the plot with a title
        call gsview (gp, XLL(const), XUL(const),
                         YUL(const), YUL(const)+HLABEL(const))
        call gsetr (gp, G_TXSIZE, LABSIZE(const))

        iferr ( begsecs = tbhgtd (tp, "BEG_TIME") ) {
        } else {
#   Col1 - MJD beg time
	   call get_tbhead(tp,tbhead)
           call calc_tbmjdtime (tbhead, begsecs, mjd)
	   call mfree(tbhead,TY_STRUCT)
           day = int ( mjd )
           secs = (mjd - float ( day )) * 3600 * 24
           call sprintf (Memc[buf], SZ_LINE, "MJD Start:  %6d %9.3fs")
             call pargi (day)
             call pargd (secs)
           call gtext (gp, .1, .7, Memc[buf], "h=l; v=c; q=h")

#   Col1 - Clock beg time
           call sprintf (Memc[buf], SZ_LINE, "Clock Start: %15.3fs")
             call pargd (begsecs)
           call gtext (gp, .1, .55, Memc[buf], "h=l; v=c; q=h")

#   Col1 - Duration (Valid-time span)
           iferr ( endsecs = tbhgtd (tp, "END_TIME") ) {
           } else {
              dursecs = endsecs - begsecs
              call sprintf (Memc[buf], SZ_LINE, "Valid-time span: %9.3fs")
                 call pargd (dursecs)
              call gtext (gp, .1, .4, Memc[buf], "h=l; v=c; q=h")
           }
        }

#  *** check if FOLD keyword -> cycles <- is in header
        iferr ( cycles = tbhgti (tp, "CYCLES") ) {
             fld_hdr = NO
        } else {
             fld_hdr = YES
        }

#    Col 1 - Tot Cnts
        iferr ( totcnts = tbhgti (tp, "TOTCNTS") ) {
        } else {
           if ( fld_hdr == YES ) {
              call sprintf (Memc[buf], SZ_LINE, "Cnts per Cycle: %d")
                call pargi (totcnts)
              call gtext (gp, .1, .25, Memc[buf], "h=l; v=c; q=h")
           } else {
              call sprintf (Memc[buf], SZ_LINE, "Tot Cnts: %d")
                call pargi (totcnts)
              call gtext (gp, .1, .25, Memc[buf], "h=l; v=c; q=h")
	   }
        }
#    Col 1 - x range warning
        if ( XAUTO(const) == NO ) {
           call gsetr (gp, G_TXSIZE, LABSIZE(const)*0.75)
           call sprintf (Memc[buf], SZ_LINE, 
             "* X-axis Range Limits Used - Not reflective in Header Info")
           call gtext (gp, .1, .1, Memc[buf], "h=l; v=c; q=h")
        }
#       iferr ( dpsecs = tbhgtd (tp, "END_TIME") ) {
#       } else {
#           call calc_tbmjdtime (tp, dpsecs, mjd)
#           day = int ( mjd )
#          secs = (mjd - float ( day )) * 3600 * 24
#          call sprintf (Memc[buf], SZ_LINE, "Start (Secs):  %6d %9.3fs")
#            call pargi (day)
#            call pargd (secs)
#          call gtext (gp, .1, .4, Memc[buf], "h=l; v=c; q=h")
#       }
     call gsetr (gp, G_TXSIZE, LABSIZE(const))
#    Col 2 - Src region
        iferr ( call tbhgtt (tp, "S_A", Memc(sregion), SZ_LINE) ) {
           call sprintf (Memc[buf], SZ_LINE, "Src Region:  NONE")
           call gtext (gp, .4, .7, Memc[buf], "h=l; v=c; q=h")
        } else {
           call cr_to_blk(Memc(sregion))
           call sprintf (Memc[buf], SZ_LINE, "Src Region:  %s")
             call pargstr (Memc[sregion])
           call gtext (gp, .4, .7, Memc[buf], "h=l; v=c; q=h")
        }
#    Col 2 - Bkgd region
        iferr ( call tbhgtt (tp, "B_A", Memc(bregion), SZ_LINE) ) {
           call sprintf (Memc[buf], SZ_LINE, "Bkg Region:  NONE")
           call gtext (gp, .4, .55, Memc[buf], "h=l; v=c; q=h")
        } else {
           call cr_to_blk(Memc(bregion))
           call sprintf (Memc[buf], SZ_LINE, "Bkg Region:  %s")
             call pargstr (Memc[bregion])
           call gtext (gp, .4, .55, Memc[buf], "h=l; v=c; q=h")
        }
#    Col 2 - Number of Bins
        iferr ( numbins = tbhgti (tp, "NUMBINS") ) {
        } else {
           if ( fld_hdr == YES ) {
              call sprintf (Memc[buf], SZ_LINE, "Bins per Cycle: %d")
                call pargi (numbins)
              call gtext (gp, .4, .4, Memc[buf], "h=l; v=c; q=h")
           } else {
              call sprintf (Memc[buf], SZ_LINE, "Num of Bins: %d")
                call pargi (numbins)
              call gtext (gp, .4, .4, Memc[buf], "h=l; v=c; q=h")
           }
        }
#    Col 2 - Bin Length
        iferr ( binlen = tbhgtd (tp, "BINLEN") ) {
            iferr ( binlen = tbhgtd (tp, "PERINCR") ) {
	    } else {
                if ( binlen > EPSILOND ) {
                   call sprintf (Memc[buf], SZ_LINE, "Bin Length: %.10es")
                     call pargd (binlen)
                   call gtext (gp, .4, .25, Memc[buf], "h=l; v=c; q=h")
		}
            }
        } else {
           call sprintf (Memc[buf], SZ_LINE, "Bin Length: %.10es")
             call pargd (binlen)
           call gtext (gp, .4, .25, Memc[buf], "h=l; v=c; q=h")
        }
#    Col 3 - Cycles
#       if ( fld_hdr == YES ) {
#          call sprintf (Memc[buf], SZ_LINE, "Num of Cycles: %d")
#            call pargi (cycles)
#          call gtext (gp, .7, .4, Memc[buf], "h=l; v=c; q=h")
#       }

# Col 3 has extra info particular to specific plots.  

#    Col 3 - Period (for fldplot)
        iferr ( period = tbhgtd (tp, "PERIOD") ) {
        } else {
           call sprintf (Memc[buf], SZ_LINE, "Period : %.11e")
             call pargd (period)
           call gtext (gp, .7, .4, Memc[buf], "h=l; v=c; q=h")
        }
#    Col 3 - Pdot (for fldplot)
        iferr ( pdot = tbhgtd (tp, "PDOT") ) {
        } else {
           call sprintf (Memc[buf], SZ_LINE, "Pdot: %.11e")
             call pargd (pdot)
           call gtext (gp, .7, .25, Memc[buf], "h=l; v=c; q=h")
        }

#    Col 3 - Tot-valid secs (for fftplot)
        iferr ( time = tbhgtr (tp, "TIME") ) {
        } else {
           call sprintf (Memc[buf], SZ_LINE, "Tot Valid Secs: %9.3fs")
             call pargr (time)
           call gtext (gp, .7, .4, Memc[buf], "h=l; v=c; q=h")
        }

#    Col 3 - Fourier Intv (for fftplot)
        iferr ( intv = tbhgtd (tp, "FOURINT") ) {
        } else {
           call sprintf (Memc[buf], SZ_LINE, "Fourier Intv: %9.3fs")
             call pargd (intv)
           call gtext (gp, .7, .25, Memc[buf], "h=l; v=c; q=h")
        }

#   Plot title
        call clgstr (PLOTTITLE, Memc[titstr], SZ_LINE)
        call gsetr (gp, G_TXSIZE, 1.)
        call sprintf (Memc[buf], SZ_LINE, "%s  %s")
           call pargstr(Memc[titstr])
           call pargstr(file)
        call gtext (gp, .5, .85, Memc[buf], "h=c; v=b; q=h")

#   Set the y-axis viewspace and label the Y axis
        call gsview (gp, XLL(const), XLL(const)+XLSPACE(const),
                         YLL(const), YUL(const))

        call sprintf (Memc[buf], SZ_LINE, "%s")
           call pargstr(yaxis)
        call gtext (gp, .5, .5, Memc[buf], "u=180; h=c; v=c; q=h")

#   Set the x-axis viewspace and label the X axis
        call gsview (gp, XLL(const), XUL(const), YLL(const),
                     YLL(const) + YLSPACE(const))

        call sprintf (Memc[buf], SZ_LINE, "%s")
           call pargstr(xaxis)
        call gtext (gp, .5, .5, Memc[buf], "h=c; v=c; q=h")


        call sfree(sp)
	
end

# ------------------------------------------------------------------------
#
# Function:	tim_mkplt
# Purpose:	plot histogram of the data in optional number of windows
# Pre-cond:	Graphics device open and constants & limits structure 
#		initalized current, table file open & columns initialized
# Description:  Loop over the number of user desired windows & plot the
#		table column data, error bars if indicated, and label the 
#		x & y axis with tics and values
#
# ------------------------------------------------------------------------
procedure tim_mkplt (gp, tp, ecol, ycol, const, limits, 
		     ebar, pltype, xlims, ylims)

pointer gp		# i: graphics device handle
pointer tp 		# i: table file handle
pointer ecol		# i: error column pointer
pointer ycol		# i: data column pointer
pointer const		# i: constants struct pointer
pointer limits		# i: limits structure pointer
bool	ebar		# i: indicates whether error bars plotted
int	pltype          # i: plot type : HISTO or POINT
real    xlims[ARB]      # i: x-axis limits
real    ylims[ARB]      # i: y-axis limits

int	bins_per_plot	# l: number of data bins in 1 plot windo 
int     this_windo	# l: current plot windo

begin

#   Compute the bins of data in each plot windo
	bins_per_plot = (xlims[END]-xlims[BEG]+1.0) / NUM_PLOTS(const)

#   Initialize the plot windo coords
	YWMIN(limits) = ylims[BEG]
	YWMAX(limits) = ylims[END]
	XWMAX(limits) = xlims[BEG] - 1.0

#   Loop over the number of plot windows and graph the data
	do this_windo = 1, NUM_PLOTS(const) {

#   Update the current windo coordinates
	   XWMIN(limits) = XWMAX(limits) + 1.0
	   XWMAX(limits) = XWMIN(limits) + bins_per_plot - 1.0

#   Update the virtual device coordinates
	   call tim_vspace (gp, const, limits)

	   switch (pltype)
	   {
	      case TY_HISTO: {
	         call tim_histo (gp, tp, const, limits, ycol)
	      }
	      case TY_BAR: {
	         call tim_bars (gp, tp, const, limits, ycol)
	      }
	   }
	   if ( ebar ) {
	      call tim_ebar (gp, tp, const, limits, ecol, ycol)
	   }

#   Label the x & y plot axis
	   call tim_drlabels (gp, const, limits)
	}

end

# ------------------------------------------------------------------------
#
# Function:	tim_histo
# Purpose:	plot histogram of the data 
# Pre-cond:	Graphics device open and constants & limits structure 
#		initialized & current, table file open & columns initialized
# Description:  Loop over the number x-axis data points & plot histogram
#		of y-axis table column
#
# ---------------------------------------------------------------------------
procedure tim_histo (gp, tp, const, limits, ycol)

pointer	gp			# i: graphics device handle
pointer tp			# i: input data table handle
pointer const			# i: const struct pointer
pointer limits			# i: limits struct pointer
pointer ycol			# i: data table column pointer

int     row 			# l: pointer to current table row
real    xpos            	# l: x position that gets updated
real    ypos			# l: input y position 

bool    nullflag[25]

begin

#   Set graphics windo to plot
	call gseti (gp, G_WCS, PLT_WCS)
	call gswind (gp, XWMIN(limits), XWMAX(limits), 
			 YWMIN(limits), YWMAX(limits))

#   Draw a box around the current plot
	call tim_pltbox (gp, limits)

#   Loop over x-axis and plot histogram of data
	row = XWMIN(limits)
        xpos = XWMIN(limits)
	while ( row < XWMAX(limits) ) {
	   row = row + 1
	   call tbrgtr (tp, ycol, ypos, nullflag, 1, row)
	   call gadraw (gp, xpos, ypos)
	   xpos = xpos + 1.0
	   call gadraw (gp, xpos, ypos)
        }
end


# ------------------------------------------------------------------------
#
# Function:	tim_bars
# Purpose:	plot bar graph of the data 
# Pre-cond:	Graphics device open and constants & limits structure 
#		initialized & current, table file open & columns initialized
# Description:  Loop over the number x-axis data points & plot y-axis 
#               table column
#
# ---------------------------------------------------------------------------
procedure tim_bars (gp, tp, const, limits, ycol)

pointer	gp			# i: graphics device handle
pointer tp			# i: input data table handle
pointer const			# i: const struct pointer
pointer limits			# i: limits struct pointer
pointer ycol			# i: data table column pointer

int     row 			# l: pointer to current table row
real    xpos            	# l: x position that gets updated
real    ypos			# l: input y position 

bool    nullflag[25]

begin

#   Set graphics windo to plot
	call gseti (gp, G_WCS, PLT_WCS)
	call gswind (gp, XWMIN(limits), XWMAX(limits), 
			 YWMIN(limits), YWMAX(limits))

#   Draw a box around the current plot
	call tim_pltbox (gp, limits)

#   Loop over x-axis and plot histogram of data
	row = XWMIN(limits)
        xpos = XWMIN(limits)
	while ( row < XWMAX(limits) ) {
	   row = row + 1
	   call tbrgtr (tp, ycol, ypos, nullflag, 1, row)
	   call gline (gp, xpos, ypos, xpos+1.0, ypos)
	   xpos = xpos + 1.0
        }
end

# ------------------------------------------------------------------------
#
# Function:	tim_ebar
# Purpose:	plot error bars over the histogram plot
# Pre-cond:	Graphics device open and constants & limits structure 
#		initialized & current, table file open & columns initialized
# Description:  Loop over the x-axis, retrieve y-axis and error data from
#		the table file and plot error bars onto current windo 
#
# ------------------------------------------------------------------------
procedure tim_ebar (gp, tp, const, limits, ecol, ycol)

pointer	gp			# i: graphics device handle
pointer tp			# i: input data table handle
pointer const			# i: const struct pointer
pointer limits			# i: limits struct pointer
pointer ecol			# i: error data column pointer
pointer ycol			# i: data table column pointer

bool    nullflag[25]		# l: null flag buffer
int     row 			# l: pointer to current table row
real    err			# l: table error data size
real    xpos			# l: x pos centered on bin
real    ypos			# l: table plot data point

begin

#   Compute position in center of bin for error bar
	xpos = XWMIN(limits) + 0.5

#   Loop over x-axis and plot error bars 
	row = XWMIN(limits)
	while ( xpos <= XWMAX(limits) ) {
	   row = row + 1
	   call tbrgtr (tp, ecol, err, nullflag, 1, row)
	   call tbrgtr (tp, ycol, ypos, nullflag, 1, row)
	   call gline (gp, xpos, ypos-err, xpos, ypos+err)
	   xpos = xpos + 1.0
	}

end

# ------------------------------------------------------------------------
#
# Function:	tim_drlabels
# Purpose:	draw tics and labels on x & y axis of current window
# Pre-cond:	Graphics device open and constants & limits structure 
#		initialized & current
#
# ------------------------------------------------------------------------
procedure tim_drlabels (gp, const, limits)

pointer	gp			# i: graphics device handle
pointer const			# i: constants struct pointer
pointer limits			# i: limits struct pointer

pointer buf			# l: temporary buffer
pointer fbuf			# l: format buffer
pointer sp			# l: space allocation pointer

begin


#  Temporary buffers for labels and formats
	call smark(sp)
	call salloc (buf, SZ_LINE, TY_CHAR)
	call salloc (fbuf, SZ_LINE, TY_CHAR)

#  Set the tic label format string 
	call sprintf (Memc[fbuf], SZ_LINE, "s=%.3e; h=c; v=c; q=h")
	  call pargr (TICSIZE(const))

#   Draw x & y axis tics and labels
	call tim_xtics (gp, const, limits, Memc[buf], Memc[fbuf])

	call tim_ytics (gp, const, limits, Memc[buf], Memc[fbuf])

	call sfree(sp)

end

# ------------------------------------------------------------------------
#
# Function:	tim_pltbox
# Purpose:	draw a box around the limits of the current window
# Pre-cond:	Graphics device open and limits structure initialized 
#		& current
#
# ------------------------------------------------------------------------
procedure tim_pltbox (gp, limits)

pointer	gp			# i: graphics device handle
pointer limits			# i: limits struct pointer

begin
	
#  Draw a box around the plot of the current window
	call gamove (gp, XWMIN(limits), YWMIN(limits))
	call gadraw (gp, XWMIN(limits), YWMAX(limits))
	call gadraw (gp, XWMAX(limits), YWMAX(limits))
	call gadraw (gp, XWMAX(limits), YWMIN(limits))
	call gadraw (gp, XWMIN(limits), YWMIN(limits))

end

# ------------------------------------------------------------------------
#
# Function:	tim_xtics
# Purpose:	draw the x-axis tics and coordinate labels
# Pre-cond:	Graphics device open and limits structure initialized 
#		& current
#
# ------------------------------------------------------------------------
procedure tim_xtics (gp, const, limits, buf, fbuf)

pointer	gp			# i: graphics device handle
pointer const			# i: constants struct pointer
pointer limits			# i: limits struct pointer
char    buf[ARB]		# i: label buffer
char    fbuf[ARB]		# i: format buffer

pointer timelabel		# l: xaxis time label; seconds or bin
int     num_tics                # l: integer number of tics
double  xlabel                  # l: x axis label
real    xpos			# l: current x-axis position
real    y1, y2			# l: y range
real    xintv			# l: tic interval

begin

#   Allocate space
	call salloc (timelabel, SZ_LINE, TY_CHAR)

#   Set graphics window to the current plots
	call gseti (gp, G_WCS, XLAB_WCS)
	y1 = 0.0
	y2 = 3.0
	call gswind (gp, XWMIN(limits), XWMAX(limits), y1, y2)

#   retrieve the first x-axis position and compute the tic interval
	num_tics = XTICS(const)
	call gtickr (XWMIN(limits), XWMAX(limits), num_tics,
		     0, xpos, xintv)

#   set integer format for bin or phase and real format for sec or freq

#   Draw the tics and label them along the x-axis 
	while ( xpos < XWMAX(limits) ) {

	   call gamove (gp, xpos, y2)
	   call gadraw (gp, xpos, y2-.5)
           xlabel = double(xpos) * BINLEN(const) + XOFFSET(const)

#   We check which kind of plot to determine the format of the labels
	   if (PTYPE(const) == XSEC) {
              if ( xlabel >= 0.999999 | xlabel < EPSILOND ) {
                 call sprintf (buf, SZ_LINE, "%.6e")
              } else {
                 call sprintf (buf, SZ_LINE, "%.10e")
	      }
	      call pargd (xlabel)
           } else if (PTYPE(const) == XFREQ) {
              call sprintf (buf, SZ_LINE, "%.6e")
	        call pargd (xlabel)
           } else if (PTYPE(const) == XPHASE ) {
              call sprintf (buf, SZ_LINE, "%.3f")
                call pargd (xlabel)
           } else {
              call sprintf (buf, SZ_LINE, "%d")
	        call pargi (int(xlabel))
	   }
           call gtext (gp, xpos, y2-1.5, buf, fbuf)
	   
	   xpos = xpos + xintv
	}

end

# ------------------------------------------------------------------------
#
# Function:	tim_ytics
# Purpose:	draw the y-axis tics and coordinate labels
# Pre-cond:	Graphics device open and limits structure initialized 
#		& current
#
# ------------------------------------------------------------------------
procedure tim_ytics (gp, const, limits, buf, fbuf)

pointer	gp			# i: graphics device handle
pointer const			# i: constants struct pointer
pointer limits			# i: limits struct pointer
char    buf[ARB]		# i: label buffer
char    fbuf[ARB]		# i: format buffer

int     num_tics                # l: integer number of tics
real    ypos			# l: current y-axis position
real    x1, x2			# l: x range
real    intv			# l: tic interval

begin
	
#   Set graphics window to the current plots
	call gseti (gp, G_WCS, YLAB_WCS)
	x1 = 1.0
	x2 = 3.0
	call gswind (gp, x1, x2, YWMIN(limits), YWMAX(limits))
	
#   retrieve the first y-axis position and compute the tic interval
	num_tics = YTICS(const)
	call gtickr (YWMIN(limits), YWMAX(limits), num_tics,
		     0, ypos, intv)

#   Draw the tics and label them along the y-axis 
	while ( ypos < YWMAX(limits) ) {

	   call gamove (gp, x2, ypos)
	   call gadraw (gp, x2-.3, ypos)
	   call sprintf (buf, SZ_LINE, "%.4e")
	     call pargr (ypos)
           call gtext (gp, x2-1.2, ypos, buf, fbuf)
	   
	   ypos = ypos + intv
	}

end

# ----------------------------------------------------------------------------
