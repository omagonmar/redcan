#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcsort.x,v 11.0 1997/11/06 16:22:09 prosb Exp $
#$Log: qpcsort.x,v $
#Revision 11.0  1997/11/06 16:22:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:50  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:18:46  dvs
#Changed position sort to check indices, not default to "y x".
#
#Revision 8.0  94/06/27  14:33:54  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:36  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:24:46  mo
#MC	12/1/93		Update for QPOE bug - qpx_addf
#
#Revision 6.0  93/05/24  15:58:54  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:16:49  mo
#MC	5/20/93		Add support for converting between 2 QPOE formats
#
#Revision 5.0  92/10/29  21:19:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:27  prosb
#General Release 1.1
#
#Revision 2.1  91/04/16  16:23:48  mo
#MC	4/16/91		Add code to make accessing QP-SORT NOT case
#			dependent.  This was causing problems with
#			qpsort, etc concerning MKINDEX.
#
#Revision 2.0  91/03/07  00:11:32  pros
#General Release 1.0
#
#
# Module:       QPCSORT.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Perform the requested QPOE event sorting
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#               {1} mc    -- to replace qp_astr to qp_pstr -- 1/91
#               {n} <who> -- <does what> -- <when>
#
#
# QPC_SORT -- routines that deal with sorting qpoe events
#
include <mach.h>
include <ctype.h>
include <qpoe.h>
include "qpcreate.h"
include <wfits.h>

#
#  QPC_SORTTYPE -- convert input sort string into sorttype string
#
procedure qpc_sorttype(s, qphead)

char	s[ARB]				# io: sort string
pointer qphead				# i: QPHEAD structure
int	abbrev()			# l: look for abbrev

include "qpcreate.com"

begin
	call strlwr(s)
	if( abbrev("none", s) >0 ){
	    call strcpy("none", Memc[sortstr], SZ_LINE)
	    sort = NO
	    nsort = 0
	    return
	}
	if( abbrev("position", s) >0 )
	{
	    call sprintf(Memc[sortstr],SZ_LINE,"%s %s")
	     call pargstr(QP_INDEXY(qphead))
	     call pargstr(QP_INDEXX(qphead))
	}
	else
	    call strcpy(s, Memc[sortstr], SZ_LINE)
end

#
#  QPC_BUILDSORT -- parse the sortstr string and build the compare arrays
#

procedure qpc_buildsort(qp)

pointer	qp					# i: qpoe handle to get macros
extern	s_cmp(), i_cmp(), l_cmp(), r_cmp(), d_cmp(), x_cmp()

include "qpcreate.com"

begin
	# make sure we are sorting
	if( sort == NO )
	    return
	# call the eventdef compiler
	if( otype == QPOE )
	    call ev_qpcompile(qp, Memc[sortstr],
			sortname, sortcmp, sortoff, sorttype, nsort,
			s_cmp, i_cmp, l_cmp, r_cmp, d_cmp, x_cmp)
	if( otype == A3D )
	    call ev_compile(Memc[prosdef_out], Memc[sortstr],
			sortname, sortcmp, sortoff, sorttype, nsort,
			s_cmp, i_cmp, l_cmp, r_cmp, d_cmp, x_cmp)
end

#
#  QPC_DESTROYSORT -- destroy the sort structures
#
procedure qpc_destroysort()

include "qpcreate.com"

begin
	call ev_destroycompile(sortname, sortcmp, sortoff, sorttype, nsort)
end

#
# QPC_OLD_SORT -- if we are not sorting, take the
# outout sort type from the input qpoe file, i.e., maintain old sort type
#
procedure qpc_oldsort(qp)

int	qp				# i: qpoe handle
int	junk				# l: return from qp_gstr
int	qp_accessf()			# l: qpoe param existence
int	qp_gstr()			# l: get string parameter

include "qpcreate.com"

begin
	# make sure we are not sorting (e.g. qpcopy)
	if( sort == YES )
	    return
	# make sure the sort param exists
	if( qp_accessf(qp, "XS-SORT") == NO){
	    if(qp_accessf(qp, "xs-sort") == NO) 
	        return
	    else
		junk = qp_gstr(qp, "xs-sort", Memc[sortstr], SZ_LINE)
	}
	else
	# get information about type of sort and replace the sortstr
	    junk = qp_gstr(qp, "XS-SORT", Memc[sortstr], SZ_LINE)
end

#
# QPC_CMP -- compare 2 QPOE records by position
# this routine calls the user-defined compare function
#
int procedure qpc_cmp(p1, p2)

pointer	p1		# i: qpc record 1
pointer	p2		# i: qpc record 2
int	cmp		# l: return value from compare
int	i		# l: loop counter
int	zfunc3()	# l: call function of 3 args

include "qpcreate.com"

begin
	# for each comparison
	do i=1, nsort{
	    # see if records are equal using this compare
	    cmp = zfunc3(Memi[sortcmp+i-1], p1, p2, Memi[sortoff+i-1])
	    # return the first time we get non-equality
	    if( cmp !=0 )
		return(cmp)
	}
	# records must be exactly the same
	return(0)
end

#
# QPC_SORTPARAM -- add parameter detailing type of sort done on events
#
procedure qpc_sortparam(qp)

int	qp				# i: qpoe handle
int	qp_accessf()			# l: qpoe param existence
include "qpcreate.com"

begin
	# add information about the type of sort
	if( qp_accessf(qp, "XS-SORT") == NO )
	    call qpx_addf(qp, "XS-SORT", "c", SZ_LINE, "type of event sort", 0)
	# overwrite if there is something in the string
	# (we may have a null string which means we want to inherit the
	# old sort param from the input qpoe file!
	if( Memc[sortstr] != EOS )
	    call qp_pstr(qp, "XS-SORT", Memc[sortstr])
end

#
# QPC_A3DSORTPARAM -- add parameter detailing type of sort done on events
#
procedure qpc_a3dsortparam(fd)

int	fd				# i: fits handle
include "qpcreate.com"

begin
	if( Memc[sortstr] != EOS )
	    call fts_putc(fd, "XS-SORT", Memc[sortstr], "type of event sort")
end

int procedure s_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( Mems[p1+offset] < Mems[p2+offset] )
	return(-1)
    else if( Mems[p1+offset] > Mems[p2+offset] )
	return(1)
    else
	return(0)
end

int procedure i_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( Memi[(p1+offset-1)/SZ_INT+1] < Memi[(p2+offset-1)/SZ_INT+1] )
	return(-1)
    else if( Memi[(p1+offset-1)/SZ_INT+1] > Memi[(p2+offset-1)/SZ_INT+1] )
	return(1)
    else
	return(0)
end

int procedure l_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( Meml[(p1+offset-1)/SZ_LONG+1] < Meml[(p2+offset-1)/SZ_LONG+1] )
	return(-1)
    else if( Meml[(p1+offset-1)/SZ_LONG+1] > Meml[(p2+offset-1)/SZ_LONG+1] )
	return(1)
    else
	return(0)
end

int procedure r_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( Memr[(p1+offset-1)/SZ_REAL+1] < Memr[(p2+offset-1)/SZ_REAL+1] )
	return(-1)
    else if( Memr[(p1+offset-1)/SZ_REAL+1] > Memr[(p2+offset-1)/SZ_REAL+1] )
	return(1)
    else
	return(0)
end

int procedure d_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( Memd[(p1+offset-1)/SZ_DOUBLE+1] < Memd[(p2+offset-1)/SZ_DOUBLE+1] )
	return(-1)
    else if(Memd[(p1+offset-1)/SZ_DOUBLE+1] > Memd[(p2+offset-1)/SZ_DOUBLE+1] )
	return(1)
    else
	return(0)
end

int procedure x_cmp(p1, p2, offset)
pointer	p1				# qpc record 1
pointer	p2				# qpc record 2
int	offset				# i: offset into record
begin
    if( real(Memx[(p1+offset-1)/SZ_COMPLEX+1]) < 
	real(Memx[(p2+offset-1)/SZ_COMPLEX+1]) )
	return(-1)
    else if( real(Memx[(p1+offset-1)/SZ_COMPLEX+1]) > 
	     real(Memx[(p2+offset-1)/SZ_COMPLEX+1]) )
	return(1)
    else
	return(0)
end


# Modified:     {0} egm   -- initial version      1988
