# $Header: /home/pros/xray/xspatial/eintools/tables/RCS/geom.h,v 11.0 1997/11/06 16:30:58 prosb Exp $
# $Log: geom.h,v $
# Revision 11.0  1997/11/06 16:30:58  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:42  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:14:47  prosb
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
# GEOM data structure and table definitions.
#
# This header defines the column names and header keywords for
# the IPC geometry table.
#
# Header params:
#
#   XDIM, YDIM:   IPC image size
#
# Columns:
#
#   XMIN. XMAX:   X minimum & maximum values for geometry
#   YMIN, YMAX:   Y minimum & maximum values for geometry
#   RIBWID:       width of rib
#   XRIB1,XRIB2:  X-coordinate centers of vertical ribs
#   YRIB1,YRIB2:  Y-coordinate centers of horizontal ribs
#
# (See help file on GEOM in the DOCS directory.)
#--------------------------------------------------------------------------

#----------------------------------------------
# GEOM header parameters
#----------------------------------------------
define XDIM               "XDIM"
define YDIM               "YDIM"

#----------------------------------------------
# GEOM column names
#----------------------------------------------
define N_COL_GEOM      9

define GEOM_XMIN_COL      "XMIN"
define GEOM_XMAX_COL      "XMAX"
define GEOM_YMIN_COL      "YMIN"
define GEOM_YMAX_COL      "YMAX"
define GEOM_RIBWID_COL    "RIBWID"
define GEOM_XRIB1_COL     "XRIB1"
define GEOM_XRIB2_COL     "XRIB2"
define GEOM_YRIB1_COL     "YRIB1"
define GEOM_YRIB2_COL     "YRIB2"


#----------------------------------------------
# GEOM data structure
#----------------------------------------------
define SZ_GEOM         18

define GEOM           (($1)+(($2-1)*SZ_CAT))
define GEOM_XMIN      Memd[P2D($1)]
define GEOM_XMAX      Memd[P2D(($1)+2)]
define GEOM_YMIN      Memd[P2D(($1)+4)]
define GEOM_YMAX      Memd[P2D(($1)+6)]
define GEOM_RIBWID    Memd[P2D(($1)+8)]
define GEOM_XRIB1     Memd[P2D(($1)+10)]
define GEOM_XRIB2     Memd[P2D(($1)+12)]
define GEOM_YRIB1     Memd[P2D(($1)+14)]
define GEOM_YRIB2     Memd[P2D(($1)+16)]


## header keywords

