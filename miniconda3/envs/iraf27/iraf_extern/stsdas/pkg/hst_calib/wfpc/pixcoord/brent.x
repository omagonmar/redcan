# BRENT -- Find the roots of a function by Brent's method
# This procedure uses Brent's method to find one root of a function. Brent's
# method uses inverse quadratic interpolation suplemented by bisection when
# the trial root lies outside the bracket. The code was converted from the
# Fortran routine ZBRENT in Numerical Recipes, section 9.3.
# B.Simon	11-Sep-90	First Code
# BRACKET_ROOT -- Find an initial bracket for a root
# This procedure takes an initial guessed bracket and expands the range
# until it contains a root. Since the method is not guaranteed to find
# a bracket, it returns true if the bracket is found and false otherwise.
# The function is taken from the Fortran routine ZBRAC in Numerical 
# Recipes, section 9.1

###  Proprietary source code removed  ###
