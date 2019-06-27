# DEBLEND -- Deblend up to 4 lines in a spectral region.
# SUBBLEND -- Subtract last fit.
# DOFIT -- Perform nonlinear iterative fit for the specified parameters.
# This uses the Levenberg-Marquardt method from NUMERICAL RECIPES.
# MODEL -- Compute model from fitted parameters.
# where the parameters are xc, sig, I(i), dx(i), and sig(i) (i=1,nlines).
# DERIVS -- Compute model and derivatives for MR_SOLVE procedure.
# where the parameters are xc, sig, I(i), dx(i), and sig(i) (i=1,nlines).
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
# FIXX - Check for bounds on x's.
# PIXIND -- Compute pixel index.

###  Proprietary source code removed  ###
