#$Log: cd_find.x,v $
#Revision 11.0  1997/11/06 16:36:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:20  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  13:55:33  prosb
#Modified header constants (EIN_SLEW->SLEW, etc.)
#
#Revision 7.0  93/12/27  18:44:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:58  prosb
#General Release 2.2
#
#Revision 1.2  93/04/18  16:19:12  prosb
#Added eoscat and hriimg datasets.
#
#Revision 1.1  93/04/13  09:36:17  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:31:52  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fits_find/RCS/cd_find.x,v 11.0 1997/11/06 16:36:44 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       cd_find.x
# Project:      PROS -- EINSTEIN CDROM
# Purpose:	Tasks which find the appropriate files/directories on the
#		Einstein CDs.
# External:	(none)
# Local:	ff_cd_dir_get, ff_fits_path_get, ff_tca_path_get
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
# Procedure:	ff_cd_dir_get
#
# Purpose:      To find the actual cd directory containing the FITS file
#
# Input variables:
#               i_dataset    	index of dataset
#               hour        	the RA "hour" of the FITS file
#		display		text display level (0=none, 5=full)
#
# Output parameters:
#               cd_dir      	top directory of cd containing FITS file
#
# Description:  This routine finds the cd which contains the passed
#		RA hour for the passed dataset.
#
#		The cd directory is found by associating the hour with
#               the correct cd directory parameter (which depends on
#		the dataset).
#
# Algorithm:    * open PSET
#		* find directory of CD
#		* close PSET
#--------------------------------------------------------------------------

procedure ff_cd_dir_get(i_dataset,hour,cd_dir,display)
int     i_dataset      	# dataset index
int     hour	      	# the RA "hour" of the FITS file
char 	cd_dir[ARB]   	# directory of cd
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

pointer pp	      	# PSET pointer

### EXTERNAL FUNCTION DECLARATIONS ###

pointer clopset()     	# returns pset pointer [sys/clio]
  
### BEGINNING OF PROCEDURE ###

begin
	# open PSET
	 pp = clopset("eincdpar")

	# find directory of CD
	 switch (i_dataset) {
    
	  case IPC_EVT:

	    if (hour < 6)       # 00h through 05h
	    {
	       call clgpseta(pp,"ipcevt1",cd_dir,SZ_FNAME)
	    }
	    else if (hour < 13) # 06h through 12h
	    {
	       call clgpseta(pp,"ipcevt2",cd_dir,SZ_FNAME)
	    }
	    else if (hour < 18) # 13h through 17h
	    {
	       call clgpseta(pp,"ipcevt3",cd_dir,SZ_FNAME)
	    }
	    else                # 18h through 23h
	    {
	       call clgpseta(pp,"ipcevt4",cd_dir,SZ_FNAME)
            }

	  case HRI_EVT:

	    if (hour < 14)       # 00h through 13h
	    {
	       call clgpseta(pp,"hrievt1",cd_dir,SZ_FNAME)
	    }
	    else                 # 14h through 23h
	    {
	       call clgpseta(pp,"hrievt2",cd_dir,SZ_FNAME)
	    }

	  case HRI_IMG:

	    if (hour < 14)       # 00h through 13h
	    {
	       call clgpseta(pp,"hriimg1",cd_dir,SZ_FNAME)
	    }
	    else                 # 14h through 23h
	    {
	       call clgpseta(pp,"hriimg2",cd_dir,SZ_FNAME)
	    }

	  case EOSCAT:

	    if (hour < 8)        # 00h through 07h
	    {
	       call clgpseta(pp,"eoscat1",cd_dir,SZ_FNAME)
	    }
	    else if (hour < 16)  # 08h through 15h
	    {
	       call clgpseta(pp,"eoscat2",cd_dir,SZ_FNAME)
	    }
	    else                 # 16h through 23h
	    {
	       call clgpseta(pp,"eoscat3",cd_dir,SZ_FNAME)
	    }

	  case SLEW:

	    call clgpseta(pp,"slewcd",cd_dir,SZ_FNAME)

	  default:
	      call errori(ECD_BADDATASET,
		"CD_DIR_GET: Do not recognize dataset index",i_dataset)
	 }

	# close pset
	 call clcpset(pp)

	 if (display>4)
	 {
	    call printf(" Using the following cd directory: %s.\n")
	     call pargstr(cd_dir)
	 }
end

#--------------------------------------------------------------------------
# Procedure:	ff_fits_path_get
#
# Purpose:      To find the pathname of the FITS file
#
# Input variables:
#               i_dataset    	index of dataset
#		fitsnm    	FITS file name
#		hourst      	the two-character version of the RA hour
#               cd_dir      	top directory of cd containing FITS file
#		display		text display level (0=none, 5=full)
#
# Output parameters:
#		fits_path   	path of FITS file
#
# Description:  This routine takes the FITS file and finds the
#		full pathnames of the FITS file on the cd. 
#		The FITS pathname is simply the cd directory with the
#               appropriate directory (usually depending on the RA hour)
#		and FITS name appended.
#--------------------------------------------------------------------------

procedure ff_fits_path_get(i_dataset,fitsnm,hourst,cd_dir,fits_path,display)
int     i_dataset      	# dataset index
char    fitsnm[ARB] 	# name of FITS file
char    hourst[ARB]   	# the two-character version of the RA hour
char 	cd_dir[ARB]   	# directory of cd
char 	fits_path[ARB]	# pathname of fits file
int	display		# text display level (0=none, 5=full)

begin
	# Create fits_path 
	 switch (i_dataset) {
    
	  case IPC_EVT, HRI_EVT, EOSCAT, HRI_IMG, SLEW:

	    call sprintf(fits_path,SZ_FNAME,"%sdata/%sh/%s")
	     call pargstr(cd_dir)
	     call pargstr(hourst)
	     call pargstr(fitsnm)

	  default:
	      call errori(ECD_BADDATASET,
		"FITS_PATH_GET: Do not recognize dataset index",i_dataset)
	 }

	 if (display>4)
	 {
	    call printf(" Fits file path found: %s.\n")
	     call pargstr(fits_path)
	 }
end

#--------------------------------------------------------------------------
# Procedure:	ff_tca_path_get
#
# Purpose:      To find the pathname of the time corrections file
#
# Input variables:
#               i_dataset    	index of dataset
#		fitsnm    	FITS file name
#		hourst      	the two-character version of the RA hour
#               cd_dir      	top directory of cd containing FITS file
#		display		text display level (0=none, 5=full)
#
# Output parameters:
#		tca_path   	path of time correction file
#
# Description:  This routine takes the FITS file and finds the
#		time correction file (if there is one) associated with that
#		FITS file. 
#
#		The time correction pathname is found (for IPC & HRI) by
#		appending the appropriate directory (depending on the
#		RA hour) and the tca file name.  This file name is
#		obtained by copying the FITS file name and replacing
#		the second-to-last and third-to-last characters with "tc".
#		(Thus I0007N10.XPA becomes I0007n10.tcA.)
#
# Algorithm:    * allocate stack space
#		* check that FITS file name has at least 3 characters
#		* create time correction file name
#		* create time correction pathname
#               * free memory stack
#--------------------------------------------------------------------------

procedure ff_tca_path_get(i_dataset,fitsnm,hourst,cd_dir,tca_path,display)
int     i_dataset      	# dataset index
char    fitsnm[ARB]   	# name of FITS file
char    hourst[ARB]   	# the string version of the above "hour"
char 	cd_dir[ARB]   	# directory of cd
char 	tca_path[ARB] 	# pathname of tca file
int	display

### LOCAL VARS ###

int     fitsnm_len    	# length of the FITS file name
pointer sp	      	# stack pointer
pointer tca_fname     	# time correction file name

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()      	# returns length of string [sys/fmtio]
  
### BEGINNING OF PROCEDURE ###

begin
	# allocate stack space
	 call smark(sp)
	 call salloc( tca_fname, SZ_FNAME, TY_CHAR)

	# check that FITS file name has at least 3 characters
	 fitsnm_len=strlen(fitsnm)
	 if (fitsnm_len < 3)
	 {
	    call errstr(ECD_BADFNFMT, 
		"FITS filename is unexpectedly short",fitsnm)
	 }

	# Create time correction file name by copying the fits name
	# and replacing the third-to-last and second-to-last characters
	# with "tc".
	 call strcpy(fitsnm,Memc[tca_fname],fitsnm_len-3)
	 call strcat("tc",Memc[tca_fname],SZ_FNAME)
	 call strcat(fitsnm[fitsnm_len],Memc[tca_fname],SZ_FNAME)

	# Create tca pathname
	 switch (i_dataset) {
    
	  case IPC_EVT:
	    call sprintf(tca_path,SZ_FNAME,"%sauxdata/timcor/%sh/%s")
	     call pargstr(cd_dir)
	     call pargstr(hourst)
	     call pargstr(Memc[tca_fname])

	  case HRI_EVT:
	    call sprintf(tca_path,SZ_FNAME,"%sauxdata/timecor/%sh/%s")
	     call pargstr(cd_dir)
	     call pargstr(hourst)
	     call pargstr(Memc[tca_fname])

	  case SLEW, EOSCAT, HRI_IMG:
	    call strcpy("",tca_path,SZ_FNAME)  # no time-correction files

	  default:
	      call errori(ECD_BADDATASET,
		"CA_PATH_GET: Do not recognize dataset index",i_dataset)
	 }

	# Free memory stack
	 call sfree (sp)

	 if (display>4)
	 {	
	    if (strlen(tca_path)>0)
	    {
		call printf(" Time correction path found: %s.\n")
		 call pargstr(tca_path)
	    }
	    else
	    {
		call printf(" No time correction file.\n")
	    }
	 }
end
