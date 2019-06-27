#$Header: /home/pros/xray/xspatial/imdisp/RCS/imdisubs.x,v 11.0 1997/11/06 16:30:29 prosb Exp $
#$Log: imdisubs.x,v $
#Revision 11.0  1997/11/06 16:30:29  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:47:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:57:54  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:30:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:29:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:36:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:27:33  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:12:54  pros
#General Release 1.0
#
# Module:       IMDISUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to support imdisp
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC  -- Update the include files -- 2/91
#               {n} <who> -- <does what> -- <when>
#
# QPTABLES.X -- routines dealing with the STScI table file
#

include <qpoe.h>
include <plhead.h>

#
# ini_distable -- open the table file and create column headers
#
procedure ini_distable(table, tp, cp, ncols, type, block)

char	table[ARB]		# i: table name
pointer tp			# i: table pointer
pointer	cp[ARB]			# i: column pointers
int	ncols			# i: number of columns to create
int	type			# i: data type of columns
int	block			# i: block factor

char	tbuf[SZ_LINE]		# l: temp buf
int	i,j			# l: loop counters
pointer tbtopn()		# l: table I/O routines

begin
	# open a new table  
	tp = tbtopn(table, NEW_FILE, 0)

	# the first column is the row number
	call tbcdef(tp, cp[1], "row", "", "%-4d", TY_INT, 1, 1)

	# define columns
	for(i=1; i<=ncols; i=i+1){
	    # make up the column name
	    call sprintf(tbuf, SZ_LINE, "c%d")
	    call pargi((i-1)*block+1)
	    j = i+1
	    # make a column of the appropriate type
	    switch(type){
	    case TY_SHORT:
		call tbcdef(tp, cp[j], tbuf, "", "%-4d", TY_INT, 1, 1)
	    case TY_INT, TY_LONG:
		call tbcdef(tp, cp[j], tbuf, "", "%-6d", TY_INT, 1, 1)
	    case TY_REAL:
		call tbcdef(tp, cp[j], tbuf, "", "%-.2f", TY_REAL, 1, 1)
	    case TY_DOUBLE, TY_COMPLEX:
		call tbcdef(tp, cp[j], tbuf, "", "%-.4f", TY_DOUBLE, 1, 1)
	    }
	}

	# now actually create it
	call tbtcre(tp)
end

#
# HD_DISTABLE -- put some header params to the table file
#
procedure hd_distable(tp, xblock, yblock, scale, bias, flip)

pointer tp			# i: table pointer
int	xblock			# i: x block factor
int	yblock			# i: y block factor
real	scale			# i: scale factor
real	bias			# i: bias factor
bool	flip			# i: flip table?

begin
	call tbhadi(tp, "xblock", xblock)
	call tbhadi(tp, "yblock", yblock)
	call tbhadr(tp, "scale", scale)
	call tbhadr(tp, "bias", bias)
	if( flip )
	    call tbhadt(tp, "flip",
	    "table is flipped - origin is in lower left")
	else
	    call tbhadt(tp, "flip",
	    "table is not flipped - origin is in upper left")
end

#
# FIL_DISATBLE -- fill a table with buffer data
#
procedure fil_distable(tp, cp, buf, ncols, nrows, type, block, flip)

pointer tp			# i: table pointer
pointer	cp[ARB]			# i: column pointers
pointer	buf			# i: data buffer
int	ncols			# i: number of columns
int	nrows			# i: number of rows
int	type			# i: data type of columns
int	block			# i: block factor
bool	flip			# i: flip table?

int	i,j			# l: loop counters
int	row			# l: current row number
int	mini			# l: min i loop value
int	maxi			# l: max i loop value
int	offset			# l: current pixel offset
int	ipixval			# l: int pixel value
real	rpixval			# l: real pixel value
double	dpixval			# l: double pixel value

begin
	# determine flip limits
	if( flip ){
	    mini = nrows - 1
	    maxi = -1
	}
	else{
	    mini = 0
	    maxi = nrows
	}
	# init row number
	row = 0
	# this loop is weird because of the 2 different ways it can be done
	# top to bottom or bottom to top
	for(i=mini; i!=maxi;){
	    # inc row number
	    row = row+1
	    # write row number
	    call tbrpti(tp, cp[1], i*block+1, 1, row)
	    # write each column for this row
	    for(j=1; j<=ncols; j=j+1){
		# determine offset into array 
		offset = i*ncols+j
		switch(type){
		case TY_SHORT:
		    ipixval = Mems[buf+offset-1]
		    call tbrpti(tp, cp[j+1], ipixval, 1, row)
		case TY_INT, TY_LONG:
		    ipixval = Memi[buf+offset-1]
		    call tbrpti(tp, cp[j+1], ipixval, 1, row)
		case TY_REAL:
		    rpixval = Memr[buf+offset-1]
		    call tbrptr(tp, cp[j+1], rpixval, 1, row)
		case TY_DOUBLE:
		    dpixval = Memd[buf+offset-1]
		    call tbrptd(tp, cp[j+1], dpixval, 1, row)
		case TY_COMPLEX:
		    dpixval = Memx[buf+offset-1]
		    call tbrptd(tp, cp[j+1], dpixval, 1, row)
		}
	    }
	    # increment or decrement the i loop counter
	    if( flip )
		i = i-1
	    else
		i = i+1
	}
end

#
#  SCA_DISBUF -- apply a scale factor and bias to data
#
procedure sca_disbuf(buf, nrecs, type, scale, bias)

pointer	buf			# i: data buffer
int	nrecs			# i: number of data elements in buf
int	type			# i: data type of columns
real	scale			# i: scale factor
real	bias			# i: bias factor
int	i			# l: loop counter

begin
	# scale the data and add the bias
	for(i=0; i<nrecs; i=i+1){
	    switch(type){
	    case TY_SHORT:
		Mems[buf+i] = real(Mems[buf+i])*scale+bias
	    case TY_INT, TY_LONG:
		Memi[buf+i] = real(Memi[buf+i])*scale+bias
	    case TY_REAL:
		Memr[buf+i] = Memr[buf+i]*scale+bias
	    case TY_DOUBLE:
		Memd[buf+i] = Memd[buf+i]*scale+bias
	    case TY_COMPLEX:
		Memx[buf+i] = Memx[buf+i]*scale+bias

	    }
	}	
end
