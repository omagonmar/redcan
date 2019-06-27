#$Header: /home/pros/xray/lib/scan/RCS/scplio.x,v 11.0 1997/11/06 16:23:41 prosb Exp $
#$Log: scplio.x,v $
#Revision 11.0  1997/11/06 16:23:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:03  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:16  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:11:09  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:19  pros
#General Release 1.0
#
#
#
# Module:	scplio.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Conversion between IRAF plio format and scan list array
# Includes:	sc_sltopm(), sc_sltopl()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include <pmset.h>	# also loads <plset.h>
include	<scset.h>
define B_DEPTH	27

#
# Function:	sc_sltopm
# Purpose:	Create and return an IRAF pm equivalent to the scan list array
# Parameters:	See argument declarations
# Uses:		pm_newmask(), pm_gsize(), pm_close(), pm_plri() in plio library
# Uses:		sc_glri() in scget.x
# Returns:	handle to open pmio pixel mask
# Exceptions:	Given dimensions cannot be greater than those of opened image.
# Method:	Convert each scan line to a range list with sc_glri and call
#		pm_plri to install it in the pm.
# Notes:	Scan list array is neither freed nor cleared by this routine.
#
pointer procedure sc_sltopm ( im, scan, width, height )

pointer im			# i: open IRAF image handle
int	width, height		# i: dimensions of scan list array image
pointer	scan[height]		# i: scan list array

pointer	pm			# o: handle for pm
pointer	ranges			# l: line coded as runlist for rg_plpi()
pointer	sp			# l: stack pointer
int	v[PL_MAXDIM]		# l: array of axis starting index
int	y			# l: line counter

int	sc_glri()
pointer	pm_newmask()

begin
	call smark (sp)
	# open a new mask for the image
	pm = pm_newmask (im, B_DEPTH)
	# initialize all dimensions to start at 1
	call amovki (1, v, PL_MAXDIM)
	# allocate longest possible rangelist
	call salloc (ranges, RL_MAXLEN(pm), TY_INT)
	# set line width parameter, one run per line
	RLI_AXLEN(ranges) = width
	# go through the scan list array, line by line
	do y = 1, height {
	    # if there are scans on this line and they produce a good rangelist
	    if( (scan[y] != SCNULL) &&
		(sc_glri(scan[y], Memi[ranges]) > 0) ) {
		# copy rangelist into pl
		v[2] = y
		call pm_plri (pm, v, Memi[ranges], B_DEPTH, width, PIX_SRC)
	    }
	}
	call sfree (sp)
	return( pm )
end

#
# Function:	sc_sltopl
# Purpose:	Create and return an IRAF pl equivalent to the scan list array
# Parameters:	See argument declarations
# Uses:		pl_create(), pl_plri() in plio library
# Uses:		sc_glri() in scget.x
# Returns:	handle to open plio pixel list
# Exceptions:	
# Method:	Convert each scan line to a range list with sc_glri and call
#		pl_plri to install it in the pl.
# Notes:	Scan list array is neither freed nor cleared by this routine.
#
pointer procedure sc_sltopl ( scan, width, height )

int	width, height		# i: dimensions of scan list array image
pointer	scan[height]		# i: scan list array

pointer	pl			# o: handle for pl
pointer	ranges			# l: line coded as runlist for rg_plpi()
pointer	sp			# l: stack pointer
int	axlen[PL_MAXDIM]	# l: dimensions as returned by pl_gsize()
int	v[PL_MAXDIM]		# l: array of axis starting index
int	y			# l: line counter

int	sc_glri()
pointer pl_create()

begin
	call smark (sp)
	# get the image size
	axlen[1] = width
	axlen[2] = height
	pl = pl_create (2, axlen, B_DEPTH)
	# initialize all dimensions to start at 1
	call amovki (1, v, PL_MAXDIM)
	# allocate longest possible rangelist
	call salloc (ranges, RL_MAXLEN(pl), TY_INT)
	# set line width parameter, one run per line
	RLI_AXLEN(ranges) = width
	# go through the scan list array, line by line
	do y = 1, height {
	    # if there are scans on this line and they produce a good rangelist
	    if( (scan[y] != SCNULL) &&
		(sc_glri(scan[y], Memi[ranges]) > 0) ) {
		# copy rangelist into pl
		v[2] = y
		call pl_plri (pl, v, Memi[ranges], B_DEPTH, width, PIX_SRC)
	    }
	}
	call sfree (sp)
	return( pl )
end

