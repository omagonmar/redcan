#                    Center for Astrophysical Sciences
#                        Johns Hopkins University
#  Synopsis:	call geterrmat(nfree, fpar, errmat)
#  Description:	A procedure to get the diagonal elements of the error matrix
#  Arguments:	int	nfree	- number of free parameters
#  Returns:	real	errmat[MAXFREE,MAXFREE]	-  the error matrix
#  Notes:	Information shared in common blocks defined in "specfit.com".
#  History:	June 1989	Gerard Kriss
# Evaluate the curvature matrix.  Curvmat will not divide by the delta's used
# Invert the curvature matrix to get the error matrix.
# Fill the elements of the error matrix.
# CURVMAT - routine to calculate the curvature matrix.
# Fill array of initial step sizes for derivative evaluation.
# Calculate initial chi-square
# Determine optimum step sizes to produce delta chisquares of unity.
# 11/1/89 - Approximate as an independent variable in a parabola
# 11/2/89 Revise calculation of mixed partials to be symmetric about minimum.
# Make sure parameters are reset to their original values in the common block

###  Proprietary source code removed  ###
