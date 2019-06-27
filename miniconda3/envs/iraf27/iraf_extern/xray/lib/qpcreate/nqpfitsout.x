# $Header: /home/pros/xray/lib/qpcreate/RCS/nqpfitsout.x,v 11.0 1997/11/06 16:21:46 prosb Exp $
# $Log: nqpfitsout.x,v $
# Revision 11.0  1997/11/06 16:21:46  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:29:11  prosb
# General Release 2.4
#
#Revision 7.0  1993/12/27  18:16:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:05  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:16:08  mo
#MC/JM	5/20/93		Add support for converting between different
#				QPOE formats
#
#Revision 5.0  92/10/29  21:19:21  prosb
#General Release 2.1
#
#Revision 4.1  92/10/16  20:22:24  mo
#MC	10/16/92	Updated for DEFFILT from GTI
#
#Revision 4.0  92/04/27  13:53:10  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/02/03  14:19:12  mo
#Initial revision
#
#
#------------------------------------------------------------------
#
# Function:       ext_out
# Purpose:        Write QPOE events out to FITS
# Called by:
# Calls:
#                 qp_gstr
#                 ev_strip
#                 ev_crelist
#                 a3d_initext
#                 get_gtsi
#                 a3d_flush
#                 a3d_initext
#                 ev_destroylist
#
# Pre-cond:       QPOE file is open
#                 FITS file is open
#                 QPOE io events pointer is assigned
#                 QPOE header pointer is assigned
# Post-cond:
# Method:
# Description:    Get the QPOE events and write them out to
#   the FITS file
# Notes:
#
#------------------------------------------------------------------

include <error.h>
include <qpc.h>
include <qpoe.h>
 
define  LEN_EVBUF       1024


#------------------------------------------------------------------
#
# Function:       ext_out
# Purpose:        Write QPOE extension  records to a FITS file
# Called by:
# Calls:
# Pre-cond:       QPOE and FITS files are open
# Post-cond:
# Method:
# Description:    Get the pointer to EXT records and write
#   out to FITS
# Notes:
#
#------------------------------------------------------------------
procedure ext_out(qp, extname, fits_fp, qphead, display)

pointer qp			# i: qp file pointer
char	extname			# i: extension record header name
pointer fits_fp                 # i: FITS file pointer
pointer qphead                  # i: qp header pointer
int     display                 # i: display level

#int     nev                     # l: num events returned by qpio_getevents
#int     mval                    # l: mask val returned by qpio_getevents
int     total                   # l: total number of photons
#int     qpio_getevents()        # l: get qpio events
#int     qp_gstr()		# l: qp get string function
long    pos                     # l: seek position holder
long    note()                  # l: function to save file position
pointer argv                    # l: argument list pointer
#pointer evl[LEN_EVBUF]          # l: event list buffer
pointer sp                      # l: stack pointer

pointer	ptr
int	cnt
pointer	extrec
pointer	descp
int	nrecs
int	rsize
pointer	ip
int	ii
include "qpcreate.com"

begin
        call smark(sp)
        call salloc(prosdef_out, LEN_EVBUF, TY_CHAR)
        call salloc(irafdef_out, LEN_EVBUF, TY_CHAR)

#-----------------------------------------------
# Get the QPOE extension event string from the QPOE header
#-----------------------------------------------
	call get_gtsi(qp, extname, prosdef_out, ptr, cnt, oevsize, extrec, 
			descp, nrecs)

#-------------------------------------------------------
# Strip the QPOE event string from the PROS event string
#-------------------------------------------------------
        call ev_strip(Memc[prosdef_out], Memc[irafdef_out], LEN_EVBUF)

#-------------------------------------------------------------------
# Split the PROS event definition into the symbols and values arrays
#-------------------------------------------------------------------
        call ev_crelist(Memc[prosdef_out], msymbols, mvalues, nmacros)

        oevsize = oevsize*SZ_SHORT

        pos = note(fits_fp)
        call a3d_extinit(fits_fp, extname, display, argv, nrecs)

#--------------------------------------------------------------
# Get the qp events into the buffer "evl" and put it out to the
# FITS file
#--------------------------------------------------------------
        total = 0
#        while (qpio_getevents(io, evl, mval, LEN_EVBUF, nrecs) != EOF)
	ip = extrec
	rsize = oevsize / SZ_INT
	do ii=1,nrecs
        {
           call a3d_putext(fits_fp, ip, 1)
           total = total + 1 
	   ip = ip + rsize
        }

        pos = note(fits_fp)
        call a3d_flush(fits_fp)
        pos = note(fits_fp)

#----------------------------------------------------------------------
# Seek back to the header and replace the value of the  total number of
# photons with the actual number read with qpio_getevents
#----------------------------------------------------------------------
#        call seek(fits_fp, pos)
#        call a3d_extinit(fits_fp, extname, display, argv, total)

#------------------------------------------
# Release the space allocated in ev_crelist
#------------------------------------------
        call ev_destroylist(msymbols, mvalues, nmacros)
	call free_descriptor(ptr,cnt)
	call mfree(extrec,TY_STRUCT)
        call sfree(sp)
end
