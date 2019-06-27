include	"../gcombine.h"


# G_UAVERAGE -- Compute an averaged image line with uniform weights
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_uaverages (data, id, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw			# Pointer to the scaling factors structure

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin

	# Uniform weighting
	if (DOWTS) {
	    do i = 1, npts {
		if (n[i] > 0) {
		    n1 = n[i]
		    k = i - 1
		    sum = 0.0
		    sumwt = 0.0
	    	    do j = 1, n1 {
			idj = Memi[id[j]+k]
		    	wt = Memr[UWTS(szuw)+idj-1]
		        sum = sum + Mems[data[j]+k] * wt
		        sumwt = sumwt + wt
		    }
		    if (fp_equalr (sumwt, 0.0))
		    	average[i] = BLANK
	            else
		    	average[i] = sum / sumwt
	        } else
		    average[i] = BLANK
	    }
	} else {
	    do i = 1, npts {
		if (n[i] >0) {
		    k = i - 1
		    n1 = n[i]
		    sum = 0.0
		    do j = 1, n1
		        sum = sum + Mems[data[j]+k]
		    average[i] = sum / real (n1)
		} else
		    average[i] = BLANK
	    }
	}

end

# G_PAVERAGE -- Compute an averaged image line with pixelwise weights
#
# CYZhang April 10, 1994

procedure g_paverages (data, id, errdata, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
pointer	errdata[ARB]		# Error data line pointer
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin
	# Pixelwise weighting
	
	do i = 1, npts {
	    if (n[i] > 0) {
		k = i - 1
	    	n1 = n[i]
		sum = 0.0
		sumwt = 0.0
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    # errdata already scaled and re-arranged as data array
		    # their IDs are kept in the ID array.
	            wt = Memr[errdata[j]+k]
		    if (wt <= 0.0) 
			wt = Memi[NCOMB(szuw)+idj-1]
		    else
			wt = Memi[NCOMB(szuw)+idj-1] / wt**2
		    sum = sum + Mems[data[j]+k] * wt
		    sumwt = sumwt + wt
		}
		if (fp_equalr (sumwt, 0.0))
		    average[i] = BLANK
		else
		    average[i] = sum / sumwt
	    } else
		average[i] = BLANK	
	}

end

# G_UAVERAGE -- Compute an averaged image line with uniform weights
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_uaveragei (data, id, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw			# Pointer to the scaling factors structure

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin

	# Uniform weighting
	if (DOWTS) {
	    do i = 1, npts {
		if (n[i] > 0) {
		    n1 = n[i]
		    k = i - 1
		    sum = 0.0
		    sumwt = 0.0
	    	    do j = 1, n1 {
			idj = Memi[id[j]+k]
		    	wt = Memr[UWTS(szuw)+idj-1]
		        sum = sum + Memi[data[j]+k] * wt
		        sumwt = sumwt + wt
		    }
		    if (fp_equalr (sumwt, 0.0))
		    	average[i] = BLANK
	            else
		    	average[i] = sum / sumwt
	        } else
		    average[i] = BLANK
	    }
	} else {
	    do i = 1, npts {
		if (n[i] >0) {
		    k = i - 1
		    n1 = n[i]
		    sum = 0.0
		    do j = 1, n1
		        sum = sum + Memi[data[j]+k]
		    average[i] = sum / real (n1)
		} else
		    average[i] = BLANK
	    }
	}

end

# G_PAVERAGE -- Compute an averaged image line with pixelwise weights
#
# CYZhang April 10, 1994

procedure g_paveragei (data, id, errdata, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
pointer	errdata[ARB]		# Error data line pointer
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin
	# Pixelwise weighting
	
	do i = 1, npts {
	    if (n[i] > 0) {
		k = i - 1
	    	n1 = n[i]
		sum = 0.0
		sumwt = 0.0
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    # errdata already scaled and re-arranged as data array
		    # their IDs are kept in the ID array.
	            wt = Memr[errdata[j]+k]
		    if (wt <= 0.0) 
			wt = Memi[NCOMB(szuw)+idj-1]
		    else
			wt = Memi[NCOMB(szuw)+idj-1] / wt**2
		    sum = sum + Memi[data[j]+k] * wt
		    sumwt = sumwt + wt
		}
		if (fp_equalr (sumwt, 0.0))
		    average[i] = BLANK
		else
		    average[i] = sum / sumwt
	    } else
		average[i] = BLANK	
	}

end

# G_UAVERAGE -- Compute an averaged image line with uniform weights
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_uaverager (data, id, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw			# Pointer to the scaling factors structure

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin

	# Uniform weighting
	if (DOWTS) {
	    do i = 1, npts {
		if (n[i] > 0) {
		    n1 = n[i]
		    k = i - 1
		    sum = 0.0
		    sumwt = 0.0
	    	    do j = 1, n1 {
			idj = Memi[id[j]+k]
		    	wt = Memr[UWTS(szuw)+idj-1]
		        sum = sum + Memr[data[j]+k] * wt
		        sumwt = sumwt + wt
		    }
		    if (fp_equalr (sumwt, 0.0))
		    	average[i] = BLANK
	            else
		    	average[i] = sum / sumwt
	        } else
		    average[i] = BLANK
	    }
	} else {
	    do i = 1, npts {
		if (n[i] >0) {
		    k = i - 1
		    n1 = n[i]
		    sum = 0.0
		    do j = 1, n1
		        sum = sum + Memr[data[j]+k]
		    average[i] = sum / real (n1)
		} else
		    average[i] = BLANK
	    }
	}

end

# G_PAVERAGE -- Compute an averaged image line with pixelwise weights
#
# CYZhang April 10, 1994

procedure g_paverager (data, id, errdata, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
pointer	errdata[ARB]		# Error data line pointer
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
real	average[npts]		# Average (returned)
pointer	szuw

int	i, j, k, n1, idj
real	sumwt, wt
real	sum

bool	fp_equalr()

include	"../gcombine.com"

begin
	# Pixelwise weighting
	
	do i = 1, npts {
	    if (n[i] > 0) {
		k = i - 1
	    	n1 = n[i]
		sum = 0.0
		sumwt = 0.0
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    # errdata already scaled and re-arranged as data array
		    # their IDs are kept in the ID array.
	            wt = Memr[errdata[j]+k]
		    if (wt <= 0.0) 
			wt = Memi[NCOMB(szuw)+idj-1]
		    else
			wt = Memi[NCOMB(szuw)+idj-1] / wt**2
		    sum = sum + Memr[data[j]+k] * wt
		    sumwt = sumwt + wt
		}
		if (fp_equalr (sumwt, 0.0))
		    average[i] = BLANK
		else
		    average[i] = sum / sumwt
	    } else
		average[i] = BLANK	
	}

end

# G_UAVERAGE -- Compute an averaged image line with uniform weights
#
# CYZhang April 10, 1994 Based on images.imcombine

procedure g_uaveraged (data, id, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
double	average[npts]		# Average (returned)
pointer	szuw			# Pointer to the scaling factors structure

int	i, j, k, n1, idj
real	sumwt, wt
double	sum

bool	fp_equalr()

include	"../gcombine.com"

begin

	# Uniform weighting
	if (DOWTS) {
	    do i = 1, npts {
		if (n[i] > 0) {
		    n1 = n[i]
		    k = i - 1
		    sum = 0.0
		    sumwt = 0.0
	    	    do j = 1, n1 {
			idj = Memi[id[j]+k]
		    	wt = Memr[UWTS(szuw)+idj-1]
		        sum = sum + Memd[data[j]+k] * wt
		        sumwt = sumwt + wt
		    }
		    if (fp_equalr (sumwt, 0.0))
		    	average[i] = BLANK
	            else
		    	average[i] = sum / sumwt
	        } else
		    average[i] = BLANK
	    }
	} else {
	    do i = 1, npts {
		if (n[i] >0) {
		    k = i - 1
		    n1 = n[i]
		    sum = 0.0
		    do j = 1, n1
		        sum = sum + Memd[data[j]+k]
		    average[i] = sum / real (n1)
		} else
		    average[i] = BLANK
	    }
	}

end

# G_PAVERAGE -- Compute an averaged image line with pixelwise weights
#
# CYZhang April 10, 1994

procedure g_paveraged (data, id, errdata, n, npts, average, szuw)

pointer	data[ARB]		# Data pointers
pointer	id[ARB] 		# IDs
pointer	errdata[ARB]		# Error data line pointer
int	n[npts]			# Number of retained pixels
int	npts			# Number of output points per line
double	average[npts]		# Average (returned)
pointer	szuw

int	i, j, k, n1, idj
real	sumwt, wt
double	sum

bool	fp_equalr()

include	"../gcombine.com"

begin
	# Pixelwise weighting
	
	do i = 1, npts {
	    if (n[i] > 0) {
		k = i - 1
	    	n1 = n[i]
		sum = 0.0
		sumwt = 0.0
		do j = 1, n1 {
		    idj = Memi[id[j]+k]
		    # errdata already scaled and re-arranged as data array
		    # their IDs are kept in the ID array.
	            wt = Memr[errdata[j]+k]
		    if (wt <= 0.0) 
			wt = Memi[NCOMB(szuw)+idj-1]
		    else
			wt = Memi[NCOMB(szuw)+idj-1] / wt**2
		    sum = sum + Memd[data[j]+k] * wt
		    sumwt = sumwt + wt
		}
		if (fp_equalr (sumwt, 0.0))
		    average[i] = BLANK
		else
		    average[i] = sum / sumwt
	    } else
		average[i] = BLANK	
	}

end

