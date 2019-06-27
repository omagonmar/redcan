#$Header: /home/pros/xray/xtiming/fft/RCS/ftp_table_out.x,v 11.0 1997/11/06 16:44:36 prosb Exp $
#$Log: ftp_table_out.x,v $
#Revision 11.0  1997/11/06 16:44:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:15  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:55:04  mo
#MC	7/2/93		Fix boolean test syntax
#
#Revision 6.0  93/05/24  16:57:16  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  08:51:03  mo
#MC	5/20/93	Add support for dp exposue time
#
#Revision 5.1  92/12/18  12:34:55  janet
#change tim_hdcp to spp name tim_hdrcp, changed binlen to double
#
#Revision 5.0  92/10/29  22:48:56  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  14:11:54  mo
#MC	10/22/92	Make this channel number unique to avoid any 
#			possible confusion with same name in different 
#			common block
#
#Revision 4.0  92/04/27  15:32:48  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/13  14:49:05  mo
#MC	4/13/92		Correct the 'common' name for the output
#			power table row counter to avoid confusion
#			or even actual conflict.
#
#Revision 3.2  92/02/20  17:39:28  mo
#MC	2/20/92		Add needed output table parameters for new
#			plot utilities
#
#Revision 3.1  91/12/18  15:16:48  mo
#MC	12/18/91	Add a utility to write integers to output table
#
#Revision 3.0  91/08/02  02:01:31  prosb
#General Release 1.1
#
#Revision 1.1  91/07/21  17:45:18  mo
#Initial revision
#
#Revision 2.0  91/03/06  22:43:40  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       ftp_table_out
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

procedure ftp_open(ltcurv, bkfile, histfile)
pointer	histfile		# i: input file name
pointer	ltcurv
pointer	bkfile

include	"ftptab.cmn"
pointer	tbtopn()

begin
	source = ltcurv
	bkgd = bkfile
	tpowf = tbtopn(Memc[histfile],NEW_FILE,0)
        call tbcdef(tpowf,histcolptr[1],"logel","","%8.1f",TY_REAL,1,1)
        call tbcdef(tpowf,histcolptr[2],"phist","","",TY_INT,1,1)
        call tbcdef(tpowf,histcolptr[3],"npower","","%10.2f",TY_REAL,1,1)
        call tbtcre(tpowf)
#        itp = get_intab(type)
#       call tbhcal(itp,tp)
#	logelmin= MAX_REAL
#	phistmin=MAX_REAL
#	npowermin=MAX_REAL
#	logelmax=-MAX_REAL
#	phistmax=-MAX_REAL
#	npowermax=-MAX_REAL
	prctr = 1
 
end

procedure ftp_dheader(label,value)
char    label[ARB]
double  value

include "ftptab.cmn"
begin
	    call tbhadd(tpowf,label,value)
end

procedure ftp_rheader(label,value)
char    label[ARB]
real    value

include "ftptab.cmn"
begin
	    call tbhadr(tpowf,label,value)
end

procedure ftp_iheader(label,value)
char    label[ARB]
int    value

include "ftptab.cmn"
begin
	    call tbhadi(tpowf,label,value)
end

procedure ftp_cheader(label,value)
char    label[ARB]
char    value[ARB]

include "ftptab.cmn"
begin
	    call tbhadt(tpowf,label,value)
end

procedure ftp_filehdr(sqp,bqp,dobk,start,stop,binsize,nobins,srcarea,bkarea)
pointer	sqp
pointer	bqp
bool	dobk
double	start
double	stop
double  binsize
int	nobins
real	srcarea
real	bkarea

include "ftptab.cmn"
int	type
pointer	tp,get_intab
pointer	qphead
bool	bdobk
begin
  	tp = get_intab(type)
#       call tbhcal(tp,tpowf)
        if( type == TABLE){
            call get_tbhead(tp,qphead)
            call put_tbhead(tpowf,qphead)
            call tim_hdrcp(tp,tpowf)
        }
        else if( type == QPOE){
            call get_qphead(tp,qphead)
            call put_tbhead(tpowf,qphead)
	    if( dobk )
		bdobk = TRUE
	    else
		bdobk = FALSE
	    call tim_hdr(tpowf,sqp,bqp,Memc[source],Memc[bkgd],bdobk)
            call ltc_fillhdr (tpowf, start, stop, srcarea, 
                          bkarea, binsize, nobins)
        }
        call mfree(qphead,TY_STRUCT)
#  write header value used in plotting -jd
#       call tbhadr(tpowf,"FREQFAC",1./ffactor)
        call ftp_cheader("","")
        call ftp_cheader("TASKINFO","The following parameters reflect the outcome of the fft task")
end


procedure ftp_write(phist,phistsize,nbins,mean)
int	phist[ARB]
int	nbins			# i: number of rows to write
real	phistsize		# i: size of histogram bins
real	mean

int	i			# l: loop counter

include	"ftptab.cmn"
int	lmin
int	lmax
int	histmin
int	histmax
int	total
real	lpower
real	bincent
real	pmin,pmax

begin

#  Default is to write all elements out
	i=1

        histmin= MAX_INT
        histmax=-MAX_INT
        lmin= -1
        lmax=-MAX_INT
	pmin = MAX_REAL
	pmax = -MAX_REAL
        total = 0
 
        do i=1,nbins
        {
            if( phist[i] > 0 )
                lpower = log10(float(phist[i]))
            else
                lpower = -1.0E0
	    bincent = float((i-1))*phistsize+phistsize/2.0E0
            lmin = min( lmin, int(lpower)+1)
            lmax = max( lmax, int(lpower)+1)
            histmin = min( histmin, phist[i])
            histmax = max( histmax, phist[i])
	    pmin = min( bincent, pmin)
	    pmax = max( bincent, pmax)
            call tbrptr(tpowf,histcolptr[1],lpower,1,prctr)
            call tbrpti(tpowf,histcolptr[2],phist[i],1,prctr)
            call tbrptr(tpowf,histcolptr[3],bincent,1,prctr)
            total = total + phist[i]
            prctr=prctr+1
        }
        call tbhadi(tpowf,"PHISTMN",histmin)
        call tbhadi(tpowf,"PHISTMX",histmax)
        call tbhadi(tpowf,"LOGELMN",lmin)
        call tbhadi(tpowf,"LOGELMX",lmax)
        call tbhadi(tpowf,"NPOWERMN",int(pmin))
        call tbhadi(tpowf,"NPOWERMX",int(pmax+.5E0))
        call tbhadi(tpowf,"TOTAL",total)
        call tbhadr(tpowf,"MEAN",mean)
end


procedure ftp_close()

include	"ftptab.cmn"

begin
  	call tbtclo(tpowf)
end

