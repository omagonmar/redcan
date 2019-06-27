#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_skip.x,v 11.0 1997/11/06 16:34:47 prosb Exp $
#$Log: ft_skip.x,v $
#Revision 11.0  1997/11/06 16:34:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:55  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:45  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:38  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:54  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:44  jmoran
#Initial revision
#
#
# Module:	ft_skip.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <mach.h>
include "fits2qp.h"

#
#  FT_SKIP -- skip FITS data
#
procedure ft_skip(fd, nshorts, flag)

int	fd				# i: FITS handle
int	nshorts				# i: number of cards written
int	flag				# i: YES if we skipped data already
int	remainder			# l: left to pad
long	skip				# i: SPP CHARS to skip
long	note()				# l: get current file pos

begin
	# if we haven't skipped the data yet, add this to skip
	if( flag == NO )
	    skip = nshorts
	else
	    skip = 0
	# determine how much more than a buffer we have skipped
	remainder = mod(nshorts, FITS_BUFFER/SZB_CHAR)
	# if we are over a buffer full ...
	if( remainder !=0 )
	    # skip past next buffer full
	    skip = skip + FITS_BUFFER/SZB_CHAR - remainder
	# skip only if necessary
	if( skip !=0 )
	    call seek(fd, note(fd)+skip)
end

