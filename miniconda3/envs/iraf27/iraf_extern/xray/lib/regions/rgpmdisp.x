#$Header: /home/pros/xray/lib/regions/RCS/rgpmdisp.x,v 11.0 1997/11/06 16:19:21 prosb Exp $
#$Log: rgpmdisp.x,v $
#Revision 11.0  1997/11/06 16:19:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:19  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:14  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:33  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:33  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:14  pros
#General Release 1.0
#
#
# Module:	RGPMDISP.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	draw the pl mask regions on a character terminal
# Includes:	rg_pmdisp(), rg_pmvallims()
# Description:	Two routines like their pl counterparts but with pm names.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	2 December 1988	initial version
#		{1} MVH	18 March 1989	Use newer rg_pldisp and rg_plvallims.
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

#
# Function:	rg_pmdisp
# Purpose:	draw the pl mask regions on a character terminal
# Parameters:	See argument declarations
# Returns:	-
# Uses:		rg_lndisp(), rg_digits() below
# Pre-state:	pl (or pm) handle opened on mask with regions
# Post-state:	no change
# Exceptions:
# Method:	Just call the equivalent pl routine.
# Notes:	Display is subsampled to fit on given terminal size.
# Notes:	If x1 is -1, full width is used; if x1 is 0, the non-zero width
#		is used; if x1 is >0, the subsection from x1 to x2 is used.
#		If y1 is -1, full height is used, if 0 non-zero height is used;
#		if y1 is >0, the subsection from y1 to y2 is used.
#
procedure rg_pmdisp ( pm, cols, rows, x1, x2, y1, y2 )

pointer pm		# i: handle for pl access
int	cols		# i: number of columns in display
int	rows		# i: number of rows to use for display
int	x1, x2		# i: subsection specified or as per code in x1
int	y1, y2		# i: subsection specified or as per code in y1

begin
	call rg_pldisp (pm, cols, rows, x1, x2, y1, y2)
end

#
# Function:	rg_pmvallims
# Purpose:	Get the minimum and maximum region values
# Parameters:	See argument declarations
# Uses:		rg_plvallims() in rgpllims.x
# Pre-state:	open pm handle
# Post-state:	vmin and vmax set to minimum and maximum region ID respectively
# Method:	Read a mask line by line as range lists, calling rg_vallim
#		for each line to update the vmin and vmax.
#
procedure rg_pmvallims ( pm, vmin, vmax )

pointer	pm		# i: handle to open pixel list
int	vmin, vmax	# o: where minimum and maximum will be placed

begin
	call rg_plvallims (pm, vmin, vmax)
end
