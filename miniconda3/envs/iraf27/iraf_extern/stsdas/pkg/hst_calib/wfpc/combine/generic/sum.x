.help sum
.nf ----------------------------------------------------------------------------
                COMBINING IMAGES: SUMMING ALGORITHM

The input images are summed.  The exposure time of the output image is the
sum of the input exposure times.  There is no checking for overflow.
.endhelp -----------------------------------------------------------------------

#$for (silrdx)


#################################################################################
# SUM --	Compute the sum of the input images for each image line.  	#
#		This procedure is based upon the `images.imcombine' package.  	#
#										#
#		Development version:	11/90	RAShaw				#

procedure sums (data, sum, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		sum[npts]		# Summed line (returned)
int		nimages			# Number of images to sum
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes

begin
	call aclrr (sum, npts)

	do j = 1, npts {
	    do i = 1, nimages {
	        sum[j] = sum[j] + Mems[data[i]+j-1]
	    }
	}
end


#################################################################################
# SUM --	Compute the sum of the input images for each image line.  	#
#		This procedure is based upon the `images.imcombine' package.  	#
#										#
#		Development version:	11/90	RAShaw				#

procedure sumi (data, sum, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		sum[npts]		# Summed line (returned)
int		nimages			# Number of images to sum
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes

begin
	call aclrr (sum, npts)

	do j = 1, npts {
	    do i = 1, nimages {
	        sum[j] = sum[j] + Memi[data[i]+j-1]
	    }
	}
end


#################################################################################
# SUM --	Compute the sum of the input images for each image line.  	#
#		This procedure is based upon the `images.imcombine' package.  	#
#										#
#		Development version:	11/90	RAShaw				#

procedure suml (data, sum, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		sum[npts]		# Summed line (returned)
int		nimages			# Number of images to sum
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes

begin
	call aclrr (sum, npts)

	do j = 1, npts {
	    do i = 1, nimages {
	        sum[j] = sum[j] + Meml[data[i]+j-1]
	    }
	}
end


#################################################################################
# SUM --	Compute the sum of the input images for each image line.  	#
#		This procedure is based upon the `images.imcombine' package.  	#
#										#
#		Development version:	11/90	RAShaw				#

procedure sumr (data, sum, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
real		sum[npts]		# Summed line (returned)
int		nimages			# Number of images to sum
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes

begin
	call aclrr (sum, npts)

	do j = 1, npts {
	    do i = 1, nimages {
	        sum[j] = sum[j] + Memr[data[i]+j-1]
	    }
	}
end


#################################################################################
# SUM --	Compute the sum of the input images for each image line.  	#
#		This procedure is based upon the `images.imcombine' package.  	#
#										#
#		Development version:	11/90	RAShaw				#

procedure sumd (data, sum, nimages, npts)

# Calling arguments:
pointer		data[nimages]		# Data pointers
double		sum[npts]		# Summed line (returned)
int		nimages			# Number of images to sum
int		npts			# Number of pixels per image line

# Local variables:
int		i, j			# Loop indexes

begin
	call aclrd (sum, npts)

	do j = 1, npts {
	    do i = 1, nimages {
	        sum[j] = sum[j] + Memd[data[i]+j-1]
	    }
	}
end

