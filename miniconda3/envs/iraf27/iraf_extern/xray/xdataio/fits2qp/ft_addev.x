#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_addev.x,v 11.0 1997/11/06 16:34:34 prosb Exp $
#$Log: ft_addev.x,v $
#Revision 11.0  1997/11/06 16:34:34  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:57  prosb
#General Release 2.4
#
#Revision 8.2  1994/09/16  16:37:51  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.1  94/06/30  16:52:50  mo
#MC	6/30/94		Remove unused variable
#
#Revision 8.0  94/06/27  15:20:41  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:16:15  mo
#MC	2/25/94		Fix bad calling sequence in qp_savewcs and
#			remove memory freeing - put in MAIN task
#
#Revision 7.0  93/12/27  18:40:09  prosb
#General Release 2.3
#
#Revision 6.2  93/12/14  18:14:12  mo
#MC	12/13/93		Add support for 'boolean' datatype, and
#				therefore can no longer 'mii' in-place
#
#Revision 6.1  93/09/13  11:06:17  mo
#JMORAN/MC	6/1/93		Update for RDF/WCS update
#
#Revision 5.0  92/10/29  21:37:02  prosb
#General Release 2.1
#
#Revision 1.4  92/10/16  19:21:01  mo
#no changes
#
#Revision 1.3  92/10/01  15:11:00  jmoran
#JMORAN comments
#
#Revision 1.2  92/09/23  11:32:22  jmoran
#JMORAN - MPE ASCII FITS changes
#
#Revision 1.1  92/07/13  14:09:18  jmoran
#Initial revision
#
#
# Module:	ft_addev.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <mach.h>
include <evmacro.h>
include <fset.h>
include <rosat.h>
include "ftwcs.h"
include "fits2qp.h"
include "mpefits.h"
include "cards.h"
#
#  FT_ADDEV -- add event data to qpoe file
#
procedure ft_addev(fd, qp, mpe_ptr, mpe_table, mpe_instr, scale)

pointer	fd			# i: FITS handle
pointer	qp			# i: QPOE file handle
pointer	mpe_ptr
bool	mpe_table
int	mpe_instr
bool	scale			# i: applying TZERO/TSCAL scaling?

int	axlen[2]		# l: axlen information
int	io			# l: qpio handle
int	left			# l: events left to read
int	get			# l: events to get this time
int	i			# l: loop counter
int	got			# l: SPP chars read in event read
pointer	ptype			# l: uncorrected type string (for bytes)
pointer	sindex			# l: inded for events
pointer	binary_buf		# l: binary buffer for input packed events
pointer	obinary_buf		# l: binary buffer for unpacked events
pointer	sp			# l: stack pointer
int	qp_accessf()		# l: existence of a qpoe apram
int	qpio_open()		# l: open a qpio event list
int	read()			# l: read data file
int	evchars			# l: length of output event in SZB_CHAR
int	binary_bytes
int	ascii_bytes

pointer	imwcs, ft_mwcs()
int	sz_typedef()

include "fits2qp.com"

begin

	# mark the stack
	call smark(sp)
	call salloc(ptype,SZ_TYPEDEF,TY_CHAR)

	# make sure we have axis information
	if( naxlen == 0 )
	{
	    call printf("warning: no qpoe 'naxlen' param - assuming %d")
	    call pargi(DEFAULT_AXLEN)
	    naxlen = DEFAULT_AXLEN
	}
	else if( naxlen != DEFAULT_AXLEN )
	    call errori(1, "illegal value for naxlen", naxlen)
	
	if( axlen1 ==0 )
	    call error(1, "no axlen1 value for qpoe event dimension")
	if( axlen2 ==0 )
	    call error(1, "no axlen2 value for qpoe event dimension")

	imwcs = ft_mwcs(fitwcs)
	call qp_savewcs(qp, imwcs, 2) 
	call mfree(imwcs, TY_STRUCT)
	
	# write the axis information to the qpoe file
	axlen[1]  = axlen1
	axlen[2]  = axlen2
	call qpx_addf (qp, "naxes", "i", 1, "number of qpoe axes", 0)
	call qp_puti (qp, "naxes", naxlen)
	call qpx_addf (qp, "axlen", "i", 2, "length of each axis", 0)
	call qp_write (qp, "axlen", axlen, 2, 1, "i")


	if( qp_accessf(qp, "event") == YES )
	    call error(1, "qpoe event definition already in qpoe file???")
	call qpx_addf (qp, "event", evotype, 1, "event record type", 0)

	# Open the event list - the "events" list defaults to "event" type
	io = qpio_open (qp, "events", NEW_FILE)

#--------------------------------------------------------
# Assign event sizes, if it is an MPE ASCII table and the
# instrument is HRI, then a place holder size is added 
# to accomodate PHA and PI columns that aren't in the 
# MPE FITS file	
#---------------------------------------------------------
	if (mpe_table)
	{
	   if (mpe_instr == ROSAT_HRI)
	   {
	      binary_bytes = SUM(mpe_ptr) + HRI_PLACEHOLDER
	   }
	   else
	   {
	      binary_bytes = SUM(mpe_ptr) 
	   }
	   ascii_bytes = evbytes
	   evchars = binary_bytes/SZB_CHAR
	}
	else
	{
	   binary_bytes = evbytes
	   evchars = sz_typedef(evotype)
	}
	  
#-----------------------------------
# Allocate space for the event index
#-----------------------------------
	call salloc(sindex, MAX_GET, TY_INT)
	call salloc(binary_buf, MAX_GET*binary_bytes/SZB_CHAR, TY_SHORT)
	call salloc(obinary_buf, 4*MAX_GET*binary_bytes/SZB_CHAR, TY_SHORT)

#---------------------------
# Initialize the event index
#---------------------------
	for(i=0; i<MAX_GET; i=i+1)
	{
	    Memi[sindex+i] = obinary_buf + (i*evchars/SZ_SHORT)
	}

#-------------------------------
# Jump to where the events start
#-------------------------------
	call seek(fd, evfptr)

	if (mpe_table)
	{
	   call mpe_write_events(fd, qp, io, mpe_ptr, sindex, obinary_buf,
                                 ascii_bytes, evnrecs, tfields, mpe_instr)
	} 
	else
	{
	   # read FITS and write QPOE events
	   left = evnrecs
	   while( left >0 )
	   {
	      # determine how many to read this time
	      get = min(MAX_GET, left)

	      # try to read 'em
	      got = read(fd, Mems[binary_buf], get*binary_bytes/SZB_CHAR)

	      if (got != get*binary_bytes/SZB_CHAR)
	      {
		 call error(1, "unexpected EOF reading event data")
	      }

	      #-----------------------
	      # Unpack events from mii 
              #-----------------------
	      call mii_scale_unpack(binary_buf, obinary_buf,
				get,evitype,evext, scale)

	      #------------------------------
	      # Write events to the QPOE file
	      #------------------------------
	      call qpio_putevents (io, Memi[sindex], get)
	      left = left - get

	   } # while loop
	} # else statement

#-------------------------
# Make index, if necessary
#-------------------------
	if (mkindex)
	{
	    call qpio_mkindex(io, key)
	}

#---------------------
# Close the event list
#---------------------
	call qpio_close(io)

	call sfree(sp)

end

