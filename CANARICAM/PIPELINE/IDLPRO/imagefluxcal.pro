; PURPOSE: Calculates and/or performs flux calibration on images using
; spectral templates of COHEN standards and the appropiate filter
; pass-band used for imaging observations.
; 
; 
; INPUTS:
; 
; imaname       - Name of the image for which the flux-calibration has
;                 to be performed. If the image is a standard star,
;                 STDSPEC and FILTER must be provided in order to
;                 calculate the flux-calibration factor. Otherwise,
;                 STDIMA must be provided in order to read the
;                 flux-calibration factor from the header of the
;                 standard star, which was supposed to be
;                 flux-calibrated in advance.
; 
; OPTIONAL INPUTS:
; 
; stdima        - Name of the image of the standard star from whose
;                 header the flux-calibration factor will be
;                 extracted.
; stdspec       - [n,2] array containing the theoretical spectrum of
;                 the standard star for which the flux-calibration is
;                 going to be obtained. The 1st row includes the
;                 wavelength array (in [um]), while the 2nd row
;                 includes the spectrum (in [W cm-2 um-1])
; filter        - [n,2] array containing the filter used for
;                 convolution with the stdspec. The 1st row includes
;                 the wavelength array (in [um]), while the 2nd row 
;                 includes the filter pass-band (no units)
; 

pro ImageFluxCal,imaname,STDIMA=stdimaname,STDSPEC=stdspec,FILTER=filter,FLUX=flux,STDNAME= stdname, COORDS=maxima, choose = choose

on_error,2
ima=readfits('OUTPUTS/'+imaname,imahead,/silent)
ima=ima[*,*,2]
if n_elements(ima) gt 1 then begin
;
; determine the maximum of the image selecting the center to do not include border-issues
;

find,smooth(ima[20:n_elements(ima(*,0))-20,20:n_elements(ima(0,*))-20],2)-smooth(ima[20:n_elements(ima(*,0))-20,20:n_elements(ima(0,*))-20],30),maximax,maximay,flux,sharp,roundness,3.,5.,[-1.0,1.0],[0.2,1.0],/silent
maximax = maximax +20.
maximay = maximay +20.
IF total(size(maximax)) GT 0 THEN BEGIN
   maxima=[[maximax],[maximay]]
   sortinds=reverse(sort(flux))
   maxima=reform(maxima[sortinds[0],*])
ENDIF ELSE BEGIN
   maxima=[-1,-1]
ENDELSE
; if the input is the image of a standard, calculate the flux
; calibration factor and calibrate the standard
IF NOT keyword_set(stdimaname) THEN BEGIN

   IF total(maxima) GE 0. THEN BEGIN
      ;
      ; perfrom photometry
      ;
      aperrad=[30.]
      skyrad=[50.,70.] 
      aper,ima,maxima[0],maxima[1],adups,adupserr,sky,skyerr,1.,aperrad,skyrad,0.,/flux,/exact,/nan,/silent
      ;
      ; convert to appropiate units
      ;
      
      filter[*,0]=filter[*,0]*1e4 ; [um] -> [A]
      stdspec[*,0]=stdspec[*,0]*1e4   ; [um] -> [A]
      stdspec[*,1]=stdspec[*,1]*1e7*1e-4 ; [W cm-2 um-1] -> [erg s-1 cm-2 A-1]
      
      ;
      ; convolve theoretical spectrum of standard with filter pass-band
      ;
      fluxd=spfilconvolution(stdspec,filter,plamb=plamb)
      fluxd=fluxd*plamb^2./2.9979d18/1d-23 ;  [erg s-1 cm-2 A-1] -> [Jy]
      ;
      ; flux-calibration factor
      ;
      fluxcal=fluxd/adups
      flux=adups*fluxcal[0]
   	  aper,ima*fluxcal[0]*1000.,maxima[0],maxima[1],adups2,adupserr2,sky2,skyerr2,1.,aperrad,skyrad,0.,/flux,/exact,/nan,/silent
      aa = where(stdspec[*,0] gt 0.995*plamb and stdspec[*,0] lt 1.005*plamb)
      print, stdname,plamb*1.E-4,flux,fluxd,adups2*1.E-3,mean(stdspec[aa,1])*plamb^2./2.9979d18/1d-23,format = '("Standard HD",A10," at ",F6.1," microns ==>",F10.1,"  (template =",F10.1," and ",F10.1,") ",F10.1)'
   ENDIF ELSE BEGIN
      print,'##########  Warning: Fail to find the source. No flux-calibration performed!!!'
      fluxcal=0.
   ENDELSE; else if the input is the image of an object, load the flux-calibration factor from the standard
ENDIF ELSE BEGIN
   ;
   ; reading flux-calibration factor from standard
   ;
   stdima=readfits('OUTPUTS/'+stdimaname,stdimahead,/silent)
   fluxcal=fxpar(stdimahead,'FLUXCAL')

   IF total(maxima) GE 0. THEN BEGIN
      ;
      ; perfrom photometry
      ;
      aperrad=[10.]
      skyrad=[20.,25.]
      aper,ima,maxima[0],maxima[1],adups,adupserr,sky,skyerr,1.,aperrad,skyrad,0.,/flux,/exact,/nan,/silent

      flux=adups*fluxcal[0]
      
   ENDIF ELSE BEGIN
       print,'Fail to find the source. Flux not calculated.'
   ENDELSE

ENDELSE
;
; update header of the standard
;

IF keyword_set(stdimaname) THEN fxaddpar,imahead,'FCALSTD',stdimaname[0],' Standard used for flux-calibration'
fxaddpar,imahead,'FLUXCAL',fluxcal[0],' Flux-calibration factor: [Jy]/[ADU s-1]'
fxaddpar,imahead,'NAXIS3',1,' Number of positions along axis 3'
IF keyword_set(STDNAME) THEN BEGIN
    fxaddpar,imahead,'STDNAME',stdname[0] ,' Number of the calibration star (HD)'
ENDIF

;
; apply calibration and save modifyed files...
;
writefits,'OUTPUTS/FC_'+imaname,ima*fluxcal[0]*1000.,imahead
choose = 'yes'
endif else begin
print, 'WARNING!    ' , imaname, '  not an image!'
choose = 'no'
endelse
END
