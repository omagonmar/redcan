#$Header: /home/pros/xray/xspectral/source/RCS/bal_plot.x,v 11.0 1997/11/06 16:42:02 prosb Exp $
#$Log: bal_plot.x,v $
#Revision 11.0  1997/11/06 16:42:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:17  prosb
#General Release 2.3
#
#Revision 6.1  93/09/25  02:14:02  dennis
#Changed to accommodate the new file formats (RDF).
#
#Revision 6.0  93/05/24  16:48:52  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:28  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:14  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:52  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:33:37  prosb
#jso - made spectral.h system wide, and open new pset parameter
#
#Revision 2.0  91/03/06  23:01:38  pros
#General Release 1.0
#
#  main routine for task which plots the BAL histogram
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

include  <gset.h>
include  <spectral.h>

#  parameter definitions

define  DATASET         "dataset_number"
define  PLOT_TITLE      "plot_title"
define  X_AXIS_TITLE    "x_axis_title"
define  Y_AXIS_TITLE    "y_axis_title"
define  LISTOUT         "listout"
define  DEVICE          "device"
define  CURSOR          "cursor"

#  local definitions

define	 Y_MINIMUM     (0.0)
define	 Y_MAXIMUM     (100.0)


#  task procedure

procedure  t_balplot ()

int      bin                    # histogram index
int      nbins                  #
int	 dataset		#
real     x1,  x2		# range of BAL on plot
real	 bal_val		# BAL value
bool     listout                #

pointer	np
pointer	 fp			# 
pointer	 ds			#
pointer	 filename		# 
pointer  title                  # plot title
pointer  xtitle			# x axis title
pointer  ytitle			# y axis title
pointer  hgm			# BAL histogram
pointer  edges			# histogram bin edges
pointer  device			#
pointer  bh			# BAL histogram
pointer  gp                     # graphics pointer
pointer  sp			# stack pointer

int	 clgeti()
bool     clgetb()
pointer	clopset()
pointer  gopen()
int	 make_obser_stack()

# 

begin
	call smark (sp)
	np = clopset("pkgpars")
#	call const_fp (fp)
	call salloc (fp, LEN_FP, TY_INT)
	call salloc (title,  SZ_PLOT_TITLE, TY_CHAR)
	call salloc (xtitle, SZ_AXIS_TITLE, TY_CHAR)
	call salloc (ytitle, SZ_AXIS_TITLE, TY_CHAR)
	call salloc (device, SZ_FNAME, TY_CHAR)

	# get the data set
	if( make_obser_stack(fp) <= 0 ){
	    call printf("No observed data sets were found! \n")
	    return
	}

	#  fetch plot titles
	call clgstr (PLOT_TITLE,     Memc[title],    SZ_PLOT_TITLE)
	call clgstr (X_AXIS_TITLE,   Memc[xtitle],   SZ_AXIS_TITLE)
	call clgstr (Y_AXIS_TITLE,   Memc[ytitle],   SZ_AXIS_TITLE)

	#  output can be either a list or a plot
	listout = clgetb (LISTOUT)
	if( !listout )
		call clgstr (DEVICE, Memc[device], SZ_FNAME)

	#  get dataset
	if( FP_DATASETS(fp) > 1 )
	    dataset = clgeti( DATASET )
	 else
	    dataset = 1
	if( (dataset > 0) && (dataset <= FP_DATASETS(fp)) )  {
	    ds = FP_OBSERSTACK(fp,dataset)
	    }

	# make sure that it is Einstein IPC data
	if( DS_INSTRUMENT(ds) == EINSTEIN_IPC )  {
	    filename = DS_FILENAME(ds)
#	    call ds_getbal(ds)	# unnecessary: make_obser_stack() did it
	    bh    = DS_BAL_HISTGRAM(ds)
	    if (bh == NULL) {
		call error(1, "BAL file is empty")
	    }

	    nbins = BH_BAL_STEPS(bh)

	    #  allocate and clear histogram buffer
	    call salloc (hgm,   nbins,   TY_REAL)
	    call salloc (edges, nbins+1, TY_REAL)
	    call aclrr (Memr[hgm], nbins)

	    #  create the histogram
	    call prep_hgm (hgm, edges, bh, x1, x2)

	    #  list or plot the histogram
	    if( listout )  {
		call printf ( "%s\n" )
		call pargstr (Memc[title])
		do bin = 1, nbins
		    if( Memr[hgm+bin-1] != 0.0 )  {
			bal_val = BH_START_BAL(bh) + bin*BH_BAL_INC(bh)
			call printf( "BAL=%5.1f for %5.1f\n" )
			call pargr (bal_val)
			call pargr (Memr[hgm+bin-1])
			}
		}
	      else  {
		gp = gopen (Memc[device], NEW_FILE, STDGRAPH)
		call gfile_label (gp, Memc[filename])
		call gtime_label (gp)
		call gseti (gp, G_XDRAWAXES, 1)
		call plt_hist (gp, Memr[hgm], Memr[edges], nbins,
			        x1, x2, Y_MINIMUM, Y_MAXIMUM,
				Memc[title], Memc[xtitle], Memc[ytitle])
		call plt_pause (gp)
		call gclose (gp)
		}
	    }
	else  {
	    call printf(" This is not an Einstein IPC data set.\n" )
	    call printf(" There is no BAL data.\n" )
	    }

#	call raze_fp (fp)
	call raze_obser_stack (fp)
	call clcpset(np)
	call sfree (sp)
end
# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
procedure  prep_hgm (hgm, edges, bh, minbal, maxbal)

int      nearest_bin            #
int      nbins			#
int      bin			# histogram index
real     minbal			#
real     maxbal			#
real     start                  # minimum BAL value in tables
real     increment              # BAL separation between tables
real     epsilon                # tolerance for "real" equality
real     bal                    #
pointer  bh			# BAL structure
pointer  hgm			#
pointer  edges			#

begin
	#  get BAL table parameters
	start     = BH_START_BAL(bh)
	increment = BH_BAL_INC(bh)
	epsilon   = BH_BAL_EPS(bh)
	nbins     = BH_BAL_STEPS(bh)

	minbal = start - 0.5*increment
	maxbal = start + (nbins-0.5)*increment

	#  indicate bin edge locations
	do bin = 1, nbins
		Memr[edges+bin-1] = start + (bin-1.5)*increment
	Memr[edges+nbins] = start + (nbins-0.5)*increment

	if( BH_ENTRIES(bh) > 0 )
		do bin = 1, BH_ENTRIES(bh)  {
			bal = BH_BAL(bh,bin)
			nearest_bin = (bal-start)/increment + epsilon
			Memr[hgm+nearest_bin-1] = BH_PERCENT(bh,bin)
			}
end

# 

procedure  plt_pause (gp)

pointer	gp			# graphics structure
real    wx,  wy                         # world coordinates
int     wcs                             # world coordinate system
int     key                             # response key
char    str[SZ_CUR_RESPONSE]            # cursor command string

int     clgcur()

begin
        key = 'r'
        repeat  {
#            PL_CURSORX[pl] = wx
#            PL_CURSORY[pl] = wy
            switch (key)  {

            #case quit
            case 'q':
                return
            case 'Q':
                return

            # default
            default:
                # do nothing
            }
        } until( clgcur(CURSOR, wx, wy, wcs, key, str, SZ_CUR_RESPONSE) == EOF )
end
