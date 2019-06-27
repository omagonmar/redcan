# ludcmd -- lower-upper decomposition
# Double-precision version of ludcmp from Numerical Recipes.
# This differs from the Numerical Recipes version in the following ways:
# (1) the calling sequence also includes an ISTAT parameter, (2) memory
# is allocated instead of using the fixed array VV, and (3) double
# precision is used.
# This routine decomposes a matrix (in-place) into lower and upper
# triangular portions.  Use lubksd to obtain a solution to A * X = B
# or to compute the inverse of the matrix A.
# If the matrix is singular, ISTAT is set to one.
# Phil Hodge, 28-Oct-1988  Subroutine copied from Numerical Recipes.
# Phil Hodge, 10-Sep-1992  Convert to double precision and rename from ludcmp.

###  Proprietary source code removed  ###
