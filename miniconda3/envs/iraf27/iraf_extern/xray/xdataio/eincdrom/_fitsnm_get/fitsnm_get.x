#$Log: fitsnm_get.x,v $
#Revision 11.0  1997/11/06 16:36:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:19  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:45:10  prosb
#General Release 2.3
#
#Revision 6.1  93/10/04  12:14:02  dvs
#Changed case of "isalldigits" to lowercase.
#
#Revision 6.0  93/05/24  17:12:10  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:37:39  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:33:00  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fitsnm_get/RCS/fitsnm_get.x,v 11.0 1997/11/06 16:36:48 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       fitsnm_get.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	t_fitsnm_get
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
# Procedure:	t_fitsnm_get
#
# Purpose:      To return the fits name corresponding to the passed in
#		specifier
#
# Input parameters: 
#               dataset     	which Einstein dataset (ipc, hri, etc.)    
#		specifier   	filename OR sequence number
#		display		text display level (0=none, 5=full)
#
# Output parameters:
#               fitsnm      	the return fits name
#
# Description:  This task returns a FITS file name corresponding to the
#		passed in specifier.  If the specifier is a filename
#		already, then the fits name is simply the specifier.
#
#               Otherwise, we must look up the fits name in the appropriate
#               sequence number index file (associated with the dataset).
#
# Algorithm:    * allocate stack space
#		* get parameters
# 		* strip whitespace off specifier
# 		* check that specifier is not empty string
#		* if specifier is a sequence number
#		    * find value of specifier
#                   * call fn_seq2fitsnm to convert sequence number to
#			FITS name
#                 otherwise,
#		    * copy specifier to fitsnm
#               * set output parameters
#               * free memory stack
#--------------------------------------------------------------------------

procedure t_fitsnm_get()

### PARAMETERS ###

pointer dataset       	# which Einstein dataset (ipc, hri, etc.)
pointer specifier     	# filename OR number identifying a file
pointer fitsnm        	# name of output FITS file
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

int     seq	      	# sequence number, if specifier is not a filename
pointer sp	      	# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

int	clgeti()	# returns integer parameter [sys/clio]
bool    isalldigits() 	# returns true if string is all digits
bool	streq()		# returns true if strings are equal [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin

	# allocate stack space 
	 call smark(sp)
	 call salloc( dataset, SZ_DATASET, TY_CHAR)
	 call salloc( specifier, SZ_FNAME, TY_CHAR)
	 call salloc( fitsnm, SZ_FNAME, TY_CHAR)

	# get parameters
	 call clgstr("dataset",Memc[dataset], SZ_DATASET)
	 call clgstr("specifier",Memc[specifier], SZ_FNAME)
	 display=clgeti("display")

	 if (display>4)
	 {
	    call printf("**** Entering fitsnm_get ****\n")
	 }

	# strip whitespace off specifier
	 call strip_whitespace(Memc[specifier])

	# check that specifier is not empty string.
	 if (streq(Memc[specifier],""))
	 {
	    call error(ECD_SPECNOTEMPTY,
		"Specifier must be non-empty.")
	 }
	 
	# Is specifier all digits? 
	 if (isalldigits(Memc[specifier]))
	 {
	    # find value of specifier
	     call sscan(Memc[specifier])
	      call gargi(seq)

	    # get the fits name associated with the sequence number
	     call fg_seq2fitsnm(seq,Memc[dataset],Memc[fitsnm],display)
	 }
	 else # specifier is a filename
	 {
	    # copy specifier to variable fitsnm
	     call strcpy(Memc[specifier],Memc[fitsnm],SZ_FNAME)
	 } 

	# set output parameters
	 call clpstr("fitsnm",Memc[fitsnm])

	# Free memory stack
	 call sfree (sp)   

	 if (display>4)
	 {
	    call printf("**** Exiting fitsnm_get ****\n")
	 }
end


