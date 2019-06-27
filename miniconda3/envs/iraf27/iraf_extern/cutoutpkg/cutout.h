# Definitions file for the Deep Wide Survey CUTOUT task

define	CT_SCAN		1
define	CT_LIST		2
define	CT_CUTOUT	3

define	CT_LARGEST	1
define	CT_COLLAGE	2


define  CT_SZ_FNAME   (1 + SZ_FNAME) / 2

# Definitions for the field center symbol table.

define  LEN_CTFC_STRUCT (12 + 4 * CT_SZ_FNAME)

define  CT_FCRA       Memd[P2D($1)]                # the field center ra / lon
define  CT_FCDEC      Memd[P2D($1+2)]              # the field center dec / lat
define  CT_FCRAWIDTH  Memd[P2D($1+4)]              # the field ra / lon width
define  CT_FCDECWIDTH Memd[P2D($1+6)]              # the field dec / lat width
define  CT_FCXWIDTH   Memi[$1+8]                   # the field ra / lon width
define  CT_FCYWIDTH   Memi[$1+9]                   # the field dec / lat width
define  CT_FCRAUNITS  Memi[$1+10]                  # the ra / lon units
define  CT_FCDECUNITS Memi[$1+11]                  # the dec / lat units
define  CT_FCSYSTEM   Memc[P2C($1+12)]             # the field center system
define  CT_FCFILTERS  Memc[P2C($1+12+CT_SZ_FNAME)] # the filter list
define  CT_FCFILDICT  Memc[P2C($1+12+2*CT_SZ_FNAME)] # the filter dictionary
define  CT_FCOBJNAME  Memc[P2C($1+12+3*CT_SZ_FNAME)] # the object name

define	DEF_LEN_CTFC  		100
define	DEF_CTFC_ROOTNAME	"fc"
define	DEF_FCSYSTEM		"ICRS"
define	SZ_OBJNAME		63


# Definitions for image list symbol table

define  LEN_CTIM_STRUCT (38 + 2 * CT_SZ_FNAME)

# The field center limits in projected coordinates.

define	CT_IMXIOFF     Memd[P2D($1)]
define	CT_IMETAOFF    Memd[P2D($1+2)]

define  CT_IMXIC       Memd[P2D($1+4)] 
define  CT_IMETAC      Memd[P2D($1+6)] 
define  CT_IMXIMIN     Memd[P2D($1+8)] 
define  CT_IMXIMAX     Memd[P2D($1+10)]
define  CT_IMETAMIN    Memd[P2D($1+12)]
define  CT_IMETAMAX    Memd[P2D($1+14)]

# The overlap region in projected coordinates.

define  CT_IMOXIMIN    Memd[P2D($1+16)]
define  CT_IMOXIMAX    Memd[P2D($1+18)]
define  CT_IMOETAMIN   Memd[P2D($1+20)]
define  CT_IMOETAMAX   Memd[P2D($1+22)]
define	CT_IMOAREA     Memd[P2D($1+24)]

# The overlap region in input image pixel coordinates.

define  CT_IMIX1       Memi[$1+26]
define  CT_IMIX2       Memi[$1+27]
define  CT_IMIY1       Memi[$1+28]
define  CT_IMIY2       Memi[$1+29]

# The overlap region in output image pixel coordinates.

define  CT_IMOX1       Memi[$1+30]
define  CT_IMOX2       Memi[$1+31]
define  CT_IMOY1       Memi[$1+32]
define  CT_IMOY2       Memi[$1+33]

# The output image region in input image pixel coordinates

define	CT_IMXMIN      Memi[$1+34]
define	CT_IMXMAX      Memi[$1+35]
define	CT_IMYMIN      Memi[$1+36]
define	CT_IMYMAX      Memi[$1+37]

define  CT_IMNAME      Memc[P2C($1+38)] 
define  CT_IMFILTER    Memc[P2C($1+38+CT_SZ_FNAME)]

define	DEF_LEN_CTIM  		100
define	DEF_CTIM_ROOTNAME	"im"

