# ACECLUSTER

define	CL_STRUCT	"aceproto$ac.h"

define	ID_NUM		 0 # i		/ Record identification
define	ID_CLUSTER	 1 # i		/ Assigned cluster identification
define	ID_NCLUSTER	 2 # i		/ Number of records in cluster
define	ID_C1		 3 # r		/ Clustering field (2D)
define	ID_C2		 4 # r		/ Cond clustering field (2D)
define	ID_C3		 5 # r		/ Clustering field (1D)
define	ID_C4		 6 # r		/ Clustering field (1D)
define	ID_F1		 7 # r		/ Non-clustering field
define	ID_F2		 8 # r		/ Non-clustering field
define	ID_F3		 9 # r		/ Non-clustering field
define	ID_AVC1		10 # r		/ Averge of clustering field
define	ID_AVC2		11 # r		/ Averge of clustering field
define	ID_AVC3		12 # r		/ Averge of clustering field
define	ID_AVC4		13 # r		/ Averge of clustering field
define	ID_AVF1		14 # r		/ Average of non-clustering field
define	ID_AVF2		15 # r		/ Average of non-clustering field
define	ID_AVF3		16 # r		/ Average of non-clustering field

define	CL_NUM		RECI($1,ID_NUM)
define	CL_CL		RECI($1,ID_CLUSTER)
define	CL_NCL		RECI($1,ID_NCLUSTER)
define	CL_C1		RECR($1,ID_C1)
define	CL_C2		RECR($1,ID_C2)
define	CL_C3		RECR($1,ID_C3)
define	CL_C4		RECR($1,ID_C3)
define	CL_F1		RECR($1,ID_F1)
define	CL_F2		RECR($1,ID_F2)
define	CL_F3		RECR($1,ID_F3)
define	CL_AVC1		RECR($1,ID_AVC1)
define	CL_AVC2		RECR($1,ID_AVC2)
define	CL_AVC3		RECR($1,ID_AVC3)
define	CL_AVC4		RECR($1,ID_AVC4)
define	CL_AVF1		RECR($1,ID_AVF1)
define	CL_AVF2		RECR($1,ID_AVF2)
define	CL_AVF3		RECR($1,ID_AVF3)

define	CL_NC		4	# Number of clustering fields
define	CL_NF		3	# Number of non-clustering fields
