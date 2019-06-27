#$Header: /home/pros/xray/xdataio/datarep/RCS/iee2host.x,v 11.0 1997/11/06 16:33:59 prosb Exp $
#$Log: iee2host.x,v $
#Revision 11.0  1997/11/06 16:33:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:57  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:05  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:36:08  pros
#General Release 1.0
#
# ieee2host.x
#
# ieee to host initilization and converstions for Datarep

include <mach.h>



procedure iee2host()
#--

extern	iee2hostc()
extern	iee2hosts()
extern	iee2hostl()
extern	iee2hostr()
extern	iee2hostd()

begin
	call setmaxrep(8)

	call datatype("char",	iee2hostc)
	call datatype("short",	iee2hosts)
	call datatype("int", 	iee2hostl)
	call datatype("long", 	iee2hostl)
	call datatype("real", 	iee2hostr)
	call datatype("double",	iee2hostd)
end


procedure iee2hostc(ibuf, iindex, obuf, oindex)

char 	ibuf[ARB]
int	iindex
char 	obuf[ARB]
int	oindex

begin
	call bytmov(ibuf, iindex, obuf, oindex, 1)

	iindex = iindex + 1
	oindex = oindex + 1
end


procedure iee2hosts(ibuf, iindex, obuf, oindex)

short 	ibuf[ARB]
int	iindex
short 	obuf[ARB]
int	oindex

begin	
	if ( BYTE_SWAP2 == YES ) call bswap2(ibuf, iindex, obuf, oindex, 2)
	else			 call bytmov(ibuf, iindex, obuf, oindex, 2)

	iindex = iindex + 2
	oindex = oindex + 2
end


procedure iee2hostl(ibuf, iindex, obuf, oindex)

long 	ibuf
int	iindex
long 	obuf
int	oindex

begin
	     if ( BYTE_SWAP4 ==YES ) call bswap4(ibuf, iindex, obuf, oindex, 4)
	else if ( BYTE_SWAP2 ==YES ) call bswap2(ibuf, iindex, obuf, oindex, 4)
	else			     call bytmov(ibuf, iindex, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure iee2hostr(ibuf, iindex, obuf, oindex)

real	ibuf[ARB]
int	iindex
real	obuf[ARB]
int	oindex
#--

real	buf

begin
	call bytmov(ibuf, iindex, buf, 1, 4)
	call ieevupkr (buf, buf, 1)
	call bytmov(buf, 1, obuf, oindex, 4)

	iindex = iindex + 4
	oindex = oindex + 4
end


procedure iee2hostd(ibuf, iindex, obuf, oindex)

double	ibuf[ARB]
int	iindex
double	obuf[ARB]
int	oindex
#--

double	buf

begin
	call bytmov(ibuf, iindex, buf, 1, 8)
	call ieevupkd (buf, buf, 1)
	call bytmov(buf, 1, obuf, oindex, 8)

	iindex = iindex + 8
	oindex = oindex + 8
end




