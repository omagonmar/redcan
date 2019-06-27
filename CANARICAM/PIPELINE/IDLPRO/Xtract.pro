FUNCTION Xtract, onoff, calim, ITERNUMBER = iternumber, MODE_EXTRACT = mode_extract, $
    	EXTRACT_SIZE = extract_size, EXTRACT_POS = extract_pos, SIGMAS = sigmas, $
    	CENTER_TRACE = center_trace, WIDTH_TRACE = width_trace


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
IF mode_extract eq 0. THEN BEGIN 
    extract_pos2 = extract_pos
    extract_size2 = extract_size
ENDIF
IF mode_extract eq 2. THEN BEGIN
    center_trace2 = center_trace
    width_trace2 =  width_trace
ENDIF
;
; Needed variables and dimensions
;
SPAdim =  n_elements(onoff(0,*))
SPEdim =  n_elements(onoff(*,0))
SPEdim2 = SPEdim / (2.^(iternumber))
minim_cal = min(calim)
maxim_cal = max(calim)
vec_spectrum = (maxim_cal-minim_cal)*findgen(SPEdim2)/SPEdim2 + minim_cal

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

IF mode_extract eq 2. THEN BEGIN
    vec  = vec_spectrum
    vec2 = (maxim_cal-minim_cal)*findgen(SPEdim)/SPEdim + minim_cal
    center_trace_pro = interpol(center_trace, vec, vec2)
    width_trace_pro  = interpol(width_trace, vec, vec2) 
    center_trace = center_trace_pro * (2.^(iternumber))
    width_trace =  (2.^(iternumber))*width_trace_pro
    onoff_reset = onoff * 0.
;    val_med = mean(onoff)
    val_med =  -2000000.
    aux = -999.
    FOR m = 0 , SPEdim -1 DO BEGIN
    	FOR k = 0, SPAdim - 1 DO BEGIN
    	    IF (k ge (center_trace(m) - (3.)*width_trace(m)) and k le (center_trace(m) + (3.)*width_trace(m)) and onoff(m,k) gt val_med) THEN BEGIN
		onoff_reset(m,k)=10.
    	    ENDIF
    	ENDFOR
    ENDFOR
    aux = where(onoff_reset gt 5.)
ENDIF
; ##	    	    	    	    	    	    	    	  ##
; ##################################################################
; 
; Ordering along the spectral direction
; 
;auxi = sort(calim(aux))
;
; Stacking all the data with the same wavelength (exactly the same)
;

xvec_spectrum = calim(aux)
yvec_spectrum = onoff(aux)
;
; Creating a spectrum with a standard spectral direction
;
xxvec_spectrum = -999.
;;n = 1.
FOR k = 0, n_elements(vec_spectrum)-2 DO BEGIN
    aux = where(xvec_spectrum gt vec_spectrum(k) and xvec_spectrum le vec_spectrum(k+1), num)
    IF aux(0) ge 0. THEN BEGIN
	IF xxvec_spectrum(0) lt 0. THEN BEGIN
     	    xxvec_spectrum =   mean(xvec_spectrum(aux))
    	    yyvec_spectrum =   mean(yvec_spectrum(aux))
    	ENDIF ELSE BEGIN
    	    xxvec_spectrum =  [xxvec_spectrum , mean(xvec_spectrum(aux))]
    	    yyvec_spectrum =  [yyvec_spectrum, mean(yvec_spectrum(aux))]
    	ENDELSE
    ENDIF ELSE BEGIN
;    	print,k, vec_spectrum(k),vec_spectrum(k+1) , vec_spectrum(0), vec_spectrum(n_elements(vec_spectrum) -1 )
    ENDELSE
ENDFOR
;
; Interpolating to obtain a non zero spectrum
;
; Here we are already making a 0.5 shift! ###############################

spec = fltarr(2, n_elements(vec_spectrum))
spec(1,*) = interpol(yyvec_spectrum , xxvec_spectrum, vec_spectrum )
spec(0,*) = vec_spectrum
;
; Restoring variables
;
onoff = onoff2
calim = calim2
IF mode_extract eq 0. THEN BEGIN
    extract_pos = extract_pos2
    extract_size = extract_size2
ENDIF
IF mode_extract eq 2. THEN BEGIN
    center_trace = center_trace2
    width_trace =  width_trace2
ENDIF

RETURN, spec

ENDELSE
END
