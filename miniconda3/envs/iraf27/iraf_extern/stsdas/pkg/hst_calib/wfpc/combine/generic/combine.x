include	<imhdr.h>
include	<imset.h>
include	<error.h>
include	<syserr.h>
include "wpdef.h"

#--------------------------------------------------------------------11 Jun 96--
.help combine.gx Jun96 wfpc$combine
.ih
NAME
  combine - Initialize variables and call appropriate combine routine
.endhelp
#-------------------------------------------------------------------------------
# COMBINE --	Initialize variables and call appropriate combine routine. 
#		This routine is based upon the `images.imcombine' package. 
#
#  Revision history:
#	   Nov 90 by RAShaw	Development version
#	 9 Mar 93 by RAShaw	AVSIGCLIP option was producing incorrect 
#				results for group 1 when "sigma" image was 
#				undefined.  Problem traced to "npts" not 
#				being defined before call to salloc memory 
#				for "sigdata". 
#	11 Jun 96 by RAShaw	Change function name from "scale" to avoid 
#				name conflict with F90 intrinsic function. 

#$for (sirdx)

procedure combines (in, dqf, nimages, out, sigma, option, log)

include "wpcom.h"

# Calling arguments:
int		log			# Log file descriptor
pointer		in[nimages]		# IMIO pointers to data
pointer		dqf[nimages]		# IMIO pointers to Data Quality Files
int		nimages			# Number of input images
pointer		out			# Output IMIO pointer
pointer		sigma			# Sigma IMIO pointer
int		option			# Combine option

# Local variables:
bool		bit[8]			# Bit codes for DQF flags
pointer		curline			# Current line number
pointer		data 			# Line of input images
bool		doscale			# Are input images to be scaled/weighted?
pointer		dqfdata			# Line of DQF images
real		gain			# Detector gain in DN/photon
real		gscale			# Scale term in noise model (% of DN)
real		high			# High sigma cutoff
int		i, j			# Dummy loop counters
real		low			# Low sigma cutoff
int		npts			# Number of pixels per image line
pointer		oldline			# Previous line number
pointer		outdata			# Output image line
real		readnoise		# Additive term in noise model
pointer		sigdata			# Sigma image line 
pointer		sp			# Pointer to stack memory

# Functions used:
bool		clgetb()		# Fetch Boolean keyword from CL
real		clgetr()		# Fetch real keyword from CL
pointer		imgnls()		# Get Next Line
pointer		imgnli()		# Get Next Line
pointer		impnlr()		# Put Next Line
bool		scalef()		# Determines scales and weights

begin
	errchk asigclips, averages, crrejs, maxrejs, medians, 
		minrejs, mmrejs, sigclips, sums, thresholds

# Fetch user-selected DQF bits.
	bit[1] = clgetb ("rsbit")		# Reed-Solomon error
	bit[2] = clgetb ("calbit")		# Calibration file defect
	bit[3] = clgetb ("defbit")		# Permanent camera defect
	bit[4] = clgetb ("satbit")		# Saturated pixel
	bit[5] = clgetb ("misbit")		# Missing data
	bit[6] = clgetb ("genbit")		# Generic bad pixel
	bit[7] = clgetb ("crbit")		# Cosmic Ray hit
	bit[8] = false				# (unused)
	CRBIT  = 15				# Hardwired, for now

# Convert bit-coded flags to an integer.
	BADBITS = 0
	do i = 1, 8
	    if (bit[i]) BADBITS = BADBITS + 2 ** (i-1)

# Determine scale factors and weights for input images.  Note that these 
# parameters are not set for option="SUM".
	BLANK = clgetr ("blank")
	switch (option) {
	    case AVERAGE, MEDIAN, MINREJECT, MAXREJECT, MINMAXREJECT: 
		low  = 0.
		high = 0.
	    case CRREJECT: 
		low       = 0.
		high      = clgetr ("highreject")
		readnoise = clgetr ("readnoise")
		gain      = clgetr ("gain")
		gscale    = clgetr ("scalenoise") / 100.
	    case THRESHOLD: 
		low   = clgetr ("lowreject")
		high  = clgetr ("highreject")
		if (low >= high) 
		    call error (0, 
			"Bad threshold limits (lowreject >= highreject)")
	    case SIGCLIP, AVSIGCLIP: 
		low  = clgetr ("lowreject")
		high = clgetr ("highreject")
	}
	doscale = scalef (in, out, nimages, log, low, high)

####################################################################
# Allocate stack memory for local variables.
	call smark (sp)
#  Bug fix 23 Feb 93 by RAShaw: "data" is an array of TY_POINTER
#	call salloc (data, nimages, TY_REAL)
	call salloc (data, nimages, TY_POINTER)
	call salloc (dqfdata, nimages, TY_POINTER)
	call salloc (curline, IM_MAXDIM, TY_LONG)
	call salloc (oldline, IM_MAXDIM, TY_LONG)
	npts = IM_LEN(out,1)
	if (sigma == NULL) {
	    call salloc (sigdata, npts, TY_REAL)
	}

# Initialize local variables.
	call amovkl (long(1), Meml[curline], IM_MAXDIM)
	call amovkl (long(1), Meml[oldline], IM_MAXDIM)

# For each line get input image lines and combine them.  Note that, because 
# the input procedure increments the current line number (cln), the cln must 
# be copied from the previous line number for each call to impnl or imgnl.

	while (impnlr (out, outdata, Meml[curline]) != EOF) {

# Initialize the output and sigma images to zero.
#	    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
#	    j = impnlr (out, outdata, Meml[curline])
	    call aclrr (Memr[outdata], npts)
	    if (sigma != NULL) {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = impnlr (sigma, sigdata, Meml[curline])
	    }
	    call aclrr (Memr[sigdata], npts)
	    do i = 1, nimages {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = imgnls (in[i], Memi[data+i-1], Meml[curline])
		if (dqf[1] != NULL) {
		    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		    j = imgnli (dqf[i], Memi[dqfdata+i-1], Meml[curline])
		}
	    }

# Impose rejection criteria
	    if (dqf[1] != NULL) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "DQF rejection not supported for SUM")
		    case AVERAGE:
			call dqaverages (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MEDIAN:
			call dqmedians (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts)
		    case MINREJECT:
			call dqminrejs (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call dqmaxrejs (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call dqmmrejs (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case CRREJECT:
			call dqcrrejs (Memi[data], Memi[dqfdata], 
				Memr[outdata], Memr[sigdata], nimages, npts, 
				high, readnoise, gain, gscale)
		    case THRESHOLD:
			call dqthresholds (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts, low, high)
		    case SIGCLIP:
			call dqsigclips (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call dqasigclips (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		}
	    } else if (doscale) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "Weighting not supported for option: SUM")
		    case AVERAGE:
			call wtaverages (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MEDIAN:
			call scmedians (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call wtminrejs (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call wtmaxrejs (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call wtmmrejs (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call wtcrrejs (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call wtsigclips (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call wtasigclips (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call wtthresholds (Memi[data], Memr[outdata], nimages, 
				npts, low, high)
		}
	    } else {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call sums (Memi[data], Memr[outdata], nimages, npts)
		    case AVERAGE:
			call averages (Memi[data], Memr[outdata], nimages, npts)
		    case MEDIAN:
			call medians (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call minrejs (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call maxrejs (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call mmrejs (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call crrejs (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call sigclips (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, low, high)
		    case AVSIGCLIP:
			call asigclips (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call thresholds (Memi[data], Memr[outdata], nimages, 
					npts, low, high)
		}
	    }

# Calculate sigma, with weighting, if appropriate.
	    if ((sigma != NULL) && (option != CRREJECT) && (option != SUM) && 
		(option != SIGCLIP) && (option != AVSIGCLIP)) {
		if (doscale || dqf[1] != NULL) 
		    call wgtsigmas (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
		else 
		    call sigmas (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
	    }
	    call amovl (Meml[curline], Meml[oldline], IM_MAXDIM)
	}

	call sfree (sp)
	end

procedure combinei (in, dqf, nimages, out, sigma, option, log)

include "wpcom.h"

# Calling arguments:
int		log			# Log file descriptor
pointer		in[nimages]		# IMIO pointers to data
pointer		dqf[nimages]		# IMIO pointers to Data Quality Files
int		nimages			# Number of input images
pointer		out			# Output IMIO pointer
pointer		sigma			# Sigma IMIO pointer
int		option			# Combine option

# Local variables:
bool		bit[8]			# Bit codes for DQF flags
pointer		curline			# Current line number
pointer		data 			# Line of input images
bool		doscale			# Are input images to be scaled/weighted?
pointer		dqfdata			# Line of DQF images
real		gain			# Detector gain in DN/photon
real		gscale			# Scale term in noise model (% of DN)
real		high			# High sigma cutoff
int		i, j			# Dummy loop counters
real		low			# Low sigma cutoff
int		npts			# Number of pixels per image line
pointer		oldline			# Previous line number
pointer		outdata			# Output image line
real		readnoise		# Additive term in noise model
pointer		sigdata			# Sigma image line 
pointer		sp			# Pointer to stack memory

# Functions used:
bool		clgetb()		# Fetch Boolean keyword from CL
real		clgetr()		# Fetch real keyword from CL
pointer		imgnli()		# Get Next Line
pointer		impnlr()		# Put Next Line
bool		scalef()		# Determines scales and weights

begin
	errchk asigclipi, averagei, crreji, maxreji, mediani, 
		minreji, mmreji, sigclipi, sumi, thresholdi

# Fetch user-selected DQF bits.
	bit[1] = clgetb ("rsbit")		# Reed-Solomon error
	bit[2] = clgetb ("calbit")		# Calibration file defect
	bit[3] = clgetb ("defbit")		# Permanent camera defect
	bit[4] = clgetb ("satbit")		# Saturated pixel
	bit[5] = clgetb ("misbit")		# Missing data
	bit[6] = clgetb ("genbit")		# Generic bad pixel
	bit[7] = clgetb ("crbit")		# Cosmic Ray hit
	bit[8] = false				# (unused)
	CRBIT  = 15				# Hardwired, for now

# Convert bit-coded flags to an integer.
	BADBITS = 0
	do i = 1, 8
	    if (bit[i]) BADBITS = BADBITS + 2 ** (i-1)

# Determine scale factors and weights for input images.  Note that these 
# parameters are not set for option="SUM".
	BLANK = clgetr ("blank")
	switch (option) {
	    case AVERAGE, MEDIAN, MINREJECT, MAXREJECT, MINMAXREJECT: 
		low  = 0.
		high = 0.
	    case CRREJECT: 
		low       = 0.
		high      = clgetr ("highreject")
		readnoise = clgetr ("readnoise")
		gain      = clgetr ("gain")
		gscale    = clgetr ("scalenoise") / 100.
	    case THRESHOLD: 
		low   = clgetr ("lowreject")
		high  = clgetr ("highreject")
		if (low >= high) 
		    call error (0, 
			"Bad threshold limits (lowreject >= highreject)")
	    case SIGCLIP, AVSIGCLIP: 
		low  = clgetr ("lowreject")
		high = clgetr ("highreject")
	}
	doscale = scalef (in, out, nimages, log, low, high)

####################################################################
# Allocate stack memory for local variables.
	call smark (sp)
#  Bug fix 23 Feb 93 by RAShaw: "data" is an array of TY_POINTER
#	call salloc (data, nimages, TY_REAL)
	call salloc (data, nimages, TY_POINTER)
	call salloc (dqfdata, nimages, TY_POINTER)
	call salloc (curline, IM_MAXDIM, TY_LONG)
	call salloc (oldline, IM_MAXDIM, TY_LONG)
	npts = IM_LEN(out,1)
	if (sigma == NULL) {
	    call salloc (sigdata, npts, TY_REAL)
	}

# Initialize local variables.
	call amovkl (long(1), Meml[curline], IM_MAXDIM)
	call amovkl (long(1), Meml[oldline], IM_MAXDIM)

# For each line get input image lines and combine them.  Note that, because 
# the input procedure increments the current line number (cln), the cln must 
# be copied from the previous line number for each call to impnl or imgnl.

	while (impnlr (out, outdata, Meml[curline]) != EOF) {

# Initialize the output and sigma images to zero.
#	    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
#	    j = impnlr (out, outdata, Meml[curline])
	    call aclrr (Memr[outdata], npts)
	    if (sigma != NULL) {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = impnlr (sigma, sigdata, Meml[curline])
	    }
	    call aclrr (Memr[sigdata], npts)
	    do i = 1, nimages {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = imgnli (in[i], Memi[data+i-1], Meml[curline])
		if (dqf[1] != NULL) {
		    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		    j = imgnli (dqf[i], Memi[dqfdata+i-1], Meml[curline])
		}
	    }

# Impose rejection criteria
	    if (dqf[1] != NULL) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "DQF rejection not supported for SUM")
		    case AVERAGE:
			call dqaveragei (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MEDIAN:
			call dqmediani (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts)
		    case MINREJECT:
			call dqminreji (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call dqmaxreji (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call dqmmreji (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case CRREJECT:
			call dqcrreji (Memi[data], Memi[dqfdata], 
				Memr[outdata], Memr[sigdata], nimages, npts, 
				high, readnoise, gain, gscale)
		    case THRESHOLD:
			call dqthresholdi (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts, low, high)
		    case SIGCLIP:
			call dqsigclipi (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call dqasigclipi (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		}
	    } else if (doscale) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "Weighting not supported for option: SUM")
		    case AVERAGE:
			call wtaveragei (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MEDIAN:
			call scmediani (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call wtminreji (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call wtmaxreji (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call wtmmreji (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call wtcrreji (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call wtsigclipi (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call wtasigclipi (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call wtthresholdi (Memi[data], Memr[outdata], nimages, 
				npts, low, high)
		}
	    } else {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call sumi (Memi[data], Memr[outdata], nimages, npts)
		    case AVERAGE:
			call averagei (Memi[data], Memr[outdata], nimages, npts)
		    case MEDIAN:
			call mediani (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call minreji (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call maxreji (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call mmreji (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call crreji (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call sigclipi (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, low, high)
		    case AVSIGCLIP:
			call asigclipi (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call thresholdi (Memi[data], Memr[outdata], nimages, 
					npts, low, high)
		}
	    }

# Calculate sigma, with weighting, if appropriate.
	    if ((sigma != NULL) && (option != CRREJECT) && (option != SUM) && 
		(option != SIGCLIP) && (option != AVSIGCLIP)) {
		if (doscale || dqf[1] != NULL) 
		    call wgtsigmai (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
		else 
		    call sigmai (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
	    }
	    call amovl (Meml[curline], Meml[oldline], IM_MAXDIM)
	}

	call sfree (sp)
	end

procedure combinel (in, dqf, nimages, out, sigma, option, log)

include "wpcom.h"

# Calling arguments:
int		log			# Log file descriptor
pointer		in[nimages]		# IMIO pointers to data
pointer		dqf[nimages]		# IMIO pointers to Data Quality Files
int		nimages			# Number of input images
pointer		out			# Output IMIO pointer
pointer		sigma			# Sigma IMIO pointer
int		option			# Combine option

# Local variables:
bool		bit[8]			# Bit codes for DQF flags
pointer		curline			# Current line number
pointer		data 			# Line of input images
bool		doscale			# Are input images to be scaled/weighted?
pointer		dqfdata			# Line of DQF images
real		gain			# Detector gain in DN/photon
real		gscale			# Scale term in noise model (% of DN)
real		high			# High sigma cutoff
int		i, j			# Dummy loop counters
real		low			# Low sigma cutoff
int		npts			# Number of pixels per image line
pointer		oldline			# Previous line number
pointer		outdata			# Output image line
real		readnoise		# Additive term in noise model
pointer		sigdata			# Sigma image line 
pointer		sp			# Pointer to stack memory

# Functions used:
bool		clgetb()		# Fetch Boolean keyword from CL
real		clgetr()		# Fetch real keyword from CL
pointer		imgnll()		# Get Next Line
pointer		imgnli()		# Get Next Line
pointer		impnlr()		# Put Next Line
bool		scalef()		# Determines scales and weights

begin
	errchk asigclipl, averagel, crrejl, maxrejl, medianl, 
		minrejl, mmrejl, sigclipl, suml, thresholdl

# Fetch user-selected DQF bits.
	bit[1] = clgetb ("rsbit")		# Reed-Solomon error
	bit[2] = clgetb ("calbit")		# Calibration file defect
	bit[3] = clgetb ("defbit")		# Permanent camera defect
	bit[4] = clgetb ("satbit")		# Saturated pixel
	bit[5] = clgetb ("misbit")		# Missing data
	bit[6] = clgetb ("genbit")		# Generic bad pixel
	bit[7] = clgetb ("crbit")		# Cosmic Ray hit
	bit[8] = false				# (unused)
	CRBIT  = 15				# Hardwired, for now

# Convert bit-coded flags to an integer.
	BADBITS = 0
	do i = 1, 8
	    if (bit[i]) BADBITS = BADBITS + 2 ** (i-1)

# Determine scale factors and weights for input images.  Note that these 
# parameters are not set for option="SUM".
	BLANK = clgetr ("blank")
	switch (option) {
	    case AVERAGE, MEDIAN, MINREJECT, MAXREJECT, MINMAXREJECT: 
		low  = 0.
		high = 0.
	    case CRREJECT: 
		low       = 0.
		high      = clgetr ("highreject")
		readnoise = clgetr ("readnoise")
		gain      = clgetr ("gain")
		gscale    = clgetr ("scalenoise") / 100.
	    case THRESHOLD: 
		low   = clgetr ("lowreject")
		high  = clgetr ("highreject")
		if (low >= high) 
		    call error (0, 
			"Bad threshold limits (lowreject >= highreject)")
	    case SIGCLIP, AVSIGCLIP: 
		low  = clgetr ("lowreject")
		high = clgetr ("highreject")
	}
	doscale = scalef (in, out, nimages, log, low, high)

####################################################################
# Allocate stack memory for local variables.
	call smark (sp)
#  Bug fix 23 Feb 93 by RAShaw: "data" is an array of TY_POINTER
#	call salloc (data, nimages, TY_REAL)
	call salloc (data, nimages, TY_POINTER)
	call salloc (dqfdata, nimages, TY_POINTER)
	call salloc (curline, IM_MAXDIM, TY_LONG)
	call salloc (oldline, IM_MAXDIM, TY_LONG)
	npts = IM_LEN(out,1)
	if (sigma == NULL) {
	    call salloc (sigdata, npts, TY_REAL)
	}

# Initialize local variables.
	call amovkl (long(1), Meml[curline], IM_MAXDIM)
	call amovkl (long(1), Meml[oldline], IM_MAXDIM)

# For each line get input image lines and combine them.  Note that, because 
# the input procedure increments the current line number (cln), the cln must 
# be copied from the previous line number for each call to impnl or imgnl.

	while (impnlr (out, outdata, Meml[curline]) != EOF) {

# Initialize the output and sigma images to zero.
#	    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
#	    j = impnlr (out, outdata, Meml[curline])
	    call aclrr (Memr[outdata], npts)
	    if (sigma != NULL) {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = impnlr (sigma, sigdata, Meml[curline])
	    }
	    call aclrr (Memr[sigdata], npts)
	    do i = 1, nimages {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = imgnll (in[i], Memi[data+i-1], Meml[curline])
		if (dqf[1] != NULL) {
		    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		    j = imgnli (dqf[i], Memi[dqfdata+i-1], Meml[curline])
		}
	    }

# Impose rejection criteria
	    if (dqf[1] != NULL) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "DQF rejection not supported for SUM")
		    case AVERAGE:
			call dqaveragel (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MEDIAN:
			call dqmedianl (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts)
		    case MINREJECT:
			call dqminrejl (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call dqmaxrejl (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call dqmmrejl (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case CRREJECT:
			call dqcrrejl (Memi[data], Memi[dqfdata], 
				Memr[outdata], Memr[sigdata], nimages, npts, 
				high, readnoise, gain, gscale)
		    case THRESHOLD:
			call dqthresholdl (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts, low, high)
		    case SIGCLIP:
			call dqsigclipl (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call dqasigclipl (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		}
	    } else if (doscale) {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call error (0, "Weighting not supported for option: SUM")
		    case AVERAGE:
			call wtaveragel (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MEDIAN:
			call scmedianl (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call wtminrejl (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call wtmaxrejl (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call wtmmrejl (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call wtcrrejl (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call wtsigclipl (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call wtasigclipl (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call wtthresholdl (Memi[data], Memr[outdata], nimages, 
				npts, low, high)
		}
	    } else {

# Call routine appropriate to combine option.  
		switch (option) {
		    case SUM:
			call suml (Memi[data], Memr[outdata], nimages, npts)
		    case AVERAGE:
			call averagel (Memi[data], Memr[outdata], nimages, npts)
		    case MEDIAN:
			call medianl (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call minrejl (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call maxrejl (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call mmrejl (Memi[data], Memr[outdata], nimages, npts)
		    case CRREJECT:
			call crrejl (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call sigclipl (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, low, high)
		    case AVSIGCLIP:
			call asigclipl (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case THRESHOLD:
			call thresholdl (Memi[data], Memr[outdata], nimages, 
					npts, low, high)
		}
	    }

# Calculate sigma, with weighting, if appropriate.
	    if ((sigma != NULL) && (option != CRREJECT) && (option != SUM) && 
		(option != SIGCLIP) && (option != AVSIGCLIP)) {
		if (doscale || dqf[1] != NULL) 
		    call wgtsigmal (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
		else 
		    call sigmal (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
	    }
	    call amovl (Meml[curline], Meml[oldline], IM_MAXDIM)
	}

	call sfree (sp)
	end

procedure combiner (in, dqf, nimages, out, sigma, option, log)

include "wpcom.h"

# Calling arguments:
int		log			# Log file descriptor
pointer		in[nimages]		# IMIO pointers to data
pointer		dqf[nimages]		# IMIO pointers to Data Quality Files
int		nimages			# Number of input images
pointer		out			# Output IMIO pointer
pointer		sigma			# Sigma IMIO pointer
int		option			# Combine option

# Local variables:
bool		bit[8]			# Bit codes for DQF flags
pointer		curline			# Current line number
pointer		data 			# Line of input images
bool		doscale			# Are input images to be scaled/weighted?
pointer		dqfdata			# Line of DQF images
real		gain			# Detector gain in DN/photon
real		gscale			# Scale term in noise model (% of DN)
real		high			# High sigma cutoff
int		i, j			# Dummy loop counters
real		low			# Low sigma cutoff
int		npts			# Number of pixels per image line
pointer		oldline			# Previous line number
pointer		outdata			# Output image line
real		readnoise		# Additive term in noise model
pointer		sigdata			# Sigma image line 
pointer		sp			# Pointer to stack memory

# Functions used:
bool		clgetb()		# Fetch Boolean keyword from CL
real		clgetr()		# Fetch real keyword from CL
pointer		imgnlr()		# Get Next Line
pointer		imgnli()		# Get Next Line
pointer		impnlr()		# Put Next Line
bool		scalef()		# Determines scales and weights

begin
	errchk asigclipr, averager, crrejr, maxrejr, medianr, 
		minrejr, mmrejr, sigclipr, sumr, thresholdr

# Fetch user-selected DQF bits.
	bit[1] = clgetb ("rsbit")		# Reed-Solomon error
	bit[2] = clgetb ("calbit")		# Calibration file defect
	bit[3] = clgetb ("defbit")		# Permanent camera defect
	bit[4] = clgetb ("satbit")		# Saturated pixel
	bit[5] = clgetb ("misbit")		# Missing data
	bit[6] = clgetb ("genbit")		# Generic bad pixel
	bit[7] = clgetb ("crbit")		# Cosmic Ray hit
	bit[8] = false				# (unused)
	CRBIT  = 15				# Hardwired, for now

# Convert bit-coded flags to an integer.
	BADBITS = 0
	do i = 1, 8
	    if (bit[i]) BADBITS = BADBITS + 2 ** (i-1)

# Determine scale factors and weights for input images.  Note that these 
# parameters are not set for option="SUM".
	BLANK = clgetr ("blank")
	switch (option) {
	    case AVERAGE, MEDIAN, MINREJECT, MAXREJECT, MINMAXREJECT: 
		low  = 0.
		high = 0.
	    case CRREJECT: 
		low       = 0.
		high      = clgetr ("highreject")
		readnoise = clgetr ("readnoise")
		gain      = clgetr ("gain")
		gscale    = clgetr ("scalenoise") / 100.
	    case THRESHOLD: 
		low   = clgetr ("lowreject")
		high  = clgetr ("highreject")
		if (low >= high) 
		    call error (0, 
			"Bad threshold limits (lowreject >= highreject)")
	    case SIGCLIP, AVSIGCLIP: 
		low  = clgetr ("lowreject")
		high = clgetr ("highreject")
	}
	doscale = scalef (in, out, nimages, log, low, high)

####################################################################
# Allocate stack memory for local variables.
	call smark (sp)
#  Bug fix 23 Feb 93 by RAShaw: "data" is an array of TY_POINTER
#	call salloc (data, nimages, TY_REAL)
	call salloc (data, nimages, TY_POINTER)
	call salloc (dqfdata, nimages, TY_POINTER)
	call salloc (curline, IM_MAXDIM, TY_LONG)
	call salloc (oldline, IM_MAXDIM, TY_LONG)
	npts = IM_LEN(out,1)
	if (sigma == NULL) {
	    call salloc (sigdata, npts, TY_REAL)
	}

# Initialize local variables.
	call amovkl (long(1), Meml[curline], IM_MAXDIM)
	call amovkl (long(1), Meml[oldline], IM_MAXDIM)

# For each line get input image lines and combine them.  Note that, because 
# the input procedure increments the current line number (cln), the cln must 
# be copied from the previous line number for each call to impnl or imgnl.

	while (impnlr (out, outdata, Meml[curline]) != EOF) {

# Initialize the output and sigma images to zero.
#	    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
#	    j = impnl$t (out, outdata, Meml[curline])
	    call aclrr (Memr[outdata], npts)
	    if (sigma != NULL) {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = impnlr (sigma, sigdata, Meml[curline])
	    }
	    call aclrr (Memr[sigdata], npts)
	    do i = 1, nimages {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = imgnlr (in[i], Memi[data+i-1], Meml[curline])
		if (dqf[1] != NULL) {
		    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		    j = imgnli (dqf[i], Memi[dqfdata+i-1], Meml[curline])
		}
	    }

# Impose rejection criteria
	    if (dqf[1] != NULL) {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call error (0, "DQF rejection not supported for SUM")
		    case AVERAGE:
			call dqaverager (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts)
		    case MEDIAN:
			call dqmedianr (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MINREJECT:
			call dqminrejr (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call dqmaxrejr (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call dqmmrejr (Memi[data], Memi[dqfdata], 
					Memr[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call dqcrrejr (Memi[data], Memi[dqfdata], 
					Memr[outdata], Memr[sigdata], nimages, 
					npts, high, readnoise, gain, gscale)
		    case SIGCLIP:
			call dqsigclipr (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call dqasigclipr (Memi[data], Memi[dqfdata], 
			Memr[outdata], Memr[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call dqthresholdr (Memi[data], Memi[dqfdata], 
				Memr[outdata], nimages, npts, low, high)
		}
	    } else if (doscale) {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call error (0, "Weighting not supported for option: SUM")
		    case AVERAGE:
			call wtaverager (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MEDIAN:
			call scmedianr (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MINREJECT:
			call wtminrejr (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MAXREJECT:
			call wtmaxrejr (Memi[data], Memr[outdata], nimages, 
					npts)
		    case MINMAXREJECT:
			call wtmmrejr (Memi[data], Memr[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call wtcrrejr (Memi[data], Memr[outdata], 
				Memr[sigdata], nimages, npts, high, readnoise, 
					gain, gscale)
		    case SIGCLIP:
			call wtsigclipr (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call wtasigclipr (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call wtthresholdr (Memi[data], Memr[outdata], nimages, 
					npts, low, high)
		}
	    } else {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call sumr (Memi[data], Memr[outdata], nimages, npts)
		    case AVERAGE:
			call averager (Memi[data], Memr[outdata], nimages, npts)
		    case MEDIAN:
			call medianr (Memi[data], Memr[outdata], nimages, npts)
		    case MINREJECT:
			call minrejr (Memi[data], Memr[outdata], nimages, npts)
		    case MAXREJECT:
			call maxrejr (Memi[data], Memr[outdata], nimages, npts)
		    case MINMAXREJECT:
			call mmrejr (Memi[data], Memr[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call crrejr (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call sigclipr (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call asigclipr (Memi[data], Memr[outdata], 
					Memr[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call thresholdr (Memi[data], Memr[outdata], nimages, 
					npts, low, high)
		}
	    }

# Calculate sigma, with weighting, if appropriate.
	    if ((sigma != NULL) && (option != CRREJECT) && (option != SUM) && 
		(option != SIGCLIP) && (option != AVSIGCLIP)) {
		if (doscale || dqf[1] != NULL) 
		    call wgtsigmar (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
		else 
		    call sigmar (Memi[data], Memr[outdata], Memr[sigdata], 
					nimages, npts)
	    }
	    call amovl (Meml[curline], Meml[oldline], IM_MAXDIM)
	}

	call sfree (sp)
	end

procedure combined (in, dqf, nimages, out, sigma, option, log)

include "wpcom.h"

# Calling arguments:
int		log			# Log file descriptor
pointer		in[nimages]		# IMIO pointers to data
pointer		dqf[nimages]		# IMIO pointers to Data Quality Files
int		nimages			# Number of input images
pointer		out			# Output IMIO pointer
pointer		sigma			# Sigma IMIO pointer
int		option			# Combine option

# Local variables:
bool		bit[8]			# Bit codes for DQF flags
pointer		curline			# Current line number
pointer		data 			# Line of input images
bool		doscale			# Are input images to be scaled/weighted?
pointer		dqfdata			# Line of DQF images
real		gain			# Detector gain in DN/photon
real		gscale			# Scale term in noise model (% of DN)
real		high			# High sigma cutoff
int		i, j			# Dummy loop counters
real		low			# Low sigma cutoff
int		npts			# Number of pixels per image line
pointer		oldline			# Previous line number
pointer		outdata			# Output image line
real		readnoise		# Additive term in noise model
pointer		sigdata			# Sigma image line 
pointer		sp			# Pointer to stack memory

# Functions used:
bool		clgetb()		# Fetch Boolean keyword from CL
real		clgetr()		# Fetch real keyword from CL
pointer		imgnld()		# Get Next Line
pointer		imgnli()		# Get Next Line
pointer		impnld()		# Put Next Line
bool		scalef()		# Determines scales and weights

begin
	errchk asigclipd, averaged, crrejd, maxrejd, mediand, 
		minrejd, mmrejd, sigclipd, sumd, thresholdd

# Fetch user-selected DQF bits.
	bit[1] = clgetb ("rsbit")		# Reed-Solomon error
	bit[2] = clgetb ("calbit")		# Calibration file defect
	bit[3] = clgetb ("defbit")		# Permanent camera defect
	bit[4] = clgetb ("satbit")		# Saturated pixel
	bit[5] = clgetb ("misbit")		# Missing data
	bit[6] = clgetb ("genbit")		# Generic bad pixel
	bit[7] = clgetb ("crbit")		# Cosmic Ray hit
	bit[8] = false				# (unused)
	CRBIT  = 15				# Hardwired, for now

# Convert bit-coded flags to an integer.
	BADBITS = 0
	do i = 1, 8
	    if (bit[i]) BADBITS = BADBITS + 2 ** (i-1)

# Determine scale factors and weights for input images.  Note that these 
# parameters are not set for option="SUM".
	BLANK = clgetr ("blank")
	switch (option) {
	    case AVERAGE, MEDIAN, MINREJECT, MAXREJECT, MINMAXREJECT: 
		low  = 0.
		high = 0.
	    case CRREJECT: 
		low       = 0.
		high      = clgetr ("highreject")
		readnoise = clgetr ("readnoise")
		gain      = clgetr ("gain")
		gscale    = clgetr ("scalenoise") / 100.
	    case THRESHOLD: 
		low   = clgetr ("lowreject")
		high  = clgetr ("highreject")
		if (low >= high) 
		    call error (0, 
			"Bad threshold limits (lowreject >= highreject)")
	    case SIGCLIP, AVSIGCLIP: 
		low  = clgetr ("lowreject")
		high = clgetr ("highreject")
	}
	doscale = scalef (in, out, nimages, log, low, high)

####################################################################
# Allocate stack memory for local variables.
	call smark (sp)
#  Bug fix 23 Feb 93 by RAShaw: "data" is an array of TY_POINTER
#	call salloc (data, nimages, TY_REAL)
	call salloc (data, nimages, TY_POINTER)
	call salloc (dqfdata, nimages, TY_POINTER)
	call salloc (curline, IM_MAXDIM, TY_LONG)
	call salloc (oldline, IM_MAXDIM, TY_LONG)
	npts = IM_LEN(out,1)
	if (sigma == NULL) {
	    call salloc (sigdata, npts, TY_DOUBLE)
	}

# Initialize local variables.
	call amovkl (long(1), Meml[curline], IM_MAXDIM)
	call amovkl (long(1), Meml[oldline], IM_MAXDIM)

# For each line get input image lines and combine them.  Note that, because 
# the input procedure increments the current line number (cln), the cln must 
# be copied from the previous line number for each call to impnl or imgnl.

	while (impnld (out, outdata, Meml[curline]) != EOF) {

# Initialize the output and sigma images to zero.
#	    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
#	    j = impnl$t (out, outdata, Meml[curline])
	    call aclrd (Memd[outdata], npts)
	    if (sigma != NULL) {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = impnld (sigma, sigdata, Meml[curline])
	    }
	    call aclrd (Memd[sigdata], npts)
	    do i = 1, nimages {
		call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		j = imgnld (in[i], Memi[data+i-1], Meml[curline])
		if (dqf[1] != NULL) {
		    call amovl (Meml[oldline], Meml[curline], IM_MAXDIM)
		    j = imgnli (dqf[i], Memi[dqfdata+i-1], Meml[curline])
		}
	    }

# Impose rejection criteria
	    if (dqf[1] != NULL) {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call error (0, "DQF rejection not supported for SUM")
		    case AVERAGE:
			call dqaveraged (Memi[data], Memi[dqfdata], 
				Memd[outdata], nimages, npts)
		    case MEDIAN:
			call dqmediand (Memi[data], Memi[dqfdata], 
					Memd[outdata], nimages, npts)
		    case MINREJECT:
			call dqminrejd (Memi[data], Memi[dqfdata], 
					Memd[outdata], nimages, npts)
		    case MAXREJECT:
			call dqmaxrejd (Memi[data], Memi[dqfdata], 
					Memd[outdata], nimages, npts)
		    case MINMAXREJECT:
			call dqmmrejd (Memi[data], Memi[dqfdata], 
					Memd[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call dqcrrejd (Memi[data], Memi[dqfdata], 
					Memd[outdata], Memd[sigdata], nimages, 
					npts, high, readnoise, gain, gscale)
		    case SIGCLIP:
			call dqsigclipd (Memi[data], Memi[dqfdata], 
			Memd[outdata], Memd[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call dqasigclipd (Memi[data], Memi[dqfdata], 
			Memd[outdata], Memd[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call dqthresholdd (Memi[data], Memi[dqfdata], 
				Memd[outdata], nimages, npts, low, high)
		}
	    } else if (doscale) {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call error (0, "Weighting not supported for option: SUM")
		    case AVERAGE:
			call wtaveraged (Memi[data], Memd[outdata], nimages, 
					npts)
		    case MEDIAN:
			call scmediand (Memi[data], Memd[outdata], nimages, 
					npts)
		    case MINREJECT:
			call wtminrejd (Memi[data], Memd[outdata], nimages, 
					npts)
		    case MAXREJECT:
			call wtmaxrejd (Memi[data], Memd[outdata], nimages, 
					npts)
		    case MINMAXREJECT:
			call wtmmrejd (Memi[data], Memd[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call wtcrrejd (Memi[data], Memd[outdata], 
				Memd[sigdata], nimages, npts, high, readnoise, 
					gain, gscale)
		    case SIGCLIP:
			call wtsigclipd (Memi[data], Memd[outdata], 
					Memd[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call wtasigclipd (Memi[data], Memd[outdata], 
					Memd[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call wtthresholdd (Memi[data], Memd[outdata], nimages, 
					npts, low, high)
		}
	    } else {

# Call routine appropriate to combine option.  Note that sigma clipping is not 
# supported for complex datatype.  
		switch (option) {
		    case SUM:
			call sumd (Memi[data], Memd[outdata], nimages, npts)
		    case AVERAGE:
			call averaged (Memi[data], Memd[outdata], nimages, npts)
		    case MEDIAN:
			call mediand (Memi[data], Memd[outdata], nimages, npts)
		    case MINREJECT:
			call minrejd (Memi[data], Memd[outdata], nimages, npts)
		    case MAXREJECT:
			call maxrejd (Memi[data], Memd[outdata], nimages, npts)
		    case MINMAXREJECT:
			call mmrejd (Memi[data], Memd[outdata], nimages, npts)
#		    $if (datatype == rd)
		    case CRREJECT:
			call crrejd (Memi[data], Memd[outdata], Memd[sigdata], 
					nimages, npts, high, readnoise, gain, 
					gscale)
		    case SIGCLIP:
			call sigclipd (Memi[data], Memd[outdata], 
					Memd[sigdata], nimages, npts, low, high)
		    case AVSIGCLIP:
			call asigclipd (Memi[data], Memd[outdata], 
					Memd[sigdata], nimages, npts, low, high)
#		    $endif
		    case THRESHOLD:
			call thresholdd (Memi[data], Memd[outdata], nimages, 
					npts, low, high)
		}
	    }

# Calculate sigma, with weighting, if appropriate.
	    if ((sigma != NULL) && (option != CRREJECT) && (option != SUM) && 
		(option != SIGCLIP) && (option != AVSIGCLIP)) {
		if (doscale || dqf[1] != NULL) 
		    call wgtsigmad (Memi[data], Memd[outdata], Memd[sigdata], 
					nimages, npts)
		else 
		    call sigmad (Memi[data], Memd[outdata], Memd[sigdata], 
					nimages, npts)
	    }
	    call amovl (Meml[curline], Meml[oldline], IM_MAXDIM)
	}

	call sfree (sp)
	end


