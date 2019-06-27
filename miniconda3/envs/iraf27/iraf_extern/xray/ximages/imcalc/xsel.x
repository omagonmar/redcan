#$Header: /home/pros/xray/ximages/imcalc/RCS/xsel.x,v 11.0 1997/11/06 16:28:01 prosb Exp $
#$Log: xsel.x,v $
#Revision 11.0  1997/11/06 16:28:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:12  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:43  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:04  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:33:04  pros
#General Release 1.0
#
#
#    XSEL.X -- select from one or another vector based on a third selection
#		vector
#

include "imcalc.h"

#
#    xsel -- select from one or another vector based on a third
#
procedure xsel(r1, r2, res, sel)

pointer r1			# i: input register 1
pointer r2			# i: input register 2
pointer res			# o: output register
pointer sel			# i: selection register
int len1			# l: length of r1 vector
int len2			# l: length of r2 vector
int lenres			# l: length of result vector
include "imcalc.com"
begin
    # get length of vectors
    len1 = R_LENGTH(r1)
    len2 = R_LENGTH(r2)
    lenres = R_LENGTH(res)
    if( len2 > 0 ){
      # case 1: 2 vectors
      if( len1 >0 ){
        # perform the selection
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call asels(Mems[R_LBUF(r1)], Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_INT:
            call aseli(Memi[R_LBUF(r1)], Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_LONG:
            call asell(Meml[R_LBUF(r1)], Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_REAL:
            call aselr(Memr[R_LBUF(r1)], Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_DOUBLE:
            call aseld(Memd[R_LBUF(r1)], Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_COMPLEX:
            call aselx(Memx[R_LBUF(r1)], Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        default:
	    call imc_error("sel: unknown image pixel datatype")
	    return
        }
      }
      # case 1.5: constant and vector
      else{
        # perform the selection
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call selkvs(R_VALS(r1), Mems[R_LBUF(r2)], Mems[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_INT:
            call selkvi(R_VALI(r1), Memi[R_LBUF(r2)], Memi[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_LONG:
            call selkvl(R_VALL(r1), Meml[R_LBUF(r2)], Meml[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_REAL:
            call selkvr(R_VALR(r1), Memr[R_LBUF(r2)], Memr[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_DOUBLE:
            call selkvd(R_VALD(r1), Memd[R_LBUF(r2)], Memd[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_COMPLEX:
            call selkvx(R_VALX(r1), Memx[R_LBUF(r2)], Memx[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        default:
            call imc_error("sel: unknown image pixel datatype")
	    return
        }
      }
    }
    # case 2: vector and constant
    else if( len1 >0 ){
        # perform the selection
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call selks(Mems[R_LBUF(r1)], R_VALS(r2), Mems[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_INT:
            call selki(Memi[R_LBUF(r1)], R_VALI(r2), Memi[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_LONG:
            call selkl(Meml[R_LBUF(r1)], R_VALL(r2), Meml[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_REAL:
            call selkr(Memr[R_LBUF(r1)], R_VALR(r2), Memr[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_DOUBLE:
            call selkd(Memd[R_LBUF(r1)], R_VALD(r2), Memd[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_COMPLEX:
            call selkx(Memx[R_LBUF(r1)], R_VALX(r2), Memx[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        default:
            call imc_error("sel: unknown image pixel datatype")
	    return
        }
    }
    # case 3: two constants
    else{
        # perform the selection
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call sel2s(R_VALS(r1), R_VALS(r2), Mems[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_INT:
            call sel2i(R_VALI(r1), R_VALI(r2), Memi[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_LONG:
            call sel2l(R_VALL(r1), R_VALL(r2), Meml[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_REAL:
            call sel2r(R_VALR(r1), R_VALR(r2), Memr[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_DOUBLE:
            call sel2d(R_VALD(r1), R_VALD(r2), Memd[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        case TY_COMPLEX:
            call sel2x(R_VALX(r1), R_VALX(r2), Memx[R_LBUF(res)],
		Memi[R_LBUF(sel)], lenres)
        default:
	    call imc_error("sel: unknown image pixel datatype")
	    return
        }
    }
end
