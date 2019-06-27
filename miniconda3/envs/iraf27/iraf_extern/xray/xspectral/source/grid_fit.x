#$Header: /home/pros/xray/xspectral/source/RCS/grid_fit.x,v 11.0 1997/11/06 16:42:15 prosb Exp $
#$Log: grid_fit.x,v $
#Revision 11.0  1997/11/06 16:42:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:33  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:25  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:30  prosb
#General Release 2.1
#
#Revision 4.3  92/10/09  09:39:24  prosb
#jso - added an error message if rebin parameter is true.  this parametrer 
#      is required, but would cause a null result so why use it.
#
#Revision 4.2  92/10/01  11:51:21  prosb
#jso - increased the precision of the column names.
#
#Revision 4.1  92/07/09  11:17:12  prosb
#jso - changes made to address bug in which the models were improperly
#      reset after each grid point calculation.  dmw made initial changes.
#
#Revision 4.0  92/04/27  18:15:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/07  16:06:23  prosb
#jso - change to make flint happy.
#
#Revision 3.2  92/03/06  10:59:52  prosb
#jso - changed a name to aviod a six character conflict
#
#Revision 3.1  91/09/22  19:06:04  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:21  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:14:02  prosb
#jso - made spectral.h system wide and add calls to open new pset parameter
#
#Revision 2.2  91/05/24  11:38:31  pros
#jso - corrected adj_params routine to deal multiple models
#
#Revision 2.1  91/04/01  14:20:54  pros
#jso - change to allow power law too have negitive exponents, per bug #139
#
#Revision 2.0  91/03/06  23:03:33  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  main routine for the grid search task

include  <mach.h>

include	<ext.h>
include  <spectral.h>

#  parameter string definitions

define  VERBOSE         "verbose"
define  GRIDFILE        "grid"

#  local definitions

define  X_PREFIX	"x_"
define  Y_PREFIX	"y_"

# define the size of the obs file string
define SZ_OBSSTR	80

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  Finds the best fit using a chi-squared grid.


procedure  t_gridfit ()

pointer	np
pointer fp             		                # data structure for parameters
real	chisq					#

real	grid_fit()
pointer clopset()

begin
	call printf ("Performing a grid search.\n")
	np = clopset("pkgpars")
	call const_fp ( fp )

        if( FP_MODEL_COUNT(fp) > 0 ){
	    chisq =  grid_fit ( fp )
	    call printf( "Minimum chi-squared is %0.3f\n" )
	    call pargr( chisq )
	    call save_fit_results( fp, chisq, "grid_fit")
	}

	call raze_fp ( fp )
	call clcpset(np)

end
# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
real  procedure  grid_fit  ( fp )

pointer fp             		                # data structure for parameters

pointer x,  y					# data structs for X and Y axes
pointer chisq_array				# array of grid results
bool	verbose					# flag for more printout
bool	final					# flag if we perform final fit
int	v,  h,  maxv,  maxh,  best_v,  best_h	# grid indices
real	chisq,  best_chisq			#
real	last_xval, last_xdelta			# final fit x value and delta
real	last_yval, last_ydelta			# final fit y value and delta
int	badval					# l: flag for bad grid value
bool	clobber					# l: clobber existing file?
pointer	xvals					# l: x grid point values
pointer yvals					# l: y grid point values
pointer	output_name				# l: output file pointer
pointer	temp_name				# l: temp file name pointer
pointer	sp					# l: stack pointer
pointer	model					# l: current model
pointer	imodel					# l: input model
pointer	omodel					# l: best fit model
pointer	best					# l: best fit params

bool	clgetb()
int	mod_parse()
real    grid_point()
real	final_chisq()

begin
	# mark the stack
	call smark(sp)
	# allocate space for output file name
	call salloc ( output_name, SZ_FNAME, TY_CHAR )
	# allocate space for temp name
	call salloc ( temp_name, SZ_FNAME, TY_CHAR )
	# allocate model strings
	call salloc(omodel, SZ_LINE, TY_CHAR)
	call salloc(best, SZ_LINE, TY_CHAR)

	# get the output file name
	call clgstr ( GRIDFILE, Memc[output_name], SZ_FNAME )
	# see if we can clobber the output file
	clobber = clgetb("clobber")
	# put on an extension
	call rootname(Memc[DS_FILENAME(FP_OBSERSTACK(fp, 1))],
		      Memc[output_name], EXT_GRD, SZ_FNAME)
	# get temp name
	call clobbername(Memc[output_name], Memc[temp_name], clobber, SZ_FNAME)

	# see if we want to do the final fit
	final = clgetb("final")
	# get vebose flag
	verbose     = clgetb( VERBOSE )

	# if rebin is set quit because to is useless to use.
	if ( clgetb( "rebin") ) {
	    call error(1, "The 'rebin' parameter will cause a null result in search_grid")
	}

	call malloc (  x, LEN_GS_AXIS, GS_AXIS_TYPE)
	call malloc (  y, LEN_GS_AXIS, GS_AXIS_TYPE)
	best_chisq  = MAX_REAL

	# show the user the models he has to choose from
	call printf("\nThe chisquare grid will be built around the following model parameters:\n")
	call show_model_data(fp)
	# save the model string
	imodel = FP_MODSTR(fp)

	call printf("Please choose the grid axes:\n")

	call get_axis_info ( fp, x, X_PREFIX )
	call get_axis_info ( fp, y, Y_PREFIX )
	maxv = GS_STEPS(y)
	maxh = GS_STEPS(x)
	call malloc ( chisq_array, (maxv*maxh), TY_REAL)
	# seed chisq with a large number, in case we skip some grid points
	call amovkr(MAX_REAL, Memr[chisq_array], (maxv*maxh))
	# allocate space to store the grid point values
	call salloc(xvals, GS_STEPS(x), TY_REAL)
	call salloc(yvals, GS_STEPS(y), TY_REAL)

	# assume no bad values
	badval = NO

	# perform the fit at each grid point

	do v = 1, maxv {
	    do h = 1, maxh {

		# re-initialize input model before calculating each grid point
		if ( mod_parse(fp, Memc[FP_MODSTR(fp)], 0) == NO ) {
		    call error(1, " couldn't recalculate model")
		}
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)) =
								    FIXED_PARAM
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(y)),GS_PARAM(y)) =
								    FIXED_PARAM

		# adjust grid point values to next point in grid
		call adj_params( fp, x, y, v, h, YES, Memr[xvals], Memr[yvals])

		# skip if temp < 0
		switch ( GS_MODELTYPE(x) ) {

		case BLACK_BODY, EXP_PLUS_GAUNT, RAYMOND:
		    if ( GS_PARAM(x) == MODEL_TEMP ) {
			model = FP_MODELSTACK(fp, GS_MODEL(x))
			if ( MODEL_PAR_VAL(model, GS_PARAM(x)) < 0.0 ) {
			    call printf("skipping negative temp at (%d %d)\n")
			     call pargi(h)
			     call pargi(v)
			     call flush(STDOUT)
			    badval = YES
			    next
			}
		    }
		}

		switch ( GS_MODELTYPE(y) ) {
		case BLACK_BODY, EXP_PLUS_GAUNT, RAYMOND:

		    if ( GS_PARAM(y) == MODEL_TEMP ) {
			model = FP_MODELSTACK(fp, GS_MODEL(y))
			if ( MODEL_PAR_VAL(model, GS_PARAM(y)) < 0.0 ) {
			    call printf("skipping negative temp at (%d %d)\n")
			     call pargi(h)
			     call pargi(v)
			     call flush(STDOUT)
			    badval = YES
			    next
			}
		    }
		}

		# this is where all of the work is done!

		chisq = grid_point( fp )
		Memr[chisq_array+(v-1)*maxh+(h-1)] = chisq

		if ( verbose ) {
		    call print_grid ( fp, x, y, v, h, chisq )
		}

		if ( chisq < best_chisq ) {
		    best_chisq = chisq
		    best_v = v
		    best_h = h
		}
	    }
	}

	# adjust params so that their values are for best fit
	call adj_params( fp, x, y, best_v, best_h, NO, 0.0, 0.0)
	call printf( " Best grid fit found at" )
	call print_grid ( fp, x, y, best_v, best_h, best_chisq )

	if ( final ) {

	    # now re-initialize model and free up the grid
	    # parameters for the final fit

	    if ( mod_parse(fp, Memc[FP_MODSTR(fp)], 0) == NO ) {
		call error(1, " couldn't recalculate model for final fit")
	    }

	    if ( GS_FREETYPE(x) != CALC_PARAM ) {
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)) =
								    FREE_PARAM
	    }
	    else {
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)) =
								    CALC_PARAM
	    }
	    if ( GS_FREETYPE(y) != CALC_PARAM ) {
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(y)),GS_PARAM(y)) =
								    FREE_PARAM
	    }
	    else {
		MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(y)),GS_PARAM(y)) =
								    CALC_PARAM
	    }

	    # now free up the grid parameters for the final fit

	    # reset grid values and deltas to be based on the range of the
	    # input model and the range of the grid, calculated earlier
	    # determine the boundary values for x and y
	    # we calculate the lo and hi value, both in the grid and also
	    # for the parameters's delta (if its free).  Later on, we will
	    # compare the boundaries with the best fit value (at x and y)
	    # to determine the delta over which to allow the final fit to vary
	    call final_lims_gotten(fp, x, last_xval, last_xdelta, badval)
	    call final_lims_gotten(fp, y, last_yval, last_ydelta, badval)

	    MODEL_PAR_VAL(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)) =
								last_xval

	    MODEL_PAR_DLT(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)) =
								last_xdelta

	    MODEL_PAR_VAL(FP_MODELSTACK(fp,GS_MODEL(y)),GS_PARAM(y)) =
								last_yval

	    MODEL_PAR_DLT(FP_MODELSTACK(fp,GS_MODEL(y)),GS_PARAM(y)) =
								last_ydelta

	    # reset links to fixed, if necessary
	    if ( GS_FREETYPE(x) != FREE_PARAM ) {

		# set all of the links
		call mod_set_link(fp,
		    MODEL_PAR_LINK(FP_MODELSTACK(fp,GS_MODEL(x)),GS_PARAM(x)),
			FREE_PARAM)
	    }

	    if ( GS_FREETYPE(y) != FREE_PARAM ) {

		# set all of the links
		call mod_set_link(fp,
		    MODEL_PAR_LINK(FP_MODELSTACK(fp,GS_MODEL(y)), GS_PARAM(y)),
			FREE_PARAM)
	    }

	    # display what we are using for the final fit
	    call printf("\nThe final fit will be performed using the following model:\n")
	    call get_omodel_string(fp, Memc[omodel], SZ_LINE)
	    call strcat("\n", Memc[omodel], SZ_LINE)
	    # reset the input model to be the current model
	    FP_MODSTR(fp) = omodel
	    call show_model_data(fp)

	    # perform the final fit
	    chisq = final_chisq( fp )

	    call printf("\nThe final best fit parameters are:\n")
	    call get_best_string(fp, Memc[best], SZ_LINE)
	    call strcat("\n", Memc[best], SZ_LINE)
	    # reset the input model to be the current model
	    FP_MODSTR(fp) = best
	    call show_model_data(fp)
	}

	else {

	    chisq = best_chisq
	    call get_omodel_string(fp, Memc[omodel], SZ_LINE)
	    call get_best_string(fp, Memc[best], SZ_LINE)
	}

	# write the output grid file
	call grid_output( Memc[temp_name], fp, x, y, chisq, Memr[chisq_array],
			  Memr[xvals], Memr[yvals],
			  Memc[imodel], Memc[omodel], Memc[best], badval)

	# reset model name
	FP_MODSTR(fp) = imodel

	# free up allocated space
	call mfree ( x, GS_AXIS_TYPE)
	call mfree ( y, GS_AXIS_TYPE)
	call mfree ( chisq_array, TY_REAL)

	# get final name
	call printf("Output Grid file: %s\n")
	 call pargstr(Memc[output_name])

	call finalname(Memc[temp_name], Memc[output_name])
	return (chisq)

end
# 
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

real procedure grid_point( fp )

pointer	fp			# data structure for parameters
real	chisq

int	ct_params()
real	simplex_search()
real	calc_chisq()

begin

	if ( (ct_params(fp,FREE_PARAM) + ct_params(fp,CALC_PARAM) ) > 0 ) {
	    chisq = simplex_search( fp )
	}
	else {
	    call single_fit ( fp )
	    chisq = calc_chisq ( fp )
	}

	return (chisq)

end


#
#  FINAL_CHISQ -- called once the frame pointer has been set up
#	this is a copy of fp_chisq without print.  fp_chisq needs
#	to be called in grid_fit so that the chisq's are correctly
#	udpated.
#

real procedure final_chisq (fp)

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
real	ss_chisq

real	chisq()
real	simplex_search()

begin

	call smark (sp)

	ss_chisq = simplex_search( fp )

	n_sets = FP_DATASETS(fp)
	totcs = 0.0

	if ( n_sets > 0 )  {
	    do dataset = 1, n_sets {
		ds = FP_OBSERSTACK(fp,dataset)
		filename = DS_FILENAME(ds)
		nbins    = DS_NPHAS(ds)
		observed = DS_OBS_DATA(ds)
		predicted= DS_PRED_DATA(ds)
		errors   = DS_OBS_ERROR(ds)
		flags    = DS_CHANNEL_FIT(ds)
		contrib  = DS_CHISQ_CONTRIB(ds)
		call salloc (energies, (nbins+1), TY_REAL)
		call salloc (variance, (nbins+1), TY_REAL)
		call pha_energy (ds, Memr[energies], (nbins+1))
		cs = chisq(Memr[observed], Memr[predicted], Memr[errors],
			   Memi[flags], Memr[variance], Memr[contrib], nbins,
			   total_counts, total_error)
		totcs = totcs + cs
	    }
	}

	if ( ( abs((totcs/ss_chisq) -1) > 1.0e-6 ) &&
	     ( abs(totcs - ss_chisq)      > 0.05   )    ) {

	    call printf("warning: problem with chisqs in search_grid %f %f\n")
	     call pargr(ss_chisq)
	     call pargr(totcs)
	     call flush(STDOUT)
	    }
	call sfree (sp)

	return(totcs)

end

#
# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  adj_params( fp, xx, yy, vv, hh, fill, xvals, yvals)

pointer	 fp			# data structure for parameters
pointer	 xmodel			# data structure for x axis model
pointer	 ymodel			# data structure for y axis model
pointer	 xx			# data structure for X axis
pointer	 yy			# data structure for Y axis
int	 vv, hh			# grid indices
int	 fill			# flag that we fill xvals, yvals
real	 xvals[ARB]		# x grid values
real	 yvals[ARB]		# y grid values

real	 lin_interp(),  log_interp()

begin
	xmodel = FP_MODELSTACK(fp, GS_MODEL(xx))
	ymodel = FP_MODELSTACK(fp, GS_MODEL(yy))
#
	if( GS_AXISTYPE(xx) == LINEAR_AXIS )
	    MODEL_PAR_VAL(xmodel, GS_PARAM(xx)) = lin_interp(xx, hh)
	else
	    MODEL_PAR_VAL(xmodel, GS_PARAM(xx)) = log_interp(xx, hh)
	if( GS_AXISTYPE(yy) == LINEAR_AXIS )
	    MODEL_PAR_VAL(ymodel, GS_PARAM(yy)) = lin_interp(yy, vv)
	else
	    MODEL_PAR_VAL(ymodel, GS_PARAM(yy)) = log_interp(yy, vv)
	# store the grid values, if necessary
	if( fill == YES ){
	    xvals[hh] = MODEL_PAR_VAL(xmodel, GS_PARAM(xx))
	    yvals[vv] = MODEL_PAR_VAL(ymodel, GS_PARAM(yy))
	}
end
# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

real  procedure  lin_interp ( axis, step )

pointer	 axis				# axis data structure
int	 step				# index on axis
real	 new_value

begin
	if( GS_STEPS(axis) > 1 )  {
	    new_value = GS_PAR_VALUE(axis) + 
			GS_DELTA(axis)*(2.0*(step-1)/(GS_STEPS(axis)-1)-1.0)
	    }
	else
	    new_value = GS_PAR_VALUE(axis)
	return (new_value)
end

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

real  procedure  log_interp ( axis, step )

pointer  axis				# axis data structure
int      step				# index on axis
real     new_value

begin
	if( GS_STEPS(axis) > 1 )  {
	    new_value = GS_PAR_VALUE(axis) *
			GS_DELTA(axis)**(2.0*(step-1)/(GS_STEPS(axis)-1)-1.0)
	    }
	else {
	    new_value = GS_PAR_VALUE(axis)
	}
	return (new_value)
end
# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  grid_output(table, fp, x, y, best_chisq, chisq_array, xvals, yvals,
				imodel, omodel, best, badval)

char	table[ARB]			# i: table name
pointer	fp				# i: frame pointer
pointer	x				# i: X axis data structure
pointer y				# i: Y axis data structure
real	best_chisq			# i: best chisquare value
real	chisq_array[ARB]		# i: grid results
real	xvals[ARB]			# i: x grid point values
real	yvals[ARB]			# i: y grid point values
char	imodel[ARB]			# i: input model string
char	omodel[ARB]			# i: final model string
char	best[ARB]			# i: best model string
int	badval				# i: flag if bad value

char	cbuf[SZ_LINE]			# l: temp char buffer
char	obsfiles[SZ_OBSSTR]		# l: string of obs files
char	chanstr[SZ_OBSSTR]		# l: channel string
char	tbuf[20]			# l: temp char buffer
int	h				# l: horizantal loop counter
int	v				# l: vertical loop counter
int	i				# l: loop counter
pointer	dataset				# l: data set index
pointer	tp				# l: table pointer
pointer	cp				# l: column pointers
pointer	sp				# l: stack pointer
pointer	dsname				# l: data set name

int	tbtopn()

begin
	# mark the stack
	call smark(sp)
	# allocate space for the column pointers
	call salloc(cp, GS_STEPS(x)+1, TY_POINTER)

	# open a new table	
	tp = tbtopn(table, NEW_FILE, 0)
        call tbcdef(tp, Memi[cp],  "y\x", "", "%6.4f", TY_REAL, 1, 1)
	# define grid columns
	do i=1, GS_STEPS(x){
	    call sprintf(cbuf, SZ_LINE, "%.4f")
	    call pargr(xvals[i])
	    call tbcdef(tp, Memi[cp+i],  cbuf, "", "%6.2f", TY_REAL, 1, 1)
	}
	# create the table
	call tbtcre(tp)

	# write models to header
	call mod_nocr(imodel)
	call tbhadt(tp, "imodel", imodel)
	call mod_nocr(omodel)
	call tbhadt(tp, "fitmodel", omodel)
	if( badval == YES )
	    call tbhadt(tp, "COMMENT", "warning - above omodel was adjusted to avoid negative temp")
	call mod_nocr(best)
	call tbhadt(tp, "best", best)

	# write input obs files to header
	obsfiles[1] = EOS
	# collect all obs file names
	do i = 1, FP_DATASETS(fp)  {
	    dsname = DS_FILENAME(FP_OBSERSTACK(fp, i))
	    dataset = FP_OBSERSTACK(fp,i)
	    # append this obs file to the string of obs files
	    call strcat(Memc[dsname], obsfiles, SZ_OBSSTR)
	    # get channels
	    call ds_channels(Memi[DS_CHANNEL_FIT(dataset)], DS_NPHAS(dataset),
			     chanstr, SZ_OBSSTR)
	    # copy them to the obs file string
	    call strcat(chanstr, obsfiles, SZ_OBSSTR)
	    if( i == FP_DATASETS(fp) )
		call strcat("\n", obsfiles, SZ_OBSSTR)
	    else

		call strcat("; ", obsfiles, SZ_OBSSTR)
	}
	call tbhadt(tp, "ifiles", obsfiles)
	# write absorption to header
	call strcpy("abs", cbuf, SZ_LINE)
	switch(FP_ABSORPTION(fp)){
	case MORRISON_MCCAMMON:
	    call tbhadt(tp, cbuf, "morrison_maccammon")
	case BROWN_GOULD:
	    call tbhadt(tp, cbuf, "brown_gould")
	default:
	    call tbhadt(tp, cbuf, "unknown")
	}

	# write the best chi-square value
	call tbhadr(tp, "best_chi", best_chisq)
	# write coordinates of the best chisq
	call tbhadr(tp, "best_x",
		MODEL_PAR_VAL(FP_MODELSTACK(fp,GS_MODEL(x)), GS_PARAM(x)))
	call tbhadr(tp, "best_y",
		MODEL_PAR_VAL(FP_MODELSTACK(fp,GS_MODEL(y)), GS_PARAM(y)))

	# add the x axis information
	call emission_str(GS_MODELTYPE(x), cbuf )
	call tbhadt(tp, "x_model", cbuf)
	# add the param type
	call get_pname(GS_PARAM(x), GS_MODELTYPE(x), cbuf, SZ_LINE)
	call tbhadt(tp, "x_param", cbuf)
	call tbhadi(tp, "x_steps", GS_STEPS(x))
	if( GS_AXISTYPE(x) == LINEAR_AXIS )
	    call tbhadt(tp, "x_axistype", "linear")
	else
	    call tbhadt(tp, "x_axistype", "log")
	call tbhadr(tp, "x_val", GS_PAR_VALUE(x))
	call tbhadr(tp, "x_delta", GS_DELTA(x))

	# add the y axis information
	call emission_str(GS_MODELTYPE(y), cbuf )
	call tbhadt(tp, "y_model", cbuf)
	# add the param type
	call get_pname(GS_PARAM(y), GS_MODELTYPE(y), cbuf, SZ_LINE)
	call tbhadt(tp, "y_param", cbuf)
	call tbhadi(tp, "y_steps", GS_STEPS(y))
	if( GS_AXISTYPE(y) == LINEAR_AXIS )
	    call tbhadt(tp, "y_axistype", "linear")
	else
	    call tbhadt(tp, "y_axistype", "log")
	call tbhadr(tp, "y_val", GS_PAR_VALUE(y))
	call tbhadr(tp, "y_delta", GS_DELTA(y))

	# put the column names to the header for later retrieval (by grid_plot)
	# it would be nicer if we could get them directly from the table
	# file with a tb call, but I can't find one!
	do i=1, GS_STEPS(x){
	    call sprintf(tbuf, 20, "col_%d")
	    call pargi(i)
	    call sprintf(cbuf, SZ_LINE, "%.4f")
	    call pargr(xvals[i])
	    call tbhadt(tp, tbuf, cbuf)
	}

	# write the table data
	do v = 1, GS_STEPS(y)  {
	    # for each row, write the y step value
	    call tbrptr(tp, Memi[cp], yvals[v], 1, v)
	    # write all of the x chi-square values
	    do h = 1, GS_STEPS(x)  {
		call tbrptr(tp, Memi[cp+h],
			chisq_array[((v-1)*GS_STEPS(x)+h)], 1, v)
	    }
	}

	# close the table file
	call tbtclo(tp)
	# free up space
	call sfree(sp)
end

#
#  GET_PNAME -- get the name of a parameter
#
procedure get_pname(param, model, name, len)

int	param				# i: param type
int	model				# i: model type
char	name[ARB]			# o: param name
int	len				# i: length of name

begin
	switch(param)  {
	case MODEL_TEMP:
		call emission_ab ( model, name )
	case MODEL_ALPHA:
		call strcpy ( "normalization (log)", name, len )
	case MODEL_INTRINSIC:
		call strcpy ( "intrinsic Nh (log)", name, len )
	case MODEL_GALACTIC:
		call strcpy ( "galactic Nh (log)", name, len )
	case MODEL_REDSHIFT:
		call strcpy ( "redshift", name, len )
	case MODEL_WIDTH:
		call strcpy ( "width", name, len )
	default:
		call strcpy ( "  ", name, len )
	}
end

#
# FINAL_LIMS_GOTTEN -- determine the final boundary values for x and y parameters
# we calculate the lo and hi value, based on the grid limits and also the
# original input model limits
#
procedure final_lims_gotten(fp, x, val, delta, badval)

pointer fp					# frame pointer
pointer x					# data struct for axis
real	val					# parameter value
real	delta					# parameter delta
int	badval					# true if we adjusted a value

int	model					# model index
real	minval					# temp min value
real	maxval					# temp max value

begin

	# get x model index
	model = FP_MODELSTACK(fp, GS_MODEL(x))

	# get min value of input and grid
	minval = GS_PAR_VALUE(x) - GS_DELTA(x)
	if( GS_FREETYPE(x) == FREE_PARAM )
		minval = min(minval, GS_PAR_VALUE(x) -
					MODEL_PAR_DLT(model, GS_PARAM(x)))

	# get max value of input and grid
	maxval = GS_PAR_VALUE(x) + GS_DELTA(x)
	if( GS_FREETYPE(x) == FREE_PARAM )
		maxval = max(maxval, GS_PAR_VALUE(x) +
					MODEL_PAR_DLT(model, GS_PARAM(x)))

	# for temperature, make sure min and max are not negative
	if ( GS_MODELTYPE(x) != POWER_LAW ) {
		if ( GS_PARAM(x) == MODEL_TEMP ) {
			if ( minval < 0.0 ) {
				call printf("\nWarning: final fit low temp limit < 0 - adjusting to 0\n")
			minval = 0.0
			badval = YES
			}
			if ( maxval < 0.0 ) {
				call error(1, "can't have final fit max temp < 0")
			}
		}
	}

	# now get the val and delta for the final fit
	val = (minval + maxval)/2.0
	delta = (maxval - minval)/2.0
end
