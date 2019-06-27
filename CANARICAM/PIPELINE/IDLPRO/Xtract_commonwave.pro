FUNCTION Xtract, onoff, calim, ITERNUMBER = iternumber, MODE_EXTRACT = mode_extract, EXTRACT_SIZE = extract_size, EXTRACT_POS = extract_pos, SIGMAS = sigmas, CENTER_TRACE = center_trace, WIDTH_TRACE = width_trace, WAVEARR = wavearr


;
;   IDL code to extract the spectrum in different ways
;
;   Previous:	    XtractPlot XtractMain
;   After:  	    XtractPlot XtractMain
;
;   Dependences:    ----
;
;   Author: 	    O. Gonzalez-Martin (20th March 2011)

;
; Saving initial variables
;

IF mode_extract GT 2 THEN BEGIN 
    print, "FAILED: WRONG EXTRACTION METHOD"
    print, "FAILED: MODE_EXTRACT == 0, 1, 2"
ENDIF ELSE BEGIN 

onoff2 = onoff
calim2 = calim
;
; Needed variables and dimensions
;
SPAdim =  n_elements(onoff(0,*))
SPEdim =  n_elements(onoff(*,0))
SPEdim2 = SPEdim / (2.^(iternumber))

; ###############################  METHODS TO EXTRACT ##############
; ##	    	    	    	    	    	    	    	  ##
; ##  	    	METHOD 0    	    	    	    	    	  ##
; ##	    	    	    	    	    	    	    	  ##
; ## Selecting the center with a certain width 
; 
IF mode_extract eq 0. THEN BEGIN 
    extract_pos = extract_pos * (2.^(iternumber))
    extract_size = extract_size * (2.^(iternumber))
    onoff = onoff(*,extract_pos-extract_size:extract_pos+extract_size)
    calim = calim(*,extract_pos-extract_size:extract_pos+extract_size)
    aux = indgen(n_elements(aux))
ENDIF
; ##	    	    	    	    	    	    	    	  ##
; ##  	    	METHOD 1    	    	    	    	    	  ##
; ##	    	    	    	    	    	    	    	  ##
; ##  Selecting pixels above N sigmas
; 
IF mode_extract eq 1. THEN BEGIN
    aux = where(onoff gt sigmas*stddev(onoff))
ENDIF
; ##	    	    	    	    	    	    	    	  ##
; ##  	    	METHOD 2    	    	    	    	    	  ##
; ##	    	    	    	    	    	    	    	  ##
; ## Extraction using the trace
; 
IF mode_extract eq 2 THEN BEGIN
    ;vec  = wavearr
    ;vec2 = (maxim_cal-minim_cal)*findgen(SPEdim)/SPEdim + minim_cal
    ;vec2=SubPix(vec,ITERNUMBER=iternumber)
    ;print, mean(center_trace - width_trace), mean(center_trace + width_trace)    
    center_trace_pro = interpol(1D*center_trace, 1D*findgen(SPEdim2), 1D*findgen(SPEdim)/(2.^(iternumber)))
    width_trace_pro  = interpol(1D*width_trace, 1D*findgen(SPEdim2), 1D*findgen(SPEdim)/(2.^(iternumber))) 
    center_trace_pro = center_trace_pro * (2.^(iternumber))
    width_trace_pro =  (2.^(iternumber))*width_trace_pro
    onoff_reset = onoff * 0.
;    val_med = mean(onoff)
    val_med =  -20000000.
    aux = -999.
    FOR m = 0 , SPEdim -1 DO BEGIN
    	FOR k = 0, SPAdim - 1 DO BEGIN
    	    IF (k ge (center_trace_pro(m) - width_trace_pro(m)) and k le (center_trace_pro(m) + width_trace_pro(m)) and onoff(m,k) gt val_med) THEN BEGIN
		onoff_reset(m,k)=1.
    	    ENDIF
    	ENDFOR
    ENDFOR
    aux = where(onoff_reset eq 1.)
ENDIF
; ##	    	    	    	    	    	    	    	  ##
; ##################################################################

xvec_spectrum = calim(aux)
yvec_spectrum = onoff(aux)

; Creating a spectrum with a standard spectral direction
;
xxvec_spectrum = -999.
wavestep=wavearr[1]-wavearr[0]
;;n = 1.
FOR k = 0, n_elements(wavearr)-1 DO BEGIN
    aux = where(1D*xvec_spectrum gt 1D*wavearr[k]-1D*wavestep/2. and 1D*xvec_spectrum le 1D*wavearr[k]+1D*wavestep/2., num)
    IF aux(0) ge 0. THEN BEGIN
    	if xxvec_spectrum(0) lt 0. then BEGIN
            xxvec_spectrum = mean(1D*xvec_spectrum(aux))
            yyvec_spectrum = total(1D*yvec_spectrum(aux)) 
    	ENDIF ELSE BEGIN
            xxvec_spectrum = [1D*xxvec_spectrum, mean(1D*xvec_spectrum(aux))]
            yyvec_spectrum = [1D*yyvec_spectrum,  total(1D*yvec_spectrum(aux))]
    	ENDELSE
    ENDIF
ENDFOR

;
; Interpolating to obtain a non zero spectrum
;
spec = fltarr(2, n_elements(wavearr))
spec(1,*) = interpol(1D*yyvec_spectrum , 1D*xxvec_spectrum, 1D*wavearr)
spec(0,*) = 1D*wavearr

;
; Restoring variables
;
onoff = onoff2
calim = calim2
;IF mode_extract eq 0. THEN BEGIN
;    extract_pos = extract_pos2
;    extract_size = extract_size2
;ENDIF
;IF mode_extract eq 2. THEN BEGIN
;    center_trace = center_trace2
;    width_trace =  width_trace2
;ENDIF

RETURN, spec

ENDELSE
END
