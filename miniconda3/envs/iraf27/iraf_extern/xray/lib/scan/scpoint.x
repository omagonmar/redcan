#$Header: /home/pros/xray/lib/scan/RCS/scpoint.x,v 11.0 1997/11/06 16:23:42 prosb Exp $
#$Log: scpoint.x,v $
#Revision 11.0  1997/11/06 16:23:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:31:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:06  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:06  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:20  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:11:26  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:22  pros
#General Release 1.0
#
#
#
# Module:	scpoint.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Create a scan list for a given point or list of points
# Includes:	sc_point()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include	<scset.h>

#
# Function:	sc_point
# Purpose:	Put scans on a scan list for set of points
# Parameters:	See argument declarations
# Uses:		sc_op() in scop.x
# Exceptions:
# Method:	
# Notes:	
#
procedure sc_point ( pt_x, pt_y, count, val, imwdth, imhght, scan, op )

int	count		# i: number of points given
real	pt_x[count]	# i: x coordinate(s) of point(s)
real	pt_y[count]	# i: y coordinate(s) of point(s)
int	val		# i: value to associate with this region
int	imwdth, imhght	# i: dimensions of image field
pointer	scan[imhght]	# i: scan list array to which to atach region
int	op		# i: code for kind of operation to perform

int	i		# l: loop counter
int	y, x		# l: pixel coords of a point

begin
	do i = 1, count {
	    # rounding to determine pixel bin: 0.5 - 1.5 = 1, 1.5 - 2.5 = 2
	    x = int(pt_x[i] + 0.5)
	    y = int(pt_y[i] + 0.5)
	    # if pixel is within image, scan over it
	    if( (y > 0) && (y <= imhght) && (x > 0) && (x <= imwdth) ) {
		call sc_op (scan[y], x, x + 1, val, op)
	    }
	}
end
