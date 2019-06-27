pro calib_spec,GALAXY=galaxy,APTYPE=aptype,APER=aper,NAME=name,STDNAME=stdname,SAVE=save,FIXAPER=fixaper,STEPS=steps,SPLINE=spline,CALC=calc,SILENT=silent,OUTOFBOUNDS=oob,ONLYFIG=onlyfig,CONVOL=convol,NOEXTEN=noexten,SYNTH=synth,ALIGN=align,ROOTDIR=rootdir

set_plot,'x'
device,retain=2,decompose=0
;IF keyword_set(rootdir) EQ 0 THEN rootdir='/data1/trecs_spec/working/'
IF keyword_set(rootdir) EQ 0 THEN rootdir='/home/tanio/data/trecs/sample/spectroscopy/'

IF keyword_set(convol) THEN BEGIN
    convol=convol
    ini=1
ENDIF ELSE BEGIN
    convol=''
    ini=0
ENDELSE

; DETERMINAMOS LOS PARAMETROS ESPECIALES PARA CADA GALAXIA
CASE galaxy OF
    'ngc3256': BEGIN
    dir=rootdir+'ngc3256/postredux/'
    label1=['_set1','_set2','_set3'] ; [089,094,100]
    label2=['_std1','_std1','_std2'] ; [084,084,122]
    readdir=[dir,dir,dir]
    stdspecname=[dir+'HD27697_std1.tem',dir+'HD27697_std1.tem',dir+'HD27697_std1.tem']
    extraw=[0.33333,0.33333,0.33333]
    slitloss=[2.0,2.0,2.2]
    stdairmass=[1.077,1.077,1.160]
    objairmass=[1.032,1.073,1.179]
    z=1.009354
    END
    'ic4518w': BEGIN
    dir=rootdir+'ic4518w/postredux/'
    label1=['_set1','_set2','_set3'] ; [081,082,083]
    label2=['_std1','_std1','_std1'] ; [073,073,073]
    readdir=[dir,dir,dir]
    stdspecname=[dir+'HD123123_std1.tem',dir+'HD123123_std1.tem',dir+'HD123123_std1.tem']
    extraw=[0.33333,0.33333,0.33333]
    slitloss=[1.35,1.35,1.35]
    stdairmass=[1.024,1.024,1.024]
    objairmass=[1.040,1.027,1.040]
    z=1.015728/0.999
    END
    'ngc5135': BEGIN
    dir=rootdir+'ngc5135/postredux/'
    label1=['_set1','_set2','_set3'] ; [098,106,107]
    label2=['_std1','_std1','_std1'] ; [092,101,101]
    readdir=[dir,dir,dir]
    stdspecname=[dir+'HD101666_std1.tem',dir+'HD101666_std1.tem',dir+'HD101666_std1.tem']
    extraw=[0.33333,0.33333,0.33333]
    slitloss=[1.125,1.16,1.16]
    stdairmass=[1.045,1.068,1.068]
    objairmass=[1.010,1.164,1.072]
    z=1.014693/1.0005
    END
    'ngc7130': BEGIN
    dir=rootdir+'ngc7130/commonpostredux/'
    label1=['_n0_set1','_n0_set2','_n1_set1','_n1_set2','_n1_set3','_n2_set1','_n3_set1','_n3_set2','_n4_set1','_n4_set2'] ; [061,062,111,112,113,057,107,108,097,098]
    label2=['_std1','_std2','_std1','_std1','_std1','_std1','_std2','_std2','_std1','_std1'] ; [055,097,106,106,106,051,114,114,092,092]
    readdir=[rootdir+'ngc7130/night0_050918/postredux/',rootdir+'ngc7130/night0_050918/postredux/',rootdir+'ngc7130/night1_060704/postredux/',rootdir+'ngc7130/night1_060704/postredux/',rootdir+'ngc7130/night1_060704/postredux/',rootdir+'ngc7130/night2_060829/postredux/',rootdir+'ngc7130/night3_060916/postredux/',rootdir+'ngc7130/night3_060916/postredux/',rootdir+'ngc7130/night4_060925/postredux/',rootdir+'ngc7130/night4_060925/postredux/']
    stdspecname=[dir+'HD190056_std1.tem',dir+'HD219784_std2.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem',dir+'HD219784_std2.tem',dir+'HD219784_std2.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem']
    extraw=[0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10,0.10]
    slitloss=[1.32,1.30,1.03,1.03,1.03,1.27,1.26,1.26,1.5,1.5]
    stdairmass=[1.448,1.323,1.009,1.009,1.009,1.101,1.092,1.092,1.234,1.234]
    objairmass=[1.253,1.445,1.007,1.008,1.038,1.227,1.076,1.165,1.088,1.184]
    z=1.016151/0.998
    END
ENDCASE

; TIPO DE APERTURA: ESPECIFICO (APTYPE) O AUTOMATICO (APER); DEFAULT (_ap4pix)
IF keyword_set(aptype) THEN aptype=galaxy+'_'+aptype ELSE IF keyword_set(aper) THEN aptype=galaxy+'_ap'+strtrim(string(aper,format='(i)'),2)+'pix' ELSE aptype=galaxy+'_ap4pix'
; APERTURA VARIABLE (=0); FIJA (=1,2)
IF keyword_set(fixaper) EQ 0 THEN fixlab='' ELSE IF fixaper EQ 1 THEN fixlab='_fix' ELSE IF fixaper EQ 2 THEN fixlab='_fix2'
; DEFINIMOS EL NOMBRE
IF keyword_set(name) EQ 0 THEN name=aptype+fixlab+'_cal'
IF keyword_set(spline) EQ 0 THEN spline='' ELSE spline='_spl'
IF keyword_set(noexten) THEN exten=0 ELSE exten=1
IF keyword_set(onlyfig) THEN ini=onlyfig ELSE ini=0

xsize=450 & ysize=450

;; ATM. TRANS.
;IF keyword_set(atmtrans) THEN BEGIN
;atmtransname='' & read,'Trasmission: ',atmtransname
; CARGAMOS LA TRANSMISION DE LA ATM. (WL POR DEFECTO EN NM!!!!!!)
atmtransname=rootdir+'cohen_stds/midIR_trans_MK_AM1.1_WV1.0.dat'
tmpatmtrans=read_ascii(atmtransname)
atmtranssize=size(tmpatmtrans.field1)
atmtrans=tmpatmtrans.field1[*,*]
atmtrans[0,*]=atmtrans[0,*]*1e4 ; Pasamos a Ang
;atmtrans[0,*]=3e18/atmtrans[0,*] ; Pasamos a Hz
;atmtrans=reverse(atmtrans,2,/OVER)
;ENDIF

;; CARGAMOS EL FILTRO
;filpbname='' & read,'Filter: ',filpbname
; CARGAMOS EL FILTRO (WL POR DEFECTO EN MICRAS!!!!!!)
filpbname=rootdir+'cohen_stds/Trecs_Nband.dat'
tmpfilpb=read_ascii(filpbname)
filpbsize=size(tmpfilpb.field1)
filpb=tmpfilpb.field1[*,*]
;print,'Pblamb: ',int_tabulated(filpb[0,*],filpb[1,*]*filpb[0,*],/DOUBLE)/int_tabulated(filpb[0,*],filpb[1,*],/DOUBLE)
filpb[0,*]=filpb[0,*]*1e4 ; Pasamos a Ang
;filpb[0,*]=3e18/filpb[0,*] ; Pasamos a Hz
;filpb=reverse(filpb,2,/OVER)

;; CARGAMOS LA DQE
; CARGAMOS EL DQE (WL POR DEFECTO EN MICRAS!!!!!)
dqename=rootdir+'cohen_stds/dqe.dat'
tmpdqe=read_ascii(dqename)
dqesize=size(tmpdqe.field1[*,*])
dqe=tmpdqe.field1[*,*]
dqe[0,*]=dqe[0,*]*1e4 ; Pasamos a Ang

; PASOS DE LA EXTRACCION ----------------------------------------------
FOR a=steps[0],steps[1],steps[2] DO BEGIN

; PRIMERO CALCULOS, LUEGO GRAFICOS
IF keyword_set(calc) THEN BEGIN; FOR h=ini,1 DO BEGIN

; CASO ESPECIAL NGC7130 CON DOS REGIONES
IF galaxy EQ 'ngc7130' AND a GT 80 OR keyword_set(oob) THEN BEGIN
    label1=['_n0_set1','_n0_set2','_n2_set1','_n4_set1','_n4_set2'] ; [061,062,057,097,098]
    label2=['_std1','_std2','_std1','_std1','_std1'] ; [055,097,051,092,092]
    readdir=[rootdir+'ngc7130/night0_050918/postredux/',rootdir+'ngc7130/night0_050918/postredux/',rootdir+'ngc7130/night2_060829/postredux/',rootdir+'ngc7130/night4_060925/postredux/',rootdir+'ngc7130/night4_060925/postredux/']
    stdspecname=[dir+'HD190056_std1.tem',dir+'HD219784_std2.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem',dir+'HD190056_std1.tem']
    extraw=[0.20,0.20,0.20,0.20,0.20]
    slitloss=[1.32,1.30,1.27,1.5,1.5]
    stdairmass=[1.448,1.323,1.101,1.234,1.234]
    objairmass=[1.253,1.445,1.227,1.088,1.184]
ENDIF

ndatasets=n_elements(label1)
weight=fltarr(ndatasets)
print,'Offset from nucleus: ',a

; CARGAMOS Y MANIPULAMOS CADA SET DE DATOS --------------------------------
FOR b=0,ndatasets-1 DO BEGIN

;headobj=headfits(dir+aptype+'_'+label1[b]+'_'+label2[b]+'.fits')
;inputobjspec=double(readfits(dir+aptype+'_'+label1[b]+'_'+label2[b]+'.fits',headobjext1,/NOSCALE,EXTEN=exten,/SILENT))
headobj=headfits(readdir[b]+aptype+label1[b]+label2[b]+fixlab+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits')
inputobjspec=readfits(readdir[b]+aptype+label1[b]+label2[b]+fixlab+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',headobjext1,/NOSCALE,EXTEN=exten,/SILENT) ; [[A],[counts s-1]]
; STANDARD
headstd=headfits(readdir[b]+stdname+label1[b]+label2[b]+'_fix2_0'+spline+'.fits')
inputstdspec=readfits(readdir[b]+stdname+label1[b]+label2[b]+'_fix2_0'+spline+'.fits',headstdext1,/NOSCALE,EXTEN=exten,/SILENT)

IF a EQ steps[0] AND b EQ 0 THEN BEGIN
print,'Loading object: ',readdir[b]+aptype+label1[b]+label2[b]+fixlab+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits'
print,'Loading standard: ',readdir[b]+stdname+label1[b]+label2[b]+'_fix2_0'+spline+'.fits'
ENDIF

; BUSCAMOS LOS TSSONS
frmtimelocobj=where(strmid(headobj,0,7) eq "FRMTIME")
frmtimeobj=strmid(headobj[frmtimelocobj[0]],9,60)+0.
frmcoaddlocobj=where(strmid(headobj,0,8) eq "FRMCOADD")
frmcoaddobj=strmid(headobj[frmcoaddlocobj[0]],9,60)+0.
chpcoaddlocobj=where(strmid(headobj,0,8) eq "CHPCOADD")
chpcoaddobj=strmid(headobj[chpcoaddlocobj[0]],9,60)+0.
tssonsobj=frmtimeobj*.001*frmcoaddobj*chpcoaddobj

frmtimelocstd=where(strmid(headstd,0,7) eq "FRMTIME")
frmtimestd=strmid(headstd[frmtimelocstd[0]],9,60)+0.
frmcoaddlocstd=where(strmid(headstd,0,8) eq "FRMCOADD")
frmcoaddstd=strmid(headstd[frmcoaddlocstd[0]],9,60)+0.
chpcoaddlocstd=where(strmid(headstd,0,8) eq "CHPCOADD")
chpcoaddstd=strmid(headstd[chpcoaddlocstd[0]],9,60)+0.
tssonsstd=frmtimestd*.001*frmcoaddstd*chpcoaddstd

; BUSCAMOS LOS NCOMBINE
ncombinelocobj=where(strmid(headobjext1,0,8) eq "NCOMBINE")
IF ncombinelocobj[0] NE -1 THEN ncombineobj=strmid(headobjext1[ncombinelocobj[0]],9,60)+0. ELSE ncombineobj=1
weight[b]=ncombineobj

IF keyword_set(silent) EQ 0 AND a EQ steps[0] THEN print,'TSSONS obj, std, NCOMB: ',tssonsobj,tssonsstd,ncombineobj

; CARGAMOS LAS LAMBDAS
;tmpfitpos=read_ascii(stdname+'_posfunct.dat')
;lambs=tmpfitpos.field001[*]
objlambs=inputobjspec[*,0]
stdlambs=inputstdspec[*,0]
synthlambs=findgen(241)*222.+78120. ; [78120:131400]
;synth=1 ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF keyword_set(synth) THEN lambs=synthlambs ELSE lambs=objlambs
nlambs=n_elements(lambs[*,0])

; RANGO EN LONGITUD DE ONDA
dellamb=lambs[1]-lambs[0]
minxr=where(abs(lambs-78850.) LE dellamb/2.,nminxr)>0 & minxr=minxr[nminxr-1]
maxxr=where(abs(lambs-131020.) LE dellamb/2.,nmaxxr)<(nlambs-1) & maxxr=maxxr[0]
lambrange=[lambs[minxr],lambs[maxxr]]*1e-4
nlambrange=maxxr-minxr+1
yrange=[-.005,.15]
;obsspec[0:minxr-1]=0.;obsspec[minxr]
;obsspec[maxxr+1:319]=0.;obsspec[maxxr]
;lamb0=where(lambs GE 105100.*1.014693/1.0005-dellamb/2.)
;lamb0=lamb0[0]
IF a EQ steps[0] THEN BEGIN
    print,'INI, END, # index lambs: ',minxr,maxxr,maxxr-minxr
    print,'0, INI, END, nlambs-1, DELTA object lamb: ',objlambs[0],objlambs[minxr],objlambs[maxxr],objlambs[nlambs-1],objlambs[1]-objlambs[0]
    print,'0, INI, END, nlambs-1, DELTA stand. lamb: ',stdlambs[0],stdlambs[minxr],stdlambs[maxxr],stdlambs[nlambs-1],stdlambs[1]-stdlambs[0]
    IF keyword_set(synth) THEN print,'0, INI, END, nlambs-1, DELTA synth. lamb: ',synthlambs[0],synthlambs[minxr],synthlambs[maxxr],synthlambs[nlambs-1],synthlambs[1]-synthlambs[0]
    print,'Weight: ',weight[b]
ENDIF

; SI ELEGIMOS LAMBDAS SINTETICAS, INTERPOLAMOS LOS ESPECTROS
IF keyword_set(synth) THEN BEGIN
    objlambs=lambs
    stdlambs=lambs
; INTERPOLAMOS OBJETO Y ESTANDAR PORQUE LAS LAMBDAS NO COINCIDEN!!!!
    objspec=interpol(inputobjspec[*,1],inputobjspec[*,0],lambs,/LSQUAD)
    stdspec=interpol(inputstdspec[*,1],inputstdspec[*,0],lambs,/LSQUAD)
ENDIF ELSE BEGIN
    objspec=inputobjspec[*,1]
    stdspec=inputstdspec[*,1]
ENDELSE

; OBJETO / STANDARD
obsspec=objspec/stdspec
null=where(finite(obsspec) EQ 0)
IF null[0] NE -1 THEN obsspec[null]=0.

; PINTAMOS
IF keyword_set(silent) EQ 0 THEN BEGIN
set_plot,'x'
window,0,XSIZE=xsize,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,inputobjspec[minxr:maxxr,1],XRANGE=lambrange,TIT='Obj spectrum',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
window,1,XSIZE=xsize,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,inputstdspec[minxr:maxxr,1],XRANGE=lambrange,TIT='Std standard',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
window,2,XSIZE=xsize,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,obsspec[minxr:maxxr],XRANGE=lambrange,TIT='Input spec/std*inpstd',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
;;window,4,XSIZE=xsize,YSIZE=ysize & plot,lambs*1e-4,intsynstd,XRANGE=lambrange,TIT='Input spec/std',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
;window,3,XSIZE=xsize,YSIZE=ysize & plot,lambs*1e-4,obsspec,XRANGE=lambrange,YRANGE=yrange,TIT='Inpgimut cohen_std',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
;;window,4,XSIZE=xsize,YSIZE=ysize & plot,lambs,ima2[*],XRANGE=lambrange,TIT='Interp cohen_std',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
;;window,5,XSIZE=xsize,YSIZE=ysize &
;;plot,lambspec,obsspec,XRANGE=lambrange,TIT='Output spec Jy
;;',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
ENDIF

IF keyword_set(align) THEN BEGIN

intstdspec=stdspec
REPEAT BEGIN

read,'What offset do you want to apply [pix]? (99 to exit): ',offset
IF offset NE 99. THEN BEGIN
    tmpobjspec=objspec
    tmpstdspec=stdspec
    intstdspec=interpol(tmpstdspec,stdlambs,objlambs+offset*dellamb,/LSQUAD)
    obsspec=tmpobjspec/intstdspec    
ENDIF

set_plot,'x'
window,0,XSIZE=xsize+150,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,objspec[minxr:maxxr],XRANGE=lambrange,TIT='Obj spectrum',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
oplot,lambs[minxr:maxxr]*1e-4,intstdspec[minxr:maxxr]/max(stdspec[minxr:maxxr])*max(objspec[minxr:maxxr]),linestyle=2
oplot,[lambs[79],lambs[79]]*1e-4,[0.,1e6],linestyle=1
window,1,XSIZE=xsize+150,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,intstdspec[minxr:maxxr],XRANGE=lambrange,TIT='Std standard',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
window,2,XSIZE=xsize+150,YSIZE=ysize
plot,lambs[minxr:maxxr]*1e-4,obsspec[minxr:maxxr],XRANGE=lambrange,YRANGE=[0,.05],TIT='Input spec/std',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
oplot,[lambs[79],lambs[79]]*1e-4,[0.,1e6],linestyle=1

ENDREP UNTIL offset EQ 99.

ENDIF ; align

;; CARGAMOS COHEN STANDARD
;stdspecname='' & read,'Stdspectrum: ',stdspecname
; CARGAMOS EL ESPECTRO DE LA ESTANDARD (WL POR DEFECTO EN MICRAS!!!!!!
;                       FLUJO en Wcm-2um-1)
tmpsynstdspec=read_ascii(stdspecname[b])
synstdspecsize=size(tmpsynstdspec.field1[*,*])
synstdspec=tmpsynstdspec.field1[*,*]
synstdspec[0,*]=synstdspec[0,*]*1e4 ; Pasamos a [A]
synstdspec[1,*]=(synstdspec[1,*]*1e7*1e-4) ; Pasamos a [erg s-1 cm-2 A-1]
;synstdspec[1,*]=synstdspec[1,*]*synstdspec[0,*]^2/3e18 ; Pasamos a ]erg s-1 cm-2 Hz-1]
;synstdspec[0,*]=3e18/synstdspec[0,*] ; Pasamos a Hz
;synstdspec=reverse(synstdspec,2,/OVER)

; INTERPOLAMOS LA SED DE LA ESTANDAR DE COHEN A LAS WL DEL OBJETO Y
; MULTIPLICAMOS LOS ESPECTROS PARA RECOBRAR LA FORMA ORIGINAL
intsynstd=interpol(synstdspec[1,*],synstdspec[0,*],lambs,/LSQUAD)
obsspec=obsspec*intsynstd ; [erg s-1 cm-2 A-1]

; COMO CALIBRAR NGC3256 Y NO MORIR EN EL INTENTO: YA QUE SE ESCOGIO
; INTELIGENTEMENTE UNA ESTANDAR QUE NO ERA DE COHEN (HR4450), NO HABIA
; ESPECTRO SINTETICO ASI QUE HEMOS TENIDO QUE RECURRIR AL ESPECTRO DE
; OTRA ESTANDAR DE TIPO ESPECTRAL SIMILAR (HD) G7III +/- = G8III. ASI
; PUES LA FORMA DEL ESPECTRO SERA APROX. LA MISMA Y PODEMOS UTILIZAR
; EL ESPECTRO SINTETICO PARA CORREGIR DEL PERFIL. SIN EMBARGO LO QUE
; NO PODEMOS ESTIMAR ES EL FACTOR DE CONVERSION ADUs-1 -> Jy YA QUE
; TENEMOS LOS ADUs-1 DE LA ESTANDARD MEDIDA PERO LOS Jy DE LA QUE
; HEMOS COGIDO COMO "TIPO". ASI PUES, LO QUE HE DECIDIDO ES UTILIZAR
; EL FACTOR DE CONVERSION MEDIO QUE SE HA CALCULADO PARA LAS OTRAS
; GALAXIAS (~3.1E-18) QUE ES APROX. 0.5 VECES EL FACTOR DE CONVERSION
; QUE SE OBTIENE AL DIVIDIR LA DENSIDAD DE ADUs-1 EN LA BANDA N DE LA
; ESTANDARD OBSERVADA ENTRE LA DENSIDAD DE FLUJO EN Jy DE LA "TIPO"
; TB. EN LA BANDA N.
; 
IF galaxy EQ 'ngc3256' THEN obsspec=obsspec*.5

; CALCULAMOS LA DENSIDAD DE FLUJO
specfildqeconv,stdspec,filpb,DQE=dqe,DFLUX=stdpbflux,PLAMB=stdplamb,lamb=lambs,/SILENT
specfildqeconv,obsspec,filpb,DQE=dqe,DFLUX=pbflux,PLAMB=plamb,lamb=lambs,/SILENT
specfildqeconv,intsynstd,filpb,DQE=dqe,DFLUX=synstdpbflux,PLAMB=synstdplamb,lamb=lambs,/SILENT

; MOSTRAMOS LA DENSIDAD DE FLUJO DE LA ESTANDAR
IF a EQ steps[0] THEN BEGIN
    stdpbflux=stdpbflux*plamb^2/3e18/1e-23
    synstdpbflux=synstdpbflux*plamb^2/3e18/1e-23 ; Pasamos a [Jy]
    print,'Integrated stdspec, synstdspec pbfluxes: ',stdpbflux,' ADUs-1, ',synstdpbflux,' Jy. N-band conversion factor: ',synstdpbflux/stdpbflux,' Jy (ADUs-1)-1'
ENDIF

; MOSTRAMOS LA DENSIDAD DE FLUJO DEL OBJETO PARA CADA DATASET
pbflux=pbflux*plamb^2/3e18/1e-23 ; Pasamos a [Jy]
IF keyword_set(silent) EQ 0 THEN print,'Integrated osbsspec pbflux set '+strtrim(string(b+1),2)+': ',pbflux*1e3,' mJy'

obsspec=obsspec*lambs^2/3e18/1e-23 ; Pasamos a [F_nu]

; INICIALIZAMOS VARIABLES AT STEP 0
IF a EQ steps[0] THEN BEGIN
    IF b EQ 0 THEN meanlambs=lambs/ndatasets ELSE $
    meanlambs=meanlambs+lambs/ndatasets;[minxr:maxxr]
    ncount=0
ENDIF

; INICIALIZAMOS ESPECTRO FINAL AT DATASET 0
IF b EQ 0 THEN finalspec=obsspec*weight[b]*extraw[b]/slitloss[b] $
ELSE finalspec=finalspec+obsspec*weight[b]*extraw[b]/slitloss[b];[minxr:maxxr]

;print,'Flux: ',b,' dataset',total(obsspec[lamb0-3:lamb0+3])
;IF b EQ 0 THEN BEGIN
;    finalspec=fltarr(nlambs)
;    finalspec[1]=obsspec[0:n_elements(lambs)-2]*extraw[b]
;;    obsspecinterp[1:n_elements(lambs)-1]=obsspec[0:n_elements(lambs)-2]
;;    FOR l=0,n_elements(lambs)-2 DO obsspecinterp[l+1]=obsspec[l]
;;    finalspec=finalspec+obsspecinterp/3.
;ENDIF ELSE BEGIN
;    finalspec=finalspec+obsspec*extraw[b]
;ENDELSE

ENDFOR ;b=ndatasets-1

; CALCULOS FINALES AT FINAL DATASET
;IF b EQ ndatasets-1 THEN BEGIN
    ;finalspec=convol(finalspec,gauss1dgen(21.,1./sqrt(2.*!pi)/1.,10.,1.))
    ; CALCULAMOS LA DENSIDAD DE FLUJO
finalspec=finalspec/total(weight*extraw)
IF a EQ steps[0] THEN print,'Total Ncombine: ',total(weight)
; PASAMOS A F_LAMB TEMPORALMENTE
tmpfinalspec=finalspec/meanlambs^2.*3e18*1e-23 ; Pasamos a [F_lamb]
; INTEGRAMOS F_LAMB SOBRE LAMB
specfildqeconv,tmpfinalspec,filpb,DQE=dqe,DFLUX=pbflux,PLAMB=plamb,lamb=meanlambs,INTFILPB=intfilpb,/SILENT
; DETERMINAMOS LA DENSIDAD DE FLUJO
pbflux=pbflux*plamb^2./3e18/1e-23 ; Pasamos a Jy
print,'Averaged '+strtrim(string(ndatasets),2)+'-dataset flux: ',pbflux*1e3,' mJy'
IF ncount EQ 0 THEN print,'INI, END, DELTA object lamb: ',meanlambs[0],meanlambs[nlambs-1],meanlambs[1]-meanlambs[0]
; print,'Flux mean dataset: ',total(finalspec[lamb0-3-minxr:lamb0+3-minxr])
IF keyword_set(silent) EQ 0 THEN BEGIN
    window,3,XSIZE=xsize,YSIZE=ysize
    plot,meanlambs[minxr:maxxr]*1e-4,finalspec[minxr:maxxr],XRANGE=lambrange,TIT='Input spec/std*inpstd',thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
    oplot,meanlambs[minxr:maxxr]*1e-4,fltarr(nlambrange)+pbflux
ENDIF

; ALMACENAMOS LOS ERRORES
IF abs(pbflux*1e3) LT 1.5*sqrt(aper) THEN BEGIN
    IF ncount EQ 0 THEN noise=fltarr(nlambs,(steps[1]-steps[0])/steps[2]+1)
    noise[*,ncount]=finalspec
    ncount=ncount+1
    print,'Used for computing errors'
ENDIF

IF keyword_set(save) THEN BEGIN

IF a EQ steps[0] THEN BEGIN
openw,fluxes,dir+name+spline+'_fluxes.dat',/GET_LUN
meanfinalspec=fltarr(nlambs)
stdvfinalspec=fltarr(nlambs)
ENDIF

printf,fluxes,a,pbflux

IF a EQ steps[0] THEN print,'Writing: ',dir+name+'_*'+spline+'.fits'
; GRABAMOS EL ESPECTRO en Jy!!!!!!!!!!
file_delete,dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',/ALLOW
IF keyword_set(noexten) THEN BEGIN
    writefits,dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',[[meanlambs],[finalspec]],headobj
ENDIF ELSE BEGIN
    writefits,dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',0.,headobj
    writefits,dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',[[meanlambs],[finalspec]],headobjext1,/APPEND
ENDELSE

IF a EQ steps[1] THEN BEGIN

atmweight=interpol(reform(atmtrans[1,*]),reform(atmtrans[0,*]),meanlambs,/LSQUAD)
;atmweight=atmweight/max(atmweight)

IF keyword_set(onlyfig) EQ 0 AND keyword_set(convol) EQ 0 AND steps[0] LE -40 AND steps[1] GE 40 THEN BEGIN
    ; SI HACEMOS EL ESCANEADO... CALCULAMOS LOS ERRORES
    FOR l=0,ncount-1 DO meanfinalspec=meanfinalspec+noise[*,l]/ncount
    FOR l=0,ncount-1 DO stdvfinalspec=stdvfinalspec+(noise[*,l]-meanfinalspec)^2.
    ; ERROR FINAL = STDEV * SQRT(APERTURE/SAMPLING STEP) ;/ ATMWEIGHT
    stdvfinalspec=sqrt(stdvfinalspec/(ncount-1));*sqrt(aper/steps[2]) ;*sqrt(aper/4.)/atmweight

; Si se promedia (hacer mean) en una apertura APER, da igual que haya
; overlapping (i.e., el paso sea menor que APER). Al final, la stdev
; sera 1./sqrt(APER) veces la que se obtiene si se coge de 1pix en
; 1pix  en el array original.
; Si se suma (hacer total, como es el caso), tambien da igual que haya
; overlapping. Al final la stdev sera sqrt(APER) veces la que se
; obtiene cogiendo de 1pix en 1pix.

; Asi pues el overlapping no influye en el calculo del error. Y como
; luego extraemos los espectros con APER, para calcular el stdev
; debemos hacerlo tambien con la misma APER

    print,'Writing stdev array: ',dir+name+spline+'_err.fits'
    file_delete,dir+name+spline+'_err.fits',/ALLOW
    IF keyword_set(noexten) THEN BEGIN
        writefits,dir+name+spline+'_err.fits',[[meanlambs],[stdvfinalspec],[atmweight]],headobj
    ENDIF ELSE BEGIN
        writefits,dir+name+spline+'_err.fits',0.,headobj
        writefits,dir+name+spline+'_err.fits',[[meanlambs],[stdvfinalspec],[atmweight]],headobjext1,/APPEND
    ENDELSE

print,'Mean sky spec and mean stdev. @ all lambs and positions: ',mean(meanfinalspec),',',mean(stdvfinalspec),' Jy with ncount=',ncount;,' and factor of sqrt(aper/step)=',sqrt(aper/steps[2])

ENDIF ELSE BEGIN ;save/load err

    ; CARGAMOS LOS ERRORES: Siempre los de la apertura de 4pix!!!!!!!!!!
    print,'Loading stdev array: ',dir+galaxy+'_ap4pix_fix2_cal'+spline+'_err.fits'
    stdvfinalspec=readfits(dir+galaxy+'_ap4pix_fix2_cal'+spline+'_err.fits',EXTEN=exten,/NOSCALE,/SILENT)
    IF stdvfinalspec[0] EQ -1 THEN message,'Cannot load stdev array. Have you calculated it before?'
    stdvfinalspec=stdvfinalspec[*,1]*sqrt(aper/4.)

ENDELSE ;save err/load

print,'Re-writing: ',dir+name+'_*'+spline+'.fits'
FOR aa=steps[0],steps[1],steps[2] DO BEGIN

; CARGAMOS DE NUEVO EL ESPECTRO
finalspec=readfits(dir+name+'_'+strtrim(string(aa,format='(i)'),2)+spline+'.fits',EXTEN=exten,/NOSCALE,/SILENT)
meanlambs=finalspec[*,0]
finalspec=finalspec[*,1]

; REGRABAMOS EL ESPECTRO CON SU ERROR
; Y EL ERROR PARA ESA POSICION APARTE en Jy!!!!!!!!!!
file_delete,dir+name+'_'+strtrim(string(aa,format='(i)'),2)+spline+'.fits',/ALLOW
IF keyword_set(noexten) THEN BEGIN
    writefits,dir+name+'_'+strtrim(string(aa,format='(i)'),2)+spline+'.fits',[[meanlambs],[finalspec],[stdvfinalspec],[atmweight]],headobj
ENDIF ELSE BEGIN
    writefits,dir+name+'_'+strtrim(string(aa,format='(i)'),2)+spline+'.fits',0.,headobj
    writefits,dir+name+'_'+strtrim(string(aa,format='(i)'),2)+spline+'.fits',[[meanlambs],[finalspec],[stdvfinalspec],[atmweight]],headobjext1,/APPEND
ENDELSE

ENDFOR

ENDIF ;a=steps[1]

ENDIF ;save

ENDIF ELSE BEGIN; calc=0

; CARGAMOS LOS ESPECTROS EN Jy!!!!!!!!!!
print,'Loading ',dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits'
finalspec=readfits(dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+'.fits',EXTEN=exten,/NOSCALE,/SILENT)
meanlambs=finalspec[*,0]
stdvfinalspec=finalspec[*,2]
atmweight=finalspec[*,3]
finalspec=finalspec[*,1]
; Y LAS DENSIDADES DE FLUJO
tmppbflux=read_ascii(dir+name+spline+'_fluxes.dat')
pbflux=tmppbflux.field1[1,where(tmppbflux.field1[0,*] EQ a)]

nlambs=n_elements(meanlambs[*,0])
dellamb=meanlambs[1]-meanlambs[0]
minxr=where(abs(meanlambs-78120.) LE dellamb/2.,nminxr)>0 & minxr=minxr[nminxr-1]
maxxr=where(abs(meanlambs-131400.) LE dellamb/2.,nmaxxr)<(nlambs-1) & maxxr=maxxr[0]
lambrange=[meanlambs[minxr],meanlambs[maxxr]]*1e-4
nlambrange=maxxr-minxr+1

extern='XYOUTS,'+strtrim(string(lambrange[0]*1.02),2)+','+strtrim(string((max(finalspec[minxr:maxxr])*1.1>.01)*.95))+',"!6'+name+' @'+strtrim(string(a*.0896,format='(f7.3)'),2)+'"" from nucleus",charsize=1.5,charthick=2.5,/DATA'

IF keyword_set(convol) THEN BEGIN
    tmpfinalspec=convol(finalspec,gauss1dgen(21.,1./sqrt(2.*!pi)/1.,10.,1.))
    tmpfinalspec=average(finalspec,1,RAVRANGE=convol,/EDGE)
    convol='_r'+strtrim(string(convol),2)+'pix'
ENDIF ELSE BEGIN
    tmpfinalspec=finalspec
ENDELSE
IF keyword_set(silent) EQ 0 THEN print,'Flux conservation: ',total(finalspec[minxr:maxxr]),total(tmpfinalspec[minxr:maxxr])

!P.THICK=3
print,'Plotting position: ',a
singleplot,dir+name+'_'+strtrim(string(a,format='(i)'),2)+spline+convol+'.ps',$
meanlambs[minxr:maxxr]*1e-4,tmpfinalspec[minxr:maxxr],$
meanlambs[minxr:maxxr]*1e-4,fltarr(nlambrange)+pbflux,$
meanlambs[minxr:maxxr]*1e-4,stdvfinalspec[minxr:maxxr],$
YERR00=[[[stdvfinalspec[minxr:maxxr]]],[[stdvfinalspec[minxr:maxxr]]]],TERRP=1,$
PSYM=[0.,0.,0.],$
LINESTYLE=[0.,0.,2.],$
NOFILL=[0.,0.,0.],$
COLOR=[0.,0.,0.],$
AXISF=1.5,$
THICK=[.8,.8,.8],$
SYMSIZE=[.8,.8,.8],$ ;Cuidado con MULTI
TICKF=.5,$
MINMAX=[lambrange[0],min(finalspec[minxr:maxxr])*.9<(-0.005),lambrange[1],max(finalspec[minxr:maxxr])*1.1>.01],$
XTITLE='!4l!X!Dobs!N (!4m!Xm)',$;/XLESSTICKS,$
YTITLE='f!4!Dn!X!N (Jy)',$
DAXIS=[1,1,0,0],/PSFONTS,/PACKS,EXTERNAL=[extern],/SILENT;,PREEXTERNAL=[extern,extern2,extern3,arrow,extern4]


IF keyword_set(silent) EQ 0 THEN BEGIN
    set_plot,'x'
    window,3,XSIZE=xsize,YSIZE=ysize
    plot,meanlambs[minxr:maxxr]*1e-4,tmpfinalspec[minxr:maxxr],XRANGE=lambrange,YRANGE=[min(finalspec[minxr:maxxr])*.9<(-0.005),max(finalspec[minxr:maxxr])*1.1>.01],TIT='Final calib spec at step '+strtrim(string(a),2),thick=1.5,charthick=1.5,xthick=1.5,ythick=1.5
;    oplot,[meanlambs[lamb0-3-minxr],meanlambs[lamb0-3-minxr]]*1e-4,[0.,1.]
;    oplot,[meanlambs[lamb0+3-minxr],meanlambs[lamb0+3-minxr]]*1e-4,[0.,1.]
    ;oplot,meanlambs*1e-4,intfilpb/max(intfilpb)*max(finalspec)
    oplot,meanlambs[minxr:maxxr]*1e-4,fltarr(nlambrange)+pbflux
ENDIF
;read,o

ENDELSE ;calc

IF keyword_set(silent) EQ 0 THEN print,'-----------------------------------------------------------------------'

ENDFOR ;a

IF keyword_set(calc) AND keyword_set(save) THEN free_lun,fluxes

END
