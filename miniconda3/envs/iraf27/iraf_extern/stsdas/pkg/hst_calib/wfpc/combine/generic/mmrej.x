include	<mach.h>
include "wpdef.h"

.help mmrej
.nf ----------------------------------------------------------------------------
         COMBINING IMAGES: MINMAX REJECTION ALGORITHM

If there is only one input image then it is copied to the output image.
If there are two input images then it is an error.  For more than two
input images they are combined by scaling and taking a weighted average 
excluding the minimum and maximum values.  The exposure time of the output 
image is the scaled and weighted average of the input exposure times.  The 
average is computed in real arithmetic with trunction on output if the 
output image is an integer datatype.  

PROCEDURES:

    MMREJ --	Combine image lines after rejecting the minimum and maximum 
		values, with no weighting or scaling.  
    DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 
		flagged values, with weighting or scaling.  
    WTMMREJ --	Combine image lines after rejecting the minimum and maximum 
		values, with weighting or scaling.  

.endhelp -----------------------------------------------------------------------

#$for (silrdx)


#################################################################################
# MMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, without weighting or scaling. 	This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure mmrejs (data, output, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		nims			# Number of non-rejected images
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	nims = nimages - 2
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		val = Mems[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#	        $else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#	        $else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval - maxval) / nims
	    Mems[data[k]+i-1] = INDEFS
	    Mems[data[m]+i-1] = INDEFS
        }
end


#################################################################################
# DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 	#
#		flagged values, with weighting or scaling.  This routine is 	#
#		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmmrejs (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus min & max weight
real		sumwt			# Sum of weights for each pixel 
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    sumval = 0.
	    sumwt  = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    ncount = 0
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			m = j
		    } 
		    sumval = sumval + val * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / netwt
		Mems[data[k]+i-1] = INDEFS
		Mems[data[m]+i-1] = INDEFS
	    }
        }
end


#################################################################################
# WTMMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, with weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmmrejs (data, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k = 1
	    m = 1
	    do j = 1, nimages {
		val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + WTS[j] * val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
			(1. - WTS[k] - WTS[m])
	    Mems[data[k]+i-1] = INDEFS
	    Mems[data[m]+i-1] = INDEFS
        }
end


#################################################################################
# MMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, without weighting or scaling. 	This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure mmreji (data, output, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		nims			# Number of non-rejected images
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	nims = nimages - 2
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		val = Memi[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#	        $else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#	        $else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval - maxval) / nims
	    Memi[data[k]+i-1] = INDEFI
	    Memi[data[m]+i-1] = INDEFI
        }
end


#################################################################################
# DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 	#
#		flagged values, with weighting or scaling.  This routine is 	#
#		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmmreji (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus min & max weight
real		sumwt			# Sum of weights for each pixel 
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    sumval = 0.
	    sumwt  = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    ncount = 0
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			m = j
		    } 
		    sumval = sumval + val * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / netwt
		Memi[data[k]+i-1] = INDEFI
		Memi[data[m]+i-1] = INDEFI
	    }
        }
end


#################################################################################
# WTMMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, with weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmmreji (data, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k = 1
	    m = 1
	    do j = 1, nimages {
		val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + WTS[j] * val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
			(1. - WTS[k] - WTS[m])
	    Memi[data[k]+i-1] = INDEFI
	    Memi[data[m]+i-1] = INDEFI
        }
end


#################################################################################
# MMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, without weighting or scaling. 	This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure mmrejl (data, output, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		nims			# Number of non-rejected images
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	nims = nimages - 2
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		val = Meml[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#	        $else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#	        $else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval - maxval) / nims
	    Meml[data[k]+i-1] = INDEFL
	    Meml[data[m]+i-1] = INDEFL
        }
end


#################################################################################
# DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 	#
#		flagged values, with weighting or scaling.  This routine is 	#
#		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmmrejl (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus min & max weight
real		sumwt			# Sum of weights for each pixel 
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    sumval = 0.
	    sumwt  = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    ncount = 0
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			m = j
		    } 
		    sumval = sumval + val * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / netwt
		Meml[data[k]+i-1] = INDEFL
		Meml[data[m]+i-1] = INDEFL
	    }
        }
end


#################################################################################
# WTMMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, with weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmmrejl (data, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval			# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k = 1
	    m = 1
	    do j = 1, nimages {
		val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + WTS[j] * val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
			(1. - WTS[k] - WTS[m])
	    Meml[data[k]+i-1] = INDEFL
	    Meml[data[m]+i-1] = INDEFL
        }
end


#################################################################################
# MMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, without weighting or scaling. 	This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure mmrejr (data, output, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		nims			# Number of non-rejected images
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval		 	# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	nims = nimages - 2
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		val = Memr[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#	        $else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#	        $else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval - maxval) / nims
	    Memr[data[k]+i-1] = INDEFR
	    Memr[data[m]+i-1] = INDEFR
        }
end


#################################################################################
# DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 	#
#		flagged values, with weighting or scaling.  This routine is 	#
#		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmmrejr (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus min & max weight
real		sumwt			# Sum of weights for each pixel 
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval		 	# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    sumval = 0.
	    sumwt  = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    ncount = 0
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			m = j
		    } 
		    sumval = sumval + val * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / netwt
		Memr[data[k]+i-1] = INDEFR
		Memr[data[m]+i-1] = INDEFR
	    }
        }
end


#################################################################################
# WTMMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, with weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmmrejr (data, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
real		sumval			# Sum of non-rejected values @pixel
real		val			# Data value
real		minval		 	# Minimum value @pixel
real		maxval			# Maximum value @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k = 1
	    m = 1
	    do j = 1, nimages {
		val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + WTS[j] * val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
			(1. - WTS[k] - WTS[m])
	    Memr[data[k]+i-1] = INDEFR
	    Memr[data[m]+i-1] = INDEFR
        }
end


#################################################################################
# MMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, without weighting or scaling. 	This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure mmrejd (data, output, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		nims			# Number of non-rejected images
double		sumval			# Sum of non-rejected values @pixel
double		val			# Data value
double		minval		 	# Minimum value @pixel
double		maxval			# Maximum value @pixel

begin
	nims = nimages - 2
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		val = Memd[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#	        $else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#	        $else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval - maxval) / nims
	    Memd[data[k]+i-1] = INDEFD
	    Memd[data[m]+i-1] = INDEFD
        }
end


#################################################################################
# DQMMREJ --	Combine image lines after rejecting the minimum, maximum and 	#
#		flagged values, with weighting or scaling.  This routine is 	#
#		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmmrejd (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus min & max weight
real		sumwt			# Sum of weights for each pixel 
double		sumval			# Sum of non-rejected values @pixel
double		val			# Data value
double		minval		 	# Minimum value @pixel
double		maxval			# Maximum value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    sumval = 0.
	    sumwt  = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    ncount = 0
	    k      = 1
	    m      = 1
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			m = j
		    } 
		    sumval = sumval + val * WTS[j]
		    sumwt  = sumwt + WTS[j]
		    ncount = ncount + 1
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k] - WTS[m]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / netwt
		Memd[data[k]+i-1] = INDEFD
		Memd[data[m]+i-1] = INDEFD
	    }
        }
end


#################################################################################
# WTMMREJ --	Combine image lines after rejecting the minimum and maximum 	#
#		values, with weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmmrejd (data, output, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
int		k			# Index of minimum value
int		m			# Index of maximum value
double		sumval			# Sum of non-rejected values @pixel
double		val			# Data value
double		minval		 	# Minimum value @pixel
double		maxval			# Maximum value @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    minval = +MAX_REAL
	    maxval = -MAX_REAL
	    k = 1
	    m = 1
	    do j = 1, nimages {
		val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    minval = val
		    k = j
		} 
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    maxval = val
		    m = j
		} 
		sumval = sumval + WTS[j] * val
	    }

# Save output value and set min/max values in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = (sumval - minval * WTS[k] - maxval * WTS[m]) / 
			(1. - WTS[k] - WTS[m])
	    Memd[data[k]+i-1] = INDEFD
	    Memd[data[m]+i-1] = INDEFD
        }
end

