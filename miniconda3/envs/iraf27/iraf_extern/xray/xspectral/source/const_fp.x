#$Header: /home/pros/xray/xspectral/source/RCS/const_fp.x,v 11.0 1997/11/06 16:41:52 prosb Exp $
#$Log: const_fp.x,v $
#Revision 11.0  1997/11/06 16:41:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:08  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:40  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:24  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:56  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:36:08  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:01:57  pros
#General Release 1.0
#
#  const_fp.x   ---   Routines to construct the fit parameter data structure.
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

include	 <spectral.h>

#
#  CONST_FP -- Routine to build the data structure.
#
procedure  const_fp ( fp )

pointer	 fp				# structure pointer
int      make_model_stack(),  make_obser_stack()

begin
	# create the frame
        call malloc( fp, LEN_FP, TY_INT )
	# create the total spectra
	call calloc(FP_EMITTED(fp), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(FP_INTRINS(fp), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(FP_REDSHIFTED(fp), SPECTRAL_BINS, TY_DOUBLE)
	call calloc(FP_INCIDENT(fp), SPECTRAL_BINS, TY_DOUBLE)

	if( make_obser_stack(fp) <= 0 )
	    call printf("No observed data sets were found! \n")

	if( make_model_stack(fp) <= 0 )
	    call printf("No model data was found! \n")
end

#
# RAZE_FP --  Routine to destroy the fitting data structure.
#
procedure  raze_fp ( fp )

pointer	 fp				# structure pointer
int	 dataset

begin
	# free up data sets
	if( FP_DATASETS(fp) > 0 )  {
	    do dataset = 1, FP_DATASETS(fp)
		call raze_ds (FP_OBSERSTACK(fp,dataset))
	    }
	# free up the model stack
        call free_model_stack (fp)
	# free up the component spectra
	call mfree(FP_EMITTED(fp), TY_DOUBLE)
	call mfree(FP_INTRINS(fp), TY_DOUBLE)
	call mfree(FP_REDSHIFTED(fp), TY_DOUBLE)
	call mfree(FP_INCIDENT(fp), TY_DOUBLE)
	# free up the frame pointer
        call mfree( fp, TY_INT )
end
