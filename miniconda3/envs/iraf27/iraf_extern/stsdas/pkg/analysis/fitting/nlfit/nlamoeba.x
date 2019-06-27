# NL_AMOEBA -- Downhill simplex minimization method.
# This module implements the AMOEBA algorithm from Numerical Recipes, 
# which minimizes a function by the downhill simplex method. It calls a 
# function, nl_sumsq, which returns the chi-squared of residuals between 
# the data and the found solution. 
# On input, array NL_SPARAMS(nl) contains an initial guess, and on return 
# the fitted coefficients. On return, NL_CHISQ(nl) contains the chi-squared, 
# and NL_RMS(nl) contains the r.m.s residual of the fit. 
# On input, array NL_PFLAGS(nl) must be set in order to flag (true) 
# coefficients which are allowed to vary during the fit. 
# In case of no convergency, ERR is returned and a warning message is 
# issued, otherwise OK is returned.
# .................... Start of AMOEBA code ..............................
# ......................  End of AMOEBA code ...........................
#     Solution is in arrays p and y; transfer it to output array NL_SPARAMS(nl)
#     and NL_CHISQ(nl) parameter.

###  Proprietary source code removed  ###
