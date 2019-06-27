#$Header: /home/pros/xray/lib/scan/RCS/scget.x,v 11.0 1997/11/06 16:23:35 prosb Exp $
#$Log: scget.x,v $
#Revision 11.0  1997/11/06 16:23:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:53  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:11:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:54:02  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:04  pros
#General Release 1.0
#
#
#
# Module:	scget.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Get other kinds of lists based on scan lists
# Includes:	sc_glri(), sc_glpl(), sc_vallims()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include <plset.h>
include	<scset.h>

#
# Function:	sc_glri
# Purpose:	Fill in range list to correspond to given scan list
# Parameters:	See argument declarations
# Called by:	sc_sltopm() and sc_sltopl() in scplio.x
# Returns:	number of scans installed as ranges
# Pre-cond:	Range list space already allocated up to maximum size.  Range
# 		list header RLI_AXLEN already set.
# Post-cond:	Range list filled, ready to be passed to a plio library call.
# Exceptions:	Scans with range or value less than 1 are not converted
# Method:	Fill in appropriate values in range list array.
# Notes:	No check is made of integrity of scan list.
#
int procedure sc_glri ( scan, ranges )

pointer	scan			# i: base of scanlist
int	ranges[RL_LENELEM,ARB]	# i,o: scratch runlist line

pointer	edge			# l: pointer to scanlist link
int	range			# l: range dimension of a single scan
int	index			# l: counter of ranges

begin
	edge = scan
	index = 1
	while( edge != SCNULL ) {
	    range = SC_X(SC_NEXT(edge)) - SC_X(edge)
	    if( (range > 0) && (SC_VAL(edge) > 0) ) {
		index = index + 1
		RL_X(ranges,index) = SC_X(edge)
		RL_N(ranges,index) = range
		RL_V(ranges,index) = SC_VAL(edge)
	    }
	    edge = SC_NEXT(SC_NEXT(edge))
	}
	RL_LEN(ranges) = index
	return( index - 1 )
end

#
# Function:	sc_glpl
# Purpose:	Fill in pixel list to correspond to given scan list
# Parameters:	See argument declarations
# Called by:	sc_disp() in scdisp.x
# Pre-cond:	Pixel list space already allocated.
# Post-cond:	Pixel list filled.
# Method:	Fill in appropriate values in pixel list array.
# Notes:	No check is made of integrity of scan list.
#
procedure sc_glpl ( scan, list, width )

pointer	scan		# i: base of scanlist
int	width		# i: length of pixel line
long	list[width]	# i: scratch runlist line

long	val		# l: value associated with a scan
pointer	edge		# l: pointer to scanlist link
int	i		# l: pixel index

begin
	call aclrl (list, width)
	edge = scan
	while( edge != SCNULL ) {
	    val = SC_VAL(edge)
	    do i = SC_X(edge), SC_X(SC_NEXT(edge)) - 1 {
		list[i] = val
	    }
	    edge = SC_NEXT(SC_NEXT(edge))
	}
end

#
# Function:	sc_vallims
# Purpose:	Determine the minimum and maximum values in the scan list array
# Parameters:	See argument declarations
# Called by:	sc_dispparams() in scdisp.x
# Post-cond:	minval and maxval are set to the minimum and maximum values
# Exceptions:	Assumes no negative numbers.
# Method:	
# Notes:	Does not check inteegrity of scan list array.
#
procedure sc_vallims ( scan, height, minval, maxval )

int	height		# i: length of scan list array
pointer	scan[height]	# i: scan list array
int	minval, maxval	# o: where minimum and maximum will be placed

pointer	edge		# l: scan list edge pointer
int	y		# l: line counter
int	val		# l: val of current scan

begin
	# a value greater than 2**27, a value less than 0
	minval = 200000000
	maxval = -1
	do y = 1, height {
	    edge = scan[y]
	    while( edge != SCNULL ) {
		val = SC_VAL(edge)
		if( val < minval ) minval = val
		if( val > maxval ) maxval = val
		edge = SC_NEXT(SC_NEXT(edge))
	    }
	}
end


