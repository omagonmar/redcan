#$Header: /home/pros/xray/xspectral/source/RCS/normalization.x,v 11.0 1997/11/06 16:42:58 prosb Exp $
#$Log: normalization.x,v $
#Revision 11.0  1997/11/06 16:42:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:32  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:40  prosb
#General Release 2.2
#
#Revision 5.1  93/04/01  17:08:26  orszak
#jso - spelling change.
#
#Revision 5.0  92/10/29  22:45:30  prosb
#General Release 2.1
#
#Revision 4.1  92/10/06  10:30:26  prosb
#jso - error message to suggest use of rebin if negative norm
#
#Revision 4.0  92/04/27  18:16:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/09/22  19:06:44  wendy
#Added
#
#Revision 3.1  91/08/23  14:26:51  prosb
#jso - set up so that the MAX_EXP would depend on iraf defines.
#
#Revision 3.0  91/08/02  01:58:46  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  16:28:26  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/03  10:15:49  pros
#jso - kluge to get around low T
#
#Revision 2.0  91/03/06  23:05:56  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   normalization.x   ---   compute the normalization

include  <mach.h>
include  <spectral.h>

define	HELIUM_TO_HYDROGEN	"helium_to_hydrogen"
define MAX_EXPR float(MAX_EXPONENTR)
# D.M.W. - revision (9/15/88)
#Changed from real procedure comp_norm( nmodel, model )
# to real procedure comp_norm( nmodel, model ,alpha1), where alpha1
# multiplies the normalizations of models with nmodel >1
#  The fitting function is always of the form
#  alpha1( f1 + alpha2 f2 + ...)
#  If alpha1 is a free parameter, then the value of alpha1 input to
#     this routine will be 1.0 (as calculated in single_fit.x)

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#    compute the normalization

real procedure comp_norm( nmodel, model , alpha1)

pointer model
int	nmodel
real	result
real	gaunt
real	energy_temp
real	redshift
real	alpha
real    alpha1
real	max_of_temp
real	HEB

real	clgetr()

begin
    alpha         = 10.**MODEL_PAR_VAL(model,MODEL_ALPHA)
    redshift      = MODEL_PAR_VAL(model,MODEL_REDSHIFT)
    energy_temp   = MODEL_PAR_VAL(model,MODEL_TEMP)

    if(  (nmodel == 1) && (MODEL_PAR_FIXED(model,MODEL_ALPHA) == CALC_PARAM) )  {
	alpha = 1.0
	}

# begin revision - dmw
    if (nmodel != 1)  {
	alpha = alpha * alpha1
	}
# end revision - dmw
    max_of_temp = log(10.0)* MAX_EXPR - log(float(SPECTRAL_BINS))

    redshift = redshift + 1.0
    switch ( MODEL_TYPE(model) )  {

	case POWER_LAW:
             result = alpha * redshift**(energy_temp-1.)

	case BLACK_BODY:
	     if ( (redshift/energy_temp) > max_of_temp ) {
		call error(1, "FIT: temperature below temporary limit")
	     }
	     else {
		result = alpha * (exp(redshift/energy_temp)-1.)/redshift**4.
	     }

	case EXP_PLUS_GAUNT:
	     if ( (redshift/energy_temp) > max_of_temp ) {
		call error(1, "FIT: temperature below temporary limit")
	     }
	     else {
		HEB = clgetr( HELIUM_TO_HYDROGEN )
		call cgaunt ( gaunt, redshift, energy_temp, HEB )
		result = alpha * exp(redshift/energy_temp)/(redshift*gaunt)
	     }

	case EXPONENTIAL:
	     if ( (redshift/energy_temp) > max_of_temp ) {
		call error(1, "FIT: temperature below temporary limit")
	     }
	     else {
		result = alpha * exp(redshift/energy_temp)/redshift
	     }

	case RAYMOND:
             result = alpha * 1.e-14/1.602

	case SINGLE_LINE:
	     result = alpha
        }

    return (result)
end


# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure adj_norm( fp, normalization )
# If normalization is calculated, then put log(normalization) into the
# model data structure.
# Store normalization in FP_NORM(fp)  (=1 if normalization is fixed, and
# calculated value if normalization is calculated). The storage in
# FP_NORM is so that the intermediate model spectra can be multiplied by
# it before being output to the ST table.
#

pointer fp			# parameter data structure
pointer model			# pointer to a model structure
pointer	pred			# predicted spectrum
#int	n			# model count
int	dataset			# dataset index
int	nphas			# number of channels
real	normalization		#
real	lognorm			#

begin
	model = FP_MODELSTACK(fp,1)
	if( MODEL_PAR_FIXED(model,MODEL_ALPHA) != FIXED_PARAM )  {
	    if ( normalization <= 0.0 ) {
		call eprintf("FIT: You have encountered a negative normalization;\n")
		call eprintf("use the 'rebin' option (see 'help fit')\n")
		call error(1, "")
	    }
	    else {
		lognorm = alog10(normalization)
	    }
	    MODEL_PAR_VAL(model,MODEL_ALPHA) = lognorm
# take out correction - dmw
#	    do n = 2, FP_MODEL_COUNT(fp)  {
#		model = FP_MODELSTACK(fp,n)
#		if( MODEL_PAR_FIXED(model,MODEL_ALPHA) == FREE_PARAM  )
#		    MODEL_PAR_VAL(model,MODEL_ALPHA) = lognorm+MODEL_PAR_VAL(model,MODEL_ALPHA)
#		}
#  end revision - dmw
	    }
	 else  {
	    normalization = 1.0
	    }
	do dataset = 1, FP_DATASETS(fp)  {
	    nphas = DS_NPHAS( FP_OBSERSTACK(fp,dataset) )
	    pred  = DS_PRED_DATA( FP_OBSERSTACK(fp,dataset) )
	    call amulkr ( Memr[pred], normalization, Memr[pred], nphas )
	    }
        # save the normalization
        FP_NORM(fp) = normalization
end

