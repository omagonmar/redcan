PRO WLcalib, listname, prefix, NCOLAPSING =  ncolapsing, idldir

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
;;;; wlcalib_com = [74670.,78750.,85140.,88020.,95030.,102600.,117280.,128770.]
;;;; av0 = [94941.4424,220.] 

wlcalib_com = [74619.2101, 78813.4841 , 85166.8354 , 88033.285 , 94941.4424,  102622.713  ,117303.511  ,  128759.52  ]
av0 = [95030.,220.] ; assumes max is 9.5 sky line and resolution of 220. A/pixel
tramo = 5.
band = 700.

readcol, 'Spectrum_theor.dat', xtheor, ytheor
;  139   ...   95030

openw, 1, "PRODUCTS/texto.out"
openw,2, 'PRODUCTS/spectra_'+prefix+'_'+listname+'.lst'
for i = 0 , n_elements(filename) -1 do begin
    if si(i) eq "SPECTRUM" then begin
    	printf,2,'OUTPUTS/WL_'+prefix+'_'+filename(i), filename(i),format = '(A," ", A)'
    	spectrum = readfits('OUTPUTS/'+prefix+'_'+filename(i),hdr,/silent)
    	filenameout = strmid(filename(i), 0,14)
	on = spectrum(*,*,0)
    	off = spectrum(*,*,1)
    	onoff= spectrum(*,*,2)
    	for l = 0,n_elements(on(0,*))-1 do for m = 0, n_elements(off(*,0))-1 do off(m,l)=total([on(m,l),off(m,l)])
	;
	; Colapsing all
	;
   	offsmooth= off(*,0)
 	for m = 0 , n_elements(off(*,0)) -1 do offsmooth(m) = total(off(m,*))
;	openw,3, "Spectrum_theor.dat"
;	for m = 0 , n_elements(off(*,0)) -1 do printf,3, m, offsmooth(m),format = '(I,I20)'
;	close,3
		
	; 
	; Smoothing
	;
	for m = 1, n_elements(offsmooth) -1 do offsmooth(m)=mean(offsmooth[m-1:m])
		
	psinit,/color
	loadct,6
	plot, offsmooth,/xstyle,/ystyle,xtitle="X axis (pixels)", ytitle="Total Counts",title="Search for Sky-bands (colapsing Y)",charsize=1.2,$
	    yrange=[0.,max(offsmooth)+0.6*mean(offsmooth)],xrange=[-20,n_elements(offsmooth)-1]
    	
	;
	; Determining max just considering those with the 5 points before and after lower than the value
	;
    	line = -999.
    	for l = 5 , n_elements(off(*,0)) -6 do begin 
    		if offsmooth(l-1)  lt offsmooth(l) and offsmooth(l-2) lt offsmooth(l) and offsmooth(l-3)  lt offsmooth(l) and offsmooth(l-4) lt offsmooth(l) and offsmooth(l-5) lt offsmooth(l) and offsmooth(l+1) lt offsmooth(l) and offsmooth(l+2) lt offsmooth(l) and offsmooth(l+3) lt offsmooth(l) and offsmooth(l+4) lt offsmooth(l) and offsmooth(l+5) lt offsmooth(l) then begin 
    			if line(0) lt 0 then line = l else line = [line, l]
    		endif
    	endfor

	;
	; Determining correspondance of the lines assuming only that the resolution is 220 A/pixel
	;
	B_value = -999.
	for m= 0, n_elements(line) -1 do begin
	    if B_value(0) lt 0. then  B_value =  wlcalib_com - line(m)*av0(1) else B_value = [B_value, wlcalib_com - line(m)*av0(1)]
	endfor	
	B_value=B_value[sort(B_value)] 
	bns= 1000.
	h = histogram(B_value, binsize=bns, min=min(B_value))
	B_value2=bns* (Where(h EQ max(h))+0.5)+ Min(B_value)
	B_value2=mean(B_value2)
	;
	; Determining the correspondance of the lines assuming that: 1. the total max is the 9.5 line and 2. the resolution is 220 A/pixel 
	;	
	maxi = where(offsmooth(line) eq max(offsmooth(line)))
    	aux_maxi = where((1.*offsmooth(line))/ (1.*offsmooth(line(maxi(0)))) ge 0.90, nn)
	;
	; Determining offset using comparison between theoretical and observed
	;
;	psinit,/color
	chi =  fltarr(n_elements(off(*,0)) - n_elements(ytheor))
	for m = 0, n_elements(off(*,0)) - n_elements(xtheor)-1 do begin
	    chi(m) = stddev(offsmooth[m:m+n_elements(ytheor)] / ytheor)
	;    plot, offsmooth[m:m+n_elements(ytheor)] /mean(offsmooth[m:m+n_elements(ytheor)])
	;    oplot, ytheor / mean(ytheor)
	endfor
;	plot, chi
;	psterm, file = 'kk.ps',/noplot

	B_value3 = 95030. - ((where(chi eq min(chi)) + 139. - xtheor(0)) * av0(1))
    	print, "Selected method: MODE     ", B_value2
    	print, "Selected method: MAX      ", av0(0) - av0(1)*line(maxi(0))
	print, "Selected method: SPEC	  ", B_value3

	plotsym, 1
	oplot, line,offsmooth(line) + 0.1*mean(offsmooth(line)), psym= 8,symsize= 2
	for m = 0, n_elements(wlcalib_com) -1 do polyfill, $
	     (([band,band,-1.*band,-1.*band,band]+wlcalib_com(m)-B_value3(0))/av0(1)),$
	    [0.,max(offsmooth)+0.6*mean(offsmooth),max(offsmooth)+0.6*mean(offsmooth),0.,0. ],color=120
;	if  (nn gt 1 ) then begin
;	    firstattempt = B_value2 + av0(1)*line
;	    for m = 0, n_elements(wlcalib_com) -1 do polyfill, ([band,band,-1.*band,-1.*band,band] + wlcalib_com(m) - B_value2)/av0(1),$ 
;	    	[0.,max(offsmooth)+0.6*mean(offsmooth),max(offsmooth)+0.6*mean(offsmooth),0.,0. ],color=120
;     	endif else begin
;   	    firstattempt = av0(0) + av0(1) * (line - line(maxi(0)))
;	    print, "Selected method: MAX      ", av0(0) - av0(1)*line(maxi(0)),"  (   ", B_value2, "  )"
;	    for m = 0, n_elements(wlcalib_com) -1 do polyfill, $
;	    	 (([band,band,-1.*band,-1.*band,band]+wlcalib_com(m)-av0(0))/av0(1))+line(maxi(0)),$
;	    	[0.,max(offsmooth)+0.6*mean(offsmooth),max(offsmooth)+0.6*mean(offsmooth),0.,0. ],color=120
;	endelse 
	;
	; Determining the correspondance always with the comparison with the theoretical spectrum of the sky
	;		
    	firstattempt = B_value3(0) + av0(1) * (line)
	
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
	     xx = indgen(tramo) + line_sel(m)-(tramo)/2.
	     yy = offsmooth(xx)
	     xx2 = (tramo*indgen(1000)/1000.) + line_sel(m)-(tramo)/2.
	     yy2 = interpol(yy,xx,xx2)
	     yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
	     ene = where(yfit eq max(yfit))
	     if line_sel2(0) lt  0. then line_sel2 =xx2(ene(0)) else line_sel2 =[ line_sel2, xx2(ene(0))]
	     oplot, xx2, yfit+ 0.1*mean(yfit), linestyle = 0, color=200 ,thick=2
	     oplot,[line_sel2(m),line_sel2(m)],[max(offsmooth)+ 0.4*mean(offsmooth),max(offsmooth)+ 0.6*mean(offsmooth)],linestyle=0,color =200.,thick=2
	endfor
    	line_sel = line_sel2
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
	    for m = 1, n_elements(offsmooth) -1 do offsmooth(m)=mean(offsmooth[m-1:m])
	    ;
	    ; Ploting sky spectrum
	    ;
	    plot, offsmooth,/xstyle,/ystyle,xtitle="X axis (pixels)", ytitle="Total Counts",yrange=[0.,max(offsmooth)+0.6*mean(offsmooth)], $
	    	title="Search for Sky-bands: Colapsing: "+string(k-ncolapsing)+":"+string(k),charsize=1.2,xrange=[-20,n_elements(offsmooth)-1],/nodata
	    ;
	    ; Interpolating around the positions and determining the max by fitting to a gaussian profile
	    ;
	    line_sel2 = -999.
	    for m = 0 , n_elements(line_sel) -1 do begin 
		 max_tram = where(offsmooth[line_sel(m)-(tramo/2.):line_sel(m)+(tramo/2.)] eq max(offsmooth[line_sel(m)-(tramo/2.):line_sel(m)+(tramo/2.)]))
		 xx0 = line_sel(m)+max_tram-(tramo)
		 xx = findgen(fix(tramo)) + xx0(0)
		 yy = offsmooth(xx)
    	    	 polyfill, [xx(0),xx(0),xx(n_elements(xx)-1),xx(n_elements(xx)-1),xx(0)],$
		    [0.,max(offsmooth)+ 0.6*mean(offsmooth),max(offsmooth)+ 0.6*mean(offsmooth),0.,0.],color=120
 		 xx2 = (tramo*indgen(1000)/1000.) + xx0(0)
		 yy2 = interpol(yy,xx,xx2)
		 yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
		 ene = where(yfit eq max(yfit))
		 if ene(0) gt n_elements(xx2)-5 or ene(0) lt 5 then begin  ; if it goes to the extreme defringing again
    	            offsmooth= off(*,k)
	            for l = 0 , n_elements(off(*,0)) -1 do offsmooth(l) = total(off(l,k-ncolapsing:k))
	    	    for l = 1, n_elements(offsmooth) -2 do offsmooth(l)=mean(offsmooth[l-1:l+1])
		    max_tram = where(offsmooth[line_sel(m)-(tramo/2.):line_sel(m)+(tramo/2.)] eq max(offsmooth[line_sel(m)-(tramo/2.):line_sel(m)+(tramo/2.)]))
		    xx0 = line_sel(m)+max_tram-(tramo)
		    xx = findgen(fix(tramo)) + xx0(0)
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
    	     	 oplot, xx2-1., yfit+ 0.1*mean(yfit), linestyle = 0, color=200 ,thick=2
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
        calim = off
	for m = 0,n_elements(calim(*,0)) -1 do for k =  0,n_elements(calim(0,*)) -1 do calim(m,k)=0.
	; 
	; Lambda Calibration per line
	; 
	for k = ncolapsing , n_elements(off(0,*)) -1, ncolapsing do begin 
	    auxi =  where (ypos eq k )
	    av =  poly_fit(xpos(auxi),zpos(auxi),1, yfit = yyfit)  ; av=[!Value.F_NaN,!Value.F_NaN]
	    xxx = indgen(n_elements(off(*,0)))
	    zpos_vec = av(0) + xxx * av(1); + xxx^2. * av(2) + xxx^3. * av(3); + xxx^4. * av(4) + xxx^5. * av(5) 
	    calim(*,k)=zpos_vec
;	    plot, xpos(auxi),zpos(auxi), psym = -2,/ystyle
;:	    oplot, xxx, zpos_vec, linestyle =2 
	endfor 	
	; 
	; Lambda Calibration per column
	; 
	for k = 0, n_elements(off(*,0)) -1 do begin
            auxi = where (calim(k,*) gt 0. )
	    zvec= calim(k,auxi)
	    yvec= auxi
	    av =  poly_fit(yvec,zvec,3, yfit = yyfit)
	    xxx = indgen(n_elements(off(0,*)))
	    zpos_vec = av(0) + xxx * av(1) + xxx^2. * av(2) + xxx^3. * av(3)
;	    zpos_vec = interpol(zvec,yvec,xxx)
	    calim(k,*)=zpos_vec   
;	    plot, yvec,zvec, psym = -2,/ystyle
;	    oplot, xxx, zpos_vec, linestyle =2 
            
	endfor
	; 
	; Writing the Calibration Matrix in OUTPUTS directory
	; 	
 	FXADDPAR, hdr, "NAXIS3", 4 ,"Number of positions along axis 3"
    	total_im=fltarr(n_elements(off(*,0)),n_elements(off(0,*)),4)
	total_im(*,*,0:2)=spectrum
	total_im(*,*,3)=calim
	writefits,'OUTPUTS/WL_'+prefix+'_'+filename(i),total_im,hdr
	; 
	; Plotting the calibration Matrix
	; 		
	loadct,6, NCOLORS=100
	plot, indgen(n_elements(calim(0,*))),indgen(n_elements(calim(*,0))),$
	    /nodata,position=[0.1,0.1,0.9,0.9],/normal,/xstyle, /ystyle,xrange=[0.,n_elements(calim(*,0))],$
	    yrange=[0.,n_elements(calim(0,*))],xtitle="X axis (pixels)",ytitle="Y axis (pixels)"
	contour, calim,nlevels=100,/Noerase,/data,/fill,position =[0.1,0.1,0.9,0.9],/xstyle, /ystyle,$
	    xrange=[0.,n_elements(calim(*,0))],yrange=[0.,n_elements(calim(0,*))],c_colors=indgen(100),$
	    min_value=min(calim),max_value=max(calim)
	COLORBAR, NCOLORS=100, POSITION=[0.91,0.1,0.93,0.9],divisions=10,min=min(calim)*1.E-4, $
	max=max(calim)*1.E-4,format='(10f6.1)',/vertical,/right
	xyouts,0.4,0.92,"WL Calibration",/normal,charsize=1.3
	psterm,file='PRODUCTS/WL_'+prefix+'_'+filenameout+'.ps',/noplot
     endif
 endfor
close,2
close,1
END
