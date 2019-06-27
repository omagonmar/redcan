#$Header: /home/pros/xray/ximages/imcalc/RCS/xprn.x,v 11.0 1997/11/06 16:27:59 prosb Exp $
#$Log: xprn.x,v $
#Revision 11.0  1997/11/06 16:27:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:22  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:02  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:57  pros
#General Release 1.0
#
#
#    XPRN.X -- print out a line of data
#

include "imcalc.h"

#
#    xprn -- print out a line of data
#
procedure xprn(r1)

pointer r1			# i: input register 1
int len				# l: length of r1 vector
include "imcalc.com"

begin
    call printf("#%d: ")
    call pargi(c_lineno)
    # get length of vector
    len = R_LENGTH(r1)
    # perform the print
    if( len > 0 ){
        switch (R_TYPE(r1)){
        case TY_SHORT:
            call prns(Mems[R_LBUF(r1)], len)
        case TY_INT:
            call prni(Memi[R_LBUF(r1)], len)
        case TY_LONG:
            call prnl(Meml[R_LBUF(r1)], len)
        case TY_REAL:
            call prnr(Memr[R_LBUF(r1)], len)
        case TY_DOUBLE:
            call prnd(Memd[R_LBUF(r1)], len)
        case TY_COMPLEX:
            call prnx(Memx[R_LBUF(r1)], len)
        default:
	    call imc_error("prn: unknown image pixel datatype")
	    return
        }
    }
    else{
        # and print it out
        switch (R_TYPE(r1)){
        case TY_SHORT:
	    call printf("%d ")
            call pargs(R_VALS(r1))
        case TY_INT:
	    call printf("%d ")
            call pargi(R_VALI(r1))
        case TY_LONG:
	    call printf("%d ")
            call pargl(R_VALL(r1))
        case TY_REAL:
	    call printf("%f ")
            call pargr(R_VALR(r1))
        case TY_DOUBLE:
	    call printf("%f ")
            call pargd(R_VALD(r1))
        case TY_COMPLEX:
	    call printf("%f ")
            call pargx(R_VALX(r1))
        default:
	    call imc_error("prn: unknown image pixel datatype")
	    return
        }
    }
    call printf("\n")
    call flush(STDOUT)
end
