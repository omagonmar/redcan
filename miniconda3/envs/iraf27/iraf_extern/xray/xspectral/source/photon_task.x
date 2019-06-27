#$Header: /home/pros/xray/xspectral/source/RCS/photon_task.x,v 11.0 1997/11/06 16:43:06 prosb Exp $
#$Log: photon_task.x,v $
#Revision 11.0  1997/11/06 16:43:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:20  prosb
#General Release 2.3
#
#Revision 6.1  93/10/22  17:12:56  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI.  (Also added default case.)
#
#Revision 6.0  93/05/24  16:52:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/07  16:09:17  prosb
#jso - changed statement so that predicted data is plotted for one channel.
#
#Revision 3.2  92/04/06  15:10:28  jmoran
#JMORAN no changes
#
#Revision 3.1  91/09/22  19:06:53  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:56  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:33:42  prosb
#jso - made spectral.h system wide and add open of new pset parameter
#
#Revision 2.0  91/03/06  23:06:37  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  main routine for task which plots the raw photon histogram

include  <gset.h>
include  <pkg/gtools.h>
include  <mach.h>
include  <spectral.h>
include  "photon_plot.h"

# 
#  main task procedure

procedure  t_photplt ()

pointer	 fp				# parameter structure
pointer	np
pointer  device                         # graphics device
pointer  gp  				# graphics pointer
pointer  gt				# GTOOLS pointer
pointer  pl				# plot structure
pointer  sp				# stack pointer

pointer  gopen(),  gt_init()
pointer	clopset()
int	 make_data_stack()

include "photon_plot.com"

begin
	call smark (sp)
	np = clopset("pkgpars")
#	call const_fp (fp)
	call salloc (fp, LEN_FP, TY_INT)
	call salloc (pl, LEN_PLOTSTRUCT, TY_STRUCT)
	call salloc (c_title,    SZ_PLOT_TITLE,  TY_CHAR)
	call salloc (c_xtitle,   SZ_AXIS_TITLE,  TY_CHAR)
	call salloc (c_ytitle,   SZ_AXIS_TITLE,  TY_CHAR)
	call salloc (device,   SZ_FNAME,       TY_CHAR)

	# get the observed and data set
	if( make_data_stack(fp) <= 0 ){
	    call printf("No data sets were found! \n")
	    return
	}

	# fetch plot titles
	call clgstr (PLOT_TITLE,       Memc[c_title],    SZ_PLOT_TITLE)
	call clgstr (X_AXIS_TITLE,     Memc[c_xtitle],   SZ_AXIS_TITLE)
	call clgstr (Y_AXIS_TITLE,     Memc[c_ytitle],   SZ_AXIS_TITLE)

	# get output device
	call clgstr (DEVICE, Memc[device], SZ_FNAME)

	# initialize GTOOLS
	gt = gt_init()

	# intialize the plot structure
	PL_TITLE[pl]    = c_title
	PL_XTITLE[pl]   = c_xtitle
	PL_YTITLE[pl]   = c_ytitle

	gp = gopen (Memc[device], NEW_FILE, STDGRAPH)
	call edit_plot (fp, gp, pl)
	call gclose (gp)
	call gt_free (gt)
#	call raze_fp (fp)
	call raze_obser_stack (fp)
	call clcpset(np)
	call sfree (sp)
end

# 
#
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----
#
procedure  edit_plot (fp, gp, pl)

pointer	fp,  gp,  pl			# structures

real	wx,  wy				# world coordinates
int	wcs				# world coordinate system
int	key				# response key
char	str[SZ_CUR_RESPONSE]		# cursor command string

int     clgcur()

include "photon_plot.com"

begin
	# init temp model to real model state
	c_mode = C_OBS
	key = 'r'
	repeat  {
	    PL_CURSORX[pl] = wx
	    PL_CURSORY[pl] = wy
	    switch (key)  {

	    #case quit
	    case 'q':
		return
	    case 'Q':
		return

	    # case info on keystrokes
	    case '?':
		call gpagefile (gp, PHOTON_PLOT_HELP, PROMPT)

	    # case of obs toggling
	    case 'o':
		if( c_mode != C_OBS ){
		    c_mode = C_OBS
		    call pl_lims(fp, pl)
		    call photon_plot(fp, gp, pl)
		}

	    # case of obs-pred toggling
	    case 'd':
		if( c_mode != C_DIFF ){
		    c_mode = C_DIFF
		    call pl_lims(fp, pl)
		    call photon_plot(fp, gp, pl)
		}

	    # case of obs-pred/err toggling
	    case 's':
		if( c_mode != C_SIGMA ){
		    c_mode = C_SIGMA
		    call pl_lims(fp, pl)
		    call photon_plot(fp, gp, pl)
		}

	    # case of error toggling
	    case 'e':
		if( c_mode != C_OBS ){
		    c_mode = C_OBS
		    call pl_lims(fp, pl)
		}
		if( PL_ERRORS[pl] == YES )  {
		    PL_ERRORS[pl] = NO
		}
		else  {
		    PL_ERRORS[pl] = YES
		}
	        call photon_plot (fp, gp, pl)

	    # case of predicted curve toggling
	    case 'p':
		if( c_mode != C_OBS ){
		    c_mode = C_OBS
		    call pl_lims(fp, pl)
		}
		if( PL_PREDICTED[pl] == YES )  {
		    PL_PREDICTED[pl] = NO
		}
		else  {
		    PL_PREDICTED[pl] = YES
		}
		call photon_plot (fp, gp, pl)

	    # case of printing model information
	    case 'l':
		if( c_label == YES )  {
		    c_label = NO
		}
		else  {
		    c_label = YES
		}
		call photon_plot (fp, gp, pl)

	    # case of colon command
	    case ':':
		call photoncolon (pl, str)
		call photon_plot (fp, gp, pl)

	    # case clear screen
	    case 'c':
		call gclear (gp)

	    # case reset and redraw plot
	    case 'r':
		call plreset (fp, pl)
		call photon_plot (fp, gp, pl)

	    # case of previous dataset
	    case '-':
		if( FP_CURDATASET(fp) > 1 )  {
		    FP_CURDATASET(fp) = FP_CURDATASET(fp) - 1
		    call plreset (fp, pl)
		    call photon_plot (fp, gp, pl)
		    }

	    # case of next dataset
	    case '+':
		if( FP_CURDATASET(fp) < FP_DATASETS(fp) )  {
		    FP_CURDATASET(fp) = FP_CURDATASET(fp) + 1
		    call plreset (fp, pl)
		    call photon_plot (fp, gp, pl)
		    }

	    # default
	    default:
		# do nothing
	    }

	    call gflush(gp)

	} until( clgcur(CURSOR, wx, wy, wcs, key, str, SZ_CUR_RESPONSE) == EOF )
end

# 
#
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  plreset (fp, pl)

pointer	 fp		# parameter structure
pointer  pl		# plotting structure

include "photon_plot.com"

begin
	PL_XTRAN[pl]     = GW_LOG
	PL_YTRAN[pl]     = GW_LINEAR
	PL_ERRORS[pl]    = YES
	PL_PREDICTED[pl] = YES
	PL_MODELS[pl]    = YES
	c_label 	 = YES
	call pl_lims(fp, pl)
end

#
#  PL_LIMS -- get min and max for given mode
#
procedure pl_lims(fp, pl)

pointer	 fp		# parameter structure
pointer  pl		# plotting structure
pointer	 ds		# dataset structure
pointer	 observed	# observed data
pointer	 predicted	# predicted data
pointer  errors		# errors on observed
int	 nbins		# number of channels
int	 i		# loop counter
real	 ymin, ymax	# min and max for y scale
real	 diff		# diff buffer (obs-pred)
real	 clgetr()

include "photon_plot.com"

begin
	ds = FP_OBSERSTACK(fp,FP_CURDATASET(fp))
	nbins = DS_NPHAS(ds)
	observed = DS_OBS_DATA(ds)
	predicted = DS_PRED_DATA(ds)
	errors   = DS_OBS_ERROR(ds)

	# x min and max are instrument dependent and same for all modes
	switch ( DS_INSTRUMENT(ds) ) {
	case EINSTEIN_IPC:
	    PL_XMIN[pl] = clgetr(IPC_MIN_E)
            PL_XMAX[pl] = clgetr(IPC_MAX_E)
	case EINSTEIN_HRI:
	    PL_XMIN[pl] = clgetr(HRI_MIN_E)
            PL_XMAX[pl] = clgetr(HRI_MAX_E)
	case EINSTEIN_MPC:
	    PL_XMIN[pl] = clgetr(MPC_MIN_E)
            PL_XMAX[pl] = clgetr(MPC_MAX_E)
	case ROSAT_PSPC:
	    PL_XMIN[pl] = clgetr(PSPC_MIN_E)
            PL_XMAX[pl] = clgetr(PSPC_MAX_E)
	case ROSAT_HRI:
	    PL_XMIN[pl] = clgetr(RHRI_MIN_E)
	    PL_XMAX[pl] = clgetr(RHRI_MAX_E)
	case SRG_HEPC1:
	    PL_XMIN[pl] = clgetr(HEPC1_MIN_E)
            PL_XMAX[pl] = clgetr(HEPC1_MAX_E)
	case SRG_LEPC1:
	    PL_XMIN[pl] = clgetr(LEPC1_MIN_E)
            PL_XMAX[pl] = clgetr(LEPC1_MAX_E)
	default:
	    PL_XMIN[pl] =   0.1
            PL_XMAX[pl] = 100.0
	}

	# y min and max depend on the mode
	ymin = Y_MINIMUM
	switch(c_mode){
	case C_OBS:
 	    ymax = 0.0
	    do i = 1, nbins
                ymax = max (Memr[observed+i-1], ymax)
	case C_DIFF:
		ymin = MAX_REAL
		ymax = - ymin
		do i = 1, nbins{
		    diff = Memr[observed+i-1] - Memr[predicted+i-1]
		    ymax = max(diff, ymax)
		    ymin = min(diff, ymin)
		}
		# make sure we see 0 on the y axis
		# and that the y axis is stretched if it goes negative
		ymin = min(0.0, ymin) * Y_MAX_SCALE
	case C_SIGMA:
		ymin = MAX_REAL
		ymax = - ymin
		do i = 1, nbins{
		    diff = Memr[observed+i-1] - Memr[predicted+i-1]
		    if( Memr[errors+i-1] > EPSILON )
			    diff = diff/Memr[errors+i-1]
		    else{
			    call printf(
				"warning: error == 0, sigma plot will wrong\n")
			    call flush(STDOUT)
		    }
		    ymax = max(diff, ymax)
		    ymin = min(diff, ymin)
		}
		# make sure we see 0 on the y axis
		# and that the y axis is stretched if it goes negative
		ymin = min(0.0, ymin) * Y_MAX_SCALE
	default:
	    call error(1, "unknown plotting mode")
	}
	PL_YMAX[pl] = Y_MAX_SCALE * ymax
	PL_YMIN[pl] = ymin
end
