*      PIX0 = -W0
*      W0 = LAMPIX (PIX0 + L0, STATUS)
*      IF (STATUS .NE. 0) RETURN
*      LMIN = LAMPIX (-512. + L0, STATUS)
*      IF (STATUS .NE. 0) RETURN
*      IF (W0.LT.LMIN) W0 = LMIN
*      LMAX = LAMPIX (L0, STATUS)
*      IF (STATUS .NE. 0) RETURN
*      IF (W0 + NW * DW.GT.LMAX) NW = INT((LMAX-W0) / DW)
* Note that U has been added to the calling sequence.  This is scratch space.

###  Proprietary source code removed  ###
