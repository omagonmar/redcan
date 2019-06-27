PRO XtractMain, listname, prefix, calib_dir, target_ext, METHOD = method, SIGMAS = sigmas, $
    	NCOLAPSING = ncolapsing, RADIAL_PROFILE = radial_profile, OFFSET = offset, TEXTFILE = textfile, INSTRUMENT = instrume

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

check_fk = 'no'
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
readcol, 'PRODUCTS/ID1'+listname+'.lst',name_pos, object_name,grating, ra, dec, format = '(a, a,X,X,X,X,A,X, f, f)' , /silent
grating = strmid(strtrim(grating ,1),0,9)
readcol, 'PRODUCTS/AV_'+prefix+'_'+listname+'.dat', meanavfilename,mean_av0, mean_av1, format = '(A20,F10.2,F10.2)' , /silent

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
target_s= spectrum(*,*,2) - median(spectrum(*,*,2))
SPEdim =  n_elements(target_s(*,0))
nMwave=SPEdim

IF n_elements(radial_profile) gt 1 THEN BEGIN
    Master_starget= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,nMwave)
ENDIF ELSE BEGIN 
    Master_starget= fltarr(n_elements(TARGETS),n_elements(offset),2,nMwave)   
ENDELSE
Master_std= fltarr(n_elements(TARGETS),2,nMwave)   
Master_std_lost= fltarr(n_elements(TARGETS),n_elements(radial_profile),2,nMwave)   
;
; Going through every TARGET 
;


FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    ; This is the Master wavelength array to which all spectra will be interpolated 
    slit_chosen = grating(where(name_pos eq TARGETS(i)))
	meanav0 = reform(mean_av0[where(meanavfilename eq TARGETS(i))])
	meanav1 = reform(mean_av1[where(meanavfilename eq TARGETS(i))])
    if slit_chosen eq 'LowRes-10' then begin
		if instrume eq "TReCS" then begin
        	Master_wave=findgen(SPEdim)*222.+72000. ; for N-band
        endif else begin
        	Master_wave=findgen(SPEdim)*190.656+72000. ; for N-band
        	;Master_wave=findgen(SPEdim)*float(meanav1[0])+float(meanav0[0]) ; for N-band
    	endelse
    endif else begin
    	Master_wave=findgen(SPEdim)*280.+160000.  ; for Q-band
    endelse
	
psinit, /color, /silent
    ;
    ; Reading target and associated standard
    ;
    spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+TARGETS(i),hdr_target,/silent)
    target_s= spectrum(*,*,2) - median(spectrum(*,*,2))
    target_c= spectrum(*,*,3)
    spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+STANDARDS(i),hdr_std,/silent)
    std_s= spectrum(*,*,2)- median(spectrum(*,*,2))
    std_c= spectrum(*,*,3)
    SPEdim =  n_elements(target_s(*,0))
    
    ;
    ; Determining the trace for the standard  
    ;
    name_std = strmid(STANDARDS(i), 0 , 14)
    xvec= findgen(SPEdim)
    TRCTRA = fxpar(hdr_std, "TRCTRA")
    TRCTRB = fxpar(hdr_std, "TRCTRB")
     center_trace_std =  xvec* TRCTRA  + TRCTRB
    TRHWHMA = fxpar(hdr_std, "TRFWHMA")
    TRHWHMB = fxpar(hdr_std, "TRFWHMB")
    TRHWHMC = fxpar(hdr_std, "TRFWHMC")
    width_trace_std = ((xvec*xvec) * TRHWHMA + xvec* TRHWHMB  + TRHWHMC)
    ;
    ;
    ; Determining the central posi (2.^(iternumber)) *tion of the target
    ;
    name_target = strmid(TARGETS(i), 0 , 14)
    TRCTRA = fxpar(hdr_target, "TRCTRA")
    TRCTRB = fxpar(hdr_target, "TRCTRB")
    center_trace_t = xvec* TRCTRA  + TRCTRB
    TRHWHMA = fxpar(hdr_target, "TRFWHMA")
    TRHWHMB = fxpar(hdr_target, "TRFWHMB")
    TRHWHMC = fxpar(hdr_target, "TRFWHMC")
    width_trace_t = ((xvec*xvec) * TRHWHMA + xvec* TRHWHMB  + TRHWHMC)
    onoff = target_s
    loadct,6, NCOLORS=100
    plot, indgen(n_elements(onoff(0,*))),indgen(n_elements(onoff(*,0))),$
    	/nodata,position=[0.1,0.1,0.95,0.95],/normal,/xstyle, /ystyle,xrange=[0.,n_elements(onoff(*,0))],$
    	yrange=[0.,n_elements(onoff(0,*))],xtitle="X axis (pixels)",ytitle="Y axis (pixels)"
    contour, onoff,nlevels=100,/Noerase,/data,/fill,position =[0.1,0.1,0.95,0.95],/xstyle, /ystyle,$
    	xrange=[0.,n_elements(onoff(*,0))],yrange=[0.,n_elements(onoff(0,*))],c_colors=indgen(100),$
    	min_value=1.*min(onoff[100:200,50:200]),max_value=1.*max(onoff[100:200,50:200])
    if method eq 1 then begin 
    	oplot, indgen(SPEdim), center_trace_t ,linestyle = 2, thick = 4
    	oplot, indgen(SPEdim), center_trace_t - width_trace_t,linestyle = 0, thick = 4
    	oplot, indgen(SPEdim), center_trace_t + width_trace_t,linestyle = 0, thick = 4
    endif
    xyouts,0.1,0.97,"Spectrum and Trace of "+TARGETS(i),/normal,charsize=1.3    
    ;
    ; Taking slit_losses from header
    ;
    slit_loss = 1.*(fxpar(hdr_std, "SLITCORR"))
    ;
    ; Loading Extension of the source
    ;
    name = object_name(WHERE(name_pos eq TARGETS(i)))
    TARGET_EXT = extension(WHERE(extname eq name(0)))
    TARGET_EXT = TARGET_EXT(0)
    ;
    ; Interpolation of images
    ; 
    target_c = SubPiX(target_c, ITERNUMBER = iternumber)
    target_s = SubPiX(target_s, ITERNUMBER = iternumber, /SCALE_MAX)
    std_c = SubPiX(std_c, ITERNUMBER = iternumber)
    std_s = SubPiX(std_s, ITERNUMBER = iternumber, /SCALE_MAX)
    
    IF n_elements(radial_profile) GT 1 THEN BEGIN
    	starget = fltarr(n_elements(radial_profile), 2, nMwave)
    ENDIF ELSE BEGIN
	starget = fltarr(n_elements(offset), 2, nMwave)
    ENDELSE
    sstd_lost = fltarr(n_elements(radial_profile), 2, nMwave)
    ;
    ; Three times the width trace for the STANDARD 
    ;
    print, STANDARDS(i), mean(center_trace_std -  4.*width_trace_std) , mean(center_trace_std + 4.*width_trace_std)
    
    sstd = Xtract(std_s , std_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = 4.*width_trace_std, WAVEARR=Master_wave)
    sstd(1,*) = median(reform(sstd(1,*)),3) 
    IF method eq 0 THEN BEGIN   
    	;
    	; Fixed aperture
    	;
	n = 0
	FOR j = 0 , n_elements(radial_profile) -1 DO BEGIN
    	    FOR k = 0, n_elements(offset) -1 DO BEGIN
    	    	print,'Extraction #',n+1, TARGETS(i), mean(center_trace_t+offset(k) - radial_profile(j)) , mean(center_trace_t+offset(k) + radial_profile(j)),$
		    format ='(A20,I5,A20,F10.2,F10.2)'
    	    	starget(n,*,*) = Xtract(target_s , target_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_t+offset(k), WIDTH_TRACE = replicate(radial_profile(j), n_elements(center_trace_t)), WAVEARR=Master_wave)
	    	    ;starget(n,1,*) = median(reform(starget(n,1,*)),3)
    	    	oplot, indgen(SPEdim), center_trace_t +offset(k),linestyle = 2, thick = 4, color = 200
    	        oplot, indgen(SPEdim), center_trace_t+offset(k) - radial_profile(j),linestyle = 0, thick = 4, color = 200
    	    	oplot, indgen(SPEdim), center_trace_t+offset(k) + radial_profile(j),linestyle = 0, thick = 4, color = 200	
		n = n+1
	    ENDFOR
	    sstd_lost(j,*,*) = Xtract(std_s , std_c,ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = replicate(radial_profile(j), n_elements(center_trace_t)), WAVEARR=Master_wave) 
		sstd_lost(j,1,*) = median(reform(sstd_lost(j,1,*)),3) 
	ENDFOR
    ENDIF ELSE BEGIN
    	;
    	; Radial increasement of the aperture as the associated standard
    	;
	n = 0
	FOR j = 0 , n_elements(radial_profile) -1 DO BEGIN
    	    FOR k = 0, n_elements(offset) -1 DO BEGIN
    	    	print,'Extraction #',n+1, TARGETS(i), mean(center_trace_t+offset(k) - radial_profile(j)* width_trace_std) , mean(center_trace_t+offset(k) + radial_profile(j)* width_trace_std),$
		    format ='(A20,I5,A20,F10.2,F10.2)'
	    	starget(n,*,*) = Xtract(target_s , target_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_t+offset(k), WIDTH_TRACE = float(radial_profile(j))* width_trace_std, WAVEARR=Master_wave)    	    
    	    ;starget(n,1,*) = median(reform(starget(n,1,*)),3)
    	        oplot, indgen(SPEdim), center_trace_t+offset(k) - radial_profile(j)* width_trace_std,linestyle = 0, thick = 4, color = 200
    	    	oplot, indgen(SPEdim), center_trace_t+offset(k) + radial_profile(j)* width_trace_std,linestyle = 0, thick = 4, color = 200		
    	    	oplot, indgen(SPEdim), center_trace_t +offset(k),linestyle = 0, thick = 6, color = 0
    	    	n = n+1
	    ENDFOR
    	sstd_lost(j,*,*) = Xtract(std_s , std_c, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace_std, WIDTH_TRACE = radial_profile(j)* width_trace_std, WAVEARR=Master_wave)
		sstd_lost(j,1,*) = median(reform(sstd_lost(j,1,*)),3) 
	ENDFOR
    ENDELSE
    ;
    ; Saving results and correcting for slit_losses
    ;
    Master_starget(i,*,*,*) =  starget
    Master_std(i,*,*) = sstd
    Master_std_lost(i,*,*,*) =  sstd_lost
    IF TARGET_EXT eq 1 THEN BEGIN 
    Master_starget(i,*,1,*) = slit_loss * starget(*,1,*)
    ;Master_starget(i,*,1,*) = starget(*,1,*)
    
    ENDIF
    ;Master_std_lost(i,*,1,*) =   slit_loss * sstd_lost(*,1,*)
    Master_std_lost(i,*,1,*) =   sstd_lost(*,1,*)
	;Master_std(i,1,*) = slit_loss *sstd(1,*)
    Master_std(i,1,*) = sstd(1,*)
    
    print, "File...   ", TARGETS(i), ": DONE   "
    psterm, file = "PRODUCTS/Specs_m"+strtrim(string(method),1)+"_"+prefix+"_"+strmid(TARGETS(i),0,14)+".ps", /noplot
ENDFOR ; i,TARGETS

psinit, /color, /silent
loadct,6
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    n = 0
    FOR j = 0,n_elements(RADIAL_PROFILE) -1 DO BEGIN
	FOR k = 0, n_elements(OFFSET) -1 DO BEGIN
    	    IF TARGET_EXT eq 0 THEN Master_starget(i,n,1,*) = Master_starget(i,n,1,*) *  Master_std(i,1,*) / Master_std_lost(i,j,1,*)
    	    n = n +1
	ENDFOR
    ENDFOR
ENDFOR    
;
; Extraction positions and date for each observation
;
readcol, 'PRODUCTS/ID1'+listname+'.lst',name_pos, object_name,ra, dec, format = '(a, a,X,X,X,X,X,X, f, f)' , /silent
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
    aux3 = where(name_date eq TARGETS(i))
    name_target(i) = object_name(aux1)
    filename_target(i) = name_pos(aux1)
    ra_target(0,i) = ra(aux1)
    dec_target(0,i) = dec(aux1)
    date_target(0,i) = date(aux3)
    printf,1,name_pos(aux1),object_name(aux1),ra(aux1),dec(aux1),date(aux3),format = '(A20,A20,F10.3,F10.3, A20)'
    aux1 = where(name_pos eq STANDARDS(i))
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
;
; Flux calibration for each target observation
;
readcol, 'PRODUCTS/redshifts_'+listname+'.lst',zname, redshifts, format = '(A,F)', /silent
name_std = strarr(n_elements(STANDARDS))
FOR i = 0, n_elements(TARGETS) -1 DO BEGIN
    aux2 = WHERE(abs(ra_cat - ra_target(1,i)) eq min(abs(ra_cat - ra_target(1,i)))  and abs(dec_cat - dec_target(1,i)) eq min(abs(dec_cat - dec_target(1,i))))
    IF aux2(0) ge 0 THEN BEGIN
    	name_std(i) = HD(aux2) 
    	print, STANDARDS(i) , HD(aux2), format = '(A25," file was identified as the Standard HD" ,A10)'
    ENDIF ELSE BEGIN 
     	print, STANDARDS(i) , format = '(A25," file was NOT identified as a Cohen Standard!" )'
    	print, "##### Warning!! No good Calibration will be performed for the object:   " + TARGETS(i)
    	print, "##### Warning!! Using HD00001!!!"
	name_std(i) = '00001'
    ENDELSE
    	;
    	; Reading Standard's theoretical spectrum
    	;
    	readcol, calib_dir + "/templates/HD" + name_std(i) + ".tem", xth, yth, erth, format = '(f,f,f)',/silent
	erth = erth /yth  
    ;
    ; Interpolation the theoretical to the observed standard
    ;
    xth = 1.E4 * xth
    yth = INTERPOL(yth,  xth , Master_std(i,0,*))
    erth = INTERPOL(erth,  xth , Master_std(i,0,*))
    xth = Master_std(i,0,*)
    ;
    ; Computing ratio between theoretical and observed standard
    ;
;    coc = reform(reform(yth) / reform(median(reform(Master_std(i,1,*)),2)) )
    coc = reform(yth / Master_std(i,1,*))
    ;
    ; Calibrating the spectrum of the target
    ;
    spec = fltarr(n_elements(Master_starget(0,*,0,0)),n_elements(Master_std(0,1,*)))
    FOR j = 0,  n_elements(spec(*,0)) -1 DO spec(j,*) = (1.E3*xth^2./3.e18/1.e-23) * Master_starget(i,j,1,*) * coc     
    ;IF check_fk eq 'yes' then oplot,Master_std(i,0,*)*1.E-4,spec(0,*),  linestyle = 0
    ;
    ; Saving final spectrum
    ;
    formati='(F20.6'
    FOR j = 0, n_elements(spec(*,0)) -1 DO formati = formati+',F20.6, F20.6'
    formati = formati +')'
    formati2='(F20.6'
    FOR j = 0, n_elements(spec(*,0)) -1 DO formati2 = formati2+',F20.6'
    formati2 = formati2 +')'
    theorfluxerr = 0.0
    spec_matrix = fltarr(n_elements(xth), 2*n_elements(spec(*,0))  )
    openw,1, "OUTPUTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(TARGETS(i), 0 , 14)+'.dat'
    openw,2, "OUTPUTS/SpecErr_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(TARGETS(i), 0 , 14)+'.dat'
	FOR j = 0 , n_elements(xth)-1 DO BEGIN	
	    specerr = fltarr(n_elements(Master_starget(i,*,1,j)))
	    FOR l = 0, n_elements(Master_starget(i,*,1,j)) -1 do begin 
	    	if Master_std(i,1,j) gt 0. and Master_starget(i,l,1,j) gt 0. then begin 
	    	    specerr(l) =  spec(l,j) * ( (1./sqrt(Master_std(i,1,j))) + theorfluxerr + erth(j) +  (1./sqrt(Master_starget(i,l,1,j))))
	    	endif else begin
		    specerr(l) = 999.
		endelse
	    endfor
	    printf,1, xth(j), spec(*,j), Master_starget(i,*,1,j), format = formati
	    printf,2, xth(j), specerr(*), format = formati2
	    spec_matrix(j,*) = [ reform(spec(*,j)),reform(Master_starget(i,*,1,j))]
	ENDFOR    
    close,1
    close,2
    print, "Saving final spectrum  : " , "OUTPUTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(TARGETS(i), 0 , 14)+'.dat'
    
    slit_chosen = reform(grating(where(name_pos eq TARGETS(i))))
    ; Saving in fits format
    
    mkhdr,hdr_matrix,reform(spec_matrix)
    hdr_target = headfits('OUTPUTS/WLC_stck_'+TARGETS(i), ext=0, /silent)
    if instrume eq "TReCS" then begin
		readcol,calib_dir + '/hdrTRECs.lst',listhdr,format = '(A)'
    endif else begin
		readcol,calib_dir + '/hdrCC.lst',listhdr,format = '(A)'
    endelse
    for ll = 0, n_elements(listhdr) -1 do begin
    	kkadd = FXPAR(hdr_target, listhdr(ll),COMMENT=KKCOMMENT)
    	FXADDPAR, hdr_matrix,listhdr(ll), kkadd,KKCOMMENT
    endfor
    ;RA      =  FXPAR(hdr_target, "RA")
    ;DEC     =  FXPAR(hdr_target, "DEC")
    ;EXPTIME =  FXPAR(hdr_target, "EXPTIME") 
    ;instrume = FXPAR(hdr_target, "INSTRUME")
    ;FXADDPAR, hdr_matrix, "OBJECT",name_target(i)
    ;FXADDPAR, hdr_matrix, "RA", RA
    ;FXADDPAR, hdr_matrix, "DEC", DEC
    ;FXADDPAR, hdr_matrix, "EXPTIME", EXPTIME
    ;FXADDPAR, hdr_matrix, "FILENAME", targets(i)
    ;FXADDPAR, hdr_matrix, "INSTRUME", instrume
    ;FXADDPAR, hdr_matrix, "GRATING", slit_chosen(0)
    
    
    FXADDPAR, hdr_matrix, "CRVAL1", xth(0)
    FXADDPAR, hdr_matrix, "CD1_1",  xth(1) - xth(0)
    FXADDPAR, hdr_matrix, "COMMENT", "##REDCAN   #######################################################################"
    FXADDPAR, hdr_matrix, "COMMENT", "##REDCAN   Develop: O.Gonzalez-Martin & T. Diaz Santos"
    FXADDPAR, hdr_matrix, "COMMENT", "##REDCAN  "
    
    readcol, textfile,aa, format = '(A50)'
    tmp = ''
    openr, lun, textfile, /get_lun
    for k=0,n_elements(aa) - 1 do begin 
    	readf, lun, tmp, format = '(A70)' ; skip header
    	FXADDPAR, hdr_matrix, "COMMENT", "##REDCAN :"+  tmp
    endfor	
    free_lun, lun
    FXADDPAR, hdr_matrix, "COMMENT", "##REDCAN    #######################################################################"
    writefits,'Spec_m'+strtrim(string(method),1)+"_"+TARGETS(i), spec_matrix, hdr_matrix
    
    ;
    ; Saving associated calibration
    ;
    openw,1, "OUTPUTS/Cal_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(STANDARDS(i), 0 , 14)+'.dat'
    	FOR j = 0 , n_elements(xth)-1 DO printf,1, xth(j), Master_std(i,1,j), float(coc(j))*1.E18, format = '(F14.1,F20.7,F20.7)'
    close,1
    print, "Saving calibration file  : " , "OUTPUTS/Cal_m"+strtrim(string(method),1)+"_"+prefix+'_'+strmid(STANDARDS(i), 0 , 14)+'.dat'
    ;
    ; Find redshift
    ;
    redshift = redshifts(WHERE(zname eq name_target(i) ))
    xth = xth * (1. - redshift(0))
    ; 
    ; Plotting
    ;
    if slit_chosen eq 'LowRes-10' then begin
        aux= where(xth gt 10.E4 and xth lt 13.E4);  for N-band 
    endif else begin
    	aux= where(xth gt 8.E4 and xth lt 35.E4);  for Q-band 
    endelse
    
    !p.multi = [0, 1, 3]
    yran = [0., median(Master_std(i,1,aux)) + 5.*stddev(Master_std(i,1,aux))]
    plot,  1.E-4*xth, Master_std(i,1,*), color = 0, thick = 3, /ystyle, /xstyle, $
    	title = "Standard: HD" + name_std(i)+ " ( " + filename_std(i)+ " ) and object "+ name_target(i) + " ( " + filename_target(i)+ " )",  $
;    	xtitle = textoidl('Wavelength (\mum)', font = -1), ytitle = "Spectrum (adu/s)",charsize = 1.5, yrange = yran
    	xtitle = 'Wavelength (um)', ytitle = "Spectrum (adu/s)",charsize = 1.5, yrange = yran
    FOR j = 0,  n_elements(spec(*,0)) -1 DO oplot, 1.E-4*xth, Master_starget(i,j,1,*), color =  50*(j+1), thick =3, linestyle =2
    if slit_chosen eq 'LowRes-10' then begin
        aux= where(xth gt 10.E4 and xth lt 12.E4);  for N-band 
    endif else begin
    	aux= where(xth gt 8.E4 and xth lt 35.E4);  for Q-band 
    endelse
    yran = [median(coc(aux)) -4.*stddev(coc(aux)), median(coc(aux)) + 30.*stddev(coc(aux))]
    plot,  1.E-4*xth, coc, color = 0, thick = 3, /ystyle, /xstyle, yrange = yran,$
;    	xtitle = textoidl('Wavelength (\mum)', font = -1), ytitle = "Irradiance per adu/s (w/cm2/um/adu/s)",charsize = 1.5, /ylog
    	xtitle = 'Wavelength (um)', ytitle = "Irradiance per adu/s (w/cm2/um/adu/s)",charsize = 1.5, /ylog
    if slit_chosen eq 'LowRes-10' then begin
        aux= where(xth gt 10.E4 and xth lt 12.E4);  for N-band 
    endif else begin
    	aux= where(xth gt 8.E4 and xth lt 35.E4);  for Q-band 
    endelse

    yran = [0.9*min(spec(*,aux)), 1.1*max(spec(*,aux))]
    plot,  1.E-4*xth, spec(0,*), color = 0, thick = 3, /ystyle, /xstyle, yrange =  yran ,$
;    	xtitle = textoidl('Wavelength (\mum)', font = -1), ytitle =  textoidl('F_{\nu} (Jy)', font = -1),charsize = 1.5,/nodata
    	xtitle = 'Wavelength (um)', ytitle =  'F (Jy)',charsize = 1.5,/nodata
    FOR j = 0,  n_elements(spec(*,0)) -1 DO oplot,  1.E-4*xth, spec(j,*), color = 50*(j+1), thick = 3
    !p.multi = 0

    if slit_chosen eq 'LowRes-10' then begin
    	xrang = [8.,13.]
    endif else begin
    	xrang = [16., 25.]
    endelse
    plot,  1.E-4*xth, spec(0,*), color = 0, thick = 3, /ystyle, /xstyle, yrange = yran ,xrange = xrang,$
;    	xtitle = textoidl('Wavelength (\mum)', font = -1) , ytitle = textoidl('F_{\nu} (Jy)', font = -1),charsize = 1.5,/nodata
    	xtitle = 'Wavelength (um)' , ytitle = 'F (Jy)',charsize = 1.5,/nodata
    if slit_chosen eq 'LowRes-10' then begin
        aux= where(xth gt 10.E4 and xth lt 12.E4);  for N-band 
    endif else begin
    	aux= where(xth gt 8.E4 and xth lt 35.E4);  for Q-band 
    endelse
    FOR j = 0,  n_elements(spec(*,0)) -1 DO begin
    	oplot,  1.E-4*xth, spec(j,*), color = 50*(j+1), thick = 3,linestyle = j
	oplot,  [0.2,0.25] * (max(1.E-4*xth(aux))) +min(1.E-4*xth(aux)), ([0.95,0.95] - 0.025*(j))*yran(1), linestyle = j, thick = 5, color = 50*(j+1)
	xyouts,[0.12] * (max(1.E-4*xth(aux))) +min(1.E-4*xth(aux)), ([0.95] - 0.025*(j))*yran(1) , "Extract #" + strtrim(string(j+1),1),color =  50*(j+1), /data
    ENDFOR 
    ;
    ; plotting tentative lines... 
    ;
    tentative_lines = [8.6,10.51, 11.3, 12.81]
    tentative_names = ["PAH","[S IV]","PAH","[Ne II]"]
    FOR k = 0,n_elements(tentative_lines) -1 DO oplot, [tentative_lines(k),tentative_lines(k)], yran,linestyle = 2, thick =2
    xyouts, tentative_lines - 0.1, replicate(1.01*yran(1),n_elements(tentative_lines)), tentative_names, /data 
ENDFOR
psterm, file = "PRODUCTS/Specs_m"+strtrim(string(method),1)+"_"+prefix+"_logs.ps", /noplot

END
