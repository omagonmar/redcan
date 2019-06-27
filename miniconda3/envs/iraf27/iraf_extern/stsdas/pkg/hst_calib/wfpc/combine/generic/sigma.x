include "wpdef.h"

#$for (silrdx)

#################################################################################
# SIGMA --	Compute sigma line from image lines with rejection.  Based 	#
#		upon the `images.imcombine' package.				#
#										#
#		Development version:	11/90	RAShaw				#

procedure sigmas (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

real		sig, pixval
int		i, j			# Loop counters
int		ncount			# Number of non-rejected values @pixel

begin	do i = 1, npts {
	    sig    = 0.
	    ncount = nimages
	    do j = 1, nimages {
		pixval = Mems[data[j]+i-1]
		if (IS_INDEFS (pixval))
		    ncount = ncount - 1
		else
		    sig = sig + (pixval - mean[i]) ** 2
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# WGTSIGMA --	Compute scaled and weighted sigma line from image lines with 	#
#		rejection.  Based upon the `images.imcombine' package.		#
#										#
#		Development version:	11/90	RAShaw				#

procedure wgtsigmas (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop counters
int		ncount			# number of non-rejected values @pixel
real		sig, pixval
real		sumwts

begin
	do i = 1, npts {
	    ncount = 0
	    sig    = 0.
	    sumwts = 0.
	    do j = 1, nimages {
		pixval = Mems[data[j]+i-1]
		if (!IS_INDEFS (pixval)) {
		    ncount = ncount + 1
		    sig    = sig + WTS[j] * (pixval / SCALES[j] - ZEROS[j] - 
				mean[i]) ** 2
		    sumwts = sumwts + WTS[j]
		}
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / sumwts * ncount / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# SIGMA --	Compute sigma line from image lines with rejection.  Based 	#
#		upon the `images.imcombine' package.				#
#										#
#		Development version:	11/90	RAShaw				#

procedure sigmai (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

real		sig, pixval
int		i, j			# Loop counters
int		ncount			# Number of non-rejected values @pixel

begin	do i = 1, npts {
	    sig    = 0.
	    ncount = nimages
	    do j = 1, nimages {
		pixval = Memi[data[j]+i-1]
		if (IS_INDEFI (pixval))
		    ncount = ncount - 1
		else
		    sig = sig + (pixval - mean[i]) ** 2
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# WGTSIGMA --	Compute scaled and weighted sigma line from image lines with 	#
#		rejection.  Based upon the `images.imcombine' package.		#
#										#
#		Development version:	11/90	RAShaw				#

procedure wgtsigmai (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop counters
int		ncount			# number of non-rejected values @pixel
real		sig, pixval
real		sumwts

begin
	do i = 1, npts {
	    ncount = 0
	    sig    = 0.
	    sumwts = 0.
	    do j = 1, nimages {
		pixval = Memi[data[j]+i-1]
		if (!IS_INDEFI (pixval)) {
		    ncount = ncount + 1
		    sig    = sig + WTS[j] * (pixval / SCALES[j] - ZEROS[j] - 
				mean[i]) ** 2
		    sumwts = sumwts + WTS[j]
		}
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / sumwts * ncount / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# SIGMA --	Compute sigma line from image lines with rejection.  Based 	#
#		upon the `images.imcombine' package.				#
#										#
#		Development version:	11/90	RAShaw				#

procedure sigmal (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

real		sig, pixval
int		i, j			# Loop counters
int		ncount			# Number of non-rejected values @pixel

begin	do i = 1, npts {
	    sig    = 0.
	    ncount = nimages
	    do j = 1, nimages {
		pixval = Meml[data[j]+i-1]
		if (IS_INDEFL (pixval))
		    ncount = ncount - 1
		else
		    sig = sig + (pixval - mean[i]) ** 2
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# WGTSIGMA --	Compute scaled and weighted sigma line from image lines with 	#
#		rejection.  Based upon the `images.imcombine' package.		#
#										#
#		Development version:	11/90	RAShaw				#

procedure wgtsigmal (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop counters
int		ncount			# number of non-rejected values @pixel
real		sig, pixval
real		sumwts

begin
	do i = 1, npts {
	    ncount = 0
	    sig    = 0.
	    sumwts = 0.
	    do j = 1, nimages {
		pixval = Meml[data[j]+i-1]
		if (!IS_INDEFL (pixval)) {
		    ncount = ncount + 1
		    sig    = sig + WTS[j] * (pixval / SCALES[j] - ZEROS[j] - 
				mean[i]) ** 2
		    sumwts = sumwts + WTS[j]
		}
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / sumwts * ncount / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# SIGMA --	Compute sigma line from image lines with rejection.  Based 	#
#		upon the `images.imcombine' package.				#
#										#
#		Development version:	11/90	RAShaw				#

procedure sigmar (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

real		sig, pixval
int		i, j			# Loop counters
int		ncount			# Number of non-rejected values @pixel

begin	do i = 1, npts {
	    sig    = 0.
	    ncount = nimages
	    do j = 1, nimages {
		pixval = Memr[data[j]+i-1]
		if (IS_INDEFR (pixval))
		    ncount = ncount - 1
		else
		    sig = sig + (pixval - mean[i]) ** 2
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# WGTSIGMA --	Compute scaled and weighted sigma line from image lines with 	#
#		rejection.  Based upon the `images.imcombine' package.		#
#										#
#		Development version:	11/90	RAShaw				#

procedure wgtsigmar (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
real		mean[npts]		# Mean vector
real		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop counters
int		ncount			# number of non-rejected values @pixel
real		sig, pixval
real		sumwts

begin
	do i = 1, npts {
	    ncount = 0
	    sig    = 0.
	    sumwts = 0.
	    do j = 1, nimages {
		pixval = Memr[data[j]+i-1]
		if (!IS_INDEFR (pixval)) {
		    ncount = ncount + 1
		    sig    = sig + WTS[j] * (pixval / SCALES[j] - ZEROS[j] - 
				mean[i]) ** 2
		    sumwts = sumwts + WTS[j]
		}
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / sumwts * ncount / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# SIGMA --	Compute sigma line from image lines with rejection.  Based 	#
#		upon the `images.imcombine' package.				#
#										#
#		Development version:	11/90	RAShaw				#

procedure sigmad (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
double		mean[npts]		# Mean vector
double		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

double		sig, pixval
int		i, j			# Loop counters
int		ncount			# Number of non-rejected values @pixel

begin	do i = 1, npts {
	    sig    = 0.
	    ncount = nimages
	    do j = 1, nimages {
		pixval = Memd[data[j]+i-1]
		if (IS_INDEFD (pixval))
		    ncount = ncount - 1
		else
		    sig = sig + (pixval - mean[i]) ** 2
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

#################################################################################
# WGTSIGMA --	Compute scaled and weighted sigma line from image lines with 	#
#		rejection.  Based upon the `images.imcombine' package.		#
#										#
#		Development version:	11/90	RAShaw				#

procedure wgtsigmad (data, mean, sigma, nimages, npts)

include "wpcom.h"

# Calling arguments:
pointer		data[nimages]		# Data vectors
double		mean[npts]		# Mean vector
double		sigma[npts]		# Sigma vector (returned)
int		nimages			# Number of images to combine
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop counters
int		ncount			# number of non-rejected values @pixel
double		sig, pixval
real		sumwts

begin
	do i = 1, npts {
	    ncount = 0
	    sig    = 0.
	    sumwts = 0.
	    do j = 1, nimages {
		pixval = Memd[data[j]+i-1]
		if (!IS_INDEFD (pixval)) {
		    ncount = ncount + 1
		    sig    = sig + WTS[j] * (pixval / SCALES[j] - ZEROS[j] - 
				mean[i]) ** 2
		    sumwts = sumwts + WTS[j]
		}
	    }
	    if (ncount > 1)
	        sigma[i] = sqrt (sig / sumwts * ncount / (ncount - 1))
	    else
	        sigma[i] = BLANK
	}
end

