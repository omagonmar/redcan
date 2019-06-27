#$Header: /home/pros/xray/xtiming/fft/RCS/fillgap.x,v 11.0 1997/11/06 16:44:35 prosb Exp $
#$Log: fillgap.x,v $
#Revision 11.0  1997/11/06 16:44:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:32:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:29  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:52  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       fillgap
# Project:      PROS -- ROSAT RSDC
# Purpose:      support routines for the fast fourier transform
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include <mach.h>
include "fft.h"
define	OFF	-1

procedure fillgap(exposure,source,index,lindex)
real	exposure		# i: exposure for bin
real	source[ARB]		# i/o input source array, output with requested
				# gap filled
int	index			# i: absolute index at which gap is to be checked
int	lindex			# i: local index within segment
include "fillgap.cmn"

begin
	switch(fillmode){
	case NO_FILL: 
	    ;
	case INTERP:
	    if( (abs(exposure-0.0E0))< EPSILON && first_index == OFF )
	    {
		first_cts = source[lindex-1]
		first_index = index
	    }
	    else if( (abs(exposure-0.0E0)) >= EPSILON  && 
			last_index == OFF && first_index != OFF)
	    {
		last_index = index-1
		last_cts = source[lindex]
		call fill_interp(source)
		call clear_gap()
	    }
	case MEAN:
	    if( (abs(exposure-0.0)) < EPSILON )
		source[lindex] = ctmean
	default:
	    call error(FFT_ERROR,"Warning: Invalid gap fill mode")
	}
end

procedure init_fillgap(td,datacol)
pointer	td			# i: input table pointer
char	datacol[ARB]		# i: label for input data

char    buf[SZ_LINE]
int	clgeti()
real	clgetr()
include "fillgap.cmn"
begin
	fillmode = clgeti(FILLMODE)
	if( fillmode == MEAN )
	{
	    call sprintf(buf,SZ_LINE,"%sMU")
	      call pargstr(datacol)
	    ctmean = clgetr(FILLCONSTANT)
#	    ctmean = tbhgtr(td,buf)
	}
	call clear_gap()
#	switch (fillmode){
#	case NO_FILL:
#	    call sprintf(buf,SZ_LINE,"NO_FILL")
#	case MEAN:
#	    call sprintf(buf,SZ_LINE,"MEAN")
#	case INTERP:
#	    call sprintf(buf,SZ_LINE,"INTERP")
#	}
#	call pwr_cheader("GAPFILL",buf)
#	call fft_cheader("GAPFILL",buf)
end

procedure finish_fillgap(source,index,lindex)
real	source[ARB]		# i/o: array of source cts
int	index			# i: absolute index at which gap occurs
int	lindex			# i: relative index ( within segment) at which
				# gap occurs
include "fillgap.cmn"

begin
#  Finish filling a gap which is still active at end of data
#
	switch(fillmode){

	case NO_FILL: 
	    ;
	case INTERP:
	    if( first_index != OFF )
	    {
		last_index = index
		last_cts = first_cts
		source[index]=last_cts
		call fill_interp(source)
	    }
	case MEAN:
	    ;
	default:
	    call error(FFT_ERROR,"Warning: Invalid gap fill mode")
	}
end

procedure fill_interp(source)
real	source[ARB]
include	"fillgap.cmn"

int bseg		# l: beginning segment number 
int eseg		# l: ending segment number
int seg			# l: index for current segment number
int findex		# l: current index for filling 
int lbindex		# l: first index within segment for filling
int leindex		# l: last index within segment for filling
int tindex		# l: current index within segment for filling
real tcounts[NELEM]	# l: temp storage for count buffer
real interp()

begin
    # Determine if the gap crosses this segment boundary
	if( first_index == 1)
	    first_cts = last_cts
	bseg = (first_index-1) / NELEM + 1
	eseg = (last_index-1) / NELEM + 1
	findex = first_index
    # For gaps outside this boundary, the data must be retrieved from disk
	if( bseg != eseg)
	{
	    do seg = bseg,eseg-1
	    { 
		call dread(seg,tcounts,1,HALFNELEM)
		lbindex = mod(findex-1,NELEM)+1
		leindex = NELEM
		do tindex=lbindex,leindex
		{
		    tcounts[tindex] = interp(findex)
		    findex = findex + 1
		}
		call dwrite(seg,tcounts,1,HALFNELEM)
	    }
#        After filling old segment, update the beginnning of the gap to the
#	    beginning of the current segment
	    first_index= 1
	    last_index=mod(last_index-1,NELEM)+1
	    first_cts = tcounts[NELEM]
	}	
#    After filling old segments, we finish filling active segment
#	else
#    We have all the data necessary here in the array
#	{
	    lbindex = mod(first_index-1,NELEM)+1
	    leindex = mod(last_index-1,NELEM)+1
	    do tindex=lbindex,leindex
	        source[tindex] = interp(tindex)
#	}		
end


real procedure interp(index)
int	index			# i: current index value
real	fill			# o: output interpolated valuebegin
include	"fillgap.cmn"
begin
 	fill = (index-(first_index-1))*(last_cts-first_cts)/ 
			(last_index+1-(first_index-1)) + first_cts
	return(fill)
end

procedure clear_gap()
include "fillgap.cmn"
begin
	first_index = OFF
	last_index = OFF
	first_cts = 0.0E0
	last_cts = 0.0E0
end

procedure gap_cheader()
include "fillgap.cmn"
char    buf[SZ_LINE]

begin
	switch (fillmode){
	case NO_FILL:
	    call sprintf(buf,SZ_LINE,"NO_FILL")
	case MEAN:
	    call sprintf(buf,SZ_LINE,"MEAN")
	case INTERP:
	    call sprintf(buf,SZ_LINE,"INTERP")
	}
	call pwr_cheader("GAPFILL",buf)
	call fft_cheader("GAPFILL",buf)
end


