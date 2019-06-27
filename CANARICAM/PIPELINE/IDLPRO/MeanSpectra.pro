PRO MeanSpectra, prefix, method, infile, RADIAL_PROFILE = radial_profile, OFFSET = offset

;
;   IDL code to perform the combination of spectra for each source
;   	
;   
;
;   Previous:	    XtractMain
;   After:  	    
;
;   Dependences:    psinit psterm
;
;   Author: 	    O. Gonzalez-Martin (11th May 2011)
;   	    	    

;

IF n_elements(OFFSET) gt 1 THEN BEGIN
    IF n_elements(radial_profile) gt 1 THEN BEGIN
    	print, "Warning: NO MORE THAN ONE APERTURE IS ALLOWED IF MORE THAN ONE OFFSET IS INTRODUCED"
    	radial_profile = radial_profile(0)
    ENDIF
ENDIF
readcol, 'PRODUCTS/List_Spec_positions.lst', lists, format = '(A)', /silent
readcol, 'PRODUCTS/redshifts_'+infile+'.lst',zname, redshifts, format = '(A,F)', /silent
FOR i = 0 , n_elements(lists) -1 DO BEGIN
    readcol, 'PRODUCTS/'+lists(i),filename,name,ra,dec,date,format = '(A,A,F,F, A)', /silent
    print,"##########", strtrim(name(0),1)
    ;
    ; Find redshift
    ;
    redshift = redshifts(WHERE(zname eq name(0) ))
    ; 
    ; Determining the number of radii performed
    ;    
    IF n_elements(radial_profile) gt 1. THEN num = n_elements(radial_profile) ELSE num = n_elements(offset)
    ;
    ; Determining the length of the spectral direction
    ;
    readcol,  'OUTPUTS/Spec_m'+strtrim(string(method),1)+'_'+prefix+'_'+strmid(filename(0), 0 , 14)+'.dat' ,  xspec,yspec, format = '(D,D)',/silent
    length = n_elements(xspec)
    radii_xspec_mean= fltarr(length)
    radii_yspec_mean= fltarr(num,length)
    radii_cspec_mean= fltarr(num,length)
    radii_errspec_mean= fltarr(num,length)
    au=''
    au2 = ''
    FOR j = 1, num -1 DO au2 = au2+'X,'
    FOR j = 0, num -1 DO BEGIN
	IF j lt 1 THEN BEGIN  
	    formati = '(F,F,'+au2+'F)'
            formati2 = '(F,F)' 
	ENDIF ELSE BEGIN
	    au = au+'X,'
	    formati = '(F,'+au+'F,'+au2+'F)'
            formati2 = '(F,'+au+'F)'
    	ENDELSE
    	spec = fltarr(3, n_elements(filename), length)
        errspec = fltarr(n_elements(filename), length)
	FOR k = 0, n_elements(filename) -1 DO BEGIN
    	    readcol,  'OUTPUTS/Spec_m'+strtrim(string(method),1)+'_'+prefix+'_'+strmid(filename(k), 0 , 14)+'.dat' ,  xspec,yspec, cspec, format = formati,/silent
            readcol,  'OUTPUTS/SpecErr_m'+strtrim(string(method),1)+'_'+prefix+'_'+strmid(filename(k), 0 , 14)+'.dat' ,  xx,specerri, format = formati2,/silent
	    print,  'OUTPUTS/SpecErr_m'+strtrim(string(method),1)+'_'+prefix+'_'+strmid(filename(k), 0 , 14)+'.dat'
	    spec(0,k,*) =  xspec
    	    spec(1,k,*) =  yspec
    	    spec(2,k,*) =  cspec
	    errspec(k,*) = specerri
	ENDFOR
    	;
	; Computing mean value
	;
	xspec_mean = fltarr(length)
	yspec_mean = fltarr(length)
	cspec_mean = fltarr(length)
	errspec_mean = fltarr(length)
	FOR k = 0, length -1 DO BEGIN
	    xspec_mean(k) = spec(0,0,k)
	    yspec_mean(k) = mean(spec(1,*,k))
	    cspec_mean(k) = mean(spec(2,*,k))
            ll = where(errspec(*,k) lt 900.)
	    if ll(0) ge 0 then begin 
	    	if n_elements(ll) gt 1 then errspec_mean(k) = stddev(spec(1,ll,k))/sqrt(n_elements(ll)) else errspec_mean(k) = errspec(ll,k)
	    endif else begin 
	    	errspec_mean(k) = 999.
    	    endelse
	ENDFOR	    
	radii_xspec_mean=xspec_mean
	radii_yspec_mean(j,*)=yspec_mean;*1000.
	radii_cspec_mean(j,*)=cspec_mean
        radii_errspec_mean(j,*) = errspec_mean
    ENDFOR
    ;
    ;Shiftting to rest-frame
    ;
    radii_xspec_mean = radii_xspec_mean * (1.-redshift(0))
    if redshift(0) eq 0. then print, "WARNING!   Final spectrum of  ", name(0), " not in restframe or local!"
    ;
    ; Saving ascii file with mean spectrum
    ;
    formati='(F24.6'
    FOR j = 0, n_elements(radii_yspec_mean(*,0)) -1 DO formati = formati+',F24.6,F24.6,F24.6'
    formati = formati +')'
    openw,1, "OUTPUTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strtrim(name(0),1)+'.dat'
        FOR j = 0 , length - 1 DO printf,1, radii_xspec_mean(j), radii_yspec_mean(*,j), radii_errspec_mean(*,j), radii_cspec_mean(*,j), format = formati
    close,1
    ;
    ; Plotting final spectrum
    ;
    aut =  textoidl('F_{\nu}~(Jy)', font = 1,/HELP)
    psinit, /color
    loadct,6    

;    if slit_chosen eq 'LowRes-10' then begin
    	aux= where(radii_xspec_mean gt 10.E4 and radii_xspec_mean lt 12.E4); for N-band
;    endif else begin
;    	aux= where(radii_xspec_mean gt 8.E4 and radii_xspec_mean lt 35.E4); for Q-band
;    endelse

    yran = [0.6*min(radii_yspec_mean(*,aux)), 1.5*max(radii_yspec_mean(*,aux))]
    plot,	1.E-4*radii_xspec_mean,radii_yspec_mean(num -1,*), color = 0,xthick = 4, ythick = 4, thick = 4, /ystyle, /xstyle, yrange =  yran ,charthick = 4,$
    	    xtitle = textoidl('Wavelength (\mum)', font = -1), ytitle = textoidl('F_{\nu} (Jy)', font = -1),charsize = 1.5,/nodata, xrange= [8.,13.]
    FOR j = 0, num -1 DO BEGIN
        ; selecting to fit to a 4th order polyfit
;        aux3 =            where(radii_xspec_mean lt    9.E4  and radii_xspec_mean gt 8.E4)
;        aux3 = [aux3, where(radii_xspec_mean lt  10.3E4 and radii_xspec_mean gt 9.8E4)]
;        aux3 = [aux3, where(radii_xspec_mean lt  11.0E4 and radii_xspec_mean gt 10.7E4)]
;        aux3 = [aux3, where(radii_xspec_mean lt  12.7E4 and radii_xspec_mean gt 11.5E4)]
;        av =  poly_fit(radii_xspec_mean(aux3),radii_yspec_mean(j,aux3),4, yfit = yyfit) 
;        yyfit = av(0) + av(1)*radii_xspec_mean + av(2)*radii_xspec_mean*radii_xspec_mean + av(3)*radii_xspec_mean*radii_xspec_mean*radii_xspec_mean + av(4)*radii_xspec_mean*radii_xspec_mean*radii_xspec_mean*radii_xspec_mean
;        aux = where( radii_yspec_mean(j,*)/yyfit lt 10. and radii_yspec_mean(j,*) gt 0. )
        oplot,   1.E-4*radii_xspec_mean, radii_yspec_mean(j,*), linestyle = 0, color = 50*(j+1), thick = 8
	oplot, 1.E-4*radii_xspec_mean , radii_yspec_mean(j,*)- radii_errspec_mean(j,*), linestyle = 0
	oplot, 1.E-4*radii_xspec_mean , radii_yspec_mean(j,*) + radii_errspec_mean(j,*), linestyle = 0
	xyouts,[0.12] * (max(1.E-4*radii_xspec_mean)) +min(1.E-4*radii_xspec_mean), ([0.95] - 0.025*(j))*yran(1) , "Extract #" + strtrim(string(j+1),1),$
	color =  50*(j+1), /data, charthick = 4, charsize = 1.5
	;
	; plotting tentative lines... 
	;
	tentative_lines = [8.45,10.51, 11.3, 12.81]
	tentative_names = ["PAH","[S IV]","PAH","[Ne II]"]
	FOR k = 0,n_elements(tentative_lines) -1 DO oplot, [tentative_lines(k),tentative_lines(k)], yran,linestyle = 2, thick =4
	xyouts ,tentative_lines - 0.1, replicate(1.01*yran(1),n_elements(tentative_lines)), tentative_names, /data , charthick = 4, charsize = 1.5
   ENDFOR
    psterm, file = "PRODUCTS/Spec_m"+strtrim(string(method),1)+"_"+prefix+'_'+strtrim(name(0),1)+'.ps', /noplot
ENDFOR    
END
