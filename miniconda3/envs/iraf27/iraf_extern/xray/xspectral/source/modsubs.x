#$Header: /home/pros/xray/xspectral/source/RCS/modsubs.x,v 11.0 1997/11/06 16:42:56 prosb Exp $
#$Log: modsubs.x,v $
#Revision 11.0  1997/11/06 16:42:56  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:42  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:37  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/03/11  13:50:27  prosb
#jso - add more raymond model abundances.
#
#Revision 3.2  92/03/05  12:28:03  orszak
#jso - test to add more raymond models.
#
#Revision 3.1  91/09/22  19:06:40  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:41  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:05:40  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# MODSUBS.X -- support for model parsing
#  these routines are mostly called from mod_parse or one of the yacc
#  code fragments
#

include <mach.h>

include "modparse.h"

#
#
# MOD_RESET - reset pointers for next compilation
#
procedure mod_reset()
include "modparse.com"
begin
	# set current string pointer back to beginning
	mod_nextch = mod_sbuf
	# no functions called as yet
	mod_frame = 0
end

#
# MOD_DEF -- install the default models' min and max args
#
procedure mod_def()

begin
	# install model names, with min and max args
	call mod_install("powerlaw", POWER_LAW, 2, 2)
	call mod_install("blackbody", BLACK_BODY, 2, 2)
	call mod_install("bremsstrahlung", EXP_PLUS_GAUNT, 2, 2)
	call mod_install("exponential", EXPONENTIAL, 2, 2)
	call mod_install("raymond", RAYMOND, 4, 4)
	call mod_install("line", SINGLE_LINE, 3, 3)
	# install special keywords at end of table
	call mod_install("absorption", ABSORPTION, 1, 3)
end

#
# MOD_INSTALL -- install a model into the lookup table
#
procedure mod_install(name, code, minargs, maxargs)

char name[ARB]				# i: name of model
int code				# i: associated function code
int minargs				# i: min number of args for model
int maxargs				# i: max number of args for model

int len					# l: len of name
int i					# l: current model
int strlen()				# l: string length
bool streq()				# l: string compare

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# check for special keywords
	if( streq("absorption", name) ){
	    i = MAX_MODDEFS + 1
	}
	else{
	    # inc number of saved names
	    mod_installed = mod_installed + 1
	    i = mod_installed
	    # check for full name table
	    if( mod_installed > MAX_MODDEFS ){
		call mod_error("model name table full")
		return
	    }
	}

	# get length of name string
	len = strlen(name)
	# allocate a space for it
	call salloc(mod_strings[i], len+1, TY_CHAR)
	# copy in the name
	call strcpy(name, Memc[mod_strings[i]], len)
	# make it lower case
	call strlwr(Memc[mod_strings[i]])
	# and the function code
	mod_codes[i] = code
	# and the required args
	mod_minargs[i] = minargs
	mod_maxargs[i] = maxargs
end

#
# MOD_ERROR -- print out an error message and set mod_error to YES
#
procedure mod_error(emsg)

char	emsg[ARB]			# i: error message
char    tbuf[SZ_LINE]			# l: temp buffer

include "modparse.com"

begin
	mod_eflag = YES
	call sprintf(tbuf, SZ_LINE, "MODEL ERROR - %s")
	call pargstr(emsg)
	call error(1, tbuf)
#	call printf("MODEL ERROR - %s\n")
#	call pargstr(emsg)
#	call flush(STDOUT)
end

#
# MOD_SAVEEXPR - save the model name in the mod_allnames string
#
procedure mod_saveexpr()

int len1			# i: temp string length
int len2			# i: temp string length
pointer old			# l: old string pointer for realloc
int strlen()			# l: string length
include "modparse.com"

begin
	if( strlen(Memc[mod_name]) != 0 ){
	    call mod_nullcomma()
	    # add ending
#	    call strcat(")\n", Memc[mod_name], SZ_LINE)
	    call strcat("\n", Memc[mod_name], SZ_LINE)
	    # get total length of two strings
	    len1 = strlen(Memc[mod_name])
	    len2 = strlen(Memc[mod_allnames])
	    # re-allocate buffer if necessary
	    if( len1+len2 > mod_namelen -1 ){
		# save old buf pointer
		old = mod_allnames
		# inc the length of the buffer
		mod_namelen = mod_namelen + NAMEINC
		# allocate a new buffer
		call salloc(mod_allnames, mod_namelen, TY_CHAR)
		# and copy in string
		call strcpy(Memc[old], Memc[mod_allnames], mod_namelen)
	    }
	    # concat new string onto old
	    call strcat(Memc[mod_name], Memc[mod_allnames], mod_namelen)
	    # and reset new string
	    call strcpy("", Memc[mod_name], SZ_LINE)
	}
end

#
#  MOD_GETARGS -- retrieve the arguments for a frame
#
procedure mod_getargs(frame, lower, upper, fixed, links, nargs)

int	frame			# i: call frame number
real	lower[MAX_ARGS]		# o: lower bound on params
real	upper[MAX_ARGS]		# o: upper bound on params
int	fixed[MAX_ARGS]		# o: fixed/free flag
int	links[MAX_ARGS]		# o: links to arguments in other models
int	nargs			# o: number of args in frame
int	i, j			# l: counters

include "modparse.com"

begin
	# process all args in frame, moving them into args array
	i = 0
	for(j=1; j<=mod_nargs[frame]; j=j+1){
	    switch(mod_types[j, frame]){
	    case NUMERAL, LINK:
		if( i > MAX_ARGS ){
	            call mod_error("max args exceeded")
	            return
		}
		i = i+1
		lower[i] = mod_lower[j, frame]
		upper[i] = mod_upper[j, frame]
		fixed[i] = mod_fixed[j, frame]
		links[i] = mod_links[j, frame]
	    default:
	        call mod_error("unknown argument type")
		return
	    }
	}
	# return the number of args we got
	nargs = i
end

#
#  MOD_CHKARGS -- check argument count against min and max
#
procedure mod_chkargs(a, args, nmodels, skip)

pointer a			# i: parser register
int	args			# i: number of args
int	nmodels			# i: number of models thus far
int	skip			# o: flag we skipped arg 1 for model 1

int	minargs			# l: min args for model
int	maxargs			# l: max args for model
char	ebuf[SZ_LINE]		# l: error mess buffer

begin
	# assume we didn't skip arg 1 for model 1
	skip = 0
	# get min and max args
	minargs = O_MINARGS(a)
	maxargs = O_MAXARGS(a)
	if( maxargs == -1 )
	    maxargs = MAX_ARGS
	# check within limits
	if( (args<minargs) || (args>maxargs) ){
	    # if not in limits, check for first model
	    if( nmodels ==0 ){
		# see if we have 1 less than min
		if( args == (minargs-1) ){
		    # we skipped the arg 1
		    skip = 1
		    return
		}
	    }
	    # otherwise its an error!
	    call sprintf(ebuf, SZ_LINE,
		"argument count (%d) out of range (%d,%d) for type %s")
	    call pargi(args)
	    call pargi(minargs)
	    call pargi(maxargs)
	    call pargstr(Memc[O_NAME(a)])
	    call mod_error(ebuf)
	    return
	}
end

#
# MOD_NULLCOMMA - null out last comma in mod_name string
#
procedure mod_nullcomma()

int index			# i: index into string
int strldx()			# l: string index
include "modparse.com"

begin
	    # change final comma to a space
	    index = strldx(",", Memc[mod_name])
	    if( index !=0 )
		Memc[(mod_name+index-1)] = ' '
end

#
# MOD_PUSHFD --	open a file and make the new fd current
#		push the previous fd on the stack
#
procedure mod_pushfd(fname)

char fname[ARB]			# i: file name to open

char tname[SZ_FNAME]		# l: in case we add the extension
int open()			# l: open a file

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# inc the number of fd's we have nested
	mod_fdlev = mod_fdlev + 1

	# check for overflow
	if( mod_fdlev >= MAX_NESTS ){
	    call mod_error("include file stack overflow")
	    return
	}

	# convert to lower case
#	call strlwr(fname)
	# open the new file
	iferr( mod_fds[mod_fdlev] = open(fname, READ_ONLY, TEXT_FILE) ){
	    call strcpy(fname, tname, SZ_FNAME)
	    call strcat(MOD_EXT, tname, SZ_FNAME)
	    mod_fds[mod_fdlev] = open(tname, READ_ONLY, TEXT_FILE)
	}
	# and make it the current fd (for next read)
	mod_fd = mod_fds[mod_fdlev]
end

#
# MOD_POPFD --	close a file
#		pop the previous fd on the stack, if there is one
#
procedure mod_popfd()

include "modparse.com"

begin
	# if we had an error earlier, just return
	if( mod_eflag == YES ) return

	# close the current file
	call close(mod_fd)
	# dec the number of fd's we have nested
	mod_fdlev = mod_fdlev - 1
	# level <= 0 - underflow
	if( mod_fdlev <= 0 ){
	    call mod_error("include file stack underflow")
	    return
	}
	# level > 0 - restore previous fd
	else
	    mod_fd = mod_fds[mod_fdlev]
end

#
#  MOD_TWOABS -- make sure absorption is applied only once to a model
#
procedure mod_twoabs(val, type)

real	val			# i: current value of absorption param
char	type[ARB]		# i: name of absorption param
char	tbuf[SZ_LINE]		# l: temp error string buffer

begin
	# we originally set all values to 0.0 so any change is an error
	if( val != 0.0 ){
	    call sprintf(tbuf, SZ_LINE, "can't apply %s twice to one model")
	    call pargstr(type)
	    call mod_error(tbuf)
	}
end

#
# MOD_FREE_ALPHA -- change free alpha param to calc alpha in model 1
#
procedure mod_free_alpha(fp)

pointer	fp				# i: frame pointer

int	link				# l: link value
int	nmodels				# l: number of models
int	i, j				# l: loop counters
pointer	model1				# l: model pointer for first model
pointer	model				# l: model pointer for loop

include "modparse.com"

begin
	# set up to read first model
	model1 = FP_MODELSTACK(fp, 1)
	# if the first model's alpha param if free ...
	if( MODEL_PAR_FIXED(model1,MODEL_ALPHA) == FREE_PARAM ){
# make sure this param is not linked (until we know how to deal with it)
if( MODEL_PAR_LINK(model1,MODEL_ALPHA) !=0 )
    call mod_error("the model #1 alpha param must not be linked (use norm=1)")
	    # change it to calc'ed ...
	    MODEL_PAR_FIXED(model1,MODEL_ALPHA) = CALC_PARAM
	    # this is the base link value of the alpha param
	    link = abs(MODEL_PAR_LINK(model1,MODEL_ALPHA))
	    # if the alpha param link is <0, make it the base (>0)
	    if( MODEL_PAR_LINK(model1,MODEL_ALPHA) <0 ){
		# for each model ...
		nmodels = FP_MODEL_COUNT(fp)
		do i=1, nmodels{
		    # set up to read this model
		    model = FP_MODELSTACK(fp, i)
		    # for each parameter in the model ...
		    do j=0, (MAX_MODEL_PARAMS-1){
			# if this is the link ...
			if( MODEL_PAR_LINK(model, j) == link ){
			    # unbase the old base
			    MODEL_PAR_LINK(model, j) = -link
			    # make the alpha the base
			    MODEL_PAR_LINK(model1,MODEL_ALPHA) = link
			}
		    }
		}
	    }
	    # now change all links to CALC_PARAM
	    if( MODEL_PAR_LINK(model1,MODEL_ALPHA) >0 ){
		# for each model ...
		nmodels = FP_MODEL_COUNT(fp)
		do i=1, nmodels{
		    # set up to read this model
		    model = FP_MODELSTACK(fp, i)
		    # for each parameter in the model ...
		    do j=0, (MAX_MODEL_PARAMS-1){
			# if this is a link ...
			if( (abs(MODEL_PAR_LINK(model, j)) == link) &&
			    (MODEL_PAR_FIXED(model, j) == FREE_PARAM) ){
			    # change it to calc'ed ...
			    MODEL_PAR_FIXED(model, j) = CALC_PARAM
			}
		    }
		}
	    }
	}
end

#       define local parameter strings
define	DELTA_IDX	"delta"
define  DELTA_NORM	"norm_delta"
define  DELTA_EM        "em_delta"
define  DELTA_INT	"intrinsic_delta"
define  DELTA_GAL       "galactic_delta"
define  DELTA_RED	"redshift_delta"

#
# MOD_DLT_DEFS - get default delta values for free params
#		   that didn't get deltas from user
#
procedure  mod_dlt_defs(fp)

pointer fp                              # i: fitting parameters structure
pointer model                		# l: pointer to current model
int	i				# l: loop counter

begin
	# loop through all models
	do i=1, FP_MODEL_COUNT(fp){
	    # get deltas on all free params that didn't explicitly get one
	    model = FP_MODELSTACK(fp,i)
	    if( MODEL_TYPE(model) == RAYMOND )
		call mod_dlt_def1(model, MODEL_ALPHA, DELTA_EM)
	    else
		call mod_dlt_def1(model, MODEL_ALPHA, DELTA_NORM)    
	    call mod_dlt_def1(model, MODEL_TEMP, DELTA_IDX)
	    call mod_dlt_def1(model, MODEL_INTRINSIC, DELTA_INT)
	    call mod_dlt_def1(model, MODEL_GALACTIC, DELTA_GAL)
	    call mod_dlt_def1(model, MODEL_REDSHIFT, DELTA_RED)
	}
end

#
#  MOD_DLT_DEF1 - get defaults for one parameter
#
procedure mod_dlt_def1(model, index, pname)

pointer model                   	# i: pointer to current model
int	index			        # l: arg index
char	pname[ARB]			# l: param name for clgetr
real    clgetr()			# l: get real param

begin
	# check for a free param that has no delta	
	if( (MODEL_PAR_DLT(model,index) <=EPSILON) &&
	    (MODEL_PAR_FIXED(model,index) == FREE_PARAM) )
	    MODEL_PAR_DLT(model,index) = clgetr(pname)
end

#
#  MOD_CHK_PERCENT -- make sure abundance percentage is one of the allowed
#			discrete values
#
procedure mod_chk_percent(percentage)

int	percentage			# i: abundance percentage

begin
	switch(percentage){
	case 10,20,25,30,40,50,60,70,75,80,90,100,110,120,130,140,150,200,300,400,500:
	    ;
	default:
	   call eprintf("Raymond abundance percentages must be one of:\n")
	   call eprintf("\t10, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90, 100,\n")
	   call eprintf("\t110, 120, 130, 140, 150, 200, 300, 400, 500.\n")
	   call flush(STDERR)
	   call mod_error("illegal percentage for Raymond abundance")
	}
end
