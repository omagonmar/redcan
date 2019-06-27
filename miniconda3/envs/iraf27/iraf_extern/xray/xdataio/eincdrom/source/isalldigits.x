#$Log: isalldigits.x,v $
#Revision 11.0  1997/11/06 16:36:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  18:28:54  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:45:34  prosb
#General Release 2.3
#
#Revision 6.1  93/10/04  12:06:14  dvs
#Changed all function calls to lowercase.
#
#Revision 6.0  93/05/24  17:11:49  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:40:31  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/isalldigits.x,v 11.0 1997/11/06 16:36:55 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       isalldigits.x
# Project:      PROS -- EINSTEIN CDROM
# External:	isalldigits
# Local: 	(none)
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <ctype.h>

#--------------------------------------------------------------------------
# Procedure:	isalldigits
#
# Purpose:      To check if the passed string consists solely of digits
#
# Input variables:
#		str:         input string
#
# Return value:	returns true iff the string consists only of numbers
#
# Notes:	Note that this does not check if the string is a number,
#		since returns false for strings such as " 300", "45 " 
#               and "-121".
#--------------------------------------------------------------------------

bool procedure isalldigits(str)
char    str[ARB]     	# string to check

### LOCAL VARS ###

int     ctr	        # counter for loop
int     slen	        # length of string
bool    isalldigitssofar# true if string is all digits so far

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen()        # returns length of string [sys/fmtio]
  
### BEGINNING OF PROCEDURE ###

begin
	 isalldigitssofar = true

	# find string length
	 slen = strlen(str)

	# loop through each string character
	 for ( ctr=1 ;(ctr<=slen) && (isalldigitssofar); ctr=ctr+1 )
	 {
	   isalldigitssofar = IS_DIGIT(str[ctr])
	 }

	# return true iff all characters in string were digits
	 return (isalldigitssofar)
end


