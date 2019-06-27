C ----------------------------------------------------------
C
      SUBROUTINE CDB2G (DR,DD,DL,DB)
C  Transformation from B1950.0 'FK4' equatorial coordinates to
C  IAU 1958 galactic coordinates
C  Given:     DR,DD       dp       B1950.0 'FK4' RA,Dec
C  Returned:  DL,DB       dp    galactic longitude and latitude L2,B2
C  Reference:
C     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DR,DD,DL,DB
      DOUBLE PRECISION V1(3),V2(3),R,D
C  L2,B2 system of galactic coordinates
C  P = 192.25       RA of galactic north pole (mean B1950.0)
C  Q =  62.6        inclination of galactic to mean B1950.0 equator
C  R =  33          longitude of ascending node
C  P,Q,R are degrees
C  Equatorial to galactic rotation matrix
C  the Eulerian angles are P, Q, 90-R
C         +CP.CQ.SR-SP.CR     +SP.CQ.SR+CP.CR     -SQ.SR
C         -CP.CQ.CR-SP.SR     -SP.CQ.CR+CP.SR     +SQ.CR
C         +CP.SQ              +SP.SQ              +CQ
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.066988739415D0,-0.872755765852D0,-0.483538914632,
     : +0.492728466075D0,-0.450346958020D0,+0.744584633283,
     : -0.867600811151D0,-0.188374601723D0,+0.460199784784/
C  Remove E-terms
      CALL SUBETRMS(DR,DD,1950D0,R,D)
C  Spherical to Cartesian
      CALL DUNITLL(R,D,V1)
C  Rotate to galactic
      CALL DPOSTX(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,DL,DB)
      END
C ----------------------------------------------------------
C
C
      SUBROUTINE CDJ2G (DR,DD,DL,DB)
C  Transformation from J2000.0 equatorial coordinates to
C  IAU 1958 galactic coordinates
C  Given:     DR,DD       dp       J2000.0 RA,Dec
C  Returned:  DL,DB  dp       galactic longitude and latitude L2,B2
C  Reference:
C     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DR,DD,DL,DB
      DOUBLE PRECISION V1(3),V2(3)
C  L2,B2 system of galactic coordinates
C  P = 192.25       RA of galactic north pole (mean B1950.0)
C  Q =  62.6        inclination of galactic to mean B1950.0 equator
C  R =  33          longitude of ascending node
C  P,Q,R are degrees
C  Equatorial to galactic rotation matrix (J2000.0):
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.054875539726D0,-0.873437108010D0,-0.483834985808D0,
     : +0.494109453312D0,-0.444829589425D0,+0.746982251810D0,
     : -0.867666135858D0,-0.198076386122D0,+0.455983795705D0/
C  Spherical to Cartesian
      CALL DUNITLL(DR,DD,V1)
C  Equatorial to galactic
      CALL DPOSTX(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,DL,DB)
      END
C ----------------------------------------------------------
C
      SUBROUTINE CDG2J (DL,DB,DR,DD)
C  Transformation from IAU 1958 galactic coordinates to
C  J2000.0 equatorial coordinates
C  Given:*     DL,DB dp       galactic longitude and latitude L2,B2
C  Returned:   DR,DD       dp       J2000.0 RA,Dec
C  Reference:
C     Blaauw et al, Mon.Not.R.Astron.Soc.,121,123 (1960)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DL,DB,DR,DD
      DOUBLE PRECISION V1(3),V2(3)
C  L2,B2 system of galactic coordinates
C  P = 192.25       RA of galactic north pole (mean B1950.0)
C  Q =  62.6        inclination of galactic to mean B1950.0 equator
C  R =  33          longitude of ascending node
C  P,Q,R are degrees
C  Equatorial to galactic rotation matrix (J2000.0):
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.054875539726D0,-0.873437108010D0,-0.483834985808D0,
     : +0.494109453312D0,-0.444829589425D0,+0.746982251810D0,
     : -0.867666135858D0,-0.198076386122D0,+0.455983795705D0/
C  Spherical to Cartesian
      CALL DUNITLL(DL,DB,V1)
C  Galactic to equatorial
      CALL DPREX(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,DR,DD)
      END
C ----------------------------------------------------------
C
      SUBROUTINE CDG2B (DL,DB,DR,DD)
C  Transformation from IAU 1958 galactic coordinates to
C  B1950.0 'FK4' equatorial coordinates
      DOUBLE PRECISION DL,DB,DR,DD,DCIRC,DCIRC1
      DOUBLE PRECISION V1(3),V2(3),R,D,RE,DE
C  L2,B2 system of galactic coordinates
C  P = 192.25       RA of galactic north pole (mean B1950.0)
C  Q =  62.6        inclination of galactic to mean B1950.0 equator
C  R =  33          longitude of ascending node
C  P,Q,R are degrees
C  Equatorial to galactic rotation matrix
C  the Eulerian angles are P, Q, 90-R
C         +CP.CQ.SR-SP.CR     +SP.CQ.SR+CP.CR     -SQ.SR
C         -CP.CQ.CR-SP.SR     -SP.CQ.CR+CP.SR     +SQ.CR
C         +CP.SQ              +SP.SQ              +CQ
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.066988739415D0,-0.872755765852D0,-0.483538914632,
     : +0.492728466075D0,-0.450346958020D0,+0.744584633283,
     : -0.867600811151D0,-0.188374601723D0,+0.460199784784/
C  Spherical to Cartesian
      CALL DUNITLL(DL,DB,V1)
C  Rotate to mean B1950.0
      CALL DPREX(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,R,D)
C  Introduce E-terms
      CALL ADDETRMS(R,D,1950D0,re,de) 
C  Express in conventional ranges
      DR=DCIRC(RE)
      DD=DCIRC1(DE)
      END

      SUBROUTINE CDG2S (DL,DB,DSL,DSB)
C  Transformation from IAU 1958 galactic coordinates to
C  de Vaucouleurs supergalactic coordinates
C  Given:
C     DL,DB       dp       galactic longitude and latitude L2,B2
C  Returned:
C     DSL,DSB     dp       supergalactic longitude and latitude
C  References:
C     de Vaucouleurs, de Vaucouleurs, & Corwin, Second Reference
C     Catalogue of Bright Galaxies, U. Texas, page 8.
C     Systems & Applied Sciences Corp., Documentation for the
C     machine-readable version of the above catalogue,
C     Contract NAS 5-26490.
C    (These two references give different values for the galactic
C     longitude of the supergalactic origin.  Both are wrong;  the
C     correct value is L2=137.37.)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DL,DB,DSL,DSB
      DOUBLE PRECISION V1(3),V2(3)
C  System of supergalactic coordinates:
C    SGL   SGB        L2     B2      (deg)
C     -    +90      47.37  +6.32
C     0     0         -      0
C  Galactic to supergalactic rotation matrix:
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.735742574804D0,+0.677261296414D0,+0.000000000000D0,
     : -0.074553778365D0,-0.080991471307D0,+0.993922590400D0,
     : +0.673145302109D0,+0.731271165817D0,+0.110081262225D0/
C  Spherical to Cartesian
      CALL DUNITLL(DL,DB,V1)
C  Galactic to supergalactic
      CALL DPOSTX(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,DSL,DSB)
      END
C ----------------------------------------------------------

C
      SUBROUTINE CDS2G (DSL,DSB,DL,DB)
C  Transformation from de Vaucouleurs supergalactic coordinates
C  to IAU 1958 galactic coordinates
C  Given:
C     DSL,DSB     dp       supergalactic longitude and latitude
C  Returned:
C     DL,DB       dp       galactic longitude and latitude L2,B2
C  References:
C     de Vaucouleurs, de Vaucouleurs, & Corwin, Second Reference
C     Catalogue of Bright Galaxies, U. Texas, page 8.
C     Systems & Applied Sciences Corp., Documentation for the
C     machine-readable version of the above catalogue,
C     Contract NAS 5-26490.
C    (These two references give different values for the galactic
C     longitude of the supergalactic origin.  Both are wrong;  the
C     correct value is L2=137.37.)
C  P.T.Wallace   Starlink   March 1986
      DOUBLE PRECISION DSL,DSB,DL,DB
      DOUBLE PRECISION V1(3),V2(3)
C  System of supergalactic coordinates:
C    SGL   SGB        L2     B2      (deg)
C     -    +90      47.37  +6.32
C     0     0         -      0
C  Galactic to supergalactic rotation matrix:
      DOUBLE PRECISION RMAT(3,3)
      DATA RMAT(1,1),RMAT(1,2),RMAT(1,3),
     :     RMAT(2,1),RMAT(2,2),RMAT(2,3),
     :     RMAT(3,1),RMAT(3,2),RMAT(3,3)/
     : -0.735742574804D0,+0.677261296414D0,+0.000000000000D0,
     : -0.074553778365D0,-0.080991471307D0,+0.993922590400D0,
     : +0.673145302109D0,+0.731271165817D0,+0.110081262225D0/
C  Spherical to Cartesian
      CALL DUNITLL(DSL,DSB,V1)
C  Supergalactic to galactic
      CALL Dprex(RMAT,V1,V2)
C  Cartesian to spherical
      CALL DPOLARLL(V2,DL,DB)
      END
C ----------------------------------------------------------







