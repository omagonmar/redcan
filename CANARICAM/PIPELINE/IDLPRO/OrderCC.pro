PRO ORDERCC, infilen

;type_tsa = type_tsa[1:n_elements(files) -1 ]  
;type_is = type_is[1:n_elements(files) -1 ] 
;files = files[1:n_elements(files) -1 ]  
 
readcol, 'PRODUCTS/ID1'+infilen+'.lst', files_id1, object, obstype, obsclass, filter1, filter2, grating,slit,sector, $
	format='(A,A,A,A,A,A,A,A,X,X,A)'
grating = strmid(strtrim(grating ,1),0,9)



readcol, 'PRODUCTS/ID2'+infilen+'.lst', files_id2, timeobs, dateobs, timedate,format='(A,A,A,D)',/silent
;readcol, 'PRODUCTS/ID3'+infilen+'.lst', files_id3, frmtime,frmcoadd,chpcoadd,exposure, objtime, $
;	format='(A,D,D,D,D,D)',/silent
readcol, 'PRODUCTS/id'+infilen+'.lst', files,type_tsa, type_is, format = '(A,A,A)', /silent


; just in case the user reduced the number of observations
aux_ele = -999.
for i = 0 ,n_elements(files) -1 do begin
    auxi = where(files_id1 eq files(i))
    if aux_ele(0) lt -900. then aux_ele=auxi(0) else aux_ele = [aux_ele, auxi(0)]
endfor

timedate = timedate(aux_ele)
grating = grating(aux_ele)
slit = slit(aux_ele)
sector = sector(aux_ele)
filter1 = filter1(aux_ele)
filter2 = filter2(aux_ele)
aux = indgen(n_elements(files)) 


;files = files(aux)
;type_tsa = type_tsa(aux)
;type_is = type_is(aux)

; @@@@ Associating adquisition to observation

; including gratings!!! 
ACQ_ASSOC=replicate("NOASSOC",n_elements(files))
for i=0,n_elements(aux) -1 do begin & $ 
	if type_tsa(aux(i)) eq "ACQUISITION" then begin & $
		type_tsa_cut=strarr(n_elements(aux)-i) & $
		type_tsa_cut=type_tsa(aux[i:n_elements(aux)-1]) & $
		aux2=where(type_tsa_cut eq "STANDARD" or type_tsa_cut eq "TARGET")  & $
    	    	IF aux2(0) ge 0. THEN ACQ_ASSOC(i)= files(aux(i+aux2(0))) & $
	endif & $
endfor

; @@@@ Associating standard to target
aux_ts= where(type_tsa eq "TARGET" and type_is eq "SPECTRUM")
aux_ss= where(type_tsa eq "STANDARD" and type_is eq "SPECTRUM")
aux_ti= where(type_tsa eq "TARGET" and type_is eq "IMAGE")
aux_si= where(type_tsa eq "STANDARD" and type_is eq "IMAGE")

STD_ASSOC=replicate("NOASSOC",n_elements(files))
for i=1,n_elements(aux) -1 do begin & $ 
    if type_tsa(aux(i)) eq "TARGET" then begin
	if type_is(aux(i)) eq "SPECTRUM" then begin & $
	    if aux_ss(0) ge 0 then begin & $
    	    	aux_slit = where(slit(aux_ss)  eq slit(aux(i))  and grating(aux_ss)   eq  grating(aux(i))  and $
		    sector(aux_ss) eq sector(aux(i))  and  filter1(aux_ss) eq filter1(aux(i)) and  filter2(aux_ss) eq filter2(aux(i))) & $
	    	if aux_slit(0) ge 0 then begin & $
    	    	    aux2 = where(abs(timedate(aux(i)) - timedate(aux_ss(aux_slit))) eq min(abs(timedate(aux(i)) - timedate(aux_ss(aux_slit))))) & $
	    	    if aux2(0) ge 0 then begin & $
	    	    	STD_ASSOC(aux(i))=files(aux_ss(aux_slit(aux2(0)))) & $
	    	    endif & $	
	    	endif & $	
	    endif & $	
    	endif & $
        if type_is(aux(i)) eq "IMAGE" then begin & $
	    if aux_si(0) ge 0 then begin & $
    	    	aux_slit = where(slit(aux_si)  eq slit(aux(i))  and grating(aux_si)   eq  grating(aux(i)) and $
		    sector(aux_si) eq sector(aux(i)) and  filter1(aux_si) eq filter1(aux(i)) and filter2(aux_si) eq filter2(aux(i)) ) & $
	    	if aux_slit(0) ge 0 then begin & $
		    aux2 = where(abs(timedate(aux(i)) - timedate(aux_si(aux_slit))) eq min(abs(timedate(aux(i)) - timedate(aux_si(aux_slit))))) & $
	    	    if aux2(0) ge 0 then begin & $
	    	    	STD_ASSOC(aux(i))=files(aux_si(aux_slit(aux2(0)))) & $
    	    	    endif & $
    	    	endif & $
    	    endif & $
	endif & $
    endif & $
endfor


; @@@@ Printing outputs
print, "@@@ Associated files: "
print, "@ Note that the associated Standard will be the closest to the observation"
print, "@ The associated observation to the acquisition image will be the first observed after the acquis."
print, "FILE","TARG/STD/ACQ","SPEC/IM","ACQUIS","STANDARD", format = '(A20,A20,A20,A20,A20)'
for i =1,n_elements(aux) -1 do print, files(aux(i)),type_tsa(aux(i)),type_is(aux(i)),ACQ_ASSOC(i),STD_ASSOC(aux(i)),format="(A20,A20,A20,A20,A20)"
openw,1,'PRODUCTS/id'+infilen+'.lst'
    printf,1, "FILE","TARG/STD/ACQ","SPEC/IM","ACQUIS","STANDARD", format = '(A20,A20,A20,A20,A20)'
    for i =1,n_elements(aux) -1 do printf,1, files(aux(i)),type_tsa(aux(i)),type_is(aux(i)),ACQ_ASSOC(i),STD_ASSOC(aux(i)),format="(A20,A20,A20,A20,A20)"
close,1

END
