#$Header: /home/pros/xray/xspectral/source/RCS/match_name.x,v 11.0 1997/11/06 16:42:42 prosb Exp $
#$Log: match_name.x,v $
#Revision 11.0  1997/11/06 16:42:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:07  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:54  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:52  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:49  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:22  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:29  prosb
#General Release 1.1
#
#Revision 2.2  91/07/12  16:17:13  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/24  12:07:34  pros
#jso -
#change to include width of line model
#
#Revision 2.0  91/03/06  23:04:56  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# match_name -- return model index from a name
#

include <spectral.h>

bool procedure  match_name ( name, index )

char	name[ARB]			# parameter name
int	index				# returned parameter index

int	strdic()
bool	answer

string	p_names	"|normalization|index|energy|temperature|intrinsicNh|galacticNh|redshift|width|"

begin
	answer = TRUE

	switch ( strdic( name, name, SZ_FNAME, p_names ) ) {

	case 1:
		index = MODEL_ALPHA
	case 2:
		index = MODEL_TEMP
	case 3:
		index = MODEL_TEMP
	case 4:
		index = MODEL_TEMP
	case 5:
		index = MODEL_INTRINSIC
	case 6:
		index = MODEL_GALACTIC
	case 7:
		index = MODEL_REDSHIFT
	case 8:
		index = MODEL_WIDTH
	default:
		answer = FALSE
	}
	return (answer)			# did we find a match ?
end
