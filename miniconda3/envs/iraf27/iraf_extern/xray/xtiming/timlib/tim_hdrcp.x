#$Header: /home/pros/xray/xtiming/timlib/RCS/tim_hdrcp.x,v 11.0 1997/11/06 16:45:11 prosb Exp $
#$Log: tim_hdrcp.x,v $
#Revision 11.0  1997/11/06 16:45:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:16  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:29  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:11:00  janet
#jd - changed binlen to a double in all timing procedures.
#
#Revision 5.0  92/10/29  23:05:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:37:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:52:57  janet
#added totcnts to hdr copy params.
#
#Revision 3.0  91/08/02  02:02:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:50:45  pros
#General Release 1.0
#
# ------------------------------------------------------------------------
#
# Module:	TIM_HDR.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	< opt, brief description of whole family, if many routines>
# External:	tim_hdr()
# Description:	hdr copy routine for timing tables
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version July 1989
#		{n} <who> -- <does what> -- <when>
#
# ------------------------------------------------------------------------

include  <tbset.h>
#include  "timplot.h"

# ------------------------------------------------------------------------
#
# Function:	tim_hdrcp
# Purpose:	Copy timing task header parameters to next table
#
# ------------------------------------------------------------------------
procedure tim_hdrcp(itp, otp)

pointer itp			# i: input table handle 
pointer otp			# i: output table handle 

pointer buf			# l: tempory buffer
pointer sregion			# l: src region buffer
pointer bregion			# l: bkgd region buffer
pointer sp			# l: space allocation pointer
int     numbins			# l: number of bins from input task
int     totcnts                 # l: net counts total
double  binlen 			# l: bin length from input task
double  starttime, stoptime	# l: data start and stop time in sc secs
double  srcarea, bkarea		# l: region from timsort

int     tbhgti()
double  tbhgtd()

begin
	call smark(sp)
	call salloc (buf, SZ_LINE, TY_CHAR)
	call salloc (sregion, SZ_LINE, TY_CHAR)
	call salloc (bregion, SZ_LINE, TY_CHAR)

#   Set the header viewspace and Label the plot with a title
	iferr ( starttime = tbhgtd (itp, "BEG_TIME") ) {
	} else {              
	   call tbhadd (otp, "beg_time", starttime)
	}
	iferr ( stoptime = tbhgtd (itp, "END_TIME") ) {               
	} else {              
	   call tbhadd (otp, "end_time", stoptime)
	} 
	iferr ( srcarea = tbhgtd (itp, "SRCAREA") ) {               
	} else {              
	   call tbhadd (otp, "srcarea", srcarea)
	} 
	iferr ( bkarea = tbhgtd (itp, "BKAREA") ) {               
	} else {              
	   call tbhadd (otp, "bkarea", bkarea)
	} 
	iferr ( binlen = tbhgtd (itp, "BINLEN") ) {
	} else {                
	   call tbhadd (otp, "binlen", binlen)
	}
	iferr ( numbins = tbhgti (itp, "NUMBINS") ) {               
	} else {
	   call tbhadi (otp, "numbins", numbins)
	}
        iferr ( totcnts = tbhgti (itp, "TOTCNTS") ) {
        } else {
           call tbhadi (otp, "totcnts", totcnts)
        }
	iferr ( call tbhgtt (itp, "S_A", Memc(sregion), SZ_LINE) ) {
	} else {
	   call cr_to_blk(Memc(sregion))
	   call tbhadt (otp, "S_A", Memc(sregion))
	}
	iferr ( call tbhgtt (itp, "B_A", Memc(bregion), SZ_LINE) ) {
	} else {
	   call cr_to_blk(Memc(bregion))
	   call tbhadt (otp, "B_A", Memc(bregion))
	}

	call sfree(sp)
end

# ----------------------------------------------------------------------------
procedure cr_to_blk (str)

char	str[ARB]
int     i

begin

	for ( i=1; str[i] != EOS; i = i+1) 
	   if ( str[i] == '\n' ) 
		str[i] = ' ';
end

