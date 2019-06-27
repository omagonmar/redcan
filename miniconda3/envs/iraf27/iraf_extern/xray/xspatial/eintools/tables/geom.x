# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/geom.x,v 11.0 1997/11/06 16:30:58 prosb Exp $
# $Log: geom.x,v $
# Revision 11.0  1997/11/06 16:30:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:44  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:15:07  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       geom.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     geom_setup
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# Table manipulation routines for IPC geometry table
#
#--------------------------------------------------------------------------

include "geom.h"

#--------------------------------------------------------------------------
# Procedure:    geom_setup
#
# Purpose:      To set up the IPC geometry for reading
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
#               and geom.h for the actual data in the geometry table.
#--------------------------------------------------------------------------

procedure geom_setup(p_gt_info)
pointer p_gt_info            # o: pointer go GT info
int     col_type[N_COL_GEOM] # array of column types
int     i_col                # index into columns

begin
        #----------------------------------------------
        # All the column types are double!
        #----------------------------------------------
	do i_col=1,N_COL_GEOM
	{
	   col_type[i_col]=TY_DOUBLE
	}

        #----------------------------------------------
        # Initialize the GT info pointer
        #----------------------------------------------
        call gt_mk_info(N_COL_GEOM,col_type,p_gt_info)

        #----------------------------------------------
        # Fill in column names
        #----------------------------------------------
        call gt_colname_def(p_gt_info,GEOM_XMIN_COL,      1)
        call gt_colname_def(p_gt_info,GEOM_XMAX_COL,      2)
        call gt_colname_def(p_gt_info,GEOM_YMIN_COL,      3)
        call gt_colname_def(p_gt_info,GEOM_YMAX_COL,      4)
        call gt_colname_def(p_gt_info,GEOM_RIBWID_COL,    5)
        call gt_colname_def(p_gt_info,GEOM_XRIB1_COL,     6)
        call gt_colname_def(p_gt_info,GEOM_XRIB2_COL,     7)
        call gt_colname_def(p_gt_info,GEOM_YRIB1_COL,     8)
        call gt_colname_def(p_gt_info,GEOM_YRIB2_COL,     9)

        #----------------------------------------------
        # Set units
        #----------------------------------------------
	do i_col=1,N_COL_GEOM
	{
	   call gt_units_def(p_gt_info,"pix",i_col)
	}
end
