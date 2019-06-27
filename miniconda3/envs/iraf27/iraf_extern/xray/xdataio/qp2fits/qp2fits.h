#JCC(9/18/97)- Add 18 keywords to a new lookup table (make_lookup3),
#             so increase MAX_LOOKUP by 18 (101 -> 119).
define  USER_AREA       Memc[($1+IMU-1)*SZ_STRUCT + 1]
define  KEY_MAX         10
define  MAX_LOOKUP      119 
define  DIFF_FNAME      "diff.out"
define	SPLIT_LINE	53
