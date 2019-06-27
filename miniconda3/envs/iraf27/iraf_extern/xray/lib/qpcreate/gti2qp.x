#$Header: /home/pros/xray/lib/qpcreate/RCS/gti2qp.x,v 11.0 1997/11/06 16:21:31 prosb Exp $
#$Log: gti2qp.x,v $
#Revision 11.0  1997/11/06 16:21:31  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:45  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:10  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:55:31  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:11  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:31  pros
#General Release 1.0
#
#
#	GTI2QP.X -- gti-specific routines for qpoe creation
#

include <mach.h>
include <rosat.h>
include <qpoe.h>
include <qpc.h>

# define the size of an input gti record
define	SZ_HOPR_GTI	(16/SZB_CHAR)	# 16 Vax bytes

# number of gti records in a buffer increment
define BUFINC	1000

#
#  GTI_OPEN -- open the gti file
#
procedure gti_open(fname, fd, convert, qphead, display, argv)

char	fname[ARB]			# i: gti file name
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
#  GTI_CLOSE -- open the gti file
#
procedure gti_close(fd, qphead, display, argv)

int	fd				# i: gti fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	call close(fd)
end

#
# GTI_GET -- read the gti records from the input file
#
procedure gti_get(fd, convert, qpgti, ngti, qphead, display, argv)

int	fd				# i: gti file descriptor
int	convert				# i: data conversion flag
pointer	qpgti				# o: pointer to gti records
pointer	qphead				# i: header
int	ngti				# i: number of records read
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	size				# l: size in SPP chars of GTI record
int	osize				# l: output buffer size
pointer	ibase				# l: base pointer to input gti records
pointer	obase				# l: base pointer to output gti records
pointer	optr				# l: pointer to current output gti rec
pointer	sp				# l: stack pointer

int	read()				# l: read from a file
double	cvtr8()				# l: convert r*8

begin
	# mark the stack
	call smark(sp)

	# get size of a record
	size = SZ_HOPR_GTI

	# allocate space for the gti records (I hope we have enough!)
	call salloc(ibase, size/SZ_SHORT, TY_SHORT)
	# allocate space for the output records
	osize = BUFINC
	call calloc(obase, osize*SZ_QPGTI, TY_STRUCT)

	# read in the gti records and convert
	ngti = 0
	while( read(fd, Mems[ibase], size) != EOF ){
	    ngti = ngti+1
	    if( ngti > osize ){
		osize = osize + BUFINC
		call realloc(obase, osize*SZ_QPGTI, TY_STRUCT)
	    }
	    # point to the current record
	    optr = obase + ((ngti-1)*SZ_QPGTI)
	    GTI_START(optr) = cvtr8(Mems[ibase],convert)
	    GTI_STOP(optr) = cvtr8(Mems[ibase+4],convert)
	}
	# reallocate output space
	call realloc(obase, ngti*SZ_QPGTI, TY_STRUCT)

	# display gti record if necessary
	if( display >= 4 )
	    call disp_qpgti(obase, ngti, QP_INST(qphead))

	# free up stack space
	call sfree(sp)

	# fill in return values
	qpgti = obase
end

#
#  GTI_PUT -- write gti records to qpoe file
#	(calls library routine put_qpgti)
#
procedure gti_put(qp, qpgti, ngti, qphead, display, argv)

int	qp				# i: qpoe file descriptor
pointer	qpgti				# i: pointer to gti records
int	ngti				# i: number of gti records
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	bytes				# l: bytes in a record
int	qpc_type()			# l: 1 == QPOE, 2 == A3D

begin
	# write gti records to qpoe file
	switch(qpc_type()){
	case QPOE:
	  call put_qpgti(qp, qpgti, ngti)
	case A3D:
	  if( ngti ==0 )
	      return
	  # write the standard part of the table header
	  bytes = (SZ_DOUBLE*2)*SZB_CHAR
	  call a3d_table_header(qp, "GTI", bytes, ngti, 2, 1)
	  call a3d_table_entry(qp, "1D", "START", "seconds")
	  call a3d_table_entry(qp, "1D", "STOP", "seconds")
	  call a3d_table_end(qp)
	  call miistruct(Memi[qpgti], Memi[qpgti], ngti, "{d,d}")
	  call a3d_write_data(qp, Memi[qpgti], ngti*bytes/SZB_CHAR)
	default:
	    call error(1, "qpcreate error: unknown qpcreate type")
	}
end
