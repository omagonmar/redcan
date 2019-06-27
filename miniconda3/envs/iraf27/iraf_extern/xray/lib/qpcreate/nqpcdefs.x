#$Header: /home/pros/xray/lib/qpcreate/RCS/nqpcdefs.x,v 11.0 1997/11/06 16:21:45 prosb Exp $
#$Log: nqpcdefs.x,v $
#Revision 11.0  1997/11/06 16:21:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:10  prosb
#General Release 2.4
#
Revision 7.0  1993/12/27  18:16:18  prosb
General Release 2.3

Revision 6.0  93/05/24  15:55:37  prosb
General Release 2.2

Revision 5.1  93/04/26  23:56:47  dennis
Regions system rewrite.

Revision 5.0  92/10/29  21:18:27  prosb
General Release 2.1

Revision 4.0  92/04/27  13:51:42  prosb
General Release 2.0:  April 1992

Revision 3.0  91/08/02  01:05:12  prosb
General Release 1.1

#Revision 2.0  91/03/07  00:10:43  pros
#General Release 1.0
#
#
#	QPCDEFS.X -- default procedures for qpoe to qpoe tasks
#

include <qpset.h>
include <qpioset.h>
include <qpoe.h>
include <ext.h>

include "qpcreate.h"

# define number of events we read at once
define SZ_EVBUF	512

#
# DEF_ALLOC -- allocate def arrays
#
procedure def_alloc(argv)

pointer	argv			# i: argument list

begin
	call calloc(REGIONS(argv), SZ_LINE, TY_CHAR)
	call calloc(TITLE(argv), SZ_LINE, TY_CHAR)
	call calloc(EXPOSURE(argv), SZ_PATHNAME, TY_CHAR)
end

#
# DEF_FREE -- allocate def arrays
#
procedure def_free(argv)

pointer	argv			# i: argument list

begin
	call mfree(REGIONS(argv), TY_CHAR)
	call mfree(TITLE(argv), TY_CHAR)
	call mfree(EXPOSURE(argv), TY_CHAR)
end

#
# DEF_GETPARAM -- get region and exposure parameters
#
procedure def_getparam(ifile, argv)

char	ifile[ARB]		# i: input file name
pointer	argv			# o: argument list pointer
bool	strne()			# l: string compare
real	clgetr()		# l: get real param

begin
	# get region
	call clgstr("region", Memc[REGIONS(argv)], SZ_LINE)
	# get exposure information
	call clgstr("exposure", Memc[EXPOSURE(argv)], SZ_PATHNAME)
        call rootname(ifile, Memc[EXPOSURE(argv)], EXT_EXPOSURE, SZ_PATHNAME)
	# get exposure threshold, if necessary
	if( strne(Memc[EXPOSURE(argv)], "NONE") ){
	    THRESH(argv) = clgetr("expthresh")
	    if( (THRESH(argv) < 0.0) || (THRESH(argv) > 100.0) )
	        call error(1, "exposure threshold must be 0.0 <= t <= 100.0")
	}
end

#
# DEF_OPEN -- open a qpoe file and an event list through a region and
#		an exposure file
#
procedure def_open(fname, fd, inrecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	inrecs				# o: number of events in qpoe file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

char	poeroot[SZ_PATHNAME]		# l: root data file name
char	evlist[SZ_EXPR]			# l: event list expression
char	datatype[SZ_DATATYPE]		# l: from qp_queryf
char	comment[SZ_COMMENT]		# l: from qp_queryf
int	maxelem				# l: from qp_queryf
int	flags				# l: from qp_queryf

int	qp_queryf()			# l: qp_queryf
pointer	qp_open()			# l: open a qpoe file
pointer	qpio_open()			# l: open a qpio event list
bool	ck_none()
int	rg_none()

begin
	# separate input poefile into a root file and an event list spec
	call qpparse(fname, poeroot, SZ_PATHNAME, evlist, SZ_EXPR)
	# open the input qpoe file
	fd[1] = qp_open(poeroot, READ_ONLY, NULL)
	# open the event list - the "events" list defaults to "event" type
	fd[2] = qpio_open(fd[1], evlist, READ_ONLY)
	# set up new mask, if necessary
	if( rg_none == NO || !ck_none(Memc[EXPOSURE(argv)] ) {
	    call set_qpmask(fd[1], fd[2], NULL, Memc[REGIONS(argv)], 
			    Memc[EXPOSURE(argv)],THRESH(argv), 
			    fd[3], TITLE(argv))
	# display the header, if necessary
	    if( display >1 )
	       call msk_disp("", fname, Memc[TITLE(argv)])
	}
	# we set inrecs to the total number of photons in the file
	# but we may get less through the filter/mask
	inrecs = qp_queryf(fd[1], "events", datatype, maxelem, comment, flags)
	# get the qpoe header
	call get_qphead(fd[1], qphead)
end

#
#  DEF_CLOSE -- close the plio, qpio and qp "files"
#  we just call reg_close
#
procedure def_close(fd, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	# close the plio, qpio and qp "files"
	call reg_close(fd, qphead, display, argv)
end

#
# DEF_GET -- read the input events and create an output events
#
procedure def_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
int	evsize				# i: size of output qpoe record
int	convert				# i: data conversion flag
pointer	sbuf				# o: event pointer
int	get				# i: number of events to get
int	got				# o: number of events got
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	i				# l: loop counter
int	mval				# l: mask from qpio_getevent
int	nev				# l: number of events returned
int	evlen				# l: number of shorts to move
int	try				# l: number of events to try this time
int	size				# l: padded size of a qpoe record
int	evl[SZ_EVBUF]			# l: event pointer from qpio_getevent
pointer	ev				# l: pointer to current output record

int	qpio_getevents()		# l: get qpoe events

begin
	# determine the number of shorts we move from input to output
	call qpc_movelen(fd[1], evsize, evlen)
	# determine the padded record size of the qpoe record
	call qpc_roundup(evsize, size)

	# get photons until we have enough or until EOF
	got = 0
	while( got < get ){
	    # get the next batch of events
	    try = min(SZ_EVBUF, get-got)
	    if( qpio_getevents(fd[2], evl, mval, try, nev) != EOF){
		# move the event records
		do i=1, nev {
		    # point to current record in sbuf
		    ev = sbuf + (got*size)
		    # inc number of events
		    got = got+1
		    # evsize is the number of shorts in the event record
		    call amovs(Mems[evl[i]], Mems[ev], evlen)
		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
		}
	    }
	    else
		break
	}
end

#
#  DEF_FINALE -- final procedure for qpcreate
#	add x_mask param
#
procedure def_finale(fd, qp, io, convert, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
pointer	qp				# o: qpoe handle
pointer	io				# i: pointer to event list
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

include "qpcreate.com"

begin
	# put the mask header to the qpoe file
	# update the composite mask
	if( TITLE(argv) !=0 ){
	    call put_qpmask(qp, Memc[TITLE(argv)])	
	    call update_qpcomposite(qp, fd[3], Memc[REGIONS(argv)])
	}
end

#
#  DEF_NOPUT -- a default routine to do a no-op for a put
#
procedure def_noput()

begin
	return
end
