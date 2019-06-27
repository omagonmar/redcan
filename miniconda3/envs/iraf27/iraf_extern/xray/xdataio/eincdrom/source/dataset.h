#$Log: dataset.h,v $
#Revision 11.0  1997/11/06 16:36:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:31  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:12  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  18:28:44  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/06  17:32:16  prosb
#Revised dataset header keywords
#
#Revision 7.0  93/12/27  18:45:27  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:42  prosb
#General Release 2.2
#
#Revision 1.2  93/04/18  16:22:04  prosb
#Added eoscat and hriimg. 
#Bumped up sz_dataset
#Added EOSCAT_LINES_TO_SKIP for skipping over introductory material
# in the index file.
#
#Revision 1.1  93/04/15  14:56:38  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/dataset.h,v 11.0 1997/11/06 16:36:52 prosb Exp $
#
# DATASET.H -- defined constants related to datasets in the eincdrom package.

# These are the indices for the various datasets accepted by 
# the package eincdrom.
#
define UNKNOWN_DATASET 0
define IPC_EVT  1   
define HRI_EVT  2   
define EOSCAT   3   # ipc image
define HRI_IMG  4   # hri image
define SLEW     5   # ipc slew
define IPCU     7   # ipc unscreened

# instrument IDs

define IPC_ID  1
define HRI_ID  2

# This is the upper bound of the number of characters in the datasets.
define SZ_DATASET  7

# This is the number of lines to skip for the EOSCAT data.
# (Only used in the now obsolete qp_get and fits_get.)
define EOSCAT_LINES_TO_SKIP 7
