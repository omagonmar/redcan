#$Header: /home/pros/xray/xdataio/datarep/RCS/vax2host.x,v 11.0 1997/11/06 16:34:01 prosb Exp $
#$Log: vax2host.x,v $
#Revision 11.0  1997/11/06 16:34:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:55  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:38:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:21  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:36:20  pros
#General Release 1.0
#
# vax2host.x
#
# vax to host initilization and converstions for Datarep

include <mach.h>



procedure vax2host()
#--

extern	iee2hostc()
extern	vax2hosts()
extern	vax2hostl()
extern	vax2hostr()
extern	vax2hostd()

begin
	call setmaxrep(8)

	call datatype("char",	iee2hostc)
	call datatype("short",	vax2hosts)
	call datatype("int", 	vax2hostl)
	call datatype("long", 	vax2hostl)
	call datatype("real", 	vax2hostr)
	call datatype("double",	vax2hostd)
end



procedure vax2hosts(ibuf, iindex, obuf, oindex)

short 	ibuf[ARB]
int	iindex
short 	obuf[ARB]
int	oindex

begin	
	if ( BYTE_SWAP2 == NO ) call bswap2(ibuf, iindex, obuf, oindex, 2)
	else			call bytmov(ibuf, iindex, obuf, oindex, 2)

	iindex = iindex + 2
	oindex = oindex + 2
end


procedure vax2hostl(ibuf, iindex, obuf, oindex)

long 	ibuf
int	iindex
long 	obuf
int	oindex

begin
	if ( BYTE_SWAP4 == NO ) call bswap4(ibuf, iindex, obuf, oindex, 4)
	else			call bytmov(ibuf, iindex, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure vax2hostr(ibuf, iindex, obuf, oindex)

real	ibuf[ARB]
int	iindex
real	obuf[ARB]
int	oindex
#--

real	buf, vaxr4()

begin
	call bytmov(ibuf, iindex, buf, 1, 4)
	buf = vaxr4(buf)
	call bytmov(buf, 1, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure vax2hostd(ibuf, iindex, obuf, oindex)

double	ibuf[ARB]
int	iindex
double	obuf[ARB]
int	oindex
#--

double	buf, vaxr8()

begin
	call bytmov(ibuf, iindex, buf, 1, 8)
	buf = vaxr8(buf)
	call bytmov(buf, 1, obuf, oindex, 8)

	iindex = iindex + 8
	oindex = oindex + 8
end
