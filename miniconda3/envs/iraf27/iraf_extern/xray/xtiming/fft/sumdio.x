#$Header: /home/pros/xray/xtiming/fft/RCS/sumdio.x,v 11.0 1997/11/06 16:44:44 prosb Exp $
#$Log: sumdio.x,v $
#Revision 11.0  1997/11/06 16:44:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:44  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:49:18  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/02/20  17:42:21  mo
#MC	2/20/92		Add clear buffer call
#
#Revision 3.0  91/08/02  02:01:42  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:43  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       sumdio
# Project:      PROS -- ROSAT RSDC
# Purpose:      support routines for the fast fourier transform
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------


procedure  sdopen (name )

char	name[ARB]	#
int	mode		# file access mode
int	type		# file type
int	open()

int	sfd		# file descriptor

common	/sxff2t/  sfd

begin
	mode = TEMP_FILE
	type = BINARY_FILE
	sfd = open( name, mode, type)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  sdclose()

int	sfd		# file descriptor

common	/sxff2t/  sfd

begin
	call close (sfd)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure sdread (irec, buffr, nrec, nelem)

int	irec		#
int	nrec		#
int	nelem		#
int	stat		# status return from read
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length
int	read()

int	sfd		# file descriptor

common	/sxff2t/  sfd

begin
	reclen  = nelem * SZ_COMPLEX
	loffset = (irec-1) * reclen + 1
	call seek ( sfd, loffset)
	reclen = reclen * nrec
	stat = read( sfd, buffr, reclen)
	if( stat < 0 )
	    call aclrr(buffr,reclen/2)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure sdwrite (irec, buffr, nrec, nelem)

int     irec            #
int     nrec            #
int     nelem           #
real	buffr[ARB]	#
long	loffset		# offset into the file
long	reclen		# record length

int	sfd		# file descriptor

common	/sxff2t/  sfd

begin
	reclen  = nelem * SZ_COMPLEX
	loffset = (irec-1) * reclen + 1
	call seek( sfd, loffset)
	reclen = reclen * nrec
	call write( sfd, buffr, reclen)
end
