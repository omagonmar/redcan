#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcaddaux.x,v 11.0 1997/11/06 16:21:53 prosb Exp $
#$Log: qpcaddaux.x,v $
#Revision 11.0  1997/11/06 16:21:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:19  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:57:58  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:18:47  mo
#MC	5/20/93		Add support for EInstein TGR->TSI converstion
#			(convtgr) option
#
#Revision 5.0  92/10/29  21:18:29  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:13  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:37  pros
#General Release 1.0
#
#
# Module:       QPCADDAUX
# Project:      PROS -- ROSAT RSDC
# Purpose:      Add auxilliary data to a QPOE file
# External:     qpcaddaux
# Local:        qpc_delf
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- initial version 			    -- 1988
#               {1} mc    -- Support for temporal status intervals  -- 1/91
#               {n} <who> -- <does what> -- <when>
#
#
# QPCADDAUX.X -- add auxiliary data to a qpoe file
#

include <qpoe.h>
include "qpcreate.h"

procedure qpcaddaux()

char	qpname[SZ_PATHNAME]			# qpoe file name
char	auxname[SZ_PATHNAME]			# aux file name
char	auxtype[SZ_FNAME]			# aux file type
pointer qp					# qpoe handle
pointer	qphead					# qpoe header
pointer	qpaux					# aux pointer
pointer	argv					# dummy arg pointer
pointer	buf					# temp char buffer
pointer	sp					# stack pointer
int	fd					# aux file pointer
int	display					# display level
int	convert					# data conversion flag
int	naux					# number of aux records
int	index					# index into string
int	ii
int	abbrev()				# look for abbreviated match
int	clgeti()				# get int param
int	stridx()				# index into string
pointer	qptsi
pointer	iptr
pointer optr
pointer	qp_open()				# open a pqoe file

include "qpcreate.com"

begin
	# mark the stack
	call smark(sp)
	# get qpoe file name
	call clgstr("qpoe", qpname, SZ_PATHNAME)
	# get aux file name
	call clgstr("aux", auxname, SZ_PATHNAME)
	# get aux file type
	call clgstr("type", auxtype, SZ_FNAME)
	# get display level
	display = clgeti("display")
	# get data conversion
	convert = clgeti("datarep")

	# open the qpoe file for writing
	qp = qp_open(qpname, READ_WRITE, NULL)
	# get the qpoe header
	call get_qphead(qp, qphead)

	# work-around for qpoe bug in which we can't read and then write
	# to a qpoe file:
	call qp_close(qp)
	qp = qp_open(qpname, READ_WRITE, NULL)

	# make it look loke we are dealing with a QPOE-style qpcreate
	# some of the xxx_put routines need to know the otype
	otype = QPOE

	# add the aux extension, if necessary
	index = stridx(".", auxname)
	if( index ==0 ){
	    call strcat(".", auxname, SZ_PATHNAME)
	    call strcat(auxtype, auxname, SZ_PATHNAME)
	}

	# convert auxtype to lower case
	call strlwr(auxtype)
	# look up the aux file
	if( abbrev("blt", auxtype) >0 ){
	    call qpc_delf(qp, auxtype)
	    call blt_open(auxname, fd, convert, qphead, display, argv)
	    call blt_get(fd, convert, qpaux, naux, qphead, display, argv)
	    call blt_put(qp, qpaux, naux, qphead, display, argv)
	    call blt_close(fd, qphead, display, argv)
	}
	else if( abbrev("tgr", auxtype) >0 ){
	    call qpc_delf(qp, auxtype)
	    call tgr_open(auxname, fd, convert, qphead, display, argv)
	    call tgr_get(fd, convert, qpaux, naux, qphead, display, argv)
	    call tgr_put(qp, qpaux, naux, qphead, display, argv)
#	    call tgr_close(fd, qphead, display, argv)
#	    call tgr_open(auxname, fd, convert, qphead, display, argv)
#	    call tgrtsi_get(fd, convert, qpaux, naux, qphead, display, argv)
#	    call tsi_put(qp, qpaux, naux, qphead, display, argv)
	    call tgr_close(fd, qphead, display, argv)
	}
	else if( abbrev("convtgr", auxtype) >0 ){
	    call qpc_delf(qp, "tsi")
	    call get_qptgr(qp, qpaux, naux)
	    if( naux > 0 ){
	    call calloc(qptsi,naux*SZ_EQPTSI,TY_STRUCT)
	    do ii=1,naux
	    {
		iptr = qpaux+(ii-1)*SZ_QPTGR
		optr = qptsi+(ii-1)*SZ_EQPTSI
		call tgr2tsi(iptr,optr,qphead)
	    }
	    call tsi_put(qp, qptsi, naux, qphead, display, argv)
	    call mfree(qptsi,TY_STRUCT)
	    }
#	    call tgr_get(fd, convert, qpaux, naux, qphead, display, argv)
#	    call tgr_put(qp, qpaux, naux, qphead, display, argv)
#	    call tgr_close(fd, qphead, display, argv)
#	    call tgr_open(auxname, fd, convert, qphead, display, argv)
#	    call tgrtsi_get(fd, convert, qpaux, naux, qphead, display, argv)
#	    call tgr_close(fd, qphead, display, argv)
	}
	else if( abbrev("tsh", auxtype) >0 ){
	    call qpc_delf(qp, auxtype)
	    call tsh_open(auxname, fd, convert, qphead, display, argv)
	    call tsh_get(fd, convert, qpaux, naux, qphead, display, argv)
	    call tsh_put(qp, qpaux, naux, qphead, display, argv)
	    call tsh_close(fd, qphead, display, argv)
	}
	else if( abbrev("gti", auxtype) >0 ){
	    call qpc_delf(qp, auxtype)
	    call gti_open(auxname, fd, convert, qphead, display, argv)
	    call gti_get(fd, convert, qpaux, naux, qphead, display, argv)
	    call gti_put(qp, qpaux, naux, qphead, display, argv)
	    call gti_close(fd, qphead, display, argv)
	}
	else if( abbrev("tsi", auxtype) >0 ){
	    call qpc_delf(qp, auxtype)
	    call tsi_open(auxname, fd, convert, qphead, display, argv)
	    call tsi_get(fd, convert, qpaux, naux, qphead, display, argv)
	    call tsi_put(qp, qpaux, naux, qphead, display, argv)
	    call tsi_close(fd, qphead, display, argv)
	}
	else{
	    call printf("\nError: unknown aux file type: %s\n")
	    call pargstr(auxtype)
	    goto 99
	}
	# record what we did for posterity
	call salloc(buf, SZ_LINE, TY_CHAR)
	call sprintf(Memc[buf], SZ_LINE, "aux=%s, type=%s -> %s")
	call pargstr(auxname)
	call pargstr(auxtype)
	call pargstr(qpname)
	call put_qphistory(qp, "qpaddaux", Memc[buf], "")
	if( display >0 ){
	    call printf("\n%s\n")
	    call pargstr(Memc[buf])
	}

	# free up space
99	call mfree(qpaux, TY_STRUCT)
	call mfree(qphead, TY_STRUCT)
	call sfree(sp)
	# close the qpoe file
	call qp_close(qp)
end

#
#  QPC_DELF -- delete parameters associated with aux data
#
procedure qpc_delf(qp, auxtype)

pointer	qp				# i: qpoe handle
char	auxtype[ARB]			# i: aux file type
char	tbuf[SZ_LINE]			# i: temp char buffer
int	qp_accessf()			# l: param access

begin
	# delete the count
	call sprintf(tbuf, SZ_LINE, "n%s")
	call pargstr(auxtype)
	call strupr(tbuf)
	if( qp_accessf(qp, tbuf) == YES )
	    call qp_deletef(qp, tbuf)	
	# delete the record definition
	call sprintf(tbuf, SZ_LINE, "%srec")
	call pargstr(auxtype)
	call strupr(tbuf)
	if( qp_accessf(qp, tbuf) == YES )
	    call qp_deletef(qp, tbuf)	
	# delete the records
	call sprintf(tbuf, SZ_LINE, "%s")
	call pargstr(auxtype)
	call strupr(tbuf)
	if( qp_accessf(qp, tbuf) == YES )
	    call qp_deletef(qp, tbuf)	
end
