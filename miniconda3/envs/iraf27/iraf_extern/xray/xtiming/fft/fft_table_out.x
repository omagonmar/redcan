#$Header: /home/pros/xray/xtiming/fft/RCS/fft_table_out.x,v 11.0 1997/11/06 16:44:32 prosb Exp $
#$Log: fft_table_out.x,v $
#Revision 11.0  1997/11/06 16:44:32  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:01  prosb
#General Release 2.3
#
#Revision 6.1  93/06/11  17:20:59  mo
#no changes
#
#Revision 6.0  93/05/24  16:57:00  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  08:50:18  mo
#MC	5/20/93		Add support for dp exposure time
#
#Revision 5.1  92/12/18  12:34:15  janet
#change tim_hdcp to spp name tim_hdrcp, changed binlen to double
#
#Revision 5.0  92/10/29  22:48:46  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  14:10:07  mo
#MC	10/22/92	Put final header parameters alphabetical order -
#			see if this is more efficient
#
#Revision 4.0  92/04/27  15:32:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:25  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  17:43:45  mo
#MC	7/21/91		Update the output file with a normalized power
#			column and header parameters for TIMPLOT
#
#Revision 2.0  91/03/06  22:43:40  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       fft_table_out
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
include	<mach.h>
include <qpoe.h>
include	"fft.h"

procedure fft_open(outfft,ltcurv, bkfile, fftfile)
bool	outfft
pointer	fftfile		# i: input file name
pointer	ltcurv
pointer	bkfile

include	"ffttab.cmn"
pointer	tbtopn()

begin
	wrfft = outfft
	source = ltcurv
	bkgd = bkfile
	if( wrfft ){
	tpf = tbtopn(Memc[fftfile],NEW_FILE,0)
	call tbcdef(tpf,freqcolptr,"freq","","%12.11f",TY_REAL,1,1)
	call tbcdef(tpf,rfreqcolptr,"rfreq","","%12.5f",TY_REAL,1,1)
	call tbcdef(tpf,ifreqcolptr,"ifreq","","%12.5f",TY_REAL,1,1)
	call tbcdef(tpf,powercolptr,"power","","%12.5f",TY_REAL,1,1)
	call tbcdef(tpf,normcolptr,"normpower","","%12.5f",TY_REAL,1,1)
	call tbtcre(tpf)
	freqmin = MAX_REAL
	rfreqmin=MAX_REAL
	ifreqmin=MAX_REAL
	powermin=MAX_REAL
	npowermin=MAX_REAL
	freqmax=-MAX_REAL
	rfreqmax=-MAX_REAL
	ifreqmax=-MAX_REAL
	powermax=-MAX_REAL
	npowermax=-MAX_REAL
	rctr = 1
	}
end


procedure fft_cheader(label,value)
char    label[ARB]
char    value[ARB]

include "ffttab.cmn"
begin
	if( wrfft)
	    call tbhadt(tpf,label,value)
end

procedure fft_rheader(label,value)
char    label[ARB]
real	value

include "ffttab.cmn"
begin
	if( wrfft)
	    call tbhadr(tpf,label,value)
end

procedure fft_dheader(label,value)
char    label[ARB]
double	value

include "ffttab.cmn"
begin
	if( wrfft)
	    call tbhadd(tpf,label,value)
end

procedure fft_iheader(label,value)
char    label[ARB]
int	value

include "ffttab.cmn"
begin
	if( wrfft)
	    call tbhadi(tpf,label,value)
end

procedure fft_filehdr(sqp,bqp,dobk,start,stop,binsize,nobins,srcarea,bkarea)

pointer	sqp
pointer	bqp

int	dobk
int	nobins

double	start
double	stop
double  binsize
double	srcarea
double	bkarea

include "ffttab.cmn"

pointer	tp, get_intab
pointer	qphead
bool	bdobk
int	type

begin
	if( wrfft){
        if( dobk == YES )
            bdobk = TRUE
        else
            bdobk = FALSE
        tp = get_intab(type)
#       call tbhcal(tp,tpf)
        if( type == TABLE){
            call get_tbhead(tp,qphead)
            call put_tbhead(tpf,qphead)
            call mfree(qphead,TY_STRUCT)
            call tim_hdrcp(tp,tpf)
        }
        else if( type == QPOE){
#            call get_qphead(tp,qphead)
#            call put_tbhead(tpf,qphead)
	    call tim_hdr(tpf,sqp,bqp,Memc[source],Memc[bkgd],bdobk)
            call ltc_fillhdr (tpf, start, stop, srcarea, 
                              bkarea, binsize, nobins)
        }
#  write header value used in plotting -jd
#       call tbhadr(tpf,"FREQFAC",1./ffactor)
        call fft_cheader("","")
        call fft_cheader("TASKINFO","The following parameters reflect the outcome of the fft task")
}
end

procedure hist_filehdr(tp,sqp,bqp,dobk)
pointer tp
pointer	sqp
pointer	bqp
int	dobk
bool	bdobk

include "ffttab.cmn"
begin
	if( dobk == YES )
	    bdobk = TRUE
	else
	    bdobk = FALSE
	call tim_hdr(tp,sqp,bqp,Memc[source],Memc[bkgd],bdobk)
end

procedure fft_write(distrib,pdistrib,nrows,ffactor,norm)
real	distrib[2,ARB]		# i: fft freq distrib ( really complex )
real	pdistrib[ARB]		# i: fft power histogram
int	nrows			# i: number of rows to write
real	ffactor			# i: frequency per bin
real	norm			# i: power normalization factor

int	i,j			# l: loop counter
real	jfactor			# l: freq of jth bin

real	npower
include	"ffttab.cmn"

begin

	if( wrfft){
#  Default is to write all elements out
	i=1

#  Write the 0th order power store in elem 1 to the header
#  Start with 2nd element in arrays to output
	if ( rctr == 1 ) {
	    call fft_zero_order (distrib[1,1], pdistrib[1], ffactor )
	    i=2
	}
	do j=i,nrows
	{
	    npower = pdistrib[j]*norm
	    jfactor = ffactor*rctr
	    freqmin = min( freqmin, jfactor)
	    rfreqmin = min( rfreqmin, distrib[1,j])
	    ifreqmin = min( ifreqmin, distrib[2,j])
	    powermin = min( powermin, pdistrib[j])
	    npowermin = min( npowermin, npower) 
	    freqmax = max( freqmax, jfactor)
	    rfreqmax = max( rfreqmax, distrib[1,j])
	    ifreqmax = max( ifreqmax, distrib[2,j])
	    powermax = max( powermax, pdistrib[j])
	    npowermax = max( npowermax, npower)
	    call tbrptr(tpf,freqcolptr,jfactor,1,rctr)
	    call tbrptr(tpf,rfreqcolptr,distrib[1,j],1,rctr)
	    call tbrptr(tpf,ifreqcolptr,distrib[2,j],1,rctr)
	    call tbrptr(tpf,powercolptr,pdistrib[j],1,rctr)
	    call tbrptr(tpf,normcolptr,npower,1,rctr)
	    rctr=rctr+1
	}
	}
end

procedure fft_zero_order (distrib, pdistrib,ffactor)
real	distrib			# i: fft freq distrib ( really complex )
real	pdistrib		# i: fft power histogram
real	ffactor			# i: freq per bin

include	"ffttab.cmn"

begin

	if( wrfft){
#  Write the 0th order power store in elem 1 to the header
	call tbhadr(tpf,"0RFREQ",distrib)
	call tbhadr(tpf,"0POWER",pdistrib)
	call tbhadr(tpf,"0FREQ",ffactor)
	}
end
	

procedure fft_close(noseg)

int noseg
include	"ffttab.cmn"

begin
	if( wrfft ){
	call tbhadr(tpf,"FREQMN",freqmin)
	call tbhadr(tpf,"FREQMX",freqmax)
	call tbhadr(tpf,"IFREQMN",ifreqmin)
	call tbhadr(tpf,"IFREQMX",ifreqmax)
	call tbhadr(tpf,"NPOWERMN",npowermin)
	call tbhadr(tpf,"NPOWERMX",npowermax)
	call tbhadr(tpf,"POWERMN",powermin)
	call tbhadr(tpf,"POWERMX",powermax)
	call tbhadr(tpf,"RFREQMN",rfreqmin)
	call tbhadr(tpf,"RFREQMX",rfreqmax)
	call tbtclo(tpf)
	}
end

