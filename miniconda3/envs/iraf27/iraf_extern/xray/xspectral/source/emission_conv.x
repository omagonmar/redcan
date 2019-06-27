#$Header: /home/pros/xray/xspectral/source/RCS/emission_conv.x,v 11.0 1997/11/06 16:42:03 prosb Exp $
#$Log: emission_conv.x,v $
#Revision 11.0  1997/11/06 16:42:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:03  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:47  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:02  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:42  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:06  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:57:36  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:02:42  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  emission_conv.x   ---   converts emission strings into codes and vice versa.

include	<spectral.h>

# revision dmw Oct 1988 --- to make singleline model invisible (since no code/spec match)

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "value" for the emission type string

int  procedure  emission_val( s )

char   s[ARB]
int    ntype,  strdic()

string e_types "|powerlaw|blackbody|bremsstrahlung|exponential|raymond|line|"

begin
	switch (strdic( s, s, SZ_FNAME, e_types ) )  {

	case 1:
		ntype = POWER_LAW
	case 2:
		ntype = BLACK_BODY
	case 3:
		ntype = EXP_PLUS_GAUNT
	case 4:
		ntype = EXPONENTIAL
	case 5:
		ntype = RAYMOND

	case 6:
		ntype = SINGLE_LINE
	default:
		ntype = EMISSION_UNSPECIFIED
	}

	return (ntype)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "string" for the emission type

procedure  emission_str ( code, name )

char    name[ARB]               # name of emission
int     code                    # emission type code

begin
        switch ( code )  {

        case POWER_LAW:
                        call strcpy ( "powerlaw", name, SZ_FNAME )

        case BLACK_BODY:
                        call strcpy ( "blackbody", name, SZ_FNAME )

        case EXP_PLUS_GAUNT:
                        call strcpy ( "bremsstrahlung", name, SZ_FNAME )

        case EXPONENTIAL:
                        call strcpy ( "exponential", name, SZ_FNAME )

        case RAYMOND:
                        call strcpy ( "raymond", name, SZ_FNAME )

        case SINGLE_LINE:
                        call strcpy ( "line", name, SZ_FNAME )

        default:
                        call strcpy ( "unspecified", name, SZ_FNAME )
        }
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "name" for the emission type 

procedure  emission_name ( code, name )

char	name[ARB]		# name of emission 
int	code			# emission type code

begin
	switch ( code )  {

	case POWER_LAW:
			call strcpy ( "Power Law", name, SZ_FNAME )

	case BLACK_BODY:
			call strcpy ( "Black Body", name, SZ_FNAME )

	case EXP_PLUS_GAUNT:
			call strcpy ( "Exponential plus Gaunt", name, SZ_FNAME )

	case EXPONENTIAL:
			call strcpy ( "Exponential", name, SZ_FNAME )

	case RAYMOND:
			call strcpy ( "Raymond Thermal", name, SZ_FNAME )

	case SINGLE_LINE:
			call strcpy ( "Single Line", name, SZ_FNAME )

	default:
			call strcpy ( "Unspecified Emission", name, SZ_FNAME )
	}
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "abcissa" for the emission type

procedure  emission_ab ( code, name )

char    name[ARB]               # name of emission
int     code                    # emission type code

begin
        switch ( code )  {

        case POWER_LAW:
                        call strcpy ( "energy index", name, SZ_FNAME )

        case BLACK_BODY:
                        call strcpy ( "temperature", name, SZ_FNAME )

        case EXP_PLUS_GAUNT:
                        call strcpy ( "temperature", name, SZ_FNAME )

        case EXPONENTIAL:
                        call strcpy ( "temperature", name, SZ_FNAME )

        case RAYMOND:
                        call strcpy ( "temperature", name, SZ_FNAME )

        case SINGLE_LINE:
                        call strcpy ( "energy", name, SZ_FNAME )

        default:
                        call strcpy ( "   ", name, SZ_FNAME )
	}
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "freedom" for the parameter

procedure  emission_fix ( code, name )

char    name[ARB]               # name of emission
int     code                    # freedom code

begin
        switch ( code )  {

        case FIXED_PARAM:
                        call strcpy ( "fixed", name, SZ_FNAME )

        case FREE_PARAM:
                        call strcpy ( "free", name, SZ_FNAME )

        case CALC_PARAM:
                        call strcpy ( "calculated", name, SZ_FNAME )

        default:
                        call strcpy ( "   ", name, SZ_FNAME )
	}
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ---- ----- -----
#  return the appropriate "freedom" code for the parameter

int  procedure  emission_fixc ( s )

char    s[ARB]	               #
int	ntype,  strdic()

string	f_types "|fixed|free|calculated|"

begin
	switch (strdic( s, s, SZ_FNAME, f_types) )  {

	case 1:
		ntype = FIXED_PARAM
	case 2:
		ntype = FREE_PARAM
	case 3: 
		ntype = CALC_PARAM
	default:
		ntype = FIXED_PARAM
	}

	return (ntype)
end

