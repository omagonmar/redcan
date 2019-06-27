#$Header: /home/pros/xray/lib/RCS/spectral.h,v 11.0 1997/11/06 16:25:42 prosb Exp $
#$Log: spectral.h,v $
#Revision 11.0  1997/11/06 16:25:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:25:48  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:39  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/09  00:41:55  dennis
#Replaced DS_OFFAXIS_ANGLE with DS_REGION_OFFAXIS_ANGLE and 
#DS_MEAN_EVENT_OFFAXIS_ANGLE, to accommodate the two meanings.
#
#Revision 7.0  93/12/27  18:22:36  prosb
#General Release 2.3
#
#Revision 6.2  93/10/22  20:15:01  dennis
#Added pointer to array of offaxis angles, in DS structure definition.
#
#Revision 6.1  93/10/20  13:14:06  mo
#MC	10/20/93	Replace individual <inst.h> with mission.h which
#			knows all the <inst.h> names
#
#Revision 6.0  93/05/24  15:37:29  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:23:26  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:07:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/03/05  12:37:11  orszak
#jso - changes for new qpspec (background OAH)
#
#Revision 3.0  91/08/02  00:46:54  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:51:37  prosb
#jso - made spectral.h system wide, added DS_SEQNO, corrected xspectraldata
#      directory (need to change this) commented out SZ_PATHNAME (defined
#      elsewhere)
#
#Revision 2.0  91/03/06  23:07:35  pros
#General Release 1.0
#
# SPECTRAL.H  ---  Spectral Package Definitions.
#

include <qpoe.h>
#include <einstein.h>
#$include <rosat.h>
include <missions.h>

#     Part 1  ---  Parameter and constant definitions

define  SPECTRAL_BINS           180
define  MAX_PHA_BINS             15           # temporary
define  MAX_IPC_BINS             15
define  MAX_MPC_BINS              8
define  MAX_DATASETS             20
define  MAX_BALS                 85

define  MAX_MODELS                8
define  MAX_MODEL_PARAMS          7
define  MAX_LINKS		  (MAX_MODELS*MAX_MODEL_PARAMS)

define  FIXED_PARAM               0
define  FREE_PARAM                1
define  CALC_PARAM                2

define  LINEAR_AXIS               0
define  LOG_AXIS                  1


# define number of currently defined models
define  MAX_MODDEFS		  6
# define the model types
define  EMISSION_UNSPECIFIED      0
define  POWER_LAW                 1
define  BLACK_BODY                2
define  EXP_PLUS_GAUNT            3
define  EXPONENTIAL               4
define  RAYMOND                   5
define  SINGLE_LINE               6

define  COSMIC_ABUNDANCE          0
define  MEYER_ABUNDANCE           1

define  MORRISON_MCCAMMON         0
define  BROWN_GOULD               1

define  GRID_VERSION             (3)

# define  SZ_PATHNAME		 80

define  NORMALIZATION_ENERGY     1.0          # keV

# 
#     Part 2  ---  Numerical constants

define  PI                    3.1415927
define  PIXELS_PER_ARCMIN     7.5
define  ERGS_PER_KEV          1.602e-9           # ergs per keV
define  CM_PER_MPC            3.086e24           # centimeters per Megaparsec
define  CM_PER_KM             1.0e5              # centimeters per kilometer
define  CM_PER_KPC            3.086e21           # centimeters per kiloparsec
define  CM_PER_PARSEC         3.086e18           # centimeters per parsec
define  CM_PER_LIGHT_YEAR     9.460e17           # centimeters per light year
define  CM_PER_AU             1.495e13           # centimeters per astronomical unit
define  BOLTZMANNS_CONSTANT   1.38062e-16        # ergs per degree Kelvin


#     Part 3  ---  Error codes for this package

define  NO_ERROR                   0
define  NO_SPECTRAL_FIT_DONE      10
define  UNKNOWN_SEARCH_METHOD     11
define  NO_USER_DEFINED_SEARCH    12
define  GRID_EXCESS_PARAMETERS    13
define  NO_FREE_PARAMETERS        14
define  CONJUGATE_EXCESS_PARAMS   15
define  FILE_READ_ERROR          100

# 
#     Part 4  ---  Structure definitions

# Model structure
define  LEN_MODEL         11+4*MAX_MODEL_PARAMS
define  MODEL_NUMBER      Memi[$1]             # model number
define  MODEL_TYPE        Memi[$1+1]           # model emission type
define  MODEL_ABUNDANCE   Memi[$1+2]           # model abundance type
define  MODEL_PERCENTAGE  Memi[$1+3]           # abundance percentage
define  MODEL_PARAM_COUNT Memi[$1+4]           # number of parameters
define  MODEL_MIN_ENERGY  Memr[$1+5]           # minimum energy
define  MODEL_MAX_ENERGY  Memr[$1+6]           # maximum energy
define  MODEL_EMITTED     Memi[$1+7]           # component emitted spectrum
define  MODEL_INTRINS     Memi[$1+8]           # component intrinsic spectrum
define  MODEL_REDSHIFTED  Memi[$1+9]           # component redshifted spectrum
define  MODEL_INCIDENT    Memi[$1+10]          # component incident spectrum
define  MODEL_PAR_FIXED   Memi[$1+11+$2]       # free/fixed/calc'ed indicator
define  MODEL_PAR_VAL     Memr[$1+11+1*MAX_MODEL_PARAMS+$2] # parameter values
define  MODEL_PAR_DLT     Memr[$1+11+2*MAX_MODEL_PARAMS+$2] # parameter deltas
define  MODEL_PAR_LINK    Memi[$1+11+3*MAX_MODEL_PARAMS+$2] # parameter links

# define offsets into fixed, val, dlt, and link arrays
define  MODEL_ALPHA          0
define  MODEL_TEMP           1
define  MODEL_INTRINSIC      2
define  MODEL_GALACTIC       3
define  MODEL_REDSHIFT       4
define  MODEL_NORM           5
define  MODEL_WIDTH          6			# for single line arg #2


# Parameter structure for computing a spectrum.
define  LEN_FP            16+MAX_MODELS+MAX_DATASETS
define  FP_MODSTR	  Memi[$1+0]	       # model descriptor string
define  FP_METHOD         Memi[$1+1]           # indicates search method
define  FP_DATASETS       Memi[$1+2]           # number of datasets used
define  FP_CURDATASET     Memi[$1+3]           # current dataset number
define  FP_NBINS          Memi[$1+4]           # number of bins
define  FP_ABSORPTION     Memi[$1+5]           # absorption type
define  FP_ABUNDANCE      Memi[$1+6]           # abundance type
define  FP_PERCENTAGE     Memi[$1+7]           # abundance percentage
define  FP_FREE_COUNT     Memi[$1+8]           # degrees of freedom
define  FP_MODEL_COUNT    Memi[$1+9]           # number of models
define  FP_CHANNELS       Memi[$1+10]          # total channels fit
define  FP_NORM           Memr[$1+11]          # final normalization
define  FP_EMITTED        Memi[$1+12]          # total emitted spectrum
define  FP_INTRINS        Memi[$1+13]          # total intrinsic spectrum
define  FP_REDSHIFTED     Memi[$1+14]          # total redshifted spectrum
define  FP_INCIDENT       Memi[$1+15]          # total incident spectrum
define  FP_MODELSTACK     Meml[$1+16+$2-1]     # array of model pointers
define  FP_OBSERSTACK     Meml[$1+16+MAX_MODELS+$2-1] # array of dataset ptrs
# next free space $1+LEN_FP

# 
# Parameter structure for a given data set
define	BASE_DS		25			# base size of ds record
define	EXTRA_DS	50		        # extra info in ds record
define  LEN_DS          (BASE_DS+EXTRA_DS)	# base + extra

define  DS_REFNUM         Memi[$1+0]           # data set number
define  DS_FILENAME       Memi[$1+1]           # data set file name
define  DS_INSTRUMENT     Memi[$1+2]           # instrument code
define  DS_SUB_INSTRUMENT Memi[$1+3]           # sub instrument number
define  DS_LIVETIME       Memr[$1+4]           # live time
define  DS_SOURCE_RADIUS  Memr[$1+5]           # source radius
define  DS_REGION_OFFAXIS_ANGLE	 Memr[$1+6]    # region center off-axis angle
define  DS_MEAN_EVENT_OFFAXIS_ANGLE  Memr[$1+7] # mean event off-axis angle
define  DS_POINT	  Memi[$1+8]	       # is this a point source?
define  DS_ARCFRAC        Memr[$1+9]           # arcing fraction
define  DS_NPHAS          Memi[$1+10]          # number of PHA channels
define	DS_SCALE	  Memr[$1+11]	       # scale factor
define  DS_OBS_DATA       Memi[$1+12]          # pointer to observed data
define  DS_OBS_ERROR      Memi[$1+13]          # pointer to observed errors
define  DS_PRED_DATA      Memi[$1+14]          # pointer to predicted data
define  DS_CHANNEL_FIT    Memi[$1+15]          # pointer to channels fit
define  DS_BAL_HISTGRAM   Memi[$1+16]          # pointer to bal structure
define  DS_LO_ENERGY	  Memi[$1+17]	       # pointer to lo energy boundary
define  DS_HI_ENERGY	  Memi[$1+18]	       # pointer to hi energy boundary
define  DS_CHISQ_CONTRIB  Memi[$1+19]	       # pointer to chi-square contrib
define	DS_NOAH		  Memi[$1+20]	       # # Of offaxis histogram values
define	DS_OAHANPTR	  Memi[$1+21]          # pointer to OAH inner radii
define	DS_OAHAN	  Memr[DS_OAHANPTR($1)+$2]# offaxis histo inner radii
define	DS_OAHPTR	  Memi[$1+22]          # pointer to off axis histo
define	DS_OAH		  Memr[DS_OAHPTR($1)+$2]# offaxis histo values
define	DS_BK_OAHPTR	  Memi[$1+23]          # pointer to off axis histo
define	DS_BK_OAH	  Memr[DS_BK_OAHPTR($1)+$2]# offaxis histo values
define	DS_FILTER	  Memi[$1+24]		# Filter #

# The following are for information purposes only:
define	DS_MISSION	  Memi[($1)+0+BASE_DS]		# mission ID
define	DS_SOURCENO	  Memi[($1)+1+BASE_DS]		# source # from sdf
define  DS_X		  Memr[($1)+2+BASE_DS]  	# source X pos.
define	DS_Y		  Memr[($1)+3+BASE_DS]  	# source Y pos.
define	DS_OLD_Y	  Memr[($1)+4+BASE_DS]  	# Einst. Y pos.
define	DS_OLD_Z	  Memr[($1)+5+BASE_DS]  	# Einst. Z pos.
define	DS_RA		  Memr[($1)+6+BASE_DS]  	# RA
define	DS_DEC		  Memr[($1)+7+BASE_DS]  	# DEC
define	DS_EPOCH	  Memi[($1)+8+BASE_DS]		# Epoch
define	DS_GLONG	  Memr[($1)+9+BASE_DS]  	# galac. long.
define	DS_GLAT		  Memr[($1)+10+BASE_DS]  	# galac. lat.
define	DS_VIGNETTING	  Memr[($1)+11+BASE_DS] 	# vign. cor.
define	DS_LIVECORR	  Memr[($1)+12+BASE_DS] 	# livetime correction
define	DS_BAREA	  Memr[($1)+13+BASE_DS] 	# bkgd area
define	DS_SAREA 	  Memr[($1)+14+BASE_DS] 	# source area
define	DS_SOURCE	  Memi[($1)+15+BASE_DS]		# pointer to raw source
define	DS_BKGD		  Memi[($1)+16+BASE_DS]		# pointer to raw bkgd
define	DS_SEQNO	  Memc[P2C(($1)+17+BASE_DS)]		# sequence

# define which grid we have used for spatial componment of bal
define NO_GNI	0
define PSGNI	1
define DGNI	2

# Parameter structure for the BAL histogram
define  MAX_BAL_ENTRIES   MAX_BALS
define  BH_BASE		  8
define  LEN_BH            BH_BASE+2*MAX_BAL_ENTRIES
define  BH_ENTRIES        Memi[$1]
define  BH_BAL_STEPS      Memi[$1+1]		# steps in BAL tables
define  BH_START_BAL      Memr[$1+2]            # first BAL in tables
define  BH_END_BAL        Memr[$1+3]            # last BAL in tables
define  BH_BAL_INC        Memr[$1+4]		# BAL increment
define  BH_BAL_EPS        Memr[$1+5]		# epsilon for equality
define  BH_BAL_FLAG       Memi[$1+6]		# psgni or dgni (see above)
define  BH_MEAN_BAL       Memr[$1+7]		# mean of histogram BALS
define  BH_BAL		  Memr[$1+$2+BH_BASE]	# BAL array
define  BH_PERCENT	  Memr[$1+$2+BH_BASE+MAX_BAL_ENTRIES]
# next free space $1+LEN_BH

# 
# Structure for the grid search.

define  LEN_GS_AXIS       8
define  GS_AXIS_TYPE      TY_REAL
define  GS_STEPS          Memi[$1]
define  GS_AXISTYPE       Memi[$1+1]
define  GS_MODEL          Memi[$1+2]
define  GS_MODELTYPE      Memi[$1+3]
define  GS_PARAM          Memi[$1+4]
define  GS_FREETYPE       Memi[$1+5]
define  GS_PAR_VALUE      Memr[$1+6]
define  GS_DELTA          Memr[$1+7]

# Structure for the grid plot

define  LEN_GP            6
define  GP_ABS_TYPE       Memi[$1]
define  GP_CHANNELS       Memi[$1+1]
define  GP_FREEPRMS       Memi[$1+2]
define  GP_BESTCHISQ      Memr[$1+3]
define  GP_BEST_X         Memr[$1+4]
define  GP_BEST_Y         Memr[$1+5]

# 
# Structure for Raymond thermal file header.

#define  LEN_RT_HEADER     134              # word length of header structure
define  LEN_RT_HEADER     50                # word length of header structure (dmw)
define  LEN_CRE           8                       # char length of creation time
define  LEN_NAM           20                      # char length of file name
define  NO_ABUNDANCES     13
define  RT_REV            Memr[$1]
define  RT_CREATION       Memc[$1+1]
define  RT_NAME           Memc[$1+LEN_CRE+1]
define  RT_PERCENT        Memr[$1+LEN_CRE+LEN_NAM+1]
define  RT_ABUNDANCE      Memr[$1+LEN_CRE+LEN_NAM+2]
define  RT_NO_ABUND       Memi[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+2]
define  RT_MINENERGY      Memr[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+3]
define  RT_ENERGYSTEP     Memr[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+4]
define  RT_NO_BINS        Memi[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+5]
define  RT_START_TEMP     Memr[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+6]
define  RT_TEMP_INC       Memr[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+7]
define  RT_NO_TEMPS       Memi[$1+LEN_CRE+LEN_NAM+NO_ABUNDANCES+8]


define  LEN_RT_TABLE      (SPECTRAL_BINS+1)
define  RT_TABLE_TEMP     Memr[$1]
define  RT_SPECTRUM       Memr[$1+$2]




# 
#     Part 5  ---  Absorption table particulars

define  ABSORP_TABLE_LENGTH       14           # number of table entries
define  LEN_AB                     5           # number of units in one entry

# These are indices into a table entry.
define  AB_LOWER_ENERGY            1           # energy at low end of bin
define  AB_UPPER_ENERGY            2           # energy at high end of bin
define  AB_COEF0                   3           # "quadratic" coefficient
define  AB_COEF1                   4           # "linear" coefficient
define  AB_COEF2                   5           # "constant" coefficient




#     Part 6  ---  Effective area table particulars

define  AREA_TABLE_LENGTH        85           # number of entries
define  AREA_TABLE_ANGLES         9           # number of angles per entry
define  AREA_TABLE_STEP         4.0           # in off-axis angle



#     Part 7  ---  Response matrix particulars

define	DATA_DIRECTORY		 "xspectraldata$"
#define	DATA_DIRECTORY		 ""
define	RESPONSE_FILE_TEMPLATE	 "%sbal%3.1ftab"

define  RESPONSE_MATRIX         160
define  RESPONSE_MATRIX_BASE    0.05
define  RESPONSE_MATRIX_STEP    0.04




# 
#     Part 9  ---  Plotting parameters

define	PHOTON_PLOT_HELP	"xspectral$photon_plot.key"
define  PHOTON_CMD_KEYS		"|xlog|xlinear|ylog|ylinear|xmin|xmax|ymin|ymax|xunits|yunits|"
define  PHOTON_CMD_XLOG		 1
define  PHOTON_CMD_XLINEAR	 2
define  PHOTON_CMD_YLOG		 3
define  PHOTON_CMD_YLINEAR	 4
define  PHOTON_CMD_XMIN		 5
define	PHOTON_CMD_XMAX		 6
define	PHOTON_CMD_YMIN		 7
define  PHOTON_CMD_YMAX		 8
define  PHOTON_CMD_XUNITS	 9
define  PHOTON_CMD_YUNITS	10

define  SZ_PLOT_TITLE           25	     # length of title string
define  SZ_AXIS_TITLE           18           # length of axis title string
define  SZ_CUR_RESPONSE         12           # length of cursor command

define	LEN_PLOTSTRUCT		18

define  PL_FILENAME             Memi[$1+0]
define	PL_TITLE		Memi[$1+1]
define  PL_XTITLE		Memi[$1+2]
define	PL_YTITLE		Memi[$1+3]
define  PL_ERRORS		Memi[$1+4]   # plot error bars
define  PL_PREDICTED		Memi[$1+5]   # plot predicted curve
define  PL_MODELS               Memi[$1+6]   # plot model info
define  PL_DIFF			Memi[$1+7]   # plot diff between pred and obs
define  PL_XTRAN		Memi[$1+8]   # linear or log X axis
define  PL_YTRAN		Memi[$1+9]   # linear or log Y axis
define  PL_CURSORX		Memr[$1+10]   # current cursor location in X
define  PL_CURSORY		Memr[$1+11]  # current cursor location in Y
define	PL_XMIN			Memr[$1+12]
define  PL_XMAX			Memr[$1+13]
define	PL_YMIN			Memr[$1+14]
define	PL_YMAX			Memr[$1+15]
define	PL_XUNITS		Memr[$1+16]
define	PL_YUNITS		Memr[$1+17]
	
