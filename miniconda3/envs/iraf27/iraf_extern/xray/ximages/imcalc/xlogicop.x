#$Header: /home/pros/xray/ximages/imcalc/RCS/xlogicop.x,v 11.0 1997/11/06 16:27:57 prosb Exp $
#$Log: xlogicop.x,v $
#Revision 11.0  1997/11/06 16:27:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:43  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:38  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:16  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:00  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:52  pros
#General Release 1.0
#
#
#    XLOGICOP.X -- logical operations
#	These routines return an int vector whose values are 0 or 1
#	depending on the values of the input vectors.
#	These are logical in the sense that  C has logical
#	operators "&&", "||", etc, not bitwise boolean operators like
#	the C "&" and "|"
#	(The latter are contained in xboolop.x)
#

include "imcalc.h"

#
#    xllt --- res[i] = r1[i] < r2[i] ? r1[i] : r2[i]
#
procedure xllt(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abltks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abltki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abltkl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abltkr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abltkd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abltkx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abltks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abltki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abltkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abltkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abltkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abltkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call ablts(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call ablti(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abltl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abltr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abltd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abltx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end

#
#    xlle --- res[i] = r1[i] <= r2[i] ? r1[i] : r2[i]
#
procedure xlle(r1, r2, res)

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
    # check for internal error
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call ableks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call ableki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call ablekl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call ablekr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call ablekd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call ablekx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call ableks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call ableki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call ablekl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call ablekr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call ablekd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call ablekx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call ables(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call ablei(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call ablel(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abler(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abled(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call ablex(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end

#
#    xlgt	 --- res[i] = r1[i] > r2[i] ? r1[i] : r2[i]
#
procedure xlgt(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abgtks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgtki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgtkl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abgtkr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abgtkd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgtkx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abgtks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgtki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgtkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abgtkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abgtkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgtkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abgts(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgti(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgtl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abgtr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abgtd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgtx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end

#
#    xlge	--- res[i] = r1[i] >= r2[i] ? r1[i] : r2[i]
#
procedure xlge(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abgeks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgeki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgekl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abgekr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abgekd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgekx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abgeks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgeki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgekl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abgekr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abgekd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgekx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abges(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abgei(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abgel(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abger(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abged(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abgex(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end


#
#    xleq 	--- res[i] = r1[i] == r2[i] ? r1[i] : r2[i]
#
procedure xleq(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abeqks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abeqki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abeqkl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abeqkr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abeqkd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abeqkx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abeqks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abeqki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abeqkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abeqkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abeqkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abeqkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abeqs(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abeqi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abeql(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abeqr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abeqd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abeqx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end


#
#    xlne - res[i] = r1[i] != r2[i] ? r1[i] : r2[i]
#
procedure xlne(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abneks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abneki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abnekl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abnekr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abnekd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abnekx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abneks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abneki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abnekl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abnekr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abnekd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abnekx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abnes(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call abnei(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call abnel(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call abner(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call abned(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call abnex(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end

#
#    xland - res[i] = r1[i] != 0 && r2[i] != 0 ? 1 : 0
#
procedure xland(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call landks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call landki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call landkl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call landkr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call landkd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call landkx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call landks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call landki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call landkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call landkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call landkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call landkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call lands(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call landi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call landl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call landr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call landd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call landx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end

#
#    xlor - res[i] = r1[i] !=0 || r2[i] !=0 ? 1 : 0
#
procedure xlor(r1, r2, res)

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
    switch(vector){
    # perform the operation between a vector and a constant
    case 0:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call lorks(Mems[R_LBUF(r1)], R_VALS(r2), Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call lorki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call lorkl(Meml[R_LBUF(r1)], R_VALL(r2), Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call lorkr(Memr[R_LBUF(r1)], R_VALR(r2), Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call lorkd(Memd[R_LBUF(r1)], R_VALD(r2), Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call lorkx(Memx[R_LBUF(r1)], R_VALX(r2), Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call lorks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call lorki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call lorkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call lorkr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call lorkd(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call lorkx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call lors(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_INT:
            call lori(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call lorl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_REAL:
            call lorr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_DOUBLE:
            call lord(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_COMPLEX:
            call lorx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("logicop")
	    return
        }
    }
end


#
#    xlnot - logical not a vector
#
procedure xlnot(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    switch (R_TYPE(r1)){
    case TY_SHORT:
        call lnots(Mems[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_INT:
        call lnoti(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call lnotl(Meml[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    default:
        call imc_unkpix("logicop: unknown image pixel datatype")
        return
    }
end
