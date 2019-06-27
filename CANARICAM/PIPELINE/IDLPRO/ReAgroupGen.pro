PRO ReAgroupGen, list, prefixin, prefixout


;   ReAgroupGen    :   Routine to produce the final 
;
;
readcol, list, obs,format = '(A)'
obs = obs(1:n_elements(obs)-1)
FOR I = 0,n_elements(obs) -1  DO BEGIN
    pl1 = readfits(prefixin + '1_stck_'+ obs(i),hdr,/silent)
    pl2 = readfits(prefixin + '2_stck_'+ obs(i),hdr,/silent)
    pl3 = readfits(prefixin + '3_stck_' + obs(i),hdr,/silent)
    pl4 = readfits(prefixin + '4_stck_' + obs(i),hdr,/silent)
    pl = fltarr(n_elements(pl1(*,0)), n_elements(pl1(0,*)),4)
    pl(*,*,0)= pl1
    pl(*,*,1)= pl2
    pl(*,*,2)= pl3
    pl(*,*,3)= pl4
    FXADDPAR, hdr, "NAXIS", 4 
    FXADDPAR, hdr, "NAXIS1", n_elements(pl1(*,0)) ,"Number of positions along axis 1"
    FXADDPAR, hdr, "NAXIS2", n_elements(pl1(0,*)) ,"Number of positions along axis 2"
    FXADDPAR, hdr, "NAXIS3", 4 ,"Number of positions along axis 3"
    writefits,prefixout+'_stck_'+obs(i),pl,hdr
ENDFOR

END
