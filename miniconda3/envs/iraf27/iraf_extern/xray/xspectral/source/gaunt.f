C  FUNCTION GAUNT (EKEV,TKEV,Z)
C  AUTHOR:  Kellogg, Baldin and Koch (Ap.J. 199, 299, 1975)
C  renamed by A. Szczypek     March 1986
C  revised by A. Szczypek     January 1988 - to incorporate revisions
C                              of Molnar et al (Ap.J. 1988) as described in
C                              version 1.1 of Science Specs.
C  revised by D. Worrall      October 1988 - to incorporate revisions
C                              transmitted by Larry Molnar to include the
C                              Kurucz interpolations for low temperatures:
C                                Z*Z*13.59/T(kev) > 100
C                              version 1.2 of Science Specs.

C  COMPUTE FREE-FREE GAUNT FACTOR USING A SERIES OF POLYNOMIAL
C  APPROXIMATIONS TO THE TABULATED VALUES OF KARZAS AND LATTER (1961).
C  FROM KELLOGG, BALDWIN, AND KOCH 1975, AP.J.

C  EKEV = PHOTON ENERGY IN KEV
C  TKEV = BREMSSTRAHLUNG TEPERATURE IN KEV
C     Z = ATOMIC NUMBER

      FUNCTION GAUNT (EKEV,TKEV,Z)
 
      REAL EKEV, TKEV, Z

      INTEGER  N,  M,  M1

      REAL GAM1, U, U1, U2, U12, UINV, T2, AI, AK, BORN, G1, G2, P

      REAL A(6,7,3),GAM2(6),GAM3(6)
 
      DATA A/1.001,1.004,1.017,1.036,1.056,1.121,1.001,1.005,1.017,
     *  1.046,1.073,1.115,.9991,1.005,1.03,1.055,1.102,1.176,.997,1.005,
     *  1.035,1.069,1.134,1.186,.9962,1.004,1.042,1.1,1.193,1.306,.9874,
     *  .9962,1.047,1.156,1.327,1.485,.9681,.9755,1.020,1.208,1.525,
     *  1.965,.3029,.1616,.04757,.013,.0049,-.0032,.4905,.2155,.08357,
     *  .02041,.00739,.00029,.654,.2833,.08057,.03257,.00759,-.00151,
     *  1.029,.391,.1266,.05149,.01274,.00324,.9569,.4891,.1764,.05914,
     *  .01407,-.00024,1.236,.7579,.326,.1077,.028,.00548,1.327,1.017,
     *  0.6017,.205,.0605,.00187,-1.323,-.254,-.01571,-.001,-.000184,
     *  .00008,-4.762,-.3386,-.03571,-.001786,-.0003,.00001,-6.349,
     *  -.4206,-.02571,-.003429,-.000234,.00005,-13.231,-.59,-.04571,
     *  -.005714,-.000445,-.00004,-7.672,-.6852,-.0643,-.005857,-.00042,
     *  .00004,-7.143,-.9947,-.12,-.01007,-.000851,-.00004,-3.175,
     *  -1.116,-0.2270,-.01821,-.001729,.00023/
 
      DATA GAM2/.7783,1.2217,2.6234,4.3766,20.,70./
      DATA GAM3/1.,1.7783,3.,5.6234,10.,30./
 
C  CONVERT TE TO KARZAS AND LATTER UNITS
 
      GAM1 = Z*Z*13.59/TKEV
C begin dmw revision Oct 1988
C					John : Jan 90
       U=EKEV/TKEV
       IF ( U .GT. 50.0 ) U = 50.0
       IF (GAM1.GT.100.) THEN
          GAM1=GAM1/1000.
          CALL KURUCZ(U,GAM1,G1)
          GAUNT=G1
          RETURN
       ENDIF
C end dmw revision
C
C  COMPUTE BORN APPROXIMATION GAUNT FACTOR
C
C      U = EKEV/TKEV			John : Jan 90
      U2 = U*U
      U1 = U/2.
      U12 = U2/16.
      UINV = 2./U1
      T2 = (U1/3.75)**2
      IF (U1.GT.2.) GO TO 40
      AI = 1. + T2*(3.5156229 + T2*(3.0899424 + T2*(1.2067492 + T2*
     *(.2659732 + T2*(.0360768 + T2*.0045813)))))
      AK = -.57721566 - ALOG(U1/2.)*AI + U12*(.4227842 + U12*(.23069756
     * + U12*(.0348859 + U12*(.00262698 + U12*(.0001075 + U12*7.E-6)))))
      BORN = .5513*EXP(U1)*AK
      GO TO 50
   40 AK = 1.25331414 + UINV*(-.07832358 + UINV*(.02189568 + UINV*
     *(-.01062446 + UINV*(.00587872 + UINV*(-.0025154 + UINV*
     *.00053208)))))
      BORN = .5513*AK/SQRT(U1)
C
C  COMPUTE POLYNOMIAL FACTOR TO MULTIPLY BORN APPROXIMATION
C
   50 IF (GAM1.LT.1.) GO TO 70
      IF (U.GE.0.003) GOTO 60
      U = 0.003
      U2 = U*U
   60 IF (U.LE.0.03) N = 1
      IF (U.LE.0.30.AND.U.GT.0.03) N = 2
      IF (U.LE.1.0.AND.U.GT.0.30) N = 3
      IF (U.LE.5.0.AND.U.GT.1.0) N = 4
      IF (U.LE.15.0.AND.U.GT.5.0) N = 5
      IF (U.GT.15.0) N = 6
      IF (GAM1.LE.1.7783) M = 1
      IF (GAM1.LE.3.0.AND.GAM1.GT.1.17783) M = 2
      IF (GAM1.LE.5.6234.AND.GAM1.GT.3.0) M = 3
      IF (GAM1.LE.10.0.AND.GAM1.GT.5.6234) M = 4
      IF (GAM1.LE.30.0.AND.GAM1.GT.10.0) M = 5
      IF (GAM1.GT.30.0) M = 6

      M1 = M + 1

      G1 = (A(N,M ,1) + A(N,M ,2)*U + A(N,M ,3)*U2)*BORN
      G2 = (A(N,M1,1) + A(N,M1,2)*U + A(N,M1,3)*U2)*BORN

      P = (GAM1-GAM3(M))/GAM2(M)
      GAUNT = (1.-P)*G1 + P*G2
      GO TO 80
   70 GAUNT = BORN
 
   80 RETURN
      END

C begin dmw revision Oct 1988
C
	SUBROUTINE KURUCZ(UIN, GAM, GAUNT)
C Subroutine supplied be Larry Molnar 
C FOR GAM.GT.0.1, USE BILINEAR INTERPOLATION OF TABLE OF
C KURUCZ 1970, SAO SPECIAL REPT., NO. 309, (P. 77) WITH THE FOLLOWING REVISIONS
C 1) G(10**0.5,10**-0.5) = 1.00
C 2) G(10**0.5,10**-1.0) = 0.86
C INTERPOLATION SCHEME BASED ON PRESS ET AL'S NUMERICAL RECIPESP. 96
C
	INTEGER J, K
	REAL*4 GAM, GAUNT, RJ, RK, T, U, UIN, YA(7,12)
	DATA YA /	5.40, 5.25, 5.00, 4.69, 4.48, 4.16, 3.85,
     +                  4.77, 4.63, 4.40, 4.13, 3.87, 3.52, 3.27,
     +                  4.15, 4.02, 3.80, 3.57, 3.27, 2.98, 2.70,
     +                  3.54, 3.41, 3.22, 2.97, 2.70, 2.45, 2.20,
     +                  2.94, 2.81, 2.65, 2.44, 2.21, 2.01, 1.81,
     +                  2.41, 2.32, 2.19, 2.02, 1.84, 1.67, 1.50,
     +                  1.95, 1.90, 1.80, 1.68, 1.52, 1.41, 1.30,
     +                  1.55, 1.56, 1.51, 1.42, 1.33, 1.25, 1.17,
     +                  1.17, 1.30, 1.32, 1.30, 1.20, 1.15, 1.11,
     +                  0.86, 1.00, 1.15, 1.18, 1.15, 1.11, 1.08,
     +                  0.59, 0.76, 0.97, 1.09, 1.13, 1.10, 1.08,
     +                  0.38, 0.53, 0.76, 0.96, 1.08, 1.09, 1.09 /
	RJ = 2.*LOG10(GAM) + 3.
	J = RJ
	RJ = J
	RK = 2.*LOG10(UIN) + 9.
	K = RK

	IF ( K .LT. 1 ) K = 1
	RK = K

C John : Jan 90

	IF ( J .GT.  6 ) THEN
		J  = 6
		RJ = J
	ENDIF
	IF ( J .LT.  1 ) THEN
		J  = 1
		RJ = J
	ENDIF
	IF ( K .GT. 11 ) THEN
		K  = 11
		RK = K
	ENDIF


		T = (LOG10(GAM) - (RJ - 3.)/2.)/0.5
		U = (LOG10(UIN) - (RK - 9.)/2.)/0.5
		GAUNT = (1.-T)*(1.-U)*YA(J,K) + T*(1.-U)*YA(J+1,K)
     +                + T*U*YA(J+1,K+1) + (1.-T)*U*YA(J,K+1)

	RETURN
	END
C end dmw revision
C







