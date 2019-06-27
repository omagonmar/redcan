PRO PerSec, listname, prefix
;
; Dividing by exposure time (and extraction positions and date of each observations)
;
;      Inputs: 
;               listname    :      name of the file list of observations.
;               prefix      :      prefix of the resulting image.
; 
; 
readcol, 'PRODUCTS/ID3'+listname+'.lst',name_exp, time1, time2, format = '(a, X,X,X,X,X,X, f, f)', /silent
FOR i = 0, n_elements(name_exp) -1 DO BEGIN
    print, "Converting  ", prefix+'_'+name_exp(i), "  with exposure   ", float(time1(i)), " sec."
    spectrum = readfits('OUTPUTS/'+prefix+'_'+name_exp(i),hdr, /silent)
    spectrum = spectrum/float(time1(i))
    writefits,'OUTPUTS/'+ prefix+'_'+name_exp(i),spectrum,hdr    
ENDFOR

END
