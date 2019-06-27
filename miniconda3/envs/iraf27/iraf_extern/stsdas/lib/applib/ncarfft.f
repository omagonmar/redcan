*  FFTPACK code obtained by Chris Biemesderfer from Argonne National Lab
*  math library over Arpanet (via netlib@argonne).  Written at NCAR by
*  Paul Swarztrauber in Apr 85.
*  Caveat receptor.  (Jack) dongarra@anl-mcs, (Eric Grosse) research!ehg
*  Compliments of netlib   Fri Jun 12 13:42:13 CDT 1987
*  Array size declarations changed from (1) to (*) for dummy arguments
*  by Phil Hodge on 15-Feb-1993.
*  Subroutines cffti1, cfftf1, and cfftb1 had an ifac argument, which was
*  the last 15 elements of the wsave array, except that it was integer
*  intead of real.  When these subroutines were called, the actual
*  argument was real, and the type mismatch resulted in error messages
*  from the compiler.  In these three subroutines, the dummy argument has
*  been renamed to xxifac, and local arrays rfac and jfac have been added.
*  These two arrays are of length 15 and are equivalenced to each other.
*  The contents of xxifac are now copied from (to) rfac in cffti1 (cfftf1
*  and cfftb1), and "ifac" is now replaced by "jfac" in expressions in the
*  body of these subroutines.  The array size 15 was chosen based on the
*  statement in the next paragraph regarding the size of the WSAVE array.
*  Phil Hodge, 12-Oct-2005.
*  The forward and backward Fourier transform routines are CFFTF and CFFTB
*  respectively.  Before using either of these, an array WSAVE of trig
*  coefficients must first be computed by calling CFFTI.  This array needs
*  to be recomputed only if the number of points to be transformed is changed.
*  The length of this array is 15 + 4*N.
*  Usage is as follows:
*  	call cffti (n, wsave)
*  	call cfftf (n, c, wsave)
*  	call cfftb (n, c, wsave)
*  	integer n		! length of array c
*  	real	wsave(15+4*n)	! work array of trig coefficients
*  	complex c(n)		! array to be transformed in-place
*  The length N is input to all routines.  The work array WSAVE is output
*  from CFFTI and input to CFFTF & CFFTB.  The complex array C is both
*  input and output for CFFTF & CFFTB.
*  This file contains the following subroutines, of which the first three
*  are the high-level routines:

###  Proprietary source code removed  ###
