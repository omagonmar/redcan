c
c  Standalone Fortran program to fix bad pixels in IRAF format
c  images using interpolation from nearest good pixels.  The unix
c  command "setenv imdir my_pixel_dir/" must be issued first to
c  let the program know that the *.pix files are kept in directory
c  "my_pixel_dir".  If the environment variable imdir is not set,
c  the program will assume that the *.pix and *.imh files are in
c  the same directory.  See IRAF manual for equivalent VMS command.
c

c
c Subroutine fixme.c by Mike Ressler (U. Hawaii), 15 March 1991
c Fortranified and edge effects fixed by Kris Sellgren (OSU), 03 Sept 91
c IRAF/imfort interface by Fred Hamann (OSU), 03 Sept 91
c

c
c To run under unix:
c   fixbad mask in out method      (enter values on command line)
c or:
c   fixbad                         (will query for values)
c
c mask: IRAF format image of good and bad pixels; a pixel has 
c       value 0 if it is good, value 1 if it is bad
c in: IRAF format input image 
c out: IRAF format output image
c method: 0 to interpolate only over x, 1 to interpolate over
c         both x and y and average the results
c
c Note maximum image size is currently 2048x2048.
c
c *********************************************************************
c
c  This program acts as the driver for the `fixme' subroutine. It reads in 
c  IRAF format mask and data files, processes the data files using `fixme', 
c  and writes the output into new IRAF data files. 
c
      real in(2048,2048),out(2048,2048),mask(2048,2048),line(2048)

      integer axlen(7),dtype,im1,im2

      character*30 file1,file2,mfile
      character*80 text
      character*1 ifm

c
c Check that correct number of command line arguments were passed;
c no arguments means query for values.
c
      call clnarg(narg)
      if (narg .lt. 4 .and. narg .ne. 0) then
	write (*,*) 'too few arguments', narg
	stop
      endif
      if (narg .gt. 4) then
	write (*,*) 'too many arguments', narg
	stop
      endif
c
c Get mask image file name
c
      if (narg .ne. 0) then
c
c Either fetch mask image file name from 1st command line argument
c
        call clargc(1,mfile,ier)
        if(ier.ne.0)then
         call imemsg(ier,text)
         write(6,30) ier,mfile,text
30       format(/,i8,' ',a30,/,a80,/)
         stop
        endif
      else
c
c Or read in mask image file name from stdin
c
        print*, 'Enter mask file name'
        read(5,20) mfile
      endif
c
c Open the IRAF mask image
c
      call imopen(mfile,1,im,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,mfile,text
        stop
      endif
c
c Obtain image dimension parameters
c
      call imgsiz(im,axlen,naxis,dtype,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,mfile,text
        stop
      endif
 
c
c     dtype = 6 for real
c
      nxm=axlen(1)
      nym=axlen(2)
c
c Read in the mask array
c
      do j = 1, nym
c       call imgs2r(im,mask,1,nxm,1,nym,ier)
        call imgl2r(im,line,j,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,30) ier,mfile,text
          stop
        endif
	do i = 1, nxm
	  mask(i,j) = line(i)
	  if (mask(i,j).ne.1.and.mask(i,j).ne.0) then
	    write (*,*) 'error mask has value not 1 or 0'
            stop
          endif
	enddo
      enddo
c
c Close the IRAF mask image
c
      call imclos(im,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,mfile,text
        stop
      endif
c
c Get input image file name
c
 10   continue
c
c Either fetch input image file name from 2nd command line argument
c
      if (narg .ne. 0) then
        call clargc(2,file1,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,30) ier,file1,text
          stop
        endif
c
c Or read in input image file name from stdin
c
      else
	print*, 'Enter input data file name'
	read(5,20) file1
 20     format(a30)
      endif
c
c Get output image file name
c Either fetch output image file name from 3rd command line argument
c
      if (narg .ne. 0) then
        call clargc(3,file2,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,30) ier,file2,text
          stop
        endif
      else
c Or read in output image file name from stdin
        print*, 'Enter output data file name'
        read(5,20) file2
      endif
c
c Open the IRAF input image
c
      call imopen(file1,1,im1,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file1,text
        stop
      endif
c
c Obtain image dimension parameters
c
      call imgsiz(im1,axlen,naxis,dtype,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file1,text
        stop
      endif
c
      nx=axlen(1)
      ny=axlen(2)
      if(nx.ne.nxm.or.ny.ne.nym) then 
        print*,' Error ',
     &    'Mask and Data arrays are different sizes. No pixels fixed.'
	stop
      endif
c
c Read in the input data array
c
      xmin=1e99
      xmax=-1e99
c     call imgs2r(im1,in,1,nx,1,ny,ier)
      do j = 1, ny
        call imgl2r(im1,line,j,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,30) ier,file1,text
          stop
        endif
       
	do i = 1, nx
   	  in(i,j) = line(i)
          if (in(i,j).lt.xmin) xmin=in(i,j)
          if (in(i,j).gt.xmax) xmax=in(i,j)
	enddo
      enddo
      write(*,*) 'INPUT min and max =',xmin,xmax
c
c Get value of method
c Either read value of method from 4th command line parameter
c
      if (narg .ne. 0) then
        call clargi(4,method,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,32) method,ier,text
 32       format(/,i5,i8,' ',/,a80,/)
          stop
        endif
        if (method .ne. 0 .and. method .ne. 1) then
	  write (*,*) 'illegal value for method (must be 0 or 1)'
    	  stop
        endif
      else
c
c Or read value of method from stdin
c
 35     write(6,40) 
 40     format(' choose interpolation method, 0=x only, 1=x and y')
        read*, method
        if(method.ne.1.and.method.ne.0)then
          print*,'Try again' 
          go to 35
        endif
      endif
c
c Create a new IRAF output image
c
c     call imcrea(file2,axlen,naxis,dtype,ier)
      call imopnc(file2,im1,im2,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file2,text
        stop
      endif
c
c Open the IRAF output image
c
      call imopen(file2,3,im2,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file2,text
        stop
      endif
c
c Call subroutine FIXME to fix bad pixels
c
      call fixme(method,out,in,mask,nx,ny)

      xmin= 1.0e99
      xmax=-1.0e99
      do i=1,nx
        do j=1,ny
          if (out(i,j).lt.xmin) xmin=out(i,j)
          if (out(i,j).gt.xmax) xmax=out(i,j)
        enddo
      enddo
      write(*,*) 'OUTPUT min and max =',xmin,xmax
c
c Write out the output data array
c
c     call imps2r(im2,out,1,nx,1,ny,ier)

      do j = 1,ny
 	do i = 1, nx
          line(i) = out(i,j) 
 	enddo
        call impl2r(im2,line,j,ier)
        if(ier.ne.0)then
          call imemsg(ier,text)
          write(6,30) ier,file2,text
          stop
        endif
      enddo

c
c Copy the IRAF image header from input image to output image
c
      call imhcpy(im1,im2,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file2,text
        stop
      endif
c
c Close the IRAF output image
c
      call imclos(im2,ier)
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file2,text
        stop
      endif
      
      if(ier.ne.0)then
        call imemsg(ier,text)
        write(6,30) ier,file1,text
        stop
      endif
c
c if reading input from stdin, loop for more input files
c
      if (narg .eq. 0) then
        print*,'Want to process another file?'
        read (*,90) ifm
 90     format (a1)
        if(ifm.eq.'y') go to 10
      endif
c
 999  end
      
c
c  ***************************************************************************
c
	subroutine fixme(method,out,in,mask,nx,ny)
 
        real in(2048,2048),mask(2048,2048)
c	real out(nx,ny)
 	real out(2048,2048)
	integer method
	integer i, j, i1, i2, j1, j2, okx, oky

	if (method .eq. 0) then
	  do i = 1, nx
	  do j = 1, ny
	  if (mask(i,j).eq.0) then   !good pixel case, ouput=input
	    out(i,j)=in(i,j)
	  else                       !bad pixel case, output=interp

c           set indices of pixels used in interpolation

	    i1=i-1
 	    if (i1 .lt. 1) i1 = 1

c           above line (and similar lines which follow) required for
c           older f77 (< V3.0?) or prog will bomb while attempting
c           to access element mask(0,j).

	    do while ((i1 .gt. 1).and.(mask(i1,j) .eq. 1)) 
	      i1=i1-1                !count back until i1 is good
	    enddo
	    i2=i+1
 	    if (i2 .gt. nx) i2 = nx
	    do while ((mask(i2,j) .eq. 1) .and. (i2 .lt. nx)) 
	      i2=i2+1                !count forward until i2 is good
	    enddo

c           account for edge

 	    if (i1 .lt. 1) i1 = 1
 	    if (i2 .gt. nx) i2 = nx

	    if (mask(i1,j) .eq. 1.0) then !can only happen by reaching edge

	      if (mask(i2,j) .eq. 0) then !replacement, not interp
		out(i,j) = in(i2,j)
	      else
	        out(i,j) = in(i,j)
	      endif

	    else if (mask(i2,j) .eq. 1.0) then
	      if (mask(i1,j) .eq. 0) then
		out(i,j) = in(i1,j)
	      else
	        out(i,j) = in(i,j)
	      endif
	    else
c	      out(i,j)=(in(i2,j)-in(i1,j))*float(i-i1)/float(i2-i1)
	      out(i,j)=(in(i2,j)-in(i1,j))*real(i-i1)/real(i2-i1)
     &          +in(i1,j)
	    endif
	  endif
	  enddo
	  enddo
	else 
	  do i = 1, nx
	  do j = 1, ny
	  okx = 1
	  oky = 1
	  if (mask(i,j).eq.0) then !good pixel case, output=input
            out(i,j)=in(i,j)
	  else                     !bad pixel case, output=interp

c           find indices of pixels to use for interpolation.

	    i1=i-1
 	    if (i1 .lt. 1) i1 = 1
	    do while ((mask(i1,j) .eq. 1) .and. (i1 .gt. 1)) 
	      i1=i1-1              !count back until i1 is not bad
	    enddo
	    i2=i+1
 	    if (i2 .gt. nx) i2 = nx
	    do while ((mask(i2,j) .eq. 1) .and. (i2 .lt. nx)) 
	      i2=i2+1              !count forward until i2 is not bad
	    enddo
	    j1=j-1
 	    if (j1 .lt. 1) j1 = 1
	    do while ((mask(i,j1) .eq. 1) .and. (j1 .gt. 1)) 
	      j1=j1-1              !same for j1
	    enddo
	    j2=j+1
 	    if (j2 .gt. ny) j2 = ny
	    do while ((mask(i,j2) .eq. 1) .and. (j2 .lt. ny)) 
	      j2=j2+1              !same for j2
	    enddo

c           indices for pixels used to interp done. 
c           account for edge pixels

 	    if (i1 .lt. 1) i1 = 1
 	    if (i2 .gt. nx) i2 = nx
 	    if (j1 .lt. 1) j1 = 1
 	    if (j2 .gt. ny) j2 = ny

	    if (mask(i1,j) .eq. 1.0) then
	      if (mask(i2,j) .eq. 0) then
		temp1 = in(i2,j)
	      else
	        temp1 = in(i,j)
		okx = 0
	      endif
	    else if (mask(i2,j) .eq. 1) then
	      if (mask(i1,j) .eq. 0) then
		temp1 = in(i1,j)
	      else
	        temp1 = in(i,j)
		okx = 0
	      endif
	    else
c	      temp1 = (in(i2,j)-in(i1,j))*float(i-i1)/
c    &          float(i2-i1)+in(i1,j)
	      temp1 = (in(i2,j)-in(i1,j))*real(i-i1)/
     &          real(i2-i1)+in(i1,j)
	    endif
	    if (mask(i,j1) .eq. 1) then
	      if (mask(i,j2) .eq. 0) then
		temp2 = in(i,j2)
	      else
	        temp2 = in(i,j)
		oky = 0
	      endif
	    else if (mask(i,j2) .eq. 1) then
	      if (mask(i,j1) .eq. 0) then
		temp2 = in(i,j1)
	      else
	        temp2 = in(i,j)
		oky = 0
	      endif
	    else
c	      temp2 = (in(i,j2)-in(i,j1))*float(j-j1)/
c    &          float(j2-j1)+in(i,j1)
	      temp2 = (in(i,j2)-in(i,j1))*real(j-j1)/
     &          real(j2-j1)+in(i,j1)
	    endif
	    if (okx .eq. 0 .and. oky .eq. 1) then
	      out(i,j)=temp2
	    else if (okx .eq. 1 .and. oky .eq. 0) then
	      out(i,j)=temp1
	    else 
	      out(i,j)=(temp1+temp2)/2.
	    endif
	  endif
	  enddo
	  enddo
	endif !end interp in x and y (method=1)

	return
	end
