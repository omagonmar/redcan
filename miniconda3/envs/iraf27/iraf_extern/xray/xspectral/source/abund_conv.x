#$Header: /home/pros/xray/xspectral/source/RCS/abund_conv.x,v 11.0 1997/11/06 16:41:47 prosb Exp $
#$Log: abund_conv.x,v $
#Revision 11.0  1997/11/06 16:41:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:52  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:29:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:48:33  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:17  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:12:52  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  18:36:02  wendy
#added copyright
#
#Revision 3.0  91/08/02  01:57:47  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:29:18  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:01:22  pros
#General Release 1.0
#
#  abund_conv.x   ---   converts abundance strings into codes and vice versa.
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright

# include  <spectral.h>



#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  return the appropriate "value" for the abundance type string

# int  procedure  abund_val( s )

# char	s[ARB]
# int	ntype,  strdic()

# string	a_types "|cosmic|meyer|"

# begin
#	switch (strdic( s, s, SZ_FNAME, a_types ) )  {
#
#	case 1:
#		ntype = COSMIC_ABUNDANCE
#	case 2:
#		ntype = MEYER_ABUNDANCE
#	default:
#		ntype = COSMIC_ABUNDANCE
#	}

#	return (ntype)
# end

