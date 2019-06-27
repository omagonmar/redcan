# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/bkfac.h,v 11.0 1997/11/06 16:30:55 prosb Exp $
# $Log: bkfac.h,v $
# Revision 11.0  1997/11/06 16:30:55  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:37  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:14:22  prosb
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
# BKFAC data structure and table definitions.
#
# This header defines the column names and header keywords for
# the background factors table
#
# Header params:
#
#   RCRPX1,RCRPX2,RCDLT1,RCDLT2:  WCS info for BKFAC
#   BESOFT,BEHARD,BECTS: bright Earth counts
#   DSSOFT,DSHARD,DSCTS: deep survey counts
#   DSTIME:              seep survey livetime
#   PIBAND:              which band the BKFAC was made for
#   NOMRA, NOMDEC:       nominal RA & DEC to identify BKFAC with QPOE file.
#
# Columns:
#
#   RCRVL1, RCRVL2, RCROT2:  WCS info for each row.
#   BEFAC,DSFAC:        bright Earth and deep survey factors
#   LIVETIME:           livetime for the row
#   PI_CTS:             Number of counts in the image for that row.
#
#   NOTE: There are two types of BKFAC tables, and they have different
#         subsets of this list of header params and columns.
#
# (See help file on BKFAC in the DOCS directory.)
#
#--------------------------------------------------------------------------


# table header keywords
define BK_RCRPX1        "RCRPX1"
define BK_RCRPX2        "RCRPX2"
define BK_RCDLT1        "RCDLT1"
define BK_RCDLT2        "RCDLT2"
define BK_BESOFT        "BESOFT"
define BK_BEHARD        "BEHARD"
define BK_BECTS         "BECTS"
define BK_DSSOFT        "DSSOFT"
define BK_DSHARD        "DSHARD"
define BK_DSCTS         "DSCTS"
define BK_DSTIME        "DSTIME"
define BK_PIBAND        "PIBAND"
define BK_NOMRA         "RA_NOM"
define BK_NOMDEC        "DEC_NOM"

# some constant values
define BK_BESOFT_ORIG   4737020.0
define BK_BEHARD_ORIG   1592930.0
define BK_DSSOFT_ORIG   172637.625
define BK_DSHARD_ORIG   155845.6875

# table contents:

define SZ_BKFAC  	14

define BKFAC            (($1)+(($2-1)*SZ_BKFAC))
define BK_BEFAC	  	Memd[P2D($1)]
define BK_DSFAC	  	Memd[P2D(($1)+2)]
define BK_LIVETIME	Memd[P2D(($1)+4)]
define BK_RCRVL1  	Memd[P2D(($1)+6)]
define BK_RCRVL2	Memd[P2D(($1)+8)]
define BK_RCROT2        Memd[P2D(($1)+10)]
define BK_PI_CTS	Memd[P2D(($1)+12)]

define N_COL_BKFAC 	7

define BK_BEFAC_NAME		"BEFAC"
define BK_BEFAC_SOFT_NAME	"BESOFT"
define BK_BEFAC_HARD_NAME	"BEHARD"
define BK_DSFAC_NAME		"DSFAC"
define BK_LIVETIME_NAME		"LIVTI"
define BK_RCRVL1_NAME	        "RCRVL1"
define BK_RCRVL2_NAME		"RCRVL2"
define BK_RCROT2_NAME		"RCROT2"
define BK_PI_CTS_NAME		"PI_CTS"
define BK_PI_CTS_SOFT_NAME	"PISOFT"
define BK_PI_CTS_HARD_NAME	"PIHARD"

define BK_BEFAC_COL		1
define BK_DSFAC_COL		2
define BK_LIVETIME_COL		3
define BK_RCRVL1_COL		4
define BK_RCRVL2_COL		5
define BK_RCROT2_COL		6
define BK_PI_CTS_COL		7




