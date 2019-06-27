PRO Fk2Dfrom1DSpec, LOCUSDIR

;
; Reding theoretical sky
;
readcol, '../PIPELINE/IDLPRO/Spectrum_theor_TRECS.dat', skyx,skyy,format = '(f,f)'
skyx = skyx -30
skyx2 = skyx
wv = (140000.-71490.)*(findgen(320)/320.) + 71490.
;
; Generating spectrum of the target
;
spec = 1.+ randomn(5L,320) + 0.05*(wv*1.E-4)^(3.) +  50000.*(wv*1.E-4)^(-3.)
emissionlines= [86000.,105100.,128000.,113000.] 
amplitudes = [100.,200.,20., 60. ]
sigmas = [300.,100.,400.,1800.]
for i = 0,n_elements(emissionlines) -1 do begin
    parms = [amplitudes(i),emissionlines(i),sigmas(i)]
    spec = spec + gaussian(wv,parms)
endfor
;
; Generating spectrum of the standard star 
;
wv2 = (350000.-20000.)*(findgen(1000)/1000.) + 20000.

std = (10.+ randomn(5L,320) + 100000.*(wv*1.E-4)^(-3.))
std2 = 10.+ randomn(5L,1000) + 100000.*(wv2*1.E-4)^(-3.)
openw,1, "../PIPELINE/COHEN/templates/HD00001.tem"
;    for i = 0,n_elements(wv2) -1 do printf,1,wv2(i)*1.E-4,double(std2(i))/ 1.86462e+14, format = '(E,E)'
    for i = 0,n_elements(wv2) -1 do printf,1,wv2(i)*1.E-4,double(std2(i)) /(1.E3*wv2(i)^2./3.e18/1.e-23) , format = '(E,E)'
close,1

;
; Absorptions
;
parms = [90.,95000.,3000.]
absorp = 100. + randomn(5L,320) - gaussian(wv,parms)
parms = [50.,113000.,3000.]
absorp = absorp - gaussian(wv,parms) 
parms = [100.,min(wv),3000.]
absorp = absorp - gaussian(wv,parms) 
parms = [100.,max(wv),3000.]
absorp = absorp - gaussian(wv,parms) 

;
; Converting to adus
;

adus_conversion = 1.E-3

psinit,/color
plot, wv*1.E-4,spec,/ystyle,/xstyle, yrange = [0., 1.1*max(spec)], xrange = [7.8, 13.3]
oplot, wv*1.E-4, std, linestyle = 2
oplot, wv*1.E-4, absorp, linestyle = 1
;
; Absorbing
;

stdabs = std * absorp + adus_conversion
specabs = spec * absorp + adus_conversion

plot, wv*1.E-4,specabs,/ystyle,/xstyle
oplot, wv*1.E-4, stdabs, linestyle = 2
wv2D = randomn(1L,320,240) +  10.
wv2Dstar = randomn(1L,320,240) +  10.
wv2Dsky = randomn(1L,320,240) +  10.
wv2Dsky2 = randomn(1L,320,240) +  10.

slope_sigma1 = 1./320.
slope_sigma2 = 1./320.
slope_center1 = 1./320.
slope_center2 =  1./320.
value = 3.*mean(wv2D)
print, value
FOR i = 0,n_elements(wv2D(*,0)) -1 DO BEGIN
    aux = where(skyx eq i, num)
    aux2 = where(skyx2 eq i, num2)
    parms = [ 120.+ slope_center1*float(i) , 1.5+ slope_sigma1*float(i),specabs(i), 0.]
    line1 = gauss1(findgen(240),parms) + randomn(1L,240)
    parms = [ 120.+slope_center2*float(i) , 1.5+ slope_sigma2*float(i),stdabs(i), 0.]
    line2 = gauss1(findgen(240),parms) + randomn(1L,240)
    FOR j = 0, n_elements(wv2D(0,*)) -1 DO BEGIN
    	if num gt 0. then wv2Dsky(i,j) = skyy(aux)/240. else wv2Dsky(i,j) = 10.
    	if num2 gt 0. then wv2Dsky2(i,j) = skyy(aux2)/240. else wv2Dsky2(i,j) = 10.
;    	if specabs(i)/(1. +abs(float(j)- 120.)^(2.5)) gt 1.*wv2d(i,j)     then wv2D(i,j)     = specabs(i)/(1. +abs(float(j)- 120.)^(2.5))
;   	if stdabs(i) /(1. +abs(float(j)- 120.)^(2.5)) gt 1.*wv2dstar(i,j) then wv2Dstar(i,j) = stdabs(i)/(1. +abs(float(j)- 120.)^(2.5))
;    	wv2D(i,*) =  gauss1(findgen(240),parms) + randomn(1L,240)
    	if  line1(j) gt value then   wv2D(i,j) = line1(j)
    	if  line2(j) gt value then   wv2Dstar(i,j) = line2(j)
    ENDFOR    
ENDFOR
wv2d = wv2d+abs(randomn(5L,320,240)) 
wv2dstar = wv2dstar+abs(randomn(5L,320,240))
wv2dsky = wv2dsky+abs(randomn(5L,320,240)) 
wv2dsky2 = wv2dsky2+abs(randomn(5L,320,240)) 
wv1d = fltarr(n_elements(wv2d(*,0)))
for i = 0,n_elements(wv1d) -1 do wv1d(i) = total(wv2d(i,100:140))
wv1dstar = fltarr(n_elements(wv2d(*,0)))
for i = 0,n_elements(wv1d) -1 do wv1dstar(i) = total(wv2dstar(i,100:140))

plot, wv*1.E-4, wv1d,/xstyle,/ystyle 
oplot, wv*1.E-4, wv1dstar, linestyle = 2
yran = [90., 300.]
plot, wv*1.E-4,spec,/ystyle,/xstyle, yrange = yran, xrange = [7.8, 13.3],$
    	xtitle = textoidl('Wavelength (\mum)', font = -1) , ytitle = textoidl('F_{\nu} (Jy)', font = -1),charsize = 1.5

tentative_lines = [8.6,9.7, 10.51, 11.3, 12.81]
tentative_names = ["PAH","Si","[S IV]","PAH","[Ne II]"]
FOR k = 0,n_elements(tentative_lines) -1 DO oplot, [tentative_lines(k),tentative_lines(k)], yran,linestyle = 2, thick =2
xyouts ,tentative_lines - 0.1, replicate(1.01*yran(1),n_elements(tentative_lines)), tentative_names, /data 
psterm,file= locusdir + 'Theoric_spec.ps'
;
; computing the data-cube
;
spec_target = fltarr(320,240,3)
spec_target(*,*,0) = wv2d + wv2dsky
spec_target(*,*,1) = wv2dsky
spec_target(*,*,2) = wv2d
spec_std = fltarr(320,240,3)
spec_std(*,*,0) =wv2dstar + wv2dsky2
spec_std(*,*,1) = wv2dsky2
spec_std(*,*,2) = wv2dstar

writefits,locusdir + "/OUTPUTS/stck_S00000000S0001.fits",spec_target
writefits, locusdir +"/OUTPUTS/stck_S00000000S0002.fits",spec_std
;
; Reading them to add parameters to the header
;
spec1 = readfits(locusdir +"/OUTPUTS/stck_S00000000S0001.fits", hdr1)
spec2 = readfits(locusdir +"/OUTPUTS/stck_S00000000S0002.fits", hdr2)

fxaddpar, hdr1,"SLITCORR",'1.000'
fxaddpar, hdr1,"INSTRUME", 'CanariCam'         ,  "Instrument used to acquire data. "       
fxaddpar, hdr1,"OBJECT", 'MYTARGFAKED '           ,"Target Name    "                                
fxaddpar, hdr1,"OBSTYPE", 'OBJECT  '	   ,    "Observation type"				
fxaddpar, hdr1,"OBSCLASS", 'science '           ,"Observe class"                                  
fxaddpar, hdr1,"OBSERVAT", 'Gemini-South',"Gemini North or Gemini South   "                    
fxaddpar, hdr1,"TELESCOP", 'Gemini-South' ,"Telescope where data taken   "                      
fxaddpar, hdr1,"EPOCH ",                2000. ,"Target Coordinate Epoch        "                    
fxaddpar, hdr1,"EQUINOX",                2000. ,"Equinox of coordinate system "                      
fxaddpar, hdr1,"TRKEQUIN",                2000. ,"Tracking equinox   "                                
fxaddpar, hdr1,"SSA", 'ssa     '          ,"Gemini SSAs         "                               
fxaddpar, hdr1,"RA",         0.000000000 ,"Target Right Ascension "                            
fxaddpar, hdr1,"DEC",         -0.00000000 ,"Target Declination "                          

fxaddpar, hdr2,"SLITCORR",'1.000'
fxaddpar, hdr2,"INSTRUME", 'CanariCam   '         ,  "Instrument used to acquire data. "       
fxaddpar, hdr2,"OBJECT", 'MYSTDFAKED '           ,"Target Name    "                                
fxaddpar, hdr2,"OBSTYPE", 'OBJECT  '	   ,    "Observation type"				
fxaddpar, hdr2,"OBSCLASS", 'partnerCal '           ,"Observe class"                                  
fxaddpar, hdr2,"OBSERVAT", 'Gemini-South',"Gemini North or Gemini South   "                    
fxaddpar, hdr2,"TELESCOP", 'Gemini-South' ,"Telescope where data taken   "                      
fxaddpar, hdr2,"EPOCH ",                2000. ,"Target Coordinate Epoch        "                    
fxaddpar, hdr2,"EQUINOX",                2000. ,"Equinox of coordinate system "                      
fxaddpar, hdr2,"TRKEQUIN",                2000. ,"Tracking equinox   "                                
fxaddpar, hdr2,"SSA", 'ssa     '          ,"Gemini SSAs         "                               
fxaddpar, hdr2,"RA",         0.000000000 ,"Target Right Ascension "                            
fxaddpar, hdr2,"DEC",         -0.00000000 ,"Target Declination "                          

writefits, locusdir +"/OUTPUTS/stck_S00000000S0001.fits",spec1, hdr1
writefits, locusdir +"/OUTPUTS/stck_S00000000S0002.fits",spec2, hdr2

openw,1,locusdir + '/inputfile.lst'
    printf,1, "S00000000S0001.fits"
    printf,1, "S00000000S0002.fits"
close,1
openw,1,locusdir +'/PRODUCTS/idinputfile.lst'
    printf,1, "FILE","TARG/STD/ACQ","SPEC/IM","ACQUIS","STANDARD", format = '(A20,A20,A20,A20,A20)'
    printf,1, "S00000000S0001.fits", "TARGET","SPECTRUM", "NOASSOC",  "S00000000S0002.fits", format = '(A20,A20,A20,A20,A20)'
    printf,1, "S00000000S0002.fits", "STANDARD","SPECTRUM", "NOASSOC",  "NOASSOC", format = '(A20,A20,A20,A20,A20)'
close,1
openw,1,locusdir +'/PRODUCTS/ID1inputfile.lst'
    printf,1,"S00000000S0001.fits",'MYTARGFAKED ' ,"OBJECT",	"science", "Open","N",	"LowRes-10",	'0.70',	'0.0000000',	'0.0000000', format = '(A18,A18,A8,A12,A6,A6,A10,A10,A10,A10)'
    printf,1,"S00000000S0002.fits",'MYSTDFAKED ' ,"OBJECT",	"partnerCal", "Open","N",	"LowRes-10",	'0.70',	'0.0000000',	'0.0000000', format = '(A18,A18,A8,A12,A6,A6,A10,A10,A10,A10)'
close,1
openw,1,locusdir +'/PRODUCTS/targets_inputfile.lst'
    printf,1,'MYTARGFAKED'
close,1
openw,1,locusdir +'/PRODUCTS/ID2inputfile.lst'
    printf,1,"S00000000S0001.fits",'99:99:99.9' ,'2999-99-99',	'99999999999.9', format = '(A18,A18,A8,A18)'
    printf,1,"S00000000S0002.fits",'00:00:00.0' ,'2999-99-99',	'99999999999.9',  format = '(A18,A18,A8,A18)'
close,1
openw,1,locusdir +'/PRODUCTS/redshifts_inputfile.lst'
    printf,1,'MYTARGFAKED', '0.000000'
close,1
stop
END
