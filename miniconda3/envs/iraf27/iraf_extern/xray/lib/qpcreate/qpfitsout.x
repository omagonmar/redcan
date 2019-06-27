# $Header: /home/pros/xray/lib/qpcreate/RCS/qpfitsout.x,v 11.0 1997/11/06 16:21:50 prosb Exp $
# $Log: qpfitsout.x,v $
# Revision 11.0  1997/11/06 16:21:50  prosb
# General Release 2.5
#
# Revision 9.3  1996/08/21 15:31:57  prosb
# *** empty log message ***
#
#MO/JCC - Increase the length of prosdef_out to SZ_TYPEDEF to match 
#         the qpcreate fix for AXAF
#
#Revision 9.2  1996/07/02  20:05:07  prosb
##########################################################################
# JCC - Updated to run fits2qp & qp2fits for AXAF data.
#
# (6/7/96)- events_out()/qpfitsout.x :
#  Increase the length of prosdef_out from 161(SZ_LINE) to 256 (LEN_XSEVENT) 
#  for XS-EVENTS to solve the problem of the table-columns truncated.
#
##########################################################################
#Revision 9.0  1995/11/16  18:29:55  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:16:16  dvs
#Added qphead to ev_strip call.
#Fixed minor bug: sortstr should be zeroed out, otherwise QP2FITS
#produces bogus "XS-SORT" string.
#
#Revision 8.0  94/06/27  14:34:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:47  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:24:00  mo
#MC	12/1/93		Add generic QPOE aux record FITS writer
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
# Function:       events_out
# Purpose:        Write QPOE events out to FITS
# Called by:
# Calls:
#                 qp_gstr
#                 ev_strip
#                 ev_crelist
#                 ev_osize
#                 a3d_initev
#                 qpio_getevets
#                 a3d_flush
#                 a3d_initev
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

include <evmacro.h>      #SZ_TYPEDEF
include <error.h>
include <qpc.h>
include <qpoe.h>
 
#  This now uses same as eventdef - evmacro/SZ_TYPEDEF - mc 8/6/96
#define  LEN_XSEVENT     256           #JCC
define  LEN_XSEVENT     SZ_TYPEDEF     #JCC
define  LEN_EVBUF       1024

procedure events_out(qp, io, fits_fp, qphead, display)

pointer qp			# i: qp file pointer
pointer io                      # i: qp events pointer
pointer fits_fp                 # i: FITS file pointer
pointer qphead                  # i: qp header pointer
int     display                 # l: display level

int     nev                     # l: num events returned by qpio_getevents
int     mval                    # l: mask val returned by qpio_getevents
int     total                   # l: total number of photons
int     qpio_getevents()        # l: get qpio events
int     qp_gstr()		# l: qp get string function
long    pos                     # l: seek position holder
long    note()                  # l: function to save file position
pointer argv                    # l: argument list pointer
pointer evl[LEN_EVBUF]          # l: event list buffer
pointer sp                      # l: stack pointer

include "qpcreate.com"

begin
        call smark(sp)
        call salloc(prosdef_out, LEN_XSEVENT, TY_CHAR)
        call salloc(irafdef_out, LEN_XSEVENT, TY_CHAR)
#---------------------------------------------------------------------
# The variable "sortstr" is defined in the common block and is used in
# the library function "qpc_sortparam()" which is called by
# "a3d_initev()"
#---------------------------------------------------------------------
        call salloc(sortstr, LEN_XSEVENT, TY_CHAR)
	Memc[sortstr]=0  # zero out string.

#-----------------------------------------------
# Get the QPOE event string from the QPOE header
#-----------------------------------------------
        if (qp_gstr(qp, "XS-EVENT", Memc[prosdef_out], LEN_XSEVENT) <= 0)
	{
	   call error(EA_FATAL, "No event definition found in QPOE file")
	}

#-------------------------------------------------------
# Strip the QPOE event string from the PROS event string
#-------------------------------------------------------
	call ev_strip(Memc[prosdef_out], Memc[irafdef_out], LEN_XSEVENT, qphead)

#-------------------------------------------------------------------
# Split the PROS event definition into the symbols and values arrays
#-------------------------------------------------------------------
        call ev_crelist(Memc[prosdef_out], msymbols, mvalues, nmacros)

#-------------------------
# Calculate the event size
#-------------------------
        call ev_osize(Memc[irafdef_out], oevsize)
        oevsize = oevsize/SZ_SHORT

#----------------------------------------------------------------------
# Save the position of the file pointer.  Since we don't know the total
# number of photons until they are read in, pass in a zero for now
# replace it after total is determined
#----------------------------------------------------------------------
        pos = note(fits_fp)
        call a3d_initev(fits_fp, qphead, display, argv, 0)

#--------------------------------------------------------------
# Get the qp events into the buffer "evl" and put it out to the
# FITS file
#--------------------------------------------------------------
        total = 0
        while (qpio_getevents(io, evl, mval, LEN_EVBUF, nev) != EOF)
        {
           call a3d_putev(fits_fp, evl, nev)
           total = total + nev
        }

        call a3d_flush(fits_fp)

#----------------------------------------------------------------------
# Seek back to the header and replace the value of the  total number of
# photons with the actual number read with qpio_getevents
#----------------------------------------------------------------------
        call seek(fits_fp, pos)
        call a3d_initev(fits_fp, qphead, display, argv, total)

#------------------------------------------
# Release the space allocated in ev_crelist
#------------------------------------------
        call ev_destroylist(msymbols, mvalues, nmacros)

        call sfree(sp)
end



#------------------------------------------------------------------
#
# Function:       gti_out
# Purpose:        Write GTI records to a FITS file
# Called by:
# Calls:
#                 gti_put
# Pre-cond:       QPOE and FITS files are open
# Post-cond:
# Method:
# Description:    Get the pointer to GTI records and write
#   out to FITS
# Notes:
#
#------------------------------------------------------------------
procedure gti_out(qp, fits_fp, qphead, display)

pointer qp                      # i: qp file pointer
pointer fits_fp                 # i: FITS file pointer
pointer qphead                  # i: qp header pointer
int     display                 # i: display level

int     gti_nrec                # l: number of GTI records
pointer gti_ptr                 # l: pointer to GTI data
pointer argv                    # l: argument list pointer
pointer	blist,elist		# l: pointers to beg,end arrays
double	duration		# l: duration of intervals

include "qpcreate.com"

begin

#-------------------------------------------------------------
# Set the the output type.  The variable "otype" is
# defined in the common block and used in the library function
# "gti_put"
#-------------------------------------------------------------
        otype = A3D

#-----------------------------------------------------
# Get pointer to GTI records and number of GTI records
#-----------------------------------------------------
	call get_goodtimes(qp,"",display,blist,elist,gti_nrec,duration)
	call reformat_gti(blist,elist,gti_nrec,gti_ptr)

#-----------------------------------------
# Put out the GTI records to the FITS file
#-----------------------------------------
        call gti_put(fits_fp, gti_ptr, gti_nrec, qphead, display, argv)

#--------------------------------------------------------------
# Free the memory allocated in the library function "get_qpgti"
#--------------------------------------------------------------
        call mfree(gti_ptr, TY_STRUCT)
	call mfree(blist,TY_DOUBLE)
	call mfree(elist,TY_DOUBLE)
end


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

int     total                   # l: total number of photons
long    pos                     # l: seek position holder
long    note()                  # l: function to save file position
pointer argv                    # l: argument list pointer
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
	call get_gtsi(qp, extname, prosdef_out, ptr, cnt, rsize, extrec, 
			descp, nrecs)

#-------------------------------------------------------
# Strip the QPOE event string from the PROS event string
#-------------------------------------------------------
        call ev_strip(Memc[prosdef_out], Memc[irafdef_out], LEN_EVBUF,
			qphead)

#-------------------------------------------------------
# For Writing the FITS records, we need the UNPADDED size
#-------------------------------------------------------
	call ev_osize(Memc[irafdef_out],oevsize)

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
	ip = extrec
	rsize = rsize / SZ_INT
	do ii=1,nrecs
        {
           call a3d_putext(fits_fp, ip, 1)
           total = total + 1 
	   ip = ip + rsize
        }

        pos = note(fits_fp)
        call a3d_flush(fits_fp)
        pos = note(fits_fp)

#------------------------------------------
# Release the space allocated in ev_crelist
#------------------------------------------
        call ev_destroylist(msymbols, mvalues, nmacros)
	call free_descriptor(ptr,cnt)
	call mfree(extrec,TY_STRUCT)
        call sfree(sp)
end
