# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/cat.h,v 11.0 1997/11/06 16:30:56 prosb Exp $
# $Log: cat.h,v $
# Revision 11.0  1997/11/06 16:30:56  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:40  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  15:17:20  dvs
#Changed some header keywords; just rearranging them.
#
#Revision 1.1  94/03/15  09:14:35  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# CAT data structure and table definitions.
#
# This header defines the column names and header keywords for
# the constant aspect table.
#
# Header params:
#
#   RCRPX1,RCRPX2,RCDLT1,RCDLT2:  WCS info for CAT
#   NOMRA, NOMDEC:     nominal RA & DEC to identify CAT with QPOE file.
#
# Columns:
#
#   RCRVL1, RCRVL2, RCROT2:  WCS info for each row.
#   LIVTI:                 livetime for each row
#
# (See help file on CAT in the DOCS directory.)
#
#--------------------------------------------------------------------------

#----------------------------------------------
# CAT header parameters
#----------------------------------------------
define CAT_RCRPX1        "RCRPX1"
define CAT_RCRPX2        "RCRPX2"
define CAT_RCDLT1        "RCDLT1"
define CAT_RCDLT2        "RCDLT2"
define CAT_NOMRA         "RA_NOM"
define CAT_NOMDEC        "DEC_NOM"

#----------------------------------------------
# CAT column names
#----------------------------------------------
define N_COL_CAT      4

define CAT_LIVETIME_NAME   "LIVTI"
define CAT_RCRVL1_NAME     "RCRVL1"
define CAT_RCRVL2_NAME     "RCRVL2"
define CAT_RCROT2_NAME     "RCROT2"

define CAT_LIVETIME_COL   1
define CAT_RCRVL1_COL     2
define CAT_RCRVL2_COL     3
define CAT_RCROT2_COL     4

#----------------------------------------------
# CAT data structure
#----------------------------------------------
define SZ_CAT         8

define CAT            (($1)+(($2-1)*SZ_CAT))

define CAT_LIVETIME     Memd[P2D($1)]
define CAT_RCRVL1       Memd[P2D($1+2)]
define CAT_RCRVL2       Memd[P2D($1+4)]
define CAT_RCROT2       Memd[P2D($1+6)]

