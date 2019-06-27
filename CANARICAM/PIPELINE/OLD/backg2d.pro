PRO backg2d_funct, x, y, a, f, pder, SLOPES=slopes, FIXED=fixed, FIXVAL=fixval
;A ver x e y son vectores! y la expansion (si existe) se hace en backg2d

;nx = long(x[0])		;Retrieve X and Y vectors
;ny = long(x[1])
xsize=size(x) & ysize=size(y)
nx=long(xsize[1]) & ny=long(ysize[1])

IF nx NE ny THEN BEGIN
    print,'X & Y must have the same lenght'
    RETURN
ENDIF

n = n_elements(a)
IF keyword_set(fixed) THEN BEGIN
    nfix=n_elements(fixed)
    IF nfix NE n THEN BEGIN
        message,'Nparams not equal to fixed elements'
        RETURN
    ENDIF
ENDIF ELSE BEGIN
    fixed=intarr(n)
ENDELSE

fixpos=where(fixed EQ 1,nfix)
IF fixpos[0] NE -1 THEN FOR i=0,nfix-1 DO a[fixpos[i]]=fixval[fixpos[i]]

;Reforming to a n-dimensional array
f=fltarr(nx)+a[0]
IF keyword_set(slopes) THEN f=f+a[1]*x+a[2]*y
;print,f

;To check visually if the fit goes well
;window,2,xsize=300,ysize=300 & surface,reform(f,nx,ny),TITLE='Fit progression'
;read,o

IF n_params(0) LE 4 THEN RETURN ;need partial?  No.

;F=a[0]+a[1]*x+a[2]*y
pder=fltarr(nx, n)+1.
IF fixed[0] EQ 0 THEN pder[*,0]=1.
IF keyword_set(slopes) THEN BEGIN
    IF fixed[1] EQ 0 THEN pder[*,1]=x
    IF fixed[2] EQ 0 THEN pder[*,2]=y
ENDIF

END

;-----------------------------------------------------------------------------

function backg2d, z, x, y, pars, WEIGHT = w, SIGMA=sigma, CHISQ=chi, $
                  YERROR=stdev, NEGATIVE = neg, TOL=tol, SLOPES=slopes,$
                  SILENT=silent, SIGITER=sigiter, DOUBLESIG=doublesig,$
                  DSPIXS=dspixs, ZTMP=ztmp, ZSUB=zsub, INDSZTMP=indsztmp,$
                  _EXTRA=extra

;Si z es 2D, x e y (que son vectores!) se expanden y vuelven a reformarse

on_error,2                      ;Return to caller if an error occurs
IF keyword_set(silent) EQ 0 THEN print,'/home/tanio/idlphot/pro/backg2d.pro: v. Feb 2008'
n=n_elements(z)
zsize=size(z)

nx=zsize[1]
ny=zsize[2]
np=n_params()
IF np LT 3 THEN x = findgen(nx)
IF np LT 4 THEN y = findgen(ny)

IF zsize[0] EQ 2 THEN BEGIN
    IF nx NE n_elements(x) THEN $
    message,'X array must have size equal to number of columns of Z'
    IF ny NE n_elements(y) THEN $
    message,'Y array must have size equal to number of rows of Z'
ENDIF ELSE BEGIN
    IF nx NE n_elements(x) OR nx NE n_elements(y) THEN $
    message,'X & Y array must have size equal to Z'
ENDELSE

;quad2d,z,x,y,ab,1;,WEIGHT=1./z,SIGMA=sigab
;print,'jar',ab,sigab

; First guess, without XY term...
pars=0.00001;[ab[0]]
IF keyword_set(slopes) THEN pars=[pars,0.,0.];ab[1],ab[2]]


;print,'---------------------------------------------------------------------'
;print,'Initial: '
;print,pars
;print,'First iter.'

;  If there's a tilt, add the XY term = 0
IF keyword_set(w) THEN wtmp = reform(w,n) ELSE wtmp = replicate(1.,n)
IF keyword_set(tol) THEN precision=tol ELSE precision=0.1

IF zsize[0] EQ 2 THEN BEGIN
    xtmp=reform(x # replicate(1.,ny),n)
    ytmp=reform(replicate(1.,nx) # y,n)
    ztmp=reform(z,n,/OVERWRITE)
ENDIF ELSE BEGIN
    xtmp=x & ytmp=y & ztmp=z
ENDELSE

; COMENZAMOS LAS ITERACIONES
;IF keyword_set(sigiter) EQ 0 THEN sigiter=0.
tmpvalinds=where(finite(ztmp),tmpnval1)
valinds=tmpvalinds & nval1=tmpnval1

niter=0
REPEAT BEGIN 

; SELECT ALL VALID PIXELS
valinds=where(finite(ztmp),nval1)
zvec=ztmp[valinds]
xvec=xtmp[valinds] & yvec=ytmp[valinds]
wvec=wtmp[valinds]
;IF keyword_set(silent) EQ 0 THEN mmm,ztmp[valinds]

; FIT THEM TO A 2D PLANE
;************* print,'1st guess:',string(pars,format='(8f10.4)')

; MUCHO CUIDADO CON QUE ZVEC SEA "DOUBLE" PORQUE CURVEFIT2D SE HACE UN
; LIO TREMENDO. EN PRINCIPIO TODO TIENE QUE SER FLOAT. NO SE SI
; FUNCIONARIA SI FUESE TODO DOUBLE. LO QUE SI NO FUNCIONA ES QUE CADA
; VARIABLE SEA DE UN TIPO.
result = curvefit2d(xvec, yvec, zvec, wvec, pars, sigma,$
                FUNCTION_NAME="backg2d_funct", ITMAX=100, CHISQ=chi,$
                YERROR=stdev, TOL=precision, SLOPES=slopes, SILENT=silent,$
                _EXTRA=extra)

; THOSE LYING OUTSIDE THE THRESHOLD ARE REJECTED (EQUALLED TO NAN)
IF keyword_set(sigiter) THEN BEGIN
FOR i=0L,nval1-1 DO BEGIN
    IF keyword_set(doublesig) THEN BEGIN
        swch=where(dspixs EQ valinds[i])
        IF swch[0] EQ -1 THEN tmpsigiter=sigiter ELSE tmpsigiter=doublesig
    ENDIF ELSE BEGIN
        tmpsigiter=sigiter
    ENDELSE
    IF ztmp[valinds[i]] GT result[i]+tmpsigiter*stdev $
    OR ztmp[valinds[i]] LT result[i]-tmpsigiter*stdev $
    THEN ztmp[valinds[i]]=!Values.F_NAN
ENDFOR
ENDIF

; VERIFICATE WHETHER THERE IS ANY REJECTION
valinds=where(finite(ztmp),nval2)
niter=niter+1
ENDREP UNTIL nval1 EQ nval2 OR keyword_set(sigiter) EQ 0
IF keyword_set(silent) EQ 0 THEN print,'At iter: ',strcompress(string(niter),/REM),', accepted %: ',strcompress(string(float(nval2)/float(tmpnval1)*100.),/REM)

; ZTMP[valinds] is the array that contains the values of the pixels
; with which the background is fitted. ZSUB is ZTMP but with the
; subtraction of the background already done (but only in the pixels
; [valinds])


IF zsize[0] EQ 2 THEN BEGIN
   endresult=fltarr(nx,ny)
   endresult=endresult+pars[0]
   IF keyword_set(slopes) THEN endresult=endresult+pars[1]*(x#replicate(1.,ny))+pars[2]*(replicate(1.,nx)#y)
ENDIF ELSE BEGIN
   endresult=result
ENDELSE

zsub=ztmp
zsub[valinds]=ztmp[valinds]-endresult
;print,'Statistics: mean and MMM results'
;print,mean(ztmp[valinds])
IF keyword_set(silent) EQ 0 THEN BEGIN
    mmm,ztmp[valinds],mode,sigm,skew
    print,'Mean, mode, median [ztmp[valinds]]: ',mean(ztmp[valinds]),mode,median(ztmp[valinds])
ENDIF
invinds=where(finite(ztmp) EQ 0,ninv)
IF invinds[0] NE -1 THEN BEGIN
    ztmp[invinds]=endresult[invinds] ;mean(ztmp[valinds])
    zerow=where(wtmp EQ 0.,nzerow) & IF zerow[0] NE -1 THEN ztmp[zerow]=0.
    ;zsub[invinds]=endresult[invinds] ;mean(ztmp[valinds]) MODIFIED CAREFULL!
ENDIF

IF keyword_set(silent) EQ 0 THEN print,'Ntot= ',n,'; Nval= ',nval2

;endresult=fltarr(n)+pars[0]
;IF keyword_set(slopes) THEN endresult=endresult+pars[1]*x+pars[2]*y

IF zsize[0] EQ 2 THEN BEGIN
    ;x=fix(x[0:nx-1])
    ;y=fix(y[indgen(ny)*nx])
    z= REFORM(z, nx, ny, /OVERWRITE) ;Restore dimensions
;endresult=reform(endresult,nx,ny,/overwrite)
;    endresult=fltarr(nx,ny)
;    endresult=endresult+pars[0]
;    IF keyword_set(slopes) THEN endresult=endresult+pars[1]*(x#replicate(1.,ny))+pars[2]*(replicate(1.,nx)#y)
    ztmp=reform(ztmp,nx,ny,/overwrite)
    zsub=reform(zsub,nx,ny,/overwrite)
    indsztmp=fltarr(n)
    indsztmp[valinds]=valinds
    indsztmp=reform(indsztmp,nx,ny,/overwrite)
END

IF n_params() EQ 2 THEN x=pars

;
IF keyword_set(silent) EQ 0 THEN print,'Coefs, sigma, chi, stdev: ',[pars,sigma,chi,stdev]
RETURN, endresult

END
