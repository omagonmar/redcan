#$Header: /home/pros/xray/xspatial/im/RCS/imread_r.x,v 11.0 1997/11/06 16:33:20 prosb Exp $
#$Log: imread_r.x,v $
#Revision 11.0  1997/11/06 16:33:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:55:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:55  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:23  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:17  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:04  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:16:08  pros
#General Release 1.0
#
#
# Module:	IMREAD_R.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	read an image as real or complex from an open image file
# External:	read_im_real(), lace_cmplx()
# Local:
# Description:	Read an image file line by line as real data, perform blocking
#		and place in real buffer or complex buffer with imaginary part
#		set to 0.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	28 November 1988	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include	<imhdr.h>

#
# Function:	read_im_real
# Purpose:	read real image data into a 2 dimensional array
# Parameters:	See argument declarations
# Uses:		im_gnlr(), lace_cmplx()
# Pre-state:	im opened on file, outbuf allocated for data
# Post-state:	Data in outbuf, imaginary parts are set to zero if complex
# Exceptions:	Outwidth must be >= axlen[1]/block, block must be >0
# Method:	< optional >
# Notes:	Axlen and outwidth are in array elements, don't adjust
#		for SZ_COMPLEX
# Notes:	Code for output buffer type (cmplx): 0-real, 1-complex
# Notes: 	Blocking factor for summing (e.g. 2: 2x2in = 1out, summed)
#
procedure read_im_real ( im, outbuf, v, axlen, outwidth, block, cmplx )

pointer	im			# i: image file handle
real	outbuf[ARB]		# i: buffer to recieve data
long	v[IM_MAXDIM]		# i: starting index in each dimension
int	axlen[IM_MAXDIM]	# i: dimensions of image for reading
int	outwidth		# i: length of output buffer row
int	block			# i: blocking factor
int	cmplx			# i: code for outbuf type

pointer	inbuf		# l: stack pointer of line read by imgnlr()
int	iwidth		# l: number of columns to be read
int	iheight		# l: number of rows to be read
int	rowsum, colsum	# l: blocking counters
int	outrow		# l: array index of start of output row
int	outcol		# l: array index of element in output column
int	owidth		# l: outwidth, possibly adjusted for complex
int	i, j		# l: loop counters
int	outstep		# l: index between real parts of adjacent pixels
int	imgnlr()	# IRAF image_get_next_line_as_real function

begin
	iwidth = axlen[1]
	iheight = axlen[2]
	# set up output indexing parameters, adjusted for complex types
	outstep = 1
	if( cmplx > 0 ) {
	    # complex types take twice the space, imaginaries set to 0.0
	    owidth = outwidth * 2
	    # alternate type 1 by pixel r,i,r,i, type 2 by line r..,i..
	    if( cmplx != 2 )
		outstep = 2
	} else {
	    owidth = outwidth
	}

	if( block > 1 ) {
	    # initialize vertical blocking counter and output row pointer
	    rowsum = 1
	    outrow = 1
	    # scan row by row from input file image
	    do i = 1, iheight {
		# initialize output row to zero
		if( rowsum == 1 )
		    call amovkr (0.0, outbuf[outrow], owidth)
		# read in next row of data
		if( imgnlr (im, inbuf, v) == EOF ) {
		    call error (1, "unexpected EOF")
		}
		outcol = outrow
		colsum = 1
		# bin data into the smaller output array
		do j = 1, iwidth {
		    outbuf[outcol] = outbuf[outcol] + Memr[inbuf + j]
		    colsum = colsum + 1
		    if( colsum > block ) {
			outcol = outcol + outstep
			colsum = 1
		    }
		}
		# count rows for vertical summing
		rowsum = rowsum + 1
		# if just completed last row in vertical blocking ...
		if( rowsum > block ) {
		    outrow = outrow + owidth
		    rowsum = 1
		}
	    }
	} else {
	    # read each row directly into output
	    outrow = 1
	    do i = 1, iheight {
		if( imgnlr (im, inbuf, v) == EOF ) {
		    call error (1, "unexpected EOF")
		}
		if( outstep == 2 ) {
		    call lace_cmplx (Memr[inbuf], outbuf[outrow], iwidth)
		} else {
		    if( owidth > iwidth )
			call amovkr (0.0, outbuf[outrow+iwidth], owidth-iwidth)
		    call amovr (Memr[inbuf], outbuf[outrow], iwidth)
		}
		outrow = outrow + owidth
	    }
	}
end

#
# Function:	lace_cmplx
# Purpose:	Given consecutive reals, move as real parts in a complex array
#		(read real to complex with no blocking) - equivalent to imgnlx
#		but using pointer in real array.
# Parameters:	See argument declarations
# Pre-state:	im opened on file, outbuf allocated for data
# Post-state:	Data in outbuf, imaginary parts are set to zero
# Method:	< optional >
# Notes:	Both arrays may occupy the same space if the reals start at
#		c_row[1]
# Notes:	Imaginary parts are set to zero
#
procedure lace_cmplx ( r_row, c_row, width )

real	r_row[ARB]	# i: real array
real	c_row[ARB]	# i: complex array (viewed as paired reals)
int	width		# i: number of array elements involved

int	i, j		# l: real and cmplx array counters, respectively

begin
	# loop backwards, starting at end of both arrays
	j = width + width - 1
	do i = width, 1, -1 {
	    # move the real part
	    c_row[j] = r_row[i]
	    # zero the imaginary part
	    c_row[j+1] = 0.0
	    j = j - 2
	}
end
