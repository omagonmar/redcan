#$Header: /home/pros/xray/xspatial/immd/RCS/mdsource.x,v 11.0 1997/11/06 16:33:02 prosb Exp $
#$Log: mdsource.x,v $
#Revision 11.0  1997/11/06 16:33:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:52:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:34  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:21:16  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:49  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:19  pros
#General Release 1.0
#
#
# Module:	MDSOURCE.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	subroutines to get source parameters for model
# External:	md_sources
# Local:
# Description:  Get the user's input of source centers and magnitudes.  Return
#		three arrays and number of sources.
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	1 December 1988	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#

include <error.h>
include	<ctype.h>

define SZ_BUF	1024

#
# Function:		pix_parse
# Purpose:		Get source parameters
# Parameters:		See argument declarations
# Returns:		Pointers for three real arrays with x, y, and
#			magnitude parameters and count of sources in the
#			parameter arrays
# Uses:		
# Pre-condition:	
# Post-condition:	Pointer values set
# Exceptions:
# Method:	< optional >
# Notes:	
#
int procedure pix_parse ( srclist, xcen, ycen, val, debug )

char	srclist[SZ_PATHNAME]	# i: input string
pointer	xcen			# o: x coordinates of source centers
pointer ycen			# o: y coordinates of source centers
pointer val			# o: magnitude of source for model application
int	debug			# i: debug switch (not used)

real	xval			# l: parsed x value
real	yval			# l: parsed y value
real	magval			# l: parsed magnitude value
int	iw			# l: loop count
char	word[SZ_FNAME,4]	# i: token list

int	md_rdlist3()
int	nscan(), access()
errchk	sscan, malloc

begin
	# Parse the input
	call sscan (srclist) 
	do iw = 1, 4
	    call gargwrd (word[1,iw], SZ_FNAME)
	
	switch( nscan () ) {
	# How many words in input line?
	 case 1:
	    if( access (word[1,1], 0, TEXT_FILE) == YES ) {
		# get source parameters from a list file
		return( md_rdlist3 (word[1,1], xcen, ycen, val) ) 
	    } else {
		call eprintf ("file not a list file\n")
	    }
	 case 3:
	    # Parse the input
	    call sscan (srclist)
	     call gargr (xval)
	     call gargr (yval)
	     call gargr (magval)
	    # check for correct number of tokens
	    if( nscan() != 3 ) {
		call eprintf ("3 args, not all numerical: %s\n")
		 call pargstr (srclist)
	    } else {
		iferr {
		    call malloc (xcen, 1, TY_REAL)
		    call malloc (ycen, 1, TY_REAL)
		    call malloc (val, 1, TY_REAL)
		} then
		    call erract (EA_FATAL)
		Memr[xcen] = xval
		Memr[ycen] = yval
		Memr[val] = magval
		return( 1 )
	    }
	 default:
	    call eprintf ("wrong number of args: %s\n")
	     call pargstr (srclist)
	}
	return( 0 )
end


# MD_RDLIST2 -- Read a list of two dimensional data pairs into two type
# real arrays in memory.  Return pointers to the arrays and a count of the
# number of pixels.  If mark sizes are to be read from the input list,
# a third array of mark sizes is returned.  Mark sizes can only be given
# in two column (x,y) mode, with the mark size given as a third column.

int procedure md_rdlist3 ( fname, xcen, ycen, val )

char	fname[SZ_FNAME]	# i: Name of list file
pointer	xcen, ycen, val	# o: Pointers to x, y and magnitude vectors

real	xval		# l: parsed x value
real	yval		# l: parsed y value
real	magval		# l: parsed magnitude value
int	buflen		# l: current length of paramter buffers
int	n		# l: number of parameters successfully read
int	fd		# l: file descriptor of open list file
int	lineno		# l: current line number in list file
pointer	sp		# l: stack pointer
pointer	lbuf		# l: line buffer
pointer	ip		# l: character index pointer in line buffer

int	getline(), nscan(), open()
errchk	open, sscan, getline, malloc

begin
	call smark (sp)
	call salloc (lbuf, SZ_LINE, TY_CHAR)
	# open the list file
	fd = open (fname, READ_ONLY, TEXT_FILE)
	# allocate initial parameter buffers
	buflen = SZ_BUF
	iferr {
	    call malloc (xcen, buflen, TY_REAL)
	    call malloc (ycen, buflen, TY_REAL)
	    call malloc (val, buflen, TY_REAL)
	} then
	    call erract (EA_FATAL)
	# initialize parameter and line counters
	n = 0
	lineno = 0
	# loop in each line
	while( getline(fd, Memc[lbuf]) != EOF ) {
	    # Skip comment lines and blank lines.
	    lineno = lineno + 1
	    if( Memc[lbuf] == '#' )
		next
	    for( ip=lbuf;  IS_WHITE(Memc[ip]);  ip=ip+1 )
		;
	    if( (Memc[ip] == '\n') || (Memc[ip] == EOS) )
		next
	    # Decode the source parameters
	    call sscan (Memc[ip])
	     call gargr (xval)
	     call gargr (yval)
	     call gargr (magval)
	    # check for correct number of tokens
	    if( nscan() != 3 ) {
		call eprintf ("wrong number of args; %s, line %d: %s\n")
		 call pargstr (fname)
		 call pargi (lineno)
		 call pargstr (Memc[lbuf])
	    } else {
		Memr[xcen+n] = xval
		Memr[ycen+n] = yval
		Memr[val+n] = magval

		n = n + 1
		if( n >= buflen ) {
		    buflen = buflen + SZ_BUF
		    call realloc (xcen, buflen, TY_REAL)
		    call realloc (ycen, buflen, TY_REAL)
		    call realloc (val, buflen, TY_REAL)
		}
	    }
	}
	# reallocate buffers just to needed size
	call realloc (xcen, n, TY_REAL)
	call realloc (ycen, n, TY_REAL)
	call realloc (val, n, TY_REAL)

	call close (fd)
	call sfree (sp)
	return (n)
end

