; PURPOSE: Calculate the flux losses for point-like sources due to the
; slit width (slit-loss) using the spectral images obtained during the
; aquisition of the standard star.
; 
; 
; INPUTS:
; 
; imaname       - Name of the aquisition image of the standard star
; slitimaname   - Name of the aquisition image of the standard star
;                 as seen through the slit FOV
; stdname       - Spectral image of the standard star whose header has
;                 to be updated with the slit-loss correction
; 
; OUTPUT:
; 
; slitloss      - Slit loss correction. An array with the correction
;                 obtained as a function of wavelength is returned if
;                 keyword WAVE, specifying the wavelength array, is
;                 passed. Otherwise, an scalar is returned.
; 

function SlitLosses,imaname,slitimaname,stdname

on_error,2

ima=readfits('OUTPUTS/'+imaname,head, /silent)
slitima=readfits('OUTPUTS/'+slitimaname,slithead, /silent)
; select the on-off image
ima=ima[*,*,2]
slitima=slitima[*,*,2]

; determine the maximum of the images
find,smooth(ima[20:n_elements(ima(*,0))-20,20:n_elements(ima(0,*))-20],2)-smooth(ima[20:n_elements(ima(*,0))-20,20:n_elements(ima(0,*))-20],30),maximax,maximay,flux,sharp,roundness,3.,5.,[-1.0,1.0],[0.2,1.0],/silent
;find,smooth(ima,2)-smooth(ima,20),maximax,maximay,flux,sharp,roundness,3.,5.,[-1.0,1.0],[0.2,1.0],/silent
maximax = maximax +20.
maximay = maximay +20.
;find,slitima,slitmaximax,slitmaximay,slitflux,slitsharp,slitroundness,5.,4.,[-1.0,1.0],[0.2,1.0],/silent

IF total(size(maximax)) GT 0 THEN BEGIN
   maxima=[[maximax],[maximay]]
   sortinds=reverse(sort(flux))
   maxima=reform(maxima[sortinds[0],*])
ENDIF ELSE BEGIN
   maxima=[-1,-1]
ENDELSE

find,slitima[20:n_elements(slitima(*,0))-20,20:n_elements(slitima(0,*))-20],slitmaximax,slitmaximay,slitflux,slitsharp,slitroundness,5.,4.,[-1.0,1.0],[0.2,1.0],/silent
slitmaximax = slitmaximax +20.
slitmaximay = slitmaximay +20.

;find,slitima,slitmaximax,slitmaximay,slitflux,slitsharp,slitroundness,5.,4.,[-1.0,1.0],[0.2,1.0],/silent
IF total(size(slitmaximax)) GT 0 THEN BEGIN
   maxslitima=[[slitmaximax],[slitmaximay]]
   sortinds=reverse(sort(slitflux))
   maxslitima=reform(maxslitima[sortinds[0],*])
ENDIF ELSE BEGIN
   maxslitima=[-1,-1]
ENDELSE


; checking that both maxixma are the same position and that the next
; pixel with the highest intensity after the maximum in each image
; is next to the maximum
; removing this condition for CC (August 2011)
IF sqrt(total((maxima-maxslitima)^2.)) LE 1.5 THEN BEGIN

   ; photometry of the sources
   aperrad=[30.]
   skyrad=[50.,70.]
   aper,ima,maxima[0],maxima[1],flux,fluxerr,sky,skyerr,1.,aperrad,skyrad,0.,/flux,/exact,/nan,/silent
   aper,slitima,maxslitima[0],maxslitima[1],slitflux,slitfluxerr,slitsky,slitskyerr,1.,aperrad,skyrad,0.,/flux,/exact,/nan,/silent

   ; slit loss correction
   slitcorr=flux/slitflux

ENDIF ELSE BEGIN
   print,'Warning: Fail to find the source, either on the slit-free image or in the image with the slit. Maybe also due to a mismatch between location of source in both images. Returning a slit correction of 1 -------------------'
   slitcorr=1.
ENDELSE

; update header of the standard
std=readfits('OUTPUTS/'+stdname,stdhead,/silent)
fxaddpar,stdhead,"SLITCORR",slitcorr[0]," Correction due to slit-losses"
writefits,'OUTPUTS/'+stdname,std,stdhead

return,slitcorr[0]

END
