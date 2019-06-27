#$Header: /home/pros/xray/lib/regions/RCS/rgareas.x,v 11.0 1997/11/06 16:19:08 prosb Exp $
#$Log: rgareas.x,v $
#Revision 11.0  1997/11/06 16:19:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:22  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:36  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:01  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:20:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:12  pros
#General Release 1.0
#
#
# Module:	RGAREA.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Calculate the areas of all regions in the mask
# Includes:	rg_areas(), rgln_areas()
# Description:	Return the number of regions and a Meml array with their areas
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	6 March 1989		initial version
#		{n} <who> -- <when> -- <does what>
#

include <plset.h>
# limit allowable region identifiers to the range from 1 to RGLIMIT
define RGLIMIT 65535

#
# Function:	rg_areas
# Purpose:	Get the areas of the regions in a mask.
# Parameters:	See argument declarations
# Uses:		rgln_areas() below
# Pre-state:	open pl handle
# Post-state:	areas set to pointer of malloc'd array with areas, cnt set to
#		highest region value (and length of array)
# Exceptions:	Mask must not contain values higher than RGLIMIT
# Method:	Read a mask line by line as range lists, adding the length
#		of each range to the appropriate array bin for its region val.
#		The region value is also checked to update the max region val.
# Note:		It is up to the calling routine to mfree the areas array.
#
procedure rg_areas ( pl, areas, cnt )

pointer	pl		# i: handle to open pixel list
pointer areas		# o: pointer to get alloc'd Meml array with areas
int	cnt		# o: int with number of regions in areas array

long	vmax			# l: maximum value in the pl
long	axlen[PL_MAXDIM]	# l: length of each exis (PL_MAXDIM is 7)
long	v[PL_MAXDIM]		# l: starting index in each axis
pointer	sp			# l: stack pointer
pointer rl_out			# l: buffer for line range-list
int	depth			# l: depth of mask (from pl_gsize)
int	naxes			# l: number of axes used
int	i			# l: loop counter

bool	pl_linenotempty()
errchk	rgln_areas

begin
	# get the dimensions of the mask
	call pl_gsize (pl, naxes, axlen, depth)
# depth check is optional alternative to value check currently used
#	if( depth > 16 )
#	    call error (0, "region array with depth greater than 16")
	call calloc (areas, RGLIMIT, TY_LONG)
	call amovkl (1, v, PL_MAXDIM)
	call smark (sp)
	call salloc (rl_out, RL_MAXLEN(pl), TY_LONG)
	# make min a value greater than 2**27, make max a value less than 0
	vmax = -1
	do i = 1, axlen[2]
	    {
	    v[2] = i
	    if( pl_linenotempty(pl, v) )
		{
		call pl_glrl (pl, v, Meml[rl_out], depth, axlen[1], 0)
		call rgln_areas (Meml[rl_out], Meml[areas], vmax, RGLIMIT)
		}
	    }
	call sfree (sp)
	# use max region ID as number of regions
	cnt = vmax
	call realloc (areas, vmax, TY_LONG)
end

#
# Function:	rgln_areas
# Purpose:	Add areas of region scans on one line to existing area array.
# Parameters:	See argument declarations
# Pre-state:	Allocated, initialized, (and partially filled) array of areas,
#		pl line read into a range list.
# Post-state:	Entries in the area array updated for this line, vmax
#		increased if region found with higher value.
# Exceptions:	Mask must not contain values higher than rlimit.
# Method:	Each range scan entry gives its region value and length in
#		pixels.
#
procedure rgln_areas ( rl, areas, vmax, rlimit )

long	rl[3,ARB]	# i: the rangelist
long	areas[ARB]	# i:o: array where areas are stored
long	vmax		# i:o: current min and max
long	rlimit		# i: largest value allowed for allocated areas array

long	val		# l: region value
int	i		# l: loop counter

begin
	# if there are no region runs, return
	if( RL_LEN(rl) < RL_FIRST )
	    return
	# get first run with a nonzero value (presumably the first run)
	do i = RL_FIRST, RL_LEN(rl)
	    {
	    val = RL_V(rl,i)
	    # only process positive regions (presumably plio gives no other)
	    if( val > 0 )
		{
		# error if region value exceeds that allowed
		if( val > rlimit )
		    call error(0, "region val greater than allowed")
		# check for max update
		if( val > vmax )
		    vmax = val
		# add range to area of its region
		areas[val] = areas[val] + RL_N(rl,i) 
		}
	    }
end
