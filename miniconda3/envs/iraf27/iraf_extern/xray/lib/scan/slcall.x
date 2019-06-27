#$Header: /home/pros/xray/lib/scan/RCS/slcall.x,v 11.0 1997/11/06 16:23:49 prosb Exp $
#$Log: slcall.x,v $
#Revision 11.0  1997/11/06 16:23:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:18  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:49  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/08/02  10:50:30  mo
#*** empty log message ***
#
#Revision 3.1  91/08/02  10:12:06  mo
#MC   8/2/91          Updated dependencies
#
#Revision 3.0  91/08/02  01:08:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:18:39  pros
#General Release 1.0
#
#
#
# Module:	slcall.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Create a convenient interface to sc calls
# Includes:	sl_circle(), sl_point(), sl_rotbox()
# Includes:	sl_apply(), sl_disp()
# Includes:	sl_pl(), sl_pm()
# Includes:	sl_verify()
# Description:  
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989 Michael VanHilst  You may do anything you like with this
#		file except remove this copyright.
# Modified:	{0} Michael VanHilst	8 February 1989	initial version
#		{n} <who> -- <when> -- <does what>

include <imhdr.h>
include	"slset.h"

#
# Function:	sl_circle
# Purpose:	Put scans on a scan list for region inside a given circle.
# Parameters:	See argument declarations
# Uses:		sc_circle() in sccircle.x
#
procedure sl_circle ( sl, xcen, ycen, radius, val, op )

pointer	sl		# i: scan list structure pointer
real	xcen, ycen	# i: coordinates of box center
real	radius		# i: radius of circle (not inclusive)
int	val		# i: value to associate with this region
int	op		# i: code for kind of operation to perform

begin
	call sc_circle (xcen, ycen, radius, val,
			SL_WDTH(sl), SL_HGHT(sl), Memi[SL_SCAN(sl)], op)
end

#
# Function:	sl_point
# Purpose:	Put scans on a scan list for point or set of points
# Parameters:	See argument declarations
# Uses:		sc_point() in scpoint.x
#
procedure sl_point ( sl, pt_x, pt_y, count, val, op )

pointer	sl		# i: scan list structure pointer
int	count		# i: number of points given
real	pt_x[count]	# i: x coordinate(s) of point(s)
real	pt_y[count]	# i: y coordinate(s) of point(s)
int	val		# i: value to associate with this region
int	op		# i: code for kind of operation to perform

begin
	call sc_point (pt_x, pt_y, count, val,
		       SL_WDTH(sl), SL_HGHT(sl), Memi[SL_SCAN(sl)], op)
end

#
# Function:	sl_rotbox
# Purpose:	Put scans on a scan list for region inside a given rotatable
#		rectangle
# Parameters:	See argument declarations
# Uses:		sc_rotbox() in scrotbox.x
#
procedure sl_rotbox ( sl, xcen, ycen, xwdth, yhght, angle, val, op )

pointer	sl		# i: scan list structure pointer
real	xcen, ycen	# i: coordinates of box center
real	xwdth, yhght	# i: box width and height
real	angle		# i: angle in degrees, rotation is counter clockwise
int	val		# i: value to associate with this region
int	op		# i: code for kind of operation to perform

begin
	call sc_rotbox (xcen, ycen, xwdth, yhght, angle, val,
			SL_WDTH(sl), SL_HGHT(sl), Memi[SL_SCAN(sl)], op)
end

#
# Function:	sl_apply
# Purpose:	Apply one scan list image to another
# Parameters:	See argument declarations
# Uses:		sc_imop() above
# Pre-cond:	two scan list arrays
# Post-cond:	scan_b is altered by application of scan_a according to op
#
procedure sl_apply ( sl_a, sl_b, op )

pointer	sl_a		# i: scan list structure to be applied to sl_b
pointer	sl_b		# i: scan list structure to be altered
int	op		# i: code for kind of operation (OR, ADD, PAINT)

begin
	if( (SL_WDTH(sl_a) != SL_WDTH(sl_b)) ||
	    (SL_HGHT(sl_a) != SL_HGHT(sl_b)) ) {
	    call error(0, "sl_apply: sl dimensions differ")
	} else {
	    call sc_imop (Memi[SL_SCAN(sl_a)], Memi[SL_SCAN(sl_b)],
			  SL_WDTH(sl_a), SL_HGHT(sl_a), op)
	}
end

#
# Function:	sl_disp
# Purpose:	Draw the scan list image in table form scaled to fit
#		a terminal.
# Parameters:	See argument declarations
# Uses:		sc_disp() in scdisp.x
#
procedure sl_disp ( sl, cols )

pointer	sl		# i: scan list structure pointer
int	cols		# i: number of columns in display

begin
	call sc_disp (Memi[SL_SCAN(sl)], SL_WDTH(sl), SL_HGHT(sl), cols)
end

#
# Function:	sl_pl
# Purpose:	Create and return an IRAF pl equivalent to the scan list image
# Parameters:	See argument declarations
# Uses:		sc_sltopl
# Returns:	handle to open plio pixel list
# Exceptions:	
# Notes:	Scan list array is neither freed nor cleared by this routine.
#
pointer procedure sl_pl ( sl )

pointer	sl		# i: scan list structure pointer

pointer	sc_sltopl()	# o: returns handle for pl

begin
	return( sc_sltopl (Memi[SL_SCAN(sl)], SL_WDTH(sl), SL_HGHT(sl)) )
end

#
# Function:	sl_pm
# Purpose:	Create and return an IRAF pm equivalent to the scan list image
# Parameters:	See argument declarations
# Uses:		sc_sltopm() in scplio.x
# Returns:	handle to open pmio pixel mask
# Exceptions:	Given dimensions cannot be greater than those of opened image.
# Notes:	Scan list array is neither freed nor cleared by this routine.
#
pointer procedure sl_pm ( im, sl )

pointer im		# i: open IRAF image handle
pointer	sl		# i: scan list structure pointer

pointer	sc_sltopm()	# o: returns handle for pm

begin
	if( (IM_LEN(im,1) != SL_WDTH(sl)) || (IM_LEN(im,2) != SL_HGHT(sl)) ) {
	    call error (0, "sl_pm: im and sl dimensions differ")
	    return( 0 )
	}
	return( sc_sltopm (im, Memi[SL_SCAN(sl)], SL_WDTH(sl), SL_HGHT(sl)) )
end

#
# Function:	sl_verify
# Purpose:	Check out the entire scan list image for inconsistancies
# Parameters:	See argument declarations
# Uses:		sc_verify()
#
procedure sl_verify ( sl, homog )

pointer	sl		# i: scan list structure pointer
int	homog		# i: flag if 1, all scans expected to have same val

begin
	call sc_verify (Memi(SL_SCAN(sl)), SL_WDTH(sl), SL_HGHT(sl), homog)
end
