PRO WLtrace, onoff, calim, prefix, filenameout,center_trace, width_trace, av_center,av_fwhm, NCOLAPSING =  ncolapsing, instrument = instrument, slit_chosen = slit_chosen

;
;   IDL code to fit the spatial profile of the spectrum to a Moffat and determine the trace
;
;   Previous:	    XtractPlot XtractMain
;   After:  	    XtractPlot XtractMain
;
;   Dependences:    ----
;
;   Author: 	    O. Gonzalez-Martin (20th March 2011)
;   	    	    Change: 11th of May 2011: Compute the initial constant value of the slope in a proper way (not assuming anything).

onoff2 = onoff 
calim2 = calim

IF NOT keyword_set(NCOLAPSING) THEN ncolapsing = 10
;
; DIMEN
;
SPAdim =  n_elements(onoff(0,*))
SPEdim =  n_elements(onoff(*,0))
;
; Defining outputs
;
center_trace = fltarr(SPEdim)
width_trace = fltarr(SPEdim)

;
; Stacking along the spectral direction
;

size_fit = 70
profile_onoff = fltarr(SPAdim)
FOR l = 0, SPAdim -1 DO profile_onoff(l)= total(onoff(20:220,l)) 
aux = where(median(profile_onoff,10) eq max(median(profile_onoff,10)))
;psinit, /color
;plot, median(profile_onoff,20),/ystyle, /xstyle
;psterm, file = "PUREBA.ps", /noplot
center  = round(median(aux)) +20 > size_fit 
if center gt SPAdim - size_fit then center = SPAdim - size_fit -1
print, "Initial center position:   ", center, format = '(A40,I5)'
profile_onoff = profile_onoff(center-size_fit:center+size_fit) 

xvec = indgen(SPAdim)
aux = where(profile_onoff ge 1.*stddev(profile_onoff))
yfit = MPFITPEAK(xvec(aux), profile_onoff(aux), A, /MOFFAT, NTERMS = 6)
IF A(0) lt 1.*stddev(profile_onoff(aux)) THEN BEGIN
    profile_onoff = fltarr(SPAdim)
    FOR l = 0, SPAdim -1 DO profile_onoff(l)= total(onoff(20:220,l)) /total(onoff(10:19,l)) 
    aux = where(median(profile_onoff,10) eq max(median(profile_onoff,10)))
    center  = round(median(aux)) +20 > size_fit 
    if center gt SPAdim - size_fit then center = SPAdim - size_fit -1
    print, "Initial center position:   ", center, format = '(A40,I5)'
    profile_onoff = profile_onoff(center-size_fit:center+size_fit) 
    xvec = indgen(SPAdim)
    aux = where(profile_onoff ge 1.*stddev(profile_onoff))
    yfit = MPFITPEAK(xvec(aux), profile_onoff(aux), A, /MOFFAT, NTERMS = 6)
ENDIF
psinit, /color
loadct,6
plot, xvec,profile_onoff,/xstyle, /ystyle, yrange=[min(profile_onoff(aux)),1.*max(profile_onoff(aux))], xrange = [0,n_elements(profile_onoff)]
oplot, xvec(aux), yfit, linestyle =2 , color = 200.
xyouts, 0.6,0.80-0.04,"Peak:         " + string(A(0)), /normal
xyouts, 0.6,0.80-0.08,"Center:       " + string(A(1)), /normal
xyouts, 0.6,0.80-0.12,"FWHM:         " + string(A(2)), /normal
xyouts, 0.6,0.80-0.16,"Moffat Index: " + string(A(3)), /normal

xmin=  (center - size_fit)
xmax=  (center + size_fit)

;oplot,[xmin,xmin]  ,[0.,1.1*max(profile_onoff)],color = 200, thick = 2,linestyle = 2
;oplot,[xmax,xmax]  ,[0.,1.1*max(profile_onoff)],color = 200, thick = 2,linestyle = 2

cmoffat = -999.
numi = 1

FOR l = 0, SPEdim -ncolapsing -1, ncolapsing DO BEGIN
   xtofit = indgen(xmax-xmin+1) + xmin
   ytofit=total(onoff(l:l+ncolapsing,xmin:xmax),1)
   IF -1.*min(ytofit) lt 0.4*max(ytofit) THEN BEGIN
      yfit = MPFITPEAK(xtofit, ytofit, A, /MOFFAT, NTERMS = 6)
      plot, xtofit, ytofit,thick = 2,/xstyle, /ystyle, $
            yrange=[1.0*min(ytofit),1.0*max(ytofit)],xtitle = "Y axis (pixels)", ytitle= "Counts", $
            title = "Profile between lines:  "+ strtrim(string(l),1) + ":" + strtrim(string(l+ncolapsing),1)
      oplot, xtofit, yfit, linestyle =2 , color = 200.
      xyouts, 0.6,0.80-0.04,"Peak:         " + string(A(0)), /normal
      xyouts, 0.6,0.80-0.08,"Center:       " + string(A(1)), /normal
      xyouts, 0.6,0.80-0.12,"HWHM:         " + string(A(2)), /normal
      xyouts, 0.6,0.80-0.16,"Moffat Index: " + string(A(3)), /normal
      xyouts, 0.6,0.80-0.20,"Constant:     " + string(A(4)), /normal
      xyouts, 0.6,0.80-0.24,"Slope:        " + string(A(5)), /normal
     ; print, A(0),1.*stddev(ytofit)
      IF A(0) gt 1.*stddev(ytofit) THEN BEGIN
      	IF cmoffat(0) lt 0. THEN BEGIN
            cmoffat = A(1)
            wmoffat = A(2)
            xmoffat = l+ncolapsing/2.
      	ENDIF ELSE BEGIN
            cmoffat = [cmoffat,A(1)]
            wmoffat = [wmoffat,A(2)]
            xmoffat = [xmoffat,l+ncolapsing/2.]
      	ENDELSE
      ENDIF
   ENDIF
   numi = numi +1
ENDFOR


xvec = indgen(SPEdim)
if cmoffat(0) gt -900. and n_elements(cmoffat) gt 2 then begin
    av =  poly_fit(xmoffat,cmoffat,1, yfit = yyfit, yerror = yerr)     
    if n_elements(cmoffat) gt 10 then begin 
    	aux = where(cmoffat - yfit lt  mean(cmoffat - yfit) + 1.*stddev(cmoffat - yfit) and cmoffat - yfit gt mean(cmoffat - yfit) -1.*stddev(cmoffat - yfit) )
    endif else begin 
    	aux = where(cmoffat - yfit lt  mean(cmoffat - yfit) + 3.*stddev(cmoffat - yfit) and cmoffat - yfit gt mean(cmoffat - yfit) - 3.*stddev(cmoffat - yfit) )
    endelse
    av =  poly_fit(xmoffat(aux),cmoffat(aux),1, yfit = yyfit, yerror = yerr) 
    center_trace = av(0) + xvec*av(1) 
    av_center=av
    if n_elements(cmoffat) gt 10 then begin 
    	aux = where(wmoffat lt median(wmoffat) +1.*stddev(wmoffat) and wmoffat gt median(wmoffat) - 1.*stddev(wmoffat))
    endif else begin 
    	aux = where(wmoffat lt mean(wmoffat) +3.*stddev(wmoffat) and wmoffat gt mean(wmoffat) - 3.*stddev(wmoffat))
    endelse
    if instrument eq "CC" and slit_chosen eq 'LowRes-10' then begin
    	;  modification 18th of July to automatize the selection of the order for the N-Band and CC
    	av1 =  poly_fit(xmoffat(aux),wmoffat(aux),1, yfit = yyfit1, yerror = yerr, chisq=chisq1) 
    	av2 =  poly_fit(xmoffat(aux),wmoffat(aux),2, yfit = yyfit2, yerror = yerr, chisq=chisq2) 
    	residuals1 = sqrt( (yyfit1 - wmoffat(aux))^2.)
    	residuals2 = sqrt( (yyfit2 - wmoffat(aux))^2.)
    	probval = mean(residuals2) / mean(residuals1)
    	if (reform(probval) gt 0.9) then av = [reform(av1), 0.] else av = reform(av2)
    endif else begin 
    	av =  poly_fit(xmoffat(aux),wmoffat(aux),1, yfit = yyfit, yerror = yerr) 
    	av = [reform(av),0.]
    endelse
    width_trace = av(0) + xvec*av(1) + (xvec^2.) *av(2) 
    av_fwhm=av
    if center_trace(n_elements(center_trace) -1 ) - center_trace(n_elements(0 ) ) gt 5. then begin
    	print , "WARNING!! ", filenameout, '   not converging'
    	print,  "           default trace perfomed. centred at:  ", median(cmoffat(aux)), format = '(A60,I3 )' 
    	width_trace =   replicate( median(wmoffat(aux)),SPEdim)   
    	center_trace =  replicate(median(cmoffat(aux)),SPEdim)
    	av_center =  [median(cmoffat(aux)), 0.]
    	av_fwhm = [ 5., 0.,0.]
    endif
endif else begin
    print , "WARNING!! ", filenameout, '   to faint to perform trace determination'
    print,  "           default trace perfomed (centred at:  ", center, ' and a width of 5. pixels.', format = '(A60,I3 ,A60)' 
    width_trace =   replicate(5.,SPEdim)   
    center_trace =  replicate(center,SPEdim)
    av_center =  [median(cmoffat(aux)), 0.]
    av_fwhm = [ 5. , 0.,0.]
endelse
    
    plot, xmoffat, cmoffat,psym = 2,/ystyle,xtitle="X axis", ytitle = "CENTER of the Moffat profile", yrange = median(cmoffat(aux)) + [-3.*stddev(cmoffat(aux)), 3.*stddev(cmoffat(aux))]
    oplot, xvec, center_trace, linestyle = 2, color = 200,thick =2
    plot, xmoffat, wmoffat,psym = 2,/ystyle,xtitle="X axis", ytitle = "FWHM of the Moffat profile", yrange = median(wmoffat(aux)) + [-3.*stddev(wmoffat(aux)),3.*stddev(wmoffat(aux))]
    oplot, xvec, width_trace, linestyle = 2, color = 200,thick =2


loadct,6, NCOLORS=100
plot, indgen(n_elements(onoff(0,*))),indgen(n_elements(onoff(*,0))),$
    /nodata,position=[0.1,0.1,0.95,0.95],/normal,/xstyle, /ystyle,xrange=[0.,n_elements(onoff(*,0))],$
    yrange=[0.,n_elements(onoff(0,*))],xtitle="X axis (pixels)",ytitle="Y axis (pixels)"
contour, onoff,nlevels=100,/Noerase,/data,/fill,position =[0.1,0.1,0.95,0.95],/xstyle, /ystyle,$
    xrange=[0.,n_elements(onoff(*,0))],yrange=[0.,n_elements(onoff(0,*))],c_colors=indgen(100),$
    min_value=1.*min(onoff[100:200,50:200]),max_value=1.*max(onoff[100:200,50:200])
xyouts,0.1,0.97,"Spectrum and Trace of "+filenameout,/normal,charsize=1.3
oplot, indgen(SPEdim), center_trace ,linestyle = 2, thick = 4
oplot, indgen(SPEdim), center_trace - width_trace,linestyle = 0, thick = 4
oplot, indgen(SPEdim), center_trace + width_trace,linestyle = 0, thick = 4
psterm ,file='PRODUCTS/Moff_'+prefix+'_'+filenameout+'.ps',/noplot

onoff = onoff2  
calim = calim2  
END

