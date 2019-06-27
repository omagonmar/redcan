#$Header: /home/pros/xray/xtiming/timplot/RCS/timcoords.x,v 11.0 1997/11/06 16:44:49 prosb Exp $
#$Log: timcoords.x,v $
#Revision 11.0  1997/11/06 16:44:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:04  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  10:29:18  janet
#jd - added consistency with doubles to the code.
#
#Revision 5.1  92/11/16  15:41:19  mo
#MC	11/16/92	Add extra limit dimension for CTOD in rparselims
#			Since it attempts the 3rd coordinate conversion
#			before terminating and Silicon Graphics version
#			died on the 3rd CTOD attempt
#
#Revision 5.0  92/10/29  22:49:36  prosb
#General Release 2.1
#
#Revision 4.0  92/06/26  14:22:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/06/17  11:24:06  janet
#> #             {2} JD -- Oct 1991 -- updates tim_xaxlims to take x range
#> #                                     in same units as axis - was just bin.
#
#
#Revision 3.2  91/10/04  11:27:34  janet
#fixed rparselims to call ctod instead of ctor because of bug on vax.
#
#Revision 3.0  91/08/02  02:02:40  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  15:06:57  janet
#fixed ylims parser to accept reals.
#
#Revision 2.1  91/07/21  14:27:17  janet
#*** empty log message ***
#
#Revision 2.0  91/03/06  22:51:34  prosb
#General Release 1.0
#
# -----------------------------------------------------------------------
#
# Module:	TIMCOORDS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Routines to handles coordinates for plotting
# External:	tim_ginit(), tim_xaxlims(), tim_yaxlims()
# Local:	tim_parselims(), tim_vspace()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version July 1989
#		{1} JD -- July 1991 -- added rparselims for y axis reals
#				    -- added gclear to clear graph windo
#		{2} JD -- Oct 1991 -- updates tim_xaxlims to take x range 
#                                     in same units as axis - was just bin. 
#		{3} JD -- Dec 1992 -- updated x-axis handling to double prec.
#				      changed rparselims to dparselims.
#
# -----------------------------------------------------------------------

include  <gset.h>
include  "timplot.h"

# -----------------------------------------------------------------------
#
# Function:	tim_ginit
# Purpose:	initalize graphics device & set device plotting constants
# Post cond:    Virtual coordinates in Constants Structure Set 
#		Window coordinates in Limits Structure Initialized
#
# -----------------------------------------------------------------------
procedure tim_ginit (gp, const, limits)

pointer gp		# i: graphics handle
pointer const		# i: constants struct pointer
pointer limits		# i: limits struct pointer

pointer  gopen()	# l: open graphics device
real     yspace		# l: Y-axis windo plotting space

begin

#   Open the graphics window
	gp = gopen ("stdgraph", NEW_FILE, STDGRAPH)
        call gclear (gp)
	call ggview (gp, XLL(const), XUL(const), YLL(const), YUL(const))

#   Compute the hdr label size and adjust the upper y limit down
	HLABEL(const) = ( YUL(const) - YLL(const)) * HDR_BORDER
	YUL(const) = YUL(const) - HLABEL(const)

#   Compute the y-axis plotting and label space
	YLSPACE(const) = ( YUL(const)- YLL(const) ) * YPLOT_BORDER

#   Compute the x-axis label and border space
	XLSPACE(const) = ( (XUL(const)-XLL(const)) * XPLOT_BORDER ) / 3.0 

#   Compute the plot space and label space of one plot in the multi windo option
	yspace = ( YUL(const) - YLL(const) ) * (1.0 - YPLOT_BORDER)
	PSPACE(const) = yspace / NUM_PLOTS(const) 
	PLSPACE(const) = ( yspace / NUM_PLOTS(const) ) * YPLOT_BORDER

#   Compute the virtual (device) X and Y coordinates
	YVMAX(limits) = YUL(const) + PSPACE(const) 
	YVMIN(limits) = YUL(const) + PLSPACE(const) 

	XVMIN(limits) = XLL(const) + ( 2.0 * XLSPACE(const) )
	XVMAX(limits) = XUL(const) - XLSPACE(const)

end

# -----------------------------------------------------------------------
#
# Function:	tim_xaxlims
# Purpose:	Retrieve x-axis plotting range
# Pre-cond:	Constant NUMBINS retrieved from table header
# Description:  the x-axis limits can either be set to 'auto' which will set 
#		the limit to all of the table rows or the user can select a 
#		subset within that range. 
# Notes:        Expected input formats are:
#		  	option1 - auto 
#		  	option2 - <start> <end>  (fit to table limits if 
#					    	  outside of range)
#		
#
# ----------------------------------------------------------------------
procedure tim_xaxlims (tp, const, limits, xlims)

pointer tp                      # i: table pointer
pointer const			# i: constants struct pointer
pointer limits			# i: limits struct pointer
real    xlims[ARB]		# o: start and stop table rows


double  parlim[2]
pointer coords			# l: x coords input 
pointer sp                      # l: space allocation pointer
bool    streq()			# l: string equal function

begin

#   X Plot limits:  default is to plot all data
#                   option is for user to pick start & stop data rows

        call smark(sp)
	call calloc (coords, SZ_LINE, TY_CHAR)
	call clgstr (XCOORDS, Memc[coords], SZ_LINE)

#   Auto is default to plot all data
	if ( streq ("auto", Memc[coords], SZ_LINE) ) {
	   xlims[BEG] = 0.0
	   xlims[END] = NUMBINS(const)
           XAUTO(const) = YES

#   Limits can be input in form of start and stop table rows (ex. 1 1000)
	} else {
	   call tim_dparselims (Memc[coords], parlim)

#          call printf ("input x limits : %f  %f, offset : %f\n")
# 	     call pargd (parlim[BEG])
# 	     call pargd (parlim[END])
#            call pargd (XOFFSET(const))
#          call flush (STDOUT)

	   xlims[BEG] = nint((parlim[BEG]-XOFFSET(const)) / BINLEN(const) )
           xlims[END] = nint((parlim[END]-XOFFSET(const)) / BINLEN(const) + 1.0) 
#          call printf ("raw x limits in bins: %f  %f\n")
#  	     call pargr (xlims[BEG])
#	     call pargr (xlims[END])
#          call flush (STDOUT)

	   if ( xlims[BEG] < 0 ) {
	      call printf ("Warning: Lower limit to small: set to 0")
              call flush (STDOUT)
	      xlims[BEG] = 0
           }
            
	   if ( xlims[END] > NUMBINS(const) ) {
	      xlims[END] = NUMBINS(const)
	      call printf ("Warning: Upper limit to large: set to %.2f\n")
		 call pargr (xlims[END]*BINLEN(const))
	   } 
           XAUTO(const) = NO

	}
#       call printf ("x limits in bins: %f  %f\n")
#	  call pargr (xlims[BEG])
#	  call pargr (xlims[END])
#       call flush (STDOUT)

        call sfree(sp)

end

# -----------------------------------------------------------------------
#
# Function:	tim_yaxlims
# Purpose:	Retrieve y-axis plotting range
# Pre-cond:	Table file open & useful columns initialized
# Description:  the y-axis limits can either be set to 'auto' which will 
#		set the limit to the min and 10 percent above the max of 
#		the column or the user can select a subset range.  If errors 
#		are plotted the y range is extended above the max error value.
# Notes:        Expected input formats are:
#			option1 - auto 
#			option2 - <start> <end>  (data outside of range 
#						  is clipped)
#
# ----------------------------------------------------------------------
procedure tim_yaxlims (tp, ebar, ycolumn, ecolumn, ylims)

pointer	tp			# i: table pointer
bool    ebar			# i: plot error bars?? y/n
char    ycolumn[ARB]		# i: ycolumn name
char    ecolumn[ARB]		# i: error column name
real    ylims[ARB]		# o: y limits

pointer coords			# l: y coords label
pointer sp                      # l: allocation pointer

real    elims[2]		# l: error limits
real    buff			# l: buffer space so that plot axis is > data

double  parlim[2]

bool     streq()		# l: string equal function

begin


#   Y Plot limits:  default is to plot from data min to max
#                   option is for user to pick data start & stop 

	call smark(sp) 
	call calloc (coords, SZ_LINE, TY_CHAR)
	call clgstr (YCOORDS, Memc[coords], SZ_LINE)

#   Auto is default to plot all data
	if ( streq ("auto", Memc[coords], SZ_LINE) ) {
	   call tbl_minmax (tp, ycolumn, ylims)

#   Set y limits to 1 above & below y if the min equals the max 
	   if ( ylims[BEG] == ylims[END] ) {
	      ylims[BEG] = ylims[BEG] - 1.0
	      ylims[END] = ylims[END] + 1.0

#   Set upper limit to 10 percent above max
	   } else {
	      buff = (ylims[END] - ylims[BEG])*.10
	      ylims[END] = ylims[END] + buff
	      if ( ylims[BEG] - buff > 0.0 ) {
		ylims[BEG] = ylims[BEG] - buff
	      }
	   }

#   Get error range & Adjust y upper limit if error bars are plotted
	   if ( ebar ) {
	      call tbl_minmax (tp, ecolumn, elims)
	      ylims[END] = ylims[END] + elims[END]
              ylims[BEG] = ylims[BEG] - elims[BEG]
	   }

#   Limits can be input in form of y value range (ex. 0 3)
	} else {
	   call tim_dparselims (Memc[coords], parlim)
           ylims[BEG] = parlim[BEG]
           ylims[END] = parlim[END]
	}

end
# -----------------------------------------------------------------------
#
# Function:	tim_iparselims
# Purpose:	Parse a string with 2 integers & return the 2 values as reals 
# Notes:        Error if more than 2 coordinates found 
#
# ----------------------------------------------------------------------
procedure tim_iparselims(coords, lims)

char	coords[ARB]		# i: axis start and stop
real    lims[ARB]		# o: parsed limits

int     nchars			# l: number of characters
int	ncoords			# l: number of coordinates
int	ip			# l: ptr for ctoi

int	ctoi()			# l: convert from char to integer
int     ilims[2]		# l: converted integer limits

begin
	ncoords = 1
	ip = 1
	while ( TRUE ) {
	   nchars = ctoi (coords, ip, ilims[ncoords])
	   if ( nchars == 0 ) break
	   if ( ncoords > 2 ) call error (1, "Only 2 Coords allowed")
	   lims[ncoords] = ilims[ncoords]
#	   call printf ("coord = %d \n")
#	     call pargi (ilims[ncoords])
	   ncoords = ncoords + 1
	}
	if ( ncoords <= 2 ) call error (1, "Format is val1_space_val2")

end

# -----------------------------------------------------------------------
#
# Function:	tim_dparselims
# Purpose:	Parse a string with 2 reals & return the 2 values as reals 
# Notes:        Error if more than 2 coordinates found 
#
# ----------------------------------------------------------------------
procedure tim_dparselims(coords, lims)

char	coords[ARB]		# i: axis start and stop
double  lims[ARB]		# o: parsed limits

int     nchars			# l: number of characters
int	ncoords			# l: number of coordinates
int	ip			# l: ptr for ctor

double  dlims[2+1]		# l: Need temporary 3rd place for CTOD test
				#  Died on Silicon Graphics without it

int     ctod()			# l: convert from char to real

begin
	ncoords = 1
	ip = 1
	while ( TRUE ) {
	   nchars = ctod (coords, ip, dlims[ncoords])
	   if ( nchars == 0 ) break
	   if ( ncoords > 2 ) call error (1, "Only 2 Coords allowed")
           lims[ncoords] = dlims[ncoords]
#          call printf ("coord = %f \n")
#   	     call pargr (lims[ncoords])
#          call flush (STDOUT)
	   ncoords = ncoords + 1
	}
	if ( ncoords <= 2 ) call error (1, "Format is val1_space_val2")

end

# -----------------------------------------------------------------------
#
# Function:	tim_vspace
# Purpose:	Set the Virtual plotting space for the current plot window
# Notes:        Space referred to by PLT_WCS, XLAB_WCS, YLAB_WCS in 
#		subsequent plotting routines
#
# ----------------------------------------------------------------------
procedure tim_vspace (gp, const, limits)

pointer gp		# i: graphics handle
pointer const		# i: constants struct pointer
pointer limits		# i: limits struct pointer

real    xlmin		# l: x-axis label min
real    ylmin		# l: y-axis label min

begin

#  Update limits
	YVMAX(limits) = YVMAX(limits) - PSPACE(const) 
	YVMIN(limits) = YVMIN(limits) - PSPACE(const) 

        xlmin = XVMIN(limits) - XLSPACE(const)
        ylmin = YVMIN(limits) - PLSPACE(const)

#  Set Plot space
    	call gseti (gp, G_WCS, PLT_WCS)
	call gsview (gp, XVMIN(limits), XVMAX(limits), 
			 YVMIN(limits), YVMAX(limits))
#  Set xlabel space
    	call gseti (gp, G_WCS, XLAB_WCS)
	call gsview (gp, XVMIN(limits), XVMAX(limits), 
		         ylmin, YVMIN(limits))
#  Set ylabel space
    	call gseti (gp, G_WCS, YLAB_WCS)
	call gsview (gp, xlmin, XVMIN(limits), 
			 YVMIN(limits), YVMAX(limits))
end
