#$Header: /home/pros/xray/xdataio/fits2qp/RCS/fits2qp.h,v 11.0 1997/11/06 16:34:27 prosb Exp $
#$Log: fits2qp.h,v $
#Revision 11.0  1997/11/06 16:34:27  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:38  prosb
#General Release 2.4
#
#Revision 8.3  1995/02/16  21:21:14  prosb
#Modified FITS2QP to correctly apply TSCAL/TZERO on extensions with
#columns which contain an array of values.  Also modified FITS2QP to
#not be so picky as to force the final index number to match the number
#of fields in an extension.  (I.e., if an extension has 8 columns, and
#TFIELD is set to 8, we can have "TUNIT5" as the final header card.)
#
#Revision 8.2  94/09/16  16:33:17  dvs
#Added EXT_SCALE, EXT_ZERO, EXT_IS_EV_INDEX to extension structure.
#
#Revision 8.1  94/06/30  16:55:16  mo
#MC	6/30/94		Add structure for TCD rotation matrix
#
#Revision 8.0  94/06/27  15:20:14  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:43  prosb
#General Release 2.3
#
#Revision 6.2  93/12/15  11:44:38  mo
#MC	12/15/93		Add support for TLMIN/MAX keywords
#
#Revision 6.1  93/12/08  13:16:16  mo
#MC	12/1/93		The WCS struct never got checked in last May
#
#Revision 5.0  92/10/29  21:36:39  prosb
#General Release 2.1
#
#Revision 4.1  92/07/13  14:12:15  jmoran
#*** empty log message ***
#
#Revision 4.0  92/04/27  15:01:25  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:13:56  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:26:27  pros
#General Release 1.0
#
# define the number of bytes in a FITS buffer
define FITS_BUFFER	2880

# define number of FITS cards in one FITS block
define MAX_CARDS	36

# max items to read at one time
define MAX_GET 2048

# define structure to hold column information for an extension table
define  SZ_EXT		10

define  EXT             (($1)+(($2)-1)*SZ_EXT)
define  EXT_SCALE       Memd[P2D(($1))]
define  EXT_ZERO        Memd[P2D(($1)+2)]
define	EXT_FORM	Memi[($1)+4]
define	EXT_TYPE	Memi[($1)+5]
define	EXT_UNIT	Memi[($1)+6]
define  EXT_IS_EV_INDEX Memi[($1)+7]
define  EXT_REPCNT      Memi[($1)+8]
# Plus one extra for word alignment.

# define returns from ft_nxtext
define  END	0
define	AUX	1
define	EVENT   2
define  SKIP	3

# qpoe defaults
define QPC_PAGESIZE	1024 		# qpoe page size
define QPC_BUCKETLEN	2048		# qpoe bucket length
define QPC_BLOCKFACTOR	1		# qpoe default block factor
define QPC_MKINDEX	TRUE		# make a qpoe index?
define QPC_KEY		""  		# key for qpoe index
define QPC_DEBUG	0   		# qpoe debug level
define SZ_KEY		20		# size of sort key
define REV1_VAL        	1
define DEFAULT_AXLEN 	2


# define RATFITS WCS structure
# (This size must be even.  If it is 13, a SEGV occurs.)
define  SZ_WCS_STRUCT   18

define  TCRPX   Memd[P2D($1 + SZ_WCS_STRUCT*($2-1) + 0)]
define  TCRVL   Memd[P2D($1 + SZ_WCS_STRUCT*($2-1) + 2)]
define  TCDLT   Memd[P2D($1 + SZ_WCS_STRUCT*($2-1) + 4)]
define  TCROT   Memd[P2D($1 + SZ_WCS_STRUCT*($2-1) + 6)]
define  TALEN   Memi[$1 + SZ_WCS_STRUCT*($2-1)+ 8]
define  TLMIN   Memi[$1 + SZ_WCS_STRUCT*($2-1)+ 9]
define  TLMAX   Memi[$1 + SZ_WCS_STRUCT*($2-1)+10]
define  TFORM   Memi[$1 + SZ_WCS_STRUCT*($2-1)+11]
define  TTYPE   Memi[$1 + SZ_WCS_STRUCT*($2-1)+12]
define  TUNIT   Memi[$1 + SZ_WCS_STRUCT*($2-1)+13]
define  TCTYP   Memi[$1 + SZ_WCS_STRUCT*($2-1)+14]
define  TCDPT   Memi[($1) + 15]
define  TNAXES  Memi[($1) + 16]

define  TCDM    Memd[TCDPT(($1))+(($3)-1)*TNAXES($1)+($2)-1]
