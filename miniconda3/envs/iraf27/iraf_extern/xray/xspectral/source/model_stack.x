#$Header: /home/pros/xray/xspectral/source/RCS/model_stack.x,v 11.0 1997/11/06 16:42:46 prosb Exp $
#$Log: model_stack.x,v $
#Revision 11.0  1997/11/06 16:42:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:05  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:02  prosb
#General Release 2.1
#
#Revision 4.1  92/10/01  11:52:46  prosb
#jso - changed the name so that it was compatible with predicated=append.
#
#Revision 4.0  92/04/27  18:16:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:32  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:33  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:20:56  prosb
#so - made spectral.h system wide
#
#Revision 2.2  91/05/24  11:41:13  pros
#jso - added extra output line
#
#Revision 2.1  91/05/10  11:47:36  pros
#lengthen the size of the inout model stack buffer from SZ_FNAME to SZ_LINE
#
#Revision 2.0  91/03/06  23:05:12  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  model_stack.x   ---   prepare stack of pointers to models

include  <spectral.h>

#  parameter definition
define  MODEL_FILE		"model"
define  ABSORPTION_TYPE		"absorption_type"




#
#  MAKE_MODEL_STACK -- create the model stack from a model descriptor
#
int  procedure  make_model_stack( fp )

pointer fp			# i: fitting parameters structure
char	model_descr[SZ_LINE]	# l: model descriptor
char    abs_string[SZ_LINE]	# l: type of absorption
int	absorption_type()	# l: look up absorption type
int	mod_parse()		# l: parse a model descriptor
bool	streq()			# l: string compare

begin
	# fetch the model descriptor
10	call clgstr (MODEL_FILE, model_descr, SZ_LINE)
	if( streq("?", model_descr) ){
	    call help_models()
	    goto 10
	}
	
	# null string means try to get the model descriptor from the prd file
	if( streq("", model_descr) ){
	    call ds_gmodstr(FP_OBSERSTACK(fp,1), "omod",
				model_descr, SZ_LINE)
	    call printf("model from file: %s\n")
	    call pargstr(model_descr)
	}

	# get the absorption type
        call clgstr( ABSORPTION_TYPE, abs_string, SZ_LINE)
        FP_ABSORPTION( fp ) = absorption_type( abs_string )

	# parse the model descriptor and create the model stack
	if( mod_parse(fp, model_descr, 0) == NO ){
	    call error(1, "couldn't create model stack")
	}
	# and return the model count
	return(FP_MODEL_COUNT(fp))
	
end

#
#  FREE_MODEL_STACK -- Routine to free up memory taken by the model stack.
#
procedure  free_model_stack ( fp )

pointer	 fp		# parameter structure
int	 n_models	# number of models
int	 i		# loop index
pointer	 model		# model pointer

begin
	# free each of the models
	n_models = FP_MODEL_COUNT(fp)
	if( n_models > 0 )  {
	    do i = 1, n_models{
		model = FP_MODELSTACK(fp,i)
		# free up the component spectra
		call mfree(MODEL_EMITTED(model), TY_DOUBLE)
		call mfree(MODEL_INTRINS(model), TY_DOUBLE)
		call mfree(MODEL_REDSHIFTED(model), TY_DOUBLE)
		call mfree(MODEL_INCIDENT(model), TY_DOUBLE)
		# free up the model struct
		call mfree (model, TY_INT)
	    }
	}
	# free up the model descriptor string
	call mfree(FP_MODSTR(fp), TY_CHAR)
end
