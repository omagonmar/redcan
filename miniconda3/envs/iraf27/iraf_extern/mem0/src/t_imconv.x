# Copyright(c) 1992 Association of Universities for Research in Astronomy Inc.

include	<fset.h>
include	<imhdr.h>

# IMCONV -- Perform 2-D convolution by the FFT technique. This is designed 
# particularly for convolving an image with a point spread function.
# By defaut (center=yes, norm="volume"), the input PSF peak will be moved 
# to the DFT center [1,1] and its volume is normalized to 1. For general use
# of this program, set center=no and norm="no". 
# 
# N.B. No restriction on the sizes of the image and PSF, but the image's
# part of interest may be shifted out of the image after convolution
# if center=no.
# 
# Link to: fft_ncar.o  /usr/stsci/stsdasx/lib/libapplib.a
#
# Some procedures are in convx.x

procedure t_imconv ()

pointer	sp		# Memory stack pointer
pointer	in_im		# Input image name string pointer
pointer in_psf		# Input point spread function file name string pointer
pointer out_im		# Output image name string pointer

pointer	in		# Input image descriptor
pointer psf		# PSF file descriptor
pointer out		# Output image descriptor

pointer	pt_impsf	# Image and PSF 
pointer	pt_psfft	# FFT of PSF 

bool	center		# Move PSF peak to DFT center [1,1]?
char	norm[SZ_LINE]	# PSF normalization: "no", "peak", or "volume".

pointer	pt_imio		# Image to be read in or written out 

int	npix_im, nlin_im, npix_psf, nlin_psf	# Image and PSF sizes
int	n1max, n2max				# Size max
int	narr		# Total number of points in array

real	pval		# Peak value of PSF 
int	ploc[2]		# Peak location of PSF 
int	sh[2]		# Amount of PSF peak shift for centering it

pointer	pt_carray, work	# For FFT 

int	fstati(), strncmp()
bool	clgetb()

pointer	immap(), imgs2r(), impl2r(), imps2r()

define	ZERO	0.0

begin
	# For properly print messages

	if (fstati (STDOUT, F_REDIR) == NO)
	    call fseti (STDOUT, F_FLUSHNL, YES)

	# Initialize the dynamic memory stack for image names

	call smark (sp)
	call salloc (in_im, SZ_FNAME, TY_CHAR)
	call salloc (in_psf, SZ_FNAME, TY_CHAR)
	call salloc (out_im, SZ_FNAME, TY_CHAR)

	# Get input and output file names

	call clgstr ("input", Memc[in_im], SZ_FNAME)
	call clgstr ("psf", Memc[in_psf], SZ_FNAME)
	call clgstr ("output", Memc[out_im], SZ_FNAME)

	# Get more parameter

	center = clgetb ("center")
	call clgstr ("norm", norm, SZ_LINE)

	# Open the input image and get its size

	in = immap (Memc[in_im], READ_ONLY, 0)
	npix_im = IM_LEN(in,1)	
	nlin_im = IM_LEN(in,2)	

	# Open the PSF file 
	
	psf = immap (Memc[in_psf], READ_ONLY, 0)
	npix_psf = IM_LEN(psf,1)	
	nlin_psf = IM_LEN(psf,2)	

	# Memory allocation for arrays according to their max size

	n1max = max (npix_im, npix_psf)
	n2max = max (nlin_im, nlin_psf)
	narr = n1max * n2max

	call malloc (pt_impsf, narr, TY_REAL)
	call malloc (pt_psfft, narr, TY_COMPLEX)

	# Read in image, and move it to the real array, starting at [1,1].

	pt_imio = imgs2r (in, 1, npix_im, 1, nlin_im)
	call move_array (Memr[pt_imio], npix_im, nlin_im, Memr[pt_impsf],
	    n1max, n2max)
	
	# Reserve disk space for the output convolved image 

	out = immap (Memc[out_im], NEW_COPY, in)
	pt_imio = impl2r (out, 1)
	Memr[pt_imio] = 1.0
	call imunmap (out)

	call imunmap (in)

	# Froward FFT image 

	call fft_b_ma (pt_carray, n1max, n2max, work)
	call ffft_b (Memr[pt_impsf], Memx[pt_carray], n1max, n2max, work)

	# Read in PSF, and move it to the real array, starting at [1,1].

	pt_imio = imgs2r (psf, 1, npix_psf, 1, nlin_psf)
	call move_array (Memr[pt_imio], npix_psf, nlin_psf, Memr[pt_impsf],
	    n1max, n2max)
	
	# Close PSF file

	call imunmap (psf)

	# Shift PSF so that its peak is at [1,1] (center of DFT)
	# if center=yes, then normalize it so that its peak=1 if norm="peak",
	# or volume=1 if norm="volume".
	# Complex array Memx[pt_psfft] is used as real working array.

	if (center || strncmp (norm, "p", 1) == 0) {
	    # Find peak value and its location of array
	        
	    call arrpeak (Memr[pt_impsf], n1max, n2max, pval, ploc)
	    sh[1] = -ploc[1] + 1
	    sh[2] = -ploc[2] + 1
	}
	call standard (Memr[pt_impsf], n1max, n2max, center, norm,
	    pval, sh, Memx[pt_psfft])

	# Do convolution

	call ffft_b (Memr[pt_impsf], Memx[pt_psfft], n1max, n2max, work)
	call amulx (Memx[pt_carray], Memx[pt_psfft], Memx[pt_carray], narr)
	call ifft_b (Memx[pt_carray], Memr[pt_impsf], n1max, n2max, work)

	# Deallocate memory for FFT

	call fft_b_mf (pt_carray, work)
	
	# Open the output image again, output the convolved image,
	# then close it.

	out = immap (Memc[out_im], READ_WRITE, 0)
	pt_imio = imps2r (out, 1, npix_im, 1, nlin_im)
	call move_array (Memr[pt_impsf], n1max, n2max, Memr[pt_imio],
	    npix_im, nlin_im)

	call imunmap (out)

	# Free dynamic memory

	call sfree (sp)

	call mfree (pt_impsf, TY_REAL)
	call mfree (pt_psfft, TY_COMPLEX)
end
