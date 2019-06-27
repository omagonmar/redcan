#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_extno.x,v 11.0 1997/11/06 16:34:37 prosb Exp $
#$Log: ft_extno.x,v $
#Revision 11.0  1997/11/06 16:34:37  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:51  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:07  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:11  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:33  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:22  jmoran
#Initial revision
#
#
# Module:	ft_extno.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <ctype.h>

#
#  FT_EXTNO -- get ext number from a card
#
procedure ft_extno(name, extno)

char	name[ARB]			# i: card name
int	extno				# o: ext number
int	i				# l: index into name
int	ip				# l: index for ctoi()
int	junk				# l: junk return from ctoi()
int	ctoi()				# l: convert char to int

begin
	# look for the first non-alpha character
	i = 1
	while( IS_ALPHA(name[i]) )
	    i = i+1
	# convert to integer
	ip = 1
	junk = ctoi(name[i], ip, extno)
end

