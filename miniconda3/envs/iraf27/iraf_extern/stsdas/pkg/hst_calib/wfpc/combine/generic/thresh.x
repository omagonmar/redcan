include "wpdef.h"

.help threshold
.nf ----------------------------------------------------------------------------
          COMBINING IMAGES: THRESHOLD REJECTION ALGORITHM

The input images are combined by scaling and taking a weighted average.  
Pixels having values below and above a rejection threshold (before scaling) 
are excluded from the average.  The exposure time of the output image is 
the scaled and weighted average of the input exposure times.  The average 
is computed in real arithmetic with trunction on output if the output image 
is an integer datatype.  

PROCEDURES:

    THRESHOLD --   Average lines, rejecting values that fall above or below 
		   the user selected thresholds (SCALES and weights equal).
    DQTHRESHOLD -- Average image lines, rejecting values that fall above or 
		   below the user selected thresholds (SCALES and weights 
		   unequal).
    WTTHRESHOLD -- Average image lines, rejecting values that fall above or 
		   below the user selected thresholds (SCALES and weights 
		   unequal).
.endhelp ----------------------------------------------------------------------

#$for (silrdx)


#################################################################################
# THRESHOLD --	Compute the average image line with threshold rejection.  The 	#
# 		input data is type dependent and the output is real.  Each 	#
# 		input image, given by an array of image pointers, is scaled 	#
# 		and then a weighted average is computed rejecting values which 	#
#		are outside the lower and upper threshold.  The output image 	#
# 		header is updated to include a scaled and weighted exposure 	#
# 		time and the number of images combined.  This routine is 	#
# 		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure thresholds (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
int		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    sumwt  = 0
	    do j = 1, nimages {
		val = Mems[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Mems[data[j]+i-1] = INDEFS
		else {
		   sumval = sumval + val
		   sumwt  = sumwt + 1
		}
	    }
	    ncount = sumwt
	    if (sumwt > 0)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# DQTHRESHOLD -- Compute the weighted average image line with threshold 	#
# 		rejection.  The input data is type dependent and the output 	#
#		is real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqthresholds (data, dqfdata, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality flag pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		bflag[IMS_MAX]		# 
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits.
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, npts)

	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Mems[data[j]+i-1]
#		    $if (datatype == x)
#		    absval = abs (val)
#		    if ((absval < low) || (absval > high))
#		    $else
		    if ((val < low) || (val > high))
#		    $endif
			Mems[data[j]+i-1] = INDEFS
		    else {
			sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
			sumwt  = sumwt  + WTS[j]
			ncount = ncount + 1
		    }
		} else 
		    Mems[data[j]+i-1] = INDEFS
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# WTTHRESHOLD -- Compute the weighted average image line with threshold 	#
#		rejection.  The input data is type dependent and the output is 	#
#		real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtthresholds (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		val = Mems[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Mems[data[j]+i-1] = INDEFS
		else {
		    sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
		    sumwt  = sumwt  + WTS[j]
		    ncount = ncount + 1
		}
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# THRESHOLD --	Compute the average image line with threshold rejection.  The 	#
# 		input data is type dependent and the output is real.  Each 	#
# 		input image, given by an array of image pointers, is scaled 	#
# 		and then a weighted average is computed rejecting values which 	#
#		are outside the lower and upper threshold.  The output image 	#
# 		header is updated to include a scaled and weighted exposure 	#
# 		time and the number of images combined.  This routine is 	#
# 		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure thresholdi (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
int		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    sumwt  = 0
	    do j = 1, nimages {
		val = Memi[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memi[data[j]+i-1] = INDEFI
		else {
		   sumval = sumval + val
		   sumwt  = sumwt + 1
		}
	    }
	    ncount = sumwt
	    if (sumwt > 0)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# DQTHRESHOLD -- Compute the weighted average image line with threshold 	#
# 		rejection.  The input data is type dependent and the output 	#
#		is real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqthresholdi (data, dqfdata, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality flag pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		bflag[IMS_MAX]		# 
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits.
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, npts)

	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memi[data[j]+i-1]
#		    $if (datatype == x)
#		    absval = abs (val)
#		    if ((absval < low) || (absval > high))
#		    $else
		    if ((val < low) || (val > high))
#		    $endif
			Memi[data[j]+i-1] = INDEFI
		    else {
			sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
			sumwt  = sumwt  + WTS[j]
			ncount = ncount + 1
		    }
		} else 
		    Memi[data[j]+i-1] = INDEFI
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# WTTHRESHOLD -- Compute the weighted average image line with threshold 	#
#		rejection.  The input data is type dependent and the output is 	#
#		real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtthresholdi (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		val = Memi[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memi[data[j]+i-1] = INDEFI
		else {
		    sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
		    sumwt  = sumwt  + WTS[j]
		    ncount = ncount + 1
		}
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# THRESHOLD --	Compute the average image line with threshold rejection.  The 	#
# 		input data is type dependent and the output is real.  Each 	#
# 		input image, given by an array of image pointers, is scaled 	#
# 		and then a weighted average is computed rejecting values which 	#
#		are outside the lower and upper threshold.  The output image 	#
# 		header is updated to include a scaled and weighted exposure 	#
# 		time and the number of images combined.  This routine is 	#
# 		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure thresholdl (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
int		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    sumwt  = 0
	    do j = 1, nimages {
		val = Meml[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Meml[data[j]+i-1] = INDEFL
		else {
		   sumval = sumval + val
		   sumwt  = sumwt + 1
		}
	    }
	    ncount = sumwt
	    if (sumwt > 0)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# DQTHRESHOLD -- Compute the weighted average image line with threshold 	#
# 		rejection.  The input data is type dependent and the output 	#
#		is real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqthresholdl (data, dqfdata, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality flag pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		bflag[IMS_MAX]		# 
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits.
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, npts)

	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Meml[data[j]+i-1]
#		    $if (datatype == x)
#		    absval = abs (val)
#		    if ((absval < low) || (absval > high))
#		    $else
		    if ((val < low) || (val > high))
#		    $endif
			Meml[data[j]+i-1] = INDEFL
		    else {
			sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
			sumwt  = sumwt  + WTS[j]
			ncount = ncount + 1
		    }
		} else 
		    Meml[data[j]+i-1] = INDEFL
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# WTTHRESHOLD -- Compute the weighted average image line with threshold 	#
#		rejection.  The input data is type dependent and the output is 	#
#		real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtthresholdl (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		val = Meml[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Meml[data[j]+i-1] = INDEFL
		else {
		    sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
		    sumwt  = sumwt  + WTS[j]
		    ncount = ncount + 1
		}
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# THRESHOLD --	Compute the average image line with threshold rejection.  The 	#
# 		input data is type dependent and the output is real.  Each 	#
# 		input image, given by an array of image pointers, is scaled 	#
# 		and then a weighted average is computed rejecting values which 	#
#		are outside the lower and upper threshold.  The output image 	#
# 		header is updated to include a scaled and weighted exposure 	#
# 		time and the number of images combined.  This routine is 	#
# 		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure thresholdr (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
int		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    sumwt  = 0
	    do j = 1, nimages {
		val = Memr[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memr[data[j]+i-1] = INDEFR
		else {
		   sumval = sumval + val
		   sumwt  = sumwt + 1
		}
	    }
	    ncount = sumwt
	    if (sumwt > 0)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# DQTHRESHOLD -- Compute the weighted average image line with threshold 	#
# 		rejection.  The input data is type dependent and the output 	#
#		is real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqthresholdr (data, dqfdata, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality flag pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		bflag[IMS_MAX]		# 
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits.
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, npts)

	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memr[data[j]+i-1]
#		    $if (datatype == x)
#		    absval = abs (val)
#		    if ((absval < low) || (absval > high))
#		    $else
		    if ((val < low) || (val > high))
#		    $endif
			Memr[data[j]+i-1] = INDEFR
		    else {
			sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
			sumwt  = sumwt  + WTS[j]
			ncount = ncount + 1
		    }
		} else 
		    Memr[data[j]+i-1] = INDEFR
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# WTTHRESHOLD -- Compute the weighted average image line with threshold 	#
#		rejection.  The input data is type dependent and the output is 	#
#		real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtthresholdr (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
real		sumval			# Running sum of values @pixel
real		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		val = Memr[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memr[data[j]+i-1] = INDEFR
		else {
		    sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
		    sumwt  = sumwt  + WTS[j]
		    ncount = ncount + 1
		}
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# THRESHOLD --	Compute the average image line with threshold rejection.  The 	#
# 		input data is type dependent and the output is real.  Each 	#
# 		input image, given by an array of image pointers, is scaled 	#
# 		and then a weighted average is computed rejecting values which 	#
#		are outside the lower and upper threshold.  The output image 	#
# 		header is updated to include a scaled and weighted exposure 	#
# 		time and the number of images combined.  This routine is 	#
# 		based upon the `images.imcombine' package.  			#
#										#
#		Development version:	1/91	RAShaw				#

procedure thresholdd (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data pointers
double		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
double		sumval			# Running sum of values @pixel
double		val			# Value of input image @pixel
int		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    sumval = 0.
	    sumwt  = 0
	    do j = 1, nimages {
		val = Memd[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memd[data[j]+i-1] = INDEFD
		else {
		   sumval = sumval + val
		   sumwt  = sumwt + 1
		}
	    }
	    ncount = sumwt
	    if (sumwt > 0)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# DQTHRESHOLD -- Compute the weighted average image line with threshold 	#
# 		rejection.  The input data is type dependent and the output 	#
#		is real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqthresholdd (data, dqfdata, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
int		dqfdata[nimages]	# Data Quality flag pointers
double		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		bflag[IMS_MAX]		# 
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
double		sumval			# Running sum of values @pixel
double		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {

# Select user-chosen Data Quality bits.
	    do j = 1, nimages
		bflag[j] = Memi[dqfdata[j]+i-1]
	    call aandki (bflag, BADBITS, bflag, npts)

	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		if (bflag[j] == 0) {
		    val = Memd[data[j]+i-1]
#		    $if (datatype == x)
#		    absval = abs (val)
#		    if ((absval < low) || (absval > high))
#		    $else
		    if ((val < low) || (val > high))
#		    $endif
			Memd[data[j]+i-1] = INDEFD
		    else {
			sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
			sumwt  = sumwt  + WTS[j]
			ncount = ncount + 1
		    }
		} else 
		    Memd[data[j]+i-1] = INDEFD
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end


#################################################################################
# WTTHRESHOLD -- Compute the weighted average image line with threshold 	#
#		rejection.  The input data is type dependent and the output is 	#
#		real.  This routine is based upon the `images.imcombine' 	#
# 		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure wtthresholdd (data, average, nimages, npts, low, high)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
double		average[npts]		# Average line (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line
real		low			# Low rejection threshold
real		high			# Low rejection threshold

# Local variables:
#$if (datatype == x)
#real		absval			# Value of input image @pixel
#$endif
int		i, j			# Loop counters
int		ncount			# Total no. of non-rejected pixels 
double		sumval			# Running sum of values @pixel
double		val			# Value of input image @pixel
real		sumwt			# Sum of weights @pixel

begin
	do i = 1, npts {
	    ncount = 0
	    sumval = 0.
	    sumwt  = 0.
	    do j = 1, nimages {
		val = Memd[data[j]+i-1]
#	        $if (datatype == x)
#		absval = abs (val)
#		if ((absval < low) || (absval > high))
#	        $else
		if ((val < low) || (val > high))
#		$endif
		    Memd[data[j]+i-1] = INDEFD
		else {
		    sumval = sumval + WTS[j] * val / SCALES[j] - ZEROS[j]
		    sumwt  = sumwt  + WTS[j]
		    ncount = ncount + 1
		}
	    }
	    if (sumwt > 0.)
		average[i] = sumval / sumwt
	    else
		average[i] = BLANK
	}
end

