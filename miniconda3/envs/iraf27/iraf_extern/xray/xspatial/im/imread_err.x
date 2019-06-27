#$Header: /home/pros/xray/xspatial/im/RCS/imread_err.x,v 11.0 1997/11/06 16:33:20 prosb Exp $
#$Log: imread_err.x,v $
#Revision 11.0  1997/11/06 16:33:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:03  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:05  pros
#General Release 1.0
#
#
# Module:	IMREAD_ERR.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	read an error array from an open real format image file
# External:	read_err_real(), asqr(), imsqrxr(), imsqrxrs()
# Local:
# Description:	Read an image file line by line as real data, perform optional
#		blocking and squaring as appropriate for an error array, and
#		place in real buffer or complex buffer (imaginary part = 0)
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1988 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	5 March 1989		initial version
#		{1} Michael VanHilst	5 April 1989		non-sqrt option
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include	<imhdr.h>

#
# Function:	read_err_real
# Purpose:	read error array data into a 2 dimensional array
# Parameters:	See argument declarations
# Uses:		im_gnlr(), lace_cmplx(), asqr()
# Pre-state:	im opened on file, outbuf allocated for data
# Post-state:	Data in outbuf, imaginary parts are set to zero if complex
# Exceptions:	Outwidth must be >= axlen[1]/block, block must be >0
# Method:	Blocking for errors sums squares of errors, then takes sqrt.
# Notes:	Axlen and outwidth are in array elements, don't adjust
#		for SZ_COMPLEX
# Notes:	Code for output buffer type (cmplx): 0-real, 1-complex
# Notes: 	Blocking factor for summing (e.g. 2: 2x2in = 1out, summed)
#
procedure read_err_real ( im, outbuf, v, axlen, outwidth, block, cmplx,
			  sqrin, sqrout )

pointer	im			# i: image file handle
real	outbuf[ARB]		# i: buffer to recieve data
long	v[IM_MAXDIM]		# i: starting index in each dimension
int	axlen[IM_MAXDIM]	# i: dimensions of image for reading
int	outwidth		# i: length of output buffer row
int	block			# i: blocking factor
int	cmplx			# i: code for outbuf type
int	sqrin			# i: code that input file contains sqaures
int	sqrout			# i: code to put squares of input in output

real	errval		# l: temp to hold value from error array
pointer	inbuf		# l: stack pointer of line read by imgnlr()
int	iwidth		# l: number of columns to be read
int	iheight		# l: number of rows to be read
int	rowsum, colsum	# l: blocking counters
int	outrow		# l: array index of start of output row
int	outcol		# l: array index of element in output column
int	owidth		# l: outwidth, possibly adjusted for complex
int	ocnt		# l: number of vals actually placed in output row
int	i, j		# l: loop counters
int	outstep		# l: index between real parts of adjacent pixels
int	imgnlr()	# IRAF image_get_next_line_as_real function

begin
	iwidth = axlen[1]
	iheight = axlen[2]
	# set up output indexing parameters, adjusted for complex types
	outstep = 1
	if( cmplx > 0 )
	{
	    # complex types take twice the space, imaginaries set to 0.0
	    owidth = outwidth * 2
	    # alternate type 1 by pixel r,i,r,i, type 2 by line r..,i..
	    if( cmplx != 2 )
		outstep = 2
	}
	else
	{
	    owidth = outwidth
	}

	if( block > 1 )
	{
	    # compute elements to place in output and ...
	    # ... set iwidth to a multiple of block
	    ocnt = iwidth / block
	    iwidth = ocnt * block
	    # initialize vertical blocking counter and output row pointer
	    rowsum = 1
	    outrow = 1
	    # scan row by row from input file image
	    do i = 1, iheight
	    {
		# initialize output row to zero
		if( rowsum == 1 )
		    call amovkr (0.0, outbuf[outrow], owidth)
		# read in next row of data
		if( imgnlr (im, inbuf, v) == EOF )
		    call error (1, "unexpected EOF")
		outcol = outrow
		colsum = 1
		# bin data into the smaller output array
		if( sqrin == 0 )
		# if the error file contains the errors (not their squares)
		{
		    do j = 1, iwidth
		    {
			errval = Memr[inbuf + j]
			outbuf[outcol] = outbuf[outcol] + (errval * errval)
			colsum = colsum + 1
			if( colsum > block )
			{
			    outcol = outcol + outstep
			    colsum = 1
			}
		    }
		}
		else
		# if the error file contains squares of the errors
		{
		    do j = 1, iwidth
		    {
			outbuf[outcol] = outbuf[outcol] + Memr[inbuf + j]
			colsum = colsum + 1
			if( colsum > block )
			{
			    outcol = outcol + outstep
			    colsum = 1
			}
		    }
		}
		# count rows for vertical summing
		rowsum = rowsum + 1
		# if just completed last row in vertical blocking
		if( rowsum > block )
		{
		    if( sqrout == 0 )
		    {
			# take sqrt of output if not to have squares
			call imsqrt (outbuf[outrow], ocnt, outstep)
		    }
		    outrow = outrow + owidth
		    rowsum = 1
		}
	    }
	}
	else
	{
	    # read each row directly into output
	    outrow = 1
	    do i = 1, iheight
		{
		if( imgnlr (im, inbuf, v) == EOF )
		    call error (1, "unexpected EOF")
		if( sqrin != sqrout )
		{
		    if( sqrout == 0 )
		    {
			call imsqrt (Memr[inbuf], iwidth, 1)
		    }
		    else
		    {
			call asqr (Memr[inbuf], iwidth)
		    }
	 	}
		    
		if( outstep == 2 )
		    {
		    call lace_cmplx (Memr[inbuf], outbuf[outrow], iwidth)
		    }
		else
		    {
		    if( owidth > iwidth )
			call amovkr (0.0, outbuf[outrow+iwidth], owidth-iwidth)
		    call amovr (Memr[inbuf], outbuf[outrow], iwidth)
		    }
		outrow = outrow + owidth
		}
	    }
end

#
# Function:	asqr
# Purpose:	replace values in a real array with their squares
# Parameters:	See argument declarations
# Post-state:	Data replaced by its square
#
procedure asqr ( a, width )

real	a[ARB]		# i: real array
int	width		# i: number of array elements involved

int	i		# l: array counter

begin
	do i = 1, width
	    a[i] = a[i] * a[i]
end

#
# Function:	imsqrxr
# Purpose:	replace real values in a complex image with their squares
# Parameters:	See argument declarations
# Post-state:	Real part of data replaced by its square
#
procedure imsqrxr ( a, width, simple )

real	a[ARB]		# i: real array
int	width		# i: number of complex array elements
int	simple		# i: 1 if imaginary parts known to be zero

real	b		# l: temporary value
int	i		# l: array index

begin
	if( simple == 1 )
	    {
	    do i = 1, width, 2
		{
		a[i] = a[i] * a[i]
		}
	    }
	else
	    {
	    do i = 1, width, 2
		{
		b = a[i+1]
		a[i+1] = 2 * b * a[i]
		a[i] = (a[i] * a[i]) - (b * b)
		}
	    }
end

#
# Function:	imsqrxrs
# Purpose:	scale values in a complex image and replace with their squares
# Parameters:	See argument declarations
# Post-state:	Real part of data replaced by its square
#
procedure imsqrxrs ( a, scale, width, simple )

real	a[ARB]		# i: real array
real	scale		# i: value be which to scale before squaring
int	width		# i: number of complex array elements
int	simple		# i: 1 if imaginary parts known to be zero

real	b		# l: temporary value
real	scsq		# l: square of scale factor
int	i		# l: array index

begin
	if( simple == 1 )
	    {
	    scsq = scale * scale
	    do i = 1, width, 2
		{
		a[i] = a[i] * a[i] * scsq
		}
	    }
	else
	    {
	    do i = 1, width, 2
		{
		b = a[i+1] * scale
		a[i] = a[i] * scale
		a[i+1] = 2 * b * a[i]
		a[i] = (a[i] * a[i]) - (b * b)
		}
	    }
end

#
# Function:	imsqrt
# Purpose:	replace real values with their square-roots
# Parameters:	See argument declarations
# Post-state:	Real data is replaced by its square
#
procedure imsqrt ( a, count, step )

real	a[ARB]		# i: real array
int	count		# i: number of array elements to sqrt
int	step		# i: number of elements to advance after each operation

int	i		# l: array index or loop count
int	j		# l: array index

begin
	if( step == 0 )
	{
	    do i = 1, count
	    {
		a[i] = sqrt(a[i])
	    }
	}
	else
	{
	    j = 1
	    do i = 1, count
	    {
		a[j] = sqrt(a[j])
		j = j + step
	    }
	}
end
