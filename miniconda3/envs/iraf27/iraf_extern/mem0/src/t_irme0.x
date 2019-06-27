# Copyright(c) 1993 Association of Universities for Research in Astronomy Inc.

include	<ctype.h>
include	<fset.h>
include	<imhdr.h>
include	<mach.h>
include	<math.h>

# IRME0 -- Perform MEM deconvolution on a 1-D or 2-D degraded image.
# This is version C, equivalent to MEM in STSDAS.analysis.restore. 
# Nailong Wu, 06-Dec-1993.

define	H2	(-$1*(log($1/$2)-1.0)-$2)  # A component of the entropy function
define	DH2	(-log($1/$2))	           # A component of the entropy gradient
define	CLIP	(max(double($1),EPSILOND)) # Clip a zero or -ve value of image

procedure t_irme0 ()

include	"irme0.com"

# This is an MEM deconvolution procedure using the zeroth-order 
# approximate Newton-Raphson method for optimization. The model updating
# technique is used to speed up convergence.
#
# Some procedures are in convx.x
 
# Filename string pointers

pointer	sp		# Memory stack pointer
pointer	in_deg		# Input degraded image 
pointer in_psf		# Input point spread function 
pointer	in_mod		# Input model (prior estimated) image 
pointer in_icf		# Input Intrinsic Correlation Function 
pointer out_rest	# Output restored image

# File descriptor pointers

pointer	degrade		# Degraded image 
pointer psf		# PSF file 
pointer	model		# Model image
pointer restore		# Output restored image 

# Dynamic memory pointers for image data and working space

pointer	pt_deg		# Degraded image
pointer	pt_psfft	# FFT of PSF combined with ICF or ICF  
pointer	pt_mod		# Model image
pointer	pt_current	# Current image in iteration
pointer	pt_conv		# Current image convolved with the PSF and ICF
pointer	pt_new		# Next image in iteration
pointer	pt_newconv	# Next image convolved with the PSF and ICF
pointer	pt_gradE	# Gradient of half chi-sq 
pointer	pt_NgradE	# New gradient of half chi-sq 
pointer	pt_hess		# Diagonal elements of Hessian of half chi-sq 

pointer	pt_imio		# Image to be read in or written out 
pointer	pt_cwkspace	# Complex working space 

pointer	pt_carray, work	# Complex array and working space for FFT

# Image and array sizes

int	n1_deg, n2_deg	# Degraded image size
int	n1_psf, n2_psf	# PSF file size
int	n1_mod, n2_mod	# Model image size
int	n1max, n2max	# Array size
int	n1lim, n2lim	# Read-in area size of model image

# Parameters for deconvoltuion

real	noise		# Readout noise in electrons
real	adu		# A/D conversion constant, electrons/DN
real	vc[2]		# Coeffs. for calc. noise var. of the degraded image
real	sigma[2]	# Sigmas of Gaussian fn as ICF 
real	fwhm[2]		# Full widths at half max of Gaussian fn as ICF
bool	hidden		# Output a hidden (or visible) image?
real	a_sp, b_sp	# Speed factors for renewing alpha and beta
real	a_rate  	# In/decrease rate of a_sp
real	aim		# Factor for setting actual target chi-sq
int	maxiter		# Max number of iterations
int	m_update	# Model update interval (number of outer iterations)
int	opt		# Optimal one-dim. search in the N-R direction 
real	tol[3]		# Convergence tolerances for ME solution, chi-sq, tp

int	message		# Verboseness of output messages, 1 (least) - 3 (most)

# Other variables in iteration

bool	useicf		# Use ICF?
int	niter		# Counter of the total iteration number	
bool	me_image	# Is the output image an ME image?
bool	converge	# Is the output image a converged one?

int	narr		# Total number of points in array

real	pval		# Peak value of array
int	ploc[2]		# Peak location
int	sh[2]		# Amount of array shift 
bool	center		# Center PSF, ICF?
char	norm[SZ_LINE]	# Normalize PSF, ICF; "no", "peak", or "volume"
real	v_on_m		# Vol/max of ACF of combinatn of PSF and ICF 

int	fstati(), clgeti(), imaccf()
real	clgetr(), imgetr()
bool	clgetb()

pointer	immap(), impl2r(), imgs2r(), imps2r()

begin
	# For properly output messages

	if (fstati (STDOUT, F_REDIR) == NO)
	    call fseti (STDOUT, F_FLUSHNL, YES)

	# Initialize the dynamic memory stack for image name strings

	call smark (sp)
	call salloc (in_deg, SZ_FNAME, TY_CHAR)
	call salloc (in_psf, SZ_FNAME, TY_CHAR)
	call salloc (in_mod, SZ_FNAME, TY_CHAR)
	call salloc (in_icf, SZ_FNAME, TY_CHAR)
	call salloc (out_rest, SZ_FNAME, TY_CHAR)

	# Get input and output file names

	call clgstr ("input", Memc[in_deg], SZ_FNAME)
	call clgstr ("psf", Memc[in_psf], SZ_FNAME)
	call clgstr ("model", Memc[in_mod], SZ_FNAME)
	call clgstr ("icf", Memc[in_icf], SZ_FNAME)
	call clgstr ("output", Memc[out_rest], SZ_FNAME)

	# Get parameters for deconvolution

	noise = clgetr ("rdnoise")		
	adu = clgetr ("gain")		
	vc[1] = (noise / adu) ** 2 
	vc[2] = 1.0 / adu 

	tp = clgetr ("tp")		# Total power (flux) of image

	sigma[1] =  clgetr ("sigma[1]")
	if (sigma[1] <= EPSILONR) {
	    fwhm[1] =  clgetr ("fwhm[1]")
	    sigma[1] = fwhm[1] / sqrt (8.0 * log (2.0))
	} else
	    fwhm[1] = sigma[1] * sqrt (8.0 * log (2.0))
	
	sigma[2] =  clgetr ("sigma[2]")
	if (sigma[2] <= EPSILONR) {
	    fwhm[2] =  clgetr ("fwhm[2]")
	    sigma[2] = fwhm[2] / sqrt (8.0 * log (2.0))
	} else
	    fwhm[2] = sigma[2] * sqrt (8.0 * log (2.0))
	hidden= clgetb ("hidden")
	
	a_sp = clgetr ("a_sp")
	a_rate = clgetr ("a_rate")
	b_sp = clgetr ("b_sp")
	aim = clgetr ("aim")
	maxiter = clgeti ("maxiter")
	m_update = clgeti ("m_update")
	damping = clgetr ("damping")	# Normalized damping factor 
	opt = clgeti ("opt")
	tol[1] = clgetr ("tol[1]")
	tol[2] = clgetr ("tol[2]")
	tol[3] = clgetr ("tol[3]")

	message = clgeti ("message")

	if (message >= 2) {
	    # Output the input parameters for perhaps keeping a record

	    call printf ("\nInput summary:\n")
	    call printf ("Input degraded image = %s\n") 
	        call pargstr(Memc[in_deg])
	    call printf ("Input PSF = %s\n") 
	        call pargstr(Memc[in_psf])
	    call printf ("Input model image = %s\n") 
	        call pargstr(Memc[in_mod])
	    call printf ("Input ICF = %s\n") 
	        call pargstr(Memc[in_icf])
	    call printf ("Output restored image = %s\n") 
	        call pargstr(Memc[out_rest])
	    call printf ("rdnoise = %g  gain = %g  tp = %g  aim = %g")
	        call pargr(noise)
	        call pargr(adu)
	        call pargr(tp)
	        call pargr(aim)
	    call printf ("  maxiter = %d\n")
	        call pargi(maxiter)
	    call printf ("sigma1-2 =  %g, %g   fwhm1-2 = %g, %g   ")
	        call pargr(sigma[1])
	        call pargr(sigma[2])
	        call pargr(fwhm[1])
	        call pargr(fwhm[2])
	    call printf ("hidden = %b\n")
	        call pargb(hidden)
	    call printf ("a_sp = %g   a_rate = %g   b_sp = %g  damping = %g")
	        call pargr(a_sp)
	        call pargr(a_rate)
	        call pargr(b_sp)
	        call pargr(damping)
	    call printf ("  opt = %d\n")
	        call pargi(opt)
	    call printf ("tol1-3 = %g, %g, %g   message = %d   m_update = %d\n")
	        call pargr(tol[1])
	        call pargr(tol[2])
	        call pargr(tol[3])
	        call pargi(message)
	        call pargi(m_update)
	    }

	# Open the degraded image and get its size

	degrade = immap (Memc[in_deg], READ_ONLY, 0)
	n1_deg = IM_LEN(degrade,1)	
	n2_deg = IM_LEN(degrade,2)	

	# Open the PSF file and get its size

	psf = immap (Memc[in_psf], READ_ONLY, 0)
	n1_psf = IM_LEN(psf,1)	
	n2_psf = IM_LEN(psf,2)	

	# Open the model image, if supplied, and get its size

	if (Memc[in_mod] != EOS && !IS_WHITE(Memc[in_mod])) {
	    model = immap (Memc[in_mod], READ_ONLY, 0)
	    n1_mod = IM_LEN(model,1)	
	    n2_mod = IM_LEN(model,2)	
	}

	# Open the output deconvolved image, then close it to reserve
	# disk space. N.B. the output image pixel value datatype is
	# forced to be real.

	restore = immap (Memc[out_rest], NEW_COPY, degrade)
	IM_PIXTYPE(restore) = TY_REAL
	pt_imio = impl2r (restore, 1)
	Memr[pt_imio] = 1.0
	call imunmap (restore)

	# Array size = max of deg. image and PSF sizes

	n1max = max (n1_deg, n1_psf)
	n2max = max (n2_deg, n2_psf)

	# Dynamic memory allocation for input images and part of working space

	narr = n1max * n2max 
	call malloc (pt_deg, narr, TY_REAL)
	call malloc (pt_psfft, narr, TY_COMPLEX)

	call malloc (pt_current, narr, TY_REAL)
	call malloc (pt_conv, narr, TY_REAL)
	call malloc (pt_new, narr, TY_REAL)

	call malloc (pt_hess, narr, TY_REAL)

	call malloc (pt_cwkspace, narr, TY_COMPLEX)

	# Initialize FFT

	call fft_b_ma (pt_carray, n1max, n2max, work)

	# Read in degraded image and move it to real array, starting at [1,1]

	pt_imio = imgs2r (degrade, 1, n1_deg, 1, n2_deg)
	call move_array (Memr[pt_imio], n1_deg, n2_deg, Memr[pt_deg],
	    n1max, n2max)
	call imunmap (degrade)

	# Combine PSF and ICF. Arrays "current" and "conv" hold PSF and ICF,
	# respectively, "new" is working space. Array "psfft" holds the result.

	# Read in PSF, center and normalize its peak.
	pt_imio = imgs2r (psf, 1, n1_psf, 1, n2_psf)
	call move_array (Memr[pt_imio], n1_psf, n2_psf, Memr[pt_current],
	    n1max, n2max)
	call imunmap (psf)

	call arrpeak (Memr[pt_current], n1max, n2max, pval, ploc)
	sh[1] = -ploc[1] + 1
	sh[2] = -ploc[2] + 1
	center = true
	call strcpy ("peak", norm, SZ_LINE)
	call standard (Memr[pt_current], n1max, n2max, center, norm,
	    pval, sh, Memr[pt_new])

	# Read in ICF if supplied, otherwise generate an elliptic Gaussian
	# function as ICF.
	useicf = false
	call get_icf (Memc[in_icf], Memr[pt_conv], n1max, n2max, sigma,
	    useicf)

	# Center and normalize ICF's volume if use it
	if (useicf) {
	    call arrpeak (Memr[pt_conv], n1max, n2max, pval, ploc)
 	    sh[1] = -ploc[1] + 1
	    sh[2] = -ploc[2] + 1
	    center = true
	    call strcpy ("volume", norm, SZ_LINE)
	    call standard (Memr[pt_conv], n1max, n2max, center, norm,
	        pval, sh, Memr[pt_new])
	}
	# Perform FFT on PSF and ICF, then combine them. The combined PSF and
	# ICF is normalized so its volume=1. Also calculate some parameters.
	call trans_psf_c (Memr[pt_current], Memr[pt_conv], Memx[pt_psfft],
	    n1max, n2max, useicf, v_on_m, Memx[pt_carray], work)

	# Calculate the diagonal elements of Hessian of half chi-sq 

	call cal_hessian (Memr[pt_deg], Memx[pt_psfft], Memr[pt_hess],
	    n1max, n2max, n1_deg, n2_deg, vc, Memx[pt_cwkspace], 
	    Memx[pt_carray], work)

	# Dynamic memory deallocation, and allocation for model image

	call mfree (pt_cwkspace, TY_COMPLEX)
	call malloc (pt_mod, narr, TY_REAL)

	# Output some parameters 
	
	call printf ("\nAuto calculated parameters:\n")

	call printf ("Vol/max of ACF of combination of PSF and ICF = %g\n")
	    call pargr (v_on_m)

	# Read in the model image, if supplied, and input tp from its header
	# if the field ME_TP exists in the case where tp is not supplied;
	# otherwise generate a flat model from the tp supplied by user or
	# estimated from degraded image.
	# Note that the model image outside the degraded image area, if any,
	# will be ignored.

	if (Memc[in_mod] != EOS  && !IS_WHITE(Memc[in_mod])) {
	    # Model image read-in area size = min of deg. and mod. image sizes
	    n1lim = min (n1_deg, n1_mod)
	    n2lim = min (n2_deg, n2_mod)
	    pt_imio = imgs2r (model, 1, n1lim, 1, n2lim)
	    call move_array (Memr[pt_imio], n1lim, n2lim, Memr[pt_mod],
	        n1max, n2max)

	    if (tp <= EPSILONR)
	        # No input tp, attempt to get it from model's header. 
	        if (imaccf (model, "ME_TP") == YES) { 
	            tp = imgetr (model, "ME_TP")
  	            call printf ("Image total power from the model TP = %g\n")
	                call pargr (tp)
	        } 
	    call imunmap (model)
	} 

	if (tp <= EPSILONR) {
	    # No tp obtained so far, calculate it from input deg. image. 
	    call def_tp (Memr[pt_deg], n1max, n2max, n1_deg, n2_deg)
	    call printf ("Image total power from the degraded TP = %g\n")
	        call pargr (tp)
	}

	if (Memc[in_mod] == EOS  || IS_WHITE(Memc[in_mod]))
	    # No input model file, generate a flat one using tp. 
	    call def_model (Memr[pt_mod], n1max, n2max, n1_deg, n2_deg)
	
	# Dynamic memory allocation for more image and working space

	call malloc (pt_newconv, narr, TY_REAL)
	call malloc (pt_gradE, narr, TY_REAL)
	call malloc (pt_NgradE, narr, TY_REAL)

	# Seek the MEM solution (hidden image). 
	
	call irme_zero_c (Memr[pt_deg],  Memx[pt_psfft], Memr[pt_mod],
	    Memr[pt_hess], Memr[pt_current], Memr[pt_conv], Memr[pt_new],
	    Memr[pt_newconv], Memr[pt_gradE], Memr[pt_NgradE], n1max, n2max,
	    n1_deg, n2_deg, vc, tol, a_sp, a_rate, b_sp, aim, maxiter, 
	    m_update, opt, message, niter, Memx[pt_carray], work) 

	# Output good news

	me_image = false	
	converge = false
	if (gJ_on_gF <= tol[1]) {
	    call printf ("\nAn ME image obtained\n")
	    me_image = true	
	    if (abs(chisq - xchisq) <= tol[2] * chisq &&
	        abs(tp - xtp) <= tol[3] * tp) {
	        call printf ("Congratulations for convergence !!\n")
	        converge = true
	    }
	}
	# Free memory of some working space

	call mfree (pt_newconv, TY_REAL)
	call mfree (pt_mod, TY_REAL)
	call mfree (pt_deg, TY_REAL)	

	# Open the output deconvolved image again for writing

	restore = immap (Memc[out_rest], READ_WRITE, 0)
	pt_imio = imps2r (restore, 1, n1_deg, 1, n2_deg)
	
	if (hidden || !useicf)
	    # Output hidden image, same as visible image if no ICF is used
	    call move_array (Memr[pt_current], n1max, n2max, Memr[pt_imio],
	        n1_deg, n2_deg)
        else {
	    # Convolve the hidden image with ICF and output

	    # Get ICF again, held in array "conv".
	    call get_icf (Memc[in_icf], Memr[pt_conv], n1max, n2max, sigma,
	        useicf)

	    # Center and normalize ICF's volume 
	    call arrpeak (Memr[pt_conv], n1max, n2max, pval, ploc)
 	    sh[1] = -ploc[1] + 1
	    sh[2] = -ploc[2] + 1
	    center = true
	    call strcpy ("volume", norm, SZ_LINE)
	    call standard (Memr[pt_conv], n1max, n2max, center, norm,
	        pval, sh, Memr[pt_new])
	
	    # Do convolution, the result is held in array "conv".
	    call ffft_b (Memr[pt_conv], Memx[pt_psfft], n1max, n2max, work)
	    call convolution_c (Memx[pt_psfft], Memr[pt_current], 
	        Memr[pt_conv], n1max, n2max, Memx[pt_carray], work)

	    call move_array (Memr[pt_conv], n1max, n2max, Memr[pt_imio],
	        n1_deg, n2_deg)
	}

	# Write ME image header cards and close the restored image

	call me_header_c (restore, noise, adu, sigma, fwhm, hidden,
	    me_image, converge, niter)

	call imunmap (restore)

	# Free dynamic memories 

	call sfree (sp)

	call mfree (pt_hess, TY_REAL)

	call mfree (pt_NgradE, TY_REAL)
	call mfree (pt_gradE, TY_REAL)
	call mfree (pt_new, TY_REAL)
	call mfree (pt_conv, TY_REAL)
	call mfree (pt_current, TY_REAL)
	call mfree (pt_psfft, TY_COMPLEX)
	
	call fft_b_mf (pt_carray, work)
end

# Read in the ICF file if supplied, otherwise generate an elliptic Gaussian
# function as ICF.

procedure get_icf (icfname, icfarr, n1max, n2max, sigma, useicf)

char	icfname[SZ_FNAME]	# Input ICF file name
real	icfarr[n1max,n2max]	# Array holding ICF data
int	n1max, n2max		# Array size
real	sigma[2]		# Sigmas of the Gaussian fn (ICF)
bool	useicf			# Use ICF?

pointer	icf			# ICF file descriptor
int	n1icf, n2icf		# ICF file size
int	n1lim, n2lim		# Read-in area size of ICF
pointer	pt_imi			# ICF file to be read in

pointer	immap(), imgs2r()

begin

	if (icfname[1] != EOS && !IS_WHITE(icfname[1])) {
	# ICF file is supplied, so open it, get its size, and read in.

	    icf = immap (icfname, READ_ONLY, 0)
	    n1icf = IM_LEN(icf,1)	
	    n2icf = IM_LEN(icf,2)	

	    # ICF file read-in area size = min of array and ICF file sizes
	    n1lim = min (n1max, n1icf)
	    n2lim = min (n2max, n2icf)
	    pt_imi = imgs2r (icf, 1, n1lim, 1, n2lim)
	    call move_array (Memr[pt_imi], n1lim, n2lim, icfarr, n1max, n2max)
	    
	    call imunmap (icf)
	    useicf = true
	} else
	    if (sigma[1] > EPSILONR || sigma[2] > EPSILONR) {
	        # Generate an ICF of Gaussian type

	        call gaussfn (icfarr, n1max, n2max, sigma)
	        useicf = true
	    }
end

# Generate a volume normalized elliptic Gaussian fn centered at [n1/2+1,n2/2+1]

procedure gaussfn (icf, n1, n2, sigma)

real	icf[n1,n2]
int	n1, n2
real	sigma[2]	# Sigmas of Gaussian function

int	narr, nc1, nc2, k, l
real	gl, scale

begin
        nc1 = n1 / 2 + 1
        nc2 = n2 / 2 + 1
	narr = n1 * n2

	scale = 0.0
	do l = 1, n2 {
	    gl = exp (-0.5 * ((l - nc2) / sigma[2]) ** 2)
	    do k = 1, n1 { 
	        icf[k,l] = gl * exp (-0.5 * ((k - nc1) / sigma[1]) ** 2)
	        scale = scale + icf[k,l]
	    }
	}

	call adivkr (icf, scale, icf, narr) 
end

# Perform FFT on PSF, then multiplied by the FFT of ICF if use ICF. Output to
# complex array "psfft". The PSF and ICF have been centered. The combined
# PSF and ICF is normalized so that volume=1.
# Also calculate some parameters.

procedure trans_psf_c (psf, icf, psfft, n1, n2, useicf, v_on_m,
	      carray, work)

include	"irme0.com"

define	DAMP_MIN	0.1		# Lower limit of damping factor

real	psf[n1,n2], icf[n1,n2]		# Input PSF and ICF
complex	psfft[n1,n2]			# Output FFT of PSF with ICF
int	n1, n2
bool	useicf		# Use ICF? 
real	v_on_m		# Vol/max of ACF of vol-norm. PSF combined with ICF
complex	carray		# Complex array for FFT
pointer	work		# Working space for FFT

int	narr		# Total number of points in array
real	scale
real 	macfq, vacfq	# Max & vol of ACF of q (vol-norm. PSF with ICF)

real	asumr()

begin 
	# Combine the FFTs of PSF and ICF

	call ffft_b (psf, psfft, n1, n2, work)

	narr = n1 * n2
	if (useicf) {
	    call ffft_b (icf, carray, n1, n2, work)
	    call amulx (psfft, carray, psfft, narr)
	}
	# Normalize the volume of PSF with ICF
 
	scale = 1.0 / real (psfft[1,1])
	call altmx  (psfft, psfft, narr, scale, 0.0) 

	# Cal. macfq and vacfq, and their ratio v_on_m. array "icf"
	# is working space. 

	call amovx (psfft, carray, narr)
	call acjgx (carray, carray, narr)
	call amulx (psfft, carray, carray, narr)
	call ifft_b (carray, icf, n1, n2, work)
	
	macfq = icf[1,1]
	vacfq = asumr (icf, narr)
	v_on_m = vacfq / macfq

	# Convert the input normalized (x - 1.0 - 100.0) damping factor to
	# actual one (DAMP_MIN - 1.0 - v_on_m). 
	
	damping = max (((v_on_m - 1.0) * damping + (100.0 - v_on_m)) / 99.0,
	    DAMP_MIN)
end

# Cal. the diagonal elements of Hessian of half chi-sq 

procedure cal_hessian (degrade, psfft, hess, n1, n2, n1deg, n2deg, vc,
	      cwkspace, carray, work)

include	"irme0.com"

real	degrade[n1,n2]
complex	psfft[n1,n2]
real	hess[n1,n2]
int	n1, n2, n1deg, n2deg	# Array and degraded image sizes
real	vc[2]
complex	cwkspace[n1,n2]
complex	carray[n1,n2]
pointer	work

real 	var
int	narr, k, l

begin
	narr = n1 * n2

	# Array "psfft" must be moved to "carray" and then perform FFT on
	# "carray"! 

	call amovx (psfft, carray, narr)

	call ifft_b (carray, hess, n1, n2, work)

	# Using the FFT tech. to calculate cross correlation between
	# (PSF with ICF)**2 and 1/var, i.e., the diagonal elements required. 

	call amulr (hess, hess, hess, narr)

	call ffft_b (hess, cwkspace, n1, n2, work)

	call acjgx (cwkspace, cwkspace, narr)

	call aclrr (hess, narr)

	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var <= EPSILONR)
	            var = MAX_REAL
	        
	        hess[k,l] = 1.0 / var
	    }
	call ffft_b (hess, carray, n1, n2, work)

	call amulx (carray, cwkspace, carray, narr)
	call ifft_b (carray, hess, n1, n2, work)    
end

# Calculate the total power from the input image.
# Note that only the area defined by the degraded image is effective.

procedure def_tp (image, n1, n2, n1deg, n2deg) 

include	"irme0.com"

real	image[n1,n2]
int	n1, n2
int	n1deg, n2deg	# Degraded image size

int	k, l

begin
	tp = 0.0
	do l = 1, n2deg
	    do k = 1, n1deg
	        tp = tp + image[k,l]
end

# Generate a flat model image from the input total power.
# Note that only the area defined by the degraded image is effective.

procedure def_model (model, n1, n2, n1deg, n2deg)

include	"irme0.com"

real	model[n1,n2]
int	n1, n2
int	n1deg, n2deg	# Degraded image size

real 	intensity
int	k, l

begin
	intensity = tp / (n1deg * n2deg)

	do l = 1, n2deg {
	    do k = 1, n1deg
		model[k,l] = intensity
	    do k = n1deg + 1, n1
	        model[k,l] = 0.0
	}
	do l = n2deg + 1, n2
	    do k = 1, n1
	        model[k,l] = 0.0
end

# This is a procedure to implement the zeroth-order opproximate Newton-Raphson
# method for MEM deconvolution, version C.

procedure irme_zero_c (degrade, psfft, model, hess, current, conv, new,
	      newconv, gradE, NgradE, n1, n2, n1deg, n2deg, vc, tol, a_sp,
	      a_rate, b_sp, aim, maxiter, m_update, opt, message, niter,
	      carray, work)

include	"irme0.com"

define	NCTRL1	5	# To control the increase of a_sp and alpha
define	NCTRL2	8	# To control the decrease of a_sp and alpha

# Array containing images and working space in iteration

real 	degrade[n1,n2]	# Degraded image
complex	psfft[n1,n2]	# FFT of the PSF combined with ICF
real	model[n1,n2]	# Model image
real 	hess[n1,n2]	# Diagonal elements of Hessian of half chi-sq 
real 	current[n1,n2]	# Current image in iteration
real 	conv[n1,n2]	# Current image convolved with the PSF and ICF
real 	new[n1,n2]	# Next image in iteration
real 	newconv[n1,n2]	# Next image convolved with the PSF and ICF

real	gradE[n1,n2]	# Gradient of half chi-sq
real	NgradE[n1,n2]	# New gradient of half chi-sq

int	n1, n2		# Array size
int	n1deg, n2deg	# Degraded image size 

real	vc[2]		# Coeffs. for calc. noise var. of the degraded image
real	tol[3]		# Convergence tolerances for ME solution, chisq, tp
real	a_sp, b_sp	# Speed factors for renewing alpha and beta
real	a_rate  	# In/decrease rate of a_sp
real	aim		# Factor for setting actual target chi-sq
int	maxiter		# Max number of iterations
int	m_update	# Model updating control
int	opt		# Optimal one-dim. search in the N-R direction
int	message		# Verboseness of output message, 1 (least) - 3 (most)

int	niter		# Counter of the total iteration number	

complex	carray[n1,n2]	# Complex array for FFT
pointer	work		# Working space for FFT

# Local variables

int	narr		# The total number of points in array
int	ndata		# The total number of non-zero pixels in degraded image	
int	k, l
real	var		# The total noise variance
int	in_iter[NCTRL1]	# Counter of inner iterations for fixed alpha & beta	
bool	speedup		# Increase a_sp?
bool	a_isnew		# Has alpha been renewed?
bool	b_isnew		# Has beta been renewed?
real	old_a_sp	# a_sp before increase
real	d_alpha		# Increment of alpha in its renewing
real	d_beta		# Increment of beta in its renewing
real	alpha_tmp	# Temporary copy of alpha
real	beta_tmp	# Temporary copy of beta
real	b_sp_tmp	# Temporary copy of b_sp

real	step		# Step in the N-R direction in optimal one-dim. search
real	d_step		# 1.0 - step

int	outer_iter	# Counter of outer iterations
int	nloop		# Counter of loops

real	norm_xchisq	# Normalized (by ndata) current chi-sq

begin

	# Initialize some parameters in common /me_com/ for iteration

	narr = n1 * n2
	ndata = 0 
	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var > EPSILONR)
	            ndata = ndata + 1
	    }

	chisq = ndata * aim
	tol1sq = tol[1] ** 2
	alpha = 0.0
	beta = 0.0

	# Initialize counters etc. 

	niter = 0
	do l = 1, NCTRL1 
	    in_iter[l] = 0	

	outer_iter = 0

	call printf ("\nIteration summary:\n")

	# Output target parameters for iteration

	call printf ("Target chi-square = %g\n")
	    call pargr (chisq)
	call printf ("Target total power = %g\n")
	    call pargr (tp)

	# Initialize current iterate

	call amovr (model, current, narr)

	# Convolve the current estimate with the PSF and ICF, and calculate 
	# gradients, vector products, statistics etc. 

	call convolution_c (psfft, current, conv, n1, n2, carray, work)
	call cal_gradE (degrade, conv, psfft, gradE, n1, n2,
            n1deg, n2deg, vc, carray, work)
	call calculate_c (degrade, model, current, conv, gradE, hess, n1, n2,
	    n1deg, n2deg, vc)

	# Iterate until convergence or the prescribed max number of iterations 
	# is reached. Maximumly the iteration may continue for extra 20 times
	# to seek an ME solution.

	while (niter <= maxiter && 
            (gJ_on_gF > tol[1] || abs(chisq - xchisq) > tol[2] * chisq ||
	    abs(tp - xtp) > tol[3] * tp) 
	    || 
	    niter > maxiter && gJ_on_gF > tol[1] && niter <= maxiter + 20) {

	    # Update alpha and/or beta, and calculate the new gradients etc.
	    # The current alpha and its renewing rate a_sp will be auto
	    # adjusted according to the convergence speed of inner iteration
	    # for fixed alpha and beta, and the magnitude of the initial 
	    # gradient of the objective function.
	
	    a_isnew = false
	    b_isnew = false

	    if (gJ_on_gF <= tol[1]) {
	        call printf("\nME solution found")
                if (abs(chisq - xchisq) > tol[2] * chisq) {
	            # Renew alpha

		    # Model is updated every m_update'th outer iteration
		    # when the current chi-sq is greater than its target
		    # by more than the tolerance value.
		    if (outer_iter == m_update && 
			(xchisq - chisq) > tol[2] * chisq) {
			call printf (". --Update model")
			call amovr (current, model, narr)
			alpha= 0.0
			outer_iter = 0
		    }
		    outer_iter = outer_iter + 1

	            call printf(". --Renew alpha")

	            # If too few (<= 2) inner iterations are needed for
		    # convergence successively NCTRL1 times, a_sp will be 
		    # increased. This adjustment is done only if a_sp was
		    # increased at least NCTRL1 outer iterations before.
		    speedup = true
		    do l = 1, NCTRL1
		        if (in_iter[l] > 2 || in_iter[l] <= 0) {
		            speedup = false
			    break
		        }
		    
		    old_a_sp = a_sp + EPSILONR * 10.0
		    if (speedup) 
			a_sp = a_sp / a_rate 

	            call new_alpha_c (a_sp, a_rate, d_alpha)
		    a_isnew = true
		}

		# Update the counter
	        if (a_sp > old_a_sp)
		    do l = 1, NCTRL1 - 1
		        in_iter[l] = -in_iter[l+1]
		else
		    do l = 1, NCTRL1 - 1
			in_iter[l] = in_iter[l+1]
                in_iter[NCTRL1] = 0

	        if (abs(tp - xtp) > tol[3] * tp) {
		    # Renew beta

	            call printf(". --Renew beta.\n")

	            call new_beta (b_sp, d_beta)
		    b_isnew = true
		} else 
	            call printf(".\n")

	        call calculate_c (degrade, model, current, conv, gradE, hess, 
	            n1, n2, n1deg, n2deg, vc)

		# If initial gJ_on_gF for new alpha and/or beta is too
		# small/large, in/decrease alpha and/or beta (dec. only)
		# until gJ_on_gF is greater/less than the prescribed values.
		# a_sp is also changed accordingly. Note the other 2 
		# conditions.

		old_a_sp = a_sp
		alpha_tmp = alpha
		beta_tmp = beta
		b_sp_tmp = b_sp

		nloop = 1
	        if (a_isnew) {
		    while (gJ_on_gF < 0.10 &&
		        (xchisq - chisq) > tol[2] * chisq && nloop <= 8) {
		        # 0.10 = 2.0 * 0.05

		        if (message == 3) {
		       	    call printf ("Initial |gradJ|/|1| = %g  ")
			        call pargr (gJ_on_gF)
			    call printf ("to be increased\n")
		        }

			a_sp = a_sp / a_rate
		        alpha = alpha_tmp + d_alpha * (a_sp - old_a_sp)
		   
	                call calculate_c (degrade, model, current, conv, gradE,
		            hess, n1, n2, n1deg, n2deg, vc)
		        nloop = nloop + 1
		    }
		}   
 
		nloop = 1
		while (gJ_on_gF > 0.51 && nloop <= 8) {
		    # 0.5 = 10.0 * 0.05

		    if (message == 3) {
			call printf ("Initial |gradJ|/|1| = %g  ")
			    call pargr (gJ_on_gF)
			call printf ("to be reduced\n")
		    }

		    if (a_isnew) {
		        alpha = alpha - d_alpha * a_sp * (1.0 - a_rate)
			a_sp = a_sp * a_rate
		    }
		    if (b_isnew) {
			beta = beta - d_beta * b_sp_tmp * (1.0 - a_rate)
			b_sp_tmp = b_sp_tmp * a_rate
		    }
	            call calculate_c (degrade, model, current, conv, gradE,
		        hess, n1, n2, n1deg, n2deg, vc)
		    nloop = nloop + 1
		}

		if (message == 3) {
		    call printf ("Initial |gradJ|/|1| = %g\n")
		        call pargr (gJ_on_gF)
		}

	    } else 
	        call printf ("\n")

	    # Increase the counters 

	    niter = niter + 1
	    in_iter[NCTRL1] = in_iter[NCTRL1] + 1

	    # If there are too many inner iterations before convergence,
	    # decrease the current alpha and a_sp for use in the future.

	    if (mod (in_iter[NCTRL1], NCTRL2) == 0) {
	        alpha = alpha - d_alpha * a_sp * (1.0 - a_rate)
	        call calculate_c (degrade, model, current, conv, gradE, hess,
	            n1, n2, n1deg, n2deg, vc)
	        a_sp = a_sp * a_rate
            }
	    # Output iteration summary

	    if (message >= 3) {
	        call printf ("*** Iteration %d  (max = %d)  ")
	            call pargi (niter)
	            call pargi (maxiter)
		call printf ("inner_iter = (")
	        do l = 1, NCTRL1 - 2 {
		    call printf ("%d  ")
	                call pargi (in_iter[l])
		}
	        call printf ("%d)  %d\n")
	            call pargi (in_iter[NCTRL1-1])
	            call pargi (in_iter[NCTRL1])
	    } else {  
	        call printf ("*** Iteration %d  (max = %d)\n")
	            call pargi (niter)
	            call pargi (maxiter)
	    }

	    # Take a full step in the direction determined by the Newton-Raphson
	    # method to get next iterate. Then calculate next degraded image
	    # and new gradient.

	    call nr_step_c (degrade, model, current, conv, gradE, hess, new,
	      n1, n2, n1deg, n2deg, vc)
	    call convolution_c (psfft, new, newconv, n1, n2, carray, work)
	    call cal_gradE (degrade, newconv, psfft, NgradE, n1, n2,
	        n1deg, n2deg, vc, carray, work)

	    # If required (opt=2,3), calculate optimal step length by one-dim.
	    # search, and then move to the optimal image by inter/extrapolation.

	    step = 1.0

	    if (opt >= 2) {
	        call opt_step_c (degrade, model, current, conv, new, newconv, 
	            NgradE, n1, n2, n1deg, n2deg, vc, opt, step)

	        d_step = 1.0 - step
	        do l = 1, n2deg
	            do k = 1, n1deg {
	                current[k,l] = CLIP(d_step * current[k,l] +
	                    step * new[k,l])
	                conv[k,l] = d_step * conv[k,l] + step * newconv[k,l]
	                gradE[k,l] = d_step * gradE[k,l] + step * NgradE[k,l]
	            }
	    } else {
	        do l = 1, n2deg
	            do k = 1, n1deg {
	                current[k,l] = new[k,l]
	                conv[k,l] = newconv[k,l] 
	                gradE[k,l] = NgradE[k,l]
	            }
	    }

	    # Calculate new vector products, statistics etc.

	    call calculate_c (degrade, model, current, conv, gradE, hess,
		n1, n2, n1deg, n2deg, vc)

	    norm_xchisq = xchisq / ndata

	    # Output iteration summary 

	    call printf ("Chi-sq = %g   (Target = %g)   (Normalized = %g)\n")
	        call pargr (xchisq)
	        call pargr (chisq)
	        call pargr (norm_xchisq)
	    call printf ("Hidden image total power = %g   (Target = %g)\n")
		call pargr (xtp)
	        call pargr (tp)
	    call printf ("Hidden image max = %g   min = %g\n")
		call pargr (immax)
	        call pargr (immin)
	    call printf ("Step = %g\n")
	        call pargr (step)

	    if (message >= 3)  
	        call printf ("|gradJ|/|1| = %g   (tol1 = %g)    test = %g\n")
	    else
	        call printf ("|gradJ|/|1| = %g   (tol1 = %g)\n")

		    call pargr (gJ_on_gF)
		    call pargr (tol[1])
		    call pargr (test)

	    if (message >= 3) {
	        # Output an additional iteration summary

	        call printf ("alpha = %g    a_sp = %g    beta = %g    ")
	            call pargr (alpha)
	            call pargr (a_sp)
	            call pargr (beta)
	        call printf ("b_sp = %g\n")
	            call pargr (b_sp)
	    }
	}
end

# Convolve an image with the PSF (FFTed already). Note that the PSF may be a
# combination of PSF and ICF, or ICF only. 

procedure convolution_c (psfft, image, conv, n1, n2, carray, work)

complex psfft[n1,n2]		# FFT of PSF
real	image[n1,n2]		# Image to be convolved
real	conv[n1,n2]		# Output image from convolution
int	n1, n2
complex	carray[n1,n2]		# Complex array for FFT	
pointer	work			# Working space for FFT	

int	narr			# Total number of points in array

begin
	# FFT image

	call ffft_b (image, carray, n1, n2, work)

	# Do convolution

	narr = n1 * n2
	call amulx (carray, psfft, carray, narr)  
	call ifft_b (carray, conv, n1, n2, work)
end

# Calculate cross correlation between PSF and residual, which is gradient of
# half chi-sq. 

procedure cal_gradE (degrade, conv, psfft, gradE, n1, n2, n1deg, n2deg, vc,
	      carray, work)

include	"irme0.com"

real	degrade[n1,n2], conv[n1,n2]	# Input and "current" degraded images
complex	psfft[n1,n2]			# FFT of PSF (with ICF)
real	gradE[n1,n2]			# Gradient of half chi-sq
int	n1, n2, n1deg, n2deg		# Array and degraded image sizes
real	vc[2]
complex	carray[n1,n2]
pointer	work

real 	var				# The total noise variance

int	narr, k, l

begin
	narr = n1 * n2
	call aclrr (gradE, narr)
	call acjgx (psfft, psfft, narr)

	# Calculate residual 

	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var <= EPSILONR)
	            var = MAX_REAL
	        
	        gradE[k,l] = (conv[k,l] - degrade[k,l]) / var
	    }
	# Cal. cross correlation of PSF and residual 

	call ffft_b (gradE, carray, n1, n2, work)

	call amulx (carray, psfft, carray, narr)
	call ifft_b (carray, gradE, n1, n2, work)    
	
	call acjgx (psfft, psfft, narr)
end

# Calculate gradients, vector products, statistics etc. about the "current"
# iterate.

procedure calculate_c (degrade, model, current, conv, gradE, hess,
	      n1, n2, n1deg, n2deg, vc)

include	"irme0.com"

real	degrade[n1,n2], model[n1,n2], current[n1,n2], conv[n1,n2]
real	gradE[n1,n2]		# Gradient of half chi-sq
real	hess[n1,n2]		# Diagonal elements of Hessian of half chi-sq 
int	n1, n2, n1deg, n2deg	# Array and degraded image sizes
real	vc[2]

real	var			# Noise variance = vc[1] + vc[2]*abs(deg) 
real 	grad[4], diagonal	                 
real	factor1

int	k, l, m, n

begin
	# Initialize

	xtp = 0.0			# Current tp
	xchisq = 0.0			# Current chi-sq
	immax = current[1,1]
	immin = immax
	do n = 1, 4
	    do m = n, 4
	        graddotgrad[m,n] = 0.0

	factor1 = alpha * damping 

	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var <= EPSILONR)
	            var = MAX_REAL

	        grad[E] = 2.0 * gradE[k,l]
	        grad[F] = 1.0
	        grad[H] = DH2(current[k,l],model[k,l])
	        grad[J] = grad[H] - alpha * gradE[k,l] - beta * grad[F]

	        diagonal = current[k,l] / 
	            (1.0 + factor1 * hess[k,l] * current[k,l]) 
	        xtp = xtp + current[k,l]
	        xchisq = xchisq + (conv[k,l] - degrade[k,l]) ** 2 / var
	        immin = min (immin, current[k,l])
	        immax = max (immax, current[k,l])
	
	        # Calculate vector products

		do n = 1, 4
	    	    do m = n, 4
	                graddotgrad[m,n] = graddotgrad[m,n] + 
	                    grad[m] * diagonal * grad[n]
	    }

	# Calculate |gradJ|/|gradF|

	gJ_on_gF = sqrt (graddotgrad[J,J] / graddotgrad[F,F])
	
	# Calculate the parallelism between (gradH - beta * gradF) and 
	# alpha * gradE, 1.0 - cos <(...), (...)>.

	if (graddotgrad[H,H] <= EPSILONR)
	    test = 0.0 
	else {
	    test = 1.0 -
	        alpha * (graddotgrad[H,E] - beta * graddotgrad[F,E]) / 
	        sqrt (max (EPSILONR, 
		(graddotgrad[H,H] + beta ** 2 * graddotgrad[F,F] - 
	        2.0 * beta * graddotgrad[H,F]) * alpha ** 2 * graddotgrad[E,E]))
	}
end

# Calculate a new value of alpha. Parameter a_sp is used to control the
# renew rate of alpha.

procedure new_alpha_c (a_sp, a_rate, d_alpha)

include	"irme0.com"

real	a_sp, a_rate		# Speed factor and its reduction rate 
real	d_alpha			# Increment of alpha

real 	delta, ubound, lbound

begin
	if (xchisq > chisq) {
	    # Calculate a new d_alpha, and use the old a_sp.

	    delta = graddotgrad[J,E] ** 2 - graddotgrad[E,E] *
	        (graddotgrad[J,J] - tol1sq * graddotgrad[F,F])

	    if (delta > 0.0) {
	        delta = sqrt (delta)
	        ubound = (graddotgrad[J,E] + delta) / graddotgrad[E,E]
	        lbound = (graddotgrad[J,E] - delta) / graddotgrad[E,E]

	        d_alpha = (xchisq - chisq) / graddotgrad[E,E]
	        d_alpha = min (d_alpha, ubound)
	        d_alpha = max (d_alpha, lbound)
	        d_alpha = 2.0 * d_alpha
	        alpha = alpha + a_sp * d_alpha
	    }
	} else {
	    # Use the old d_alpha, and reduce a_sp.

    	    alpha = alpha - a_sp * d_alpha * (1.0 - a_rate)
	    a_sp = a_sp * a_rate
	}
end

# Calculate a new value of beta. Parameter b_sp is used to control the
# renew rate of beta.

procedure new_beta (b_sp, d_beta)

include	"irme0.com"

real	b_sp, d_beta		# Speed factor and increment of beta

real 	delta, ubound, lbound

begin
	# Calculate a new beta

	delta = graddotgrad[J,F] ** 2 - graddotgrad[F,F] *
	    (graddotgrad[J,J] - tol1sq * graddotgrad[F,F])

	if (delta > 0.0) {
	    delta = sqrt (delta)
	    ubound = (graddotgrad[J,F] + delta) / graddotgrad[F,F]
	    lbound = (graddotgrad[J,F] - delta) / graddotgrad[F,F]

	    d_beta = (xtp - tp) / graddotgrad[F,F]
	    d_beta = min (d_beta, ubound)
	    d_beta= max (d_beta, lbound)
	    beta = beta + b_sp * d_beta
	}
end

# Take a full step in the direction determined by the approximate 
# Newton-Raphson method.

procedure nr_step_c (degrade, model, current, conv, gradE, hess, new,
	      n1, n2, n1deg, n2deg, vc)

include	"irme0.com"

real 	degrade[n1,n2], model[n1,n2], current[n1,n2], conv[n1,n2], new[n1,n2]
real	gradE[n1,n2]		# Gradient of half chi-sq 
real	hess[n1,n2]		# Diagonal elements of Hessian of half chi-sq 
int	n1, n2, n1deg, n2deg	# Array and degraded image sizes
real	vc[2]

int	k, l
real 	diagonal, gradJ, var, factor1

begin
	factor1 = alpha * damping 

	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var <= EPSILONR)
	            var = MAX_REAL

	        gradJ = DH2(current[k,l],model[k,l]) - alpha * gradE[k,l] - beta
	        diagonal = current[k,l] / 
	            (1.0 + factor1 * hess[k,l] * current[k,l])
	        new[k,l] = CLIP(current[k,l] + diagonal * gradJ)
	    }
end

# Do one-dim. search for zero gradJ along the direction determined 
# by the N-R method. opt=1: no; 2: quadratic; 3: quadratic/cubic.

procedure opt_step_c (degrade, model, current, conv, new, newconv, gradE,
	      n1, n2, n1deg, n2deg, vc, opt, step)

include	"irme0.com"

define	STEP_MAX	4.0

real	degrade[n1,n2], model[n1,n2], current[n1,n2], conv[n1,n2]
real	new[n1,n2], newconv[n1,n2]
real	gradE[n1,n2]		# New gradient of half chi-sq
int	n1, n2, n1deg, n2deg	# Array and degraded image sizes
real	vc[2]
int	opt
real	step			# Optimal step, limited to be <= step_max

int	k, l
real 	gradJ, gradJdotd_b, var, h_alpha
real	J0, J1, z, w

begin
	h_alpha = 0.5 * alpha
	gradJdotd_b = 0.0
	J0 = -h_alpha * xchisq - beta * xtp
	J1 = 0.0
	do l = 1, n2deg
	    do k = 1, n1deg {
	        var = vc[1] + vc[2] * abs(degrade[k,l]) 
	        if (var <= EPSILONR)
	            var = MAX_REAL

	        gradJ = DH2(new[k,l],model[k,l]) - alpha * gradE[k,l] - beta
	        gradJdotd_b = gradJdotd_b +  gradJ * (new[k,l] - current[k,l])

	        J0 = J0 + H2(current[k,l],model[k,l])
	        J1 = J1 + H2(new[k,l],model[k,l]) - 
	            h_alpha * (newconv[k,l] - degrade[k,l]) ** 2 / var -
		    beta * new[k,l]
	    }

	if (gradJdotd_b >= -EPSILONR || opt == 2) { 
	    # Search for ME point by quadratic extrapolation 
	    step = min (graddotgrad[J,J] / (graddotgrad[J,J] - gradJdotd_b), 
	        STEP_MAX)
	} else {
	    # Search for ME point by cubic interpolation 
	    z = 3.0 * (J1 - J0) - graddotgrad[J,J] - gradJdotd_b
	    w = sqrt (z * z - graddotgrad[J,J] * gradJdotd_b)
	    step = graddotgrad[J,J] / (graddotgrad[J,J] - z + w)  
	}
end

# This is to write header cards of the restored image, recording a few
# iteration parameters and variables, some of which are from common /me_com/.

procedure me_header_c (restore, noise, adu, sigma, fwhm, hidden,
	      me_image, converge, niter)

include	"irme0.com"

pointer restore		# Pointer of output restored image descriptor 
real	noise		# Readout noise in electrons
real	adu		# A/D conversion constant, electrons/DN
real	sigma[2]	# Sigmas of Gaussian fn (ICF)
real	fwhm[2]		# Full widths at half max of Gaussian fn (ICF)
bool	hidden		# Is the output image a hidden (or visible) image?
bool	me_image	# Is the output image an ME image?
bool	converge	# Is the output image a converged one?
int	niter		# The total number of iterations

begin
	call imastr (restore, "  ", "  irme0 records:  ")
	call imaddr (restore, "ME_NOISE", noise) 
	call imaddr (restore, "ME_ADU", adu) 
	call imaddr (restore, "ME_TP", tp)           	# Total power of image 
	call imaddr (restore, "ME_SIGM1", sigma[1]) 
	call imaddr (restore, "ME_SIGM2", sigma[2]) 
	call imaddr (restore, "ME_FWHM1", fwhm[1]) 
	call imaddr (restore, "ME_FWHM2", fwhm[2]) 

	call imaddb (restore, "ME_HIDDN", hidden) 
	call imaddb (restore, "ME_MEIMG", me_image) 
	call imaddb (restore, "ME_CONVG", converge) 
	call imaddi (restore, "ME_NITER", niter) 

	call imaddr (restore, "ME_MAX", immax)		# Max of hidden image 
	call imaddr (restore, "ME_MIN", immin) 		# Min of hidden image
end
