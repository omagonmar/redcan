#$Header: /home/pros/xray/lib/qpcreate/RCS/reg2qp.x,v 11.0 1997/11/06 16:22:15 prosb Exp $
#$Log: reg2qp.x,v $
#Revision 11.0  1997/11/06 16:22:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:26  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:18  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  12:10:19  mo
#MC	4/13/92		Add a conditional on the pl_close, since we
#			now want to avoid creating a PL file for
#			NONE of field due to IRAF bug
#
#Revision 3.0  91/08/02  01:05:31  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:46  pros
#General Release 1.0
#
#
#	REG2QP -- driver routines to access a qpoe file through
#			a region filter
#

include <qpset.h>
include <qpioset.h>
include <qpoe.h>
include "qpcreate.h"
include "reg2qp.h"

#
# REG_OPEN -- open a qpoe file and an event list through a region
#
procedure reg_open(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of events in qpoe file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

char	poeroot[SZ_PATHNAME]		# l: root data file name
char	evlist[SZ_EXPR]			# l: event list expression
char	datatype[SZ_DATATYPE]		# l: from qp_queryf
char	comment[SZ_COMMENT]		# l: from qp_queryf
int	block				# l: blocking factor
int	maxelem				# l: from qp_queryf
int	flags				# l: from qp_queryf

bool	strne()				# l: string compare
int	qp_stati()			# l: get qpoe status
int	qp_queryf()			# l: qp_queryf
pointer	qp_open()			# l: open a qpoe file
pointer	qpio_open()			# l: open a qpio event list
pointer	rg_qpcreate()			# l: create a region

begin
	# separate input poefile into a root file and an event list spec
	call qpparse(fname, poeroot, SZ_PATHNAME, evlist, SZ_EXPR)
	# open the input qpoe file
	fd[1] = qp_open(poeroot, READ_ONLY, NULL)
	# open the event list - the "events" list defaults to "event" type
	fd[2] = qpio_open(fd[1], evlist, READ_ONLY)
	# reset the mask value if a region was specified
	if( strne("", Memc[REGIONS(argv)]) ){
	    block = qp_stati(fd[1], QPOE_BLOCKFACTOR)
	    if( block ==0 ){
		call printf("block factor is 0: did you setenv the qmfiles?")
		call error(1, "illegal block factor")
	    }
	    else if( block != 1 ){
		call printf("qpdisp warning: block factor is not 1 (%d)\n")
		call pargd(block)
	    }
	    # work-around for bug in rg_p<l,m>create
	    TITLE(argv) = 0
	    fd[3] = rg_qpcreate(Memc[REGIONS(argv)], fd[1], TITLE(argv))
	    # set up the region as a mask
	    call qpio_seti(fd[2], QPIO_PL, fd[3])
	    # display the header
	    if( display >1 )
		call msk_disp("", fname, Memc[TITLE(argv)])
	}
	else
	    TITLE(argv) = 0
	# we set irecs to the total number of photons in the file
	# but we may get less through the filter/mask
	irecs = qp_queryf(fd[1], "events", datatype, maxelem, comment, flags)
	# get the qpoe header
	call get_qphead(fd[1], qphead)
end

#
#  REG_CLOSE -- close the plio, qpio and qp "files"
#
procedure reg_close(fd, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	qphead = qphead			# avoid compile warning
	argv = argv			# avoid compile warning
	if( display >=5 )
	    call printf("closing input event file\n")
	if( fd[3] >= 0 )
	    call pl_close(fd[3])
	call qpio_close(fd[2])
	call qp_close(fd[1])
end


#
# REG_GET -- read the next input event and create an output event
#
procedure reg_get(fd, evsize, convert, event, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
int	evsize				# i: event size
int	convert				# i: data conversion flag
pointer	event				# o: event pointer
int	get				# i: number of records to get
int	got				# o: number of records got
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	mval				# l: mask from qpio_getevent
int	qpio_getevents()		# l: get qpoe events

begin
	# avoid compile warnings
	evsize = evsize
	convert = convert
	qphead = qphead
	argv = argv
	display = display
	# get photons
	if( qpio_getevents(fd[2], event, mval, get, got) == EOF)
	   got = 0
end
