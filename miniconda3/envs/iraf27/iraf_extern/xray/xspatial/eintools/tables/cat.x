# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/cat.x,v 11.0 1997/11/06 16:30:57 prosb Exp $
# $Log: cat.x,v $
# Revision 11.0  1997/11/06 16:30:57  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:41  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  15:17:44  dvs
#Changed some header keywords; just rearranging them.
#
#Revision 1.1  94/03/15  09:15:03  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       cat.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     cat_setup
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# Table manipulation routines for constant aspect table
#
#--------------------------------------------------------------------------

include "cat.h"

#--------------------------------------------------------------------------
# Procedure:    cat_setup
#
# Purpose:      To set up the constant aspect table for creation or reading
#
# Output variables:
#               p_gt_info       pointer to generic table info
#
# Description:  This routine will set up the generic table info pointer
#               so we can automatically read in the data from the table
#               or write to the table easily.
#
#               Memory is set aside for the GT info structure.
#               
#               See gt_info.x for more on generic table info structure,
#               and cat.h for the actual data structure used for the CAT.
#--------------------------------------------------------------------------
procedure cat_setup(p_gt_info)
pointer p_gt_info           # o: pointer go GT info
int	col_type[N_COL_CAT] # array of column types
int	i_col		    # index into columns

begin
        #----------------------------------------------
        # All the column types are double!
        #----------------------------------------------
 	do i_col=1,4
	{
	   col_type[i_col]=TY_DOUBLE
	}

        #----------------------------------------------
        # Initialize the GT info pointer
        #----------------------------------------------
        call gt_mk_info(N_COL_CAT,col_type,p_gt_info)

        #----------------------------------------------
        # Fill in column names
        #----------------------------------------------
        call gt_colname_def(p_gt_info,CAT_LIVETIME_NAME,CAT_LIVETIME_COL)
        call gt_colname_def(p_gt_info,CAT_RCRVL1_NAME,  CAT_RCRVL1_COL)
        call gt_colname_def(p_gt_info,CAT_RCRVL2_NAME,  CAT_RCRVL2_COL)
        call gt_colname_def(p_gt_info,CAT_RCROT2_NAME,  CAT_RCROT2_COL)

        #----------------------------------------------
        # Set units
        #----------------------------------------------
        call gt_units_def(p_gt_info,"sec",CAT_LIVETIME_COL)
        call gt_units_def(p_gt_info,"deg",CAT_RCRVL1_COL)
        call gt_units_def(p_gt_info,"deg",CAT_RCRVL2_COL)
        call gt_units_def(p_gt_info,"deg",CAT_RCROT2_COL)

        #----------------------------------------------
        # Set format types
        #----------------------------------------------
        call gt_fmt_def(p_gt_info,"%15.5f",CAT_LIVETIME_COL)
        call gt_fmt_def(p_gt_info,"%15.5f",CAT_RCRVL1_COL)
        call gt_fmt_def(p_gt_info,"%15.5f",CAT_RCRVL2_COL)
        call gt_fmt_def(p_gt_info,"%15.5f",CAT_RCROT2_COL)
end
