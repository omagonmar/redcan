# Compute the output FITS CRPIX, CRVAL, and CD arrays from the MWCS LTERM and
# WTERM. Note that the CD matrix terms are still transposed from the usual
# Fortran order. 

procedure ct_gftermd (mw, crpix, crval, cd, ndim)

pointer	mw		#I the input mwcs pointer
double	crpix[ndim]	#O the output FITS CRPIX array
double	crval[ndim]	#O the output FITS CRVAL array
double	cd[ndim,ndim]	#O the output FITS CD matrix
int	ndim		#I the dimensionality of the wcs

pointer	sp, r, wcd, ltv, ltm, iltm

begin
	call smark (sp)
	call salloc (r, ndim, TY_DOUBLE)
	call salloc (wcd, ndim * ndim, TY_DOUBLE)
	call salloc (ltv, ndim, TY_DOUBLE)
	call salloc (ltm, ndim * ndim, TY_DOUBLE)
	call salloc (iltm, ndim * ndim, TY_DOUBLE)

        call mw_gwtermd (mw, Memd[r], crval, Memd[wcd], ndim)
        call mw_gltermd (mw, Memd[ltm], Memd[ltv], ndim)
        call mwvmuld (Memd[ltm], Memd[r], crpix, ndim)
        call aaddd (crpix, Memd[ltv], crpix, ndim)
        call mwinvertd (Memd[ltm], Memd[iltm], ndim)
        call mwmmuld (Memd[wcd], Memd[iltm], cd, ndim)

	call sfree (sp)
end


# Given the FITS CRPIX, CRVAL, and CD arrays and the LTERM LTV and LTM arrays
# set the new LTERM and WTERM values.

procedure ct_sftermd (mw, crpix, crval, cd, ltv, ltm, ndim)

pointer mw              #I the input mwcs pointer
double  crpix[ndim]     #I the input FITS CRPIX array
double  crval[ndim]     #I the input FITS CRVAL array
double  cd[ndim,ndim]   #I the input FITS CD matrix
double  ltv[ndim]       #I the input LTV array
double  ltm[ndim,ndim]  #I the input LTM matrix
int     ndim            #I the dimensionality of the wcs

pointer	sp, r, nr, ncd, iltm

begin
	call smark (sp)
	call salloc (r, ndim, TY_DOUBLE) 
	call salloc (nr, ndim, TY_DOUBLE) 
	call salloc (ncd, ndim * ndim, TY_DOUBLE) 
	call salloc (iltm, ndim * ndim, TY_DOUBLE) 

        call mw_sltermd (mw, ltm, ltv, ndim)
        call mwmmuld (cd, ltm, Memd[ncd], ndim)
        call mwinvertd (ltm, Memd[iltm], ndim)
        call asubd (crpix, ltv, Memd[r], ndim)
        call mwvmuld (Memd[iltm], Memd[r], Memd[nr], ndim)
        call mw_swtermd (mw, Memd[nr], crval, Memd[ncd], ndim)

	call sfree (sp)
end
