PRO MainTrace, listname, prefix, NCOLAPSING = ncolapsing, instrument = instrument

;
;   IDL code to extract each spectrum in different ways and make some plots
;
;   Previous:	    WLcalib
;   After:  	    XtractMain
;
;   Dependences:    Xtract WLtrace psinit psterm colorbar
;
;   Author: 	    O. Gonzalez-Martin (20th March 2011)
;


;
; Defining variables
;
IF NOT keyword_set(NCOLAPSING) THEN ncolapsing = 10

readcol, 'PRODUCTS/id'+listname+'.lst', filename, tsa, si, acq, std, format = '(A,A,A,A,A)', /silent 
filename = filename(where( (tsa eq "TARGET" or tsa eq "STANDARD") and si eq "SPECTRUM"))
readcol, 'PRODUCTS/ID1'+listname+'.lst',filenameslit,grating, slit,sector,format='(A,X,X,X,X,X,A,A,X,X,A)',/silent
grating = strmid(strtrim(grating ,1),0,9)

;readcol, 'PRODUCTS/spectra_'+prefix+'_'+listname+'.lst',filename,filename2,format='(A,A)',/silent
FOR i = 0 , n_elements(filename) -1 DO BEGIN
    spectrum = readfits('OUTPUTS/WL_'+prefix+'_'+filename(i),hdr,/silent)
    filenameout = strmid(filename(i), 0,14)
    onoff= spectrum(*,*,2)
    calim= spectrum(*,*,3)
    SPAdim =  n_elements(onoff(0,*))
    SPEdim =  n_elements(onoff(*,0))
    extract_pos = SPAdim/2 +3
    slit_chosen = grating(where(filenameslit eq filename(i)))
    ;
    ; Determining the trace
    ;
    print, "### Determining the trace of...", filenameout
    WLtrace, onoff , calim, prefix, filenameout, center_trace, width_trace, av_center,av_fwhm, NCOLAPSING = ncolapsing, instrument = instrument, slit_chosen = slit_chosen   ; add here the info in the header CHANGE!
    ;
    ; Including in the the header
    ;
    fxaddpar, hdr, "TrCtrA",av_center(1), "Slope of the trace's center"
    fxaddpar, hdr, "TrCtrB",av_center(0), "Constant of the trace's center"
    fxaddpar, hdr, "TrFWHMA",av_fwhm(2), "C1 of the trace's FWHM"
    fxaddpar, hdr, "TrFWHMB",av_fwhm(1), "C2 of the trace's FWHM (linear)"
    fxaddpar, hdr, "TrFWHMC",av_fwhm(0), "C3 of the trace's FWHM (const.)"
    ;
    ; Saving fits-file with the new header
    ;
    writefits, 'OUTPUTS/WL_'+prefix+'_'+filename(i), spectrum, hdr
ENDFOR   
END
