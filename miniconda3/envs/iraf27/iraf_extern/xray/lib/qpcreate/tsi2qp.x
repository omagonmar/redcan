#$Header: /home/pros/xray/lib/qpcreate/RCS/tsi2qp.x,v 11.0 1997/11/06 16:22:20 prosb Exp $
#$Log: tsi2qp.x,v $
#Revision 11.0  1997/11/06 16:22:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:26  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:18:06  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:33:26  mo
#no changes
#
#Revision 6.0  93/05/24  15:59:27  prosb
#General Release 2.2
#
#Revision 5.3  93/05/21  18:36:21  mo
#no changes
#
#Revision 5.2  93/05/19  17:13:24  mo
#MC	5/20/93		Update for EINSTEIN support
#
#Revision 5.1  93/01/27  18:27:54  mo
#MC	1/27/93		Add support for Einstein/IPC TSI Records
#			.
#
#
#Revision 5.0  92/10/29  21:19:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:35  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:12:04  pros
#General Release 1.0
#
#
# Module:       TSI2QP.X -- temporal status interval routines for QPOE creation
# Project:      PROS -- ROSAT RSDC
# Purpose:	These routines convert from Level 1 processing file format
#		to QPOE TSI format
# External:     tsi_open, tsi_put, tsi_get, tsi_close
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC    --  initial version  1/91   
#               {1} MC    --  Correct parameter count for HRI -- 1/91
#			      and remove the macros for the TSI records
#               {n} <who> -- <does what> -- <when>
#

include <mach.h>
include <rosat.h>
include <qpoe.h>
include <qpc.h>
include <einstein.h>

# define the size of an input tsi record
define	SZ_HOPR_SCR	(76/SZB_CHAR)	# 64 Vax bytes
define	SZ_PSPC_TSI	(24/SZB_CHAR)	# 64 Vax bytes
define	SZ_EIN_TGR	(12/SZB_CHAR)	

# number of tsi records in a buffer increment
define BUFINC	1000

define  RHTSIREC        "{d,i,i,i,i,i,i,i,i,i,i,i,i,i,i}"
define  ETSIREC        "{d,i,i,i,i,i,i,i,i,i,i}"
define  RPTSIREC        "{d,i,i,i,i}"
#
#  TSI_OPEN -- open the tsi file
#
procedure tsi_open(fname, fd, convert, qphead, display, argv)

char	fname[ARB]			# i: tsi file name
int	fd				# l: file descriptor
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	open()				# l: open a file

begin
	# open the file
	fd = open(fname, READ_ONLY, BINARY_FILE)
end

#
#  TSI_CLOSE -- close the tsi file
#
procedure tsi_close(fd, qphead, display, argv)

int	fd				# i: tsi fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	call close(fd)
end

#
# TSI_GET -- read the tsi records from the input file
#
procedure tsi_get(fd, convert, qptsi, ntsi, qphead, display, argv)

int	fd				# i: tsi file descriptor
int	convert				# i: data conversion flag
pointer	qptsi				# o: pointer to tsi records
pointer	qphead				# i: header
int	ntsi				# i: number of records read
int	display				# i: display level
pointer	argv				# i: pointer to arg list

bool	notvalid			# i: no records available flag
int	reclen				# l: size of output record
int	size				# l: size in SPP chars of TSI record
int	osize				# l: output buffer size
pointer	ibase				# l: base pointer to input tsi records
pointer	obase				# l: base pointer to output tsi records
pointer	optr				# l: pointer to current output tsi rec
pointer	sp				# l: stack pointer

int	read()				# l: read from a file
int	cvti4()				# l: convert i*4 
double	cvtr8()				# l: convert r*8

begin
	# mark the stack
	call smark(sp)

	notvalid = FALSE
	# get size of a record
	switch(QP_INST(qphead)){
	case ROSAT_HRI:
	    size = SZ_HOPR_SCR		# size of input record
	    reclen = SZ_HQPTSI		# size of output record in shorts
	case ROSAT_PSPC:
	    size = SZ_PSPC_TSI		# size of input record
	    reclen = SZ_PQPTSI		# size of output record in shorts
	case EINSTEIN_IPC:
	    size = SZ_EIN_TGR
	    reclen = SZ_EQPTSI
	case EINSTEIN_HRI:
	    size = SZ_EIN_TGR
	    reclen = SZ_EQPTSI
	default:
	    call eprintf("No TSI records for this instrument\n")
	    notvalid = TRUE
	    qptsi = 0
	    ntsi = 0
	}
    if( !notvalid ){
	# allocate space for the tsi records (I hope we have enough!)
	call salloc(ibase, size/SZ_SHORT, TY_SHORT)
	# allocate space for the output records
	osize = BUFINC
	call calloc(obase, osize*reclen, TY_STRUCT)

	# read in the tsi records and convert
	ntsi = 0
	while( read(fd, Mems[ibase], size) != EOF ){
	    ntsi = ntsi+1
	    if( ntsi > osize ){
		osize = osize + BUFINC
		call realloc(obase, osize*reclen, TY_STRUCT)
	    }
	    # point to the current record
	    optr = obase + ((ntsi-1)*reclen)
	    switch(QP_INST(qphead)){
	    case ROSAT_HRI:
	        TSI_START(optr) = cvtr8(Mems[ibase],convert)
	        TSI_FAILED(optr) = cvti4(Mems[ibase+10],convert)
	        TSI_LOGICALS(optr) = cvti4(Mems[ibase+12],convert)
	        TSI_HIBK(optr) = cvti4(Mems[ibase+14],convert)
	        TSI_HVLEV(optr) = cvti4(Mems[ibase+16],convert)
	        TSI_VG(optr) = cvti4(Mems[ibase+18],convert)
	        TSI_ASPSTAT(optr) = cvti4(Mems[ibase+20],convert)
	        TSI_ASPERR(optr) = cvti4(Mems[ibase+22],convert)
	        TSI_HQUAL(optr) = cvti4(Mems[ibase+24],convert)
	        TSI_SAADIND(optr) = cvti4(Mems[ibase+26],convert)
	        TSI_SAADA(optr) = cvti4(Mems[ibase+28],convert)
	        TSI_SAADB(optr) = cvti4(Mems[ibase+30],convert)
	        TSI_TEMP1(optr) = cvti4(Mems[ibase+32],convert)
	        TSI_TEMP2(optr) = cvti4(Mems[ibase+34],convert)
	        TSI_TEMP3(optr) = cvti4(Mems[ibase+36],convert)
	    case ROSAT_PSPC:
		TSI_START(optr) = cvtr8(Mems[ibase],convert)
	        TSI_FAILED(optr) = cvti4(Mems[ibase+4],convert)
	        TSI_LOGICALS(optr) = cvti4(Mems[ibase+6],convert)
	        TSI_RMB(optr) = cvti4(Mems[ibase+8],convert)
	        TSI_DFB(optr) = cvti4(Mems[ibase+10],convert)
#	    case EINSTEIN_HRI, EINSTEIN_IPC:
#		call tgrtsiget()
	    default:
		call eprintf("No TSI records for this instrument\n")
	    }
	}
	# reallocate output space
	call realloc(obase, ntsi*reclen, TY_STRUCT)

	# display tsi record if necessary
	if( display >= 4 )
	    call disp_tsi(obase, ntsi, QP_INST(qphead))

	# free up stack space
	call sfree(sp)

	# fill in return values
	qptsi = obase
    }
end

#
#  TSI_PUT -- write tsi records to qpoe file
#	(calls library routine put_tsi)
#
procedure tsi_put(qp, qptsi, ntsi, qphead, display, argv)

int	qp				# i: qpoe file descriptor
pointer	qptsi				# i: pointer to tsi records
int	ntsi				# i: number of tsi records
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	bytes				# l: bytes in a record
int	qpc_type()			# l: 1 == QPOE, 2 == A3D

pointer prostsi
pointer	recdef
pointer sp
#pointer msymbols
#pointer mvalues
#int     nmacros


begin
        call smark(sp)
        call salloc(prostsi,SZ_LINE,TY_CHAR)
        call salloc(recdef,SZ_LINE,TY_CHAR)
	# write tsi records to qpoe file

	switch(QP_INST(qphead)){
        case ROSAT_HRI:
            call strcpy(RHTSIREC,Memc[recdef],SZ_LINE)
            call strcpy(XS_RHTSI,Memc[prostsi],SZ_LINE)
        case ROSAT_PSPC:
            call strcpy(RPTSIREC,Memc[recdef],SZ_LINE)
            call strcpy(XS_RPTSI,Memc[prostsi],SZ_LINE)
	case EINSTEIN_IPC,EINSTEIN_HRI:
            call strcpy(ETSIREC,Memc[recdef],SZ_LINE)
            call strcpy(XS_ETSI,Memc[prostsi],SZ_LINE)
        default:
            call eprintf("no TSI records for this instrument\n")
	    call strcpy(NULL,Memc[recdef],SZ_LINE)
        }      

#        call ev_crelist(Memc[prostsi],msymbols,mvalues,nmacros)

	switch(qpc_type()){
	case QPOE:
#          call ev_wrlist(qp, msymbols,mvalues,nmacros)
	  call put_tsi(qp, qptsi, ntsi, qphead, recdef, prostsi)
	case A3D:
	  if( ntsi ==0 )
	      return
	  # write the standard part of the table header
	  switch(QP_INST(qphead)){
	  case ROSAT_HRI:
	    bytes = (SZ_HQPTSI)*SZ_STRUCT*SZB_CHAR
	    call a3d_table_header(qp, "TSI", bytes, ntsi, 15, 1)
	    call a3d_table_entry(qp, "1D", "TSTART", "seconds")
	    call a3d_table_entry(qp, "1J", "FAILED", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "LOGICALS", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "HIBK", "levels" )
	    call a3d_table_entry(qp, "1J", "HVLEV", "levels" )
	    call a3d_table_entry(qp, "1J", "VG", "levels" )
	    call a3d_table_entry(qp, "1J", "ASPSTAT", "levels" )
	    call a3d_table_entry(qp, "1J", "ASPERR", "levels" )
	    call a3d_table_entry(qp, "1J", "HQUAL", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "SAADIND", "levels" )
	    call a3d_table_entry(qp, "1J", "SAADA", "levels" )
	    call a3d_table_entry(qp, "1J", "SAADB", "levels" )
	    call a3d_table_entry(qp, "1J", "TEMP1", "levels" )
	    call a3d_table_entry(qp, "1J", "TEMP2", "levels" )
	    call a3d_table_entry(qp, "1J", "TEMP3", "levels" )
	    call a3d_table_end(qp)
	    call miistruct(Memi[qptsi], Memi[qptsi], ntsi, RHTSIREC )
	    call a3d_write_data(qp, Memi[qptsi], ntsi*bytes/SZB_CHAR)
	  case ROSAT_PSPC:
	    bytes = (SZ_PQPTSI)*SZ_STRUCT*SZB_CHAR
	    call a3d_table_header(qp, "TSI", bytes, ntsi, 5, 1)
	    call a3d_table_entry(qp, "1D", "TSTART", "seconds")
	    call a3d_table_entry(qp, "1J", "FAILED", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "LOGICALS", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "RMB", "levels" )
	    call a3d_table_entry(qp, "1J", "DFB", "levels" )
	    call a3d_table_end(qp)
	    call miistruct(Memi[qptsi], Memi[qptsi], ntsi, RPTSIREC )
	    call a3d_write_data(qp, Memi[qptsi], ntsi*bytes/SZB_CHAR)
	  case EINSTEIN_IPC,EINSTEIN_HRI:
	    bytes = (SZ_EQPTSI)*SZ_STRUCT*SZB_CHAR
	  #  This became a separate procedure to get around 'too many
	  #		strings in procecure' error in SPP
	    call a3d_table_header(qp, "TSI", bytes, ntsi, 11, 1)
	    call a3d_ein(qp)
	    call a3d_table_end(qp)
	    call miistruct(Memi[qptsi], Memi[qptsi], ntsi, ETSIREC )
	    call a3d_write_data(qp, Memi[qptsi], ntsi*bytes/SZB_CHAR)
	  default:
	    call eprintf("No TSI records defined for this instrument\n")
	  }  	# end INST case
#	  call a3d_qpev(qp,msymbols,mvalues,nmacros)
	default: 
	    call error(1, "qpcreate error: unknown qpcreate type")
	}  	# end QPOE ( qpoe/a3d ) case
#	call ev_destroylist(msymbols,mvalues,nmacros)
	call sfree(sp)
end	

procedure a3d_ein(qp)
pointer	qp

begin
	    call a3d_table_entry(qp, "1D", "TSTART", "seconds")
	    call a3d_table_entry(qp, "1J", "FAILED", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "LOGICALS", "bit-encoded" )
	    call a3d_table_entry(qp, "1J", "HIBK", "levels" )
	    call a3d_table_entry(qp, "1J", "HVLEV", "levels" )
	    call a3d_table_entry(qp, "1J", "VG", "levels" )
	    call a3d_table_entry(qp, "1J", "ASPSTAT", "levels" )
	    call a3d_table_entry(qp, "1J", "ASPERR", "levels" )
	    call a3d_table_entry(qp, "1J", "ATTCODE", "mode" )
	    call a3d_table_entry(qp, "1J", "VIEWGEOM", "levels" )
	    call a3d_table_entry(qp, "1J", "ANON", "bit-encoded" )
end

