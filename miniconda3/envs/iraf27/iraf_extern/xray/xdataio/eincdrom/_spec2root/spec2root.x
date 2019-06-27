#$Log: spec2root.x,v $
#Revision 11.0  1997/11/06 16:36:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:45:24  prosb
#General Release 2.3
#
#Revision 6.1  93/10/04  12:14:52  dvs
#Changed case of "isalldigits" to lowercase.
#
#Revision 6.0  93/05/24  17:12:24  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:39:09  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_spec2root/RCS/spec2root.x,v 11.0 1997/11/06 16:36:51 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       spec2root.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	t_spec2root
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
# Procedure:	t_spec2root
#
# Purpose:      To convert the specifier into the proper root
#		extension to use for various eincdrom CL scripts.
# 
# Input parameters: 
#               dataset     	which Einstein dataset (ipc, hri, etc.)    
#		specifier   	filename OR number identifying a file
#		display		text display level (0=none, 5=full)
#
# Output parameters:
#               root        	the return root extension
#
# Description:  This task creates a root string used to construct filenames
#		in various CL scripts in the eincdrom package.  The root
#		is formed as follows:
#		   IF the specifier is all digits,
#		     THEN
#		          the root is formed by taking the first letter of
#		          the dataset and appending the specifier
#		     ELSE
#		          the root is the specifier up to, but not 
#                         including, its first "."
#
# Algorithm:    * allocate stack space
#		* get parameters
# 		* strip whitespace off specifier
# 		* check that specifier is not empty string
#		* if specifier is all digits,
#		   * Remove leading 0's by converting the string into a number.
#                  * create the root by taking first character of dataset
#		     and appending the specifier
#                 otherwise,
#		   * find the position of the first "." in the specifier
#                  * copy the specifier up to that position into the root
#               * set output parameters
#               * free memory stack
#
# Comments:	This task does not output any text, since it is to be
#		used as a hidden task in CL scripts.
#		
# Known bugs:   If the specifier starts or ends with spaces, or if
#              	it begins with "+" or "-", it is not considered a
#               number.
# 		
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
#
# Modified:     {0} David Van Stone -- 3/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#
#--------------------------------------------------------------------------

procedure t_spec2root()

### PARAMETERS ###

pointer	dataset       	# which Einstein dataset (ipc, hri, etc.)
pointer specifier     	# filename OR number identifying a file
pointer root	      	# the return root extension
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

int     pt_pos        	# position of the point (".") in the specifier
int	spec_value	# the value of the specifier, if it is a number
pointer sp	      	# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

int	clgeti()	# returns integer parameter [sys/clio]
bool    isalldigits() 	# returns true if string is all digits
int     stridx()      	# returns first index of char in string [sys/fmtio]
bool	streq()		# returns true if strings are equal [sys/fmtio]
  
### BEGINNING OF PROCEDURE ###

begin

	# allocate stack space
	 call smark(sp)
	 call salloc( dataset, SZ_DATASET, TY_CHAR)
	 call salloc( specifier, SZ_FNAME, TY_CHAR)
	 call salloc( root, SZ_FNAME, TY_CHAR)

	# get parameters
	 call clgstr("dataset",Memc[dataset], SZ_DATASET)
	 call clgstr("specifier",Memc[specifier], SZ_FNAME)
	 display=clgeti("display")

	 if (display>4)
	 {
	    call printf("**** Entering spec2root ****\n")
	 }

	# strip whitespace off specifier
	 call strip_whitespace(Memc[specifier])

	# check that specifier is not empty string
	 if (streq(Memc[specifier],""))
	 {
	    call error(ECD_SPECNOTEMPTY,
		"Specifier must be non-empty.")
	 }
	 
	# Is specifier all digits? 
	 if ( isalldigits(Memc[specifier]) )
	 {
	   # Remove leading 0's by converting the string into a number.
	    call sscan(Memc[specifier])
	     call gargi(spec_value)

	   # create the root by taking first character of dataset
	   # and appending the specifier
	    call sprintf(Memc[root],SZ_FNAME,"%c%d")
	     call pargc(Memc[dataset])
	     call pargi(spec_value)

	    if (display>4)
	    {
		call printf(" Specifier is a number.")
	    }
	 }
	 else  # The specifier must be a filename.  
	 {
	   # find the position of the first "." in the specifier
	    pt_pos = stridx(".",Memc[specifier])

	   # copy the specifier up to that position into the root
	    if (pt_pos == 0) 
	    {  
	       # period not found: copy whole string
	        call strcpy(Memc[specifier],Memc[root],SZ_FNAME)
	    }
	    else
	        call strcpy(Memc[specifier],Memc[root],pt_pos-1)

	    if (display>4)
	    {
		call printf(" Specifier is a filename.")
	    }
	 }

	# set output parameters
	 call clpstr("root",Memc[root])

	# Free memory stack
	 call sfree (sp)   

	 if (display>4)
	 {
	    call printf(" Returning root: %s.\n")
	     call pargstr(Memc[root])
	    call printf("**** Exiting spec2root ****\n")
	 }
end
