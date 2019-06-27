# MRQMIN -- Levenberg-Marquard nonlinear chi square minimization.
# From NUMERICAL RECIPES by Press, Flannery, Teukolsky, and Vetterling, p526.
# Levenberg-Marquardt method, attempting to reduce the value of chi
# square of a fit between a set of NDATA points X,Y with individual
# standard deviations SIG, and a nonlinear function dependent on MA
# coefficients A.  The array LISTA numbers the parameters A such that the
# first MFIT elements correspond to values actually being adjusted; the
# remaining MA-MFIT parameters are held fixed at their input value.  The
# program returns the current best-fit values for the MA fit parameters
# A, and chi square, CHISQ.  The arrays COVAR and ALPHA with physical
# dimension NCA (>= MFIT) are used as working space during most
# iterations.  Supply a subroutine FUNCS(X,A,YFIT,DYDA,MA) that evaluates
# the fitting function YFIT, and its derivatives DYDA with respect to the
# fitting parameters A at X.  On the first call provide an initial guess
# for the parameters A, and set ALAMDA<0 for initialization (which then
# sets ALAMDA=0.001).  If a step succeeds  CHISQ becomes smaller and
# ALAMDA decreases by a factor of 10.  If a step fails ALAMDA grows by a
# factor of 10.  You must call this routine repeatedly until convergence
# is achieved.  Then make one final call with ALAMDA = 0, so that COVAR
# returns the covariance matrix, and ALPHA the curvature matrix.
# This routine is cast in the IRAF SPP language but the variable names have
# been maintained for reference to the original source.  Also the working
# arrays ATRY, BETA, and DA are allocated dynamically to eliminate
# limitations on the number of parameters fit.
# MRQCOF -- Evaluate linearized matrix coefficients.
# From NUMERICAL RECIPES by Press, Flannery, Teukolsky, and Vetterling, p527.
# Used by MRQMIN to evaluate the linearized fitting matrix ALPHA and vector
# BETA.
# This procedure has been recast in the IRAF/SPP language but the variable
# names have been maintained.  Dynamic memory is used.
# GAUSSJ -- Linear equation solution by Gauss-Jordan elimination.
# From NUMERICAL RECIPES by Press, Flannery, Teukolsky, and Vetterling, p28.
# Linear equation solution by Gauss-Jordan elimination.  A is an input matrix
# of N by N elements, stored in an array of physical dimensions NP by
# NP.  B is an input matrix of N by M containing the M right-hand side
# vectors, stored in an array of physical dimensions NP by MP.  On
# output, A is replaced by its matrix inverse, and B is replaced by the
# corresponding set of solutionn vectors.
# This procedure has been recast in the IRAF/SPP language using dynamic
# memory allocation and error return.  The variable names have been maintained.
# COVSRT -- Sort covariance matrix.
# From NUMERICAL RECIPES by Press, Flannery, Teukolsky, and Vetterling, p515.
# Given the covariance matrix COVAR of a fit for MFIT of MA total parameters,
# and their ordering LISTA, repack the covariance matrix to the true order of
# the parameters.  Elements associated with fixed parameters will be zero.
# NCVM is the physical dimension of COVAR.
# This procedure has been recast into the IRAF/SPP language but the
# original variable names are used.

###  Proprietary source code removed  ###
