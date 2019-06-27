#$Header: /home/pros/xray/xspectral/source/RCS/free_params.x,v 11.0 1997/11/06 16:42:12 prosb Exp $
#$Log: free_params.x,v $
#Revision 11.0  1997/11/06 16:42:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:39  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:32  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:12  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:20  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:56  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:17  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:10:53  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:03:17  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  FREE_PARAMS -- routines that deal with free parameters, both those
#  that are truly free (unlinked or base) and those that are sort of free
#  (linked).

include  <spectral.h>

define NL_MODEL		($1)*3-2
define NL_PARAM		($1)*3-1
define NL_INDEX		($1)*3-0

#
#  FREE_PARAMS -- Determine the number and location of free parameters
#
int  procedure  free_params( fp, fraction, vals, steps, nmodel, nparam,
			     nlink, nlinks, max_params )

pointer fp                              # parameter data structure
pointer model                           # pntr to model structure
real	fraction			# 
real    vals[ARB]                       # initiall values for free parameters
real    steps[ARB]                      # initial steps for free parameters
int     nmodel[ARB]                     # corresponding model numbers
int     nparam[ARB]                     # corresponding parameter codes
int	nlink[ARB]			# o: array of linked parameters
int	nlinks				# o: number of links in array
int     max_params                      # maximum allowed parameters
int     num_models                      # number of models available
int     i_model                         # index for models
int     i_param                         # index for parameters
int     nfree                           # number of free parameters
int	base[MAX_LINKS]			# base links
int	j				# loop counter
int	got				# link counter
int	link				# current link value

begin
        nfree = 0
        num_models = FP_MODEL_COUNT(fp)

	# first determine the truly free parameters
        if( num_models > 0 ){

            do i_model = 1, num_models  {
                model = FP_MODELSTACK(fp,i_model)
                do i_param = 0, (MAX_MODEL_PARAMS-1) {
                    if( (MODEL_PAR_FIXED(model,i_param) == FREE_PARAM) &&
                        (MODEL_PAR_LINK(model,i_param) >=0) )  {
                        nfree = nfree + 1
                        if( nfree > max_params )
                            call error (1, "Too many free parameters.")
                        nmodel[nfree] = i_model
                        nparam[nfree] = i_param
                        vals[nfree]  = MODEL_PAR_VAL(model,i_param)
                        steps[nfree] = MODEL_PAR_DLT(model,i_param)
                        if( steps[nfree] == 0.0 )
                            steps[nfree] = fraction
			# save the link value
			base[nfree] = MODEL_PAR_LINK(model, i_param)
                    }
                }
            }

	    # now deal with the linked parameters
	    nlinks = 0
            do i_model = 1, num_models  {
                model = FP_MODELSTACK(fp,i_model)
                do i_param = 0, (MAX_MODEL_PARAMS-1) {
                    if( (MODEL_PAR_FIXED(model,i_param) == FREE_PARAM) &&
                        (MODEL_PAR_LINK(model,i_param) <0) )  {
			link = abs(MODEL_PAR_LINK(model, i_param))
                        nlinks = nlinks + 1
                        if( nlinks > MAX_LINKS )
                            call error (1, "Too many links.")
                        nlink[NL_MODEL(nlinks)] = i_model
                        nlink[NL_PARAM(nlinks)] = i_param
			got = 0
			# look for the index
			do j=1, nfree{
			    if( link == base[j] ){
				nlink[NL_INDEX(nlinks)] = j
				got = got+1
			    }
			}
			# make sure we found one, but not more
			if( got ==0 )
			    call errori(1, "no base link in free_param", link)
			if( got >1 )
			    call errori(1, "too many base links in free_param",
						link)
                    }
                }
            }

	}	
        return (nfree)
end

#
#  FREE_UPDATED -- update values of all free parameters,
#  both the truly free and the linked free
#  this is the double precision version (used in nagfit.x)
#
procedure free_updated(fp, nmodel, nparam, nparameters,
		      nlink, nlinks, pinit, pdelt, xc)

pointer fp                              # i: parameter data structure
int     nmodel[ARB]                     # i: corresponding model numbers
int     nparam[ARB]                     # i: corresponding parameter codes
int	nparameters			# i: number of free params
int	nlink[ARB]			# i: array of linked parameters
int	nlinks				# i: number of links in array
real	pinit[ARB]			# i: initial values
real	pdelt[ARB]			# i: deltas
double	xc[ARB]				# i: scale factors

int	n				# l: loop counter
int	param				# l: current parameter
int	index				# l: current index
pointer	model				# l: model pointer

begin
	# update the truly free parameters
	do n = 1, nparameters  {
	    model = FP_MODELSTACK(fp,nmodel[n])
	    MODEL_PAR_VAL(model,nparam[n]) = pinit[n] + pdelt[n]*dtanh(xc[n])
	}
	# update the linked free parameters
	do n = 1, nlinks  {
	    model = FP_MODELSTACK(fp,nlink[NL_MODEL(n)])
	    param = nlink[NL_PARAM(n)]
	    index = nlink[NL_INDEX(n)]
	    MODEL_PAR_VAL(model, param) = pinit[index] +
					  pdelt[index]*dtanh(xc[index])
	}
end

#
#  FREE_UPDATER -- update values of all free parameters,
#  both the truly free and the linked free
#  this is the real precision version (used in conj_grad.x)
#
procedure free_updater(fp, nmodel, nparam, nparameters,
		      nlink, nlinks, pinit, pdelt, xc)

pointer fp                              # i: parameter data structure
int     nmodel[ARB]                     # i: corresponding model numbers
int     nparam[ARB]                     # i: corresponding parameter codes
int	nparameters			# i: number of free params
int	nlink[ARB]			# i: array of linked parameters
int	nlinks				# i: number of links in array
real	pinit[ARB]			# i: initial values
real	pdelt[ARB]			# i: deltas
real	xc[ARB]				# i: scale factors

int	n				# l: loop counter
int	param				# l: current parameter
int	index				# l: current index
pointer	model				# l: model pointer

begin
	# update the truly free parameters
	do n = 1, nparameters  {
	    model = FP_MODELSTACK(fp,nmodel[n])
	    MODEL_PAR_VAL(model,nparam[n]) = pinit[n] + pdelt[n]*tanh(xc[n])
	}
	# update the linked free parameters
	do n = 1, nlinks  {
	    model = FP_MODELSTACK(fp,nlink[NL_MODEL(n)])
	    param = nlink[NL_PARAM(n)]
	    index = nlink[NL_INDEX(n)]
	    MODEL_PAR_VAL(model, param) = pinit[index] +
					  pdelt[index]*tanh(xc[index])
	}
end

