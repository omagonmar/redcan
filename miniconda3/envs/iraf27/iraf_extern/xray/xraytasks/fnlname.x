# $Header: /home/pros/xray/xraytasks/RCS/fnlname.x,v 11.0 1997/11/06 16:46:30 prosb Exp $
# $Log: fnlname.x,v $
# Revision 11.0  1997/11/06 16:46:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:03  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:03:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:43:52  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  91/10/10  10:52:44  jmoran
#Initial revision
#
#
# Module:	fnlname.x
# Project:	PROS -- ROSAT RSDC
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JFM initial version 10/10/91
#		{n} <who> -- <does what> -- <when>
#

include <error.h>		# error messages
############################################################################
#
#  Copy the final filename into the CL variable s1.
#  This is merely a hidden utility task to call the finalname PROS library
#	function and make the info available to the script tasks 
#
############################################################################

procedure t_finalname()

pointer	sp
pointer	infilename	# input instrument name
pointer	outfilename	# output instrument name


begin
# mark the position of the stack pointer
	call smark(sp)

# allocate space on the stack for the strings
	call salloc( infilename, SZ_PATHNAME, TY_CHAR)
	call salloc( outfilename, SZ_PATHNAME, TY_CHAR)

# get the string parameters from the CL
	call clgstr("infilename",Memc[infilename],SZ_PATHNAME)
	call clgstr("outfilename",Memc[outfilename],SZ_PATHNAME)


# call the PROS library function "finalname"  
	call finalname(Memc[infilename],Memc[outfilename])


# free space on the stack
	call sfree(sp)
end
