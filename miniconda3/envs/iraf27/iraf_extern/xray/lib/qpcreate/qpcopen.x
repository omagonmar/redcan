#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcopen.x,v 11.0 1997/11/06 16:22:03 prosb Exp $
#$Log: qpcopen.x,v $
#Revision 11.0  1997/11/06 16:22:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:37  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:14  pros
#General Release 1.0
#
#
#	QPCOPEN.X -- open the output qpoe file, either as a new file
#			or as a copy of the input file
#		     also routine to close the qpoe file
#

include <qpset.h>
include "qpcreate.h"

#
#  QPC_CREQP --  open a qpoe file and set up some internal params
#
procedure qpc_creqp(qpname, pagesize, bucketlen, debug, qp)

char	qpname[ARB]			# i: qpoe name
int	pagesize			# i: qpoe pagesize
int	bucketlen			# i: qpoe bucketlen
int	debug				# i: qpoe debug level
pointer	qp				# o: qp handle to return
pointer	qp_open()			# l: open a qpoe file

begin
	# open the qpoe file - here starts qpoe code
	qp = qp_open (qpname, NEW_FILE, NULL)

	# Set the datafile page size.
	call qp_seti (qp, QPOE_PAGESIZE, pagesize)
	# Set the bucket length in units of number of events.
	call qp_seti (qp, QPOE_BUCKETLEN, bucketlen)
	# Set the debug level
	call qp_seti (qp, QPOE_DEBUGLEVEL, debug)
end

#
#  QPC_COPYQP --  open a qpoe file and copy params from input qpoe
#
procedure qpc_copyqp(qpname, eventfd, qphead, qp)

char	qpname[ARB]			# i: qpoe name
pointer	eventfd				# i: input qp handle
pointer	qphead				# o: qpoe header
pointer	qp				# o: qp handle to return
pointer	qp_open()			# l: open a qpoe file

begin
	# open the qpoe file - here starts qpoe code
	qp = qp_open (qpname, NEW_COPY, eventfd)
end

#
# QPC_CLOSEQP -- close output qpoe file
#
procedure qpc_closeqp(qp)

pointer qp				# i: qpoe handle

begin
	call qp_close(qp)
end

