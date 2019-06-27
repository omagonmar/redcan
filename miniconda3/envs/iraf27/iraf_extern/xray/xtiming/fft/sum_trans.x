#$Header: /home/pros/xray/xtiming/fft/RCS/sum_trans.x,v 11.0 1997/11/06 16:44:44 prosb Exp $
#$Log: sum_trans.x,v $
#Revision 11.0  1997/11/06 16:44:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:41  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  08:48:07  mo
#MC	5/20/93	Fix SUMMED FFT for <512 bins
#
#Revision 5.0  92/10/29  22:49:16  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  17:54:12  mo
#*** empty log message ***
#
#Revision 4.0  92/04/27  15:33:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  14:42:13  mo
#MC	4/13/92		Correct the powerhist size and make the
#			summing conditional on being > 1 segment
#
#Revision 3.1  92/02/20  17:42:54  mo
#MC	2/20/92		Add better memory buffer handling
#
#Revision 3.0  91/08/02  02:01:42  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  22:44:39  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       sum_trans
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
#########################################################################

include	<mach.h>
include	"fft.h"

procedure  sum_transforms(  nbins,segno)

int	segno			# i: current segment number
int	nbins			# i: number of bins for FFT ( power of 2)
int	currec			# l: current internal fft record counter
int	j			# l: loop indices
int	nf			# l: Nyquist binno
int	lastrec
include	"sumtrans.cmn"

pointer temptran

begin
	if( segno == 1){
	    call malloc (transform, NELEM , TY_REAL)
	    call malloc (stransform, NELEM , TY_REAL)
	    call malloc (powerdist, HALFNELEM , TY_REAL)
	}
	currec = 1
# Only the first half of the FFT result is meaningful
	while( HALFNELEM*(currec-1) <= nbins )
	{
#       Read the next buffer full of FFT results
	    call aclrr (Memr[stransform], NELEM)
	    call aclrr (Memr[transform], NELEM)
	    call aclrr (Memr[powerdist], HALFNELEM)
	    call dread( currec, Memr[transform], 1, HALFNELEM)
	    if( segno > 1 )   #  File is written first time and
			      #  added to on subsequent calls
	    {
	        call sdread( currec, Memr[stransform], 1, HALFNELEM)
	        call pread( currec, Memr[powerdist], 1, HALFNELEM)
	    }
	    do j = 1, min(nbins,HALFNELEM)
	    {
		call sumall(j,Memr[transform],Memr[stransform],Memr[powerdist])
	    }

#  Last BIN
#  Special index for the LAST value 
#                if( binno == nf - 1){
                if( nbins <= NELEM){
		    nf = nbins/2+1
                    lastrec = max(currec,(nf)/NELEM + 1 + NELEM/HALFNELEM)
                    if( lastrec != currec ){
	    		call calloc (temptran, NELEM , TY_REAL)
                        call dread( lastrec, Memr[temptran], 1, HALFNELEM )
                        Memr[transform+2*(nf-1)] = Memr[temptran]
                        Memr[transform+2*(nf-1)+1] = Memr[temptran+1]
	    		call aclrr (Memr[temptran], NELEM)
                        call sdread( lastrec, Memr[temptran], 1, HALFNELEM )
                        Memr[stransform+2*(nf-1)] = Memr[temptran]
                        Memr[stransform+2*(nf-1)] = Memr[temptran+1]
		        call sumall(nf,Memr[transform],Memr[stransform],Memr[powerdist])
                    }
                }
#
#  Last BIN

	    call sdwrite( currec, Memr[stransform], 1, HALFNELEM)
	    call pwrite(currec, Memr[powerdist], 1, HALFNELEM)
#       Save the fft transform and power density distribution
	     currec = currec + 1
	}
end

procedure sum_free()
include	"sumtrans.cmn"
begin
	call mfree(transform,TY_REAL)
	call mfree(stransform,TY_REAL)
	call mfree(powerdist,TY_REAL)
end

procedure sumall(index,transform,stransform,powerdist)

int	index
real	transform[2,ARB]
real	stransform[2,ARB]
real	powerdist[ARB]
begin
	stransform[1,index] = stransform[1,index] + transform[1,index]
	stransform[2,index] = stransform[2,index] + transform[2,index]
	powerdist[index] = powerdist[index] + 
			   transform[1,index] * transform[1,index] +
			   transform[2,index] * transform[2,index]
end
