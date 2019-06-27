      subroutine tvignk ()
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
      integer instrt
      integer maskfe
      integer refime
      integer temp
      integer*2 shorte
      logical clobbr
      integer*4 axlen(7 )
      integer depth
      integer disply
      integer fd
      integer line
      integer mline
      integer ncols
      integer naxes
      integer v(7 )
      integer vm(7 )
      integer mirrox
      integer maxx
      integer mirroy
      integer maxy
      integer n
      integer x
      integer y
      integer ysq
      double precision scale
      double precision theta
      double precision vbinrs
      double precision vbinse
      double precision vign
      integer*2 vignbn
      integer im
      integer pm
      integer sp
      integer instrc
      integer title
      integer vignrc
      integer vignle
      integer pmnewk
      integer immap
      integer clgeti
      logical clgetb
      double precision clgetd
      double precision calcta
      double precision calcvn
      integer imgeti
      integer stridx
      integer*4 imgetl
      logical xerflg
      common /xercom/ xerflg
      integer*2 st0001(10)
      integer*2 st0002(2)
      integer*2 st0003(50)
      integer*2 st0004(5)
      integer*2 st0005(11)
      integer*2 st0006(8)
      integer*2 st0007(8)
      integer*2 st0008(6)
      integer*2 st0009(8)
      integer*2 st0010(9)
      integer*2 st0011(9)
      integer*2 st0012(46)
      integer*2 st0013(11)
      integer*2 st0014(1)
      integer*2 st0015(1)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) /114,101,102, 95,105,109, 97,103/
      data (st0001(iyy),iyy= 9,10) /101, 0/
      data st0002 / 91, 0/
      data (st0003(iyy),iyy= 1, 8) / 66,114, 97, 99,107,101,116, 32/
      data (st0003(iyy),iyy= 9,16) /110,111,116, 97,116,105,111,110/
      data (st0003(iyy),iyy=17,24) / 32,111,110, 32,114,101,102,101/
      data (st0003(iyy),iyy=25,32) /114,101,110, 99,101, 32,105,109/
      data (st0003(iyy),iyy=33,40) / 97,103,101, 32,110,111,116, 32/
      data (st0003(iyy),iyy=41,48) /115,117,112,112,111,114,116,101/
      data (st0003(iyy),iyy=49,50) /100, 0/
      data st0004 /109, 97,115,107, 0/
      data (st0005(iyy),iyy= 1, 8) /114,101,115,111,108,117,116,105/
      data (st0005(iyy),iyy= 9,11) /111,110, 0/
      data st0006 / 99,108,111, 98, 98,101,114, 0/
      data st0007 /100,105,115,112,108, 97,121, 0/
      data st0008 /110, 99,111,108,115, 0/
      data st0009 /105, 95,110, 97,120,105,115, 0/
      data (st0010(iyy),iyy= 1, 8) /105, 95,110, 97,120,105,115, 49/
      data (st0010(iyy),iyy= 9, 9) / 0/
      data (st0011(iyy),iyy= 1, 8) /105, 95,110, 97,120,105,115, 50/
      data (st0011(iyy),iyy= 9, 9) / 0/
      data (st0012(iyy),iyy= 1, 8) /114,101,102,101,114,101,110, 99/
      data (st0012(iyy),iyy= 9,16) /101, 32,105,109, 97,103,101, 32/
      data (st0012(iyy),iyy=17,24) / 97,120,105,115, 32,100,105,109/
      data (st0012(iyy),iyy=25,32) /101,110,115,105,111,110,115, 32/
      data (st0012(iyy),iyy=33,40) /109,117,115,116, 32, 98,101, 32/
      data (st0012(iyy),iyy=41,46) /101,113,117, 97,108, 0/
      data (st0013(iyy),iyy= 1, 8) /118,105,103,110,101,116,116,105/
      data (st0013(iyy),iyy= 9,11) /110,103, 0/
      data st0014 / 0/
      data st0015 / 0/
         call smark(sp)
         call salloc( title, 8192, 2)
         call salloc( vignrc , 33 , 10 )
         call salloc( instrc , 12 , 10 )
         call salloc( maskfe, 127 , 2 )
         call salloc( refime, 127 , 2 )
         call salloc( instrt , 127 , 2 )
         call salloc( temp , 127 , 2 )
         call clgstr(st0001,memc(refime),127 )
         n = stridx( st0002 , memc(refime))
         if (.not.( n .ne. 0 )) goto 110
            call xerror( 1 , st0003)
            if (xerflg) goto 100
110      continue
         call clgstr(st0004,memc(maskfe),127 )
         vbinrs = clgetd(st0005)
         vbinse = 0.01d0
         im = immap(memc(refime),1 ,0)
         clobbr = clgetb(st0006)
         disply = clgeti(st0007)
         if (.not.( disply .ge. 1)) goto 120
            ncols = clgeti(st0008)
120      continue
         im = immap(memc(refime),1 ,0)
         naxes=imgeti(im,st0009)
         axlen(1)=imgetl(im,st0010)
         axlen(2)=imgetl(im,st0011)
         if (.not.( axlen(1) .ne. axlen(2) )) goto 130
            call xerror( 1, st0012)
            if (xerflg) goto 100
130      continue
         call readvr(disply,im,vignrc,instrc)
         call vignge(memc(refime),memc(maskfe),clobbr,127 , memc(temp))
         naxes = 2
         depth = 16
         pm = pmnewk(im,depth)
         line = 1
         shorte = 1
         call amovki(1,v,7 )
         call amovki(1,vm,7 )
         y = memi(instrc+9)
         mirroy = memi((instrc+7)) + (memi((instrc+7)) -y)+1
         mline = mirroy
         vm(naxes) = mline
         maxy = -1
         call salloc( vignle , axlen(1) , 3 )
140      if (.not.( line .le. axlen(2) .and. y .le. memi((instrc+7)) .or
     *   . mirroy .gt. memi((instrc+7)) .and. mirroy .gt. 0 )) goto 141
            x = memi(instrc+8)
            mirrox=memi((instrc+6)) + abs(memi((instrc+6)) -x)+1
            maxx = mirrox
            theta = calcta(instrc,x,y,ysq)
            vign = calcvn(vignrc,theta)
            vignbn = (vign / vbinse + .5d0)
            shorte = 100
            call amovks(shorte,mems(vignle),axlen(1))
            call calclt(instrc,vignrc,axlen,vignbn,vbinrs,vbinse,x, 
     *      mirrox,ysq,mems(vignle))
            x=maxx+1
            call calcrt(instrc,vignrc,axlen,vignbn,vbinrs,vbinse,x, ysq,
     *      mems(vignle))
            if (.not.( y .le. memi((instrc+7)) )) goto 150
               if (.not.( disply .ge. 2 )) goto 160
                  call dbdisp(line,vignbn,mems(vignle),instrc,axlen)
160            continue
               if (.not.( disply .ge. 3 )) goto 170
                  call dblinp(line,mems(vignle),instrc,axlen)
170            continue
               call pmplps(pm,v,mems(vignle),0,axlen(1),0)
               line = line+1
               v(naxes) = line
150         continue
            if (.not.( mirroy .gt. memi((instrc+7)) .and. mirroy .le. 
     *      axlen(1))) goto 180
               if (.not.( disply .ge. 2 )) goto 190
                  call dbdisp(mline,vignbn,mems(vignle),instrc,axlen)
190            continue
               if (.not.( disply .ge. 3 )) goto 200
                  call dblinp(line,mems(vignle),instrc,axlen)
200            continue
               call pmplps(pm,vm,mems(vignle),0,axlen(1),0)
180         continue
            if (.not.( mirroy .gt. memi((instrc+7)) .and. mirroy .le. 
     *      axlen(1))) goto 210
               maxy = max(y,maxy,mirroy)
               goto 211
210         continue
               maxy = max(y,maxy)
211         continue
            y = y+1
            mirroy = mirroy-1
            mline = mirroy
            vm(naxes) = mline
            goto 140
141      continue
         if (.not.( maxy .lt. axlen(2))) goto 220
            y = maxy+1
            line = y
            v(naxes)=line
230         if (.not.( line .le. axlen(2) )) goto 231
               x = memi(instrc+8)
               mirrox=memi((instrc+6)) + abs(memi((instrc+6)) -x+1)
               maxx = mirrox
               theta = calcta(instrc,x,y,ysq)
               vign = calcvn(vignrc,theta)
               vignbn = (vign / vbinse + .5)
               call amovks(shorte,mems(vignle),axlen(1))
               call calclt(instrc,vignrc,axlen,vignbn,vbinrs,vbinse, x,
     *         mirrox,ysq,mems(vignle))
               x=maxx+1
               call calcrt(instrc,vignrc,axlen,vignbn,vbinrs,vbinse,x, 
     *         ysq,mems(vignle))
               if (.not.( disply .ge. 2 )) goto 240
                  call dbdisp(line,vignbn,mems(vignle),instrc,axlen)
240            continue
               if (.not.( disply .ge. 3 )) goto 250
                  call dblinp(line,mems(vignle),instrc,axlen)
250            continue
               call pmplps(pm,v,mems(vignle),0,axlen(1),0)
               line = line+1
               v(naxes) = line
               y = y+1
               goto 230
231         continue
220      continue
         if (.not.( disply .ge. 1)) goto 260
            call rgpmdp(pm,ncols,ncols,-1,-1,-1,-1)
            call xffluh( 4 )
260      continue
         scale = vbinse
         call encpld(memc(maskfe),st0013,memc(refime), axlen(1),axlen(2)
     *   ,scale,0,memc(title),8192)
         if (.not.( disply .ge. 1 )) goto 270
            call mskdip(st0014,st0015,memc(title))
270      continue
         call plsavf(pm,memc(temp),memc(title),0)
         call imunmp(im)
         call plcloe(pm)
         call xfcloe(fd)
         call finale(memc(temp),memc(maskfe))
         call sfree(sp)
100      return
      end
c     tvignk  t_vignmask
c     vignle  vignline
c     calcta  calc_theta
c     vbinse  vbinscale
c     calcrt  calc_right
c     vignge  vigngetoutfile
c     mirrox  mirrorx
c     mirroy  mirrory
c     vignbn  vignbin
c     vignrc  vignrec
c     rgpmdp  rg_pmdisp
c     shorte  shortone
c     calclt  calc_left
c     dblinp  dblinedisp
c     refime  ref_image
c     maskfe  maskfile
c     disply  display
c     readvr  read_vign_par
c     imunmp  imunmap
c     instrc  instrec
c     vbinrs  vbinres
c     calcvn  calc_vign
c     plsavf  pl_savef
c     plcloe  pl_close
c     finale  finalname
c     instrt  instrument
c     encpld  enc_plhead
c     clobbr  clobber
c     mskdip  msk_disp
c     pmnewk  pm_newmask
