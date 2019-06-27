# $Header: /home/pros/xray/xraytasks/RCS/clobname.x,v 11.0 1997/11/06 16:46:29 prosb Exp $
# $Log: clobname.x,v $
# Revision 11.0  1997/11/06 16:46:29  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:00  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:08  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:02:56  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:43:43  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  91/10/10  10:51:00  jmoran
#Initial revision
#
#
# Module:	clobname.x
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
#  This is merely a hidden utility task to call the clobbername PROS library
#	function and make the info available to the script tasks 
#
############################################################################

procedure t_clobbername()

pointer	sp
pointer	infilename	# input name
pointer	tempname	# temporary name
bool    clobber         # clobber?
bool    clgetb()        # declare library functions

begin
# mark the position of the stack pointer
	call smark(sp)

# allocate space on the stack for the strings
	call salloc( infilename, SZ_PATHNAME, TY_CHAR)
	call salloc( tempname, SZ_PATHNAME, TY_CHAR)

# get the string parameters from the CL
	call clgstr("infilename",Memc[infilename],SZ_PATHNAME)
	call clgstr("tempname",Memc[tempname],SZ_PATHNAME)

# get the boolean parameter from the CL
        clobber = clgetb("clobber")

# call the PROS library function "clobbername"  
	call clobbername(Memc[infilename],Memc[tempname],clobber,SZ_PATHNAME)

# put a string type parameter to the CL
	call clpstr("s1",Memc[tempname])

# free space on the stack
	call sfree(sp)
end
