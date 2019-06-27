#$Header: /home/pros/xray/ximages/imcalc/RCS/xfunc.x,v 11.0 1997/11/06 16:27:53 prosb Exp $
#$Log: xfunc.x,v $
#Revision 11.0  1997/11/06 16:27:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:26  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:07  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:58  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:41  pros
#General Release 1.0
#
#
#    XFUNC.X -- functions on vectors or vectors and constants
#

include "imcalc.h"

#
#    xzero - clear a vector
#
procedure xzero(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call aclrs(Mems[R_LBUF(res)], len)
    case TY_INT:
        call aclri(Memi[R_LBUF(res)], len)
    case TY_LONG:
        call aclrl(Meml[R_LBUF(res)], len)
    case TY_REAL:
        call aclrr(Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call aclrd(Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call aclrx(Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xabs - take the abs of a vector
#
procedure xabs(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call aabss(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call aabsi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call aabsl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call aabsr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call aabsd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call aabsx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xsin - take the sin of a vector
#
procedure xsin(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern sind()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call sins(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call sini(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call sinl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call sinr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call sind(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call sinx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xcos - take the cos of a vector
#
procedure xcos(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern cosd()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call coss(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call cosi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call cosl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call cosr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call cosd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call cosx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xtan - take the tan of a vector
#
procedure xtan(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern tand()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call tans(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call tani(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call tanl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call tanr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call tand(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call tanx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xasin - take the asin of a vector
#
procedure xasin(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern asind()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call asins(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call asini(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call asinl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call asinr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call asind(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call asinx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xacos - take the acos of a vector
#
procedure xacos(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern acosd()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call acoss(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call acosi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call acosl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call acosr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call acosd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call acosx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xatan - take the atan of a vector
#
procedure xatan(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"
extern atand()			# l: avoid intrinsic of same name

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call atans(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call atani(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call atanl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call atanr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call atand(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call atanx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xlog - take the log of a vector
#
procedure xlog(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
extern errfcns()		# l: error function
extern errfcni()		# l: error function
extern errfcnl()		# l: error function
extern errfcnr()		# l: error function
extern errfcnd()		# l: error function
extern errfcnx()		# l: error function

include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call allns(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len, errfcns)
    case TY_INT:
        call allni(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len, errfcni)
    case TY_LONG:
        call allnl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len, errfcnl)
    case TY_REAL:
        call allnr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len, errfcnr)
    case TY_DOUBLE:
        call allnd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len, errfcnd)
    case TY_COMPLEX:
        call allnx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len, errfcnx)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xlog10 - take the log10 of a vector
#
procedure xlog10(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
extern errfcns()		# l: error function
extern errfcni()		# l: error function
extern errfcnl()		# l: error function
extern errfcnr()		# l: error function
extern errfcnd()		# l: error function
extern errfcnx()		# l: error function
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call alogs(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len, errfcns)
    case TY_INT:
        call alogi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len, errfcni)
    case TY_LONG:
        call alogl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len, errfcnl)
    case TY_REAL:
        call alogr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len, errfcnr)
    case TY_DOUBLE:
        call alogd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len, errfcnd)
    case TY_COMPLEX:
        call alogx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len, errfcnx)
    default:
        call imc_unkpix("func")
	return
    }
end


#
#    xsqrt - take the sqrt of a vector
#
procedure xsqrt(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
extern errfcns()		# l: error function
extern errfcni()		# l: error function
extern errfcnl()		# l: error function
extern errfcnr()		# l: error function
extern errfcnd()		# l: error function
extern errfcnx()		# l: error function
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call asqrs(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len, errfcns)
    case TY_INT:
        call asqri(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len, errfcni)
    case TY_LONG:
        call asqrl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len, errfcnl)
    case TY_REAL:
        call asqrr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len, errfcnr)
    case TY_DOUBLE:
        call asqrd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len, errfcnd)
    case TY_COMPLEX:
        call asqrx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len, errfcnx)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xexp - take the exp of a vector
#
procedure xexp(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call exps(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call expi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call expl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call expr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call expd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call expx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

#
#    xmod - mod two vectors or a vector and a constant
#
procedure xmod(r1, r2, res)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
int len				# l: length of r1 vector
int vector			# l: flag if r2 is a vector
include "imcalc.com"

begin
    # get length of vector
    len = R_LENGTH(r1)
    # get constant flag
    vector = R_LENGTH(r2)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amodks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amodki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amodkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amodkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amodkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
#        case TY_COMPLEX:
#            call amodkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
#		len)
        default:
            call imc_unkpix("func")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amodks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amodki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amodkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amodkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amodkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
#        case TY_COMPLEX:
#            call amodkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
#		len)
        default:
            call imc_unkpix("func")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amods(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amodi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amodl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amodr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amodd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
#        case TY_COMPLEX:
#            call amodx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
#		len)
        default:
            call imc_unkpix("func")
	    return
        }
    }
end

#
#    xmin - min two vectors or a vector and a constant
#
procedure xmin(r1, r2, res)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
int len				# l: length of r1 vector
int vector			# l: flag if r2 is a vector
include "imcalc.com"

begin
    # get length of vector
    len = R_LENGTH(r1)
    # get constant flag
    vector = R_LENGTH(r2)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aminks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aminki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aminkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aminkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aminkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aminkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aminks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aminki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aminkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aminkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aminkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aminkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amins(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amini(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aminl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aminr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amind(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aminx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
        }
    }
end

#
#    xmax - max two vectors or a vector and a constant
#
procedure xmax(r1, r2, res)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
int len				# l: length of r1 vector
int vector			# l: flag if r2 is a vector
include "imcalc.com"

begin
    # get length of vector
    len = R_LENGTH(r1)
    # get constant flag
    vector = R_LENGTH(r2)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amaxks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amaxki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amaxkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amaxkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amaxkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amaxkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amaxks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amaxki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amaxkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amaxkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amaxkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amaxkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amaxs(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amaxi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amaxl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amaxr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amaxd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amaxx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
        }
    }
end


#
#    xatn2 - atn2 two vectors or a vector and a constant
#
procedure xatn2(r1, r2, res)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
int len				# l: length of r1 vector
int vector			# l: flag if r2 is a vector
include "imcalc.com"

begin
    # get length of vector
    len = R_LENGTH(r1)
    # get constant flag
    vector = R_LENGTH(r2)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
#        case TY_SHORT:
#            call atn2ks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
#		len)
#        case TY_INT:
#            call atn2ki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
#		len)
#        case TY_LONG:
#            call atn2kl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
#		len)
#        case TY_REAL:
#            call atn2kr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
#		len)
#        case TY_DOUBLE:
#            call atn2kd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
#		len)
#        case TY_COMPLEX:
#            call atn2kx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
#		len)
        default:
            call imc_unkpix("func")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
#        case TY_SHORT:
#            call atn2ks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
#		len)
#        case TY_INT:
#            call atn2ki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
#		len)
#        case TY_LONG:
#            call atn2kl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
#		len)
#        case TY_REAL:
#            call atn2kr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
#		len)
#        case TY_DOUBLE:
#            call atn2kd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
#		len)
#        case TY_COMPLEX:
#            call atn2kx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
#		len)
        default:
            call imc_unkpix("func")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call atn2s(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call atn2i(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call atn2l(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call atn2r(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call atn2d(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call atn2x(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("func")
	    return
        }
    }
end

#
#    xnint - take the nint of a vector
#
procedure xnint(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin
    # get length of vector
    len = R_LENGTH(r1)
    # return an integer vector
    R_TYPE(res) = TY_INT
    # allocate a new buffer space
    if( R_LBUF(res) ==0 ){
	call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
    }
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call nints(Mems[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_INT:
        call ninti(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call nintl(Meml[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_REAL:
        call nintr(Memr[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_DOUBLE:
        call nintd(Memd[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_COMPLEX:
        call nintx(Memx[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    default:
        call imc_unkpix("func")
	return
    }
end

