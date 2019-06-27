#$Header: /home/pros/xray/lib/pros/RCS/qpmask.x,v 11.0 1997/11/06 16:21:06 prosb Exp $
#$Log: qpmask.x,v $
#Revision 11.0  1997/11/06 16:21:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:34  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:00  prosb
#General Release 2.2
#
#Revision 5.1  93/04/26  23:55:43  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:17:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:01:16  wendy
#General
#
#Revision 2.0  91/03/07  00:07:27  pros
#General Release 1.0
#
#
#  QPMASK.X -- manipulate the filter mask in a qpoe file
#
include <qpset.h>
include <qpioset.h>

#
# SET_QPMASK -- create a region/exposure mask and reset the qpoe mask 
#
procedure set_qpmask(qp, io, parsing, region, exposure, expthresh, pl, title)

int	qp				# i: qp handle
int	io				# i: event io handle
pointer	parsing				# i: external parsing request
char	region[ARB]			# i: region descriptor
char	exposure[ARB]			# i: exposure file name
real	expthresh			# i: exposure threshold
pointer	pl				# o: output plio handle
pointer	title				# o: mask title
int	block				# l: blocking factor
int	qpio_stati()			# l: get qpoe status
pointer	msk_qpopen()			# l: create region/exposure mask

begin
	# init title pointer
	title = 0
	# reset the mask value if a region was specified
	block = qpio_stati(io, QPOE_BLOCKFACTOR)
	if( block ==0 ){
	    call printf("block factor is 0: did you setenv the qmfiles?\n")
	    call error(1, "illegal block factor")
	}
	else if( block != 1 ){
	    call printf("\nWarning: block factor %d is not 1 ... ignoring\n")
	    call pargi(block)
	}
	# open the region and/or exposure
	pl = msk_qpopen(parsing, region, exposure, expthresh, qp, title)
	# set up the region as a mask
	call qpio_seti(io, QPIO_PL, pl)
end

