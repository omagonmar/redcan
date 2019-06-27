PRO WLcalib, listname, prefix, NCOLAPSING =  ncolapsing, idldir, instrument = instrument

;
;   IDL code to make wavelength calibration. Needs a list of files, a prefix 
;   	    (right now s1 and s2) and the number of colapsing lines to perform 
;   	    the calibration.
;
;   Previous: 	Stacking.py
;   After:  	XtractMain.pro
;
;   Dependences: psinit psterm colorbar
;
;   Author: Dr. O. Gonzalez-Martin (2nd March 2011)
;


IF NOT keyword_set(NCOLAPSING) THEN ncolapsing = 10

readcol, 'PRODUCTS/id'+listname+'.lst',filename, tsa,si,acqassoc,stdassoc,$
	format='(A,A,A,A,A)',/silent
; 
; Definitions:
;

;wlcalib_com = [74619.2101, 78813.4841 , 85166.8354 , 88033.285 , 94941.4424,  102622.713  ,117303.511  ,  128759.52  ]
; wlcalib_com = [175860,182980,186480,190150,193100,198900,203220,206530,211750,218550,225950,229410,231990]  for the Q-band
wlcalib_com = [74619.2101, 78813.4841 , 85166.8354 , 88033.285 , 94941.4424,  102622.713  ,117303.511  ,125509.,  128759.52 ,175860,182980,186480,190150,193100,198900,203220,206530,211750,218550,225950,229410,231990 ]

readcol, 'PRODUCTS/ID1'+listname+'.lst',filenameslit,grating, slit,sector,format='(A,X,X,X,X,X,A,A,X,X,A)',/silent
grating = strmid(strtrim(grating ,1),0,9)

tramo = 5
band = 1400.


openw, 1, "PRODUCTS/texto.out"
openw,2, 'PRODUCTS/spectra_'+prefix+'_'+listname+'.lst'
openw,3, 'PRODUCTS/AV_'+prefix+'_'+listname+'.dat'
for i = 0 , n_elements(filename) -1 do begin
    wlcalib_com = [74619.2101, 78813.4841 , 85166.8354 , 88033.285 , 94941.4424,  102622.713  ,117303.511  ,125509.,   128759.52 ,175860,182980,186480,190150,193100,198900,203220,206530,211750,218550,225950,229410,231990 ]
    amplitud = 1.0
    if si(i) eq "SPECTRUM" then begin
		auxi = where(filenameslit eq filename(i))
    	slit_chosen = grating(where(filenameslit eq filename(i)))
		if slit_chosen eq 'LowRes-10' then begin
	    	if sector(auxi) eq "Open" then begin 	    
	    		readcol, 'Spectrum_theor_N.dat', xtheor, ytheor,/silent
    	    endif else begin
	    		readcol, 'Spectrum_theor_N_poly.dat', xtheor, ytheor,/silent
	    	endelse
		endif else begin
 	    	readcol, 'Spectrum_theor_Q.dat', xtheor, ytheor,/silent
		endelse
	
		printf,2,'OUTPUTS/WL_'+prefix+'_'+filename(i), filename(i),format = '(A," ", A)'
    		spectrum = readfits('OUTPUTS/'+prefix+'_'+filename(i),hdr)
    		filenameout = strmid(filename(i), 0,14)
		on = spectrum(*,*,0)
    	off = spectrum(*,*,1)
		off_record = off
    	onoff= spectrum(*,*,2)
    	if min(off) lt 0. then off = off - min(off)
    	if min(off_record) lt 0. then off = off_record - min(off_record)
    	if min(on) lt 0. then on =  on - min(on)
		if min(onoff) lt 0. then onoff =  onoff - min(onoff)
		if instrument eq "CC" then begin
	    	onoff = ROTATE(onoff, 2)  
	    	on = ROTATE(on, 2)  
	    	off = ROTATE(off, 2) 
	    	off_record = ROTATE(off_record, 2) 
	    	if slit_chosen eq 'LowRes-10' then begin
	    		if sector(auxi) eq "Open" then begin 	    	
				    av0 = [95030.,190.656]  ; for N-band without poly  (CC)
    	    	endif else begin
		    		av0 = [105000.,195.]  ; for N-band WITH poly   (CC)
    	    	    wlcalib_com = [74619.2101, 78813.4841 , 85166.8354 , 88033.285 ,97000., 104100.  ,108000. ,175860,182980,186480,190150,193100,198900,203220,206530,211750,218550,225950,229410,231990 ]
				endelse
	    	endif else begin
	    		av0 = [175860., 280.]  ; for Q-band   (CC)
 	    	endelse
		endif else begin
	    	if slit_chosen eq 'LowRes-10' then begin
	    		av0 = [95030.,222.]  ;  for N-band  (T-ReCs)
	    	endif else begin
	    		av0 = [175860.,340.]  ;  for Q-band  (T-ReCs)
 	    	endelse
		endelse
	
	;
	; removing bad regions
	;
	;print, mean(on),stddev(on)
	;
	; adding on to the off to perform the final computation
	;
	off=on+off
	off = off(0:300,*)
	;
	; Colapsing all
	;
        offsmooth=total(off,2,/nan)

 	;print, "writing new conversion..."
;	auxi = where(filenameslit eq filename(i))
;	if sector(auxi) ne "Open" then begin
	;    print, "SAVINGGGGGGGGGGGGGGGGGGGG", filename(i), sector(auxi)
	;    openw,5, "Spectrum_theor_saved_"+string(strtrim(i,1))+".dat"
	;        for m = 0 , n_elements(off(*,0)) -1 do printf,5, m, offsmooth(m),format = '(I,I20)'
    	;    close,5
 ;	endif	
	; 
	; Smoothing
	;
	for m = 1, n_elements(offsmooth) -2 do offsmooth(m)=mean(offsmooth[m-1:m+1],/nan)
		
	psinit,/color
	loadct,6
	;
	; Determining offset using comparison between theoretical and observed
	;
        
    	chi = fltarr(2*(n_elements(off(*,0)) - n_elements(ytheor)), 40)
	
	amplitudes = 0.2 *( (findgen(n_elements(chi(0,*))))/n_elements(chi(0,*)) -0.3) + amplitud
;	amplitudes = 0.4 *( (findgen(n_elements(chi(0,*))))/n_elements(chi(0,*)) -0.5) + amplitud
	
	tam_off = n_elements(offsmooth)
	offsmoothold = offsmooth 
	offsmooth = [offsmooth, replicate(min(offsmooth) ,  n_elements(offsmooth)-n_elements(chi(*,0)) )]
    ;	ytheor = (max(offsmoothold ) - min(offsmoothold ) )* ytheor/ ( max(ytheor ) - min( ytheor ) )+  (median(offsmoothold) - median(ytheor))  
	for m = 0, n_elements(chi(*,0)) -1 do begin
	    for l = 0,n_elements(chi(0,*)) -1   do begin
	    	ytheor2 =interpol( ytheor, amplitudes(l)*xtheor,xtheor) 
	    	chi(m,l) = stddev(offsmooth[m:m+n_elements(ytheor2)] / ytheor2)
            endfor
	endfor
	chi_cont = min(chi)*[0.9, 1.,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8]
    	contour, chi, indgen(n_elements(chi(*,0))) - min(xtheor), amplitudes, LEVELS = chi_cont, $
;	    c_annotation = strmid(strtrim(string( chi_cont),1), 0,3), position = [0.15,0.15, 0.95,0.95],$
	    position = [0.15,0.15, 0.95,0.95],$
	    xtitle = "Offset", ytitle = "Dispersion",charsize= 1.3
	
	
	for m = 0, n_elements(chi(*,0)) -1 do begin
	    for l = 0,n_elements(chi(0,*)) -1   do begin
    	    	if chi(m,l)  eq min(chi) and amplitudes(l) lt 1.10 then begin
;    	    	if chi(m,l) eq 	min(chi) then begin
 		    amplitud = amplitudes(l)
		    shifttemplate = m - min(xtheor)  - 2.
		endif          
	    endfor
	endfor
	
	;
	; Plotting fit
	;
   	plots, shifttemplate +2., amplitud, psym = 1, symsize = 3
    	xyouts, 0.7,0.9,"Best Offset = " + strmid(strtrim(string(shifttemplate),1),0,4),/normal
    	xyouts, 0.7,0.85,"Best dispersion = " + strmid(strtrim(string( amplitud),1),0,6),/normal
	
	offsmooth = offsmooth(0:tam_off -1 )
	ytheor =interpol(ytheor, xtheor/amplitud,xtheor) 
	print, "+++++++++++++++++++++++++++++++++++++++++++++"	
	if instrument eq "CC" then begin
	    if slit_chosen eq 'LowRes-10' then begin
	    	if sector(auxi) eq "Open" then begin 	    	
    	    	    B_value3 = av0(0) - ((shifttemplate + 116. ) *  av0(1)) ;  for N-band
	    	endif else begin
		print, 150.
    	    	    B_value3 = av0(0) - ((shifttemplate + 169. ) *  av0(1)) ;  for N-band	 
	    	endelse
	    endif else begin
	    	B_value3 = av0(0) - ((shifttemplate + 47. ) *  av0(1))  ;  for Q-band
	    endelse
	endif else begin
	    if slit_chosen eq 'LowRes-10' then begin
;	    	B_value3 = av0(0) - ((shifttemplate + 139.) *  av0(1))
	    	B_value3 = av0(0) - ((shifttemplate + 142.) *  av0(1))
	    endif else begin
	    	B_value3 = av0(0) - ((shifttemplate + 26. ) *  av0(1))  ;  for Q-band
	    endelse
    	endelse
    	print, "Desplacement of the teplate of ",shifttemplate
	print, "Selected method: SPEC	  ", B_value3	
	
	;
	; Determining max just considering those with the 5 points before and after lower than the value
	;
    	line = -999.
        for l = 5 , n_elements(off(*,0)) -6 do begin 
           if offsmooth[l] eq max(offsmooth[l-5:l+5]) then begin
              if line(0) lt 0 then line = l else line = [line, l]
           endif
        endfor
;	openw,6, 'OUTPUTS/ref_list_'+filenameout+'.dat'
;	    for l = 0 , n_elements(line) -1 do printf,6, line(l)+1,format = '(F10.0)'
;	close,6
    	firstattempt = B_value3(0) + av0(1) * line  
	    	
	ymaxrang = max(offsmooth) + 1.*stddev(offsmooth)
	yminrang = min(offsmooth) - 1.*stddev(offsmooth)
	plot, offsmooth,/xstyle,/ystyle,xtitle="X axis (pixels)", ytitle="Total Counts",title="Search for Sky-bands (colapsing Y)",charsize=1.6,$
	    yrange=[yminrang,ymaxrang],xrange=[-20,n_elements(offsmooth)-1], position = [0.15,0.15, 0.95,0.95]

	for m = 0, n_elements(wlcalib_com) -1 do begin 
	    polyfill, ([band,band,-1.*band,-1.*band,band] + wlcalib_com(m) -  B_value3(0))/(av0(1))  ,$
	    [yminrang,ymaxrang,ymaxrang,yminrang,yminrang ],color=120
	    xyouts,  ((band/2.+wlcalib_com(m)-B_value3(0))/(av0(1))),1.1*yminrang, strmid(strtrim(string(wlcalib_com(m)*1.E-4),1),0,4) , orientation = 90, /data    
	endfor
	plotsym, 1
	oplot, line, offsmooth(line)  + 0.5*stddev(offsmooth), psym= 8,symsize= 2
	oplot, offsmooth
    	line_sel = -999.
    	wl_sel = -999.
    	for l = 0, n_elements(firstattempt) -1 do begin 
    	   aux = where(abs(wlcalib_com - firstattempt(l)) lt band) 
    	   if aux(0) gt 0 then begin 
    		   if line_sel(0) lt 0. then begin
    			   line_sel=line(l) 
    			   wl_sel = wlcalib_com(aux)
    		   endif else begin
    			   line_sel = [line_sel, line(l)]
    			   wl_sel = [wl_sel, wlcalib_com(aux)]
    		   endelse 
    	   endif
	endfor
	;
	; Interpolating around the positions and determining the max by fitting to a gaussian profile
	;
	line_sel2 = -999.
	for m = 0 , n_elements(line_sel) -1 do begin
	     xx = indgen(tramo) + line_sel(m) - tramo/2
	     yy = offsmooth(xx)
	     xx2 = (tramo*indgen(1000)/1000.) + line_sel(m) - tramo/2
	     yy2 = interpol(yy,xx,xx2)
	     yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
	     ene = where(yfit eq max(yfit))
	     if line_sel2(0) lt  0. then line_sel2 =xx2(ene(0)) else line_sel2 =[ line_sel2, xx2(ene(0))]
	     oplot, xx2, yfit, linestyle = 0, color=200 ,thick=10
	     ;oplot,[line_sel2(m),line_sel2(m)],[max(offsmooth)+ 0.4*mean(offsmooth),max(offsmooth)+ 0.6*mean(offsmooth)],linestyle=0,color =200.,thick=2    
	endfor
        oplot,xtheor, 0.8* ytheor* mean(offsmooth) / mean(ytheor), THICK =1, LINESTYLE =1
	xyouts, 0.2, 0.90, filename(i),/normal
	oplot, xtheor + shifttemplate , ytheor* mean(offsmooth) / mean(ytheor), THICK =2, LINESTYLE =2
	psterm, file='PRODUCTS/WL_'+prefix+'_'+filenameout+'_mean.ps',/noplot
	
	psinit, /color
	!p.multi = 0
    	line_sel = line_sel2 ; line_sel is now a float! it can be 45.7782
	;
	; Going through the spatial direction
	;
    	line_sel_total = -999.
    	for k = ncolapsing , n_elements(off(0,*)) -1, ncolapsing  do begin 
    	    ;
	    ; Colapsing every colapsingnumber lines
	    ;
    	    offsmooth= off(*,k)
	    for m = 0 , n_elements(off(*,0)) -1 do offsmooth(m) = total(off(m,k-ncolapsing:k))
	    
	    ; 
	    ; Smoothing
	    ;
	    for m = 1, n_elements(offsmooth) -2 do offsmooth(m)=mean(offsmooth[m-1:m+1])
	    ;
	    ; Ploting sky spectrum
	    ;
	    
	    ymaxrang = max(offsmooth) + 1.*stddev(offsmooth)
	    yminrang = min(offsmooth) - 1.*stddev(offsmooth)
	    plot, offsmooth,/xstyle,/ystyle,xtitle="X axis (pixels)", ytitle="Total Counts",yrange=[yminrang,ymaxrang], $
	    	title="Search for Sky-bands: Colapsing: "+string(k-ncolapsing)+":"+string(k),charsize=1.2,xrange=[-20,n_elements(offsmooth)-1],/nodata
	    ;
	    ; Interpolating around the positions and determining the max by fitting to a gaussian profile
	    ;
	    line_sel2 = -999.
            line_sel=round(line_sel) ; <--- this is because indices (when passed to offsmooth) cannot be floats
	    for m = 0 , n_elements(line_sel) -1 do begin 
		 max_tram = where(offsmooth[line_sel(m)-(tramo/2):line_sel(m)+(tramo/2)] eq max(offsmooth[line_sel(m)-(tramo/2):line_sel(m)+(tramo/2)]))
		 xx0 = line_sel(m)+max_tram-tramo
		 xx = findgen(tramo) + xx0(0)
		 yy = offsmooth(xx)
 		 xx2 = (tramo*indgen(1000)/1000.) + xx0(0)
		 yy2 = interpol(yy,xx,xx2)
		 yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
		 ene = where(yfit eq max(yfit))
    	    	 polyfill, [xx(0),xx(0),xx(n_elements(xx)-1),xx(n_elements(xx)-1),xx(0)],$
		    [yminrang,ymaxrang,ymaxrang,yminrang,yminrang ],color=120
		 if ene(0) gt n_elements(xx2)-5 or ene(0) lt 5 then begin  ; if it goes to the extreme defringing again
    	            offsmooth= off(*,k)
	            for l = 0 , n_elements(off(*,0)) -1 do offsmooth(l) = total(off(l,k-ncolapsing:k))
	    	    for l = 2, n_elements(offsmooth) -3 do offsmooth(l)=mean(offsmooth[l-2:l+2])
		    max_tram = where(offsmooth[line_sel(m)-(tramo/2):line_sel(m)+(tramo/2)] eq max(offsmooth[line_sel(m)-(tramo/2):line_sel(m)+(tramo/2)]))
		    xx0 = line_sel(m)+max_tram-tramo
		    xx = findgen(tramo) + xx0(0)
		    yy = offsmooth(xx)
 		    xx2 = (tramo*indgen(1000)/1000.) + xx0(0)
		    yy2 = interpol(yy,xx,xx2)
		    yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
		    ene = where(yfit eq max(yfit))
		 endif
		 if ene(0) gt n_elements(xx2)-5 or ene(0) lt 5 then begin 
		    print, "#########################################################################################"
		    print, " "
		    print, "WARNING: FAILING to find the MAX in Row:" + string(k-ncolapsing)+":"+string(k)+ "(columns around "+ string(line_sel(m)) + " )"
		    print, "	 A higher colapsing number is recommended."
		    print, " "
		    print, "#########################################################################################"
		    printf,1, "#########################################################################################"
		    printf,1, " "
		    printf,1, "WARNING: FAILING to find the MAX in Row:" + string(k-ncolapsing)+":"+string(k)+ "(columns around "+ string(line_sel(m)) + " )"
		    printf,1, "	    A higher colapsing number is recommended."
		    printf,1, " "
		    printf,1, "#########################################################################################"
		 endif   
		 if line_sel2(0) lt  0. then line_sel2 =xx2(ene(0)) else line_sel2 =[ line_sel2, xx2(ene(0))]
    	     	 oplot, xx2, yfit, linestyle = 0, color=200 ,thick=2
		 oplot,[line_sel2(m),line_sel2(m)],[max(offsmooth)+ 0.5*mean(offsmooth),max(offsmooth)+ 0.6*mean(offsmooth)],linestyle=0,color =200.,thick=4
	         oplot,[line_sel2(m),line_sel2(m)],[0.,0.1*mean(offsmooth)],linestyle=0,color =200.,thick=4
	    endfor
	    oplot, offsmooth
	    ;
	    ; Fitting every line and getting data along the spacial direction
	    ;
    	    if n_elements(line_sel) gt 2 then begin 
	       if line_sel_total(0) lt 0. then begin
    	    	       line_sel_total= line_sel2
    	    	       wl_sel_total = wl_sel
		       k_sel_total =  replicate(k,n_elements(wl_sel))
    	       endif else begin
    	    	       line_sel_total = [line_sel_total, line_sel2]
    	    	       wl_sel_total = [wl_sel_total, wl_sel]
		       k_sel_total = [k_sel_total, replicate(k,n_elements(wl_sel))]
    	       endelse 
    	    endif   
    	endfor 
	;
	; Computing the calibration Matrix
	;
    	xpos = line_sel_total
	ypos = k_sel_total
	zpos = wl_sel_total
        wavecalim = off_record * 0.
	; 
	; Wave Calibration per line
	; 
	mean_av1= -999.
	for k = ncolapsing , n_elements(off(0,*)) -1, ncolapsing do begin 
           auxi =  where (ypos eq k)
           av =  poly_fit(xpos(auxi),zpos(auxi),1, yfit = yyfit) ; av=[!Value.F_NaN,!Value.F_NaN]
           xxx = indgen(n_elements(off_record(*,0)))
           zpos_vec = av(0) + xxx * av(1) ; + xxx^2. * av(2) + xxx^3. * av(3); + xxx^4. * av(4) + xxx^5. * av(5) 
           wavecalim(*,k-ncolapsing/2)=zpos_vec
	   if mean_av1(0) lt 0. then begin 
	    	mean_av1 = av(1)
	    	mean_av0 = av(0)
	   endif else begin
	    	mean_av1 = [mean_av1, av(1)]
	    	mean_av0 = [mean_av0, av(0)]
	   endelse
	   plot, xpos(auxi),zpos(auxi), psym = 2, /ystyle, /xstyle
	   oplot, xxx, zpos_vec, linestyle = 2
	endfor 	
	mean_av1 = mean(mean_av1)
	mean_av0 = mean(mean_av0)  
	print, filename(i),mean_av0, mean_av1, format = '(A20,F10.2,F10.2)'
	printf,3, filename(i),mean_av0, mean_av1, format = '(A20,F10.2,F10.2)'
	; 
	; Wave Calibration per column
	; 
	for k = 0, n_elements(off_record(*,0)) -1 do begin
           auxi = where (wavecalim(k,*) gt 0.)
           zvec= wavecalim(k,auxi)
           yvec= auxi
    	   if instrument eq "CC" then begin
            av =  poly_fit(yvec,zvec,3, yfit = yyfit)
            xxx = indgen(n_elements(off_record(0,*)))
            zpos_vec = av(0) + xxx * av(1) + xxx^2. * av(2) + xxx^3. * av(3); + xxx^4. * av(4)  + xxx^5. * av(5)+ xxx^6. * av(6)
            ;zpos_vec = replicate(av(0) ,n_elements(xxx)); * av(1)
           endif else begin
            av =  poly_fit(yvec,zvec,3, yfit = yyfit)
            xxx = indgen(n_elements(off_record(0,*)))
            zpos_vec = av(0) + xxx * av(1) + xxx^2. * av(2) + xxx^3. * av(3) ;+ xxx^4. * av(4);+ xxx^5. * av(5)
	   endelse
	   wavecalim(k,*)=zpos_vec   
	   plot, yvec,zvec, psym = 2, /ystyle, /xstyle
	   oplot, xxx, zpos_vec, linestyle = 2
	endfor
	; 
	; Writing the Calibration Matrix in OUTPUTS directory
	; 	
    	;
	; saving individuals
	;
	;hdrind = hdr
	;FXADDPAR, hdrind, "NAXIS3", 2 ,"Number of positions along axis 3"
	;writefits,'OUTPUTS/pl1_'+prefix+'_'+filename(i),on,hdrind
	;writefits,'OUTPUTS/pl2_'+prefix+'_'+filename(i),off_record,hdrind
	;writefits,'OUTPUTS/pl3_'+prefix+'_'+filename(i),onoff,hdrind
	;writefits,'OUTPUTS/pl4_'+prefix+'_'+filename(i),wavecalim,hdrind
	
	FXADDPAR, hdr, "NAXIS3", 4 ,"Number of positions along axis 3"
    	total_im=fltarr(n_elements(off_record(*,0)),n_elements(off_record(0,*)),4)
	total_im(*,*,0)=on
	total_im(*,*,1)=off_record
	total_im(*,*,2)=onoff
	total_im(*,*,3)=wavecalim
	writefits,'OUTPUTS/WL_'+prefix+'_'+filename(i),total_im,hdr
	; 
	; Plotting the calibration Matrix
	; 		
	loadct,6, NCOLORS=100
	plot, indgen(n_elements(wavecalim(0,*))),indgen(n_elements(wavecalim(*,0))),$
	    /nodata,position=[0.1,0.1,0.9,0.9],/normal,/xstyle, /ystyle,xrange=[0.,n_elements(wavecalim(*,0))],$
	    yrange=[0.,n_elements(wavecalim(0,*))],xtitle="X axis (pixels)",ytitle="Y axis (pixels)"
	contour, wavecalim,nlevels=100,/Noerase,/data,/fill,position =[0.1,0.1,0.9,0.9],/xstyle, /ystyle,$
	    xrange=[0.,n_elements(wavecalim(*,0))],yrange=[0.,n_elements(wavecalim(0,*))],c_colors=indgen(100),$
	    min_value=min(wavecalim),max_value=max(wavecalim)
	COLORBAR, NCOLORS=100, POSITION=[0.91,0.1,0.93,0.9],divisions=10,min=min(wavecalim)*1.E-4, $
	max=max(wavecalim)*1.E-4,format='(10f6.1)',/vertical,/right
	xyouts,0.4,0.92,"WL Calibration",/normal,charsize=1.3
	psterm,file='PRODUCTS/WL_'+prefix+'_'+filenameout+'.ps',/noplot
    endif
endfor
close,3
close,2
close,1
END
