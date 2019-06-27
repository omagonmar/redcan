#$Header: /home/pros/xray/ximages/imcalc/RCS/xbranch.x,v 11.0 1997/11/06 16:27:49 prosb Exp $
#$Log: xbranch.x,v $
#Revision 11.0  1997/11/06 16:27:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:59  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:55  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:29  pros
#General Release 1.0
#
#
# XBRANCH - branch code for imcalc cpu
#

include "imcalc.h"

#
# XBEOF - branch if eof
#
procedure xbeof()
include "imcalc.com"
begin
    # on eof, branch as requested or to last inst
    if( (c_imageno ==0) || (c_ateof == YES) ){
	if( ARG1(c_ip) != 0 )
	    c_ip = min(ARG1(c_ip) - 1, c_nextinst - 1)
	else{
	    c_ip = c_ip + ARG2(c_ip) - 1
	    if( c_ip > c_nextinst - 1 )
		c_ip = c_nextinst - 1
	}	
    }
    # increment line number, if necessary
    if( c_ip == 0 )
	c_lineno = c_lineno + 1
end

#
#  XBNEOF - branch if not eof
#
procedure xbneof()
include "imcalc.com"
begin
    if( (c_imageno !=0) && (c_ateof != YES) ){
	if( ARG1(c_ip) != 0 )
	    c_ip = min(ARG1(c_ip) - 1, c_nextinst - 1)
	else{
	    c_ip = c_ip + ARG2(c_ip) - 1
	    if( c_ip > c_nextinst - 1 )
		c_ip = c_nextinst - 1
	}	
    }
    # increment line number, if necessary
    if( c_ip == 0 )
	c_lineno = c_lineno + 1
end
