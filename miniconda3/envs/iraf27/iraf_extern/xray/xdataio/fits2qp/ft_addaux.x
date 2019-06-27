#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_addaux.x,v 11.0 1997/11/06 16:34:33 prosb Exp $
#$Log: ft_addaux.x,v $
#Revision 11.0  1997/11/06 16:34:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:54  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:37:37  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:20:37  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:16:57  mo
#MC	2/25/94		Fix data-type mismatch caused by passing defined
#			constant directly in calling sequence and not
#			via correctly typed variable
#
#Revision 7.0  93/12/27  18:40:06  prosb
#General Release 2.3
#
#Revision 6.4  93/12/14  18:12:03  mo
#MC	12/13/93	Extensive changes for auxiliary QPOE extensions
#			Including record format padding and uncoding
#			'bool' data types
#
#Revision 6.2  93/09/20  17:32:40  mo
#MC	9/20/93		Update to write single auxilliary records
#			to avoid alignment problems
#
#Revision 6.1  93/09/01  13:37:08  mo
#MC	9/1/93		(Jmoran - update static buffers to pointers/allocs
#
#Revision 5.0  92/10/29  21:36:59  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:10  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:09:00  jmoran
#Initial revision
#
#
# Module:	ft_addaux.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <mach.h>
include <qpset.h>
include "fits2qp.h"
include	<evmacro.h>
#
#  FT_ADDAUX -- add auxiliary data to qpoe file as opaque array
#
procedure ft_addaux(fd, iname, itype, otype, ptype, nrecs, bytes, qp, ext, scale)

int	fd				# i: FITS file handle
char	iname[ARB]			# i: name of extension
char	itype[ARB]			# i: IRAF general type definition
char	otype[ARB]			# i: IRAF general type definition
char	ptype[ARB]			# i: PROS specific type definition
int	nrecs				# i: number of records
int	bytes				# i: number of bytes per record
int	qp				# i: QPOE file handle
int	ext				# i: EXT record for this extension
bool	scale				# i: applying TZERO/TSCAL scaling?

int	len,flen			# l: size of buffer to allocate
int	lrecs				# l: number of records in current buffer
int	chars				# l: number of 'chars' per record
int	got, get, left	 		# l: you figure it out!
int	remainder			# l: shorts left in padding
pointer	name
pointer	cbuf
pointer	tbuf
pointer	pbuf
pointer	obuf				# l: output data buffer
pointer	ltype				# l: local type for REC
pointer	buf				# l: pointer to input data buffer
pointer	sp				# l: stack pointer
long	note()				# l: get file position
int	qp_accessf()			# l: qpoe param existence
int	read()				# l: read data file
int	outptr


begin
	# mark the stack
	call smark(sp)
	call salloc(ltype, SZ_TYPEDEF, TY_CHAR)

	call salloc(name, SZ_TYPEDEF, TY_CHAR)
	call salloc(tbuf, SZ_TYPEDEF, TY_CHAR)
	call salloc(pbuf, SZ_TYPEDEF, TY_CHAR)
	call salloc(cbuf, SZ_TYPEDEF, TY_CHAR)

	# convert input name to upper case
	call strcpy(iname, Memc[name], SZ_TYPEDEF)
	call strupr(Memc[name])

	# add the number of records
	call sprintf(Memc[tbuf], SZ_TYPEDEF, "N%s")
	call pargstr(Memc[name])
	call sprintf(Memc[cbuf], SZ_TYPEDEF, "number of %s records")
	call pargstr(Memc[name])
	if( qp_accessf(qp, Memc[tbuf]) == YES ) {
	    call printf("warning: param %s exists - overwriting\n")
	     call pargstr(Memc[tbuf])
	    call qp_deletef(qp, Memc[tbuf])
	}
	call qpx_addf (qp, Memc[tbuf], "i", 1, cbuf, QPF_INHERIT)
	call qp_puti (qp, Memc[tbuf], nrecs)

	# add the type definition
	call sprintf(Memc[tbuf], SZ_TYPEDEF, "%sREC")
	call pargstr(Memc[name])
	call sprintf(Memc[cbuf], SZ_TYPEDEF, "%s record type")
	call pargstr(Memc[name])
	if( qp_accessf(qp, Memc[tbuf]) == YES ) {
	    call printf("warning: param %s exists - overwriting\n")
	     call pargstr(Memc[tbuf])
	    call qp_deletef(qp, Memc[tbuf])
	}
	flen = 0
	call strcpy(otype,Memc[ltype],SZ_TYPEDEF)

	call qpx_addf (qp, Memc[tbuf], Memc[ltype], flen, Memc[cbuf], QPF_INHERIT)

	# add the pros specific type definition
	call sprintf(Memc[pbuf], SZ_TYPEDEF, "XS-%sREC")
	call pargstr(Memc[name])
	call sprintf(Memc[cbuf], SZ_TYPEDEF, "%s PROS/IRAF specific record type")
	call pargstr(Memc[name])
	if( qp_accessf(qp, Memc[pbuf]) == YES ) {
	    call printf("warning: param %s exists - overwriting\n")
	        call pargstr(Memc[pbuf])
	    call qp_deletef(qp, Memc[pbuf])
	}
	flen = SZ_TYPEDEF
	call qpx_addf (qp, Memc[pbuf], "c", flen, Memc[cbuf], QPF_INHERIT )
	call qp_pstr(qp, Memc[pbuf], ptype )

	# add the data itself
	call sprintf(Memc[cbuf], SZ_TYPEDEF, "%s records")
	call pargstr(Memc[name])
	if( qp_accessf(qp, Memc[name]) == YES ) {
	    call printf("warning: param %s exists - overwriting\n")
	     call pargstr(Memc[tbuf])
	    call qp_deletef(qp, Memc[name])
	}
#  Again, use 0 and not nrecs so that this will be extensible
	flen = 0
	call qpx_addf (qp, Memc[name], Memc[tbuf], flen, Memc[cbuf], QPF_INHERIT)

######################################################33
	# read in the records

	# get length of single record - since QPOE will pad, we must
	# write out the records INDIVIDUALLY so that the padding
	# is done EVERY record and therefore is consistent

	if( nrecs > 0 )
	    len = (nrecs * bytes - 1) / SZB_CHAR + 1
	else
	    len = 0

	chars = bytes/SZB_CHAR
	if( chars * SZB_CHAR  != bytes )
	    chars = bytes

	got = 0
	left = len
#   GET must be rounded down to be an exact multiple of the input
#	record length and an even number of BYTES, since we can only
#	input in units of CHARS (2-bytes)
	get = min(MAX_GET, left)
	get = (get / chars) * chars	

	lrecs = get / chars		# allocate space for the records
	call salloc(buf, MAX_GET, TY_SHORT)
	call salloc(obuf, 4*MAX_GET, TY_SHORT)

	outptr=1
	while( left >0 ){
	    if( read(fd, Mems[buf], get) != get )
		call errstr(1, "unexpected EOF reading data", Memc[name])
	    got = got + get

#call printf("Prior to mii call in ft_addaux- extname: *%s* type: *%s*\n")
#call pargstr(Memc[name])
#call pargstr(itype)

	    lrecs = get / chars
	    # unpack the data
	    call mii_scale_unpack(buf,obuf,lrecs,itype,ext,scale)

	    # write it to the qpoe file
	    call qp_write(qp, Memc[name], Mems[obuf], lrecs, outptr,
			   Memc[tbuf])
	    outptr = outptr + lrecs

	    left = left - get
	    get = min(get, left)

	}

	# seek past padding
	remainder = mod(len, FITS_BUFFER/SZB_CHAR)
	if( remainder !=0 ){
	    left = FITS_BUFFER/SZB_CHAR - remainder
	    call seek(fd, note(fd)+left)
	}
	
	# free up stack space
	call sfree(sp)
end

