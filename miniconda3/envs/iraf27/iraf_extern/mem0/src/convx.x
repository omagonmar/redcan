# 4 procedures shared by t_imconv.x, t_irme0.x

# Move real ain[n1in,n2in] to aout[n1out,n2out]. ain[1,1] => aout[1,1]

procedure move_array (ain, n1in, n2in, aout, n1out, n2out)

real	ain[n1in,n2in], aout[n1out,n2out]  # Input and output real arrays
int	n1in, n2in, n1out, n2out	   # Array sizes

int	n1min, n2min, i, j

begin
	n1min = min (n1in, n1out)
	n2min = min (n2in, n2out)

	# Clear the out array

	do j = 1, n2out
	    do i = 1, n1out
	        aout[i,j] = 0.0 

	# Copy from input to out array

	do j = 1, n2min
	    do i = 1, n1min
	        aout[i,j] = ain[i,j] 
end

# Find the peak value and its location of a real array

procedure arrpeak (a, n1, n2, pval, ploc)

real	a[n1,n2]
int	n1, n2
real	pval		# Peak value
int	ploc[2]		# Peak location

real	ptmp	
int	i, j 

real	ahivr()

begin

	    pval = ahivr (a[1,1], n1)
	    ploc[2] = 1
	    do j = 2, n2 {
	        ptmp = ahivr (a[1,j], n1)
	        if (ptmp > pval) {
	            pval = ptmp
	            ploc[2] = j
	        }
	    }
	    ploc[1] = 1
	    do i = 1, n1 {
	        if (a[i,ploc[2]] == pval) {
	            ploc[1] = i
	            break
	        }
	    }
end

# Shift array a[n1,n2] by (sh[1],sh[2]) so that its peak at [1,1] if center=yes,
# then set the peak value=1.0 if norm="peak", or volume=1.0 if norm="volume".
# Real array atmp is working space.

procedure standard (a, n1, n2, center, norm, pval, sh, atmp)

real	a[n1,n2]
int	n1, n2
bool	center		# Move PSF peak to the DFT center?
char	norm[SZ_LINE]	# Normalization control
real	pval		# Peak value of array
int	sh[2]		# Amount of shift
real	atmp[n1,n2]	# Working space

int	narr		# Total number of points in array
int	inln, outln, i, j
real	scale

int	strncmp ()

begin
	narr = n1 * n2

	if (center) {
	    outln = 1 + sh[2]
	    outln = mod (outln, n2)
	    do inln = 1, n2 {
	        if (outln < 1)
	            outln = outln + n2
	        if (outln > n2)
                   outln = outln - n2
                call lnshift (a[1,inln], atmp[1,outln], n1, sh[1]) 
                outln = outln + 1
	    }
	    do j = 1, n2
	        do i = 1, n1 
	            a[i,j] = atmp[i,j]
	}
	
	if (strncmp (norm, "p", 1) == 0) {	# For peak normalization
	    scale =  pval
	    call adivkr (a, scale, a, narr)
	}
	if (strncmp (norm, "v", 1) == 0) { 	# For volume normalization
	    scale = 0.0
	    do j = 1, n2
	        do i = 1, n1 
	            scale = scale + a[i,j]
	    call adivkr (a, scale, a, narr)
	}
end

# Shift cyclically 1-D array ain[n1] by sh1, resulting aout[n1]. 
# ain and aout must be distinct arrays.

procedure lnshift (ain, aout, n1, sh1)

real	ain[n1], aout[n1]	# Input and output arrays
int	n1, sh1

int	shabs		# abs (sh1)
int	nx		# n1 - abs(sh1)

begin
 
	if (sh1 > 0) {
	    nx = n1 - sh1
	    call amovr (ain, aout[sh1+1], nx)
	    call amovr (ain[nx+1], aout, sh1)
	} else if (sh1 < 0) {
	    shabs = abs (sh1)
	    nx = n1 - shabs
	    call amovr (ain, aout[nx+1], shabs)
	    call amovr (ain[shabs+1], aout, nx)
	} else {
	    call amovr (ain, aout, n1)
	}
end
