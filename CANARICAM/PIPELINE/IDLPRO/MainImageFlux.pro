PRO MainImageFlux, infilen, prefix, calib_dir

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
aux = WHERE(tot_sel eq "STANDARD")
aux_std = aux
IF aux(0) ge 0 then begin
tot_im_acq=tot_im_acq(aux)
tot_im_std = tot_im(aux)
openw,1,"PRODUCTS/Fluxes_"+prefix+"_"+infilen+".txt"
FOR i = 0, n_elements(aux) -1 DO BEGIN
    aux2 = WHERE(abs(ra_cat - tot_ra(aux(i))) eq min(abs(ra_cat - tot_ra(aux(i))))  and abs(dec_cat - tot_dec(aux(i))) eq min(abs(dec_cat - tot_dec(aux(i)))))
    if aux2(0) ge 0 then begin 
    	name_std = HD(aux2)
    	print, tot_im(aux(i)) , HD(aux2), format = '(A25," file was identified as the Standard HD" ,A10)'
    endif else begin 
    	name_std = '00001'
    	print, "##############   Warning!:    Standard not found in the catalog!.... Calibration skipped for: "+ tot_im(aux(i))
    	print, tot_im(aux(i)) , '00001', format = '(A25," file was identified as the Standard HD" ,A10)'
        print, "##### Warning!! Using HD00001!!!"
    endelse 	
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
    ImageFluxCal, prefix+"_"+tot_im(aux(i)), STDSPEC=stdspec, FILTER=filter, flux = fluxi,COORDS=coordis, STDNAME= name_std, choose = choose
    ;printf,1, tot_im(aux(i)), tot_name(aux(i)), tot_filt(aux(i)), coordis(0), coordis(1), 1000.*fluxi, format = '(A20,A20,A20,F10.2,F10.2,F10.2, " mJy")'
ENDFOR
endif
;
; Reading list of Targets
;
aux = WHERE(tot_sel eq "TARGET")
IF aux(0) ge 0 and aux_std(0) ge 0 then begin  ; Must be the target and the calibration star
FOR i = 0, n_elements(aux) -1 DO BEGIN
    imi = acq(WHERE(filename eq tot_im(aux(i))))
    IF imi(0) ne "NOASSOC" THEN BEGIN
    	corimi = std(WHERE(filename eq imi(0)))
    	stdname = tot_im_std(WHERE(tot_im_acq eq corimi(0)))
    ENDIF ELSE BEGIN
    	stdname = std(WHERE(filename eq tot_im(aux(i))))
    ENDELSE
    IF stdname(0) ne 'NOASSOC' THEN BEGIN
    	print, tot_im(aux(i)) ,"FC_"+prefix+"_"+stdname(0) , format = '(A25," converted using:  " ,A30)'
    	ImageFluxCal, prefix+"_"+tot_im(aux(i)), STDIMA = "FC_"+prefix+"_"+stdname(0) , flux = fluxi,COORDS=coordis, choose = choose
    	im = readfits('OUTPUTS/'+"FC_"+prefix+"_"+stdname(0),stdimahead,/silent)
    	HDsel = fxpar(stdimahead, 'STDNAME')
	HDselname = fxpar(stdimahead, 'OBJECT')
    	if choose eq 'yes'  then begin
	     if float(HDsel[0]) gt 1 then begin 
	    	 printf,1, tot_im(aux(i)), tot_name(aux(i)), tot_filt(aux(i)), coordis(0), coordis(1), 1000.*fluxi, HDsel[0], stdname[0], format = '(A20,A15,A20,F10.2,F10.2,F16.2, A10, A20)'
    	    endif else begin
	    	 printf,1, tot_im(aux(i)), tot_name(aux(i)), tot_filt(aux(i)), coordis(0), coordis(1), 1000.*fluxi, HDsel[0], stdname[0],HDselname[0],format = '(A20,A15,A20,F10.2,F10.2,F16.2, A10, A20, A12)'
	    endelse
	endif
    ENDIF ELSE BEGIN
    	print, "##############   Warning!:    " + tot_im(aux(i))+ "  without association!!"
    ENDELSE
ENDFOR
endif
close,1
END
