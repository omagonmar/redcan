#$Header: /home/pros/xray/ximages/imcalc/RCS/xboolop.x,v 11.0 1997/11/06 16:27:48 prosb Exp $
#$Log: xboolop.x,v $
#Revision 11.0  1997/11/06 16:27:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:50  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:54  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:26  pros
#General Release 1.0
#
#
#    XBOOLOP.X -- boolean operations
#	These are bitwise boolean operations, in the sense of
#	the C operators "&" and "|", as opposed to logical
#	operations in the sense of C "&&" and "||"
#	(The latter are contained in xlogicop.x)
#

include "imcalc.h"

#
#    xband - and two vectors or a vector and a constant
#
procedure xband(r1, r2, res)

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
            call aandks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aandki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aandkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aandks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aandki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aandkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aands(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aandi(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aandl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    }
end


#
#    xbor - or two vectors or a vector and a constant
#
procedure xbor(r1, r2, res)

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
            call aborks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aborki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aborkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call aborks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call aborki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aborkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
	}
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call abors(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call abori(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call aborl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    }
end

#
#    xbxor - xor two vectors or a vector and a constant
#
procedure xbxor(r1, r2, res)

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
            call axorks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call axorki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call axorkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    # convert value in a 1d buf into constant and
    # perform the operation between a vector and a constant
    case 1:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call axorks(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call axorki(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call axorkl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    # perform the operation between two vectors
    default:
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call axors(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		len)
        case TY_INT:
            call axori(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		len)
        case TY_LONG:
            call axorl(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		len)
        default:
            call imc_unkpix("boolop")
	    return
        }
    }
end

#
#    xbnot - boolean not a vector
#
procedure xbnot(r1, res)

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
        call anots(Mems[R_LBUF(r1)], Mems[R_LBUF(res)], len)
    case TY_INT:
        call anoti(Memi[R_LBUF(r1)], Memi[R_LBUF(res)], len)
    case TY_LONG:
        call anotl(Meml[R_LBUF(r1)], Meml[R_LBUF(res)], len)
    default:
        call imc_unkpix("boolop")
        return
    }
end
