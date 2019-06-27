      integer function sysruk (task, cmd, arglit, intere)
      integer arglit
      integer intere
      integer*2 task(32767+1)
      integer*2 cmd(32767+1)
      integer i
      integer ntasks
      integer lmarg
      integer rmarg
      integer maxch
      integer ncol
      integer eawarn
      logical streq
      integer envgei
      integer envscn
      logical xerpop
      logical xerflg
      common /xercom/ xerflg
      integer iyy
      integer dp(4)
      integer*2 dict(16)
      integer*2 st0001(9)
      integer*2 st0002(6)
      integer*2 st0003(6)
      integer*2 st0004(4)
      integer*2 st0005(2)
      integer*2 st0006(29)
      integer*2 st0007(25)
      save
      data (dict(iyy),iyy= 1, 8) / 97,100,100, 0,109,101,114,103/
      data (dict(iyy),iyy= 9,16) /101, 0,112, 97,105,110,116, 0/
      data (st0001(iyy),iyy= 1, 8) /116,116,121,110, 99,111,108,115/
      data (st0001(iyy),iyy= 9, 9) / 0/
      data st0002 / 99,104,100,105,114, 0/
      data st0003 /104,111,109,101, 36, 0/
      data st0004 /115,101,116, 0/
      data st0005 / 9, 0/
      data (st0006(iyy),iyy= 1, 8) /105,110,118, 97,108,105,100, 32/
      data (st0006(iyy),iyy= 9,16) /115,101,116, 32,115,116, 97,116/
      data (st0006(iyy),iyy=17,24) /101,109,101,110,116, 58, 32, 39/
      data (st0006(iyy),iyy=25,29) / 37,115, 39, 10, 0/
      data (st0007(iyy),iyy= 1, 8) /105,110,118, 97,108,105,100, 32/
      data (st0007(iyy),iyy= 9,16) / 83, 69, 84, 32,105,110, 32, 73/
      data (st0007(iyy),iyy=17,24) / 82, 65, 70, 32, 77, 97,105,110/
      data (st0007(iyy),iyy=25,25) / 0/
      data (dp(iyy),iyy= 1, 4) / 1, 5, 11, 0/
      data ntasks /0/
      data lmarg /5/, maxch /0/, ncol /0/, eawarn /3/
         if (.not.(ntasks .eq. 0)) goto 110
            i=1
120         if (.not.(dp(i) .ne. 0)) goto 122
121            i=i+1
               goto 120
122         continue
            ntasks = i - 1
110      continue
         if (.not.(task(1) .eq. 63)) goto 130
            call xerpsh
            rmarg = envgei (st0001)
            if (.not.xerpop()) goto 140
               rmarg = 80
140         continue
            call strtbl (4, dict, dp, ntasks, lmarg, rmarg, maxch, ncol)
            sysruk = (0)
            goto 100
130      continue
         if (.not.(streq (task, st0002))) goto 150
            call xerpsh
            if (.not.(cmd(arglit) .eq. 0)) goto 170
               call fchdir (st0003)
               goto 171
170         continue
               call fchdir (cmd(arglit))
171         continue
162         if (.not.xerpop()) goto 160
               if (.not.(intere .eq. 1)) goto 180
                  call erract (eawarn)
                  if (xerflg) goto 100
                  goto 181
180            continue
181            continue
160         continue
            sysruk = (0)
            goto 100
150      continue
         if (.not.(streq (task, st0004))) goto 190
            call xerpsh
            if (.not.(cmd(arglit) .eq. 0)) goto 210
               call envlit (4, st0005, 1)
               call xffluh(4)
               goto 211
210         continue
            if (.not.(envscn (cmd) .le. 0)) goto 220
               if (.not.(intere .eq. 1)) goto 230
                  call eprinf (st0006)
                  call pargsr (cmd)
                  goto 231
230            continue
                  goto 91
231            continue
220         continue
211         continue
202         if (.not.xerpop()) goto 200
               if (.not.(intere .eq. 1)) goto 240
                  call erract (eawarn)
                  if (xerflg) goto 100
                  goto 241
240            continue
91                call syspac (0, st0007)
241            continue
200         continue
            sysruk = (0)
            goto 100
190      continue
151      continue
131      continue
         if (.not.(streq (task, dict(dp(1))))) goto 250
            call scatet
            sysruk = (0)
            goto 100
250      continue
         if (.not.(streq (task, dict(dp(2))))) goto 260
            call scmtet
            sysruk = (0)
            goto 100
260      continue
         if (.not.(streq (task, dict(dp(3))))) goto 270
            call scptet
            sysruk = (0)
            goto 100
270      continue
         sysruk = (-1)
         goto 100
100      return
      end
      subroutine scmtet ()
      logical Memb(1)
      integer*2 Memc(1)
      integer*2 Mems(1)
      integer Memi(1)
      integer*4 Meml(1)
      real Memr(1)
      double precision Memd(1)
      complex Memx(1)
      equivalence (Memb, Memc, Mems, Memi, Meml, Memr, Memd, Memx)
      common /Mem/ Memd
      integer line
      integer startx
      integer stopx
      integer val
      integer scbuie
      integer clgeti
      integer*2 st0001(6)
      integer*2 st0002(5)
      integer*2 st0003(4)
      save
      data st0001 /115,116, 97,114,116, 0/
      data st0002 /115,116,111,112, 0/
      data st0003 /118, 97,108, 0/
         line = scbuie()
         startx = clgeti(st0001)
         stopx = clgeti(st0002)
         val = clgeti(st0003)
         call scmere (line, startx, stopx, val)
         call sclist (line)
100      return
      end
      subroutine scptet ()
      logical Memb(1)
      integer*2 Memc(1)
      integer*2 Mems(1)
      integer Memi(1)
      integer*4 Meml(1)
      real Memr(1)
      double precision Memd(1)
      complex Memx(1)
      equivalence (Memb, Memc, Mems, Memi, Meml, Memr, Memd, Memx)
      common /Mem/ Memd
      integer line
      integer startx
      integer stopx
      integer val
      integer scbuie
      integer clgeti
      integer*2 st0001(6)
      integer*2 st0002(5)
      integer*2 st0003(4)
      save
      data st0001 /115,116, 97,114,116, 0/
      data st0002 /115,116,111,112, 0/
      data st0003 /118, 97,108, 0/
         line = scbuie()
         startx = clgeti(st0001)
         stopx = clgeti(st0002)
         val = clgeti(st0003)
         call scpait (line, startx, stopx, val)
         call sclist (line)
100      return
      end
      subroutine scatet ()
      logical Memb(1)
      integer*2 Memc(1)
      integer*2 Mems(1)
      integer Memi(1)
      integer*4 Meml(1)
      real Memr(1)
      double precision Memd(1)
      complex Memx(1)
      equivalence (Memb, Memc, Mems, Memi, Meml, Memr, Memd, Memx)
      common /Mem/ Memd
      integer line
      integer startx
      integer stopx
      integer val
      integer scbuie
      integer clgeti
      integer*2 st0001(6)
      integer*2 st0002(5)
      integer*2 st0003(4)
      save
      data st0001 /115,116, 97,114,116, 0/
      data st0002 /115,116,111,112, 0/
      data st0003 /118, 97,108, 0/
         line = scbuie()
         startx = clgeti(st0001)
         stopx = clgeti(st0002)
         val = clgeti(st0003)
         call scadd (line, startx, stopx, val)
         call sclist (line)
100      return
      end
      integer function scbuie ()
      logical Memb(1)
      integer*2 Memc(1)
      integer*2 Mems(1)
      integer Memi(1)
      integer*4 Meml(1)
      real Memr(1)
      double precision Memd(1)
      complex Memx(1)
      equivalence (Memb, Memc, Mems, Memi, Meml, Memr, Memd, Memx)
      common /Mem/ Memd
      integer line
      integer startx
      integer stopx
      integer val
      integer clgeti
      integer scnewe
      integer*2 st0001(44)
      integer*2 st0002(6)
      integer*2 st0003(5)
      integer*2 st0004(4)
      integer*2 st0005(2)
      integer*2 st0006(2)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) / 77, 97,107,101, 32, 98, 97,115/
      data (st0001(iyy),iyy= 9,16) /101, 32,108,105,110,101, 32, 98/
      data (st0001(iyy),iyy=17,24) / 97, 99,107, 32,116,111, 32,102/
      data (st0001(iyy),iyy=25,32) /114,111,110,116, 32,117,110,116/
      data (st0001(iyy),iyy=33,40) /105,108, 32,115,116, 97,114,116/
      data (st0001(iyy),iyy=41,44) / 61, 48, 10, 0/
      data st0002 /115,116, 97,114,116, 0/
      data st0003 /115,116,111,112, 0/
      data st0004 /118, 97,108, 0/
      data st0005 / 10, 0/
      data st0006 / 10, 0/
         call xprinf(st0001)
         line = 0
110      continue
            startx = clgeti(st0002)
            if (.not.( startx .gt. 0 )) goto 120
               stopx = clgeti(st0003)
               val = clgeti(st0004)
               line = scnewe(stopx, val, 0 , line)
               line = scnewe(startx, val, 1 , line)
               goto 121
120         continue
            if (.not.( startx .eq. -1 )) goto 130
               line = scnewe(20, 10, 0 , line)
               line = scnewe(10, 10, 1 , line)
               goto 131
130         continue
            if (.not.( startx .eq. -2 )) goto 140
               line = scnewe(40, 10, 0 , line)
               line = scnewe(30, 10, 1 , line)
               line = scnewe(20, 10, 0 , line)
               line = scnewe(10, 10, 1 , line)
               goto 141
140         continue
            if (.not.( startx .eq. -3 )) goto 150
               line = scnewe(60, 10, 0 , line)
               line = scnewe(50, 10, 1 , line)
               line = scnewe(40, 10, 0 , line)
               line = scnewe(30, 10, 1 , line)
               line = scnewe(20, 10, 0 , line)
               line = scnewe(10, 10, 1 , line)
150         continue
141         continue
131         continue
121         continue
111         if (.not.( startx .le. 0 )) goto 110
112      continue
         call xprinf(st0005)
         call sclist (line)
         call scchek(line,1000,1,1)
         call xprinf(st0006)
         scbuie = ( line )
         goto 100
100      return
      end
c     eawarn  ea_warn
c     scchek  sc_check
c     scmtet  sc_mtest
c     scptet  sc_ptest
c     scnewe  sc_newedge
c     scbuie  sc_buildline
c     sysruk  sys_runtask
c     envscn  envscan
c     scmere  sc_merge
c     intere  interactive
c     sclist  sc_list
c     envgei  envgeti
c     syspac  sys_panic
c     eprinf  eprintf
c     scpait  sc_paint
c     scatet  sc_atest
c     arglit  arglist_offset
c     pargsr  pargstr
c     envlit  envlist
c     startx  start_x
