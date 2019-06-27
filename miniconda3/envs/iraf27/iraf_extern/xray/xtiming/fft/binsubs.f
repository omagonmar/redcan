      subroutine timopp (param, ext, filene, none, qp, qpio)
      logical none
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
      integer qp
      integer qpio
      integer*2 param(*)
      integer*2 ext(*)
      integer*2 filene(*)
      integer sp
      integer evlist
      integer filert
      integer sbuf
      integer qpopen
      integer qpioon
      logical cknone
      logical streq
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(1)
      integer*2 st0002(28)
      save
      integer iyy
      data st0001 / 0/
      data (st0002(iyy),iyy= 1, 8) /114,101,113,117,105,114,101,115/
      data (st0002(iyy),iyy= 9,16) / 32, 42, 37,115, 32,102,105,108/
      data (st0002(iyy),iyy=17,24) /101, 32, 97,115, 32,105,110,112/
      data (st0002(iyy),iyy=25,28) /117,116, 10, 0/
         call smark (sp)
         call salloc (evlist, 1024, 2)
         call salloc (sbuf, 161 , 2)
         call salloc (filert, 127 , 2)
         call clgstr (param, filene, 127 )
         call rootne (filene,filene,ext,127 )
         none = cknone( filene )
         if (.not.(streq(st0001, filene) )) goto 110
            call sprinf(sbuf,161 ,st0002)
            call pargsr(ext)
            call xerror(1, sbuf)
            if (xerflg) goto 100
110      continue
         if (.not.( .not.none )) goto 120
            call qppare (filene, memc(filert), 127 , memc(evlist), 1024)
            qp = qpopen (memc(filert), 1 , 0)
            qpio = qpioon( qp, memc(evlist), 1 )
            goto 121
120      continue
            call xstrcy( filene, memc(evlist), 127 )
121      continue
         call sfree(sp)
100      return
      end
      subroutine timopf (filene, ext, none, qp, qpio)
      logical none
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
      integer qp
      integer qpio
      integer*2 filene(*)
      integer*2 ext(*)
      integer sp
      integer evlist
      integer filert
      integer sbuf
      integer qpopen
      integer qpioon
      logical cknone
      logical streq
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(1)
      integer*2 st0002(28)
      save
      integer iyy
      data st0001 / 0/
      data (st0002(iyy),iyy= 1, 8) /114,101,113,117,105,114,101,115/
      data (st0002(iyy),iyy= 9,16) / 32, 42, 37,115, 32,102,105,108/
      data (st0002(iyy),iyy=17,24) /101, 32, 97,115, 32,105,110,112/
      data (st0002(iyy),iyy=25,28) /117,116, 10, 0/
         call smark (sp)
         call salloc (evlist, 1024, 2)
         call salloc (sbuf, 161 , 2)
         call salloc (filert, 127 , 2)
         none = cknone( filene )
         if (.not.(streq(st0001, filene) )) goto 110
            call sprinf(sbuf,161 ,st0002)
            call pargsr(ext)
            call xerror(1, sbuf)
            if (xerflg) goto 100
110      continue
         if (.not.( .not.none )) goto 120
            call qppare (filene, memc(filert), 127 , memc(evlist), 1024)
            qp = qpopen (memc(filert), 1 , 0)
            qpio = qpioon( qp, memc(evlist), 1 )
            goto 121
120      continue
            call xstrcy( filene, memc(evlist), 127 )
121      continue
         call sfree(sp)
100      return
      end
      subroutine timcke (qp, qptype, offset)
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
      integer qp
      integer qptype
      integer offset
      integer type
      integer sp
      integer evloop
      integer sbuf
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(5)
      integer*2 st0002(51)
      integer*2 st0003(29)
      integer*2 st0004(32)
      save
      integer iyy
      data st0001 /116,105,109,101, 0/
      data (st0002(iyy),iyy= 1, 8) / 37,115, 32,101,118,101,110,116/
      data (st0002(iyy),iyy= 9,16) / 32,115,116,114,117, 99,116,117/
      data (st0002(iyy),iyy=17,24) /114,101, 32, 40,113,112, 41, 32/
      data (st0002(iyy),iyy=25,32) /109,117,115,116, 32,104, 97,118/
      data (st0002(iyy),iyy=33,40) /101, 32, 39,116,105,109,101, 39/
      data (st0002(iyy),iyy=41,48) / 32,100,101,102,105,110,101,100/
      data (st0002(iyy),iyy=49,51) / 92,115, 0/
      data (st0003(iyy),iyy= 1, 8) / 37,115, 32, 39,116,105,109,101/
      data (st0003(iyy),iyy= 9,16) / 39, 32,109,117,115,116, 32, 98/
      data (st0003(iyy),iyy=17,24) /101, 32, 84, 89, 95, 68, 79, 85/
      data (st0003(iyy),iyy=25,29) / 66, 76, 69, 10, 0/
      data (st0004(iyy),iyy= 1, 8) /115,111,117,114, 99,101, 32, 39/
      data (st0004(iyy),iyy= 9,16) /116,105,109,101, 39, 32,109,117/
      data (st0004(iyy),iyy=17,24) /115,116, 32, 98,101, 32, 84, 89/
      data (st0004(iyy),iyy=25,32) / 95, 68, 79, 85, 66, 76, 69, 0/
         call smark(sp)
         call salloc( sbuf, 161 , 2)
         if (.not.( evloop(qp, st0001, type, offset) .eq. 0 )) goto 110
            call sprinf(sbuf,161 ,st0002)
            call pargsr(int(qptype))
            call xerror(1, sbuf)
            if (xerflg) goto 100
            goto 111
110      continue
         if (.not.( type .ne. 7 )) goto 120
            call sprinf(sbuf,161 ,st0003)
            call pargsr(int(qptype))
            call xerror(1, st0004)
            if (xerflg) goto 100
120      continue
111      continue
         call sfree(sp)
100      return
      end
      subroutine timgea (qp, area)
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
      integer qp
      double precision area
      integer areas
      integer indics
      integer i
      save
         area = 0.0d0
         call getqpa(qp,areas,indics)
         do 110 i=1,indics
            area = area + memi(areas+i-1)
110      continue
111      continue
100      return
      end
      subroutine ltcses (disply, qpio, offset, start, stop, numbis, 
     *binleh)
      integer disply
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
      integer qpio
      integer offset
      double precision start
      double precision stop
      integer numbis
      real binleh
      integer clgeti
      real clgetr
      integer*2 st0001(5)
      integer*2 st0002(11)
      integer*2 st0003(33)
      save
      integer iyy
      data st0001 / 98,105,110,115, 0/
      data (st0002(iyy),iyy= 1, 8) / 98,105,110, 95,108,101,110,103/
      data (st0002(iyy),iyy= 9,11) /116,104, 0/
      data (st0003(iyy),iyy= 1, 8) / 98,105,110,108,101,110, 32, 61/
      data (st0003(iyy),iyy= 9,16) / 32, 37, 49, 50, 46, 51,102, 32/
      data (st0003(iyy),iyy=17,24) / 38, 32,110,117,109, 95, 98,105/
      data (st0003(iyy),iyy=25,32) /110,115, 32, 61, 32, 37,100, 10/
      data (st0003(iyy),iyy=33,33) / 0/
         call timges (disply,qpio,offset,start,stop)
         numbis = clgeti(st0001)
         if (.not.( numbis .gt. 0 )) goto 110
            binleh = (stop-start)/float(numbis)
            goto 111
110      continue
            binleh = clgetr (st0002)
            numbis = int ((stop-start)/binleh) + 1
111      continue
         if (.not.( disply .gt. 1 )) goto 120
            call xprinf(st0003)
            call pargr(binleh)
            call pargi(numbis)
120      continue
100      return
      end
      subroutine fldses (disply, offset, start, stop, period, numfos, 
     *numbis, binleh)
      integer disply
      integer offset
      double precision start
      double precision stop
      real period
      integer numfos
      integer numbis
      real binleh
      integer clgeti
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(5)
      integer*2 st0002(51)
      integer*2 st0003(51)
      save
      integer iyy
      data st0001 / 98,105,110,115, 0/
      data (st0002(iyy),iyy= 1, 8) / 69,120, 99,101,101,100,101,100/
      data (st0002(iyy),iyy= 9,16) / 32, 77, 97,120, 32, 35, 32, 66/
      data (st0002(iyy),iyy=17,24) /105,110,115, 32, 45, 32,114,101/
      data (st0002(iyy),iyy=25,32) /113,117,101,115,116,101,100, 32/
      data (st0002(iyy),iyy=33,40) / 37,100, 32,119,104,101,110, 32/
      data (st0002(iyy),iyy=41,48) /109, 97,120, 32,105,115, 32, 37/
      data (st0002(iyy),iyy=49,51) /100, 10, 0/
      data (st0003(iyy),iyy= 1, 8) / 98,105,110,108,101,110, 32, 61/
      data (st0003(iyy),iyy= 9,16) / 32, 37, 49, 50, 46, 51,102, 32/
      data (st0003(iyy),iyy=17,24) / 38, 32,110,117,109, 95, 98,105/
      data (st0003(iyy),iyy=25,32) /110,115, 32, 61, 32, 37,100, 32/
      data (st0003(iyy),iyy=33,40) / 38, 32,110,117,109, 95,102,111/
      data (st0003(iyy),iyy=41,48) /108,100,115, 32, 61, 32, 37,100/
      data (st0003(iyy),iyy=49,51) / 32, 10, 0/
         numbis = clgeti(st0001)
         if (.not.(numbis .gt. 1000)) goto 110
            call xerror(1,st0002)
            if (xerflg) goto 100
            call pargi(numbis)
            call pargi(1000)
            goto 111
110      continue
         if (.not.( numbis .le. 0 )) goto 120
            numbis = 1
120      continue
111      continue
         binleh = period / numbis
         numfos = int ((stop-start)/binleh)/numbis + 1
         if (.not.( disply .gt. 1 )) goto 130
            call xprinf(st0003)
            call pargr(binleh)
            call pargi(numbis)
            call pargi(numfos)
130      continue
100      return
      end
      subroutine timgis (disply, qp, start, stop, gintvs, numgis, duratn
     *)
      integer disply
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
      integer qp
      double precision start
      double precision stop
      integer gintvs
      integer numgis
      double precision duratn
      logical getgis
      logical clgetb
      integer*2 st0001(11)
      integer*2 st0002(1)
      integer*2 st0003(34)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) /103,101,116, 95,103,105,110,116/
      data (st0001(iyy),iyy= 9,11) /118,115, 0/
      data st0002 / 0/
      data (st0003(iyy),iyy= 1, 8) / 35, 32, 71,105,110,116,118,115/
      data (st0003(iyy),iyy= 9,16) / 32, 61, 32, 37,100, 44, 32, 68/
      data (st0003(iyy),iyy=17,24) /117,114, 97,116,105,111,110, 32/
      data (st0003(iyy),iyy=25,32) / 61, 32, 37, 49, 52, 46, 51,102/
      data (st0003(iyy),iyy=33,34) / 10, 0/
         getgis = clgetb(st0001)
         if (.not.( getgis )) goto 110
            call getgos (qp, st0002, gintvs, numgis, duratn)
110      continue
         if (.not.( .not.getgis .or. numgis .eq. 0 )) goto 120
            call xmallc(gintvs, 2, 7)
            numgis = 1
            memd(gintvs) = start
            memd(gintvs+1) = stop
            duratn = stop - start
120      continue
         if (.not.( disply .ge. 3 )) goto 130
            call xprinf(st0003)
            call pargi (numgis)
            call pargd (duratn)
130      continue
100      return
      end
      subroutine timoue (param, ext, mastee, outpue, tempne, clobbr)
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
      integer mastee
      integer outpue
      integer tempne
      logical clobbr
      integer*2 param(*)
      integer*2 ext(*)
      integer sp
      logical streq
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(5)
      integer*2 st0002(30)
      save
      integer iyy
      data st0001 / 78, 79, 78, 69, 0/
      data (st0002(iyy),iyy= 1, 8) /114,101,113,117,105,114,101,115/
      data (st0002(iyy),iyy= 9,16) / 32,116, 97, 98,108,101, 32,102/
      data (st0002(iyy),iyy=17,24) /105,108,101, 32, 97,115, 32,111/
      data (st0002(iyy),iyy=25,30) /117,116,112,117,116, 0/
         call smark(sp)
         call clgstr (param, memc(outpue), 127 )
         call rootne(memc(mastee),memc(outpue), ext, 127 )
         if (.not.(streq(st0001, memc(outpue)) )) goto 110
            call xerror(1, st0002)
            if (xerflg) goto 100
110      continue
         call clobbe(memc(outpue),memc(tempne),clobbr,127 )
         call sfree(sp)
100      return
      end
      subroutine timqpe (qp, qpio)
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
      integer qp
      integer qpio
      save
         call qpioce(qpio)
         call qpcloe(qp)
100      return
      end
      subroutine timges (disply, qp, offset, start, stop)
      integer disply
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
      integer qp
      integer offset
      double precision start
      double precision stop
      integer ev
      integer qpiost
      integer*2 st0001(37)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) / 68, 97,116, 97, 32,115,116, 97/
      data (st0001(iyy),iyy= 9,16) /114,116, 32, 61, 32, 37, 49, 52/
      data (st0001(iyy),iyy=17,24) / 46, 51,102, 32, 38, 32,115,116/
      data (st0001(iyy),iyy=25,32) /111,112, 32, 61, 32, 37, 49, 52/
      data (st0001(iyy),iyy=33,37) / 46, 51,102, 10, 0/
         ev = qpiost (qp, 18 )
         start = memd((ev+offset-1)/4+1)
         ev = qpiost (qp, 17 )
         stop = memd((ev+offset-1)/4+1)
         if (.not.( disply .ge. 3 )) goto 110
            call xprinf(st0001)
            call pargd (start)
            call pargd (stop)
110      continue
100      return
      end
      subroutine timhdr (tp, sqp, bqp, photoe, bkgdfe, dobkgd)
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
      integer tp
      integer sqp
      integer bqp
      logical dobkgd
      integer*2 photoe(*)
      integer*2 bkgdfe(*)
      integer qphd
      integer*2 st0001(2)
      integer*2 st0002(2)
      save
      data st0001 /115, 0/
      data st0002 / 98, 0/
         call getqpd (sqp, qphd)
         call puttbd (tp, qphd)
         call timadk(tp, sqp, photoe, st0001)
         if (.not.( dobkgd .and. bqp .ne. 0)) goto 110
            call timadk (tp, bqp, bkgdfe, st0002)
110      continue
         call xmfree(qphd, 10 )
100      return
      end
      subroutine timinn (start, binleh, minmax, startn, stopbn, expose)
      double precision start
      real binleh
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
      integer minmax
      double precision startn
      double precision stopbn
      real expose
      save
         call timinm (minmax)
         startn = start
         stopbn = startn + binleh
         expose = 0.0e0
100      return
      end
c     sprinf  sprintf
c     cknone  ck_none
c     stopbn  stop_bin
c     mastee  master_name
c     indics  indices
c     fldses  fld_setbins
c     timinm  tim_initmm
c     getgis  get_gintvs
c     timopp  tim_openqp
c     rootne  rootname
c     duratn  duration
c     getgos  get_goodtimes
c     getqpd  get_qphead
c     numfos  numfolds
c     timhdr  tim_hdr
c     timinn  tim_initbin
c     photoe  photon_file
c     bkgdfe  bkgd_file
c     filert  file_root
c     getqpa  get_qparea
c     ltcses  ltc_setbins
c     timgis  tim_gintvs
c     binleh  bin_length
c     startn  start_bin
c     timadk  tim_addmsk
c     qpopen  qp_open
c     numgis  num_gintvs
c     timqpe  tim_qpclose
c     qpioon  qpio_open
c     puttbd  put_tbhead
c     filene  file_name
c     timopf  tim_openqpf
c     disply  display
c     clobbe  clobbername
c     timges  tim_getss
c     timcke  tim_cktime
c     expose  exposure
c     qppare  qpparse
c     numbis  numbins
c     evloop  ev_lookup
c     timgea  tim_getarea
c     qpcloe  qp_close
c     tempne  tempname
c     qpioce  qpio_close
c     pargsr  pargstr
c     outpue  output_name
c     clobbr  clobber
c     timoue  tim_outtable
