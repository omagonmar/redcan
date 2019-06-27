#$Header: /home/pros/xray/xspectral/source/RCS/output_fit.x,v 11.0 1997/11/06 16:43:00 prosb Exp $
#$Log: output_fit.x,v $
#Revision 11.0  1997/11/06 16:43:00  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:06  prosb
#General Release 2.3
#
#Revision 6.1  93/08/23  19:04:50  dennis
#Changed extension for chi-square table file from EXT_CHI to EXT_CSQ, 
#to avoid naming collision with period's EXT_CHI file.
#
#Revision 6.0  93/05/24  16:51:56  prosb
#General Release 2.2
#
#Revision 5.1  93/01/30  12:44:47  prosb
#jso - fix the output to be new still so that it can be input with a null.
#      see bug report 240.
#
#Revision 5.0  92/10/29  22:45:43  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/05  12:26:11  orszak
#jso - one line change to make the best model have output with more precision
#
#Revision 3.1  91/09/22  19:06:46  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:51  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  16:31:43  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/24  11:43:38  pros
#jso/eric - change the way the model is written out to table file
#	      added three arguements for line model
#
#Revision 2.0  91/03/06  23:06:19  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  OUTPUT_FIT.X -- write out fit results
#
include <mach.h>

include <ext.h>
include  <spectral.h>

# define cl param name
define  PRED_PREFERENCE  "predicted"
define  CHISQUARE_DB	 "chisquare"
define  INTERMED	 "intermediate"

# define user preference codes for predicted data
define	NOTHING		1
define	NEWFILE		2
define	APPENDFILE	3

# define the size of the chi square string parameter
define SZ_CHISTR	80
# define the size of the model string parameter
define SZ_MODSTR	160

#
#  SAVE_FIT_RESULTS -- save results of a fit
#
procedure  save_fit_results ( fp, chisq, fit )

pointer	fp			# data structure for fitting parameters
real	chisq			# chi-squared result
char	fit[ARB]		# fit type

begin
	call output_spectra( fp, chisq, fit )
end

#
#  OUTPUT_SPECTRA -- save predicted spectra in prd file
#
procedure  output_spectra (fp, chisq, fit)

pointer	fp			# i: parameter data structure
real	chisq			# i: chi-square
char	fit[ARB]		# i: fit type

char	buf[SZ_LINE]		# l: temp char string
char	iname[SZ_PATHNAME]	# l: obs file or old pred file
char	oname[SZ_PATHNAME]	# l: new pred fle
char	temp[SZ_PATHNAME]	# l: temp output file name
char	chiname[SZ_PATHNAME]	# l: chisquare data base file
char	intname[SZ_PATHNAME]	# l: intermediate spectral file
char	inttemp[SZ_PATHNAME]	# l: temp intermediate spectral file name
char	obsfiles[SZ_CHISTR]	# l: string for obs names
char	prdfiles[SZ_CHISTR]	# l: string for prd names
char	chanstr[SZ_CHISTR]	# l: string for channels
char	best[SZ_MODSTR]		# l: best model param string after fit
char	imodel[SZ_MODSTR]	# l: input model
char	omodel[SZ_MODSTR]	# l: output model
int	i			# l: loop counter
int	n			# l: prd number in each file
int	pref			# l: preference code
int	dataset			# l: data set index
real	comp_chi		# l: component chisqfor each data set
pointer	dsname			# l: obs data set file name
bool	clobber			# l: clobber output files?

int	tbtacc()		# l: existence of a table file
bool	clgetb()		# l: get boolean parameter
bool	strne()			# l: string compare

begin
	# get user's preference for how to deal with the predicted data
	call clgstr( PRED_PREFERENCE, buf, SZ_PATHNAME )
	call get_pred_pref(buf, pref)
	# if we do nothing, just return
	if( pref == NOTHING )
	    return
	# get clobber param
	clobber = clgetb("clobber")
	# get chi square file name
	call clgstr(CHISQUARE_DB, chiname, SZ_PATHNAME)
	call rootname(Memc[DS_FILENAME(FP_OBSERSTACK(fp, 1))],
		      chiname, EXT_CSQ, SZ_PATHNAME)
	# get intermediate spectra file name
	call clgstr(INTERMED, intname, SZ_PATHNAME)
	call rootname(Memc[DS_FILENAME(FP_OBSERSTACK(fp, 1))],
		      intname, EXT_INT, SZ_PATHNAME)
	# make sure we can clobber the file
	call clobbername(intname, inttemp, clobber, SZ_PATHNAME)
	# null out obsfiles and prdfiles
	obsfiles[1] = EOS
	prdfiles[1] = EOS

	# get the model string
	call get_best_string(fp, best, SZ_MODSTR)

	# get the model string
	call get_omodel_string(fp, omodel, SZ_MODSTR)

	# write a predicted data files
	do i = 1, FP_DATASETS(fp)  {
	    dsname = DS_FILENAME(FP_OBSERSTACK(fp, i))
	    dataset = FP_OBSERSTACK(fp,i)
	    switch(pref){
	    # if newfile, copy the obs data file to the prd file
	    case NEWFILE:
		# input file is the obs file
		call strcpy(Memc[dsname], iname, SZ_PATHNAME)
		# get predicted file name from observed
		call get_prdname(Memc[dsname], oname, SZ_PATHNAME)
		# make sure we can clobber the file
		call clobbername(oname, temp, clobber, SZ_PATHNAME)
	    # if appendfile, copy the old prd file if it exists
	    case APPENDFILE:
		# get predicted file name from observed
		call get_prdname(Memc[dsname], oname, SZ_PATHNAME)
		# if prd file exists ...
		if( tbtacc(oname) == YES ){
		    # use it for input
		    call strcpy(oname, iname, SZ_PATHNAME)
		    # fake the clobbername
		    call clobbername(oname, temp, true, SZ_PATHNAME)
		}
		else{
		    # use the obs file for input
		    call strcpy(Memc[dsname], iname, SZ_FNAME)
		    # fake the clobbername results
		    call strcpy(oname, temp, SZ_FNAME)
		}
	    }
	    # get component chi square
	    call comp_chisq(dataset, comp_chi)
	    # write the output prd file
	    # get rid of all spaces, tabs, and CR's at end
	    call strcpy(Memc[FP_MODSTR(fp)], imodel, SZ_MODSTR)
	    call mod_nocr(imodel)
	    call mod_nocr(omodel)
	    call mod_nocr(best)
	    call ds_append(dataset, iname, temp, chisq, comp_chi,
			   FP_ABSORPTION(fp),
			   imodel, best, omodel,
			   fit, SZ_CHISTR, n)

	    # and rename prd file to final name
	    call printf("Predicted Data file: %s\n")
	     call pargstr(oname)

	    call finalname(temp, oname, SZ_PATHNAME)
	    # add the name and the prd # to the chisquare string
	    # we will write this final string to each prd file in turn
	    call sprintf(buf, SZ_LINE, "%s #%d")
	    call pargstr(oname)
	    call pargi(n)
	    # append this obs file to the string of obs files
	    call strcat(Memc[dsname], obsfiles, SZ_CHISTR)
	    # get channels
	    call ds_channels(Memi[DS_CHANNEL_FIT(dataset)], DS_NPHAS(dataset),
			     chanstr, SZ_CHISTR)
	    # copy them to the obs file string
	    call strcat(chanstr, obsfiles, SZ_CHISTR)
	    if( i != FP_DATASETS(fp) )
		call strcat("; ", obsfiles, SZ_CHISTR)
	    # append this prd file to the string of prd files
	    call strcat(buf, prdfiles, SZ_CHISTR)
	    if( i != FP_DATASETS(fp) )
		call strcat("; ", prdfiles, SZ_CHISTR)
	}
	# now write the output predicted data files into each prd file
	do i = 1, FP_DATASETS(fp)  {
	    # get input file name
	    dsname = DS_FILENAME(FP_OBSERSTACK(fp, i))
	    # get predicted file name from observed
	    call get_prdname(Memc[dsname], oname, SZ_PATHNAME)
	    # and write the string of obs files into this one obs file
	    call ds_obsfiles(oname, obsfiles)
	    # and write the string of prd files into this one prd file
	    call ds_prdfiles(oname, prdfiles)
	}
	# write chisquare info into the data base, if necessary
	if( strne(chiname, "NONE") ){
	    call ds_chisquare(fp, chiname, chisq, prdfiles, SZ_CHISTR,
						  best, SZ_MODSTR)
	}
	# write intermediate spectra, if necessary
	if( strne(intname, "NONE") ){
	    call int_output(inttemp, fp, best)

	    call printf("Intermediate Spectra file: %s\n")
	     call pargstr(intname)

	    call finalname(inttemp, intname, SZ_PATHNAME)
	}
end

#
# GET_PRED_PREF -- get user preference about predicted data
#
procedure get_pred_pref(buf, pref)

char	buf[SZ_LINE]		# i: user-input preference string
int	pref			# o: preference code
int	strdic()

string	prefs	"|none|newfile|appendfile|"

begin
	switch(strdic(buf, buf, SZ_LINE, prefs)) {
	case 1:
		pref = NOTHING
	case 2:
		pref = NEWFILE
	case 3:
		pref = APPENDFILE
	default:
		pref = APPENDFILE
	}
end

#
#  GET_BEST_STRING -- get the model string of best fit values
#
procedure get_best_string(fp, best, len)

pointer	fp				# i: frame pointer
char	best[ARB]			# o: model string
int	len				# i: length of model string

begin
	call get_model_string(fp, best, len, 1)
end

#
#  GET_OMODEL_STRING -- get the model string of best fit values
#
procedure get_omodel_string(fp, omodel, len)

pointer	fp				# i: frame pointer
char	omodel[ARB]			# o: omodel string
int	len				# i: length of model string

begin
	call get_model_string(fp, omodel, len, 2)
end

#
#  GET_MODEL_STRING -- get the model string in short form for param storage
#
procedure get_model_string(fp, model, len, flag)

pointer	fp				# i: frame pointer
char	model[ARB]			# o: model string
int	len				# i: length of model string
int	flag				# i: 1=best, 2=omodel

char	tbuf[SZ_LINE]			# l: temp char buffer
char	ebuf[SZ_LINE]			# l: emission name
int	i				# l: model loop counter
int	code				# l: model code
pointer	model_ptr			# l: model pointer

int	strlen()			# l: string length

begin
	# clear the model string
	model[1] = EOS
	# loop through models
	do i = 1, FP_MODEL_COUNT(fp)  {
	    # start with a fresh copy of the string buffer
	    tbuf[1] = EOS
	    # get pointer to next model
	    model_ptr = FP_MODELSTACK(fp,i)
	    # get code for emitter type
	    code = MODEL_TYPE(model_ptr)
	    # get absorption
	    call get_model_abs(model_ptr, tbuf, SZ_LINE, flag)
	    # get name of emission type
	    call emission_str(code, ebuf)
	    # copy the only first 3 letters!
	    ebuf[4] = EOS
	    call strcat(ebuf, tbuf, SZ_LINE)
	    # append open paren
	    call strcat("(", tbuf, SZ_LINE)
	    # get model args
	    call get_model_param(model_ptr, MODEL_ALPHA, tbuf, SZ_LINE, flag)
	    call get_model_param(model_ptr, MODEL_TEMP, tbuf, SZ_LINE, flag)
	    if( code == RAYMOND ){
		if(MODEL_ABUNDANCE(model_ptr) == MEYER_ABUNDANCE)
		    call strcat("meyer ", tbuf, SZ_LINE)
		else
		    call strcat("cosmic ", tbuf, SZ_LINE)
		call sprintf(tbuf[strlen(tbuf)+1], len, "%d,")
		call pargi(MODEL_PERCENTAGE(model_ptr))
	    }
	    if( code == SINGLE_LINE )
 	        call get_model_param(model_ptr, MODEL_WIDTH,
				     tbuf, SZ_LINE, flag)
	    # add the closed paren (and overwrite the last arg comma)
	    call sprintf(tbuf[strlen(tbuf)], SZ_LINE, ")+")
	    # copy this model to the output
	    call strcat(tbuf, model, len)
	}
	# null out the last semi-colon
	model[strlen(model)] = EOS
end

#
#  GET_MODEL_ABS -- get absorption params
#
procedure get_model_abs(model_ptr, tbuf, len, flag)

pointer	model_ptr			# i: model pointer
char	tbuf[ARB]			# o: output string
int	len				# i: length of string
int	flag				# i: 1=best, 2=omodel

int	strlen()			# l: string length

begin
	# add the galactic absorption
	if( (abs(MODEL_PAR_VAL(model_ptr,MODEL_GALACTIC)) > EPSILON) ||
	    (MODEL_PAR_LINK(model_ptr,MODEL_INTRINSIC)!=0) ){
	    call sprintf(tbuf[strlen(tbuf)+1], len, "abs(")
	    call get_model_param(model_ptr, MODEL_GALACTIC, tbuf, len, flag)
	    # add the closed paren and operator(overwrite the last arg comma)
#	    call sprintf(tbuf[strlen(tbuf)], len, ")*")
#	}
	   # add the intrinsic absorption
	   if( (abs(MODEL_PAR_VAL(model_ptr,MODEL_INTRINSIC)) > EPSILON) ||
	    (MODEL_PAR_LINK(model_ptr,MODEL_INTRINSIC)!=0) ){
#	    call sprintf(tbuf[strlen(tbuf)+1], len, "abs(")
		call get_model_param(model_ptr, MODEL_INTRINSIC,
							tbuf, len, flag)
		call get_model_param(model_ptr, MODEL_REDSHIFT,
							tbuf, len, flag)
	    }
	    # add the closed paren and operator(overwrite the last arg comma)
	    call sprintf(tbuf[strlen(tbuf)], len, ")*")
	}
end

#
#  GET_MODEL_PARAM -- get a parameter (and assoc. modefiers) for a model
#
procedure get_model_param(model_ptr, arg, tbuf, len, flag)

pointer	model_ptr			# i: model pointer
int	arg				# i: argument in model
char	tbuf[ARB]			# o: output string
int	len				# i: length of string
int	flag				# i: 1=best, 2=omodel

int	strlen()			# l: string length

begin
# it appears that we need the link information for the parameters
# in the best fit case, not just in the omodel case
# jeff and eric -- 5/10/91

	# if this is a link, just write link number
	if(MODEL_PAR_LINK(model_ptr,arg) <0){
	    call sprintf(tbuf[strlen(tbuf)+1], len, "L%d ")
	    call pargi(abs(MODEL_PAR_LINK(model_ptr,arg)))
	    return
	}

	# add free flag and delta, if necessary
	if( flag == 1 ){
	    call sprintf(tbuf[strlen(tbuf)+1], len, "%.4f")
	    call pargr(MODEL_PAR_VAL(model_ptr,arg))
	}
	else{
	    if(MODEL_PAR_FIXED(model_ptr,arg) == FIXED_PARAM){
		call sprintf(tbuf[strlen(tbuf)+1], len, "%.4f")
		call pargr(MODEL_PAR_VAL(model_ptr,arg))
	    }
	    else if(MODEL_PAR_FIXED(model_ptr,arg) == FREE_PARAM){
		call sprintf(tbuf[strlen(tbuf)+1], len, "%.4f")
		call pargr(
		    MODEL_PAR_VAL(model_ptr,arg)-MODEL_PAR_DLT(model_ptr,arg))
		call strcat(":", tbuf, len)
		call sprintf(tbuf[strlen(tbuf)+1], len, "%.4f")
		call pargr(
		    MODEL_PAR_VAL(model_ptr,arg)+MODEL_PAR_DLT(model_ptr,arg))
	    }
	    else
		return
	}

	# add the link number
	if(MODEL_PAR_LINK(model_ptr,arg) >0){
	    call sprintf(tbuf[strlen(tbuf)+1], len, "L%d")
	    call pargi(abs(MODEL_PAR_LINK(model_ptr,arg)))
	}

	# add argument separator
	call strcat(" ", tbuf, len)
end

#
#  mod_nocr -- remove trailing CR from model
#
procedure mod_nocr(model)

char	model[ARB]			# i: model
int	j				# l: loop counter
int	strlen()			# l: string length

begin
	j = strlen(model)
	while( ((model[j] == '\n')	||
	        (model[j] == ' ' )	||
	        (model[j] == '\t' ))	&&
	       (j>0) ){
	    model[j] = EOS
	    j = j-1
	}
end
