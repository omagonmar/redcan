PRO Flatfield, filelist


readcol, filelist, filename , format = '(A)',/silent
FOR i = 0, n_elements(filename) -1 DO BEGIN  ; Running along the number of observations
    ;
    ; Reading file
    ;
    im = readfits(filename(i),hdr, /exten,/silent )    
    ;
    ; Generating flatfield per observation
    ;
    IF n_elements(im(0,0,0,*)) gt 1 THEN BEGIN
    	im_flat=fltarr(n_elements(im(*,0,0,0)), n_elements(im(0,*,0,0)))
    	FOR j= 0, n_elements(im(*,0,0,0)) -1 DO FOR k = 0,n_elements(im(0,*,0,0)) -1 DO im_flat(j,k) = median(im(j,k,1,*))
    	im_flat = im_flat/median(im_flat)
    	FOR j= 0, n_elements(im(0,0,0,*)) -1 DO BEGIN
    		im(0,0,0,j) = im(0,0,0,j)/im_flat
    		im(0,0,1,j) = im(0,0,1,j)/im_flat
    	ENDFOR
	writefits,'OUTPUTS/fl_'+filename(i),im,hdr
    ENDIF
ENDFOR

END
