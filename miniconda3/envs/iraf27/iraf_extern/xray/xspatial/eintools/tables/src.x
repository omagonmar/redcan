# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/src.x,v 11.0 1997/11/06 16:31:00 prosb Exp $
# $Log: src.x,v $
# Revision 11.0  1997/11/06 16:31:00  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:47  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:15:33  prosb
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
# Table manipulation routines for source table
#
#--------------------------------------------------------------------------

include "src.h"

#--------------------------------------------------------------------------
# Procedure:    src_setup
#
# Purpose:      To set up the source table for creation or reading
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
#               and src.h for the actual data structure used for the CAT.
#--------------------------------------------------------------------------
procedure src_setup(p_gt_info)
pointer p_gt_info           # o: pointer go GT info
int     col_type[N_COL_SRC] # array of column types
int     i_col               # index into columns

begin
        #----------------------------------------------
        # All the column types are double!
        #----------------------------------------------
	do i_col=1,N_COL_SRC
	{
	   col_type[i_col]=TY_DOUBLE
	}

        #----------------------------------------------
        # Initialize the GT info pointer
        #----------------------------------------------
        call gt_mk_info(N_COL_SRC,col_type,p_gt_info)

        #----------------------------------------------
        # Fill in column names
        #----------------------------------------------
        call gt_colname_def(p_gt_info,SRC_X_COL,      1)
        call gt_colname_def(p_gt_info,SRC_Y_COL,      2)

        #----------------------------------------------
        # Set units
        #----------------------------------------------
	do i_col=1,N_COL_SRC
	{
	   call gt_units_def(p_gt_info,"pix",i_col)
	}
end
