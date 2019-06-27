#$Header: /home/pros/xray/ximages/imcalc/RCS/xcht.x,v 11.0 1997/11/06 16:27:50 prosb Exp $
#$Log: xcht.x,v $
#Revision 11.0  1997/11/06 16:27:50  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:20  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:58  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:55  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:33  pros
#General Release 1.0
#
#
#	XCHT.X - convert a line of data
#		from one data type to another
#

include	<imhdr.h>
include	"imcalc.h"

define SHIFT 100

# define type of conversions
define SHORT_SHORT	303	# TY_SHORT*SHIFT+TY_SHORT
define SHORT_INT	304	# TY_SHORT*SHIFT+TY_INT
define SHORT_LONG	305	# TY_SHORT*SHIFT+TY_LONG
define SHORT_REAL	306	# TY_SHORT*SHIFT+TY_REAL
define SHORT_DOUBLE	307	# TY_SHORT*SHIFT+TY_DOUBLE
define SHORT_COMPLEX	308	# TY_SHORT*SHIFT+TY_COMPLEX

define INT_SHORT	403	# TY_INT*SHIFT+TY_SHORT
define INT_INT		404	# TY_INT*SHIFT+TY_INT
define INT_LONG		405	# TY_INT*SHIFT+TY_LONG
define INT_REAL		406	# TY_INT*SHIFT+TY_REAL
define INT_DOUBLE	407	# TY_INT*SHIFT+TY_DOUBLE
define INT_COMPLEX	408	# TY_INT*SHIFT+TY_COMPLEX

define LONG_SHORT	503	# TY_LONG*SHIFT+TY_SHORT
define LONG_INT		504	# TY_LONG*SHIFT+TY_INT
define LONG_LONG	505	# TY_LONG*SHIFT+TY_LONG
define LONG_REAL	506	# TY_LONG*SHIFT+TY_REAL
define LONG_DOUBLE	507	# TY_LONG*SHIFT+TY_DOUBLE
define LONG_COMPLEX	508	# TY_LONG*SHIFT+TY_COMPLEX

define REAL_SHORT	603	# TY_REAL*SHIFT+TY_SHORT
define REAL_INT		604	# TY_REAL*SHIFT+TY_INT
define REAL_LONG	605	# TY_REAL*SHIFT+TY_LONG
define REAL_REAL	606	# TY_REAL*SHIFT+TY_REAL
define REAL_DOUBLE	607	# TY_REAL*SHIFT+TY_DOUBLE
define REAL_COMPLEX	608	# TY_REAL*SHIFT+TY_COMPLEX

define DOUBLE_SHORT	703	# TY_DOUBLE*SHIFT+TY_SHORT
define DOUBLE_INT	704	# TY_DOUBLE*SHIFT+TY_INT
define DOUBLE_LONG	705	# TY_DOUBLE*SHIFT+TY_LONG
define DOUBLE_REAL	706	# TY_DOUBLE*SHIFT+TY_REAL
define DOUBLE_DOUBLE	707	# TY_DOUBLE*SHIFT+TY_DOUBLE
define DOUBLE_COMPLEX	708	# TY_DOUBLE*SHIFT+TY_COMPLEX

define COMPLEX_SHORT	803	# TY_COMPLEX*SHIFT+TY_SHORT
define COMPLEX_INT	804	# TY_COMPLEX*SHIFT+TY_INT
define COMPLEX_LONG	805	# TY_COMPLEX*SHIFT+TY_LONG
define COMPLEX_REAL	806	# TY_COMPLEX*SHIFT+TY_REAL
define COMPLEX_DOUBLE	807	# TY_COMPLEX*SHIFT+TY_DOUBLE
define COMPLEX_COMPLEX	808	# TY_COMPLEX*SHIFT+TY_COMPLEX

#
# XCHTV -- change the type of an vector
#
procedure xchtv (in, typein, out, typeout, len)

pointer	in			# i: input buf
int typein			# i: type to change from
pointer	out			# o: output buf
int typeout			# i: type to change to
int len				# i: length of data buf
int cflag			# l: change from type1 to type2
include "imcalc.com"

begin

	# find out what we are converting from and to
	cflag = typein * SHIFT + typeout

	# and do it
	switch(cflag){

	case SHORT_SHORT:
	    call achtss(Mems[in], Mems[out], len)
	case SHORT_INT:
	    call achtsi(Mems[in], Memi[out], len)
	case SHORT_LONG:
	    call achtsl(Mems[in], Meml[out], len)
	case SHORT_REAL:
	    call achtsr(Mems[in], Memr[out], len)
	case SHORT_DOUBLE:
	    call achtsd(Mems[in], Memd[out], len)
	case SHORT_COMPLEX:
	    call achtsx(Mems[in], Memx[out], len)

	case INT_SHORT:
	    call achtis(Memi[in], Mems[out], len)
	case INT_INT:
	    call achtii(Memi[in], Memi[out], len)
	case INT_LONG:
	    call achtil(Memi[in], Meml[out], len)
	case INT_REAL:
	    call achtir(Memi[in], Memr[out], len)
	case INT_DOUBLE:
	    call achtid(Memi[in], Memd[out], len)
	case INT_COMPLEX:
	    call achtix(Memi[in], Memx[out], len)

	case LONG_SHORT:
	    call achtls(Meml[in], Mems[out], len)
	case LONG_INT:
	    call achtli(Meml[in], Memi[out], len)
	case LONG_LONG:
	    call achtll(Meml[in], Meml[out], len)
	case LONG_REAL:
	    call achtlr(Meml[in], Memr[out], len)
	case LONG_DOUBLE:
	    call achtld(Meml[in], Memd[out], len)
	case LONG_COMPLEX:
	    call achtlx(Meml[in], Memx[out], len)

	case REAL_SHORT:
	    call achtrs(Memr[in], Mems[out], len)
	case REAL_INT:
	    call achtri(Memr[in], Memi[out], len)
	case REAL_LONG:
	    call achtrl(Memr[in], Meml[out], len)
	case REAL_REAL:
	    call achtrr(Memr[in], Memr[out], len)
	case REAL_DOUBLE:
	    call achtrd(Memr[in], Memd[out], len)
	case REAL_COMPLEX:
	    call achtrx(Memr[in], Memx[out], len)

	case DOUBLE_SHORT:
	    call achtds(Memd[in], Mems[out], len)
	case DOUBLE_INT:
	    call achtdi(Memd[in], Memi[out], len)
	case DOUBLE_LONG:
	    call achtdl(Memd[in], Meml[out], len)
	case DOUBLE_REAL:
	    call achtdr(Memd[in], Memr[out], len)
	case DOUBLE_DOUBLE:
	    call achtdd(Memd[in], Memd[out], len)
	case DOUBLE_COMPLEX:
	    call achtdx(Memd[in], Memx[out], len)

	case COMPLEX_SHORT:
	    call achtxs(Memx[in], Mems[out], len)
	case COMPLEX_INT:
	    call achtxi(Memx[in], Memi[out], len)
	case COMPLEX_LONG:
	    call achtxl(Memx[in], Meml[out], len)
	case COMPLEX_REAL:
	    call achtxr(Memx[in], Memr[out], len)
	case COMPLEX_DOUBLE:
	    call achtxd(Memx[in], Memd[out], len)
	case COMPLEX_COMPLEX:
	    call achtxx(Memx[in], Memx[out], len)

	}
end


#
# XCHT -- change the type of an vector
#
procedure xcht (in, out)

pointer	in			# input register
pointer	out			# output register
include "imcalc.com"

begin
	call xchtv(R_LBUF(in), R_TYPE(in), R_LBUF(out), R_TYPE(out),
		   R_LENGTH(out))
end

# XCHTK -- change the type of a constant operand

procedure xchtk (in, type)

pointer	in			# input register
int type			# type to change to
int cflag			# l: change from type1 to type2
include "imcalc.com"

begin

	# find out what we are converting from and to
	cflag = R_TYPE(in) * SHIFT + type
	# change type flag in register
	R_TYPE(in) = type

	# and do it
	switch(cflag){

	case SHORT_SHORT:
	    R_VALS(in) = short(R_VALS(in))
	case SHORT_INT:
	    R_VALI(in) = int(R_VALS(in))
	case SHORT_LONG:
	    R_VALL(in) = long(R_VALS(in))
	case SHORT_REAL:
	    R_VALR(in) = real(R_VALS(in))
	case SHORT_DOUBLE:
	    R_VALD(in) = double(R_VALS(in))
	case SHORT_COMPLEX:
	    R_VALX(in) = complex(R_VALS(in))

	case INT_SHORT:
	    R_VALS(in) = short(R_VALI(in))
	case INT_INT:
	    R_VALI(in) = int(R_VALI(in))
	case INT_LONG:
	    R_VALL(in) = long(R_VALI(in))
	case INT_REAL:
	    R_VALR(in) = real(R_VALI(in))
	case INT_DOUBLE:
	    R_VALD(in) = double(R_VALI(in))
	case INT_COMPLEX:
	    R_VALX(in) = complex(R_VALI(in))

	case LONG_SHORT:
	    R_VALS(in) = short(R_VALL(in))
	case LONG_INT:
	    R_VALI(in) = int(R_VALL(in))
	case LONG_LONG:
	    R_VALL(in) = long(R_VALL(in))
	case LONG_REAL:
	    R_VALR(in) = real(R_VALL(in))
	case LONG_DOUBLE:
	    R_VALD(in) = double(R_VALL(in))
	case LONG_COMPLEX:
	    R_VALX(in) = complex(R_VALL(in))

	case REAL_SHORT:
	    R_VALS(in) = short(R_VALR(in))
	case REAL_INT:
	    R_VALI(in) = int(R_VALR(in))
	case REAL_LONG:
	    R_VALL(in) = long(R_VALR(in))
	case REAL_REAL:
	    R_VALR(in) = real(R_VALR(in))
	case REAL_DOUBLE:
	    R_VALD(in) = double(R_VALR(in))
	case REAL_COMPLEX:
	    R_VALX(in) = complex(R_VALR(in))

	case DOUBLE_SHORT:
	    R_VALS(in) = short(R_VALD(in))
	case DOUBLE_INT:
	    R_VALI(in) = int(R_VALD(in))
	case DOUBLE_LONG:
	    R_VALL(in) = long(R_VALD(in))
	case DOUBLE_REAL:
	    R_VALR(in) = real(R_VALD(in))
	case DOUBLE_DOUBLE:
	    R_VALD(in) = double(R_VALD(in))
	case DOUBLE_COMPLEX:
	    R_VALX(in) = complex(R_VALD(in))

	case COMPLEX_SHORT:
	    R_VALS(in) = short(R_VALX(in))
	case COMPLEX_INT:
	    R_VALI(in) = int(R_VALX(in))
	case COMPLEX_LONG:
	    R_VALL(in) = long(R_VALX(in))
	case COMPLEX_REAL:
	    R_VALR(in) = real(R_VALX(in))
	case COMPLEX_DOUBLE:
	    R_VALD(in) = double(R_VALX(in))
	case COMPLEX_COMPLEX:
	    R_VALX(in) = complex(R_VALX(in))

	}

end
