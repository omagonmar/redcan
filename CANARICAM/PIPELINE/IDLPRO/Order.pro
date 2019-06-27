PRO ORDER, infilen

;
;   IDL code to order the list of files and write the output files
;
;   Previous:	    Obsidentify.py
;   After:  	    Obsidentify.py and Stacking.py
;
;   Dependences:    ----
;
;   Author: 	    O. Gonzalez-Martin (Feb 2011)

readcol, 'PRODUCTS/ID1'+infilen+'.lst', files, object, obstype, obsclass, filter1, filter2, grating,slit,sector, $
	format='(A,A,A,A,A,A,A,A,X,X,A)',/silent
grating = strmid(strtrim(grating ,2),0,9)

readcol, 'PRODUCTS/ID2'+infilen+'.lst', files, timeobs, dateobs, timedate,format='(A,A,A,D)',/silent
readcol, 'PRODUCTS/ID3'+infilen+'.lst', files, frmtime,frmcoadd,chpcoadd,exposure, objtime, $
	format='(A,D,D,D,D,D)',/silent
;readcol, 'PRODUCTS/ID4'+infilen+'.lst', files, nnodsets, $
;	format='(A,A,A,F,A,A,A,A,A,A,F,F,F,F)',/silent

; @@@@  Ordering dataset according the initial time
timedate = timedate -min(timedate)
for i = 0, n_elements(timedate) -1 do print, files(i), timedate(i) , format = '("The relative time for  ", A20," is  ",I10)'
aux=sort(timedate)

; @@@@  Checking order and saving changes
step=fltarr(n_elements(timedate))
for i=0,n_elements(timedate) -1 do step(i) = timedate(i)-timedate(aux(i))
if max(step) eq 0 then print, "@@@ Files already ordered" else print, "@@@ Changing order of files:"
for i =0,n_elements(step) -1 do if step(i) ne 0 then print, "@ ",files(i), "  changed of order."

; @@@@ Classifying as IMAGE vs SPECTRUM according to the grating
TYPE_IS = strarr(n_elements(aux))
for j=0,n_elements(aux) -1 do begin & $ 
	if  grating(aux(j)) eq "LR_Ref_Mi" or grating(aux(j)) eq "Mirror" or grating(aux(j)) eq "Mirror+2" or grating(aux(j)) eq "Mirror+1" then begin & $
		TYPE_IS(aux(j)) = "IMAGE"  & $
	endif else begin & $
		TYPE_IS(aux(j)) =  "SPECTRUM" & $
	endelse & $
endfor

; @@@@ Classifying as STANDARD, TARGET or ACQUISITION according to the OBSCLASS
TYPE_TSA = strarr(n_elements(aux))
for j=0,n_elements(aux) -1 do begin & $ 
	if strtrim(obsclass(aux(j)),2) eq "partnerCal" or  strtrim(obsclass(aux(j)),2) eq "progCal"  or  strtrim(obsclass(aux(j)),2) eq "dayCal" then begin & $
		TYPE_TSA(aux(j))= "STANDARD" & $
	endif & $
	if strtrim(obsclass(aux(j)),2) eq "science" then begin & $
		TYPE_TSA(aux(j))= "TARGET" & $
	endif & $
	if strtrim( obsclass(aux(j)),2) eq "acq" or  strtrim(obsclass(aux(j)),2) eq "acqCal" then begin & $
		TYPE_TSA(aux(j))= "ACQUISITION" & $
	endif & $
endfor

; @@@@ Associating adquisition to observation
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
    
;if aux_ts(0) ge 0 then begin & $
;    for i = 0, n_elements(aux_ts) -1 do begin & $
;	aux2=where(abs(exposure(aux(aux_ts(i))) - exposure(aux(aux_ss))) eq min(abs(exposure(aux(aux_ts(i))) - exposure(aux(aux_ss))))) & $
;	STD_ASSOC(aux(aux_ts(i)))=files(aux(aux_ss(aux2))) & $
;    endfor & $
;endif
;if aux_ti(0) ge 0 then begin & $
;    for i = 0, n_elements(aux_ti) -1 do begin & $
;	aux2=where(abs(exposure(aux(aux_ti(i))) - exposure(aux(aux_si))) eq min(abs(exposure(aux(aux_ti(i))) - exposure(aux(aux_si))))) & $
;	STD_ASSOC(aux(aux_ti(i)))=files(aux(aux_si(aux2))) & $
;    endfor & $
;endif

; @@@@ Printing outputs
print, "@@@ Associated files: "
print, "@ Note that the associated Standard will be the closest to the observation"
print, "@ The associated observation to the acquisition image will be the first observed after the acquis."
print, "FILE","TARG/STD/ACQ","SPEC/IM","ACQUIS","STANDARD", format = '(A20,A20,A20,A20,A20)'
for i =0,n_elements(files) -1 do print, files(aux(i)),type_tsa(aux(i)),type_is(aux(i)),ACQ_ASSOC(i),STD_ASSOC(aux(i)),format="(A20,A20,A20,A20,A20)"
openw,1,'PRODUCTS/id'+infilen+'.lst'
printf,1, "FILE","TARG/STD/ACQ","SPEC/IM","ACQUIS","STANDARD", format = '(A20,A20,A20,A20,A20)'
for i =0,n_elements(files) -1 do printf,1, files(aux(i)),type_tsa(aux(i)),type_is(aux(i)),ACQ_ASSOC(i),STD_ASSOC(aux(i)),format="(A20,A20,A20,A20,A20)"
close,1
openw,1,'PRODUCTS/ORD'+infilen+'.lst'
for i =0,n_elements(files) -1 do printf,1,files(aux(i)) ,format='(A19)'
close,1

END
