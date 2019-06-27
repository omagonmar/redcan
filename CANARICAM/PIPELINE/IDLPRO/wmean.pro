function wmean,arr,weight,DIM=dim,ARRERR=arrerr,WMEANERR=wmeanerr,WSTDDEV=wstddev

arrsize=size(arr)
IF NOT keyword_set(dim) THEN dim=1
IF n_params() EQ 1 THEN weight=arr*0.+1.
IF keyword_set(arrerr) THEN weight=1./arrerr^2.

totw=total(weight,dim,/nan)
wmean=total(arr*weight,dim,/nan)/totw

IF keyword_set(arrerr) THEN wmeanerr=sqrt(1./totw) ELSE IF arg_present(wmeanerr) THEN print,'No STD of weighted mean available. If the weights are not errors, the std of the mean doesn NOT make sense, because if weights are large, the error on the mean will be absurdly small.'

; Reform the wmean to rebin it later
rdim=arrsize[1:arrsize[0]]
rdim[dim-1]=1
rwmean=reform(wmean,rdim)

wstddev=sqrt(total(weight*(arr-rebin(rwmean,arrsize[1:arrsize[0]]))^2.,dim,/nan)/totw)

IF dim NE arrsize[0] THEN wmean=reform(wmean,rdim)

return,wmean

end
