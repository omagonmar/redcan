# Macros for accessing array elements.
#  NL_MARQ --  Levenberg-Marquardt minimization method.
#  This module is based on the FORTRAN version of Numerical Recipes. 
#  Several modifications were introduced, such as:
#  - stopping criterion takes lambda value into account.
#  - dynamic memory allocation.
#  - layering on top of nlfit data structures and function calls.
#  - specific function computation routine instead of external.
#  - single-size covariance and curvature matrices.
#  - error handling.
#  On input, array NL_SPARAMS(nl) contains an initial guess, and on 
#  return the fitted coefficients. On return, array NL_PERRORS(nl)
#  stores the coefficient errors derived from the covariance matrix.
#  On return, NL_CHISQ(nl) contains the chi-squared, and NL_RMS(nl) 
#  contains the r.m.s residual of the fit. 
#  On input, array NL_PFLAGS(nl) must be set in order to flag (true) 
#  coefficients which are allowed to vary during the fit. 
#  In case a singular matrix is found, ERR is returned and a warning 
#  message is issued, otherwise OK is returned.
#  NL_MQMIN --  Perform one Levenberg-Marquardt iteration.
#  "lambda" is the fudge factor for the scale length constant. If
#  set to any negative value, routine initializes the trial coefficient
#  vector and the covariance and curvature matrices. After convergency,
#  this routine must be called with lambda = 0 so the final covariance
#  and chisq can be returned. 
#  Matrices "alpha" and "covar" must be allocated by the caller.
#  NL_MCOF --  Compute curvature matrix and chi-squared gradient vector.
#  This routine also updates the chi-squared and rms values for the current
#  coefficients. It calls routine nl_fdev which computes both the function
#  and its derivates respect each coefficient for a given value of the
#  independent variable(s).
#  NL_CVSRT --  Rearrange covariance matrix into the full "ncoeff"
#               space. Zeros are left in places corresponding to
#               frozen coefficients.
#  NL_GJ --  Solve linear system by Gauss-Jordan elimination. If singular
#            matrix, return ERR.

###  Proprietary source code removed  ###
