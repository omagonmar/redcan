      program calc_off

c     program used in shift_comb.cl task. read file calc_off.in
c     which is the value of the shift_comb param coords_xc. subtract
c     each line from the first line. output into calc_off.out.

      real x(100), y(100)

      open(unit=1,file='calc_off.in',status='old')
      open(unit=2,file='calc_off.ot',status='unknown')
      open(unit=3,file='calc_off.ot1',status='unknown')
      open(unit=4,file='calc_off.ot2',status='unknown')

      i=1
10    read(1,*,end=100) x(i),y(i)
      i=i+1
      go to 10

100   continue

      xmax=1e-99
      ymax=1e-99
   
      n=i-1

      doi=1,n
        if(x(i).gt.xmax) xmax=x(i)
        if(y(i).gt.ymax) ymax=y(i)
      enddo

c      write(*,*) xmax,ymax

      do i=1,n
        write(2,*)  -(x(i) - xmax),  -(y(i) - ymax)
        write(3,*)  -(( x(i)-xmax ) - int( x(i)-xmax )),
     >              -(( y(i)-ymax ) - int( y(i)-ymax ))
        write(4,*)  -int( x(i)-xmax ),  -int( y(i)-ymax )
      enddo

      stop  
      end
