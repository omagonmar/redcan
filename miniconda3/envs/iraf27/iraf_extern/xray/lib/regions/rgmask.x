#$Header: /home/pros/xray/lib/regions/RCS/rgmask.x,v 11.0 1997/11/06 16:19:15 prosb Exp $
#$Log: rgmask.x,v $
#Revision 11.0  1997/11/06 16:19:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:44:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:51  prosb
#General Release 2.2
#
#Revision 5.1  93/02/13  21:39:27  dennis
#*** empty log message ***
#
#Revision 5.0  92/10/29  21:14:19  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:21:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:06:28  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:15:44  pros
#General Release 1.0
#
#
# Module:	RGMASK.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Make a pixel mask stencil or stenciled region filter
# Includes:	rg_mask(), rg_()
# Description:	Routines to support rg_mask().  rg_mask takes an exposure
#		mask and a threshold and makes a stencil (good pixel list)
#		from those pixels in the exposure mask which mask value equals
#		or exceeds the threshold value.  If a region mask is given, a
#		new region mask is made by filtering the region mask through
#		the stencil, and returned.  If no region mask is given, the
#		stencil is returned.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	28 November 1988	initial version
#		{n} <who> -- <when> -- <does what>
#

include	<plset.h>
include	<pmset.h>

#
# Function:	rg_pmmask
# Purpose:	Clip an exposure mask at threshold and make a boolean stencil.
#		If a region mask is given, stencil it and return the result
#		in place of the boolean stencil.
# Parameters:	See argument declarations
# Returns:	handle for a pm of the stencil or a stenciled region mask.
# Uses:		rg_pmset(), rg_pmcopy(), rg_pmonemask(), rg_pmtwomask() below
# Post-state:	Passed masks are unchanged.
# Exceptions:	An actual mask must be given for the exposure mask.
#
pointer procedure rg_pmmask ( expmask, regmask, threshold )
pointer	expmask		# pm of image file exposure mask
pointer	regmask		# pm of image filtering region mask (optional)
int	threshold	# threshold of acceptable exposure values

pointer	pm
int	edepth, rdepth
int	eaxes, raxes 
int	eaxlen[PM_MAXDIM], raxlen[PM_MAXDIM]

pointer	pm_newcopy()

begin
	# check for missing input
	if (expmask == 0) {
	    call error (1, "no exposure mask given")
	}
	
	# get dimensions of exposure mask
	call pm_gsize (expmask, eaxes, eaxlen, edepth)
	# if no region mask, just create a boolean mask
	if (regmask == 0) {
	    # open the mask which will be returned
	    pm = pm_newcopy (expmask)
	    # call routine to do the job
	    if (threshold <= 0) {
		call rg_pmset ( pm, 1 )
	    } else {
		call rg_pmonemask (expmask, pm, threshold,
				 edepth, eaxlen[1], eaxlen[2])
	    }
	# if region mask is also given, stencil it by the exposure mask
	} else {
	    # get dimensions of the region mask
	    call pm_gsize (regmask, raxes, raxlen, rdepth)
	    # masks must have the same x and y dimensions
	    if ((raxes < 2) || 
		(eaxlen[1] != raxlen[1]) ||
		(eaxlen[2] != raxlen[2])) {
		call error (1, "mask and region sizes don't match")
	    } else {
		# open the mask which will be returned
		pm = pm_newcopy (regmask)
		if (threshold <= 0) {
		    call rg_pmcopy (pm, regmask)
		} else {
		    # call routine to clip and stencil in one pass
		    call rg_pmtwomask (expmask, regmask, pm, threshold,
				     rdepth, eaxlen[1], eaxlen[2])
		}
	    }
	}
	return (pm)
end

# rg_pmonemask
# create boolean stencil mask given exposure mask and a threshold level
procedure rg_pmonemask ( expmask, pm, threshold, depth, width, height )
pointer	expmask
pointer pm
int	threshold
int	depth
int	width, height

pointer	sp
pointer rlbuf
int	i
int	v[PM_MAXDIM]

bool	pm_linenotempty()
int	rg_clip()

begin
	call smark (sp)
	# set subsection to full region
	call amovki (1, v, PM_MAXDIM)
	# allocate line rangelist buffer
	call salloc (rlbuf, width * RL_LENELEM, TY_INT)
	do i = 1, height {
	    v[2] = i
	    if (pm_linenotempty (expmask, v)) {
		# get a range list of this line
		call pm_glri (expmask, v, Memi[rlbuf], depth, width, 0)
		# if there are any ranges left after clipping, put them in pm
		if (rg_clip (Memi[rlbuf], threshold) > 1) {
		    call pm_plri (pm, v, Memi[rlbuf], depth, width, 0)
		}
	    }
	}
	call sfree (sp)
end

# rg_pmtwomask
# stencil region mask by threshold-clipped exposure mask, putting result in pm
procedure rg_pmtwomask ( expmask, regmask, pm, threshold, depth, width, height )
pointer	expmask
pointer	regmask
pointer pm
int	threshold
int	depth
int	width, height

pointer	sp
pointer	ebuf, rbuf, obuf
int	i
int	good			# number of ranges passed by stencil
int	v[PM_MAXDIM]
bool	pm_linenotempty()
int	rg_clip()
int	rg_stencil()
begin
	call smark (sp)
	# set subsection to full region
	call amovki (1, v, PM_MAXDIM)
	# allocate two line rangelist buffers
	call salloc (ebuf, width * RL_LENELEM, TY_INT)
	call salloc (rbuf, width * RL_LENELEM, TY_INT)
	call salloc (obuf, width * RL_LENELEM, TY_INT)
	RLI_AXLEN[obuf] = width
	# do one line at a time
	do i = 1, height {
	    v[2] = i
	    # only if both masks have info can we have something to write
	    if (pm_linenotempty(expmask,v) && pm_linenotempty(regmask,v)) {
		# get exposure mask line range list
		call pm_glri (expmask, v, Memi[ebuf], depth, width, 0)
		# if exposure mask still has ranges after clipping
		if (rg_clip(Memi[ebuf], threshold) > 1) {
		    # get the region mask line range list
		    call pm_glri (regmask, v, Memi[rbuf], depth, width, 0)
		    good = rg_stencil (Memi[ebuf], Memi[rbuf], Memi[obuf])
		    # if region ranges were left after stenciling, write to pm
		    if (good > 1) {
			RLI_LEN[obuf] = good
			call pm_plri (pm, v, Memi[obuf], depth, width, 0)
		    }
		}
	    }
	}
	call sfree(sp)
end

# rg_pmcopy
# copy full contents of one pm into another
procedure rg_pmcopy ( dst, src )
pointer	dst
pointer src

int	depth
int	axes
int	axlen[PM_MAXDIM]
int	v[PM_MAXDIM]

begin
	# set subsection to full region
	call amovki (1, v, PM_MAXDIM)
	call pm_gsize (src, axes, axlen, depth)
	call pm_rop (src, v, dst, v, axlen, PIX_SRC)
end

# rg_pmset
# make opaque mask of given value
procedure rg_pmset ( dst, value )
pointer	dst
int	value

int	i
int	depth
int	axes
int	axlen[PM_MAXDIM]
int	v[PM_MAXDIM]
int	linebuf[RL_LENELEM,3]

begin
	# set subsection to full region
	call amovki (1, v, PM_MAXDIM)
	call pm_gsize (dst, axes, axlen, depth)

	# PIX_VALUE does not work in the current PLIO
	# call pm_rop (dst, v, dst, v, axlen, PIX_VALUE(value))

	RL_AXLEN[linebuf] = axlen[1]
	RL_LEN[linebuf] = 2
	RL_X[linebuf,2] = 1
	RL_N[linebuf,2] = axlen[1]
	RL_V[linebuf,2] = 1
	do i = 1, axlen[2] {
	    v[2] = i
	    call pm_plri (dst, v, linebuf, depth, axlen[1], 0)
	}
end

#
# Function:	rg_plmask
# Purpose:	Clip an exposure mask at threshold and make a boolean stencil.
#		If a region mask is given, stencil it and return the result
#		in place of the boolean stencil.
# Parameters:	See argument declarations
# Returns:	handle for a pl of the stencil or a stenciled region mask.
# Uses:		rg_plset(), rg_plcopy(), rg_plonemask(), rg_pltwomask() below
# Post-state:	Passed masks are unchanged.
# Exceptions:	An actual mask must be given for the exposure mask.
#
pointer procedure rg_plmask ( expmask, regmask, threshold )
pointer	expmask		# pl of image file exposure mask
pointer	regmask		# pl of image filtering region mask (optional)
int	threshold	# threshold of acceptable exposure values

pointer	pl
int	edepth, rdepth
int	eaxes, raxes 
int	eaxlen[PL_MAXDIM], raxlen[PL_MAXDIM]

pointer	pl_newcopy()

begin
	# check for missing input
	if (expmask == 0) {
	    call error (1, "no exposure mask given")
	}
	
	# get dimensions of exposure mask
	call pl_gsize (expmask, eaxes, eaxlen, edepth)
	# if no region mask, just create a boolean mask
	if (regmask == 0) {
	    # open the mask which will be returned
	    pl = pl_newcopy (expmask)
	    # call routine to do the job
	    if (threshold <= 0) {
		call rg_plset ( pl, 1 )
	    } else {
		call rg_plonemask (expmask, pl, threshold,
				 edepth, eaxlen[1], eaxlen[2])
	    }
	# if region mask is also given, stencil it by the exposure mask
	} else {
	    # get dimensions of the region mask
	    call pl_gsize (regmask, raxes, raxlen, rdepth)
	    # masks must have the same x and y dimensions
	    if ((raxes < 2) || 
		(eaxlen[1] != raxlen[1]) ||
		(eaxlen[2] != raxlen[2])) {
		call error (1, "mask and region sizes don't match")
	    } else {
		# open the mask which will be returned
		pl = pl_newcopy (regmask)
		if (threshold <= 0) {
		    call rg_plcopy (pl, regmask)
		} else {
		    # call routine to clip and stencil in one pass
		    call rg_pltwomask (expmask, regmask, pl, threshold,
				     rdepth, eaxlen[1], eaxlen[2])
		}
	    }
	}
	return (pl)
end


# rg_plonemask
# create boolean stencil mask given exposure mask and a threshold level
procedure rg_plonemask ( expmask, pl, threshold, depth, width, height )
pointer	expmask
pointer pl
int	threshold
int	depth
int	width, height

pointer	sp
pointer rlbuf
int	i
int	v[PL_MAXDIM]

bool	pl_linenotempty()
int	rg_clip()

begin
	call smark (sp)
	# set subsection to full region
	call amovki (1, v, PL_MAXDIM)
	# allocate line rangelist buffer
	call salloc (rlbuf, width * RL_LENELEM, TY_INT)
	do i = 1, height {
	    v[2] = i
	    if (pl_linenotempty (expmask, v)) {
		# get a range list of this line
		call pl_glri (expmask, v, Memi[rlbuf], depth, width, 0)
		# if there are any ranges left after clipping, put them in pl
		if (rg_clip (Memi[rlbuf], threshold) > 1) {
		    call pl_plri (pl, v, Memi[rlbuf], depth, width, 0)
		}
	    }
	}
	call sfree (sp)
end


# rg_pltwomask
# stencil region mask by threshold-clipped exposure mask, putting result in pl
procedure rg_pltwomask ( expmask, regmask, pl, threshold, depth, width, height )
pointer	expmask
pointer	regmask
pointer pl
int	threshold
int	depth
int	width, height

pointer	sp
pointer	ebuf, rbuf, obuf
int	i
int	good			# number of ranges passed by stencil
int	v[PL_MAXDIM]
bool	pl_linenotempty()
int	rg_clip()
int	rg_stencil()
begin
	call smark (sp)
	# set subsection to full region
	call amovki (1, v, PL_MAXDIM)
	# allocate two line rangelist buffers
	call salloc (ebuf, width * RL_LENELEM, TY_INT)
	call salloc (rbuf, width * RL_LENELEM, TY_INT)
	call salloc (obuf, width * RL_LENELEM, TY_INT)
	RLI_AXLEN[obuf] = width
	# do one line at a time
	do i = 1, height {
	    v[2] = i
	    # only if both masks have info can we have something to write
	    if (pl_linenotempty(expmask,v) && pl_linenotempty(regmask,v)) {
		# get exposure mask line range list
		call pl_glri (expmask, v, Memi[ebuf], depth, width, 0)
		# if exposure mask still has ranges after clipping
		if (rg_clip(Memi[ebuf], threshold) > 1) {
		    # get the region mask line range list
		    call pl_glri (regmask, v, Memi[rbuf], depth, width, 0)
		    good = rg_stencil (Memi[ebuf], Memi[rbuf], Memi[obuf])
		    # if region ranges were left after stenciling, write to pl
		    if (good > 1) {
			RLI_LEN[obuf] = good
			call pl_plri (pl, v, Memi[obuf], depth, width, 0)
		    }
		}
	    }
	}
	call sfree(sp)
end

# rg_plcopy
# copy full contents of one pl into another
procedure rg_plcopy ( dst, src )
pointer	dst
pointer src

int	depth
int	axes
int	axlen[PL_MAXDIM]
int	v[PL_MAXDIM]

begin
	# set subsection to full region
	call amovki (1, v, PL_MAXDIM)
	call pl_gsize (src, axes, axlen, depth)
	call pl_rop (src, v, dst, v, axlen, PIX_SRC)
end


# rg_plset
# make opaque mask of given value
procedure rg_plset ( dst, value )
pointer	dst
int	value

int	i
int	depth
int	axes
int	axlen[PL_MAXDIM]
int	v[PL_MAXDIM]
int	linebuf[RL_LENELEM,3]

begin
	# set subsection to full region
	call amovki (1, v, PL_MAXDIM)
	call pl_gsize (dst, axes, axlen, depth)

	# PIX_VALUE does not work in the current PLIO
	# call pl_rop (dst, v, dst, v, axlen, PIX_VALUE(value))

	RL_AXLEN[linebuf] = axlen[1]
	RL_LEN[linebuf] = 2
	RL_X[linebuf,2] = 1
	RL_N[linebuf,2] = axlen[1]
	RL_V[linebuf,2] = 1
	do i = 1, axlen[2] {
	    v[2] = i
	    call pl_plri (dst, v, linebuf, depth, axlen[1], 0)
	}
end


# rg_clip
# take exposure mask range line and make it boolean after clipping by threshold
int procedure rg_clip ( rline, threshold )
int	rline[RL_LENELEM,ARB]		# range list for one line
int	threshold			# accept ranges with val >= threshold

int	cnt
int	i, j
int	x, n
int	on
begin
	# how many ranges are in the line
	cnt = RL_LEN(rline)
	# set index of output (first meaningful range is 2)
	j = 1
	on = NO
	# go through original ranges
	do i = 2, cnt {
	    # if last range was accepted and still open
	    if (on == YES) {
		# look for continuation of range
		if ((RL_V(rline,i) >= threshold) && (RL_X(rline,i) == x)) {
		    # update n and x
		    x = RL_N(rline,i)
		    n = n + x
		    x = x + RL_X(rline,i)
		} else {
		    # close the current range
		    on = NO
		    RL_N(rline,j) = n
		}
	    }
	    # if there is no open range
	    if (on == NO) {
		# look for beginning of qualifying range
		if (RL_V(rline,i) >= threshold) {
		    # mark beginning of range and note n and x of end
		    j = j + 1
		    x = RL_X(rline,i)
		    RL_X(rline,j) = x
		    RL_V(rline,j) = 1
		    n = RL_N(rline,i)
		    x = x + n
		    on = YES
		}
	    }
	}
	# if last range was open and ran to the end, close it
	if (on == YES) {
	    RL_N(rline,j) = n
	}
	# set number of ranges in line
	RL_LEN(rline) = j
	# return range count (plus 1 for parameter space)
	return (j)
end


# rg_stencil
# stencil one line of the region mask, put result in region line
# return number of ranges in output (plus one)
int procedure rg_stencil ( stencil, regline, newline )
int	stencil[RL_LENELEM,ARB]
int	regline[RL_LENELEM,ARB]
int	newline[RL_LENELEM,ARB]

int	s, r, o			# range index for stencil, regline, output
int	scnt, rcnt
int	sx1, sx2, rx1, rx2
common	/rng/ sx1,sx2,rx1,rx2

int	rg_addrange()

begin
	rcnt = RL_LEN(regline)
	scnt = RL_LEN(stencil)
	o = 1
	s = 1
	# starting values to force reading on first pass
	sx1 = -1
	sx2 = -1
	do r = 2, rcnt {
	    rx1 = RL_X(regline,r)
	    rx2 = rx1 + RL_N(regline,r)
	    # advance stencil range such that its end passes start of reg range
	    while (rx1 >= sx2) {
		s = s + 1
		if (s > scnt) return (o)
		sx1 = RL_X(stencil,s)
		sx2 = sx1 + RL_N(stencil,s)
	    }
	    # if the reg range starts before the end of the mask range
	    if (rx2 > sx1) {
		while ((rx1 < sx2) &&
		       (rg_addrange (newline, o, RL_V(regline,r)) == YES)) {
		    # if stencil range does not traverse region range, try next
		    s = s + 1
		    if (s > scnt) return (o)
		    sx1 = RL_X(stencil,s)
		    sx2 = sx1 + RL_N(stencil,s)
		}
	    }
	}
	return (o)
end

# rg_addrange
# add one range at o in out range line
# return YES if stencil range fell short of end of region range
int procedure rg_addrange ( out, o, val )
int	out[RL_LENELEM,ARB]	# range list where range is to be written
int	o			# index of last written range
int	val			# value from region mask range

int	clipped
int	sx1, sx2, rx1, rx2
common	/rng/ sx1,sx2,rx1,rx2
begin
	# count all or part of this range
	o = o + 1
	RL_V(out,o) = val
	# start is later of mask or reg range start
	if (rx1 >= sx1) {
	    RL_X(out,o) = rx1
	} else {
	    RL_X(out,o) = sx1
	}
	# end is earlier of mask or reg range end
	if (rx2 <= sx2) {
	    RL_N(out,o) = rx2 - RL_X(out,o)
	    clipped = NO
	} else {
	    RL_N(out,o) = sx2 - RL_X(out,o)
	    clipped = YES
	}
	return (clipped)
end

int procedure dbrnge ()
int	sx1, sx2, rx1, rx2
common	/rng/ sx1,sx2,rx1,rx2
begin
	call printf ("sx1: %d, sx2: %d, rx1: %d, rx2: %d\n")
	    call pargi (sx1)
	    call pargi (sx2)
	    call pargi (rx1)
	    call pargi (rx2)
	call flush (STDOUT)
	return(1)
end


