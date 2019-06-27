include <mach.h>
include "wpdef.h"

.help minrej
.nf ----------------------------------------------------------------------------
          COMBINING IMAGES: MINIMUM REJECTION ALGORITHM

For more than two input images they are combined by scaling and taking a weighted 
average excluding the minimum value and, if DQFs are used, flagged bad data.  
The exposure time of the output image is the scaled and weighted average of the 
input image exposure times.  The average is computed in real arithmetic with
trunction on output if the output image is an integer datatype.

PROCEDURES:

    MINREJ	-- Combine image lines after rejecting the minimum value at 
		   each pixel, without weighting or scaling. 
    DQMINREJ	-- Combine image lines using Data Quality flags, after rejecting 
		   the minimum value at each pixel, possibly with weighting 
		   and/or scaling. 
    WTMINREJ	-- Combine image lines after rejecting the minimum value at 
		   each pixel, with weighting and/or scaling.
.endhelp -----------------------------------------------------------------------

#$for (silrdx)


#################################################################################
# MINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel without weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure minrejs (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		nims			# Total of non-rejected images
real		val			# Data value @pixel
real		sumval			# Running sum of pixel values
real		minval			# Smallest data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    minval = Mems[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Mems[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + minval
		    minval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Mems[data[k]+i-1] = INDEFS
        }
end


#################################################################################
# DQMINREJ --	Combine image lines, modulo the Data Quality flags, after 	#
#		rejecting the minimum value at each pixel and possibly with 	#
#		weighting or scaling.  This routine is based upon the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqminrejs (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointer
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus minimum wt
real		sumwt			# Sum of weights for each pixel
real		val			# Data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		minval			# Smallest data value @line

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    minval = +MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * minval) / netwt
		Mems[data[k]+i-1] = INDEFS
	    }
        }
end


#################################################################################
# WTMINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel with weighting and/or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtminrejs (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
real		val			# Data value @pixel
real		minval			# Smallest data value @pixel
real		sumval			# Running sum of non-flagged pixel values

begin
	do i = 1, npts {

# Initialize local variables.  
	    minval = Mems[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + WTS[k] * minval
		    minval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Mems[data[k]+i-1] = INDEFS
        }
end


#################################################################################
# MINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel without weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure minreji (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		nims			# Total of non-rejected images
real		val			# Data value @pixel
real		sumval			# Running sum of pixel values
real		minval			# Smallest data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    minval = Memi[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memi[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + minval
		    minval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memi[data[k]+i-1] = INDEFI
        }
end


#################################################################################
# DQMINREJ --	Combine image lines, modulo the Data Quality flags, after 	#
#		rejecting the minimum value at each pixel and possibly with 	#
#		weighting or scaling.  This routine is based upon the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqminreji (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointer
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus minimum wt
real		sumwt			# Sum of weights for each pixel
real		val			# Data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		minval			# Smallest data value @line

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    minval = +MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * minval) / netwt
		Memi[data[k]+i-1] = INDEFI
	    }
        }
end


#################################################################################
# WTMINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel with weighting and/or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtminreji (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
real		val			# Data value @pixel
real		minval			# Smallest data value @pixel
real		sumval			# Running sum of non-flagged pixel values

begin
	do i = 1, npts {

# Initialize local variables.  
	    minval = Memi[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + WTS[k] * minval
		    minval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memi[data[k]+i-1] = INDEFI
        }
end


#################################################################################
# MINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel without weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure minrejl (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		nims			# Total of non-rejected images
real		val			# Data value @pixel
real		sumval			# Running sum of pixel values
real		minval			# Smallest data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    minval = Meml[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Meml[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + minval
		    minval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Meml[data[k]+i-1] = INDEFL
        }
end


#################################################################################
# DQMINREJ --	Combine image lines, modulo the Data Quality flags, after 	#
#		rejecting the minimum value at each pixel and possibly with 	#
#		weighting or scaling.  This routine is based upon the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqminrejl (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointer
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus minimum wt
real		sumwt			# Sum of weights for each pixel
real		val			# Data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		minval			# Smallest data value @line

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    minval = +MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * minval) / netwt
		Meml[data[k]+i-1] = INDEFL
	    }
        }
end


#################################################################################
# WTMINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel with weighting and/or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtminrejl (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
real		val			# Data value @pixel
real		minval			# Smallest data value @pixel
real		sumval			# Running sum of non-flagged pixel values

begin
	do i = 1, npts {

# Initialize local variables.  
	    minval = Meml[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + WTS[k] * minval
		    minval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Meml[data[k]+i-1] = INDEFL
        }
end


#################################################################################
# MINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel without weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure minrejr (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		nims			# Total of non-rejected images
real		val			# Data value @pixel
real		sumval			# Running sum of pixel values
real		minval			# Smallest data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    minval = Memr[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memr[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + minval
		    minval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memr[data[k]+i-1] = INDEFR
        }
end


#################################################################################
# DQMINREJ --	Combine image lines, modulo the Data Quality flags, after 	#
#		rejecting the minimum value at each pixel and possibly with 	#
#		weighting or scaling.  This routine is based upon the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqminrejr (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointer
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus minimum wt
real		sumwt			# Sum of weights for each pixel
real		val			# Data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		minval			# Smallest data value @line

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    minval = +MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * minval) / netwt
		Memr[data[k]+i-1] = INDEFR
	    }
        }
end


#################################################################################
# WTMINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel with weighting and/or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtminrejr (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
real		val			# Data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		minval			# Smallest data value @pixel

begin
	do i = 1, npts {

# Initialize local variables.  
	    minval = Memr[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + WTS[k] * minval
		    minval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memr[data[k]+i-1] = INDEFR
        }
end


#################################################################################
# MINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel without weighting or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure minrejd (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		nims			# Total of non-rejected images
double		val			# Data value @pixel
double		sumval			# Running sum of pixel values
double		minval			# Smallest data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    minval = Memd[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memd[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + minval
		    minval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memd[data[k]+i-1] = INDEFD
        }
end


#################################################################################
# DQMINREJ --	Combine image lines, modulo the Data Quality flags, after 	#
#		rejecting the minimum value at each pixel and possibly with 	#
#		weighting or scaling.  This routine is based upon the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqminrejd (data, dqfdata, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality File pointer
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# 
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus minimum wt
real		sumwt			# Sum of weights for each pixel
double		val			# Data value @pixel
double		sumval			# Running sum of non-flagged pixel values
double		minval			# Smallest data value @line

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    minval = +MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) < abs(minval)) {
#		    $else
		    if (val < minval) {
#		    $endif
			minval = val
			k = j
		    } 
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * minval) / netwt
		Memd[data[k]+i-1] = INDEFD
	    }
        }
end


#################################################################################
# WTMINREJ --	Combine image lines after rejecting the minimum value at each 	#
#		pixel with weighting and/or scaling.  This routine is based 	#
#		upon the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtminrejd (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of minimum value
double		val			# Data value @pixel
double		sumval			# Running sum of non-flagged pixel values
double		minval			# Smallest data value @pixel

begin
	do i = 1, npts {

# Initialize local variables.  
	    minval = Memd[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) < abs(minval)) {
#		$else
		if (val < minval) {
#		$endif
		    sumval = sumval + WTS[k] * minval
		    minval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Save output value and set minimum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memd[data[k]+i-1] = INDEFD
        }
end


