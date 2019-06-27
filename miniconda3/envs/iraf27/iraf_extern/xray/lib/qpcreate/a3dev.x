#$Header: /home/pros/xray/lib/qpcreate/RCS/a3dev.x,v 11.0 1997/11/06 16:21:25 prosb Exp $
#$Log: a3dev.x,v $
#Revision 11.0  1997/11/06 16:21:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:55  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:10:00  dvs
#Uses QP_INDEXX & QP_INDEXY instead of "x", "y" for event indices.
#We should call miistruct if we aren't using IEEE or if the event
#size has changed (due to unpacking or changing type sizes)
#
#Revision 8.0  94/06/27  14:32:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:38  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:27:08  mo
#MC	12/1/93		Update WCS for FITS output to determine x,y
#			column number for WCS output FITS
#
#Revision 6.0  93/05/24  15:55:20  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:23:07  mo
#MC/JM	5/20/93		Add support for converting 2 different QPOE formats
#
#Revision 5.0  92/10/29  21:18:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:19  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:08  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:18  pros
#General Release 1.0
#
#
# Module:       A3DEV.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to put EVENTS in A3D FITS files
# External:     a3d_initev, a3d_qpev, a3d_putev
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   --  initial version 		-- 1989
#               {1} mc    --  Made a3d_qpev not dependent on common so
#		              it can be used to write out more the just
#			      the main event definitions
#							-- 1/91
#               {n} <who> -- <does what> -- <when>
#
#
#	A3DEV.X -- routines to deal with putting events into A3D FITS
#

include <mach.h>
include <wfits.h>
include <qpoe.h>
include "qpcreate.h"

#
#  A3D_INITEV -- write A3D header for event table to FITS file
#
procedure a3d_initev(fd, qphead, display, argv, nev)

int	fd				# i: file descriptor
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	nev				# i: number of events
int	bytes				# l: bytes in one column
int	index1,index2
int	ev_lookuplist()
char	type[2]
int	offset
# this is shared with a3d_putev
int	a3devflag			# l: flag we init'ed a3d_putev
common/a3dwrcom/a3devflag

include "qpcreate.com"

begin
	# write the standard part of the table header
	bytes = oevsize*SZB_CHAR
	call a3d_table_header(fd, "EVENTS", bytes, nev, nmacros, 1)
	# handle unknown event types separately
	call a3d_qpev(fd,msymbols,mvalues,nmacros)
	# add parameters for qpoe axis len
	call fts_puti(fd, "NAXLEN", 2, "Number of QPOE axes")
	call fts_puti(fd, "AXLEN1", QP_XDIM(qphead), "Dim. of qpoe axis 1")
	call fts_puti(fd, "AXLEN2", QP_YDIM(qphead), "Dim. of qpoe axis 2")
	# write the qpoe header to the FITS file
	call put_a3dhead(fd, qphead)
        index1 = ev_lookuplist(QP_INDEXX(qphead),
				 msymbols, mvalues, nmacros, type, offset)
        index2 = ev_lookuplist(QP_INDEXY(qphead),
				 msymbols, mvalues, nmacros, type, offset)
        call put_wcs(fd,qphead,"T",index1,index2)
	call qpc_a3dsortparam(fd)
	# end the table
	call a3d_table_end(fd)
	# re-init the a3dwrcom flag
	a3devflag = NO
end

#
#  A3D_QPEV -- write table header for a PROS event def
#
procedure a3d_qpev(fd,msymbols,mvalues,nmacros)

int	fd				# i: FITS handle
pointer	msymbols			# i: 
pointer	mvalues				# i:
int	nmacros				# i:
int	i				# l: loop counter
char	name[SZ_FNAME]			# l: name of variable
char	type[SZ_FNAME]			# l: type of variable

#include "qpcreate.com"

begin
	do i=1, nmacros{	
	    # get the name of this data element
	    call strcpy(Memc[Memi[msymbols+i-1]], name, SZ_FNAME)
	    # seed the type string
	    call strcpy("1?", type, SZ_FNAME)
	    switch(Memc[Memi[mvalues+i-1]]){
	    case 's':
		type[2] = 'I'
	    case 'i':
		type[2] = 'J'
	    case 'l':
		type[2] = 'J'
	    case 'r':
		type[2] = 'E'
	    case 'd':
		type[2] = 'D'
	    case 'x':
		type[1] = '2'
		type[2] = 'E'
	    default:
		call error(1, "unknown macro data type")
	    }
	    # make the name upper case
	    call strupr(name)
	    # write it to the FITS file table header (no units, though ...)
	    call a3d_table_entry(fd, type, name, "")
	}
end

#
#  A3D_PUTEV -- write events to an A3D FITS file
#
procedure a3d_putev(fd, ebuf, nrecs)

int	fd				# i: FITS handle
int	ebuf[ARB]			# i: array of pointers to events
int	nrecs				# i: number of events to write
int	i				# l: loop counter

# this is shared with a3d_initev
int	a3devflag			# l: flag we init'ed a3d_putev
common/a3dwrcom/a3devflag

int	a3dsize				# l: size of typedef for a3d
int	qpsize				# l: size of typedef for qpoe
bool	is_changing			# l: TRUE if data must change size.
include "qpcreate.com"

begin
	call ev_size(Memc[irafdef_out],qpsize)
	call ev_osize(Memc[irafdef_out],a3dsize)

	# the data must be packed if IEEE_USED is false and it must be
	#   unpadded if the a3d and qpoe sizes differ.
	is_changing = ((IEEE_USED==NO) || (a3dsize!=qpsize))

	# put each event pointed to in ebuf
	do i = 1, nrecs
	{
	    if (is_changing)
	    {
	      call miistruct(Mems[ebuf[i]], Mems[ebuf[i]], 1, Memc[irafdef_out])
	    }
	    call a3d_write(fd, Mems[ebuf[i]], oevsize*SZ_SHORT)	
	}	
end

