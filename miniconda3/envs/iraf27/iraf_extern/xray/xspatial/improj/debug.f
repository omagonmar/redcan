      integer function dps (arr, n)
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
      integer arr
      integer n
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,100, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i-1)
            call pargs (mems(arr+i-1))
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dps = (1)
         goto 100
100      return
      end
      integer function dpi (arr, n)
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
      integer arr
      integer n
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,100, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i-1)
            call pargi (memi(arr+i-1))
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dpi = (1)
         goto 100
100      return
      end
      integer function dpr (arr, n)
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
      integer arr
      integer n
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,102, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i-1)
            call pargr (memr(arr+i-1))
            call xffluh(4)
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dpr = (1)
         goto 100
100      return
      end
      integer function dpd (arr, n)
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
      integer arr
      integer n
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,102, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i-1)
            call pargd (memd(arr+i-1))
            call xffluh(4)
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dpd = (1)
         goto 100
100      return
      end
      integer function dpc (arr)
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
      integer arr
      integer*2 st0001(4)
      save
      data st0001 / 37,115, 10, 0/
         call xprinf(st0001)
         call pargsr (memc(arr))
         call xffluh(4)
         dpc = (1)
         goto 100
100      return
      end
      integer function das (arr, n)
      integer n
      integer*2 arr(*)
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,100, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i)
            call pargs (arr(i))
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         das = (1)
         goto 100
100      return
      end
      integer function dai (arr, n)
      integer n
      integer arr(*)
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,100, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i)
            call pargi (arr(i))
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dai = (1)
         goto 100
100      return
      end
      integer function dar (arr, n)
      integer n
      real arr(*)
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,102, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i)
            call pargr (arr(i))
            call xffluh(4)
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dar = (1)
         goto 100
100      return
      end
      integer function dad (arr, n)
      integer n
      double precision arr(*)
      integer i
      integer*2 st0001(8)
      integer*2 st0002(2)
      save
      data st0001 / 37,100, 58, 32, 37,102, 44, 0/
      data st0002 / 10, 0/
         do 110 i = 1, n 
            call xprinf(st0001)
            call pargi (i)
            call pargd (arr(i))
            call xffluh(4)
110      continue
111      continue
         call xprinf(st0002)
         call xffluh(4)
         dad = (1)
         goto 100
100      return
      end
      integer function dac (arr)
      integer*2 arr(*)
      integer*2 st0001(4)
      save
      data st0001 / 37,115, 10, 0/
         call xprinf(st0001)
         call pargsr (arr)
         call xffluh(4)
         dac = (1)
         goto 100
100      return
      end
c     pargsr  pargstr
