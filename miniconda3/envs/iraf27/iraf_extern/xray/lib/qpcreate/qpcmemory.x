#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcmemory.x,v 11.0 1997/11/06 16:22:00 prosb Exp $
#$Log: qpcmemory.x,v $
#Revision 11.0  1997/11/06 16:22:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:26  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:08  pros
#General Release 1.0
#
#
#  QPC_MEMORY -- get memory for qpoe events
#	uses values placed into qpcreate.com
#
include "qpcreate.h"

procedure qpc_memory(buf, get)

pointer	buf				# o: buffer pointer
int	get				# o: number of records allocated
pointer	temp				# l: temp space pointer

include "qpcreate.com"

begin
	# see if we can get the whole thing at once
	# but put a cap on the size to avoid thrashing!
	if( (inrecs !=0) && (inrecs <= sortsize/revsize) ){
	    ifnoerr( call calloc(buf, inrecs*revsize, TY_SHORT) )
		# make sure we can get a bit more space for an index
		ifnoerr( call calloc(temp, inrecs, TY_INT) ){
		    get = inrecs
		    call mfree(temp, TY_INT)
		    return
		}
	}
	# otherwise successively to get smaller and smaller pieces
	get = sortsize/revsize
	while( TRUE ){
	    ifnoerr( call calloc(buf, get*revsize, TY_SHORT) )
		# make sure we can get a bit more space for an index
		ifnoerr( call calloc(temp, get, TY_INT) ){
		    call mfree(temp, TY_INT)
		    return
		}
		else
		    get = get / 2
	}
end
