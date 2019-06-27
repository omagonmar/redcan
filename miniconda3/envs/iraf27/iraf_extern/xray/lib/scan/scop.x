#$Header: /home/pros/xray/lib/scan/RCS/scop.x,v 11.0 1997/11/06 16:23:37 prosb Exp $
#$Log: scop.x,v $
#Revision 11.0  1997/11/06 16:23:37  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:20:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:27  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:21:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:10:36  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:10  pros
#General Release 1.0
#
#
#
# Module:	scop.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Carry out an operation on a scan line or between scan lines
# Includes:	sc_op(), sc_imop()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_op
# Purpose:	Apply a single scan to an existing scan line
# Parameters:	See argument declarations
# Uses:		sc_merge() in scmerge.x
# Uses:		sc_add() in scadd.x
# Called by:	sc_rotbox() in scrotbox.x
# Exceptions:
# Method:	Check the operator argument and call the appropriate
#		routine.
# Notes:	
#
procedure sc_op ( line, start_x, stop_x, val, op )

pointer line		# i,o: scan list base pointer to which to apply scan
int	start_x		# i: x coordinate of first pixel in new scan
int	stop_x		# i: x coordinate after last pixel in new scan
int	val		# i: value associated with new scan
int	op		# i: code for type of application operation

begin
	if( start_x < stop_x ) {
	    if( op == SCOR ) {
		call sc_merge (line, start_x, stop_x, val)
	    } else if( op == SCAD ) {
		call sc_add (line, start_x, stop_x, val)
	    } else if( op == SCPN ) {
		call sc_paint (line, start_x, stop_x, val)
	    } else {
		call printf("Error: unknown op code\n")
	    }
	}
end


#
# Function:	sc_imop
# Purpose:	Apply one scan list image to another
# Parameters:	See argument declarations
# Uses:		sc_op() above
# Pre-cond:	two scan list arrays
# Post-cond:	scan_b is altered by application of scan_a according to op
# Exceptions:
# Method:	Loop through both scans line by line.  For each line, for
#		each scan edge pair (start-stop) in scan_a, call sc_op.
# Notes:
#
procedure sc_imop ( scan_a, scan_b, wdth, hght, op )

int	wdth, hght	# i: dimensions of image
pointer	scan_a[hght]	# i: new scan list array to be applied to scan_b
pointer	scan_b[hght]	# i,o: existing scan list array to be altered
int	op		# i: code for kind of operation (OR, ADD, PAINT)

pointer edge		# l: pointer to edge in scan_a
int	y		# l: line counter in loop

begin
	do y = 1, hght {
	    edge = scan_a[y]
	    while( edge != SCNULL ) {
		call sc_op (scan_b[y], SC_X(edge), SC_X(SC_NEXT(edge)),
			    SC_VAL(edge), op)
		edge = SC_NEXT(SC_NEXT(edge))
	    }
	}
end


