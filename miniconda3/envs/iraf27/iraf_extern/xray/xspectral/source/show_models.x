#$Header: /home/pros/xray/xspectral/source/RCS/show_models.x,v 11.0 1997/11/06 16:43:20 prosb Exp $
#$Log: show_models.x,v $
#Revision 11.0  1997/11/06 16:43:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:08  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:58  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:47  prosb
#General Release 2.2
#
#Revision 5.1  93/05/05  17:28:58  prosb
#jso - changed emission measure to normalization to properly agree with
#      documentation.
#
#Revision 5.0  92/10/29  22:46:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:18:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:17  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:08  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:44:03  prosb
#jso - made spectral.h system wide and added call for new pset parameeter
#
#Revision 2.0  91/03/06  23:07:26  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#	main task routine to display all the model info

include	<spectral.h>

procedure  t_smodels ()

pointer	fp			# data structure for fitting parameters
pointer	np

int	make_model_stack()	# makes model pointers in above structure

pointer clopset()

begin

	np = clopset("pkgpars")
	call malloc( fp, LEN_FP, TY_INT )

	if( make_model_stack( fp ) > 0 ){
	    call show_model_data( fp )
	    call free_model_stack( fp )
	    }
	  else
	    call printf(" No model parameters are currently defined! \n")

	call mfree( fp, TY_INT )
	call clcpset(np)

end

#
#  FP_SMODELS -- called once the frame pointer has been set up
#	( we don't want to call t_smodels from other tasks)
#
procedure  fp_smodels (fp)

pointer	fp			# data structure for fitting parameters

begin
	if( FP_MODEL_COUNT(fp) >0 )
	    call show_model_data(fp)
	else
	    call printf(" No model parameters are currently defined! \n")
end


# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
procedure  show_model_data ( fp )

pointer	fp				# fitting parameters structure
pointer	sp				# stack pointer
pointer	emitter_type			# name of emission type
pointer param_type			# parameter type for emission
pointer	free_type			# freedom type for the parameter
pointer	model_ptr			#
int	model				# index into model array
int	code				# emission type code
int	percent				# abundance percentage

# 

begin
	call smark( sp )
	call salloc( emitter_type, SZ_LINE, TY_CHAR)
	call salloc( param_type,   SZ_LINE, TY_CHAR)
	call salloc( free_type,    SZ_LINE, TY_CHAR)

	# display the model descriptor
	call printf("\nModel: %s\n")
	call pargstr(Memc[FP_MODSTR(fp)])

#	# display the type of absorption
#	call printf("absorption type: %s\n")
#	switch(FP_ABSORPTION(fp)){
#	case MORRISON_MCCAMMON:
#	    call pargstr("morrison_maccammon")
#	case BROWN_GOULD:
#	    call pargstr("brown_gould")
#	default:
#	    call pargstr("unknown")
#	}

#	for each model, convert codes to strings and print them
	do model = 1, FP_MODEL_COUNT(fp)  {
	    model_ptr = FP_MODELSTACK(fp,model)
	    code = MODEL_TYPE(model_ptr)
	    call emission_name( code, Memc[emitter_type] )
	    call emission_ab( code, Memc[param_type] )
	    call printf ( "Model Component %d: %s \n" )
	    call pargi ( MODEL_NUMBER(model_ptr) )
	    call pargstr ( Memc[emitter_type] )

	    # display the temperature
	    call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_TEMP),
		Memc[free_type])
	    call show_link( MODEL_PAR_LINK(model_ptr,MODEL_TEMP),
		Memc[free_type])
	    if( code == RAYMOND )  {
		percent = MODEL_PERCENTAGE(model_ptr)
		if( MODEL_ABUNDANCE(model_ptr) == MEYER_ABUNDANCE )  {
		    call printf("          Meyer abundance at %d percent. \n" )
            	    call pargi ( percent )
		}
		else  {
		    call printf("          Cosmic abundance at %d percent.\n")
                    call pargi ( percent )
		}
	    }
	    call printf ( "          %s = %0.3f (%s) \n" )
	    call pargstr ( Memc[param_type] )
	    call show_best_val(model_ptr, MODEL_TEMP)
	    call pargstr ( Memc[free_type] )
	    # single line width
	    if( code == SINGLE_LINE ){
		call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_WIDTH),
		    Memc[free_type])
		call show_link( MODEL_PAR_LINK(model_ptr,MODEL_WIDTH),
		    Memc[free_type])
		call printf ( "          line width = %0.3f (%s) \n" )
		call show_best_val(model_ptr, MODEL_WIDTH)
		call pargstr ( Memc[free_type] )
	    }

	    # display the alpha
	    call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_ALPHA),
		Memc[free_type])
	    call show_link( MODEL_PAR_LINK(model_ptr,MODEL_ALPHA),
		Memc[free_type])
	    if( code == RAYMOND ){
		call printf ( " normalization (log) = %f (%s) \n" )
		call show_best_val(model_ptr, MODEL_ALPHA)
	    }
	    else{
		call printf ( "    normalization (log) = %0.4f (%s) \n" )
		call show_best_val(model_ptr, MODEL_ALPHA)
	    }
	    call pargstr ( Memc[free_type] )

	    # display galactic absorption
	    call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_GALACTIC),
		Memc[free_type])
	    call show_link( MODEL_PAR_LINK(model_ptr,MODEL_GALACTIC),
		Memc[free_type])
	    call printf ( "    galactic Nh (log) = %0.3f (%s) \n" )
	    call show_best_val(model_ptr, MODEL_GALACTIC)
	    call pargstr ( Memc[free_type] )

	    # display intrinsic emission
	    call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_INTRINSIC),
		Memc[free_type])
	    call show_link( MODEL_PAR_LINK(model_ptr,MODEL_INTRINSIC),
		Memc[free_type])
	    call printf ( "    intrinsic Nh (log) = %0.3f (%s) \n" )
	    call show_best_val(model_ptr, MODEL_INTRINSIC)
	    call pargstr ( Memc[free_type] )

	    # display redshift
	    call emission_fix( MODEL_PAR_FIXED(model_ptr,MODEL_REDSHIFT),
		Memc[free_type])
	    call show_link( MODEL_PAR_LINK(model_ptr,MODEL_REDSHIFT),
		Memc[free_type])
	    call printf ( "          redshift = %0.3f (%s) \n" )
	    call show_best_val(model_ptr, MODEL_REDSHIFT)
	    call pargstr ( Memc[free_type] )
	    call printf ( "\n" )
	}

	call sfree( sp )
end

#
#  SHOW_BEST_VAL -- show best value
#
procedure show_best_val(model_ptr, type)

pointer	model_ptr				# i: model pointer
int	type					# i: param type

begin
	call pargr(MODEL_PAR_VAL(model_ptr,type))
end

#
# SHOW_LINK -- show the link state of a parameter
#
procedure show_link(link, buf)

int	link			# i: link value
char	buf[ARB]		# o: output buffer
char	tbuf[SZ_LINE]		# temp buffer

begin
	# skip if no link
	if( link ==0 )
	    return
	call strcat(" L", buf, SZ_LINE)
	call sprintf(tbuf, SZ_LINE, "%d")
	call pargi(link)
	call strcat(tbuf, buf, SZ_LINE)
end

#
# SHOW_DLT -- show the delta of a parameter
#
procedure show_dlt(delta, buf)

real	delta			# i: param delta value
char	buf[ARB]		# o: output buffer
char	tbuf[SZ_LINE]		# temp buffer

begin
	call sprintf(tbuf, SZ_LINE, " %.2f")
	call pargr(delta)
	call strcat(tbuf, buf, SZ_LINE)
end

