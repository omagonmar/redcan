#$Log: eci.h,v $
#Revision 11.0  1997/11/06 16:37:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:53  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:11:40  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:48  prosb
#General Release 2.3.1
#
#Revision 1.2  94/05/13  17:09:17  prosb
#Changed header macros from EC_ to ECI_.
#
#Revision 1.1  94/05/06  17:27:20  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/ecdinfo/RCS/eci.h,v 11.0 1997/11/06 16:37:05 prosb Exp $
#
#--------------------------------------------------------------------------
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 7/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
#
# ECI (ecdinfo) data structure and table definitions.
#
# The info tables store information about every set of data for each
# of the six Einstein datasets.
#
# Columns:
#
#   seq:          sequence number of observation.  (0 for slew data)
#   fits-root:    Main part of FITS filename corresponding to data
#   ext:          FITS extension.  (E.g., for "i2109s68.upa" the extension
#                 would be "a".) 
#   cd:           Which CDROM contains the data for this observation.
#   ra,dec:       RA and DEC of observation.
#   hour:         Hour of observation.  (E.g., "03h".)
#   evt-off:      Number of seconds the events should be adjusted.
#                 (This is only non-zero for HRI event files.)
#   livetime:     Livetime of observation.  (0.0 for slew data.)
#   title:        Title of observation.
#
#--------------------------------------------------------------------------

#----------------------------------------------
# ECI data structure
#----------------------------------------------
define SZ_ECI  	        14

define ECI              (($1)+(($2-1)*SZ_ECI))
define ECI_SEQ	  	Memi[($1)]
define ECI_P_FITSROOT   Memi[($1)+1]
define ECI_P_EXT        Memi[($1)+2]
define ECI_CD           Memi[($1)+3]
define ECI_RA           Memd[P2D(($1)+4)]
define ECI_DEC          Memd[P2D(($1)+6)]
define ECI_LIVETIME     Memd[P2D(($1)+8)]
define ECI_EVTOFF       Memd[P2D(($1)+10)]
define ECI_P_HOUR       Memi[($1)+12]
define ECI_P_TITLE      Memi[($1)+13]
define ECI_FITSROOT     Memc[ECI_P_FITSROOT($1)]
define ECI_EXT          Memc[ECI_P_EXT($1)]
define ECI_HOUR         Memc[ECI_P_HOUR($1)]
define ECI_TITLE        Memc[ECI_P_TITLE($1)]

define N_COL_ECI 	10

#----------------------------------------------
# ECI column definitions.
#----------------------------------------------

define ECI_SEQ_NAME          "SEQ"
define ECI_FITSROOT_NAME     "FITS-ROOT"
define ECI_EXT_NAME          "EXT"
define ECI_CD_NAME           "CD"
define ECI_RA_NAME           "RA"
define ECI_DEC_NAME          "DEC"
define ECI_HOUR_NAME         "HOUR"
define ECI_LIVETIME_NAME     "LIVETIME"
define ECI_TITLE_NAME        "TITLE"
define ECI_EVTOFF_NAME       "EVT-OFF"

define ECI_FITSROOT_LEN  8
define ECI_EXT_LEN       1
define ECI_HOUR_LEN      3
define ECI_TITLE_LEN     150

#----------------------------------------------
# make certain that DOUBLES are on even byte boundaries!
#----------------------------------------------
define ECI_SEQ_COL          1
define ECI_FITSROOT_COL     2
define ECI_EXT_COL          3
define ECI_CD_COL           4
define ECI_RA_COL           5
define ECI_DEC_COL          6
define ECI_LIVETIME_COL     7
define ECI_EVTOFF_COL       8
define ECI_HOUR_COL         9
define ECI_TITLE_COL        10





