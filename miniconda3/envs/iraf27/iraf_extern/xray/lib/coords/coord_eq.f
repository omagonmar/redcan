C ----------------------------------------------------------
C
      SUBROUTINE CDMB2J (R1950,D1950,DR1950,DD1950,P1950,V1950,
     :                      R2000,D2000,DR2000,DD2000,P2000,V2000)
C  Convert B1950.0 FK4 star data to J2000.0 FK5
C  This routine converts stars from the old, Bessel-Newcomb, FK4
C  system to the new, IAU 1976, FK5, Fricke system, using Yallop's
C  implementation (see ref 2) of a matrix method due to Standish.
C  The numerical values of ref 2 are used canonically.
C  Given:  (all B1950.0,FK4)
C     R1950,D1950     dp    B1950.0 RA,Dec (deg)
C     DR1950,DD1950   dp    B1950.0 proper motions (arcsec/trop.yr)
C     P1950           dp    parallax (arcsec)
C     V1950           dp    radial velocity (km/s, +ve = moving away)
C  Returned:  (all J2000.0,FK5)
C     R2000,D2000     dp    J2000.0 RA,Dec (rad)
C     DR2000,DD2000   dp    J2000.0 proper motions (arcsec/Jul.yr)
C     P2000           dp    parallax (arcsec)
C     V2000           dp    radial velocity (km/s, +ve = moving away)
C  Notes:
C     1)  The proper motions in RA are dRA/dt rather than
C         cos(Dec)*dRA/dt, and are per year rather than per century.
C     2)  Conversion from Besselian epoch 1950.0 to Julian epoch
C         2000.0 only is provided for.  Conversions involving other
C         epochs will require use of the appropriate precession,
C         proper motion, and E-terms routines before and/or
C         after FK425 is called.
C     3)  In the FK4 catalogue the proper motions of stars within
C         10 degrees of the poles do not embody the differential
C         E-term effect and should, strictly speaking, be handled
C         in a different manner from stars outside these regions.
C         However, given the general lack of homogeneity of the star
C         data available for routine astrometry, the difficulties of
C         handling positions that may have been determined from
C         astrometric fields spanning the polar and non-polar regions,
C         the likelihood that the differential E-terms effect was not
C         taken into account when allowing for proper motion in past
C         astrometry, and the undesirability of a discontinuity in
C         the algorithm, the decision has been made in this routine to
C         include the effect of differential E-terms on the proper
C         motions for all stars, whether polar or not.  At epoch 2000,
C         and measuring on the sky rather than in terms of dRA, the
C         errors resulting from this simplification are less than
C         1 milliarcsecond in position and 1 milliarcsecond per
C         century in proper motion.
C  References:
C     1  The transformation of astrometric catalog systems to the
C        equinox J2000.0.  Smith, C.A. et al, paper to be submitted
C        to the Astronomical Journal.  Draft dated 1987 August 26.
C     2  Transformation of mean star places from FK4 B1950.0 to
C        FK5 J2000.0 using matrices in 6-space.  Yallop, B.D. et al,
C        paper to be submitted to the Astronomical Journal.  Draft
C        dated 1987 October 8.
C  P.T.Wallace   Starlink   27 October 1987
C Modified by JCM to change input units May 1988
      DOUBLE PRECISION R1950,D1950,DR1950,DD1950,P1950,V1950
      DOUBLE PRECISION R2000,D2000,DR2000,DD2000,P2000,V2000
      DOUBLE PRECISION R,D,UR,UD,PX,RV,SR,CR,SD,CD,W,WD
      	DOUBLE PRECISION X,Y,Z,XD,YD,ZD
      	DOUBLE PRECISION RXYSQ,RXYZSQ,RXY,RXYZ,SPXY,SPXYZ
      	INTEGER I,J
C  Star position and velocity vectors
      	DOUBLE PRECISION R0(3),RD0(3)
C  Combined position and velocity vectors
      	DOUBLE PRECISION V1(6),V2(6)
      	DOUBLE PRECISION D2PI
      	PARAMETER (D2PI=6.283185307179586476925287D0)
C  Small number to avoid arithmetic problems
      	DOUBLE PRECISION TINY
      	PARAMETER (TINY=1D-30)
C  CANONICAL CONSTANTS  (see references)
C  Km per sec to AU per tropical century
C  = 86400 * 36524.2198782 / 1.49597870E8
      	DOUBLE PRECISION VF
      	PARAMETER (VF=21.0945D0)
C JCMLIB functions
      DOUBLE PRECISION DRADIN,DRADOUT,DDOT
C  Constant vector and matrix (by columns)
      	DOUBLE PRECISION A(3),AD(3),EM(6,6)
      	DATA A,AD/ -1.62557D-6,  -0.31919D-6, -0.13843D-6,
     :           +1.245D-3,    -1.580D-3,   -0.659D-3/
      DATA (EM(I,1),I=1,6) / +0.999925678186902D0,
     :                       +0.011182059571766D0,
     :                       +0.004857946721186D0,
     :                       -0.000541652366951D0,
     :                       +0.237917612131583D0,
     :                       -0.436111276039270D0 /

      DATA (EM(I,2),I=1,6) / -0.011182059642247D0,
     :                       +0.999937478448132D0,
     :                       -0.000027147426498D0,
     :                       -0.237968129744288D0,
     :                       -0.002660763319071D0,
     :                       +0.012259092261564D0 /

      DATA (EM(I,3),I=1,6) / -0.004857946558960D0,
     :                       -0.000027176441185D0,
     :                       +0.999988199738770D0,
     :                       +0.436227555856097D0,
     :                       -0.008537771074048D0,
     :                       +0.002119110818172D0 /

      DATA (EM(I,4),I=1,6) / +0.000002423950176D0,
     :                       +0.000000027106627D0,
     :                       +0.000000011776559D0,
     :                       +0.999947035154614D0,
     :                       +0.011182506007242D0,
     :                       +0.004857669948650D0 /

      DATA (EM(I,5),I=1,6) / -0.000000027106627D0,
     :                       +0.000002423978783D0,
     :                       -0.000000000065816D0,
     :                       -0.011182506121805D0,
     :                       +0.999958833818833D0,
     :                       -0.000027137309539D0 /

      DATA (EM(I,6),I=1,6) / -0.000000011776558D0,
     :                       -0.000000000065874D0,
     :                       +0.000002424101735D0,
     :                       -0.004857669684959D0,
     :                       -0.000027184471371D0,
     :                       +1.000009560363559D0 /
C----------------------------
C  Pick up B1950 data (units radians and arcsec/TC)
      	R=dradin(R1950)
      	D=dradin(D1950)
      	UR=DR1950*100.
      	UD=DD1950*100.
      	PX=P1950
      	RV=V1950
C  Spherical to Cartesian
      	SR=SIN(R)
      	CR=COS(R)
      	SD=SIN(D)
      	CD=COS(D)
      	R0(1)=CR*CD
      	R0(2)=SR*CD
      	R0(3)=   SD
      	W=VF*RV*PX
      	RD0(1)=-SR*CD*UR-CR*SD*UD+W*R0(1)
      	RD0(2)= CR*CD*UR-SR*SD*UD+W*R0(2)
      	RD0(3)=             CD*UD+W*R0(3)
C  Allow for e-terms and express as position+velocity 6-vector
      	W=DDOT(R0,A)
      	WD=DDOT(R0,AD)
      	DO I=1,3
         V1(I)=R0(I)-A(I)+W*R0(I)
         V1(I+3)=RD0(I)-AD(I)+WD*R0(I)
      	END DO
C  Convert position+velocity vector to Fricke system
      	DO I=1,6
         W=0D0
         DO J=1,6
            W=W+EM(I,J)*V1(J)
         END DO
         V2(I)=W
      	END DO
C  Revert to spherical coordinates
      	X=V2(1)
      	Y=V2(2)
      	Z=V2(3)
      	XD=V2(4)
      	YD=V2(5)
      	ZD=V2(6)
      	RXYSQ=X*X+Y*Y
      	RXYZSQ=RXYSQ+Z*Z
      	RXY=SQRT(RXYSQ)
      	RXYZ=SQRT(RXYZSQ)
      	SPXY=X*XD+Y*YD
      	SPXYZ=SPXY+Z*ZD
      	IF (X.EQ.0D0.AND.Y.EQ.0D0) THEN
         R=0D0
      	ELSE
         R=ATAN2(Y,X)
         IF (R.LT.0.0D0) R=R+D2PI
      	END IF
      	D=ATAN2(Z,RXY)
      	IF (RXY.GT.TINY) THEN
         UR=(X*YD-Y*XD)/RXYSQ
         UD=(ZD*RXYSQ-Z*SPXY)/(RXYZSQ*RXY)
      	END IF
      	IF (PX.GT.TINY) THEN
         RV=SPXYZ/(PX*RXYZ*VF)
         PX=PX/RXYZ
      	END IF
C  Return results
      	R2000=dradout(R)
      	D2000=dradout(D)
      	DR2000=UR/100.
      	DD2000=UD/100.
      	V2000=RV
      	P2000=PX
      	END
C ----------------------------------------------------------
C
      SUBROUTINE CDMJ2B (R2000,D2000,DR2000,DD2000,P2000,V2000,
     :                      R1950,D1950,DR1950,DD1950,P1950,V1950)

C  Convert J2000.0 FK5 star data to B1950.0 FK4
C  (DOUBLE PRECISION)
C  This routine converts stars from the new, IAU 1976, FK5, Fricke
C  system, to the old, Bessel-Newcomb, FK4 system, using Yallop's
C  implementation (see ref 2) of a matrix method due to Standish.
C  The numerical values of ref 2 are used canonically.
C  Given:  (all J2000.0,FK5)
C     R2000,D2000     dp    J2000.0 RA,Dec (deg)
C     DR2000,DD2000   dp    J2000.0 proper motions (arcsec/Jul.yr)
C     P2000           dp    parallax (arcsec)
C     V2000           dp    radial velocity (km/s, +ve = moving away)
C  Returned:  (all B1950.0,FK4)
C     R1950,D1950     dp    B1950.0 RA,Dec (deg)
C     DR1950,DD1950   dp    B1950.0 proper motions (arcsec/trop.yr)
C     P1950           dp    parallax (arcsec)
C     V1950           dp    radial velocity (km/s, +ve = moving away)
C  Notes:
C     1)  The proper motions in RA are dRA/dt rather than
C         cos(Dec)*dRA/dt, and are per year rather than per century.
C     2)  Note that conversion from Julian epoch 2000.0 to Besselian
C         epoch 1950.0 only is provided for.  Conversions involving
C         other epochs will require use of the appropriate precession,
C         proper motion, and E-terms routines before and/or after
C         FK524 is called.
C     3)  In the FK4 catalogue the proper motions of stars within
C         10 degrees of the poles do not embody the differential
C         E-term effect and should, strictly speaking, be handled
C         in a different manner from stars outside these regions.
C         However, given the general lack of homogeneity of the star
C         data available for routine astrometry, the difficulties of
C         handling positions that may have been determined from
C         astrometric fields spanning the polar and non-polar regions,
C         the likelihood that the differential E-terms effect was not
C         taken into account when allowing for proper motion in past
C         astrometry, and the undesirability of a discontinuity in
C         the algorithm, the decision has been made in this routine to
C         include the effect of differential E-terms on the proper
C         motions for all stars, whether polar or not.  At epoch 2000,
C         and measuring on the sky rather than in terms of dRA, the
C         errors resulting from this simplification are less than
C         1 milliarcsecond in position and 1 milliarcsecond per
C         century in proper motion.
C
C  References:
C
C     1  The transformation of astrometric catalog systems to the
C        equinox J2000.0.  Smith, C.A. et al, paper to be submitted
C        to the Astronomical Journal.  Draft dated 1987 August 26.
C     2  Transformation of mean star places from FK4 B1950.0 to
C        FK5 J2000.0 using matrices in 6-space.  Yallop, B.D. et al,
C        paper to be submitted to the Astronomical Journal.  Draft
C        dated 1987 October 8.
            DOUBLE PRECISION R2000,D2000,DR2000,DD2000,P2000,V2000,
     :                 R1950,D1950,DR1950,DD1950,P1950,V1950
C  Miscellaneous
      DOUBLE PRECISION R,D,UR,UD,PX,RV
      DOUBLE PRECISION SR,CR,SD,CD,X,Y,Z,W
      DOUBLE PRECISION V1(6),V2(6)
      DOUBLE PRECISION XD,YD,ZD
      DOUBLE PRECISION RXYZ,RXYSQ,RXY
      INTEGER I,J
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)
C  Small number to avoid arithmetic problems
      DOUBLE PRECISION TINY
      PARAMETER (TINY=1D-30)
C  CANONICAL CONSTANTS  (see references)
C  Km per sec to AU per tropical century
C  = 86400 * 36524.2198782 / 1.49597870E8
      DOUBLE PRECISION VF
      PARAMETER (VF=21.0945D0)
      DOUBLE PRECISION DRADIN,DRADOUT
C  Constant vector and matrix (by columns)
      DOUBLE PRECISION A(6),EMI(6,6)
      DATA A/ -1.62557D-6,  -0.31919D-6, -0.13843D-6,
     :        +1.245D-3,    -1.580D-3,   -0.659D-3/

      DATA (EMI(I,1),I=1,6) / +0.999925679499910D0,
     :                        -0.011181482788805D0,
     :                        -0.004859004008828D0,
     :                        -0.000541640798032D0,
     :                        -0.237963047085011D0,
     :                        +0.436218238658637D0 /

      DATA (EMI(I,2),I=1,6) / +0.011181482840782D0,
     :                        +0.999937484898031D0,
     :                        -0.000027155744957D0,
     :                        +0.237912530551179D0,
     :                        -0.002660706488970D0,
     :                        -0.008537588719453D0 /

      DATA (EMI(I,3),I=1,6) / +0.004859003889183D0,
     :                        -0.000027177143501D0,
     :                        +0.999988194601879D0,
     :                        -0.436101961325347D0,
     :                        +0.012258830424865D0,
     :                        +0.002119065556992D0 /

      DATA (EMI(I,4),I=1,6) / -0.000002423898405D0,
     :                        +0.000000027105439D0,
     :                        +0.000000011777422D0,
     :                        +0.999904322043106D0,
     :                        -0.011181451601069D0,
     :                        -0.004858519608686D0 /

      DATA (EMI(I,5),I=1,6) / -0.000000027105439D0,
     :                        -0.000002423927017D0,
     :                        +0.000000000065851D0,
     :                        +0.011181451608968D0,
     :                        +0.999916125340107D0,
     :                        -0.000027162614355D0 /

      DATA (EMI(I,6),I=1,6) / -0.000000011777422D0,
     :                        +0.000000000065846D0,
     :                        -0.000002424049954D0,
     :                        +0.004858519590501D0,
     :                        -0.000027165866691D0,
     :                        +0.999966838131419D0 /

C  The above values were obtained by inverting C.Hohenkerk's
C  forward matrix (private communication), which agrees with
C  the one given in reference 2 but which has one additional
C  decimal place.
C  Pick up J2000 data (units radians and arcsec/JC)
      R=DRADIN(R2000)
      D=DRADIN(D2000)
      UR=DR2000*100.D0
      UD=DD2000*100.D0
      PX=P2000
      RV=V2000
C  Spherical to Cartesian
      SR=SIN(R)
      CR=COS(R)
      SD=SIN(D)
      CD=COS(D)
      X=CR*CD
      Y=SR*CD
      Z=   SD
      W=VF*RV*PX
      V1(1)=X
      V1(2)=Y
      V1(3)=Z
      V1(4)=-UR*Y-CR*SD*UD+W*X
      V1(5)= UR*X-SR*SD*UD+W*Y
      V1(6)=         CD*UD+W*Z
C  Convert position+velocity vector to BN system
      DO I=1,6
         W=0D0
         DO J=1,6
            W=W+EMI(I,J)*V1(J)
         END DO
         V2(I)=W
      END DO
C  Vector components
      X=V2(1)
      Y=V2(2)
      Z=V2(3)
      XD=V2(4)
      YD=V2(5)
      ZD=V2(6)

C  Magnitude of position vector
      RXYZ=SQRT(X*X+Y*Y+Z*Z)

C  Radial velocity and parallax
      IF (PX.GT.TINY) THEN
         RV=(X*XD+Y*YD+Z*ZD)/(PX*VF*RXYZ)
         PX=PX/RXYZ
      END IF
C  Include E-terms
      X=X+A(1)*RXYZ
      Y=Y+A(2)*RXYZ
      Z=Z+A(3)*RXYZ
      XD=XD+A(4)*RXYZ
      YD=YD+A(5)*RXYZ
      ZD=ZD+A(6)*RXYZ
C  Convert to spherical
      RXYSQ=X*X+Y*Y
      RXY=SQRT(RXYSQ)
      IF (X.EQ.0D0.AND.Y.EQ.0D0) THEN
         R=0D0
      ELSE
         R=ATAN2(Y,X)
         IF (R.LT.0.0D0) R=R+D2PI
      END IF
      D=ATAN2(Z,RXY)
      IF (RXY.GT.TINY) THEN
         UR=(X*YD-Y*XD)/RXYSQ
         UD=(ZD*RXYSQ-Z*(X*XD+Y*YD))/((RXYSQ+Z*Z)*RXY)
      END IF
C  Return results
      R1950=dradout(R)
      D1950=dradout(D)
      DR1950=UR/100.D0
      DD1950=UD/100.D0
      V1950=RV
      P1950=PX
      END
C ----------------------------------------------------------
      SUBROUTINE CDB2J (R1950,D1950,BEPOCH,R2000,D2000)
C  Convert B1950.0 FK4 star data to J2000.0 FK5 assuming zero
C  proper motion in an inertial frame.
C  (DOUBLE PRECISION)
C  This routine converts stars from the old, Bessel-Newcomb, FK4
C  system to the new, IAU 1976, FK5, Fricke system, in such a
C  way that the FK5 proper motion is zero.  Because such a star
C  has, in general, a non-zero proper motion in the FK4 system,
C  the routine requires the epoch at which the position in the
C  FK4 system was determined.
C  The method is from Appendix 2 of ref 1, but using the constants
C  of ref 2.
C  Given:
C     R1950,D1950     dp    B1950.0 FK4 RA,Dec at epoch (deg)
C     BEPOCH          dp    Besselian epoch (e.g. 1979.3D0)
C  Returned:
C     R2000,D2000     dp    J2000.0 FK5 RA,Dec (deg)
C  Notes:
C     1)  The epoch BEPOCH is strictly speaking Besselian, but
C         if a Julian epoch is supplied the result will be
C         affected only to a negligible extent.
C     2)  Conversion from Besselian epoch 1950.0 to Julian epoch
C         2000.0 only is provided for.  Conversions involving other
C         epochs will require use of the appropriate precession,
C         proper motion, and E-terms routines before and/or
C         after FK425 is called.
C     3)  In the FK4 catalogue the proper motions of stars within
C         10 degrees of the poles do not embody the differential
C         E-term effect and should, strictly speaking, be handled
C         in a different manner from stars outside these regions.
C         However, given the general lack of homogeneity of the star
C         data available for routine astrometry, the difficulties of
C         handling positions that may have been determined from
C         astrometric fields spanning the polar and non-polar regions,
C         the likelihood that the differential E-terms effect was not
C         taken into account when allowing for proper motion in past
C         astrometry, and the undesirability of a discontinuity in
C         the algorithm, the decision has been made in this routine to
C         include the effect of differential E-terms on the proper
C         motions for all stars, whether polar or not.  At epoch 2000,
C         and measuring on the sky rather than in terms of dRA, the
C         errors resulting from this simplification are less than
C         1 milliarcsecond in position and 1 milliarcsecond per
C         century in proper motion.
C
C  References:
C     1  Aoki,S., et al, 1983.  Astron.Astrophys., 128, 263.
C     2  The transformation of astrometric catalog systems to the
C        equinox J2000.0.  Smith, C.A. et al, paper to be submitted
C        to the Astronomical Journal.  Draft dated 1987 August 26.
C     3  Transformation of mean star places from FK4 B1950.0 to
C        FK5 J2000.0 using matrices in 6-space.  Yallop, B.D. et al,
C        paper to be submitted to the Astronomical Journal.  Draft
C        dated 1987 October 8.
C  P.T.Wallace   Starlink   27 October 1987
C Converted to JCMLIB May 1988
      	DOUBLE PRECISION R1950,D1950,BEPOCH,R2000,D2000
      	DOUBLE PRECISION D2PI
      	PARAMETER (D2PI=6.283185307179586476925287D0)
      	DOUBLE PRECISION W
      	INTEGER I,J
C  Radians per year to arcsec per century
      DOUBLE PRECISION PMF
        PARAMETER (PMF=3600D0*100D0*360D0/D2PI)
C  Position and position+velocity vectors
      	DOUBLE PRECISION R0(3),A1(3),V1(3),V2(6)
C  CANONICAL CONSTANTS  (see references)
C  Vectors A and Adot, and matrix M (only half of which is needed here)
      DOUBLE PRECISION A(3),AD(3),EM(6,3)
C  Functions
      	DOUBLE PRECISION CAL_JE,CALTBE,DDOT
      DATA A,AD/ -1.62557D-6,  -0.31919D-6, -0.13843D-6,
     :           +1.245D-3,    -1.580D-3,   -0.659D-3/

      DATA (EM(I,1),I=1,6) / +0.999925678186902D0,
     :                       +0.011182059571766D0,
     :                       +0.004857946721186D0,
     :                       -0.000541652366951D0,
     :                       +0.237917612131583D0,
     :                       -0.436111276039270D0 /

      DATA (EM(I,2),I=1,6) / -0.011182059642247D0,
     :                       +0.999937478448132D0,
     :                       -0.000027147426498D0,
     :                       -0.237968129744288D0,
     :                       -0.002660763319071D0,
     :                       +0.012259092261564D0 /

      DATA (EM(I,3),I=1,6) / -0.004857946558960D0,
     :                       -0.000027176441185D0,
     :                       +0.999988199738770D0,
     :                       +0.436227555856097D0,
     :                       -0.008537771074048D0,
     :                       +0.002119110818172D0 /
C  Spherical to Cartesian

        CALL dunitll(R1950,D1950,R0)

C  Adjust vector A to give zero proper motion in FK5
C  W is time since 1950 in century rad/arcsec
        W=(BEPOCH-1950D0)/PMF
      	DO I=1,3
         A1(I)=A(I)+W*AD(I)
      	END DO

C  Remove e-terms
      	W=DDOT(R0,A1)
      	DO I=1,3
         V1(I)=R0(I)-A1(I)+W*R0(I)
      	END DO

C  Convert position vector to Fricke system
      	DO I=1,6
         W=0D0
         DO J=1,3
            W=W+EM(I,J)*V1(J)
         END DO
         V2(I)=W
      	END DO

C  Allow for fictitious proper motion in FK4
      	W=(CAL_JE(CALTBE(BEPOCH))-2000D0)/PMF
      DO I=1,3
         V2(I)=V2(I)+W*V2(I+3)
       	END DO

C  Revert to spherical coordinates
      	CALL DPOLARLL (V2,R2000,D2000)
      	END
C ----------------------------------------------------------
C
      SUBROUTINE CDJ2B (R2000,D2000,BEPOCH,R1950,D1950)
C  Convert a J2000.0 FK5 star position to B1950.0 FK4 assuming
C  zero proper motion and parallax.
C  This routine converts star positions from the new, IAU 1976,
C  FK5, Fricke system to the old, Bessel-Newcomb, FK4 system.
C  Notes:
C     1) Conversion from Julian epoch 2000.0 to Besselian epoch 1950.0
C        only is provided for.  Conversions involving other epochs will
C        require use of the appropriate precession routines before and
C        after this routine is called.
C     2) Unlike in the sla_FK524 routine, the FK5 proper motions, the
C        parallax and the radial velocity are presumed zero.
C     3) It is the intention that FK5 should be a close approximation
C        to an inertial frame, so that distant objects have zero proper
C        motion;  such objects have (in general) non-zero proper motion
C      in FK4, BUT this routine does not return those fictitious proper
C        motions.
C     4) The position returned by this routine is in the B1950
C        reference frame but at Besselian epoch BEPOCH.  For
C        comparison with catalogues the BEPOCH argument will
C        frequently be 1950D0.
C  Given:
C     R2000,D2000     dp    J2000.0 FK5 RA,Dec (deg)
C     BEPOCH          dp    Besselian epoch (e.g. 1950D0)
C  Returned:
C     R1950,D1950     dp    B1950.0 FK4 RA,Dec (deg) at epoch BEPOCH
C  Ignored:
C     DR1950,DD1950   dp    B1950.0 FK4 proper motions (arcsec/trop.yr)
C  n.b.  The proper motion in RA is dRA/dt rather than cos(Dec)*dRA/dt.
C  P.T.Wallace   Starlink   30 July 1987
      DOUBLE PRECISION R2000,D2000,BEPOCH,R1950,D1950,DR1950,DD1950
      	DOUBLE PRECISION R,D,PX,RV
C  FK5 equinox J2000 (any epoch) to FK4 equinox B1950 epoch B1950
      	CALL CDMJ2B (R2000,D2000,0D0,0D0,0D0,0D0,
     :               R,D,DR1950,DD1950,PX,RV)
C  Fictitious proper motion to epoch BEPOCH
      	CALL DPMOT (R,D,DR1950,DD1950,1950D0,BEPOCH,
     :            R1950,D1950)
      	END

C
      SUBROUTINE DPMOT (R0,D0,PR1,PD1,EP0,EP1,R1,D1)
C  Apply corrections for proper motion to a star RA,Dec
C  References:
C     1984 Astronomical Almanac, pp B39-B41.
C     (also Lederle & Schwan, Astron. Astrophys. 134,
C      1-6, 1984)
C  Given:
C     R0,D0    dp     RA,Dec at epoch EP0 (deg)
C     PR,PD    dp     proper motions:  RA,Dec arcsec/ year of epoch
c PX and RV removed from algorithm
C     PX       dp     parallax (arcsec)
C     RV       dp     radial velocity (km/sec, +ve if receeding)
C     EP0      dp     start epoch in years (e.g Julian epoch)
C     EP1      dp     end epoch in years (same system as EP0)
C  Returned:
C     R1,D1    dp     RA,Dec at epoch EP1 (deg)
C  Notes:
C     1)  The proper motions in RA are dRA/dt rather than
C         cos(Dec)*dRA/dt, and are in the same coordinate
C         system as R0,D0.
C  P.T.Wallace   Starlink   June 1984
      	DOUBLE PRECISION R0,D0,PR,PD,EP0,EP1,R1,D1
      	INTEGER I
      	DOUBLE PRECISION DCOSD,DSIND
      	DOUBLE PRECISION EM(3),T,P(3)
      DOUBLE PRECISION DRADIN
      DOUBLE PRECISION PD1,PR1
C
      PD=DRADIN(PD1/3600.0D0)
      PR=DRADIN(PR1/3600.0D0)	
C  Spherical to Cartesian
      	CALL DUNITLL(R0,D0,P)
      	EM(1)=-PR*P(2)-PD*DCOSD(R0)*DSIND(D0)
      	EM(2)= PR*P(1)-PD*DSIND(R0)*DSIND(D0)
      	EM(3)=         PD*DCOSD(D0)        
C  Apply the motion
      	T=EP1-EP0
      	DO I=1,3
         P(I)=P(I)+T*EM(I)
      	END DO
C  Cartesian to spherical
      	CALL DPOLARLL(P,R1,D1)
      	END
C ----------------------------------------------------------
C
      SUBROUTINE CPRECB (BEP0,BEP1, RMATP)
C  Generate the matrix of precession between two epochs,
C  using the old, pre-IAU1976, Bessel-Newcomb model
C  Given:
C     BEP0    dp         beginning Besselian epoch
C     BEP1    dp         ending Besselian epoch
C  Returned:
C     RMATP  dp(3,3)    precession matrix
C  Reference:
C     Explanatory Supplement to the A.E., 1960, section
C      2B, p30.
C  The matrix is in the sense   V(BEP1)  =  RMATP * V(BEP0) .
C  P.T.Wallace   Starlink   July 1984
      DOUBLE PRECISION BEP0,BEP1,RMATP(3,3)
      DOUBLE PRECISION AS2R
      DOUBLE PRECISION T0,T
      DOUBLE PRECISION TAS2R
      DOUBLE PRECISION ZETA0,Z,THETA
      DOUBLE PRECISION SZE,CZE,SZ,CZ,STH,CTH,CTHSZ,CTHCZ
C  Arc seconds to radians
      PARAMETER (AS2R=0.4848136811095359949D-05)
C  Interval between basic epoch B1900.0 and beginning epoch,
C   in tropical centuries
      T0=(BEP0-1900D0)/100D0
C  Interval over which precession required, in tropical centuries
      T=(BEP1-BEP0)/100D0
C  Rotations (Euler angles)
      TAS2R=T*AS2R
      ZETA0=(2304.250D0+1.396*T0+(0.302D0+0.018D0*T)*T)*TAS2R
      Z=ZETA0+0.791D0*T*TAS2R
      THETA=(2004.682D0-0.853D0*T0+(-0.42665-0.042D0*T)*T)*TAS2R
C  Elements of rotation matrix
      SZE=SIN(ZETA0)
      CZE=COS(ZETA0)
      SZ=SIN(Z)
      CZ=COS(Z)
      STH=SIN(THETA)
      CTH=COS(THETA)
      CTHSZ=CTH*SZ
      CTHCZ=CTH*CZ
      RMATP(1,1)= CZE*CTHCZ - SZE*SZ
      RMATP(2,1)= CZE*CTHSZ + SZE*CZ
      RMATP(3,1)= CZE*STH
      RMATP(1,2)=-SZE*CTHCZ - CZE*SZ
      RMATP(2,2)=-SZE*CTHSZ + CZE*CZ
      RMATP(3,2)=-SZE*STH
      RMATP(1,3)=-STH*CZ
      RMATP(2,3)=-STH*SZ
      RMATP(3,3)= CTH
      END
C ----------------------------------------------------------
C
      SUBROUTINE CPRECJ (EP0,EP1, RMATP)
C  Form the matrix of precession between two epochs (IAU1976/FK5)
C
C  References:
C     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
C      equations (6) & (7), p283.
C     Kaplan,G.H., 1981. USNO circular no. 163, pA2.
C  Given:
C     EP0    dp         beginning epoch
C     EP1    dp         ending epoch
C  Returned:
C     RMATP  dp(3,3)    precession matrix
C  Notes:
C  1)  The epochs are TDB (loosely ET) Julian epochs.
C  2)  The matrix is in the sense   V(EP1)  =  RMATP * V(EP0) .
C  P.T.Wallace   Starlink   February 1984
      DOUBLE PRECISION EP0,EP1,RMATP(3,3)
      DOUBLE PRECISION AS2R
      DOUBLE PRECISION T0,T
      DOUBLE PRECISION TAS2R
      DOUBLE PRECISION W
      DOUBLE PRECISION ZETA,Z,THETA
      DOUBLE PRECISION SZE,CZE,SZ,CZ,STH,CTH,CTHSZ,CTHCZ
C  Arc seconds to radians
      PARAMETER (AS2R=0.4848136811095359949D-05)
C  Interval between basic epoch J2000.0 and beginning epoch (JC)
      T0=(EP0-2000D0)/100D0
C  Interval over which precession required (JC)
      T=(EP1-EP0)/100D0
C  Rotations (Euler angles)
      TAS2R=T*AS2R
      W=2306.2181D0+(1.39656D0-0.000139D0*T0)*T0
      ZETA=(W+((0.30188D0-0.000344D0*T0)+0.017998D0*T)*T)*TAS2R
      Z=(W+((1.09468D0+0.000066D0*T0)+0.018203D0*T)*T)*TAS2R
      THETA=((2004.3109D0+(-0.85330D0-0.000217D0*T0)*T0)
     :      +((-0.42665D0-0.000217D0*T0)-0.041833D0*T)*T)*TAS2R
C  Elements of rotation matrix
      SZE=SIN(ZETA)
      CZE=COS(ZETA)
      SZ=SIN(Z)
      CZ=COS(Z)
      STH=SIN(THETA)
      CTH=COS(THETA)
      CTHSZ=CTH*SZ
      CTHCZ=CTH*CZ
      RMATP(1,1)= CZE*CTHCZ - SZE*SZ
      RMATP(2,1)= CZE*CTHSZ + SZE*CZ
      RMATP(3,1)= CZE*STH
      RMATP(1,2)=-SZE*CTHCZ - CZE*SZ
      RMATP(2,2)=-SZE*CTHSZ + CZE*CZ
      RMATP(3,2)=-SZE*STH
      RMATP(1,3)=-STH*CZ
      RMATP(2,3)=-STH*SZ
      RMATP(3,3)= CTH
      END
C ----------------------------------------------------------
C
      SUBROUTINE CPRECM (RA,DC,PM)
C  Precession - either FK4 (Bessel-Newcomb, pre-IAU1976) or
C  FK5 (Fricke, post-IAU1976) as required.
C  Given:
C     RA,DC      dp     RA,Dec, mean equator & equinox of epoch EP0
C	PM		Precession matrix
C  Returned:
C     RA,DC      dp     RA,Dec, mean equator & equinox of epoch EP1
      DOUBLE PRECISION RA,DC
      DOUBLE PRECISION PM(3,3),V1(3),V2(3)
C     Convert RA,Dec to x,y,z
         CALL DUNITLL(RA,DC,V1)
C     Precess
         CALL DPOSTX(PM,V1,V2)
C     Back to RA,Dec
         CALL DPOLARLL(V2,RA,DC)
      END

C -------------------------------------------------------------
C
C HMNAO SLALIB routines
C modified by Jonathan McDowell Nov 1987, Mar 88
C
      SUBROUTINE ADDETRMS (RM,DM,EQ,RC,DC)
C
C  Add the E-terms (elliptic component of annual aberration)
C  to a pre IAU 1976 mean place to conform to the old
C  catalogue convention
C  (double precision)
C  Given:
C     RM,DM     dp     RA,Dec (degrees) without E-terms
C     EQ        dp     Besselian epoch of mean equator and equinox
C  Returned:
C     RC,DC     dp     RA,Dec (degrees) with E-terms included
C  Explanation:
C     Most star positions from pre-1984 optical catalogues (or
C     derived from astrometry using such stars) embody the
C     E-terms.  If it is necessary to convert a formal mean
C     place (for example a pulsar timing position) to one
C     consistent with such a star catalogue, then the RA,Dec
C     should be adjusted using this routine.
C  Reference:
C     Explanatory Supplement to the Astronomical Ephemeris,
C     section 2D, page 48.
C  P.T.Wallace   Starlink   July 1986
       DOUBLE PRECISION RM,DM,EQ,RC,DC
      DOUBLE PRECISION A(3),V(3)
C  E-terms vector
      CALL GETETRMS(EQ,A)
C  Spherical to Cartesian
      CALL DUNITLL (RM,DM,V)
C  Include the E-terms
      CALL DVADD(A,V)
C  Cartesian to spherical
      CALL DPOLARLL (V,RC,DC)
C  Bring RA into conventional range
      END

C ----------------------------------------------------------
C
      SUBROUTINE GETETRMS (EP,EV)
C  Compute the E-terms (elliptic component of annual aberration)
C  vector
C  (DOUBLE PRECISION)
C  Given:
C     EP      dp      Besselian epoch
C  Returned:
C     EV      dp(3)   E-terms as (dx,dy,dz)
C  References:
C     1  The transformation of astrometric catalog systems to the
C        equinox J2000.0.  Smith, C.A. et al, paper to be submitted
C        to the Astronomical Journal.  Draft dated 1987 August 26.
C     2  Transformation of mean star places from FK4 B1950.0 to
C        FK5 J2000.0 using matrices in 6-space.  Yallop, B.D. et al,
C        paper to be submitted to the Astronomical Journal.  Draft
C        dated 1987 October 8.
C  Note the use of the J2000 aberration constant (20.49552 arcsec).
C  This is a reflection of the fact that the E-terms embodied in
C  existing star catalogues were computed from a variety of
C  aberration constants.  Rather than adopting one of the old
C  constants the latest value is used here.
C  P.T.Wallace   Starlink   28 October 1987
            DOUBLE PRECISION EP,EV(3)
C  Arcseconds to degrees
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.4848136811095359949D-5)
      DOUBLE PRECISION T,E,E0,P,EK,CP
C  Julian centuries since B1950
      T=(EP-1950D0)*1.00002135903D-2
C  Eccentricity
      E=0.01673011D0-(0.00004193D0+0.000000126D0*T)*T
C  Mean obliquity
      E0=(84404.836D0-(46.8495D0+(0.00319D0+0.00181D0*T)*T)*T)*AS2R
C  Mean longitude of perihelion
      P=(1015489.951D0+(6190.67D0+(1.65D0+0.012D0*T)*T)*T)*AS2R
C  E-terms
      EK=E*20.49552D0*AS2R
      CP=COS(P)
      EV(1)= EK*SIN(P)
      EV(2)=-EK*CP*COS(E0)
      EV(3)=-EK*CP*SIN(E0)
      END
C ----------------------------------------------------------
C
      SUBROUTINE SUBETRMS (RC,DC,EQ,RM,DM)
C  Remove the E-terms (elliptic component of annual aberration)
C  from a pre IAU 1976 catalogue RA,Dec to give a mean place
C  (DOUBLE PRECISION)
C  Given:
C     RC,DC     dp     RA,Dec (degrees) with E-terms included
C     EQ        dp     Besselian epoch of mean equator and equinox
C  Returned:
C     RM,DM     dp     RA,Dec (degrees) without E-terms
C  Explanation:
C     Most star positions from pre-1984 optical catalogues (or
C     derived from astrometry using such stars) embody the
C     E-terms.  This routine converts such a position to a
C     formal mean place (allowing, for example, comparison with a
C     pulsar timing position).
C  Reference:
C     Explanatory Supplement to the Astronomical Ephemeris,
C     section 2D, page 48.
C  P.T.Wallace   Starlink   July 1986
            DOUBLE PRECISION RC,DC,EQ,RM,DM
      DOUBLE PRECISION DDOT
      DOUBLE PRECISION A(3),V(3),F
      INTEGER I
C  E-terms
      CALL GETETRMS(EQ,A)
C  Spherical to Cartesian
      CALL DUNITLL (RC,DC,V)
C  Include the E-terms
      F=1D0+DDOT(V,A)
      DO I=1,3
         V(I)=F*V(I)-A(I)
      END DO
C  Cartesian to spherical
      CALL DPOLARLL (V,RM,DM)
      END


