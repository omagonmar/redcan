PRO XtractMain, listname, prefix, calib_dir, target_ext, METHOD = method, SIGMAS = sigmas, $
    	NCOLAPSING = ncolapsing, RADIAL_PROFILE = radial_profile, OFFSET = offset

;
;   IDL code to perform the spectral extraction according to the following criteria:
;   	
;   
;
;   Previous:	    XtractPlot
;   After:  	    
;
;   Dependences:    Xtract WLtrace psinit psterm colorbar
;
;   Author: 	    O. Gonzalez-Martin (25th March 2011)
;   	    	    Change 11th May 2011: The trace calculation (WLtrace.pro) have been taken out to MainTrace.pro

;
; Definitions
;
Diameter_telescope = 8.
iternumber = 3
Cvalue = 1.e-4/(Diameter_telescope*1.e6)*206265./0.0896 ; [lambdas um] / [Telescope diameter um]  * [arcsec in 2!pi] / [arcsec /pixel]
;
; NO MORE THAN ONE APERTURE IS ALLOWED IF MORE THAN ONE OFFSET IS INTRODUCED
;
IF n_elements(OFFSET) gt 1 THEN BEGIN
    IF n_elements(radial_profile) gt 1 THEN BEGIN
    	print, "Warning: NO MORE THAN ONE APERTURE IS ALLOWED IF MORE THAN ONE OFFSET IS INTRODUCED. SELECTING ONLY THE FIRST APERTURE."
    	radial_profile = radial_profile(0)
    ENDIF
ENDIF

readcol, 'PRODUCTS/Extension_'+listname+'.lst', Extname, extension, format = '(A,I)', /silent 
readcol, 'PRODUCTS/ID1'+listname+'.lst',name_pos, object_name,ra, dec, format = '(a, a,X,X,X,X,X,X, f, f)' , /silent
;
; Selecting targets and standards
;
readcol, 'PRODUCTS/id'+listname+'.lst', filename, tsa, si, acq, std, format = '(A,A,A,A,A)', /silent 
TARGETS = filename(where(tsa eq "TARGET" and si eq "SPECTRUM"))
STANDARDS = std(where(tsa eq "TARGET" and si eq "SPECTRUM"))
print, ""
print, "The association of the spectrum and standard is done as follows:"
print, ""
FOR i = 0, n_elements(TARGETS) -1 DO print, targets(i), standards(i), format = '("Target:  ",A," asssociated to:  ",A)'

spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+TARGETS(0),hdr_target,/silent)
target_s= spectrum(*,*,2)
SPEdim =  n_elements(target_s(*,0))
IF n_elements(radial_profile) gt 1 THEN BEGIN
    Master_starget= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,SPEdim)
ENDIF ELSE BEGIN 
    Master_starget= fltarr(n_elements(TARGETS),n_elements(offset),2,SPEdim)   
ENDELSE
Master_std= fltarr(n_elements(TARGETS),2,SPEdim)   
Master_std_lost= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,SPEdim)   
;
; Going through every TARGET 
;
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    ;
    ; Reading target and associated standard
    ;
    spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+TARGETS(i),hdr_target,/silent)
    target_s= spectrum(*,*,2)
    target_c= spectrum(*,*,3)
    spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+STANDARDS(i),hdr_std,/silent)
    std_s= spectrum(*,*,2)
    std_c= spectrum(*,*,3)
    SPEdim =  n_elements(target_s(*,0))
;    minim_cal = min(target_c)
;    maxim_cal = max(target_c)
;    vec = (maxim_cal-minim_cal)*findgen(SPEdim)/SPEdim + minim_cal

    ;
    ; Determining the trace for the standard  
    ;
    name_std = strmid(STANDARDS(i), 0 , 14)
    xvec= findgen(SPEdim)
    TRCTRA = fxpar(hdr_std, "TRCTRA")
    TRCTRB = fxpar(hdr_std, "TRCTRB")
    center_trace_std = xvec* TRCTRA  + TRCTRB
    TRFWHMA = fxpar(hdr_std, "TRFWHMA")
    TRFWHMB = fxpar(hdr_std, "TRFWHMB")
    width_trace_std = ( xvec* TRFWHMA  + TRFWHMB) ; FWHM / 2.35
    ;
    ;
    ; Determining the central posi (2.^(iternumber)) *tion of the target
    ;
    name_target = strmid(TARGETS(i), 0 , 14)
    TRCTRA = fxpar(hdr_target, "TRCTRA")
    TRCTRB = fxpar(hdr_target, "TRCTRB")
    center_trace_t = xvec* TRCTRA  + TRCTRB
    TRFWHMA = fxpar(hdr_target, "TRFWHMA")
    TRFWHMB = fxpar(hdr_target, "TRFWHMB")
    width_trace_t = ( xvec* TRFWHMA  + TRFWHMB) ; FWHM / 2.35
;    IF NOT keyword_set(EXTRACT_SIZE) OR extract_size LT 0 THEN  extract_size = mean(width_trace_t) 
    ;
    ; Taking slit_losses from header
    ;
    slit_loss = 1.*(fxpar(hdr_std, "SLITCORR"))
    ;
    ; Loading Extension of the source
    ;
    name = object_name(WHERE(name_pos eq TARGETS(i)))
    TARGET_EXT = extension(WHERE(extname eq name(0)))
    ;
    ; Interpolation of images
    ;
    target_c = SubPiX(target_c, ITERNUMBER = iternumber)
    target_s = SubPiX(target_s, ITERNUMBER = iternumber, /SCALE_MAX)
    std_c = SubPiX(std_c, ITERNUMBER = iternumber)
    std_s = SubPiX(std_s, ITERNUMBER = iternumber, /SCALE_MAX)
    
    IF n_elements(radial_profile) GT 1 THEN BEGIN
    	starget = fltarr(n_elements(radial_profile), 2, SPEdim)
    ENDIF ELSE BEGIN
	starget = fltarr(n_elements(offset), 2, SPEdim)
    ENDELSE
    sstd_lost = fltarr(n_elements(radial_profile), 2, SPEdim)
    ;
    ; Three times the width trace for the STANDARD 
    ;
    sstd = Xtract(std_s , std_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = 6.*width_trace_std)

    IF method eq 0 THEN BEGIN   
    	;
    	; Fixed aperture
    	;
	n = 0
	FOR j = 0 , n_elements(radial_profile) -1 DO BEGIN
    	    FOR k = 0, n_elements(offset) -1 DO BEGIN
    	    	starget(n,*,*) = Xtract(target_s , target_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_t+offset(k), WIDTH_TRACE = replicate(radial_profile(j), n_elements(center_trace_t)))
    	    	n = n+1
	    ENDFOR
	    sstd_lost(j,*,*) = Xtract(std_s , std_c,ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = replicate(radial_profile(j), n_elements(center_trace_t))) 
	ENDFOR
    ENDIF ELSE BEGIN
    	;
    	; Radial increasement of the aperture as the associated target
    	;
	n = 0
	FOR j = 0 , n_elements(radial_profile) -1 DO BEGIN
    	    FOR k = 0, n_elements(offset) -1 DO BEGIN
	    	starget(n,*,*) = Xtract(target_s , target_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_t+offset(k), WIDTH_TRACE = radial_profile(j)* width_trace_std)
    	    	n = n+1
	    ENDFOR
    	    sstd_lost(j,*,*) = Xtract(std_s , std_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = radial_profile(j)* width_trace_std)
	ENDFOR
    ENDELSE
    ;
    ; Saving results and correcting for slit_losses
    ;
    
    Master_starget(i,*,*,*) =  starget
    Master_std(i,*,*) = sstd
    Master_std_lost(i,*,*,*) =  sstd_lost
    IF TARGET_EXT eq 0 THEN BEGIN 
       Master_starget(i,*,1,*) = slit_loss * starget(*,1,*)
    ENDIF
    Master_std(i,1,*) = slit_loss *sstd(1,*)
    Master_std_lost(i,*,1,*) =   slit_loss * sstd_lost(*,1,*)
    print, "File...   ", TARGETS(i), ": DONE   "
ENDFOR
;
; Cutting spectra 
;
cute = WHERE(Master_starget(0,0,0,*) gt 7.8E4 and Master_starget(0,0,0,*) lt 13.1E4)
wv_sel  = Master_starget(0,0,0,cute)
;
;  Interpolating all to the first target
;
print, "Interpolating all the spectra to the first one"
IF n_elements(radial_profile) gt 1 THEN BEGIN
    Master_starget2= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,n_elements(wv_sel))   
ENDIF ELSE BEGIN 
    Master_starget2= fltarr(n_elements(TARGETS),n_elements(offset),2,n_elements(wv_sel))   
ENDELSE
Master_std2= fltarr(n_elements(TARGETS),2,n_elements(wv_sel))   
Master_std_lost2= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,n_elements(wv_sel))   
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    Master_std2(i,1,*) = INTERPOL( Master_std(i,1,*) , Master_std(i,0,*) , wv_sel)
    Master_std2(i,0,*) = wv_sel
    n = 0
    FOR j = 0,n_elements(RADIAL_PROFILE) -1 DO BEGIN
	FOR k = 0, n_elements(OFFSET) -1 DO BEGIN
	    Master_starget2(i,n,1,*) = INTERPOL( Master_starget(i,n,1,*) , Master_starget(i,n,0,*) , wv_sel)
    	    Master_starget2(i,n,0,*) = wv_sel
	    Master_std_lost2(i,j,1,*) = INTERPOL( Master_std_lost(i,j,1,*) , Master_std_lost(i,j,0,*) , wv_sel)
    	    Master_std_lost2(i,j,0,*) = wv_sel
    	    IF TARGET_EXT eq 0 THEN Master_starget2(i,n,1,*) = Master_starget2(i,n,1,*) *  Master_std2(i,1,*) / Master_std_lost2(i,j,1,*)
    	    n = n +1
	ENDFOR
    ENDFOR
ENDFOR    
Master_std = Master_std2
Master_starget = Master_starget2

;
; Extraction positions and date for each observation
;
readcol, 'PRODUCTS/ID1'+listname+'.lst',name_pos, object_name,ra, dec, format = '(a, a,X,X,X,X,X,X, f, f)' , /silent
readcol, 'PRODUCTS/ID3'+listname+'.lst',name_exp, time1, time2, format = '(a, X,X,X,X,X,X, f, f)', /silent
readcol, 'PRODUCTS/ID2'+listname+'.lst', name_date, date, format = '(a,x,a )', /silent
ra_target = fltarr(2,n_elements(TARGETS))
dec_target = fltarr(2,n_elements(TARGETS))
date_target = strarr(2,n_elements(TARGETS))
name_target = strarr(n_elements(TARGETS))
filename_target = strarr(n_elements(TARGETS))
filename_std = strarr(n_elements(TARGETS))
openw,1, "PRODUCTS/Spec_positions.lst"
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    aux1 = where(name_pos eq TARGETS(i))
    aux2 = where(name_exp eq TARGETS(i))
    aux3 = where(name_date eq TARGETS(i))
    name_target(i) = object_name(aux1)
    filename_target(i) = name_pos(aux1)
    ra_target(0,i) = ra(aux1)
    dec_target(0,i) = dec(aux1)
    date_target(0,i) = date(aux3)
    printf,1,name_pos(aux1),object_name(aux1),ra(aux1),dec(aux1),date(aux3),format = '(A20,A20,F10.3,F10.3, A20)'
    aux1 = where(name_pos eq STANDARDS(i))
    aux2 = where(name_exp eq STANDARDS(i))
    aux3 = where(name_date eq STANDARDS(i))
    ra_target(1,i) = ra(aux1)
    dec_target(1,i) = dec(aux1)
    filename_std(i) = name_pos(aux1)
    date_target(1,i) = date(aux3)
ENDFOR
close,1
print, " "
print, "Selection of targets and standards: "
print, " "
FOR i = 0, n_elements(ra_target(0,*)) -1 DO print,"TARGET   :", TARGETS(i), ra_target(0,i), dec_target(0,i), date_target(0,i), format = '(A20, A20, F10.2,F10.2,A20)'
FOR i = 0, n_elements(ra_target(0,*)) -1 DO print,"STANDARD :", STANDARDS(i), ra_target(1,i), dec_target(1,i), date_target(1,i), format = '(A20, A20, F10.2,F10.2,A20)'
;
; Identifiying the standard's name
;
readcol, 'Cohen_coord.lst', HD, rah, ram,ras, decg,decm,decs, format = '(a,f,f,f,f,f,f)', /silent
ra_cat =  360.*(rah + (ram/60.) + (ras /3600. ))/24.
dec_cat = fltarr(n_elements(ra_cat))
FOR i = 0, n_elements(dec_cat) -1 DO IF decg(i) gt 0. then dec_cat(i) = decg(i) + (decm(i)/60.  + decs(i)/3600.) else dec_cat(i) = decg(i) - (decm(i)/60.  + decs(i)/3600.)

psinit, /color
loadct,6
!p.multi = [0, 1, 3]
;
; Flux calibration for each target observation
;
name_std = strarr(n_elements(STANDARDS))
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    aux2 = WHERE(abs(ra_cat - ra_target(1,i)) eq min(abs(ra_cat - ra_target(1,i)))  and abs(dec_cat - dec_target(1,i)) eq min(abs(dec_cat - dec_target(1,i))))
    name_std(i) = HD(aux2)
    print, STANDARDS(i) , HD(aux2), format = '(A25," file was identified as the Standard HD" ,A10)'
    ;
    ; Reading Standard's theoretical spectrum
    ;
    readcol, calib_dir + "/templates/HD" + name_std(i) + ".tem", xth, yth, format = '(f,f)',/silent
    ;
    ; Interpolation the theoretical to the observed standard
    ;
    xth = 1.E4 * xth
    yth = INTERPOL(yth,  xth , Master_std(i,0,*))
    xth = Master_std(i,0,*)
    ;
    ; Computing ratio between theoretical and observed standard
    ;
    ;coc = fltarr(n_elements(Master_std(i,1,*)))
                                ;FOR m = 0 ,
                                ;n_elements(Master_std(i,1,*)) -1 DO
                                ;coc(m) = yth(m) / Master_std(i,1,m)
                                ;---> modified to:
    coc = reform(yth / Master_std(i,1,*))
    ;
    ; Calibrating the spectrum of the target
    ;
    spec = fltarr(n_elements(Master_starget(0,*,0,0)),n_elements(Master_std(0,1,*)))
    FOR j = 0,  n_elements(spec(*,0)) -1 DO spec(j,*) = (1.E3*xth^2./3.e18/1.e-23) * Master_starget(i,j,1,*) * coc
    ;
    ; Saving final spectrum
    ;
    formati='(F'
    FOR j = 0, n_elements(spec(*,0)) -1 DO formati = formati+', F'
    formati = formati +')'
    
    openw,1, "OUTPUTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(TARGETS(i), 0 , 14)+'.dat'
  	FOR j = 0 , n_elements(xth)-1 DO printf,1, xth(j), spec(*,j), format = formati
    close,1
    print, "Saving final spectrum  : " , "OUTPUTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(TARGETS(i), 0 , 14)+'.dat'
    ;
    ; Saving associated calibration
    ;
    openw,1, "OUTPUTS/Cal_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(STANDARDS(i), 0 , 14)+'.dat'
    	FOR j = 0 , n_elements(xth)-1 DO printf,1, xth(j), Master_std(i,1,j), coc(j), format = '(F,F,F)'
    close,1
    print, "Saving calibration file  : " , "OUTPUTS/Cal_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(STANDARDS(i), 0 , 14)+'.dat'
    ; 
    ; Plotting
    ;
    aux= where(xth gt 10.E4 and xth lt 12.E4)
    yran = [0., median(Master_std(i,1,aux)) + 10.*stddev(Master_std(i,1,aux))]
    plot,  1.E-4*xth, Master_std(i,1,*), color = 0, thick = 3, /ystyle, /xstyle, $
    	title = "Standard: HD" + name_std(i)+ " ( " + filename_std(i)+ " ) and object "+ name_target(i) + " ( " + filename_target(i)+ " )",  $
    	xtitle = "Wavelength (um)", ytitle = "Spectrum (adu/s)",charsize = 1.5, yrange = yran
    yran = [median(coc(aux)) -4.*stddev(coc(aux)), median(coc(aux)) + 25.*stddev(coc(aux))]
    plot,  1.E-4*xth, coc, color = 0, thick = 3, /ystyle, /xstyle, yrange = yran,$
    	xtitle = "Wavelength (um)", ytitle = "Irradiance per adu/s (w/cm2/um/adu/s)",charsize = 1.5, /ylog
    yran = [0., mean(spec(*,aux)) + 12.*stddev(spec(*,aux))]
    plot,  1.E-4*xth, spec(0,*), color = 0, thick = 3, /ystyle, /xstyle, yrange =  yran ,$
    	xtitle = "Wavelength (um)", ytitle = "Fv (Jy)",charsize = 1.5,/nodata
    FOR j = 0,  n_elements(spec(*,0)) -1 DO oplot,  1.E-4*xth, spec(j,*), color = 50*(j+1), thick = 3
ENDFOR
psterm, file = "PRODUCTS/Specs_m"+strtrim(string(method),1)+"_"+prefix+"_logs.ps", /noplot
END
