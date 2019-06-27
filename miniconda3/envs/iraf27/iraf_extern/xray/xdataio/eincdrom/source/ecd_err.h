#$Log: ecd_err.h,v $
#Revision 11.0  1997/11/06 16:36:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:35  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  18:28:50  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/06  17:32:39  prosb
#Added new errors.
#
#Revision 7.0  93/12/27  18:45:32  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:47  prosb
#General Release 2.2
#
#Revision 1.1  93/04/15  15:00:18  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/ecd_err.h,v 11.0 1997/11/06 16:36:54 prosb Exp $
#
# ecd_err.h
#
# This file is the list of errors in the eincdrom directory. 
#

# OBSOLETED ERROR CODES
define ECD_CANTREADFILE  290  # Can't read file
define ECD_CANTFINDDIR   291  # Can't access directory
define ECD_UNKDATASET    292  # Unknown data set
define ECD_BADDATASET    293  # Unexpected data set 
define ECD_SEQNOTFOUND   294  # Sequence not found in index file
define ECD_NOFNINDEX     295  # No fits name index for this data set
define ECD_BADFNINDEXFMT 296  # Fits name index file has unexpected format
define ECD_BADFNFMT      297  # Fits file name is in unexpected format
define ECD_SPECNOTEMPTY  298  # Specifier must not be empty string
define ECD_FITSNOTEMPTY  299  # Fitsname must not be empty string

# NEW ERROR CODES
define ECD_UNKNOWN_TYPE     307     # Unknown type
define ECD_UNKNOWN_BAND     308     # Unknown pi band
define ECD_UNKNOWN_BAND_ID  309     # Unknown pi band index
define ECD_UNKNOWN_INST_ID  310     # Unknown instrument index
define ECD_MISSING_COL      312     # Missing column
define ECD_MISSING_ROWVAL   313     # Missing a value from a row
define ECD_WRONG_DIMENSION  314     # wrong dimension
define ECD_WRONG_SIZE       315     # wrong size
define ECD_WRONG_PIXTYPE    316     # wrong pixel type
define ECD_WRONG_WCS_ROLL   317     # wrong wcs roll angle
define ECD_WRONG_WCS_BLOCK  318     # wrong wcs block size 
define ECD_WRONG_WCS_REF    319     # wrong wcs reference points
define ECD_WRONG_FILETYPE   320     # wrong type of file
define ECD_UNEXPECTED_EOF   330     # unexpected EOF
define ECD_NO_TIME_IN_QP    335     # no time attribute in qpoe file
define ECD_WRONG_NUM_ROW    340     # wrong number of rows
define ECD_WRONG_NUM_COL    341     # wrong number of columns
define ECD_BAD_CELL_SIZE    345     # bad cell size
define ECD_ZERO_SCALE       350     # zero scale
define ECD_BAD_RESOLUTION   355     # bad resolution
