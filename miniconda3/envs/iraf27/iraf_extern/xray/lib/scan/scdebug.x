#$Header: /home/pros/xray/lib/scan/RCS/scdebug.x,v 11.0 1997/11/06 16:23:31 prosb Exp $
#$Log: scdebug.x,v $
#Revision 11.0  1997/11/06 16:23:31  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:36:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:14  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:49  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:11:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:52:32  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:17:57  pros
#General Release 1.0
#
#
#
# Module:	scdebug.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Debugging routines for scan library
# Includes:	sc_verify(), sc_check(), sc_error(), sc_list(), sc_debug()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_verify
# Purpose:	Check out the entire scan list array for inconsistancies
# Parameters:	See argument declarations
# Uses:		sc_check()
# Method:	Check each line using sc_check()
# Notes:
#
procedure sc_verify ( scan, width, height, valchk )

int	width, height	# i: dimensions of scan list array
pointer	scan[height]	# i: array of scan lists
int	valchk		# i: flag to expect all scans to have same val

int	y		# l: line counter

begin
	do y = 1, height {
	    call sc_check (scan[y], width, y, valchk)
	}
end

#
# Function:	sc_check
# Purpose:	check a scan line for error in form
# Parameters:	See argument declarations
# Uses:		sc_error(), sc_debug()
# Method:
# Notes:	The following rules apply:
#		 a) Every start must be followed by a stop with the same val
#		 b) No edge can have an x lower than a preceding edge
#		 c) The stop following a start cannot have the same x
#		 d) If a start following a start has the same val -
#		     they cannot have the same x
#		 e) No x can be less than 1 or greater than length
#		 f) Every edge must be a start or a stop
#		 g) No val can be less than 1
#		 h) if specified, all vals must be the same
#
procedure sc_check ( line, length, num, valchk )

pointer line		# i: beginning of scan line link list
int	length		# i: defined length of scan
int	num		# i: index of the line
int	valchk		# i: >0 flag to expect all scans to have same val

pointer old		# l: pointer to edge record before current edge
pointer here		# l: pointer to currently referenced edge record
int	index		# l: counter of record
int	val		# l: reference val for uniform val expectation

begin
	if( line == SCNULL )
	    return
	if( SC_X(line) < 1 )
	    call sc_error (line, num, 1, "start before 1")
	if( SC_TYPE(line) != SCSTART )
	    call sc_error (line, num, 1, "doesn't start with a start")
	val = SC_VAL(line)
	old = line
	here = SC_NEXT(line)
	index = 2
	# loop through each edge
	while( here != SCNULL ) {
	    if( SC_X(here) < SC_X(old) ) {
		call sc_error (here, num, index, "x less than prior x")
		call sc_debug (old, index - 1)
	    }
	    if( SC_TYPE(old) == SCSTART ) {
		if( SC_TYPE(here) != SCSTOP ) {
		    call sc_error (here, num, index, "start without stop")
		    call sc_debug (old, index - 1)
		} else {
		    if( SC_VAL(old) != SC_VAL(here) ) {
		        call sc_error(here,num,index,"start stop vals differ")
		    	call sc_debug (old, index - 1)
		    }
		    if( SC_X(old) == SC_X(here) ) {
		        call sc_error(here,num,index,"start stop x's match")
		    	call sc_debug (old, index - 1)
		    }
		}
	    } else if( SC_TYPE(old) == SCSTOP ) {
		if( (SC_VAL(old) == SC_VAL(here)) &&
		    (SC_X(old) == SC_X(here)) ) {
		    call sc_error (here, num, index, "adjacent scans same val")
		    call sc_debug (old, index - 1)
		}
	    }
	    if( SC_TYPE(here) == SCTEMP ) {
		call sc_error (here, num, index, "temp edge in line")
	    } else if( (SC_TYPE(here) != SCSTART) &&
		       (SC_TYPE(here) != SCSTOP) ) {
		call sc_error (here, num, index, "unknown edge type")
	    }
	    if( SC_VAL(here) < 1 ) {
		call sc_error (here, num, index, "scan val less than 1")
	    }
	    if( (valchk > 0) && (SC_VAL(here) != val) ) {
		call sc_error (here, num, index, "scan with different val")
		call sc_debug (line, 1)
	    }
	    if( SC_X(here) > length )
		call sc_error (here, num, index, "scan beyond length")
	    old = here
	    here = SC_NEXT(here)
	    index = index + 1
	}
	if( SC_TYPE(old) != SCSTOP )
	    call sc_error (old, num, index - 1, "line doesn't end on a stop")
end


#
# Function:	sc_error
# Purpose:	Report a scan error and display the offending scan edge record
# Parameters:	See argument declarations
# Uses:		sc_debug()
# Method:	Print the passed message and parameters and call sc_debug()
# Notes:
#
procedure sc_error ( link, num, index, fault )

pointer	link		# i: scan edge record in which error detected
int	num		# i: line number in which error detected
int	index		# i: record index in line of link
char	fault[ARB]	# i: string describing error

begin
	call printf ("Scan error - line %d, edge %d: %s\n")
	 call pargi (num)
	 call pargi (index)
	 call pargstr (fault)
	call sc_debug (link, index)
end


#
# Function:	sc_list
# Purpose:	List all edge records in a scan line
# Parameters:	See argument declarations
# Uses:		sc_debug()
# Method:	Loop while calling sc_debug()
# Notes:
#
procedure sc_list ( line )

pointer line	# i: head of link line to be listed

pointer link	# l: current link being listed
int	index	# l: count of the links

begin
	link = line
	index = 1
	while( link != SCNULL ) {
	    call sc_debug (link, index)
	    link = SC_NEXT(link)
	    index = index + 1
	}
end


#
# Function:	sc_debug
# Purpose:	Print the contents of a scan edge record
# Parameters:	See argument declarations
# Uses:
# Method:
# Notes:
#
procedure sc_debug ( rec, index )

pointer rec	# i: link record to be listed
int	index	# i: index of record in line

begin
	if( rec == SCNULL )
	    return
	if( SC_TYPE(rec) == SCSTART ) {
	   call printf(" %d: start, x=%d, val=%d, this=%d, next=%d\n")
	} else if( SC_TYPE(rec) == SCSTOP ) {
	   call printf(" %d:  stop, x=%d, val=%d, this=%d, next=%d\n")
	} else if( SC_TYPE(rec) == SCTEMP ) {
	   call printf(" %d:  temp, x=%d, val=%d, this=%d, next=%d\n")
	} else {
	   call printf(" %d:  BAD!, x=%d, val=%d, this=%d, next=%d\n")
	}
	 call pargi(index)
	 call pargi(SC_X(rec))
	 call pargi(SC_VAL(rec))
	 call pargi(rec)
	 call pargi(SC_NEXT(rec))
	return
end
