#$Log: _fits_get_obs.cl,v $
#Revision 11.0  1997/11/06 16:36:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:56  prosb
#General Release 2.3.1
#
#Revision 7.2  94/06/01  12:13:27  prosb
#Changed _fits_get to _fits_get_obs
#
#Revision 7.1  94/05/04  11:09:00  prosb
#Moved from fits_get.cl to _fits_get.cl.
#
#Revision 7.0  93/12/27  18:46:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:16  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:47:43  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/RCS/_fits_get_obs.cl,v 11.0 1997/11/06 16:36:36 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       fits_get.cl
# Project:      PROS -- EINSTEIN CDROM
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Task:		fits_get
#
# Purpose:      To locate and copy a fits file from on-line Einstein
#		CDs to the current directory 
#
# Input parameters:
#               dataset     	which Einstein dataset (ipc, hri, etc.)
#		specifier   	FITS filename OR sequence number
#		clobber		overwrite output qpoe file?
#		display		text display level (0=none, 5=full)
#
# Description:  This task locates the FITS file name (corresponding to
#		the specifier) and copies it into the current directory.
#		If the user enters a sequence number as a specifier,
#		this task will first find the corresponding FITS filename
#		by looking in the sequence number index file for the dataset.
#
# Algorithm:    * copy automatic parameters into local vars
#		* call _fitsnm_get to find the name of the FITS file
#		* call _fits_find to find the pathname of the FITS file
#		* call _cp_wo_attr to copy the FITS file into the current
#		  directory, without copying the attributes 
#
# Notes:	We must use _cp_wo_attr since on the CD the fits files are
#		write-protected.  (The IRAF routine "copy" will first
#		copy the file attributes before copying the contents
#		of the file, thus causing an error for these fits files.)
#
#--------------------------------------------------------------------------

procedure fits_get (dataset,specifier)

### PARAMETERS ###

string 	dataset		# which Einstein dataset (ipc, hri, slew)
string 	specifier	# FITS filename OR sequence number
bool 	clobber 	# overwrite qpoefile?
int  	display 	# text display level (0=none, 5=full)
pset	eincdpar     	# PSET to use for eincdrom parameters

begin

### LOCAL VARS ###

	string	c_dataset    	# local copy of parameter "dataset"
	string	c_specifier  	# local copy of parameter "specifier"
	file	fitsname     	# name of fits file to copy
	file	fitspath     	# path of fits file to copy

### BEGINNING OF CL SCRIPT ###

	# copy automatic parameters into local vars
	 c_dataset   = dataset
	 c_specifier = specifier

	# call _fitsnm_get to find the name of the FITS file
	 _fitsnm_get (c_dataset,c_specifier,display=display,eincdpar=eincdpar)
	 fitsname  = _fitsnm_get.fitsnm

  	# call _fits_find to find the pathname of the FITS file
   	 _fits_find(c_dataset,fitsname,display=display,eincdpar=eincdpar)
     	 fitspath=_fits_find.fits_path

	# call _cp_wo_attr to copy the FITS file into the current
	# directory, without copying the attributes 
   	 _cp_wo_attr (fitspath, fitsname, clobber=clobber)

	 if (display>0)
   	 {
     	    	print("")
     	    	print("Copied ",fitspath," to the current directory.")
     	    	print("")
   	 } 

end
