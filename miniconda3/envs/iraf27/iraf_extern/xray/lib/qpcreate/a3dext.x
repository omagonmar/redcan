#$Header: /home/pros/xray/lib/qpcreate/RCS/a3dext.x,v 11.0 1997/11/06 16:21:25 prosb Exp $
#$Log: a3dext.x,v $
#Revision 11.0  1997/11/06 16:21:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:56  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:04:30  dvs
#Call miistruct instead of miiauxstruct.  We should call this whether
#or not we are in IEEE mode, since we may need to pack structure if
#columns are not aligned in an optimal fashion.
#
#Revision 8.0  94/06/27  14:32:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:40  prosb
#General Release 2.3
#
#Revision 1.1  93/12/16  09:28:25  mo
#Initial revision
#
# Module:       A3DEXT.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to put QPOE extensions in A3D FITS files
# External:     a3d_initext, a3d_qpev, a3d_putext
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   --  initial version 		-- 1989
#               {1} mc    --  Made a3d_qpev not dependent on common so
#		              it can be used to write out more the just
#			      the main event definitions
#							-- 1/91
#               {n} <who> -- <does what> -- <when>
#
#
#	A3DEXT.X -- routines to deal with putting events into A3D FITS
#

include <mach.h>
include <wfits.h>
include <qpoe.h>
include "qpcreate.h"

#
#  A3D_INITEXT -- write A3D header for event table to FITS file
#
procedure a3d_extinit(fd, extname, display, argv, nev)

int	fd				# i: file descriptor
char	extname				# i: extension record name
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	nev				# i: number of events
int	bytes				# l: bytes in one column

include "qpcreate.com"

begin
	# write the standard part of the table header
	bytes = oevsize*SZB_CHAR
	call a3d_table_header(fd, extname, bytes, nev, nmacros, 1)

	# handle unknown event types separately

	call a3d_qpext(fd,msymbols,mvalues,nmacros)

	# end the table
	call a3d_table_end(fd)

end

#
#  A3D_QPEXT -- write table header for a PROS qpoe extension def
#
procedure a3d_qpext(fd,msymbols,mvalues,nmacros)

int	fd				# i: FITS handle
pointer	msymbols			# i: 
pointer	mvalues				# i:
int	nmacros				# i:
int	i				# l: loop counter
char	name[SZ_FNAME]			# l: name of variable
char	type[SZ_FNAME]			# l: type of variable


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
#  A3D_PUTEXT -- write extension records to an A3D FITS file
#
procedure a3d_putext(fd, ebuf, nrecs)

int	fd				# i: FITS handle
int	ebuf[ARB]			# i: array of pointers to events
int	nrecs				# i: number of events to write
int	i				# l: loop counter

# this is shared with a3d_initev
#int	a3devflag			# l: flag we init'ed a3d_putev
#common/a3dextwrcom/a3devflag

include "qpcreate.com"

begin
	# put each event pointed to in ebuf
	do i = 1, nrecs
	{
	    call miistruct(Memi[ebuf[i]], Memi[ebuf[i]], 1, 
				Memc[irafdef_out])
	    call a3d_write(fd, Memi[ebuf[i]], oevsize*SZ_SHORT)	
	}	
end

