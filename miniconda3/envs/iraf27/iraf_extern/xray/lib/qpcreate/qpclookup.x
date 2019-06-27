#$Header: /home/pros/xray/lib/qpcreate/RCS/qpclookup.x,v 11.0 1997/11/06 16:22:00 prosb Exp $
#$Log: qpclookup.x,v $
#Revision 11.0  1997/11/06 16:22:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:32  prosb
#General Release 2.4
#
#Revision 8.1  1995/02/24  14:44:29  mo
#MC	2/24/95		Force return of YES/NO, even though ev_lookuplist
#			returns NO and non-zero
#
#Revision 8.0  1994/06/27  14:33:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:07  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:06  pros
#General Release 1.0
#
#
#  QPC_LOOKUP.X -- lookup a parameter name and get type and offset
#  returns:
#	YES if a type and offset were found
#	NO  if no type or offset were found (i.e., no macro or a macro
#	    defining something other than an event offset)
#
int procedure qpc_lookup(macro, type, offset)

char	macro[ARB]			# i: macro name
int	type				# o: data type
int	offset				# o: offset
int	ev_lookuplist()
int	ans				# l:
include "qpcreate.com"

begin
    ans = ev_lookuplist(macro, msymbols, mvalues, nmacros, type, offset)
    if( ans > 0 )
	ans = YES
    return(ans)	
end
