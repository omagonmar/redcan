#$Header: /home/pros/xray/ximages/pllist/RCS/pllist.x,v 11.0 1997/11/06 16:28:35 prosb Exp $
#$Log: pllist.x,v $
#Revision 11.0  1997/11/06 16:28:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:35  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:47  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:30:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:11  pros
#General Release 1.0
#
#
# Module:       PLLIST.X	( formerly PLDISP.X )
# Project:      PROS -- ROSAT RSDC
# Purpose:      Display the entries in a PLIO/PMIO mask file
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MVH   -- initial version 		-- 1987
#               {1} MC    -- To change name from PLDISP -- 1/91
#               {n} <who> -- <does what> -- <when>
#

include <plset.h>

include <ext.h>
include <plhead.h>

procedure t_pllist()

int	ncols				# number of columns to display
int	nrows				# rows to display
int	x1, y1, x2, y2			# rg_pldisp parameters
pointer	pl				# plio handle
char	plname[SZ_PATHNAME]		# name of output PLIO file
char	plhead[SZ_PLHEAD]		# plio header string
char	dmode[SZ_LINE]			# mode of plio display (zoom, etc.)

pointer pl_open()
int	clgeti()			# get int

begin
	# get the parameters
	call clgstr ("mask", plname, SZ_PATHNAME)
	call clgstr("disp_mode", dmode, SZ_LINE)
	ncols = clgeti("ncols")
	nrows = clgeti("nrows")

	# add the pixel mask extension
	call addextname(plname, EXT_PL, SZ_PATHNAME)

	# get the plio display limits
	call get_plims(dmode, x1, x2, y1, y2)

	# open the mask
	pl = pl_open (NULL)
	# use this file as the mask
	call pl_loadf(pl, plname, plhead, SZ_PLHEAD)

	# display the title
	call disp_plhead(plhead)

	# disp the PLIO file
	call rg_pldisp(pl, ncols, nrows, x1, x2, y1, y2)

	# close mask
	call pl_close (pl)
end

