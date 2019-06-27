#$Header: /home/pros/xray/ximages/imcalc/RCS/xarithop.x,v 11.0 1997/11/06 16:27:46 prosb Exp $
#$Log: xarithop.x,v $
#Revision 11.0  1997/11/06 16:27:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:56  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:18  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:10  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:54  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:45  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:52  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:21  pros
#General Release 1.0
#
#
#    XARITHOP.X -- arithmetic operations on vectors
#

include "imcalc.h"

#
#    xadd - add two vectors or a vector and a constant
#
procedure xadd(r1, r2, res)

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
            call aaddks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aaddki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aaddkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aaddkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aaddkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aaddkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
	}
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aaddks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aaddki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aaddkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aaddkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aaddkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aaddkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aadds(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aaddi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aaddl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aaddr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aaddd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aaddx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    }
end

#
#    xsub - sub two vectors or a vector and a constant
#
procedure xsub(r1, r2, res)

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
            call asubks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call asubki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call asubkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call asubkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call asubkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call asubkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
	}
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call asubks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call asubki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call asubkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call asubkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call asubkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call asubkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call asubs(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call asubi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call asubl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call asubr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call asubd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call asubx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    }
end

#
#    xmul - mul two vectors or a vector and a constant
#
procedure xmul(r1, r2, res)

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
            call amulks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amulki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amulkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amulkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amulkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amulkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
	}
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amulks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amulki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amulkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amulkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amulkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amulkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call amuls(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call amuli(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call amull(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call amulr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call amuld(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call amulx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    }
end

#
#    xdiv - div two vectors or a vector and a constant
#
procedure xdiv(r1, r2, res)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
int len				# l: length of r1 vector
int vector			# l: flag if r2 is a vector
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
    # get constant flag
    vector = R_LENGTH(r2)
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call adivks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call adivki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call adivkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call adivkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call adivkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call adivkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
	}
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call adivks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call adivki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call adivkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call adivkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call adivkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call adivkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call advzs(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len, errfcns)
        case TY_INT:
            call advzi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len, errfcni)
        case TY_LONG:
            call advzl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len, errfcnl)
        case TY_REAL:
            call advzr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len, errfcnr)
        case TY_DOUBLE:
            call advzd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len, errfcnd)
        case TY_COMPLEX:
            call advzx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len, errfcnx)
        default:
            call imc_unkpix("arithop")
	    return
        }
    }
end

#
#    xpow - exp two vectors or a vector and a constant
#
procedure xpow(r1, r2, res)

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
            call aexpks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aexpki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aexpkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aexpkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aexpkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aexpkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
	}
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aexpks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aexpki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aexpkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        case TY_REAL:
            call aexpkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call aexpkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call aexpkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("arithop")
	    return
        }
    # perform the operation between two vectors
    default:
        call imc_error("second operand must be constant for exp")
        return
    }
end

#
#    xneg - negate a vector
#
procedure xneg(r1, res)

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
        call anegs(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call anegi(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call anegl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    case TY_REAL:
        call anegr(Memr[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    case TY_DOUBLE:
        call anegd(Memd[R_LBUF(r1)], Memd[R_LBUF(res)], len)
    case TY_COMPLEX:
        call anegx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("arithop")
	return
    }
end
