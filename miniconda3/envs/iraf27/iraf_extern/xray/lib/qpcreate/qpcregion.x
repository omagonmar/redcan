#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcregion.x,v 11.0 1997/11/06 16:22:07 prosb Exp $
#$Log: qpcregion.x,v $
#Revision 11.0  1997/11/06 16:22:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:48  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:07  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:48  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:26  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:26  pros
#General Release 1.0
#
#
#  QPC_INITREGION -- determine if the region is to be added to the event record
#
include <mach.h>

procedure qpc_initregion(qp, msymbols, nmacros)

pointer	qp				# i: qpoe handle
pointer	msymbols			# i: pointer to a list of macros names
int	nmacros				# i: number of names in list
int	i				# l: loop counter
int	ev_lookup()			# l: lookup macro type and offset
bool	streq()				# l: string compare

int	doevr				# l: flag is we add regions
int	evroff				# l: offset into record
int	evrtype				# l: type of data element
common/evregcom/doevr, evroff, evrtype

begin
	do i=1, nmacros{
	    if( streq("region", Memc[Memi[msymbols+i-1]]) ){
		if( ev_lookup(qp, "region", evrtype, evroff) == YES ){
		    # convert byte offset into short offset
		    doevr = YES
		    return
		}
		else
		    call error(1, "region is undefined in event struct")
	    }
	}
	# didn't find "region" in the list
	doevr = NO
end

#
#  QPC_PUTREGION -- put a region number into an event struct
#
procedure qpc_putregion(ev, mval)

pointer	ev				# i: event struct pointer
int	mval				# i: mask value

int	doevr				# l: flag is we add regions
int	evroff				# l: offset into record
int	evrtype				# l: type of data element
common/evregcom/doevr, evroff, evrtype

begin
	# store the region value, if necessary
	# we assume the region type is short, since anything else
	# does not make sense
	if( doevr == YES ){
	    switch( evrtype ){
	    case TY_SHORT:
		Mems[ev+evroff] = mval
	    case TY_INT, TY_LONG:
		Memi[(ev+evroff-1)/SZ_INT+1] = mval
	    default:
		call error(1, "region type must be TY_SHORT or TY_INT")
	    }
	}
end

