#$Header: /home/pros/xray/ximages/imcalc/RCS/imcpu.x,v 11.0 1997/11/06 16:27:39 prosb Exp $
#$Log: imcpu.x,v $
#Revision 11.0  1997/11/06 16:27:39  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:10  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:54  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:28:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:48  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:35  pros
#General Release 1.0
#
#
#	IMCPU.X - routines that deal with the virtual CPU
#

include <error.h>

include "imcalc.h"
include "imcfunc.h"

#
# IMC_IMDESCR -- get next available image descriptor
#
procedure imc_imdescr(im)

pointer im			# o: next image descr
include "imcalc.com"

begin
	if( c_nextimage >= MAX_IMAGES ){
	    call imc_error("too many images")
	    return
	}
	im = I_IMPTR(c_images, c_nextimage)
	c_nextimage = c_nextimage + 1

	if( c_debug >=5 ){
		call printf("imreg=%d\n")
		call pargi(im)
	}
end

#
# IMC_REGISTER -- get next available register
#
procedure imc_register(reg)

pointer reg			# o: next register
include "imcalc.com"

begin
	if( c_nextreg >= MAX_REGISTERS ){
	    call imc_error("too many registers")
	    return
	}
	reg = R_REGPTR(c_registers, c_nextreg)
	c_nextreg = c_nextreg + 1

	if( c_debug >=5 ){
		call printf("reg=%d\n")
		call pargi(reg)
	}
end

#
# IMC_COMPILE0 -- add an instruction with 0 arguments to the meta-code
#
procedure imc_compile0(inst)

int inst				# i: instruction
include "imcalc.com"

begin
	if( c_nextinst >= MAX_INSTRUCTIONS )
	    call imc_error("too many instructions")
	INST(c_nextinst) = inst
	ARG1(c_nextinst) = 0
	c_nextinst = c_nextinst + 1
end

#
# IMC_COMPILE1 -- add an instruction with 1 argument to the meta-code
#
procedure imc_compile1(inst, a)

int inst				# i: instruction
pointer a				# i: arg 1
include "imcalc.com"

begin
	if( c_nextinst >= MAX_INSTRUCTIONS )
	    call imc_error("too many instructions")
	INST(c_nextinst) = inst
	ARG1(c_nextinst) = a
	ARG2(c_nextinst) = 0
	c_nextinst = c_nextinst + 1
end

#
# IMC_COMPILE2 -- add an instruction with 2 arguments to the meta-code
#
procedure imc_compile2(inst, a, b)

int inst				# i: instruction
pointer a				# i: arg 1
pointer b				# i: arg 2
include "imcalc.com"

begin
	if( c_nextinst >= MAX_INSTRUCTIONS )
	    call imc_error("too many instructions")
	INST(c_nextinst) = inst
	ARG1(c_nextinst) = a
	ARG2(c_nextinst) = b
	ARG3(c_nextinst) = 0
	c_nextinst = c_nextinst + 1
end

#
# IMC_COMPILE3 -- add an instruction with 3 arguments to the meta-code
#
procedure imc_compile3(inst, a, b, c)

int inst				# i: instruction
pointer a				# i: arg 1
pointer b				# i: arg 2
pointer c				# i: arg 3
include "imcalc.com"

begin
	if( c_nextinst >= MAX_INSTRUCTIONS )
	    call imc_error("too many instructions")
	INST(c_nextinst) = inst
	ARG1(c_nextinst) = a
	ARG2(c_nextinst) = b
	ARG3(c_nextinst) = c
	ARG4(c_nextinst) = 0
	c_nextinst = c_nextinst + 1
end

#
# IMC_COMPILE4 -- add an instruction with 4 arguments to the meta-code
#
procedure imc_compile4(inst, a, b, c, d)

int inst				# i: instruction
pointer a				# i: arg 1
pointer b				# i: arg 2
pointer c				# i: arg 3
pointer d				# i: arg 4
include "imcalc.com"

begin
	if( c_nextinst >= MAX_INSTRUCTIONS )
	    call imc_error("too many instructions")
	INST(c_nextinst) = inst
	ARG1(c_nextinst) = a
	ARG2(c_nextinst) = b
	ARG3(c_nextinst) = c
	ARG4(c_nextinst) = d
	c_nextinst = c_nextinst + 1
end

#
# IMC_ENDCOMPILE
#
procedure imc_endcompile()

include "imcalc.com"

begin
	if( c_nextinst > 1 ){
	    call imc_compile1(OP_BNEOF, 1)
	}
	call imc_compile0(OP_RTN)
end

#
# IMC_EXECUTE -- execute metacode instructions
#
procedure imc_execute()

int i			# l: loop variable
include "imcalc.com"

begin
	# don't bother for 1 instruction (OP_RTN)
	if( c_nextinst <= 2 )
	    return

	call imc_time("start cpu")

	# display instructions
	if( c_debug !=0 ){
	    call printf("INSTRUCTIONS:\n")
	    for(i=1; i<c_nextinst; i=i+1){
		call printf("%d:\t%d\t%d\t%d\t%d \n")
		call pargi(INST(i))
		call pargi(ARG1(i))
		call pargi(ARG2(i))
		call pargi(ARG3(i))
		call pargi(ARG4(i))
	    }
	    call printf("\n")
	    call flush(STDOUT)
	}

	# start at first instruction
	c_ip = 1
	# execute the machine
	c_lineno = 1

	# execute the machine, one instruction at a time
	while( INST(c_ip) != OP_RTN ){

	    # check for error on previous instruction
	    if( c_error == YES )
		return

	    # reassure the faint at heart
	    if( c_debug >= 5 ){
		call printf("# %d: c_ip=%d, INST=%d\n")
		call pargi(c_lineno)
		call pargi(c_ip)
		call pargi(INST(c_ip))
		call flush(STDOUT)
	    }

	    # execute the instruction
	    switch( INST(c_ip) ){
		case OP_LOAD:
			call xload(ARG1(c_ip), ARG2(c_ip))
		case OP_STORE:
			call xstore(ARG1(c_ip), ARG2(c_ip))
		case OP_BNEOF:
			call xbneof()
		case OP_BEOF:
			call xbeof()
		case OP_SELECT:
			call xsel(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip),
				  ARG4(c_ip))
		case OP_CALL:
			call imc_error("OP_CALL should never be executed")
		case OP_CHT:
			call xcht(ARG1(c_ip), ARG2(c_ip))
		case OP_NEG:
			call xneg(ARG1(c_ip), ARG2(c_ip))
		case OP_ADD:
			call xadd(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_SUB:
			call xsub(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_MUL:
			call xmul(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_DIV:
			call xdiv(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_POW:
			call xpow(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_BNOT:
			call xbnot(ARG1(c_ip), ARG2(c_ip))
		case OP_BAND:
			call xband(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_BXOR:
			call xbxor(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_BOR:
			call xbor(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_LT:
			call xllt(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_GT:
			call xlgt(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_LE:
			call xlle(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_GE:
			call xlge(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_EQ:
			call xleq(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_NE:
			call xlne(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_LNOT:
			call xlnot(ARG1(c_ip), ARG2(c_ip))
		case OP_LAND:
			call xland(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_LOR:
			call xlor(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case OP_PRINT:
			call xprn(ARG1(c_ip))
		# these are the expansion of the OP_CALL instruction
		# functions taking 1 argument
		case FUNC_ABS:
			call xabs(ARG1(c_ip), ARG2(c_ip))
		case FUNC_ACOS:
			call xacos(ARG1(c_ip), ARG2(c_ip))
		case FUNC_AIMAG:
			call xaimag(ARG1(c_ip), ARG2(c_ip))
		case FUNC_AREAL:
			call xareal(ARG1(c_ip), ARG2(c_ip))
		case FUNC_ASIN:
			call xasin(ARG1(c_ip), ARG2(c_ip))
		case FUNC_ATAN1:
			call xatan(ARG1(c_ip), ARG2(c_ip))
		case FUNC_ATAN2:
			call xatn2(ARG1(c_ip), ARG2(c_ip))
		case FUNC_CONJG:
			call xconjg(ARG1(c_ip), ARG2(c_ip))
		case FUNC_COS:
			call xcos(ARG1(c_ip), ARG2(c_ip))
		case FUNC_EXP:
			call xexp(ARG1(c_ip), ARG2(c_ip))
		case FUNC_LOG:
			call xlog(ARG1(c_ip), ARG2(c_ip))
		case FUNC_LOG10:
			call xlog10(ARG1(c_ip), ARG2(c_ip))
		case FUNC_NINT:
			call xnint(ARG1(c_ip), ARG2(c_ip))
		case FUNC_SIN:
			call xsin(ARG1(c_ip), ARG2(c_ip))
		case FUNC_SQRT:
			call xsqrt(ARG1(c_ip), ARG2(c_ip))
		case FUNC_TAN:
			call xtan(ARG1(c_ip), ARG2(c_ip))
		case FUNC_ZERO:
			call xzero(ARG1(c_ip), ARG2(c_ip))
		# functions taking two arguments
		case FUNC_MOD:
			call xmod(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case FUNC_MAX:
			call xmax(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		case FUNC_MIN:
			call xmin(ARG1(c_ip), ARG2(c_ip), ARG3(c_ip))
		# projections
		case PROJ_AVG:
			call xavg(ARG1(c_ip), ARG2(c_ip))
		case PROJ_MED:
			call xmed(ARG1(c_ip), ARG2(c_ip))
		case PROJ_LOW:
			call xlow(ARG1(c_ip), ARG2(c_ip))
		case PROJ_HIGH:
			call xhigh(ARG1(c_ip), ARG2(c_ip))
		case PROJ_SUM:
			call xsum(ARG1(c_ip), ARG2(c_ip))
		default:
			call imc_error("unknown CPU instruction")
	    }
	    c_ip = c_ip + 1
	}

	call imc_time("end cpu")
end

