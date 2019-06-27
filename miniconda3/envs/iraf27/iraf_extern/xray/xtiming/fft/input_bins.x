#$Header: /home/pros/xray/xtiming/fft/RCS/input_bins.x,v 11.0 1997/11/06 16:44:38 prosb Exp $
#$Log: input_bins.x,v $
#Revision 11.0  1997/11/06 16:44:38  prosb
#General Release 2.5
#
#Revision 9.2  1996/04/17 13:53:07  prosb
##JCC - Add "int ltc_rd_hd"
#
#Revision 9.1  96/04/16  17:13:40  prosb
#JCC - Updated tb_rd_hd() to fix the compiling error on LINUX.
#      [ Replaced "call ltc_rd_hd()" with "temp = ltc_rd_hd()" ]
#
#Revision 9.0  95/11/16  19:33:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:23  prosb
#General Release 2.3
#
#Revision 6.1  93/12/17  10:38:59  mo
#MC	12/10/93	Fix ERROR that had NET and CTRT columns interchanged
#			and initialize bknorm=1.0, while adding ERRTYPE
#			parameter to calling sequence
#
#Revision 6.0  93/05/24  16:57:25  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  08:46:23  mo
#MC	5/20/93	ADd support for exposure time
#
#Revision 5.1  92/12/18  12:36:27  janet
#changed binlen to double.
#
#Revision 5.0  92/10/29  22:49:03  prosb
#General Release 2.1
#
#Revision 4.3  92/09/29  14:09:30  mo
#MC	9/29/92		Updated calling sequencs for begs and ends rather
#			than 2 dimensional GTIs
#
#Revision 4.2  92/09/04  17:38:01  mo
#MC	9/4/92		Made the 'exp' column optional.  If not present
#			warning to user of no exposure screening
#
#Revision 4.1  92/09/04  11:10:05  mo
#MC	9/4/92		Add 4 'clgetd' calls for needed parameters, if not
#			found in input lightcurve table header.
#			( SRCAREA, BINLEN, BEG_TIME, END_TIME )
#			This will allow the program to run on 'foreign' 
#			light curve files
#
#Revision 4.0  92/04/27  15:33:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/13  14:46:28  mo
#MC	4/13/92		Correct code to keep record counter for 
#			source and background separate and to support
#			all the same options as ltcurv ( e.g. bk, exp, net, ctrt)
#
#Revision 3.3  92/02/20  17:41:43  mo
#MC	2/20/92		Add arguments to pass back start and stop
#			times when input is a table file
#
#Revision 3.2  92/02/06  17:31:01  mo
#MC	2/5/92		No changes
#
#Revision 3.1  91/09/25  17:24:40  mo
#9/25/91	JD/MC	Update program to allow input QPOE background 
#			file and correct GOOD TIME intervals with user
#			specified FILTER parameter.
#
#Revision 2.0  91/03/06  22:44:07  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       INPUT_BINS.x 
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
#  INPUT_BINS.X   ---   to get a LTC table file into local array space 

include	<gset.h>
include	<tbset.h>
include	<ext.h>
#include "filelist.h"
include	"ltcio.h"
include	 "fft.h"
include	"binpars.h"
include	"../timlib/timing.h"
define	FFT_FATAL	1

procedure	tb_cls_bin(tp)
pointer	tp
begin
	call tbtclo(tp)
end

procedure	qp_cls_bin(ltcio)
pointer	ltcio
begin
	if( DOBKGD(ltcio) == YES)
	    call tim_qpclose(BQP(ltcio),BQPIO(ltcio))
	else
	    call tim_qpclose(SQP(ltcio),SQPIO(ltcio))
end

int  procedure  ltc_rd_hd ( tp, nbins, binlen, area, start, stop )

int	 tp			# i: input file descriptor
int	 nbins			# o: number of photons expected
double   area			# o: area of photon collection
double   binlen			# o: no secs per bin
double	 start,stop		# o: start and stop times from file

int	answer
int	parnum
int	tbpsta()
double	clgetd()
double  tbhgtd()

begin
	area = 0.0D0

	nbins = tbpsta(tp,TBL_NROWS)
        # check for existence of parameter
        call tbhfkw(tp, SRCAREA, parnum)
        # if parnum ==0, param does not exist
        if( parnum ==0 )
	    area= clgetd("srcarea")
	else
	    area = tbhgtd(tp,SRCAREA)
        # check for existence of parameter
        call tbhfkw(tp, BINLEN, parnum)
        # if parnum ==0, param does not exist
        if( parnum ==0 )
	    binlen = clgetd("binlen")
	else
	    binlen = tbhgtd(tp,BINLEN)

        # check for existence of parameter
        call tbhfkw(tp, "BEG_TIME", parnum)
        # if parnum ==0, param does not exist
        if( parnum ==0 )
	    start = clgetd("begtime")
	else
	    start = tbhgtd(tp,"BEG_TIME")
        # check for existence of parameter
        call tbhfkw(tp, "END_TIME", parnum)
        # if parnum ==0, param does not exist
        if( parnum ==0 )
	    stop = clgetd("endtime")
	else
	stop = tbhgtd(tp,"END_TIME")
	answer = OK
    
#	if( answer == EOF )
#	    call printf( " Got unexpected EOF reading ISF header.\n" )
	return (answer)
end


procedure qp_rd_hd(display,photon_file,bk_file,datacol,ltcio,binpars,
		   num_of_bins,gbegs,gends,num_gintvs,duration,minmax,exposure)
int	display
char	photon_file[ARB]
char	bk_file[ARB]
char	datacol[ARB]
pointer	ltcio
pointer	binpars
int	num_of_bins
pointer	gbegs
pointer	gends
int	num_gintvs
double	duration
pointer	minmax
pointer	sp
#pointer	bk_file
real	exposure
int	abbrev()
pointer	src_filter,bkg_filter

double  acctime			# l: sum of gtis, accepted time

bool	none

begin
	call smark(sp)
#	call salloc(bk_file,SZ_PATHNAME,TY_CHAR)
	call salloc(bkg_filter,SZ_PATHNAME,TY_CHAR)
	call salloc(src_filter,SZ_PATHNAME,TY_CHAR)

	call tim_openqpf(photon_file,Memc[src_filter],EXT_STI,none,SQP(ltcio),
			SQPIO(ltcio))
	call tim_cktime(SQP(ltcio),"source",SOFFSET(ltcio))
	call tim_getarea(SQP(ltcio),SRC_AREA(ltcio))

#	call tim_openqp(BKGRDFILENAME,EXT_BTI,Memc[bk_file],Memc[bkg_filter],
#                        none,BQP(ltcio),BQPIO(ltcio))
 	call tim_openqpf(bk_file,Memc[bkg_filter],EXT_BTI, none,BQP(ltcio),
                         BQPIO(ltcio))

#      call printf("just opened bk with filter = %s ... qpoe filter %s\n")
#        call pargstr (Memc[bkg_filter])
#        call pargstr (Memc[src_filter])
#      call flush (STDOUT)

#	none = TRUE
	if( none)
	    DOBKGD(ltcio) = NO
	else
	    DOBKGD(ltcio) = YES
	if( DOBKGD(ltcio)==1){
	    call tim_cktime(BQP(ltcio),"bkgd",BOFFSET(ltcio))
	    call tim_getarea(BQP(ltcio),BK_AREA(ltcio))
	}

#	call tim_lsetbins(display,SQPIO(ltcio),SOFFSET(ltcio),START(binpars),
#			STOP(binpars), num_of_bins,BINLENGTH(binpars))

	call tim_gintvs(display,SQP(ltcio),SQPIO(ltcio),SOFFSET(ltcio),
			Memc[src_filter],START(binpars),STOP(binpars),
                        gbegs, gends, num_gintvs, acctime)

	call ltc_setbins(display,START(binpars),
			STOP(binpars), num_of_bins,BINLENGTH(binpars))

	call tim_initbin(START(binpars),BINLENGTH(binpars),minmax,
			STARTBIN(binpars),STOPBIN(binpars),TOTEXP(ltcio))

	call strupr(datacol)
	if( abbrev("SRC",datacol) > 0 )
		COLUMN(ltcio) = SRC
	else if( abbrev("SOURCE",datacol) > 0 )
		COLUMN(ltcio) = SRC
	else if( abbrev("BKGD",datacol) > 0 )
		COLUMN(ltcio) = BK
	else if( abbrev("BACKGROUND",datacol) > 0 )
		COLUMN(ltcio) = BK
	else if( abbrev("NET",datacol) > 0 )
		COLUMN(ltcio) = NET
	else if( abbrev("EXPOSURE",datacol) > 0 )
		COLUMN(ltcio) = EXPOSURE
	else if( abbrev("CTRT",datacol) > 0 )
		COLUMN(ltcio) = CTRT
	else{
		call eprintf("Allowed inputs are: %s %s %s %s %s\n")
#		    call pargstr("SRC or SOURCE")
#		    call pargstr("BK or BACKGROUND")
		    call pargstr("NET")
		    call pargstr("EXPOSURE")
		    call pargstr("CTRT")
	 	call error(FFT_FATAL,"Unknown input data type\n")
	}
	call sfree(sp)
end


procedure qp_rd_bins(display,ltcio,binpars,i,gbegs,gends,num_gintvs,datacol,
			minmax,source_bins,lexp)
int	display		# i: display level
pointer	ltcio		# i: structure of input qpoe handles and constants
pointer	binpars		# i: structure of binsize parameters
pointer	gbegs		# i: structure of good intervals
pointer	gends		# i: structure of good intervals
int	num_gintvs	# i: number of good intervals
char	datacol[SZ_LINE]# i: requested type of bin
pointer	minmax		# i/o:  updated mins and maxes
real	source_bins[ARB]# o: output requested bins
real	lexp

real	source
real	bkgd
real	net
real	net_err
real	ctrt
real	ctrt_err
real	bknorm

int	i

# These are the current record numbers in the respective files,
#  so they must be remembered between calls.
# This common is really just a local data statement
int	srec		# current source QPOE record
int	brec		# current bkgd QPOE record
int	errtype		# type of error calculation - moot point here

common	/qprecs/srec,brec

begin


	call tim_srcbin(SQPIO(ltcio),START(binpars),BINLENGTH(binpars),
			i,display,srec,SOFFSET(ltcio),source)

	if(DOBKGD(ltcio)== 1)
	    call tim_bkbin(BQPIO(ltcio),START(binpars),BINLENGTH(binpars),
			i,display,brec,BOFFSET(ltcio),bkgd)

#	if( COLUMN(ltcio) == EXPOSURE )
	    call tim_binexp(display,num_gintvs,SQP(ltcio),STARTBIN(binpars),
			STOPBIN(binpars),Memd[gbegs],Memd[gends],lexp,TOTEXP(ltcio))

#	if( COLUMN(ltcio) == BK || COLUMN(ltcio) == NET || COLUMN(ltcio) == CTRT)
	errtype = NO		# force GAUSSIAN, since not used in this task 
	bknorm = 1.0E0
	    call tim_cntrate(source,bkgd,lexp,i,errtype,SRC_AREA(ltcio),
			BK_AREA(ltcio),bknorm,ctrt,ctrt_err,net,net_err)


	STARTBIN(binpars) = START(binpars) + i * BINLENGTH(binpars)
	STOPBIN(binpars) = STARTBIN(binpars) + BINLENGTH(binpars)
	switch( COLUMN(ltcio)){
	case SRC:
	    source_bins[1] = source
	case BK:
	    source_bins[1] = bkgd
	case NET:
	    source_bins[1] = net
	case EXPOSURE:
	    source_bins[1] = lexp
	case CTRT:
	    source_bins[1] = ctrt
	default:
	    call error(FFT_FATAL,"Unknown input column name\n")
	}

end

procedure tb_rd_hd(display,nbins,binsize,start,stop,area,tp,datacol,colptr,expptr)
pointer tp
char    datacol[ARB]
pointer colptr
pointer expptr
int     display
int     nbins
double  binsize
double  area
double	start,stop		# o:
int     ltc_rd_hd               #JCC
int     temp     #JCC

char    buf[SZ_LINE]
begin
#JCC    call ltc_rd_hd ( tp, nbins, binsize, area, start,stop )
        temp = ltc_rd_hd ( tp, nbins, binsize, area, start,stop )   #JCC
        call tbcfnd(tp,datacol,colptr,1)
        if( colptr == NULL ) {
            call sprintf(buf,SZ_LINE,"Input Column Does Not Exist: %s")
               call pargstr(datacol)
            call error(FFT_FATAL,buf)
        }
        call tbcfnd(tp,"exp",expptr,1)
        if( expptr == NULL ) {
#            call sprintf(buf,SZ_LINE,"Input Column Does Not Exist: %s")
#              call pargstr("exp")
#            call error(FFT_FATAL,buf)
            call eprintf("Input Column Does Not Exist: %s\n")
              call pargstr("exp")
	    call eprintf("WARNING: no exposure screening performed\n")
        }
end


procedure tb_rd_bins(tp,colptr,source_bins,currow,expptr,lexp)
pointer	tp
pointer	colptr
real	source_bins[ARB]
int	currow
pointer	expptr
real	lexp

bool	nullflags
begin
        call tbrgtr(tp,colptr,source_bins,nullflags,1,currow)
	if( expptr != NULL )
	    call tbrgtr(tp,expptr,lexp,nullflags,1,currow)
end

