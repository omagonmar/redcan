include	<mach.h>
include "wpdef.h"

.help asigclip
.nf ----------------------------------------------------------------------------
         COMBINING IMAGES: AVERAGE SIGMA CLIPPING ALGORITHM

If there is only one input image then it is copied to the output image.  If 
there are two input images then it is an error.  For more than two
input images they are combined by scaling and taking a weighted average while
rejecting points which deviate from the average by more than specified
factors times the expected sigma at each point.  The exposure time of the
output image is the scaled and weighted average of the input exposure times.
The average is computed in real arithmetic with trunction on output if
the output image is an integer datatype.

The average sigma clipping algorithm is applied to each image line as follows.

(1) The input image lines are scaled to account for different mean intensities.
(2) The weighted average of each point in the line is computed after rejecting
    the high and low values (the minmax combining algorithm).  This minimizes 
    the influence of bad values in the initial estimate of the average.  
(3) The sigma about the mean at each point (including the high and low values)
    is computed.  Each residual is multiplied by the square root of the 
    scaling factor to compensate for the reduction in noise due to the 
    intensity scaling.  
(4) Each sigma is divided by the square root of the mean to account for the 
    Poisson variation in the noise and the average sigma is computed.  This 
    average sigma is much less influenced by bad values and works well even 
    with only a few images.  
(5) The estimated sigma at each point is then found by multiplying the average 
    sigma by the mean at that point.  
(6) The most deviant point exceeding a specified factor times the estimated 
    sigma is rejected.  Note that at most one value is rejected at each point.  
(7) The final weighted average excluding the rejected values is computed.  

PROCEDURES:

    ASIGCLIP     -- Average sigma clipping when SCALES and weights are equal.
    DQASIGCLIP   -- Average sigma clipping, excluding bad pixels, when SCALES 
			and weights not equal.
    WTASIGCLIP   -- Average sigma clipping when SCALES and weights unequal.
.endhelp -----------------------------------------------------------------------



#################################################################################
# ASIGCLIP --	Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure asigclips (data, output, sigma, nimages, npts, lowsig, highsig)

pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		i, j, k			# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		minval, maxval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    minval = Mems[data[1]+i-1]
	    maxval = Mems[data[2]+i-1]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
	    }
	    sumval = minval + maxval

# Compute the mean with and without rejecting the extrema.
	    do j = 3, nimages {
		val = Mems[data[j]+i-1]
		if (val < minval) 
		    minval = val
		else if (val > maxval) 
		    maxval = val
		sumval = sumval + val
	    }
	    Memr[mean+i-1] = (sumval - minval - maxval) / (nimages - 2.)
	    output[i] = sumval / nimages
	}

# Compute sigma at each point and the average line sigma.  Correct the sigma 
# at each point for variation in the mean intensity at that point.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = Mems[data[j]+i-1] - val
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFS(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = Mems[data[1]+i-1] - val
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = Mems[data[j]+i-1] - val
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (nimages*output[i] - 
				Mems[data[k]+i-1]) / (nimages - 1.)
		Mems[data[k]+i-1] = INDEFS
	    }
	}

	call sfree (sp)
end


#################################################################################
# DQASIGCLIP -- Combine input image lines, excluding flagged pixels, using 	#
#		the average sigma clip algorithm when weights and scale 	#
#		factors are not equal.  This procedure is based upon the 	#
#		`images.imcombine' package.  					#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure dqasigclips (data, dqfdata, output, sigma, nimages, npts, lowsig, 
			highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flags @value
int		i, j, k, m		# Dummy indexes
int		ncount			# No. of non-rejected values @pixel
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
real		netwt			# Sum of wts @pixel excluding extrema
real		sumwt			# Sum of weights @pixel 
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)
	do i = 1, npts {

# Select user-chosen Data Quality bits.  
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    m      = 1

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
		    if (val < minval) {
			minval = val
			k      = j
		    } 
		    if (val > maxval) {
			maxval = val
			m      = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) {
		Memr[mean+i-1] = INDEFS
		output[i] = BLANK
		sigma[i]  = BLANK
		next
#  Bug fix 2/93 by RAShaw: exclude the following block if all values rejected
#	    } 
	    } else {
		Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * 
				WTS[m]) / netwt
		output[i] = sumval / sumwt
	    }
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFS(Mems[data[j]+i-1]) && !IS_INDEFS(val)) {
		    resid = (Mems[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    sumval = sumval + resid * resid
		}
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFS(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = 0.
	    maxresid2 = 0.
	    k         = 1
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFS(Mems[data[j]+i-1]) && !IS_INDEFS(val)) {
		    resid = (Mems[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    resid2 = resid * resid 

# Determine the index of the most deviant pixel.  
		    if (resid2 > maxresid2) {
			maxresid  = resid
			maxresid2 = resid2
			k = j
		    }
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Mems[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1. - WTS[k])
		Mems[data[k]+i-1] = INDEFS
	    }
	}

	call sfree (sp)
end


#################################################################################
# WTASIGCLIP -- Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are not equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure wtasigclips (data, output, sigma, nimages, npts, lowsig, highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

int		i, j, k, m		# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image val @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    k      = 1
	    m      = 2
	    minval = Mems[data[k]+i-1] / SCALES[k] - ZEROS[k]
	    maxval = Mems[data[m]+i-1] / SCALES[m] - ZEROS[m]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
		m      = 1
		k      = 2
	    }
	    sumval = minval * WTS[k] + maxval * WTS[m]

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 3, nimages {
		val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
		if (val < minval) {
		    minval = val
		    k      = j
		} else if (val > maxval) {
		    maxval = val
		    m      = j
		} 
		sumval = sumval + WTS[j] * val
	    }
	    Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
				(1. - WTS[k] - WTS[m])
	    output[i] = sumval
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = (Mems[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFS(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = (Mems[data[1]+i-1] / SCALES[1] - ZEROS[1] - val) * 
				WTS[1]
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = (Mems[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Mems[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1 - WTS[k])
		Mems[data[k]+i-1] = INDEFS
	    }
	}

	call sfree (sp)
end


#################################################################################
# ASIGCLIP --	Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure asigclipi (data, output, sigma, nimages, npts, lowsig, highsig)

pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		i, j, k			# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		minval, maxval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    minval = Memi[data[1]+i-1]
	    maxval = Memi[data[2]+i-1]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
	    }
	    sumval = minval + maxval

# Compute the mean with and without rejecting the extrema.
	    do j = 3, nimages {
		val = Memi[data[j]+i-1]
		if (val < minval) 
		    minval = val
		else if (val > maxval) 
		    maxval = val
		sumval = sumval + val
	    }
	    Memr[mean+i-1] = (sumval - minval - maxval) / (nimages - 2.)
	    output[i] = sumval / nimages
	}

# Compute sigma at each point and the average line sigma.  Correct the sigma 
# at each point for variation in the mean intensity at that point.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = Memi[data[j]+i-1] - val
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFI(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = Memi[data[1]+i-1] - val
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = Memi[data[j]+i-1] - val
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (nimages*output[i] - 
				Memi[data[k]+i-1]) / (nimages - 1.)
		Memi[data[k]+i-1] = INDEFI
	    }
	}

	call sfree (sp)
end


#################################################################################
# DQASIGCLIP -- Combine input image lines, excluding flagged pixels, using 	#
#		the average sigma clip algorithm when weights and scale 	#
#		factors are not equal.  This procedure is based upon the 	#
#		`images.imcombine' package.  					#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure dqasigclipi (data, dqfdata, output, sigma, nimages, npts, lowsig, 
			highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flags @value
int		i, j, k, m		# Dummy indexes
int		ncount			# No. of non-rejected values @pixel
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
real		netwt			# Sum of wts @pixel excluding extrema
real		sumwt			# Sum of weights @pixel 
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)
	do i = 1, npts {

# Select user-chosen Data Quality bits.  
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    m      = 1

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
		    if (val < minval) {
			minval = val
			k      = j
		    } 
		    if (val > maxval) {
			maxval = val
			m      = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) {
		Memr[mean+i-1] = INDEFI
		output[i] = BLANK
		sigma[i]  = BLANK
		next
#  Bug fix 2/93 by RAShaw: exclude the following block if all values rejected
#	    } 
	    } else {
		Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * 
				WTS[m]) / netwt
		output[i] = sumval / sumwt
	    }
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFI(Memi[data[j]+i-1]) && !IS_INDEFI(val)) {
		    resid = (Memi[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    sumval = sumval + resid * resid
		}
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFI(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = 0.
	    maxresid2 = 0.
	    k         = 1
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFI(Memi[data[j]+i-1]) && !IS_INDEFI(val)) {
		    resid = (Memi[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    resid2 = resid * resid 

# Determine the index of the most deviant pixel.  
		    if (resid2 > maxresid2) {
			maxresid  = resid
			maxresid2 = resid2
			k = j
		    }
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memi[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1. - WTS[k])
		Memi[data[k]+i-1] = INDEFI
	    }
	}

	call sfree (sp)
end


#################################################################################
# WTASIGCLIP -- Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are not equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure wtasigclipi (data, output, sigma, nimages, npts, lowsig, highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

int		i, j, k, m		# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image val @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    k      = 1
	    m      = 2
	    minval = Memi[data[k]+i-1] / SCALES[k] - ZEROS[k]
	    maxval = Memi[data[m]+i-1] / SCALES[m] - ZEROS[m]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
		m      = 1
		k      = 2
	    }
	    sumval = minval * WTS[k] + maxval * WTS[m]

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 3, nimages {
		val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
		if (val < minval) {
		    minval = val
		    k      = j
		} else if (val > maxval) {
		    maxval = val
		    m      = j
		} 
		sumval = sumval + WTS[j] * val
	    }
	    Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
				(1. - WTS[k] - WTS[m])
	    output[i] = sumval
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = (Memi[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFI(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = (Memi[data[1]+i-1] / SCALES[1] - ZEROS[1] - val) * 
				WTS[1]
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = (Memi[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memi[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1 - WTS[k])
		Memi[data[k]+i-1] = INDEFI
	    }
	}

	call sfree (sp)
end


#################################################################################
# ASIGCLIP --	Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure asigclipl (data, output, sigma, nimages, npts, lowsig, highsig)

pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		i, j, k			# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		minval, maxval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    minval = Meml[data[1]+i-1]
	    maxval = Meml[data[2]+i-1]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
	    }
	    sumval = minval + maxval

# Compute the mean with and without rejecting the extrema.
	    do j = 3, nimages {
		val = Meml[data[j]+i-1]
		if (val < minval) 
		    minval = val
		else if (val > maxval) 
		    maxval = val
		sumval = sumval + val
	    }
	    Memr[mean+i-1] = (sumval - minval - maxval) / (nimages - 2.)
	    output[i] = sumval / nimages
	}

# Compute sigma at each point and the average line sigma.  Correct the sigma 
# at each point for variation in the mean intensity at that point.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = Meml[data[j]+i-1] - val
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFL(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = Meml[data[1]+i-1] - val
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = Meml[data[j]+i-1] - val
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (nimages*output[i] - 
				Meml[data[k]+i-1]) / (nimages - 1.)
		Meml[data[k]+i-1] = INDEFL
	    }
	}

	call sfree (sp)
end


#################################################################################
# DQASIGCLIP -- Combine input image lines, excluding flagged pixels, using 	#
#		the average sigma clip algorithm when weights and scale 	#
#		factors are not equal.  This procedure is based upon the 	#
#		`images.imcombine' package.  					#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure dqasigclipl (data, dqfdata, output, sigma, nimages, npts, lowsig, 
			highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flags @value
int		i, j, k, m		# Dummy indexes
int		ncount			# No. of non-rejected values @pixel
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
real		netwt			# Sum of wts @pixel excluding extrema
real		sumwt			# Sum of weights @pixel 
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)
	do i = 1, npts {

# Select user-chosen Data Quality bits.  
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    m      = 1

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
		    if (val < minval) {
			minval = val
			k      = j
		    } 
		    if (val > maxval) {
			maxval = val
			m      = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) {
		Memr[mean+i-1] = INDEFL
		output[i] = BLANK
		sigma[i]  = BLANK
		next
#  Bug fix 2/93 by RAShaw: exclude the following block if all values rejected
#	    } 
	    } else {
		Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * 
				WTS[m]) / netwt
		output[i] = sumval / sumwt
	    }
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFL(Meml[data[j]+i-1]) && !IS_INDEFL(val)) {
		    resid = (Meml[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    sumval = sumval + resid * resid
		}
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFL(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = 0.
	    maxresid2 = 0.
	    k         = 1
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFL(Meml[data[j]+i-1]) && !IS_INDEFL(val)) {
		    resid = (Meml[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    resid2 = resid * resid 

# Determine the index of the most deviant pixel.  
		    if (resid2 > maxresid2) {
			maxresid  = resid
			maxresid2 = resid2
			k = j
		    }
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Meml[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1. - WTS[k])
		Meml[data[k]+i-1] = INDEFL
	    }
	}

	call sfree (sp)
end


#################################################################################
# WTASIGCLIP -- Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are not equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure wtasigclipl (data, output, sigma, nimages, npts, lowsig, highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

int		i, j, k, m		# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image val @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    k      = 1
	    m      = 2
	    minval = Meml[data[k]+i-1] / SCALES[k] - ZEROS[k]
	    maxval = Meml[data[m]+i-1] / SCALES[m] - ZEROS[m]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
		m      = 1
		k      = 2
	    }
	    sumval = minval * WTS[k] + maxval * WTS[m]

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 3, nimages {
		val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
		if (val < minval) {
		    minval = val
		    k      = j
		} else if (val > maxval) {
		    maxval = val
		    m      = j
		} 
		sumval = sumval + WTS[j] * val
	    }
	    Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
				(1. - WTS[k] - WTS[m])
	    output[i] = sumval
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = (Meml[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFL(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = (Meml[data[1]+i-1] / SCALES[1] - ZEROS[1] - val) * 
				WTS[1]
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = (Meml[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Meml[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1 - WTS[k])
		Meml[data[k]+i-1] = INDEFL
	    }
	}

	call sfree (sp)
end


#################################################################################
# ASIGCLIP --	Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure asigclipr (data, output, sigma, nimages, npts, lowsig, highsig)

pointer		data[nimages]		# Data lines
real		output[npts]		# Mean line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		i, j, k			# Dummy indexes
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    minval = Memr[data[1]+i-1]
	    maxval = Memr[data[2]+i-1]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
	    }
	    sumval = minval + maxval

# Compute the mean with and without rejecting the extrema.
	    do j = 3, nimages {
		val = Memr[data[j]+i-1]
		if (val < minval) 
		    minval = val
		else if (val > maxval) 
		    maxval = val
		sumval = sumval + val
	    }
	    Memr[mean+i-1] = (sumval - minval - maxval) / (nimages - 2.)
	    output[i] = sumval / nimages
	}

# Compute sigma at each point and the average line sigma.  Correct the sigma 
# at each point for variation in the mean intensity at that point.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = Memr[data[j]+i-1] - val
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFR(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = Memr[data[1]+i-1] - val
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = Memr[data[j]+i-1] - val
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (nimages*output[i] - 
				Memr[data[k]+i-1]) / (nimages - 1.)
		Memr[data[k]+i-1] = INDEFR
	    }
	}

	call sfree (sp)
end


#################################################################################
# DQASIGCLIP -- Combine input image lines, excluding flagged pixels, using 	#
#		the average sigma clip algorithm when weights and scale 	#
#		factors are not equal.  This procedure is based upon the 	#
#		`images.imcombine' package.  					#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure dqasigclipr (data, dqfdata, output, sigma, nimages, npts, lowsig, 
			highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flags @value
int		i, j, k, m		# Dummy indexes
int		ncount			# No. of non-rejected values @pixel
real		maxresid, maxresid2	# Max. deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
real		netwt			# Sum of wts @pixel excluding extrema
real		sumwt			# Sum of weights @pixel 
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)
	do i = 1, npts {

# Select user-chosen Data Quality bits.  
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    m      = 1

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
		    if (val < minval) {
			minval = val
			k      = j
		    } 
		    if (val > maxval) {
			maxval = val
			m      = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) {
		Memr[mean+i-1] = INDEFR
		output[i] = BLANK
		sigma[i]  = BLANK
		next
#  Bug fix 2/93 by RAShaw: exclude the following block if all values rejected
#	    } 
	    } else {
		Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * 
				WTS[m]) / netwt
		output[i] = sumval / sumwt
	    }
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFR(Memr[data[j]+i-1]) && !IS_INDEFR(val)) {
		    resid = (Memr[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    sumval = sumval + resid * resid
		}
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFR(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = 0.
	    maxresid2 = 0.
	    k         = 1
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFR(Memr[data[j]+i-1]) && !IS_INDEFR(val)) {
		    resid = (Memr[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    resid2 = resid * resid 

# Determine the index of the most deviant pixel.  
		    if (resid2 > maxresid2) {
			maxresid  = resid
			maxresid2 = resid2
			k = j
		    }
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memr[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1. - WTS[k])
		Memr[data[k]+i-1] = INDEFR
	    }
	}

	call sfree (sp)
end


#################################################################################
# WTASIGCLIP -- Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are not equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure wtasigclipr (data, output, sigma, nimages, npts, lowsig, highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
real		output[npts]		# Output line (returned)
real		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

int		i, j, k, m		# Dummy indexes
real		maxresid, maxresid2	# Maximum deviation from mean; its square
real		maxval, minval		# Maximum and minimum value @pixel
real		resid, resid2		# Deviation of val from mean; its square
real		sigall			# Average sigma @line
real		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_REAL)

# Initialize variables.
	do i = 1, npts {
	    k      = 1
	    m      = 2
	    minval = Memr[data[k]+i-1] / SCALES[k] - ZEROS[k]
	    maxval = Memr[data[m]+i-1] / SCALES[m] - ZEROS[m]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
		m      = 1
		k      = 2
	    }
	    sumval = minval * WTS[k] + maxval * WTS[m]

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 3, nimages {
		val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
		if (val < minval) {
		    minval = val
		    k      = j
		} else if (val > maxval) {
		    maxval = val
		    m      = j
		} 
		sumval = sumval + WTS[j] * val
	    }
	    Memr[mean+i-1] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
				(1. - WTS[k] - WTS[m])
	    output[i] = sumval
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memr[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = (Memr[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFR(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkr (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memr[mean+i-1]
	    maxresid  = (Memr[data[1]+i-1] / SCALES[1] - ZEROS[1] - val) * 
				WTS[1]
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = (Memr[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memr[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1 - WTS[k])
		Memr[data[k]+i-1] = INDEFR
	    }
	}

	call sfree (sp)
end


#################################################################################
# ASIGCLIP --	Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure asigclipd (data, output, sigma, nimages, npts, lowsig, highsig)

pointer		data[nimages]		# Data lines
double		output[npts]		# Mean line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		i, j, k			# Dummy indexes
double		maxresid, maxresid2	# Max. deviation from mean; its square
double		maxval, minval		# Maximum and minimum value @pixel
double		resid, resid2		# Deviation of val from mean; its square
double		sigall			# Average sigma @line
double		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_DOUBLE)

# Initialize variables.
	do i = 1, npts {
	    minval = Memd[data[1]+i-1]
	    maxval = Memd[data[2]+i-1]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
	    }
	    sumval = minval + maxval

# Compute the mean with and without rejecting the extrema.
	    do j = 3, nimages {
		val = Memd[data[j]+i-1]
		if (val < minval) 
		    minval = val
		else if (val > maxval) 
		    maxval = val
		sumval = sumval + val
	    }
	    Memd[mean+i-1] = (sumval - minval - maxval) / (nimages - 2.)
	    output[i] = sumval / nimages
	}

# Compute sigma at each point and the average line sigma.  Correct the sigma 
# at each point for variation in the mean intensity at that point.  
	sigall = 0.
	do i = 1, npts {
	    val = Memd[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = Memd[data[j]+i-1] - val
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFD(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkd (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memd[mean+i-1]
	    maxresid  = Memd[data[1]+i-1] - val
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = Memd[data[j]+i-1] - val
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (nimages*output[i] - 
				Memd[data[k]+i-1]) / (nimages - 1.)
		Memd[data[k]+i-1] = INDEFD
	    }
	}

	call sfree (sp)
end


#################################################################################
# DQASIGCLIP -- Combine input image lines, excluding flagged pixels, using 	#
#		the average sigma clip algorithm when weights and scale 	#
#		factors are not equal.  This procedure is based upon the 	#
#		`images.imcombine' package.  					#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure dqasigclipd (data, dqfdata, output, sigma, nimages, npts, lowsig, 
			highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
int		dqfdata[nimages]	# Data lines
double		output[npts]		# Output line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

# Local variables:
int		bflag[IMS_MAX]		# User-selected DQF flags @value
int		i, j, k, m		# Dummy indexes
int		ncount			# No. of non-rejected values @pixel
double		maxresid, maxresid2	# Max. deviation from mean; its square
double		maxval, minval		# Maximum and minimum value @pixel
double		resid, resid2		# Deviation of val from mean; its square
double		sigall			# Average sigma @line
double		val, sumval		# Input image value @pixel; accumulation
real		netwt			# Sum of wts @pixel excluding extrema
real		sumwt			# Sum of weights @pixel 
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_DOUBLE)
	do i = 1, npts {

# Select user-chosen Data Quality bits.  
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    m      = 1

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
		    if (val < minval) {
			minval = val
			k      = j
		    } 
		    if (val > maxval) {
			maxval = val
			m      = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) {
		Memd[mean+i-1] = INDEFD
		output[i] = BLANK
		sigma[i]  = BLANK
		next
#  Bug fix 2/93 by RAShaw: exclude the following block if all values rejected
#	    } 
	    } else {
		Memd[mean+i-1] = (sumval - minval * WTS[k] - maxval * 
				WTS[m]) / netwt
		output[i] = sumval / sumwt
	    }
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memd[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFD(Memd[data[j]+i-1]) && !IS_INDEFD(val)) {
		    resid = (Memd[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    sumval = sumval + resid * resid
		}
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFD(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkd (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memd[mean+i-1]
	    maxresid  = 0.
	    maxresid2 = 0.
	    k         = 1
	    do j = 1, nimages {
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#		if (!IS_INDEF(Mem$t[data[j]+i-1])) {
		if (!IS_INDEFD(Memd[data[j]+i-1]) && !IS_INDEFD(val)) {
		    resid = (Memd[data[j]+i-1] / SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		    resid2 = resid * resid 

# Determine the index of the most deviant pixel.  
		    if (resid2 > maxresid2) {
			maxresid  = resid
			maxresid2 = resid2
			k = j
		    }
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memd[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1. - WTS[k])
		Memd[data[k]+i-1] = INDEFD
	    }
	}

	call sfree (sp)
end


#################################################################################
# WTASIGCLIP -- Combine input data lines using the average sigma clip 		#
#		algorithm when weights and scale factors are not equal.  This 	#
#		procedure is based upon the `images.imcombine' package.  	#
#										#
#  Revision history:								#
#	   Jan 91 by RAShaw	Development version				#
#	18 Feb 93 by RAShaw	Protect against val==INDEF; use IS_INDEF 	#
#				macro rather than explicit comparison		#

procedure wtasigclipd (data, output, sigma, nimages, npts, lowsig, highsig)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data lines
double		output[npts]		# Output line (returned)
double		sigma[npts]		# Sigma line (returned)
int		nimages			# Number of input images
int		npts			# Number of pixels/line
real		highsig			# High sigma rejection threshold
real		lowsig			# Low sigma rejection threshold

int		i, j, k, m		# Dummy indexes
double		maxresid, maxresid2	# Maximum deviation from mean; its square
double		maxval, minval		# Maximum and minimum value @pixel
double		resid, resid2		# Deviation of val from mean; its square
double		sigall			# Average sigma @line
double		val, sumval		# Input image value @pixel; accumulation
pointer		sp			# Pointer to stack memory
pointer		mean			# Mean value @pixel, excluding extrema

begin
	call smark (sp)
	call salloc (mean, npts, TY_DOUBLE)

# Initialize variables.
	do i = 1, npts {
	    k      = 1
	    m      = 2
	    minval = Memd[data[k]+i-1] / SCALES[k] - ZEROS[k]
	    maxval = Memd[data[m]+i-1] / SCALES[m] - ZEROS[m]
	    if (minval > maxval) {
		val    = minval
		minval = maxval
		maxval = val
		m      = 1
		k      = 2
	    }
	    sumval = minval * WTS[k] + maxval * WTS[m]

# Compute the scaled and weighted mean with and without rejecting the 
# minimum and maximum points.  
	    do j = 3, nimages {
		val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
		if (val < minval) {
		    minval = val
		    k      = j
		} else if (val > maxval) {
		    maxval = val
		    m      = j
		} 
		sumval = sumval + WTS[j] * val
	    }
	    Memd[mean+i-1] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
				(1. - WTS[k] - WTS[m])
	    output[i] = sumval
	}

# Compute sigma at each point and the average line sigma.  Correct individual 
# residuals for the image scaling and the sigma at each for variation in the 
# mean intensity @pixel.  
	sigall = 0.
	do i = 1, npts {
	    val = Memd[mean+i-1]
	    sumval = 0.
	    do j = 1, nimages {
		resid  = (Memd[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		sumval = sumval + resid * resid
	    }
#  Bug fix 2/93 by RAShaw: protect against val==INDEF
#	    if (val > 0.)
	    if (val > 0. && !IS_INDEFD(val))
	        sigma[i] = sqrt (val)
	    else
	        sigma[i] = 1.
	    sigall = sigall + sqrt (sumval) / sigma[i]
	}
	sigall = sigall / sqrt (nimages - 1.) / npts
	call amulkd (sigma, sigall, sigma, npts)

# Reject the most deviant pixel if it exceeds the high/low sigma threshold.  
	do i = 1, npts {
	    minval = -lowsig * sigma[i]
	    maxval = highsig * sigma[i]
	    val = Memd[mean+i-1]
	    maxresid  = (Memd[data[1]+i-1] / SCALES[1] - ZEROS[1] - val) * 
				WTS[1]
	    maxresid2 = maxresid * maxresid

# Determine the index of the most deviant pixel.  
	    k = 1
	    do j = 2, nimages {
		resid  = (Memd[data[j]+i-1]/ SCALES[j] - ZEROS[j] - val) * 
				WTS[j]
		resid2 = resid * resid 
		if (resid2 > maxresid2) {
		    maxresid  = resid
		    maxresid2 = resid2
		    k = j
		}
	    }
	    if ((maxresid > maxval) || (maxresid < minval)) {
		output[i] = (output[i] - (Memd[data[k]+i-1] / SCALES[k] -
		    ZEROS[k]) * WTS[k]) / (1 - WTS[k])
		Memd[data[k]+i-1] = INDEFD
	    }
	}

	call sfree (sp)
end

