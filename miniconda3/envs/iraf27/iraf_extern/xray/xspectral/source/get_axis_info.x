#$Header: /home/pros/xray/xspectral/source/RCS/get_axis_info.x,v 11.0 1997/11/06 16:42:13 prosb Exp $
#$Log: get_axis_info.x,v $
#Revision 11.0  1997/11/06 16:42:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:41  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:58  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:18  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:12:42  prosb
#jso - made spectral.h system wide
#
#Revision 2.1  91/05/24  11:36:40  pros
#jso - added warning message to block use of linked
#	parameters as axis variables which caused a warning
#	also allowed for line model width to be axis
#
#Revision 2.0  91/03/06  23:03:22  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  routines for getting grid search axis information

include  <spectral.h>

#  local definitions

define  AXISSTEPS	"axis_steps"
define  AXISTYPE	"axis_type"
define  AXISMODEL	"model_for_axis"
define  AXISPAR		"axis_parameter"
define  AXISDELTA	"parameter_delta"


#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

int  procedure  axis_type ( s )

char	 s[ARB]
int	 ntype,   strdic()

string   l_types "|linear|logarithmic|"

begin
	switch (strdic( s, s, SZ_FNAME, l_types ) )  {

	case 1:
		ntype = LINEAR_AXIS
	case 2:
		ntype = LOG_AXIS
	default:
		ntype = LINEAR_AXIS
	}

	return (ntype)
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  get_axis_info ( fp, x, prefix )

pointer	 fp			# parameter data structure
pointer	 x			# axis data structure
pointer	 sval			# string response
pointer  pname			# parameter handle
pointer	 sp			# stack pointer
char	 prefix[ARB]		# axis name prefix (i.e. X or Y)
int	 par_index		# parameter code in model structure

int	 clgeti(),  axis_type()
real	 clgetr()
bool	 match_name()

begin
	call smark ( sp )
	call salloc ( sval, SZ_FNAME, TY_CHAR )
	call salloc ( pname, SZ_FNAME, TY_CHAR )

	# get model number only if there is more than 1 to get!
	if( FP_MODEL_COUNT(fp) >1 ){
	    call strcpy ( prefix, Memc[pname], SZ_FNAME )
	    call strcat ( AXISMODEL, Memc[pname], SZ_FNAME )
	    GS_MODEL(x) = 0
	    while( (GS_MODEL(x) < 1) || (GS_MODEL(x) > FP_MODEL_COUNT(fp)) ){
		GS_MODEL(x) = clgeti( Memc[pname] )
	    }
	}
	else
	    GS_MODEL(x) = 1
	GS_MODELTYPE(x) = MODEL_TYPE(FP_MODELSTACK(fp,GS_MODEL(x)))

	# get the parameter type
99	Memc[sval] = EOS
        call strcpy ( prefix, Memc[pname], SZ_FNAME )
        call strcat ( AXISPAR, Memc[pname], SZ_FNAME )
	while( !match_name( Memc[sval], par_index) )  {
	    call clgstr( Memc[pname], Memc[sval], SZ_FNAME )
	    }
	GS_PARAM(x)     = par_index

	# make sure we don't use linked params as grid axes
	if( MODEL_PAR_LINK(FP_MODELSTACK(fp,GS_MODEL(x)), GS_PARAM(x)) !=0 ){
	    call printf("grid axis cannot be a linked value\n")
	    call flush(STDOUT)
	    goto 99
	}

#	if( GS_STEPS(x) > 1 )  {
            call strcpy ( prefix, Memc[pname], SZ_FNAME )
            call strcat ( AXISDELTA, Memc[pname], SZ_FNAME )
	    GS_DELTA(x)     = clgetr( Memc[pname] )
#	    }

	# get the steps
        call strcpy ( prefix, Memc[pname], SZ_FNAME )
        call strcat ( AXISSTEPS, Memc[pname], SZ_FNAME )
	GS_STEPS(x)     = clgeti( Memc[pname] )

	# get the axis type
	call strcpy ( prefix, Memc[pname], SZ_FNAME )
	call strcat ( AXISTYPE, Memc[pname], SZ_FNAME )
	call clgstr ( Memc[pname], Memc[sval], SZ_FNAME )
	GS_AXISTYPE(x)  = axis_type( Memc[sval] )

	GS_PAR_VALUE(x) = MODEL_PAR_VAL(FP_MODELSTACK(fp,GS_MODEL(x)),par_index)
	GS_FREETYPE(x)  = MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(x)),par_index)
	MODEL_PAR_FIXED(FP_MODELSTACK(fp,GS_MODEL(x)),par_index) = FIXED_PARAM

	call sfree ( sp )
end

