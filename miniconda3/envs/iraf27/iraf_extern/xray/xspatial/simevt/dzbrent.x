# $Header: /home/pros/xray/xspatial/simevt/RCS/dzbrent.x,v 11.0 1997/11/06 16:33:29 prosb Exp $
# $Log: dzbrent.x,v $
# Revision 11.0  1997/11/06 16:33:29  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:56:07  prosb
# General Release 2.4
#
#Revision 1.1  1994/10/24  16:36:08  prosb
#Initial revision
#
#Revision 1.1  94/10/24  15:42:52  prosb
#Initial revision
#
# Revision 1.2  1994/09/06  17:27:58  manning
# krm - removed double definition of the intrinsic function "abs".
# this was done after consulting the spp and fortran manuals ...
# the compiler should identify the argument as a double and return
# a double.
#
# Revision 1.1  1994/08/31  15:36:41  manning
# Initial revision
#
#
# Module:       dzbrent.x
# Project:      PROS -- ROSAT RSDC
# Description:  Function dzbrent solves the equation func(x) = X by 
#               converting to the equation func(x) - X = 0, and solving 
#               for the root, assumed to lie between x1 and x2.  X is a 
#               constant between 0 and 1.  The root is returned as dzbrent, 
#               which is refined until it converges to within a value tol.
#               The algorithm is identical to the zbrent routine in 
#               Press, et. al.
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} KRM -- initial version -- 8/1994
#
#-------------------------------------------------------------------------

include <mach.h>

define ITMAX 100
define EPS 3.0e-8

#-------------------------------------------------------------------------

double procedure dzbrent(type, par, X, x1, x2, tol)

int type
real par
double X
double x1
double x2
double tol

int iter

double a, b, c, d, e

double min1, min2

double fa, fb, fc

double p, q, r, s, tol1, xm

double get_integral()

begin

    a = x1
    b = x2
    fa = get_integral(type, par, a) - X
    fb = get_integral(type, par, b) - X

    if ( fa*fb > 0.0d0 ) {
	call error(1, "Root must be bracketed in DZBRENT!")
    }

    fc = fb

    do iter=1, ITMAX {
	
	if ( fb*fc > 0.0d0 ) {
	    c = a
	    fc = fa
	    d = b -a
	    e = d

	}
	if ( abs(fc) < abs(fb) ) {
	    a = b
	    b = c
	    c = a
	    fa = fb
	    fb = fc
 	    fc = fa
	}
	tol1 = 2.d0*EPS*abs(b) + 0.5d0*tol
	xm = 0.5d0*(c - b)
  	
	if ( (abs(xm) <= tol1) || (abs(fb) <= EPSILOND ) ) {
	    return(b)
	}

	if ( (abs(e) >= tol1) && (abs(fa) > abs(fb)) ) {
	    s = fb/fa
	    	
	    if ( a == c ) {
		p = 2.0d0*xm*s
	 	q = 1.0d0 - s
	    }
	    else {
		q = fa/fc
		r = fb/fc
		p = s*(2.0d0*xm*q*(q-r) - (b-a)*(r-1.0d0))
		q = (q - 1.0d0)*(r-1.0d0)*(s-1.0d0)
	    }
	    if ( p > 0.0d0 ) {
		q = -q
	    }
	    p = abs(p)

	    min1 = 3.0d0*xm*q - abs(tol1*q)
	    min2 = abs(e*q)

	    
	    if ( 2.0d0*p < min(min1,min2) ) {
		e = d
		d = p/q
	    }
	    else {
		d = xm
		e = d
	    }
	}
	else {
	    d = xm
	    e = d
	}
	a = b
	fa = fb
	
	if ( abs(d) > tol1 ) {
	    b = b + d
	}
	else {
	    if ( xm > 0.0d0 ) {
		b = b + abs(tol1)
	    }
	    else {
		b = b - abs(tol1)
	    }
	}
	fb = get_integral(type, par, b) - X
    }

end
