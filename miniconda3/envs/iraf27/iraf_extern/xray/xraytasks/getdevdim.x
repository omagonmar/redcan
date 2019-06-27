# $Header: /home/pros/xray/xraytasks/RCS/getdevdim.x,v 11.0 1997/11/06 16:46:30 prosb Exp $
# $Log: getdevdim.x,v $
# Revision 11.0  1997/11/06 16:46:30  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:04  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:27  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:14  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:03:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:08:40  prosb
#General Release 2.1
#
#Revision 1.1  92/10/23  10:11:13  mo
#Initial revision
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

procedure t_getdevdim()

pointer	sp
pointer	device		# input instrument name
pointer	tty
int	devx
int	devy

pointer	ttygdes()
int	ttygeti

begin
# mark the position of the stack pointer
	call smark(sp)

	call salloc(device,SZ_PATHNAME,TY_CHAR)

	call clgstr("device",Memc[device],SZ_PATHNAME)
        tty = ttygdes(Memc[device])
        devx = ttygeti (tty, "xr")
        devy = ttygeti (tty, "yr")
        call ttycdes (tty)

# put a string type parameter to the CL
        call clputi("x",devx)
        call clputi("y",devy)

# free space on the stack
	call sfree(sp)
end
