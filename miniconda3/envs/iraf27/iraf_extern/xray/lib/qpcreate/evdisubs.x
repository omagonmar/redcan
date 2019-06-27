#$Header: /home/pros/xray/lib/qpcreate/RCS/evdisubs.x,v 11.0 1997/11/06 16:21:28 prosb Exp $
#$Log: evdisubs.x,v $
#Revision 11.0  1997/11/06 16:21:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:00  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:14:58  dvs
#Fixed bug: l_disp needed a "dodisp" parameter passed in.
#
#Revision 8.0  94/06/27  14:32:35  prosb
#General Release 2.3.1
#
#Revision 1.1  94/03/25  14:37:57  mo
#Initial revision
#
#Revision 7.0  93/12/27  18:27:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:56  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:31:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:46  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:24  pros
#General Release 1.0
#
# Module:       EVDISUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to display elements from QPOE EVENT definition
#		Also open table and create column headers
# External:     s_disp(),i_disp(),l_disp(),r_disp(),d_disp(),x_disp()
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version  1990
#               {1} MC    -- Convert to right justified columns with
#			     default widths appropriate for data types -- 1/91 
#               {n} <who> -- <does what> -- <when>#

#
#  THESE ARE THE ACTION ROUTINES FOR DISPLAY, ONE PER DATA TYPE
#
procedure s_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)

int	offset				# i: offset into event record
pointer	tp				# i: table pointer
pointer	cp				# i: column pointer
bool	dotable				# i: write to table?
pointer	ev				# i: event record pointer
int	total				# i: event number
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
bool	dodisp				# i: flag no display
int	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
	val = int(Mems[ev+offset])
	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%6d")
	    call pargi(val)
	    call strcat(ibuf, tbuf, len)
	}
	# write to table if necessary
	if( dotable )
	    call tbrpti(tp, cp, val, 1, total)
end

procedure i_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)

int	offset				# i: offset into event record
pointer	tp				# i: table pointer
pointer	cp				# i: column pointer
bool	dotable				# i: write to table?
pointer	ev				# i: event record pointer
int	total				# i: event number
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
bool	dodisp				# i: flag no display
int	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
entry l_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)
	# get value of event element
	val = Memi[(ev+offset-1)/SZ_INT+1]
	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%10d")
	    call pargi(val)
	    call strcat(ibuf, tbuf, len)
	}
	# write to table if necessary
	if( dotable )
	    call tbrpti(tp, cp, val, 1, total)
end

procedure r_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)

int	offset				# i: offset into event record
pointer	tp				# i: table pointer
pointer	cp				# i: column pointer
bool	dotable				# i: write to table?
pointer	ev				# i: event record pointer
int	total				# i: event number
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
bool	dodisp				# i: flag no display
real	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
	val = Memr[(ev+offset-1)/SZ_REAL+1]
	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%11.2f")
	    call pargr(val)
	    call strcat(ibuf, tbuf, len)
	}
	# write to table if necessary
	if( dotable )
	    call tbrptr(tp, cp, val, 1, total)
end

procedure d_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)

int	offset				# i: offset into event record
pointer	tp				# i: table pointer
pointer	cp				# i: column pointer
bool	dotable				# i: write to table?
pointer	ev				# i: event record pointer
int	total				# i: event number
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
bool	dodisp				# i: flag no display
double	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
	val = Memd[(ev+offset-1)/SZ_DOUBLE+1]
	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%17.4f")
	    call pargd(val)
	    call strcat(ibuf, tbuf, len)
	}
	# write to table if necessary
	if( dotable )
	    call tbrptd(tp, cp, val, 1, total)
end

procedure x_disp(offset, tp, cp, dotable, ev, total, tbuf, len, dodisp)

int	offset				# i: offset into event record
pointer	tp				# i: table pointer
pointer	cp				# i: column pointer
bool	dotable				# i: write to table?
pointer	ev				# i: event record pointer
int	total				# i: event number
char	tbuf[ARB]			# o: output buffer
int	len				# i: length of tbuf
bool	dodisp				# i: flag no display
complex	val				# l: value of element
char	ibuf[SZ_FNAME]			# l: temp buffer for this value

begin
	# get value of event element
	val = Memx[(ev+offset-1)/SZ_COMPLEX+1]
	if( dodisp ){
	    call sprintf(ibuf, SZ_FNAME, "%17.4f")
	    call pargd(double(val))
	    call strcat(ibuf, tbuf, len)
	}
	# write to table if necessary
	if( dotable )
	    call tbrptd(tp, cp, double(val), 1, total)
end

