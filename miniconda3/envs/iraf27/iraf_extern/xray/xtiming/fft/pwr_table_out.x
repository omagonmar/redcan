#$Header: /home/pros/xray/xtiming/fft/RCS/pwr_table_out.x,v 11.0 1997/11/06 16:44:42 prosb Exp $
#$Log: pwr_table_out.x,v $
#Revision 11.0  1997/11/06 16:44:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:39  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:34  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:36  prosb
#General Release 2.2
#
#Revision 5.1  92/12/18  12:35:13  janet
#change tim_hdcp to spp name tim_hdrcp, changed binlen to double
#
#Revision 5.0  92/10/29  22:49:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:33:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  02:01:38  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  17:48:50  mo
#MC	7/21/91		Update for the normalized power column output
#
#Revision 2.0  91/03/06  22:44:28  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       pwr_table_out
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
include <mach.h>
include <qpoe.h>
include <clk.h>
include	"fft.h"

procedure pwr_open(lt_curv,back_file,critfile)
pointer	lt_curv
pointer	back_file
pointer	critfile		# i: output filename

pointer	tbtopn()
#pointer	refclk
include "pwrtab.cmn"

begin
	source = lt_curv
	bkgd = back_file
	tp = tbtopn(Memc[critfile],NEW_FILE,0)
        call tbcdef(tp,bincolptr,"bin","","",TY_INT,1,1)
        call tbcdef(tp,freqcolptr,"freq","","",TY_REAL,1,1)
        call tbcdef(tp,cpowercolptr,"power","","",TY_REAL,1,1)
        call tbcdef(tp,npowercolptr,"npower","","",TY_REAL,1,1)
        call tbtcre(tp)
        xrctr = 1
        npowermin = MAX_REAL
        npowermax = -MAX_REAL
        cpowermin = MAX_REAL
        cpowermax = -MAX_REAL
        freqmin = MAX_REAL
        freqmax = -MAX_REAL
        binmin = MAX_INT
        binmax = -MAX_INT
end


procedure pwr_cheader(label,value)
char	label[ARB]
char	value[ARB]

include "pwrtab.cmn"
begin
	call tbhadt(tp,label,value)
end

procedure pwr_dheader(label,value)
char	label[ARB]
double  value

include "pwrtab.cmn"
begin
	call tbhadd(tp,label,value)
end

procedure pwr_rheader(label,value)
char	label[ARB]
real	value

include "pwrtab.cmn"
begin
	call tbhadr(tp,label,value)
end

procedure pwr_iheader(label,value)
char	label[ARB]
int	value

include "pwrtab.cmn"
begin
	call tbhadi(tp,label,value)
end

procedure pwr_filehdr(sqp,bqp,dobk,start,stop,binsize,nobins,srcarea,bkarea)
pointer	sqp
pointer	bqp
bool	dobk
double	start
double	stop
double  binsize
int	nobins
double	srcarea
double  bkarea
include "pwrtab.cmn"
pointer	itp,get_intab()
pointer	qphead
int	type
begin
        itp = get_intab(type)
#       call tbhcal(itp,tp)
        if( type == TABLE ){
            call get_tbhead(itp,qphead)
            call put_tbhead(tp,qphead)
            call tim_hdrcp(itp,tp)
            call mfree(qphead,TY_STRUCT)
	}
        else if(type == QPOE){
#            call get_qphead(itp,qphead)
#            call put_tbhead(tp,qphead)
	    call tim_hdr(tp,sqp,bqp,Memc[source],Memc[bkgd],dobk)
            call ltc_fillhdr (tp, start, stop, srcarea, 
                          bkarea, binsize, nobins)
	}
#        call mfree(refclk,TY_STRUCT)
end

procedure pwr_write(binno,freq,pdistrib,normpower)
int	binno		# i: fft bin number

real	freq		# i: frequency  of current bin
real	pdistrib	# i: power value
real	normpower	# i: normalized power value

include "pwrtab.cmn"

begin

# ** jd kludge ** for AAS ----- bin num 1 don't write check
   if ( binno != 0 ) {
	call tbrpti(tp,bincolptr,binno,1,xrctr)
        call tbrptr(tp,freqcolptr,freq,1,xrctr)
	call tbrptr(tp,cpowercolptr,pdistrib,1,xrctr)
	call tbrptr(tp,npowercolptr,normpower,1,xrctr)
	xrctr = xrctr +1
	freqmin = min(freqmin,freq)
	freqmax = max(freqmax,freq)
	npowermin = min( npowermin , normpower)
	npowermax = max( npowermax , normpower)
	cpowermin = min( cpowermin , pdistrib)
	cpowermax = max( cpowermax , pdistrib)
	binmin = min( binmin, binno)
	binmax = max( binmax, binno)
   }

end


procedure pwr_close()

include "pwrtab.cmn"

begin
	call tbhadi(tp,"BINMN",binmin)
	call tbhadi(tp,"BINMX",binmax)
	call tbhadr(tp,"FREQMN",freqmin)
	call tbhadr(tp,"FREQMX",freqmax)
	call tbhadr(tp,"POWERMN",cpowermin)
	call tbhadr(tp,"POWERMX",cpowermax)
	call tbhadr(tp,"NPOWERMN",npowermin)
	call tbhadr(tp,"NPOWERMX",npowermax)
	call tbtclo(tp)
end

