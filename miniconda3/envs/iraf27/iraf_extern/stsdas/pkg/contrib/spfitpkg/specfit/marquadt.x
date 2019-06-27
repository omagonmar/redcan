#                    Center for Astrophysical Sciences
#                        Johns Hopkins University
#  Synopsis:	specfit
#  Description:	SPECFIT is an IRAF task for fitting complex continua with
#  Arguments:	int	nfree
#  Returns:	none
#  Notes:	fx() is an external user-supplied function
#  History:	May 1989	Gerard Kriss
# Before starting, impose user-defined limits on parameters.
# Evaluate curvature matrix, alpha, and gradient vector, beta.
# Remember, a delta[j] * delta[k] is missing from the denominator of
# each alpha[j,k].  Multiply it in later.
# Add Marquadt parameter to the diagonal of alpha and check that curvature
# is positive.
# Compute changes to current free parameters

###  Proprietary source code removed  ###
