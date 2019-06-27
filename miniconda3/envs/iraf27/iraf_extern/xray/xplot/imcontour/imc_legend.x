#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_legend.x,v 11.0 1997/11/06 16:38:07 prosb Exp $
#$Log: imc_legend.x,v $
#Revision 11.0  1997/11/06 16:38:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:08  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  11:54:37  janet
#jd - fixed format statement, added sfree.
#
#Revision 7.0  93/12/27  18:48:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:41:02  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:07  prosb
#General Release 2.1
#
#Revision 4.1  92/10/19  14:35:55  prosb
#*** empty log message ***
#
#Revision 4.0  92/04/27  17:32:34  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/24  16:43:41  janet
#commented out the line to make src marks bold.
#
#Revision 3.1  92/01/15  13:31:00  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:24:01  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:34  wendy
#Initial revision
#
#Revision 2.2  91/05/30  12:38:39  janet
#field center display when graph is pixel grid is in pixels
#
#Revision 2.0  91/03/06  23:20:54  pros
#General Release 1.0
#
# ---------------------------------------------------------------------
#
# Module:	IMC_SKYMAP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Plot a skymap grid for imcontour
# Includes:     sky_legend(), identify_plt(), scale_legend(), clevel_legend()
# Modified:	{0} Janet DePonte -- October 1989 -- modified original ST code
#		{1} JD --  May 1991 -- Added precision to Legend ra/dec display 
#                          by adding new conversion routines prad_hms,prad_dms
#		{n} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------

include <gset.h>
include <math.h>
include "imcontour.h"
include "clevels.h"

# ---------------------------------------------------------------------
#
# Function:	sky_legend
# Purpose:	draw the contour map legend with title, center position,
#		scale, map width, and contour levels
#
# ---------------------------------------------------------------------
procedure sky_legend (gp, pl_cnst, scldev, map)

# Draw the scale, mag key and title

pointer	gp			# i: Graphics descriptor ptr
pointer	pl_cnst			# i: Plate constants struc ptr
char    scldev[ARB]             # i: scale device
int     map 			# i: SKY or PIXEL map

int     line                    # l: current legend output line number

begin

# Draw the chart scale legend
	call scale_legend (gp, pl_cnst, scldev, map, line)

# List the contour levels 
	call clevel_legend (gp, line)

	call gflush(gp)

end

# ---------------------------------------------------------------------
#
# Function:	identify_plt
# Purpose:	Label the plot with the name and id of the contoured image
#
# ---------------------------------------------------------------------
procedure identify_plt (gp, title, fname)

pointer	gp			# i: graphics pointer
char	title[ARB]		# i: input image id
char	fname[ARB]		# i: input image file name

real	wl, wr, wb, wt		# l: world coordinates for labels
real    wx 			# l: label position 

begin

	call gseti  (gp, G_WCS, TITLE_WCS)
	call ggwind (gp, wl, wr, wb, wt)
 	wx = (wr - wl) / 2.0
	call gtext  (gp, wx, wb, fname, "h=c;v=b;s=1.0")

#	call gseti  (gp, G_TXFONT, GT_BOLD)
	call gtext  (gp, wx, wt, title, "h=c;v=t;s=1.2")

end

# -----------------------------------------------------------------------
#
# Function:	scale_legend
# Purpose:	label pointing direction, scale, and width
#
# ---------------------------------------------------------------------
procedure scale_legend (gp, pl_cnst, scldev, map, line)

pointer	gp			# i: graphics pointer
pointer	pl_cnst			# i: plot constants struct ptr
char    scldev[ARB]             # i: scale device 
int     map			# i: SKY or PIXEL map
int	line			# u: line number of legend

pointer	sp			# l: space allocation ptr
pointer label			# l: legend label buffer ptr
pointer units			# l: units of a label plotted as superscripts

real    ratio                   # l: x/y ratio

bool    streq()			# l: string equal function

begin

#   Set graphics parameters for legend
	call gseti  (gp, G_WCS, LEGEND_WCS)
 	call gsetr (gp, G_TXSIZE, .75)

#  Allocate space for label and unit buffers
	call smark  (sp)
	call salloc (label, SZ_LINE, TY_CHAR)
	call salloc (units, SZ_LINE, TY_CHAR)

#  Chart center RA and Dec
	line = 1
	call chtext (gp, line, "Field Center:", NORMAL_SCRIPT)

	if ( map == SKY ) {
	   line = line + 1
	   call prad_hms (CEN_RA(pl_cnst), Memc[label], Memc[units], SZ_LINE)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
	   call chtext (gp, line, Memc[units], SUPER_SCRIPT)

	   line = line + 1
	   call prad_dms (CEN_DEC(pl_cnst), Memc[label], Memc[units], SZ_LINE)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
	   call chtext (gp, line, Memc[units], SUPER_SCRIPT)
	} else if ( map == PIXEL ) {
           line = line + 1
           call sprintf (Memc[label], SZ_LINE, "X Pixel %.2f")
             call pargr (IMPIXX(pl_cnst)*.5)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
          
           line = line + 1
           call sprintf (Memc[label], SZ_LINE, "Y Pixel %.2f")
             call pargr (IMPIXY(pl_cnst)*.5)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
	}

#  Chart scale 
	line = line + 2
	if ( map == SKY  & streq (scldev, "stdplot") ) {
	   call sprintf (Memc[label], SZ_LINE, "Scale: %.2f\"/mm")
	      call pargr (SAPERMMY(pl_cnst))
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
  	   line = line + 1

           ratio = SAPERMMX(pl_cnst) / SAPERMMY(pl_cnst)
	   call sprintf (Memc[label], SZ_LINE, "X/Y Ratio: %.2f")
              call pargr (ratio)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)

	} else if ( map == PIXEL & streq (scldev, "stdplot") ) { 
	   call sprintf (Memc[label], SZ_LINE, "Scale: %.2f pix/mm")
	      call pargr (PIXMMY(pl_cnst))
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
  	   line = line + 1

           ratio = PIXMMX(pl_cnst) / PIXMMY(pl_cnst)
	   call sprintf (Memc[label], SZ_LINE, "X/Y Ratio: %.2f")
              call pargr (ratio)
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
	}

	call sfree (sp)
end


# ---------------------------------------------------------------------
#
# Function:	clevel_legend
# Purpose:	label the map with the list of contour levels
#
# ---------------------------------------------------------------------
procedure clevel_legend (gp, line)

pointer	gp	# i: graphics pointer
int     line	# u: legend line

pointer sp	# l: stack pointer
pointer label   # l: print buffer
int     i	# l: loop pointer

include "clevels.com"

begin

	call smark (sp)
	call salloc (label, SZ_LINE, TY_CHAR)

#  Label the contour level section
	line = line + 2
	call chtext (gp, line, "Contour Levels:", NORMAL_SCRIPT)

#  Loop over the number of contours & write each to the graphics device
	for (i=1; i<=NUM_PARAMS(sptr); i=i+1) {
	   line = line + 1
	   call sprintf (Memc[label], SZ_LINE, "%10.4f")
	      call pargr (PARAMS(sptr,i))
	   call chtext (gp, line, Memc[label], NORMAL_SCRIPT)
	}

        call sfree(sp)
end
