# NUMREP.X - A collection of routines recoded from Numerical Recipes by 
# Press, Flannery, Teukolsky, and Vetterling.  Used by permission of the 
# authors.  Copyright(c) 1986 Numerical Recipes Software.
# FOUR1 -  Replaces DATA by it's discrete transform, if ISIGN is input
# as 1; or replaces DATA by NN times it's inverse discrete Fourier transform
# if ISIGN is input as -1.  Data is a complex array of length NN or, equiv-
# alently, a real array of length 2*NN.  NN *must* be an integer power of
# two.
# REALFT - Calculates the Fourier Transform of a set of 2N real valued
# data points.  Replaces this data (which is stored in the array DATA) by
# the positive frequency half of it's complex Fourier Transform.  The real
# valued first and last components of the complex transform are returned
# as elements DATA(1) and DATA(2) respectively.  N must be an integer power
# of 2.  This routine also calculates the inverse transform of a complex
# array if it is the transform of real data.  (Result in this case must be
# multiplied by 1/N). A forward transform is perform for isign == 1, other-
# wise the inverse transform is computed.
# TWOFFT - Given two real input arrays DATA1 and DATA2, each of length
# N, this routine calls cc_four1() and returns two complex output arrays,
# FFT1 and FFT2, each of complex length N (i.e. real length 2*N), which
# contain the discrete Fourier transforms of the respective DATAs.  As
# always, N must be an integer power of 2.

###  Proprietary source code removed  ###
