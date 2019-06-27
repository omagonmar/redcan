C ******************************************************
C **                 -- ARITH --                      **
C **                                                  **
C ******************************************************
C
C Jonathan McDowell
C JCMLIB V3.0    	Last modified 1988 Mar 1
c 			Last modified 1989 May 10
C -----------------------------------------------------------

C>[1]	SUBROUTINE IRMOD (I,J,K,R)
      SUBROUTINE IRMOD (I,J,K,R)
C Arithmetic modulo R, returns integer division and remainder
c  Input                                                     
      INTEGER I		
c  Divisor                                                   
      INTEGER R		
c  [I/R]                                                     
      INTEGER J		
c  I-[I/R] = I (mod R)                                       
      INTEGER K		
C
      K=I
      J=I/R
      K=K-R*J
      END
C ------------------------------------------------------
C>[2]	SUBROUTINE RRMOD (X,I,Y,R)
      SUBROUTINE RRMOD (X,I,Y,R)
C Real arithmetic modulo R
c  Input                                                       
      REAL X			
c  Divisor                                                     
      REAL R			
c  [X/R]                                                     
      INTEGER I		
c  X-[X/R]= X (mod R)                                          
      REAL Y			
C
      I=INT(X/R)
      Y=X-R*I
      END
C --------------------------------------------------------
C>[3]	SUBROUTINE DRMOD (X,I,Y,R)
      SUBROUTINE DRMOD (X,I,Y,R)
C Real arithmetic modulo R
c  Input                                                      
      DOUBLE PRECISION X		
c  Divisor                                                    
      DOUBLE PRECISION R		
c  [X/R]                                                     
      INTEGER I		
c  X-[X/R]= X (mod R)                                         
      DOUBLE PRECISION Y		
C
      I=INT(X/R)
      Y=X-R*I
      END
C --------------------------------------------------------
C>[4]	INTEGER FUNCTION INTUP (X)
      INTEGER FUNCTION INTUP (X)
C ROUNDS UP REAL TO NEXT INTEGER
      REAL X
C
      INTUP=INT (X)
      IF (FLOAT(INTUP).NE.X) INTUP=INTUP+1
      END
C
C---------------------------------------------------------
C>[5]	SUBROUTINE FRAC (R,I,X)
      SUBROUTINE FRAC (R,I,X)
C Split number into integer and fractional part
c> 	Rev 1 Last modified 1989 May 10
c  Input no                                                     
      REAL R		
c  integer part of R                                          
      INTEGER I	
c  Fractional part of R                                         
      REAL X		
C
      I=INT(R)
      X=R-FLOAT(I)
      if (x.lt.0.0) then
       x=x+1
       i=i-1
      endif
      END
C --------------------------------------------------------
C>[6]	SUBROUTINE DFRAC (R,I,X)
      SUBROUTINE DFRAC (R,I,X)
C Split number into integer and fractional part
c  Input no                                                    
      DOUBLE PRECISION R	
c> 	Rev 1 Last modified 1989 May 10
c  integer part of R                                          
      INTEGER I	
c  Fractional part of R                                        
      DOUBLE PRECISION X	
C
      I=INT(R)
      X=R-DFLOAT(I)
      if (x.lt.0.d0) then
       x=x+1
       i=i-1
      endif
      END

C---------------------------------------------------------
C>[7]	SUBROUTINE SEXIN (R,S,ID,IM,Y)
      SUBROUTINE SEXIN (R,S,ID,IM,Y)
C Split number into sexagesimal fields
c  Input no   (real)                                        
      REAL R		
C Output Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      REAL Y
C
C
      IF (R.LT.0.0) THEN
       Y=-R
       S='-'
      ELSE
       Y=R
       S=' '
      ENDIF
      ID=INT(Y)
      Y=60.0*(Y-FLOAT(ID))
      IM=INT(Y)
      Y=60.0*(Y-FLOAT(IM))		
      END
C---------------------------------------------------------
C>[8]	SUBROUTINE SEXOUT (S,ID,IM,Y,R)
      SUBROUTINE SEXOUT (S,ID,IM,Y,R)
C Split number into sexagesimal fields
c  Output no                                                     
      REAL R		
C Input Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      REAL Y
C
C
      R=FLOAT(ID)+FLOAT(IM)/60.+Y/3600.
      IF (S.EQ.'-') R=-R
      END


C---------------------------------------------------------
C>[9]	SUBROUTINE DSEXIN (R,S,ID,IM,Y)
      SUBROUTINE DSEXIN (R,S,ID,IM,Y)
C Split number into sexagesimal fields
c  Input no                                                     
      DOUBLE PRECISION R		
C Output Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      DOUBLE PRECISION Y
C
C
      IF (R.LT.0.D0) THEN
       Y=-R
       S='-'
      ELSE
       Y=R
       S=' '
      ENDIF
      ID=INT(Y)
      Y=60.0D0*(Y-DFLOAT(ID))
      IM=INT(Y)
      Y=60.0D0*(Y-DFLOAT(IM))		
      END
C---------------------------------------------------------
C>[10]	SUBROUTINE DSEXOUT (S,ID,IM,Y,R)
      SUBROUTINE DSEXOUT (S,ID,IM,Y,R)
C Split number into sexagesimal fields
c  Output no                                                     
      DOUBLE PRECISION R		
C Input Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      DOUBLE PRECISION Y
C
C
      R=FLOAT(ID)+FLOAT(IM)/60.+Y/3600.
      IF (S.EQ.'-') R=-R
      END
C---------------------------------------------------------------
C>[11]	SUBROUTINE SEXFIN (R,S,ID,IM,Y)
      SUBROUTINE SEXFIN (R,S,ID,IM,Y)
C Split number into sexagesimal fields
c  Input no   (DDMMSS.SS)                                        
      REAL R		
C Output Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      REAL Y
C
C
      IF (R.LT.0.0) THEN
       Y=-R
       S='-'
      ELSE
       Y=R
       S=' '
      ENDIF
      CALL RRMOD (Y,ID,Y,10000.)
      CALL RRMOD (Y,IM,Y,100.)
      END
C---------------------------------------------------------
C>[12]	SUBROUTINE SEXFOUT (S,ID,IM,Y,R)
      SUBROUTINE SEXFOUT (S,ID,IM,Y,R)
C Split number into sexagesimal fields pasted together
c  Output no                                                     
      REAL R		
C Input Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      REAL Y
C
C
      R=FLOAT(ID)*10000.+FLOAT(IM)*100.+Y 
      IF (S.EQ.'-') R=-R
      END


C---------------------------------------------------------
C>[13]	SUBROUTINE DSEXFIN (R,S,ID,IM,Y)
      SUBROUTINE DSEXFIN (R,S,ID,IM,Y)
C Split number into sexagesimal fields
c  Input no                                                     
      DOUBLE PRECISION R		
C Output Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      DOUBLE PRECISION Y
C
C
      IF (R.LT.0.D0) THEN
       Y=-R
       S='-'
      ELSE
       Y=R
       S=' '
      ENDIF
      CALL DRMOD (Y,ID,Y,10000.D0)
      CALL DRMOD (Y,IM,Y,100.D0)
      END
C---------------------------------------------------------
C>[14]	SUBROUTINE DSEXFOUT (S,ID,IM,Y,R)
      SUBROUTINE DSEXFOUT (S,ID,IM,Y,R)
C Split number into sexagesimal fields
c  Output no                                                     
      DOUBLE PRECISION R		
C Input Sign, deg, min, s
      CHARACTER S
      INTEGER ID,IM
      DOUBLE PRECISION Y
C
C
      R=DBLE(ID)*10000.D0+DBLE(IM)*100.D0+Y
      IF (S.EQ.'-') R=-R
      END
C----------------------------------------------------------

C>[15]	REAL FUNCTION RADIN (X)
      REAL FUNCTION RADIN (X)
C Input:X, deg Output: Y,rad
      REAL X,RAD
      PARAMETER (RAD=0.017453292)
      RADIN=X*RAD
      end

C>[16]	REAL function RADOUT (X)
      REAL function RADOUT (X)
C Input X(rad), output Y (deg)
      REAL X,DEG
      PARAMETER (DEG=57.29577951)
      RADOUT=X*DEG
      END
C>[17]	DOUBLE PRECISION function  DRADIN (X)
      DOUBLE PRECISION function  DRADIN (X)
C Input:X, deg Output: Y,rad
      DOUBLE PRECISION X,RAD
      PARAMETER (RAD=0.017453292D0)
      DRADIN=X*RAD
      END
C>[18]	DOUBLE PRECISION FUNCTION DRADOUT (X)
      DOUBLE PRECISION FUNCTION DRADOUT (X)
C Input X(rad), output Y (deg)
      DOUBLE PRECISION X,DEG
      PARAMETER (DEG=57.29577951D0)
      DRADOUT=X*DEG
      END

C *****************************************
C **            JCM SLALIB               **
C *****************************************
C STARLINK SLALIB software 
C modified by Jonathan McDowell Nov 1987
C
C----------------------------------------------------------------
C----------------------------------------------------------------
C

C>[19]  DOUBLE PRECISION FUNCTION dcirc1r (ANGLE)
      DOUBLE PRECISION FUNCTION dcirc1r (ANGLE)
C  Normalise angle into range +/- pi  (DOUBLE PRECISION)
C  Given:
C     ANGLE     dp      the angle in radians
C  The result is ANGLE expressed in the +/- pi (double
C  precision).
C  P.T.Wallace   Starlink   December 1984
      	DOUBLE PRECISION ANGLE
      DOUBLE PRECISION DPI,D2PI
      PARAMETER (DPI=3.141592653589793238462643D0)
      PARAMETER (D2PI=6.283185307179586476925287D0)
      dcirc1r=MOD(ANGLE,D2PI)
      IF (ABS(dcirc1r).GE.DPI)
     :          dcirc1r=dcirc1r-SIGN(D2PI,ANGLE)

      END
C----------------------------------------------------------------
C
C>[20]	DOUBLE PRECISION FUNCTION dcircr (ANGLE)
      DOUBLE PRECISION FUNCTION dcircr (ANGLE)
C  Normalise angle into range 0-2 pi  (DOUBLE PRECISION)
C  Given:
C     ANGLE     dp      the angle in radians
C  The result is ANGLE expressed in the range 0-2 pi (double
C  precision).
      	DOUBLE PRECISION ANGLE
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925287D0)
      dcircr=MOD(ANGLE,D2PI)
      IF (dcircr.LT.0D0) dcircr=dcircr+D2PI
      END
C----------------------------------------------------------------
C ----------------------------------------------------------
C
C>[21]	REAL FUNCTION circ1r (ANGLE)
      REAL FUNCTION circ1r (ANGLE)
C  Normalise angle into range +/- pi  (single precision)
C  Given:
C     ANGLE     dp      the angle in radians
C  The result is ANGLE expressed in the +/- pi (single
C  precision).
C  P.T.Wallace   Starlink   December 1984
            REAL ANGLE
      REAL API,A2PI
      PARAMETER (API=3.141592653589793238462643)
      PARAMETER (A2PI=6.283185307179586476925287)
      circ1r=MOD(ANGLE,A2PI)
      IF (ABS(circ1r).GE.API)
     :          circ1r=circ1r-SIGN(A2PI,ANGLE)
      END
C ----------------------------------------------------------
C
C>[22]	REAL FUNCTION circr (ANGLE)
      REAL FUNCTION circr (ANGLE)
C  Normalise angle into range 0-2 pi  (single precision)
C  Given:
C     ANGLE     dp      the angle in radians
C  The result is ANGLE expressed in the range 0-2 pi (single
C  precision).
C  P.T.Wallace   Starlink   December 1984
            REAL ANGLE
      REAL A2PI
      PARAMETER (A2PI=6.283185307179586476925287)
      circr=MOD(ANGLE,A2PI)
      IF (circr.LT.0.0) circr=circr+A2PI
      END

C----------------------------------------------------------------
C
C>[23]	DOUBLE PRECISION FUNCTION dcirc1 (ANGLE)
      DOUBLE PRECISION FUNCTION dcirc1 (ANGLE)
C  Normalise angle into range +/- 180  (DOUBLE PRECISION)
C  Given:
C     ANGLE     dp      the angle in deg 
C  The result is ANGLE expressed in the +/- 180 (double
C  precision).
C  P.T.Wallace   Starlink   December 1984
     	DOUBLE PRECISION ANGLE
      DOUBLE PRECISION DPI,D2PI
      PARAMETER (DPI=180.d0)
      PARAMETER (D2PI=360.d0) 
      dcirc1=MOD(ANGLE,D2PI)
      IF (ABS(dcirc1).GE.DPI)
     :          dcirc1=dcirc1-SIGN(D2PI,ANGLE)

      END
C----------------------------------------------------------------
C
C>[24]	DOUBLE PRECISION FUNCTION dcirc (ANGLE)
      DOUBLE PRECISION FUNCTION dcirc (ANGLE)
C  Normalise angle into range 0-360 (DOUBLE PRECISION)
C  Given:
C     ANGLE     dp      the angle in deg 
C  The result is ANGLE expressed in the range 0-360. (double
C  precision).
      	DOUBLE PRECISION ANGLE
      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=360.d0) 
      dcirc=MOD(ANGLE,D2PI)
      IF (dcirc.LT.0D0) dcirc=dcirc+D2PI
      END
C----------------------------------------------------------------
C ----------------------------------------------------------
C
C>[25]	REAL FUNCTION circ1 (ANGLE)
      REAL FUNCTION circ1 (ANGLE)
C  Normalise angle into range +/- 180   (single precision)
C  Given:
C     ANGLE     dp      the angle in deg
C  The result is ANGLE expressed in the +/- 180 (single
C  precision).
C  P.T.Wallace   Starlink   December 1984
            REAL ANGLE
      REAL API,A2PI
      PARAMETER (API=180.0) 
      PARAMETER (A2PI=360.0) 
      circ1=MOD(ANGLE,A2PI)
      IF (ABS(circ1).GE.API)
     :          circ1=circ1-SIGN(A2PI,ANGLE)
      END
C ----------------------------------------------------------
C
C>[26]	REAL FUNCTION circ (ANGLE)
      REAL FUNCTION circ (ANGLE)
C  Normalise angle into range 0-360 single precision)
C  Given:
C     ANGLE     dp      the angle in deg 
C  The result is ANGLE expressed in the range 0-360 (single
C  precision).
C  P.T.Wallace   Starlink   December 1984
            REAL ANGLE
      REAL A2PI
      PARAMETER (A2PI=360.0) 
      circ=MOD(ANGLE,A2PI)
      IF (circ.LT.0.0) circ=circ+A2PI
      END


C>[27]	subroutine round (x,y,sig)
      subroutine round (x,y,sig)
      real x,y
      integer k,tol,sig,j
      real a,b
      tol=sig-1
      a=alog10(x)
      k=a
      if (a.lt.0.0) k=k-1
      b=a-k+tol
      a=10.**b
      j=a
      if (a-j.ge.0.5) j=j+1
      y=j*10.0**(k-tol)
      end
      

C-----------------------------------------------------
C>[28]	logical function qrlap (x1,x2,y1,y2,u1,u2)
      logical function qrlap (x1,x2,y1,y2,u1,u2)
C 1-D window
C Returns (u1,u2) as the overlap of (x1,x2) and (y1,y2)
C True if this overlap is nonzero.

      REAL x1,x2,y1,y2,u1,u2
      logical q

      q=.true.
C Check left end
      if (x1.lt.y1) then
C Left end of x left of y
C   x1...y1...x2...y2
C        |----|
       u1=y1
      elseif (x1.gt.y2) then
C Left end of x beyond right end of y
C   y1...y2   x1...x2
C        ||
       u1=y2
       q=.false.
      else
C Left end of x within y range
C   y1...x1...y2...x2
C        |----|
       u1=x1
      endif

C Check right end
      if (x2.gt.y2) then
C Right end of x beyond y
       u2=y2
      elseif(x2.lt.y1) then
C Right end of x to left of y; no overlap
       u2=y1
       q=.false.
      else
C Right end of x within y
       u2=x2
      endif
      qrlap=q
      end
C----------------------------------------------------------------------
C-----------------------------------------------------
C>[29]	logical function qdrlap (x1,x2,y1,y2,u1,u2)
      logical function qdrlap (x1,x2,y1,y2,u1,u2)
C 1-D window
C Returns (u1,u2) as the overlap of (x1,x2) and (y1,y2)
C True if this overlap is nonzero.

      DOUBLE PRECISION x1,x2,y1,y2,u1,u2
      logical q

      q=.true.
C Check left end
      if (x1.lt.y1) then
C Left end of x left of y
C   x1...y1...x2...y2
C        |----|
       u1=y1
      elseif (x1.gt.y2) then
C Left end of x beyond right end of y
C   y1...y2   x1...x2
C        ||
       u1=y2
       q=.false.
      else
C Left end of x within y range
C   y1...x1...y2...x2
C        |----|
       u1=x1
      endif

C Check right end
      if (x2.gt.y2) then
C Right end of x beyond y
       u2=y2
      elseif(x2.lt.y1) then
C Right end of x to left of y; no overlap
       u2=y1
       q=.false.
      else
C Right end of x within y
       u2=x2
      endif
      qdrlap=q
      end
C----------------------------------------------------------------------

C>[30]	logical function qclip (x,y,x1,x2,y1,y2)
      logical function qclip (x,y,x1,x2,y1,y2)
C General purpose 2D window routine: is (x,y) within (x1,x2)X(y1,y2)?
      real x,y,x1,y1,x2,y2
      qclip=x.ge.x1.and.x.le.x2.and.y.ge.y1.and.y.le.y2
      end

C>[31]	logical function qdclip (x,y,x1,x2,y1,y2)
      logical function qdclip (x,y,x1,x2,y1,y2)
C General purpose 2D window routine: is (x,y) within (x1,x2)X(y1,y2)?
      DOUBLE PRECISION x,y,x1,y1,x2,y2
      qdclip=x.ge.x1.and.x.le.x2.and.y.ge.y1.and.y.le.y2
      end

C>[32]	subroutine order (u1,u2)
      subroutine order (u1,u2)
      real u1,u2,ux
            if (u1.gt.u2) then
             ux=u1
             u1=u2
             u2=ux
            endif
      end
C>[33]	subroutine dorder (u1,u2)
      subroutine dorder (u1,u2)
      DOUBLE PRECISION u1,u2,ux
            if (u1.gt.u2) then
             ux=u1
             u1=u2
             u2=ux
            endif
      end


