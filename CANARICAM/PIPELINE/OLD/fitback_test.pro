pro fitback_test,image,DIR=dir,CENT=cent,SAVE=save,TYPE=type,SILENT=silent,SIGMA=sigma,NOEXTEN=noexten,CALIB=calib,NAME=name,ROTATE=rotate,GAUSS=gauss

;FOR i=0,3 DO BEGIN

;names=['asta_S20050918S0031','asta_S20050918S0033','asta_S20050918S0034','asta_S20050918S0035']
;image=names[i]
;dir='/home/tanio/data/trecs_2006B/GS-2006B-Q-9_ic4687/'
;dir='/home/tanio/data/trecs_2006B/GS-2006B-Q-9_ngc1614/'
IF keyword_set(dir) EQ 0 THEN dir=''
IF keyword_set(type) EQ 0 THEN BEGIN
    type='' & read,'What kind of data is this? (imag/spec): ',type
ENDIF
IF type EQ 'imag' THEN BEGIN
    IF keyword_set(sigma) EQ 0 THEN sigit=3. ELSE sigit=sigma
    doublesig=1.
ENDIF ELSE IF type EQ 'spec' THEN BEGIN
    IF keyword_set(sigma) EQ 0 THEN sigit=2. ELSE sigit=sigma
    doublesig=0.
ENDIF ELSE BEGIN
    message,'Bad input'
    STOP
ENDELSE
IF keyword_set(noexten) THEN exten=0 ELSE exten=1

imagesize=size(image)
IF imagesize[0] EQ 0 THEN BEGIN
    head=headfits(dir+image+'.fits')
    ima=readfits(dir+image+'.fits',headext1,/NOSCALE,EXTEN=exten)
ENDIF ELSE BEGIN
    print,'There is NO header if you pass the variable'
    ima=image
ENDELSE
;IF n_params() GT 1 THEN BEGIN
;head2=headfits(dir+image2+'.fits')
;ima2=readfits(dir+image2+'.fits',headext2,/NOSCALE,EXTEN=exten)
;ENDIF

; HEADER: BUSCAMOS LOS TSSONS
frmtimeloc=where(strmid(head,0,7) eq "FRMTIME")
frmtime=strmid(head[frmtimeloc[0]],9,60)+0.
frmcoaddloc=where(strmid(head,0,8) eq "FRMCOADD")
frmcoadd=strmid(head[frmcoaddloc[0]],9,60)+0.
chpcoaddloc=where(strmid(head,0,8) eq "CHPCOADD")
chpcoadd=strmid(head[chpcoaddloc[0]],9,60)+0.
tssons=frmtime*.001*frmcoadd*chpcoadd

IF keyword_set(silent) EQ 0 THEN print,'TSSONS: ',tssons

imasize=size(ima)
imasize2=size(ima2)
xarr=dindgen(imasize[1]) & yarr=dindgen(imasize[2])
xarr2d=xarr#replicate(1.,imasize[2]) & yarr2d=replicate(1.,imasize[1])#yarr

gkerrfwhm=1.5
gkerr=gauss2drgen(11.,1./(2.*!pi*gkerrfwhm^2),5.,5.,gkerrfwhm)
gkerr=gkerr/total(gkerr)
print,'Flux cons. = ',total(gkerr)
gaussima=convol(ima,gkerr)

IF keyword_set(silent) EQ 0 THEN BEGIN
tvim,ima,0,SCL='log',MINA=.001,MAXF=1000.
tvim,gaussima,1,SCL='log',MINA=.001,MAXF=1000.
ENDIF

IF keyword_set(cent) THEN cent=cent ELSE cent=[159,119]
; Ajustamos el background primero para seleccionar solo los pixeles de
; background
;mask=where(reform(sqrt((xarr2d-cent[0])^2+(yarr2d-cent[1])^2)) LE 60.,nmask)
;mask=[mask,where(reform(sqrt((xarr2d-176)^2+(yarr2d-36)^2)) LE 30.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-110)^2+(yarr2d-125)^2)) LE 40.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-240)^2+(yarr2d-130)^2)) LE 40.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-170)^2+(yarr2d-205)^2)) LE 20.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-113)^2+(yarr2d-34)^2)) LE 20.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-195)^2+(yarr2d-190)^2)) LE 25.,nmask)]
;mask=[mask,where(reform(sqrt((xarr2d-145)^2+(yarr2d-190)^2)) LE 20.,nmask)]

IF keyword_set(doublesig) EQ 0 THEN mask=0
fitbkg2d=backg2d(ima,param1,TOL=.001,ZTMP=ztmp,ZSUB=zsub,VALIND=valind,SIGIT=sigit,DOUBLESIG=doublesig,DSPIXS=mask,/SLOP,SILENT=silent)
print,'Param1: ',param1

;ztmp=maskim(ima,0,50,CENT=[160,120],/invert)
;ztmp=ima
IF keyword_set(silent) EQ 0 THEN tvim,ztmp,2,SCL='log',MINF=.1,MAXF=10.

IF type EQ 'imag' THEN BEGIN

; Ajustamos las lineas mediante un spline de 1D
arraytofit=ztmp;ima
sclpar=32
averagepar=79
avima=dblarr(imasize[1]/sclpar,imasize[2])
fit1d=dblarr(imasize[1],imasize[2])
FOR i=0,imasize[2]-1 DO BEGIN
    avima[*,i]=average(arraytofit[*,i],sclpar,XARR=xarr,/EDGE,AVRANG=averagepar)
    ;posval=where(valind[*,i] GT 0)
    ;xarr=float(valind[posval,i] mod imasize[1])
    ;tmpavima=arraytofit[valind[posval,i]]
    fit1d[*,i]=spline(xarr,avima[*,i],dindgen(imasize[1]),1.)
    ;fit1d[*,i]=interpol(tmpavima,xarr,dindgen(imasize[1]),/QU)
ENDFOR
print,'Totals ima,imafit1d: ',total(ztmp),total(fit1d),total(fit1d)/total(ztmp)
gaussfit1d=convol(fit1d,gkerr)

imafit=ima-fit1d
fit=fit1d
gaussfit=gaussfit1d
lab='i'

ENDIF ELSE BEGIN

imafit=ima-fitbkg2d
fit=fitbkg2d
gaussfit=convol(fitbkg2d,gkerr)
lab='s'

ENDELSE

gaussimafit=convol(imafit,gkerr)
IF keyword_set(silent) EQ 0 THEN BEGIN
tvim,fit,3,SCL='log',MINF=.1,MAXF=5.
tvim,imafit,4,SCL='log',MINA=.001,MAXF=1000.
tvim,gaussimafit,5,SCL='log',MINA=.001,MAXF=1000.
ENDIF

;fitbkg2d=backg2d(ima,param1,TOL=.001,ZTMP=ztmp,ZSUB=zsub,VALIND=valind,SIGIT=1.75,/SLOP)
;print,'Param1: ',param1
;imafit2d=ima-fitbkg2d
;gaussimafit2d=convol(imafit2d,gkerr)
;IF keyword_set(silent) EQ 0 THEN BEGIN
;tvim,fitbkg2d,6,SCL='log',MINA=.001
;tvim,imafit2d,7,SCL='log',MINA=.001
;tvim,gaussimafit2d,8,SCL='log',MINA=.001
;ENDIF

;fitbkg1d2d=backg2d(imafit1d,param2,TOL=.001,ZTMP=ztmp,ZSUB=zsub,VALIND=valind,SIGIT=1.75,/SLOP)
;print,'Param2: ',param2
;imafit1d2d=imafit1d-fitbkg1d2d
;gaussimafit1d2d=convol(imafit1d2d,gkerr)
;IF keyword_set(silent) EQ 0 THEN BEGIN
;tvim,fitbkg1d2d,9,SCL='log',MINA=.001
;tvim,imafit1d2d,10,SCL='log',MINA=.001
;tvim,gaussimafit1d2d,11,SCL='log',MINA=.001
;;tvim,gaussztmp,3,SCL='log',MINA=min(gaussztmp)
;;tvim,zsub,3,SCL='log',MINA=.0001
;ENDIF

aperts=[5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70.,80.]
naperts=n_elements(aperts)
apesky=[80,90]
aper,ima,cent[0],cent[1],mag,magerr,sky,skyerr,1.,aperts,apesky,[1.,-1.],/EXACT,/FLUX,/SILENT
aper,imafit,cent[0],cent[1],mag2,magerr2,sky2,skyerr2,1.,aperts,apesky,[1.,-1.],/EXACT,/FLUX,/SILENT
;aper,imafit2d,cent[0],cent[1],mag3,magerr3,sky3,skyerr3,1.,aperts,apesky,[1.,-1.],/EXACT,/FLUX,/SILENT
;aper,imafit1d2d,cent[0],cent[1],mag4,magerr4,sky4,skyerr4,1.,aperts,apesky,[1.,-1.],/EXACT,/FLUX,/SILENT

IF keyword_set(silent) EQ 0 THEN BEGIN
print,aperts
print,'Ima: flux,backg,flux-backg: '
mmm,ima
print,mag,sky,-(aperts^2*!pi*replicate(sky,naperts)-mag)
print,'Imafit1d: flux,backg,flux-backg: '
mmm,imafit
print,mag2,sky2,-(aperts^2*!pi*replicate(sky2,naperts)-mag2)
;print,'Imafit2d: flux,backg,flux-backg: '
;mmm,imafit2d
;print,mag3,sky3,-(aperts^2*!pi*replicate(sky3,naperts)-mag3)
;print,'Imafit1d2d: flux,backg,flux-backg: '
;mmm,imafit1d2d
;print,mag4,sky4,-(aperts^2*!pi*replicate(sky4,naperts)-mag4)
ENDIF


;read,o
;fitsubsubima=fitsubima-fit1d
;gausssubsubima=convol(fitsubsubima,gkerr)

; BACKper
IF keyword_set(save) THEN BEGIN
    print,'Writting: ',dir+image+'_'+lab+'bs.fits'
    print,'Writting: ',dir+image+'_'+lab+'bs_ADUs-1.fits'
    file_delete,dir+image+'_'+lab+'bs.fits',/ALLOW
    file_delete,dir+image+'_'+lab+'bs_ADUs-1.fits',/ALLOW
    IF keyword_set(calib) THEN BEGIN
        IF keyword_set(name) THEN image=name
        print,'Writting: ',dir+image+'_Jy.fits'
        file_delete,dir+image+'_Jy.fits',/ALLOW
        ;IF keyword_set(rotate) THEN BEGIN
            print,'Writting: ',dir+image+'_Jy_rot.fits'
            file_delete,dir+image+'_Jy_rot.fits',/ALLOW
            IF keyword_set(gauss) THEN BEGIN
                print,'Writting: ',dir+image+'_Jy_rot_gauss1pix.fits'
                file_delete,dir+image+'_Jy_rot_gauss1pix.fits',/ALLOW
            ENDIF
        ;ENDIF
        noexten=1
    ENDIF
IF keyword_set(noexten) THEN BEGIN
    writefits,dir+image+'_'+lab+'bs.fits',imafit,head
    imafit=imafit/tssons
    writefits,dir+image+'_'+lab+'bs_ADUs-1.fits',imafit,head
    IF keyword_set(calib) THEN BEGIN
        imafit=imafit*calib
        writefits,dir+image+'_Jy.fits',imafit,head
        ;IF keyword_set(rotate) THEN BEGIN
            imafit=rot(imafit,rotate,/CUBIC,MISSING=0.)
            writefits,dir+image+'_Jy_rot.fits',imafit,head
            IF keyword_set(gauss) THEN BEGIN
                gkerr=psf_gaussian(NPIXEL=11.,FWHM=gauss*2.355,NDIM=2.,/NORM,/DOUBLE)
                imafit=convol(imafit,gkerr)                
                writefits,dir+image+'_Jy_rot_gauss1pix.fits',imafit,head
                file_copy,dir+image+'_Jy_rot_gauss1pix.fits','/home/tanio/data/hst/sample/nIR/ngc3256/'+image+'_Jy_stdav_gauss1pix.fits',/OVERW
            ENDIF
        ;ENDIF
    ENDIF
ENDIF ELSE BEGIN
    writefits,dir+image+'_'+lab+'bs.fits',0.,head
    writefits,dir+image+'_'+lab+'bs.fits',imafit,headext1,/APPEND
    imafit=imafit/tssons
    writefits,dir+image+'_'+lab+'bs_ADUs-1.fits',0.,head
    writefits,dir+image+'_'+lab+'bs_ADUs-1.fits',imafit,headext1,/APPEND
    IF keyword_set(calib) THEN BEGIN
        imafit=imafit*calib
    writefits,dir+image+'_Jy.fits',0.,head
    writefits,dir+image+'_Jy.fits',imafit,headext1,/APPEND
    ENDIF
ENDELSE
ENDIF


; -----------------------------------------------------------------


; FLAT
;IF i EQ 0 THEN superflat=ima/4. ELSE superflat=superflat+ima/4.

;ENDFOR

;superflat=superflat/mean(superflat)
;file_delete,'S20050918S003_Sflat.fits',/ALLOW
;writefits,'S20050918S003_Sflat.fits',0.,head
;writefits,'S20050918S003_Sflat.fits',superflat,/APPEND;,headext1

; FLAT
;flathead=headfits('S20050918S003_Sflat.fits')
;flat=readfits('S20050918S003_Sflat.fits',flatheadext1,/NOSCALE,EXTEN=exten)
;file_delete,image+'_fs.fits',/ALLOW
;writefits,image+'_fs.fits',0.,head
;writefits,image+'_fs.fits',ima/flat,headext1,/APPEND

;ima2=readfits(image+'_bs.fits',head2)

;stop
;return,ima

END
