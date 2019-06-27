# $Header: /home/pros/xray/xraytasks/RCS/imgclust.x,v 11.0 1997/11/06 16:46:31 prosb Exp $
# $Log: imgclust.x,v $
# Revision 11.0  1997/11/06 16:46:31  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:06  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:03:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:42  prosb
#General Release 2.1
#
#Revision 1.2  92/09/14  13:26:45  mo
#	New PROS utility routine
#
#
#
# Module:	imgclust.x
# Project:	PROS -- ROSAT RSDC
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} MC initial version 3/5/92
#		{n} <who> -- <does what> -- <when>
#

include <error.h>		# error messages
############################################################################
#
#  Strip the IMAGE SECTION,CLUSTER, QPOE BLOCK Specifier from the filename
#		( should strip all modifiers)
#
############################################################################

procedure t_imgclust()

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

# call the IRAF library function "imgclust"  
	call imgcluster(Memc[infilename],Memc[outfilename],SZ_PATHNAME)

# put a string type parameter to the CL
        call clpstr("s1",Memc[outfilename])

# free space on the stack
	call sfree(sp)
end
