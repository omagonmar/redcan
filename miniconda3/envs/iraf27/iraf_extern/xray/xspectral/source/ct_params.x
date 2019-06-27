#$Header: /home/pros/xray/xspectral/source/RCS/ct_params.x,v 11.0 1997/11/06 16:41:55 prosb Exp $
#$Log: ct_params.x,v $
#Revision 11.0  1997/11/06 16:41:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:44  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:24:04  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:05:27  wendy
#Added
#
#Revision 3.0  91/08/02  01:57:58  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  15:38:20  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:02:06  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  CT_PARAMS -- Determine the number of parameters of a given type.
# NB: only params with link >=0 (i.e., unlinked or base links) are counted
#
include  <spectral.h>

int  procedure  ct_params( fp, typeparam )

pointer fp                              # parameter data structure
pointer model                           # pntr to model structure
int     typeparam                       # type of parameter to be counted
int     num_models                      # number of models available
int     i_model,  i_param               # indices for models, parameters
int     count                           # number of parameters

begin
        count = 0
        num_models = FP_MODEL_COUNT(fp)

        if( num_models > 0 )
            do i_model = 1, num_models  {
                model = FP_MODELSTACK(fp,i_model)
                do i_param = 0, (MAX_MODEL_PARAMS-1) {
                    if( (MODEL_PAR_FIXED(model,i_param) == typeparam) &&
                    	(MODEL_PAR_LINK(model,i_param) >=0) )
                        count = count + 1
                    }
                }

        return (count)
end
