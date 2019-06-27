PRO MainSlitlosses, infilen, prefix


;
;   IDL code to compute the slit-losses according to the acquisition images
;
;   Previous:	    MainImageFlux.pro
;   After:  	    WLcalib.pro
;
;   Dependences:    Slitlosses.pro
;
;   Author: 	    O. Gonzalez-Martin (18th May 2011)
;


readcol, 'PRODUCTS/ID1'+infilen+'.lst', files, object, obstype, obsclass, filter1, filter2, grating,slit, $
	format='(A,A,A,A,A,A,A,A)',/silent
readcol, 'PRODUCTS/id'+infilen+'.lst', filename, tsa, si, acq, std, format = '(A,A,A,A,A)', /silent 
STANDARDS = filename(where(tsa eq "STANDARD" and si eq "SPECTRUM"))

FOR i = 0, n_elements(STANDARDS) -1 DO BEGIN
    aux = where(acq eq STANDARDS(i))   ;     Acquisition images associated to the standard
    print, "Standard: ", prefix+"_"+STANDARDS(i)
    IF n_elements(aux) ge 2 THEN BEGIN
    	FOR j = 0,n_elements(aux) -1 DO BEGIN
    	    aux2 = where( files eq filename(aux(j)))
	    IF slit(aux2) eq "Open" THEN BEGIN
	    	IM = files(aux2) 
	    	print, "	...associated to the image WITHOUT slit: ", prefix+"_"+IM
	    ENDIF ELSE BEGIN
	    	SPEC = files(aux2)
	    	print, " 	...associated to the image WITH slit: ", prefix+"_"+SPEC	    
	    ENDELSE	
    	ENDFOR
	print, "Computing slit-losses of ", prefix+"_"+STANDARDS(i), " with files: "
	print, "---> ",prefix+"_"+IM
	print, "---> ",prefix+"_"+SPEC
    	slitloss = SlitLosses(prefix+"_"+IM,prefix+"_"+SPEC,prefix+"_"+STANDARDS(i))
    ENDIF ELSE BEGIN
    	print, "Warning: No enough acquisition images to perform slit-losses"
        print, "	    	    (Slit losses set to 1.)"
	slitloss = 1.
        std=readfits('OUTPUTS/'+prefix+"_"+STANDARDS(i),stdhead,/silent)
    	fxaddpar,stdhead,"SLITCORR",slitloss[0]," Correction due to slit-losses"
    	writefits,'OUTPUTS/'+prefix+"_"+STANDARDS(i),std,stdhead
    ENDELSE 
    IF n_elements(aux) gt 2 THEN BEGIN	
        print, "Warning: More than one image calibration WITH or WITHOUT slit"
        print, "	    (taking only the closest to the observation)"
    ENDIF   
ENDFOR

END
