# $Header: /home/pros/xray/xdataio/eincdrom/tables/RCS/gen_tab.h,v 11.0 1997/11/06 16:36:58 prosb Exp $
# $Log: gen_tab.h,v $
# Revision 11.0  1997/11/06 16:36:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:01:41  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  16:59:26  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/06  17:34:56  prosb
#Initial revision
#
#
#
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
#
# GENTAB.H -- header information for generic table routines.
#
#
############################################
#
# GT INFO structure:
#
# The generic table routines store the information about the table
# in a GT INFO structure. (See routines in gt_info.x.)  This structure
# contains the following information:
#
#      GT_NCOL:       number of columns in the table 
#      GT_SZROW:      sum of the sizes of the columns (in SZ_CHAR units)
#      GT_PP_COLNAME: pointer to an array of column names
#      GT_PP_UNITS:   pointer to an array of column units
#      GT_PP_FMT:     pointer to an array of column formats
#      GT_P_TYPE:     pointer to an array of column types
#
# 
# We also provide shortcuts to access to various arrays.  For
# instance, GT_P_COLNAME(p,n) is a pointer to the n-th column name.
# (GT_COLNAME(p,n) is the first character of the n-th column name.)
#
# 

define LEN_GTINFO	6
define SZ_GTINFO	6

define GT_NCOL		Memi[($1)]
define GT_SZROW		Memi[($1)+1]
define GT_PP_COLNAME	Memi[($1)+2]
define GT_PP_UNITS	Memi[($1)+3]
define GT_PP_FMT	Memi[($1)+4]
define GT_P_TYPE	Memi[($1)+5]

# shortcuts to access arrays pointed to by last four records
define GT_P_COLNAME	Memi[GT_PP_COLNAME($1)+(($2)-1)]
define GT_P_UNITS	Memi[GT_PP_UNITS($1)  +(($2)-1)]
define GT_P_FMT		Memi[GT_PP_FMT($1)    +(($2)-1)]
define GT_TYPE		Memi[GT_P_TYPE($1)   +(($2)-1)]

# shortcuts to get to the actual names
define GT_COLNAME	Memc[GT_P_COLNAME($1,$2)]
define GT_UNITS		Memc[GT_P_UNITS($1,$2)]
define GT_FMT		Memc[GT_P_FMT($1,$2)]

############################################
#
# These strings are the default formats for the defined types, to
# be used if the programmer does not provide a format for a column.
#
define DEF_REAL_FMT	"%15.7g"	
define DEF_DOUBLE_FMT	"%25.16g"	
define DEF_INT_FMT	"%11d"	
define DEF_BOOL_FMT	"%6b"	
define DEF_STR_FMT      "%s"
