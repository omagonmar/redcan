# $Header: /home/pros/xray/lib/pros/RCS/tsidisubs.x,v 11.0 1997/11/06 16:21:16 prosb Exp $
# $Log: tsidisubs.x,v $
# Revision 11.0  1997/11/06 16:21:16  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:28:34  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:38  prosb
#General Release 2.2
#
#Revision 1.1  93/05/19  17:08:56  mo
#Initial revision
#
#
# Module:       TSIDISUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to display elements from QPOE auxiliary definition
# Local:        s_adisp(),i_adisp(),r_adisp(),d_adisp(),x_adisp()
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
#               {n} <who> -- <does what> -- <when>#

#
#  QP_AHEADER -- make up a nice header for the display
#
procedure qp_aheader(name, type, ncomp, tbuf, len)

pointer	name				# i: pointer to element names
pointer	type				# i: pointer to element types
int	ncomp				# i: number of names
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
char	ibuf[SZ_FNAME]			# l: temp buffer
char	format[SZ_FNAME]		# l: format for value
int	i				# l: loop counter

begin
	do i=1, ncomp{
	    switch(Memi[type+i-1]){
	    case TY_SHORT:
		call strcpy("%6s", format, SZ_FNAME)
	    case TY_INT:
		call strcpy("%10s", format, SZ_FNAME)
	    case TY_LONG:
		call strcpy("%10s", format, SZ_FNAME)
	    case TY_REAL:
		call strcpy("%11s", format, SZ_FNAME)
	    case TY_DOUBLE:
		call strcpy("%17s", format, SZ_FNAME)
	    case TY_COMPLEX:
		call strcpy("%17s", format, SZ_FNAME)
	    }
	    call sprintf(ibuf, SZ_FNAME, format)
	    call pargstr(Memc[Memi[name+i-1]])
	    call strcat(ibuf, tbuf, len)
	}	
end

#
#  THESE ARE THE ACTION ROUTINES FOR DISPLAY, ONE PER DATA TYPE
#
procedure s_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
short	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
#	val = int(Mems[ev+offset])
	call amovs(Mems[ev+offset],val,SZ_SHORT)
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%6d")
	    call pargs(val)
	    call strcat(ibuf, tbuf, len)
#	}
	# write to table if necessary
end

procedure i_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
int	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
#	val = Memi[(ev+offset-1)/SZ_INT+1]
	call amovs(Mems[ev+offset],val,SZ_INT)
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%10d")
	    call pargi(val)
	    call strcat(ibuf, tbuf, len)
#	}
end

procedure l_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
long	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
#	val = Memi[(ev+offset-1)/SZ_LONG+1]
	call amovs(Mems[ev+offset],val,SZ_LONG)
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%10d")
	    call pargi(val)
	    call strcat(ibuf, tbuf, len)
#	}
end

procedure r_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
real	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
#	val = Memr[(ev+offset-1)/SZ_REAL+1]
	call amovs(Mems[ev+offset],val,SZ_REAL)
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%11.2f")
	    call pargr(val)
	    call strcat(ibuf, tbuf, len)
#	}
end

procedure d_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
double	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
#	val = Memd[(ev+offset-1)/SZ_DOUBLE+1]
	call amovs(Mems[ev+offset],val,SZ_DOUBLE)
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%17.4f")
	    call pargd(val)
	    call strcat(ibuf, tbuf, len)
#	}
end

procedure x_adisp(offset, ev, tbuf, len)

int	offset				# i: offset into event record
pointer	ev				# i: event record pointer
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
complex	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
	val = Memx[(ev+offset-1)/SZ_COMPLEX+1]
#	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%17.4f")
	    call pargd(double(val))
	    call strcat(ibuf, tbuf, len)
#	}
end

