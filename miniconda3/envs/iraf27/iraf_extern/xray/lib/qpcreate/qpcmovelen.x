#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcmovelen.x,v 11.0 1997/11/06 16:22:02 prosb Exp $
#$Log: qpcmovelen.x,v $
#Revision 11.0  1997/11/06 16:22:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:20  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:11  pros
#General Release 1.0
#
include <qpoe.h>
include "qpcreate.h"

#
#  QPC_MOVELEN -- determine how many short to move from input event to output
#
procedure qpc_movelen(qp, evsize, evlen)

int	qp				# i: qpoe handle
int	evsize				# i: size of output qpoe record
int	evlen				# o: number of shorts to move
int	ievsize				# l: input event size

begin
	# get the input qpoe event size
	call ev_qpsize(qp, ievsize)
	# determine the number of shorts we move from the input record
	# assume input size if we don't know the output size
	if( evsize ==0 )
	    evlen = ievsize
	else
	    # just move the minimum required
	    evlen = min(ievsize, evsize)
end

