# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
# IE_JIMEXAM -- 1D profile plot and gaussian fit parameters.
# If no GIO pointer is given then only the fit parameters are printed.
# The fitting uses a Levenberg-Marquardt nonlinear chi square minimization.
# IE_GFIT -- 1D Gaussian fit.
# DERIVS -- Compute model and derivatives for MR_SOLVE procedure.
# where the params are A1-A5.
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
