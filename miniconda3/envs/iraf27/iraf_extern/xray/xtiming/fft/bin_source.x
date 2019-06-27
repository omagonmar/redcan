#$Header: /home/pros/xray/xtiming/fft/RCS/bin_source.x,v 11.0 1997/11/06 16:44:24 prosb Exp $
#$Log: bin_source.x,v $
#Revision 11.0  1997/11/06 16:44:24  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:35  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:43  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/14  09:48:12  mo
#MC	4/14/94		Change internal TOTCNTS variable to real, and
#			truncate to integer only when writing to header
#
#Revision 7.0  93/12/27  19:00:46  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:54:13  mo
#MC	7/2/93		Correct boolean initializations from YES/NO to TRY/FALSE
#			and remove redundant == TRUE (RS6000 port)
#
#Revision 6.0  93/05/24  16:56:41  prosb
#General Release 2.2
#
#Revision 5.3  93/05/20  08:45:15  mo
#JD/MC	5/20/93	UPdate for doubple preciesion time
#
#Revision 5.2  93/02/04  09:43:23  mo
#MC	Add FOURINT outputs to output tables
#
#Revision 5.1  92/12/18  12:31:06  janet
#changed binlen, refbinlen, BINLENGTH to double.
#
#Revision 5.0  92/10/29  22:48:33  prosb
#General Release 2.1
#
#Revision 4.2  92/10/23  10:02:37  mo
#MC	10/24/92	Reset input buffer with each summed fft lool
#
#Revision 4.1  92/10/16  20:28:05  mo
#MC	10/16/92		Correct mismatched types in MAX,MIN functions
#
#Revision 4.0  92/04/27  15:32:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/04/13  14:41:06  mo
#MC	4/13/92 	Remove the BINSPERSEG option since it
#			was not scientifically interesting
#
#Revision 3.4  92/02/20  17:38:24  mo
#MC	2/20/92		Add changes to get the TIMES correct for
#			both table and QPOE input, coherent and summed
#			options.
#
#Revision 3.3  92/02/06  17:30:26  mo
#MC	2/5/92		no changes
#
#Revision 3.2  91/12/18  15:14:38  mo
#MC	12/18/91	Add code to sum all the input data and
#			record in the output file as TOTCNTS
#
#Revision 3.1  91/09/25  17:19:50  mo
#MC	9/25/91		Fix the bug that prevented a list of input
#			source files to work - reference bin size
#			not being set correctly
#
#Revision 2.2  91/07/21  17:41:10  mo
#MC	7/21/91		No changes
#
#Revision 2.0  91/03/06  22:43:16  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       bin_source
# Project:      PROS -- ROSAT RSDC
# Purpose:      support routines for the fast fourier transform
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {2} JD -- Dec 1992 -- changed binlen, refbinlen, BINLENGTH
#				      to double.
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
#  BIN_SOURCE.X   ---   to read a LTC table file into local array space 

include	 "fft.h"
include	<tbset.h>
include "filelist.h"
include	<qpoe.h>
include	<ext.h>
define	FFT_FATAL	1
define	SZ_MMM		100
#include  "../timlib/timing.h"
#include  "ltcio.h"
include	"binpars.h"
include <mach.h>

#  ------------------------------------------------------------------------
#
procedure  rd_ltcurv_file (ltcurv_file,bkfile,datacol,type,display,
                           no_bins,binlen,segno,noseg,binsperseg,reflen,len)

char	ltcurv_file[ARB]		# i: name of input lightcurve file
char	bkfile[ARB]		        # i: name of input bk file
char	datacol[ARB]			# i: table col to evaluate
int	display				# i: display level option
int	type
int	no_bins				# o: number of bins in the current file
double  binlen				# o: length in sec of the ltcurv bin
int	noseg				# o: total number of segnemts
int	len				# o: current no FFT bins
int	reflen				# o: reference no FFT bins
					#  power of 2
int	segno				# i: current segment number

bool	newfile				# l: flag for opening additional files
bool	closefile			# l: flag for closing file list
bool	inacc()
#bool	dobk

int	binsperseg			# l: number of bins per segment
int	cnt				# l: local num bins read
real	sumcts				# l: summed input cts
int	totcnt				# l: total bins read
int	currec
int	td
#int	num_gintvs
#int	type
#int	soffset,boffset
real	exppercent			# l: minimum time in bin to include
real	expthresh			# l: minimum time in bin to include
double	exp
double  refbinlen			# l: reference bin length
double	start
double	stop
double	tottime
double	duration			# l: fourier time = len x binlen

#double  area				# l: area of source region
#double  bk_area				# l: area of source region
pointer	histbuf
pointer	source_bins
pointer	sp
pointer	filelist
pointer	label

#pointer	bqp
#pointer	src_ptr
#pointer	bk_ptr
#pointer	minmax
#pointer	ltcio
pointer	binpars
#pointer	gintvs
#pointer	tp

int	 read_bin()  
pointer	open_input()
#int	ltc_rd_hd()

	common /stats/start,stop,tottime,sumcts

begin
	call smark(sp)
	call salloc(label,SZ_PATHNAME,TY_CHAR)
#	call salloc(histbuf,SZ_LINE,TY_CHAR)
#	call salloc(filelist,SZ_FILELIST,TY_STRUCT)
#	call malloc(ltcio,SZ_BINPARS,TY_STRUCT)
#	call malloc(minmax,SZ_MMM,TY_STRUCT)
#	if( segno == 1 && noseg == 1)
	if( segno == 1 )
	{	
	    call malloc(histbuf,SZ_LINE,TY_CHAR)
	    call malloc(filelist,SZ_FILELIST,TY_STRUCT)
	    call calloc(binpars,SZ_BINPARS,TY_STRUCT)
	    call get_expthresh(display,ltcurv_file,datacol,exppercent)
	    call init_filelist(filelist,ltcurv_file,newfile,closefile,binsperseg)
#	    call init_fillgap(td,datacol)
#	    call malloc(source_bins,NELEM,TY_REAL)
	    refbinlen = 0.0d0
	    sumcts = 0.0E0
	    tottime = 0.0D0
	    start = MAX_REAL
	    stop = 0.0E0
	}
	if( newfile )
	{
	    call clear_gap()
#  Get next file name from list of input files
	    call fntgfnb(FILLIST(filelist),ltcurv_file,SZ_PATHNAME)
#   Call this just to update the 'type' in case of LIST input
	    if( inacc(ltcurv_file,type))  {
	    }
	        if( FCOUNT(filelist) != 1)
	            call inclose()
	        td = open_input(display,datacol,type,binpars,
                                ltcurv_file, bkfile, no_bins)
	        call init_fillgap(datacol)
			
	        call calloc(source_bins,NELEM,TY_REAL)
		call set_binlengths(BINLENGTH(binpars),filelist,
				    refbinlen,binsperseg,no_bins,noseg,newfile)
            	len = nint(log(float(binsperseg))/log(2.0))
            	len = 2**len
		if( segno== 1){
		    reflen = len
#		    tottime = tottime + STOP(binpars) - START(binpars)
		    start = min(START(binpars),start)
		    stop = max(STOP(binpars),stop)
		}
		else{
		    if( len == reflen){
#		        tottime = tottime + STOP(binpars) - START(binpars)
		        start = min(START(binpars),start)
		        stop = max(STOP(binpars),stop)
		    }
		}
	        expthresh = (exppercent *  BINLENGTH(binpars)) / 100.0E0
	        call sprintf(Memc[label],SZ_PATHNAME,"FILE%03d")
		    call pargi(segno)
                call fft_cheader(Memc[label],ltcurv_file)
#	    }
#            else  
#	    {
#                call eprintf( " Could not access file: %s " )
#                  call pargstr( ltcurv_file )
#                call error(FFT_FATAL, " Aborting this task." )
#            }
	}
	currec = 1
	totcnt = 0
#	tottime = 0.0D0
	cnt = read_bin(display,binpars, currec, expthresh,datacol, 
			Memr[source_bins],no_bins,segno,binsperseg,sumcts,exp)
	totcnt = totcnt + cnt
	tottime = tottime + exp
	while( cnt != 0 )
	{
	    call wr_bins( currec, Memr[source_bins], segno)
	    cnt = read_bin(display,binpars, 
				currec, expthresh, datacol,Memr[source_bins],
				no_bins,segno,binsperseg,sumcts,exp)
	    totcnt = totcnt + cnt
	    tottime = tottime + exp
	}
	call bin_summary(display,totcnt,ltcurv_file)
        call mfree( source_bins, TY_REAL)
#	call aclrr(Memr[source_bins],NELEM)
#	no_bins = binsperseg
#	call sfree(sp)
	if( FCOUNT(filelist) > NO_FILES(filelist) && closefile && segno >= noseg)
	{
           call fntclsb(FILLIST(filelist))
	   closefile = FALSE
	}

	binlen = BINLENGTH(binpars)

	if( segno == noseg ){
	    duration = double(reflen) * binlen 
            call fft_iheader("TOTCNTS",int(sumcts))
            call fft_dheader("TIME",tottime)
            call fft_dheader("BEG_TIME",start)
            call fft_dheader("END_TIME",stop)
            call fft_dheader("FOURINT",duration)

            call pwr_iheader("TOTCNTS",int(sumcts))
            call pwr_dheader("TIME",tottime)
            call pwr_dheader("BEG_TIME",start)
            call pwr_dheader("END_TIME",stop)
            call pwr_dheader("FOURINT",duration)

            call ftp_iheader("TOTCNTS",int(sumcts))
            call ftp_dheader("TIME",tottime)
            call ftp_dheader("BEG_TIME",start)
            call ftp_dheader("END_TIME",stop)
            call ftp_dheader("FOURINT",duration)

	    call mfree( binpars, TY_STRUCT)
	    call mfree( histbuf, TY_CHAR )
	    call mfree( filelist, TY_STRUCT )
	}
	call sfree(sp)
#        ptr = get_intab(type)
#        if( TYPE != TABLE){
#            call fft_iheader("TOTCNTS",sumcts)
#            call pwr_iheader("TOTCNTS",sumcts)
#            call ftp_iheader("TOTCNTS",sumcts)
#        }
end


procedure get_expthresh(display,ltcurv,datacol,exppercent)
int	display		# i: display level
char	ltcurv[ARB]	# i: input file name
char	datacol[ARB]	# i: input data
real 	exppercent	# o: exposure threshold for bin

real	clgetr()

begin
	    exppercent = clgetr("expthresh")
	    if( display >= 2 ){
	        call printf("fft: fft analysis of file %s, data column: %s, exp thresh: %5.2f\n")
	        call pargstr( ltcurv)
	        call pargstr( datacol)
	        call pargr(exppercent)
		call flush(STDOUT)
   	    }

end

procedure init_filelist(filelist,ltcurv_file,newfile,closefile,binsperseg)
pointer	filelist		# i: structure of filenames
char	ltcurv_file[ARB]	# i: input filename
bool	newfile			# o: Open a new file?
bool	closefile		# o: Close an old file?
int	binsperseg		# o: number of bins in the file

#int	clgeti()
pointer	fntopnb()
int	fntlenb()

begin

#  Allow the possibility that the input could be a list of file names
	    FILLIST(filelist) = fntopnb(ltcurv_file,0)
	    NO_FILES(filelist) = fntlenb(FILLIST(filelist))
	    FCOUNT(filelist) = 1
	    newfile = TRUE
	    closefile = TRUE
#  If only one input file, allow subdivision into FFT segments
#    otherwise, if multiple files, 1 segment == 1 file
#           call printf ("Num of Files = %d\n")
#             call pargi (NO_FILES(filelist))
##  This option was not scientifically meaningful - so it has been disabled
	    if( NO_FILES(filelist) ==  1 )
#	        binsperseg = clgeti(BINSPERSEGMENT)
	    binsperseg = 0
end


procedure set_binlengths(binlen,filelist,refbinlen,
				binsperseg,no_bins,noseg,newfile)
double  binlen
pointer	filelist
double  refbinlen
int	binsperseg
int	no_bins
int	noseg
bool	newfile

bool	fp_equald()
begin
	if( FCOUNT(filelist) != 1) {
	    if( !fp_equald(binlen,refbinlen) ) {
	        call eprintf("Incompatible input bin lengths\n reference bin	length: %f, current bin length: % f")
			call pargd(refbinlen)
			call pargd(binlen)
		 call error(FFT_FATAL,"Ltcurv fatal error\n")
	    }
	}
	else
	    refbinlen = binlen
        if( NO_FILES(filelist) >  1 )
	    binsperseg = 0
        FCOUNT(filelist) = FCOUNT(filelist) + 1
	if( FCOUNT(filelist) > NO_FILES( filelist))
	    newfile = FALSE
	else
	    newfile = TRUE
        if( binsperseg > 0 )
            noseg = no_bins  / binsperseg + 1
	else
	    binsperseg = no_bins
	if( NO_FILES(filelist) > 1 )
	{
	    binsperseg = no_bins
	    noseg = NO_FILES(filelist)
       	}

end

bool procedure inacc(file,type)
pointer	file
int	type

bool	stat
bool	tbtacc()
begin
#  If the type is list, we still don't know the input file type - guess TABLE
	if( type == LIST ){
	    stat = tbtacc(file)
	    if( stat )
		type = TABLE
	    else
		type = QPOE
	}
	else{
	    stat = TRUE
	    if( type == TABLE )
	        stat = tbtacc(file)
#	    else
#	        call tim_openqpf(file,STI_EXT,photon_file,none,spq,src_ptr) )
	}
	return(stat)
end

procedure bin_summary(display,totcnt,ltcurv_file)
int	display
int	totcnt
char	ltcurv_file[ARB]

begin
	if( display > 1 )
	{
	    call printf("Actually read %d bins from ltcurv file: %s \n")
		    call pargi(totcnt)
		    call pargstr(ltcurv_file)
	    call flush(STDOUT)
	}
end

