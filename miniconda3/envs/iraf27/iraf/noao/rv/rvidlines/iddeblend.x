# ID_MR_DOFIT -- Fit gaussian components.  This is an interface to ID_DOFIT1
# which puts parameters into the form required by ID_DOFIT1 and vice-versa.
# It also implements a constrained approach to the solution.
# ID_MODEL -- Compute model.
# where the params are I1, I2, xg, yg, and sg.
# ID_DOFIT1 -- Perform nonlinear iterative fit for the specified parameters.
# This uses the Levenberg-Marquardt method from NUMERICAL RECIPES.
# ID_DERIVS -- Compute model and derivatives for MR_SOLVE procedure.
# where the params are I1, I2, xc, sig, I(i), dx(i), and sig(i) (i=1,nlines).
# ID_MR_SOLVE -- Levenberg-Marquardt nonlinear chi square minimization.
# Use the Levenberg-Marquardt method to minimize the chi squared of a set
# of paraemters.  The parameters being fit are indexed by the flag array.
# To initialize the Marquardt parameter, MR, is less than zero.  After that
# the parameter is adjusted as needed.  To finish set the parameter to zero
# to free memory.  This procedure requires a subroutine, DERIVS, which
# takes the derivatives of the function being fit with respect to the
# parameters.  There is no limitation on the number of parameters or
# data points.  For a description of the method see NUMERICAL RECIPES
# by Press, Flannery, Teukolsky, and Vetterling, p523.
# ID_MR_EVAL -- Evaluate curvature matrix.  This calls procedure DERIVS.
# MR_INVERT -- Solve a set of linear equations using Householder transforms.

###  Proprietary source code removed  ###
