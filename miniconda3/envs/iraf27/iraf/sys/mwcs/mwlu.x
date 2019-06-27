# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.
# MULU -- Matrix utilities for MWCS.
# These routines are derived from routines in the book Numerical Recipes,
# Press et. al. 1986.
# MW_LUDECOMPOSE -- Replace an NxN matrix A by the LU decomposition of a
# rowwise permutation of the matrix.  The LU decomposed matrix A and the
# permutation index IX are output.  The decomposition is performed in place.
# MW_LUBACKSUB -- Solves the set of N linear equations A*X=B.  Here A is input,
# not as the matrix A but rather as its LU decomposition, determined by the
# routine mw_ludecompose.  IX is input as the permutation vector as returned by
# mw_ludecompose.  B is input as the right hand side vector B, and returns with
# the solution vector X.

###  Proprietary source code removed  ###
