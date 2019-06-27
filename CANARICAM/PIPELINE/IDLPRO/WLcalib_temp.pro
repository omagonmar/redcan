PRO WLcalib, listname, prefix

readcol, 'PRODUCTS/id'+listname,filename,tsa,si,acqassoc,stdassoc,$
	format='(A,A,A,A,A)',/silent
wlcalib_com = [74670.,78750.,85140.,88020.,95030.,102600.,117280.,128770.]

for i = 0 , n_elements(filename) -1 do begin
    if si(i) eq "SPECTRUM" then begin
    	spectrum = readfits('OUTPUTS/'+prefix+'_'+filename(i),hdr,/silent)
    	on = spectrum(*,*,0)
    	off = spectrum(*,*,1)
    	onoff= spectrum(*,*,2)
    	line_sel_total = -999.
    	for k = 10 , n_elements(off(0,*)) -1,10  do begin 
    	    av = [95030.,220.]  ; assumes max is 9.5 sky line and resolution of 220. A/pixel
    	    middleoff=k
    	    offsmooth= off(*,k)
    	    ;
	    ; Colapsing every 10 lines
	    ;
	    for m = 0 , n_elements(off(*,0)) -1 do offsmooth(m) = total(off(m,k-10:k))
    	    ;
	    ; Smoothing the spectrum
	    ;
    	    offsmooth= median(offsmooth,3)
    	    ;
	    ; Determining maximuns just considering those with the 5 points before and after lower than the value
	    ;
    	    line = -999.
    	    for l = 5 , n_elements(off(*,middleoff)) -6 do begin 
    	    	    if offsmooth(l) gt 1.0*mean(offsmooth) and offsmooth(l-1)  lt offsmooth(l) and offsmooth(l-2) lt offsmooth(l) and offsmooth(l-3)  lt offsmooth(l) and offsmooth(l-4) lt offsmooth(l) and offsmooth(l-5) lt offsmooth(l) and offsmooth(l+1) lt offsmooth(l) and offsmooth(l+2) lt offsmooth(l) and offsmooth(l+3) lt offsmooth(l) and offsmooth(l+4) lt offsmooth(l) and offsmooth(l+5) lt offsmooth(l) then begin 
    	    		    if line(0) lt 0 then line = l else line = [line, l]
    	    	    endif
    	    endfor
     	    ;
	    ; Determining the correspondence of the lines assuming that: 1. the total max is the 9.5 line and 2. the resolution is 220 A/pixel 
	    ;
   	    maxi = where(offsmooth(line) eq max(offsmooth(line)))
    	    av = [95030.,220.]  ; assumes max is 9.5 sky line and resolution of 220. A/pixel
    	    firstattempt = av(0) + av(1) * (line - line(maxi(0))) ;  else firstattempt = av(0) + av(1) * line
    	    line_sel = -999.
    	    wl_sel = -999.
    	    for l = 0, n_elements(firstattempt) -1 do begin 
    	       aux = where(abs(wlcalib_com - firstattempt(l)) lt 300.) 
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
		 xx = indgen(10) + line_sel(m)-5
		 yy = offsmooth(xx)
		 xx2 = (indgen(1000)/100.) + line_sel(m)-5
		 yy2 = interpol(yy,xx,xx2)
		 yfit = GAUSSFIT(xx2, yy2, coeff, NTERMS=3)  
		 ene = where(yfit eq max(yfit))
		 if line_sel2(0) lt  0. then line_sel2 =xx2(ene(0)) else line_sel2 =[ line_sel2, xx2(ene(0))]
	    endfor
	    ;
	    ; Fitting every line and getting data along the spacial direction
	    ;
	    line_sel = line_sel2
    	    if n_elements(line_sel) gt 2 then begin 
    	       av=poly_fit( line_sel, wl_sel,1)
	       if line_sel_total(0) lt 0. then begin
    	    	       line_sel_total= (wl_sel - av(0))/av(1)
    	    	       wl_sel_total = wl_sel
		       k_sel_total =  replicate(k,n_elements(wl_sel))
    	       endif else begin
    	    	       line_sel_total = [line_sel_total, (wl_sel - av(0))/av(1)]
    	    	       wl_sel_total = [wl_sel_total, wl_sel]
		       k_sel_total = [k_sel_total, replicate(k,n_elements(wl_sel))]
    	       endelse 
    	    endif   
    	endfor 
	;
	; Computing the distorsion along the spatial direction (Y)
	;
	psinit,/color
	xx_sel = -999.
	auxi = where(wl_sel_total eq wlcalib_com(4)) 
	plot, k_sel_total(auxi), line_sel_total(auxi)- mean(line_sel_total(auxi)), psym = 2, /ystyle,$ 
		charsize = 1.2,xtitle="y (pixels)",ytitle="deviation (pixels)",/nodata, /xstyle
	for m = 0 , n_elements(wlcalib_com) - 1 do begin 
		auxi = where(wl_sel_total eq wlcalib_com(m)) 
		if auxi(0) ge 0 then begin 
			if xx_sel(0) lt 0 then begin
				xx_sel = k_sel_total(auxi)
				yy_sel = line_sel_total(auxi)- median(line_sel_total(auxi))
			endif else begin 
				xx_sel = [xx_sel, k_sel_total(auxi)]
				yy_sel = [yy_sel, line_sel_total(auxi)- median(line_sel_total(auxi))]
			endelse
			oplot, k_sel_total(auxi), line_sel_total(auxi)- median(line_sel_total(auxi)), psym = m
		endif
	endfor	
	av_yfinal = poly_fit(xx_sel, yy_sel, 2,yfit = value_y, yerror = error_y)
	vec = n_elements(off(0,*))*findgen(1000)/1000.
	oplot, vec, av_yfinal(0) + av_yfinal(1)*vec + av_yfinal(2)*vec^2.
	auxi= where((yy_sel - value_y) lt error_y)
	av_yfinal = poly_fit(xx_sel(auxi), yy_sel(auxi), 2,yfit = value_y, yerror = error_y)
	oplot, vec, av_yfinal(0) + av_yfinal(1)*vec + av_yfinal(2)*vec^2., linestyle = 2
    	print, "The final transformation is:   dy = ",av_yfinal,  format = '(A25, F,F,F)'
	line_sel_total = line_sel_total - ( av_yfinal(0) + av_yfinal(1)*k_sel_total + av_yfinal(2)*k_sel_total^2.)
	; 
	; Lambda Calibration per line
	; 
	for k = 10 , n_elements(off(0,*)) -1,10  do begin 
		auxi =  where (k_sel_total eq k )
		if auxi(0) ge 0 then begin
			av =  poly_fit(line_sel_total(auxi),wl_sel_total(auxi),1) 
			print, k, av, format = '(I,F,F)'
		endif
	endfor 	
	;
	; Total Lambda Calibration
	;
    	av_final=poly_fit(line_sel_total,wl_sel_total,1) 
    	plot, line_sel_total, wl_sel_total*1.E-4,psym=2,/ystyle, /xstyle,charsize = 1.2,xtitle="x (pixel)",ytitle="A"
    	oplot, [0.,250.],(av_final(1)*[0.,250.] + av_final(0))*1.E-4, linestyle = 2
    	print, "The final transformation is:   ",av_final(0) , " + ",av_final(1), " x pixel (A)", format = '(A30, F10.3,A5, F10.3, A20)'
	;
	; Writing calibration in the header
	;
	print, av_final(0) - av_final(1)*av_yfinal(0), av_final(1), -1.*av_final(1)*av_yfinal(1), -1.*av_final(1)*av_yfinal(2)
	A = av_final(0) - av_final(1)*av_yfinal(0) 
	B = av_final(1)
	C =  -1.*av_final(1)*av_yfinal(1)
	D = -1.*av_final(1)*av_yfinal(2) 
	vec = indgen(n_elements(onoff(*, 123)) )
 	print, "Adding transformation to the header in :  "+prefix+'_'+filename(i)
 	FXADDPAR, hdr, "Cal_A", A, "Wave. cal. L(A) = A + B * x + C * y+ D * y^2"
 	FXADDPAR, hdr, "Cal_B", B, "Wave. cal. L(A) = A + B * x + C * y+ D * y^2"
 	FXADDPAR, hdr, "Cal_C", C, "Wave. cal. L(A) = A + B * x + C * y+ D * y^2"
 	FXADDPAR, hdr, "Cal_D", D, "Wave. cal. L(A) = A + B * x + C * y+ D * y^2"
	writefits,'OUTPUTS/'+prefix+'_'+filename(i),spectrum,hdr
	psterm, file = 'PRODUCTS/WL_'+filename(i)+'.ps', /noplot
    endif
endfor
end
