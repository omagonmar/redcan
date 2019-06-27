#$Header: /home/pros/xray/xspatial/imfft/RCS/fftaids.x,v 11.0 1997/11/06 16:33:10 prosb Exp $
#$Log: fftaids.x,v $
#Revision 11.0  1997/11/06 16:33:10  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:35  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:05  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:43:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:27:56  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:15:42  pros
#General Release 1.0
#
#
# Module:	FFTAIDS.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to use when working with fft's
# External:	fft_inspect(), fft_poweroftow(), fft_specnorm()
# Local:        
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	5 Dec 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include <imhdr.h>


#
# Function:	fft_inspect
# Purpose:	write out fft results in one of many forms for inspection
# Parameters:	See argument declarations
# Returns:	integer 1 to quit, 0 to continue processing
# Uses:		put_im_complex(), finalname()
# Pre-cond:	imbuf has ffted data in fortran standard complex form
# Post-cond:	no change
# Exceptions:
# Method:	program loops until user chooses to quit or continue
# Notes:	< optional >
#
int procedure fft_inspect ( tempname, realname, imbuf, axlen )

char	tempname[SZ_PATHNAME]	# i: temporary output image file name
char	realname[SZ_PATHNAME]	# i: name of output image file
complex	imbuf[ARB]		# i: buffer containing image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer

int	choice			# l: user selection for what to do
int	clgeti()

begin
	repeat {
	call printf("0=continue, 1=modulus, 2=phase, 3=real, 4=imag, 5=quit\n")
	    choice = clgeti ("select")
	    switch( choice ) {
	     case 1:
		call printf ("	writing modulus to: %s")
		 call pargstr (realname)
		call put_im_complex (tempname, imbuf, axlen, 1)
		call finalname (tempname, realname)
		call printf (".\n")
	     case 2:
		call printf ("	writing phase to: %s")
		 call pargstr (realname)
		call put_im_complex (tempname, imbuf, axlen, 2)
		call finalname (tempname, realname)
		call printf (".\n")
	     case 3:
		call printf ("	writing real part to: %s")
		 call pargstr (realname)
		call put_im_complex (tempname, imbuf, axlen, 3)
		call finalname (tempname, realname)
		call printf (".\n")
	     case 4:
		call printf ("	writing imaginary part to: %s")
		 call pargstr (realname)
		call put_im_complex (tempname, imbuf, axlen, 4)
		call finalname (tempname, realname)
		call printf (".\n")
	     case 5:
		return(1)
	     case 7:
		call printf ("	writing full complex image to: %s")
		 call pargstr (realname)
		call put_im_complex (tempname, imbuf, axlen, 0)
		call finalname (tempname, realname)
		call printf (".\n")
	     default:
		;
	    }
	} until( choice == 0 )
	return(0)
end


#
# Function:	fft_poweroftwo
# Purpose:	increase an integer to next integer power of two
# Parameters:	See argument declarations
# Returns:	changes input value
# Uses:		
# Pre-cond:	an integer, presumably an array dimension
# Post-cond:	the variable with which it is called is changed
# Exceptions:
# Method:	loop on increasing powers of 2 until val met or exceeded
# Notes:	most fft routines require power of two array dimensions
#
procedure fft_poweroftwo ( val )
int val
int n
begin
	n = 1
	repeat {
	   n = n * 2
	} until (n >= val)
	val = n
end


#
# Function:	fft_specnorm
# Purpose:	normalize k data to set power at 1,1 to 1
# Parameters:	See argument declarations
# Returns:	value by which buffer was multiplied
# Uses:		
# Pre-cond:	complex data in k space (forward fft'd)
# Post-cond:	data normalized for use in convolution (power is one)
# Exceptions:
# Method:	divide all imaginary and real values by the modulus at (1,1)
# Notes:	smoothing with a normalized function preserves the total energy
#		(counts) in the image data
#
real procedure fft_specnorm ( xbuf, xbufsz )

real	xbuf[ARB]	# i: 2D image buffer of data in k space
int	xbufsz		# i: total number of pixels in image buffer

real	density		# l: spectral density from first element

begin
	density = sqrt(double((xbuf[1]*xbuf[1])+(xbuf[2]*xbuf[2])))
	if( (density == 0.0) || (density == 1.0) )
	    return (1.0)
	density = 1.0 / density
	call amulkr (xbuf, density, xbuf, xbufsz * 2)
	return (density)
end
