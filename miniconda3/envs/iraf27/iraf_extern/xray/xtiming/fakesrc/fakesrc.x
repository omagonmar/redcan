#$Header: /home/pros/xray/xtiming/fakesrc/RCS/fakesrc.x,v 11.0 1997/11/06 16:44:22 prosb Exp $
#$Log: fakesrc.x,v $
#Revision 11.0  1997/11/06 16:44:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:28  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:22:51  dvs
#Made more general: checks for QPOE indices instead of assuming "x" and "y".
#
#Revision 8.0  94/06/27  17:39:28  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:37  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:25  prosb
#General Release 2.1
#
#Revision 2.1  91/12/18  14:47:12  mo
#MC	12/18/91		No changes
#
#Revision 2.0  91/03/06  22:40:48  pros
#General Release 1.0
#
#
#	FAKENEW.X -- new version of fakesrc that makes the qpoe file directly
#

include <mach.h>
include <qpc.h>
include <qpoe.h>
include <einstein.h>
include <clk.h>
include	"fakesrc.h"
#include	"/iraf/iraf/sys/qpoe/qpoe.h"

procedure t_fakesrc()
pointer	argv				# user argument list
int	qpc_ty				# type of qpoe file to create
begin
	qpc_ty = QPOE
	goto 99
entry t_fakefits()
	qpc_ty = A3D
	goto 99
99	# done determining output file type
	# init the driver arrays (0 auxiliary files)
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv,LEN_ARG,TY_STRUCT)
	call calloc(AR_FNMN,SZ_PATHNAME,TY_CHAR)
	call def_alloc(argv)
	# load the drivers
	call fake_load()
	# call the convert task
	if (qpc_ty == QPOE)
	  call qp_create(argv)
	else if (qpc_ty == A3D)
	  call a3d_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free argv space
	call mfree(AR_FNMN,TY_CHAR)
	call mfree(AR_FNCA,TY_DOUBLE)
	call def_free(argv)
	call mfree(argv,TY_STRUCT)
end


#
#  FAKE_LOAD -- load procs, params, ext names, and allocate argv space
#
procedure	fake_load()
extern	fake_open(),fake_get(),fake_close()
extern	fkhd_open(),fkhd_get(),fkhd_close()
extern	fake_getparam(),fake_wrhistory()

# shared with fake_get
int	fakeinit		# flag if we have determined the offsets
int	fakeoff[7]		# x, y, pha, pi, time, dx, dy offsets
common/fakecom/fakeinit, fakeoff
begin
	# load the event drivers
	call qpc_evload("source_file","", fake_open, fake_get, fake_close)
	# load the header drivers
	call qpc_hdload("header",".mhdr", fkhd_open, fkhd_get, fkhd_close);
	# no sorting
	call qpc_setsort(NO)
	# load getparam and history files
	call qpc_parload(fake_getparam)
	call qpc_histload(fake_wrhistory)	
	#reset offset flag
	fakeinit	= NO
end


#
#  FAKE_GETPARAM -- get fakesource-specific parameters
#
procedure fake_getparam(ifile,argv)
char	ifile[ARB]			# i: input file name
pointer	argv				# i/o: argument pointer list

bool	clobber				# clobber files? second copy.

pointer	sp
pointer	flnm				# source file name
pointer	flnm1				# profile file name

bool	clgetb()			# get boolean parameter
double	clgetd()			# get double parameter
int	clgeti()			# get integer parameter
int	open()				# open an ascii file
bool	streq()				# check for equality of two strings
long	cputime()
begin
	call smark(sp)
	call salloc(flnm ,SZ_PATHNAME,TY_CHAR)
	call salloc(flnm1,SZ_PATHNAME,TY_CHAR)

	# get general parameters
	call clgstr("title", Memc[TITLE(argv)], SZ_LINE)
	AR_LENA	= clgetd("length_of_aquisition")
	AR_SEQN	= clgeti("sequence_number")
	clobber		= clgetb("clobber")
	call clgstr("source_file",AR_FNNM,SZ_PATHNAME)
	
	# open the pulse profile file, if needed
	call clgstr("profile_file",Memc[flnm],SZ_PATHNAME)
	if (streq("NONE",Memc[flnm]))
	  AR_DOPR	= (1==0)
	else {
	  AR_DOPR	= (1==1)
	  call clobbername(Memc[flnm],Memc[flnm1],clobber,SZ_PATHNAME)
	  AR_PROF	= open(Memc[flnm1],NEW_FILE,TEXT_FILE)
	}

	# seed random number generator well
	AR_SEED	= cputime(0)
	call sfree(sp)
end


#
#  FAKE_WRHISTORY -- write history record (required by qpcreate routines)
#
procedure fake_wrhistory(qp,qpname,file,qphead,display,argv)
pointer	qp				# i: qp handle
char	qpname[SZ_FNAME]		# i: output qp file
pointer	file				# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

pointer	sp				# stack pointer
pointer	buf				# history line
int	len				# length of history line

int	strlen()			# string length
int	qp_accessf()			# qpoe specialized test function
int	qpc_type()			# what type of file are we making?
begin
	call smark(sp)
	len	= strlen(qpname) +
		  strlen(AR_FNNM) +
		  SZ_LINE
	call salloc(buf,len,TY_CHAR)

	# make a history comment
	call sprintf(Memc[buf],len,"%s used to create %s")
	 call pargstr(AR_FNNM)
	 call pargstr(qpname)

	# display if necessary
	if (display>0) {
	  call printf("\n%s\n")
	   call pargstr(Memc[buf])
	  call printf("title: %s\n")
	   call pargstr(Memc[TITLE(argv)])
	}

	if ( qpc_type() == QPOE ) {
	  # write the history record
	  call put_qphistory(qp,"fakesrc",Memc[buf],"")
	  # write title to the file
	  if (qp_accessf(qp,"title") == NO)
	    call qp_addf(qp,"title","c",len,"qpoe title",0)
	  call qp_astr(qp,"title",Memc[TITLE(argv)])
	}
	if ( qpc_type() == A3D ) {
	  call fts_putc(qp, "HISTORY", Memc[buf], "Creation of FITS file")
	  call fts_putc(qp, "TITLE", Memc[TITLE(argv)], "Title of data")
	}
	call sfree(sp)
end


#
#  FAKE_OPEN -- open the data rate file, and store its data.
#
procedure fake_open(fname,fl_dsc,irecs,convert,qphead,display,argv)
char	fname[ARB]			# i: name of list file
int	fl_dsc				# o: list file
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# o: general pointer to everything

double	ptime				# dummy time variable

int	srcfl				# source file
int	i,j

bool	access()			# find access ability to a file
int	fscan()				# read from an ascii file
int	open()				# open a file

begin
	# Get source function
	# open file
	if (!(access(AR_FNNM,READ_ONLY,TEXT_FILE)))
	  call error(2,"Specified source rate file does not exist")

	# find out how much data, then get it
	srcfl	= open(AR_FNNM,READ_ONLY,TEXT_FILE)
	AR_NUMB	= 0
	while (fscan(srcfl,"%f %f") != EOF) {
	  call gargd(ptime)
	  call gargd(ptime)
	  AR_NUMB	= AR_NUMB + 1
	}
	call close(srcfl)
	srcfl	= open(AR_FNNM,READ_ONLY,TEXT_FILE)
	call malloc(AR_FNCA,2 * AR_NUMB,TY_DOUBLE)
	AR_TOTT	= 0
	for ( i=1 ; i<=AR_NUMB ; i=i+1) {
	  j	= fscan(srcfl,"%f %f")
	   call gargd(AR_FNCB(i - 1))
	   call gargd(AR_FNCB(i + AR_NUMB - 1))
	  AR_TOTT	= AR_TOTT + AR_FNCB(i + AR_NUMB - 1)
	}

	call close(srcfl)

	# initialize other stuff
	AR_TIME	= 0
	AR_INLT	= 0
end

#
#  FAKE_GET -- read the next input event and create an output event
#		for now, just a copy of DEF_GET
#
procedure fake_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)
int	fd				# i: file descriptor (unused)
int	evsize				# i: size of output qpoe record
int	convert				# i: data conversion flag
pointer	sbuf				# o: sbuf pointer
int	get				# i: number of records to get
int	got				# o: number of records got
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

double	time				# time of event
double	itime				# interval time
int	size				# padded size of qpoe record
int	junk				# junk for qpc_lookup
pointer ev				# pointer to an event
real	rn				# random number

double	interval()			# get a random interval time
int	qpc_lookup()
real	urand()				# random number generator

# shared with fake_load
int	fakeinit		# flag if we have determined the offsets
int	fakeoff[7]		# x, y, pha, pi, time, dx, dy offsets
common/fakecom/fakeinit, fakeoff

begin
	call qpc_time("create event - start", display)

	# get x and y offsets, if necessary (but only once)
	if( fakeinit == NO ){
	    if( qpc_lookup(QP_INDEXX(qphead), junk, fakeoff[1]) == NO )
		call errstr(1, "event structure must have x-index defined",
			QP_INDEXX(qphead))
	    else
		if( junk != TY_SHORT )
		    call errstr(1, "x-index must be TY_SHORT",QP_INDEXX(qphead))
	    if( qpc_lookup(QP_INDEXY(qphead), junk, fakeoff[2]) == NO )
		call errstr(1, "event structure must have y-index defined",
			QP_INDEXY(qphead))
	    else
		if( junk != TY_SHORT )
		    call errstr(1, "y-index must be TY_SHORT",QP_INDEXY(qphead))

	  if( qpc_lookup("pha", junk, fakeoff[3]) == NO )
	    fakeoff[3] = -1
	  else
	    if( junk != TY_SHORT )
	      call error(1, "'pha' must be TY_SHORT")
	  if( qpc_lookup("pi", junk, fakeoff[4]) == NO )
	    fakeoff[4] = -1
	  else
	    if( junk != TY_SHORT )
	      call error(1, "'pi' must be TY_SHORT")
	  if( qpc_lookup("time", junk, fakeoff[5]) == NO )
	    fakeoff[5] = -1
	  else
	    if( junk != TY_DOUBLE )
	      call error(1, "'time' must be TY_DOUBLE")
	  if( qpc_lookup("dx", junk, fakeoff[6]) == NO )
	    fakeoff[6] = -1
	  else
	    if( junk != TY_SHORT )
	      call error(1, "'dx' must be TY_SHORT")
	  if( qpc_lookup("dy", junk, fakeoff[7]) == NO )
	    fakeoff[7] = -1
	  else
	    if( junk != TY_SHORT )
	      call error(1, "'dy' must be TY_SHORT")
	  fakeinit = YES
	}

	# make sure user asked for a valid event type
	if( evsize ==0 )
	  call error(1, "event type must be peewee, small, medium, or large")
	else
	# get the actual record size (padded to a double)
	  call qpc_roundup(evsize, size)

	# get photons until we have enough or time is up
	got = 0
	while( got < get ){
	  ev = sbuf + (got * size)

	  # get next time
	  rn	= urand(AR_SEED)
	  itime	= interval(Memd[AR_FNCA], AR_NUMB, AR_LSTB, AR_INLT, rn,
		   display)
	  AR_TIME	= AR_TIME + itime
	  time = AR_TIME + QP_DATEOBS(qphead) * 86400.0 + QP_TIMEOBS(qphead)

	  # put values in QP record
	  # X
	  if( fakeoff[1] >=0 )
	    Mems[ev+fakeoff[1]] = DEFAULT_X
	  # Y
	  if( fakeoff[2] >=0 )
	    Mems[ev+fakeoff[2]] = DEFAULT_Y
	  # PHA
	  if( fakeoff[3] >=0 )
	    Mems[ev+fakeoff[3]] = DEFAULT_PHA
	  # PI
	  if( fakeoff[4] >=0 )
	    Mems[ev+fakeoff[4]] = DEFAULT_PI
	  # TIME
	  if( fakeoff[5] >=0 )
	    Memd[(ev+fakeoff[5]-1)/SZ_DOUBLE+1] = time
	  # DX
	  if( fakeoff[6] >=0 )
	    Mems[ev+fakeoff[6]] = DEFAULT_DX
	  # DY
	  if( fakeoff[7] >=0 )
	    Mems[ev+fakeoff[7]] = DEFAULT_DY

	  if (AR_TOTT < AR_TIME) {
	    break
	  }

#	  if (display >= 5)				# if necessary,
#	    call disp_qpevent(ev,evsize)		# display event
	  got	= got + 1		# increment number of events
	}

	call qpc_time("create event - end", display)
end

#
#  FAKE_CLOSE -- close qp files and de-allocate space in argv
#
procedure fake_close(fd,qphead,display,argv)
int	fd				# i: file descriptor, unused
pointer	qphead				# i: header, unused
int	display				# i: display level
pointer	argv				# i: pointer to real file info.

begin
end

#
#  FAKE_FINAL -- dummy final procedure
#
procedure fake_final(fd,qp,io,evsize,convert,qphead,display,argv)
int	fd[ARB]
pointer	qp
pointer	io
int	evsize
int	convert
pointer	qphead
int	display
pointer	argv

begin
	fd[1]	= fd[1]			# avoid compilation messages
	qp	= qp
	io	= io
	evsize	= evsize
	convert	= convert
	qphead	= qphead
	display	= display
	argv	= argv
end

#
#  FKHD_OPEN -- null routine to make qpcreate think a header is being opened. 
#		This will eventually ope such a file, if it exists, for header 
#		information only.
#
procedure fkhd_open(fname, fd, convert, display, argv)
char	fname[ARB]			# i: header file name
int	fd				# o: file descriptor
int	convert				# i: data conversion flag
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	argv=argv			# avoid compiler warning
	convert=convert
	if (display >= 5) {
	  call printf("Not really opening null header file.\n")
	}
end

#
#  FKHD_CLOSE -- same deal as open
#
procedure fkhd_close(fd,qphead,display,argv)
int	fd				# i: header fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
begin
	qphead=qphead			# avoid compiler warnings
	argv=argv
	fd=fd
	if (display >= 5) {
	  call printf("Not closing unopened silly header file.\n")
	}
end

#
#  FKHD_GET -- devise a reasonable header
#
procedure fkhd_get(fd,convert,qphead,display,argv)
int	fd				# i: header file
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header
int	display				# i: display level
pointer argv				# o: pointer to arg list

double	mjd				# modified julian date
long	ctime				# clock time
pointer	sp
pointer	refclk				# date/time structure

long	clktime()			# clock time in seconds
double	mutjd()				# convert ut to jd
begin
	fd=fd				# avoid compiler warning
	convert=convert

	# set up date/time structure
	call smark(sp)
	call salloc(refclk, LEN_CLK, TY_STRUCT)

	# actually give decent fake heaader values.
	#  as if it is a standard einstein ipc mission pointed at 0,0
	QP_MISSION(qphead)	= EINSTEIN
	call strcpy("Einstein",QP_MISSTR(qphead),SZ_QPSTR)
	QP_INST(qphead)		= EINSTEIN + 1 + and(EINSTEIN_IPC,
							EINSTEIN_INSTMASK)
	call strcpy("IPC",QP_INSTSTR(qphead),SZ_QPSTR)
	QP_EQUINOX(qphead)	= EINSTEIN_EQUINOX
	call strcpy(CTYPE1, QP_CTYPE1(qphead), SZ_WCSSTR)
	call strcpy(CTYPE2, QP_CTYPE2(qphead), SZ_WCSSTR)
	QP_CRPIX1(qphead)	= EINSTEIN_IPC_TANGENT_X
	QP_CRPIX2(qphead)	= EINSTEIN_IPC_TANGENT_Y
	QP_CDELT1(qphead)	= -EINSTEIN_IPC_ARC_SEC_PER_PIXEL/3600.0
	QP_CDELT2(qphead)	= EINSTEIN_IPC_ARC_SEC_PER_PIXEL/3600.0

	# clktime works off of jan 1, 1980 as base. jan 1 1900 was 15019 mjd, 
	# so 1 jan, 1980 was 29220 + 15019 = 44219
	ctime	= clktime(0)
	mjd	= ctime/86400.0	# days
	call printf("mjd: %f\n")
	 call pargd(mjd)
	call mjdut(1979,364,mjd,refclk)
	call sprintf(QP_DATEOBS(qphead),SZ_QPSTR,"%02d/%02d/%02d")
	 call pargi(MDAY(refclk))
	 call pargi(MONTH(refclk))
	 call pargi(YEAR(refclk))
	call sprintf(QP_TIMEOBS(qphead),SZ_QPSTR,"%02d:%02d:%02d")
	 call pargi(HOUR(refclk))
	 call pargi(MINUTE(refclk))
	 call pargi(SECOND(refclk))
	mjd	= mjd + (AR_LENA/24.0*60.0*60.0)	# end time in seconds
	call mjdut(1979,364,mjd,refclk)
	call sprintf(QP_DATEEND(qphead),SZ_QPSTR,"%02d/%02d/%02d")
	 call pargi(MDAY(refclk))
	 call pargi(MONTH(refclk))
	 call pargi(YEAR(refclk))
	call sprintf(QP_TIMEEND(qphead),SZ_QPSTR,"%02d:%02d:%02d")
	 call pargi(HOUR(refclk))
	 call pargi(MINUTE(refclk))
	 call pargi(SECOND(refclk))
	QP_MJDOBS(qphead)	= mutjd(MJDREFYEAR, MJDREFDAY, refclk) +
					MJDREFOFFSET

	call sprintf(QP_OBSID(qphead), SZ_QPSTR, "%d")
	 call pargi(AR_SEQN)
	call strcpy("USA",QP_COUNTRY(qphead),SZ_QPSTR)
	QP_MJDRDAY(qphead)	= EINSTEIN_MJDRDAY
	QP_MJDRFRAC(qphead)	= EINSTEIN_MJDRFRAC
	QP_EVTREF(qphead)	= EINSTEIN_EVTREF
	QP_XPT(qphead)		= EINSTEIN_IPC_DIM/2
	QP_YPT(qphead)		= EINSTEIN_IPC_DIM/2
	QP_XDET(qphead)		= EINSTEIN_IPC_DIM
	QP_YDET(qphead)		= EINSTEIN_IPC_DIM
	QP_FOV(qphead)		= EINSTEIN_IPC_FOV
	QP_INSTPIX(qphead)	= EINSTEIN_IPC_ARC_SEC_PER_PIXEL
	QP_XDOPTI(qphead) = (QP_CRPIX1(qphead)-EINSTEIN_IPC_OPTI_X) *
			    abs(QP_CDELT1(qphead))*3600.0
	QP_YDOPTI(qphead) = (QP_CRPIX2(qphead)-EINSTEIN_IPC_OPTI_Y) *
			    QP_CDELT2(qphead)*3600.0
	QP_CHANNELS(qphead) = EINSTEIN_IPC_PULSE_CHANNELS
	QP_XAOPTI(qphead) = (QP_CRPIX1(qphead)-QP_XAOPTI(qphead)) *
			     abs(QP_CDELT1(qphead))*3600.0
	QP_YAOPTI(qphead) = (QP_CRPIX2(qphead)-QP_YAOPTI(qphead)) *
			     QP_CDELT2(qphead)*3600.0
	QP_CRETIME(qphead) = clktime(0)
	QP_MODTIME(qphead) = QP_CRETIME(qphead)
	QP_LIMTIME(qphead) = 0

	QP_ONTIME(qphead)	= AR_LENA
	QP_LIVETIME(qphead)	= AR_LENA*1.43

	call sfree(sp)
end

