#$Header: /home/pros/xray/xspectral/source/RCS/single_fit.x,v 11.0 1997/11/06 16:43:22 prosb Exp $
#$Log: single_fit.x,v $
#Revision 11.0  1997/11/06 16:43:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:35:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:57  prosb
#General Release 2.3
#
#Revision 6.1  93/10/22  18:17:53  dennis
#Added SRG_HEPC1, SRG_LEPC1, default cases, for DSRI.
#
#Revision 6.0  93/05/24  16:52:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/03  17:10:23  orszak
#jso - turn on ROSAT HRI fitting.
#
#Revision 3.2  91/09/22  19:07:21  wendy
#Added
#
#Revision 3.1  91/08/23  14:27:08  prosb
#jso - set up so that the MAX_EXP would depend on iraf defines.
#
#Revision 3.0  91/08/02  01:59:10  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:44:49  prosb
#jso - made spectral.h system wide and added call for new pset parameeter
#
#Revision 2.2  91/05/24  11:45:29  pros
#jso - change the way logadd happens and what it uses for a limit
#
#Revision 2.1  91/04/25  16:36:42  pros
#Make the code path of single fit be the same as fit with or free and no calculated parameters.
#
#Revision 2.0  91/03/06  23:07:33  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  main routine for the single value spectral fit task
#   revision dmw Oct 1988 - to run t_smodels after fit

include <mach.h>

include <spectral.h>

# max allowed log for double on Sun-3
define MAX_EXPD	double(MAX_EXPONENTD)
define BAD_EXPD (-MAX_EXPD-1.0D0)

#  task procedure
procedure  t_singlef()

pointer  fp                            #  data structure for fitting parameters
pointer	np
pointer clopset()

begin

        call printf ("Performing a single value fit.\n")
	np = clopset("pkgpars")
	call const_fp( fp )
	call fp_singlef(fp)
	call raze_fp ( fp )
	call clcpset(np)

end

#
#  FP_SINGLEF -- called once the frame pointer has been set up
#	( we don't want to call t_singlef from other tasks)
#
procedure  fp_singlef (fp)

pointer  fp                            #  data structure for fitting parameters
# int	 fstatus			# saved fixed parameter status
real	 chisq
# real	 normalization		#
int	 nparameters
int	 ct_params()
# real	 norm_chisq()
real	 fp_chisq()

begin
	# make sure we have no free or calc'ed params
	nparameters = ct_params(fp,FREE_PARAM) + ct_params(fp,CALC_PARAM)
	if( nparameters != 0 )
	    call error(1, "no free or calc'ed parameters allowed")

	if( FP_MODEL_COUNT(fp) > 0 )  {
#	    fstatus = MODEL_PAR_FIXED(FP_MODELSTACK(fp,1),MODEL_ALPHA)
#	    MODEL_PAR_FIXED(FP_MODELSTACK(fp,1),MODEL_ALPHA) = FIXED_PARAM
	    call single_fit( fp )
#	    chisq = norm_chisq( fp, normalization )
#	    call adj_norm( fp, normalization)
#	    MODEL_PAR_FIXED(FP_MODELSTACK(fp,1),MODEL_ALPHA) = fstatus
	    chisq = fp_chisq(fp)
	    # we have to set the FP_NORM value explicitly
	    # for some reason, its done in adj_norm
	    FP_NORM(fp) = 1.0
	    call save_fit_results( fp, chisq, "single_fit" )
	    call fp_smodels(fp)
	}

end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

#    perform a single value fit

# D.M.W. - revision (9/15/88)
# Changed call of sum_comp( nmodel, model, emission, nbins )
# to call of sum_comp( nmodel, model, emission, nbins ,alpha1)
#  where alpha1 is the initial normalization of the first model (if first
#    normalization is fixed), or 1.0 otherwise.
#  Note that the normalizations of models are ratios wrt the norm of model 1
#  See notes in normalization.x
# revision dmw Oct 1988
#   put logarithmic values in all the intermediate spectra (to avoid
#   floating underflow problems and put in correct form for display tbd.

procedure  single_fit(fp)

pointer  fp,  model, model1
int      error_code,  nbins,  nmodel,  ndataset
int	 absorption
real     Nh,  redshift
real     alpha1

double	 mirrored_spectrum[SPECTRAL_BINS]   # incident * area (log)
double   filtered_spectrum[SPECTRAL_BINS]   # incident * area (log)
double	 incident_spectrum[SPECTRAL_BINS]

begin
	error_code = NO_ERROR
	nbins      = SPECTRAL_BINS
	absorption = FP_ABSORPTION(fp)

	# clear the total spectral arrays
	call amovkd( BAD_EXPD, Memd[FP_EMITTED(fp)], nbins )
	call amovkd( BAD_EXPD, Memd[FP_INTRINS(fp)], nbins )
	call amovkd( BAD_EXPD, Memd[FP_REDSHIFTED(fp)], nbins ) 
	call amovkd( BAD_EXPD, Memd[FP_INCIDENT(fp)], nbins ) 

	#  get value for alpha1	
	model1 = FP_MODELSTACK(fp, 1)
	if (MODEL_PAR_FIXED(model1, MODEL_ALPHA) == FIXED_PARAM)
	    alpha1 = 10.**MODEL_PAR_VAL(model1,MODEL_ALPHA)
	else
	    alpha1 = 1.0

	do nmodel = 1, FP_MODEL_COUNT(fp)
	{
	    model = FP_MODELSTACK(fp, nmodel)
	    call sum_comp (nmodel, model, Memd[MODEL_EMITTED(model)],
				   nbins ,alpha1)
	    Nh = 10.**MODEL_PAR_VAL(model,MODEL_INTRINSIC)
	    call apply_absorption (absorption, Nh,
				   Memd[MODEL_EMITTED(model)],
				   Memd[MODEL_INTRINS(model)], nbins)
	    redshift = MODEL_PAR_VAL(model,MODEL_REDSHIFT)
	    call apply_redshift (redshift, Memd[MODEL_INTRINS(model)],
				   Memd[MODEL_REDSHIFTED(model)], nbins)
	    Nh = 10.**MODEL_PAR_VAL(model,MODEL_GALACTIC)
	    call apply_absorption (absorption, Nh,
				   Memd[MODEL_REDSHIFTED(model)],
				   Memd[MODEL_INCIDENT(model)], nbins )

	    # add this model component to total
	    # we have to unlog the two, add, and re-log
	    call logadd (Memd[MODEL_EMITTED(model)],
				Memd[FP_EMITTED(fp)], nbins)
	    call logadd (Memd[MODEL_INTRINS(model)],
				Memd[FP_INTRINS(fp)], nbins)
	    call logadd (Memd[MODEL_REDSHIFTED(model)],
				Memd[FP_REDSHIFTED(fp)], nbins )
	    call logadd (Memd[MODEL_INCIDENT(model)],
				Memd[FP_INCIDENT(fp)], nbins)

	}
	call amovd(Memd[FP_INCIDENT(fp)], incident_spectrum, nbins)

	call cnv_phot_spect (incident_spectrum, nbins)

	do ndataset = 1, FP_DATASETS(fp)
	{
	    FP_CURDATASET(fp) = ndataset
	    switch ( DS_INSTRUMENT(FP_OBSERSTACK(fp, ndataset)) )
	    {
	      case EINSTEIN_IPC:
		call telescope_response (fp, incident_spectrum,
					 mirrored_spectrum, nbins)
		call filter_fold (mirrored_spectrum, filtered_spectrum, nbins)
		call ipc_fold (fp, filtered_spectrum, nbins)
	      case EINSTEIN_MPC:
		call mpc_fold (fp, incident_spectrum, nbins)
	      case EINSTEIN_HRI:
		call hri_fold (fp, incident_spectrum, nbins)
	      case ROSAT_PSPC:
		call pspc_fold(fp, incident_spectrum, nbins)
	      case ROSAT_HRI:
		call rhri_fold(fp, incident_spectrum, nbins)
	      case SRG_HEPC1:
		call hepc1_fold(fp, incident_spectrum, nbins)
	      case SRG_LEPC1:
		call lepc1_fold(fp, incident_spectrum, nbins)
	      default:
		call def_fold(fp, incident_spectrum, nbins)
	    }
	    call apply_live_time (fp)
	}
end

#
# LOGADD --  add a model component to the total; we must unlog the
# component, make sure the value is within range then add to the unlogged
# total, and re-log.
#
procedure logadd (ibuf, obuf, nbins)

double	ibuf[ARB]			# i: input buffer
double	obuf[ARB]			# o: output buf
int	nbins				# i: number of bins

int	ii				# l: loop counter
double	maxlog				# l: max log value allowed
double	minlog				# l: min log value allowed

begin
	# get largest and smallest allowed value for the log
	maxlog = double(MAX_EXPD)
	minlog = -maxlog

	# for each bin ...
	do ii = 1, nbins {
	    # if the value is not too large
	    if ( ibuf[ii] > maxlog ) {
		call error(1, "log of model spectrum too large")
	    }
	    # if we have an empty obuf bin
	    if ( obuf[ii] == BAD_EXPD ) {
		# copy the input to obuf
		obuf[ii] = ibuf[ii]
	    }
	    # else unlog obuf and input, add, and re-log
	    # minlog will be smallest value
	    else {
		obuf[ii] = dlog10( 10.0D0**ibuf[ii] + 10.0D0**obuf[ii] +
							10.0D0**minlog )
	    }
	}
end
