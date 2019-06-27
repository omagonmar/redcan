#$Header: /home/pros/xray/lib/scan/RCS/scpool.x,v 11.0 1997/11/06 16:23:44 prosb Exp $
#$Log: scpool.x,v $
#Revision 11.0  1997/11/06 16:23:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:56  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:10  prosb
#General Release 2.3
#
#Revision 6.1  93/06/15  15:35:17  dennis
#Removed pointer type declaration of procedures sc_freeedge() & sc_fillpool()
#
#Revision 6.0  93/05/24  16:02:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:10  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:11:54  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:27  pros
#General Release 1.0
#
#
#
# Module:	scpool.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	manage and distribute memory space for scan edge records
# Functions:	sc_getedge(), sc_freeedge(), sc_newedge()
# Functions:	sc_fillpool(), sc_freepool()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 You may do anything you like with this file except
#		remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

# number of records to malloc at a time
define SCBLOCK	1000

#
# Function:	sc_getedge
# Purpose:	get a scan record from the pool or newly malloc'd
# Returns:	pointer to scan record
# Uses:		sc_fillpool() below
# Called by:	sc_newedge() below
# Method:	< optional >
# Notes:	
#
pointer procedure sc_getedge ( )

pointer newrec		# l: new scan record to be returned
int	init		# l: compile time flag for onetime initialization
pointer sc_pool		# l: place to park unused scan records
pointer sc_blocks	# l: link list identifying malloc'd blocks
data	init/0/
common /sccom/ sc_pool, sc_blocks

begin
	# check for one-time init to initialize pool pointers and space
	if( init == 0 ) {
	    sc_pool = SCNULL
	    sc_blocks = SCNULL
	    call sc_fillpool()
	    init = 1
	}
	# if scan record available from pool, take it, else allocate one
	if( sc_pool == SCNULL  )
	    call sc_fillpool()
	newrec = sc_pool
	sc_pool = SC_NEXT(sc_pool)
	SC_NEXT(newrec) = SCNULL
	return (newrec)
end

#
# Function:	sc_freeedge
# Purpose:	free a scan record by putting it on the pool
# Parameters:	See argument declarations
# Returns:	Pointer to scan record
# Called by:	sc_merge() in scmerge.x
# Exceptions:	none
# Method:	< optional >
# Notes:	
#
procedure sc_freeedge ( oldrec )

pointer oldrec		# i: scan record to be returned to pool space

pointer sc_pool		# l: place to park unused scan records
pointer sc_blocks	# l: link list identifying malloc'd blocks
common /sccom/ sc_pool, sc_blocks

begin
	SC_NEXT(oldrec) = sc_pool
	sc_pool = oldrec
end

#
# Function:	sc_newedge
# Purpose:	get an initialized scan record from the pool
# Parameters:	See argument declarations
# Returns:	pointer to scan edge mark record
# Uses:		sc_getedge() above
# Called by:	sc_merge() in scmerge.x
# Called by:	sc_add() in scadd.x
# Method:	< optional >
# Notes:	
#
pointer procedure sc_newedge ( x, val, type, nxt )

int	x		# i: x coordinate of this scan marker
int	val		# i: value associated with this scan segment
int	type		# i: either SCSTART or SCSTOP
int	nxt		# i: pointer to next link in scan or NULL

pointer newrec		# l: new scan record to be returned
pointer sc_getedge()	# get a record from pool space

begin
	newrec = sc_getedge()
	SC_X(newrec) = x
	SC_VAL(newrec) = val
	SC_TYPE(newrec) = type
	SC_NEXT(newrec) = nxt
	return (newrec)
end

#
# Function:	sc_fillpool
# Purpose:	Alloc a block of pool space and fill the edge pool
# Parameters:	See argument declarations
# Post-condition:	malloc marked in sc_block
# Post-condition:	remainder of space used as link list in sc_pool
# Uses:		malloc()
# Called by:	sc_getedge() above
# Method:	Allocate enough memory for n edge records.  Keep one to mark
#		the allocated memory space and put the rest in the pool.
# Notes:	
#
procedure sc_fillpool ()

pointer newrec		# l: pointer to scan edge record space
int	i		# l: loop counter
pointer sc_pool		# l: place to park unused scan records
pointer sc_blocks	# l: link list identifying malloc'd blocks
common /sccom/ sc_pool, sc_blocks

begin
	call malloc (newrec, (SCBLOCK * SC_LEN), TY_INT)
	SC_NEXT(newrec) = sc_blocks
	sc_blocks = newrec
	do i = 2, SCBLOCK {
	    newrec = newrec + SC_LEN
	    SC_NEXT(newrec) = sc_pool
	    sc_pool = newrec
	}
end

#
# Function:	sc_freepool
# Purpose:	Free all malloc'd blocks of pool space
# Parameters:	See argument declarations
# Post-condition:	pool pointers set to NULL
# Post-condition:	malloc'd pool space all mfree'd
# Uses:		mfree()
# Called by:
# Method:	Free malloc blocks marked by link list in sc_blocks.
# Notes:	
#
procedure sc_freepool ()

pointer oldrec		# l: pointer to record block space
pointer nxt		# l: pointer to next (needed before freeing oldrec)
pointer sc_pool		# l: place to park unused scan records
pointer sc_blocks	# l: link list identifying malloc'd blocks
common /sccom/ sc_pool, sc_blocks

begin
	oldrec = sc_blocks
	while( oldrec != SCNULL ) {
	    nxt = SC_NEXT(oldrec)
	    call mfree (oldrec, TY_INT)
	    oldrec = nxt
	}
	sc_blocks = SCNULL
	sc_pool = SCNULL
end
