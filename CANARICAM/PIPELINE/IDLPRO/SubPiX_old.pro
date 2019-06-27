FUNCTION SubPiX_old, im, ITERNUMBER = iternumber , SCALE_MAX = scale_max

;
; INTERPOLATION OF AN IMAGE
;
print,systime()
imout = im
IF iternumber gt 0 THEN BEGIN
    FOR p = 0 ,iternumber -1 DO BEGIN
    	SPAdim =  n_elements(imout(0,*))
    	SPEdim =  n_elements(imout(*,0))
    	im_sub = fltarr(SPEdim*2,SPAdim*2)
    	FOR k = 0, 2*SPEdim -1 DO BEGIN
    		FOR m = 0, 2*SPAdim -1 DO BEGIN
    		    im_sub(k,m) = interpolate(imout, k/2, m/2.,/grid)
    		ENDFOR
    	ENDFOR
    	imout = im_sub
    ENDFOR  
    IF keyword_set(SCALE_MAX) THEN imout = imout/(2.^(2.*iternumber))
ENDIF
print,systime()

RETURN, imout
END
