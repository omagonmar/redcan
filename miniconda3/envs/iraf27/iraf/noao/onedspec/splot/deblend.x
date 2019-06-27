# Profile types.
# Elements of fit array.
# Type of constraints.
# DOFIT -- Fit line profiles.  This is an interface to DOFIT1
# which puts parameters into the required form and vice-versa.
# It also implements a constrained approach to the solution.
# DOREFIT -- Refit line profiles.  This assumes the input is very close
# to the final solution and minimizes the number of calls to the
# fitting routines.  This is intended for efficient use in the
# in computing bootstrap error estimates.
# MODEL -- Compute model.
# DERIVS -- Compute model and derivatives for MR_SOLVE procedure.
# This could be optimized more for the Voigt profile by reversing
# the do loops since v0 need only be computed once per line.
# DOFIT1 -- Perform nonlinear iterative fit for the specified parameters.
# This uses the Levenberg-Marquardt method from NUMERICAL RECIPES.
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
# MR_EVAL -- Evaluate curvature matrix.  This calls procedure DERIVS.
# MR_INVERT -- Solve a set of linear equations using Householder transforms.

###  Proprietary source code removed  ###
