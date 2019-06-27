#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_pixgrid.x,v 11.0 1997/11/06 16:38:08 prosb Exp $
#$Log: imc_pixgrid.x,v $
#Revision 11.0  1997/11/06 16:38:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:41:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:24:02  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:36  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:20:58  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
#
# Module:	imc_pixgrid
# Project:	PROS -- ROSAT RSDC
# Purpose:	draw a pixel grid map 
# Includes:	pix_grid()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- October 1989 -- initial version
#		{n} <who> -- <when> -- <does what>
#
# -------------------------------------------------------------------------

include <gset.h>
include "imcontour.h"

# -------------------------------------------------------------------------
#
# Function:	pix_grid()
# Purpose:	draw and label a pixel map 
# Uses:		graphics routine gtickr takes the axis range and an
#               estimate of the number of tics and determines an interval 
#		that is rounded and an absolute number of tics
#
# -------------------------------------------------------------------------
procedure pix_grid (gp, ty_grid, gr_label)

pointer  gp		# i: graphics pointer
int      ty_grid	# i: grid type - FULL or TICS or NONE
int      gr_label	# i: grid label - IN or OUT or NONE

bool     alternate	# l: indicated whether alternate labeling 
bool     donext         # l: indicated whether next line should be labeled   	

int      pixlines	# l: input number of pixel lines

real	 bottom 	# l: graphics window bottom border 
real     edge		# l: width used in placing labels
real     intv		# l: interval between labels
real     left 		# l: graphics window left border 
real	 right 		# l: graphics window right border 
real     top    	# l: graphics window top border 
real     xpos, ypos	# l: grid position

pointer  label		# l: ptr to grid label buffer
pointer  buff  		# l: temporary buffer
pointer  sp		# l: stack pointer

int      clgeti()

begin
	call smark (sp)
   	call salloc(label, SZ_LINE, TY_CHAR)
   	call salloc(buff, SZ_LINE, TY_CHAR)

#   Retrieve paramter for # of grid lines
 	pixlines = clgeti("pixel_lines")

#   Set attributes to plot box
	call gseti (gp, G_WCS, PIX_WCS)
	call ggwind(gp, left, right, bottom, top)

#   Plot the pixel box
	call gamove (gp, left, bottom)
	call gadraw (gp, right, bottom)
	call gadraw (gp, right, top)
	call gadraw (gp, left, top)
	call gadraw (gp, left, bottom)

#   ALternate labeling if >=5 pixel lines
	if ( pixlines >= 5 ) {
	   alternate = true 
	   donext = true
	} else {
	   alternate = false
	   donext = true
	}

#   Set attributes to plot dotted grid lines
	if ( ty_grid == FULL ) {
	   call gseti  (gp, G_PLTYPE, GL_DOTTED)
	}
	call gsetr  (gp, G_PLWIDTH, 1.0)
	call gsetr  (gp, G_TXSIZE, 0.75)

#  Setup label format for IN or OUT
	edge = (top - bottom) / EDGE_FACTOR
	if ( gr_label == OUT ) {
	   call sprintf (Memc[buff], 12, "h=c;v=c;q=h")
	   ypos = bottom - edge
	} else if ( gr_label == IN ) {
	   call sprintf (Memc[buff], 12, "h=c;v=c;q=h")
	   ypos = bottom + edge
	}

#   ---- X AXIS ----
#   Plot the pixel grid and label in x direction
	call gtickr (left, right, pixlines, 0, xpos, intv)

	while ( xpos < right ) {
	   call gamove (gp, xpos, bottom)
	   If ( ty_grid == FULL ) { 
	      call gadraw (gp, xpos, top)
	   } else if ( ty_grid == TICS ) {
	      call gadraw (gp, xpos, bottom+.5*edge)
	      call gamove (gp, xpos, top)
	      call gadraw (gp, xpos, top-.5*edge)
	   }

#   Label if they are not turned off
	   if ( gr_label != NO_LABEL ) {
	      if ( !alternate )
	         donext = true
	      if ( donext ) {
	         call sprintf (Memc[label], 4, "%-4d")
	           call pargi (int(xpos))
	         call gtext (gp, xpos, ypos, Memc[label], Memc[buff])
	         donext = false
	      } else {
	         donext = true
	      }
	   }
	   xpos = xpos + intv
	}

#   --- Y AXIS ----
#   Plot the pixel grid and label in y direction
	edge = (right - left) / EDGE_FACTOR
	call gtickr (bottom, top, pixlines, 0, ypos, intv)
	donext = false 

#  Setup label format for IN or OUT
	if ( gr_label == OUT ) {
	   xpos = left - edge
	   call sprintf (Memc[buff], 12, "h=r;v=c;q=h")
	} else if ( gr_label == IN ) {
	   xpos = left + edge
	   call sprintf (Memc[buff], 12, "h=l;v=c;q=h")
	}

	while ( ypos < top ) {

#   Draw a line if FULL, a tic if TICS, or nothing if NO_GRID
	   call gamove (gp, left, ypos)
	   If ( ty_grid == FULL ) { 
	      call gadraw (gp, right, ypos)
	   } else if ( ty_grid == TICS ) {
	      call gadraw (gp, left+0.5*edge, ypos)
	      call gamove (gp, right, ypos)
	      call gadraw (gp, right-0.5*edge, ypos)
	   }

#   Label if they are not turned off
	   if ( gr_label != NO_LABEL ) {
	      if ( !alternate )
	         donext = true
	      if ( donext ) {
		 if ( gr_label == OUT ) {
	            call sprintf (Memc[label], 6, "%4d")
	              call pargi (int(ypos))
		 } else if ( gr_label == IN ) {
	            call sprintf (Memc[label], 6, "%-4d")
	              call pargi (int(ypos))
		 }
	         call gtext (gp, xpos, ypos, Memc[label], Memc[buff])
	         donext = false
	      } else {
	         donext = true
	      }
	   }
	   ypos = ypos + intv
	}

	call sfree(sp)

end

# -------------------------------------------------------------------------

