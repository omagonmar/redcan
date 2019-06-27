C
C Calandar functions scraped from the JMCD Cal library
C John : Nov 89
C
C
C ----------------------------------------------------------
C
C>[24]  REAL*8 FUNCTION CALTJE (EPJ)
      	REAL*8 FUNCTION CALTJE (EPJ)
C>	 Julian Epoch to JD
C	 Origin: SLALIB
*  Reference:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*  P.T.Wallace   Starlink   February 1984
C>	 Last modified 1987
C>	 Rev 1
C < Julian epoch
	REAL*8 EPJ
c....................................
	CALTJE = 2451544.5D0 + (EPJ-2000D0)*365.25D0
	END
C----------------------------------------------------------------
C
C>[22] 	REAL*8 FUNCTION CALTBE (BE)
      	REAL*8 FUNCTION CALTBE (BE)
C>	 Conversion of Besselian Epoch to Julian Date
*  Reference:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*  P.T.Wallace   Starlink   February 1984
C>	 Last modified 1987
C>	 Rev 1
c < Besselian epoch
        REAL*8 BE
c..........................................................
      	caltBE= 2415019.81352D0 + (BE-1900D0)*365.242198781D0
      	END
C ----------------------------------------------------------

C>[21]	REAL*8 FUNCTION CALBE (T)
	REAL*8 FUNCTION CALBE (T)
C> 	 Conversion of Julian Date to Besselian Epoch
*  Reference:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*  P.T.Wallace   Starlink   February 1984
C>	 Last modified 1989 May 8
C>	 Rev 2
C < JD            
	REAL*8 T
C.......................................................      
	CALBE = 1900D0 + (T-2415019.81352D0)/365.242198781D0
	END
C----------------------------------------------------------------

C>[23]  DOUBLE PRECISION FUNCTION CAL_JE (T)
      	DOUBLE PRECISION FUNCTION CAL_JE (T)
C>	 Conversion of Julian Date to Julian Epoch
C  Reference:
C     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
C  P.T.Wallace   Starlink   February 1984
C>	Last modified 1989 May 8
C>	Rev 2
c < JD
        DOUBLE PRECISION T
c....................................................
      	CAL_JE = 2000D0 + (T-2451544.5D0)/365.25D0
      	END
C ----------------------------------------------------------
C
C>[25]	DOUBLE PRECISION FUNCTION CAL_JC (T)
      DOUBLE PRECISION FUNCTION CAL_JC (T)
C> 	 JD to JULIAN CENTURIES SINCE J2000.0
C>	 Last modified 1987
C>	 Rev 2 1989 Jun - corrected value by 0.5d
C < JD
      DOUBLE PRECISION T
c..............................................
      	CAL_JC=(T-2451545.0D0)/36525D0
      END
c---------------------------------------------------------------




C
C Complex functions scraped from JMCD mat_complex.f
C
C
C ----------------------------------------------------------
C
C>[2]	REAL FUNCTION ARGD (X,Y)
      REAL FUNCTION ARGD (X,Y)
C Argument of complex number in degrees
C Arctan (Y/X)
c  Cos theta, Sin theta                                      
      REAL X,Y 		
      REAL TWOPI
      PARAMETER (TWOPI=360.0)
C
      ARGD=0.
      IF (X.EQ.0.0.AND.Y.EQ.0.0) RETURN
      ARGD=ATAN2D (Y,X)
      IF (ARGD.LT.0.) ARGD=ARGD+TWOPI
      END
C ----------------------------------------------------------
C
C>[5]	DOUBLE PRECISION FUNCTION DARGD (X,Y)
      DOUBLE PRECISION FUNCTION DARGD (X,Y)
C Argument of complex number in degrees
C Arctan (Y/X)
c  Cos theta, Sin theta                                    
      DOUBLE PRECISION X,Y 		
      DOUBLE PRECISION TWOPI
      PARAMETER (TWOPI=360.0D0)
C
      DARGD=0.
      IF (X.EQ.0.0.AND.Y.EQ.0.0) RETURN
      DARGD=DATAN2D (Y,X)
      IF (DARGD.LT.0.) DARGD=DARGD+TWOPI
      END
C ----------------------------------------------------------------
C
C
      SUBROUTINE ERROR (PROMPT)
C Writes message to error stream and sets io status to error
      CHARACTER*(*) PROMPT

      RETURN

      END
