# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/src.h,v 11.0 1997/11/06 16:30:59 prosb Exp $
# $Log: src.h,v $
# Revision 11.0  1997/11/06 16:30:59  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:46  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:14:53  prosb
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
# SRC data structure and table definitions.
#
# This header defines the column names for the source table file.
#
# Columns:
#
#   X,Y:   x and Y position of source
#
# (See help file on SRC in the DOCS directory.)
#
#--------------------------------------------------------------------------

#----------------------------------------------
# CAT column names
#----------------------------------------------
define N_COL_SRC      2

define SRC_X_COL      "X"
define SRC_Y_COL      "Y"

#----------------------------------------------
# CAT data structure
#----------------------------------------------
define SZ_SRC         4

define SRC            (($1)+(($2-1)*SZ_SRC))
define SRC_X          Memd[P2D($1)]
define SRC_Y          Memd[P2D(($1)+2)]

