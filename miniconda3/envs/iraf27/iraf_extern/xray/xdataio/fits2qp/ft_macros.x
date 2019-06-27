#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_macros.x,v 11.0 1997/11/06 16:34:38 prosb Exp $
#$Log: ft_macros.x,v $
#Revision 11.0  1997/11/06 16:34:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:16  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:18  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:40  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:29  jmoran
#Initial revision
#
#
# Module:	ft_macros
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#


#
# FT_MACROS -- write record definition macros to qpoe file
#
procedure ft_macros(qp, prostype)

pointer	qp					# i: qpoe handle
char	prostype[ARB]				# l: pros event definition
pointer	msymbols				# l: macro symbols
pointer	mvalues					# l: macro values
int	nmacros					# l: number of macros
bool	streq()					# l: string compare

begin

	# if no prostype, just return
	if( streq("", prostype) )
	    return
	# put the PROS event definition to the qpoe file
	call ev_qpput(qp, prostype)
	# create a list of the macros, one for each data in the event struct
	call ev_crelist(prostype, msymbols, mvalues, nmacros)
	# write the macros for each data in the event struct
	call ev_wrlist(qp, msymbols, mvalues, nmacros)
	# destroy the macro names and values
	call ev_destroylist(msymbols, mvalues, nmacros)
end

