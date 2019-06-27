#$Header: /home/pros/xray/xdataio/datarep/RCS/host2txt.x,v 11.0 1997/11/06 16:33:58 prosb Exp $
#$Log: host2txt.x,v $
#Revision 11.0  1997/11/06 16:33:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:57:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:18:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:53  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:23:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:36:01  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:00:28  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:12:17  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  21:55:04  mo
#MC	8/1/91		No change - restructure
#
#Revision 2.0  91/03/06  23:36:03  pros
#General Release 1.0

# hst2txt.x
#
# host to text initilization and converstions for Datarep

include <mach.h>

define	NCAR	16

procedure hst2txt()
#--

extern	hst2txtc()
extern	hst2txts()
extern	hst2txtl()
extern	hst2txtr()
extern	hst2txtd()

extern	print_loop()
extern	print_call()
extern	print_ret()

int	locpr()

include "datapar.com"
include "hst2txt.com"

begin
	call setmaxrep(NCAR + 2)

	call datatype("char",	hst2txtc)
	call datatype("short",	hst2txts)
	call datatype("int", 	hst2txtl)
	call datatype("long", 	hst2txtl)
	call datatype("real", 	hst2txtr)
	call datatype("double",	hst2txtd)

	pr_loop = op_loop
	pr_call = op_call
	pr_ret  = op_ret

	op_loop = locpr(print_loop)
	op_call = locpr(print_call)
	op_ret  = locpr(print_ret)
end


procedure hst2txtc(ibuf, iindex, obuf, oindex)

char 	ibuf[ARB]
int	iindex
char 	obuf[ARB]
int	oindex

include "hst2txt.com"

begin
	call bytmov(ibuf, iindex, obuf, oindex, 1)

	iindex = iindex + 1
	oindex = oindex + 1

	call nl(obuf, oindex)
end


procedure hst2txts(ibuf, iindex, obuf, oindex)

short 	ibuf[ARB]
int	iindex
short 	obuf[ARB]
int	oindex
#-- 

short	buf
int	len
int	itoc()

include "hst2txt.com"

begin	
	call bytmov(ibuf, iindex, buf, 1, 2)

	len = itoc(int(buf), pr_buffer, NCAR)
	call chrpak(pr_buffer, 1, obuf, oindex, len)

	iindex = iindex + 4
	oindex = oindex + len

	call nl(obuf, oindex)
end


procedure hst2txtl(ibuf, iindex, obuf, oindex)

long 	ibuf
int	iindex
long 	obuf
int	oindex
#--

int	buf
int	len
int	itoc()

include "hst2txt.com"

begin
	call bytmov(ibuf, iindex, buf, 1, 4)

	len = itoc(buf, pr_buffer, NCAR)
	call chrpak(pr_buffer, 1, obuf, oindex, len)

	iindex = iindex + 4
	oindex = oindex + len

	call nl(obuf, oindex)
end


procedure hst2txtr(ibuf, iindex, obuf, oindex)

real	ibuf[ARB]
int	iindex
real	obuf[ARB]
int	oindex
#--

real	buf
int	dtoc()
int	len

include "hst2txt.com"

begin
	call bytmov(ibuf, iindex, buf, 1, 4)

	len = dtoc(double(buf), pr_buffer, NCAR, 8, 'g', 12)
	call chrpak(pr_buffer, 1, obuf, oindex, len)

	iindex = iindex + 4
	oindex = oindex + len

	call nl(obuf, oindex)
end


procedure hst2txtd(ibuf, iindex, obuf, oindex)

double	ibuf[ARB]
int	iindex
double	obuf[ARB]
int	oindex
#--

double	buf
int	dtoc()
int	len

include "hst2txt.com"

begin
	call bytmov(ibuf, iindex, buf, 1, 8)

	len = dtoc(buf, pr_buffer, NCAR, 8, 'g', 12)
	call chrpak(pr_buffer, 1, obuf, oindex, len)

	iindex = iindex + 8
	oindex = oindex + len

	call nl(obuf, oindex)
end



procedure nl(buf, index)

short	buf[ARB]
int	index
#--

begin
	call chrpak("\n", 1, buf, index, 1)
	index = index + 1
end



procedure print_loop(ibase, iindex, obase, oindex)

char	ibase[ARB]
int	iindex
char	obase[ARB]
int	oindex
#--

include "hst2txt.com"

begin
	call zcall4(pr_loop, ibase, iindex, obase, oindex)
end



procedure print_call(ibase, iindex, obase, oindex)

char	ibase[ARB]
int	iindex
char	obase[ARB]
int	oindex
#--

include "hst2txt.com"

begin
	call zcall4(pr_call, ibase, iindex, obase, oindex)
end



procedure print_ret(ibase, iindex, obase, oindex)

char	ibase[ARB]
int	iindex
char	obase[ARB]
int	oindex
#--

include "hst2txt.com"

begin
	call zcall4(pr_ret, ibase, iindex, obase, oindex)
end

