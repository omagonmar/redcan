*  inputs
*  outputs
*  Module number:
*  Module name:
*  Keyphrase:
*  ----------
*  Lagrange's formula of polynomial interpolation
*  Description:
*  ------------
*  Neville's algorithm of Lagrange's formula of polynomial interpolation.
*  Adapted from the subroutine POLINT in p. 82 of Numerical Recipes by
*  Press et. al. (1986),
*  Given arrays XA and YA, each of length N, and given a value X, this routine
*  returns a value Y, and an error estimate DY.
*  FORTRAN name: VPOLIN.FOR
*  Keywords of accessed files and tables:
*  --------------------------------------
*  Name                         I/O     Description / Comments
*  Subroutines Called:
*  -------------------
*  CDBS:
*       None
*  SDAS:
*       None
*  Others:
*       None
*  History:
*  --------
*  Version      Date        Author          Description
*     1       02-28-88     J.-C. HSU        coding
*                                       --size of arrays XA and YA
*                                       --input arrays
*                                       --working array
*                                       --interpolated value and its error
*  initialize the tableau C and D
*  initial approximate value of Y
*  for each column of the tableau, loop over the current C's and D's and update
*  them

###  Proprietary source code removed  ###
