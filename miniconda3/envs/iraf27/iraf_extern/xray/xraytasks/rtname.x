#$Header: /home/pros/xray/xraytasks/RCS/rtname.x,v 11.0 1997/11/06 16:46:33 prosb Exp $
#$Log: rtname.x,v $
#Revision 11.0  1997/11/06 16:46:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:37:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:03:13  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:44:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/10/04  14:19:53  jmoran
#JFM - Fixed call to clpstr. Added comments. Removed include
#file that wasn't needed. 
#
#Revision 3.0  91/08/02  01:26:12  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:45  pros
#General Release 1.0
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
include <error.h>		# error messages

#
#     Generate a default output filename according to the PROS conventions
#
############################################################################
#
#  Generate a default output filename and write it to the CL pre-defined
#	variable s1.
#  This is merely a hidden utility task to call the rootname PROS library
#	function and make the info available to the script tasks 
#
############################################################################

procedure t_rootname()

pointer	sp
pointer	infilename	# input instrument name
pointer	outfilename	# output instrument name
pointer ext		# requested extension

begin
# mark the position of the stack pointer
	call smark(sp)

# allocate space on the stack for the strings
	call salloc( infilename, SZ_PATHNAME, TY_CHAR)
	call salloc( outfilename, SZ_PATHNAME, TY_CHAR)
	call salloc( ext, SZ_PATHNAME, TY_CHAR)

# get the string parameters from the CL
	call clgstr("infilename",Memc[infilename],SZ_PATHNAME)
	call clgstr("outfilename",Memc[outfilename],SZ_PATHNAME)
	call clgstr("ext",Memc[ext],SZ_PATHNAME)

# call the PROS library function "rootname"  
	call rootname(Memc[infilename],Memc[outfilename],Memc[ext],SZ_PATHNAME)

# put a string type parameter to the CL
	call clpstr("s1",Memc[outfilename])

# free space on the stack
	call sfree(sp)
end
