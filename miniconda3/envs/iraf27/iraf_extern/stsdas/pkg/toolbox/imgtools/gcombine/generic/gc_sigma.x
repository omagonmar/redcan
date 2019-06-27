include	"../gcombine.h"


# G_USIGMA -- Compute the sigma image line when uniform weighting or 
#  no weighting is involved. This is the sigma in the mean, not the
#  averaged sample standard deviation itself.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine
#
# I. Busko May 27, 1998 Fixed bug that caused a floating-point crash
# in IMIO. The task won't crash but the output error array will be
# filled up with BLANK values, only when the number of input files
# is exactly equal to GPIX. This seems to be more of a design bug.

procedure g_usigmas (data, id, n, npts, average, sigma, szuw, nm)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure
pointer	nm			# Pointer to noise model structure

int	i, j, k, idj, n1
real	wt, sigcor, sumwt, sumwt1, val, b
real	a, sumvar, sumvar1, one, zero
data 	one, zero /1.0, 0.0/

include	"../gcombine.com"

begin
	if ( DOWTS && G_WEIGHT == W_UNIFORM) {
	# For uniform weighting we compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
		    if (n1 <= GPIX && NSMOD_E ) {
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/sum_weight)*sqrt(sum of [weight/scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# if the weight is exactly 1/var, this will become
	#  sigma_in_mean = 1 / sum (1/var)
	# See Equations in Page 71 of Bevington's book
			sumwt1 = 0.0
			sumvar1 = zero
			do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    wt = Memr[UWTS(szuw)+idj-1] 
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+(wt/Memr[SCALES(szuw)+idj-1]) **
			    	2 * val
			    sumwt1 = sumwt1 + wt
			}
			if (sumwt1 <= 0.0)  {
		    	    sumwt1 = real (n1)
		    	    call eprintf ("Warning: Sum of weights is negative")
		    	    call flush (STDERR)
		    	}
		    	sigma[i] = sqrt (sumvar1) / sumwt1
	    	    } else if ( n1 > GPIX || (n1 < GPIX && !NSMOD_E) ) {
			if (n1 > 1)
		 	    sigcor = real (n1) / real (n1 - 1)
			else
			    sigcor = 1.
			sumwt = 0.0
			sumvar = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
		  	    wt = Memr[UWTS(szuw)+idj-1] 
			    sumvar = sumvar + (Mems[data[j]+k] - a) ** 2 * wt
			    sumwt = sumwt + wt
			}
		    	# Here is the "averaged sigma" in data
		    	sigma[i] = sqrt (sumvar * sigcor / sumwt)
		    	# The uncertainty in the mean should be 
		    	#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    	    	sigma[i] = sigma[i] / sqrt ( real (n1) )
		    } else {
	                # Avoids floating-point errors in IMIO (IB, 5/27/98)
		        sigma[i] = BLANK
	            }
		} else 
		    sigma[i] = BLANK
	    }
	} else if ( !DOWTS || G_WEIGHT == W_NONE ) {
	# No weighting applied
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/N)*sqrt(sum of [1./scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# If all the sigma_in_data are equal, then the sum becomes 
	#     N*sigma_in_data**2, and its sqrt is sqrt(N) * sigma_in_data,
	# so that sigma_in_mean = sigma_in_data / sqrt (N)
	# See Equations in Page 72 of Bevington's book
		    if ( n1 <= GPIX && NSMOD_E ) {
			sumvar1 = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+ (one/Memr[SCALES(szuw)+idj-1])**
			    	2 * val
			}
			sigma[i] = sqrt (sumvar1) / real (n1)
		    } else if (n1 > GPIX || n1 < GPIX && !NSMOD_E ) {
			if (n1 > 1)
			    sigcor = 1.0 / real (n1 - 1)
			else
			    sigcor = 1.
			sumvar = zero
			do j = 1, n1
			    sumvar = sumvar + (Mems[data[j]+k] - a) ** 2
			# Here is the "averaged sigma" 
			sigma[i] = sqrt (sumvar * sigcor)
			# The uncertainty in the mean should be 
			#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    		sigma[i] = sigma[i] / sqrt (real(n1))
		    }
		} else
		    sigma[i] = BLANK
	    }
	}
end

# G_PSIGMA -- Compute the sigma image line when pixelwise weighting 
#  is applied.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_psigmas (data, id, errdata, n, npts, average, sigma, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
pointer	errdata[ARB]		# Error data pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure

int	i, j, k, n1, idj
real	sigcor, sumwt, wt
real	a, sumvar, zero, one
data	zero, one /0.0, 1.0/

include	"../gcombine.com"

begin
	# Compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
 	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (n1 > 0) {
		a = average[i]
		sumwt = zero
		sumvar = zero
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    wt = Mems[errdata[j]+k]
		    # errdata are scaled and rearranged in gc_gdata 
		    # the same way as data
		    if (wt <= zero)  {
#			call eprintf ("Warning: negative error in error map")
		    	next
		    } else
		    # variance = error**2
			wt = Memi[NCOMB(szuw)+idj-1] / wt ** 2
			sumvar = sumvar + (Mems[data[j]+k] - a) ** 2 * wt
			sumwt = sumwt + wt
	    	    }
	    	if (n1 > 1)
		    sigcor = real (n1) / real (n1 - 1)
	    	else
		    sigcor = 1.0
	    	if (n1 >= GPIX)
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = sqrt (sumvar * sigcor / sumwt / real (n1))
	    	else if (n1 < GPIX) 
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = one / sqrt (sumwt)
	    } else
		sigma[i] = BLANK
	}
end

# G_USIGMA -- Compute the sigma image line when uniform weighting or 
#  no weighting is involved. This is the sigma in the mean, not the
#  averaged sample standard deviation itself.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine
#
# I. Busko May 27, 1998 Fixed bug that caused a floating-point crash
# in IMIO. The task won't crash but the output error array will be
# filled up with BLANK values, only when the number of input files
# is exactly equal to GPIX. This seems to be more of a design bug.

procedure g_usigmai (data, id, n, npts, average, sigma, szuw, nm)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure
pointer	nm			# Pointer to noise model structure

int	i, j, k, idj, n1
real	wt, sigcor, sumwt, sumwt1, val, b
real	a, sumvar, sumvar1, one, zero
data 	one, zero /1.0, 0.0/

include	"../gcombine.com"

begin
	if ( DOWTS && G_WEIGHT == W_UNIFORM) {
	# For uniform weighting we compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
		    if (n1 <= GPIX && NSMOD_E ) {
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/sum_weight)*sqrt(sum of [weight/scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# if the weight is exactly 1/var, this will become
	#  sigma_in_mean = 1 / sum (1/var)
	# See Equations in Page 71 of Bevington's book
			sumwt1 = 0.0
			sumvar1 = zero
			do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    wt = Memr[UWTS(szuw)+idj-1] 
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+(wt/Memr[SCALES(szuw)+idj-1]) **
			    	2 * val
			    sumwt1 = sumwt1 + wt
			}
			if (sumwt1 <= 0.0)  {
		    	    sumwt1 = real (n1)
		    	    call eprintf ("Warning: Sum of weights is negative")
		    	    call flush (STDERR)
		    	}
		    	sigma[i] = sqrt (sumvar1) / sumwt1
	    	    } else if ( n1 > GPIX || (n1 < GPIX && !NSMOD_E) ) {
			if (n1 > 1)
		 	    sigcor = real (n1) / real (n1 - 1)
			else
			    sigcor = 1.
			sumwt = 0.0
			sumvar = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
		  	    wt = Memr[UWTS(szuw)+idj-1] 
			    sumvar = sumvar + (Memi[data[j]+k] - a) ** 2 * wt
			    sumwt = sumwt + wt
			}
		    	# Here is the "averaged sigma" in data
		    	sigma[i] = sqrt (sumvar * sigcor / sumwt)
		    	# The uncertainty in the mean should be 
		    	#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    	    	sigma[i] = sigma[i] / sqrt ( real (n1) )
		    } else {
	                # Avoids floating-point errors in IMIO (IB, 5/27/98)
		        sigma[i] = BLANK
	            }
		} else 
		    sigma[i] = BLANK
	    }
	} else if ( !DOWTS || G_WEIGHT == W_NONE ) {
	# No weighting applied
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/N)*sqrt(sum of [1./scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# If all the sigma_in_data are equal, then the sum becomes 
	#     N*sigma_in_data**2, and its sqrt is sqrt(N) * sigma_in_data,
	# so that sigma_in_mean = sigma_in_data / sqrt (N)
	# See Equations in Page 72 of Bevington's book
		    if ( n1 <= GPIX && NSMOD_E ) {
			sumvar1 = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+ (one/Memr[SCALES(szuw)+idj-1])**
			    	2 * val
			}
			sigma[i] = sqrt (sumvar1) / real (n1)
		    } else if (n1 > GPIX || n1 < GPIX && !NSMOD_E ) {
			if (n1 > 1)
			    sigcor = 1.0 / real (n1 - 1)
			else
			    sigcor = 1.
			sumvar = zero
			do j = 1, n1
			    sumvar = sumvar + (Memi[data[j]+k] - a) ** 2
			# Here is the "averaged sigma" 
			sigma[i] = sqrt (sumvar * sigcor)
			# The uncertainty in the mean should be 
			#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    		sigma[i] = sigma[i] / sqrt (real(n1))
		    }
		} else
		    sigma[i] = BLANK
	    }
	}
end

# G_PSIGMA -- Compute the sigma image line when pixelwise weighting 
#  is applied.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_psigmai (data, id, errdata, n, npts, average, sigma, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
pointer	errdata[ARB]		# Error data pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure

int	i, j, k, n1, idj
real	sigcor, sumwt, wt
real	a, sumvar, zero, one
data	zero, one /0.0, 1.0/

include	"../gcombine.com"

begin
	# Compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
 	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (n1 > 0) {
		a = average[i]
		sumwt = zero
		sumvar = zero
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    wt = Memi[errdata[j]+k]
		    # errdata are scaled and rearranged in gc_gdata 
		    # the same way as data
		    if (wt <= zero)  {
#			call eprintf ("Warning: negative error in error map")
		    	next
		    } else
		    # variance = error**2
			wt = Memi[NCOMB(szuw)+idj-1] / wt ** 2
			sumvar = sumvar + (Memi[data[j]+k] - a) ** 2 * wt
			sumwt = sumwt + wt
	    	    }
	    	if (n1 > 1)
		    sigcor = real (n1) / real (n1 - 1)
	    	else
		    sigcor = 1.0
	    	if (n1 >= GPIX)
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = sqrt (sumvar * sigcor / sumwt / real (n1))
	    	else if (n1 < GPIX) 
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = one / sqrt (sumwt)
	    } else
		sigma[i] = BLANK
	}
end

# G_USIGMA -- Compute the sigma image line when uniform weighting or 
#  no weighting is involved. This is the sigma in the mean, not the
#  averaged sample standard deviation itself.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine
#
# I. Busko May 27, 1998 Fixed bug that caused a floating-point crash
# in IMIO. The task won't crash but the output error array will be
# filled up with BLANK values, only when the number of input files
# is exactly equal to GPIX. This seems to be more of a design bug.

procedure g_usigmar (data, id, n, npts, average, sigma, szuw, nm)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure
pointer	nm			# Pointer to noise model structure

int	i, j, k, idj, n1
real	wt, sigcor, sumwt, sumwt1, val, b
real	a, sumvar, sumvar1, one, zero
data	one, zero /1.0, 0.0/

include	"../gcombine.com"

begin
	if ( DOWTS && G_WEIGHT == W_UNIFORM) {
	# For uniform weighting we compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
		    if (n1 <= GPIX && NSMOD_E ) {
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/sum_weight)*sqrt(sum of [weight/scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# if the weight is exactly 1/var, this will become
	#  sigma_in_mean = 1 / sum (1/var)
	# See Equations in Page 71 of Bevington's book
			sumwt1 = 0.0
			sumvar1 = zero
			do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    wt = Memr[UWTS(szuw)+idj-1] 
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+(wt/Memr[SCALES(szuw)+idj-1]) **
			    	2 * val
			    sumwt1 = sumwt1 + wt
			}
			if (sumwt1 <= 0.0)  {
		    	    sumwt1 = real (n1)
		    	    call eprintf ("Warning: Sum of weights is negative")
		    	    call flush (STDERR)
		    	}
		    	sigma[i] = sqrt (sumvar1) / sumwt1
	    	    } else if ( n1 > GPIX || (n1 < GPIX && !NSMOD_E) ) {
			if (n1 > 1)
		 	    sigcor = real (n1) / real (n1 - 1)
			else
			    sigcor = 1.
			sumwt = 0.0
			sumvar = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
		  	    wt = Memr[UWTS(szuw)+idj-1] 
			    sumvar = sumvar + (Memr[data[j]+k] - a) ** 2 * wt
			    sumwt = sumwt + wt
			}
		    	# Here is the "averaged sigma" in data
		    	sigma[i] = sqrt (sumvar * sigcor / sumwt)
		    	# The uncertainty in the mean should be 
		    	#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    	    	sigma[i] = sigma[i] / sqrt ( real (n1) )
		    } else {
	                # Avoids floating-point errors in IMIO (IB, 5/27/98)
		        sigma[i] = BLANK
	            }
		} else 
		    sigma[i] = BLANK
	    }
	} else if ( !DOWTS || G_WEIGHT == W_NONE ) {
	# No weighting applied
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/N)*sqrt(sum of [1./scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# If all the sigma_in_data are equal, then the sum becomes 
	#     N*sigma_in_data**2, and its sqrt is sqrt(N) * sigma_in_data,
	# so that sigma_in_mean = sigma_in_data / sqrt (N)
	# See Equations in Page 72 of Bevington's book
		    if ( n1 <= GPIX && NSMOD_E ) {
			sumvar1 = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+ (one/Memr[SCALES(szuw)+idj-1])**
			    	2 * val
			}
			sigma[i] = sqrt (sumvar1) / real (n1)
		    } else if (n1 > GPIX || n1 < GPIX && !NSMOD_E ) {
			if (n1 > 1)
			    sigcor = 1.0 / real (n1 - 1)
			else
			    sigcor = 1.
			sumvar = zero
			do j = 1, n1
			    sumvar = sumvar + (Memr[data[j]+k] - a) ** 2
			# Here is the "averaged sigma" 
			sigma[i] = sqrt (sumvar * sigcor)
			# The uncertainty in the mean should be 
			#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    		sigma[i] = sigma[i] / sqrt (real(n1))
		    }
		} else
		    sigma[i] = BLANK
	    }
	}
end

# G_PSIGMA -- Compute the sigma image line when pixelwise weighting 
#  is applied.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_psigmar (data, id, errdata, n, npts, average, sigma, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
pointer	errdata[ARB]		# Error data pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
real	average[npts]		# Average
real	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure

int	i, j, k, n1, idj
real	sigcor, sumwt, wt
real	a, sumvar, zero, one
data 	zero, one /0.0, 1.0/

include	"../gcombine.com"

begin
	# Compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
 	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (n1 > 0) {
		a = average[i]
		sumwt = zero
		sumvar = zero
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    wt = Memr[errdata[j]+k]
		    # errdata are scaled and rearranged in gc_gdata 
		    # the same way as data
		    if (wt <= zero)  {
#			call eprintf ("Warning: negative error in error map")
		    	next
		    } else
		    # variance = error**2
			wt = Memi[NCOMB(szuw)+idj-1] / wt ** 2
			sumvar = sumvar + (Memr[data[j]+k] - a) ** 2 * wt
			sumwt = sumwt + wt
	    	    }
	    	if (n1 > 1)
		    sigcor = real (n1) / real (n1 - 1)
	    	else
		    sigcor = 1.0
	    	if (n1 >= GPIX)
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = sqrt (sumvar * sigcor / sumwt / real (n1))
	    	else if (n1 < GPIX) 
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = one / sqrt (sumwt)
	    } else
		sigma[i] = BLANK
	}
end

# G_USIGMA -- Compute the sigma image line when uniform weighting or 
#  no weighting is involved. This is the sigma in the mean, not the
#  averaged sample standard deviation itself.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine
#
# I. Busko May 27, 1998 Fixed bug that caused a floating-point crash
# in IMIO. The task won't crash but the output error array will be
# filled up with BLANK values, only when the number of input files
# is exactly equal to GPIX. This seems to be more of a design bug.

procedure g_usigmad (data, id, n, npts, average, sigma, szuw, nm)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
double	average[npts]		# Average
double	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure
pointer	nm			# Pointer to noise model structure

int	i, j, k, idj, n1
real	wt, sigcor, sumwt, sumwt1, val, b
double	a, sumvar, sumvar1, one, zero
data	one, zero /1.0D0, 0.0D0/

include	"../gcombine.com"

begin
	if ( DOWTS && G_WEIGHT == W_UNIFORM) {
	# For uniform weighting we compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
		    if (n1 <= GPIX && NSMOD_E ) {
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/sum_weight)*sqrt(sum of [weight/scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# if the weight is exactly 1/var, this will become
	#  sigma_in_mean = 1 / sum (1/var)
	# See Equations in Page 71 of Bevington's book
			sumwt1 = 0.0
			sumvar1 = zero
			do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    wt = Memr[UWTS(szuw)+idj-1] 
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+(wt/Memr[SCALES(szuw)+idj-1]) **
			    	2 * val
			    sumwt1 = sumwt1 + wt
			}
			if (sumwt1 <= 0.0)  {
		    	    sumwt1 = real (n1)
		    	    call eprintf ("Warning: Sum of weights is negative")
		    	    call flush (STDERR)
		    	}
		    	sigma[i] = sqrt (sumvar1) / sumwt1
	    	    } else if ( n1 > GPIX || (n1 < GPIX && !NSMOD_E) ) {
			if (n1 > 1)
		 	    sigcor = real (n1) / real (n1 - 1)
			else
			    sigcor = 1.
			sumwt = 0.0
			sumvar = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
		  	    wt = Memr[UWTS(szuw)+idj-1] 
			    sumvar = sumvar + (Memd[data[j]+k] - a) ** 2 * wt
			    sumwt = sumwt + wt
			}
		    	# Here is the "averaged sigma" in data
		    	sigma[i] = sqrt (sumvar * sigcor / sumwt)
		    	# The uncertainty in the mean should be 
		    	#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    	    	sigma[i] = sigma[i] / sqrt ( real (n1) )
		    } else {
	                # Avoids floating-point errors in IMIO (IB, 5/27/98)
		        sigma[i] = BLANK
	            }
		} else 
		    sigma[i] = BLANK
	    }
	} else if ( !DOWTS || G_WEIGHT == W_NONE ) {
	# No weighting applied
	    do i = 1, npts {
		n1 = n[i]
		if (n1 > 0) {
		    k = i - 1
		    a = average[i]
	# When number of retained images is too small, compute the 
	# "error in the mean" based on the variance from noise model.
	#  sigma_in_mean = (1/N)*sqrt(sum of [1./scales]**2
	#     *[(rdnoise/g)**2+(scaled_mean+zeros)*scales/g+...])
	# If all the sigma_in_data are equal, then the sum becomes 
	#     N*sigma_in_data**2, and its sqrt is sqrt(N) * sigma_in_data,
	# so that sigma_in_mean = sigma_in_data / sqrt (N)
	# See Equations in Page 72 of Bevington's book
		    if ( n1 <= GPIX && NSMOD_E ) {
			sumvar1 = zero
		    	do j = 1, n1 {
			    idj = Memi[id[j]+k]
			    # scale the signal back to original
			    b = (a + Memr[ZEROS(szuw)+idj-1]) *
			    	Memr[SCALES(szuw)+idj-1]
			    call g_nmvar (max (1.0, b), val, 
			    	Memr[RDNOISE(nm)+idj-1], Memr[GAIN(nm)+idj-1],
			    	Memr[SNOISE(nm)+idj-1])
			    sumvar1 = sumvar1+ (one/Memr[SCALES(szuw)+idj-1])**
			    	2 * val
			}
			sigma[i] = sqrt (sumvar1) / real (n1)
		    } else if (n1 > GPIX || n1 < GPIX && !NSMOD_E ) {
			if (n1 > 1)
			    sigcor = 1.0 / real (n1 - 1)
			else
			    sigcor = 1.
			sumvar = zero
			do j = 1, n1
			    sumvar = sumvar + (Memd[data[j]+k] - a) ** 2
			# Here is the "averaged sigma" 
			sigma[i] = sqrt (sumvar * sigcor)
			# The uncertainty in the mean should be 
			#  	sigma_in_mean = sigma_in_data / sqrt (N)
	    		sigma[i] = sigma[i] / sqrt (real(n1))
		    }
		} else
		    sigma[i] = BLANK
	    }
	}
end

# G_PSIGMA -- Compute the sigma image line when pixelwise weighting 
#  is applied.
#  Reference: "Data Reduction and Error Analysis for the Physical
#  Sciences, by P.R. Bevington, 1969
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_psigmad (data, id, errdata, n, npts, average, sigma, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB]			# Image ID pointers
pointer	errdata[ARB]		# Error data pointers
int	n[npts]			# Number of good pixels
int	npts			# Number of output points per line
double	average[npts]		# Average
double	sigma[npts]		# Sigma line (returned)
pointer	szuw			# Pointer to scaling structure

int	i, j, k, n1, idj
real	sigcor, sumwt, wt
double	a, sumvar, zero, one
data 	zero, one /0.0D0, 1.0D0/

include	"../gcombine.com"

begin
	# Compute the "average sigma" in the data.
	# See Equations in Page 73 of Bevington's book
 	do i = 1, npts {
	    k = i - 1
	    n1 = n[i]
	    if (n1 > 0) {
		a = average[i]
		sumwt = zero
		sumvar = zero
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    wt = Memd[errdata[j]+k]
		    # errdata are scaled and rearranged in gc_gdata 
		    # the same way as data
		    if (wt <= zero)  {
#			call eprintf ("Warning: negative error in error map")
		    	next
		    } else
		    # variance = error**2
			wt = Memi[NCOMB(szuw)+idj-1] / wt ** 2
			sumvar = sumvar + (Memd[data[j]+k] - a) ** 2 * wt
			sumwt = sumwt + wt
	    	    }
	    	if (n1 > 1)
		    sigcor = real (n1) / real (n1 - 1)
	    	else
		    sigcor = 1.0
	    	if (n1 >= GPIX)
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = sqrt (sumvar * sigcor / sumwt / real (n1))
	    	else if (n1 < GPIX) 
		    if (sumwt <= 0.0)
			sigma[i] = BLANK
		    else
			sigma[i] = one / sqrt (sumwt)
	    } else
		sigma[i] = BLANK
	}
end

