#Revision 10.0 1997/09/15 JDS
#qpappend_ftsi has a new parameter that gives the user
#the control of whether or not to append the TSI 
#records as well. Either all or just the first TSI
#records can be included in the final qpoe file.
#  [ updated from qpappend/Revision9.1 ]
#
#Revision 9.1  1997/06/12 21:15:04  prosb
#JCC(6/12/97) - add comments and update qpp_tsiaux()
#               XS_TSIREC - crashed when it's same in 1st & 3rd qpoes,
#                           but different in 2nd qpoe.
#
#Revision 9.0  1995/11/16 19:02:03  prosb
#General Release 2.4
#
## QPAPPEND -- Append the event list and auxiliary QPOE lists from a set
#		of input QPOE files.  Match by PIXEL NUMBER only.
#		Merge the Headers
#

include <mach.h>
include <math.h>
include <qpoe.h>
include <qpc.h>
include	<qpset.h>

# the first part of argv is defined in qpc.h
# define the other parts of argv we will need
define	SZ_ARGV		(SZ_DEFARGV+13)
#define SZ_ARGV (SZ_DEFARGV + 3)
define	APPINIT		Memi[$1+SZ_DEFARGV]
define	NO_FILES 	Memi[$1+(SZ_DEFARGV)+1]
define 	FCOUNT   	Memi[$1+(SZ_DEFARGV)+2]
define 	FILLIST  	Memi[$1+(SZ_DEFARGV)+3]
define	TIMES		Memi[$1+(SZ_DEFARGV)+4]
define	EVENTS		Memi[$1+(SZ_DEFARGV)+5]
define	RAOFF		Memi[$1+(SZ_DEFARGV)+6]
define	DECOFF		Memi[$1+(SZ_DEFARGV)+7]
define	ROLLOFF		Memi[$1+(SZ_DEFARGV)+8]
define	FLIST		Memi[$1+(SZ_DEFARGV)+9]
define	OUTNAME		Memi[$1+(SZ_DEFARGV)+10]
define	VALID		Memi[$1+(SZ_DEFARGV)+11]
define  DOTSI		Memi[$1+(SZ_DEFARGV)+12]
#define	REFPER		Memd[P2D(($1)+(SZ_DEFARGV)+4)] # initial period(seconds)
#define	PDOT		Memd[P2D(($1)+(SZ_DEFARGV)+6]	# rate of change in period
#define	PHSSTART	Memd[P2D(($1)+(SZ_DEFARGV)+8)]	# start time of data

#
#  T_QPAPPEND -- main task to append a list of QPOE files
#
procedure t_qpappend_ftsi()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate argv space  (change from 10 to 20 (jcc))
	call calloc(argv, SZ_ARGV+20, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers and allocate argv space
	call app_load2()
	APPINIT(argv) = NO
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  APP_LOAD -- load driver routines
#
procedure app_load2()

extern	app_open2(), app_get2(), def_close()
extern	app_getparam3(), app_hist2(), app_finale2()


begin
        # load the header drivers
# call qpc_hdload("header", ".mhdr", uhd_open, uhd_get, uhd_close)
        # load the time drivers
#*call qpc_auxload("tgr", ".tgr",qptgr_open,qptgr_get,tgr_put,tgr_close,1)
#*call qpc_auxload("gti", ".gti",qpgti_open,qpgti_get,gti_put,gti_close,1)
#*call qpc_auxload("tsi", ".tsi",qptsi_open,qptsi_get,tsi_put,tsi_close,1)
        # load the aspect drivers
#*call qpc_auxload("blt", ".blt",qpblt_open,qpblt_get,blt_put,blt_close,2)
	# load the event drivers
	#  The exact name "qpoe_list" is used to tell QPCREATE that this
	#    is a LIST of input QPOE files, and so will not COPY, but CREATE
	#	output file.  QPCREATE must be changed if this parameter
	# 	name is changed
	call qpc_evload("qpoe_list", ".qp", app_open2, app_get2, def_close)
	# load getparam routine
	call qpc_parload(app_getparam3)
        call qpc_finaleload(app_finale2)
	# load history routine
	call qpc_histload(app_hist2)
end

#
# APP_GETPARAM -- get region parameter for qpappend
#
procedure app_getparam3(ifile, argv)

char	ifile[ARB]		# input file name
pointer	argv			# argument list pointer
int     ii
int     clgeti()
#bool   clgetb()
#double	clgetd()		# get real param

begin
	# get standard params
	call def_getparam(ifile, argv)
	# call clgeti("dotsi",Memi[DOTSI(argv)])
	# Memi[DOTSI(argv)] = clgetb("dotsi")
        #Memi[DOTSI(argv)] = clgeti("dotsi")
        ##DOTSI(argv) = clgeti("dotsi")
        ii = clgeti("dotsi")
        call printf("app_getparam3/ii=%d\n")
        call pargi(ii)

        DOTSI(argv) = ii
        call printf("DOTSI(argv)=%d\n")
        call pargi(DOTSI(argv))
end

procedure app_finale2(fd, qp, io, convert, qphead, display, argv)

int     fd[MAX_ICHANS]                  # i: file descriptor
pointer qp                              # o: qpoe handle
pointer io                              # i: pointer to event list
int     convert                         # i: data conversion flag
pointer qphead                          # i: header
int     display                         # i: display level
pointer argv                            # i: pointer to arg list

bool	gti				# l: good time info available ?
int	i,j				# l: loop counter
int	trecs,nrecs
pointer	filtkey
pointer	filtstr				# l: pointer to filter expression
pointer	poeroot
pointer	buf
pointer	fname
pointer lfilter
pointer	exfilt
pointer	temphead
#pointer	inex	  			# l: pointer for individual expression
pointer ex				# l: pointer for merged expression

double	duration

pointer	sp
pointer	qpex_open()
bool	get_expstr()
bool	ck_qpatt()
int	qp_accessf()
#double	update_exp()
double	sumtimes()
int	qpex_attrld()
#int	qp_geti()
int	strlen()
#include "qpcreate.com"
pointer	blist,elist
pointer	bcur,ecur
pointer	hist
int	ngti,xlen,len
int	cgti,clen

begin
	call smark(sp)
	call salloc(filtkey,SZ_LINE,TY_CHAR)
	call salloc(poeroot,SZ_PATHNAME,TY_CHAR)
	call salloc(fname,SZ_PATHNAME,TY_CHAR)
	call salloc(lfilter,SZ_EXPR,TY_CHAR)
	call salloc(exfilt,SZ_EXPR,TY_CHAR)
	call salloc(temphead,SZ_QPHEAD,TY_STRUCT)
	call salloc(buf,SZ_LINE,TY_CHAR)
	call salloc(hist,SZ_EXPR,TY_CHAR)
        # put the mask header to the qpoe file
        # update the composite mask ( if fd[3] == 0, then no mask set)
	convert = 0

	call app_remove2(qp,argv)
	call del_history(qp)
	call del_masks(qp)
#	call qp_close(qp)
#        qp = qp_open(Memc[OUTNAME(argv)], READ_WRITE, NULL)

#        if( REGSUM(argv) !=0 && fd[3] >= 0 ){
#            call put_qpmask(qp, Memc[REGSUM(argv)])     
#            call update_qpcomposite(qp, fd[3], Memc[REGIONS(argv)])
#        }
        #---------------------------------------------------------
        # Check that 'time' is an attribute in the input QPOE file
        #---------------------------------------------------------
        if (ck_qpatt(qp,"time") )
           call strcpy("deffilt",Memc[filtkey],SZ_LINE)
        else
           call strcpy("XS-FHIST",Memc[filtkey],SZ_LINE)

#	ex = qpex_open(qp,"")
        call fntrewb(FILLIST(argv))
	FCOUNT(argv) = 1
	ngti = 0
	xlen = 0
#	call calloc(blist,xlen,TY_DOUBLE)
#	call calloc(elist,xlen,TY_DOUBLE)
        call def_close(fd, temphead, display, argv)
        do i=1,NO_FILES(argv)
        {
	  if( Memi[VALID(argv)+i] == YES)
	  {
	    ex = qpex_open(qp,"")
            call fntgfnb(FILLIST(argv),Memc[fname],SZ_PATHNAME)
            call qpparse(Memc[fname], Memc[poeroot], SZ_PATHNAME, Memc[lfilter], SZ_EXPR)
	    call def_open(Memc[fname], fd, trecs, convert, temphead, display,
				argv) 
	  if( (DOTSI(argv)== YES)|| (i==1))
	  {
	    call app_tsiaux2(fd[1],qphead,qp,i,display,argv)
	  }
            call strip_qpfilt(lfilter,exfilt,SZ_EXPR)
            if (ck_qpatt(fd[1],"time") )
               call strcpy("deffilt",Memc[filtkey],SZ_LINE)
            else
               call strcpy("XS-FHIST",Memc[filtkey],SZ_LINE)
#	    inex = qpex_open(fd[1],"")
	    gti = get_expstr(fd[1],filtstr)
	    call qpex_modfilter(ex,Memc[exfilt])
	    gti = get_expstr(fd[1],filtstr)
	    if( gti)
	        call qpex_modfilter(ex,Memc[filtstr])
            bcur = NULL; ecur = NULL; duration = 0.0; clen=0
            cgti = qpex_attrld(ex,"time",bcur,ecur,clen)
	    duration = 0.0D0
            if( cgti > 0 )
               duration = sumtimes(bcur,ecur,cgti,display)
	    Memr[TIMES(argv)+i-1]= duration
#	    if( clen > xlen )
#	    {
#	        call realloc(blist,xlen,TY_DOUBLE,xlen+h)
#		call realloc(elist,xlen,TY_DOUBLE,xlen)
#	    }
#	    else
#	    call qpex_close(inex)
	    if( ngti+cgti > xlen )
	    {
		xlen = xlen+clen 
		call realloc(blist,xlen,TY_DOUBLE)
		call realloc(elist,xlen,TY_DOUBLE)
	    }
	    call amovd(Memd[bcur],Memd[blist+ngti],cgti)
	    call amovd(Memd[ecur],Memd[elist+ngti],cgti)
	    ngti = ngti + cgti
	    call find_history(fd[1],nrecs)
	    do j=1,nrecs
	    {
		Memc[buf]=EOS
		call get_history(fd[1],j,Memc[hist])
		call sprintf(Memc[buf],SZ_LINE,"file %d")
		   call pargi(i)
                call put_qphistory(qp, Memc[buf], Memc[hist], "")
	    }
#	    if( i != NO_FILES(argv) )
	        call def_close(fd, temphead, display, argv)
	    call qpex_close(ex)
	    call mfree(bcur,TY_DOUBLE)
	    call mfree(ecur,TY_DOUBLE)
            Memc[hist]=EOS
#           call sprintf(Memc[hist],len,"file: %d %s events: %.1f times: %.2f RA
#off: %.1f Dec off: %.1f Roll off: %.1f (arcsec)")
            call sprintf(Memc[hist],SZ_EXPR,"file: %d %s events: %d times: %.1f")
                call pargi(i)
                call pargstr(Memc[fname])
                call pargi(Memr[EVENTS(argv)+i-1])
 		 call pargr(Memr[TIMES(argv)+i-1])
#               call pargr(Memr[RAOFF(argv)+i-1])
#               call pargr(Memr[DECOFF(argv)+i-1])
#               call pargr(Memr[ROLLOFF(argv)+i-1])
            if( display >0 ){
                call printf("\n%s\n")
                call pargstr(Memc[hist])
            }
	  }  # if valid
	  else
	  {
		Memc[hist]=EOS
		call sprintf(Memc[hist],len,"file: %d - invalid header - skipped")
		    call pargi(i)
		    call pargstr(Memc[fname])
	  }
          call put_qphistory(qp, "qpappend", Memc[hist], "")
        }      
        call fntrewb(FILLIST(argv))
	# Leave a file open, QPCREATE will need the 'fd' handle
	call def_open(Memc[fname], fd, trecs, convert, temphead, display,
				argv) 
#	duration = update_exp(Memc[filtkey],qp,ex,!gti,qphead)
        if( ngti > 0 )
             duration = sumtimes(blist,elist,ngti,display)
        else
             duration = 0.0D0
         call put_gtifilt(blist,elist,ngti,filtstr)
	call app_gtiaux2(blist,elist,ngti,qp)
 
        if( qp_accessf(qp,"deffilt") == YES)          
            call qp_deletef(qp,"deffilt") 
#  Minimum case - make sure old XS-FHIST string gets put in new file
        if( gti ){
                len=strlen(Memc[filtstr])
                if( qp_accessf(qp, Memc[filtkey]) == NO ){
#                    call qp_addf (qp, Memc[filtkey], "c", len+SZ_LINE,
#                                  "standard time filter", QPF_NONE)
                    call qpx_addf (qp, Memc[filtkey], "c", len+SZ_LINE,
                                   "standard time filter", QPF_INHERIT)
                }
                call qp_pstr(qp, Memc[filtkey], Memc[filtstr])
        }
#  End minimum case
	QP_ONTIME(qphead) = duration
        call fix_qphead_times(duration, qp, qphead)
#	call qpex_close(ex)
	Memc[hist]=EOS
        call sprintf(Memc[hist], SZ_EXPR, "%s (%s; %d files, no exp.) -> %s" )
          call pargstr(Memc[FLIST(argv)])
          call pargstr(Memc[REGIONS(argv)])
          call pargi(NO_FILES(argv))
          call pargstr(Memc[OUTNAME(argv)])
        # display, if necessary
        if( display >0 ){
            call printf("\n%s\n")
            call pargstr(Memc[hist])
        }
        # write the history record
        call put_qphistory(qp, "qpappend", Memc[hist], "")
#       	if( qp_accessf(qp, "NTSI") != NO )
#	{
#       	    i = qp_geti(qp, "NTSI")
#            call qp_puti (qp, "NTSI", i-1)
#	}
	call mfree(blist,TY_DOUBLE)
	call mfree(elist,TY_DOUBLE)
	call mfree(TIMES(argv),TY_REAL)
	call mfree(EVENTS(argv),TY_INT)
	call mfree(VALID(argv),TY_INT)
#	call mfree(RAOFF(argv),TY_REAL)
#	call mfree(DECOFF(argv),TY_REAL)
#	call mfree(ROLLOFF(argv),TY_REAL)
	call mfree(FLIST(argv),TY_CHAR)
	call mfree(OUTNAME(argv),TY_CHAR)
        call qp_seti(qp,QPOE_NODEFFILT, NO)
	call sfree(sp)
end

#
#
# APP_HIST -- write history (and a title) to qpoe file
#
procedure app_hist2(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
#int	i
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
pointer	fname
int	strlen()			# l: string length
#bool	streq()				# l: string compare

#pointer	mw

begin
	# mark the stack
	call smark(sp)
	call salloc(fname,SZ_PATHNAME,TY_CHAR)
	# allocate a string long enough
	len = strlen(Memc[FLIST(argv)])+
	      strlen(Memc[REGIONS(argv)])+
#	      strlen(Memc[EXPOSURE(argv)])+
	      strlen(qpname)+
	      2 * SZ_LINE
	call salloc(buf, len, TY_CHAR)

	call calloc(OUTNAME(argv),SZ_PATHNAME,TY_CHAR)
	call strcpy(qpname,Memc[OUTNAME(argv)],SZ_PATHNAME)
#        call fntrewb(FILLIST(argv))
#	do i=1,NO_FILES(argv)
#	{
#            call fntgfnb(FILLIST(argv),Memc[fname],SZ_PATHNAME)
#            Memc[buf]=EOS
##           call sprintf(Memc[buf],len,"file: %d %s events: %.1f times: %.2f RA
##off: %.1f Dec off: %.1f Roll off: %.1f (arcsec)")
# call sprintf(Memc[buf],len,"file: %d %s events: %d ")
#                call pargi(i)
#                call pargstr(Memc[fname])
#                call pargi(Memr[EVENTS(argv)+i-1])
##                call pargr(Memr[TIMES(argv)+i-1])
##               call pargr(Memr[RAOFF(argv)+i-1])
##               call pargr(Memr[DECOFF(argv)+i-1])
##               call pargr(Memr[ROLLOFF(argv)+i-1])
#            if( display >0 ){
#                call printf("\n%s\n")
#                call pargstr(Memc[buf])
#            }
#            call put_qphistory(qp, "qpappend", Memc[buf], "")
#	}
#
#        call fntrewb(FILLIST(argv))
#	Memc[buf]=EOS
#	# make a history comment
#	    call sprintf(Memc[buf], len, "%s (%s; %d files, no exp.) -> %s" )
#	    call pargstr(Memc[FLIST(argv)])
#	    call pargstr(Memc[REGIONS(argv)])
#	    call pargi(NO_FILES(argv))
#	    call pargstr(qpname)
#	# display, if necessary
#	if( display >0 ){
#	    call printf("\n%s\n")
#	    call pargstr(Memc[buf])
#	}
#	# write the history record
#	call put_qphistory(qp, "qpappend", Memc[buf], "")

	call put_qphead(qp,qphead)

        call qp_seti(qp,QPOE_NODEFFILT, YES)
	# free up stack space
	call sfree(sp)
end
#
# APP_OPEN -- open a qpoe file (or list of qpoe files) 
#
procedure app_open2(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

pointer	newqphead			# l: temp qphead
pointer	sp				# l: stack marker

int	i
int     trecs

bool	use
bool	qpc_mergehead()
int     fntopnb(),fntlenb()


begin
	call smark(sp)
	call salloc(newqphead,SZ_QPHEAD,TY_STRUCT)
        # display, if necessary
        if( display >1 ){
            call printf("opening input event file:\t%s\n")
            call pargstr(fname)
        }

	call calloc(FLIST(argv),SZ_PATHNAME,TY_CHAR)
	call strcpy(fname,Memc[FLIST(argv)],SZ_PATHNAME)

        # open the file
        FILLIST(argv)  = fntopnb(fname,0)
        NO_FILES(argv) = fntlenb(FILLIST(argv))
        if( display > 1 )
        {
            call printf("Total input files: %d\n")
            call pargi(NO_FILES(argv))
        }
        # end new stuff

        # new stuff
        irecs = 0
        trecs = 0

	call calloc(VALID(argv),NO_FILES(argv),TY_INT)
	convert = 0
        call fntrewb(FILLIST(argv))
#  Let's do the merge of headers FIRST, so we can see if there are any
#	problems before we work too hard.
        do i=1,NO_FILES(argv)
        {
            call fntgfnb(FILLIST(argv),fname,SZ_PATHNAME)
	    # first perform the usual open
	    if( i == 1)
	        call def_open(fname, fd, trecs, convert, qphead, display, argv)
	    else
	        call def_open(fname, fd, trecs, convert, newqphead, display, 
				argv)
	    use = qpc_mergehead(i,NO_FILES(argv),newqphead, qphead)
	    if( use ){
                irecs = irecs + trecs
		Memi[VALID(argv)+i] = YES
	    }
	    else
		Memi[VALID(argv)+i] = NO
	    call def_close(fd, newqphead, display, argv)
        }       
        call fntrewb(FILLIST(argv))
	call calloc(TIMES(argv),NO_FILES(argv),TY_REAL)
	call calloc(EVENTS(argv),NO_FILES(argv),TY_INT)
#	call calloc(RAOFF(argv),NO_FILES(argv),TY_REAL)
#	call calloc(DECOFF(argv),NO_FILES(argv),TY_REAL)
#	call calloc(ROLLOFF(argv),NO_FILES(argv),TY_REAL)
        FCOUNT(argv) = 1
        call fntgfnb(FILLIST(argv),fname,SZ_PATHNAME)
        if( display >= 1 )
        {
            call printf("Opening file #%d : %s \n")
              call pargi(FCOUNT(argv))
              call pargstr(fname)
        }
#        Memi[EVENTS(argv)+FCOUNT(argv)-1]=0
	call def_open(fname, fd, trecs, convert, newqphead, display, argv)
#        call qpc_mergehead(FCOUNT(argv),NO_FILES(argv),newqphead, qphead)

	call sfree(sp)
end

define SZ_EVBUF	512

#
# APP_GET -- read the next buffer of input events and create an output event
#		buffer
#
procedure app_get2(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]		# i: file descriptor
int	evsize			# i: size of output qpoe record
int	convert			# i: data conversion flag
pointer	sbuf			# o: event pointer
int	get			# i: number of events to get
int	got			# o: number of events got
pointer	qphead			# i: header
int	display			# i: display level
pointer	argv			# i: pointer to arg list

int	i			# l: loop counter
int	mval			# l: mask from qpio_getevent
int	nev			# l: number of events returned
int	evlen			# l: number of shorts to move
int	try			# l: number of events to try this time
int	evl[SZ_EVBUF]		# l: event pointer from qpio_getevent
int	size			# l: padded size of a qpoe record
pointer	ev			# l: pointer to current output record
#double  phase,phi,exp,tref


pointer newqphead
pointer sp

int	trecs
# new
char    fname[SZ_PATHNAME]
#short   head[SZ_UHEAD]
#double reftime_set()
#double  reftime
#int     start
# end new

int	qpio_getevents()	# l: get qpoe events
#int	qpc_lookup()		# l: look up an event element name

# Just to remember from call to call ( save)
#int	toffset		# x, y offsets
#int	ttype		# x, y data type
#common/phscom/toffset, ttype

begin
	# get x and y offsets, if necessary (but only once)
	call smark(sp)
	call salloc(newqphead,SZ_QPHEAD,TY_STRUCT)
	if( APPINIT(argv) == NO ){
#	    call get_qpoffs(0
#	    if( qpc_lookup("phase", ttype, toffset) == NO )
#		call error(1, "'time' undefined in event struct")
#	    if( ttype != TY_DOUBLE)
#		call error(1, "'time' must be TY_DOUBLE")
	    APPINIT(argv) = YES
# ***  Need to get access to these 'look-up' routines, each input file
	}
	# determine the number of shorts we move from input to output
	call qpc_movelen(fd[1], evsize, evlen)
	# determine the padded record size of the qpoe record
	call qpc_roundup(evsize, size)
	# get photons and calculate phase 
	got = 0
	while( got < get ){
	    # get the next batch of events
	    try = min(SZ_EVBUF, get-got)
	    if( qpio_getevents(fd[2], evl, mval, try, nev) != EOF){
		do i=1, nev{
		    # point to current record in sbuf
		    ev = sbuf + (got*size)
		    # inc number of events
		    got = got+1
		    # move the old record into the new one
#		    call amovs(Mems[evl[i]], Mems[ev], evlen)
#                      call amovs(Mems[evl[i]], Mems[ev], evlen)
                    call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
                                     evl[i], ev)
		    # Calculate phase of time 
#        	    ref = Mems[evl[i]+toffset] 
#		    call amovs(Mems[evl[i]+toffset],tref,SZ_DOUBLE)
#        	    tref = tref - PHSSTART(argv)
#	            call calc_phase (REFPER(argv), PDOT(argv), tref, display, 
#			phase, phi, exp)
#		    call amovs(phi,Mems[ev+toffset],SZ_DOUBLE)

		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
		}
		Memi[EVENTS(argv)+FCOUNT(argv)-1] = 
				Memi[EVENTS(argv)+FCOUNT(argv)-1] + nev 
	    }
            else # EOF with more files to go
            {
		convert = 0
                if( FCOUNT(argv) < NO_FILES(argv) )
                {
                    call def_close(fd,newqphead,display,argv)
		    APPINIT(argv) = NO
                    FCOUNT(argv) = FCOUNT(argv) + 1
		    Memi[EVENTS(argv)+FCOUNT(argv)-1] = 0
                    call fntgfnb(FILLIST(argv),fname,SZ_PATHNAME)
                    if( display > 1 )
                    {
                        call printf("Opening file #%d : %s \n")
                        call pargi(FCOUNT(argv))
                        call pargstr(fname)
                    }
	    	    call def_open(fname, fd, trecs, convert, newqphead, 
				  display, argv)
#		    call disp_qphead(newqphead,"dummy",display)
#                    call qpc_mergehead(FCOUNT(argv),NO_FILES(argv),newqphead, qphead)
                }
                else # end of ALL input files
                    break # out of the while
        
           }
}	# end while
	call sfree(sp)
end


#JCC(6/12/97) - if TSIREC has different formats, output NTSI=0
#               and use the format in the 1st file for TSIREC
#             - try to distinguish nrecs from already_merged_qp (qp) 
#               and inqp  : add a new variable "nrecs_mqp"
#
procedure app_tsiaux2(inqp,qphead,qp,fileno,display,argv)

pointer	inqp            # qpoe that will be appended 
pointer	qp              # already_merged_qpoe so far

pointer	qphead
int	fileno          # file number for inqp
int	display
pointer	argv		# l: qpcreate control structure

#JCC(6/12/97) - add nrecs_mqp 
int	nrecs		# NTSI in the current qpoe (inqp)
int	nrecs_mqp       # NTSI in already_merged_qpoe (qp)

pointer	sp
pointer	tsidef		# l: ptr to XS-TSIREC in already_merged_qpoe
pointer	ntsidef		# l: ptr to XS-TSIREC in current qpoe (inqp)
pointer	irafdef		# l: pointer to IRAF definition string
pointer	tsiptr		# l: list of elements in TSI rec
pointer	ntsiptr		# l: list of elements in TSI rec
#pointer	tsiargv		# l: TSI record control structure
int	tsicnt		# l: number of elements in TSI Rec
int	ntsicnt		# l: number of elements in TSI Rec
int	tsisize		# l: length of TSI record in TY_STRUCT units
#int	ntsireclen	# l: length of TSI record in TY_STRUCT units
#int	tsireclen	# l: length of TSI record in TY_STRUCT units
int	ntsisize	# l: length of TSI record in TY_STRUCT units
int	ntsize
int	tsize
pointer	qptsi		# l: pointer to TSI records
pointer	oqptsi		# l: pointer to TSI records
int	ii
pointer	ibuf,obuf
#pointer	tsistr
pointer	tsidescp

pointer	qp_accessf()
int	qp_geti()
bool	streq()
# Static common to remember current record number
int	recno
#common	/stats/recno
begin

     recno = 0
     call smark(sp)
     if( fileno == 1 )
     {
        if( QP_REVISION(qphead) >= 1 || QP_MISSION(qphead) == 0 )
        {
           call get_gtsi(inqp, "TSI", tsidef, tsiptr, tsicnt, tsisize, 
                qptsi, tsidescp, nrecs)
           if( display > 2 )
           {
              call disp_gtsi(P2S(qptsi), nrecs, QP_INST(qphead), 
                   Memc[tsidef],tsisize)
            }
        }
        else
        {
	   call calloc(tsidef,SZ_EXPR,TY_CHAR)
           if( qp_accessf(inqp, "XS-TSIREC") == YES)
	      call qp_gstr(inqp,"XS-TSIREC", Memc[tsidef], SZ_EXPR)
	   else
              nrecs = 0
              call get_tsi(inqp, QP_INST(qphead), qptsi, nrecs) 
	      if( display > 2)
	           call disp_tsi(qptsi, nrecs, QP_INST(qphead))
	      call mfree(tsiptr,TY_STRUCT)
	      call mfree(tsidescp,TY_STRUCT)
        }  # end of   if( QP_REVISION...)

        if( nrecs > 0 )
	{
           call salloc(irafdef,SZ_EXPR,TY_CHAR)
	   call ev_strip(Memc[tsidef], Memc[irafdef], SZ_EXPR,0)
           ##call tsi_put(qp, qptsi, nrecs, qphead, display,argv)
           call put_tsi(qp, qptsi, nrecs, qphead, irafdef, tsidef)
	   if( display > 2 )
           {
	      if( QP_REVISION(qphead) >= 1 || QP_MISSION(qphead) == 0)
              {  
                 call disp_gtsi(P2S(qptsi), nrecs, QP_INST(qphead), 
                      Memc[tsidef],tsisize)
              }
	      else
                 call disp_tsi(qptsi, nrecs, QP_INST(qphead))
           }  # end ( if display > 2)
           #recno = nrecs+1
	   recno = nrecs		# will be incremented later
           call mfree(tsidef,TY_CHAR)
	}  # end nrecs > 0 )
        else
        {
	   call eprintf("WARNING: no TSI records found in file #: %d\n")
	   call pargi(fileno)
         }
     }    # ( fileno == 1 ) "
     else # fileno != 1
     {
        if( qp_accessf(qp, "NTSI") == NO )
           nrecs = 0
        else
        {    
           nrecs = qp_geti(qp, "NTSI") 
                   # qp : ptr to qpoe that has been merged so far 
           nrecs_mqp = nrecs  #JCC(6/12/97) - save it, see below
        }
        
        recno = nrecs
        # Get definition used in output file
	call calloc(tsidef,SZ_EXPR,TY_CHAR)
       	if( qp_accessf(qp, "XS-TSIREC") == YES)
	   call qp_gstr(qp,"XS-TSIREC", Memc[tsidef], SZ_EXPR)
	else
           nrecs = 0

        if( QP_REVISION(qphead) >= 1 || QP_MISSION(qphead) == 0 )
        {
           call get_gtsi(inqp, "TSI", ntsidef, tsiptr, tsicnt, ntsisize, 
                qptsi, tsidescp, nrecs)
	   if( display > 2 )
           { 
              call disp_gtsi(P2S(qptsi), nrecs, QP_INST(qphead),
		   Memc[ntsidef],ntsisize)
           }
	   call mfree(tsiptr,TY_STRUCT)
           call mfree(tsidescp,TY_STRUCT)
        }
        else
        {
	   call calloc(ntsidef,SZ_EXPR,TY_CHAR)
       	   if( qp_accessf(inqp, "XS-TSIREC") == YES)
	      call qp_gstr(inqp,"XS-TSIREC", Memc[ntsidef], SZ_EXPR)
	   else
              nrecs = 0

           #inqp: ptr to qpoe that will be appended to ptr "qp"
           #nrecs:  NTSI in "inqp"
           call get_tsi(inqp, QP_INST(qphead), qptsi, nrecs) 

	   if( display > 2 )
               call disp_tsi(qptsi, nrecs, QP_INST(qphead))
        }
        #
        #JCC(6/12/97) - if NTSI in already_merged_qpoe (ptr "qp") is ZERO
        #               (ie.  nrecs_mqp==0), it indicates that XS_TSIREC 
        #               was different before when merging qpoe's.
        #
        # If all input files not in SAME TSI format, just don't do them
        #
        #JCC(6/12/97) - add   (if  nrecs_mqp == 0 )

        #if( nrecs > 0 && !streq(Memc[tsidef],Memc[ntsidef]) )

	if((nrecs > 0 && !streq(Memc[tsidef],Memc[ntsidef]) )
             || nrecs_mqp == 0 )
        {
	 call eprintf("TSI formats differ, no TSI information in output file\n")
	    nrecs = 0
	    recno = 0
        }

	if( nrecs > 0 )
	{
	   if( recno == 0 )	# Initialize if no TSI recs yet
	   {
	      call salloc(irafdef,SZ_EXPR,TY_CHAR)
	      call ev_strip(Memc[ntsidef], Memc[irafdef], SZ_EXPR,0)
              call put_tsi(qp, qptsi, nrecs, qphead, irafdef, tsidef)
	      recno = nrecs	# incremented next time
           }
	   else
	   {
              call parse_descriptor(Memc[tsidef],tsiptr,tsize,tsicnt)
	      call parse_descriptor(Memc[ntsidef],ntsiptr,ntsize,ntsicnt)
	      ntsisize = ntsize / SZB_CHAR
	      tsisize = tsize / SZB_CHAR
	      call qpc_roundup(ntsisize,ntsize)
	      ntsize = ntsize / SZ_STRUCT
	      call calloc(oqptsi,nrecs*ntsize,TY_STRUCT)
	      call compare_descriptors(ntsiptr,tsiptr,ntsicnt,tsicnt)
	      do ii = 1,nrecs
	      {
	         ibuf = P2S( qptsi) +(ii-1)*tsisize
		 obuf = P2S(oqptsi) +(ii-1)*ntsisize
                 call qp_movedata(tsicnt, tsiptr, ibuf, obuf)
	      }
	      obuf = P2S(oqptsi)
	      obuf = P2S(qptsi)
              # call disp_gtsi(obuf, nrecs, QP_INST(qphead),
              #      Memc[ntsidef],ntsisize)
              # call disp_gtsi(P2S(qptsi), nrecs, QP_INST(qphead),
              #		Memc[ntsidef],ntsisize)
              #  IRAF has a problem with starting a second BUFFER record 
              #  unless aligned on a STRUCT boundary

              ii = recno + 1

              # if( (ii/2) * 2 == ii)
              #    if( (tsisize/2) * 2 != tsisize )
              #      ii = ii-1
	      call qp_write(qp,"TSI",Mems[obuf],nrecs,ii,"TSIREC")
	           recno = recno+nrecs		# incremented when used
	      call free_descriptor(tsiptr,tsicnt)
	      call free_descriptor(ntsiptr,ntsicnt)
           }	# end recno == 0
        }	# end nrecs > 0
        if( qp_accessf(qp,"NTSI") == YES )
	    call qp_puti (qp, "NTSI", recno)
     }   # end fileno == 1
     call mfree(qptsi,TY_STRUCT)
     if( fileno != 1)
     {
        call mfree(oqptsi,TY_STRUCT)
        call mfree(ntsidef,TY_CHAR)
     }
     call mfree(tsidef,TY_CHAR)
     call sfree(sp)
end   # end app_tsiaux2()

procedure app_gtiaux2(blist,elist,nlist,qp)
pointer	blist
pointer	elist
int	nlist
pointer	qp
#pointer	argv

pointer	qpgti
begin
	call reformat_gti(blist,elist,nlist,qpgti)
	call put_qpgti(qp, qpgti, nlist)
	if( nlist > 0 )
	    call mfree(qpgti,TY_STRUCT)
end

procedure app_remove2(qp,argv)
pointer	qp
pointer	argv

int	qp_accessf()
# Remove all AUXILIARY records that were inherited.  These must all
# be merged and re-written
begin
     if( DOTSI(argv)==YES)
     {
        if( qp_accessf(qp, "NTSI") == YES )
            call qp_deletef(qp, "NTSI")
        if( qp_accessf(qp, "XS-TSIREC") == YES )
            call qp_deletef(qp, "XS-TSIREC")
        if( qp_accessf(qp, "TSIREC") == YES )
            call qp_deletef(qp, "TSIREC")
        if( qp_accessf(qp, "TSI") == YES )
            call qp_deletef(qp, "TSI")
     }
        if( qp_accessf(qp, "NGTI") == YES )
            call qp_deletef(qp, "NGTI")
        if( qp_accessf(qp, "XS-GTIREC") == YES )
            call qp_deletef(qp, "XS-GTIREC")
        if( qp_accessf(qp, "GTIREC") == YES )
            call qp_deletef(qp, "GTIREC")
        if( qp_accessf(qp, "GTI") == YES )
            call qp_deletef(qp, "GTI")
        
	if( qp_accessf(qp, "NSTD") == YES )
            call qp_deletef(qp, "NSTD")
        if( qp_accessf(qp, "XS-STDREC") == YES )
            call qp_deletef(qp, "XS-STDREC")
        if( qp_accessf(qp, "STDREC") == YES )
            call qp_deletef(qp, "STDREC")
        if( qp_accessf(qp, "STD") == YES )
            call qp_deletef(qp, "STD")

	if( qp_accessf(qp, "NALL") == YES )
            call qp_deletef(qp, "NALL")
        if( qp_accessf(qp, "XS-ALLREC") == YES )
            call qp_deletef(qp, "XS-ALLREC")
        if( qp_accessf(qp, "ALLREC") == YES )
            call qp_deletef(qp, "ALLREC")
        if( qp_accessf(qp, "ALL") == YES )
            call qp_deletef(qp, "ALL")

        if( qp_accessf(qp, "NTGR") == YES )
            call qp_deletef(qp, "NTGR")
        if( qp_accessf(qp, "XS-TGRREC") == YES )
            call qp_deletef(qp, "XS-TGRREC")
        if( qp_accessf(qp, "TGRREC") == YES )
            call qp_deletef(qp, "TGRREC")
        if( qp_accessf(qp, "TGR") == YES )
            call qp_deletef(qp, "TGR")
end	
