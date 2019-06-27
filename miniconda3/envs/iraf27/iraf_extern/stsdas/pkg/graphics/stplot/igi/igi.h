# Include file for igi structures

# 1/31/91 add half-filled marker style HALF_MARKER.  ZGL
# 2/4/91 add image section WCS flag MG_IMGWCS.  ZGL
# 2/11/91 changed version to 3.0.  ZGL
# 9/17/91  Added IMAGE_DATA, bumped version to 3.1.  ZGL
# 28 May 1992  Changed version to 3.2 with several changes.  ZGL
# 12 June 1992  Add STDOUT_REDIR, bump version to 3.3.  ZGL
# 16 June 1992  Add FONTS defines, changed MG_QUALITY to MG_FONTSET.  ZGL
# 25 June 1992	Add ZMIN, ZMAX, CMAP.  Change version to 3.4.  ZGL
# 17 July 1992  Add FILLPAT and it's macros.  ZGL
# 7 August 1992  Add MG_CMMIN and MG_CMMAX for color map manipulations.  ZGL
# 7 October 1992 Fix MG_FILLPAT, had redundant index.  ZGL
# 15 March 1993  Removed the version to a separate include file,
#  version.h so we don't have to recompile everything if the version
#  changes.


# Parameter macro definitions

# Types of input data
define	NO_DATA		0
define	TEXT_DATA	1
define	TABLE_DATA	2
define	IMAGE_DATA	3

# Text parameters
define	ROMAN_FONT	1
define	GREEK_FONT	2
define	SCRIPT_FONT	3
define	TINY_FONT	4

define	LOW_QUALITY	1
define	MEDIUM_QUALITY	2
define	HIGH_QUALITY	3

define	SOFT_FONTS	1
define	HARD_FONTS	2
define	IGI_FONTS	3
define	GIO_FONTS	4

# Point marker attributes
define	OPEN_MARKER	0
define	SKELETAL_MARKER	1
define	STARRED_MARKER	2
define	SOLID_MARKER	3
define	HALF_MARKER	4

define	DOWN		1
define	RIGHT		2
define	UP		3
define	LEFT		4

# Line styles
define	CLEAR_LINE	-1
define	SOLID_LINE	0
define	DOTTED_LINE	1
define	SHORT_DASH	2
define	LONG_DASH	3
define	DOT_SHORT_DASH	4
define	DOT_LONG_DASH	5
define	SHORT_LONG_DASH	6

# Color Index
define	MAX_CI		16

# Error bar styles
define	BAR_TICK	1
define	BAR_ONLY	2
define	TICK_ONLY	3
define	UPPER_LOWER	4

# Fill patterns
define	CLEAR_FILL	0
define	HOLLOW_FILL	1
define	SOLID_FILL	2
define	HATCH_FILL	4


# Expression evaluation error conditions
define	NO_DATA		8
define	INSUF_DATA	9
define	NULL_OPER	10

define	LEN_COMMAND	12
define	MAX_TILES	15

define	CONSTANT	257
define	IDENTIFIER	258
define	NEWLINE		259
define	NEWCMD		260
define	NEWARG		261
define	ARGUMENT	262
define	COMMENT		263
define	STRING		264

define	COMMAND_MODE	1
define	DEFINE_MODE	2
define	INPUT_MODE	4
define	PLAYBACK_MODE	8
define	CURSOR_MODE	16
define	EXPAND_MODE	32

define	IS_STATE	(and(CMD_STATE($1),($2))!=0)
define	IS_DELIM	((IS_WHITE($1))||(IS_NEWCOMMAND($1))||(($1)==','))
define	IS_NEWCOMMAND	((($1)==';')||(($1)=='\n'))
define	IS_CMDMODE	(IS_STATE(($1),COMMAND_MODE))


# igi parameters structure
define	LEN_IGS		21			# Structure size
define	CMD_STATE	Memi[($1)+1]		# Command state
define	CMD_BUFFER	Memi[($1)+2]		# Command buffer (spool) file descriptor
define	ALL_COMMANDS	Memi[($1)+3]		# Full command buffer (spool) file descriptor
define	CMD_SEQUENCE	Memi[($1)+4]		# Command number
define	LAST_CMD_PNT	Memi[($1)+5]		# Last command buffer location
define	LAST_COMMAND	Memc[LAST_CMD_PNT($1)]	# Last command 
define	PLOT_CMD_PNT	Memi[($1)+6]		# Last plot command buffer loc
define	PLOT_COMMAND	Memc[PLOT_CMD_PNT($1)]	# Last graphics output command 
define	WRITE_CMD	Memi[($1)+7]		# Write command to buffer?
define	SPOOL_OUT_PNT	Memi[($1)+8]		# Temp output file name pointer
define	SPOOL_OUTPUT	Memc[SPOOL_OUT_PNT($1)]	# Temp output file name

define	SYM_TABLE	Memi[($1)+11]		# Symbol table pointer
define	TOKEN_VALUE	Memi[($1)+12]		# Token value structure
define	INPUT_SOURCE	Memi[($1)+13]		# Input stream descriptor
define	INPUT_STACK	Memi[($1)+14]		# Input stream stack
define	STATE_STACK	Memi[($1)+15]		# Command state stack
define	GIO_GP		Memi[($1)+16]		# Graphics pointer
define	DEBUG_OUTPUT	Memi[($1)+17]		# Debug output?
define	PLOT_PARMS	Memi[($1)+18]		# Plot parameters structure ptr
define	STDOUT_REDIR	Memi[($1)+19]		# STDOUT redirected?
define	PRINT_ERROR	Memi[($1)+20]		# Print error?

# SYMTAB default allocation parameters (non-limiting).
define	LEN_INDEX	40		# nbuckets in symtab hash index
define	LEN_STAB	150		# initial symbol table size
define	SZ_SBUF		1024		# initial string buffer size

# Symbol table structure.
define	LEN_SYMSTRUCT	4
define	SYM_VALUE	Memi[($1)]	# SBUF offset of value string
define	SYM_STROFF	Memi[($1)+1]	# SBUF offset of macro text
define	SYM_NMACARG	Memi[($1)+2]	# Number of macro arguments
define	SYM_MARGOFF	Memi[($1)+3]	# SBUF offset to macro arguments

# Lexical analyser output structure
define	LEN_LOPS	5			# Size of structure
define	LOP_TYPE	Memi[($1)]		# Data type
define	LOP_VALP	Memi[($1)+1]		# Pointer
define	LOP_VALC	Memc[LOP_VALP($1)]	# String value
define	LOP_VALI	Memi[($1)+2]		# Integer value
define	LOP_VALR	Memr[($1)+2]		# Real value
define	LOP_ARGN	Memi[($1)+2]		# Macro argument index
define	LOP_LEN		Memi[($1)+3]		# Size of string operand
define	LOP_PUSHED	Memi[($1)+4]		# Text pushed back on input?

# Stack structure
define	LEN_STKS	3			# Structure size
define	STK_DEF_SIZE	10			# Starting stack depth
define	STK_DEPTH	Memi[($1)]		# Depth of stack
define	STK_STACK	Memi[($1)+1]		# File descriptor stack
define	STK_INDEX	Memi[($1)+2]		# Input file index
define	STK_VALUE	Memi[STK_STACK($1)+STK_INDEX($1)-1]


define	DATA_SIZE	1000			# Initial data buffer size

# Text attributes
define	TEXT_ESCAPE	'\\'
define	MG_DEF_SLANT 	0.21
define	MG_DEF_SUPFRAC 	0.6
define	MG_DEF_CHARSIZE	0.0125
define	MG_DEF_PNTSIZE	MG_DEF_CHARSIZE
define	MG_DEF_PNTFILL	1.5
define	MG_DEF_STELLAR	0.25

# Pixmap filter functions
define	MG_PMF_CMAP	-1
define	MG_PMF_NONE	0
define	MG_PMF_LINEAR	1
define	MG_PMF_LOG	2
define	MG_PMF_SQRT	3
define	MG_PMF_HEQ	4


# Structure for igi plotting parameters

define	LEN_MGSTR	127			# Size of structure

# Data parameters
define	MG_DATASRC	Memi[($1)+1]		# Type of input data
define	MG_DATAFN_P	Memi[($1)+2]		# Input data file name location
define	MG_FILE_NAME	Memc[MG_DATAFN_P($1)]	# Input data file name 
define	MG_COLNAME_P	Memi[($1)+3]		# Table column name
define	MG_COLNAME	Memc[MG_COLNAME_P($1)]	# Table column name
define	MG_COLNUM	Memi[($1)+4)		# Text column number
define	MG_FROW		Memi[($1)+5]		# Starting row number
define	MG_LROW		Memi[($1)+6]		# Ending row number
define	MG_NPTS		Memi[($1)+7]		# Number of data values
define	MG_DRAW		Memi[($1)+8]		# Draw (or erase) lines YES|NO

define	MG_SNPTS	Memi[($1)+9]		# Size of Scratch data vector
define	MG_SDATAP	Memi[($1)+10]		# Pointer to Scratch data vector
define	MG_XNPTS	Memi[($1)+11]		# Size of X data vector
define	MG_XDATAP	Memi[($1)+12]		# Pointer to X data vector
define	MG_YNPTS	Memi[($1)+13]		# Size of Y data vector
define	MG_YDATAP	Memi[($1)+14]		# Pointer to Y data vector
define	MG_ENPTS	Memi[($1)+15]		# Size of Error data vector
define	MG_EDATAP	Memi[($1)+16]		# Pointer to Error data vector
define	MG_PNPTS	Memi[($1)+17]		# Size of Marker data vector
define	MG_PDATAP	Memi[($1)+18]		# Pointer to Marker data vector
define	MG_LNPTS	Memi[($1)+19]		# Size of Limits data vector
define	MG_LDATAP	Memi[($1)+20]		# Pointer to Limits data vector

# Plot attributes
define	MG_LTYPEN	Memi[($1)+21]		# Line style code
define	MG_LTYPE_P	Memi[($1)+22]		# Line style string pointer
define	MG_LTYPE	Memc[MG_LTYPE_P($1)]	# Line style
define	MG_LWEIGHT	Memr[($1)+23]		# Line weight (width)
define	MG_CHARSIZE	Memr[($1)+24]		# Text and point size (NDC)
define	MG_EXPAND	Memr[($1)+25]		# Text and marker size
define	MG_ANGLE	Memr[($1)+26]		# Text and marker angle
define	MG_SLANT 	Memr[($1)+27]		# Italic text slant
define	MG_SUPFRAC 	Memr[($1)+28]		# Text superscript fraction
define	MG_IJUSTC	Memi[($1)+29]		# Text justification code
define	MG_FONTSET	Memi[($1)+30]		# Font set (gio or igi)

define	MG_PTYPN	Memi[($1)+31]		# Number of marker vertices
define	MG_PTYPS	Memi[($1)+32]		# Marker style code
define	MG_PNTSIZE	Memr[($1)+33]		# Point size
define	MG_PNTFILL	Memr[($1)+34]		# Solid point fill factor
define	MG_STELLAR	Memr[($1)+35]		# Stellar point factor
define	MG_PTYPE_P	Memi[($1)+36]		# Point type string pointer
define	MG_PTYPE	Memc[MG_PTYPE_P($1)]	# Point type string 
define	MG_EBTYPE	Memi[($1)+37]		# Error bar style

define	MG_COLOR	Memi[($1)+39]		# Color index

define	MG_IMGWCS	Memi[($1)+40]		# Use WCS from image section?

define	MG_XLOG		Memi[($1)+41]		# X axis log?
define	MG_YLOG		Memi[($1)+42]		# Y axis log?

# Pen position
define	MG_XPOS		Memr[($1)+44]		# Pen X position
define	MG_YPOS		Memr[($1)+45]		# Pen Y position

# Window scaling
define	MG_NXPANE	Memi[($1)+46]		# Horizonatal panes
define	MG_NYPANE	Memi[($1)+47]		# Vertical panes
define	MG_PANE		Memi[($1)+48]		# Pane (wcs) number

define	MG_WINDLEFT	Memr[($1)+51]		# Left edge of data window
define	MG_WINDRIGHT	Memr[($1)+52]		# Rigth edge of data window
define	MG_WINDBOTTOM	Memr[($1)+53]		# Bottom edge of data window
define	MG_WINDTOP	Memr[($1)+54]		# Top edge of data window

define	MG_PAGELEFT	Memr[($1)+61]		# Left edge of virtual page
define	MG_PAGERIGHT	Memr[($1)+62]		# Right edge of virtual page
define	MG_PAGEBOTTOM	Memr[($1)+63]		# Bottom edge of virtual page
define	MG_PAGETOP	Memr[($1)+64]		# Top edge of virtual page

define	MG_VIEWLEFT	Memr[($1)+65]		# Left edge of viewport
define	MG_VIEWRIGHT	Memr[($1)+66]		# Right edge of viewport
define	MG_VIEWBOTTOM	Memr[($1)+67]		# Bottom edge of viewport
define	MG_VIEWTOP	Memr[($1)+68]		# Top edge of viewport

# Axis labeling
define	MG_MINORX	Memr[($1)+71]		# Minor X tick spacing
define	MG_MINORY	Memr[($1)+72]		# Minor Y tick spacing
define	MG_MAJORX	Memr[($1)+73]		# Major X tick spacing
define	MG_MAJORY	Memr[($1)+74]		# Major Y tick spacing
define	MG_XLEXP	Memr[($1)+75]		# Exponential notation?
define	MG_XHEXP	Memr[($1)+76]		# Exponential notation?
define	MG_YLEXP	Memr[($1)+77]		# Exponential notation?
define	MG_YHEXP	Memr[($1)+78]		# Exponential notation?
define	MG_GXSTEP	Memr[($1)+79]		# X grid spacing
define	MG_GYSTEP	Memr[($1)+80]		# Y grid spacing

define	MG_SEXAGX	Memi[($1)+81]		# Label X in sexagesimal?
define	MG_SEXAGY	Memi[($1)+82]		# Label Y in sexagesimal?
define	MG_SEXAGS	Memi[($1)+83]		# Label in sexagesimal?
define	MG_NDECMX	Memi[($1)+84]		# Precision of X sex. label
define	MG_NDECMY	Memi[($1)+85]		# Precision of Y sex. label
define	MG_NDECIM	Memi[($1)+86]		# Precision of sex. label

define	MG_GSTEP	Memr[($1)+90]		# Last major tick spacing

define	MG_TITLE_P	Memi[($1)+91]		# Plot title
define	MG_TITLE	Memc[MG_TITLE_P($1)]	# Plot title
define	MG_XLABEL_P	Memi[($1)+92]		# X axis label
define	MG_XLABEL	Memc[MG_XLABEL_P($1)]	# X axis label
define	MG_YLABEL_P	Memi[($1)+93]		# Y axis label
define	MG_YLABEL	Memc[MG_YLABEL_P($1)]	# Y axis label

define	MG_TICKFMT_P	Memi[($1)+94]		# Axis tick format
define	MG_TICKFMT	Memc[MG_TICKFMT_P($1)]	# Axis tick format

define	MG_ZDATAP	Memi[($1)+101]		# Pointer to Z data buffer
define	MG_ZNPTS	Memi[($1)+102]		# Size of Z data buffer
define	MG_ZNPTSX	Memi[($1)+103]		# X size of Z data buffer
define	MG_ZNPTSY	Memi[($1)+104]		# Y size of Z data buffer
define	MG_ZMIN		Memr[($1)+106]		# Minimum z value
define	MG_ZMAX		Memr[($1)+107]		# Maximum z value
define	MG_CMAPP	Memi[($1)+108]		# Color map buffer
define	MG_CMNPTS	Memi[($1)+109]		# Size of color map buffer
define	MG_ZFUNC	Memi[($1)+110]		# Pixmap filter function
define	MG_CMMIN	Memi[($1)+111]		# Minimum cmap value
define	MG_CMMAX	Memi[($1)+112]		# Maximum cmap value

define	MG_FILLPAT	Memi[($1)+113]		# Fill pattern
