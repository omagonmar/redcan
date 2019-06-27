pro extract_spec_std,objname,stdname,REFPOSAPER=refposaper,REFWIDAPER=refwidaper,APERW=aperw,REFWAVE=refwave,FIXAPER=fixaper,PSOURCE=psource,SPATPROF=spatprof,NAME=name,SAVE=save,ASK=ask,FIXROW=fixrow,SILENT=silent,STEPS=steps,GALAXY=galaxy,APPROXZ=appz,SIDECORR=sidecorr,INPUTS=inputs,NOEXTEN=noexten,ROOTDIR=rootdir,DEBUG=debug


;extract_spec_ngc7130,'t_st_st_S20060704S0106_fs',APER=20.,NAME='HD_ap20pix_std1',/SAVE,STEPS=[0,0,1]
;extract_spec_ngc7130,'t_st_st_S20060704S0111_fs',REFAPER='t_st_st_S20060704S0106_fs',APER=4.,NAME='ngc7130_ap4pix_dset1',/SAVE,STEPS=[-40,40,1]
;extract_spec_ngc7130,'t_st_st_S20060704S0112_fs',REFAPER='t_st_st_S20060704S0106_fs',APER=4.,NAME='ngc7130_ap4pix_dset2',/SAVE,STEPS=[-40,40,1]
;extract_spec_ngc7130,'t_st_st_S20060704S0113_fs',REFAPER='t_st_st_S20060704S0106_fs',APER=4.,NAME='ngc7130_ap4pix_dset3',/SAVE,STEPS=[-40,40,1]


;REFPOSAPER: reference position file for the aperture
;REFWIDAPER: reference width file for the aperture
;APERW: aperture width
;REFWAVE: reference wavelength for the aperture positioning in [micron]
;FIXAPER: fixed aperture? 0 = no; 1 = grown as standard star; 2 = grown linearly with lambda
;NAME: name of the output
;SAVE: save output
;ASK: interactive mode. Asks where do you want to extract the spectrum
;FIXROW; ????????
;SILENT: obsolete -> change to DEBUG
;STEPS: 3 value array [a,b,c] where a = initial step; b = final
;step; c = step size; if only one extraction is required STEPS=[0,0,1]
;and INPUTS should be specified
;GALAXY: name of the galaxy
;INPUTS: 2 value array [a,b] where a = reference wavelength; b =
;reference row
;NOEXTEN: when science data is in extension = 0 then use /NOEXTEN
;ROOTDIR: directory where the data are; if not specified, local
;directory is used


IF n_params() NE 2 THEN message,'No object and/or standard name'
IF NOT keyword_set(aperw) THEN BEGIN
   message,'No aperture defined'
   STOP
END
IF NOT keyword_set(rootdir) THEN rootdir=file_search('.',/test_dir,/full,/mark)
dir=file_search(rootdir+'reduction/',/test_dir)
IF dir EQ '' THEN BEGIN
   file_mkdir,rootdir+'reduction/'
   dir=rootdir+'reduction/'
ENDIF

IF NOT keyword_set(name) THEN name=objname+'_1dext' ELSE name=name+'_1dext'

IF NOT keyword_set(inputs) THEN inputs=[0,0]

IF keyword_set(galaxy) THEN galaxy=galaxy ELSE stop

IF keyword_set(noexten) THEN exten=0 ELSE exten=1
IF NOT keyword_set(fixaper) THEN fixlab='_varap' ELSE IF fixaper EQ 1 THEN fixlab='_stdap' ELSE IF fixaper EQ 2 THEN fixlab='_fixap'
IF fixlab NE '' THEN realfix=fixaper ELSE realfix=0

;print,'PROBLEMS WITH FIXAPER = ',realfix

; OBJECT
head=headfits(rootdir+objname+'.fits')
ima=readfits(rootdir+objname+'.fits',headext1,/NOSCALE,EXTEN=exten)
;ima=ima*1000.
imasize=size(ima)

IF NOT keyword_set(noexten) THEN BEGIN
; WE HAVE TO LOAD THE WAVELENGTHS OF EACH OBJECT/STANDARD ITSELF
   crvalloc=where(strmid(headext1,0,6) eq "CRVAL1")
   inilamb=strmid(headext1[crvalloc[0]],9,60)+0.
;cdelt1loc=where(strmid(headext1,0,6) eq "CDELT1")  ; O si tienes CD1_1:
   cdelt1loc=where(strmid(headext1,0,5) eq "CD1_1")
   dellamb=strmid(headext1[cdelt1loc[0]],9,60)+0.
; DEFINE THE LAMBDA ARRAY
   lambs=findgen(imasize[1])*dellamb+inilamb
;lambs=tmplambs.field1[0,*]
   airmassloc=where(strmid(head,0,7) eq "AIRMASS")
   airmass=strmid(head[airmassloc[0]],9,60)+0.
   print,'AIRMASS: ',airmass
   print,'CRVAL1, CD1_1: ',[inilamb,dellamb]
ENDIF ELSE BEGIN
   inilamb=76300.
   dellamb=222.
   lambs=findgen(imasize[1])*dellamb+inilamb
ENDELSE

inilamb=where(lambs LE 78000.,nini)>0 & inilamb=inilamb[nini-1]
endlamb=where(lambs GT 132000.)<imasize[1]-1 & endlamb=endlamb[0]
; CARGAMOS LA TRANSMISION DE LA ATM. (WL POR DEFECTO EN NM!!!!!!)
atmtransname=rootdir+'midIR_trans_MK_AM1.1_WV1.0.dat'
tmpatmtrans=read_ascii(atmtransname)
atmtranssize=size(tmpatmtrans.field1)
atmtrans=tmpatmtrans.field1[*,*]
atmtrans[0,*]=atmtrans[0,*]*1e4 ; Pasamos a Ang
lambweight=interpol(reform(atmtrans[1,*]),reform(atmtrans[0,*]),lambs,/LSQUAD)
lambweight=lambweight/max(lambweight)
masklambweight=fltarr(imasize[1])
masklambweight[inilamb:endlamb]=1.
lambweight=lambweight*masklambweight

;IF strmid(name,0,2) NE 'HD' THEN BEGIN
IF objname NE stdname THEN BEGIN
   widthmask=0.25 ; [micron]
   sivlamb=where(lambs GT 105100.*(1.+appz)) & sivlamb=sivlamb[0]
   pahlamb1=where(lambs GT 112500.*(1.+appz)) & pahlamb1=pahlamb1[0]
   pahlamb2=where(lambs GT 86000.*(1.+appz)) & pahlamb2=pahlamb2[0]
   siabslamb=where(lambs GT 96000.*(1.+appz)) & siabslamb=siabslamb[0]
   lambweight[pahlamb2-(wdithmask/dellamb):pahlamb2+(wdithmask/dellamb)]=0.
   lambweight[sivlamb-(wdithmask/dellamb):sivlamb+(wdithmask/dellamb)]=0.
   lambweight[pahlamb1-(wdithmask/dellamb):pahlamb1+(wdithmask/dellamb)]=0.
;lambweight[siabslamb-10:siabslamb+10]=0. ;UTILIZAR??????????????
   lambweight[0:inilamb+5]=0. & lambweight[endlamb-6:imasize[1]-1]=0.
ENDIF

IF keyword_set(ask) THEN readpix=1
tvim,ima,0,SCL='log',MINA=1.,READPIX=readpix,POSITIONS=pos
IF keyword_set(pos) EQ 0 THEN ask=0

xsize=300 & ysize=300
IF NOT keyword_set(refwave) THEN refwave=refwave*10000. ELSE reflambda=122000.






; DETERMINAMOS LA FILA INICIAL GENERAL DE REFERENCIA
IF keyword_set(ask) THEN BEGIN ; Preguntamos la coordenada _y_ o...
    gauss1diniposfit=pos[1,0]
ENDIF ELSE BEGIN
    ; ...colapsamos la imagen en el eje _Y_ y vemos donde esta el maximo
    colcoll=fltarr(imasize[2])
    FOR i=inilamb,endlamb DO colcoll=colcoll+ima[i,*]
    gauss1diniposfit=whxy(colcoll,'max')
    gauss1diniposfit=gauss1diniposfit[0]
ENDELSE

; ESTABLECEMOS LOS RANGOS PARA LOS PESOS DE LOS AJUSTES
gauss1dwidthfit=50
gauss1dweight=fltarr(imasize[2])
gauss1dweight[gauss1diniposfit-gauss1dwidthfit>0:gauss1diniposfit+gauss1dwidthfit<imasize[2]-1]=1.
fitb1dweight=(gauss1dweight-1.)*(-1.);fltarr(imasize[2])+1.
;fitb1dweight[gauss1diniposfit-gauss1dwidthfit:gauss1diniposfit+gauss1dwidthfit]=0.

;; CALCULARMOS EL RANGO EN COLUMNAS QUE OCUPA EL ESPECTRO
;; Y SUSTRAEMOS LINEA A LINEA LA MEDIA DEL CIELO FUERA DE EL
;; ESTO LO UTILIZABAMOS ANTES SIGUIENDO ROCHE ET AL. PERO NO FUNCIONA
;rowcoll=fltarr(imasize[1])
;FOR i=0,imasize[2]-1 DO rowcoll=rowcoll+ima[*,i]
;maxcol=whxy(rowcoll,'max')
;maxcol=maxcol[0]
;skyinds=where(rowcoll LT rowcoll[maxcol]*.02 AND rowcoll GT -rowcoll[maxcol]*.1)
;FOR i=0,imasize[2]-1 DO ima[*,i]=ima[*,i]-mean(ima[skyinds,i])

; PASOS DE EXTRACCION
;count=0
resolve_routine,'backg1dpol',/compile,/either

; SI NO HAY APERTURA DE REFERENCIA... ------------------------------------
IF NOT keyword_set(refposaper) AND NOT keyword_set(refwidaper) THEN BEGIN

ngaussterms=5
terms=fltarr(imasize[1],ngaussterms)
imasub=fltarr(imasize[1],imasize[2])
IF keyword_set(silent) EQ 0 THEN window,2,XSIZE=xsize,YSIZE=ysize
FOR i=0,imasize[1]-1 DO BEGIN
    ; PARA CADA COLUMNA AJUSTAMOS EL FONDO...
    fitback1d=backg1dpol(reform(ima[i,*]),findgen(imasize[2]),backterm,NTERMS=2,SIGIT=2.0,CHISQ=back1dchi,YERR=back1dyerr,WEIGHT=fitb1dweight,ZTMP=zpos,/SILENT)
    ; ...Y LO RESTAMOS
    imasub[i,*]=ima[i,*]-fitback1d
    ; SOBRE LA IMAGEN RESTADA, AJUSTAMOS UNA GAUSSIANA A CADA COLUMNA
    IF max(imasub[i,*]) GT 0 THEN maxini=1. ELSE maxini=0.
    fitgauss=gauss1d(findgen(imasize[2]),imasub[i,*],term,CHISQ=gausschi,NTERM=ngaussterms,ESTIMATES=[max(imasub[i,*])*maxini,gauss1diniposfit,1.5,0.,0.],SIGMA=gausssig,YERR=gaussyerr,WEIGHT=gauss1dweight,SILENT=silent)
    IF i EQ imasize[1]-1 THEN print,'Gauss1d fit done'
    terms[i,*]=term
;    print,'Iter: ',i
;    print,'Terms: ',i,term
    IF keyword_set(silent) EQ 0 THEN BEGIN
        plot,findgen(imasize[2]),ima[i,*],THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,TITLE='Fitted (column) gauss.'
        oplot,findgen(imasize[2]),fitgauss,THICK=1.8
        oplot,findgen(imasize[2]),fitback1d,THICK=1.8
        oplot,findgen(imasize[2]),zpos,THICK=1.8
    ENDIF
;    read,o
ENDFOR

; UNA VEZ TENEMOS LOS TERMINOS DE LAS GAUSSIANAS DE LAS COLUMNAS
; AJUSTAMOS SUS POSICIONES...
nposterms=2 & nsigterms=2
valinds=where(terms[*,0] GT 10. AND terms[*,2] GT 1. AND terms[*,0] LE max(ima[*,*]) AND terms[*,2] LT 5.,nvalids)
fit1dpos=backg1dpol(terms[valinds[*],1],valinds[*],apos,NTERMS=nposterms,SIGIT=1.75,CHISQ=backchi1,YERR=backyerr1,WEIGHT=lambweight[valinds],ZTMP=zpos);terms[valinds[*],0],
; ...Y SUS ANCHURAS
fit1dsig=backg1dpol(terms[valinds[*],2],valinds[*],asig,NTERMS=nsigterms,SIGIT=1.75,CHISQ=backchi2,YERR=backyerr2,WEIGHT=lambweight[valinds],ZTMP=zsig);terms[valinds[*],0],

; RECOBRAMOS LAS FUNCIONES (POLINOMIOS)
fitpos=fltarr(imasize[1])
;FOR i=0,nterms-1 DO fitpos=fitpos+lambs^i*apos[i]
FOR i=0,nposterms-1 DO fitpos=fitpos+findgen(imasize[1])^i*apos[i]
fitsig=fltarr(imasize[1])
FOR i=0,nsigterms-1 DO fitsig=fitsig+findgen(imasize[1])^i*asig[i]

IF keyword_set(silent) EQ 0 THEN BEGIN
window,1,XSIZE=xsize,YSIZE=ysize
plot,lambs/10000.,terms[*,1],YRANGE=[min(fitpos)*.99,max(fitpos)*1.01],THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,XTITLE='um',YTITLE='Y pos.'
oplot,lambs/10000.,fitpos,THICK=1.8
oplot,lambs[valinds[*]]/10000.,zpos,THICK=1.5,PSYM=1

window,3,XSIZE=xsize,YSIZE=ysize
plot,lambs/10000.,terms[*,2]*2.35,YRANGE=[min(fitsig*2.35)*.98,max(fitsig*2.35)*1.02],THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,XTITLE='um',YTITLE='FWHM'
oplot,lambs/10000.,fitsig*2.35,THICK=1.8
;oplot,lambs[valinds[*]]/10000.,fit1dsig*2.35,THICK=1.8,PSYM=4
oplot,lambs[valinds[*]]/10000.,zsig*2.35,THICK=1.5,PSYM=1;4
ENDIF

; GRABAMOS LAS FUNCIONES DE POSICION, SIGMA Y LONG. ONDA
IF keyword_set(save) THEN BEGIN
openw,posfunct,dir+objname+'_posfunct.dat',/get_lun
printf,posfunct,fitpos,format='(320(A," ",:))'
free_lun,posfunct
openw,sigfunct,dir+objname+'_sigfunct.dat',/get_lun
printf,sigfunct,fitsig,format='(320(A," ",:))'
free_lun,sigfunct
openw,lambfunct,dir+objname+'_lambfunct.dat',/get_lun
printf,lambfunct,lambs,format='(320(A," ",:))'
free_lun,lambfunct
ENDIF


; DETERMINAMOS LA LONG. ONDA DE REFERENCIA Y EL INDICE (LA COLUMNA)
;lamb0=179 ; lambs[lamb0]=10.3686um lamb0[ngc7130]=119
lamb0=where(lambs GE reflambda-dellamb/2.)
lamb0=lamb0[0]
lamb00=lamb0
IF keyword_set(silent) EQ 0 THEN BEGIN
    print,'Reference lambda (#column,value): ',lamb0,lambs[lamb0]
    print,'Reference (std) row @',strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5),'um: ',fitpos[lamb0]
ENDIF

;tmpest=read_ascii(dir+'estrella.dat')
;est=tmpest.field001[*,*]

;window,10,XSIZE=xsize,YSIZE=ysize
;plot,lambs[*]/10000.,fitsig*2.35,YRANGE=[2,8]
;read,o
;oplot,lambs[*]/10000.,lambs[*]/10000.*1.22*206265./8e6/.0896
;read,o
;oplot,lambs[*]/10000.,est[*]
;read,o
;oplot,lambs[*]/10000.,sqrt((fitsig*2.35)^2.-(lambs[*]/10000.*1.22*206265./8e6/.0896)^2.-est[*]^2.)

;openw,lambfunct,dir+'estrella.dat',/get_lun
;printf,lambfunct,sqrt((fitsig*2.35)^2.-(lambs[*]/10000.*1.22*206265./8e6/.0896)^2.),format='(320(A," ",:))'
;free_lun,lambfunct

;stop

; COMPROBAMOS SI LA SIGMA SE INCREMENTA
IF (fitsig[n_elements(fitsig)-1]-fitsig[0])*2.354 LT .25 THEN BEGIN
    print,'Bad fitsig!!! MIGHT NOT BE DIFFRACTION LIMITTED!!! Fixing aperture'
    IF keyword_set(fixaper) EQ 0 THEN fixaper=1.
    fitsig[*]=1.
ENDIF
IF fitpos[n_elements(fitpos)-1]-fitpos[0] LT 0. THEN BEGIN
    print,'WARNING: Fitpos decreases'
    ;fitpos[*]=fitpos[lamb0]
ENDIF

IF keyword_set(silent) EQ 0 THEN BEGIN
print,'INI, lamb00, END lambda #columns: ',inilamb,lamb00,endlamb
print,'Lambda INI, lamb00, END, DELTA: ',lambs[inilamb],lambs[lamb00],lambs[endlamb],lambs[1]-lambs[0]
print,'Width INI, lamb00, END: ',fitsig[inilamb]*2.354,fitsig[lamb00]*2.354,fitsig[endlamb]*2.354
ENDIF

ENDIF ELSE BEGIN                ; refposaper=0 & refwidthaper=0

; EN EL CASO DE TOMAR COMO REFERENCIA OTRO ESPECTRO EXTRAIDO
; CARGAMOS LAS FUNCIONES DE AJUSTE ---------------------------------------

;IF count EQ 0 THEN BEGIN
IF keyword_set(refposaper) THEN BEGIN
    print,'Loading position function: ',refposaper+'_posfunct.dat'
    tmpfitpos=read_ascii(dir+refposaper+'_posfunct.dat')
    fitpos=tmpfitpos.field001[*]
    tmpfitlambs=read_ascii(dir+refposaper+'_lambfunct.dat')
    fitlambs=tmpfitlambs.field001[*]
ENDIF ELSE BEGIN
    print,'Taking reference POSITION and LAMBDA from WIDTH reference'
    print,'Loading position function: ',refwidaper+'_posfunct.dat'
    tmpfitsig=read_ascii(dir+refwidaper+'_posfunct.dat')
    fitsig=tmpfitsig.field001[*]
    tmpfitlambs=read_ascii(dir+refwidaper+'_lambfunct.dat')
    fitlambs=tmpfitlambs.field001[*]
ENDELSE
IF keyword_set(refwidaper) THEN BEGIN
    print,'Loading width function: ',refwidaper+'_sigfunct.dat'
    tmpfitsig=read_ascii(dir+refwidaper+'_sigfunct.dat')
    fitsig=tmpfitsig.field001[*]
ENDIF ELSE BEGIN
    print,'Taking reference WIDTH from POSITION reference'
    print,'Loading width function: ',refposaper+'_sigfunct.dat'
    tmpfitsig=read_ascii(dir+refposaper+'_sigfunct.dat')
    fitsig=tmpfitsig.field001[*]
ENDELSE

; LAS COMPROBAMOS
IF (fitsig[n_elements(fitsig)-1]-fitsig[0])*2.354 LT .25 THEN BEGIN
    print,'Bad fitsig!!! MIGHT NOT BE DIFFRACTION LIMITTED!!! Fixing aperture'
    IF keyword_set(fixaper) EQ 0 THEN fixaper=1.
    fitsig[*]=1.
ENDIF
IF fitpos[n_elements(fitpos)-1]-fitpos[0] LT 0. THEN BEGIN
    print,'WARNING: Fitpos decreases'
ENDIF

; PARA CADA COLUMNA AJUSTAMOS EL FONDO
imasub=fltarr(imasize[1],imasize[2])
FOR i=0,imasize[1]-1 DO BEGIN
    fitback1d=backg1dpol(reform(ima[i,*]),findgen(imasize[2]),backterm,NTERMS=2,SIGIT=2.0,CHISQ=back1dchi,YERR=back1dyerr,WEIGHT=fitb1dweight,ZTMP=zpos,/SILENT)
    ; Y LO RESTAMOS
    imasub[i,*]=ima[i,*]-fitback1d
ENDFOR

; COMPROBAMOS QUE LA CALIBRACION EN LONG. ONDA DEL OBJETO Y SU
; REFERENCIA SON IGUALES
IF keyword_set(silent) EQ 0 THEN print,'Ini. lambs (std,obj): ',fitlambs[0],lambs[0]
IF fitlambs[0] GT lambs[0]*1.005 OR fitlambs[0] LT lambs[0]*0.995 OR fitlambs[imasize[1]-1] GT lambs[imasize[1]-1]*1.005 OR fitlambs[imasize[1]-1] LT lambs[imasize[1]-1]*0.995 THEN BEGIN
    message,'No coinciden las lambs. iniciales'
    STOP
ENDIF ELSE BEGIN
    print,'INI and END lambda #columns: ',inilamb,endlamb
    print,'Fitted/loaded lambda INI: ',fitlambs[inilamb],lambs[inilamb]
    print,'Fitted/loaded lambda END: ',fitlambs[endlamb],lambs[endlamb]
    print,'Fitted/loaded DELTA lamb: ',fitlambs[1]-fitlambs[0],lambs[1]-lambs[0]
    print,'Loaded width INI, END: ',[fitsig[inilamb],fitsig[endlamb]]*2.354
ENDELSE

; ------------------------------------------------------------------------

; AHORA SE DETERMINA LA COL. DE REF. RESPECTO A LA CUAL EXTRAEREMOS
; TODOS LOS PASOS. SE PUEDE ESCOGER LA ZONA DE REFERENCIA PARA LA
; EXTRACCION CLICKANDO O PREGUNTANDO LA COL. DE REFERENCIA E
; INTRODUCIENDO UN OFFSET.

; SI SE PREGUNTA, (LA PRIMERA VEZ) ASIGNAMOS EL COLUMNA 'CLICKADA'
; COMO LONG. ONDA DE REFERENCIA
;lamb0=179 ; lambs[lamb0]=10.3686um
IF keyword_set(ask) THEN BEGIN ; Preguntamos la coord. _x_
    lamb0=pos[0,0] ; MANUAL/INTERACTIVE REFERENCE LAMBDA
ENDIF ELSE BEGIN
; SI NO, (LA PRIMERA VEZ) SE PREGUNTA
    ;read,'Reference #column wavelength: ',lamb0
    lamb0=inputs[0] ; EN REALIDAD YA LO SABEMOS Y SE LO PASAMOS DESDE INPUTS
; SI ESCRIBIMOS 0, SE TOMA COMO REFERENCIA EL PIXEL A 12.2UM
    IF lamb0[0] EQ 0 THEN lamb0=where(lambs GE reflambda-dellamb/2.)
; SI QUEREMOS EXTRAER A UNA DISTANCIA (OFFSET) CON RESPECTO AL NUCLEO
; ESTA SERA LA FILA DE REFERENCIA
    ;read,'Reference offset from nucleus: ',offsetfromnuc
    offsetfromnuc=inputs[1]
    gauss1diniposfit=gauss1diniposfit+offsetfromnuc
ENDELSE
lamb0=lamb0[0] ; lamb0=referencia manual (que es auto. si lamb0=0)
lamb00=where(lambs GE reflambda-dellamb/2.)
lamb00=lamb00[0] ; lamb00=referencia automatica
IF lamb00 NE lamb0 THEN BEGIN
    lamb00=lamb0
    message,'AUTOMATIC REF. LAMBDA IS NOT EQUAL TO MANUAL REF. LAMBDA ---------------------------------------------'
ENDIF

print,'Reference lambda (#column,value): ',fix(lamb0),lambs[lamb0]/10000.
print,'Reference manu. (std nuc) #row @',strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5),'um: ',fitpos[lamb0]
print,'Reference auto. (std nuc) #row @',strmid(strcompress(string(lambs[lamb00]/10000.),/REM),0,5),'um: ',fitpos[lamb00]

; COLAPSAMOS 11 COLUMNAS CON RESPECTO A LA COL. DE REF.
;collapima=fltarr(imasize[2])
;FOR i=0,imasize[1]-1 DO collapima=collapima+imasub[i,*]
subcollapima=fltarr(imasize[2])
FOR i=lamb0-5,lamb0+5 DO subcollapima=subcollapima+imasub[i,*]
;IF keyword_set(silent) EQ 0 THEN print,'lamb0:................. ',lamb0

gauss1diniposfitnuc=whxy(subcollapima,'max')
gauss1diniposfitnuc=gauss1diniposfitnuc[0]
; Y CALCULAMOS LA FILA DE REFERNCIA EN LA QUE SE ENCUENTRA EL NUCLEO
; EN LA COL. DE REF.
fitgaussnuc=gauss1d(findgen(imasize[2]),subcollapima[*],termnuc,CHISQ=gausschi,NTERM=4,ESTIMATES=[max(subcollapima[*]),gauss1diniposfitnuc,1.5,0.],SIGMA=gausssig,YERR=gaussyerr,WEIGHT=gauss1dweight,SILENT=silent)

; SI NO HEMOS ESCOGIDO FIJAR LA FILA DE REFERENCIA (TANTO SI HEMOS
; PREGUNTADO COMO SI HEMOS INTRODUCIDO UN OFFSET O 0), AJUSTAMOS A UNA
; GAUSSIANA EN LA COLUMNA DE REFERENCIA, Y CALCULAMOS LA POSICION EXACTA
; DE LA FILA DE REFERENCIA
IF keyword_set(fixrow) EQ 0 THEN BEGIN
    fitgauss=gauss1d(findgen(imasize[2]),subcollapima[*],term,CHISQ=gausschi,NTERM=4,ESTIMATES=[max(subcollapima[*]),gauss1diniposfit,1.5,0.],SIGMA=gausssig,YERR=gaussyerr,WEIGHT=gauss1dweight,SILENT=silent)
    IF objname EQ refposaper AND lamb0 EQ lamb00 AND abs(term[1]-fitpos[lamb0]) LE .5 THEN BEGIN
        print,'Fixing reference position to fitted reference position function'
        print,'Distance reference-fit: ',term[1]-fitpos[lamb0]
        term[1]=fitos[lamb0]
    ENDIF
    refrow=term[1]
ENDIF ELSE BEGIN
; SI HEMOS ESCOGIDO FIJAR LA FILA DE REFERENCIA
    IF keyword_set(ask) THEN BEGIN
; SI HEMOS PREGUNTADO, LA FILA DE REFERENCIA SERA EN LA QUE HEMOS
; 'CLICKADO'
        ;fitgauss=fltarr(imasize[2])
        refrow=gauss1diniposfit;=pos[1,0]
    ENDIF ELSE BEGIN
; SI NO, CALCULAMOS LA FILA DE REFERENCIA CON EL OFFSET RESPECTO AL
; NUCLEO
        ;fitgauss=fitgaussnuc
        IF objname EQ refposaper AND lamb0 EQ lamb00 AND abs(termnuc[1]-fitpos[lamb0]) LE .5 THEN BEGIN
        print,'Fixing reference position to fitted reference position function'
        print,'Distance reference-fit: ',termnuc[1]-fitpos[lamb0]
        termnuc[1]=fitpos[lamb0]
        ENDIF
        refrow=termnuc[1]+offsetfromnuc
    ENDELSE
ENDELSE

; ES DECIR SI QUEREMOS ESCOGER UNA FILA DE REFERENCIA DETERMINADA
; (NO MEDIANTE UN OFFSET CON RESPECTO AL NUCLEO) TIENE QUE SER A
; TRAVES DEL -ASK- -> PARA ESO HE IMPLEMENTADO EL VER LAS COORDENADAS

IF keyword_set(silent) EQ 0 THEN BEGIN
    print,'Reference (obj nuc stacked) #row @',strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5),'um: ',termnuc[1]
    print,'Manual offset from reference (obj nuc stacked): ',refrow-termnuc[1]
ENDIF

;ENDIF                           ; count=0

ENDELSE ; ----------------------------------------------------------------

FOR a=steps[0],steps[1],steps[2] DO BEGIN

; LA FUNCION DE POSICION ES LA DE LA APERTURA REFERENCIA MENOS LA
; POSICION EN LA FILA DE REFERENCIA, MAS LA FILA DEL ESPECTRO EN LA
; FILA _ACTUAL_ DE REFERENCIA, MAS EL OFFSET EXTRA A LOS LADOS

finalpos=fitpos
IF keyword_set(refposaper) OR keyword_set(refwidaper) THEN finalpos=finalpos-fitpos[lamb0]+refrow+a

IF keyword_set(silent) EQ 0 and a EQ steps[0] THEN BEGIN
window,3,XSIZE=xsize,YSIZE=ysize
plot,findgen(imasize[2]),subcollapima,THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,TITLE='Spatial dist. collapsed at '+strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5)+'um',XTITLE='Row at col. '+strcompress(string(lamb0),/REM),XRANGE=[refrow-8,refrow+8]
;IF keyword_set(ask) EQ 0 OR (keyword_set(ask) AND keyword_set(fixrow) EQ 0) THEN oplot,findgen(imasize[2]),fitgauss,THICK=1.8

oplot,findgen(imasize[2]),fitgaussnuc,THICK=1.8,LINESTYLE=2.
oplot,[refrow-aperw/2.,refrow-aperw/2.],[0.,max(subcollapima)],THICK=1.8
oplot,[refrow+aperw/2.,refrow+aperw/2.],[0.,max(subcollapima)],THICK=1.8
ENDIF

IF keyword_set(silent) EQ 0 THEN BEGIN
    print,'Reference (obj) #row @',strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5),'um: ',refrow
    IF lamb00 NE lamb0 THEN print,'Reference (obj) #row @',strmid(strcompress(string(lambs[lamb00]/10000.),/REM),0,5),'um: ',finalpos[lamb00]-a
    print,'Current (obj) #row @',strmid(strcompress(string(lambs[lamb0]/10000.),/REM),0,5),'um : ',finalpos[lamb0]
    IF lamb00 NE lamb0 THEN print,'Current (obj) #row @',strmid(strcompress(string(lambs[lamb00]/10000.),/REM),0,5),'um : ',finalpos[lamb00]
    print,'Offset from reference #row: ',a
ENDIF

;read,'Aperture width: ',aperw
; EN CADA COLUMNA SUMAMOS EL FLUJO CONTENIDO EN LA APERTURA (VARIABLE)
IF keyword_set(fixaper) AND a EQ steps[0] THEN print,'Fixed aperture ---------------------'

IF NOT keyword_set(fixaper) THEN BEGIN
    IF a EQ steps[0] THEN print,'Growing aperture from REFERENCE function'
    normalfitsig=fitsig/fitsig[lamb00]
;refaperw=aperw+(2.*sqrt(2.*alog(2)))^2.*fitsig[lamb00]*(normalfitsig-1)
;refaperw=sqrt(aperw^2.+(2.*sqrt(2.*alog(2)))^2.*fitsig[lamb00]^2.*(normalfitsig^2.-1))   ;SUMACUADRATICA
    refaperw=aperw*normalfitsig
    nullref=where(refaperw LT 1.,nnullref)
    IF nullref[0] NE -1 THEN BEGIN
        print,'Aperture width lower than 1 pixel! Fixing...........'
        refaperw=refaperw>1.
    ENDIF
ENDIF ELSE BEGIN
    IF fixaper EQ 1 THEN BEGIN
        IF a EQ steps[0] THEN print,'FORCING to grow INTRINSIC PSF aperture'
        fitsig=lambs*1.e-4/8e6*206265./0.0896 ; [pix]
        normalfitsig=fitsig/fitsig[lamb00]
; si la apertura es mas grande que la fwhm de la estrella en lamb00
; se hace crecer la apertura com suma cuadratica
        IF aperw GE fitsig[lamb00] THEN BEGIN
            refaperw=sqrt(aperw^2.+fitsig[lamb00]^2.*(normalfitsig^2.-1))
; si la apertura es mas pequenha que la fwhm de la estrella en lamb00
; se hace crecer la apertura como un multiplo del crecimiento intrinseco
; de la PSF
        ENDIF ELSE BEGIN
            IF a EQ steps[0] THEN print,'Warning: Aperture width lower than PSF FWHM -> Growing aperture from REFERENCE function!!!!!!!!!!!!!!!!'
            refaperw=normalfitsig*aperw
        ENDELSE
    ENDIF ELSE BEGIN
        IF a EQ steps[0] THEN print,'FIXING APERTURE -- No variability'
        refaperw=fltarr(imasize[1])+aperw
    ENDELSE
ENDELSE

IF a EQ steps[0] THEN print,'Aperture = ',strmid(strcompress(string(aperw),/REM),0,4),'pix @',strmid(strcompress(string(lambs[lamb00]/10000.),/REM),0,5),'um (from ',strmid(strcompress(string(refaperw[inilamb]),/REM),0,5),'pix @',strmid(strcompress(string(lambs[inilamb]/10000.),/REM),0,5),' to ',strmid(strcompress(string(refaperw[endlamb]),/REM),0,5),'pix @',strmid(strcompress(string(lambs[endlamb]/10000.),/REM),0,5),')'

flux=fltarr(imasize[1])
FOR i=0,imasize[1]-1 DO BEGIN

    pospos=finalpos[i]+refaperw[i]/2.
    negpos=finalpos[i]-refaperw[i]/2.
;    print,'Pos: ',i,lambs[i],finalpos[i],refaperw
    fixpospos=fix(pospos)
    posposnow=fixpospos
    fixnegpos=fix(negpos)
    posnegnow=fixnegpos

    negdecval=negpos-fixnegpos
    IF negdecval LT 0.5 THEN BEGIN ; 124.22-124
        flux[i]=flux[i]+imasub[i,posnegnow]*(0.5-negdecval)
        posnegnow=posnegnow+1 ; 125
    ENDIF ELSE BEGIN ; 124.72-124
        posnegnow=posnegnow+1 ; 125
        flux[i]=flux[i]+imasub[i,posnegnow]*(1.-negdecval+0.5)
        posnegnow=posnegnow+1 ;126
    ENDELSE

    posdecval=pospos-fixpospos
    IF posdecval LT 0.5 THEN BEGIN ; 128.22-128
        flux[i]=flux[i]+imasub[i,posposnow]*(0.5+posdecval)
        posposnow=posposnow-1 ; 127
    ENDIF ELSE BEGIN ; 128.72-128
        posposnow=posposnow+1   ; 129
        flux[i]=flux[i]+imasub[i,posposnow]*(posdecval-0.5)
        posposnow=posposnow-1 ; 128
    ENDELSE

    FOR j=posnegnow,posposnow DO BEGIN
        flux[i]=flux[i]+imasub[i,j]
    ENDFOR
;print,refaperw*aperw
ENDFOR

fluxpline=spline(lambs,flux,lambs+dellamb/2.,10.)
invfluxpline=spline(lambs+dellamb/2.,fluxpline,lambs,1.)

IF keyword_set(save) THEN BEGIN
    IF a EQ steps[0] THEN print,'Writing: ',dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'.fits'
    file_delete,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'.fits',/ALLOW
    file_delete,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'_spl.fits',/ALLOW
IF keyword_set(noexten) THEN BEGIN
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'.fits',[[lambs],[flux]],head
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'_spl.fits',[[lambs],[invfluxpline]],head
ENDIF ELSE BEGIN
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'.fits',0.,head
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'.fits',[[lambs],[flux]],headext1,/APPEND
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'_spl.fits',0.,head
    writefits,dir+name+fixlab+'_'+strtrim(string(a,format='(i)'),2)+'_spl.fits',[[lambs],[invfluxpline]],headext1,/APPEND
ENDELSE

;print,'Flux conservation when splining: ',total(flux[inilamb:endlamb]),total(fluxpline[inilamb:endlamb]),total(invfluxpline[inilamb:endlamb])
ENDIF

;kerr=gauss1dgen(11,1./(2.*!pi),5.,2.)
;flux=convol(flux,kerr)
IF keyword_set(silent) EQ 0 THEN BEGIN
window,2,XSIZE=xsize,YSIZE=ysize
plot,lambs[inilamb:endlamb]/10000.,flux[inilamb:endlamb],THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,TITLE='Extracted spec. with ap='+strmid(strcompress(string(aperw),/rem),0,3),XTITLE='um',YTITLE='Flux (ADUs-1)'
;print,'Aperture flux: ',total(flux),' ADUs-1'
print,'Spectrum flux: ',total(flux[inilamb:endlamb]),' ADUs-1'
;print,lambs[lamb0],' flux: ',total(flux[lamb0-3:lamb0+3]),' ADUs-1'

window,4,XSIZE=xsize,YSIZE=ysize
plot,lambs[inilamb:endlamb]/10000.,invfluxpline[inilamb:endlamb],THICK=1.5,XTHICK=1.5,YTHICK=1.5,CHARTHICK=1.5,CHARSIZE=1.0,TITLE='Splined extracted spec. with ap='+strmid(strcompress(string(aperw),/rem),0,3),XTITLE='um',YTITLE='Flux (ADUs-1)'
;oplot,[lambs[lamb0-3],lambs[lamb0-3]]/10000.,[0,max(invfluxpline[inilamb:endlamb])],THICK=1.8
;oplot,[lambs[lamb0+3],lambs[lamb0+3]]/10000.,[0,max(invfluxpline[inilamb:endlamb])],THICK=1.8
;print,'Aperture flux: ',total(flux),' ADUs-1'
print,'Splined spectrum flux: ',total(invfluxpline[inilamb:endlamb]),' ADUs-1'
;print,lamb0,' flux: ',total(invfluxpline[lamb0-3:lamb0+3]),' ADUs-1'

mag=3
mmm,ima,mode,stdev,skew
tvim,maximim(ima,mag),5,SCL='log',MINA=1.,MAXA=mode+stdev*20.
;ARROW,0,finalpos[0]+refaperw[0]/2.,imasize[1]-1,finalpos[imasize[1]-1]+refaperw[imasize[1]-1]/2.,COLOR=254,THICK=.5,HSIZE=1./1e6
;ARROW,0,finalpos[0]-refaperw[0]/2.,imasize[1]-1,finalpos[imasize[1]-1]-refaperw[imasize[1]-1]/2.,COLOR=254,THICK=.5,HSIZE=1./1e6
ARROW,0+mag/2,(finalpos[0]+refaperw[0]/2.)*mag+mag/2,(imasize[1]-1)*mag+mag/2,(finalpos[imasize[1]-1]+refaperw[imasize[1]-1]/2.)*mag+mag/2,COLOR=254,THICK=.5,HSIZE=1./1e6
ARROW,0+mag/2,(finalpos[0]-refaperw[0]/2.)*mag+mag/2,(imasize[1]-1)*mag+mag/2,(finalpos[imasize[1]-1]-refaperw[imasize[1]-1]/2.)*mag+mag/2,COLOR=254,THICK=.5,HSIZE=1./1e6
;ARROW,201*mag+mag/2,(finalpos[lamb0]-refaperw[lamb0]/2.)*mag+mag/2,201*mag+mag/2,(finalpos[lamb0]+refaperw[lamb0]/2.)*mag+mag/2,COLOR=254,THICK=.5,HSIZE=1./1e6
;ARROW,(lamb0-3)*mag+mag/2,(finalpos[lamb0])*mag+mag/2,(lamb0+3)*mag+mag/2,(finalpos[lamb0])*mag+mag/2,COLOR=254,THICK=.5,HSIZE=1./1e6
ENDIF

IF keyword_set(silent) EQ 0 THEN print,'--------------------------------------------------------------------------------'

;window,10,XSIZE=xsize*1.5,YSIZE=ysize*1.5
;plot,lambs[inilamb:endlamb],flux[inilamb:endlamb],YRANGE=[0,1.6e4]
;fluxpline=spline(lambs,flux,lambs+dellamb/2.,10.)
;window,11,XSIZE=xsize*1.5,YSIZE=ysize*1.5
;plot,lambs[inilamb:endlamb],fluxpline,YRANGE=[0,1.6e4]
;invfluxpline=spline(lambs+dellamb/2.,fluxpline,lambs,1.)
;window,12,XSIZE=xsize*1.5,YSIZE=ysize*1.5
;plot,lambs[inilamb:endlamb],invfluxpline,YRANGE=[0,1.6e4]
;print,'Fluxes: ',total(flux[inilamb:endlamb]),total(fluxpline),total(invfluxpline)


;count=count+1
ENDFOR

fixaper=realfix

IF keyword_set(debug) THEN stop
print,'FINISHING extract_spec -------------------------------------'


END
