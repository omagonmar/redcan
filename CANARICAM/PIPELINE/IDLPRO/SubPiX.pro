FUNCTION SubPiX, im, ITERNUMBER = iternumber , SCALE_MAX = scale_max

;
; INTERPOLATION OF AN IMAGE  
;
;     Inputs:
;               im           :      Name of the image.
;               iternumber   :      Number of iteration.
;               scale_max    :      to scale to the number of counts.
;


imout = im
IF iternumber gt 0 THEN BEGIN
    FOR p = 0 ,iternumber -1 DO BEGIN
       imoutsize=size(imout)
       IF imoutsize[0] EQ 2 THEN imout = interpolate(imout,findgen(imoutsize[1]*2)/2.,findgen(imoutsize[2]*2)/2.,/grid) ELSE IF imoutsize[0] EQ 1 THEN imout = interpolate(imout,findgen(imoutsize[1]*2)/2.)
    ENDFOR
    IF keyword_set(SCALE_MAX) THEN begin 
;    	imout = imout*(2.^(2.*iternumber))
    	imout = imout*(2.^(iternumber+1))
    endif	
ENDIF

RETURN, imout
END
