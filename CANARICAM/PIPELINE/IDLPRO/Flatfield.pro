PRO Flatfield, filelist


;
;   Flatfield   :   Procedure to associate each observation to each
;                   best flatfield.
;   Inputs:
;                   filelist :    name of the input file of list of fits

readcol, 'PRODUCTS/id'+filelist+'.lst',filename, tsa,si,acq,std,$
    format='(A,A,A,A,A)',/silent
readcol, 'PRODUCTS/ID1'+filelist+'.lst', files, object, obstype, obsclass, filter1, filter2, grating,slit,ra,dec, $
	format='(A,A,A,A,A,A,A,A,F,F)',/silent

aux = WHERE(si eq "IMAGE")    
tot_im_assoc = 'NONE'
FOR i = 0, n_elements(aux) -1 DO BEGIN  ; Running along the number of observations
    IF slit(WHERE(files eq filename(aux(i)))) eq "Open" THEN BEGIN
    	;
    	; Reading file
    	;
	print,filename(aux(i)), filename(aux(i))  , format = '(A20, " associated to ",A20)' 
    	IF tot_im_assoc(0) eq 'NONE' THEN BEGIN
	    tot_im_assoc = filename(aux(i))
	    tot_im = filename(aux(i))
	ENDIF ELSE BEGIN
	    tot_im_assoc = [tot_im_assoc, filename(aux(i))]
	    tot_im =   [tot_im, filename(aux(i))]	
	ENDELSE
    ENDIF    
ENDFOR
;
;
;
openw,1,'PRODUCTS/flats.txt'
for i = 0, n_elements(tot_im) -1 do printf,1,tot_im(i), format = '(A20)'
close,1
;
; For spectroscopy
;
tot_im_assoc = 'NONE'
im_assoc = 'NONE'
FOR i = 0, n_elements(filename) -1 DO BEGIN  ; Running along the number of observations
    IF si(i) eq "IMAGE" THEN BEGIN
    	IF slit(WHERE(files eq filename(i))) eq "Open" THEN BEGIN
    	    ;
    	    ; Reading file
    	    ;
	    print,filename(i), filename(i)  , format = '(A20, " associated to ",A20)' 
    	    im_assoc=filename(i)
	    IF tot_im_assoc(0) eq 'NONE' THEN BEGIN
	    	tot_im_assoc = filename(i)
	    	tot_im = filename(i)
	    ENDIF ELSE BEGIN
	    	tot_im_assoc = [tot_im_assoc, filename(i)]
	    	tot_im =   [tot_im, filename(i)]	
	    ENDELSE
    	ENDIF  ELSE BEGIN
	    print,filename(i), im_assoc  , format = '(A20, " associated to ",A20)' 
    	    IF tot_im_assoc(0) eq 'NONE' THEN BEGIN
	    	tot_im_assoc = im_assoc
	    	tot_im = filename(i)
	    ENDIF ELSE BEGIN
	    	tot_im_assoc = [tot_im_assoc,im_assoc]
	    	tot_im =   [tot_im, filename(i)]	
	    ENDELSE
    	ENDELSE  
    ENDIF ELSE BEGIN
        print,filename(i), im_assoc  , format = '(A20, " associated to ",A20)' 
    	IF tot_im_assoc(0) eq 'NONE' THEN BEGIN
	    tot_im_assoc = im_assoc
	    tot_im = filename(i)
	ENDIF ELSE BEGIN
	    tot_im_assoc = [tot_im_assoc,im_assoc]
	    tot_im =   [tot_im, filename(i)]	
	ENDELSE
    ENDELSE
ENDFOR
;
; Order as in id
;

;for i = 0, n_elements(tot_im) -1 do print, "ANTES  ", tot_im(i), tot_im_assoc(i), format = '(A20,A20,A20)'

readcol, 'PRODUCTS/ID4'+filelist+'.lst', files, nnods, nnodsets, nsavesets,format = '(A,I,I,I)' 

openw,1,'PRODUCTS/toflat.txt'
FOR i = 1,n_elements(filename) -1 DO BEGIN
    aux = WHERE(tot_im eq filename(i))
    IF n_elements(aux) gt 0 and aux(0) ge 0 THEN printf,1,tot_im(aux(0)),tot_im_assoc(aux(0)), nnods(i-1), nnodsets(i-1), nsavesets(i-1),format = '(A20,A20,I,I,I)'
ENDFOR
close,1

openw,1,'PRODUCTS/toflat2.txt'
FOR i = 1,n_elements(filename) -1 DO BEGIN
    aux = WHERE(tot_im eq filename(i))
    if n_elements(aux) gt 0 and aux(0) ge 0 THEN printf,1,tot_im(aux(0)),tot_im_assoc(aux(0)), nnods(i-1), nnodsets(i-1), nsavesets(i-1),format = '(A,",",A,",",I,",",I,",",I)'
ENDFOR
close,1

END
