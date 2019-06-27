include	<imhdr.h>
include	"../gcombine.h"

define	NXMAX	500	# Maximum number of pixels per dimension


# G_SECSTAT -- Compute image statistics within specified section.
# Only a subsample of pixels is used.  Masked and thresholded pixels are
# ignored.  Only the desired statistics are computed to increase
# efficiency.

procedure g_secstats (im, dqf, section, mode, median, mean)

pointer	im			 # Data image
pointer	dqf			 # DQF image
char	section[ARB]		 # Image section
real	mode, median, mean	 # Statistics

int	i, ndim, n, nv
real	a
pointer	sp, v1, v2, dv, va, vb, vs, vd
pointer	dp, lp, mp, mask, work, imgnls()
short	g_modes(), asums()

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (dv, IM_MAXDIM, TY_LONG)
	call salloc (va, IM_MAXDIM, TY_LONG)
	call salloc (vb, IM_MAXDIM, TY_LONG)
	call salloc (vs, IM_MAXDIM, TY_LONG)
	call salloc (vd, IM_MAXDIM, TY_LONG)

	# Determine the image section parameters.  This must be in terms of
	# the data image pixel coordinates though the section may be specified
	# in terms of the reference image coordinates.  Limit the number of
	# pixels in each dimension to a maximum.

	ndim = IM_NDIM(im)
	# The default values of va, vb, and dv are set by the caller to
	# g_section!
	call amovki (1, Memi[v1], IM_MAXDIM)
	call amovki (1, Memi[va], IM_MAXDIM)
	call amovki (1, Memi[vs], IM_MAXDIM)
	call amovi (IM_LEN(im,1), Memi[vb], ndim)
	call g_section (section, Memi[va], Memi[vb], Memi[vs], ndim)

	n = 1
	do i = 0, ndim-1 {
	    Memi[v1+i] = max (1, min (Memi[va+i], Memi[vb+i]))
	    Memi[v2+i] = min (IM_LEN(im,i+1), max (Memi[va+i], Memi[vb+i]))
	    Memi[dv+i] = abs (Memi[vs+i])
	    nv = min (NXMAX, (Memi[v2+i] - Memi[v1+i]) / Memi[dv+i] + 1)
	    if (nv == 1)
		Memi[dv+i] = 1
	    else
		Memi[dv+i] = (Memi[v2+i] - Memi[v1+i]) / (nv -1)
	    Memi[v2+i] = Memi[v1+i] + (nv - 1) * Memi[dv+i]
	    n = n * nv
	}

	call amovl (Memi[v1], Memi[va], IM_MAXDIM)
	# The left most index must start from 1
	Memi[va] = 1
	call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	# Accumulate the pixel values within the section.  Masked pixels and
	# thresholded pixels are ignored.

	call salloc (work, n, TY_SHORT)
	dp = work
	if (dqf != NULL) {
	    while (imgnls (im, lp, Memi[vb]) != EOF) {
		call g_mask (dqf, mask, Memi[vd])

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		mp = mask + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    a = Mems[lp]
			    if (a >= LTHRESH && a <= HTHRESH) {
				Mems[dp] = a
				dp = dp + 1
			    }
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    Mems[dp] = Mems[lp]
			    dp = dp + 1
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	        call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	    }
	} else {
	    while (imgnls (im, lp, Memi[vb]) != EOF) {

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Mems[lp]
			if (a >= LTHRESH && a <= HTHRESH) {
			    Mems[dp] = a
			    dp = dp + 1
			}
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Mems[lp]
			Mems[dp] = a
			dp = dp + 1
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	    }
	}
	n = dp - work
	if (n < 1) {
	    call sfree (sp)
	    call error (1, "Image section contains no pixels")
	}

	# Compute only statistics needed.
	if (DOMODE || DOMEDIAN) {
	    call asrts (Mems[work], Mems[work], n)
	    mode = g_modes (Mems[work], n)
	    median = Mems[work+n/2-1]
	}
	if (DOMEAN)
	    mean = asums (Mems[work], n) / real (n)

	call sfree (sp)
end


define	NMIN	100	# Minimum number of pixels for mode calculation
define	ZRANGE	0.8	# Fraction of pixels about median to use
define	ZSTEP	0.01	# Step size for search for mode
define	ZBIN	0.1	# Bin size for mode.
define	BINMIN	7.0	# Minimum bin width in ADU for mode

# G_MODE -- Compute mode of an array.  The mode is found by binning
# with a bin size based on the data range over a fraction of the
# pixels about the median and a bin step which may be smaller than the
# bin size.  If there are too few points the median is returned.
# The input array must be sorted.

short procedure g_modes (a, n)

short	a[n]			# Data array
int	n			# Number of points

int	i, j, k, nmax
real	z1, z2, zzstep, zzbin
short	mode
bool	fp_equalr()

begin
	if (n < NMIN)
	    return (a[n/2])

	# Compute the mode.  The array must be sorted.  Consider a
	# range of values about the median point.  Use a bin size which
	# is ZBIN of the range.  Step the bin limits in ZSTEP fraction of
	# the bin size.

	i = 1 + n * (1. - ZRANGE) / 2.
	j = 1 + n * (1. + ZRANGE) / 2.
	z1 = a[i]
	z2 = a[j]
	if (fp_equalr (z1, z2)) {
	    mode = z1
	    return (mode)
	}

	zzstep = ZSTEP * (z2 - z1)
	zzbin = ZBIN * (z2 - z1)
	zzstep = max (1., zzstep)
	zzbin = max (1., zzbin)
	# Kavan's note: Avoid picking up noise spikes
	zzbin = max (BINMIN, zzbin)
	z1 = z1 - zzstep
	k = i
	nmax = 0
	repeat {
	    z1 = z1 + zzstep
	    z2 = z1 + zzbin
	    for (; i < j && a[i] < z1; i=i+1)
		;
	    for (; k < j && a[k] < z2; k=k+1)
		;
	    if (k - i > nmax) {
	        nmax = k - i
	        mode = a[(i+k)/2]
	    }
	} until (k >= j)

	return (mode)
end

# G_SECSTAT -- Compute image statistics within specified section.
# Only a subsample of pixels is used.  Masked and thresholded pixels are
# ignored.  Only the desired statistics are computed to increase
# efficiency.

procedure g_secstati (im, dqf, section, mode, median, mean)

pointer	im			 # Data image
pointer	dqf			 # DQF image
char	section[ARB]		 # Image section
real	mode, median, mean	 # Statistics

int	i, ndim, n, nv
real	a
pointer	sp, v1, v2, dv, va, vb, vs, vd
pointer	dp, lp, mp, mask, work, imgnli()
int	g_modei(), asumi()

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (dv, IM_MAXDIM, TY_LONG)
	call salloc (va, IM_MAXDIM, TY_LONG)
	call salloc (vb, IM_MAXDIM, TY_LONG)
	call salloc (vs, IM_MAXDIM, TY_LONG)
	call salloc (vd, IM_MAXDIM, TY_LONG)

	# Determine the image section parameters.  This must be in terms of
	# the data image pixel coordinates though the section may be specified
	# in terms of the reference image coordinates.  Limit the number of
	# pixels in each dimension to a maximum.

	ndim = IM_NDIM(im)
	# The default values of va, vb, and dv are set by the caller to
	# g_section!
	call amovki (1, Memi[v1], IM_MAXDIM)
	call amovki (1, Memi[va], IM_MAXDIM)
	call amovki (1, Memi[vs], IM_MAXDIM)
	call amovi (IM_LEN(im,1), Memi[vb], ndim)
	call g_section (section, Memi[va], Memi[vb], Memi[vs], ndim)

	n = 1
	do i = 0, ndim-1 {
	    Memi[v1+i] = max (1, min (Memi[va+i], Memi[vb+i]))
	    Memi[v2+i] = min (IM_LEN(im,i+1), max (Memi[va+i], Memi[vb+i]))
	    Memi[dv+i] = abs (Memi[vs+i])
	    nv = min (NXMAX, (Memi[v2+i] - Memi[v1+i]) / Memi[dv+i] + 1)
	    if (nv == 1)
		Memi[dv+i] = 1
	    else
		Memi[dv+i] = (Memi[v2+i] - Memi[v1+i]) / (nv -1)
	    Memi[v2+i] = Memi[v1+i] + (nv - 1) * Memi[dv+i]
	    n = n * nv
	}

	call amovl (Memi[v1], Memi[va], IM_MAXDIM)
	# The left most index must start from 1
	Memi[va] = 1
	call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	# Accumulate the pixel values within the section.  Masked pixels and
	# thresholded pixels are ignored.

	call salloc (work, n, TY_INT)
	dp = work
	if (dqf != NULL) {
	    while (imgnli (im, lp, Memi[vb]) != EOF) {
		call g_mask (dqf, mask, Memi[vd])

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		mp = mask + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    a = Memi[lp]
			    if (a >= LTHRESH && a <= HTHRESH) {
				Memi[dp] = a
				dp = dp + 1
			    }
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    Memi[dp] = Memi[lp]
			    dp = dp + 1
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	        call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	    }
	} else {
	    while (imgnli (im, lp, Memi[vb]) != EOF) {

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memi[lp]
			if (a >= LTHRESH && a <= HTHRESH) {
			    Memi[dp] = a
			    dp = dp + 1
			}
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memi[lp]
			Memi[dp] = a
			dp = dp + 1
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	    }
	}
	n = dp - work
	if (n < 1) {
	    call sfree (sp)
	    call error (1, "Image section contains no pixels")
	}

	# Compute only statistics needed.
	if (DOMODE || DOMEDIAN) {
	    call asrti (Memi[work], Memi[work], n)
	    mode = g_modei (Memi[work], n)
	    median = Memi[work+n/2-1]
	}
	if (DOMEAN)
	    mean = asumi (Memi[work], n) / real (n)

	call sfree (sp)
end


define	NMIN	100	# Minimum number of pixels for mode calculation
define	ZRANGE	0.8	# Fraction of pixels about median to use
define	ZSTEP	0.01	# Step size for search for mode
define	ZBIN	0.1	# Bin size for mode.
define	BINMIN	7.0	# Minimum bin width in ADU for mode

# G_MODE -- Compute mode of an array.  The mode is found by binning
# with a bin size based on the data range over a fraction of the
# pixels about the median and a bin step which may be smaller than the
# bin size.  If there are too few points the median is returned.
# The input array must be sorted.

int procedure g_modei (a, n)

int	a[n]			# Data array
int	n			# Number of points

int	i, j, k, nmax
real	z1, z2, zzstep, zzbin
int	mode
bool	fp_equalr()

begin
	if (n < NMIN)
	    return (a[n/2])

	# Compute the mode.  The array must be sorted.  Consider a
	# range of values about the median point.  Use a bin size which
	# is ZBIN of the range.  Step the bin limits in ZSTEP fraction of
	# the bin size.

	i = 1 + n * (1. - ZRANGE) / 2.
	j = 1 + n * (1. + ZRANGE) / 2.
	z1 = a[i]
	z2 = a[j]
	if (fp_equalr (z1, z2)) {
	    mode = z1
	    return (mode)
	}

	zzstep = ZSTEP * (z2 - z1)
	zzbin = ZBIN * (z2 - z1)
	zzstep = max (1., zzstep)
	zzbin = max (1., zzbin)
	# Kavan's note: Avoid picking up noise spikes
	zzbin = max (BINMIN, zzbin)
	z1 = z1 - zzstep
	k = i
	nmax = 0
	repeat {
	    z1 = z1 + zzstep
	    z2 = z1 + zzbin
	    for (; i < j && a[i] < z1; i=i+1)
		;
	    for (; k < j && a[k] < z2; k=k+1)
		;
	    if (k - i > nmax) {
	        nmax = k - i
	        mode = a[(i+k)/2]
	    }
	} until (k >= j)

	return (mode)
end

# G_SECSTAT -- Compute image statistics within specified section.
# Only a subsample of pixels is used.  Masked and thresholded pixels are
# ignored.  Only the desired statistics are computed to increase
# efficiency.

procedure g_secstatr (im, dqf, section, mode, median, mean)

pointer	im			 # Data image
pointer	dqf			 # DQF image
char	section[ARB]		 # Image section
real	mode, median, mean	 # Statistics

int	i, ndim, n, nv
real	a
pointer	sp, v1, v2, dv, va, vb, vs, vd
pointer	dp, lp, mp, mask, work, imgnlr()
real	g_moder(), asumr()

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (dv, IM_MAXDIM, TY_LONG)
	call salloc (va, IM_MAXDIM, TY_LONG)
	call salloc (vb, IM_MAXDIM, TY_LONG)
	call salloc (vs, IM_MAXDIM, TY_LONG)
	call salloc (vd, IM_MAXDIM, TY_LONG)

	# Determine the image section parameters.  This must be in terms of
	# the data image pixel coordinates though the section may be specified
	# in terms of the reference image coordinates.  Limit the number of
	# pixels in each dimension to a maximum.

	ndim = IM_NDIM(im)
	# The default values of va, vb, and dv are set by the caller to
	# g_section!
	call amovki (1, Memi[v1], IM_MAXDIM)
	call amovki (1, Memi[va], IM_MAXDIM)
	call amovki (1, Memi[vs], IM_MAXDIM)
	call amovi (IM_LEN(im,1), Memi[vb], ndim)
	call g_section (section, Memi[va], Memi[vb], Memi[vs], ndim)

	n = 1
	do i = 0, ndim-1 {
	    Memi[v1+i] = max (1, min (Memi[va+i], Memi[vb+i]))
	    Memi[v2+i] = min (IM_LEN(im,i+1), max (Memi[va+i], Memi[vb+i]))
	    Memi[dv+i] = abs (Memi[vs+i])
	    nv = min (NXMAX, (Memi[v2+i] - Memi[v1+i]) / Memi[dv+i] + 1)
	    if (nv == 1)
		Memi[dv+i] = 1
	    else
		Memi[dv+i] = (Memi[v2+i] - Memi[v1+i]) / (nv -1)
	    Memi[v2+i] = Memi[v1+i] + (nv - 1) * Memi[dv+i]
	    n = n * nv
	}

	call amovl (Memi[v1], Memi[va], IM_MAXDIM)
	# The left most index must start from 1
	Memi[va] = 1
	call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	# Accumulate the pixel values within the section.  Masked pixels and
	# thresholded pixels are ignored.

	call salloc (work, n, TY_REAL)
	dp = work
	if (dqf != NULL) {
	    while (imgnlr (im, lp, Memi[vb]) != EOF) {
		call g_mask (dqf, mask, Memi[vd])

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		mp = mask + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    a = Memr[lp]
			    if (a >= LTHRESH && a <= HTHRESH) {
				Memr[dp] = a
				dp = dp + 1
			    }
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    Memr[dp] = Memr[lp]
			    dp = dp + 1
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	        call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	    }
	} else {
	    while (imgnlr (im, lp, Memi[vb]) != EOF) {

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memr[lp]
			if (a >= LTHRESH && a <= HTHRESH) {
			    Memr[dp] = a
			    dp = dp + 1
			}
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memr[lp]
			Memr[dp] = a
			dp = dp + 1
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	    }
	}
	n = dp - work
	if (n < 1) {
	    call sfree (sp)
	    call error (1, "Image section contains no pixels")
	}

	# Compute only statistics needed.
	if (DOMODE || DOMEDIAN) {
	    call asrtr (Memr[work], Memr[work], n)
	    mode = g_moder (Memr[work], n)
	    median = Memr[work+n/2-1]
	}
	if (DOMEAN)
	    mean = asumr (Memr[work], n) / real (n)

	call sfree (sp)
end


define	NMIN	100	# Minimum number of pixels for mode calculation
define	ZRANGE	0.8	# Fraction of pixels about median to use
define	ZSTEP	0.01	# Step size for search for mode
define	ZBIN	0.1	# Bin size for mode.
define	BINMIN	7.0	# Minimum bin width in ADU for mode

# G_MODE -- Compute mode of an array.  The mode is found by binning
# with a bin size based on the data range over a fraction of the
# pixels about the median and a bin step which may be smaller than the
# bin size.  If there are too few points the median is returned.
# The input array must be sorted.

real procedure g_moder (a, n)

real	a[n]			# Data array
int	n			# Number of points

int	i, j, k, nmax
real	z1, z2, zzstep, zzbin
real	mode
bool	fp_equalr()

begin
	if (n < NMIN)
	    return (a[n/2])

	# Compute the mode.  The array must be sorted.  Consider a
	# range of values about the median point.  Use a bin size which
	# is ZBIN of the range.  Step the bin limits in ZSTEP fraction of
	# the bin size.

	i = 1 + n * (1. - ZRANGE) / 2.
	j = 1 + n * (1. + ZRANGE) / 2.
	z1 = a[i]
	z2 = a[j]
	if (fp_equalr (z1, z2)) {
	    mode = z1
	    return (mode)
	}

	zzstep = ZSTEP * (z2 - z1)
	zzbin = ZBIN * (z2 - z1)
	# Kavan's note: Avoid picking up noise spikes
	zzbin = max (BINMIN, zzbin)
	z1 = z1 - zzstep
	k = i
	nmax = 0
	repeat {
	    z1 = z1 + zzstep
	    z2 = z1 + zzbin
	    for (; i < j && a[i] < z1; i=i+1)
		;
	    for (; k < j && a[k] < z2; k=k+1)
		;
	    if (k - i > nmax) {
	        nmax = k - i
	        mode = a[(i+k)/2]
	    }
	} until (k >= j)

	return (mode)
end

# G_SECSTAT -- Compute image statistics within specified section.
# Only a subsample of pixels is used.  Masked and thresholded pixels are
# ignored.  Only the desired statistics are computed to increase
# efficiency.

procedure g_secstatd (im, dqf, section, mode, median, mean)

pointer	im			 # Data image
pointer	dqf			 # DQF image
char	section[ARB]		 # Image section
real	mode, median, mean	 # Statistics

int	i, ndim, n, nv
real	a
pointer	sp, v1, v2, dv, va, vb, vs, vd
pointer	dp, lp, mp, mask, work, imgnld()
double	g_moded(), asumd()

include	"../gcombine.com"

begin
	call smark (sp)
	call salloc (v1, IM_MAXDIM, TY_LONG)
	call salloc (v2, IM_MAXDIM, TY_LONG)
	call salloc (dv, IM_MAXDIM, TY_LONG)
	call salloc (va, IM_MAXDIM, TY_LONG)
	call salloc (vb, IM_MAXDIM, TY_LONG)
	call salloc (vs, IM_MAXDIM, TY_LONG)
	call salloc (vd, IM_MAXDIM, TY_LONG)

	# Determine the image section parameters.  This must be in terms of
	# the data image pixel coordinates though the section may be specified
	# in terms of the reference image coordinates.  Limit the number of
	# pixels in each dimension to a maximum.

	ndim = IM_NDIM(im)
	# The default values of va, vb, and dv are set by the caller to
	# g_section!
	call amovki (1, Memi[v1], IM_MAXDIM)
	call amovki (1, Memi[va], IM_MAXDIM)
	call amovki (1, Memi[vs], IM_MAXDIM)
	call amovi (IM_LEN(im,1), Memi[vb], ndim)
	call g_section (section, Memi[va], Memi[vb], Memi[vs], ndim)

	n = 1
	do i = 0, ndim-1 {
	    Memi[v1+i] = max (1, min (Memi[va+i], Memi[vb+i]))
	    Memi[v2+i] = min (IM_LEN(im,i+1), max (Memi[va+i], Memi[vb+i]))
	    Memi[dv+i] = abs (Memi[vs+i])
	    nv = min (NXMAX, (Memi[v2+i] - Memi[v1+i]) / Memi[dv+i] + 1)
	    if (nv == 1)
		Memi[dv+i] = 1
	    else
		Memi[dv+i] = (Memi[v2+i] - Memi[v1+i]) / (nv -1)
	    Memi[v2+i] = Memi[v1+i] + (nv - 1) * Memi[dv+i]
	    n = n * nv
	}

	call amovl (Memi[v1], Memi[va], IM_MAXDIM)
	# The left most index must start from 1
	Memi[va] = 1
	call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	# Accumulate the pixel values within the section.  Masked pixels and
	# thresholded pixels are ignored.

	call salloc (work, n, TY_DOUBLE)
	dp = work
	if (dqf != NULL) {
	    while (imgnld (im, lp, Memi[vb]) != EOF) {
		call g_mask (dqf, mask, Memi[vd])

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		mp = mask + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    a = Memd[lp]
			    if (a >= LTHRESH && a <= HTHRESH) {
				Memd[dp] = a
				dp = dp + 1
			    }
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			if (Memi[mp] == 0) {
			    Memd[dp] = Memd[lp]
			    dp = dp + 1
			}
			mp = mp + Memi[dv]
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	        call amovl (Memi[va], Memi[vd], IM_MAXDIM)
	    }
	} else {
	    while (imgnld (im, lp, Memi[vb]) != EOF) {

		# Gather the good pixels into work array
		lp = lp + Memi[v1] - 1
		if (DOTHRESH) {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memd[lp]
			if (a >= LTHRESH && a <= HTHRESH) {
			    Memd[dp] = a
			    dp = dp + 1
			}
			lp = lp + Memi[dv]
		    }
		} else {
		    do i = Memi[v1], Memi[v2], Memi[dv] {
			a = Memd[lp]
			Memd[dp] = a
			dp = dp + 1
			lp = lp + Memi[dv]
		    }
		}
		for (i=2; i<=ndim; i=i+1) {
		    Memi[va+i-1] = Memi[va+i-1] + Memi[dv+i-1]
		    if (Memi[va+i-1] <= Memi[v2+i-1])
		        break
		    Memi[va+i-1] = Memi[v1+i-1]
	        }
	        if (i > ndim)
		    break
	        call amovl (Memi[va], Memi[vb], IM_MAXDIM)
	    }
	}
	n = dp - work
	if (n < 1) {
	    call sfree (sp)
	    call error (1, "Image section contains no pixels")
	}

	# Compute only statistics needed.
	if (DOMODE || DOMEDIAN) {
	    call asrtd (Memd[work], Memd[work], n)
	    mode = g_moded (Memd[work], n)
	    median = Memd[work+n/2-1]
	}
	if (DOMEAN)
	    mean = asumd (Memd[work], n) / real (n)

	call sfree (sp)
end


define	NMIN	100	# Minimum number of pixels for mode calculation
define	ZRANGE	0.8	# Fraction of pixels about median to use
define	ZSTEP	0.01	# Step size for search for mode
define	ZBIN	0.1	# Bin size for mode.
define	BINMIN	7.0	# Minimum bin width in ADU for mode

# G_MODE -- Compute mode of an array.  The mode is found by binning
# with a bin size based on the data range over a fraction of the
# pixels about the median and a bin step which may be smaller than the
# bin size.  If there are too few points the median is returned.
# The input array must be sorted.

double procedure g_moded (a, n)

double	a[n]			# Data array
int	n			# Number of points

int	i, j, k, nmax
real	z1, z2, zzstep, zzbin
double	mode
bool	fp_equalr()

begin
	if (n < NMIN)
	    return (a[n/2])

	# Compute the mode.  The array must be sorted.  Consider a
	# range of values about the median point.  Use a bin size which
	# is ZBIN of the range.  Step the bin limits in ZSTEP fraction of
	# the bin size.

	i = 1 + n * (1. - ZRANGE) / 2.
	j = 1 + n * (1. + ZRANGE) / 2.
	z1 = a[i]
	z2 = a[j]
	if (fp_equalr (z1, z2)) {
	    mode = z1
	    return (mode)
	}

	zzstep = ZSTEP * (z2 - z1)
	zzbin = ZBIN * (z2 - z1)
	# Kavan's note: Avoid picking up noise spikes
	zzbin = max (BINMIN, zzbin)
	z1 = z1 - zzstep
	k = i
	nmax = 0
	repeat {
	    z1 = z1 + zzstep
	    z2 = z1 + zzbin
	    for (; i < j && a[i] < z1; i=i+1)
		;
	    for (; k < j && a[k] < z2; k=k+1)
		;
	    if (k - i > nmax) {
	        nmax = k - i
	        mode = a[(i+k)/2]
	    }
	} until (k >= j)

	return (mode)
end

