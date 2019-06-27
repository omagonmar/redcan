#$Header: /home/pros/xray/xspatial/immodel/RCS/pixacts.x,v 11.0 1997/11/06 16:30:24 prosb Exp $
#$Log: pixacts.x,v $
#Revision 11.0  1997/11/06 16:30:24  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:29:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:04  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:30:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:29  pros
#General Release 1.0
#
#
# Module:       PIXACTS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      actions taken by the yacc parser
# External:     pix_table(), pixlist()
# Local:        pix_nocol(), pix_pixel()
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Eric Mandel  initial version whoknows<when>
#               {n} <who> -- <does what> -- <when>
#

#
# PIXACTS.X -- actions taken by the yacc parser
#

include <error.h>
include	<ctype.h>
include <tbset.h>

include "pixparse.h"

#
# PIX_TABLE -- process a table file containing pixels and intensities
#
procedure pix_table(fname, xcol, ycol, cntcol, yyval)

char	fname[ARB]			# i: list file name
char	xcol[ARB]			# i: x column name
char	ycol[ARB]			# i: y column name
char	cntcol[ARB]			# i: intensity column name
pointer	yyval				# o: return value

int	nrows				# l: number of rows
int	ncols				# l: temp for tbpsta
pointer tdp				# l: pointer to table descriptor
pointer	xcdp, ycdp, cntcdp		# l: pointers to column descriptors
pointer	null				# l: pointer to null for tbcptr()
int	tbpsta()			# l: get value of a parameter
pointer	tbtopen()			# l: open a table

include "pixparse.com"

begin
	if( c_debug >0 ){
	    call printf("processing table: %s with columns: %s %s %s\n")
	    call pargstr(fname)
	    call pargstr(xcol)
	    call pargstr(ycol)
	    call pargstr(cntcol)
	}
	# open the table
	tdp = tbtopen(fname, READ_ONLY, 0)
	# get number of rows
	nrows = tbpsta(tdp, TBL_NROWS)	
	O_TYPE(yyval) = 0
	# make sure we have the columns
	ncols = 1
	call tbcfnd(tdp, xcol, xcdp, ncols)
	if( xcdp <=0 )
	    call pix_nocol(xcol, fname)
	call tbcfnd(tdp, ycol, ycdp, ncols)
	if( ycdp <=0 )
	    call pix_nocol(ycol, fname)
	call tbcfnd(tdp, cntcol, cntcdp, ncols)
	if( cntcdp <=0 )
	    call pix_nocol(cntcol, fname)
	# reallocate space for this number of elements
	c_npix = c_npix + nrows
	while( c_npix > c_max )
	    c_max = c_max + BUFINC
	call realloc (c_x, c_max, TY_REAL)
	call realloc (c_y, c_max, TY_REAL)
	call realloc (c_cnts, c_max, TY_REAL)
	# allocate space for null
	call malloc(null, nrows, TY_BOOL)
	# grab the data elements for the three columns
	call tbcgtr(tdp, xcdp, Memr[c_x+c_npix-nrows], Memb[null], 1, nrows)
	call tbcgtr(tdp, ycdp, Memr[c_y+c_npix-nrows], Memb[null], 1, nrows)
	call tbcgtr(tdp, cntcdp, Memr[c_cnts+c_npix-nrows], Memb[null], 1, nrows)
	# close the table
	call tbtclo(tdp)
	# free up null pointer space
	call mfree(null, TY_BOOL)
end

#
# PIX_NOCOL -- die on error "can't find column"
#
procedure pix_nocol(colname, fname)

char	colname[ARB]			# i: column name
char	fname[ARB]			# i: table name
char	tbuf[SZ_LINE]			# l: temp buffer

begin
	call sprintf(tbuf, SZ_LINE, "can't find column name %s in table %s")
	call pargstr(colname)
	call pargstr(fname)
	call error(1, tbuf)
end
	
#
# PIX_LIST -- Read a list of 3 columns into the c_x, c_y, and c_cnts
# arrays. Update c_npix (number of elements read) and realloc arrays
# as needed
#

procedure pix_list (fname, yyval)

char	fname[ARB]	# i: Name of list file
pointer	yyval		# return value

int	fd		# l: file descriptor of open list file
int	lineno		# l: current line number in list file
real	xval		# l: parsed x value
real	yval		# l: parsed y value
real	magval		# l: parsed magnitude value
pointer	sp		# l: stack pointer
pointer	lbuf		# l: line buffer
pointer	ip		# l: character index pointer in line buffer

int	getline(), nscan(), open()
errchk	open, sscan, getline

include "pixparse.com"

begin
	# mark the stack
	call smark (sp)
	if( c_debug >0 ){
	    call printf("processing list: %s\n")
	    call pargstr(fname)
	}
	# allocate some  buffer space
	call salloc (lbuf, SZ_LINE, TY_CHAR)
	# open the list file
	fd = open (fname, READ_ONLY, TEXT_FILE)
	# initialize line counter
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
		call error(1, "in pix_parse")
	    } else 
		# put the values in their place
		call pix_pixel(xval, yval, magval, yyval)
	}
	# close file and free up space
	call close (fd)
	call sfree (sp)
end

#
# PIX_PIXEL -- process pixel and intensity
#
procedure pix_pixel(x, y, cnt, yyval)

real	x				# x value
real	y				# y value
real	cnt				# intensity
pointer	yyval				# return value

include "pixparse.com"

begin
	if( c_debug >1 ){
	    call printf("processing pixel: %.2f %.2f %.2f\n")
	    call pargr(x)
	    call pargr(y)
	    call pargr(cnt)
	}
	# got one more pixel
	c_npix = c_npix+1
	# see if it fits into this buffer
	if( c_npix > c_max ) {
	    # re-allocate buffer if not
	    c_max = c_max + BUFINC
	    call realloc (c_x, c_max, TY_REAL)
	    call realloc (c_y, c_max, TY_REAL)
	    call realloc (c_cnts, c_max, TY_REAL)
	}
	Memr[c_x+c_npix-1] = x
	Memr[c_y+c_npix-1] = y
	Memr[c_cnts+c_npix-1] = cnt

	# dummy for yacc
	O_TYPE(yyval) = 0
end

