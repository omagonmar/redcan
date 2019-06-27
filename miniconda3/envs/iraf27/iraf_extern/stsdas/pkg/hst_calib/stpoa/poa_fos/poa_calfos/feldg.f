C
      SUBROUTINE FELDG(GLAT,GLON,ALT,BNORTH,BEAST,BDOWN,BABS)           
c  ------------------------------------------------------------------------
c  Part of "poa_calfos" (STECF/IPMG)
c  Part of "NEWBILCAL" program to produce IGRF geomagnetic model (GSFC)
c
c  History:
c  --------
c  Version   Date        Author          Description
c      1.0       Jul 00  M. Rosa         POA calibration code
c  ------------------------------------------------------------------------
C-------------------------------------------------------------------
C CALCULATES EARTH MAGNETIC FIELD FROM SPHERICAL HARMONICS MODEL
C REF: G. KLUGE, EUROPEAN SPACE OPERATIONS CENTRE, INTERNAL NOTE 61, 
C      1970.
C--------------------------------------------------------------------
C CHANGES (D. BILITZA, NOV 87):
C   - FIELD COEFFICIENTS IN BINARY DATA FILES INSTEAD OF BLOCK DATA
C   - CALCULATES DIPOL MOMENT
C--------------------------------------------------------------------
C  INPUT:  ENTRY POINT FELDG
C               GLAT  GEODETIC LATITUDE IN DEGREES (NORTH)
C               GLON  GEODETIC LONGITUDE IN DEGREES (EAST)
C               ALT   ALTITUDE IN KM ABOVE SEA LEVEL
C
C          ENTRY POINT FELDC
C              V(3)  CARTESIAN COORDINATES IN EARTH RADII (6371.2 KM)
C                     X-AXIS POINTING TO EQUATOR AT 0 LONGITUDE
C                     Y-AXIS POINTING TO EQUATOR AT 90 LONG.
C                     Z-AXIS POINTING TO NORTH POLE
C
C          COMMON BLANK AND ENTRY POINT FELDI ARE NEEDED WHEN USED
C            IN CONNECTION WITH L-CALCULATION PROGRAM SHELLG.
C       
C          COMMON /MODEL/ AND /GENER/
C              UMR     = ATAN(1.0)*4./180.   <DEGREE>*UMR=<RADIANT>
C              ERA       EARTH RADIUS FOR NORMALIZATION OF CARTESIAN 
C                     COORDINATES (6371.2 KM)
C              AQUAD, BQUAD   SQUARE OF MAJOR AND MINOR HALF AXIS FOR 
C                     EARTH ELLIPSOID AS RECOMMENDED BY INTERNATIONAL 
C                     ASTRONOMICAL UNION (6378.160, 6356.775 KM).
c comment (MRR): This is IAU 1964 (r=6378.160; 1/f=298.25)
C              NMAX    MAXIMUM ORDER OF SPHERICAL HARMONICS
C              TIME       YEAR (DECIMAL: 1973.5) FOR WHICH MAGNETIC 
C                     FIELD IS TO BE CALCULATED
C              G(M)       NORMALIZED FIELD COEFFICIENTS (SEE FELDCOF)
C                     M=NMAX*(NMAX+2)
C------------------------------------------------------------------------
C  OUTPUT: BABS   MAGNETIC FIELD STRENGTH IN GAUSS
C          BNORTH, BEAST, BDOWN   COMPONENTS OF THE FIELD WITH RESPECT
C                TO THE LOCAL GEODETIC COORDINATE SYSTEM, WITH AXIS
C                POINTING IN THE TANGENTIAL PLANE TO THE NORTH, EAST
C                AND DOWNWARD.   
C-----------------------------------------------------------------------

      INTEGER  NMAX,I,K,IH,IL,IS,IHMAX,LAST,M,IMAX  
      REAL*4   V(3),B(3)
      REAL*4   TIME
      REAL*4   G(144)
      REAL*4   f,x,y,z,s,t,bnorth,beast,bdown,babs
      REAL*4   glat,glon,alt,rlat,ct,st,d,rlon,cp,sp,rq
      real*4   bxxx,byyy,bzzz,brho,xxx,yyy,zzz,rho
      REAL*4   UMR,ERAD,AQUAD,BQUAD
      REAL*4   XI(3),H(144)
      CHARACTER*33        NAME
      
      COMMON /SHCOM/  XI,H
c ** MR ** changed Common to align on boundaries
c ** org **     COMMON/MODEL/       NAME,NMAX,TIME,G
      COMMON/MODEL/       TIME,G,NMAX,NAME
      COMMON/GENER/       UMR,ERAD,AQUAD,BQUAD
C
C-- IS RECORDS ENTRY POINT
C
C*****ENTRY POINT  FELDG  TO BE USED WITH GEODETIC CO-ORDINATES         
      IS=1                                                              
      RLAT=GLAT*UMR
      CT=SIN(RLAT)                                                      
      ST=COS(RLAT)                                                      
      D=SQRT(AQUAD-(AQUAD-BQUAD)*CT*CT)                                 
      RLON=GLON*UMR
      CP=COS(RLON)                                                      
      SP=SIN(RLON)                                                      
      ZZZ=(ALT+BQUAD/D)*CT/ERAD
      RHO=(ALT+AQUAD/D)*ST/ERAD
      XXX=RHO*CP                                                       
      YYY=RHO*SP                                                       
      GOTO10                                                            
      ENTRY FELDC(V,B)                                                  
C*****ENTRY POINT  FELDC  TO BE USED WITH CARTESIAN CO-ORDINATES        
      IS=2                                                              
      XXX=V(1)                                                          
      YYY=V(2)                                                          
      ZZZ=V(3)                                                          
10    RQ=1./(XXX*XXX+YYY*YYY+ZZZ*ZZZ) 
      XI(1)=XXX*RQ                                                      
      XI(2)=YYY*RQ                                                      
      XI(3)=ZZZ*RQ                                                      
      GOTO20                                                            
      ENTRY FELDI                                                       
C*****ENTRY POINT  FELDI  USED FOR L COMPUTATION                        
      IS=3                                                              
20    IHMAX=NMAX*NMAX+1                                                 
      LAST=IHMAX+NMAX+NMAX                                              
      IMAX=NMAX+NMAX-1                                                  
      DO 8 I=IHMAX,LAST                                                 
8     H(I)=G(I)                                                         
      DO 6 K=1,3,2                                                      
      I=IMAX                                                            
      IH=IHMAX                                                          
1     IL=IH-I                                                           
      F=2./FLOAT(I-K+2)                                                 
      X=XI(1)*F                                                         
      Y=XI(2)*F                                                         
      Z=XI(3)*(F+F)                                                     
      I=I-2                                                             
      IF(I-1)5,4,2                                                      
2     DO 3 M=3,I,2                                                      
      H(IL+M+1)=G(IL+M+1)+Z*H(IH+M+1)+X*(H(IH+M+3)-H(IH+M-1))           
     &                               -Y*(H(IH+M+2)+H(IH+M-2))           
3     H(IL+M)=G(IL+M)+Z*H(IH+M)+X*(H(IH+M+2)-H(IH+M-2))                 
     &                         +Y*(H(IH+M+3)+H(IH+M-1))                 
4     H(IL+2)=G(IL+2)+Z*H(IH+2)+X*H(IH+4)-Y*(H(IH+3)+H(IH))             
      H(IL+1)=G(IL+1)+Z*H(IH+1)+Y*H(IH+4)+X*(H(IH+3)-H(IH))             
5     H(IL)=G(IL)+Z*H(IH)+2.*(X*H(IH+1)+Y*H(IH+2))                      
      IH=IL                                                             
      IF(I.GE.K)GOTO1                                                   
6     CONTINUE                                                          
      IF(IS.EQ.3)RETURN                                                 
      S=.5*H(1)+2.*(H(2)*XI(3)+H(3)*XI(1)+H(4)*XI(2))                   
      T=(RQ+RQ)*SQRT(RQ)                                                
      BXXX=T*(H(3)-S*XXX)                                               
      BYYY=T*(H(4)-S*YYY)                                               
      BZZZ=T*(H(2)-S*ZZZ)                                               
      IF(IS.EQ.2)GOTO7                                                  
      BABS=SQRT(BXXX*BXXX+BYYY*BYYY+BZZZ*BZZZ)
      BEAST=BYYY*CP-BXXX*SP                                             
      BRHO=BYYY*SP+BXXX*CP                                              
      BNORTH=BZZZ*ST-BRHO*CT                                            
      BDOWN=-BZZZ*CT-BRHO*ST                                            
      RETURN                                                            
7     B(1)=BXXX                                                         
      B(2)=BYYY                                                         
      B(3)=BZZZ                                                         
      RETURN                                                            
      END                                                               
C
