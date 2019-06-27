# JCC97/3/97) - define MAX_SRCS 
# JCC(3/3/97) - change MAX_SUBCELLS from 4100 to 4097
#
#Revision 1.2  1997/02/10  21:57:13  prosb
# JCC(2/10/97) - increase MAX_SUBCELLS from 1024 to 4100
#
#Revision 1.1  1996/11/04  21:56:29  prosb
#Initial revision
#JCC (10/31/96) - copied from /pros/xray/xlocal/imdetect/detect.h(rev9.0)
#
#
# maximal number of source (was 5000) 
define        MAX_SRCS        2000     
#ptr to start of blob
define	DET_ERROR	1
define BEG 		1
# of fields for blob limits info
define BLOB_LIMITS_FIELDS 	5
# of fields for blob pos sum info
define	BLOB_SUM_FIELDS	3
# ptr to end of blob
define	END		2
#indicates blob rec is storing data
define	IN_USE		1
# max subcells for array dim; was 1024 (JCC)
define	MAX_SUBCELLS    4097	
# max subcells for array dim of a blob
define	MAX_BLOBS	500
# max subcells for array dim of a box
define	MAX_BOX		502
# pos array delimiter:  was 250 ; peak_pos[2,MAX_POS]
define	MAX_POS		2000
# ct weight factor is net counts
define	NET		1
# indicates blob rec not storing data
define	NOT_IN_USE	0
# indicates subcell is below thresh
define	OFF		0
# indicates subcell is above thresh
define	ON		1
# ct weight factor is sigma sqrd type
define	SIG_SQRD	2
#ptr to status of blob
define	STATUS		1
# ptr to total cwf for blob
define	TOTAL_CWF	3
# cptr to cwf for X
define	X_SUM		1
# ptr to max X coord in blob
define	X_MAX		3
# ptr to min X coord in blob
define	X_MIN		2
# X cordinate ptr
define	X_POS		1
# ptr to cwf for Y
define	Y_SUM		2
# ptr to max Y coord of blob
define	Y_MAX		5
# ptr to min Y coord of blob
define	Y_MIN		4
# Y coordinate ptr
define	Y_POS		2
