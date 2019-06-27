#$Header: /home/pros/xray/xtiming/qpphase/RCS/qpphase.x,v 11.0 1997/11/06 16:46:00 prosb Exp $
#$Log: qpphase.x,v $
#Revision 11.0  1997/11/06 16:46:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:36:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:44:44  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/19  12:41:57  mo
#MC	5/19/94		Fixed format for history record  (Bug 5/17/94)
#
#Revision 7.0  93/12/27  19:06:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:01:22  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:10:44  mo
#MC	5/20/93		Update for new QPCREATE changes to support general
#			EVENT structures
#
#Revision 5.0  92/10/29  22:41:25  prosb
#General Release 2.1
#
#Revision 1.1  92/10/23  09:57:36  mo
#Initial revision
#
#Revision 1.1  92/10/23  09:56:23  mo
#Initial revision
#
#Revision 4.0  92/04/27  14:29:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  14:56:54  mo
#MC	4/13/92		Displace the ARGV structure definitions by 1
#			to accomodate new region summary string in DEF_ARGV
#
#Revision 3.0  91/08/02  01:17:50  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:13:15  pros
#General Release 1.0
#
#
# QPROTATE -- rotate a qpoe file (with possible regions and filters)
#

include <math.h>
include <qpoe.h>
include <qpc.h>

# the first part of argv is defined in qpc.h
# define the other parts of argv we will need
define	SZ_ARGV		(SZ_DEFARGV+10)
define	PHSINIT		Memi[$1+SZ_DEFARGV+1]
define	REFPER		Memd[P2D(($1)+SZ_DEFARGV+2)]# initial period(seconds)
define	PDOT		Memd[P2D(($1)+SZ_DEFARGV+4)]# rate of change in period
define	PHSSTART	Memd[P2D(($1)+SZ_DEFARGV+6)]# start time of data

#
#  T_QPPHASE-- main task to add a time phase column to a QPOE file
#
procedure t_qpphase()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv, SZ_ARGV+10, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers and allocate argv space
	call phs_load()
	PHSINIT(argv) = NO
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  PHS_LOAD -- load driver routines
#
procedure phs_load()

extern	phs_open(), phs_get(), def_close()
extern	phs_getparam(), phs_hist()


begin
	# load the event drivers
	call qpc_evload("input_qpoe", ".qp", phs_open, phs_get, def_close)
	# load getparam routine
	call qpc_parload(phs_getparam)
	# load history routine
	call qpc_histload(phs_hist)
	# flag we have no x,y offsets
end

#
# PHS_GETPARAM -- get region parameter for qpphase
#
procedure phs_getparam(ifile, argv)

char	ifile[ARB]		# input file name
pointer	argv			# argument list pointer
double	clgetd()		# get real param

begin
	# get standard params
	call def_getparam(ifile, argv)
	# get special qprotate params
        REFPER(argv) = clgetd("period")
        PDOT(argv) = clgetd("pdot")
#	ANGLE(argv) = DEGTORAD(clgetr("angle"))
end

#
# PHS_HIST -- write history (and a title) to qpoe file
#
procedure phs_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
int	strlen()			# l: string length
bool	streq()				# l: string compare

#pointer	mw

begin
	# mark the stack
	call smark(sp)
	# allocate a string long enough
	len = strlen(Memc[file[1]])+
	      strlen(Memc[REGIONS(argv)])+
	      strlen(Memc[EXPOSURE(argv)])+
	      strlen(qpname)+
	      SZ_LINE
	call salloc(buf, len, TY_CHAR)

	# make a history comment
	if( streq("NONE", Memc[EXPOSURE(argv)]) ){
	    call sprintf(Memc[buf], len, "%s (%s; no exp.; period=%.8e; pdot=%.6e) -> %s" )
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargd(REFPER(argv))
	    call pargd(PDOT(argv))
	    call pargstr(qpname)
	}
	else{
	    call sprintf(Memc[buf], len, "%s (%s; %s %.2f; period=%.8e; pdot=%.6e) -> %s"  )
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(Memc[EXPOSURE(argv)])
	    call pargr(THRESH(argv))
	    call pargd(REFPER(argv))
	    call pargd(PDOT(argv))
	    call pargstr(qpname)
	}
	# display, if necessary
	if( display >0 ){
	    call printf("\n%s\n")
	    call pargstr(Memc[buf])
	}
	# write the history record
	call put_qphistory(qp, "qpphase", Memc[buf], "")

	# write the new rotation angle into the wcs

	# free up stack space
	call sfree(sp)
end

#
# PHS_OPEN -- open a qpoe file and an event list through a region
#		and determine some constant quantities for the phase 
#
procedure phs_open(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

double	start_time,stop_time
int	soffset

begin
	# first perform the usual open
	call def_open(fname, fd, irecs, convert, qphead, display, argv)
#   Check the event definition has times, and retrieve the start and stop
        call tim_cktime(fd[1],"source",soffset)
        call tim_getss (display, fd[2], soffset, start_time, stop_time)
	PHSSTART(argv) = start_time

#   Retrieve the input file name and open the qpoe file
#        call t_openqp (SOURCEFILENAME, EXT_STI, Memc[sevlist], 
#                       Memc[photon_file], none, sqp)
#        src_ptr = qpio_open (sqp, Memc[sevlist], READ_ONLY)

#   Check the event definition has times, and retrieve the start and stop
#         call tim_cktime(sqp,"source",soffset)
#         call tim_getss (display, src_ptr, soffset, start_time, stop_time)

#   Assign a phase to each qpoe event
#        while ( tim_getnxtime (src_ptr,mval,nev,evl,qrec,soffset,phot_time) ) {



	if( display >=4 ){
#	    call printf("angle: %.2f -> %.2f\n")
#	    call pargr(RADTODEG(OANGLE(argv)))
#	    call pargr(RADTODEG(ANGLE(argv)))
#	    call printf("sin(o-n): %.2f; cos(o-n): %.2f\n")
#	    call pargr(SINB(argv))
#	    call pargr(COSB(argv))
#	    call printf("x, y plate scale ratios: %.2f %.2f\n")
#	    call pargr(PLATE1(argv))
#	    call pargr(PLATE2(argv))
	}
end

define SZ_EVBUF	512

#
# PHS_GET -- read the next input event and create an output event
#
procedure phs_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

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
double  phase,phi,exp,tref

int	qpio_getevents()	# l: get qpoe events
int	qpc_lookup()		# l: look up an event element name

# Just to remember from call to call ( save)
int	poffset		# phase offsets
int	ptype		# phase data type
int	toffset		# time offsets
int	ttype		# time data type
common/phscom/toffset, ttype

begin
	# get x and y offsets, if necessary (but only once)
	if( PHSINIT(argv) == NO ){
	    if( qpc_lookup("phase", ptype, poffset) == NO )
		call error(1, "'phase' undefined in event struct")
	    if( ptype != TY_DOUBLE)
		call error(1, "'phase' must be TY_DOUBLE")
	    if( qpc_lookup("time", ttype, toffset) == NO )
	    {
		# Assume that output-phase is REPLACING input-time
		ttype = ptype
		toffset = poffset
	    }
#		call error(1, "'time' undefined in event struct")
	    if( ttype != TY_DOUBLE)
		call error(1, "'time' must be TY_DOUBLE")
	    PHSINIT(argv) = YES
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
                    #--------------------------------
                    # point to current record in sbuf
                    #--------------------------------
                    ev = sbuf + (got*size)

                    #---------------------
                    # inc number of events
                    #---------------------
                    got = got+1

		    # Calculate phase of time 
#        	    ref = Mems[ev+toffset] 
		    # Get input data from INPUT buffer (evl)
		    call amovs(Mems[evl[i]+toffset],tref,SZ_DOUBLE)
        	    tref = tref - PHSSTART(argv)
	            call calc_phase (REFPER(argv), PDOT(argv), tref, display, 
			phase, phi, exp)

                    #---------------------------------------------------
                    # if instrument is PSPC and events are large_to_full
                    # or full_to_large, shift the events
                    #---------------------------------------------------
                    if (IN_L_TO_F(argv) || IN_F_TO_L(argv))
                    {
                       call def_shift(evl[i], ev, argv)
                    }
                    else
                    {
#                      call amovs(Mems[evl[i]], Mems[ev], evlen)
                       call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
                                        evl[i], ev)
                    }

		    #  Put answer input OUTPUT buffer
		    call amovs(phi,Mems[ev+poffset],SZ_DOUBLE)

		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
		}
	    }
	    else
		break
	}
end






