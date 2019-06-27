#$Header: /home/pros/xray/xplot/imcontour/RCS/imc_contours.x,v 11.0 1997/11/06 16:38:06 prosb Exp $
#$Log: imc_contours.x,v $
#Revision 11.0  1997/11/06 16:38:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:02:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:35:05  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:24:00  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:02:32  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:20:51  pros
#General Release 1.0
#
# -------------------------------------------------------------------
#
# Module:	imc_contours
# Project:	PROS -- ROSAT RSDC
# Purpose:	routine to graph contours onto an image
# Includes:	draw_contours()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte -- October 1989 -- initial version
#		{n} <who> -- <when> -- <does what>
#
# -------------------------------------------------------------------

include <gset.h>
include "imcontour.h"
include "clevels.h"

# -------------------------------------------------------------------
#
# Function:	draw_contours
# Purpose:	graph contours of an image onto a graphics display
#
# -------------------------------------------------------------------
procedure draw_contours(igp,a,xaxlen,yaxlen,display)

pointer  igp 			# i: graphics pointer

int      xaxlen			# i: x-axis length
int      yaxlen			# i: y-axis length
int	 display		# i: display level

real     a[xaxlen,yaxlen]       # i: data to be contoured

int      i, j, k		# l: loop counters	
int      mm, nn			# l: adjusted axis length
int	 icase			# l: case setup

real     deltx, delty		# l: position change
real     v1, v2, v3, v4 	# l: local position values
real	 val			# l: current position value
real     x, y			# l: current position
real	 xx0, xx1		# l: computed x grid position
real	 yy0, yy1		# l: computed y grid position
 
include  "clevels.com"

begin

# Set the Graphics windo to Pixel
        call gseti (igp, G_WCS, PIX_WCS)

	mm=xaxlen-1
	nn=yaxlen-1
	deltx=1.0; delty=1.0
	y=1.0
	do j = 1, nn {
	   x=1.0
	   for (i=1; i<=mm; i=i+1) {
	      v1=a[i,j]
	      v2=a[i+1,j]
	      v3=a[i,j+1]
	      v4=a[i+1,j+1]
	      for (k=NUM_PARAMS(sptr); k>=1; k=k-1) {
		 val=PARAMS(sptr,k)
	         if (val > -1.E10) {
		    if (val > 0.0) {
		       call gseti (igp, G_PLTYPE, GL_SOLID)
		    } else {
		       call gseti (igp, G_PLTYPE, GL_DOTTED)
		    }
		    icase=1
		    if (val > v1) icase=icase+1
		    if (val > v2) icase=icase+2
		    if (val > v3) icase=icase+4
		    if (val > v4) icase=9-icase

		    switch (icase) {
		    case 1: {
		    }
		    case 2: {	         
		       xx0=x+deltx*(val-v1)/(v2-v1)
		       yy0=y
		       xx1=x
		       yy1=y+delty*(val-v1)/(v3-v1)
		       }
		   case 3: {		 
		       xx0=x+deltx*(val-v1)/(v2-v1)
		       yy0=y
		       xx1=x+deltx
	 	       yy1=y+delty*(val-v2)/(v4-v2)
		       }
		    case 4: {
		       xx0=x
		       yy0=y+delty*(val-v1)/(v3-v1)
		       xx1=x+deltx
		       yy1=y+delty*(val-v2)/(v4-v2)
		       }
		    case 5: {
		       xx0=x
		       yy0=y+delty*(val-v1)/(v3-v1)
		       xx1=x+deltx*(val-v3)/(v4-v3)
		       yy1=y+delty
		       }
		    case 6: {
		       xx0=x+deltx*(val-v1)/(v2-v1)
		       yy0=y
		       xx1=x+deltx*(val-v3)/(v4-v3)
		       yy1=y+delty
		       }
		    case 7: {
		       xx0=x+deltx*(val-v1)/(v2-v1)
		       yy0=y
		       xx1=x
		       yy1=y+delty*(val-v1)/(v3-v1)

		       call gamove ( igp, xx0, yy0 )
		       call gadraw ( igp, xx1, yy1 )
		       xx0=x+deltx*(val-v3)/(v4-v3)
		       yy0=y+delty
		       xx1=x+deltx
		       yy1=y+delty*(val-v2)/(v4-v2)
		       }
		    case 8: {
		       xx0=x+deltx*(val-v3)/(v4-v3)
		       yy0=y+delty
		       xx1=x+deltx
		       yy1=y+delty*(val-v2)/(v4-v2)
		       }
		    }
		    if ( icase != 1 ) {
		       call gamove ( igp, xx0, yy0 )
		       call gadraw ( igp, xx1, yy1 )
		    }
	         }   
	      }  
	      x=x+deltx
	   }
	   y=y+delty
	}

	call gflush(igp)
end


