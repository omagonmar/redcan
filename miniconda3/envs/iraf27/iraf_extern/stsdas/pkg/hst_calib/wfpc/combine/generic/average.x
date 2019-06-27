include "wpdef.h"

.help average
.nf ----------------------------------------------------------------------------
                  COMBINING IMAGES: AVERAGING ALGORITHM

The input images are combined by scaling and taking a weighted average.  The
exposure time of the output image, which is written to the output image header, 
is the scaled and weighted average of the input exposure times.

PROCEDURES:

    AVERAGE   -- Average image lines without scaling or weighting. 
    DQAVERAGE -- Average image lines, excluding bad pixels, with scaling and/or 
		 weighting.
    WTAVERAGE -- Average image lines with scaling and/or weighting.
.endhelp -----------------------------------------------------------------------

#$for (silrdx)


#################################################################################
# AVERAGE --	Compute the average of each pixel in the image line without 	#
#		scaling.  These routines are based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure averages (data, avg, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
real		rnimag			# No. images to be combined (rdx)

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    do i = 1, nimages 
		avg[j] = avg[j] + Mems[data[i]+j-1]
	}

# Normalize to nimages:
	rnimag = nimages
	call adivkr (avg, rnimag, avg, npts)
end


#################################################################################
# DQAVERAGE --	Compute the weighted average of each pixel in the image line 	#
# 		using DQF flags.  The input data is type dependent and the 	#
#		output is real.  						#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqaverages (data, dqfdata, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
pointer		dqfdata[nimages]	# Data Quality File pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# DQF flag @value
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected values @pixel
real		sum			# Sum of non-rejected values @pixel
real		wtsum			# Sum of non-rejected weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)
	do j = 1, npts {

# Select user-chosen Data Quality bits:
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, nimages)
	    sum    = 0.
	    wtsum  = 0.
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    sum    = sum + WTS[i] * (Mems[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		    wtsum  = wtsum + WTS[i]
		    ncount = ncount + 1
		} else 				# Skip over DQF flagged data
		    Mems[data[i]+j-1] = INDEFS
	    }

# Normalize to sum of weights:
	    if (wtsum <= 0.) 
		avg[j] = BLANK
	    else
		avg[j] = sum / wtsum
	}
end


#################################################################################
# WTAVERAGE --	Compute the weighted average of each pixel in the image line.  	#
#		The input data is type dependent and the output is real.	#
#										#
#		Development version:	1/91	RAShaw				#
	

procedure wtaverages (data, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes
real		sum			# Weighted sum of values @pixel
real		wtsum			# Sum of weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    sum   = 0.
	    wtsum = 0.
	    do i = 1, nimages {
		sum = sum + WTS[i] * (Mems[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		wtsum  = wtsum + WTS[i]
	    }

# Normalize to nimages:
	    avg[j] = sum / wtsum
	}
end


#################################################################################
# AVERAGE --	Compute the average of each pixel in the image line without 	#
#		scaling.  These routines are based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure averagei (data, avg, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
real		rnimag			# No. images to be combined (rdx)

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    do i = 1, nimages 
		avg[j] = avg[j] + Memi[data[i]+j-1]
	}

# Normalize to nimages:
	rnimag = nimages
	call adivkr (avg, rnimag, avg, npts)
end


#################################################################################
# DQAVERAGE --	Compute the weighted average of each pixel in the image line 	#
# 		using DQF flags.  The input data is type dependent and the 	#
#		output is real.  						#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqaveragei (data, dqfdata, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
pointer		dqfdata[nimages]	# Data Quality File pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# DQF flag @value
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected values @pixel
real		sum			# Sum of non-rejected values @pixel
real		wtsum			# Sum of non-rejected weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)
	do j = 1, npts {

# Select user-chosen Data Quality bits:
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, nimages)
	    sum    = 0.
	    wtsum  = 0.
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    sum    = sum + WTS[i] * (Memi[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		    wtsum  = wtsum + WTS[i]
		    ncount = ncount + 1
		} else 				# Skip over DQF flagged data
		    Memi[data[i]+j-1] = INDEFI
	    }

# Normalize to sum of weights:
	    if (wtsum <= 0.) 
		avg[j] = BLANK
	    else
		avg[j] = sum / wtsum
	}
end


#################################################################################
# WTAVERAGE --	Compute the weighted average of each pixel in the image line.  	#
#		The input data is type dependent and the output is real.	#
#										#
#		Development version:	1/91	RAShaw				#
	

procedure wtaveragei (data, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes
real		sum			# Weighted sum of values @pixel
real		wtsum			# Sum of weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    sum   = 0.
	    wtsum = 0.
	    do i = 1, nimages {
		sum = sum + WTS[i] * (Memi[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		wtsum  = wtsum + WTS[i]
	    }

# Normalize to nimages:
	    avg[j] = sum / wtsum
	}
end


#################################################################################
# AVERAGE --	Compute the average of each pixel in the image line without 	#
#		scaling.  These routines are based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure averagel (data, avg, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
real		rnimag			# No. images to be combined (rdx)

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    do i = 1, nimages 
		avg[j] = avg[j] + Meml[data[i]+j-1]
	}

# Normalize to nimages:
	rnimag = nimages
	call adivkr (avg, rnimag, avg, npts)
end


#################################################################################
# DQAVERAGE --	Compute the weighted average of each pixel in the image line 	#
# 		using DQF flags.  The input data is type dependent and the 	#
#		output is real.  						#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqaveragel (data, dqfdata, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
pointer		dqfdata[nimages]	# Data Quality File pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# DQF flag @value
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected values @pixel
real		sum			# Sum of non-rejected values @pixel
real		wtsum			# Sum of non-rejected weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)
	do j = 1, npts {

# Select user-chosen Data Quality bits:
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, nimages)
	    sum    = 0.
	    wtsum  = 0.
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    sum    = sum + WTS[i] * (Meml[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		    wtsum  = wtsum + WTS[i]
		    ncount = ncount + 1
		} else 				# Skip over DQF flagged data
		    Meml[data[i]+j-1] = INDEFL
	    }

# Normalize to sum of weights:
	    if (wtsum <= 0.) 
		avg[j] = BLANK
	    else
		avg[j] = sum / wtsum
	}
end


#################################################################################
# WTAVERAGE --	Compute the weighted average of each pixel in the image line.  	#
#		The input data is type dependent and the output is real.	#
#										#
#		Development version:	1/91	RAShaw				#
	

procedure wtaveragel (data, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes
real		sum			# Weighted sum of values @pixel
real		wtsum			# Sum of weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    sum   = 0.
	    wtsum = 0.
	    do i = 1, nimages {
		sum = sum + WTS[i] * (Meml[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		wtsum  = wtsum + WTS[i]
	    }

# Normalize to nimages:
	    avg[j] = sum / wtsum
	}
end


#################################################################################
# AVERAGE --	Compute the average of each pixel in the image line without 	#
#		scaling.  These routines are based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure averager (data, avg, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
real		rnimag			# No. images to be combined (rdx)

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    do i = 1, nimages 
		avg[j] = avg[j] + Memr[data[i]+j-1]
	}

# Normalize to nimages:
	rnimag = nimages
	call adivkr (avg, rnimag, avg, npts)
end


#################################################################################
# DQAVERAGE --	Compute the weighted average of each pixel in the image line 	#
# 		using DQF flags.  The input data is type dependent and the 	#
#		output is real.  						#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqaverager (data, dqfdata, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
pointer		dqfdata[nimages]	# Data Quality File pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# DQF flag @value
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected values @pixel
real		sum			# Sum of non-rejected values @pixel
real		wtsum			# Sum of non-rejected weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)
	do j = 1, npts {

# Select user-chosen Data Quality bits:
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, nimages)
	    sum    = 0.
	    wtsum  = 0.
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    sum    = sum + WTS[i] * (Memr[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		    wtsum  = wtsum + WTS[i]
		    ncount = ncount + 1
		} else 				# Skip over DQF flagged data
		    Memr[data[i]+j-1] = INDEFR
	    }

# Normalize to sum of weights:
	    if (wtsum <= 0.) 
		avg[j] = BLANK
	    else
		avg[j] = sum / wtsum
	}
end


#################################################################################
# WTAVERAGE --	Compute the weighted average of each pixel in the image line.  	#
#		The input data is type dependent and the output is real.	#
#										#
#		Development version:	1/91	RAShaw				#
	

procedure wtaverager (data, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
real		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes
real		sum			# Weighted sum of values @pixel
real		wtsum			# Sum of weights @pixel

begin

# Initialize output:
	call aclrr (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    sum   = 0.
	    wtsum = 0.
	    do i = 1, nimages {
		sum = sum + WTS[i] * (Memr[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		wtsum  = wtsum + WTS[i]
	    }

# Normalize to nimages:
	    avg[j] = sum / wtsum
	}
end


#################################################################################
# AVERAGE --	Compute the average of each pixel in the image line without 	#
#		scaling.  These routines are based upon the `images.imcombine' 	#
#		package.  							#
#										#
#		Development version:	1/91	RAShaw				#

procedure averaged (data, avg, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
double		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Dummy indexes
double		rnimag			# No. images to be combined (rdx)

begin

# Initialize output:
	call aclrd (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    do i = 1, nimages 
		avg[j] = avg[j] + Memd[data[i]+j-1]
	}

# Normalize to nimages:
	rnimag = nimages
	call adivkd (avg, rnimag, avg, npts)
end


#################################################################################
# DQAVERAGE --	Compute the weighted average of each pixel in the image line 	#
# 		using DQF flags.  The input data is type dependent and the 	#
#		output is real.  						#
#										#
#		Development version:	1/91	RAShaw				#

procedure dqaveraged (data, dqfdata, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
pointer		dqfdata[nimages]	# Data Quality File pointers
double		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		bflag[IMS_MAX]		# DQF flag @value
int		i, j			# Loop indexes
int		ncount			# Number of non-rejected values @pixel
real		sum			# Sum of non-rejected values @pixel
real		wtsum			# Sum of non-rejected weights @pixel

begin

# Initialize output:
	call aclrd (avg, npts)
	do j = 1, npts {

# Select user-chosen Data Quality bits:
	    do i = 1, nimages
		bflag[i] = Memi[dqfdata[i]+j-1]
	    call aandki (bflag, BADBITS, bflag, nimages)
	    sum    = 0.
	    wtsum  = 0.
	    ncount = 0
	    do i = 1, nimages {
		if (bflag[i] == 0) {
		    sum    = sum + WTS[i] * (Memd[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		    wtsum  = wtsum + WTS[i]
		    ncount = ncount + 1
		} else 				# Skip over DQF flagged data
		    Memd[data[i]+j-1] = INDEFD
	    }

# Normalize to sum of weights:
	    if (wtsum <= 0.) 
		avg[j] = BLANK
	    else
		avg[j] = sum / wtsum
	}
end


#################################################################################
# WTAVERAGE --	Compute the weighted average of each pixel in the image line.  	#
#		The input data is type dependent and the output is real.	#
#										#
#		Development version:	1/91	RAShaw				#
	

procedure wtaveraged (data, avg, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# IMIO data pointers
double		avg[npts]		# Average line (returned)
int		nimages			# Number of images to be combined
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes
real		sum			# Weighted sum of values @pixel
real		wtsum			# Sum of weights @pixel

begin

# Initialize output:
	call aclrd (avg, npts)

# Accumulate sum @pixel:
	do j = 1, npts {
	    sum   = 0.
	    wtsum = 0.
	    do i = 1, nimages {
		sum = sum + WTS[i] * (Memd[data[i]+j-1] / SCALES[i] - 
				ZEROS[i])
		wtsum  = wtsum + WTS[i]
	    }

# Normalize to nimages:
	    avg[j] = sum / wtsum
	}
end

