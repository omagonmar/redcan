#$Header: /home/pros/xray/xspatial/immodel/RCS/imsmooth.x,v 11.0 1997/11/06 16:30:21 prosb Exp $
#$Log: imsmooth.x,v $
#Revision 11.0  1997/11/06 16:30:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:42  prosb
#General Release 2.3
#
#Revision 6.4  93/11/30  18:12:44  prosb
#MC	11/30/93		Add CLR command to data buffer holding input
#				error array to avoid INVALID values in
#				the PADDED portion of the array
#
#Revision 6.3  93/11/30  00:46:33  dennis
#Removed option to estimate errors from data.
#
#Revision 6.2  93/11/23  09:04:32  mo
#MC	11/23/93		Add auto-flush code (as per enhancement
#				request)
#
#Revision 6.1  93/06/28  14:33:22  prosb
#jso - separated the if debug's from the clgetb's because the DECStation
#      compiler with call the function to test both booleans.  this is not
#      the behavior we want.
#
#Revision 6.0  93/05/24  16:11:58  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:31  prosb
#General Release 2.1
#
#Revision 4.4  92/10/01  11:18:39  prosb
#jso - i corrected the error error checking section, and i uncommented the
#      mwcs code so that the mwcs is updated correctly.
#      i had to move the imunmap(inim) for mwcs.
#
#Revision 4.3  92/09/30  13:45:16  mo
#MC	9/20/92		Remove 'bad' check for zeros in error file, since
#			it really detects zeros in data file and terminates
#
#Revision 4.2  92/09/08  12:24:58  mo
#MC	9/8/92		Try harder with checking if the output file can
#			actually be written to.
#
#Revision 4.1  92/07/07  09:10:55  mo
#MC	7/2/92		Upgrade all filename lengths to SZ_PATHNAME
#
#Revision 4.0  92/04/27  17:30:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:04  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  22:07:52  mo
#MC	8/1/91		Disable the MWCS code - still IRAF bugs
#
#Revision 2.0  91/03/06  23:16:15  pros
#General Release 1.0
#
#
# Module:	IMSMOOTH.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	smooth an image by convolving it with a smoothing function
# External:	t_smooth
# Local:
# Description:	Convolution is done in k-space after fft'ing the image.  The
#		result is inverse-fft'd back and written out.  The smoothing
#		function can be described in xy space or in kspace.  A set
#		of standard functions can be selected with parameters, or the
#		function can be read from an IRAF file.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	1 December 1988	initial version
#		{1} MVH	10 March 1989	added error array handling
#		{2} MVH 5 April 1989	array files to have square of error
#		{3} DMM-19 November 1990 commented out line so qpoe files load
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include	<fset.h>
include	<imhdr.h>
include <error.h>

include <ext.h>

#
# Function:	t_smooth
# Purpose:	smooth an image by convolution using fft's
# Parameters:	See argument declarations
# Returns:	
# Uses:		
# Pre-state:	image data in an IRAF format image
# Post-state:	smoothed version of image in an IRAF format image
# Exceptions:
# Method:	< optional >
# Notes:	A debug option allows writing out intermediate states of the
#		image and smoothing function, and stopping at any time.
#
procedure t_smooth ( )

real	xcen, ycen		# l: coordinates of data center
real	unmul			# l: factor needed after inverse FFT
real	normmul			# l: factor used to normalize model
real	xoff, yoff		# l: debug adjustments of coordinates
real	frac			# l: fractional part of xoff or yoff
int	owidth, oheight		# l: dimensions of data buffer
int	obufsz			# l: size of data buffer
int	block			# i: input blocking factor
int	padding			# i: number of zeroes for padding
int	v[IM_MAXDIM]		# l: im read starting indeces
int	inaxlen[IM_MAXDIM]	# l: im dimensions for input
int	axlen[IM_MAXDIM]	# l: im dimensions for fft
int	outaxlen[IM_MAXDIM]	# l: im dimensions for output
int	blkfac[IM_MAXDIM]
int	smcode			# l: code of smoothing function
int	ixoff, iyoff		# l: integer component of center adjust
int	display			# i: level of status message and debug
int 	junk			# l: return from fnextn, fd for open check
int	i
real	mags[IM_MAXDIM]
real	shifts[IM_MAXDIM]
pointer	ibuf			# l: input data buffer
pointer obuf			# l: output data buffer
pointer sbuf			# l: smoothing function buffer
pointer tbuf			# l: temp buffer to test image 'write' buffer
pointer sp			# l: stack pointer
pointer	inim			# l: input image pointer
pointer	outim			# l: ouput image pointer
pointer errim			# l: error array image file pointer
pointer smfunc			# l: structure for smoothing parameters
pointer	iminame			# i: buf for name of input image file
pointer	imoname			# i: buf for name of output image file
pointer	tempname		# l: temporary output image file name
pointer	erriname		# i: name of input image file
pointer	erroname		# i: name of output image file
pointer	mw
char	smname[SZ_PATHNAME]	# i: name of smoothing function
bool	clobber			# i: clobber old output file
bool	debug			# l: do detailed inspection of process
bool	dostat			# l: print status messages
bool	doerr			# l: compute an error array
## bool	errfile			# l: errors came from error file

int	md_parse()		# return smoothing function code
pointer	md_alloc()		# return smoothing function structure
int	md_getparams()		# get function parameters from cl
real	fft_specnorm()		# normalize and return multiplier used
int	fft_inspect()		# options to write fft result
pointer	smo_map()		# open output image with old header stuff
pointer	smerr_map()		# open output error image with old header stuff
pointer	immap()			# open an image
pointer	impl2i()		# open an image
pointer	mw_openim()
int	open()			# open a binary file
int	fnextn()		# get file name extension
real	clgetr()		# get real param from cl or .par file
int	clgeti(),fstati()	# get int param from cl or param file
bool	clgetb()		# get boolean parameter
bool	streq()			# string compare (equality)
bool	strne()			# string compare (not equal)
bool	envgetb()
bool	ck_none()

begin
        if (fstati (STDOUT, F_REDIR) != YES)
            call fseti(STDOUT, F_FLUSHNL, YES)

	call smark(sp)

  # get the filenames

	call salloc(iminame, SZ_PATHNAME, TY_CHAR)
	call salloc(imoname, SZ_PATHNAME, TY_CHAR)
	call salloc(tempname, SZ_PATHNAME, TY_CHAR)
	call clgstr("input_image", Memc[iminame], SZ_PATHNAME)
	call rootname("", Memc[iminame], "", SZ_PATHNAME)
	if( (streq(Memc[iminame], "")) || (streq(Memc[iminame], "NONE")) )
	{
	    call sfree(sp)
	    call error(0, "requires input image name")
	}
	block = clgeti("block")
	call clgstr("output_image", Memc[imoname], SZ_PATHNAME)
	call rootname(Memc[iminame], Memc[imoname], EXT_SMOOTH, SZ_PATHNAME)
	if( (streq(Memc[imoname], "")) || (streq(Memc[imoname], "NONE")) )
	{
	    call sfree(sp)
	    call error(0, "requires output image name")
	}
	junk = fnextn(Memc[imoname], Memc[tempname], SZ_PATHNAME)
	if( strne(Memc[tempname], "imh") )
	{
	    call error(1, "output image must be of type '.imh'")
	}
	clobber = clgetb("clobber")

 	# get output selection

	display = clgeti("display")
	dostat = (display > 0)
	debug = (display >= 5)

	# reset clobber to yes if debug mode is on

	if( debug ) {
	    clobber = TRUE
	}

	call clobbername(Memc[imoname], Memc[tempname], clobber, SZ_PATHNAME)
	# check for write permission
	junk = open(Memc[tempname], NEW_FILE, BINARY_FILE)
	if( junk == 0 )
	{
	    call error(1, "Write access denied for output image")
	}
	call close(junk)
	call delete(Memc[tempname])
	inim = immap(Memc[iminame], READ_ONLY, 0)
	outim = immap(Memc[tempname], NEW_COPY, inim)
	tbuf = impl2i( outim, 1)
	Memi[tbuf+1] = 1
	call imunmap(outim)
	call imdelete(Memc[tempname])

  # open the reference image and get its dimensions

#	if (!envgetb ("nomwcs")) {
#	    mw = mw_openim (inim)
#	}
	# get image's dimensions
	inaxlen[1] = IM_LEN(inim,1)
	inaxlen[2] = IM_LEN(inim,2)
	# determine output images dimensions (no partial blocking at end)
	if( (block < 1) || (block > inaxlen[1]) || (block > inaxlen[2]) )
	{
	    call sfree(sp)
	    call imunmap(inim)
	    call error(0, "block value out of range")
	}
	owidth = inaxlen[1] / block
	oheight = inaxlen[2] / block
	outaxlen[1] = owidth
	outaxlen[2] = oheight

  # report image dimensions

	if( (inaxlen[1] != owidth) || (inaxlen[2] != oheight) )
	{
	    call printf("\n	input image dimensions: %d x %d")
	     call pargi(inaxlen[1])
	     call pargi(inaxlen[2])
	}
	call printf("\n	resultant output image dimensions: %d x %d\n")
	 call pargi(owidth)
	 call pargi(oheight)

  # determine level extent of zero padding

	padding = clgeti("padding")
	if( padding > 0 )
	{
	    # padding that more than doubles size is useless
	    if( padding > owidth )
		owidth = owidth + owidth
	    else
		owidth = owidth + padding
	    if( padding > oheight )
		oheight = oheight + oheight
	    else
		oheight = oheight + padding
	}
	# increase to nearest power of two
	call fft_poweroftwo(owidth)
	call fft_poweroftwo(oheight)
	obufsz = owidth * oheight
	axlen[1] = owidth
	axlen[2] = oheight
	call printf("	internal image dimensions for fft: %d x %d\n\n")
	 call pargi(owidth)
	 call pargi(oheight)

  # is size reasonable?

	if( (owidth * oheight) > 300000 ) {
	    call printf(
	     "WARNING: image size will require much processing time,\n")
	    call printf(
	     "   and may result in memory faulting.\n")
	}

  # get the smoothing model parameters

	call clgstr("function", smname, SZ_PATHNAME)
	smcode = md_parse (smname)
	if( smcode == 0 )
	{
	    call sfree(sp)
	    call imunmap(inim)
	    call error(0, "Unknown function type")
	}
	smfunc = md_alloc(smcode)
	if( md_getparams(smfunc) != 1 )
	{
	    call sfree(sp)
	    call imunmap(inim)
	    call error(0, "Unacceptable function parameter")
	}

  # if error array is input, open it and verify its dimensions

	# get error array id
	doerr = clgetb("errors")
	if( doerr )
	{
	    call salloc(erriname, SZ_PATHNAME, TY_CHAR)
	    call salloc(erroname, SZ_PATHNAME, TY_CHAR)
	    call clgstr("errarray", Memc[erriname], SZ_PATHNAME)
	    call rootname(Memc[iminame], Memc[erriname], EXT_ERROR, SZ_PATHNAME)
	    if (!ck_none(Memc[erriname]))
	    {
		errim = immap(Memc[erriname], READ_ONLY, 0)
		# get image's dimensions
		if( (inaxlen[1] != IM_LEN(errim,1)) ||
		    (inaxlen[2] != IM_LEN(errim,2)) )
		{
		    call sfree(sp)
		    call imunmap(inim)
		    call imunmap(errim)
		    call error(0, "image and error array dimensions differ")
		}
		call imunmap(errim)
##		errfile = TRUE
	    }
	    else
	    {
##		errfile = FALSE
		call eprintf(
	"***** To compute errors, you must provide an array of squared errors.\n")
		call eprintf(
	"***** (You may use xspatial task errcreate to make the error array.)\n")
		call error(0, "Abandoning the smoothing operation")
	    }
	    call clgstr("error_out", Memc[erroname], SZ_PATHNAME)
	    call rootname(Memc[imoname], Memc[erroname], EXT_ERROR, SZ_PATHNAME)
	}

		
  # make the smoothing model data

	if( dostat )
	{
	    call printf("\n	status of imsmooth process:\n")
	    call printf("	modeling smoothing function\n")
	    call flush(STDOUT)
	}
	# calculate exact center of buffer for smoothing function
	xcen = real((owidth / 2) + 1)
	ycen = real((oheight / 2) + 1)

	ixoff = 0
	iyoff = 0
	if ( debug ) {
	    if ( clgetb("adjust_center") ) {

		# read new centers
		call printf("Calculated center is: %.2f, %.2f\n")
		 call pargr(xcen)
		 call pargr(ycen)
		xoff = clgetr("xcen") - xcen
		yoff = clgetr("ycen") - ycen
		ixoff = int(xoff)
		frac = xoff - real(ixoff)
		if( frac != 0.0 ) {
		    xcen = xcen + frac
		}
		iyoff = int(yoff)
		frac = yoff - real(iyoff)
		if( frac != 0.0 ) {
		    ycen = ycen + frac
		}
	    }
	}

	call md_place(smfunc, xcen, ycen, 1.0)
	# allocate smoothing model buffer
	call salloc(sbuf, obufsz * 2, TY_REAL)
	# put smoothing model in buffer as complex values
	call md_apply(Memr[sbuf], owidth, oheight, smfunc, 1, 1)

	# apply any requested adjustments to the model
	if( ixoff != 0 )
	    call fft_xroll(Memr[sbuf], axlen, ixoff)
	if( iyoff != 0 )
	    call fft_yroll(Memr[sbuf], axlen, iyoff)

	if ( debug ) {
	    if ( clgetb( "display_model" ) ) {

		call printf ("Components of convolving function...\n")
		call flush (STDOUT)

		if ( fft_inspect(Memc[tempname], Memc[imoname],
			    Memr[sbuf], axlen) == 1 ) {
		    call sfree(sp)
		    call imunmap(inim)
		    return
		}

	    }
	}

	# shift smoothing model origin from center to corners
	call fft_shift(Memr[sbuf], axlen)

  # fft the smoothing model data

	# smoothing functions code 100 are in k space
	if( smcode < 100 )
	{
	    if( dostat )
	    {
		call printf("	FFTing smoothing function\n")
		call flush(STDOUT)
	    }
	    call fourn(Memr[sbuf], axlen, 2, 1)
	    # normalize spectral density of smoothing function and get factor
	    normmul = fft_specnorm (Memr[sbuf], obufsz)

	    if ( debug ) {
		if ( clgetb("examine_model_fft") ) {

		    call printf ("components of fourier transform of convolving function...\n")
		    call flush (STDOUT)
		    # shift image origin from corners to center
		    call fft_shift(memr[sbuf], axlen)

		    if( fft_inspect(memc[tempname], memc[imoname],
				memr[sbuf], axlen) == 1 ) {
			call sfree(sp)
			call imunmap(inim)
			return
		    }

		    # shift image origin from center to corners
		    call fft_shift(Memr[sbuf], axlen)
		}
	    }
	}

  # read in the reference image data

	if( dostat )
	{
	    call printf ("	reading data file\n")
	    call flush (STDOUT)
	}
	# allocate and clear full image buffer
	call salloc(ibuf, obufsz * 2, TY_REAL)
	call aclrr(Memr[ibuf], obufsz * 2)
	# read in the image
	call amovki(1, v, IM_MAXDIM)
	# read in the data as complex pairs
	call read_im_real(inim, Memr[ibuf], v, inaxlen, owidth, block, 1)

	if ( debug ) {
	    if ( clgetb( "display_image" ) ) {

		call printf("Components of input image...\n")
		call flush (STDOUT)

		if( fft_inspect(Memc[tempname], Memc[imoname],
			    Memr[ibuf], axlen) == 1 ) {
		    call sfree(sp)
		    return
		}

	    }
	}

  # fft the image data

	if( dostat )
	{
	    call printf("	FFTing data\n")
	    call flush(STDOUT)
	}
	call fourn(Memr[ibuf], axlen, 2, 1)

	if ( debug ) {
	    if ( clgetb("examine_image_fft") ) {

		call printf("Components of Fourier transform of input image...\n")
		call flush (STDOUT)

		if( fft_inspect(Memc[tempname], Memc[imoname],
			    Memr[ibuf], axlen) == 1 ) {
		    call sfree(sp)
		    return
		}

	    }
	}

  # convolving the data

	if( dostat )
	{
	    call printf ("	convolving data\n")
	    call flush(STDOUT)
	}
	# result will overwrite the smoothing function (keep fft of input)
	obuf = sbuf
	call amulx(Memr[ibuf], Memr[sbuf], Memr[obuf], obufsz)

	if ( debug ) {
	    if ( clgetb("examine_convolution_fft") ) {

		call printf("Components of Fourier transform of convolved image...\n")
		call flush (STDOUT)

		if( fft_inspect(Memc[tempname], Memc[imoname],
			    Memr[obuf], axlen) == 1 ) {
		    call sfree(sp)
		    return
		}
	    }
	}
 
  # inverse fft the smoothed data

	if( dostat )
	{
	    call printf("	inverse FFTing data\n")
	    call flush(STDOUT)
	}
	call fourn (Memr[obuf], axlen, 2, -1)
	unmul = 1.0 / real(obufsz)
	if( debug )
	{
	    # remove scaling of inverse fft
	    call amulkr(Memr[obuf], unmul, Memr[obuf], obufsz * 2)
	    if( clgetb("examine_complex_result") )
	    {
		call printf("Compenents of convolved image...\n")
            	call flush (STDOUT)
	        if( fft_inspect(Memc[tempname], Memc[imoname],
				Memr[obuf], axlen) == 1 )
		{
		    call sfree(sp)
		    return
		}
	    }
	}

  # write out the results

	# write out smoothed data image
	if( dostat )
	{
	    call printf("	writing smoothed image to: %s\n")
	     call pargstr(Memc[imoname])
	    call flush(STDOUT)
	}
	outim = smo_map(Memc[iminame], Memc[tempname], Memc[imoname],
			block, smfunc)
	if( debug )
	    # if we already scaled from the inverse fft just write it
	    call put_im_real(outim, Memr[obuf], axlen, outaxlen, 1)
	else
	    # remove scaling of inverse fft
	    call put_s_im_real(outim, Memr[obuf], axlen, outaxlen, unmul, 1)
        if (!envgetb ("nomwcs")) {
		blkfac[1]=block
		blkfac[2]=block
                mw = mw_openim (inim)
# same as next two lines                call achtir (blkfac, mags, 2)
		mags[1] = real(block)
		mags[2] = real(block)
                call arcpr (1.0, mags, mags, 2)
                call mw_scale (mw, mags, 0)
                do i = 1, 2 {
                    shifts[i] = 1.0 - mags[i] * (1. + real (blkfac[i])) / 2.0
		}
                call mw_shift (mw, shifts, 0)
                call mw_saveim (mw, outim)
                call mw_close (mw)
        }
	call imunmap(outim)
	call finalname(Memc[tempname], Memc[imoname])

  # compute the errors

	if( doerr )
	{
    # set up fft of errors squared
	    if( dostat )
	    {
		call printf("\n	computing errors:\n")
		call flush(STDOUT)
	    }
 	    # get the initial errors from a file
					##[, else use existing fft of data]
##	    if( errfile )
##	    {
		if( dostat )
		{
		    call printf("	reading error array\n")
		    call flush(STDOUT)
		}
		# read in the error array
		call amovki(1, v, IM_MAXDIM)
		call aclrr(Memr[ibuf], obufsz * 2)
		# read in squares of the error data as complex pairs
		errim = immap(Memc[erriname], READ_ONLY, 0)
		call read_err_real(errim, Memr[ibuf], v,
				   inaxlen, owidth, block, 1, 1, 1)

		# Verify suitability of error array
		# making an appropriate check
		junk = (obufsz * 2) - 1
		do i = 0, junk, 2 {
		    if( Memr[ibuf + i] < 0.0 ) {
			call printf("Error array (errors squared) contains a ")
			call printf("negative value!\n")
			call error(1, "Invalid error array")
		    }
		}

	       	if (!envgetb ("nomwcs")) {
                    mw = mw_openim (errim)
		}
		call imunmap(errim)
		if( dostat )
		{
		    call printf("	FFTing error squares\n")
		    call flush(STDOUT)
		}
		call fourn(Memr[ibuf], axlen, 2, 1)
##	    }
##	    else
##	    {
##		if( dostat )
##		{
##		    call printf("	using sqrt of data for errors\n")
##		    call flush(STDOUT)
##		}
##	    }
    # get fft of squares of convolving function
	    if( dostat )
	    {
		call printf("	modeling smoothing function \n")
		call flush(STDOUT)
	    }
	    # put smoothing model in buffer as complex values
	    call md_apply (Memr[sbuf], owidth, oheight, smfunc, 1, 1)
	    # apply any requested adjustments to the model
	    if( ixoff != 0 )
		call fft_xroll(Memr[sbuf], axlen, ixoff)
	    if( iyoff != 0 )
		call fft_yroll(Memr[sbuf], axlen, iyoff)
	    # shift smoothing model origin from center to corners
	    call fft_shift (Memr[sbuf], axlen)
	    if( smcode > 100 )
	    {
		# inverse fft k-space model here
		if( dostat )
		{
		    call printf ("	inverse FFTing K smoothing function\n")
		    call flush (STDOUT)
		}
		call fourn (Memr[sbuf], axlen, 2, -1)
		# scale to normalize and remove fft factor, then square
		call imsqrxrs (Memr[sbuf], unmul * normmul, obufsz * 2, 0)
	    }
	    else
	    {
		# scale to normalize, and then square
		call imsqrxrs (Memr[sbuf], normmul, obufsz * 2, 1)
	    }

	    # transorm through fft
	    if( dostat )
	    {
		call printf("	FFTing smoothing function squares\n")
		call flush(STDOUT)
	    }
	    call fourn (Memr[sbuf], axlen, 2, 1)
    # convolve the data and inverse fft it
	    if( dostat )
	    {
		call printf("	convolving function and error squares\n")
		call flush(STDOUT)
	    }
	    call amulx(Memr[ibuf], Memr[sbuf], Memr[obuf], obufsz)
	    if( dostat )
	    {
		call printf("	inverse FFTing new errors\n")
		call flush(STDOUT)
	    }
	    call fourn (Memr[obuf], axlen, 2, -1)
    # write out new error array
	    if( dostat )
	    {
		call printf("	writing error array to: %s\n")
		 call pargstr(Memc[erroname])
		call flush(STDOUT)
	    }
	    call clobbername (Memc[erroname], Memc[tempname],
			      clobber, SZ_PATHNAME)
##	    if( errfile )
		outim = smerr_map (Memc[erriname], Memc[tempname],
				   Memc[imoname], YES, block, smfunc)
##	    else
##		outim = smerr_map (Memc[iminame], Memc[tempname],
##				   Memc[imoname], NO, block, smfunc)
	    call mfree (smfunc, TY_STRUCT)
	    # remove scaling of inverse fft and write to file
# write squares of errors rather than errors (which must be square-rooted
	    call put_s_im_real (outim, Memr[obuf], axlen, outaxlen, unmul, 1)
#	    call put_err_real (outim, Memr[obuf], axlen, outaxlen, unmul)
            if (!envgetb ("nomwcs")) {
		blkfac[1]=block
		blkfac[2]=block
                mw = mw_openim (inim)
# same as next two lines                call achtir (blkfac, mags, 2)
		mags[1] = real(block)
		mags[2] = real(block)
                call arcpr (1.0, mags, mags, 2)
                call mw_scale (mw, mags, 0)
                do i = 1, 2 {
                    shifts[i] = 1.0 - mags[i] * (1. + real (blkfac[i])) / 2.0
		}
                call mw_shift (mw, shifts, 0)
                call mw_saveim (mw, outim)
                call mw_close (mw)
            }
	    call imunmap(outim)
	    call finalname (Memc[tempname], Memc[erroname])
	}
	# end of error section
	else {
	    call mfree (smfunc, TY_STRUCT)
	}

	call imunmap(inim)
	call sfree(sp)
end
