      subroutine tnagft ()
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
      integer fp
      integer nparas
      real chisq
      integer ctpars
      real simplh
      integer*2 st0001(42)
      integer*2 st0002(30)
      integer*2 st0003(21)
      integer*2 st0004(47)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) / 80,101,114,102,111,114,109,105/
      data (st0001(iyy),iyy= 9,16) /110,103, 32,116,104,101, 32, 83/
      data (st0001(iyy),iyy=17,24) /105,109,112,108,101,120, 32,109/
      data (st0001(iyy),iyy=25,32) /105,110,105,109,105,122, 97,116/
      data (st0001(iyy),iyy=33,40) /105,111,110, 32,102,105,116, 46/
      data (st0001(iyy),iyy=41,42) / 10, 0/
      data (st0002(iyy),iyy= 1, 8) / 70,111,117,110,100, 32, 37,100/
      data (st0002(iyy),iyy= 9,16) / 32,102,114,101,101, 32,112, 97/
      data (st0002(iyy),iyy=17,24) /114, 97,109,101,116,101,114, 40/
      data (st0002(iyy),iyy=25,30) /115, 41, 46, 32, 10, 0/
      data (st0003(iyy),iyy= 1, 8) /115,105,109,112,108,101,120, 95/
      data (st0003(iyy),iyy= 9,16) /109,105,110,105,109,105,122, 97/
      data (st0003(iyy),iyy=17,21) /116,105,111,110, 0/
      data (st0004(iyy),iyy= 1, 8) / 78,111, 32,102,114,101,101, 32/
      data (st0004(iyy),iyy= 9,16) /112, 97,114, 97,109,101,116,101/
      data (st0004(iyy),iyy=17,24) /114,115, 32,119,101,114,101, 32/
      data (st0004(iyy),iyy=25,32) /102,111,117,110,100, 32,105,110/
      data (st0004(iyy),iyy=33,40) / 32,116,104,101, 32,109,111,100/
      data (st0004(iyy),iyy=41,47) /101,108,115, 46, 32, 10, 0/
         call xprinf(st0001)
         call constp ( fp )
         if (.not.( memi(fp+9) .gt. 0 )) goto 110
            nparas = ctpars(fp,1) + ctpars(fp,2)
            if (.not.( nparas .gt. 0 )) goto 120
               call xprinf( st0002)
               call pargi( nparas )
               chisq = simplh( fp )
               call fpchiq(fp)
               call savefs( fp, chisq, st0003 )
               call fpsmos(fp)
               goto 121
120         continue
               call fpsinf(fp)
               call xprinf( st0004)
121         continue
110      continue
         call razefp ( fp )
100      return
      end
      real function simplh (fp)
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
      integer fp
      integer maxits
      integer maxpas
      integer n
      integer iw
      integer ifail
      double precision work1(8)
      double precision work2(8)
      double precision work3(8)
      double precision work4(8)
      double precision work5(8)
      double precision work6(8,8)
      double precision chisq
      real bestcq
      double precision tolere
      double precision xc(8)
      real params(8)
      real paramp(8)
      integer clgeti
      integer freeps
      logical clgetb
      real clgetr
      real normcq
      external funct
      external monit
      integer fptr
      logical verboe
      integer iteran
      integer nparas
      integer nmodel(8)
      integer nparam(8)
      real norman
      real pinit(8)
      real pdelt(8)
      integer nlink((8*6)*3)
      integer nlinks
      common /nagcom/ fptr, verboe, iteran, nparas, nmodel, nparam, 
     *norman, pinit, pdelt, nlink, nlinks
      integer*2 st0001(10)
      integer*2 st0002(8)
      integer*2 st0003(15)
      integer*2 st0004(8)
      integer*2 st0005(38)
      integer*2 st0006(41)
      integer*2 st0007(25)
      integer*2 st0008(24)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) /116,111,108,101,114, 97,110, 99/
      data (st0001(iyy),iyy= 9,10) /101, 0/
      data st0002 /118,101,114, 98,111,115,101, 0/
      data (st0003(iyy),iyy= 1, 8) /109, 97,120, 95,105,116,101,114/
      data (st0003(iyy),iyy= 9,15) / 97,116,105,111,110,115, 0/
      data st0004 /115,105,109,112,108,101,120, 0/
      data (st0005(iyy),iyy= 1, 8) /114,111,108,108,105,110,103, 32/
      data (st0005(iyy),iyy= 9,16) /111,117,114, 32,111,119,110, 32/
      data (st0005(iyy),iyy=17,24) /115,105,109,112,108,101,120, 32/
      data (st0005(iyy),iyy=25,32) /109,105,110,105,109,105,122, 97/
      data (st0005(iyy),iyy=33,38) /116,105,111,110, 10, 0/
      data (st0006(iyy),iyy= 1, 8) / 42, 42, 42, 32, 69,114,114,111/
      data (st0006(iyy),iyy= 9,16) /114, 32, 42, 42, 42, 32, 78, 65/
      data (st0006(iyy),iyy=17,24) / 71, 32,109,105,110,105,109,105/
      data (st0006(iyy),iyy=25,32) /122, 97,116,105,111,110, 32, 69/
      data (st0006(iyy),iyy=33,40) / 48, 52, 67, 67, 70, 59, 32, 32/
      data (st0006(iyy),iyy=41,41) / 0/
      data (st0007(iyy),iyy= 1, 8) /112, 97,114, 97,109,101,116,101/
      data (st0007(iyy),iyy= 9,16) /114, 32,111,117,116, 32,111,102/
      data (st0007(iyy),iyy=17,24) / 32,114, 97,110,103,101, 46, 10/
      data (st0007(iyy),iyy=25,25) / 0/
      data (st0008(iyy),iyy= 1, 8) /112,114,101,109, 97,116,117,114/
      data (st0008(iyy),iyy= 9,16) /101, 32,116,101,114,109,105,110/
      data (st0008(iyy),iyy=17,24) / 97,116,105,111,110, 46, 10, 0/
      simplh = 0
         maxpas = 8
         tolere = dble(clgetr(st0001))
         verboe = clgetb(st0002)
         maxits = clgeti(st0003)
         chisq = dble(0.99e37 )
         nparas = freeps( fp, 0.10 , params, paramp, nmodel, nparam, 
     *   nlink, nlinks, maxpas)
         if (.not.( nparas .gt. 0 )) goto 110
            fptr = fp
            iteran = 0
            do 120 n = 1, nparas 
               pinit(n) = params(n)
               pdelt(n) = paramp(n)
               xc(n) = 0.0d0
120         continue
121         continue
            iw = nparas+1
            ifail = 1
            if (.not.( clgeti(st0004) .eq.0 )) goto 130
               call e04ccf( nparas, xc, chisq, tolere, iw, work1, work2,
     *          work3, work4, work5, work6, funct, monit, maxits, ifail)
               goto 131
130         continue
               call xprinf(st0005)
               call xffluh(4)
               call simplx( nparas, xc, chisq, tolere, iw, work1, work2,
     *          work3, work4, work5, work6, funct, monit, maxits, ifail)
131         continue
            if (.not.( ifail .ne. 0 )) goto 140
               call xprinf(st0006)
               if (.not.( ifail .eq. 1 )) goto 150
                  call xprinf(st0007)
150            continue
               if (.not.( ifail .eq. 2 )) goto 160
                  call xprinf(st0008)
160            continue
140         continue
            call freeud(fp, nmodel, nparam, nparas, nlink, nlinks, pinit
     *      , pdelt, xc)
            call singlt(fp)
            chisq = normcq( fp, norman )
            goto 111
110      continue
            call singlt( fp )
            chisq = normcq( fp, norman )
111      continue
         call adjnom( fp, norman )
         bestcq = chisq
         simplh = (bestcq)
         goto 100
100      return
      end
      subroutine monit (fmin, fmax, sim, n, is, ncall)
      double precision fmin
      double precision fmax
      integer n
      integer is
      integer ncall
      double precision sim(*)
      save
         goto 100
100      return
      end
      subroutine funct (n, xc, fc)
      integer n
      double precision fc
      double precision xc(*)
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
      integer fp
      integer model
      integer i
      real result
      real pvals(8)
      real pnorm
      real calccq
      real normcq
      integer fptr
      logical verboe
      integer iteran
      integer nparas
      integer nmodel(8)
      integer nparam(8)
      real norman
      real pinit(8)
      real pdelt(8)
      integer nlink((8*6)*3)
      integer nlinks
      common /nagcom/ fptr, verboe, iteran, nparas, nmodel, nparam, 
     *norman, pinit, pdelt, nlink, nlinks
      save
         fc = 0.0
         if (.not.( nparas .gt. 0 )) goto 110
            fp = fptr
            call freeud(fp, nmodel, nparam, nparas, nlink, nlinks, pinit
     *      , pdelt, xc)
            do 120 i = 1, nparas 
               model = meml(fp+16+nmodel(i)-1)
               pvals(i) = memr(model+11+1*6+nparam(i))
120         continue
121         continue
            iteran = iteran + 1
            call singlt( fp )
            model = meml(fp+16+1-1)
            if (.not.( memi(model+11+0) .eq. 2 )) goto 130
               fc = dble(normcq( fp, norman ))
               goto 131
130         continue
               fc = dble(calccq( fp ))
               norman = 1.0
131         continue
            result = fc
            pnorm= norman
            if (.not.( verboe )) goto 140
               call prntvs (iteran, result, pnorm, nparas, pvals)
140         continue
110      continue
100      return
      end
c     constp  const_fp
c     normcq  norm_chisq
c     calccq  calc_chisq
c     ctpars  ct_params
c     freeud  free_updated
c     savefs  save_fit_results
c     tolere  tolerance
c     razefp  raze_fp
c     maxits  maxiters
c     fpsinf  fp_singlef
c     nparas  nparameters
c     adjnom  adj_norm
c     tnagft  t_nagfit
c     verboe  verbose
c     fpchiq  fp_chisq
c     singlt  single_fit
c     bestcq  best_chisq
c     iteran  iteration
c     params  param_vals
c     prntvs  prntvals
c     simplh  simplex_search
c     maxpas  max_params
c     fpsmos  fp_smodels
c     paramp  param_step
c     freeps  free_params
c     norman  normalization
c     simplx  simplex
