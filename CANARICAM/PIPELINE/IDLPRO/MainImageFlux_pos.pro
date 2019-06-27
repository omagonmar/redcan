PRO MainImageFlux_pos, infilen, prefix, calib_dir

;
;   IDL code to compute the slit-losses according to the acquisition images
;
;   Previous:	    PerSec.pro
;   After:  	    MainSlitLosses.pro
;
;   Dependences:    imagefluxcal.pro
;
;   Author: 	    O. Gonzalez-Martin (18th May 2011)
;

readcol, 'PRODUCTS/ID1'+infilen+'.lst', files, object, obstype, obsclass, filter1, filter2, grating,slit,ra,dec, $
	format='(A,A,A,A,A,A,A,A,F,F)',/silent
readcol, 'PRODUCTS/id'+infilen+'.lst', filename, tsa, si, acq, std, format = '(A,A,A,A,A)', /silent 
IMAGES = WHERE(si eq "IMAGE")
tot_sel = "NONE"
FOR i = 0, n_elements(IMAGES) -1 DO BEGIN
    aux_slit = WHERE(files eq filename(IMAGES(i)))
    RAPOS = ra(aux_slit)
    DECPOS = dec(aux_slit)
    NAME = object(aux_slit)
    IF strmid(filter1(aux_slit),0,4) ne "Open" THEN FILT = filter1(aux_slit) ELSE FILT = filter2(aux_slit)
    IF slit(aux_slit) eq "Open" THEN BEGIN
    	IF tsa(images(i)) eq "ACQUISITION" THEN BEGIN
	    aux = where(filename eq acq(images(i)))
	    SELEC = tsa(aux)	
    	ENDIF ELSE BEGIN  ; targets and standards
    	    SELEC = tsa(images(i))	
    	ENDELSE
    	IF tot_sel(0) eq "NONE" THEN BEGIN
    	    tot_sel = SELEC 
	    tot_im = filename(images(i))
	    tot_im_acq = acq(images(i))
    	    tot_filt = FILT
    	    tot_ra = RAPOS
    	    tot_dec = DECPOS
    	    tot_name = NAME
    	ENDIF ELSE BEGIN
    	    tot_sel = [tot_sel, SELEC]
	    tot_im = [tot_im, filename(images(i))]
	    tot_im_acq = [tot_im_acq , acq(images(i))]
	    tot_filt = [tot_filt,   FILT]
	    tot_ra = [tot_ra,   RAPOS]
	    tot_dec = [tot_dec,   DECPOS]
	    tot_name = [tot_name,   NAME]
    	ENDELSE
;    	print,filename(images(i)), SELEC, format = '(A20,A20)'    
    ENDIF
ENDFOR
;
; Reading list of Standards
;
readcol, 'Cohen_coord.lst', HD, rah, ram,ras, decg,decm,decs, format = '(a,f,f,f,f,f,f)', /silent
ra_cat =  360.*(rah + (ram/60.) + (ras /3600. ))/24.
dec_cat = fltarr(n_elements(ra_cat))
FOR i = 0, n_elements(dec_cat) -1 DO IF decg(i) gt 0. then dec_cat(i) = decg(i) + (decm(i)/60.  + decs(i)/3600.) else dec_cat(i) = decg(i) - (decm(i)/60.  + decs(i)/3600.)
;
; Running Standards
;
readcol, "PRODUCTS/coordis.lst", namecoord, xpos, ypos,format = '(A,F,F)'
aux = WHERE(tot_sel eq "STANDARD")
IF aux(0) ge 0 THEN BEGIN
    tot_im_acq=tot_im_acq(aux)
    tot_im_std = tot_im(aux)
    openw,1,"PRODUCTS/Fluxes_"+prefix+"_"+ infilen+".txt"
    FOR i = 0, n_elements(aux) -1 DO BEGIN
    	aux2 = WHERE(abs(ra_cat - tot_ra(aux(i))) eq min(abs(ra_cat - tot_ra(aux(i))))  and abs(dec_cat - tot_dec(aux(i))) eq min(abs(dec_cat - tot_dec(aux(i)))))
    	name_std = HD(aux2)
    	print, tot_im(aux(i)) , HD(aux2), format = '(A25," file was identified as the Standard HD" ,A10)'
    	;
    	; Reading Standard's theoretical spectrum
    	;
    	readcol, calib_dir + "/templates/HD" + name_std(0) + ".tem", xth, yth, format = '(f,f)',/silent
    	stdspec = fltarr(n_elements(xth),2)
    	stdspec(*,0) = xth
    	stdspec(*,1) = yth
    	readcol, calib_dir + "/../FILTERS/" + tot_filt(aux(i)) + ".txt", xfilt, yfilt, format = '(f,f)',/silent
    	filter =  fltarr(n_elements(xfilt),2)
    	filter(*,0) = xfilt
    	filter(*,1) = yfilt
	coordis=[xpos(where(namecoord eq tot_im(aux(i)))), ypos(where(namecoord eq tot_im(aux(i))))]
    	ImageFluxCal_pos, prefix+"_"+tot_im(aux(i)), STDSPEC=stdspec, FILTER=filter, fluxs = fluxi,COORDS=coordis, FLUXERR=fluxierr
    	printf,1, tot_im(aux(i)), tot_name(aux(i)), tot_filt(aux(i)), coordis(0), coordis(1), 1000.*fluxi, 1000.*fluxierr, format = '(A20,A20,A20,F10.2,F10.2,F10.2, F10.2, " mJy")'
    ENDFOR
ENDIF
;
; Reading list of Targets
;
aux = WHERE(tot_sel eq "TARGET")
IF aux(0) ge 0 THEN BEGIN
    FOR i = 0, n_elements(aux) -1 DO BEGIN
        imi = acq(WHERE(filename eq tot_im(aux(i))))
        IF imi ne "NOASSOC" THEN BEGIN
        	corimi = std(WHERE(filename eq imi(0)))
        	stdname = tot_im_std(WHERE(tot_im_acq eq corimi(0)))
    	ENDIF ELSE BEGIN
    		stdname = std(WHERE(filename eq tot_im(aux(i))))
    	ENDELSE
	coordis=[xpos(where(namecoord eq tot_im(aux(i)))), ypos(where(namecoord eq tot_im(aux(i))))]
    	ImageFluxCal_pos, prefix+"_"+tot_im(aux(i)), STDIMA = "FC_"+prefix+"_"+stdname(0) , fluxs = fluxi,COORDS=coordis, FLUXERR=fluxierr
    	printf,1, tot_im(aux(i)), tot_name(aux(i)), tot_filt(aux(i)), coordis(0), coordis(1), 1000.*fluxi,1000.*fluxierr, format = '(A20,A20,A20,F10.2,F10.2,F10.2, F10.2, " mJy" )'
    ENDFOR
ENDIF
close,1
END
