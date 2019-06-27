include <mach.h>
include "wpdef.h"

.help maxrej
.nf ----------------------------------------------------------------------------
          COMBINING IMAGES: MAXIMUM REJECTION ALGORITHM

For more than one input image they are combined by scaling and taking a weighted 
average excluding the maximum value and, if DQFs are used, flagged bad data.  
The exposure time of the output image is the scaled and weighted average of the 
input image exposure times.  The average is computed in real arithmetic with
trunction on output if the output image is an integer datatype.

PROCEDURES:

    MAXREJ	-- Combine image lines without weighting or scaling.
    DQMAXREJ	-- Combine image lines using Data Quality flags, possibly with 
		   weighting or scaling.  
    WTMAXREJ	-- Combine image lines with weighting or scaling.  
.endhelp -----------------------------------------------------------------------



#################################################################################
# MAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel without weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure maxrejs (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
int		nims			# Total of non-rejected images
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of pixel values
real		val			# Data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    maxval = Mems[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Mems[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + maxval
		    maxval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Mems[data[k]+i-1] = INDEFS
        }
end


#################################################################################
# DQMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel, modulo the Data Quality flags, and possibly with 	#
#		weighting or scaling.  This routine is based on the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmaxrejs (data, dqfdata, output, nimages, npts)

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
int		k			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus maximum wt
real		sumwt			# Sum of weights for each pixel
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			k = j
		    }  
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * maxval) / netwt
		Mems[data[k]+i-1] = INDEFS
	    }
        }
end


#################################################################################
# WTMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel with weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmaxrejs (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Initialize local variables
	    maxval = Mems[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Mems[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + WTS[k] * maxval
		    maxval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Mems[data[k]+i-1] = INDEFS
        }
end


#################################################################################
# MAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel without weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure maxreji (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
int		nims			# Total of non-rejected images
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of pixel values
real		val			# Data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    maxval = Memi[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memi[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + maxval
		    maxval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memi[data[k]+i-1] = INDEFI
        }
end


#################################################################################
# DQMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel, modulo the Data Quality flags, and possibly with 	#
#		weighting or scaling.  This routine is based on the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmaxreji (data, dqfdata, output, nimages, npts)

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
int		k			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus maximum wt
real		sumwt			# Sum of weights for each pixel
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			k = j
		    }  
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * maxval) / netwt
		Memi[data[k]+i-1] = INDEFI
	    }
        }
end


#################################################################################
# WTMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel with weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmaxreji (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Initialize local variables
	    maxval = Memi[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memi[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + WTS[k] * maxval
		    maxval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memi[data[k]+i-1] = INDEFI
        }
end


#################################################################################
# MAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel without weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure maxrejl (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
int		nims			# Total of non-rejected images
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of pixel values
real		val			# Data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    maxval = Meml[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Meml[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + maxval
		    maxval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Meml[data[k]+i-1] = INDEFL
        }
end


#################################################################################
# DQMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel, modulo the Data Quality flags, and possibly with 	#
#		weighting or scaling.  This routine is based on the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmaxrejl (data, dqfdata, output, nimages, npts)

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
int		k			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus maximum wt
real		sumwt			# Sum of weights for each pixel
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			k = j
		    }  
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * maxval) / netwt
		Meml[data[k]+i-1] = INDEFL
	    }
        }
end


#################################################################################
# WTMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel with weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmaxrejl (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Initialize local variables
	    maxval = Meml[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Meml[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + WTS[k] * maxval
		    maxval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Meml[data[k]+i-1] = INDEFL
        }
end


#################################################################################
# MAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel without weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure maxrejr (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
int		nims			# Total of non-rejected images
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of pixel values
real		val			# Data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    maxval = Memr[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memr[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + maxval
		    maxval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memr[data[k]+i-1] = INDEFR
        }
end


#################################################################################
# DQMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel, modulo the Data Quality flags, and possibly with 	#
#		weighting or scaling.  This routine is based on the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmaxrejr (data, dqfdata, output, nimages, npts)

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
int		k			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus maximum wt
real		sumwt			# Sum of weights for each pixel
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			k = j
		    }  
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * maxval) / netwt
		Memr[data[k]+i-1] = INDEFR
	    }
        }
end


#################################################################################
# WTMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel with weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmaxrejr (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
real		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
real		maxval			# Largest data value @pixel
real		sumval			# Running sum of non-flagged pixel values
real		val			# Data value @pixel

begin
	do i = 1, npts {

# Initialize local variables
	    maxval = Memr[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memr[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + WTS[k] * maxval
		    maxval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memr[data[k]+i-1] = INDEFR
        }
end


#################################################################################
# MAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel without weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure maxrejd (data, output, nimages, npts)

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
int		nims			# Total of non-rejected images
double		maxval			# Largest data value @pixel
double		sumval			# Running sum of pixel values
double		val			# Data value @pixel

begin
	nims = nimages - 1
	do i = 1, npts {
	    sumval = 0.
	    maxval = Memd[data[1]+i-1]
	    k = 1
	    do j = 2, nimages {
	        val = Memd[data[j]+i-1]
#	        $if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + maxval
		    maxval = val
		    k      = j
		} else
		    sumval = sumval + val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / nims
	    Memd[data[k]+i-1] = INDEFD
        }
end


#################################################################################
# DQMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel, modulo the Data Quality flags, and possibly with 	#
#		weighting or scaling.  This routine is based on the 		#
#		`images.imcombine' package.  					#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqmaxrejd (data, dqfdata, output, nimages, npts)

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
int		k			# Index of maximum value
int		ncount			# Total of non-rejected pixels
real		netwt			# Sum of weights minus maximum wt
real		sumwt			# Sum of weights for each pixel
double		maxval			# Largest data value @pixel
double		sumval			# Running sum of non-flagged pixel values
double		val			# Data value @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits:
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, nimages)

# Initialize other variables
	    maxval = -MAX_REAL
	    sumval = 0.
	    sumwt  = 0.
	    k      = 1
	    ncount = 0
	    do j = 1, nimages { 
		if (bflag[j] == 0) {
		    ncount = ncount + 1
		    val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		    $if (datatype == x)
#		    if (abs(val) > abs(maxval)) {
#		    $else
		    if (val > maxval) {
#		    $endif
			maxval = val
			k = j
		    }  
		    sumval = sumval + WTS[j] * val
		    sumwt  = sumwt + WTS[j]
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    netwt = sumwt - WTS[k]
	    if (netwt <= 0.) 
		output[i] = BLANK
	    else {
		output[i] = (sumval - WTS[k] * maxval) / netwt
		Memd[data[k]+i-1] = INDEFD
	    }
        }
end


#################################################################################
# WTMAXREJ --	Combine image lines after rejecting the maximum value at each 	#
#		pixel with weighting or scaling.  This routine is based on 	#
#		the `images.imcombine' package.  				#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtmaxrejd (data, output, nimages, npts)

include "wpcom.h"

# Passed arguments:
pointer		data[nimages]		# IMIO data pointers
double		output[npts]		# Output line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy loop counters
int		k			# Index of maximum value
double		maxval			# Largest data value @pixel
double		sumval			# Running sum of non-flagged pixel values
double		val			# Data value @pixel

begin
	do i = 1, npts {

# Initialize local variables
	    maxval = Memd[data[1]+i-1] / SCALES[1] - ZEROS[1]
	    sumval = 0.
	    k      = 1
	    do j = 2, nimages { 
		val = Memd[data[j]+i-1] / SCALES[j] - ZEROS[j]
#		$if (datatype == x)
#		if (abs(val) > abs(maxval)) {
#		$else
		if (val > maxval) {
#		$endif
		    sumval = sumval + WTS[k] * maxval
		    maxval = val
		    k = j
		} else 
		    sumval = sumval + WTS[j] * val
	    }

# Store output value and set maximum value in working data array to INDEF for 
# future use (e.g., in SIGMA routine).  
	    output[i] = sumval / (1. - WTS[k])
	    Memd[data[k]+i-1] = INDEFD
        }
end


