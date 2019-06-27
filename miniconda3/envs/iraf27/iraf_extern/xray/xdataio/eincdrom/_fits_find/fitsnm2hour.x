#$Log: fitsnm2hour.x,v $
#Revision 11.0  1997/11/06 16:36:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:15  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:25  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:45:04  prosb
#General Release 2.3
#
#Revision 6.1  93/08/31  13:35:14  prosb
#(dvs) Checking in upper-to-lowercase change, and changing
#error message given when FITS file is invalid.
#
#Revision 6.0  93/05/24  17:12:04  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:37:01  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:31:55  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fits_find/RCS/fitsnm2hour.x,v 11.0 1997/11/06 16:36:46 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       fitsnm2hour.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	fitsnm2hour
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
# Procedure:	fitsnm2hour
#
# Purpose:      To extract the RA hour from the FITS name.
#
# Input variables:
#		fitsnm    	fits file name
#
# Output variables:
#               hour        	the "hour" of the fits file
#		hourst      	the two-character version of the hour
#		display		text display level (0=none, 5=full)
#
# Description:  The second and third characters of the FITS file name on
#		the Einstein CDs indicate the RA hour of that data. (The
#		FITS files are organized by RA hours on the CDs.) This
#		routine finds the RA hour from the FITS name.
#
# Algorithm:    * check that fits file length is at least 3 characters
#		* create hour string from second and third digits
#		* check that the string contains only digits
#		* convert hour string to an integer
#		* check that the hour is between 0 and 23
#		* if any of the conditions failed, give an error
#
# Notes:	This routine will return an error under the following
#		conditions:
#
#		   * if there aren't at least three characters in the
#		     FITS file name
#		   * if the second and third characters aren't digits
#		   * if the RA hour is not between 0 and 23.
#
#--------------------------------------------------------------------------

procedure ff_fitsnm2hour (fitsnm,hour,hourst,display)

### PARAMETERS ###

char    fitsnm[ARB] 	# name of FITS file
int     hour	      	# the RA "hour" of the FITS file
char    hourst[ARB]   	# the string version of the above "hour"
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

bool    is_fits_ok    	# true if FITS file has proper format to read hour

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()      	# returns length of string [sys/fmtio]
bool    isalldigits() 	# returns true if string is all digits
  
### BEGINNING OF PROCEDURE ###

begin
	is_fits_ok = false

	# Check that fits file length is at least 3 characters
	 if (strlen(fitsnm) >= 3 )
	 {  
	    # create hour string from second and third digits
	     call strcpy(fitsnm[2],hourst,2)

	    # check that the string contains only digits
	     if (isalldigits(hourst))
	     {
	        # convert hour string to an integer
	         call sscan(hourst)
	          call gargi(hour)

	        # check that the hour is between 0 and 23
	         if (hour>=0 && hour<=23)
	         {
	            is_fits_ok=true
	         }
  	         else
	     	 {
	            # maybe the user typed in a letter followed by a
		    # sequence number instead of a sequence number?
		     call eprintf("\nRA hour of %d from FITS filename %s ")
		      call pargi(hour)
		      call pargstr(fitsnm)
	             call eprintf("is invalid.  Is %s REALLY\nthe filename?\n")
                      call pargstr(fitsnm)
	         }
	     }
	 }

	# if any of the conditions failed, give an error
	 if (! is_fits_ok)
	 {
	    call errstr(ECD_BADFNFMT, 
		"Invalid FITS filename",fitsnm)
	 }

	 if (display>4)
	 {
	    call printf(" RA hour found from FITS name: %d.\n")
	     call pargi(hour)
	 }
end
