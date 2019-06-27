include	<mach.h>
include "wpdef.h"

.help crreject
.nf ----------------------------------------------------------------------------
           COMBINING IMAGES: COSMIC RAY REJECTION ALGORITHM

For more than one input image they are combined by scaling and taking a 
weighted average while rejecting points which exceed the median by more than 
a specified factors times the expected sigma at each point.  The exposure time 
of the output image is the scaled and weighted average of the input exposure 
times.  The average is computed in real arithmetic with trunction on output if 
the output image is an integer datatype.  

The cosmic ray rejection algorithm is applied to each image line as follows:  

(1) The input image lines are scaled to account for different mean intensities.  
(2) The median of each point in the line is computed, which minimizes the 
    influence of bad values in the initial estimate of the average.  
(3) The sigma about the median at each point is computed, based upon an input 
    noise model, and each residual is multiplied by the square root of the 
    scaling factor to compensate for the reduction in noise due to the 
    intensity scaling.  
(4) Points exceeding the median by more than a specified factor times the 
    estimated sigma are rejected.  Note that the minimum value is always kept 
    at each point.  
(5) The final weighted average excluding the rejected values is computed.  

PROCEDURES:

    CRREJ     -- Sigma clipping without scaling or weighting.
    DQCRREJ   -- Sigma clipping, excluding bad pixels, with scaling and/or 
			weighting.
    WTCRREJ   -- Sigma clipping with scaling and/or weighting.
.endhelp -----------------------------------------------------------------------



#################################################################################
# CRREJ --	Combine input data lines using a method similar to the sigma 	#
# 		clip algorithm when weights and scale factors are equal.  This	#
#		routine is different in that the median, rather than the mean 	#
#		of all but the largest and smallest values, is used as the 	#
#		value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure crrejs (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read in DN
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		mean, median		# Mean and median values @pixel
real		resid			# Deviation of val from mean; its square
real		sumval, val		# Accumulation; input image value @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Mems[data[j]+i-1]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, nimages)
	    default:
		call bigsorts (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model, and that the estimate of the mean must be positive.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject the most deviant pixels, and compute the average of the remaining 
# values.  Also compute sigma at each point.
	    maxval = kappa * sigma[i]
	    sumval = 0.
	    ncount = 0
	    do j = 1, nimages {
		val   = Mems[data[j]+i-1]
		resid = val - median
		if (resid > maxval) 
		    Mems[data[j]+i-1] = INDEFS
		else {
		    sumval = sumval + val
		    ncount = ncount + 1
		}
	    }
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / ncount
		sumval = 0.
		do j = 1, nimages {
		    val = Mems[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (val != INDEF) {
		    if (!IS_INDEFS(val)) {
			resid  = val - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# DQCRREJ --	Combine input data lines using a method similar to the dqsigma 	#
# 		clip algorithm when weights and scale factors are not equal,  	#
#		and bad pixels are excluded.  This routine is different in 	#
#		that the median, rather than the mean of all but the largest 	#
#		and smallest values, is used as the value about which the 	#
#		clipping is done.  Also, only anomalously high values are 	#
#		clipped, and more than one value may be eliminated.  		#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure dqcrrejs (data, dqfdata, output, sigma, nimages, npts, kappa, 
			readnoise, gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flag(s) @value
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean, median values @pixel
real		sumval			# Accumulation of image values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize working array:
	    ncount = 0
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }

# Sort the work array.
	    switch (ncount) {
	    case 0:
		output[i] = BLANK
		sigma[i]  = BLANK
		next
	    case 1:
		output[i] = work[1]
		sigma[i]  = BLANK
		next
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, ncount)
	    default:
		call bigsorts (work, ncount)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = ncount / 2
	    if (half*2 < ncount)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa", and increment 
# the corresponding DQF value by 2**(CRBIT-1) (i.e. set CRBIT).  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Mems[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		if (work[j] != INDEF) {
		if (!IS_INDEFS(work[j])) {
		    work[j] = work[j] / SCALES[j] - ZEROS[j]
		    resid   = work[j] - median
		    if (resid > maxval) {
			work[j]              = INDEFS
			Mems[data[j]+i-1]   = INDEFS
			Memi[dqfdata[j]+i-1] = Memi[dqfdata[j]+i-1] + 2**(CRBIT-1)
		    } else {
			sumval = sumval + work[j] * WTS[j]
			sumwt  = sumwt + WTS[j]
			ncount = ncount + 1
		    }
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (work[j] != INDEF) {
		    if (!IS_INDEFS(work[j])) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# WTCRREJ --	Combine input data lines using a method similar to the wtsigma 	#
# 		clip algorithm when weights and scale factors are not equal.  	#
#		This routine is different in that the median, rather than the 	#
#		mean of all but the largest and smallest values, is used as 	#
#		the value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure wtcrrejs (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean values @pixel
real		sumval			# Accumulation of values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorts (work, nimages)
	    default:
		call bigsorts (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa".  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
		resid   = work[j] - median
		if (resid > maxval) {
		    work[j]              = INDEFS
		    Mems[data[j]+i-1]   = INDEFS
		} else {
		    sumval = sumval + work[j] * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
		    if (work[j] != INDEFS) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}

end


#################################################################################
# CRREJ --	Combine input data lines using a method similar to the sigma 	#
# 		clip algorithm when weights and scale factors are equal.  This	#
#		routine is different in that the median, rather than the mean 	#
#		of all but the largest and smallest values, is used as the 	#
#		value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure crreji (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read in DN
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		mean, median		# Mean and median values @pixel
real		resid			# Deviation of val from mean; its square
real		sumval, val		# Accumulation; input image value @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memi[data[j]+i-1]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, nimages)
	    default:
		call bigsorti (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model, and that the estimate of the mean must be positive.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject the most deviant pixels, and compute the average of the remaining 
# values.  Also compute sigma at each point.
	    maxval = kappa * sigma[i]
	    sumval = 0.
	    ncount = 0
	    do j = 1, nimages {
		val   = Memi[data[j]+i-1]
		resid = val - median
		if (resid > maxval) 
		    Memi[data[j]+i-1] = INDEFI
		else {
		    sumval = sumval + val
		    ncount = ncount + 1
		}
	    }
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / ncount
		sumval = 0.
		do j = 1, nimages {
		    val = Memi[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (val != INDEF) {
		    if (!IS_INDEFI(val)) {
			resid  = val - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# DQCRREJ --	Combine input data lines using a method similar to the dqsigma 	#
# 		clip algorithm when weights and scale factors are not equal,  	#
#		and bad pixels are excluded.  This routine is different in 	#
#		that the median, rather than the mean of all but the largest 	#
#		and smallest values, is used as the value about which the 	#
#		clipping is done.  Also, only anomalously high values are 	#
#		clipped, and more than one value may be eliminated.  		#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure dqcrreji (data, dqfdata, output, sigma, nimages, npts, kappa, 
			readnoise, gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flag(s) @value
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean, median values @pixel
real		sumval			# Accumulation of image values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize working array:
	    ncount = 0
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }

# Sort the work array.
	    switch (ncount) {
	    case 0:
		output[i] = BLANK
		sigma[i]  = BLANK
		next
	    case 1:
		output[i] = work[1]
		sigma[i]  = BLANK
		next
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, ncount)
	    default:
		call bigsorti (work, ncount)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = ncount / 2
	    if (half*2 < ncount)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa", and increment 
# the corresponding DQF value by 2**(CRBIT-1) (i.e. set CRBIT).  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memi[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		if (work[j] != INDEF) {
		if (!IS_INDEFI(work[j])) {
		    work[j] = work[j] / SCALES[j] - ZEROS[j]
		    resid   = work[j] - median
		    if (resid > maxval) {
			work[j]              = INDEFI
			Memi[data[j]+i-1]   = INDEFI
			Memi[dqfdata[j]+i-1] = Memi[dqfdata[j]+i-1] + 2**(CRBIT-1)
		    } else {
			sumval = sumval + work[j] * WTS[j]
			sumwt  = sumwt + WTS[j]
			ncount = ncount + 1
		    }
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (work[j] != INDEF) {
		    if (!IS_INDEFI(work[j])) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# WTCRREJ --	Combine input data lines using a method similar to the wtsigma 	#
# 		clip algorithm when weights and scale factors are not equal.  	#
#		This routine is different in that the median, rather than the 	#
#		mean of all but the largest and smallest values, is used as 	#
#		the value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure wtcrreji (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean values @pixel
real		sumval			# Accumulation of values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsorti (work, nimages)
	    default:
		call bigsorti (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa".  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
		resid   = work[j] - median
		if (resid > maxval) {
		    work[j]              = INDEFI
		    Memi[data[j]+i-1]   = INDEFI
		} else {
		    sumval = sumval + work[j] * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
		    if (work[j] != INDEFI) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}

end


#################################################################################
# CRREJ --	Combine input data lines using a method similar to the sigma 	#
# 		clip algorithm when weights and scale factors are equal.  This	#
#		routine is different in that the median, rather than the mean 	#
#		of all but the largest and smallest values, is used as the 	#
#		value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure crrejl (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read in DN
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		mean, median		# Mean and median values @pixel
real		resid			# Deviation of val from mean; its square
real		sumval, val		# Accumulation; input image value @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Meml[data[j]+i-1]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, nimages)
	    default:
		call bigsortl (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model, and that the estimate of the mean must be positive.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject the most deviant pixels, and compute the average of the remaining 
# values.  Also compute sigma at each point.
	    maxval = kappa * sigma[i]
	    sumval = 0.
	    ncount = 0
	    do j = 1, nimages {
		val   = Meml[data[j]+i-1]
		resid = val - median
		if (resid > maxval) 
		    Meml[data[j]+i-1] = INDEFL
		else {
		    sumval = sumval + val
		    ncount = ncount + 1
		}
	    }
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / ncount
		sumval = 0.
		do j = 1, nimages {
		    val = Meml[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (val != INDEF) {
		    if (!IS_INDEFL(val)) {
			resid  = val - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# DQCRREJ --	Combine input data lines using a method similar to the dqsigma 	#
# 		clip algorithm when weights and scale factors are not equal,  	#
#		and bad pixels are excluded.  This routine is different in 	#
#		that the median, rather than the mean of all but the largest 	#
#		and smallest values, is used as the value about which the 	#
#		clipping is done.  Also, only anomalously high values are 	#
#		clipped, and more than one value may be eliminated.  		#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure dqcrrejl (data, dqfdata, output, sigma, nimages, npts, kappa, 
			readnoise, gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flag(s) @value
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean, median values @pixel
real		sumval			# Accumulation of image values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize working array:
	    ncount = 0
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }

# Sort the work array.
	    switch (ncount) {
	    case 0:
		output[i] = BLANK
		sigma[i]  = BLANK
		next
	    case 1:
		output[i] = work[1]
		sigma[i]  = BLANK
		next
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, ncount)
	    default:
		call bigsortl (work, ncount)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = ncount / 2
	    if (half*2 < ncount)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa", and increment 
# the corresponding DQF value by 2**(CRBIT-1) (i.e. set CRBIT).  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Meml[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		if (work[j] != INDEF) {
		if (!IS_INDEFL(work[j])) {
		    work[j] = work[j] / SCALES[j] - ZEROS[j]
		    resid   = work[j] - median
		    if (resid > maxval) {
			work[j]              = INDEFL
			Meml[data[j]+i-1]   = INDEFL
			Memi[dqfdata[j]+i-1] = Memi[dqfdata[j]+i-1] + 2**(CRBIT-1)
		    } else {
			sumval = sumval + work[j] * WTS[j]
			sumwt  = sumwt + WTS[j]
			ncount = ncount + 1
		    }
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (work[j] != INDEF) {
		    if (!IS_INDEFL(work[j])) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# WTCRREJ --	Combine input data lines using a method similar to the wtsigma 	#
# 		clip algorithm when weights and scale factors are not equal.  	#
#		This routine is different in that the median, rather than the 	#
#		mean of all but the largest and smallest values, is used as 	#
#		the value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure wtcrrejl (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean values @pixel
real		sumval			# Accumulation of values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortl (work, nimages)
	    default:
		call bigsortl (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa".  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
		resid   = work[j] - median
		if (resid > maxval) {
		    work[j]              = INDEFL
		    Meml[data[j]+i-1]   = INDEFL
		} else {
		    sumval = sumval + work[j] * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
		    if (work[j] != INDEFL) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}

end


#################################################################################
# CRREJ --	Combine input data lines using a method similar to the sigma 	#
# 		clip algorithm when weights and scale factors are equal.  This	#
#		routine is different in that the median, rather than the mean 	#
#		of all but the largest and smallest values, is used as the 	#
#		value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure crrejr (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read in DN
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		mean, median		# Mean and median values @pixel
real		resid			# Deviation of val from mean; its square
real		sumval, val		# Accumulation; input image value @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memr[data[j]+i-1]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, nimages)
	    default:
		call bigsortr (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model, and that the estimate of the mean must be positive.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject the most deviant pixels, and compute the average of the remaining 
# values.  Also compute sigma at each point.
	    maxval = kappa * sigma[i]
	    sumval = 0.
	    ncount = 0
	    do j = 1, nimages {
		val   = Memr[data[j]+i-1]
		resid = val - median
		if (resid > maxval) 
		    Memr[data[j]+i-1] = INDEFR
		else {
		    sumval = sumval + val
		    ncount = ncount + 1
		}
	    }
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / ncount
		sumval = 0.
		do j = 1, nimages {
		    val = Memr[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (val != INDEF) {
		    if (!IS_INDEFR(val)) {
			resid  = val - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# DQCRREJ --	Combine input data lines using a method similar to the dqsigma 	#
# 		clip algorithm when weights and scale factors are not equal,  	#
#		and bad pixels are excluded.  This routine is different in 	#
#		that the median, rather than the mean of all but the largest 	#
#		and smallest values, is used as the value about which the 	#
#		clipping is done.  Also, only anomalously high values are 	#
#		clipped, and more than one value may be eliminated.  		#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure dqcrrejr (data, dqfdata, output, sigma, nimages, npts, kappa, 
			readnoise, gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flag(s) @value
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean, median values @pixel
real		sumval			# Accumulation of image values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize working array:
	    ncount = 0
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }

# Sort the work array.
	    switch (ncount) {
	    case 0:
		output[i] = BLANK
		sigma[i]  = BLANK
		next
	    case 1:
		output[i] = work[1]
		sigma[i]  = BLANK
		next
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, ncount)
	    default:
		call bigsortr (work, ncount)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = ncount / 2
	    if (half*2 < ncount)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa", and increment 
# the corresponding DQF value by 2**(CRBIT-1) (i.e. set CRBIT).  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memr[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		if (work[j] != INDEF) {
		if (!IS_INDEFR(work[j])) {
		    work[j] = work[j] / SCALES[j] - ZEROS[j]
		    resid   = work[j] - median
		    if (resid > maxval) {
			work[j]              = INDEFR
			Memr[data[j]+i-1]   = INDEFR
			Memi[dqfdata[j]+i-1] = Memi[dqfdata[j]+i-1] + 2**(CRBIT-1)
		    } else {
			sumval = sumval + work[j] * WTS[j]
			sumwt  = sumwt + WTS[j]
			ncount = ncount + 1
		    }
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (work[j] != INDEF) {
		    if (!IS_INDEFR(work[j])) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# WTCRREJ --	Combine input data lines using a method similar to the wtsigma 	#
# 		clip algorithm when weights and scale factors are not equal.  	#
#		This routine is different in that the median, rather than the 	#
#		mean of all but the largest and smallest values, is used as 	#
#		the value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure wtcrrejr (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
real		resid			# Deviation of val from mean; its square
real		mean, median		# Mean, median values @pixel
real		sumval			# Accumulation of values @pixel
real		maxval			# Maximum value @pixel
real		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortr (work, nimages)
	    default:
		call bigsortr (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa".  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
		resid   = work[j] - median
		if (resid > maxval) {
		    work[j]              = INDEFR
		    Memr[data[j]+i-1]   = INDEFR
		} else {
		    sumval = sumval + work[j] * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
		    if (work[j] != INDEFR) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}

end


#################################################################################
# CRREJ --	Combine input data lines using a method similar to the sigma 	#
# 		clip algorithm when weights and scale factors are equal.  This	#
#		routine is different in that the median, rather than the mean 	#
#		of all but the largest and smallest values, is used as the 	#
#		value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure crrejd (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
double		output[npts]		# Mean line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read in DN
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
double		mean, median		# Mean and median values @pixel
double		resid			# Deviation of val from mean; its square
double		sumval, val		# Accumulation; input image value @pixel
double		maxval			# Maximum value @pixel
double		work[IMS_MAX]		# Working array

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memd[data[j]+i-1]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, nimages)
	    default:
		call bigsortd (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model, and that the estimate of the mean must be positive.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject the most deviant pixels, and compute the average of the remaining 
# values.  Also compute sigma at each point.
	    maxval = kappa * sigma[i]
	    sumval = 0.
	    ncount = 0
	    do j = 1, nimages {
		val   = Memd[data[j]+i-1]
		resid = val - median
		if (resid > maxval) 
		    Memd[data[j]+i-1] = INDEFD
		else {
		    sumval = sumval + val
		    ncount = ncount + 1
		}
	    }
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / ncount
		sumval = 0.
		do j = 1, nimages {
		    val = Memd[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (val != INDEF) {
		    if (!IS_INDEFD(val)) {
			resid  = val - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# DQCRREJ --	Combine input data lines using a method similar to the dqsigma 	#
# 		clip algorithm when weights and scale factors are not equal,  	#
#		and bad pixels are excluded.  This routine is different in 	#
#		that the median, rather than the mean of all but the largest 	#
#		and smallest values, is used as the value about which the 	#
#		clipping is done.  Also, only anomalously high values are 	#
#		clipped, and more than one value may be eliminated.  		#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure dqcrrejd (data, dqfdata, output, sigma, nimages, npts, kappa, 
			readnoise, gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
double		output[npts]		# Output line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flag(s) @value
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
double		resid			# Deviation of val from mean; its square
double		mean, median		# Mean, median values @pixel
double		sumval			# Accumulation of image values @pixel
double		maxval			# Maximum value @pixel
double		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize working array:
	    ncount = 0
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    ncount       = ncount + 1
		    work[ncount] = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }

# Sort the work array.
	    switch (ncount) {
	    case 0:
		output[i] = BLANK
		sigma[i]  = BLANK
		next
	    case 1:
		output[i] = work[1]
		sigma[i]  = BLANK
		next
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, ncount)
	    default:
		call bigsortd (work, ncount)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = ncount / 2
	    if (half*2 < ncount)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa", and increment 
# the corresponding DQF value by 2**(CRBIT-1) (i.e. set CRBIT).  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memd[data[j]+i-1]
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		if (work[j] != INDEF) {
		if (!IS_INDEFD(work[j])) {
		    work[j] = work[j] / SCALES[j] - ZEROS[j]
		    resid   = work[j] - median
		    if (resid > maxval) {
			work[j]              = INDEFD
			Memd[data[j]+i-1]   = INDEFD
			Memi[dqfdata[j]+i-1] = Memi[dqfdata[j]+i-1] + 2**(CRBIT-1)
		    } else {
			sumval = sumval + work[j] * WTS[j]
			sumwt  = sumwt + WTS[j]
			ncount = ncount + 1
		    }
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: replace expression with generic macro
#		    if (work[j] != INDEF) {
		    if (!IS_INDEFD(work[j])) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}
end


#################################################################################
# WTCRREJ --	Combine input data lines using a method similar to the wtsigma 	#
# 		clip algorithm when weights and scale factors are not equal.  	#
#		This routine is different in that the median, rather than the 	#
#		mean of all but the largest and smallest values, is used as 	#
#		the value about which the clipping is done.  Also, only the 	#
#		anomalously high values are clipped, and more than one value	#
#		may be eliminated.  						#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Use IS_INDEF macro rather than explicit 	#
#				comparison					#

procedure wtcrrejd (data, output, sigma, nimages, npts, kappa, readnoise, 
			gain, grain)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
double		output[npts]		# Output line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		kappa			# High sigma rejection threshold
real		readnoise		# Additive noise from read process
real		gain			# Detector gain in photons per DN
real		grain			# Multiplicative term in noise model

# Local variables:
int		half			# Half the working array size
int		i, j			# Dummy indexes
int		ncount			# Number of non-rejected values @pixel
real		readsq			# Square of readnoise
double		resid			# Deviation of val from mean; its square
double		mean, median		# Mean, median values @pixel
double		sumval			# Accumulation of values @pixel
double		maxval			# Maximum value @pixel
double		work[IMS_MAX]		# Working array
real		sumwt			# Sum of weights @pixel

begin
	readsq = readnoise * readnoise * gain * gain

# Initialize working array:
	do i = 1, npts {
	    do j = 1, nimages
		work[j] = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]

# Sort the work array.
	    switch (nimages) {
	    case 0, 1:
		return
	    case 2:
		;
	    case 3, 4, 5, 6, 7:
		call smallsortd (work, nimages)
	    default:
		call bigsortd (work, nimages)
	    }

# Compute the median value and sigma.  Note that sigma is based upon the 
# noise model.
	    half = nimages / 2
	    if (half*2 < nimages)
		median = work[half+1]
	    else
		median = (work[half] + work[half+1]) / 2.
	    maxval   = max (real (median), 0.) * gain 
	    sigma[i] = sqrt (readsq + maxval + (grain * maxval) ** 2) / gain 

# Reject pixels that exceed the median by more than "kappa".  
	    maxval = kappa * sigma[i]
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		work[j] = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
		resid   = work[j] - median
		if (resid > maxval) {
		    work[j]              = INDEFD
		    Memd[data[j]+i-1]   = INDEFD
		} else {
		    sumval = sumval + work[j] * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		}
	    }

# Compute the average of the remaining values and the sigma at each point.  
	    switch (ncount) {
	    case 0: 
		output[i] = BLANK
		sigma[i]  = BLANK
	    case 1: 
		output[i] = sumval / sumwt
		sigma[i]  = BLANK
	    default: 
		mean   = sumval / sumwt
		sumval = 0.
		do j = 1, nimages {
		    if (work[j] != INDEFD) {
			resid  = work[j] - mean
			sumval = sumval + resid * resid
		    }
		}
		output[i] = mean
		sigma[i]  = sqrt (sumval / (ncount - 1.))
	    }
	}

end

