#$Header: /home/pros/xray/lib/scan/RCS/scopen.x,v 11.0 1997/11/06 16:23:38 prosb Exp $
#$Log: scopen.x,v $
#Revision 11.0  1997/11/06 16:23:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:10:46  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:13  pros
#General Release 1.0
#
#
#
# Module:	scopen.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Open and close a scan list array
# Includes:	sc_open(), sc_close(), sc_repool()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_open
# Purpose:	Allocate a scan list array for a client
# Parameters:	See argument declarations
# Returns:	pointer to scan list array in Memi
# Uses:		malloc
# Called by:	sc_polygon() in scpolygon.x, application programs
# Method:	Malloc and clear the array
# Notes:	
#
pointer procedure sc_open ( height )

int	height		# i: height dimension of scan list image

pointer	scanptr		# o: array of scan lists

begin
	call malloc (scanptr, height, TY_INT)
	call amovki (SCNULL, Memi[scanptr], height)
	return( scanptr )
end

#
# Function:	sc_close
# Purpose:	Close a scan list array and free its space for reuse
# Parameters:	See argument declarations
# Uses:		sc_repool() below
# Called by:	sc_polygon() in scpolygon.x, application programs
# Method:	Free each edge on each line (return to pool), then free the
#		array.
# Notes:	
#
procedure sc_close ( scan, height )

int	height		# i: height dimension of scan list
pointer	scan		# i: array of scan lists

begin
	call sc_repool (Memi[scan], height)
	call mfree (scan, TY_INT)
end

#
# Function:	sc_repool
# Purpose:	Return all the scan records to the pool
# Parameters:	See argument declarations
# Uses:		sc_freeedge()
# Called by:	sc_close() above
# Method:	Free each edge on each line (return to pool)
# Notes:	
#
procedure sc_repool ( scan, height )

int	height		# i: height dimension of scan list
pointer	scan[height]	# i: array of scan lists

pointer edge		# l: pointer to a scan list edge
pointer nxt		# l: pointer to next scan list edge
int	y		# l: line counter

begin
	do y = 1, height {
	    edge = scan[y]
	    while( edge != SCNULL ) {
		nxt = SC_NEXT(edge)
		call sc_freeedge(edge)
		edge = nxt
	    }
	}
end
