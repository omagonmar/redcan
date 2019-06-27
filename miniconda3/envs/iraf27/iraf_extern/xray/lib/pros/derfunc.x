# $Header: /home/pros/xray/lib/pros/RCS/derfunc.x,v 11.0 1997/11/06 16:20:19 prosb Exp $
# $Log: derfunc.x,v $
# Revision 11.0  1997/11/06 16:20:19  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:21  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:35  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:59  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:10:35  mo
#MC	7/2/93		Remove redundant ( == TRUE) from booleans (RS6000 port)
#
#Revision 6.0  93/05/24  15:44:07  prosb
#General Release 2.2
#
#Revision 5.1  92/10/30  10:33:18  mo
#BASELINE 5.0 release 2.1
#
#Revision 5.0  92/10/29  21:15:01  prosb
#General Release 2.1
#
#____________________________________________________________________
# Routine:       derf
# Programmed by: SAO / Leon Van Speybroeck
# Rev:           2.00
# Date:          Mon May 11 17:09:06 EDT 1992
#
# this program calculates the error function
#
#____________________________________________________________________
# converted to SPP by JD on 9/15/92
#____________________________________________________________________

define ZERO	0.0d0
define ONE	1.0d0
define TWO      2.0d0
define ONE_HALF 0.5d0

define SRTPI    1.772453850905516027298167d0 
define ZMAX	26.64175d0 
define TOL	1.0d-16
define TOLCCF   1.0d-15 

#__________________________________________________________________

double procedure derf (x)

double x 		# i: arguments

double z 		# l: internal form of x
double tempf, tempz
double f 		# l: normalization factor
double erf

bool   negarg 		# l: logical indicating a sign change

double derfps()
double derfccf() 	# l: functions

begin

      if ( x < ZERO ) {
        negarg = TRUE
      } else {
        negarg = FALSE
      }

      if ( negarg ) {
         z = -x
      } else {
         z = x
      }

      if ( z >= ZMAX ) {
         erf = ONE
         if ( negarg ) erf = -erf

      } else {

         tempz = -z * z

         tempf = exp (tempz)

	 f = tempf / SRTPI

         if ( z <= TWO ) {
            erf = f * derfps(x)
         } else {
            erf = ONE - f * derfccf(z)
            if ( negarg ) erf = -erf
         }
      }

      return (erf)
      end

#__________________________________________________________________
# Routine:       derfps
# Programmed by: SAO / Leon Van Speybroeck
# Rev:           2.00
# Date:          Mon May 11 17:09:06 EDT 1992
#
# this program calculates 2x 1F1(1;3/2;x**2)
# using a power series
#__________________________________________________________________

double procedure derfps (z)

double z 		# i: argument

double z2 		# l:  2 times square of z
double t,sum,two_z 	# l: the term index,term, and sum
double twonp1 		# l: (2*n+1)

double erfps

begin

      two_z = TWO * z
      z2 = two_z * z

      sum = ONE
      twonp1 = ONE
      t = ONE

      do while ( abs(t) > TOL ) {
         twonp1 = twonp1 + TWO
         t = t * z2 / twonp1
         sum = sum + t
      }

      erfps = two_z * sum

      return (erfps)
end

#__________________________________________________________________
# Routine:       derfccf
# Programmed by: SAO / Leon Van Speybroeck
# Rev:           2.00
# Date:          Mon May 11 17:09:06 EDT 1992
#
# this program calculates the continued part of the complementary 
# error function using formula 7.1.14 of NBS 55
#__________________________________________________________________

double procedure derfccf (z)

double z

double z2 		#  square of z

double ab[0:2]
double a,am1,am2
double b,bm2
double afac

equivalence (ab(0),a),(ab(1),am1),(ab(2),am2)

#__________________________________________________________________
begin

      z2 = z*z

      afac = ZERO
      am2 = ZERO
      am1 = ONE/z
      bm2 = am1

      do while ( TRUE ) {
         afac = afac + ONE_HALF 
         b = z + afac * bm2
         a = ( z*am1 + afac*am2 )/ b

         if ( abs(am1/a - ONE) <= TOLCCF ) {
#           derfccf = a
            return (a)
         }

# cycle
         am1 = am1 / b
         bm2 = ONE / b
         call amovd(ab[0],ab[1],2)
      }
end

