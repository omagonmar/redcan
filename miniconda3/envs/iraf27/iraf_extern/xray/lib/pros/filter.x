#
# FILTER.X -- routines to filter arrays of records.
# We use the same filter mechanism as is used for qpoe events.
# The structs pointers for these arrays of records must be TY_STRUCT,
# however, unlike, event filters, which are TY_SHORT.
#
# RCS header:
# $Header: /home/pros/xray/lib/pros/RCS/filter.x,v 11.0 1997/11/06 16:20:24 prosb Exp $
# $Log: filter.x,v $
# Revision 11.0  1997/11/06 16:20:24  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:30  prosb
# General Release 2.4
#
Revision 8.0  1994/06/27  13:45:51  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:09:15  prosb
General Release 2.3

Revision 6.1  93/11/30  11:53:11  prosb
MC	11/30/93		Update bad qp_addf routine

Revision 6.0  93/05/24  15:44:25  prosb
General Release 2.2

Revision 5.0  92/10/29  21:16:32  prosb
General Release 2.1

Revision 4.0  92/04/27  13:47:32  prosb
General Release 2.0:  April 1992

# Revision 1.1  91/01/11  11:06:09  eric
# Initial version
# 

include <qpoe.h>
include <missions.h>

# define the filter struct
define SZ_FLT		3
define FLT_EX		Memi[($1)+0]
define FLT_QP		Memi[($1)+1]
define FLT_QPN		Memi[($1)+2]
define FLT_QPNAME	Memc[Memi[($1)+2]]

# define the name of the fake filter qpoe file
define FAKENAME		"fakefilter.qp"

#
# FLT_OPEN -- initialize a filter expression
# (the "qp" arg is not used, but I suspect we will need it someday)
#
int procedure flt_open(qp)

pointer	qp				# i: qpoe handle
pointer	fptr				# l: filter handle
int	qp_access()			# l: qpoe file access
pointer	qp_open()			# l: open a qpoe file

begin
	# allocate a filter struct
	call calloc(fptr, SZ_FLT, TY_STRUCT)
	# make up the fake qpoe name name
	call calloc(FLT_QPN(fptr), SZ_PATHNAME, TY_CHAR)
	call strcpy(FAKENAME, FLT_QPNAME(fptr), SZ_PATHNAME)

	# delete the fake filter qpoe file, if necessary
	if( qp_access(FLT_QPNAME(fptr), 0) == YES )
	    call qp_delete(FLT_QPNAME(fptr))
	# open a fake qpoe file for filtering
	FLT_QP(fptr) = qp_open(FLT_QPNAME(fptr), NEW_FILE, 0)
	
	# return the filter handle
	return(fptr)
end

#
# FLT_ADDMACRO -- add a macro definition to be used by the filter
#
procedure flt_addmacro(fptr, name, value)

pointer	fptr				# i: filter handle
char	name[ARB]			# i: filter expression
char	value[ARB]			# i: filter expression
int	len				# l: length of string
int	qp_accessf()			# l: check for qpoe param existence
int	strlen()			# l: string length

begin
	# get length of value string
	len = strlen(value)+1
	# define the macro, if necessary
        if( qp_accessf(FLT_QP(fptr), name) == NO )
            call qpx_addf(FLT_QP(fptr), name, "macro", len, "macro def", 0)
        # write the macro value
        call qp_write(FLT_QP(fptr), name, value, len, 1, "macro")
end

#
#  FLT_COMPILE -- compile a filter in preparation for evaluation
#
procedure flt_compile(fptr, filter)

pointer	fptr				# i: filter handle
char	filter[ARB]			# i: filter expression
pointer	qpex_open()			# l: open a qpoe filter expression

begin
	# just use the qpoe expression open
	FLT_EX(fptr) = qpex_open(FLT_QP(fptr), filter)
end

#
#  FLT_EVALUATE -- evaluate a filter for a particular data record
#
int procedure flt_evaluate(fptr, ip)

pointer	fptr			# i: filter expression structure
pointer	ip			# i: struct pointer to input record
pointer	iev[1], oev[1]		# l: input and output arrays of pointers
int	qpex_evaluate()		# l: for qpex_evaluate

begin
	# convert struct pointer to short pointer (used by qpex)
	iev[1] = ip*2
	# evaluate the filter and return
	return(qpex_evaluate(FLT_EX(fptr), iev, oev, 1))
end

#
#  FLT_CLOSE -- close a filter
#
procedure flt_close(fptr)

pointer	fptr				# i: filter handle

begin
	call qpex_close(FLT_EX(fptr))
	call qp_close(FLT_QP(fptr))
	call qp_delete(FLT_QPNAME(fptr))
	call mfree(FLT_QPN(fptr), TY_CHAR)
	call mfree(fptr, TY_STRUCT)
end

