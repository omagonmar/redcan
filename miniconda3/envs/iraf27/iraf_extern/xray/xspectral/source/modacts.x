#$Header: /home/pros/xray/xspectral/source/RCS/modacts.x,v 11.0 1997/11/06 16:42:45 prosb Exp $
#$Log: modacts.x,v $
#Revision 11.0  1997/11/06 16:42:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:12  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:18  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:02  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:00  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:01  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:27  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:32  prosb
#General Release 1.1
#
#Revision 2.1  91/05/24  11:40:08  pros
#jso/eric - changed to allow for fixed linked parameters
#
#Revision 2.0  91/03/06  23:05:08  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  MODACTS.X - parser "code fragments", as called from yacc
#

include <error.h>
include <ctype.h>

include "modparse.h"

#
# MOD_SETUP_MODEL -- package up model args
#
procedure mod_setup_model(a, b, yyval)

pointer a			# i: model frame
pointer	b			# i: argument frame 
pointer	yyval			# o: parser output value

int	frame			# i: call frame number
int	nargs			# l: number of args in model
int	skip			# l: flag we skipped arg1 of model 1
real	lower[MAX_ARGS]		# l: lower bound on parameter
real	upper[MAX_ARGS]		# l: upper bound on parameter
int	fixed[MAX_ARGS]		# l: fixed/free flag
int	links[MAX_ARGS]		# l: links to arguments in other models
int	emission_val()		# l: get value for emission type
pointer model			# l: output model register

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# get argument frame
	frame = O_VALI(b)

	# retrieve the args for this frame
	call mod_getargs(frame, lower, upper, fixed, links, nargs)
	# if we had an error, return
	if( mod_eflag == YES ) return

	# check args against allowed min and max
	call mod_chkargs(a, nargs, mod_nmodels, skip)
	# if we had an error, return
	if( mod_eflag == YES ) return

	# allocate a new record for this model
	# this is a permanent struct that goes into the output fp
	call calloc(model, LEN_MODEL, TY_STRUCT)
	mod_nmodels = mod_nmodels + 1
	FP_MODEL_COUNT(mod_fp) = mod_nmodels
	FP_MODELSTACK(mod_fp,mod_nmodels) = model
	MODEL_NUMBER(model) = mod_nmodels
	MODEL_TYPE(model) = emission_val( Memc[O_NAME(a)] )
	# create the component spectra
	call calloc(MODEL_EMITTED(model), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(MODEL_INTRINS(model), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(MODEL_REDSHIFTED(model), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(MODEL_INCIDENT(model), SPECTRAL_BINS, TY_DOUBLE)
	# fill in the arguments that we know now
	# we will apply absorption at a later time
	if( skip ==0 ){
	    if( fixed[1] == FREE_PARAM ){
		MODEL_PAR_VAL(model,MODEL_ALPHA) = (lower[1]+upper[1])/2
		MODEL_PAR_DLT(model,MODEL_ALPHA) = (upper[1]-lower[1])/2
	    }
	    else{
		MODEL_PAR_VAL(model,MODEL_ALPHA) = lower[1]
		MODEL_PAR_DLT(model,MODEL_ALPHA) = upper[1]
	    }
	    MODEL_PAR_FIXED(model,MODEL_ALPHA) = fixed[1]
	    MODEL_PAR_LINK(model,MODEL_ALPHA) = links[1]
	}
	# if we skipped the arg, make it a calculated parameter
	else{
	    MODEL_PAR_VAL(model,MODEL_ALPHA) = 1.0
	    MODEL_PAR_DLT(model,MODEL_ALPHA) = 0.0
	    MODEL_PAR_FIXED(model,MODEL_ALPHA) = CALC_PARAM
	    MODEL_PAR_LINK(model,MODEL_ALPHA) = 0
	}
	if( fixed[2-skip] == FREE_PARAM ){
	    MODEL_PAR_VAL(model,MODEL_TEMP) = (lower[2-skip]+upper[2-skip])/2
	    MODEL_PAR_DLT(model,MODEL_TEMP) = (upper[2-skip]-lower[2-skip])/2
	}
	else{
	    MODEL_PAR_VAL(model,MODEL_TEMP) = lower[2-skip]
	    MODEL_PAR_DLT(model,MODEL_TEMP) = upper[2-skip]
	}
	MODEL_PAR_FIXED(model,MODEL_TEMP) = fixed[2-skip]
	MODEL_PAR_LINK(model,MODEL_TEMP) = links[2-skip]
	if( O_CODE(a) == RAYMOND ){
	    # make sure the user didn't try to make raymond stuff free!
	    if( fixed[3-skip] == FREE_PARAM )
		call error(1, "raymond abundance cannot be a free param")
	    if( fixed[4-skip] == FREE_PARAM )
		call error(1, "raymond percentage cannot be a free param")
	    MODEL_ABUNDANCE(model) = lower[3-skip]
	    MODEL_PERCENTAGE(model) = lower[4-skip]
	    call mod_chk_percent(MODEL_PERCENTAGE(model))
	}
	# get width for single line
	if( O_CODE(a) == SINGLE_LINE ){
	    if( fixed[3-skip] == FREE_PARAM ){
		MODEL_PAR_VAL(model,MODEL_WIDTH) = (lower[3-skip]+upper[3-skip])/2
		MODEL_PAR_DLT(model,MODEL_WIDTH) = (upper[3-skip]-lower[3-skip])/2
	    }
	    else{
		MODEL_PAR_VAL(model,MODEL_WIDTH) = lower[3-skip]
		MODEL_PAR_DLT(model,MODEL_WIDTH) = upper[3-skip]
	    }
	    MODEL_PAR_FIXED(model,MODEL_WIDTH) = fixed[3-skip]
	    MODEL_PAR_LINK(model,MODEL_WIDTH) = links[3-skip]
	}

	# return the model on the parser stack
	O_MODEL(yyval) = model
end

#
# MOD_SETUP_ABSORPTION -- package up absorption args
#
procedure mod_setup_absorption(a, b, yyval)

pointer a			# i: model frame
pointer	b			# i: argument frame 
pointer	yyval			# o: parser output value

int	frame			# i: call frame number
int	nargs			# l: number of args in model
int	skip			# l: dummy for mod_chkargs
real	lower[MAX_ARGS]		# l: lower bound on parameters
real	upper[MAX_ARGS]		# l: upper bound on parameters
int	fixed[MAX_ARGS]		# l: fixed/free flag
int	links[MAX_ARGS]		# l: links to arguments in other models
pointer abs			# l: output absorption register

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# get argument frame
	frame = O_VALI(b)

	# retrieve the args for this frame
	call mod_getargs(frame, lower, upper, fixed, links, nargs)
	# if we had an error, return
	if( mod_eflag == YES ) return

	# now args against allowed min and max
	call mod_chkargs(a, nargs, 1, skip)
	# if we had an error, return
	if( mod_eflag == YES ) return

	# allocate a new record for this absorption
	# this is a temp struct which will be applied to models
	call salloc(abs, LEN_MODEL, TY_STRUCT)
	# clear the struct
	call aclri(Memi[abs], LEN_MODEL)

 	# use can specify 1 arg (galactic), 2 args (intrinsic, redshift) or
	# 3 args (galactic, intrinsic, redshift)
	switch(nargs){
	case 1:
	    if( fixed[1] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_GALACTIC) = (lower[1]+upper[1])/2
		MODEL_PAR_DLT(abs,MODEL_GALACTIC) = (upper[1]-lower[1])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_GALACTIC) = lower[1]
		MODEL_PAR_DLT(abs,MODEL_GALACTIC) = upper[1]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_GALACTIC) = fixed[1]
	    MODEL_PAR_LINK(abs,MODEL_GALACTIC) = links[1]
	case 2:
	    if( fixed[1] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_INTRINSIC)  = (lower[1]+upper[1])/2
		MODEL_PAR_DLT(abs,MODEL_INTRINSIC)  = (upper[1]-lower[1])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_INTRINSIC)  = lower[1]
		MODEL_PAR_DLT(abs,MODEL_INTRINSIC)  = upper[1]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_INTRINSIC)  = fixed[1]
	    MODEL_PAR_LINK(abs,MODEL_INTRINSIC)  = links[1]

	    if( fixed[2] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_REDSHIFT)  = (lower[2]+upper[2])/2
		MODEL_PAR_DLT(abs,MODEL_REDSHIFT)  = (upper[2]-lower[2])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_REDSHIFT)  = lower[2]
		MODEL_PAR_DLT(abs,MODEL_REDSHIFT)  = upper[2]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_REDSHIFT)  = fixed[2]
	    MODEL_PAR_LINK(abs,MODEL_REDSHIFT)  = links[2]
	case 3:
	    if( fixed[1] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_GALACTIC) = (lower[1]+upper[1])/2
		MODEL_PAR_DLT(abs,MODEL_GALACTIC) = (upper[1]-lower[1])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_GALACTIC) = lower[1]
		MODEL_PAR_DLT(abs,MODEL_GALACTIC) = upper[1]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_GALACTIC) = fixed[1]
	    MODEL_PAR_LINK(abs,MODEL_GALACTIC) = links[1]

	    if( fixed[2] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_INTRINSIC)  = (lower[2]+upper[2])/2
		MODEL_PAR_DLT(abs,MODEL_INTRINSIC)  = (upper[2]-lower[2])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_INTRINSIC)  = lower[2]
		MODEL_PAR_DLT(abs,MODEL_INTRINSIC)  = upper[2]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_INTRINSIC)  = fixed[2]
	    MODEL_PAR_LINK(abs,MODEL_INTRINSIC)  = links[2]

	    if( fixed[3] == FREE_PARAM ){
		MODEL_PAR_VAL(abs,MODEL_REDSHIFT)  = (lower[3]+upper[3])/2
		MODEL_PAR_DLT(abs,MODEL_REDSHIFT)  = (upper[3]-lower[3])/2
	    }
	    else{
		MODEL_PAR_VAL(abs,MODEL_REDSHIFT)  = lower[3]
		MODEL_PAR_DLT(abs,MODEL_REDSHIFT)  = upper[3]
	    }
	    MODEL_PAR_FIXED(abs,MODEL_REDSHIFT)  = fixed[3]
	    MODEL_PAR_LINK(abs,MODEL_REDSHIFT)  = links[3]
	}	

	# return the absorption on the parser stack
	O_MODEL(yyval) = abs
end

#
#  MOD_APPLY_ABSORPTION -- apply absorption to a list of models
#
procedure mod_apply_absorption(a, b, yyval)

pointer a			# i: absorption frame
pointer b			# i: list frame
pointer yyval			# o: parser output value
pointer	list			# l: list
int	nmodels			# l: number of elements in list
int	i			# l: loop counter
pointer abs			# l: absorption struct
pointer	model			# l: model struct
int	mod_abs_link()		# l: determine the link value

include "modparse.com"

begin
	# get the absorption structure
	abs = O_ABSORPTION(a)
	# get list pointer
	list = O_LIST(b)
	# get length of list
	nmodels = Memi[list]
	# loop over all of the models, adding the absorption to the struct
	do i=1, nmodels{
	    model = Memi[list+i]
	    if(MODEL_PAR_VAL(abs,MODEL_INTRINSIC) != 0.0){
	    call mod_twoabs(MODEL_PAR_VAL(model,MODEL_INTRINSIC), "intrinsic")
	    MODEL_PAR_VAL(model,MODEL_INTRINSIC) =
		MODEL_PAR_VAL(abs,MODEL_INTRINSIC)
	    MODEL_PAR_DLT(model,MODEL_INTRINSIC) =
		MODEL_PAR_DLT(abs,MODEL_INTRINSIC)
	    MODEL_PAR_FIXED(model,MODEL_INTRINSIC) =
		MODEL_PAR_FIXED(abs,MODEL_INTRINSIC)
	    # it's only an implicit link if there's more > 1 model applied to
	    if((nmodels >1) || (MODEL_PAR_LINK(abs,MODEL_INTRINSIC)!=0))
		MODEL_PAR_LINK(model,MODEL_INTRINSIC) =
		mod_abs_link(MODEL_PAR_LINK(abs,MODEL_INTRINSIC),
			     MODEL_PAR_FIXED(abs,MODEL_INTRINSIC), i)
	    else
		MODEL_PAR_LINK(model,MODEL_INTRINSIC) = 0
	    }
	    else{
		if(MODEL_PAR_LINK(abs,MODEL_INTRINSIC)<0)
		    MODEL_PAR_LINK(model,MODEL_INTRINSIC) =
			MODEL_PAR_LINK(abs,MODEL_INTRINSIC)
	    }

	    if(MODEL_PAR_VAL(abs,MODEL_GALACTIC) != 0.0){
	    call mod_twoabs(MODEL_PAR_VAL(model,MODEL_GALACTIC), "galactic")
	    MODEL_PAR_VAL(model,MODEL_GALACTIC)  =
		MODEL_PAR_VAL(abs,MODEL_GALACTIC) 
	    MODEL_PAR_DLT(model,MODEL_GALACTIC)  =
		MODEL_PAR_DLT(abs,MODEL_GALACTIC) 
	    MODEL_PAR_FIXED(model,MODEL_GALACTIC) =
		MODEL_PAR_FIXED(abs,MODEL_GALACTIC) 
	    # it's only an implicit link if there's more > 1 model applied to
	    if((nmodels >1) || (MODEL_PAR_LINK(abs,MODEL_GALACTIC)!=0))
		MODEL_PAR_LINK(model,MODEL_GALACTIC)  =
		mod_abs_link(MODEL_PAR_LINK(abs,MODEL_GALACTIC),
			     MODEL_PAR_FIXED(abs,MODEL_GALACTIC), i)
	    else
		MODEL_PAR_LINK(model,MODEL_GALACTIC) = 0
	    }
	    else{
		if(MODEL_PAR_LINK(abs,MODEL_GALACTIC)<0)
		    MODEL_PAR_LINK(model,MODEL_GALACTIC) =
			MODEL_PAR_LINK(abs,MODEL_GALACTIC)
	    }

	    if(MODEL_PAR_VAL(abs,MODEL_REDSHIFT) != 0.0){
	    call mod_twoabs(MODEL_PAR_VAL(model,MODEL_REDSHIFT), "redshift")
	    MODEL_PAR_VAL(model,MODEL_REDSHIFT)  =
		MODEL_PAR_VAL(abs,MODEL_REDSHIFT) 
	    MODEL_PAR_DLT(model,MODEL_REDSHIFT)  =
		MODEL_PAR_DLT(abs,MODEL_REDSHIFT) 
	    MODEL_PAR_FIXED(model,MODEL_REDSHIFT)  =
		MODEL_PAR_FIXED(abs,MODEL_REDSHIFT) 
	    # it's only an implicit link if there's more > 1 model applied to
	    if((nmodels >1) || (MODEL_PAR_LINK(abs,MODEL_GALACTIC)!=0))
		MODEL_PAR_LINK(model,MODEL_REDSHIFT)  =
		mod_abs_link(MODEL_PAR_LINK(abs,MODEL_REDSHIFT),
			     MODEL_PAR_FIXED(abs,MODEL_REDSHIFT), i)
	    else
		MODEL_PAR_LINK(model,MODEL_REDSHIFT) = 0
	    }
	    else{
		if(MODEL_PAR_LINK(abs,MODEL_REDSHIFT)<0)
		    MODEL_PAR_LINK(model,MODEL_REDSHIFT) =
			MODEL_PAR_LINK(abs,MODEL_REDSHIFT)
	    }
	}

	# return the updated list
	O_LIST(yyval) = list
end

#
# MOD_SETUP_LIST -- start a list of models
#
procedure mod_setup_list(a, yyval)

pointer a			# i: model frame
pointer yyval			# o: parser output value
pointer	list			# l: list buffer pointer

include "modparse.com"

begin
	# allocate a buffer for the list
	call salloc(list, MAX_MODELS+1, TY_POINTER)
	# the first element is the number of pointers in the list
	Memi[list] = 1
	# put the address of the model struct into the list
	Memi[list+1] = O_MODEL(a)	
	# return the list on the parser stack
	O_LIST(yyval) = list
end

#
# MOD_MERGE_LISTS -- merge two model lists
#
procedure mod_merge_lists(a, b, yyval)

pointer a			# i: list 1 frame
pointer b			# i: list 2 frame
pointer yyval			# o: parser output value
pointer	lista			# l: list 1
pointer	listb			# l: list 2
int	nmodelsa		# l: number of elements in list a
int	nmodelsb		# l: number of elements in list b

begin
	# get list pointers
	lista = O_LIST(a)
	listb = O_LIST(b)
	# get length of each list
	nmodelsa = Memi[lista]
	nmodelsb = Memi[listb]
	# make sure we don't have too many models
	if( (nmodelsa+nmodelsb) > MAX_MODELS ){
	    call mod_error("too many models")
	    return
	}
	# append list b to list a
	call amovi(Memi[listb+nmodelsb], Memi[lista+nmodelsa+1], nmodelsb)
	# update the number of elements in lista
	Memi[lista] = nmodelsa + nmodelsb
	# return the updated list
	O_LIST(yyval) = lista
end

#
# MOD_STARTARGLIST -- start an argument list for a model
#
procedure mod_startarglist(a, type, yyval)

pointer a			# i: value frame
int	type			# i: type of argument (value or increment)
pointer yyval			# o: parser output value

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# get a new call frame
	mod_frame = mod_frame + 1
	# check vs. max
	if( mod_frame > MAX_CALLS ){
	    call mod_error("too many function calls")
	    return
	}
	# add argument to call frame
	if( a != NULL ){
	    # number of args is 1
	    mod_nargs[mod_frame] = 1
	    # add the type of argument
	    mod_types[1, mod_frame] = type
	    # add the argument value
	    mod_lower[1, mod_frame] = O_LOWER(a)
	    # add the delta
	    mod_upper[1, mod_frame] = O_UPPER(a)
	    # add the fixed/free state
	    mod_fixed[1, mod_frame] = O_FIXED(a)
	    # add the link number
	    mod_links[1, mod_frame] = O_LINK(a)
	}
	else
	    # no args
	    mod_nargs[mod_frame] = 0
	# return the call number
	O_VALI(yyval) = mod_frame
end

#
# MOD_ADDARG -- add an argument to an argument list for a model
#
procedure mod_addarg(a, b, type, yyval)

pointer a			# i: arglist frame
pointer b			# i: value frame
int	type			# i: type of argument (value or link)
pointer yyval			# o: parser output value

int frame			# l: current call frame
int argno			# l: argument number

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# get current argument number
	frame = O_VALI(a)
	# add 1 to number of args in this frame
	argno = mod_nargs[frame] + 1
	# check against max
	if( argno > MAX_ARGS ){
	    call mod_error("too many arguments in function")
	    return
	}
	# add the type of argument
	mod_types[argno, frame] = type
	# add the argument
	mod_lower[argno, frame] = O_LOWER(b)
	# add the argument
	mod_upper[argno, frame] = O_UPPER(b)
	# add the fixed/free state
	mod_fixed[argno, frame] = O_FIXED(b)
	# add the link number
	mod_links[argno, frame] = O_LINK(b)
	# store the new total number of args
	mod_nargs[frame] = argno
	# return the call frame
	O_VALI(yyval) = frame
end

#
# MOD_NEWFILE -- call mod_pushfd from grammer
#
procedure mod_newfile(a, yyval)

pointer a			# i: input parser register
pointer yyval			# o: parser output value

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	call mod_pushfd(O_VALC(a))
	O_VALI(yyval) = O_VALI(a)
end

#
# MOD_ENDEXPR -- perform final operations on an expression
#
procedure mod_endexpr(a, yyval)

pointer	a			# i: res = op a
pointer yyval			# o: expression as a result
include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return
	# save the model descriptor
	call mod_saveexpr()
	# return the same register
	O_LIST(yyval) = O_LIST(a)
end

#
# MOD_FUNCTION -- evaluate a function
#
procedure mod_function(a, b, yyval)

pointer	a			# i: function code
pointer	b			# i: old value
pointer	yyval			# o: new value

begin
	# evaluate the appropriate function
	switch(O_VALI(a)){
	case MOD_LOG:
	    # copy the parameter record
	    call amovi(Memi[b], Memi[yyval], LEN_OPERAND)
	    # overwrite the parameter value
	    O_VALR(yyval) = log10(O_VALR(b))
	default:
	    call mod_error("unknown function")
	}
	# look for modifiers
	call mod_modifiers(yyval)
end

#
# MOD_ABSTYPE -- set new absorption type
#
procedure mod_abstype(a, yyval)

pointer	a			# i: abstype code
pointer	yyval			# o: new value

include "modparse.com"

begin
	# set the new absorption code
	FP_ABSORPTION(mod_fp) = O_VALI(a)
	# copy the operand struct (not really needed)
	call amovi(Memi[a], Memi[yyval], LEN_OPERAND)
end

