PRO WLtransform , listname

readcol, 'PRODUCTS/id'+listname+'.lst', filename, tsa, si, acq, std, format = '(A,A,A,A,A)', /silent 
filename = filename(where(si eq "SPECTRUM"))

FOR k = 0, n_elements(filename) -1 DO BEGIN
    ;
    ; Reading files
    ;
    spectrum = readfits('OUTPUTS/WL_stck_'+filename(k),hdr_target,/silent)
    target= spectrum(*,*,2)
    wlcalib= spectrum(*,*,3)
    ; 
    ; Defining variables
    ;
    SPEdim =  n_elements(target(*,0))
    SPAdim =  n_elements(target(0,*))
    wlcalib_min = min(wlcalib)
    wlcalib_max = max(wlcalib)
     AWL = (max(wlcalib) - min(wlcalib) ) /SPEdim
     BWL = min(wlcalib) 
     WLvec = AWL * findgen(SPEdim)   + BWL
     ;
     ;  Calculating new matrix
     ;
     new_target = fltarr(SPEdim, SPAdim)
     new_wlcalib = fltarr(SPEdim, SPAdim)
     FOR i = 0 , SPAdim -1 DO BEGIN
	xvec_new = INTERPOL( findgen(SPEdim) ,wlcalib(*,i) , WLvec, /SPLINE)
	new_target(*,i) = INTERPOL( target(*,i) , findgen(SPEdim)  , xvec_new, /SPLINE)
	new_wlcalib(*,i) = WLvec
    ENDFOR
    ;
    ; Updating header
    ;
    
    fxaddpar, hdr_target , "WCSNAMEP", 'PHYSICAL'

    fxaddpar, hdr_target , "WCSTY1P",  'PHYSICAL'
    fxaddpar, hdr_target , "LTV1", 1.*BWL
    fxaddpar, hdr_target , "LTM1_1", 1.*AWL
    fxaddpar, hdr_target , "CTYPE1P",  'X'
    fxaddpar, hdr_target , "CRVAL1P",  1.*BWL
    fxaddpar, hdr_target , "CRPIX1P", 1.
    fxaddpar, hdr_target , "CDELT1P",1.*AWL
    fxaddpar, hdr_target , "WCSTY2P",  'PHYSICAL'
    fxaddpar, hdr_target , "LTV2", 1.
    fxaddpar, hdr_target , "LTM2_1", 1.
    fxaddpar, hdr_target , "CTYPE2P",  'Y'
    fxaddpar, hdr_target , "CRVAL2P",  1.
    fxaddpar, hdr_target , "CRPIX2P", 1.
    fxaddpar, hdr_target , "CDELT2P",1.

    fxaddpar, hdr_target , "NAXIS3", 1
    ;
    ; Writing results
    ;   
    ;new_image = fltarr(SPEdim, SPAdim, 4)
    ;new_image(*,*,0) = spectrum(*,*,0)
    ;new_image(*,*,1) = spectrum(*,*,1)
    ;new_image(*,*,2) = new_target
    ;new_image(*,*,3) = new_wlcalib
    writefits, 'OUTPUTS/WLC_stck_'+filename(k), new_target, hdr_target
ENDFOR

END
