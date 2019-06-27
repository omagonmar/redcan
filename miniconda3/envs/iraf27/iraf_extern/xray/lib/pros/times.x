#$Header: /home/pros/xray/lib/pros/RCS/times.x,v 11.1 1999/01/29 19:58:09 prosb Exp $
#$Log: times.x,v $
#Revision 11.1  1999/01/29 19:58:09  prosb
#JCC(1/99) - comment : get_timeoff() is used in apply_bary.
#
#Revision 11.0  1997/11/06 16:21:07  prosb
#General Release 2.5
#
#Revision 9.3  1997/06/11 17:51:40  prosb
#JCC(6/11/97) - change IS_INDEF to IS_INDEFD ; INDEF to INDEFD.
#
#Revision 9.2  1997/06/06 21:12:06  prosb
#JCC(6/6/97) - commented out the print statements for get_filttimes().
#
#Revision 9.1  1996/07/02 19:59:08  prosb
#######################################################################
# JCC - Updated to run fits2qp & qp2fits for AXAF data.
#
# (6/14/96) - output_timfilt()/times.x 
#      DEFFILT: For a merged list print one line with all time intvs 
#      separated by commas and ended with ")" without "\n"
#
#######################################################################
#Revision 9.0  1995/11/16  18:28:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:30  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/20  13:40:58  janet
#jd - removed salloc of sbuf that's not used.
#
#Revision 7.1  94/04/13  15:58:50  mo
#MC	3/25/94		Add routine GTI_UPDATE, moved from XTIMING package
#			so QPCALC can access it as well
#
#Revision 7.0  93/12/27  18:10:56  prosb
#General Release 2.3
#
#Revision 6.4  93/12/09  16:37:17  dvs
#(1) Changed some low-level routines to NOT print out "No GTI Record"
#    unless the display is set higher than 1.
#(2) Checking in Maureen's change to some low-level routines which
#    will set a time filter to 7 decimal places instead of 6.
#
#Revision 6.3  93/11/22  17:17:06  mo
#MC	11/22/93		Ensure that blist/elist are nlist+1
#
#Revision 6.2  93/10/21  11:37:58  mo
#MC/DVS	9/8/93		Free a memory buffer
#
#Revision 6.1  93/07/02  14:14:31  mo
#MC   7/2/93          Remove redundant ( == TRUE) from booleans (RS6000 port)
#
#Revision 6.0  93/05/24  15:54:26  prosb
#General Release 2.2
#
#Revision 5.5  93/05/19  17:05:51  mo
#MC	5/20/93		Put tim_cktim back in TIMING library.  Include
#			new get_timeoff, for PROS to find the 'time' offset
#			in a QPOE file.
#
#Revision 5.4  93/05/05  11:41:09  janet
#jd - updated output_gtis with check if mklst = true before using fd.
#
#Revision 5.3  93/05/05  11:31:10  janet
#updates calling sequence to get_qpgti.
#
#Revision 5.2  93/04/22  12:19:31  jmoran
#*** empty log message ***
#
#Revision 5.1  93/04/22  12:06:36  jmoran
#JMORAN RATFITS GTI changes
#
#Revision 5.0  92/10/29  21:17:40  prosb
#General Release 2.1
#
#Revision 4.8  92/10/21  16:26:00  mo
#MC	10/21/92	Zero time pointers before start
#
#Revision 4.7  92/10/16  20:23:56  mo
#MC	10/16/92	Added format routine to convert back to qpgti format
#
#Revision 4.6  92/10/08  09:20:27  mo
#MC	10/8/92		Added a specifiable precision to the
#			GTI printout 
#
#Revision 4.5  92/10/02  19:57:29  mo
#MC	10/1/92		Add additional code to check if 'time' attribute
#			exists in the QPOE file.
#
#Revision 4.4  92/09/29  14:41:52  mo
#MC	9/29/92		First draft of changes to support DEFFILT as the
#			absolute referenece for exposure time and leaving
#			GTI only as an original archive.  Required changing
#			to the IRAF format of gbegs and gends rather than
#			a double dimensioned array.
#			Also forces use of DEFFILT for calculating exposure,
#			even if 'nodeffilt' specified by user.
#.`
#
#
#Revision 4.3  92/08/11  14:33:23  mo
#MC	8/11/92		Improved modularity of routines - moved duplicated
#			code to subroutines.
#			Fixes get_goodtimes to return EXPTIME or ONTIME
#			when no GTIS ( deffilts ) are available.
#
#Revision 4.1  92/06/16  12:25:12  jmoran
#JMORAN added code to calloc a single space for the time filter string
#in "output_timfilt"
#
#Revision 4.0  92/04/27  13:50:18  prosb
#General Release 2.0:  April 1992
#
#Revision 3.8  92/04/23  22:16:13  prosb
#Commented out variable definition "status" line 293 -- not used.
#
#Revision 3.7  92/04/23  13:04:07  mo
#MC	4/23/92	Finalized changes for IRAF 2.10, time filtering.
#		Fixed nasty but, where output_gtis was modifying
#		its input value of ngtis.  Also made sure all
#		'gti' arrays are dimension to 'ngti+1' since
#		output_gtis requires this.
#
#Revision 3.6  92/04/10  08:04:11  mo
#MC	4/10/92		Back the the WRITE_ONLY open for sun, since
#			NEW_FILE produced no output
#
#Revision 3.5  92/04/06  16:52:47  mo
#MC	4/6/92		Add routines for getting QPOE and IMAGE
#			ON-TIME, add format to output_gtis routine
#			and correct open/WRITE_ONLY to open/NEW_FILE
#			since former doesn't work for VMS
#
#Revision 3.4  92/03/18  14:03:04  mo
#MC	3/18/92		Add the get_imexp routine
#
#Revision 3.3  92/03/09  15:13:43  mo
#MC	3/9.92		Add routine to create a filter string from the
#			GTIS to be used in DEFFILT
#
#Revision 3.2  92/02/06  16:53:53  mo
#MC	2/5/92		Change get_goodtimes to read filtered
#			GTI records and not the ON_TIME from header
#
#Revision 3.1  92/01/20  15:49:15  mo
#MC	1/20/92		Add a filtered times routine and cause
#			get_goodtimes to always apply current time filter
#
#Revision 1.1  91/08/30  14:32:43  mo
#Initial revision
#
#Revision 2.0  91/03/07  00:07:39  pros
#General Release 1.0
#
# --------------------------------------------------------------------------
#
#	times.x -- time filtering routines
#
# --------------------------------------------------------------------------
#
#define	SZ_BUF	2048
define	SZ_DATA	2048	# Length of internal buffer for time filters
include	<mach.h>
include <qpoe.h>
#include <einstein.h>
#include <rosat.h>
include <fset.h>
include <fio.h>
include <printf.h>
#include <qpset.h>
include <qpioset.h>


# --------------------------------------------------------------------------
#
# GET_GOODTIMES -- get list of good time intervals including command filter
#
#    Replace previous get_goodtimes ( now get_gdtimes ) which didn't do 
#	filtering with improved version that does the filtering
# --------------------------------------------------------------------------
procedure get_goodtimes(qp, timespec, display, blist, elist, nlist, duration)

pointer	qp		# i: qpoe handle
char	timespec[ARB]	# i: temporal specification
int	display		# i: display level
pointer	blist		# o: list of good intervals
pointer	elist		# o: list of good intervals
int	nlist		# o: number of intervals in good list
double	duration	# o: total duration of good times (sec.)
pointer qphead          # l: pointer to QPOE header structure
double  get_filttimes() # l: get filtered times

begin
        duration = get_filttimes(qp, timespec, display, blist, elist, nlist)
        if( nlist == 0 ){
            call get_qphead(qp,qphead)
            duration = QP_EXPTIME(qphead)
            if( duration <= EPSILOND ){
                duration = QP_ONTIME(qphead)
                call printf("No good times (deffilt) - ONTIME taken from QPOE header\n")
            }
            else
                call printf("No good times (deffilt) - EXPTIME taken from QPOE header\n")
	        call mfree(qphead,TY_STRUCT)
        }
end

# --------------------------------------------------------------------------
#
# GET_QPEXP -- get list of good time intervals including command filter
#
#    Replace previous get_goodtimes ( now get_gdtimes ) which didn't do 
#	filtering with improved version that does the filtering
# --------------------------------------------------------------------------
procedure get_qpexp(qp, timespec, display, blist, elist, nlist, duration)

pointer	qp		# i: qpoe handle
char	timespec[ARB]	# i: temporal specification
int	display		# i: display level
pointer	blist		# o: list of good intervals
pointer	elist		# o: list of good intervals
int	nlist		# o: number of intervals in good list
double	duration	# o: total duration of good times (sec.)

begin
        call get_goodtimes(qp,timespec,display,blist,elist,nlist,duration)
end

# --------------------------------------------------------------------------
#
# GET_IMEXP -- get IMAGE exposure time
#
# --------------------------------------------------------------------------
procedure get_imexp(im, duration)

pointer	im		# i: qpoe handle
double	duration	# o: total duration of good times (sec.)
int	imaccf()
double	imgetd()

begin
	if( imaccf(im,"EXPTIME") == YES)
	    duration = imgetd(im,"EXPTIME")
	else if( imaccf(im,"XS-ONTIME") == YES){
	    call eprintf("WARNING: static XS-ONTIME parameter used for Exposure Time\n")
	    duration = imgetd(im,"XS-ONTIME")
	}
	else
	    call error(1,"No exposure time available")

end

# --------------------------------------------------------------------------
#
# GET_FILTTIMES -- get list of filttime intervals from final filter list
#
# --------------------------------------------------------------------------
double procedure get_filttimes(qp, timespec, display, gbegs, gends, nranges)

pointer	qp		# i: qpoe handle
char	timespec[ARB]	# i: temporal specification
int     display         # i: display level
pointer	gbegs		# o: list of good interval starts 
pointer	gends		# o: list of good interval ends
int	nranges		# o: number of intervals in good list
double	duration	# o: function return total duration of good times (sec.)



char	timsp[SZ_DATA]
int	xlen,slen
int	num_gintvs,status
pointer	ex
pointer	ltimsp

int	qpex_attrld()
int     strlen()
double	get_gtifilt()
double	sumtimes()

bool	ck_qpatt()
pointer	qpex_open()
pointer	qpex_modfilter()

begin
 
#  If the 'time' attribute doesn't exist in the QPOE file, these
#	strings won't work - return 0 duration and look for XS-ONTIME

#JCC (6/5/97) - add printf statements
#   call printf("\n   get_filttimes : timespec = %s \n")
#   call pargstr(timespec)

    nranges = 0
    gbegs = NULL;  gends = NULL;  xlen = 0
    if( ck_qpatt(qp,"time") ){
        # Get the time filter 
	ex = qpex_open(qp,"")

	# Strip off the leading and trailing []
	slen = strlen(timespec)
	if( slen >= 2 ){
	    call strcpy( timespec[2],timsp, SZ_DATA)
	    timsp[slen-1]=NULL
	}
	else
	    call strcpy(timespec,timsp,slen)
# If the filter is the Null string no need to strip the []`s
	# Set the timefilter that was specified on the input file
	status = qpex_modfilter(ex,timsp)
	
	# Get the standard GTIS as a list of ranges and add to the current filter
	duration = get_gtifilt(qp,ltimsp,num_gintvs,gbegs,gends)
	status = qpex_modfilter(ex,Memc[ltimsp])

#	Retrieve the merged TIME filter list as a set of ranges
#        gbegs = NULL;  gends = NULL;  xlen = 0
        nranges = qpex_attrld (ex, "time", gbegs, gends, xlen)
	duration = sumtimes(gbegs,gends,nranges,display)
	call mfree(ltimsp,TY_CHAR)
        call qpex_close(ex)
    }
    else
	duration = 0.0D0
    return(duration)
end

######################################################################
#
#  Read the list of good times from the DEFFILT keyword and
#	format them as a time filter string
#
#######################################################################
double procedure get_gtifilt(qp,ltimsp,num_gintvs,gbegs,gends)
pointer	qp		#i: input qpoe handle
pointer	ltimsp		#o: output filter string
pointer	gbegs		#o: good time interval beg arrays 
pointer	gends		#o: good time interval end arrays
int	num_gintvs	#o: number of intervals

double	duration	#o: returned function value

begin
#  Get the DEFFILT from the QPOE file and write as an ASCII filter to a 
#	temp file
        call get_gdtimes (qp, "", gbegs, gends, num_gintvs, duration)
	if( num_gintvs == 0 ){
	    call malloc(ltimsp,SZ_LINE,TY_CHAR)
	    Memc[ltimsp] = EOS
	}
	else
            call put_gtifilt(gbegs, gends, num_gintvs, ltimsp )
	return(duration)
end

# --------------------------------------------------------------------------
#
# GET_GDTIMES -- get DEFFILT from QPOE file - no extra filtering
#
# --------------------------------------------------------------------------
procedure get_gdtimes(qp, timespec, blist, elist, nlist, duration)
 
pointer qp              # i: qpoe handle
char    timespec[ARB]   # i: temporal specification
pointer blist           # o: list of good intervals begin
pointer elist           # o: list of good intervals end
int     nlist           # o: number of intervals in good list
double  duration        # o: total duration of good times (sec.)

#int     i               # l: loop counter
int	nlen		# l: returned length of arrays  
#pointer qpgti           # l: good time interval pointer
bool    strne()         # l: string compare
bool	ck_qpatt()

pointer	ex		# l: pointer to ex portion of qpoe file
pointer	qpex_open()	# l: qpoe routine
#pointer tp             # l: pointer to time records
#pointer qphead         # l: pointer to qpoe header
#int    nrecs           # l: number of time records
int	qpex_attrld()
double	sumtimes()

begin
    blist = NULL; elist = NULL; duration = 0.0; nlen=0; nlist=0
    if( ck_qpatt(qp,"time") ){
        # hopefully, this will go away some day! - like today for 2.9.2
	ex = qpex_open(qp,"")
        if( strne("", timespec)  )
            call error(1, "Sorry, timespec must be a null string")
        # get the time intervals
#        call get_qpgti(qp, qpgti, nlist)
#        # convert them to simple array format
#        duration = 0.0D0
#        call calloc(list, (nlist+1)*2, TY_DOUBLE)
	call setdeffilt(qp,ex)
#        blist = NULL; elist = NULL; duration = 0.0; nlen=0
	nlist = qpex_attrld(ex,"time",blist,elist,nlen)
	duration = sumtimes(blist,elist,nlist,0)
	call qpex_close(ex)
    }
    else
	duration = 0.0D0
end
 
######################################################################
#
#  
#	Format lists  of GOOD time intervals into a time filter string
#
#######################################################################
procedure put_gtifilt(gbegs,gends,num_gintvs,ltimsp)
pointer	gbegs		# i: pointer to good time intervals starts to compose filt string
pointer	gends		# i: pointer to good time intervals ends to compose filt string
int	num_gintvs	# i: number of intervals in gintvs
pointer	ltimsp		# o: output pointer to filter string
int	ldisp		# l: display level
#int	status		# l: status from getline

bool	merge
bool 	mklst

begin
        # Get the standard GTIS as a list of ranges
        merge = TRUE
        mklst = TRUE

        ldisp = 0
        call output_timfilt (Memd[gbegs], Memd[gends], num_gintvs, "%.7f",ldisp, ltimsp, merge, mklst)

end

######################################################################
#
#  Read lists of good times 
#	format them as a time filter string
#
#######################################################################
procedure output_gtis (gbegs, gends, num_gintvs, format, display, fd, merge, mklst)

double  gbegs[ARB]	# i: gti start times
double  gends[ARB]	# i: gti stop times
int     num_gintvs      # i: number of gti records
char	format[ARB]		# i: format to use for output list
int	display         # i: whether to display gti's
int     fd              # i: ascii output file descriptor
bool    merge           # i: merge times ?
bool    mklst           # i: whether to make an asii list


pointer	filt		# l: pointer to ASCII output string - alloced in output	timfilt
int	len,clen	# l: string lengths
int	strlen()

begin
# nrecs is 0 - print warning - the rest doesn't matter
        if( num_gintvs==0 ){
	    if (display > 1 ) {
               call printf("\nNo gti records\n")
	    }
        } else {
 
# output a header
#           if ( display > 0 ) {
#              call printf("\n\tGood Time Intervals\n\n")
#              call printf("start\t\tend\t\tduration\n\n")
#           }
 
	    call output_timfilt (gbegs, gends, num_gintvs, format, display, 
                                 filt, merge, mklst)
            if ( mklst ) {
               len = strlen(Memc[filt])
               clen = 0
               while( clen < len ){    # print in lumps of SZ_OBUF
                  call fprintf(fd, "%s")
                      call pargstr(Memc[filt+clen])
                  clen = clen + SZ_OBUF  # SZ_OBUF is an IRAF string limit
               }
               call fprintf(fd, "\n")
	       call mfree(filt,TY_CHAR)	
	    }
	}
end

procedure output_timfilt (gbegs, gends, num_gintvs, format, display, filt, 
merge, mklst)

double	gbegs[ARB]	# i: deffilt start times
double  gends[ARB]	# i: deffilt stop times
int     num_gintvs      # i: number of gti records
char	format[ARB]		# i: format to use for output list
int	display         # i: whether to display gti's
pointer	filt            # o: ascii output file descriptor
bool    merge           # i: merge times ?
bool    mklst           # i: whether to make an asii list

char	lform[SZ_LINE]  # l: string to compose format string
bool    gap             # l: indicates whether there's a gap
bool    first		# l: first print indicator
bool    last            # l: last print indicator
int     i               # l: loop counter
int	n
int	szbuf		# l: current output buffer size
int	lnum_gintvs	# l: don't alter the input value
double  start		# l: gap start time
double  stop 		# l: gap stop time

int	strlen()
begin

# nrecs is 0 - print warning - the rest doesn't matter
        if( num_gintvs==0 ){
	   if (display>1)
	   {
              call printf("\nNo gti records\n")
	   }
#---------------------------------------------------
# NEW
#---------------------------------------------------
           call calloc(filt,2,TY_CHAR)
	   Memc[filt] = ' '
	   Memc[filt + 1] = EOS
#---------------------------------------------------
#NEW
#---------------------------------------------------
        } else {

# output a header
	   if ( display > 0 ) {
              call printf("\n\tGood Time Intervals\n\n")
              call printf("start\t\tend\t\tduration\n\n")
	   }

#   first initalize some variables
#	   lnum_gintvs = num_gintvs 
	   lnum_gintvs = num_gintvs + 1
           gbegs[lnum_gintvs] = 0.0D0
           gends[lnum_gintvs] = 0.0D0

	   start = gbegs[1]
	   first = true
	   last = false

	   szbuf = SZ_DATA
	   call calloc(filt,szbuf,TY_CHAR)

#   process all gti records 
           for(i=1; i<=lnum_gintvs; i=i+1){

	      if( strlen(Memc[filt])+SZ_LINE > szbuf ){
		szbuf = szbuf + SZ_DATA
		call realloc(filt,szbuf,TY_CHAR)
	      }
#   compare the start of this intv to the stop of prev to determine gap
	      if ( (i > 1 ) && (gends[i-1] != gbegs[i]) ){
 		 gap = true
                 stop = gends[i-1]
	      }
#   Display record to stdout, print extra blank line if gap determined
	      if ( (display > 0) && (i != lnum_gintvs)) {
                 if (gap) {
                    call printf("\n")
	 	 }
#                 call printf("%.2f\t%.2f\t%.2f\n")
		  call strcpy(format,lform,SZ_LINE)
	          call strcat("\t",lform,SZ_LINE)
	          call strcat(format,lform,SZ_LINE)
	          call strcat("\t",lform,SZ_LINE)
	          call strcat(format,lform,SZ_LINE)
		  call strcat("\n",lform,SZ_LINE)
		  call printf(lform)
                  call pargd(gbegs[i])
                  call pargd(gends[i])
                  call pargd(gends[i]-gbegs[i])
	      }
#  Make an ascii list of time intvs with gap as delimeter
	      if ( (gap) && (mklst)) {

#  For a merged list print one line with all time intvs separated by commas
		 if (merge) {
		    if ( first ) {
 		       call sprintf (Memc[filt],szbuf,"time=(")
		       first = false
		    }	
		    call strcpy(format,lform,SZ_LINE)
		    call strcat(":",lform,SZ_LINE)
		    call strcat(format,lform,SZ_LINE)
		    n = strlen(Memc[filt])
 		    call sprintf (Memc[filt+n],szbuf,lform)
		      call pargd(start)
		      call pargd(stop)

		    if ( i == lnum_gintvs ){
		       first = true
		       n = strlen(Memc[filt])
                      #JCC- remove "\n"
                       #  call sprintf (Memc[filt+n],szbuf,")\n")
 		       call sprintf (Memc[filt+n],szbuf,")")
		    } else {
		       n = strlen(Memc[filt])
		       call sprintf (Memc[filt+n],szbuf,",")
		    }

#  For unmerged list print 1 time filter per line commented out
		 } else {
		    call strcpy("# time=(",lform,SZ_LINE)
		    call strcat(format,lform,SZ_LINE)
		    call strcat(":",lform,SZ_LINE)
		    call strcat(format,lform,SZ_LINE)
		    call strcat(")\n",lform,SZ_LINE)
# 		    call sprintf (Memc[filt],szbuf,"# time=(%.2f:%.2f)\n")
		    n = strlen(Memc[filt])
 		    call sprintf (Memc[filt+n],szbuf,lform)
		      call pargd(start)
		      call pargd(stop)
		 }
	      } 

#  Finished processing gap so set up for next one
	      if (gap) {
		 start = gbegs(i)
		 gap = false
	      }
	   }

	n=strlen(Memc[filt])
	Memc[filt+n]=EOS
# --- NEW - moved from 2 lines above ---
	}
# --- NEW - moved from 2 lines above ---

end

procedure setdeffilt(qp,ex)
pointer	qp			# input QPOE handle
pointer	ex			# input filter string handle
#int	nodeffilt
int	len
int	maxch
#int	qp_stati()
int	qp_accessf()
int	qp_gstr()
pointer	filtstr
pointer	sp

begin
	call smark(sp)
        maxch = 0
        len = 0 
        if( qp_accessf(qp, "deffilt") != NO ){
            while( len == maxch ){
                maxch = maxch + 2048
                call realloc(filtstr,maxch+SZ_LINE,TY_CHAR)
                len =  qp_gstr(qp,"deffilt",Memc[filtstr],maxch)
            }
	}
	else if( qp_accessf(qp,"XS-FHIST") != NO ){
            while( len == maxch ){
                maxch = maxch + 2048
                call realloc(filtstr,maxch+SZ_LINE,TY_CHAR)
                len =  qp_gstr(qp,"XS-FHIST",Memc[filtstr],maxch)
	    }
	}
	else{
		call realloc(filtstr,SZ_LINE,TY_CHAR)
		call strcpy("",Memc[filtstr],SZ_LINE)
		call eprintf("WARNING: no good time intervals found in file" )
	}
	call qpex_modfilter(ex,Memc[filtstr])
	call mfree(filtstr,TY_CHAR)
	call sfree(sp)
end


double procedure get_gtitimes(qp, blist, elist, nlist, display, gti_root)

pointer qp              # i: qpoe handle
int     display         # i: display level
pointer blist           # l: list of good intervals
pointer elist           # l: list of good intervals
int     nlist           # l: number of intervals in good list
char    gti_root[ARB]
double  duration        # o: total duration of good times (sec.)
pointer qpgti           # l: pointer to QPOE header structure
int     ii

begin
        call get_qpgti(qp, qpgti, nlist, gti_root)

        call calloc(blist, nlist+1, TY_DOUBLE)
        call calloc(elist, nlist+1, TY_DOUBLE)
        do ii = 1, nlist
	{
            Memd[blist+ii-1] = GTI_START(GTI(qpgti,ii))
            Memd[elist+ii-1] = GTI_STOP(GTI(qpgti,ii))
            duration = duration + Memd[elist+ii-1] - Memd[blist+ii-1]
        }

        call mfree(qpgti, TY_STRUCT)
        return (duration)
end

# --------------------------------------------------------------------------

double procedure sumtimes(gbegs,gends,nranges,display)
pointer	gbegs
pointer	gends
int	nranges
int	display
double	duration

int	ii
bool	open_left
bool	open_right

begin
#       The PROS GTI exclude the possibility of final OPEN-ENDED ranges
        if (nranges > 0) {
            open_left = IS_INDEFD(Memd[gbegs])   #JCC(97):INDEF->INDEFD
            open_right = IS_INDEFD(Memd[gends+nranges-1]) #1997:INDEF->INDEFD
        } else {
            open_left = FALSE
            open_right = FALSE
        }

#       Reformat the start and stop times for what PROS expects
        duration = 0.0D0
#       call calloc(list, (nranges+1)*2, TY_DOUBLE)
        if (display >= 2) {
           call printf ("nranges=%d\n")
             call pargi (nranges)
        }
        if( !(open_left || open_right) ){
            do ii=1,nranges{
#               Memd[list+((i-1)*2)] = Memd[blist+i-1]
#               Memd[list+((i-1)*2)+1] = Memd[elist+i-1]
                duration = duration + Memd[gends+ii-1] - Memd[gbegs+ii-1]
                if( display >= 2){
                    call printf("start: %.4f stop: %.4f duration: %.4f\n")
                        call pargd(Memd[gbegs+ii-1])
                        call pargd(Memd[gends+ii-1])
                        call pargd(duration)
                }
            }
        }
        else
            duration = INDEFD     #JCC(97) : INDEF->INDEFD

	return(duration)
end

bool procedure ck_qpatt(qp,attname)
pointer qp
char    attname[ARB]
 
bool    att
pointer ex
pointer expand
pointer filtstr
pointer sp
int     n
 
int     qp_expandtext()
pointer qpex_open()
int     qpex_modfilter()
 
begin
#  Check that 'time' is an attribute in the input QPOE file
        call smark(sp)
        ex = qpex_open(qp,"")
        call salloc(expand,SZ_LINE,TY_CHAR)
        call salloc(filtstr,SZ_LINE,TY_CHAR)
        n = qp_expandtext (qp, attname, Memc[expand], SZ_LINE)
#  Check to see if 'time' exists in the QPOE file
        call strcpy(Memc[expand],Memc[filtstr],SZ_LINE)

        call strcat("=(0:)",Memc[filtstr],SZ_LINE)
        if( qpex_modfilter(ex, Memc[filtstr]) == ERR)
            att = FALSE
        else
            att = TRUE
        call qpex_close(ex)
        call sfree(sp)
        return(att)
end
 
#------------------------------------------------------------------
#
# Function:     get_timeoff
# Purpose:      Verify that the current QPOE file has time entries defined as
#               double precision in the events and get the offset
# Uses:         /pros library
# Pre-cond:     A file handle to the active main QPOE file
# Post-cond:    Either a fatal error abort OR
#                  the offset of the time attribute that it found
#
# JCC(1/99) - this routine is used in apply_bary.
# -------------------------------------------------------------------------

bool procedure get_timeoff(qp,qptype,offset)
pointer qp              # i: qpoe file handle
pointer qptype          # i: input file type (source/bkgd)
int     offset          # o: offset of "time" photon attribute
int     type            # l: variable data type
bool	timeoff		# o: returned function values
int     ev_lookup()             # lookup type and offset of named parameter

begin

# Make sure time is in the src event struct (and save offset of event element)
	timeoff = TRUE
        if( ev_lookup(qp, "time", type, offset) == NO ){
		timeoff = FALSE
		offset = 0
        }
        else
            if( type != TY_DOUBLE ){
		timeoff = FALSE
		offset = 0
            }
	return(timeoff)
end


procedure reformat_gti(blist,elist,nlist,qpgti)
pointer	blist			# i:	input gti begin times
pointer elist			# i:	input gti end times
int	nlist			# i:    input number of intervals
pointer	qpgti			# o:    alloced pointer to structure of GTIS
int	i

begin
        call calloc(qpgti, SZ_QPGTI*nlist, TY_STRUCT)
        do i=1, nlist{
            GTI_START(GTI(qpgti,i)) = Memd[blist+i-1]
            GTI_STOP(GTI(qpgti,i)) = Memd[elist+i-1]
        }
end

procedure gti_update(qp, qphead, blist, elist, ngti)

pointer qp
pointer qphead
pointer blist
pointer	elist
int     ngti

double  duration
pointer qpgti
int	i

begin

        duration = 0.D0

        call calloc(qpgti, SZ_QPGTI*ngti, TY_STRUCT)

        do i = 1, ngti
        {
#          GTI_START(GTI(qpgti,i)) = Memd[gtis+((i-1)*2)]
#          GTI_STOP(GTI(qpgti,i)) = Memd[gtis+((i-1)*2)+1]
#          duration = duration + (GTI_STOP(GTI(qpgti,i)) -
#                                 GTI_START(GTI(qpgti,i)))

	   GTI_START(GTI(qpgti,i)) = Memd[blist+i-1]
	   GTI_STOP(GTI(qpgti,i))  = Memd[elist+i-1]
	   duration = duration + Memd[elist+i-1] - Memd[blist+i-1]
        }

#-------------------------------
# Update QPOE header information
#-------------------------------
        QP_ONTIME(qphead) = duration
#        QP_LIVETIME(qphead) = duration / QP_DEADTC(qphead)

#-------------------
# NEW
#-------------------
        QP_LIVETIME(qphead) = duration * QP_DEADTC(qphead)
#-------------------
# NEW
#-------------------

        call put_qphead(qp, qphead)

#--------------------------------
# Write the updated GTI intervals
#--------------------------------
        call put_qpgti(qp, qpgti, ngti)

        call mfree(qpgti, TY_STRUCT)



end


