#$Header: /home/pros/xray/ximages/imcalc/RCS/imacts.x,v 11.0 1997/11/06 16:27:01 prosb Exp $
#$Log: imacts.x,v $
#Revision 11.0  1997/11/06 16:27:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:38  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:32  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  08:30:55  mo
#MC	5/20/93		Allow hhh and pl extensions in output filename
#
#Revision 5.0  92/10/29  21:24:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:37  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:08  pros
#General Release 1.0
#
#
#	IMACTS.X - parser "code fragments", as called from yacc
#

include <error.h>

include "imcalc.h"
include "imcfunc.h"

#
# IMC_LOAD -- Open an image file, and compile instructions to load next
# line of the image into a register
#
procedure imc_load(imname, yyval)

char imname[ARB]		# i: image file name
pointer yyval			# o: parser output value
pointer reg			# l: register
int im				# l: image descriptor
int immap()			# l: open an image
int imc_chkimdim()		# l: check image size
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get an image descriptor
	call imc_imdescr(im)
	# open the image
	iferr( I_IM(im) = immap(imname, READ_ONLY, 0) ){
	    call imc_error("can't open input image file")
	    return
	}
        # check dimensions of this image against previously saved values
	if( imc_chkimdim(I_IM(im)) ==0 )
	    return
	# save the name in the image structure
	call strcpy(imname, I_NAME(im), SZ_FNAME)
	# set the image vector
	call amovkl(long(1), I_V(im), IM_MAXDIM)
	# add 1 image to image count
	c_imageno = c_imageno + 1
	# get a register
	call imc_register(reg)
	# register is same type as image
	R_TYPE(reg) = IM_PIXTYPE(I_IM(im))
	# and so is the length
	R_LENGTH(reg) = IM_LEN(I_IM(im),1)
	# compile the load instruction
	call imc_compile2(OP_LOAD, im, reg)
	# compile branch on eof (to end of machine)
	call imc_compile1(OP_BEOF, MAX_INSTRUCTIONS+1)
	# return the register
	O_REGISTER(yyval) = reg
end

#
# IMC_STORE -- store a line in the output buffer
#
procedure imc_store(imname, expr, yyval)

char imname[ARB]		# i: image file name
pointer expr			# i: expression as input
pointer yyval			# o: expression as a result
int i				# l: loop counter
int im				# l: image descriptor
int flag			# l: immap flags
int mode			# l: open mode
int junk			# l: return from fnextn
char section[SZ_FNAME]		# l: section name
char imn[SZ_FNAME]		# l: file name to open
char extn[SZ_FNAME]		# l: file extension
int immap()			# l: open an image
int imaccess()			# l: check for image existence
int fnextn()			# l: get extension
bool strne()			# l: string compare
bool streq()			# l: string compare
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	call imc_imdescr(im)
	# at this point, there had better be some indication of
	# the size of the output image
	if( c_ndim ==0 ){
	    call imc_error("must have an image size described on rhs")
	    return
	}
	# add the ".imh" extension if necessary
	junk = fnextn (imname, extn, SZ_FNAME)
	if( streq(extn, "") )
#	    call strcat(".imh", imname, SZ_FNAME)
	    call strcpy("imh", extn, SZ_FNAME)
	if( strne(extn, "imh") && strne(extn, "hhh") && strne(extn, "pl")){
	    call imc_error("output image must be of type '.imh', '.hhh', or '.pl' ")
	    return
	}

	# see if this is a section
	call imgsection (imname, section, SZ_FNAME)
	if (section[1] != EOS) {
	    c_section = YES
	    mode = READ_WRITE
	    flag = 0
  	    call strcpy(imname, imn, SZ_FNAME)
	}
	else{
	    c_section = NO
	    mode = NEW_COPY
	    flag = c_imhandle
	    # check for image already existing
	    if (imaccess(imname, 0) == YES) {
		if( c_delete ){
		    # make a temp file name
		    call mktemp("imcalc", c_imtemp, SZ_FNAME)
		    # this becomes the temp file name
		    call strcpy(c_imtemp, imn, SZ_FNAME)
		    # add ".imh" or other(.pl, .hhh)  extension
#		    call strcat (".imh", imn, SZ_FNAME)
		    call strcat (".", imn, SZ_FNAME)
		    call strcat (extn, imn, SZ_FNAME)
		    # and save the real file name for renaming
		    call strcpy(imname, c_imname, SZ_FNAME)
		}
		else{
		    call imc_error("output image already exists")
		    return
		}
	    }
	    else{
		call strcpy(imname, imn, SZ_FNAME)
            }
	}
	# map the output image
	iferr( 	I_IM(im) = immap(imn, mode, flag) ){
	    call imc_error("can't open output image file")
	    return
	}
	# fill in the dimensions and type of the image
	# based on our examination of input images
	if( mode == NEW_IMAGE ){
	    IM_NDIM(I_IM(im)) = c_ndim
	    for(i=1; i<=c_ndim; i=i+1)
	        IM_LEN(I_IM(im), i) = c_len[i]
	    # fill in the type with default
	    IM_PIXTYPE(I_IM(im)) = 0
	}
	# set the image vector
	call amovkl(long(1), I_V(im), IM_MAXDIM)
	# write the history record
	call imc_wrhist(I_IM(im))
	# add 1 image to image count
	c_imageno = c_imageno + 1
	# compile the store instruction
	call imc_compile2(OP_STORE, expr, im)
	# return the register
	O_REGISTER(yyval) = expr
end

#
# IMC_BINOP -- Perform a binary operation on two operands
# IMC_BOOLOP -- Perform a boolean operation on two operands
# IMC_LOGICOP -- Perform a logical operation on two operands
#
procedure imc_binop (operation, a, b, yyval)

int operation			# i: i.e., '+', '-', etc.
pointer	a, b			# i: res = a op b
pointer yyval			# o: expression as a result
int silonly			# l: flag that operation is boolean
int makeintv			# l: flag that we allocate a new int  buf
pointer a_op, b_op		# l: data type coerces registers
pointer x_op			# l: swap register
pointer res			# l: result register
include "imcalc.com"

begin
# entry imc_binop (operation, a, b, yyval)
	silonly = NO
	makeintv = NO
	goto 99

entry imc_boolop (operation, a, b, yyval)
	silonly = YES
	makeintv = NO
	goto 99

entry imc_logicop (operation, a, b, yyval)
	silonly = NO
	makeintv = YES
	goto 99

	# if we had an error earlier, just return
99	if( c_error != 0 ) return

	# get a register
	call imc_register(res)

	# if both operand are constants, do the operation and return
	if( (R_LENGTH(a) ==0) && (R_LENGTH(b) ==0) ){
		call imc_binopk(operation, a, b, res)
		# return the register
		O_REGISTER(yyval) = res
		return
	}

	# set data type of output to higher of two inputs
	R_TYPE(res) = max(R_TYPE(a), R_TYPE(b))

	# the boolean operation are only for sil types
	if( silonly == YES )
	    R_TYPE(res) = min(R_TYPE(res), TY_LONG)	

	# coerce the input operands to the same data type
        call imc_coerce(a, a_op, R_TYPE(res))
        call imc_coerce(b, b_op, R_TYPE(res))

	# take max line length, in case one is constant
	R_LENGTH(res) = max(R_LENGTH(a_op), R_LENGTH(b_op))

	# we want the constant to be the second arg, if there is one
	# so swap the registers, if necessary
	if( R_LENGTH(a_op) <= 1 ){
	    # make sure its not a=len(1) and b=len(0)
	    if( R_LENGTH(b_op) !=0 ){
		# check for non-commutative operators
		switch(operation){
		case OP_DIV, OP_SUB, OP_POW, FUNC_MOD, FUNC_ATAN2:
		    call imc_error(
		    "non-commuting ops can't have constant first arg\n")
		    return
		default:
		    x_op = a_op
		    a_op = b_op
		    b_op = x_op
		}
	    }
	}

	# allocate integer space for result register for logical ops
	# we change the type to INT and allocate a new buffer
	if( makeintv == YES ){
	    R_TYPE(res) = TY_INT
	    # allocate a new buffer space
	    call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
	}

	# compile the instruction
	call imc_compile3(operation, a_op, b_op, res)

	# return the register
	O_REGISTER(yyval) = res
end

#
# IMC_UNOP -- perform a unary operation on an image or a const
#
procedure imc_unop (operation, a, yyval)

int operation			# i: i.e., '+', '-', etc.
pointer	a			# i: res = op a
pointer yyval			# o: expression as a result
pointer a_op			# l: data type coerced register
pointer res			# l: result register
int resscalar			# l: result is a scalar
include "imcalc.com"

begin

# entry imc_unop (operation, a, yyval)
	resscalar = NO
	goto 99

entry imc_projop (operation, a, yyval)
	resscalar = YES
	goto 99

99
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get a register
	call imc_register(res)

	# if operand is a constant, do the operation and return
	if( R_LENGTH(a) ==0){
		call imc_unopk(operation, a, res)
		# return the register
		O_REGISTER(yyval) = res
		return
	}

	# set type of output
	# for OP_BNOT, we only have sil
	if( operation == OP_BNOT )
		R_TYPE(res) = min(R_TYPE(a), TY_LONG)
	else
		R_TYPE(res) = R_TYPE(a)

	# set length of output
	if( resscalar == NO )
	    R_LENGTH(res) = R_LENGTH(a)
	# for scalars, allocate 1-d line
	else{
	    R_LENGTH(res) = 1
	    # allocate a new buffer space
	    call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
	}

	# coerce the type, if necessary
        call imc_coerce(a, a_op, R_TYPE(res))

	# allocate space for result register for logical ops
	# we change the type to INT here as well, as vops return int
	if( operation == OP_LNOT ){
	    R_TYPE(res) = TY_INT
	    # allocate a new buffer space
	    call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))
	}

	# compile the instruction
	call imc_compile2(operation, a_op, res)

	# return the register on the parser stack
	O_REGISTER(yyval) = res
end

#
# IMC_INT -- put a constant int into a register
#
procedure imc_int(i, yyval)

int i				# i: input int constant
pointer yyval			# o: output register
pointer res			# l: constant register
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get a register
	call imc_register(res)
	# set values on constant register
	R_LENGTH(res) = 0
	R_TYPE(res) = TY_INT
	R_VALI(res) = i
	# return the register
	O_REGISTER(yyval) = res
end

#
# IMC_FLOAT -- put a constant float into a register
#
procedure imc_float(f, yyval)

real f				# i: input float constant
pointer yyval			# o: output register
pointer res			# l: constant register
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get a register
	call imc_register(res)
	# set values on constant register
	R_LENGTH(res) = 0
	R_TYPE(res) = TY_REAL
	R_VALR(res) = f
	# return the register
	O_REGISTER(yyval) = res
end

#
# IMC_QUEST -- compile "? :" type of expression
#
procedure imc_quest (sel, a, b, yyval)

pointer sel			# i: selection register
pointer	a, b			# i: res = sel ? a : b
pointer yyval			# o: expression as a result
pointer a_op, b_op		# l: data type coerces registers
pointer res			# l: result register
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get a register
	call imc_register(res)

	# set data type of output of higher of two inputs
	R_TYPE(res) = max(R_TYPE(a), R_TYPE(b))

	# coerce the input operands to the same data type
        call imc_coerce(a, a_op, R_TYPE(res))
        call imc_coerce(b, b_op, R_TYPE(res))

	# take max line length possible, in case of constants
	R_LENGTH(res) = max(R_LENGTH(a_op), R_LENGTH(b_op))
	R_LENGTH(res) = max(R_LENGTH(res), R_LENGTH(sel))

        # allocate a new buffer space
	call salloc(R_LBUF(res), R_LENGTH(res), R_TYPE(res))

	# compile the instruction
	call imc_compile4(OP_SELECT, a_op, b_op, res, sel)

	# return the register on the parser stack
	O_REGISTER(yyval) = res
end

#
#  IMC_PRINT -- print values
#
procedure imc_print (a, yyval)

pointer	a			# i: line or const to print
pointer yyval			# o: expression as a result
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# compile the instruction
	call imc_compile1(OP_PRINT, a)

	# return the register on the parser stack
	O_REGISTER(yyval) = a
end

#
# IMC_STARTARGLIST -- start an argument list for a function
#
procedure imc_startarglist(a, yyval)

pointer a			# i: expression
pointer yyval			# o: parser output value
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get a new call frame
	c_callno = c_callno + 1
	if( c_callno > MAX_CALLS ){
	    call imc_error("too many function calls")
	    return
	}
	# add argument to call frame
	if( a != NULL ){
	    c_nargs[c_callno] = 1
	    c_arg[1, c_callno] = a
	}
	else
	    c_nargs[c_callno] = 0
	# return the call number
	O_VALI(yyval) = c_callno
end

#
# IMC_ADDARG -- add an argument to an argument list for a function
#
procedure imc_addarg(arglist, a, yyval)

int arglist			# i: arglist to this point
pointer a			# i: expression to add to arglist
pointer yyval			# o: parser output value
int callno			# l: current call frame
int argno			# l: argument number
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get current argument number
	callno = arglist
	argno = c_nargs[callno] + 1
	if( argno > MAX_ARGS ){
	    call imc_error("too many arguments in function")
	    return
	}
	c_arg[argno, callno] = a
	c_nargs[c_callno] = argno
	O_VALI(yyval) = callno
end

#
# IMC_CMD --  execute an external command
#
procedure imc_cmd(str)

char str[ARB]			# command string
bool streq()			# string compare

include "imcalc.com"

begin
	# check for null string
	if( streq(str, "") ){
	    return
	}
	# just execute it
	if( c_debug >= 5 ){
	    call printf("cmd: %s\n")
	    call pargstr(str)
	}
	iferr( call clcmd(str) )
		call imc_errors("error executing cl command", str)
end

#
# IMC_CALL -- call a function of the form res = func ( expr )
#
procedure imc_call (name, callno, yyval)

char name[ARB]			# i: function name
int callno			# l: current call frame
pointer yyval			# o: expression as a result
int argno			# l: number of arguments
int class			# l: class of function (1 arg, mult args, etc.)
int func			# l: function number from lookup
int i				# l: loop counter
pointer buf			# l: result pointer in multi arg funcs
pointer reg			# l: register pointer
int func_lookup()		# l: lookup function
include "imcalc.com"

begin
	# if we had an error earlier, just return
	if( c_error != 0 ) return

	# get number of arguments
	argno = c_nargs[callno]

	# lookup the function
	func = func_lookup(name)
	if( func == 0 ){
	    call imc_errors("undefined function", name)
	    return
	}

	# get class of function
	class = func / 100
	# compile the function
	switch(class){
	# functions taking a single argument
	case FUNC_1:
	    if( argno != 1 ){
		call imc_errors("too many args for function", name)
		return
            }
	    else{
		# compile a 1 op inst
	        call imc_unop(func, c_arg[1, callno], yyval)
	    }
	case FUNC_2:
	    if( argno != 2 ){
		call imc_errors("wrong number of args for function", name)
		return
            }
	    else{
		# compile a 2 op inst
	        call imc_binop(func, c_arg[1, callno], c_arg[2, callno], yyval)
	    }
	case FUNC_1_2:
	    # compile either a 1 op inst or a 2 op inst
	    if( argno == 1 )
		call imc_unop(func+1, c_arg[1, callno], yyval)
	    else{
		if( argno != 2 ){
		    call imc_errors("too many args for function", name)
		    return
		}
		else{
		    call imc_binop(func+2, c_arg[1, callno],
					   c_arg[2, callno], yyval)
		}
	    }
	case FUNC_CHT:
	    # change the type of an operand and set output type, if necessary
	    call imc_func_cht(func, c_arg[1, callno], O_REGISTER(yyval))
	case FUNC_N:
	    call salloc(buf, LEN_REGISTER, TY_STRUCT)
	    switch(func){
	    case FUNC_MIN, FUNC_MAX:
		if( argno < 2 ){
		    call imc_error("min and max require at least two args")
		    return
		}
		# compile a series of identical operations with diff args
	  	for(i=1; i<argno; i=i+1){
		    # the first arg is either arg1 or previous results
		    if( i == 1 )
			call amovi(c_arg[1, callno], Memi[buf], LEN_REGISTER)
		    else
			call amovi(O_REGISTER(yyval), Memi[buf], LEN_REGISTER)
		    # compile next instruction
		    call imc_binop(func, Memi[buf], c_arg[i+1, callno], yyval)
		}
	    }
	case FUNC_CMPLX:
	    if( argno != 1 ){
		call imc_errors("too many args for function", name)
		return
            }
	    else{
		if( R_TYPE(c_arg[1, callno]) != TY_COMPLEX ){
		    call imc_error("function requires complex arg", name)
		    return
		}
		# compile a 1 op inst
	        call imc_unop(func, c_arg[1, callno], yyval)
	    }
	case PROJ_N:
	    if( argno == 1 ){
	        call imc_projop(func, c_arg[1, callno], yyval)
	    }
	    else{
		call imc_error("multi-arg projections are not implemented")
	    }
	case PROJ_CONST:
	    # get a register
	    call imc_register(reg)
	    switch(func){
	    case PROJ_LEN:
		# set type to INT
		R_TYPE(reg) = TY_INT
		# set length to 1
		R_LENGTH(reg) = 1
		# allocate a 1-D buffer space
		call salloc(R_LBUF(reg), R_LENGTH(reg), R_TYPE(reg))
		# allocate a buffer for eventual results
		call salloc(buf, argno, TY_INT)
		# get the length of each arg
	  	for(i=1; i<=argno; i=i+1){
	            call xlen(c_arg[i, callno], reg)
		    Memi[buf+i-1] = Memi[R_LBUF(reg)]
		}
		# return this buffer as data
		R_LBUF(reg) = buf
		R_LENGTH(reg) = argno
		R_TYPE(reg) = TY_INT		
		O_REGISTER(yyval) = reg
	    }
	default:	
	    call imc_error("illegal class for function", name)
	}
end

#
#    imc_wrhist -- write a history line to imcalc
#
procedure imc_wrhist(im)

pointer	im				# image handle
int	index				# index into hist string
int	len				# input string length
pointer	cbuf				# command buffer
pointer	hbuf				# history buf
pointer	sp				# stack pointer
int	strldx()			# look for char
int	strlen()			# string length
int	imaccf()			# image param existence
include "lex.com"

begin
	# mark the stack
	call smark(sp)
	# get length of current line buffer
	len = strlen(lbuf)+SZ_LINE
	# allocate buffer to hold history
	call salloc(cbuf, len, TY_CHAR)
	call salloc(hbuf, len, TY_CHAR)
	# copy the entire line buffer to the command buffer
	call strcpy(lbuf, Memc[cbuf], len)
	# null out what comes after this command
	# the lptr actually pointes 1 past the char we want to null out
	# and it starts at 1, not 0
	if( lptr !=0 )
	    Memc[cbuf+lptr-2] = 0
	# but add a <CR>
	call strcat("\n", Memc[cbuf], len)
	# look for a previous command, ending in a ";"
	index = strldx(";", Memc[cbuf])
	# skip leading spaces
	while( Memc[cbuf+index] == ' ' )
	    index = index+1
	# make up the final history
	call strcpy("imcalc: ", Memc[hbuf], len)
	call strcat(Memc[cbuf+index], Memc[hbuf], len)
	# put to iraf history
        if( imaccf(im, "history") == NO )
            call imaddf(im, "history", "c")
	call imastr(im, "history", Memc[hbuf])
	# free the stack
	call sfree(sp)
end
