# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
# GAMMLN -- Return natural log of gamma function.
# POIDEV -- Returns Poisson deviates for a given mean.
# GASDEV -- Return a normally distributed deviate of zero mean and unit var.
# MR_SOLVE -- Levenberg-Marquardt nonlinear chi square minimization.
#     MR_EVAL -- Evaluate curvature matrix.
#     MR_INVERT -- Solve a set of linear equations using Householder transforms.
# TWOFFT -- Returns the complex FFTs of two input real arrays.
# REALFT -- Calculates the FFT of a set of 2N real valued data points.
#     FOUR1 -- Computes the forward or inverse FFT of the input array.
# GAMMLN -- Return natural log of gamma function.
# Argument must greater than 0.  Full accuracy is obtained for values
# greater than 1.  For 0<xx<1, the reflection formula can be used first.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# POIDEV -- Returns Poisson deviates for a given mean.
# The real value returned is an integer.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# Modified to return zero for input values less than or equal to zero.
# GASDEV -- Return a normally distributed deviate with zero mean and unit
# variance.  The method computes two deviates simultaneously.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# MR_SOLVE -- Levenberg-Marquardt nonlinear chi square minimization.
# Use the Levenberg-Marquardt method to minimize the chi squared of a set
# of paraemters.  The parameters being fit are indexed by the flag array.
# To initialize the Marquardt parameter, MR, is less than zero.  After that
# the parameter is adjusted as needed.  To finish set the parameter to zero
# to free memory.  This procedure requires a subroutine, DERIVS, which
# takes the derivatives of the function being fit with respect to the
# parameters.  There is no limitation on the number of parameters or
# data points.  For a description of the method see NUMERICAL RECIPES
# by Press, Flannery, Teukolsky, and Vetterling, p523.
# These routines have their origin in Numerical Recipes, MRQMIN, MRQCOF,
# but have been completely redesigned.
# MR_EVAL -- Evaluate curvature matrix.  This calls procedure DERIVS.
# MR_INVERT -- Solve a set of linear equations using Householder transforms.
# This calls a routine published in in "Solving Least Squares Problems",
# by Charles L. Lawson and Richard J. Hanson, Prentice Hall, 1974.
# TWOFFT - Given two real input arrays DATA1 and DATA2, each of length
# N, this routine calls cc_four1() and returns two complex output arrays,
# FFT1 and FFT2, each of complex length N (i.e. real length 2*N), which
# contain the discrete Fourier transforms of the respective DATAs.  As
# always, N must be an integer power of 2.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# REALFT - Calculates the Fourier Transform of a set of 2N real valued
# data points.  Replaces this data (which is stored in the array DATA) by
# the positive frequency half of it's complex Fourier Transform.  The real
# valued first and last components of the complex transform are returned
# as elements DATA(1) and DATA(2) respectively.  N must be an integer power
# of 2.  This routine also calculates the inverse transform of a complex
# array if it is the transform of real data.  (Result in this case must be
# multiplied by 1/N). A forward transform is perform for isign == 1, other-
# wise the inverse transform is computed.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# FOUR1 -  Replaces DATA by it's discrete transform, if ISIGN is input
# as 1; or replaces DATA by NN times it's inverse discrete Fourier transform
# if ISIGN is input as -1.  Data is a complex array of length NN or, equiv-
# alently, a real array of length 2*NN.  NN *must* be an integer power of
# two.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# LU Decomosition
# Given an N x N matrix A, with physical dimension N, this routine
# replaces it by the LU decomposition of a rowwise permutation of
# itself.  A and N are input.  A is output, arranged as in equation
# (2.3.14) above; INDX is an output vector which records the row
# permutation effected by the partial pivioting; D is output as +/-1
# depending on whether the number of row interchanges was even or odd,
# respectively.  This routine is used in combination with LUBKSB to
# solve linear equations or invert a matrix.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# Solves the set of N linear equations AX = B.  Here A is input, not
# as the matrix of A but rather as its LU decomposition, determined by
# the routine LUDCMP.  INDX is input as the permuation vector returned
# by LUDCMP.  B is input as the right-hand side vector B, and returns
# with the solution vector X.  A, N, NP and INDX are not modified by
# this routine and can be left in place for successive calls with
# different right-hand sides B.  This routine takes into account the
# possiblity that B will begin with many zero elements, so it is
# efficient for use in matrix inversion.
# Based on Numerical Recipes by Press, Flannery, Teukolsky, and Vetterling.
# Used by permission of the authors.
# Copyright(c) 1986 Numerical Recipes Software.
# Invert a matrix using LU decomposition using A as both input and output.

###  Proprietary source code removed  ###
