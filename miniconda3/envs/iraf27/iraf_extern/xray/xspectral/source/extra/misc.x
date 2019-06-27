#$Header: /home/pros/xray/xspectral/source/extra/RCS/misc.x,v 11.0 1997/11/06 16:41:41 prosb Exp $
#$Log: misc.x,v $
#Revision 11.0  1997/11/06 16:41:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:32  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  17:35:36  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:53:50  prosb
General Release 2.3

Revision 6.0  93/05/24  16:53:22  prosb
General Release 2.2

Revision 5.0  92/10/29  22:43:05  prosb
General Release 2.1

Revision 3.0  91/08/02  01:59:29  prosb
General Release 1.1

#Revision 2.0  91/03/06  23:05:02  pros
#General Release 1.0
#
include "modparse.h"

procedure dname()

include "modparse.com"

begin
	call printf("mod_name=%d %s\n")
	call pargi(mod_name)
	call pargstr(Memc[mod_name])
	call printf("mod_allnames=%d %s\n")
	call pargi(mod_allnames)
	call pargstr(Memc[mod_allnames])
end
