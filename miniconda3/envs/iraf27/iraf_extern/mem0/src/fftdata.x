# Copyright(c) 1992 Association of Universities for Research in Astronomy Inc.

include	<math.h>

# FFTDATA -- Generate data for FFT test.

procedure fftdata (a, n1, n2)

real	a[n1,n2]	# Array to hold data
int	n1, n2 		# Size of the array in each dim.

int	hn1, hn2 	# Parameters for the function to be generated
real	sgmi, sgmj

int	i, j
real	scale, gj 

begin
	# Gaussian function
	hn1 = n1 / 2 + 1
	hn2 = n2 / 2 + 1
	sgmi = 1.0
	sgmj = 1.0
	scale = 0.0
	do j = 1, n2 {
	    gj = exp (-0.5 * ((j - hn2) / sgmj) ** 2)
	    do i = 1, n1 {
         	a[i,j] = gj * exp (-0.5 * ((i - hn1) / sgmi) ** 2)
	        scale = scale + a[i,j]    
	    }
	}

	# Normalization
	do j = 1, n2
	    do i = 1, n1 
	        a[i,j] =a[i,j] / scale
end	
