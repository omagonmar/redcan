#$Header: /home/pros/xray/ximages/imcalc/RCS/imacts1.x,v 11.0 1997/11/06 16:27:02 prosb Exp $
#$Log: imacts1.x,v $
#Revision 11.0  1997/11/06 16:27:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:33:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:43:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:23:47  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:05:36  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:24:25  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:27:42  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:16:43  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:31:14  pros
#General Release 1.0
#
#
#	IMACTS1.X - support for parser "code fragments", as called from yacc
#

include <error.h>
include <imhdr.h>
include <time.h>

include "imcalc.h"
include "imcfunc.h"

#
# IMC_COERCE - coerce a register to a data type
#
procedure imc_coerce(in, out, type)

pointer in			# i: input register
pointer out			# o: ouput register
int type			# i: data type
include "imcalc.com"

begin
	# coerce if necessary
	if( R_TYPE(in) != type ){
	    # change constants in place
	    if( R_LENGTH(in) == 0 ){
		out = in
		call xchtk(out, type)
	    }
	    else{
		call imc_register(out)
		# set type of new register
		R_TYPE(out) = type
		# and length
		R_LENGTH(out) = R_LENGTH(in)
		# allocate a new buffer space
		call salloc(R_LBUF(out), R_LENGTH(out), R_TYPE(out))
		# compile the convert instruction
		call imc_compile2(OP_CHT, in, out)
	    }
	}
	else
	    # out is the same as in
	    out = in
end

#
# IMC_FUNC_CHT -- compile a change type function call
#
procedure  imc_func_cht(func, in, out)

int func			# i: function code
pointer in			# i: input register
pointer out			# o: output register
int type			# l: new type
include "imcalc.com"

begin
    switch(func){
    case FUNC_SHORT:
	type = TY_SHORT
    case FUNC_INT:
	type = TY_INT
    case FUNC_LONG:
	type = TY_LONG
    case FUNC_REAL:
	type = TY_REAL
    case FUNC_DOUBLE:
	type = TY_DOUBLE
    case FUNC_COMPLEX:
	type = TY_COMPLEX
    }
    # compile the change type instruction
    call imc_coerce(in, out, type)
    # change type of output image, if necessary
    c_pixtype = max(c_pixtype, type)
end

#
#  IMC_CHKIMSIZE -- check size of image vs. last stored image
#
int procedure imc_chkimdim(im)

pointer im			# i: current image descriptor
int i				# l: loop counter
int vector			# l: flag which image is a vector
int mindim			# l: min dim of the two images
include "imcalc.com"

begin
	# first time through, just copy info into common
	if( c_ndim ==0 ){
	    c_pixtype = IM_PIXTYPE(im)
	    c_ndim = IM_NDIM(im)
	    for(i=1; i<=c_ndim; i=i+1){
		c_len[i] = IM_LEN(im,i)
	    }
	    # save the first image handle
	    c_imhandle = im
	}
	# check the lengths of the two images
	else{
	    vector = 0
	    mindim = min(c_ndim, IM_NDIM(im))
	    # loop through the dimensions, checking for consistency
	    # number of pixels in each dimension must be same or else
	    # one of them must be of len 1
	    for(i=1; i<=mindim; i=i+1){
	        if( c_len[i] != IM_LEN(im, i) ){
	    	    switch(vector){
	    	    # set flag for which is a vector
	    	    case 0:
	    	        # see if one of the dims is 1
	    	        if( c_len[i] == 1 )
	    	    	    vector = 1
	    	        if( IM_LEN(im, i) == 1 )
	    	    	    vector = 2
	    	        # mismatched lengths
	    	        if( vector == 0 ){
	    	    	    call imc_error("dimensions of images don't match")
	    	    	    return(0)
	    	        }	    	    
	    	    case 1:
	    	        if( c_len[i] != 1 ){
	    	    	    call imc_warn("more than 1 vector in expression")
	    	        }	    	    
	    	    case 2:
	    	        if( IM_LEN(im, i) != 1 ){
	    	    	    call imc_warn("more than 1 vector in expression")
	    	        }	    	    

	    	    }
	        }
	    }

	    # make sure the non-vector image has the greater dimension
	    switch(vector){
	    # no vectors - no problem
	    case 0:
	        ;
	    # saved guy is the vector
	    case 1:
	        if( c_ndim > IM_NDIM(im) ){
	    	    call imc_error("vector can't be of greater dim than image")
	    	    return(0)
	        }
	    # new guy is the vector
	    case 2:
	        if( IM_NDIM(im) > c_ndim ){
	    	    call imc_error("vector can't be of greater dim than image")
	    	    return(0)
	        }
	    }

	    # if the current saved guy is a vector, save the other guy
	    if( vector == 1 ){
	        c_pixtype = IM_PIXTYPE(im)
	        c_ndim = IM_NDIM(IM)
	        for(i=1; i<=c_ndim; i=i+1)
	    	    c_len[i] = IM_LEN(IM,i)
	    }
	    # make sure we have the highest pixtype
	    else{
	        c_pixtype = max(c_pixtype, IM_PIXTYPE(im))
	    }
	    # save image handle first time through
	    if( c_imhandle ==0 )
		c_imhandle = im
	    # overwrite saved handle if it was a vector
	    else if( vector ==1 )
		c_imhandle = im
	}
	return(1)
end

#
# IMC_WARN -- print out an warn message, don't set c_error to YES
#
procedure imc_warn(emsg)

char emsg[ARB]			# i: warn message
#char ebuf[SZ_FNAME]		# l: formatted warn message
include "imcalc.com"

begin
#	call strcpy("IMCALC WARNING -", ebuf, SZ_FNAME)
#	call strcat(emsg, ebuf, SZ_FNAME)
#	call error(1, ebuf)
	call eprintf("IMCALC WARN - %s\n")
	call pargstr(emsg)
end

#
# IMC_ERROR -- print out an error message and set c_error to YES
#
procedure imc_error(emsg)

char emsg[ARB]			# i: error message
#char ebuf[SZ_FNAME]		# l: formatted error message
include "imcalc.com"
include "lex.com"

begin
	# print out error message
	call eprintf("IMCALC ERROR - %s\n")
	call pargstr(emsg)
	# set flag to stop processing this expression
	c_error = YES
	# insure that we do a getline after this syntax error
	lptr = 0
end

#
# IMC_ERRORS - print out an error message and an optional string
#
procedure imc_errors( mess1, mess2)

char mess1[ARB]			# first part of error message
char mess2[ARB]			# second part of error message
char ebuf[SZ_FNAME]		# error buffer
bool strne()			# string compare

begin
    # copy the first error message
    call strcpy(mess1, ebuf, SZ_FNAME)
    # and the second message, if necessary
    if( strne("", mess2) ){
	call strcat(": ", ebuf, SZ_FNAME)
	call strcat(mess2, ebuf, SZ_FNAME)
    }
    # call the error handler
    call imc_error(ebuf)
end

#
# IMC_UNKPIX -- the infamous "unknown pixel data type" error
#
procedure imc_unkpix(msg)

char msg[ARB]			# message

begin
	call imc_errors("unknown pixel data type", msg)
end


#
# FUNC_LOOKUP -- lookup a function name and return function code
#
int procedure func_lookup(name)

char name[ARB]			# i: name to lookup
char cc				# l: first char of name
bool streq()			# l: string compare

begin
	cc = name[1]
	# switch off the first letter, to make lookup faster
	switch(cc){
	case 'a':
	    if( streq(name, "abs") )
		return(FUNC_ABS)
	    else if( streq(name, "acos") )
		return(FUNC_ACOS)
	    else if( streq(name, "aimag") )
		return(FUNC_AIMAG)
	    else if( streq(name, "areal") )
		return(FUNC_AREAL)
	    else if( streq(name, "asin") )
		return(FUNC_ASIN)
	    else if( streq(name, "atan") )
		return(FUNC_ATAN)
	    else if( streq(name, "avg") )
		return(PROJ_AVG)
	    else
		return(0)
	case 'c':
	    if( streq(name, "complex") )
		return(FUNC_COMPLEX)
	    else if( streq(name, "conjg") )
		return(FUNC_CONJG)
	    else if( streq(name, "cos") )
		return(FUNC_COS)
	    else
		return(0)
	case 'd':
	    if( streq(name, "double") )
		return(FUNC_DOUBLE)
	    else
		return(0)
	case 'e':
	    if( streq(name, "exp") )
		return(FUNC_EXP)
	    else
		return(0)
	case 'h':
	    if( streq(name, "high") )
		return(PROJ_HIGH)
	    else
		return(0)
	case 'i':
	    if( streq(name, "int") )
		return(FUNC_INT)
	    else
		return(0)
	case 'l':
	    if( streq(name, "log") )
		return(FUNC_LOG)
	    else if( streq(name, "log10") )
		return(FUNC_LOG10)
	    else if( streq(name, "long") )
		return(FUNC_LONG)
	    else if( streq(name, "low") )
		return(PROJ_LOW)
	    else if( streq(name, "len") )
		return(PROJ_LEN)
	    else
		return(0)
	case 'm':
	    if( streq(name, "min") )
		return(FUNC_MIN)
	    else if( streq(name, "max") )
		return(FUNC_MAX)
	    else if( streq(name, "mod") )
		return(FUNC_MOD)
	    else if( streq(name, "med") )
		return(PROJ_MED)
	    else
		return(0)
	case 'n':
	    if( streq(name, "nint") )
		return(FUNC_NINT)
	    else
		return(0)
	case 'r':
	    if( streq(name, "real") )
		return(FUNC_REAL)
	    else
		return(0)
	case 's':
	    if( streq(name, "short") )
		return(FUNC_SHORT)
	    else if( streq(name, "sin") )
		return(FUNC_SIN)
	    else if( streq(name, "sqrt") )
		return(FUNC_SQRT)
	    else if( streq(name, "sum") )
		return(PROJ_SUM)
	    else
		return(0)
	case 't':
	    if( streq(name, "tan") )
		return(FUNC_TAN)
	    else
		return(0)
	case 'z':
	    if( streq(name, "zero") )
		return(FUNC_ZERO)
	    else
		return(0)
	
	# didn't find name
	default:
	    return(0)	
	}
end

#
# IMC_TIME -- print out time for debugging
#
procedure imc_time(str)

char str[ARB]		# i: string to print out
char timstr[SZ_TIME]	# l: output debug str
long clktime()		# l: get time since 1-1-80
include "imcalc.com"

begin
    if( c_debug >= 1 ){
	call cnvtime(clktime(long(0)), timstr, SZ_TIME)
	call printf("%s:\t%s\n")
	call pargstr(str)
	call pargstr(timstr)
    }
end
	
