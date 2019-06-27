; $Id: curvefit.pro,v 1.27 2002/02/06 21:45:42 scottm Exp $
;
; Copyright (c) 1982-2002, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;
;+
; NAME:
;       CURVEFIT
;
; PURPOSE:
;       Non-linear least squares fit to a function of an arbitrary
;       number of parameters.  The function may be any non-linear
;       function.  If available, partial derivatives can be calculated by
;       the user function, else this routine will estimate partial derivatives
;       with a forward difference approximation.
;
; CATEGORY:
;       E2 - Curve and Surface Fitting.
;
; CALLING SEQUENCE:
;       Result = CURVEFIT(X, Y, Weights, A, SIGMA, FUNCTION_NAME = name, $
;                         ITMAX=ITMAX, ITER=ITER, TOL=TOL, /NODERIVATIVE)
;
; INPUTS:
;       X:  A row vector of independent variables.  This routine does
;           not manipulate or use values in X, it simply passes X
;           to the user-written function.
;
;       Y:  A row vector containing the dependent variable.
;
;  Weights:  A row vector of weights, the same length as Y.
;            For no weighting,
;                 Weights(i) = 1.0.
;            For instrumental (Gaussian) weighting,
;                 Weights(i)=1.0/sigma(i)^2
;            For statistical (Poisson)  weighting,
;                 Weights(i) = 1.0/y(i), etc.
;
;       A:  A vector, with as many elements as the number of terms, that
;           contains the initial estimate for each parameter.  IF A is double-
;           precision, calculations are performed in double precision,
;           otherwise they are performed in single precision. Fitted parameters
;           are returned in A.
;
; KEYWORDS:
;       FUNCTION_NAME:  The name of the function (actually, a procedure) to
;       fit.  IF omitted, "FUNCT" is used. The procedure must be written as
;       described under RESTRICTIONS, below.
;
;       ITMAX:  Maximum number of iterations. Default = 20.
;       ITER:   The actual number of iterations which were performed
;       TOL:    The convergence tolerance. The routine returns when the
;               relative decrease in chi-squared is less than TOL in an
;               interation. Default = 1.e-3.
;       CHI2:   The value of chi-squared on exit (obselete)
;
;       CHISQ:   The value of reduced chi-squared on exit
;       NODERIVATIVE:   IF this keyword is set THEN the user procedure will not
;               be requested to provide partial derivatives. The partial
;               derivatives will be estimated in CURVEFIT using forward
;               differences. IF analytical derivatives are available they
;               should always be used.
;
;       DOUBLE = Set this keyword to force the calculation to be done in
;                double-precision arithmetic.
;
;   YERROR: The standard error between YFIT and Y.
;
; OUTPUTS:
;       Returns a vector of calculated values.
;       A:  A vector of parameters containing fit.
;
; OPTIONAL OUTPUT PARAMETERS:
;       Sigma:  A vector of standard deviations for the parameters in A.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       The function to be fit must be defined and called FUNCT,
;       unless the FUNCTION_NAME keyword is supplied.  This function,
;       (actually written as a procedure) must accept values of
;       X (the independent variable), and A (the fitted function's
;       parameter values), and return F (the function's value at
;       X), and PDER (a 2D array of partial derivatives).
;       For an example, see FUNCT in the IDL User's Libaray.
;       A call to FUNCT is entered as:
;       FUNCT, X, A, F, PDER
; where:
;       X = Variable passed into CURVEFIT.  It is the job of the user-written
;           function to interpret this variable.
;       A = Vector of NTERMS function parameters, input.
;       F = Vector of NPOINT values of function, y(i) = funct(x), output.
;       PDER = Array, (NPOINT, NTERMS), of partial derivatives of funct.
;               PDER(I,J) = DErivative of function at ith point with
;               respect to jth parameter.  Optional output parameter.
;               PDER should not be calculated IF the parameter is not
;               supplied in call. IF the /NODERIVATIVE keyword is set in the
;               call to CURVEFIT THEN the user routine will never need to
;               calculate PDER.
;
; PROCEDURE:
;       Copied from "CURFIT", least squares fit to a non-linear
;       function, pages 237-239, Bevington, Data Reduction and Error
;       Analysis for the Physical Sciences.  This is adapted from:
;       Marquardt, "An Algorithm for Least-Squares Estimation of Nonlinear
;       Parameters", J. Soc. Ind. Appl. Math., Vol 11, no. 2, pp. 431-441,
;       June, 1963.
;
;       "This method is the Gradient-expansion algorithm which
;       combines the best features of the gradient search with
;       the method of linearizing the fitting function."
;
;       Iterations are performed until the chi square changes by
;       only TOL or until ITMAX iterations have been performed.
;
;       The initial guess of the parameter values should be
;       as close to the actual values as possible or the solution
;       may not converge.
;
; EXAMPLE:  Fit a function of the form f(x) = a * exp(b*x) + c to
;           sample pairs contained in x and y.
;           In this example, a=a(0), b=a(1) and c=a(2).
;           The partials are easily computed symbolicaly:
;           df/da = exp(b*x), df/db = a * x * exp(b*x), and df/dc = 1.0
;
;           Here is the user-written procedure to return F(x) and
;           the partials, given x:
;
;       pro gfunct, x, a, f, pder      ; Function + partials
;         bx = exp(a(1) * x)
;         f= a(0) * bx + a(2)         ;Evaluate the function
;         IF N_PARAMS() ge 4 THEN $   ;Return partials?
;         pder= [[bx], [a(0) * x * bx], [replicate(1.0, N_ELEMENTS(f))]]
;       end
;
;         x=findgen(10)                  ;Define indep & dep variables.
;         y=[12.0, 11.0,10.2,9.4,8.7,8.1,7.5,6.9,6.5,6.1]
;         Weights=1.0/y            ;Weights
;         a=[10.0,-0.1,2.0]        ;Initial guess
;         yfit=curvefit(x,y,Weights,a,sigma,function_name='gfunct')
;         print, 'Function parameters: ', a
;         print, yfit
;       end
;
; MODIFICATION HISTORY:
;       Written, DMS, RSI, September, 1982.
;       Does not iterate IF the first guess is good.  DMS, Oct, 1990.
;       Added CALL_PROCEDURE to make the function's name a parameter.
;              (Nov 1990)
;       12/14/92 - modified to reflect the changes in the 1991
;            edition of Bevington (eq. II-27) (jiy-suggested by CreaSo)
;       Mark Rivers, U of Chicago, Feb. 12, 1995
;           - Added following keywords: ITMAX, ITER, TOL, CHI2, NODERIVATIVE
;             These make the routine much more generally useful.
;           - Removed Oct. 1990 modification so the routine does one iteration
;             even IF first guess is good. Required to get meaningful output
;             for errors.
;           - Added forward difference derivative calculations required for
;             NODERIVATIVE keyword.
;           - Fixed a bug: PDER was passed to user's procedure on first call,
;             but was not defined. Thus, user's procedure might not calculate
;             it, but the result was THEN used.
;
;      Steve Penton, RSI, June 1996.
;            - Changed SIGMAA to SIGMA to be consistant with other fitting
;              routines.
;            - Changed CHI2 to CHISQ to be consistant with other fitting
;              routines.
;            - Changed W to Weights to be consistant with other fitting
;              routines.
;            _ Updated docs regarding weighing.
;
;      Chris Torrence, RSI, Jan,June 2000.
;         - Fixed bug: if A only had 1 term, it was passed to user procedure
;           as an array. Now ensure it is a scalar.
;         - Added more info to error messages.
;         - Added /DOUBLE keyword.
;      CT, RSI, Nov 2001: If Weights is undefined, then assume no weighting,
;           and boost the Sigma error estimates according to NR Sec 15.2
;           Added YERROR keyword.
;
;-
FUNCTION CURVEFIT2D, x,y,z,weightsIn,a,sigma, FUNCTION_NAME = Function_Name, $
                        ITMAX=itmax, ITER=iter, TOL=tol, CHI2=chi2, $
                        NODERIVATIVE=noderivative, CHISQ=chisq, $
                        DOUBLE=double, YERROR=zerror, SILENT=silent, $
                        _EXTRA=extra

    COMPILE_OPT strictarr

       ON_ERROR,2              ;Return to caller IF error
       ;IF keyword_set(silent) EQ 0 THEN print,'/home/tanio/idlphot/pro/curvefit2d.pro: v. Feb 2008'
       ;Name of function to fit

       IF n_elements(function_name) LE 0 THEN function_name = "FUNCT"

       type = size(a,/type)
    double = (N_ELEMENTS(double) LT 1) ? (type EQ 5) : KEYWORD_SET(double)

    CASE double OF
    0: IF (type NE 4) THEN a = float(a)  ;Make params floating
    1: IF (type NE 5) THEN a = double(a)  ;Make params floating
    ENDCASE

    IF n_elements(tol) EQ 0 THEN tol = double ? 1d-3 : 1e-3  ;Convergence tol
    IF n_elements(itmax) EQ 0 THEN itmax = 20     ;Maximum # iterations

       ; IF we will be estimating partial derivatives THEN compute machine
       ; precision

       IF keyword_set(NODERIVATIVE) THEN BEGIN
          res = machar(DOUBLE=double)
          eps = sqrt(res.eps)
       ENDIF

       nterms = n_elements(a)         ; # of parameters
       nZ = n_elements(z)
       nfree = nZ - nterms ; Degrees of freedom

       IF nfree LE 0 THEN MESSAGE, $
        'Number of parameters in A must be less than number of dependent values in Z.'

       IF (nterms EQ 1) THEN a = a[0]   ; Ensure a is a scalar
       flambda = double ? 0.001d : 0.001                   ;Initial lambda
       diag = lindgen(nterms)*(nterms+1) ; Subscripts of diagonal elements

;      Define the partial derivative array

       IF double THEN pder = dblarr(nZ, nterms) $
       ELSE pder = fltarr(n_elements(z), nterms)

    noWeighting = N_ELEMENTS(weightsIn) eq 0
    weights = noWeighting ? REPLICATE(1.0, nZ) : weightsIn

    error_msg1 = 'Result F from "'+ $
        Function_name+'" must have same number of elements as Z.'
    error_msg2 = 'PDER from "'+ $
        Function_name+'"  must be of size N_ELEMENTS(Z) by N_ELEMENTS(A).'

       FOR iter = 1, itmax DO BEGIN      ; Iteration loop

;         Evaluate alpha and beta matricies.

          IF keyword_set(NODERIVATIVE) THEN BEGIN

;            Evaluate function and estimate partial derivatives
            CALL_PROCEDURE, Function_name,x,y,a,zfit,_EXTRA=extra
            IF (N_ELEMENTS(zfit) NE nZ) THEN MESSAGE, error_msg1
             FOR term=0, nterms-1 DO BEGIN

                p = a       ; Copy current parameters

                ; Increment size for forward difference derivative
                inc = eps * abs(p[term])
                IF (inc EQ 0.) THEN inc = eps
                p[term] = p[term] + inc
                CALL_PROCEDURE, function_name,x,y,p,zfit1,_EXTRA=extra
                pder[0,term] = (zfit1-zfit)/inc

            ENDFOR
          ENDIF ELSE BEGIN

             ; The user's procedure will return partial derivatives
;if function_name EQ "GAUSS2_FUNCT" THEN print,'curvefitrecibe',x
            call_procedure, function_name,x,y,a,zfit,pder,_EXTRA=extra     ;1st call
;if function_name EQ "GAUSS2_FUNCT" THEN print,a
            IF (N_ELEMENTS(zfit) NE nZ) THEN MESSAGE, error_msg1
 
          ENDELSE

          IF nterms EQ 1 THEN pder = reform(pder, n_elements(z), 1)
            IF (NOT ARRAY_EQUAL(SIZE(pder,/DIM),[nZ,nterms])) THEN $
                MESSAGE, error_msg2

          beta = (z-zfit)*weights # pder
          alpha = transpose(pder) # (weights # (fltarr(nterms)+1)*pder)

          ; save current values of return parameters

          sigma1 = sqrt( 1.0 / alpha[diag] )           ; Current sigma.
          sigma  = sigma1

          chisq1 = total(weights*(z-zfit)^2)/nfree     ; Current chi squared.
          chisq = chisq1

          zfit1 = zfit

          done_early = chisq1 LT total(abs(z))/1d7/nfree
          ;print,'chisq1,total...',chisq1,total(abs(z))/1d7/nfree
          IF done_early THEN BEGIN
              print,'Done early'
              GOTO, done
          ENDIF

          c = sqrt(alpha[diag])
          c = c # c

          lambdaCount = 0
;if function_name EQ 'GAUSS2_FUNCT' THEN print,pder,beta,alpha,sigma,chisq,c
          REPEAT BEGIN

             lambdaCount = lambdaCount + 1

             ; Normalize alpha to have unit diagonal.
             array = alpha / c

             ; Augment the diagonal.
             array[diag] = array[diag]*(1.+flambda)

             ; Invert modified curvature matrix to find new parameters.
             IF n_elements(array) EQ 1 THEN array = (1.0 / array) $
             ELSE array = invert(array)

             b = a + array/c # transpose(beta)          ; New params
             IF (nterms EQ 1) THEN b = b[0]             ; Ensure b is a scalar
             call_procedure, function_name,x,y,b,zfit,_EXTRA=extra    ;pder?
             ;Evaluate function

             ;if function_name EQ 'GAUSS2_FUNCT' THEN print,a
             chisq = total(weights*(z-zfit)^2)/nfree    ; New chisq
             sigma = sqrt(array[diag]/alpha[diag])      ; New sigma
             ;=sigma=sqrt(invert(alpha[diag])
             ;if function_name EQ 'GAUSS2_FUNCT' THEN print,b,chisq
             IF (finite(chisq) EQ 0) OR $
             (lambdaCount GT 30 AND chisq GE chisq1) THEN BEGIN

                ; Reject changes made this iteration, use old values.
                zfit  = zfit1
                sigma = sigma1
                chisq = chisq1

               MESSAGE,'Failed to converge- CHISQ increasing without bound.', $
               /INFORMATIONAL

                GOTO, done

             ENDIF

             flambda = flambda*10.               ; Assume fit got worse

          ENDREP UNTIL chisq LE chisq1

          flambda = flambda/100.
          a=b                                    ; Save new parameter estimate.

;This is the row that have to be written to check if the fit goes well
;if function_name EQ 'GAUSS2_FUNCT' THEN print,b,sigma,'Chisqr:',chisq

          IF ((chisq1-chisq)/chisq1) LE tol THEN GOTO,done   ;Finished?
       ENDFOR                        ;iteration loop

       iterationStr = STRTRIM(itmax,2)+' iteration' + (['','s'])[itmax NE 1]
       MESSAGE, 'Failed to converge after '+iterationStr+'.', $
       /INFORMATIONAL

done:

;    print,'LOS CHIS: ',chisq,chisq1,(chisq1-chisq)/chisq1,lambdaCount
    IF function_name EQ 'GAUSS2Dr_FUNCT' AND keyword_set(silent) EQ 0 THEN $
    print,'Curvefit2d iterations: ',iter
    call_procedure, function_name, x,y,a,zfit,pder,_EXTRA=extra
    chisq = total(weights*(z-zfit)^2)/nfree
    alpha = transpose(pder) # (weights # (fltarr(nterms)+1)*pder)
    covar=invert(alpha)
    sigma = sqrt(covar[diag])
    ;if function_name EQ 'GAUSS2_FUNCT' THEN print,b,sigma,chisq
    ; If no weighting, then we need to boost error estimates by sqrt(chisq).
    ; See Numerical Recipes section 15.2 for details.
    if noWeighting then begin
        sigma = sigma*SQRT(chisq)
    endif

    ; Experimental variance estimate, unbiased
    var = (nZ GT nterms) ? TOTAL((zfit-z)^2 )/nfree : (dbl ? 0d : 0.0)
    zerror = SQRT(var)

    chi2 = chisq*nfree         ; Return chi-squared (chi2 obsolete-still works)
    IF done_early THEN iter = iter - 1
    RETURN,zfit          ; return result
END
