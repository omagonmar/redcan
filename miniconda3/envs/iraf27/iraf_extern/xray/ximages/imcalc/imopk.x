#$Header: /home/pros/xray/ximages/imcalc/RCS/imopk.x,v 11.0 1997/11/06 16:27:40 prosb Exp $
#$Log: imopk.x,v $
#Revision 11.0  1997/11/06 16:27:40  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:44  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:49  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:40  pros
#General Release 1.0
#
#
# IMOPK.X --  operations on one or two constant registers
#

include "imcalc.h"
include "imcfunc.h"

define tan	sin(($1))/cos(($1))

#
# IMC_BINOPK -- perform binary operations between 2 constants
# and return a constant register
#
procedure imc_binopk (operation, a, b, c)

int	operation		# i: i.e., '+', '-', etc.
pointer	a, b			# i: c = a op b
pointer c			# o: output register
int type			# l: type of result
int	and(), ands(), andl()	# l: logical
int	or(), ors(), orl()	# l: logical
int	xor(), xors(), xorl()	# l: logical

begin
	# coerce the two types, if necessary
	if( R_TYPE(a) != R_TYPE(b) ){
		type = max(R_TYPE(a), R_TYPE(b))
		call xchtk(a, type)
		call xchtk(b, type)
	}
	else
		type = R_TYPE(a)

	# set the output type and length
	R_TYPE(c) = type
	R_LENGTH(c) = 0
	switch(operation){
	    case OP_BAND:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = ands(R_VALS(a), R_VALS(b))
		case TY_INT:
		    R_VALI(c) = and(R_VALI(a), R_VALI(b))
		case TY_LONG:
		    R_VALL(c) = andl(R_VALL(a), R_VALL(b))

		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_BOR:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = ors(R_VALS(a), R_VALS(b))
		case TY_INT:
		    R_VALI(c) = or(R_VALI(a), R_VALI(b))
		case TY_LONG:
		    R_VALL(c) = orl(R_VALL(a), R_VALL(b))

		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_BXOR:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = xors(R_VALS(a), R_VALS(b))
		case TY_INT:
		    R_VALI(c) = xor(R_VALI(a), R_VALI(b))
		case TY_LONG:
		    R_VALL(c) = xorl(R_VALL(a), R_VALL(b))

		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_ADD:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = R_VALS(a) + R_VALS(b)
		case TY_INT:
		    R_VALI(c) = R_VALI(a) + R_VALI(b)
		case TY_LONG:
		    R_VALL(c) = R_VALL(a) + R_VALL(b)
		case TY_REAL:
		    R_VALR(c) = R_VALR(a) + R_VALR(b)
		case TY_DOUBLE:
		    R_VALD(c) = R_VALD(a) + R_VALD(b)
		case TY_COMPLEX:
		    R_VALX(c) = R_VALX(a) + R_VALX(b)
		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_SUB:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = R_VALS(a) - R_VALS(b)
		case TY_INT:
		    R_VALI(c) = R_VALI(a) - R_VALI(b)
		case TY_LONG:
		    R_VALL(c) = R_VALL(a) - R_VALL(b)
		case TY_REAL:
		    R_VALR(c) = R_VALR(a) - R_VALR(b)
		case TY_DOUBLE:
		    R_VALD(c) = R_VALD(a) - R_VALD(b)
		case TY_COMPLEX:
		    R_VALX(c) = R_VALX(a) - R_VALX(b)
		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_MUL:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = R_VALS(a) * R_VALS(b)
		case TY_INT:
		    R_VALI(c) = R_VALI(a) * R_VALI(b)
		case TY_LONG:
		    R_VALL(c) = R_VALL(a) * R_VALL(b)
		case TY_REAL:
		    R_VALR(c) = R_VALR(a) * R_VALR(b)
		case TY_DOUBLE:
		    R_VALD(c) = R_VALD(a) * R_VALD(b)
		case TY_COMPLEX:
		    R_VALX(c) = R_VALX(a) * R_VALX(b)
		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_DIV:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = R_VALS(a) / R_VALS(b)
		case TY_INT:
		    R_VALI(c) = R_VALI(a) / R_VALI(b)
		case TY_LONG:
		    R_VALL(c) = R_VALL(a) / R_VALL(b)
		case TY_REAL:
		    R_VALR(c) = R_VALR(a) / R_VALR(b)
		case TY_DOUBLE:
		    R_VALD(c) = R_VALD(a) / R_VALD(b)
		case TY_COMPLEX:
		    R_VALX(c) = R_VALX(a) / R_VALX(b)
		default:
		    call imc_unkpix("binopk")
	    }
	    case OP_POW:
	    switch(type){
		case TY_SHORT:
		    R_VALS(c) = R_VALS(a) ** R_VALS(b)
		case TY_INT:
		    R_VALI(c) = R_VALI(a) ** R_VALI(b)
		case TY_LONG:
		    R_VALL(c) = R_VALL(a) ** R_VALL(b)
		case TY_REAL:
		    R_VALR(c) = R_VALR(a) ** R_VALR(b)
		case TY_DOUBLE:
		    R_VALD(c) = R_VALD(a) ** R_VALD(b)
		case TY_COMPLEX:
		    R_VALX(c) = R_VALX(a) ** R_VALX(b)
		default:
		    call imc_unkpix("binopk")
	    }
	    case FUNC_ATAN2:
		call atan2k(a, b, c)
	    case FUNC_MAX:
		call maxk(a, b, c)
	    case FUNC_MIN:
		call mink(a, b, c)
	    case FUNC_MOD:
		call modk(a, b, c)
	    default:
		call imc_error("unknown binary operator")
	}
end

#
# MAXK -- max of 2 constants
#
procedure maxk(a, b, c)

pointer a		# i: input register
pointer b		# i: input register
pointer c		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_VALS(c) = max(R_VALS(a), R_VALS(b))
	case TY_INT:
	    R_VALI(c) = max(R_VALI(a), R_VALI(b))
	case TY_LONG:
	    R_VALL(c) = max(R_VALL(a), R_VALL(b))
	case TY_REAL:
	    R_VALR(c) = max(R_VALR(a), R_VALR(b))
	case TY_DOUBLE:
	    R_VALD(c) = max(R_VALD(a), R_VALD(b))
	case TY_COMPLEX:
	    R_TYPE(c) = TY_DOUBLE
	    R_VALD(c) = max(double(R_VALX(a)), double(R_VALX(b)))
	default:
	    call imc_unkpix("binopk")
    }	
end

#
# MINK -- min of 2 constants
#
procedure mink(a, b, c)

pointer a		# i: input register
pointer b		# i: input register
pointer c		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_VALS(c) = min(R_VALS(a), R_VALS(b))
	case TY_INT:
	    R_VALI(c) = min(R_VALI(a), R_VALI(b))
	case TY_LONG:
	    R_VALL(c) = min(R_VALL(a), R_VALL(b))
	case TY_REAL:
	    R_VALR(c) = min(R_VALR(a), R_VALR(b))
	case TY_DOUBLE:
	    R_VALD(c) = min(R_VALD(a), R_VALD(b))
	case TY_COMPLEX:
	    R_TYPE(c) = TY_DOUBLE
	    R_VALD(c) = min(double(R_VALX(a)), double(R_VALX(b)))
	default:
	    call imc_unkpix("binopk")
    }	
end

#
# MODK -- mod of 2 constants
#
procedure modk(a, b, c)

pointer a		# i: input register
pointer b		# i: input register
pointer c		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_VALS(c) = mod(R_VALS(a), R_VALS(b))
	case TY_INT:
	    R_VALI(c) = mod(R_VALI(a), R_VALI(b))
	case TY_LONG:
	    R_VALL(c) = mod(R_VALL(a), R_VALL(b))
	case TY_REAL:
	    R_VALR(c) = mod(R_VALR(a), R_VALR(b))
	case TY_DOUBLE:
	    R_VALD(c) = mod(R_VALD(a), R_VALD(b))
	case TY_COMPLEX:
	    R_TYPE(c) = TY_DOUBLE
	    R_VALD(c) = mod(double(R_VALX(a)), double(R_VALX(b)))
	default:
	    call imc_unkpix("binopk")
    }	
end

#
# ATAN2K -- atan2 of 2 constants
#
procedure atan2k(a, b, c)

pointer a		# i: input register
pointer b		# i: input register
pointer c		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(c) = TY_REAL
	    R_VALR(c) = atan2(real(R_VALS(a)), real(R_VALS(b)))
	case TY_INT:
	    R_TYPE(c) = TY_REAL
	    R_VALR(c) = atan2(real(R_VALI(a)), real(R_VALI(b)))
	case TY_LONG:
	    R_TYPE(c) = TY_DOUBLE
	    R_VALD(c) = atan2(double(R_VALL(a)), double(R_VALL(b)))
	case TY_REAL:
	    R_VALR(c) = atan2(R_VALR(a), R_VALR(b))
	case TY_DOUBLE:
	    R_VALD(c) = atan2(R_VALD(a), R_VALD(b))
	case TY_COMPLEX:
	    R_TYPE(c) = TY_DOUBLE
	    R_VALD(c) = atan2(double(R_VALS(a)), double(R_VALS(b)))
	default:
	    call imc_unkpix("binopk")
    }	
end


#
# IMC_UNOPK -- Perform a unary operation.  Since there is only one operand, the
# datatype does not change.
#
procedure imc_unopk (operation, a, b)

int	operation			# i: operation 
pointer	a				# i: input register
pointer b				# o: output register
int	nots(), not(), notl()		# l: not function

begin
	# output is same type as input
	R_TYPE(b) = R_TYPE(a)
	R_LENGTH(b) = 0

	# perform the operation
	switch (operation) {
	case OP_NEG:
	    switch (R_TYPE(a)) {
		case TY_SHORT:
		    R_VALS(b) = -R_VALS(a)
		case TY_INT:
		    R_VALI(b) = -R_VALI(a)
		case TY_LONG:
		    R_VALL(b) = -R_VALL(a)
		case TY_REAL:
		    R_VALR(b) = -R_VALR(a)
		case TY_DOUBLE:
		    R_VALD(b) = -R_VALD(a)
		case TY_COMPLEX:
		    R_VALX(b) = -R_VALX(a)
		default:
		    call imc_unkpix("unopk")
	    }
	case OP_BNOT:
	    switch (R_TYPE(a)) {
		case TY_SHORT:
		    R_VALS(b) = nots(R_VALS(a))
		case TY_INT:
		    R_VALI(b) = not(R_VALI(a))
		case TY_LONG:
		    R_VALL(b) = notl(R_VALL(a))
		default:
		    call imc_unkpix("unopk")
	    }
# this is too stupid ...
#	case OP_LNOT:
#	    switch (R_TYPE(a)) {
#	    case TY_SHORT:
#		if( R_VALS(a) == 0 )
#		    R_VALS(b) = 1
#		else
#		    R_VALS(b) = 0
#	    case TY_INT:
#		if( R_VALI(a) == 0 )
#		    R_VALI(b) = 1
#		else
#		    R_VALI(b) = 0
#	    case TY_LONG:
#		if( R_VALL(a) == 0 )
#		    R_VALL(b) = 1
#		else
#		    R_VALL(b) = 0
#	    case TY_REAL:
#		if( R_VALR(a) == 0 )
#		    R_VALR(b) = 1
#		else
#		    R_VALR(b) = 0
#	    case TY_DOUBLE:
#		if( R_VALD(a) == 0 )
#		    R_VALD(b) = 1
#		else
#		    R_VALD(b) = 0
#	    case TY_COMPLEX:
#		if( R_VALX(a) == 0 )
#		    R_VALX(b) = 1
#		else
#		    R_VALX(b) = 0
#	    default:
#		call imc_unkpix("unopk")
#	    }
	case FUNC_SIN:
	    call sink(a, b)
	case FUNC_COS:
	    call cosk(a, b)
	case FUNC_TAN:
	    call tank(a, b)
	case FUNC_ASIN:
	    call asink(a, b)
	case FUNC_ACOS:
	    call acosk(a, b)
	case FUNC_ATAN1:
	    call atank(a, b)
	case FUNC_SQRT:
	    call sqrtk(a, b)
	case FUNC_EXP:
	    call expk(a, b)

	case FUNC_LOG:
	    call logk(a, b)
	case FUNC_LOG10:
	    call log10k(a, b)
	case FUNC_ABS:
	    call absk(a, b)
	case FUNC_CONJG:
	    call conjgk(a, b)
	case FUNC_AIMAG:
	    call aimagk(a, b)
	case FUNC_AREAL:
	    call arealk(a, b)
	case FUNC_NINT:
	    call nintk(a, b)
	default:
	    call imc_error ("unknown unary operator")
	    return
	}
end

#
# SINK -- sin of a constant
#
procedure sink(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = sin(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = sin(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = sin(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = sin(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = sin(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = sin(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# COSK -- cos of a constant
#
procedure cosk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = cos(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = cos(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = cos(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = cos(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = cos(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = cos(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# TANK -- tan of a constant
#
procedure tank(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = tan(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = tan(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = tan(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = tan(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = tan(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = tan(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# ASINK -- asin of a constant
#
procedure asink(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = asin(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = asin(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = asin(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = asin(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = asin(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = asin(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# ACOSK -- acos of a constant
#
procedure acosk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = acos(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = acos(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = acos(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = acos(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = acos(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = acos(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# ATANK -- atan of a constant
#
procedure atank(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = atan(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = atan(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = atan(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = atan(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = atan(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = atan(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# SQRTK -- sqrt of a constant
#
procedure sqrtk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = sqrt(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = sqrt(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = sqrt(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = sqrt(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = sqrt(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = sqrt(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# EXPK -- exp of a constant
#
procedure expk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = exp(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = exp(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = exp(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = exp(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = exp(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = exp(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# LOGK -- log of a constant
#
procedure logk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = log(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = log(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = log(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = log(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = log(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = log(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# LOG10K -- log of a constant
#
procedure log10k(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = log10(real(R_VALS(a)))
	case TY_INT:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = log10(real(R_VALI(a)))
	case TY_LONG:
	    R_TYPE(b) = TY_DOUBLE
	    R_VALD(b) = log10(double(R_VALL(a)))
	case TY_REAL:
	    R_VALR(b) = log10(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = log10(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = log10(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

#
# ABSK -- abs of a constant
#
procedure absk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_VALS(b) = abs(R_VALS(a))
	case TY_INT:
	    R_VALI(b) = abs(R_VALI(a))
	case TY_LONG:
	    R_VALL(b) = abs(R_VALL(a))
	case TY_REAL:
	    R_VALR(b) = abs(R_VALR(a))
	case TY_DOUBLE:
	    R_VALD(b) = abs(R_VALD(a))
	case TY_COMPLEX:
	    R_VALX(b) = abs(double(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }
end

#
# CONJGK -- conjg of a complex constant
#
procedure conjgk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_COMPLEX:
	    R_VALX(b) = conjg(R_VALX(a))
	default:
	    call imc_unkpix("complexk")
    }	
end

#
# AIMAGK -- imaginary part of a complex constant
#
procedure aimagk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_COMPLEX:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = aimag(R_VALX(a))
	default:
	    call imc_unkpix("complexk")
    }	
end

#
# AREALK -- real part of a complex constant
#
procedure arealk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    switch (R_TYPE(a)) {
	case TY_COMPLEX:
	    R_TYPE(b) = TY_REAL
	    R_VALR(b) = real(R_VALX(a))
	default:
	    call imc_unkpix("complexk")
    }	
end

#
# NINTK -- nint of a constant
#
procedure nintk(a, b)

pointer a		# i: input register
pointer b		# o: output register

begin
    R_TYPE(b) = TY_INT
    switch (R_TYPE(a)) {
	case TY_SHORT:
	    R_VALI(b) = nint(real(R_VALS(a)))
	case TY_INT:
	    R_VALI(b) = nint(real(R_VALI(a)))
	case TY_LONG:
	    R_VALI(b) = nint(real(R_VALL(a)))
	case TY_REAL:
	    R_VALI(b) = nint(real(R_VALR(a)))
	case TY_DOUBLE:
	    R_VALI(b) = nint(real(R_VALD(a)))
	case TY_COMPLEX:
	    R_VALI(b) = nint(real(R_VALX(a)))
	default:
	    call imc_unkpix("unopk")
    }	
end

