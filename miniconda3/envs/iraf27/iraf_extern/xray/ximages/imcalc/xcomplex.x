#$Header: /home/pros/xray/ximages/imcalc/RCS/xcomplex.x,v 11.0 1997/11/06 16:27:51 prosb Exp $
#$Log: xcomplex.x,v $
#Revision 11.0  1997/11/06 16:27:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:02  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:56  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:32:36  pros
#General Release 1.0
#
#
# XCOMPLEX.X -- routines that only operate on complex numbers
#

include "imcalc.h"

#
#    xconjg - complex conjgate a vector
#
procedure xconjg(r1, res)

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
    case TY_COMPLEX:
        call acjgx(Memx[R_LBUF(r1)], Memx[R_LBUF(res)], len)
    default:
        call imc_unkpix("complex")
	return
    }

end

#
#    xaimag - get imaginary part of a complex vector
#
procedure xaimag(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # return a real vector
    R_TYPE(res) = TY_REAL
#    # allocate a new buffer space
#    call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_COMPLEX:
        call aimagx(Memx[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    default:
        call imc_unkpix("complex")
	return
    }

end

#
#    xareal - get real part of a complex vector
#
procedure xareal(r1, res)

pointer r1			# i: input register 1
pointer res			# o: output register
int len				# l: length of r1 vector
include "imcalc.com"

begin

    # get length of vector
    len = R_LENGTH(r1)
    # return a real vector
    R_TYPE(res) = TY_REAL
#    # allocate a new buffer space
#    call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
    # overwrite r1's buffer
    R_LBUF(res) = R_LBUF(r1)
    switch (R_TYPE(r1)){
    case TY_COMPLEX:
        call arealx(Memx[R_LBUF(r1)], Memr[R_LBUF(res)], len)
    default:
        call imc_unkpix("complex")
	return
    }

end

# AIMAGX -- get imaginary part of a complex vector.

procedure aimagx (a, b, npix)

complex	a[ARB], b[ARB]
int	npix
int	i

begin
	do i = 1, npix
	    b[i] = aimag (a[i])
end

# AREALX -- get real part of a complex vector.

procedure arealx (a, b, npix)

complex	a[ARB], b[ARB]
int	npix
int	i

begin
	do i = 1, npix
	    b[i] = real (a[i])
end
