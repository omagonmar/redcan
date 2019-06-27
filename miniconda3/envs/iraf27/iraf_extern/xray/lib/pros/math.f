      real function atan2d (a, b)
      real a
      real b
      save
      atan2d = 0
         atan2d = (atan2(((a)/57.295779513082320877),((b)/57.29577951308
     *   2320877)))
         goto 100
100      return
      end
      double precision function datan2d (a, b)
      real a
      real b
      save
      datand = 0
         datand = (atan2(((a)/57.295779513082320877),((b)/57.29577951308
     *   2320877)))
         goto 100
100      return
      end
      double precision function dcosd (a)
      real a
      save
      dcosd = 0
         dcosd = (cos(((a)/57.295779513082320877)))
         goto 100
100      return
      end
      real function cosd (a)
      real a
      save
      cosd = 0
         cosd = (cos(((a)/57.295779513082320877)))
         goto 100
100      return
      end
      real function dacosd (a)
      real a
      save
      dacosd = 0
         dacosd = (acos(((a)/57.295779513082320877)))
         goto 100
100      return
      end
      double precision function dsind (a)
      real a
      save
      dsind = 0
         dsind = (sin(((a)/57.295779513082320877)))
         goto 100
100      return
      end
      real function sind (a)
      real a
      save
      sind = 0
         sind = (sin(((a)/57.295779513082320877)))
         goto 100
100      return
      end
      real function acosd (a)
      real a
      save
      acosd = 0
         acosd = (acos(((a)/57.295779513082320877)))
         goto 100
100      return
      end
c     datand  datan2d
