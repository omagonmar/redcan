#$Header: /home/pros/xray/xdataio/fits2qp/RCS/mpefits.h,v 11.0 1997/11/06 16:35:34 prosb Exp $
#$Log: mpefits.h,v $
#Revision 11.0  1997/11/06 16:35:34  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:41:14  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:26:09  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:55  prosb
#General Release 2.1
#
#Revision 1.4  92/10/16  20:19:38  mo
#MC	10/16/92		Added instrument dependent offsets for
#				position offset values
#
#Revision 1.3  92/10/16  19:20:03  mo
#MC	10/16/92	Change HRI_PLACEHOLDER from 4 to 2 since we now
#			have PHA but not PI
#
#Revision 1.2  92/10/15  16:26:23  jmoran
#*** empty log message ***
#
#Revision 1.1  92/09/23  11:37:05  jmoran
#Initial revision
#
define  SIZE        Memi[$1]
define  TYPE        Memi[$1 + 1]
define  SUM         Memi[$1 + 2]
define	X_POS	    Memi[$1 + 3]
define  Y_POS	    Memi[$1 + 4]
define  DX_POS	    Memi[$1 + 5]
define  DY_POS	    Memi[$1 + 6]
define	TIME_POS    Memi[$1 + 7]
define	PHA_POS	    Memi[$1 + 8]
define	PI_POS	    Memi[$1 + 9]
define  SZ_MPE_STRUCT  10

define	FOUND_GTIS   Memb[$1 + 0]
define  PARSED_GTIS  Memb[$1 + 1]
define  COUNT_GTIS   Memi[$1 + 2]
define  GTI_PTR	     Memi[$1 + 3]
define	GTI_BUFSZ    Memi[$1 + 4]
define  SZ_GTI_STRUCT 5

define	MAX_GTIS	100

define	X_NAME		"xpix"
define  Y_NAME		"ypix"
define  DX_NAME		"xdet"
define  DY_NAME		"ydet"
define	PI_NAME		"ampl"
define	PHA_NAME	"raw_ampl"
define	TIME_NAME	"time"

define	HRI_X_OFFSET	4096
define  HRI_Y_OFFSET	4095
define  HRI_DX_OFFSET	-1
define	HRI_DY_OFFSET	-1
define	PSPC_X_OFFSET	7681
define  PSPC_Y_OFFSET	7680
define  PSPC_DX_OFFSET	1
define	PSPC_DY_OFFSET	1

define  FITS_BYTE       8       # Bits in a FITS byte
define  LSBF            NO      # Least significant byte first

#-----------------------------------------------------------------
# to be added to the sum of the bytes (in binary) this accounts
# for the PI (as shorts, 2 bytes, each) placeholder being
# added to the binary buffer for events
#-----------------------------------------------------------------
define	HRI_PLACEHOLDER		2

#define  ROSAT_SC_MJDRD          48043
#define  ROSAT_SC_MJDRF          0.8797453703700

# defines for values assigned for HRI and PSPC that aren't in the
# original MPE FITS file
# MP_ = MPE FITS PSPC
# MH_ = MPE FITS HRI
# No prefix = EITHER

define  CDELT1              	-1.388889E-4
define  CDELT2              	1.388889E-4

define	MP_CRPIX1		7.681000E3
define  MP_CRPIX2               7.681000E3
define  MP_CDELT1               30.0D0*(CDELT1)
define  MP_CDELT2               30.0D0*(CDELT2)

define  MH_CRPIX1               4.096000E3
define  MH_CRPIX2               4.097000E3
define  MH_CDELT1               16.0D0*(CDELT1)
define  MH_CDELT2               16.0D0*(CDELT2)

define  TELESCOP            	"ROSAT"
define  XS_CNTRY		"FRG"
define 	XS_MODE			1

# The following are defined in <rosat.h>
#RADECSYS 			  "FK5"
#CTYPE1 			  "RA---TAN"
#CTYPE2 			  "DEC--TAN"
#ROSAT_EQUINOX                    2000.0

