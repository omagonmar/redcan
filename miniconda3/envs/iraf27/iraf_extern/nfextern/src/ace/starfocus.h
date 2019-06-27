# STARFOCUS

# Types of coordinates
define	SF_TYPES	"|center|mark1|markall|"
define	SF_CENTER	1		  # Star at center of image
define	SF_MARK1	2		  # Mark stars in first image
define	SF_MARKALL	3		  # Mark stars in all images

# Task type
define	STARFOCUS	1
define	PSFMEASURE	2
define	STFFOCUS	3

# Radius types
define	SF_WTYPES	"|Radius|FWHM|GFWHM|MFWHM|"

define	SF_RMIN		16		  # Minimum centering search radius
define	MAX_FRAMES	8		  # Maximum number of display frames

# Data structures for STARFOCUS

define	NBNDRYPIX	100		  # Number of boundary pixels
define	TYBNDRY		BT_REFLECT	  # Type of boundary extension
define	SAMPLE		.2		  # Subpixel sampling size
define	SF_SZFNAME	79		  # Length of file names
define	SF_SZWTYPE	7		  # Length of width type string

# Main data structure
define	SF		42
define	SF_TASK		Memi[$1]	  # Task type
define	SF_WTYPE	Memc[P2C($1+1)]	  # Width type string
define	SF_WCODE	Memi[$1+5]	  # Width code
define	SF_BETA		Memr[P2R($1+6)]	  # Moffat beta
define	SF_SCALE	Memr[P2R($1+7)]	  # Pixel scale
define	SF_LEVEL	Memr[P2R($1+8)]	  # Profile measurement level
define	SF_RADIUS	Memr[P2R($1+9)]	  # Profile radius
define	SF_SBUF		Memr[P2R($1+10)]  # Sky region buffer
define	SF_SWIDTH	Memr[P2R($1+11)]  # Sky region width
define	SF_SAT		Memr[P2R($1+12)]  # Saturation
define	SF_NIT		Memi[$1+13]	  # Number of iterations for radius
define	SF_RSIG		Memr[P2R($1+14)]  # Size sigma clip at each focus
define	SF_FSIG		Memr[P2R($1+15)]  # Best focus sigma clip
define	SF_OVRPLT	Memi[$1+16]	  # Overplot the best profile?
define	SF_NCOLS	Memi[$1+17]	  # Number of image columns
define	SF_NLINES	Memi[$1+18]	  # Number of image lines
define	SF_XF		Memr[P2R($1+19)]  # X field center
define	SF_YF		Memr[P2R($1+20)]  # Y field center
define	SF_GP		Memi[$1+21]	  # GIO pointer
define	SF_F		Memr[P2R($1+22)]  # Best focus
define	SF_W		Memr[P2R($1+23)]  # Width at best focus
define	SF_M		Memr[P2R($1+24)]  # Brightest star magnitude
define	SF_XP1		Memr[P2R($1+25)]  # First derivative point to plot
define	SF_XP2		Memr[P2R($1+26)]  # Last derivative point to plot
define	SF_YP1		Memr[P2R($1+27)]  # Minimum of derivative profile
define	SF_YP2		Memr[P2R($1+28)]  # Maximum of derivative profile
define	SF_N		Memi[$1+29]	  # Number of points not deleted
define	SF_NSFD		Memi[$1+30]	  # Number of data points
define	SF_SFDS		Memi[$1+31]	  # Pointer to data structures
define	SF_NS		Memi[$1+32]	  # Number of stars not deleted
define	SF_NSTARS	Memi[$1+33]	  # Number of stars
define	SF_STARS	Memi[$1+34]	  # Pointer to star groups
define	SF_NF		Memi[$1+35]	  # Number of focuses not deleted
define	SF_NFOCUS	Memi[$1+36]	  # Number of different focus values
define	SF_FOCUS	Memi[$1+37]	  # Pointer to focus groups
define	SF_NI		Memi[$1+38]	  # Number of images not deleted
define	SF_NIMAGES	Memi[$1+39]	  # Number of images
define	SF_IMAGES	Memi[$1+40]	  # Pointer to image groups
define	SF_BEST		Memi[$1+41]	  # Pointer to best focus star

define	SF_SFD		Memi[SF_SFDS($1)+$2-1]
define	SF_SFS		Memi[SF_STARS($1)+$2-1]
define	SF_SFF		Memi[SF_FOCUS($1)+$2-1]
define	SF_SFI		Memi[SF_IMAGES($1)+$2-1]

# Basic data structure.
define	SFD		98
define	SFD_IMAGE	Memc[P2C($1)]	  # Image name
define	SFD_DATA	Memi[$1+40]	  # Pointer to real image raster
define	SFD_RADIUS	Memr[P2R($1+41)]  # Profile radius
define	SFD_NP		Memi[$1+42]	  # Number of profile points
define	SFD_NPMAX	Memi[$1+43]	  # Maximum number of profile points
define	SFD_X1		Memi[$1+44]	  # Image raster limits
define	SFD_X2		Memi[$1+45]
define	SFD_Y1		Memi[$1+46]
define	SFD_Y2		Memi[$1+47]
define	SFD_ID		Memi[$1+48]	  # Star ID
define	SFD_F		Memr[P2R($1+49)]  # Focus
define	SFD_RA		Memd[P2D($1+50)]  # RA (hours)
define	SFD_DEC		Memd[P2D($1+52)]  # DEC (deg)
define	SFD_X		Memr[P2R($1+54)]  # Star X position
define	SFD_Y		Memr[P2R($1+55)]  # Star Y position
define	SFD_W		Memr[P2R($1+56)]  # Width to use
define	SFD_M		Memr[P2R($1+57)]  # Magnitude
define	SFD_E		Memr[P2R($1+58)]  # Ellipticity
define	SFD_PA		Memr[P2R($1+59)]  # Position angle
define	SFD_R		Memr[P2R($1+60)]  # Radius at given level
define	SFD_DFWHM	Memr[P2R($1+61)]  # Direct FWHM
define	SFD_GFWHM	Memr[P2R($1+62)]  # Gaussian FWHM
define	SFD_MFWHM	Memr[P2R($1+63)]  # Moffat FWHM
define	SFD_ASI1	Memi[$1+64]	  # Pointer to enclosed flux profile
define	SFD_ASI2	Memi[$1+65]	  # Pointer to derivative profile
define	SFD_YP1		Memr[P2R($1+66)]  # Minimum of derivative profile
define	SFD_YP2		Memr[P2R($1+67)]  # Maximum of derivative profile
define	SFD_FWHM	Memr[P2R($1+$2+67)]# FWHM vs level=0.5*i (i=1-19)
define	SFD_BKGD	Memr[P2R($1+87)]  # Background value
define	SFD_BKGD1	Memr[P2R($1+88)]  # Original background value
define	SFD_MISO	Memr[P2R($1+89)]  # Moment isophote
define	SFD_SIGMA	Memr[P2R($1+90)]  # Moffat alpha
define	SFD_ALPHA	Memr[P2R($1+91)]  # Moffat alpha
define	SFD_BETA	Memr[P2R($1+92)]  # Moffat beta
define	SFD_STATUS	Memi[$1+93]	  # Status
define	SFD_NSAT	Memi[$1+94]	  # Number of saturated pixels
define	SFD_SFS		Memi[$1+95]	  # Pointer to star group
define	SFD_SFF		Memi[$1+96]	  # Pointer to focus group
define	SFD_SFI		Memi[$1+97]	  # Pointer to image group


# Structure grouping data by star.
define	SFS		($1+7)
define	SFS_ID		Memi[$1]	  # Star ID
define	SFS_F		Memr[P2R($1+1)]	  # Best focus
define	SFS_W		Memr[P2R($1+2)]	  # Best width
define	SFS_M		Memr[P2R($1+3)]	  # Average magnitude
define	SFS_N		Memi[$1+4]	  # Number of points used
define	SFS_NF		Memi[$1+5]	  # Number of focuses
define	SFS_NSFD	Memi[$1+6]	  # Number of data points
define	SFS_SFD		Memi[$1+$2+6]	  # Array of data structures


# Structure grouping stars by focus values.
define	SFF		($1+5)
define	SFF_F		Memr[P2R($1)]	  # Focus
define	SFF_W		Memr[P2R($1+1)]	  # Average width
define	SFF_N		Memi[$1+2]	  # Number in average
define	SFF_NI		Memi[$1+3]	  # Number of images
define	SFF_NSFD	Memi[$1+4]	  # Number of data points
define	SFF_SFD		Memi[$1+$2+4]	  # Array of data structures


# Structure grouping stars by image.
define	SFI		($1+42)
define	SFI_IMAGE	Memc[P2C($1)]	  # Image
define	SFI_N		Memi[$1+40]	  # Number in imagE
define	SFI_NSFD	Memi[$1+41]	  # Number of data points
define	SFI_SFD		Memi[$1+$2+41]	  # Array of data structures
