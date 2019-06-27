C ****************************************************************
C **                     -- VECD --                           **
C **                                                            **
C ****************************************************************
C
C DOUBLE PRECISION 3-vector manipulating routines
C
C Jonathan McDowell
C
C JCMLIB V2.0 		Last modified 1987 Sep 28
C
C -----------------------------------------------------------------
      DOUBLE PRECISION FUNCTION DDOT (A,B)
C Cartesian product of two vectors
c  Input vectors                                       
      DOUBLE PRECISION A(3),B(3)	
C
      DDOT= A(1)*B(1)+A(2)*B(2)+A(3)*B(3)
      END
C ---------------------------------------------------------------
      DOUBLE PRECISION FUNCTION DNORM (A)
C Euclidean length of two vectors
      DOUBLE PRECISION A(3)
C
      DNORM= dSQRT (A(1)**2+A(2)**2+A(3)**2)
      END
C ---------------------------------------------------------------
      SUBROUTINE DCROSS (A,B,C)
C Vector cross product C = A x B
      DOUBLE PRECISION A(3),B(3),C(3)
C
      C(1)=A(2)*B(3)-A(3)*B(2)
      C(2)=A(3)*B(1)-A(1)*B(3)
      C(3)=A(1)*B(2)-A(2)*B(1)
      END
C ---------------------------------------------------------------
      SUBROUTINE DVEC (R,THETA,PHI,P)
C Spherical polars to Cartesians
c  3-vector                                                
      DOUBLE PRECISION P(3)		
c  Polar angle (deg)                                      
      DOUBLE PRECISION THETA		
c  Azimuthal angle (deg)                                    
      DOUBLE PRECISION PHI		
c  Radial coordinate	                                         
      DOUBLE PRECISION R		
C
      DOUBLE PRECISION dcosd,dsind
      P(1)=R*dCOSD(PHI)*dSIND(THETA)
      P(2)=R*dSIND(PHI)*dSIND(THETA)
      P(3)=R*dCOSD(THETA)
      END
C ---------------------------------------------------------------
      SUBROUTINE DPOLAR (P,R,THETA,PHI)
C Cartesians to spherical polars
c  3-vector                                                
      DOUBLE PRECISION P(3)		
c  Polar angle (deg)                                      
      DOUBLE PRECISION THETA		
c  Azimuthal angle (deg)                                    
      DOUBLE PRECISION PHI		
c  Radial coordinate	                                         
      DOUBLE PRECISION R		
C Functions
      DOUBLE PRECISION DNORM,DARGD,dacosd
C
      R=DNORM(P)
      IF (R.GT.0) THEN
       PHI=DARGD (P(1),P(2))
       THETA=DACOSD (P(3)/R)
      ELSE
       PHI=0.
       THETA=0.
      ENDIF
      END
c
      SUBROUTINE DPOLARLL (P,Long,Lat)
C Cartesians to spherical polars long and lat
c  3-vector                                                
      DOUBLE PRECISION P(3)		
c  Polar angle (deg)                                      
      DOUBLE PRECISION lat
      DOUBLE PRECISION THETA		
c  Azimuthal angle (deg)                                    
      DOUBLE PRECISION long		
c  Radial coordinate	                                         
      DOUBLE PRECISION R		
C Functions
      DOUBLE PRECISION dNORM,dARGD,dacosd
C
      R=dNORM(P)
      IF (R.GT.0.d0) THEN
       long=DARGD (P(1),P(2))
       THETA=DACOSD (P(3)/R)
      ELSE
       LONG=0.d0
       THETA=0.d0
      ENDIF
      lat=90.0d0-theta
      END
C------------------------------------------------------------
      subroutine DUNITLL (LONG,LAT,P)
      DOUBLE PRECISION P(3)
      DOUBLE PRECISION LONG,LAT,DCOSD,DSIND
      P(1)=DCOSD(LONG)*DCOSD(LAT)
      P(2)=DSIND(LONG)*DCOSD(LAT)
      P(3)=DSIND(LAT)
      END
C
      subroutine dpolarllr (p,long,lat)
      DOUBLE PRECISION p(3)
      DOUBLE PRECISION lat,long,DRADIN
      DOUBLE PRECISION x,y
      call dpolarll (p,x,y)
      LONG= dradin (x) 
      LAT= dradin (y)
      end
c
      subroutine dunitllr (long,lat,p)
      DOUBLE PRECISION p(3),lat,long,x,y,DRADOUT
      X=dradout (long)
      Y=dradout (lat)
      call dunitll (x,y,p)
      end

c
      subroutine dpolar6 (p,r,theta,phi,rrdot,tdot,phidot)
      DOUBLE PRECISION p(6),r,theta,phi,rrdot,tdot,phidot,rx
      call dpolar (p,r,theta,phi)
      if (r.gt.0) then
       rrdot=(p(1)*p(4)+p(2)*p(5)+p(3)*p(6))/r
       rx=dsqrt(p(1)**2+p(2)**2)
       if (rx.gt.0) then
        tdot= (p(3)*(p(1)*p(4)+p(2)*p(5))-p(6)*(rx**2))/(rx*r*r)
        phidot=(p(1)*p(4)-p(2)*p(5))/rx
       else
        tdot=0.
        phidot=0.
       endif
      else
       rrdot=0.
       tdot=0.
       phidot=0.
      endif
      end
c
      subroutine dvec6 (r,theta,phi,rrdot,tdot,phidot,p)
      DOUBLE PRECISION p(6),r,theta,phi,rrdot,tdot,phidot,dcosd,dsind
      DOUBLE PRECISION ca,sa,cb,sb,w
      call dvec (r,theta,phi,p)
      ca=dcosd(phi)
      sa=dsind(phi)
      cb=dcosd(theta)
      sb=dsind(theta)
      w=r*tdot*cb+rrdot*sb
      P(1)=R*dCOSD(PHI)*dSIND(THETA)
      P(2)=R*dSIND(PHI)*dSIND(THETA)
      P(3)=R*dCOSD(THETA)
      p(4)=-p(2)*phidot+w*ca
      p(5)=p(1)*phidot+w*sa
      p(6)=-r*tdot*sb+rrdot*cb
      end
c

      
C ---------------------------------------------------------------
      SUBROUTINE DPREX (AA,Y,X)
C Premultiply matrix AA by array Y, result in X
c  Vectors                                             
      DOUBLE PRECISION X(3),Y(3),X1	
c  Matrix                                               
      DOUBLE PRECISION AA(3,3)		
      INTEGER I,J
C
      DO I=1,3
       X1=0.
       DO J=1,3
        X1=X1+Y(J)*AA(J,I)
       ENDDO
       X(I)=X1
      ENDDO
      END
C ---------------------------------------------------------------
      SUBROUTINE DPOSTX (AA,Y,X)
C Postmultiply matrix AA by array Y, result in X
c  Vectors                                             
      DOUBLE PRECISION X(3),Y(3),X1	
c  Matrix                                               
      DOUBLE PRECISION AA(3,3)		
      INTEGER I,J
C
      DO I=1,3
       X1=0.
       DO J=1,3
        X1=X1+AA(I,J)*Y(J)
       ENDDO
       X(I)=X1
      ENDDO
      END
C ---------------------------------------------------
      SUBROUTINE DMMULT (A,B,C)
C Matrix multiply AB=C
      DOUBLE PRECISION A(3,3),B(3,3),C(3,3)
      INTEGER I,J,k
      DOUBLE PRECISION W
      DO I=1,3
       DO J=1,3
        W=0.0
        DO K=1,3
         W=W+A(I,K)*B(K,J)
        ENDDO
        C(I,J)=W
       ENDDO
      ENDDO
      END
C ---------------------------------------------------
      DOUBLE PRECISION FUNCTION DMAXMOD (R)
C Cubic norm = max(i) abs(R(i))
c  Vector                                                   
      DOUBLE PRECISION R(3)	
      DOUBLE PRECISION A,B
      INTEGER J
C
      A=0.
      DO J=1,3
       B=ABS(R(J))
       IF(B.GT.A)A=B
      ENDDO
      DMAXMOD=A
      END
C -------------------------------------------------------
      SUBROUTINE DVCOPY (P,R)
C Copy P to R
      DOUBLE PRECISION P(3),R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=P(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE DVZERO (R)
C Set R to zero
      DOUBLE PRECISION R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=0.D0
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE DVADD (P,R)
C  Add P to R ( Result: R=R+P)
      DOUBLE PRECISION P(3),R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=R(I)+P(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE DVCMULT (R,C)
C Scalar multiply of vector R by C
      DOUBLE PRECISION R(3)
      DOUBLE PRECISION C
      INTEGER I
C
      DO I=1,3
       R(I)=C*R(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE DVUNIT (R,R0)
C Make R a unit vector, return norm
      DOUBLE PRECISION R(3)
      DOUBLE PRECISION R0
      INTEGER I
      DOUBLE PRECISION DNORM
C
      R0=DNORM(R)
      IF (R0.EQ.0.D0)RETURN
      DO I=1,3
       R(I)=R(I)/R0
      ENDDO
      END
C --------------------------------------------------------
C ****************************************************************
C **                     -- VECR   --                           **
C **                                                            **
C ****************************************************************
C
C REAL 3-vector manipulating routines
C
C Jonathan McDowell
C
C JCMLIB V2.0 		Last modified 1987 Sep 28
C
C -----------------------------------------------------------------
      REAL FUNCTION RDOT (A,B)
C Cartesian product of two vectors
c  Input vectors                                       
      REAL A(3),B(3)	
C
      RDOT= A(1)*B(1)+A(2)*B(2)+A(3)*B(3)
      END
C ---------------------------------------------------------------
      REAL FUNCTION NORM (A)
C Euclidean length of two vectors
      REAL A(3)
C
      NORM= SQRT (A(1)**2+A(2)**2+A(3)**2)
      END
C ---------------------------------------------------------------
      SUBROUTINE CROSS (A,B,C)
C Vector cross product C = A x B
      REAL A(3),B(3),C(3)
C
      C(1)=A(2)*B(3)-A(3)*B(2)
      C(2)=A(3)*B(1)-A(1)*B(3)
      C(3)=A(1)*B(2)-A(2)*B(1)
      END
C ---------------------------------------------------------------
      SUBROUTINE VEC (R,THETA,PHI,P)
C Spherical polars to Cartesians
c  3-vector                                                
      REAL P(3)		
c  Polar angle (deg)                                      
      REAL THETA		
c  Azimuthal angle (deg)                                    
      REAL PHI		
c  Radial coordinate	                                         
      REAL R,cosd,sind		
C
      P(1)=R*COSD(PHI)*SIND(THETA)
      P(2)=R*SIND(PHI)*SIND(THETA)
      P(3)=R*COSD(THETA)
      END
C ---------------------------------------------------------------
      SUBROUTINE POLAR (P,R,THETA,PHI)
C Cartesians to spherical polars
c  3-vector                                                
      REAL P(3)		
c  Polar angle (deg)                                      
      REAL THETA		
c  Azimuthal angle (deg)                                    
      REAL PHI		
c  Radial coordinate	                                         
      REAL R		
C Functions
      REAL NORM,ARGD,acosd
C
      R=NORM(P)
      IF (R.GT.0) THEN
       PHI=ARGD (P(1),P(2))
       THETA=ACOSD (P(3)/R)
      ELSE
       PHI=0.
       THETA=0.
      ENDIF
      END
C
      SUBROUTINE POLARLL (P,Long,Lat)
C Cartesians to spherical polars long and lat
c  3-vector                                                
      REAL P(3)		
c  Polar angle (deg)                                      
      REAL lat
      REAL THETA		
c  Azimuthal angle (deg)                                    
      REAL long		
c  Radial coordinate	                                         
      REAL R		
C Functions
      REAL NORM,ARGD,acosd
C
      R=NORM(P)
      IF (R.GT.0) THEN
       long=ARGD (P(1),P(2))
       THETA=ACOSD (P(3)/R)
      ELSE
       long=0.
       THETA=0.
      ENDIF
      lat=90.0-theta
      END
C------------------------------------------------------------
      subroutine UNITLL (LONG,LAT,P)
      REAL P(3)
      REAL LONG,LAT,COSD,SIND
      P(1)=COSD(LONG)*COSD(LAT)
      P(2)=SIND(LONG)*COSD(LAT)
      P(3)=SIND(LAT)
      END
C
      subroutine polarllr (p,long,LAT)
      real p(3)
      real lat,long,RADIN
      real x,y
      call polarll (p,x,y)
      LONG= radin (x)
      LAT=radin (y)
      end
c
      subroutine unitllr (long,LAT,p)
      real p(3),lat,long,x,y,RADOUT
      X= radout (lONG)
      Y= radout (lAT)
      call unitll (x,y,p)
      end

c
      subroutine polar6 (p,r,theta,phi,rrdot,tdot,phidot)
      REAL p(6),r,theta,phi,rrdot,tdot,phidot,rx
      call polar (p,r,theta,phi)
      if (r.gt.0) then
       rrdot=(p(1)*p(4)+p(2)*p(5)+p(3)*p(6))/r
       rx=sqrt(p(1)**2+p(2)**2)
       if (rx.gt.0) then
        tdot= (p(3)*(p(1)*p(4)+p(2)*p(5))-p(6)*(rx**2))/(rx*r*r)
        phidot=(p(1)*p(4)-p(2)*p(5))/rx
       else
        tdot=0.
        phidot=0.
       endif
      else
       rrdot=0.
       tdot=0.
       phidot=0.
      endif
      end
c
      subroutine vec6 (r,theta,phi,rrdot,tdot,phidot,p)
      REAL p(6),r,theta,phi,rrdot,tdot,phidot,cosd,sind
      REAL ca,cb,sa,sb,w
      call vec (r,theta,phi,p)
      ca=cosd(phi)
      sa=sind(phi)
      cb=cosd(theta)
      sb=sind(theta)
      w=r*tdot*cb+rrdot*sb
      P(1)=R*COSD(PHI)*SIND(THETA)
      P(2)=R*SIND(PHI)*SIND(THETA)
      P(3)=R*COSD(THETA)
      p(4)=-p(2)*phidot+w*ca
      p(5)=p(1)*phidot+w*sa
      p(6)=-r*tdot*sb+rrdot*cb
      end
c

      
C ---------------------------------------------------------------
      SUBROUTINE PREX (AA,Y,X)
C Premultiply matrix AA by array Y, result in X
c  Vectors                                             
      REAL X(3),Y(3)	
c  Matrix                                               
      REAL AA(3,3),X1
      INTEGER I,J
C
      DO I=1,3
       X1=0.
       DO J=1,3
        X1=X1+Y(J)*AA(J,I)
       ENDDO
       X(I)=X1
      ENDDO
      END
C ---------------------------------------------------------------
      SUBROUTINE POSTX (AA,Y,X)
C Postmultiply matrix AA by array Y, result in X
c  Vectors                                             
      REAL X(3),Y(3)	
c  Matrix                                               
      REAL AA(3,3),X1
      INTEGER I,J
C
      DO I=1,3
       X1=0.
       DO J=1,3
        X1=X1+AA(I,J)*Y(J)
       ENDDO
       X(I)=X1
      ENDDO
      END
C ---------------------------------------------------
      SUBROUTINE MMULT (A,B,C)
C Matrix multiply AB=C
      REAL A(3,3),B(3,3),C(3,3)
      INTEGER I,J,K
      REAL W
      DO I=1,3
       DO J=1,3
        W=0.0
        DO K=1,3
         W=W+A(I,K)*B(K,J)
        ENDDO
        C(I,J)=W
       ENDDO
      ENDDO
      END
C ---------------------------------------------------
      
      REAL FUNCTION RMAXMOD (R)
C Cubic norm = max(i) abs(R(i))
c  Vector                                                   
      REAL R(3)	
      REAL A,B
      INTEGER J
C
      A=0.
      DO J=1,3
       B=ABS(R(J))
       IF(B.GT.A)A=B
      ENDDO
      RMAXMOD=A
      END
C -------------------------------------------------------
      SUBROUTINE VCOPY (P,R)
C Copy P to R
      REAL P(3),R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=P(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE VZERO (R)
C Set R to zero
      REAL R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=0.D0
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE VADD (P,R)
C  Add P to R ( Result: R=R+P)
      REAL P(3),R(3)
      INTEGER I
C
      DO I=1,3
       R(I)=R(I)+P(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE VCMULT (R,C)
C Scalar multiply of vector R by C
      REAL R(3)
      REAL C
      INTEGER I
C
      DO I=1,3
       R(I)=C*R(I)
      ENDDO
      END
C --------------------------------------------------------
      SUBROUTINE VUNIT (R,R0)
C Make R a unit vector, return norm
      REAL R(3)
      REAL R0
      INTEGER I
      REAL NORM
C
      R0=NORM(R)
      IF (R0.EQ.0.0)RETURN
      DO I=1,3
       R(I)=R(I)/R0
      ENDDO
      END
C --------------------------------------------------------
