#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcev.x,v 11.0 1997/11/06 16:21:57 prosb Exp $
#$Log: qpcev.x,v $
#Revision 11.0  1997/11/06 16:21:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:58  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:31:46  mo
#MC	12/1/93		Update with fix to QPOE - qpx_addf
#
#Revision 6.0  93/05/24  15:58:12  prosb
#General Release 2.2
#
#Revision 5.1  93/02/03  11:05:30  jmoran
#*** empty log message ***
#
#Revision 5.0  92/10/29  21:18:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:16  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:53  pros
#General Release 1.0
#
#
#	QPCEV.X -- routines to open. close, manipulate the event list
#

include <qpoe.h>
include "qpcreate.h"

#
# QPC_OPNEV -- create and open the event list
#
procedure qpc_opnev(qp, eventdef, io)

pointer	qp				# i: qpoe handle
char	eventdef[ARB]			# i: event definition string
pointer io				# o: event handle
pointer	qpio_open()			# l: open an event list
int	qp_accessf()			# l: qpoe param existence

begin
	# Define the event structure for the QPOE output file.
	if( qp_accessf(qp, "event") == YES )
	    call qp_deletef(qp, "event")	
	call qpx_addf (qp, "event", eventdef, 1, "event record type", 0)
	# Open the event list - the "events" list defaults to "event" type
	io = qpio_open (qp, "events", NEW_FILE)
end

#
# QPC_CLSEEV -- make an index and close event list
#
procedure qpc_clsev(io, mkindex, key)

pointer	io				# i: event handle
bool	mkindex				# i: true if we make an index
char	key[ARB]			# i: key for qpoe index

begin
	# make index, if necessary
	if( mkindex )
	    call qpio_mkindex(io, key)
	# close it all up
	call qpio_close(io)
end

