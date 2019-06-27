#$Log: fits_find.x,v $
#Revision 11.0  1997/11/06 16:36:45  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:22  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:45:02  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:12:01  prosb
#General Release 2.2
#
#Revision 1.2  93/04/28  09:54:40  prosb
#This routine will now give an error if it can not find either the
#FITS file or the time-corrections file.
#
#Revision 1.1  93/04/13  09:36:43  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:31:54  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fits_find/RCS/fits_find.x,v 11.0 1997/11/06 16:36:45 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       fits_find.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	t_fits_find
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <iraf.h>
include "../source/dataset.h"
include "../source/ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:	t_fits_find
# Module:       fits_find.x
# Project:      PROS -- EINSTEIN CDROM
# Purpose:      To return the path of a given FITS file on an Einstein
#		CD.
#
# Input parameters: 
#               dataset:     which Einstein dataset (ipc, hri, etc.)    
#		fitsname:    name of fits file
#
# Output parameters:
#		fits_path:   path of fits file
#		tca_path:    path of time correction file
#               cd_dir:      top directory of cd containing fits file
#
# Description:  This task is given a FITS file name and returns the
#		full pathnames of the FITS file on the proper Einstein CD,
#		as well as the time correction file (if there is one)
#		associated with that FITS file.  Also returns the 
#		directory of the CD.
#
#		This task gives an error if the FITS file (or time
#		correction file, if there should be one) is not readable.
#
# Algorithm:    * allocate stack space
#		* get parameters
#		* convert dataset string to dataset index
#		* strip whitespace off FITS name
#		* get the hour from the FITS name
#		* get the CD directory
#		* check that CD directory exists
#		* get the fits pathname and tca pathname
#		* check that fits pathname and tca pathname exist
#               * set output parameters
#               * free memory stack
#
# Notes:	Some datasets will not have a tca pathname.  In these
#		cases, the output parameter will be empty.
#--------------------------------------------------------------------------

procedure t_fits_find()

### PARAMETERS ###

pointer dataset       	# which Einstein dataset (ipc, hri, etc.)
pointer p_fitsnm        # pointer to name of FITS file
pointer p_cd_dir	# pointer to directory of cd
pointer p_fits_path     # pointer to pathname of fits file
pointer p_tca_path      # pointer to pathname of tca file

### LOCAL VARS ###

int     i_dataset      	# index of dataset
int     hour          	# the "hour" of the fits file
char    hourst[2]     	# two digits corresponding to hour string
pointer sp	      	# stack pointer
int	display		# text display level (0=none, 5=full)

### EXTERNAL FUNCTION DECLARATIONS ###

int     dataset2index() # returns dataset index
bool	access()	# returns true if file is accessible [sys/fio]
bool	strne()		# returns true if strings differ [sys/fmtio]
int  	clgeti()	# returns integer parameter [sys/clio]
    
### BEGINNING OF PROCEDURE ###

begin

	# allocate stack space 
	 call smark(sp)
	 call salloc( dataset, SZ_DATASET, TY_CHAR)
	 call salloc( p_fitsnm, SZ_FNAME, TY_CHAR)
	 call salloc( p_cd_dir, SZ_FNAME, TY_CHAR)
	 call salloc( p_fits_path, SZ_FNAME, TY_CHAR)
	 call salloc( p_tca_path, SZ_FNAME, TY_CHAR)

	 # get parameters
	 call clgstr("dataset",Memc[dataset], SZ_DATASET)
	 call clgstr("fitsname",Memc[p_fitsnm], SZ_FNAME)
	 display=clgeti("display")

	 if (display>4)
	 {
	    call printf("**** Entering fits_find ****\n")
	 }

	# convert dataset string to dataset index
	 i_dataset=dataset2index(Memc[dataset])

	# strip whitespace off FITS name
	 call strip_whitespace(Memc[p_fitsnm])

	# get the hour from the FITS name
	 call ff_fitsnm2hour(Memc[p_fitsnm],hour,hourst,display)

	# get the CD directory
	 call ff_cd_dir_get(i_dataset,hour,Memc[p_cd_dir],display)

	# check that CD directory exists
	 if (!access(Memc[p_cd_dir],0,0))
	 {
	    call errstr(ECD_CANTFINDDIR,
		"Can't find CD directory which should contain the FITS file",Memc[p_cd_dir])
	 }

	# get the fits pathname and tca pathname
	 call ff_fits_path_get(i_dataset,Memc[p_fitsnm],hourst,
				Memc[p_cd_dir],Memc[p_fits_path],display)
	 call ff_tca_path_get(i_dataset,Memc[p_fitsnm],hourst,
				Memc[p_cd_dir],Memc[p_tca_path],display) 

	# Do they exist?
	 if (!access(Memc[p_fits_path],READ_ONLY,0))
	 {
	    call errstr(ECD_CANTREADFILE,"Can't read FITS file",
                           Memc[p_fits_path])
	 }

	 if (strne(Memc[p_tca_path],"") && 
	           !access(Memc[p_tca_path],READ_ONLY,0))
	 {
	    call errstr(ECD_CANTREADFILE,
               "Can't read time correction file",Memc[p_tca_path])
	 }

	
	# set output parameters
	 call clpstr("fits_path",Memc[p_fits_path])
	 call clpstr("tca_path",Memc[p_tca_path])
	 call clpstr("cd_dir",Memc[p_cd_dir])
   
	# Free memory stack
	 call sfree (sp)   

	 if (display>4)
	 {
	    call printf("**** Exiting fits_find ****\n")
	 }
end

