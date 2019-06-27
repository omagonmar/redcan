#$Header: /home/pros/xray/xdataio/datarep/RCS/dg2host.x,v 11.0 1997/11/06 16:33:57 prosb Exp $
#$Log: dg2host.x,v $
#Revision 11.0  1997/11/06 16:33:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:28  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:58  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:24  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:17  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:36:00  pros
#General Release 1.0
#
# dg2host.x
#
# dg to host initilization and converstions for Datarep

include <mach.h>



procedure dg2host()
#--

extern	iee2hostc()
extern	iee2hosts()
extern	iee2hostl()
extern	dg2hostr()
extern	dg2hostd()

begin
	call setmaxrep(8)

	call datatype("char",	iee2hostc)
	call datatype("short",	iee2hosts)
	call datatype("int", 	iee2hostl)
	call datatype("long", 	iee2hostl)
	call datatype("real", 	dg2hostr)
	call datatype("double",	dg2hostd)
end


procedure dg2hostr(ibuf, iindex, obuf, oindex)

real	ibuf[ARB]
int	iindex
real	obuf[ARB]
int	oindex
#--

real	buf, dgr4()

begin
	call bytmov(ibuf, iindex, buf, 1, 4)
	buf = dgr4(buf)
	call bytmov(buf, 1, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure dg2hostd(ibuf, iindex, obuf, oindex)

double	ibuf[ARB]
int	iindex
double	obuf[ARB]
int	oindex
#--

double	buf, dgr8()

begin
	call bytmov(ibuf, iindex, buf, 1, 8)
	buf = dgr8(buf)
	call bytmov(buf, 1, obuf, oindex, 8)

	iindex = iindex + 8
	oindex = oindex + 8
end
