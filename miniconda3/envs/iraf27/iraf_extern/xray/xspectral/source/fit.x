#$Header: /home/pros/xray/xspectral/source/RCS/fit.x,v 11.0 1997/11/06 16:42:05 prosb Exp $
#$Log: fit.x,v $
#Revision 11.0  1997/11/06 16:42:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:08  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:43:07  mo
#MC	7/2/93		Correct 'boolean' initialization from YES to TRUE
#			(RS6000 port)
#
#Revision 6.0  93/05/24  16:49:54  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:06  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  91/09/27  14:40:12  orszak
#jso - had to readjust the chisq checking because it was much to stringent.
#      this suggestion of frh seems to work fine.
#
#Revision 3.2  91/09/22  19:05:46  wendy
#Added
#
#Revision 3.1  91/08/23  14:25:15  prosb
#jso - changed the two chisq test to a tolerence set to 1e-6
#
#Revision 3.0  91/08/02  01:58:08  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:06:58  prosb
#jso - made spectral.h system wide and add calls to open new pset parameter
#
#Revision 2.2  91/06/07  11:08:05  pros
#jso - make verbose mode give nice titles for the debugging output
#
#Revision 2.1  91/04/25  16:35:30  pros
#Fix computation of chisq when no parameters are free or calculated.
#
#Revision 2.0  91/03/06  23:02:51  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  main routine for the gradient fit task using the NAG routines
# revisions dmw Oct 1988 to print model parameters after a fit
#      also, will run single fit if no free parameters
#      also, evaluates the predicted spectrum with best-fit parameters
#               from simplex (last call of FUNC by simplex may not have been
#               at minimum chi-squared position)
# also, verbose printout now in user-coordinate frame (rather than 'par' frame)
#            

include  <mach.h>
include  <spectral.h>

#  parameter string definitions

define  TOLERANCE               "tolerance"
define  MAX_ITERATIONS		"max_iterations"
define  VERBOSE            	"verbose"

#  local definitions

define	MAX_FREE_PARAMS		 8
define  FRACTION		 0.10	# fraction of value for next step



#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----
#  Finds the best fit for the free parameters, using a conjugate gradient
#  search.


procedure  t_fit ()

pointer	fp				# data structure for parameters
pointer np				# pset
int	nparameters			# number of parameters
real	chisq				# 
real	junk

int	ct_params()
real	simplex_search()
real	fp_chisq()
pointer	clopset()

begin
	call printf ("Performing the Simplex minimization fit.\n")
	np = clopset("pkgpars")
	call const_fp ( fp )

	if( FP_MODEL_COUNT(fp) > 0 )  {
	    nparameters = ct_params(fp,FREE_PARAM) + ct_params(fp,CALC_PARAM)
	    if( nparameters > 0 )  {
		call printf( "Found %d free parameter(s). \n")
		call pargi( nparameters )
		chisq = simplex_search( fp )
		junk = fp_chisq(fp)
		if ( ( abs((junk/chisq) -1) > 1.0e-6 ) &&
		     ( abs(junk-chisq)      > 0.05   )    ) {
		    call printf("warning: problem with chisqs %f %f\n")
		    call pargr(chisq)
		    call pargr(junk)
		    call flush(STDOUT)
		}
		call save_fit_results( fp, chisq, "simplex_minimization" )
		call fp_smodels(fp)
		}
	      else {
                call fp_singlef(fp)
		call printf( "No free parameters were found in the models. \n")
                  }
	    }
	call raze_fp ( fp )
	call clcpset(np)

end



#  Set up for the Simplex minimization.
#
real  procedure  simplex_search( fp )

pointer	fp				# parameter data structure

int	maxiters			# maximum number of iterations
int	max_params			# maximum allowed parameters
int	n				# parameter index
int	iw				#
int	ifail				# error indicator
double	work1[MAX_FREE_PARAMS]		#
double	work2[MAX_FREE_PARAMS]		#
double	work3[MAX_FREE_PARAMS]		#
double	work4[MAX_FREE_PARAMS]		#
double	work5[MAX_FREE_PARAMS]		#
double	work6[MAX_FREE_PARAMS,MAX_FREE_PARAMS]	#
double	chisq				# chi-square of fit
real	best_chisq			#
double	tolerance			# convergence tolerance
double	xc[MAX_FREE_PARAMS]		#
real	param_vals[MAX_FREE_PARAMS]	# array of free parameter values
real	param_step[MAX_FREE_PARAMS]	# array of free parameter steps

int	clgeti(),  free_params()
bool	clgetb()
real	clgetr(),  norm_chisq()
extern	funct,  monit

include "nag.com"

begin
	first = TRUE
	max_params  = MAX_FREE_PARAMS
	tolerance   = double(clgetr(TOLERANCE))
	verbose	    = clgetb(VERBOSE)
	maxiters    = clgeti(MAX_ITERATIONS)
	chisq       = double(MAX_REAL)
	nparameters = free_params( fp, FRACTION, param_vals, param_step,
				   nmodel, nparam, nlink, nlinks, max_params)
	if( nparameters > 0 )  {
	    fptr = fp
	    iteration = 0
	    # initialize the param initial values, deltas, etc.
	    do n = 1, nparameters  {
		pinit[n] = param_vals[n]
		pdelt[n] = param_step[n]
		xc[n] = 0.0d0
	    }
	    iw = nparameters+1
	    ifail = 1
	    # this is where all of the work is done!
	    call simplex( nparameters, xc, chisq, tolerance, 
			 iw, work1, work2, work3, work4, work5, work6,
			 funct, monit, maxiters, ifail)
	    if( ifail != 0 )  {
		call printf("Error - simplex minimization")
		if( ifail == 1 )
		    call printf("parameter out of range.\n")
		if( ifail == 2 )
		    call printf("premature termination.\n")
	    }
	    # update the free parameters (double version)
	    call free_updated(fp, nmodel, nparam, nparameters,
				 nlink, nlinks, pinit, pdelt, xc)

	  # re-evaluate spectrum with best-fit parameters
	  #
	  call single_fit(fp)
          chisq  = norm_chisq( fp, normalization )

	    }
	 else  {
            call single_fit( fp )
            chisq  = norm_chisq( fp, normalization )
	    }
        call adj_norm( fp, normalization )
	best_chisq = chisq
	return (best_chisq)
end



#  Monitor function
#
procedure  monit ( fmin, fmax, sim, n, is, ncall)

int	n, is, ncall
double	fmin, fmax, sim[ARB]

begin
	return
end



#  Evaluate a Chi-square.
#
procedure  funct ( n, xc, fc )

int	n
double	xc[ARB]
double	fc
pointer fp                              # data structure for parameters
pointer	model				# pointer to a model structure
int	i				# loop index
real	result				# single prec. version of "fc"
real	pvals[MAX_FREE_PARAMS]		# 
real    pnorm

real	calc_chisq(),  norm_chisq()

include "nag.com"

begin
	fc = 0.0
	if( nparameters > 0 )  {
	    fp = fptr
	    # update the free parameters (double version)
	    call free_updated(fp, nmodel, nparam, nparameters,
				 nlink, nlinks, pinit, pdelt, xc)
	    # update some debugging stuff
	    do i = 1, nparameters  {
		model = FP_MODELSTACK(fp,nmodel[i])
		pvals[i] = MODEL_PAR_VAL(model,nparam[i])
	    }
	    if ( verbose ) {
		if ( first ) {
		    call prnt_names(nparameters, nparam)
		    first = FALSE
		}
	    }
	    iteration = iteration + 1
	    call single_fit( fp )
	    model = FP_MODELSTACK(fp,1)
            if( MODEL_PAR_FIXED(model,MODEL_ALPHA) == CALC_PARAM ) 
                fc = double(norm_chisq( fp, normalization ))
            else  {
                fc = double(calc_chisq( fp ))
                normalization = 1.0
	    }
	    result = fc
 	    pnorm= normalization
	    if ( verbose ) {
		call prnt_vals (iteration, result, pnorm,
						nparameters, pvals)
	    }
	}
end


#
# PRNT_VALS -- print fit values
#
procedure  prnt_vals ( iteration, result, pnorm, nprms, prmvals )

int	 iteration		#
int	 nprms			# 
real     pnorm
real	 result			#
real	 prmvals[ARB]		#
int	 n			# parameter loop index

begin
	call printf (" %4d %11.5e %11.5e ")
	call pargi (iteration)
	call pargr (result)
	call pargr (pnorm)
	do n = 1, nprms  {
	    call printf ("%11.5e ")
	    call pargr(prmvals[n])
	}
	call printf ("\n")
	call flush (STDOUT)
end


#
# PRNT_NAMES -- print fit names
#
procedure prnt_names(nprms, nprm)

int	nprms
int	nprm[ARB]

int	ii
char	name1[SZ_LINE]
char	name2[SZ_LINE]
begin
	call strcpy("                    absolute ", name1, SZ_LINE)
	call strcpy("  iter     chisq       norm  ", name2, SZ_LINE)
	do ii = 1, nprms {
	    switch ( nprm[ii] ) {

		case MODEL_ALPHA:
		    call strcat("   log rel. ", name1, SZ_LINE)
		    call strcat("     norm   ", name2, SZ_LINE)
		case MODEL_TEMP:
		    call strcat("    keV, or ", name1, SZ_LINE)
		    call strcat("     index  ", name2, SZ_LINE)
		case MODEL_INTRINSIC:
		    call strcat("  intrinsic ", name1, SZ_LINE)
		    call strcat("     Nh     ", name2, SZ_LINE)
		case MODEL_GALACTIC:
		    call strcat("   galactic ", name1, SZ_LINE)
		    call strcat("      Nh    ", name2, SZ_LINE)
		case MODEL_REDSHIFT:
		    call strcat("            ", name1, SZ_LINE)
	    	    call strcat("   redshift ", name2, SZ_LINE)
		case MODEL_NORM:
		    call strcat("            ", name1, SZ_LINE)
	    	    call strcat("      what? ", name2, SZ_LINE)
		case MODEL_WIDTH:
		    call strcat("      line  ", name1, SZ_LINE)
		    call strcat("      width ", name2, SZ_LINE)
		default:
		    # this is just here as a reminder that we need to add new
		    # parameters in here; not that we can not know a param
		    call strcat("    unknown ", name1, SZ_LINE)
		    call strcat("    unknown ", name2, SZ_LINE)
	     }
	}
	call printf("%s\n%s\n")
	call pargstr(name1)
	call pargstr(name2)
	call flush(STDOUT)

end
