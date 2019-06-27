#$Header: /home/pros/xray/xtiming/fft/RCS/spowerdio.x,v 11.0 1997/11/06 16:44:43 prosb Exp $
#$Log: spowerdio.x,v $
#Revision 11.0  1997/11/06 16:44:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:42  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:36  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:14  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  14:47:59  mo
#MC	4/13/92		Correct length of power histogram from COMPLEX
#			( this is only for coefficients) to REAL which
#			is correct for power
#
#Revision 3.1  92/02/20  17:39:51  mo
#MC	2/20/92		Fix type in common block name and add
#			other fixes to summed fft options
#
#Revision 3.0  91/08/02  02:01:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:36  pros
#General Release 1.0
#

#	These routines perform the file I/O for the FORTRAN FFT routines.
#
#						A. Szczypek   May 1987

##########################################################################

procedure  popen (name )

char	name[ARB]	#
int	mode		# file access mode
int	type		# file type
int	open()

int	pfd		# file descriptor

common	/pxff2t/  pfd

begin
#	mode = READ_WRITE
	mode = TEMP_FILE
#	mode = NEW_FILE
	type = BINARY_FILE
	pfd = open( name, mode, type)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  pclose()

int	pfd		# file descriptor

common	/pxff2t/  pfd

begin
	call close (pfd)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure pread (irec, buffr, nrec, nelem)

int	irec		#
int	nrec		#
int	nelem		#
int	stat		# status return from read
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length
int	read()

int	pfd		# file descriptor

common	/pxff2t/  pfd

begin
	reclen  = nelem * SZ_REAL
	loffset = (irec-1) * reclen + 1
	call seek ( pfd, loffset)
	reclen = reclen * nrec
	stat = read( pfd, buffr, reclen)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure pwrite (irec, buffr, nrec, nelem)

int     irec            #
int     nrec            #
int     nelem           #
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length

int	pfd		# file descriptor

common	/pxff2t/  pfd

begin
	reclen  = nelem * SZ_REAL
	loffset = (irec-1) * reclen + 1
	call seek( pfd, loffset)
	reclen = reclen * nrec
	call write( pfd, buffr, reclen)
end
