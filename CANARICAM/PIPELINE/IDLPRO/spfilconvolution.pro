function spfilconvolution,spectrum,filter,PLAMB=plamb

; spectrum: two-dimensional array [[wave],[flux]] [Ang.], [f_lambda [Ang.]]
; filter: two-dimensional array [[wave],[passband]] [Ang.], [whatever]
; plamb: pivot lambda used to pass from f_nu to f_lambda

on_error,2

specwave=spectrum[*,0]
spec=spectrum[*,1]
nspecwave=n_elements(spec)
filwave=filter[*,0]
fil=filter[*,1]
nfilwave=n_elements(fil)
;
; Selecting good interval ... 
; MODIF: 8 June 2011 
; Author: O. Gonzalez Martin
;
filtergood = WHERE(filwave ge specwave[0] and filwave le specwave[nspecwave-1])
filwave=filter[filtergood,0]
fil=filter[filtergood,1]
nfilwave=n_elements(fil)

IF specwave[0] GT filwave[0] OR specwave[nspecwave-1] LT filwave[nfilwave-1] THEN message,'Filter range outside spectrum range --------------------------------------------------------'
specfilwaveinds=where(specwave GE filwave[0] AND specwave LE filwave[nfilwave-1],nspecfilwaveinds)

specwave=specwave[specfilwaveinds]
spec=spec[specfilwaveinds]
intfil=interpol(fil,filwave,specwave)

; INTEGRATE: flux_d = int(P(l)*S(l)*l*dl) / int(P(l)*l*dl)

; Modification August to remove repited points
aux = -100
for i = 1 , n_elements(specwave) -1 do begin 
    if specwave(i) - specwave(i-1) gt 1. then begin 
    	if aux[0] lt 0 then aux = i else aux = [aux, i]
    endif
endfor

specwave = specwave(aux)
intfil = intfil(aux)
spec = spec(aux) 
; end of modification August
;pbflux=int_tabulated(specwave,intfil*spec*specwave,/DOUBLE)/int_tabulated(specwave,intfil*specwave,/DOUBLE)
;plamb=sqrt(int_tabulated(specwave,intfil*specwave,/DOUBLE)/int_tabulated(specwave,intfil/specwave,/DOUBLE))
aux = where(intfil gt 50.)
plamb = mean(specwave(aux))
aux = where(specwave gt 0.995*plamb and specwave lt 1.005*plamb)
pbflux = mean(spec(aux))
return,pbflux

END
