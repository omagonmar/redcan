#$Header: /home/pros/xray/xspatial/im/RCS/imwrite_r.x,v 11.0 1997/11/06 16:33:22 prosb Exp $
#$Log: imwrite_r.x,v $
#Revision 11.0  1997/11/06 16:33:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:56  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:15  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:22:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:06  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:22  pros
#General Release 1.0
#
#
# Module:       IMWRITE_R.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      write image to open image file from a real or complex array
# External:     put_im_real(), put_s_im_real(), myacabs()
# Local:        
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M.VanHilst  initial version 	28 November 1988
#               {n} <who> -- <does what> -- <when>
#

include <imhdr.h>


#############################################################################
#
# put_im_real
#
# put real data from a 2 dimensional array into a type real image file
# width (in pixels) of buffer and image file need not be the same
#
# Input: image file name
# Input: 2D buffer containing image data (real or complex)
# Input: array of buffer axes lengths for each dimension
# Input: array of output file axes lengths for each dimension
# Input: code for input buffer type: 0-real, 1-complex (writes only real part)
#
#############################################################################

procedure put_im_real ( im, imbuf, iaxlen, oaxlen, cmplx )

pointer im			# i: image file handle
real	imbuf[ARB]		# i: buffer containing image data
int	iaxlen[IM_MAXDIM]	# i: dimensions of image buffer
int	oaxlen[IM_MAXDIM]	# i: dimensions of image file
int	cmplx			# i: code for imbuf type

int	lineptr		# l: index in data buffer of line being written
int	i		# l: loop counter for line number
int	iwidth		# l: length in reals of a line in imbuf
long	v[IM_MAXDIM]	# l: starting index in each dimension
pointer out		# l: stack pointer of line given by impnlr()

pointer	impnlr()

begin
	# fill in the dimensions and type of the image
	IM_NDIM(im) = 2
	IM_LEN(im, 1) = oaxlen[1]
	IM_LEN(im, 2) = oaxlen[2]
	# fill in the type with default
	IM_PIXTYPE(im) = TY_REAL
	# set up writing (width and first index on line)
	if( cmplx == 1 ) {
	    iwidth = iaxlen[1] * 2
	} else {
	    iwidth = iaxlen[1]
	}
	# if output is bigger than input, don't over-run input
	if( oaxlen[1] > iaxlen[1] )
	    oaxlen[1] = iaxlen[1]
	if( oaxlen[2] > iaxlen[2] )
	    oaxlen[2] = iaxlen[2]
	call amovkl (long(1), v, IM_MAXDIM)
	lineptr = 1
	# write the data to the file
	do i = 1, oaxlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    if( cmplx == 1 ) {
		# move modulus of complex array
#		call myacabs (imbuf[lineptr], Memr[out], oaxlen[1])
		call myareal (imbuf[lineptr], Memr[out], oaxlen[1])
	    } else {
		call amovr (imbuf[lineptr], Memr[out], oaxlen[1])
	    }
	    lineptr = lineptr + iwidth
	}
end


#############################################################################
#
# put_s_im_real
#
# put scaled real data from a 2 dimensional array into a type real image file
# width (in pixels) of buffer and image file will be the same
#
# Input: image file name
# Input: 2D buffer containing image data (real or complex)
# Input: array of axes lengths for each dimension
# Input: scale factor to apply to data before writing
# Input: code for input buffer type: 0-real, 1-complex (writes only real part)
#
#############################################################################

procedure put_s_im_real ( im, imbuf, iaxlen, oaxlen, scale, cmplx )

pointer im			# i: image file handle
real	imbuf[ARB]		# i: buffer containing image data
int	iaxlen[IM_MAXDIM]	# i: dimensions of image buffer
int	oaxlen[IM_MAXDIM]	# i: dimensions of image file
real	scale			# i: value by which to scale data
int	cmplx			# i: code for imbuf type

int	lineptr		# l: index in data buffer of line being written
int	i		# l: loop counter for line number
int	iwidth		# l: length in reals of a line in imbuf
long	v[IM_MAXDIM]	# l: starting index in each dimension
pointer out		# l: stack pointer of line given by impnlr()

pointer	impnlr()

begin
	# fill in the dimensions and type of the image
	IM_NDIM(im) = 2
	IM_LEN(im, 1) = oaxlen[1]
	IM_LEN(im, 2) = oaxlen[2]
	# fill in the type with default
	IM_PIXTYPE(im) = TY_REAL
	# set up writing (width and first index on line)
	if( cmplx == 1 )
	    iwidth = iaxlen[1] * 2
	else
	    iwidth = iaxlen[1]
	# if output is bigger than input, don't over-run input
	if( oaxlen[1] > iaxlen[1] )
	    oaxlen[1] = iaxlen[1]
	if( oaxlen[2] > iaxlen[2] )
	    oaxlen[2] = iaxlen[2]
	call amovkl (long(1), v, IM_MAXDIM)
	lineptr = 1
	# write the data to the file
	do i = 1, oaxlen[2] {
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) ) {
		call error (1, "premature end of file on write\n")
	    }
	    if( cmplx == 1 ) {
		# move modulus of complex array
#		call myacabs (imbuf[lineptr], Memr[out], oaxlen[1])
		call myareal (imbuf[lineptr], Memr[out], oaxlen[1])
	    } else {
		call amovr (imbuf[lineptr], Memr[out], oaxlen[1])
	    }
	    # multiply values in the line by scale
	    call amulkr (Memr[out], scale, Memr[out], oaxlen[1])
	    lineptr = lineptr + iwidth
	}
end

#procedure myacabs ( in, out, cnt )
#
#complex	in[ARB]		# i: array containing complex values
#real	out[ARB]	# i: array to recieve moduli of complex array
#int	cnt		# i: length of array
#int	i		# l: loop counter
#begin
#	do i = 1, cnt {
#	    out[i] = cabs(in[i])
#	}
#end

procedure myareal ( in, out, cnt )

complex	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve moduli of complex array
int	cnt		# i: length of array
int	i		# l: loop counter
begin
	do i = 1, cnt {
	    out[i] = real(in[i])
	}
end
