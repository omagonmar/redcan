#$Header: /home/pros/xray/xspatial/im/RCS/imwrite_err.x,v 11.0 1997/11/06 16:33:21 prosb Exp $
#$Log: imwrite_err.x,v $
#Revision 11.0  1997/11/06 16:33:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:58  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:25  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:06  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:19  pros
#General Release 1.0
#
#
# Module:	IMWRITE_ERR.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	write an error array to an open real format image file
# External:	put_err_real()
# Local:	aerrsqrt()
# Description:	Write to an image file line by line as real data, perform
#		optional scaling and square-rooting, from a real buffer or
#		complex buffer (imaginary part = 0)
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	28 November 1988	initial version
#		{1} Michael VanHilst	5 April 1989		headers added
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include	<imhdr.h>

#
# Function:	put_err_real
# Purpose:	write square-root of error data into an open image file
# Parameters:	See argument declarations
# Uses:		impnlr(), aerrsqrt() below
# Pre-state:	im opened on file, imbuf with square of error data
# Post-state:	Data in processed and placed in im file
# Method:	Scale then take square-root of data
#		Since modulus of complex is sqrt(a**2+i**2) and a and i are
#		squares, we just take sqrt(a+i).  Scaling is applied first
#		as it is assumed to be the factor from the inverse FFT.
# Notes:	Iaxlen and oaxlen are in array elements, don't adjust
#		for SZ_COMPLEX
#
procedure put_err_real ( im, imbuf, iaxlen, oaxlen, scale )

pointer im			# i: image file handle
real	imbuf[ARB]		# i: 2D buffer containing complex image data
int	iaxlen[IM_MAXDIM]	# i: dimensions of image buffer
int	oaxlen[IM_MAXDIM]	# i: dimensions of image file
real	scale			# i: value by which to scale data

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
	iwidth = iaxlen[1] * 2
	# if output is bigger than input, don't over-run input
	if( oaxlen[1] > iaxlen[1] )
	    oaxlen[1] = iaxlen[1]
	if( oaxlen[2] > iaxlen[2] )
	    oaxlen[2] = iaxlen[2]
	call amovkl (long(1), v, IM_MAXDIM)
	lineptr = 1
	# write the data to the file
	do i = 1, oaxlen[2]
	{
	    # get pointer to line buffer in output spool for file
	    if( EOF == impnlr (im, out, v) )
		call error (0, "premature end of file on write\n")
	    # move modulus of complex array
	    call aerrsqrt (imbuf[lineptr], Memr[out], scale, oaxlen[1])
	    lineptr = lineptr + iwidth
	}
end

#
# Function:	aerrsqrt
# Purpose:	divide by a constant and take square roots of real values
#		in a complex image
# Parameters:	See argument declarations
# Post-state:	Real array gets square root of (sum of real and imaginary
#		parts, scaled)
# Notes:	Like scaled modulus of a complex number, but complex number
#		parts are already squared
#
procedure aerrsqrt ( in, out, scale, cnt )

real	in[ARB]		# i: array containing complex values
real	out[ARB]	# i: array to recieve moduli of complex array
real	scale		# i: constant by which to multiply
int	cnt		# i: length of array

real	temp		# l: intermediate operand
int	i, j		# l: loop counters
begin
	j = 1
	do i = 1, cnt
	{
	    temp = (in[j] + in[j+1]) * scale
	    if( temp >= 0 )
	    {
		out[i] = sqrt(temp)
	    }
	    else
	    {
		out[i] = -sqrt(-temp)
	    }
	    j = j + 2
	}
end
