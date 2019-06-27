#$Header: /home/pros/xray/xspectral/source/RCS/plt_hist.x,v 11.0 1997/11/06 16:43:03 prosb Exp $
#$Log: plt_hist.x,v $
#Revision 11.0  1997/11/06 16:43:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:01  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:36  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:59  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:58  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:35:04  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:06:48  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# PLT_HIST -- Plot a histogram on an open graphics device.

include  <gset.h>
include  <pkg/gtools.h>
include  <spectral.h>

procedure plt_hist (gp, v, x, npts, x1, x2, y1, y2, title, xtitle, ytitle)

pointer	gp			# graphics descriptor
real	v[ARB]			# data vector
real    x[ARB]                  # histogram bin edges
int	npts			# number of data points
real	x1,  x2			# range of X in data vector
real    y1,  y2			# range of Y in data vector
char	title[ARB]		# plot title
char    xtitle[ARB]		# x axis title
char    ytitle[ARB]     	# y axis title

errchk	gswind, gascale, glabax

begin
	call gswind (gp, x1, x2, y1, y2)
#	call gascale (gp, v, npts, 2)
	call glabax (gp, title, xtitle, ytitle)
	call histplt (gp, v, x, npts)
end


# HISTPLT -- Histogram line.

procedure  histplt (gp, v, x, npts)

pointer	gp			# graphics descriptor
real	v[ARB]			# data vector
real    x[ARB]                  # histogram bin edges
int	npts			# number of data points

int     i

begin
	if( npts > 1 )  {
		# reset to solid line
		call gseti(gp, G_PLTYPE, 1)
		call gamove (gp, x[1], 0.0)
		do i = 1, npts  {
			call gadraw (gp, x[i], v[i])
			call gadraw (gp, x[i+1], v[i])
#			call gadraw (gp, x[i+1], 0.0)
			}
		}
		call gadraw (gp, x[npts+1], 0.0)
end

