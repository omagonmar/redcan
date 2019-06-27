#$Header: /home/pros/xray/xspectral/source/RCS/chisq.x,v 11.0 1997/11/06 16:41:44 prosb Exp $
#$Log: chisq.x,v $
#Revision 11.0  1997/11/06 16:41:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:11  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:24  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:35  prosb
#General Release 2.1
#
#Revision 4.1  92/07/09  11:15:53  prosb
#jso - added a comment to note that the routine fp_chisq is tied to the
#      routine final_chisq in grid_fit.x
#
#Revision 4.0  92/04/27  18:13:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.7  92/03/26  15:56:57  prosb
#jso - missed changing a call of chisq with the new calling sequence.
#
#Revision 3.6  92/03/25  11:31:14  orszak
#jso - oops, total error should have been added in quadrature.
#
#Revision 3.5  92/03/19  16:30:50  orszak
#jso - added up total counts and errors and output.  as speced by lpd and bjw
#
#Revision 3.4  92/03/13  16:01:02  prosb
#jso - another place were the net counts was set to zero.  now they are
#      allowed to be negitive.
#
#Revision 3.3  92/03/06  10:41:35  prosb
#jso - added missing brace
#
#Revision 3.2  92/03/05  12:27:04  orszak
#jso - small change so that negitive net counts does not get set to zero.
#      approved by frh and lpd.
#
#Revision 3.1  91/09/22  19:05:20  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:54  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  15:34:39  prosb
#jso - made spectral.h system wide
#
#Revision 2.2  91/04/25  16:33:27  pros
#*** empty log message ***
#
#Revision 2.1  91/04/15  17:41:29  john
#Fix a really nasty mistake in the arguments to salloc.
#
#Revision 2.0  91/03/06  23:01:49  pros
#General Release 1.0
#
#
#  CHISQ.X -- routines that deal with chi-square calculation
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright



include	<mach.h>	# define EPSILON
include  <spectral.h>

#
#  FP_CHISQ -- called once the frame pointer has been set up
#
#	***** NB: any changes to fp_chisq should be     *****
#	***** incorporated in final_chisq in grid_fit.x *****
#
real procedure  fp_chisq (fp)

pointer	sp,  fp,  ds			# stack, parameter, dataset
pointer	filename			#
pointer	energies, observed, predicted	#
pointer	errors,   flags		#
pointer	variance			# (obs-pred)/error_weight
pointer	contrib			# contribution to chi-square
int	n_sets,  dataset		# number of data sets, and index
int	nbins				#
real	cs				# chi-square result
real	total_counts
real	total_error
real	totcs

real	chisq()

begin
	call smark (sp)
	n_sets = FP_DATASETS(fp)
	call printf( "Found %d dataset(s).\n")
		call pargi( n_sets )

	totcs = 0.0
	if( n_sets > 0 )  {
	    do dataset = 1, n_sets  {
		ds = FP_OBSERSTACK(fp,dataset)
		filename = DS_FILENAME(ds)
		nbins    = DS_NPHAS(ds)
		observed = DS_OBS_DATA(ds)
		predicted= DS_PRED_DATA(ds)
		errors   = DS_OBS_ERROR(ds)
		flags    = DS_CHANNEL_FIT(ds)
		contrib =  DS_CHISQ_CONTRIB(ds)
		call salloc (energies, (nbins+1), TY_REAL)
		call salloc (variance, (nbins+1), TY_REAL)
		call pha_energy (ds, Memr[energies], (nbins+1))
		cs = chisq(Memr[observed], Memr[predicted], Memr[errors],
			   Memi[flags], Memr[variance], Memr[contrib], nbins,
			   total_counts, total_error)
		totcs = totcs + cs

		call printf( "\n Data set #%d from file: %s \n" )
		    call pargi (dataset)
		    call pargstr (Memc[filename])
		call disp_table(Memr[observed], Memr[predicted], Memr[errors],
				Memr[energies], Memi[flags], Memr[variance],
				cs, nbins, total_counts, total_error)
		}
	    }
	call sfree (sp)
	return(totcs)
end
# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
real  procedure  chisq ( observed, predicted, errors, flags, variance,
			contrib, nbins, total_counts, total_error)

real	observed[ARB]			# i: observed data points
real	errors[ARB]			# i: errors on observed points
real	predicted[ARB]			# i: predicted data points
int	flags[ARB]			# i: channel use flags
real	variance[ARB]			# o: (pred-obs)/error
real	contrib[ARB]			# o: chi square contribution
int	nbins				# i: length of above arrays
real	total_counts
real	total_error

real	chisqval			# l: computed chi-square
int	bin				# l: channel index

begin

	chisqval = 0.0
	total_counts = 0.0
	total_error = 0.0

	do bin = 1, nbins {

	    # calculate the chi-square contribution for this bin
	    if ( errors[bin] > 0.0 ) {

		variance[bin] = (predicted[bin]-observed[bin])/errors[bin]
		contrib[bin] = variance[bin] * variance[bin]

		# add this contribution to the total chi-square, if necessary
		if ( flags[bin] != 0 ) {
		    total_counts = total_counts + observed[bin]
		    total_error  = total_error  + errors[bin]*errors[bin]
		    chisqval = chisqval + contrib[bin]
		}
	    }
	    else {
		variance[bin] = 0.0
		contrib[bin] = 0.0

		# add this contribution to the total chi-square, if necessary
		if ( flags[bin] != 0 ) {
		    total_counts = total_counts + observed[bin]
		    total_error  = total_error  + errors[bin]*errors[bin]
		}
	    }
	}
	total_error = sqrt(total_error)

	return (chisqval)
end

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

real  procedure  calc_chisq ( fp )

pointer	 fp		# parameter structure
pointer	 ds		# data set structure
pointer	 obser		# observed data array
pointer	 err		# observed data error array
pointer	 pred		# predicted data array
pointer	 flags		# channel flags array
pointer	variance	#
pointer	 contrib	# chi-sq contribution
int	 nbins		# number of channels
int	 dataset	# data set index
real	 cs		# Chi-squared answer
real	total_counts
real	total_error

pointer	sp

real	 chisq()

begin
	call smark(sp)
        cs = 0.0
        do dataset = 1, FP_DATASETS(fp)  {
	    ds = FP_OBSERSTACK(fp,dataset)
            nbins = DS_NPHAS(ds)
            obser = DS_OBS_DATA(ds)
            err   = DS_OBS_ERROR(ds)
            pred  = DS_PRED_DATA(ds)
            flags = DS_CHANNEL_FIT(ds)
	    contrib = DS_CHISQ_CONTRIB(ds)
	    call salloc(variance, nbins+1, TY_REAL)

	    cs = cs + chisq(Memr[obser], Memr[pred], Memr[err], Memi[flags], 
				Memr[variance], Memr[contrib], nbins,
				total_counts, total_error)
            }


	call sfree(sp)
        return (cs)

end
# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
real  procedure  norm_chisq ( fp, norm )

pointer  fp             # parameter structure
pointer	 ds		# dataset structure
pointer  obser          # observed data array
pointer  err            # observed data error array
pointer  pred           # predicted data array
pointer  flags          # channel flags array
real	 norm		# computed normalization
int	 dataset	# data set index
int	 nbins		# length of above arrays
real	 chisq		# computed chi-square

double   sum1		# sum of (counts[bin]*prd[bin]/error[bin])
double   sum2 		# sum of (prd[bin]*prd[bin]/error[bin])
double   sum3 		# sum of (counts[bin]*counts[bin]/error[bin])

begin
	sum1 = 0.0
	sum2 = 0.0
	sum3 = 0.0
        do dataset = 1, FP_DATASETS(fp)  {
	    ds = FP_OBSERSTACK(fp,dataset)
            nbins = DS_NPHAS(ds)
            obser = DS_OBS_DATA(ds)
            err   = DS_OBS_ERROR(ds)
            pred  = DS_PRED_DATA(ds)
	    flags = DS_CHANNEL_FIT(ds)
	    call cssums( Memr[obser], Memr[err], Memr[pred], Memi[flags],
			 nbins, sum1, sum2, sum3)
	    }

	if( sum2 > 0.0D0 ){

	    norm  = real(sum1 / sum2)
	}
	else{
	    norm = 1.0
	}
	chisq = real(sum3 - sum1*norm)
	return (chisq)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  cssums ( obs, err, prd, flags, nbins, sum1, sum2, sum3)

real	obs[ARB]
real	err[ARB]
real	prd[ARB]
int	flags[ARB]
int	nbins
int	bin		# channel index
real	counts		# 
real	error		#
double	sum1,  sum2,  sum3

begin

	do bin = 1, nbins  {
	    if( flags[bin] != 0 )  {
		counts = obs[bin]
		error = err[bin] * err[bin]
		if( error > 0 )  {

		    sum1 = sum1 + double((counts*prd[bin])/error)
		    sum2 = sum2 + double((prd[bin]*prd[bin])/error)
		    sum3 = sum3 + double((counts*counts)/error)
		    }
		}
	    }
end

#
#   DISP_TABLE   ---   creates the tabular display of channel data
#
procedure  disp_table (observed, predicted, errors, energies, flags,
			variance, chisq, nbins, total_counts, total_error)

real    observed[ARB]                   # observed data points
real    predicted[ARB]                  # predicted data points
real    errors[ARB]                     # errors on observed points
real	energies[ARB]			# boundaries energies
int     flags[ARB]                      # channel use flags
real	variance[ARB]			# chi sq contributions
real	chisq				# chisq result
int     nbins                           # length of above arrays
real	total_counts			# total net counts
real	total_error			# total error on net counts

int	bin				# channel index
char	c				# use flag

begin
	call printf( "\n PHA energy range   observed     error   predicted " )
	call printf( "(pred-obs)/error \n" )
	call printf(   " --- ------------   --------     -----   --------- " )
	call printf( "---------------- \n" )
	do bin = 1, nbins  {
	    if( flags[bin] != 0 )
		c = '*'
	      else
		c = ' '
	
#	    printed stuff:  1     2      3      4  5     6      7      8
	    call printf( "%4d %5.2f->%4.2f %11.1f %c %7.1f %11.1f %10.1f \n" )
		call pargi( bin )		# 1
		call pargr( energies[bin] )	# 2
		call pargr( energies[bin+1] )	# 3
		call pargr( observed[bin] )	# 4
		call pargc( c )			# 5
		call pargr( errors[bin] )	# 6
		call pargr( predicted[bin] )	# 7
		call pargr( variance[bin] )	# 8
	}

	call printf( "%16t* indicates use in Chi-square calculation. \n" )

	call printf("\nThe fitted net counts are: %.2f; with error: %.2f.\n")
	 call pargr(total_counts)
	 call pargr(total_error)

	call printf( "\nChi-square = %10.3f \n" )
	    call pargr( chisq )

	call flush(STDOUT)
end

#
#  COMP_CHISQ - retrieve the chisq contrib for a component data set
#
procedure comp_chisq(ds, comp_chi)

pointer	ds				# i: data set
real	comp_chi			# o: component chisq

int	i				# l: loop counter
int	nbins				# l: number of bins in data set
pointer	flags				# l: flag if this channel used
pointer	contrib				# l: chisq contrib for each channel

begin
	nbins    = DS_NPHAS(ds)
	flags    = DS_CHANNEL_FIT(ds)
	contrib =  DS_CHISQ_CONTRIB(ds)

	comp_chi = 0.0
	# for each contribution ...
	do i = 1, nbins{
	    # add this contribution to the total chi-square, if necessary
	    if( Memi[flags+i-1] != 0 )
	        comp_chi = comp_chi + Memr[contrib+i-1]
	}
end
