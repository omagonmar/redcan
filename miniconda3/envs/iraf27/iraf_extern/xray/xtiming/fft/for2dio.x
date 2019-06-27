#$Header: /home/pros/xray/xtiming/fft/RCS/for2dio.x,v 11.0 1997/11/06 16:44:35 prosb Exp $
#$Log: for2dio.x,v $
#Revision 11.0  1997/11/06 16:44:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:17  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:13  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:32:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/02/20  17:43:25  mo
#MC	2/20/92		Add parentheses to procedure with no
#			arguments for easier code maintenance
#
#Revision 3.0  91/08/02  02:01:30  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:55  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       for2dio
# Project:      PROS -- ROSAT RSDC
# Purpose:	These routines perform file I/O for the spp FFT routines.
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Adam Szczypek initial version  August 1990
#
# -------------------------------------------------------------------------


procedure  dopen (name )

char	name[ARB]	#
int	mode		# file access mode
int	type		# file type
int	open()

int	fd		# file descriptor

common	/xff2t/  fd

begin
#	mode = READ_WRITE
	mode = TEMP_FILE
#	mode = NEW_FILE
	type = BINARY_FILE
	fd = open( name, mode, type)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  dclose()

int	fd		# file descriptor

common	/xff2t/  fd

begin
	call close (fd)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure dread (irec, buffr, nrec, nelem)

int	irec		#
int	nrec		#
int	nelem		#
int	stat		# status return from read
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length
int	read()

int	fd		# file descriptor

common	/xff2t/  fd

begin
	reclen  = nelem * SZ_COMPLEX
	loffset = (irec-1) * reclen + 1
	call seek ( fd, loffset)
	reclen = reclen * nrec
	stat = read( fd, buffr, reclen)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure dwrite (irec, buffr, nrec, nelem)

int     irec            #
int     nrec            #
int     nelem           #
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length

int	fd		# file descriptor

common	/xff2t/  fd

begin
	reclen  = nelem * SZ_COMPLEX
	loffset = (irec-1) * reclen + 1
	call seek( fd, loffset)
	reclen = reclen * nrec
	call write( fd, buffr, reclen)
end
