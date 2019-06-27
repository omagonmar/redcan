#$Header: /home/pros/xray/xspectral/source/RCS/rd_absorption.x,v 11.0 1997/11/06 16:43:16 prosb Exp $
#$Log: rd_absorption.x,v $
#Revision 11.0  1997/11/06 16:43:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:46:11  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:07:11  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:05  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:42:31  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:14  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   rd_absorption.x  ---   converts absorption strings into codes

include <spectral.h>

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----

int  procedure  absorption_type ( s )

char	s[ARB]
int	code,  strdic()

string  abs_types "|morrisonandmccammon|brownandgould|"

begin
	switch (strdic( s, s, SZ_FNAME, abs_types ) )  {

	case 1:
		code = MORRISON_MCCAMMON
	case 2:
		code = BROWN_GOULD
	default:
		code = MORRISON_MCCAMMON
	}
	
	return (code)
end
