#$Header: /home/pros/xray/xspatial/imfft/RCS/imwrite_x.x,v 11.0 1997/11/06 16:33:13 prosb Exp $
#$Log: imwrite_x.x,v $
#Revision 11.0  1997/11/06 16:33:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:07  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:02  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:44:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:07  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:26  pros
#General Release 1.0
#
#
# Module:       IMWRITE_X.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      write into open image file real or complex data arrays
# External:     put_im_complex(), put_complex(), put_real(), put_imag(),
#		put_modulus(), put_phase()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

include <imhdr.h>

procedure write_access ( imname )
char	imname[SZ_FNAME]

pointer	im
pointer	immap()
errchk	immap()

begin
	# open the output image file
	iferr( im = immap(imname, READ_ONLY, 0) )
	{
	    iferr(  )
		call error(1, "Can't write to output image file")
	    call imunmap(im)
	    call imdelete(imname)
	}
	else
	    call imunmap(im)
end

#############################################################################
#
# put_im_complex
#
# put real data from a 2 dimensional array into a type real image file
# width (in pixels) of buffer and image file will be the same
#
# Input: image file name
# Input: 2D buffer containing image data (real or complex)
# Input: array of axes lengths for each dimension
# Input: code for output form:
#   0-complex, 1-modulus only, 2-phase only, 3-real only, 4-imaginary only
#   5-modulus then phase, 6-real then imaginary
#
#############################################################################

procedure put_im_complex ( imname, imbuf, axlen, form )

char	imname[SZ_FNAME]	# i: name of output image file
complex	imbuf[ARB]		# i: buffer containing image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
int	form			# i: form of output

long	v[IM_MAXDIM]	# l: starting index in each dimension
pointer im		# l: image file handle

pointer	immap()
errchk	immap()

begin
	# open the output image file
	iferr( im = immap(imname, NEW_IMAGE, 0) ) {
	    call error(1, "can't open output image file")
	}
	# set up writing (width and first index on line)
	call amovkl (long(1), v, IM_MAXDIM)
	switch( form ) {
	case 0:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 2
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_PIXTYPE(im) = TY_COMPLEX
	    call put_complex (im, imbuf, axlen, v)
	case 1:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 2
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_PIXTYPE(im) = TY_REAL
	    call put_modulus (im, imbuf, axlen, v)
	case 2:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 2
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_PIXTYPE(im) = TY_REAL
	    call put_phase (im, imbuf, axlen, v)
	case 3:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 2
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_PIXTYPE(im) = TY_REAL
	    call put_real (im, imbuf, axlen, v)
	case 4:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 2
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_PIXTYPE(im) = TY_REAL
	    call put_imag (im, imbuf, axlen, v)
	case 5:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 3
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_LEN(im, 3) = 2
	    IM_PIXTYPE(im) = TY_REAL
	    call put_modulus (im, imbuf, axlen, v)
	    call put_phase (im, imbuf, axlen, v)
	case 6:
	    # fill in the dimensions and type of the image
	    IM_NDIM(im) = 3
	    IM_LEN(im, 1) = axlen[1]
	    IM_LEN(im, 2) = axlen[2]
	    IM_LEN(im, 3) = 2
	    IM_PIXTYPE(im) = TY_REAL
	    call put_real (im, imbuf, axlen, v)
	    call put_imag (im, imbuf, axlen, v)
	default:
	    # selection error, close and delete file
	    call printf ("unknown choice of output type\n")
	    call imunmap (im)
	    iferr( call imdelete (imname) ) ;
	    return
	}
	# close the file
	call imunmap (im)
end


#################################################################
#
# put_complex
#
# write complex data unaltered to an open file
#
# Input: image handle open to an IRAF image file
# Input: 2D buffer containing complex imaghe data
# Input: array with the lengths of each axis
# Input: array with the starting index (in the im file) for each axis
#
#################################################################

procedure put_complex ( im, imbuf, axlen, v )

pointer	im			# i: handle of open image file
complex	imbuf[ARB]		# i: buffer containing complex image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
long	v[IM_MAXDIM]		# i: starting index in each dimension

int	i		# l: loop counter for line number
int	lineptr		# l: index in data buffer of line being written
pointer out		# l: stack pointer of line given by impnlr()
pointer	impnlx()

begin
	lineptr = 1
	do i = 1, axlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlx (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    call amovx (imbuf[lineptr], Memr[out], axlen[1])
	    lineptr = lineptr + axlen[1]
	}
end

#################################################################
#
# put_real
#
# write the real component of complex data to an open file
#
# Input: image handle open to an IRAF image file
# Input: 2D buffer containing complex imaghe data
# Input: array with the lengths of each axis
# Input: array with the starting index (in the im file) for each axis
#
#################################################################

procedure put_real ( im, imbuf, axlen, v )

pointer	im			# i: handle of open image file
complex	imbuf[ARB]		# i: buffer containing complex image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
long	v[IM_MAXDIM]		# i: starting index in each dimension

int	i		# l: loop counter for line number
int	lineptr		# l: index in data buffer of line being written
pointer out		# l: stack pointer of line given by impnlr()
pointer	impnlr()

begin
	lineptr = 1
	do i = 1, axlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    call areal (imbuf[lineptr], Memr[out], axlen[1])
	    lineptr = lineptr + axlen[1]
	}
end


#################################################################
#
# put_imag
#
# write the imaginary component of complex data to an open file
#
# Input: image handle open to an IRAF image file
# Input: 2D buffer containing complex imaghe data
# Input: array with the lengths of each axis
# Input: array with the starting index (in the im file) for each axis
#
#################################################################

procedure put_imag ( im, imbuf, axlen, v )
pointer	im			# i: handle of open image file
complex	imbuf[ARB]		# i: buffer containing complex image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
long	v[IM_MAXDIM]		# i: starting index in each dimension

int	i		# l: loop counter for line number
int	lineptr		# l: index in data buffer of line being written
pointer out		# l: stack pointer of line given by impnlr()
pointer	impnlr()

begin
	lineptr = 1
	do i = 1, axlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    call aaimag (imbuf[lineptr], Memr[out], axlen[1])
	    lineptr = lineptr + axlen[1]
	}
end

#################################################################
#
# put_modulus
#
# write the modulus (sqrt(r**2+i**2)) of complex data to an open file
#
# Input: image handle open to an IRAF image file
# Input: 2D buffer containing complex imaghe data
# Input: array with the lengths of each axis
# Input: array with the starting index (in the im file) for each axis
#
#################################################################

procedure put_modulus ( im, imbuf, axlen, v )

pointer	im			# i: handle of open image file
complex	imbuf[ARB]		# i: buffer containing complex image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
long	v[IM_MAXDIM]		# i: starting index in each dimension

int	i		# l: loop counter for line number
int	lineptr		# l: index in data buffer of line being written
pointer out		# l: stack pointer of line given by impnlr()
pointer	impnlr()

begin
	lineptr = 1
	do i = 1, axlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    call acabs (imbuf[lineptr], Memr[out], axlen[1])
	    lineptr = lineptr + axlen[1]
	}
end

#################################################################
#
# put_phase
#
# write the phase (atan(i/r)) of complex data to an open file
#
# Input: image handle open to an IRAF image file
# Input: 2D buffer containing complex imaghe data
# Input: array with the lengths of each axis
# Input: array with the starting index (in the im file) for each axis
#
#################################################################

procedure put_phase ( im, imbuf, axlen, v )

pointer	im			# i: handle of open image file
complex	imbuf[ARB]		# i: buffer containing complex image data
int	axlen[IM_MAXDIM]	# i: dimensions of image buffer
long	v[IM_MAXDIM]		# i: starting index in each dimension

int	i		# l: loop counter for line number
int	lineptr		# l: index in data buffer of line being written
pointer out		# l: stack pointer of line given by impnlr()
pointer	impnlr()

begin
	lineptr = 1
	do i = 1, axlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    call aatan (imbuf[lineptr], Memr[out], axlen[1])
	    lineptr = lineptr + axlen[1]
	}
end
