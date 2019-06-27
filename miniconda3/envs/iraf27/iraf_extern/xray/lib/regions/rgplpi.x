#$Header: /home/pros/xray/lib/regions/RCS/rgplpi.x,v 11.0 1997/11/06 16:19:20 prosb Exp $
#$Log: rgplpi.x,v $
#Revision 11.0  1997/11/06 16:19:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:16  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:39:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:32  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:32  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:16:11  pros
#General Release 1.0
#
# ----------------------------------------------------------------------------
#
# Module:	rgplpi
# Project:	PROS -- ROSAT RSDC
# Purpose:	Apply a range-list format line to a pixel list mask
# Procedure:	rg_plpi()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Michael VanHilst -- initial version -- 2 December 1988
#		{2} MVH -- removed case of clearing empty line - 12 Oct 1989
#		{n} <who> -- <does what> -- <when>
#
#------------------------------------------------------------------------------

include <pmset.h>
include "rgset.h"

########################################################################
#
# rg_plpi
#
# Given a range-list format line (see plset.h) make the requested operation
#   on a line of a pixel list or pixel mask
#
# more general pl_plri/pm_plri type function for regions allows two forms
# of paint if RGOP == RGROP, it does a pl_plri/pm_plri
#
# rgop is a code for the type of operation requestes (codes are in rgset.h)
#  RG_ROP      - 0: use PLIO's pl_plri/pm_plri with rop
#  RG_PAINT    - 1: set every pixel where input is non-zero to input val
#  RG_MASK     - 2: clear every pixel where input is zero
#  RG_ERASE    - 3: clear every pixel where input is non-zero
#  RG_VALUE    - 4: set every pixel where input is non-zero to value in rop
#  RG_SURROUND - 5: set every pixel where input is zero to value in rop
# rop is val for value/surround, or the PLIO code used by RG_ROP
# pltype specifies whether handle is pl or pm
#
# Input: handle of pm or pl file (as per pltype) open for writing
# Input: array of axis starting indeces (v[2] gives line number)
# Input: range list with pixel list details for this line
# Input: int scratch buffer as long as line width (not used with RG_ROP)
# Input: depth of mask in bits (e.g. 16)
# Input: width of line in pixels
# Input: paint operator code (see rgset.h)
# Input: PLIO raster operator code, if ROP specified by RGOP
# Input: code to write pm instead of pl (1=pm, else pl)
#
########################################################################

procedure rg_plpi ( pl, v, line, buf, depth, width, rgop, rop, pltype )

pointer	pl			# i: handle for open pl or pm
int	v[PL_MAXDIM]		# i: array of axis starting index
int	line[RL_LENELEM,ARB]	# i: pl_plri suitable rangelist line
int	buf[width]		# i: line buffer (saves alloc'ing each line) 
int	depth, width		# i: line width and depth in bits
int	rgop			# i: rg paint operator
int	rop			# i: rop function - RG_ROP, val - RG_VALUE
int	pltype			# i: code to select between pl and pm

int	cnt			# l: count of entries in range list
int	rangex, rangeend	# l: x coords of limits of one range entry
int	i, j			# l: loop counters
int	func, val		# l: internal function identifier, val

bool	pl_linenotempty(), pm_linenotempty()

begin
	# some cases reduce to variants of other cases
	if( rgop == RG_MASK ) {
	    func = RG_SURROUND
	    val = 0
	} else if( rgop == RG_ERASE ) {
	    func = RG_VALUE
	    val = 0
	} else {
	    func = rgop
	    val = rop
	}
	# for pm type output
	if( pltype == 1 ) {
	    switch( func ) {
	    case RG_ROP:
		# simple rop function request
		call pm_plri (pl, v, line, depth, width, rop)
		return
	    case RG_PAINT:
		# check for no new ranges
		cnt = RL_LEN(line)
		if( cnt < 2 ) return
		# check for no old ranges
		if( pm_linenotempty(pl,v) ) {
		    # get a pixel list
		    call pm_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    do j = 2, cnt {
			rangex = RL_X(line,j)
			rangeend = rangex + RL_N(line,j) - 1
			val = RL_V(line,j)
			do i = rangex, rangeend
			    buf[i] = val
		    }
		    # replace original line
		    call pm_plpi (pl, v, buf, depth, width, PIX_SRC)
		} else {
		    call pm_plri (pl, v, line, depth, width, PIX_SRC)
		} 
	    case RG_VALUE:
		# check for no new ranges
		cnt = RL_LEN(line)
		if (cnt < 2) return
		# check for no old ranges
		if( pm_linenotempty(pl,v) ) {
		    # get a pixel list
		    call pm_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    do j = 2, cnt {
			rangex = RL_X(line,j)
			rangeend = rangex + RL_N(line,j) - 1
			do i = rangex, rangeend
			    buf[i] = val
		    }
		    # replace original line
		    call pm_plpi (pl, v, buf, depth, width, PIX_SRC)
		} else {		# empty mask line
		    # replace all range values with given value
		    if( val != 0 ) {
			do i = 2, cnt {
			    buf[i] = RL_V(line,i)
			    RL_V(line,i) = val
			}
			call pm_plri (pl, v, line, depth, width, PIX_SRC)
			# restore original range values
			do i = 2, cnt
			    RL_V(line,i) = buf[i]
		    }
		}
	    case RG_SURROUND:
		# check for no new ranges
		cnt = RL_LEN(line)
		if( cnt < 2 ) {
		    if( val == 0 ) {
			call pm_plri (pl, v, line, depth, width, PIX_CLR)
		    } else {
			call amovi (line, buf, RL_LENELEM+RL_LENELEM)
			RL_LEN(line) = 2
			RL_X(line,2) = 1
			RL_N(line,2) = width
			RL_V(line,2) = val
			call pm_plri (pl, v, line, depth, width, PIX_SRC)
			call amovi (buf, line, RL_LENELEM+RL_LENELEM)
		    }
		} else {
		    # get a pixel list
		    call pm_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    rangex = 1
		    do j = 2, cnt {
			rangeend = RL_X(line,j)
			if (rangeend > rangex) {
			    do i = rangex, rangeend
				buf[i] = val
			}
			rangex = rangeend + RL_N(line,j) - 1
		    }
		    if( width > rangex ) {
			do i = rangex, width
			    buf[i] = val
		    }
		    # replace original line
		    call pm_plpi (pl, v, buf, depth, width, PIX_SRC)
		}
	    }
	# for pl type output
	} else {
	    switch( func ) {
	    case RG_ROP:
		# simple rop function request
		call pl_plri (pl, v, line, depth, width, rop)
		return
	    case RG_PAINT:
		# check for no new ranges
		cnt = RL_LEN(line)
		if( cnt < 2 ) return
		# check for no old ranges
		if( pl_linenotempty(pl,v) ) {
		    # get a pixel list
		    call pl_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    do j = 2, cnt {
			rangex = RL_X(line,j)
			rangeend = rangex + RL_N(line,j) - 1
			val = RL_V(line,j)
			do i = rangex, rangeend
			    buf[i] = val
		    }
		    # replace original line
		    call pl_plpi (pl, v, buf, depth, width, PIX_SRC)
		} else {
		    call pl_plri (pl, v, line, depth, width, PIX_SRC)
		} 
	    case RG_VALUE:
		# check for no new ranges
		cnt = RL_LEN(line)
		if (cnt < 2) return
		# check for no old ranges
		if( pl_linenotempty(pl,v) ) {
		    # get a pixel list
		    call pl_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    do j = 2, cnt {
			rangex = RL_X(line,j)
			rangeend = rangex + RL_N(line,j) - 1
			do i = rangex, rangeend
			    buf[i] = val
		    }
		    # replace original line
		    call pl_plpi (pl, v, buf, depth, width, PIX_SRC)
		} else {		# empty mask line
		    # replace all range values with given value
		    if( val != 0 ) {
			do i = 2, cnt {
			    buf[i] = RL_V(line,i)
			    RL_V(line,i) = val
			}
			call pl_plri (pl, v, line, depth, width, PIX_SRC)
			# restore original range values
			do i = 2, cnt
			    RL_V(line,i) = buf[i]
		    }
		}
	    case RG_SURROUND:
		# check for no new ranges
		cnt = RL_LEN(line)
		if( cnt < 2 ) {
		    if( val == 0 ) {
			call pl_plri (pl, v, line, depth, width, PIX_CLR)
		    } else {
			call amovi (line, buf, RL_LENELEM+RL_LENELEM)
			RL_LEN(line) = 2
			RL_X(line,2) = 1
			RL_N(line,2) = width
			RL_V(line,2) = val
			call pl_plri (pl, v, line, depth, width, PIX_SRC)
			call amovi (buf, line, RL_LENELEM+RL_LENELEM)
		    }
		} else {
		    # get a pixel list
		    call pl_glpi (pl, v, buf, depth, width, 0)
		    # add in new ranges
		    rangex = 1
		    do j = 2, cnt {
			rangeend = RL_X(line,j)
			if (rangeend > rangex) {
			    do i = rangex, rangeend
				buf[i] = val
			}
			rangex = rangeend + RL_N(line,j) - 1
		    }
		    if( width > rangex ) {
			do i = rangex, width
			    buf[i] = val
		    }
		    # replace original line
		    call pl_plpi (pl, v, buf, depth, width, PIX_SRC)
		}
	    }
	}
end


