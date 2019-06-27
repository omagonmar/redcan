#$Header: /home/pros/xray/lib/qpcreate/RCS/tsh2qp.x,v 11.0 1997/11/06 16:22:19 prosb Exp $
#$Log: tsh2qp.x,v $
#Revision 11.0  1997/11/06 16:22:19  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:24  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:18:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:34  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:12:00  pros
#General Release 1.0
#
#
#	TSH2QP.X -- tsh-specific routines for qpoe creation
#

include <mach.h>
include <rosat.h>
include <qpoe.h>
include <qpc.h>

# define the size of an input tsh record
define	SZ_HOPR_TSH	(12/SZB_CHAR)	# 12 Vax bytes

# number of tsh records in a buffer increment
define BUFINC	1000

#
#  TSH_OPEN -- open the tsh file
#
procedure tsh_open(fname, fd, convert, qphead, display, argv)

char	fname[ARB]			# i: tsh file name
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
#  TSH_CLOSE -- open the tsh file
#
procedure tsh_close(fd, qphead, display, argv)

int	fd				# i: tsh fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	call close(fd)
end

#
# TSH_GET -- read the tsh records from the input file
#
procedure tsh_get(fd, convert, qptsh, ntime, qphead, display, argv)

int	fd				# i: tsh file descriptor
int	convert				# i: data conversion flag
pointer	qptsh				# o: pointer to tsh records
pointer	qphead				# i: header
int	ntime				# i: number of records read
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	size				# l: size in SPP chars of TSH record
int	osize				# l: output buffer size
pointer	ibase				# l: base pointer to input tsh records
pointer	obase				# l: base pointer to output tsh records
pointer	optr				# l: pointer to current output tsh rec
pointer	sp				# l: stack pointer

int	read()				# l: read from a file
short	cvti2()				# l: convert i*2
double	cvtr8()				# l: convert r*8

begin
	# mark the stack
	call smark(sp)

	# get size of a record
	size = SZ_HOPR_TSH

	# allocate space for the tsh records (I hope we have enough!)
	call salloc(ibase, size/SZ_SHORT, TY_SHORT)
	# allocate space for the output records
	osize = BUFINC
	call calloc(obase, osize*SZ_QPTSH, TY_STRUCT)

	# read in the tsh records and convert
	ntime = 0
	while( read(fd, Mems[ibase], size) != EOF ){
	    ntime = ntime+1
	    if( ntime > osize ){
		osize = osize + BUFINC
		call realloc(obase, osize*SZ_QPTSH, TY_STRUCT)
	    }
	    # point to the current record
	    optr = obase + ((ntime-1)*SZ_QPTSH)
	    TSH_TIME(optr) = cvtr8(Mems[ibase],convert)
	    TSH_ID(optr) = cvti2(Mems[ibase+4],convert)
	    TSH_STATUS(optr) = cvti2(Mems[ibase+5],convert)
	}
	# reallocate output space
	call realloc(obase, ntime*SZ_QPTSH, TY_STRUCT)

	# display tsh record if necessary
	if( display >= 4 )
	    call disp_qptsh(obase, ntime, QP_INST(qphead))

	# free up stack space
	call sfree(sp)

	# fill in return values
	qptsh = obase
end

#
#  TSH_PUT -- write tsh records to qpoe file
#	(calls library routine put_qptsh)
#
procedure tsh_put(qp, qptsh, ntsh, qphead, display, argv)

int	qp				# i: qpoe file descriptor
pointer	qptsh				# i: pointer to tsh records
int	ntsh				# i: number of tsh records
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	bytes				# l: bytes in a record
int	qpc_type()			# l: 1 == QPOE, 2 == A3D

begin
	# write tsh records to qpoe file
	switch(qpc_type()){
	case QPOE:
	  call put_qptsh(qp, qptsh, ntsh)
	case A3D:
	  if( ntsh ==0 )
	      return
	  # write the standard part of the table header
	  bytes = (SZ_DOUBLE+(2*SZ_INT))*SZB_CHAR
	  call a3d_table_header(qp, "TSH", bytes, ntsh, 3, 1)
	  call a3d_table_entry(qp, "1D", "TIME", "seconds")
	  call a3d_table_entry(qp, "1J", "ID", "TSH id")
	  call a3d_table_entry(qp, "1J", "STATUS", "TSH status value")
	  call a3d_table_end(qp)
	  call miistruct(Memi[qptsh], Memi[qptsh], ntsh, "{d,i,i}")
	  call a3d_write_data(qp, Memi[qptsh], ntsh*bytes/SZB_CHAR)
	default:
	    call error(1, "qpcreate error: unknown qpcreate type")
	}
end
