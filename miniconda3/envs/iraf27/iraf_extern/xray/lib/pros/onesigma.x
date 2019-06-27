# $Header: /home/pros/xray/lib/pros/RCS/onesigma.x,v 11.0 1997/11/06 16:20:46 prosb Exp $
# $Log: onesigma.x,v $
# Revision 11.0  1997/11/06 16:20:46  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:28:07  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:52  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:16  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  10:49:27  mo
#Initial revision
#
#
# Module:	one_sigma.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	< opt, brief description of whole family, if many routines>
# External:	< routines which can be called by applications>
# Local:	< routines which are NOT intended to be called by applications>
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - initial version - 8/93
#		{n} <who> -- <does what> -- <when>
# ----------------------------------------------------------------------------
#
#    Calculating Errors for Small Numbers of Counts -- F. Primini (8/93)
#
#    I've unearthed the derivation of the look-up table values for
# errors on small numbers of counts used in IPC Rev. 1 and PROS LDETECT.
# I summarize the derivation below, both for mathematical and historical
# interest. For those unwilling to wade through it, the bottom line is
# that the value for n=0 is indeed valid (at least as valid as any of
# the others) and not just an extrapolation or an arbitrary number.
# Further, there is a simple algebraic approximation, good to < ~2% for
# all n, which obviates the need for a look-up table at all.  
#
#   The earliest reference I could find is an internal CfA memo from
# Tommaso Maccacaro, which may be found on P. 290 of the IPC Rev. 1
# Science Spec's (SAO Special Report 393). The look-up table itself is
# found in the IPC fortran routine l_snr. A more complete reference may
# be found in Gehrels (1986, ApJ, 303, 336), a preprint of which I
# circulated to the division in 1985. The summary below draws heavily
# from this paper.
#
#   If n counts per bin are actually observed, then the upper limit U,
# to the true value per bin N (i.e. the parent mean) at the confidence
# level C is given by the solution to
#
#		 n
#		__
#		\
#		/  U**i * exp(-U)/(i!)	= 1 - C			(1)
#		--
#		i=0
#
# for Poisson statistics. This equation states that the probability of
# observing n or fewer counts from a distribution with parent mean U is
# only 1-C. In other words, in a large number of identical observations
# with the same N, U(n) will be greater than N 100*C% of the time. This
# is a standard definition of confidence limit. (It's equally possible
# to deal with lower limits, but as it turns out, the error derived from
# the upper limit analysis in the Poisson case is the larger of the two,
# and hence the conservative choice.) Note that U is well-defined when
# n=0. Values of U(n) for various confidence levels appear in Table 1 of
# the Gehrels paper. The confidence level we're interested in is
# C = 0.8413, since this corresponds to the Gaussian 1 sigma limit
# (i.e., for large n, U=n+sqrt(n) > N 84% of the time).
# 
#   The error is then estimated to be "sigma" = U - n. Note in the
# Gaussian limit this just reduces to sqrt(n). Values of U, sigma, and
# sigma**2 are listed below, using Table 1 of Gehrels. The values in the
# IPC Rev. 1 look-up table are simply 100*sigma**2. Also listed below
# are values to an approximate solution to eq. 1 for C=0.8413 (cf.
# Gehrels eq. 7). The approximation is
#
#		sigma' ~ 1 + sqrt(n + 0.75)			(2)
#
# and, as one can see from the %diff = (sigma'-sigma)/sigma, sigma' is
# good to better than 2% overall.
#
#	n	U	sigma	sigma**2	sigma'	%diff
#
#	0	1.841	1.841	3.39		1.866	1.4
#	1	3.300	2.300	5.29		2.323	1.0
#	2	4.638	2.638	6.96		2.658	0.8
#	...
#	5	8.382	3.382	11.44		3.398	0.5
#	...
#	40	47.38	7.38	54.46		7.38	-
#	...
#	100	111.0	11.0	121.0		11.0	-
#
# Because eq. 2 is so easy and accurate, I recommend that we adopt it
# whenever we need to compute the "1 sigma error" on n counts. We
# should, however, recognize that we are thinking in a "Gaussian" way,
# and should be careful in how we use those "1 sigma errors" in model
# fitting or hypothesis testing.
#
# -------------------------------------------------------------------------

include <mach.h>

# -------------------------------------------------------------------------
# one_sigma :: input:  counts, number of counts, calculation type
#              output: err - 1 sigma error on the counts.  
#	       Specification given above.
# -------------------------------------------------------------------------
procedure one_sigma (counts, n, poisson, err)

real   counts[ARB] 	#i: counts
int    n        	#i: number of counts
int    poisson		#i: flag for poisson calculation
real   err[ARB]      	#o: one sigma error calc using approximation 
                	#   described above
int    i

begin

	if ( poisson == YES ) {

	   # -----------------------------------------------------------
	   # Compute the error using poison statistics and the algorithm 
	   # described above.  POISERR = 1 in QPOE header. 
	   # This is the PROS default.
	   # -----------------------------------------------------------
	   do i = 1, n {
             if (counts[i] < -EPSILONR) {
		call error (1,"Counts can't be less that 0")
     	     }
             err[i]  = 1.0 + sqrt(counts[i] + 0.75)
	   }

	} else {

	   # -----------------------------------------------------------
	   # Compute the error using gaussian statistics.  
	   # When POISERR = 0 in QPOE header.
	   # -----------------------------------------------------------
	   do i = 1, n {
             if (counts[i] < -EPSILONR) {
		call error (1,"Counts can't be less that 0")
     	     }
	     err[i] = sqrt(counts[i])
	   }
        }
end
