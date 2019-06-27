#$Header: /home/pros/xray/xtiming/fft/RCS/bin_io.x,v 11.0 1997/11/06 16:44:23 prosb Exp $
#$Log: bin_io.x,v $
#Revision 11.0  1997/11/06 16:44:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:31  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  14:12:46  mo
#MC	10/22/92	Force a fresh copy of transform temp file
#			in each loop of summed fft
#
#Revision 4.0  92/04/27  15:31:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:43:12  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       bin_io
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
##############################################################################

include	"fft.h"


#############################################################################

procedure  wr_bins( currec, counts , segno)

int	currec		# i: current output record number
int	segno		# i:
real	counts[ARB]	# i:
pointer	sp		# stack pointer
pointer	temp_file	# name of scratch file

begin
	call smark(sp)
#	if( currec == 1 && segno == 1)
	if( currec == 1 )
	{
	    call salloc( temp_file, SZ_FNAME, TY_CHAR)
	    call mktemp( "temp", Memc[temp_file], SZ_FNAME )
	    call dopen ( Memc[temp_file] )

	    if( segno == 1 )
	    {

	    call mktemp( "temp", Memc[temp_file], SZ_FNAME )
	    call sdopen ( Memc[temp_file] )
	    call mktemp( "temp", Memc[temp_file], SZ_FNAME )
	    call popen ( Memc[temp_file] )
	    }
	}
	call dwrite ( currec , counts[1], 1, HALFNELEM)
	currec = currec+1
	call sfree (sp)

end
