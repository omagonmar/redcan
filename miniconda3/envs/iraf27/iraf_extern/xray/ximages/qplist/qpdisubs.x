#$Header: /home/pros/xray/ximages/qplist/RCS/qpdisubs.x,v 11.0 1997/11/06 16:28:47 prosb Exp $
#$Log: qpdisubs.x,v $
#Revision 11.0  1997/11/06 16:28:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:55  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:59  prosb
#General Release 2.3.1
#
#Revision 7.1  94/03/23  15:58:40  mo
#MC	3/22/94		Move 6 action display routines to QPCREATE/EVDISUBS
#			for general use
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
# Module:       QPDISUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to display elements from QPOE EVENT definition
#		Also open table and create column headers
# External:     qpd_inittable(),qpd_header()
# CALLS(lib):        s_disp(),i_disp(),r_disp(),d_disp(),x_disp() 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version  1990
#               {1} MC    -- Convert to right justified columns with
#			     default widths appropriate for data types -- 1/91 
#               {n} <who> -- <does what> -- <when>#

procedure qpd_inittable(table, tp, cp, name, type, ncomp)

char table[ARB]			# i: table name
pointer tp			# o: table pointer
pointer cp			# o: column pointers
pointer	name			# i: array of element names
pointer	type			# i: array of element types
int	ncomp			# i: number of names

int	i			# l: loop counter
int	etype			# l: element type
int	ttype			# l: table type
char	format[SZ_FNAME]	# l: column format
pointer tbtopn()		# l: table I/O routines

begin
	# open a new table  
	tp = tbtopn(table, NEW_FILE, 0)
	# allocate space for the column pointers
	call calloc(cp, ncomp, TY_POINTER)
	# loop though macros and define columns
	do i=1, ncomp{
	    etype = Memi[type+i-1]
	    switch(etype){
	    case TY_SHORT:
		ttype = TY_INT
		call strcpy("%6d", format, SZ_FNAME)
	    case TY_INT:
		ttype = TY_INT
		call strcpy("%10d", format, SZ_FNAME)
	    case TY_LONG:
		ttype = TY_INT
		call strcpy("%10d", format, SZ_FNAME)
	    case TY_REAL:
		ttype = TY_REAL
		call strcpy("%11.2f", format, SZ_FNAME)
	    case TY_DOUBLE:
		ttype = TY_DOUBLE
		call strcpy("%17.4f", format, SZ_FNAME)
	    case TY_COMPLEX:
		ttype = TY_DOUBLE
		call strcpy("%17.4f", format, SZ_FNAME)
	    }
	    call tbcdef(tp, Memi[cp+i-1], Memc[Memi[name+i-1]], "",
			format, ttype, 1, 1)
	}
	# now actually create the table
	call tbtcre(tp)
end

#
#  QPD_HEADER -- make up a nice header for the display
#
procedure qpd_header(name, type, ncomp, tbuf, len)

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

