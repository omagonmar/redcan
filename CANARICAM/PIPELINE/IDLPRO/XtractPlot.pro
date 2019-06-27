PRO XtractPlot, listname, prefix, SIGMAS = sigmas, EXTRACT_SIZE = extract_size, NCOLAPSING = ncolapsing

;
;   IDL code to extract each spectrum in different ways and make some plots
;
;   Previous:	    WLcalib
;   After:  	    XtractMain
;
;   Dependences:    Xtract WLtrace psinit psterm colorbar
;
;   Author: 	    O. Gonzalez-Martin (20th March 2011)
;


;
; Defining variables
;
Diameter_telescope = 8.
Cvalue = 1.e-4/(Diameter_telescope*1.e6)*206265./0.0896 ; [lambdas um] / [Telescope diameter um]  * [arcsec in 2!pi] / [arcsec /pixel]
iternumber = 3 
IF NOT keyword_set(SIGMAS) THEN sigmas = 3.
IF NOT keyword_set(EXTRACT_SIZE) THEN extract_size = 20.
IF NOT keyword_set(NCOLAPSING) THEN ncolapsing = 10


readcol, 'PRODUCTS/spectra_'+prefix+'_'+listname+'.lst',filename,filename2,format='(A,A)',/silent
FOR i = 0 , n_elements(filename) -1 DO BEGIN
    spectrum = readfits(filename(i),hdr,/silent)
    filenameout = strmid(filename2(i), 0,14)
    onoff= spectrum(*,*,2)
    calim= spectrum(*,*,3)
    SPAdim =  n_elements(onoff(0,*))
    SPEdim =  n_elements(onoff(*,0))
    extract_pos = SPAdim/2 +3
    ;
    ; Determining the trace
    ;
    WLtrace, onoff , calim, prefix, filenameout, center_trace, width_trace, NCOLAPSING = ncolapsing   ; add here the info in the header CHANGE!
    ;
    ; Interpolation of images
    ;
    calim = SubPiX(calim, ITERNUMBER = iternumber)
    onoff = SubPiX(onoff, ITERNUMBER = iternumber, /SCALE_MAX)
    ;
    ; Extracting spectra in  four different ways
    ;
    spec1 = Xtract( onoff , calim, ITERNUMBER = iternumber, MODE_EXTRACT = 0, EXTRACT_SIZE = extract_size, EXTRACT_POS = extract_pos)
    spec2 = Xtract( onoff , calim, ITERNUMBER = iternumber, MODE_EXTRACT = 1, SIGMAS = sigmas)
    spec3 = Xtract( onoff , calim, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace, WIDTH_TRACE = width_trace)
    center_trace2 = replicate(extract_pos(0), SPEdim)
    IF extract_size le 3. THEN BEGIN
    	width_trace2  = (extract_size)*spec1(0,*)/spec1(0,0)   ; if it is higher than the PSF of  the standard grows with the PSF
    ENDIF ELSE BEGIN
        width_trace2  = sqrt(extract_size^2.  + Cvalue^2. *spec1(0,*)^2. *( (spec1(0,*)/spec1(0,0))^2. -1.) )  ; if is lower than the PSF of the standard grows cuadratically
    ENDELSE
    spec4 = Xtract( onoff , calim, ITERNUMBER = iternumber, MODE_EXTRACT = 2, CENTER_TRACE = center_trace2, WIDTH_TRACE = width_trace2)
    ;
    ; Plotting
    ;
    psinit,/color
    loadct,6
    plot, spec1(0,*)*1.E-4, spec1(1,*),color=0,thick=1,/xstyle,xminor= 5,yrange=[0., 1.05*max([spec1(1,*),spec2(1,*),spec3(1,*)])],/ystyle, $
        xtitle= "Wavelength (um)", ytitle = "Total counts"
    oplot, spec2(0,*)*1.E-4, spec2(1,*),color=200,thick=2
    oplot, spec3(0,*)*1.E-4, spec3(1,*),color=0,thick=4, linestyle=0
    oplot, spec4(0,*)*1.E-4, spec4(1,*),color=120,thick=4, linestyle=0
    xlab = [0.6,0.6,0.6,0.6] + 0.1
    ylab = 0.9 - 0.025*findgen(4)
    clab = [0,200,0,120]
    thlab = [1,2,4,4] 
    nameslab = [string(strtrim(fix(extract_size),1))+" -pixels",string(strtrim(fix(sigmas),1))+  " -sigma",   "Fitting to a Moffat", "Theoretical"]
    FOR m = 0, n_elements(xlab)-1 DO plots , [xlab(m),xlab(m)+0.05], [ylab(m),ylab(m)],linestyle = 0, color = clab(m),thick = thlab(m),/normal
    FOR m = 0, n_elements(xlab)-1 DO xyouts, xlab(m)+0.06, ylab(m) , nameslab(m),/normal
    psterm,file='PRODUCTS/Xt_'+prefix+'_'+filenameout+'.ps',/noplot
ENDFOR   
END
