#$Header: /home/pros/xray/ximages/imcalc/RCS/xproj.x,v 11.0 1997/11/06 16:28:00 prosb Exp $
#$Log: xproj.x,v $
#Revision 11.0  1997/11/06 16:28:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:10  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:40  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:17  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:26  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:03  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:33:00  pros
#General Release 1.0
#
#
#    XPROJ.X -- projections on vectors
#

include "imcalc.h"

#
#    xlen - get the len of a line of a vector
#
procedure xlen(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register

begin

    # result is a scaler of type int
    R_LENGTH(res) = 1
    R_TYPE(res) = TY_INT
    call amovki(R_LENGTH(r1), Memi[R_LBUF(res)], 1)

end

#
#    xsum - take the sum of a line of a vector
#
procedure xsum(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
real asums(), asumi(), asumr()
double asuml(), asumd()
complex asumx()
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # result is a scaler - type varies
    R_LENGTH(res) = 1
    switch (R_TYPE(r1)){
    case TY_SHORT:
	R_TYPE(res) = TY_REAL
        call amovkr(asums(Mems[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_INT:
	R_TYPE(res) = TY_REAL
        call amovkr(asumi(Memi[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_LONG:
	R_TYPE(res) = TY_DOUBLE
        call amovkd(asuml(Meml[R_LBUF(r1)], len), Memd[R_LBUF(res)], 1)
    case TY_REAL:
	R_TYPE(res) = TY_REAL
        call amovkr(asumr(Memr[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_DOUBLE:
	R_TYPE(res) = TY_DOUBLE
        call amovkd(asumd(Memd[R_LBUF(r1)], len), Memd[R_LBUF(res)], 1)
    case TY_COMPLEX:
	R_TYPE(res) = TY_COMPLEX
        call amovkx(asumx(Memx[R_LBUF(r1)], len), Memx[R_LBUF(res)], 1)
    default:
        call imc_unkpix("proj")
	return
    }

end

#
#    xlow - get the lo value of a line in a vector
#
procedure xlow(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
short alovs()
int alovi()
long alovd()
real alovr()
double alovl()
complex alovx()
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # result is a scaler - type varies
    R_LENGTH(res) = 1
    switch (R_TYPE(r1)){
    case TY_SHORT:
	R_TYPE(res) = TY_SHORT
        call amovks(alovs(Mems[R_LBUF(r1)], len), Mems[R_LBUF(res)], 1)
    case TY_INT:
	R_TYPE(res) = TY_INT
        call amovki(alovi(Memi[R_LBUF(r1)], len), Memi[R_LBUF(res)], 1)
    case TY_LONG:
	R_TYPE(res) = TY_LONG
        call amovkl(alovl(Meml[R_LBUF(r1)], len), Meml[R_LBUF(res)], 1)
    case TY_REAL:
	R_TYPE(res) = TY_REAL
        call amovkr(alovr(Memr[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_DOUBLE:
	R_TYPE(res) = TY_DOUBLE
        call amovkd(alovd(Memd[R_LBUF(r1)], len), Memd[R_LBUF(res)], 1)
    case TY_COMPLEX:
	R_TYPE(res) = TY_COMPLEX
        call amovkx(alovx(Memx[R_LBUF(r1)], len), Memx[R_LBUF(res)], 1)
    default:
        call imc_unkpix("proj")
	return
    }

end

#
#    xhigh - get the hi value of a line in a vector
#
procedure xhigh(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
short ahivs()
int ahivi()
long ahivd()
real ahivr()
double ahivl()
complex ahivx()
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # result is a scaler - type varies
    R_LENGTH(res) = 1
    switch (R_TYPE(r1)){
    case TY_SHORT:
	R_TYPE(res) = TY_SHORT
        call amovks(ahivs(Mems[R_LBUF(r1)], len), Mems[R_LBUF(res)], 1)
    case TY_INT:
	R_TYPE(res) = TY_INT
        call amovki(ahivi(Memi[R_LBUF(r1)], len), Memi[R_LBUF(res)], 1)
    case TY_LONG:
	R_TYPE(res) = TY_LONG
        call amovkl(ahivl(Meml[R_LBUF(r1)], len), Meml[R_LBUF(res)], 1)
    case TY_REAL:
	R_TYPE(res) = TY_REAL
        call amovkr(ahivr(Memr[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_DOUBLE:
	R_TYPE(res) = TY_DOUBLE
        call amovkd(ahivd(Memd[R_LBUF(r1)], len), Memd[R_LBUF(res)], 1)
    case TY_COMPLEX:
	R_TYPE(res) = TY_COMPLEX
        call amovkx(ahivx(Memx[R_LBUF(r1)], len), Memx[R_LBUF(res)], 1)
    default:
        call imc_unkpix("proj")
	return
    }

end

#
#    xmed - get the med value of a line in a vector
#
procedure xmed(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
short ameds()
int amedi()
long amedd()
real amedr()
double amedl()
complex amedx()
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # result is a scaler - type varies
    R_LENGTH(res) = 1
    switch (R_TYPE(r1)){
    case TY_SHORT:
	R_TYPE(res) = TY_SHORT
        call amovks(ameds(Mems[R_LBUF(r1)], len), Mems[R_LBUF(res)], 1)
    case TY_INT:
	R_TYPE(res) = TY_INT
        call amovki(amedi(Memi[R_LBUF(r1)], len), Memi[R_LBUF(res)], 1)
    case TY_LONG:
	R_TYPE(res) = TY_LONG
        call amovkl(amedl(Meml[R_LBUF(r1)], len), Meml[R_LBUF(res)], 1)
    case TY_REAL:
	R_TYPE(res) = TY_REAL
        call amovkr(amedr(Memr[R_LBUF(r1)], len), Memr[R_LBUF(res)], 1)
    case TY_DOUBLE:
	R_TYPE(res) = TY_DOUBLE
        call amovkd(amedd(Memd[R_LBUF(r1)], len), Memd[R_LBUF(res)], 1)
    case TY_COMPLEX:
	R_TYPE(res) = TY_COMPLEX
        call amovkx(amedx(Memx[R_LBUF(r1)], len), Memx[R_LBUF(res)], 1)
    default:
        call imc_unkpix("proj")
	return
    }

end

#
#    xavg - take the avg of a line of a vector
#
procedure xavg(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
real avgr
real sigmar
double avgd
double sigmad
complex avgx
complex sigmax
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # result is a scaler - type varies
    R_LENGTH(res) = 1
    switch (R_TYPE(r1)){
    case TY_SHORT:
	R_TYPE(res) = TY_REAL
        call aavgs(Mems[R_LBUF(r1)], len, avgr, sigmar)
	call amovkr(avgr, Memr[R_LBUF(res)], 1)
    case TY_INT:
	R_TYPE(res) = TY_REAL
        call aavgi(Memi[R_LBUF(r1)], len, avgr, sigmar)
	call amovkr(avgr, Memr[R_LBUF(res)], 1)
    case TY_LONG:
	R_TYPE(res) = TY_DOUBLE
        call aavgl(Meml[R_LBUF(r1)], len, avgd, sigmad)
	call amovkd(avgd, Memd[R_LBUF(res)], 1)
    case TY_REAL:
	R_TYPE(res) = TY_REAL
        call aavgr(Memr[R_LBUF(r1)], len, avgr, sigmar)
	call amovkr(avgr, Memr[R_LBUF(res)], 1)
    case TY_DOUBLE:
	R_TYPE(res) = TY_DOUBLE
        call aavgd(Memd[R_LBUF(r1)], len, avgd, sigmad)
	call amovkd(avgd, Memd[R_LBUF(res)], 1)
    case TY_COMPLEX:
	R_TYPE(res) = TY_COMPLEX
        call aavgx(Memx[R_LBUF(r1)], len, avgx, sigmax)
	call amovkx(avgx, Memx[R_LBUF(res)], 1)
    default:
        call imc_unkpix("proj")
	return
    }

end

