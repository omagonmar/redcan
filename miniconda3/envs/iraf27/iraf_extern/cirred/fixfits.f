c 
c Subroutine fixme.c by Mike Ressler (U. Hawaii), 15 March 1991
c Fortranified and edge effects fixed by Kris Sellgren (OSU), 03 Sept 91
c IRAF/imfort interface by Fred Hamann (OSU), 03 Sept 91
c 
c imfort removed, add CFITSIO package commands. RDB ctio 98 OCT.
c
c To run under unix:
c   fixbad mask in out method      (enter values on command line)
c or:
c   fixbad                         (will query for values)
c
c mask: FITS image of good and bad pixels; a pixel has 
c       value 0 if it is good, value 1 if it is bad
c in: FITS input image 
c out: FITS output image
c method: 0 to interpolate only over x, 1 to interpolate over
c         both x and y and average the results
c
c Note maximum image size is currently 2048x2048, but this can be easily
c  changed.
c
c *********************************************************************
c
c  This program acts as the driver for the `fixme' subroutine. It reads in 
c  IRAF format mask and data files, processes the data files using `fixme', 
c  and writes the output into new IRAF data files. 
c
      integer status,inunit,readwrite,blocksize,nfound
      integer group,firstpix
      real nullval
      logical anynull
      character errtext*30

      integer axlen(7)
      real in(2048,2048),out(2048,2048),mask(2048,2048),line(2048)
      character*30 file1,file2,mfile
      character*80 text,header(500)
      character*1 ifm

      status = 0
      blocksize=1
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
c or read in mask image file name from stdin.
c
        print*, 'Enter mask file name'
        read(5,20) mfile
      endif
c
c open the FITS mask file, with readonly access
c
      call ftgiou(inunit,status)
      readwrite=0
      call ftopen(inunit,mfile,readwrite,blocksize,status)
      if (status .gt. 0) then
        WRITE(*,*) 'Failed to open file ', mfile
        stop
      endif

c
c Obtain image dimension parameters
c
      call ftgknj(inunit,'NAXIS',1,2,axlen,nfound,status)
      if (nfound .ne. 2)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          stop
      end if
      nxm=axlen(1)
      nym=axlen(2)
c
c read the mask data
c
      group=1
      firstpix=1
      nullval=-999

      do j=1,nym 
        call ftgpve(inunit,group,firstpix,nxm,nullval,
     &              line,anynull,status)
        do i=1,nxm
	  mask(i,j) = line(i)
        end do
        firstpix=firstpix+nxm
      end do
c
c close the file and free the unit number
c
      call ftclos(inunit, status)
      call ftfiou(inunit, status)
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
c
c Or read in output image file name from stdin
c
        print*, 'Enter output data file name'
        read(5,20) file2
      endif
c
c open the FITS input file, with readonly access
c
      call ftgiou(inunit,status)
      readwrite=0
      call ftopen(inunit,file1,readwrite,blocksize,status)
      if (status .gt. 0) then
        call ftgerr(status,errtext)
	write(*,*) 'An error occured while opening the input file'
        write(*,*) errtext
        stop
      endif

c
c Obtain image dimension parameters
c
      call ftgknj(inunit,'NAXIS',1,2,axlen,nfound,status)
      if (nfound .ne. 2)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          stop
      else
        nx=axlen(1)
        ny=axlen(2)
        if(nx.ne.nxm.or.ny.ne.nym) then
          print*,' Warning!!!!!  ',
     &    'Mask and Input arrays are different sizes. STOP.'
          stop
          endif
      end if
c
c read the header info
c
      call ftghsp(inunit,nkeys,nspace,status)
c     write(*,*) 'Get header info'
c     write(*,*) 'Number of HREC',nkeys

      do i = 1, nkeys
        call ftgrec(inunit,i,header(i),status)
      end do
c
c read the input data
c
      write(*,*) 'Begin reading input image'
      group=1
      firstpix=1
      nullval=-999

      do j=1,nym 
        call ftgpve(inunit,group,firstpix,nxm,nullval,
     &              line,anynull,status)
        do i=1,nxm
          in(i,j) = line(i)
        end do
        firstpix=firstpix+nxm
      end do
c
c Check values
c
      xmin=1e99
      xmax=-1e99
      do j = 1, ny
        do i = 1, nx
          if (in(i,j).lt.xmin) xmin=in(i,j)
          if (in(i,j).gt.xmax) xmax=in(i,j)
        enddo
      enddo
      write(*,*) 'INPUT min and max =',xmin,xmax

c
c close the file and free the unit number
c
      call ftclos(inunit, status)
      call ftfiou(inunit, status)
c
c Get value of method
c Either read value of method from 4th command line parameter
c
      if (narg .ne. 0) then
        call clargi(4,method,ier)
        if(ier.ne.0)then
         call imemsg(ier,text)
         write(6,32) method,ier,text
 32      format(/,i5,i8,' ',/,a80,/)
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
c Call subroutine FIXME to fix bad pixels
c
      write(*,*) 'Begin fixing'
      call fixme(method,out,in,mask,nx,ny)

      call writeimage(file2,out,nx,ny,header,nkeys)
c
c if reading input from stdin, loop for more input files
c
      if (narg .eq. 0) then
        print*,'Want to process another file?'
        read (*,90) ifm
 90     format (a1)
        if(ifm.eq.'y') go to 10
      endif

      stop
999   end

c
c write image, from CFITSIO cookbook,f
c
      subroutine writeimage(filename,array,nx,ny,header,nkeys)

      integer status,unit,blocksize,bitpix,naxis,naxes(2),nkeys
      integer i,group,fpixel,nelements,nx,ny
      real array(nx,ny)
      character filename*30
      character*80 header(100)
      logical simple,extend

 1    status=0
      blocksize=1

C     Delete the file if it already exists, so we can then recreate it
 2    call deletefile(filename,status)
c
c Get an unused Logical Unit Number to use to open the FITS file
c
 3    call ftgiou(unit,status)

c
c create the new empty FITS file
c
 4    call ftinit(unit,filename,blocksize,status)

      simple=.true.
      bitpix=-32
      naxis=2
      naxes(1)=nx
      naxes(2)=ny
      extend=.true.
c
c write the required header keywords
c
 5    call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)

c
c write the input records to the output file
c
      do i = 1, nkeys
        call ftprec(unit,header(i),status)
      end do
c
c write the array to the FITS file
c
      group=1
      fpixel=1
      nelements=naxes(1)*naxes(2)
 6    call ftppre(unit,group,fpixel,nelements,array,status)

c
c close the file and free the unit number
c
 8    call ftclos(unit, status)
      call ftfiou(unit, status)
c
c check for any error, and if so print out error messages
c
 9    if (status .gt. 0)call printerror(status)
      return 
      end
c
c  The fixme subroutine. Interpolate over bad pixels.
c
	subroutine fixme(method,out,in,mask,nx,ny)
 
        real in(2048,2048),mask(2048,2048)
        real out(nx,ny)
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

c
c above line (and similar lines which follow) required for
c older f77 (< V3.0?) or prog will bomb while attempting
c to access element mask(0,j).
c

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

	    if (mask(i1,j) .eq. 1) then !can only happen by reaching edge

	      if (mask(i2,j) .eq. 0) then !replacement, not interp
		out(i,j) = in(i2,j)
	      else
	        out(i,j) = in(i,j)
	      endif
	    else if (mask(i2,j) .eq. 1) then
	      if (mask(i1,j) .eq. 0) then
		out(i,j) = in(i1,j)
	      else
	        out(i,j) = in(i,j)
	      endif
	    else
	      out(i,j)=(in(i2,j)-in(i1,j))*float(i-i1)/float(i2-i1)
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

c
c find indices of pixels to use for interpolation.
c

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
c
c indices for pixels used to interp done. account for edge pixels
c
	    if (i1 .lt. 1) i1 = 1
	    if (i2 .gt. nx) i2 = nx
	    if (j1 .lt. 1) j1 = 1
	    if (j2 .gt. ny) j2 = ny

	    if (mask(i1,j) .eq. 1) then
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
	      temp1 = (in(i2,j)-in(i1,j))*float(i-i1)/
     &          float(i2-i1)+in(i1,j)
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
	      temp2 = (in(i,j2)-in(i,j1))*float(j-j1)/
     &          float(j2-j1)+in(i,j1)
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
      xmin=1e99
      xmax=-1e99
      do j = 1, ny
        do i = 1, nx
          if (out(i,j).lt.xmin) xmin=out(i,j)
          if (out(i,j).gt.xmax) xmax=out(i,j)
        enddo
      enddo
      write(*,*) 'OUTPUT min and max =',xmin,xmax
	return
	end

      subroutine printerror(status)

C     Print out the FITSIO error messages to the user

      integer status
      character errtext*30,errmessage*80

C     check if status is OK (no error); if so, simply return
      if (status .le. 0)return

C     get the text string which describes the error
 1    call ftgerr(status,errtext)
      print *,'FITSIO Error Status =',status,': ',errtext

C     read and print out all the error messages on the FITSIO stack
 2    call ftgmsg(errmessage)
      do while (errmessage .ne. ' ')
          print *,errmessage
          call ftgmsg(errmessage)
      end do
      end
c
c     A simple little routine to delete a FITS file
c
      subroutine deletefile(filename,status)

      integer status,unit,blocksize
      character*(*) filename

C     simply return if status is greater than zero
      if (status .gt. 0)return

C     Get an unused Logical Unit Number to use to open the FITS file
 1    call ftgiou(unit,status)

C     try to open the file, to see if it exists
 2    call ftopen(unit,filename,1,blocksize,status)

      if (status .eq. 0)then
C         file was opened;  so now delete it
          write(*,*) 'overwriting existing output file ',filename
 3        call ftdelt(unit,status)
      else if (status .eq. 103)then
C         file doesn't exist, so just reset status to zero and clear errors
          status=0
 4        call ftcmsg
      else
C         there was some other error opening the file; delete the file anyway
          status=0
 5        call ftcmsg
          call ftdelt(unit,status)
      end if

C     free the unit number for later reuse
 6    call ftfiou(unit, status)
      end
