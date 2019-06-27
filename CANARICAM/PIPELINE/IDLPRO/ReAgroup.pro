PRO ReAgroup, inputfile

;
;    Reagrouping data-cube
;

readcol, inputfile, obs,nods, nnodsets, nsavesets, format = '(A,I,I,I)'
FOR I = 0,n_elements(obs) -1  DO BEGIN
    pl0 = readfits('OUTPUTS/micvtfltb_' + obs(i),hdr,exten= 0,/silent)
    pl1 = readfits('OUTPUTS/micvtfltb_' + obs(i),kk,exten=1)
    pl2 = readfits('OUTPUTS/miavtfltb_' + obs(i),kk,exten=1,/silent)
    pl3 = readfits('OUTPUTS/midvtfltb_' + obs(i),kk,exten=1,/silent)
    pl = fltarr(n_elements(pl1(*,0)), n_elements(pl1(0,*)),3)
    pl(*,*,0)= pl1
    pl(*,*,1)= pl2
    pl(*,*,2)= pl3
    FXADDPAR, hdr, "NAXIS", 3 
    FXADDPAR, hdr, "NAXIS1", n_elements(pl1(*,0)) ,"Number of positions along axis 3"
    FXADDPAR, hdr, "NAXIS2", n_elements(pl1(0,*)) ,"Number of positions along axis 3"
    FXADDPAR, hdr, "NAXIS3", 3 ,"Number of positions along axis 3"
    writefits,'OUTPUTS/stck_'+obs(i),pl,hdr
ENDFOR

END
