#$Log: eci.x,v $
#Revision 11.0  1997/11/06 16:37:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:54  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:11:43  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:50  prosb
#General Release 2.3.1
#
#Revision 1.2  94/05/13  17:09:33  prosb
#Changed header macros from EC_ to ECI_.
#
#Revision 1.1  94/05/06  17:27:03  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/ecdinfo/RCS/eci.x,v 11.0 1997/11/06 16:37:08 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       eci.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     eci_setup
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "eci.h"
include "../source/ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:    eci_setup
#
# Purpose:      Set up generic table info structure for ecdinfo tables.
#
# Input parameters:
#               p_cat_info       pointer to generic table info
#
# Description:  This routine will set up the generic table info pointer
#               so we can automatically read in the data from the table
#               or write to the table easily.
#
#               Memory is set aside for the GT info structure.
#               
#               See gt_info.x for more on generic table info structure,
#               and eci.h for the actual data structure used for the 
#		ecdinfo tables.
#--------------------------------------------------------------------------

procedure eci_setup(p_eci_info)
pointer p_eci_info	# o: pointer to GT info
int	col_type[N_COL_ECI]	# array of column types

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Initialize column types.
        #----------------------------------------------
	col_type[ECI_SEQ_COL]=TY_INT
	col_type[ECI_FITSROOT_COL]=-ECI_FITSROOT_LEN
	col_type[ECI_EXT_COL]=-ECI_EXT_LEN  	
	col_type[ECI_CD_COL]=TY_INT
	col_type[ECI_RA_COL]=TY_DOUBLE
	col_type[ECI_DEC_COL]=TY_DOUBLE
	col_type[ECI_LIVETIME_COL]=TY_DOUBLE
	col_type[ECI_EVTOFF_COL]=TY_DOUBLE
	col_type[ECI_HOUR_COL]=-ECI_HOUR_LEN  	
	col_type[ECI_TITLE_COL]=-ECI_TITLE_LEN  

        #----------------------------------------------
        # Initialize the GT info pointer
        #----------------------------------------------
	call gt_mk_info(N_COL_ECI,col_type,p_eci_info)

        #----------------------------------------------
        # Fill in names.
        #----------------------------------------------
	call gt_colname_def(p_eci_info,ECI_SEQ_NAME, ECI_SEQ_COL)
	call gt_colname_def(p_eci_info,ECI_FITSROOT_NAME, ECI_FITSROOT_COL)
	call gt_colname_def(p_eci_info,ECI_EXT_NAME, ECI_EXT_COL)
	call gt_colname_def(p_eci_info,ECI_CD_NAME, ECI_CD_COL)
	call gt_colname_def(p_eci_info,ECI_RA_NAME, ECI_RA_COL)
	call gt_colname_def(p_eci_info,ECI_DEC_NAME, ECI_DEC_COL)
	call gt_colname_def(p_eci_info,ECI_LIVETIME_NAME, ECI_LIVETIME_COL)
	call gt_colname_def(p_eci_info,ECI_EVTOFF_NAME, ECI_EVTOFF_COL)
	call gt_colname_def(p_eci_info,ECI_HOUR_NAME, ECI_HOUR_COL)
	call gt_colname_def(p_eci_info,ECI_TITLE_NAME, ECI_TITLE_COL)

        #----------------------------------------------
        # Set units
        #----------------------------------------------
	call gt_units_def(p_eci_info,"deg", ECI_RA_COL)
	call gt_units_def(p_eci_info,"deg", ECI_DEC_COL)
	call gt_units_def(p_eci_info,"sec", ECI_LIVETIME_COL)
end

