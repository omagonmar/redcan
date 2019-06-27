#$Header: /home/pros/xray/xspectral/source/RCS/modlinks.x,v 11.0 1997/11/06 16:42:53 prosb Exp $
#$Log: modlinks.x,v $
#Revision 11.0  1997/11/06 16:42:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:18  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:29  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:14  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:19  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:38  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:36  prosb
#General Release 1.1
#
#Revision 2.1  91/05/24  11:42:33  pros
#jso/eric - change to allow for fixed linked parameters
#
#Revision 2.0  91/03/06  23:05:24  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# MODLINKS.X -- routines to deal with links between parameters
#

include "modparse.h"

#
# MOD_RESOLVE_LINKS -- resolve all parameter links
#
procedure mod_resolve_links(fp)

pointer	fp				# i: frame pointer
int	link				# l: link value
int	nmodels				# l: number of models
int	i, j				# l: loop counters
int	free				# l: free state of base param
real	val				# l: value of base param
real	delta				# l: delta of base param
pointer	model				# l: model pointer

include "modparse.com"

begin
	# get number of models
	nmodels = FP_MODEL_COUNT(fp)
	# return if no models
	if( nmodels ==0 )
	    return
	# for each model ...
	do i=1, nmodels{
	    # set up to read this model
	    model = FP_MODELSTACK(fp, i)
	    # for each parameter in the model ...
	    do j=0, (MAX_MODEL_PARAMS-1){
		# if the link is unresolved ...
		link = MODEL_PAR_LINK(model, j)
		# resolve it
		if( link <0 ){
		    call mod_resolve_link(fp, -link, val, delta, free)
		    MODEL_PAR_FIXED(model,j) = free
		    if( free == FREE_PARAM ){
			MODEL_PAR_VAL(model, j) = val
			MODEL_PAR_DLT(model, j) = delta
		    }
		    else{
			MODEL_PAR_VAL(model, j) = val
			MODEL_PAR_DLT(model, j) = 0.0
		    }
		}
	    }
	}
end

#
# MOD_RESOLVE_LINK -- resolve a parameter link
#
procedure mod_resolve_link(fp, link, val, delta, free)

pointer	fp				# i: frame pointer
int	link				# i: link value
real	val				# o: param value
real	delta				# o: param delta
int	free				# o: free state

int	nmodels				# l: number of models
int	i, j				# l: loop counters
int	got				# l: number of base links
pointer	model				# l: model pointer
char	tbuf[SZ_LINE]			# l: temp error buffer

include "modparse.com"

begin
	# get number of models
	nmodels = FP_MODEL_COUNT(fp)
	# got no base links
	got = 0
	# for each model ...
	do i=1, nmodels{
	    # set up to read this model
	    model = FP_MODELSTACK(fp, i)
	    # for each parameter in the model ...
	    do j=0, (MAX_MODEL_PARAMS-1){
		# if this is the link ...
		if( link == MODEL_PAR_LINK(model, j) ){
		    # return it's value
		    val = MODEL_PAR_VAL(model, j)
		    delta = MODEL_PAR_DLT(model, j)
		    free = MODEL_PAR_FIXED(model,j)
		    got = got + 1
		}
	    }
	}
	# make sure we got only one base
	if( got ==0 ){
	    # we couldn't resolve the link
	    call sprintf(tbuf, SZ_LINE, "couldn't resolve link %d")
	    call pargi(link)
	    call mod_error(tbuf)
	}
	else if( got > 1 ){
	    # resolved the link more than once
	    call sprintf(tbuf, SZ_LINE, "too many base links for %d")
	    call pargi(link)
	    call mod_error(tbuf)
	}
end

#
#  MOD_ABS_LINK -- determine the link value for absorption params
#		   that are applied to a model
#
int procedure mod_abs_link(link, fixed, i)

int	link				# i: abs link value
int	fixed				# i: abs fixed state
int	i				# i: model being applied to in loop

include "modparse.com"

begin
	# case 1: If link <0, this is simply a linked parameter
	# and so we make all of the models be linked as well.
	if( link <0 )
	    return(link)
	# case 2: If link >0, this is the base link of a linked set.
	# We make one of the params the base, and the others linked to it.
	else if( link >0 ){
	    if( i ==1 )
		return(link)
	    else
		return(-link)
	}
	# case 3: If link ==0, there is no explicit linking.
	# However, if this param is free, we must link these models.
	# To do this, we make a dummy link number, assign it to one model
	# and link the others to it.
	else{
#	    # its really fixed, no sweat
#	    if( fixed == FIXED_PARAM )
#		return(link)
#	    # its free - we must link all models to themselves
#	    else{
		# the first one will be the base
		if( i == 1 ){
		    # increment the link
		    mod_link = mod_link + 1
		    # the new link value if the first available link
		    link = mod_link
		    return(link)
		}
		# the others are linked to it
		else{
		    call mod_error("internal error - 0 link for i!=0")
	 	}
	    }
#	}	
end

#
#  MOD_SET_LINK -- set fixed/free state for all links in a chain
#
procedure mod_set_link(fp,  link, fstate)

pointer	fp				# i: frame pointer
int	link				# i: link value
int	fstate				# i: fixed free state

int	nmodels				# l: number of models
int	i, j				# l: loop counters
pointer	model				# l: model pointer

include "modparse.com"

begin
	# return if this is not a linked param
	if( link ==0 ) return

	# get number of models
	nmodels = FP_MODEL_COUNT(fp)
	# for each model ...
	do i=1, nmodels{
	    # set up to read this model
	    model = FP_MODELSTACK(fp, i)
	    # for each parameter in the model ...
	    do j=0, (MAX_MODEL_PARAMS-1){
		# if this is the link ...
		if( abs(link) == abs(MODEL_PAR_LINK(model, j)) )
		    # change the fixed/free state
		    MODEL_PAR_FIXED(model, j) = fstate
	    }
	}
end
