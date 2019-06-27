
      SUBROUTINE CRE2J (DR,DD,DATE,DL,DB)
      DOUBLE PRECISION date
      REAL DR,DD,DL,DB
      DOUBLE PRECISION L,B
      CALL CDE2J (DBLE(DR),DBLE(DD),L,B)
      DL=L
      DB=B
      END

      SUBROUTINE CRJ2E (DL,DB,DATE,DR,DD)
      DOUBLE PRECISION date
      REAL DR,DD,DL,DB
      DOUBLE PRECISION R,D
      CALL CDJ2E (DBLE(DL),DBLE(DB),R,D)
      DR=R
      DD=D
      END

      SUBROUTINE CDJ2E (DR,DD,DATE,DL,DB)
C  Transformation from J2000.0 equatorial coordinates to
C  ecliptic coordinates
C  Given:
C     DR,DD       dp      J2000.0 mean RA,Dec (deg)
C     DATE        dp      TDB 
C  Returned:
C     DL,DB       dp      ecliptic longitude and latitude
C                         (mean of date, IAU 1980 theory, deg)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DR,DD,DATE,DL,DB
      DOUBLE PRECISION CAL_JE
      DOUBLE PRECISION RMAT(3,3),V1(3),V2(3)
C  Equatorial to ecliptic
C  Mean J2000 to mean of date
      CALL CPRECJ(2000D0,CAL_JE(DATE),RMAT)
      CALL DUNITLL(DR,DD,V1)
      CALL DPOSTX(RMAT,V1,V2)
      CALL ECMAT(DATE,RMAT)
      CALL DPOSTX(RMAT,V2,V1)
      CALL DPOLARLL(V1,DL,DB)
      END
C ----------------------------------------------------------
C
      SUBROUTINE CDE2J (DL,DB,DATE,DR,DD)
C  Transformation from ecliptic coordinates to
C  J2000.0 equatorial coordinates
C  Given:
C     DL,DB       dp      ecliptic longitude and latitude
C                           (mean of date, IAU 1980 theory, deg)
C     DATE        dp      TDB 
C  Returned:
C     DR,DD       dp      J2000.0 mean RA,Dec (deg)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DL,DB,DATE,DR,DD
      DOUBLE PRECISION CAL_JE
      DOUBLE PRECISION RMAT(3,3),V1(3),V2(3)
C  Spherical to Cartesian
      CALL DUNITLL(DL,DB,V1)
C  Ecliptic to equatorial
      CALL ECMAT(DATE,RMAT)
      CALL Dprex(RMAT,V1,V2)
C  Mean of date to J2000
      CALL CPRECJ(2000D0,CAL_JE(DATE),RMAT)
      CALL dprex (RMAT,V2,V1)
C  Cartesian to spherical
      CALL DPOLARLL(V1,DR,DD)
      END
C----------------------------------------------------------------
C
      SUBROUTINE ECMAT (DATE, RMAT)
C  Form the equatorial to ecliptic rotation matrix (IAU 1980 theory)
C  Given:
C     DATE     dp         TDB (loosely ET) as Modified Julian Date
C  Returned:
C     RMAT     dp(3,3)    matrix
C  References:
C     Murray,C.A., Vectorial Astrometry, section 4.3.
C  Note:
C    The matrix is in the sense   V(ecl)  =  RMAT * V(equ);  the
C    equator, equinox and ecliptic are mean of date.
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DATE,RMAT(3,3)
C  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.4848136811095359949D-05)
      DOUBLE PRECISION T,EPS0,S,C
      DOUBLE PRECISION CAL_JC
C  Interval between basic epoch J2000.0 and current epoch (JC)
      T=CAL_JC(DATE) 
C  Mean obliquity
      EPS0=AS2R*(84381.448+(-46.8150+(-0.00059+0.001813*T)*T)*T)
C  Matrix
      S=SIN(EPS0)
      C=COS(EPS0)
      RMAT(1,1)=1D0
      RMAT(2,1)=0D0
      RMAT(3,1)=0D0
      RMAT(1,2)=0D0
      RMAT(2,2)=C
      RMAT(3,2)=-S
      RMAT(1,3)=0D0
      RMAT(2,3)=S
      RMAT(3,3)=C

      END

