#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcreate.h,v 11.0 1997/11/06 16:21:52 prosb Exp $
#$Log: qpcreate.h,v $
#Revision 11.0  1997/11/06 16:21:52  prosb
#General Release 2.5
#
#Revision 9.1  1996/08/21 15:14:46  prosb
#*** empty log message ***
#
#JCC - Comment out SZ_MACRO_STRING. Instead use SZ_TYPEDEF for 
#      prosdef_in/out and irafdef_in/out. 
#Revision 9.0  1995/11/16  18:29:40  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:21  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:36  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  11:47:06  mo
#MC/JM	5/20/93		moved from qpcreate.x
#
#Revision 5.0  92/10/29  21:19:00  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:39  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:22  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:19  pros
#General Release 1.0
#
#
#	qpcreate.h -- include file for qpcreate library
#
include <qpc.h>

# define the types of sorts we can do
define	NO_SORT		0
define	XY_SORT		1
define	TIME_SORT	2
define  UNKNOWN_SORT	100

# define the size of the QPC data base
define  QPC_LENDB		17

# define the record structure for an input file
define  QPC_LENFILE		7
define	QPC_FILE		Memc[Memi[($1)+((($2)-1)*QPC_LENFILE)+0]]
define	QPC_FPTR		Memi[($1)+((($2)-1)*QPC_LENFILE)+0]
define	QPC_PARAM		Memc[Memi[($1)+((($2)-1)*QPC_LENFILE)+1]]
define	QPC_PPTR		Memi[($1)+((($2)-1)*QPC_LENFILE)+1]
define	QPC_EXT			Memc[Memi[($1)+((($2)-1)*QPC_LENFILE)+2]]
define	QPC_EPTR		Memi[($1)+((($2)-1)*QPC_LENFILE)+2]
define	QPC_OPEN		Memi[($1)+((($2)-1)*QPC_LENFILE)+3]
define	QPC_GET			Memi[($1)+((($2)-1)*QPC_LENFILE)+4]
define	QPC_PUT			Memi[($1)+((($2)-1)*QPC_LENFILE)+5]
define	QPC_CLOSE		Memi[($1)+((($2)-1)*QPC_LENFILE)+6]

# pre-defined offsets into file record
define	F_IN		1
define	F_OUT		2
define	F_HD		3
define	F_MAX		3

# define the size of a FITS record in bytes
define FITS_RECORD 2880

# define the size of the qpcreate data base in qpcreate.com
define  SZ_QPCCOM	8

# size limiting defintions.
define	LEN_EVBUF	512		# size of output event buffer
define	SZ_KEY		20		# size of sort key
define	MAX_RECS	100000		# max records in a sort
define	MAX_TEMPS	100		# max number of temp files

# qpoe defaults
define QPC_PAGESIZE	1024 		# qpoe page size
define QPC_BUCKETLEN	2048		# qpoe bucket length
define QPC_BLOCKFACTOR	1		# qpoe block factor
define QPC_MKINDEX	TRUE		# make a qpoe index?
define QPC_KEY		""  		# key for qpoe index
define QPC_DEBUG	0   		# qpoe debug level

# define MAYBE, to go with YES and NO
define MAYBE 3

# The following were pulled from qpcreate.x
define  QPC_WARN        1
define  QPC_FATAL       100

define  EV_NEITHER      -1
define  EV_LARGE        0
define  EV_FULL         1

define  SZ_DATA         8*1024

#define	SZ_MACRO_STRING		5*SZ_LINE   #JCC (8/20/96)
define	NOT_FOUND_VAL		-1
define  MAX_NUM_MACRO           20
define  SZ_MACRO_STRUCT         5
define  MACRO_STRUCT            (($1) + (($2 - 1) * SZ_MACRO_STRUCT))

define  TYPE              	Memc[P2C ($1)]
define  SIZE			Memi[($1) + 1]
define	BYTE_OFFSET		Memi[($1) + 2]
define  WHERE_FOUND             Memi[($1) + 3]
define  NAME_PTR          	Memi[($1) + 4]
define  NAME_STR          	Memc[NAME_PTR($1)]
