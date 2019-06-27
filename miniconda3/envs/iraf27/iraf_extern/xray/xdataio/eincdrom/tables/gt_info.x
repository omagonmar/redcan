# $Header: /home/pros/xray/xdataio/eincdrom/tables/RCS/gt_info.x,v 11.0 1997/11/06 16:37:02 prosb Exp $
# $Log: gt_info.x,v $
# Revision 11.0  1997/11/06 16:37:02  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:01:45  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:52  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:33  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/06  17:34:47  prosb
#Initial revision
#
#
#
#--------------------------------------------------------------------------
# Module:       gt_info.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     gt_mk_info, gt_colname_def, gt_units_def, gt_fmt_def,
#		gt_free_info
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <tbset.h>
include "../source/ecd_err.h"
include "gen_tab.h"

#--------------------------------------------------------------------------
# Procedure:    gt_mk_info
#
# Purpose:      To make the generic table info for a table
#
# Input variables:
#               n_col 		number of columns in table
#		col_type	array of variable types in table
#
# Output variables:
#               p_gt_info       pointer to generic table info
#
# Description:  This routine sets aside memory and fills in the info
#		structure needed to use the various generic table
#		routines.  (See gen_tab.h.) 
#
#		It fills in GT_NCOL with the number of columns (n_col),
#		then for each column it assigns GT_TYPE to the passed
#		in type (col_type), assigns GT_UNITS to "", and assigns
#		GT_FMT to be the default format string for the type.
#		This routine also calculates GT_SZROW by summing the
#		size of all the types in the column.
#
#		The user will have to set the column names after calling
#		this routine.
# 		
#		If the column type is negative, this routine will 
#		assume this is a string of length abs(col_type).
#		In this case, the column length will be increased
#		by the size of a pointer, since when we read in a row,
#		we will be creating a pointer to that string.
#--------------------------------------------------------------------------


procedure gt_mk_info(n_col,col_type,p_gt_info)
int	n_col		# i: number of columns in table
int	col_type[n_col] # i: array of variable types in table
pointer p_gt_info	# o:  pointer to generic table info

### LOCAL VARS ###

int	sz_row		# running total of the size of the columns
int	i_col		# column index
int	type		# column type

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # check for illegal n_col
        #----------------------------------------------
	if (n_col <= 0)
	{
	    call errori(ECD_WRONG_NUM_COL,
		"GT_MK_INFO: Illegal number of columns",n_col)
	}

        #----------------------------------------------
        # Set aside memory for the GT info table
        #----------------------------------------------
	call malloc(p_gt_info,SZ_GTINFO,TY_STRUCT)

        #----------------------------------------------
        # Set GT_NCOL to be the number of columns.
        #----------------------------------------------
	GT_NCOL(p_gt_info)=n_col

        #----------------------------------------------
        # Set aside memory for the various arrays
        #----------------------------------------------
	call malloc(GT_PP_COLNAME(p_gt_info),n_col,TY_STRUCT)
	call malloc(GT_PP_UNITS(p_gt_info),n_col*(SZ_COLUNITS+1),TY_STRUCT)
	call malloc(GT_PP_FMT(p_gt_info),n_col*(SZ_COLFMT+1),TY_STRUCT)
	call malloc(GT_P_TYPE(p_gt_info),n_col,TY_INT)

        #-------------------------------------------------
        # Initialize sz_row and loop through the columns
        #-------------------------------------------------
	sz_row=0
	do i_col=1,n_col
	{
            #----------------------------------------------
            # Set GT_TYPE to be the passed in col_type
            #----------------------------------------------
	    GT_TYPE(p_gt_info,i_col)=col_type[i_col]

            #----------------------------------------------
            # Set aside memory for the strings
            #----------------------------------------------
	    call malloc(GT_P_COLNAME(p_gt_info,i_col),SZ_COLNAME, TY_CHAR)
	    call malloc(GT_P_UNITS(p_gt_info,i_col),  SZ_COLUNITS,TY_CHAR)
	    call malloc(GT_P_FMT(p_gt_info,i_col),    SZ_COLFMT,  TY_CHAR)

            #----------------------------------------------
            # Set GT_UNITS to be the empty string
            #----------------------------------------------
            call strcpy("",GT_UNITS(p_gt_info,i_col),SZ_COLUNITS)

            #--------------------------------------------------
            # Depending on the column type, set:
	    #    GT_FMT to be the default format for the type
	    #    increment sz_row by the size of this column
            #-------------------------------------------------
	    type = GT_TYPE(p_gt_info,i_col)
	    if (type<0)  # type string
	    {
		call strcpy(DEF_STR_FMT,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
		sz_row=sz_row+SZ_POINTER/SZ_INT
	    }
	    else switch(type)
            {
             	case TY_REAL:
                    call strcpy(DEF_REAL_FMT,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
		    sz_row=sz_row+SZ_REAL/SZ_INT
             	case TY_DOUBLE:
                    call strcpy(DEF_DOUBLE_FMT,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
		    sz_row=sz_row+SZ_DOUBLE/SZ_INT
             	case TY_INT:
                    call strcpy(DEF_INT_FMT,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
		    sz_row=sz_row+1
             	case TY_BOOL:
                    call strcpy(DEF_BOOL_FMT,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
		    sz_row=sz_row+SZ_BOOL/SZ_INT
             	default:
                    call errori(ECD_UNKNOWN_TYPE,
                       "GT_MK_INFO: Unknown type",type)
             }
        }

        #-------------------------------------------------
        # Set GT_SZROW to the size of the columns
        #-------------------------------------------------
	GT_SZROW(p_gt_info)=sz_row
end

#--------------------------------------------------------------------------
# Procedure:    gt_colname_def
#
# Purpose:      To set the column name in the GT INFO structure.
#
# Input and output variables:
#               p_gt_info       pointer to generic table info
#
# Input variables:
#               colname		column name to add (size SZ_COLNAME)
#		i_col		index of column
#
# Description:  This routine copies the passed string into the
#		GT_COLNAME portion of the generic table info structure.
#--------------------------------------------------------------------------

procedure gt_colname_def(p_gt_info,colname,i_col)
pointer p_gt_info	    # io:  pointer to generic table info
char    colname[SZ_COLNAME] # i: column name
int	i_col		    # i: index of column to be changed
begin
	call strcpy(colname,GT_COLNAME(p_gt_info,i_col),SZ_COLNAME)
end

#--------------------------------------------------------------------------
# Procedure:    gt_units_def
#
# Purpose:      To set the units in the GT INFO structure.
#
# Input and output variables:
#               p_gt_info       pointer to generic table info
#
# Input variables:
#               units		column unit to add (size SZ_COLUNITS)
#		i_col		index of column
#
# Description:  This routine copies the passed string into the
#		GT_UNITS portion of the generic table info structure.
#--------------------------------------------------------------------------

procedure gt_units_def(p_gt_info,units,i_col)
pointer p_gt_info	   # io:  pointer to generic table info
char    units[SZ_COLUNITS] # i: column units to be added
int	i_col		# i: index of column to be changed
begin
	call strcpy(units,GT_UNITS(p_gt_info,i_col),SZ_COLUNITS)
end

#--------------------------------------------------------------------------
# Procedure:    gt_fmt_def
#
# Purpose:      To set the format in the GT INFO structure.
#
# Input and output variables:
#               p_gt_info       pointer to generic table info
#
# Input variables:
#               fmt		column format to add (size SZ_COLFMT)
#		i_col		index of column
#
# Description:  This routine copies the passed string into the
#		GT_FMT portion of the generic table info structure.
#--------------------------------------------------------------------------

procedure gt_fmt_def(p_gt_info,fmt,i_col)
pointer p_gt_info	# io:  pointer to generic table info
char    fmt[SZ_COLFMT]	# i: column format to be added
int	i_col		# i: index of column to be changed
begin
	call strcpy(fmt,GT_FMT(p_gt_info,i_col),SZ_COLFMT)
end

#--------------------------------------------------------------------------
# Procedure:    gt_free_info
#
# Purpose:      To free memory within generic table info structure
#
# Input and output variables:
#               p_gt_info       pointer to generic table info
#
# Description:  This routine frees the memory from the strings and
#		arrays within the generic table info structure.
#		This routine should be called at the end of the routine
#		which called gt_mk_info.
#--------------------------------------------------------------------------

procedure gt_free_info(p_gt_info)
pointer p_gt_info	# io:  pointer to generic table info

### LOCAL VARS ###

int	i_col		# i: index of column to be changed

### BEGINNING OF PROCEDURE ###

begin

        #-------------------------------------------------
        # Release strings (Column name, format, units)
        #-------------------------------------------------
	do i_col=1,GT_NCOL(p_gt_info)
	{
	    call mfree(GT_P_COLNAME(p_gt_info,i_col),TY_CHAR)
	    call mfree(GT_P_FMT(p_gt_info,i_col),TY_CHAR)
	    call mfree(GT_P_UNITS(p_gt_info,i_col),TY_CHAR)
	}

        #-------------------------------------------------
        # Release arrays (of strings and of types)
        #-------------------------------------------------
	call mfree(GT_PP_COLNAME(p_gt_info),TY_STRUCT)
	call mfree(GT_PP_FMT(p_gt_info),TY_STRUCT)
	call mfree(GT_PP_UNITS(p_gt_info),TY_STRUCT)
	call mfree(GT_P_TYPE(p_gt_info),TY_INT)

        #-------------------------------------------------
        # Release actual structure
        #-------------------------------------------------
	call mfree(p_gt_info,TY_STRUCT)
end


