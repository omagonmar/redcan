#$Header: /home/pros/xray/lib/qpcreate/RCS/tgr2qp.x,v 11.0 1997/11/06 16:22:18 prosb Exp $
#$Log: tgr2qp.x,v $
#Revision 11.0  1997/11/06 16:22:18  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:03  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:19  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:18:01  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:17:44  mo
#MC	7/2/93		Force stemp to short for data conversion.
#
#Revision 6.0  93/05/24  15:59:20  prosb
#General Release 2.2
#
#Revision 5.4  93/05/21  18:35:57  mo
#MC	5/21/93		Reverse QPFLAG and QPCODE
#
#Revision 5.3  93/05/19  17:15:13  mo
#MC	5/20/93		Add EINSTEIN support to convert TGR to TSI
#
#Revision 5.2  93/03/12  10:06:02  mo
#MC	3/10/93		First pass at TGR -> TSI translation
#
#Revision 5.1  93/01/27  18:27:21  mo
#MC	1/27/93		Add support for Einstein/IPC TSI records
#			converted from TGR records
#
#Revision 5.0  92/10/29  21:19:33  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  91/12/18  12:14:07  mo
#MC	12/18/91	Add new routine 'interobi' to check
#			for interobi gap ( and don't force HRI point mode)
#
#Revision 3.1  91/12/16  18:00:35  mo
#MC	12/16/91	Force the HRI pointing mode to be 1 since
#			this not available in the TGR file
#
#Revision 3.0  91/08/02  01:05:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:56  pros
#General Release 1.0
#
#
#	TGR2QP.X -- tgr-specific routines for qpoe creation
#

include <qpoe.h>
include <mach.h>
include <einstein.h>
include "qpcreate.h"

# define the size of an input tgr record
define	SZ_DG_IPC_TGR	(20/SZB_CHAR)	# 20 DG bytes
define	SZ_DG_HRI_TGR	(18/SZB_CHAR)	# 18 DG bytes

# number of tgr records in a buffer increment
define BUFINC	1000

# Define the TGR -> TSI conversion ( jmcdowell)
#TFORM1  = '1D                '  /  Data type for field
#TTYPE1  = 'SC_TIME           '  /  Start time of interval
#TUNIT1  = 's                 '  /  (since 1978.0)
#TFORM2  = '1J                '  /  Data type for field
#TTYPE2  = 'PASSFAIL          '  /  Bit flags indicating why data rejected
#TUNIT2  = 'BIT_ENCODE        '  /
#TFORM3  = '1J                '  /  Data type for field
#TTYPE3  = 'LOGICALS          '  /  Bit encoded logical parameter values
#TUNIT3  = 'BIT_ENCODE        '  /
#TFORM4  = '1I                '  /  Data type for field
#TTYPE4  = 'HIBACK            '  /  Background (BIT 12) (TGR STAT3 Bits 13-15)
#TUNIT4  = '                  '  /
#TFORM5 = '1I                '  /  Data type for field
#TTYPE5  = 'HVLEVEL           '  /  High Voltage level(TGR STAT3 Bits 6-9)
#TUNIT5  = '                  '  /
#TFORM7  = '1I                '  /  Data type for field
#TTYPE7  = 'ASPSTAT           '  /  Aspect Status (BIT 11)  (TGR STAT1 Bits 0-3)
#TUNIT7  = '                  '  /
#TFORM10  = '1I                '  /  Data type for field
#TTYPE10 = 'VG            '  /  VGFLAG            (TGR STAT3 Bits 10-12)
#TUNIT10 = '                  '  /
#TFORM8  = '1I                '  /  Data type for field
#TTYPE8  = 'ASPERR            '  /  Aspect error  (2 * TGR STAT1 Bits 4-7)
#TUNIT8  = 'arcsec            '  /  (nearest 2")
#TFORM9  = '1I                '  /  Data type for field
#TTYPE9  = 'ATTCODE           '  /  Attitude          (TGR STAT3 Bits 0-1)
#TUNIT9  = '                  '  /
#TFORM6  = '1I                '  /  Data type for field
#TTYPE6  = 'VIEWGEOM          '  /  Viewing Geometry (BIT 13) (TGR STAT4 Bits 12-15)
#TUNIT6  = '                  '  /
#TFORM11 = '1I                '  /  Data type for field
#TTYPE11 = 'ANOM              '  /  Anomaly code      (TGR STAT3 Bits 2-5)
#TUNIT11 = '                  '  /
##COMMENT  PASSFAIL is bit encoded as follows:
#COMMENT   BIT         FLAG       Corresponding TGR bit
#COMMENT   BIT         FLAG       Corresponding TGR bit          HEX
#COMMENT    0    EOF  End of File flag    EOF record             00000001
#      When EOF set - all other FAILED bits, zered )
#COMMENT    1    INT  Inter-observ. gap   IOG record             00000002
#      When IOG set - all other FAILED bits, zered )
#COMMENT    2    (Not used)                                      00000004
#COMMENT    3    VE Threshold flag (IPC)  STAT4/11               00000008
#COMMENT    4    (Not used)                                      00000010
#COMMENT    5    (Not used)                                      00000020
#COMMENT    6    (Not used)                                      00000040
#COMMENT    7    (Not used)                                      00000080
#COMMENT    8    USER User flag           STAT1/8                00000100
#COMMENT    9    HV   High Voltage off    STAT1/9                00000200
#COMMENT   10    ACD  ACD flag            STAT1/10               00000400
#COMMENT   11    ASP  Aspect Solution Bad STAT1/11               00000800
#COMMENT   12    HIBK High Background     STAT1 bit 12           00001000
#COMMENT   13    VG   Earthblock          STAT1 bit 13           00002000
#COMMENT   14    DRP  Telemetry problem   STAT1 bit 14           00004000
#COMMENT   15    BAD  Time screened       STAT1 bit 15           00008000
#COMMENT   16    FIDCAL flag              STAT2 bit  0           00010000
#COMMENT   17    INSTCAL flag             STAT2 bit  1           00020000
#COMMENT   18    MPCCAL flag              STAT2 bit  2           00040000
#COMMENT   19    BIT14 ACD BIT14 (HVOFF)  STAT2 bit  3           00080000
#COMMENT   20    USER3 ACD USER3 flag     STAT2 bit  4           00100000
#COMMENT   21    USER2 ACD USER2 flag     STAT2 bit  5           00200000
#COMMENT   22    USER1 ACD USER1 flag     STAT2 bit  6           00400000
#COMMENT   23    USER0 ACD USER0 flag     STAT2 bit  7           00800000
#COMMENT   24    FPCS ACD FPCSSCAN        STAT2 bit  8           01000000
#COMMENT   25    ACDH ACD Heater-1 flag   STAT2 bit  9           02000000
#COMMENT   26    ACDF ACD Filter flag     STAT2 bit 10           04000000
#COMMENT   27    SAADB SAA B flag         STAT2 bit 11           08000000
#COMMENT   28    SAADA SAA A flag         STAT2 bit 12           10000000
#COMMENT   29    ACDS ACD Sun flag        STAT2 bit 13           20000000
#COMMENT   30    ACDE ACD Earthblock      STAT2 bit 14           40000000
#COMMENT   31    MANUAL PCG               STAT2 bit 15           80000000
#COMMENT 
#
#  TGR_OPEN -- open the tgr file
#
procedure tgr_open(fname, fd, convert, qphead, display, argv)

char	fname[ARB]			# i: tgr file name
int	fd				# l: file descriptor
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	headsize			# l: size of header
int	open()				# l: open a file

begin
	# open the file
	fd = open(fname, READ_ONLY, BINARY_FILE)
	# check whether there is a header 
	# this is a kludge to get around the fact that production
	# tgr files have a header, but public domain tgr's don't
	# the file pointer is put into the correct place
	call uhd_checkhead(fd, qphead, convert, headsize)
end

#
#  TGR_CLOSE -- open the tgr file
#
procedure tgr_close(fd, qphead, display, argv)

int	fd				# i: tgr fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	if( display >=5 )
	    call printf("closing tgr file\n")
	call close(fd)
end

procedure tgr_get(fd, convert, qptgr, ntime, qphead, display, argv)

int     fd                              # i: tgr file descriptor
int     convert                         # i: data conversion flag
pointer qptgr                           # o: pointer to tgr records
pointer qphead                          # i: header
int     ntime                           # i: number of records read
int     display                         # i: display level
pointer argv                            # i: pointer to arg list

short   shortone                        # l: constant 1
short   stemp	                        # l: 
int     size                            # l: size in SPP chars of TGR record
int     osize                           # l: output TGR buffer size
pointer ibase                           # l: base pointer to input tgr records
pointer obase                           # l: base pointer to output tgr records
pointer optr                            # l: pointer to current output tgr rec
pointer sp                              # l: stack pointer

bool    interobi()                      # l: routine to ck inter obi gap
int     read()                          # l: read from a file
short   cvti2()                         # l: convert i*2
int     cvti4()                         # l: convert i*4
double  cvtr8()                         # l: convert r*8

begin
        # mark the stack
        call smark(sp)

        shortone = 1
        # get size of a record
        switch( QP_INST(qphead) ){
        case EINSTEIN_IPC:
            size = SZ_DG_IPC_TGR
        case EINSTEIN_HRI:
            size = SZ_DG_HRI_TGR
        default:
            call error(1, "unknown Einstein detector")
        }

        # allocate space for the tgr records (I hope we have enough!)
        call salloc(ibase, size/SZ_SHORT, TY_SHORT)
        # allocate space for the output records
        osize = BUFINC
        call calloc(obase, osize*SZ_QPTGR, TY_STRUCT)

        # read in the tgr records and convert
        ntime = 0
        while( read(fd, Mems[ibase], size) != EOF ){
            ntime = ntime+1
            if( ntime > osize ){
                osize = osize + BUFINC
                call realloc(obase, osize*SZ_QPTGR, TY_STRUCT)
            }
            # point to the current record
            optr = obase + ((ntime-1)*SZ_QPTGR)
            # convert the time
            TGR_TIME(optr) = cvtr8(Mems[ibase],convert) + QP_TBASE(qphead)
            TGR_HUT(optr) = cvti4(Mems[ibase+4],convert)
            TGR_STAT1(optr) = cvti2(Mems[ibase+6],convert)
            TGR_STAT2(optr) = cvti2(Mems[ibase+7],convert)
            TGR_STAT3(optr) = cvti2(Mems[ibase+8],convert)
            if( QP_INST(qphead) == EINSTEIN_IPC )       
                TGR_STAT4(optr) = cvti2(Mems[ibase+9],convert)
            else
                TGR_STAT4(optr) = 0
# HRI processing forgot to set the pointing bit on - we'll force it here
#       just the way standard processing did
            if( QP_INST(qphead) == EINSTEIN_HRI &&
                !interobi(optr) ) 
		stemp = short(TGR_STAT3(optr))
                TGR_STAT3(optr) = or(stemp,shortone)
#                TGR_STAT3(optr) = or(TGR_STAT3(optr),shortone)
        }
        # reallocate output space
        call realloc(obase, ntime*SZ_QPTGR, TY_STRUCT)

        # display tgr record if necessary
        if( display >= 4 )
            call disp_qptgr(obase, ntime, QP_INST(qphead))

        # free up stack space
        call sfree(sp)

        # fill in return values
        qptgr = obase
end

#
# TGRTSI_GET -- read the tgr records from the input file
#
#procedure tgrtsi_get(fd, convert, qptgr, qptsi, ntime, qphead, display, argv)
#
#int	fd				# i: tgr file descriptor
#int	convert				# i: data conversion flag
#pointer	qptgr				# o: pointer to tgr records
#pointer	qphead				# i: header
#int	ntime				# i: number of records read
#int	display				# i: display level
#pointer	argv				# i: pointer to arg list
#
#short	shortone			# l: constant 1
#int	size				# l: size in SPP chars of TGR record
#int	osize				# l: output buffer size
#int     ssize                           # l: output TSI buffer size
#int	nrec				# l: number of TSI records converted
#pointer	ibase				# l: base pointer to input tgr records
#pointer	obase				# l: base pointer to output tgr records
#pointer sbase                           # l: base pointer to output tsi records
#pointer	optr				# l: pointer to current output tgr rec
#pointer	sptr				# l: pointer to current output tsi rec
#pointer	sp				# l: stack pointer
#
#bool	interobi()			# l: routine to ck inter obi gap
#int	read()				# l: read from a file
#short	cvti2()				# l: convert i*2
#int	cvti4()				# l: convert i*4
#double	cvtr8()				# l: convert r*8
#
#begin
#	# mark the stack
#	call smark(sp)
#
#	shortone = 1
#	# get size of a record
#	switch( QP_INST(qphead) ){
#	case EINSTEIN_IPC:
#	    size = SZ_DG_IPC_TGR
#	case EINSTEIN_HRI:
#	    size = SZ_DG_HRI_TGR
#	default:
#	    call error(1, "unknown Einstein detector")
#	}
#
#	# allocate space for the tgr records (I hope we have enough!)
#	call salloc(ibase, size/SZ_SHORT, TY_SHORT)
#	# allocate space for the output records
#	osize = BUFINC
#	ssize = BUFINC
#	call calloc(obase, SZ_QPTGR, TY_STRUCT)
#	call calloc(sbase, SZ_EQPTSI*ssize, TY_STRUCT)
#
#	# read in the tgr records and convert
#	nrec = 0
#	while( read(fd, Mems[ibase], size) != EOF ){
##	    ntime = ntime+1
#	    nrec = nrec+1
##	    if( ntime > osize ){
##		osize = osize + BUFINC
##		call realloc(obase, osize*SZ_QPTGR, TY_STRUCT)
##	    }
#	    if( nrec > ssize ){
#		ssize = ssize + BUFINC
#		call realloc(sbase, ssize*SZ_EQPTSI, TY_STRUCT)
#	    }
#	    # point to the current record
#	    optr = obase 
#	    sptr = sbase + ((nrec-1)*SZ_EQPTSI)
#	    # convert the time
#	    TGR_TIME(optr) = cvtr8(Mems[ibase],convert) + QP_TBASE(qphead)
#	    TGR_HUT(optr) = cvti4(Mems[ibase+4],convert)
#	    TGR_STAT1(optr) = cvti2(Mems[ibase+6],convert)
#	    TGR_STAT2(optr) = cvti2(Mems[ibase+7],convert)
#	    TGR_STAT3(optr) = cvti2(Mems[ibase+8],convert)
#	    if( QP_INST(qphead) == EINSTEIN_IPC )	
#		TGR_STAT4(optr) = cvti2(Mems[ibase+9],convert)
#	    else
#		TGR_STAT4(optr) = 0
## HRI processing forgot to set the pointing bit on - we'll force it here
##	just the way standard processing did
#	    if( QP_INST(qphead) == EINSTEIN_HRI &&
#		!interobi(optr) ) 
#	        TGR_STAT3(optr) = or(TGR_STAT3(optr),shortone)
#	    call tgr2tsi(optr,sptr)
#	}
##	# reallocate output space
##	call realloc(obase, ntime*SZ_QPTGR, TY_STRUCT)
#	# reallocate output space
#	call realloc(sbase, nrec*SZ_EQPTSI, TY_STRUCT)
#
#	# display tgr record if necessary
##	if( display >= 4 )
##	    call disp_qptgr(obase, ntime, QP_INST(qphead))
#	if( display >= 4 )
#	    call disp_qptsi(sbase, nrec, QP_INST(qphead))
#
#	# free up stack space
#	call sfree(sp)
#
#	# fill in return values
#	qptgr = obase
#	qptsi = sbase
#end

#
#  TGR_PUT -- write tgr records to qpoe file
#	(calls library routine put_qptgr)
#
procedure tgr_put(qp, qptgr, ntgr, qphead, display, argv)

int	qp				# i: qpoe file descriptor
pointer	qptgr				# i: pointer to tgr records
int	ntgr				# i: number of tgr records
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	bytes				# l: bytes in a record
int	nlist				# l: number of intervals from good()
int	i				# l: loop counter
int	ii
pointer	iptr				# l: pointer to TGR records
pointer	optr				# l: pointer to TSI records
pointer	list				# l: list of good ints from good()
pointer	qpgti				# l: list of good time intervals
pointer	qptsi				# l: list of good time intervals
double	duration			# l: total good time in secs.
int	qpc_type()			# l: 1 == QPOE, 2 == A3D

begin
	# write tgr records to qpoe file
	switch(qpc_type()){
        case 1:
          call put_qptgr(qp, qptgr, ntgr)
        case 2:
          if( ntgr ==0 )
              return
          # write the standard part of the table header
          bytes = (SZ_DOUBLE+(6*SZ_INT))*SZB_CHAR
          call a3d_table_header(qp, "TGR", bytes, ntgr, 7, 1)
          call a3d_table_entry(qp, "1D", "TIME", "seconds")
          call a3d_table_entry(qp, "1J", "HUT", "SC units")
          call a3d_table_entry(qp, "1J", "STAT1", "bit flag")
          call a3d_table_entry(qp, "1J", "STAT2", "bit flag")
          call a3d_table_entry(qp, "1J", "STAT3", "bit flag")
          call a3d_table_entry(qp, "1J", "STAT4", "bit flag")
          call a3d_table_entry(qp, "1J", "ALIGN1", "dummy for alignment")
          call a3d_table_end(qp)
          call miistruct(Memi[qptgr], Memi[qptgr], ntgr, "{d,i,i,i,i,i,i}")
          call a3d_write_data(qp, Memi[qptgr], ntgr*bytes/SZB_CHAR)
        default:
            call error(1, "qpcreate error: unknown qpcreate type")
        }

	# derive good time intervals from tgr records
	call good_qptgr(qptgr, ntgr, QP_INST(qphead), list, nlist, duration)
	# convert to gti struct
	call calloc(qpgti, nlist*SZ_QPGTI, TY_STRUCT)
	do i=1, nlist{
	    GTI_START(GTI(qpgti,i)) = Memd[list+((i-1)*2)]
	    GTI_STOP(GTI(qpgti,i)) = Memd[list+((i-1)*2)+1]
	}
	# write them to the file
	call gti_put(qp, qpgti, nlist, qphead, display, argv)
        
	# derive the TSI records from the tgr records
	call calloc(qptsi,ntgr*SZ_EQPTSI,TY_STRUCT)
        do ii=1,ntgr
        {
            iptr = qptgr+(ii-1)*SZ_QPTGR
            optr = qptsi+(ii-1)*SZ_EQPTSI
            call tgr2tsi(iptr,optr,qphead)
        }
        call tsi_put(qp, qptsi, ntgr, qphead, display, argv)

	call mfree(qptsi, TY_STRUCT)
	call mfree(qpgti, TY_STRUCT)
	call mfree(list, TY_DOUBLE)
end

procedure tgr2tsi(optr,sptr,qphead)
pointer optr	# i: pointer to current TGR record
pointer sptr	# i: pointer to TSI record to fill
pointer qphead	# i: pointer to QPOE header parameters

long	ltemp	# l: temporary short to long converter
long	ltemp1	# l: temporary short to long converter
bool	interobi()

begin
	    TSI_START(sptr) = TGR_TIME(optr)
	    TSI_FAILED(sptr) = 0
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),1000X)) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT4(optr),0800X)/2) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),2000X)/4) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),0800X)/8) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),0400X)/16) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),8000X)/32) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),0200X)/64) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),4000X)/128) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT1(optr),0100X)/256) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),4000X)/512) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),2000X)/1024) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),1000X)/2048) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0800X)/4096) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0400X)/8192) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0200X)/16384) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0100X)/32768) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0080X)/65536) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0040X)/131072) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0020X)/262144) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0010X)/524288) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0008X)/1048576) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0004X)/2297152) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0002X)/4594304) 
#	    TSI_FAILED(sptr)=or(TSI_FAILED(sptr),and(TGR_STAT2(optr),0001X)/9188608) 
#            TSI_FAILED(sptr)=TGR_STAT2(optr)
#            ltemp = TGR_STAT1(optr)

#   Convert the input shorts to UNSIGNED longs (and only use high byte of STAT1)
	    ltemp = and(TGR_STAT1(optr),0000FF00X)
	    ltemp1 = and(TGR_STAT2(optr),0000FFFFX)
#  ltemp1(STAT2) becomes the high-order 2 bytes, ltemp (STAT1) becomes the low 
#	order 2 bytes
	    ltemp1 = and(ltemp1*65536,0FFFF0000X)	# shift left 16 bits
	    TSI_FAILED(sptr)=or(ltemp1,ltemp)
#  Add special bits for EOF, inter-obi gap and IPC/VE threshold flag
            if( QP_INST(qphead) == EINSTEIN_IPC ){
	      ltemp = and(TGR_STAT4(optr),00000800X) # get bit 11
	      TSI_FAILED(sptr)=or(TSI_FAILED(sptr),  
				  ltemp/256)	     # shift down to bit 3
              if( TGR_STAT1(optr) == -1 && TGR_STAT2(optr) == -1 &&
                  TGR_STAT3(optr) == -1 && TGR_STAT4(optr) == -1 ){
	            TSI_FAILED(sptr)=0001X 
	      }
            }
	    if( interobi(optr) )
	        TSI_FAILED(sptr)=0002X 
	    TSI_LOGICALS(sptr) = 0 
	    TSI_HVLEV(sptr)    = and(and(TGR_STAT3(optr),03C0X)/64,000FX)
            if( QP_INST(qphead) == EINSTEIN_IPC ){
#	        TSI_VGFLAG(sptr) = and(and(TGR_STAT4(optr),0F000X)/4096,000FX)
#        	TSI_VG(sptr)       = and(and(TGR_STAT3(optr),01C00X)/1024,0007X)
	        TSI_VG(sptr) = and(and(TGR_STAT4(optr),0F000X)/4096,000FX)
        	TSI_VGFLAG(sptr)   = and(and(TGR_STAT3(optr),01C00X)/1024,0007X)
	    }
	    else if( QP_INST(qphead) == EINSTEIN_HRI ){
	        TSI_VGFLAG(sptr) = 0
	        TSI_VG(sptr)       = 0
	    }
	    TSI_ASPSTAT(sptr)  = and(and(TGR_STAT1(optr),000FX),000FX)
	    TSI_ASPERR(sptr)   = 2 * and(and(TGR_STAT1(optr),00F0X)/16,000FX)
	    TSI_ATTCODE(sptr)  = and(and(TGR_STAT3(optr),0003X),0003X)
	    TSI_HIBK(sptr)     = and(and(TGR_STAT3(optr),0E000X)/8192,0007X)
	    TSI_ANOM(sptr)     = and(and(TGR_STAT3(optr),003CX)/4,000FX)
end

#
#  TGR_PUT -- write tgr records to qpoe file
#	(calls library routine put_qptgr)
#
#procedure tgrtsi_put(qp, qptgr, qptsi, ntgr, qphead, display, argv)
#int	qp				# i: qpoe file descriptor
#pointer	qptgr				# i: pointer to tgr records
#int	ntgr				# i: number of tgr records
#pointer	qphead				# i: header
#int	display				# i: display level
#pointer	argv				# i: pointer to arg list
#
#begin
#	call tgr_put(qp,qptgr,ntgr,qphead,display,argv)
#	call tsi_put(qp,qptsi,ntgr,qphead,display,argv)
#end
