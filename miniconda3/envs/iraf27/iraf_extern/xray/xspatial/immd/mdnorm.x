#$Header: /home/pros/xray/xspatial/immd/RCS/mdnorm.x,v 11.0 1997/11/06 16:33:00 prosb Exp $
#$Log: mdnorm.x,v $
#Revision 11.0  1997/11/06 16:33:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:39  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:36  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:10  pros
#General Release 1.0
#
#
# Module:	MDNORM.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	routines to compute the normilization factor for a model
# External:	md_norm(), md_rowsum()
# Local:
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	21 Dec 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include <iraf.h>
include <imhdr.h>
include "mdset.h"


#
# Function:	md_norm
# Purpose:	compute the normilization factor for a model
# Parameters:	See argument declarations
# Returns:	1/sum of function over defined area
# Uses:		md_apply(), md_rowsum()
# Pre-cond:	function must be completely defined in func structure
# Post-cond:	no change
# Exceptions:
# Method:	Function is centered on a pixel at the center.  Sum over
#		defined area is then computed row by row.  Summing works from
#		outside in to keep magnitudes of sum and data as close as
#		possible (minimize rounding errors).
# Notes:	Should also work with user supplied file or function
#
real procedure md_norm ( width, height, func )

int	width, height	# i: dimensions of hypothetical buffer
pointer	func		# i: structure describing model function

double	suma		# l: running sum of lines starting at 1
double	sumb		# l: running sum of lines starting at height
real	ycena		# l: position of buf center relative to ya
real	ycenb		# l: position of buf center relative to yb
int	ya		# l: row index starting at 1
int	yb		# l: row index starting at height
pointer	linebuf		# l: salloc buffer for one image line
pointer	nfunc		# l: local copy of model function structure
pointer	sp		# l: stack pointer
real	md_filenorm()

begin
	# catch special case of MDFILE
	if( (MD_FUNCTION(func) == MDFILE) || (MD_FUNCTION(func) == MDKFILE) )
	    return( md_filenorm (MD_FILENAME(func)) )
	call smark (sp)
	# allocate buffer for single line
	call salloc (linebuf, width, TY_REAL)
	# make a copy of the function table
	call salloc (nfunc, MD_LEN, TY_STRUCT)
	call amovi (Memi[func], Memi[nfunc], MD_LEN)
	# set value to unity
	MD_VAL(nfunc) = 1.0
	# put line center in integer middle of line
	MD_XCEN(nfunc) = real(width / 2)
	# y centers are offsets from the line being counted
	ycena = real(height / 2)
	ycenb = ycena - real(height)
	# clear the sums
	suma = 0.0D0
	sumb = 0.0D0
	# compute sum one line at a time, working from both ends
	ya = 1
	yb = height
	while( ya < yb ) {
	    # sum the bottom row
	    MD_YCEN(nfunc) = real(ya)
	    call md_apply (Memr[linebuf], width, 1, nfunc, 0, 1)
	    call md_rowsum (Memr[linebuf], width, suma)
	    # sum the top row
	    MD_YCEN(nfunc) = real(yb)
	    call md_apply (Memr[linebuf], width, 1, nfunc, 0, 1)
	    call md_rowsum (Memr[linebuf], width, sumb)
	    ycena = ycena - 1.0
	    ycenb = ycenb + 1.0
	    ya = ya + 1
	    yb = yb - 1
	}
	# if height was odd, add in the middle line
	if( ya == yb ) {
	    MD_YCEN(nfunc) = real(ya)
	    call md_apply (Memr[linebuf], width, 1, nfunc, 0, 1)
	    call md_rowsum (Memr[linebuf], width, suma)
	}
	suma = suma + sumb
	if( suma == 0.0 ) {
	    call printf ("Error: model gives no data\n")
	    sumb = 0.0D0
	} else
	    sumb = 1.0D0 / suma
	call sfree(sp)
	return(real(sumb))
end


#
# Function:	md_rowsum
# Purpose:	sum the values in a 1d array
# Parameters:	See argument declarations
# Returns:	
# Uses:		md_apply(), md_rowsum()
# Pre-cond:	line with data, initialized sum variable
# Post-cond:	the computed sum is added to the sum argument
# Exceptions:
# Method:	Summing works from the outside in to keep magnitudes of
#		sum and data as close as possible (minimize rounding errors).
#
procedure md_rowsum ( line, width, sum )

real	line[ARB]	# i: line of data
int	width		# i: length of line
double	sum		# i,o: running subtotal to add this line's sum

double	suma		# l: running sum of lines starting at 1
double	sumb		# l: running sum of lines starting at width
int	xa		# l: index starting at 1
int	xb		# l: index starting at width

begin
	xa = 1
	xb = width
	suma = 0.0D0
	sumb = 0.0D0
	while( xa < xb ) {
	    suma = suma + line[xa]
	    sumb = sumb + line[xb]
	    xa = xa + 1
	    xb = xb - 1
	}
	if( xa == xb )
	    suma = suma + line[xa]
	suma = suma + sumb
	sum = sum + suma
end

#
# Function:	md_filenorm
# Purpose:	return 1/(sum of all pixels in a data file)
# Parameters:	See argument declarations
# Returns:	
# Uses:		immap(), imgnlr(), mdrowsum()
# Pre-cond:	File must exist
# Post-cond:	no change
# Exceptions:
# Method:	Summing works from the outside in to keep magnitudes of
#		sum and data as close as possible (minimize rounding errors).
# Notes:	Normalization for files is done in this special routine
#		for efficiency, using the method of the other model functions
#		(opening and closing the file for each line) would be too
#		slow.
#
real procedure md_filenorm ( file )

char	file[ARB]	# i: name of input file

double	suma		# l: running sum of lines starting at 1
double	sumb		# l: running sum of lines starting at height
long	v[IM_MAXDIM]	# l: number of dimensions permitted of IRAF images
int	ya		# l: row index starting at 1
int	yb		# l: row index starting at height
int	width, height	# l: dimensions of file
pointer	mdim		# l: handle for input file
pointer	linebuf		# l: buffer for reading image

int	imgnlr()
pointer	immap()

begin

	mdim = immap(file, READ_ONLY, 0)
	# get image's dimensions
	width = IM_LEN(mdim,1)
	height = IM_LEN(mdim,2)

	# set initial indices to 1
	call amovkl (long(1), v, IM_MAXDIM)
	# clear the sums
	suma = 0.0D0
	sumb = 0.0D0
	# compute sum one line at a time, working from both ends
	ya = 1
	yb = height
	while( ya < yb ) {
	    # sum the bottom row
	    v[2] = ya
	    # read in one line
	    if( imgnlr (mdim, linebuf, v) == EOF ) {
		call error (1, "unexpected EOF")
	    }
	    call md_rowsum (Memr[linebuf], width, suma)
	    # sum the top row
	    v[2] = yb
	    # read in one line
	    if( imgnlr (mdim, linebuf, v) == EOF ) {
		call error (1, "unexpected EOF")
	    }
	    call md_rowsum (Memr[linebuf], width, sumb)
	    ya = ya + 1
	    yb = yb - 1
	}
	# if height was odd, add in the middle line
	if( ya == yb ) {
	    v[2] = ya
	    # read in one line
	    if( imgnlr (mdim, linebuf, v) == EOF ) {
		call error (1, "unexpected EOF")
	    }
	    call md_rowsum (Memr[linebuf], width, suma)
	}
	suma = suma + sumb
	if( suma == 0.0 ) {
	    call printf ("Error: model gives no data\n")
	    sumb = 0.0D0
	} else
	    sumb = 1.0D0 / suma
	return( real(sumb) )
end
