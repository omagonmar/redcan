# Copyright(c) 1992 Association of Universities for Research in Astronomy Inc.

# Interface procedures for using subs in the NCARFFT library for 2-D FFT.
# (1) fft_b_ma (pt_carray, n1, n2, work) 	# Initialize  
# (2) fft_b_mf (pt_carray, work)		# Memory free 
# (3) ffft_b (rarray, carray, n1, n2, work)	# Forward FFT
# (4) ifft_b (carray, rarray, n1, n2, work)	# Inverse FFT

define	LEN_WORK	3
define	TRIGTAB1	Memi[$1]
define	TRIGTAB2	Memi[$1+1]
define	XWORK		Memi[$1+2]

procedure fft_b_ma (pt_carray, n1, n2, work)

# Memory allocation for complex data array and working space for FFT

pointer	pt_carray	# Pointer of complex array 
int	n1, n2		# Array dimensions
pointer	work		# Pointer of fft work structure

int	narr		# Total number of points in array
int	wsiz		# Size of trigonometrical fn table 

begin
	narr = n1 * n2
	call malloc (pt_carray, narr, TY_COMPLEX)

	call malloc (work, LEN_WORK, TY_STRUCT)
	wsiz = n1 * 4 + 15
	call calloc (TRIGTAB1(work), wsiz, TY_REAL)
	call cffti (n1, Memr[TRIGTAB1(work)])

	wsiz = n2 * 4 + 15
	call calloc (TRIGTAB2(work), wsiz, TY_REAL)
	call cffti (n2, Memr[TRIGTAB2(work)])

	call malloc (XWORK(work), n2, TY_COMPLEX)
end

procedure fft_b_mf (pt_carray, work)

# Memory deallocation for complex data array and working space for FFT

pointer	pt_carray	# Pointer of complex array 
pointer	work		# Pointer of fft work structure

begin
	call mfree (pt_carray, TY_COMPLEX)

	call mfree (TRIGTAB1(work), TY_REAL)
	call mfree (TRIGTAB2(work), TY_REAL)
	call mfree (XWORK(work), TY_COMPLEX)
	call mfree (work, TY_STRUCT)
end

procedure ffft_b (rinput, coutput, n1, n2, work)

# 2-D forward FFT based on NCARFFT. FFT in NCAR is done for complex
# array. So the real input array is moved to the complex array, which
# is then FFTed and output. The scale factor=1.0 (not scaled).

real	rinput[n1,n2]		# Input real array
complex	coutput[n1,n2]		# Output complex array, allocated in fft_b_ma
int	n1, n2			# Array dimensions
pointer	work			# FFT work structure, allocated in fft_b_ma 

int	i, j

begin
	# Transform row by row 
	do i = 1, n2 {
	    call achtrx (rinput[1,i], coutput[1,i], n1)
	    call cfftf (n1, coutput[1,i], Memr[TRIGTAB1(work)])
        }

	# Transform column by column
	do i = 1, n1 {
	    do j = 1, n2 {
	        Memx[XWORK(work)+j-1] = coutput[i,j]
	    }
	    call cfftf (n2, Memx[XWORK(work)], Memr[TRIGTAB2(work)])
	    do j = 1, n2 {
	        coutput[i,j] = Memx[XWORK(work)+j-1]
	    }
	}
end

procedure ifft_b (cinput, routput, n1, n2, work)

# 2-D inverse FFT based on NCARFFT. FFT in NCAR is done for complex
# array. So the complex array after FFT is moved to a real array before
# output. The scale factor=1.0/(n1*n2).
# N.B. The input complex array, cinput, is changed after FFT !!

complex	cinput[n1,n2]		# Input complex array, allocated in fft_b_ma
real	routput[n1,n2]		# Output real array
int	n1, n2			# Array dimensions
pointer	work			# FFT work structure,allocated in fft_b_ma 

real	scale			# Scale factor = 1.0/(n1*n2)
int	i, j

begin
	scale = 1.0 / (n1 * n2)

	# Transform row by row
	do i = 1, n2 {
	    call cfftb (n1, cinput[1,i], Memr[TRIGTAB1(work)])
	}

	# Transform column by column
	do i = 1, n1 {
	    do j = 1, n2 {
	        Memx[XWORK(work)+j-1] = cinput[i,j]
	    }
	    call cfftb (n2, Memx[XWORK(work)], Memr[TRIGTAB2(work)])
	    do j = 1, n2 {
	        cinput[i,j] = Memx[XWORK(work)+j-1]
	    }
	}

	# Extract real part of complex array and scale it
	do i = 1, n2 {
	    call achtxr (cinput[1,i], routput[1,i], n1)
	    do j = 1, n1
	        routput[j,i] = routput[j,i] * scale    
	}
end
