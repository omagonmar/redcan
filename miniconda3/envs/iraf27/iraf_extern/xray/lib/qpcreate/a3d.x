#$Header: /home/pros/xray/lib/qpcreate/RCS/a3d.x,v 11.2 2001/03/26 21:00:01 prosb Exp $
#$Log: a3d.x,v $
#Revision 11.2  2001/03/26 21:00:01  prosb
#Y2K fixes
#
#WR (2/22/00) - changed: call wft_init_write_pixels(FITS_RECORD, TY_CHAR, FITS_BYTE)
# to: call wft_init_write_pixels(FITS_RECORD, TY_CHAR, FITS_BYTE, 0)
#JCC(2/14/00) - change LEN_DATE to LEN_DATE2 ?? need to be tested
#
#Revision 11.1  1999/09/20 16:10:53  prosb
#JCC(6/17/98) - Y2K: Updated a3d_main_header() to pass LEN_DATE instead
#               of LEN_STRING when calling wft_encode_date.
#
#Revision 11.0  1997/11/06 16:21:24  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:53  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:22  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:35  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:55:17  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:12  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:14  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:07  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  21:51:30  mo
#MC	8/1/91		Change from A3DTABLE to BINTABLE FITS extension
#			keyword
#
#Revision 2.0  91/03/07  00:10:14  pros
#General Release 1.0
#
#
#  A3D.X -- routines to create a FITS A3D table file
#

include <mach.h>
include <qpoe.h>
include <wfits.h> 
include "qpcreate.h"

#
#  A3D_INIT -- init to write a FITS header
# called by routines that write standard headers
#
procedure a3d_init(fd)

int	fd				# i: fits handle

begin
	call wft_init_write_pixels(FITS_RECORD, TY_CHAR, FITS_BYTE, 0)
end

#
#  A3D_MAIN_HEADER -- write a dummy FITS header for A3D files
#
procedure a3d_main_header(fd, event)

int	fd				# i: FITS handle
char	event[ARB]			# l: name of qpoe event record
char	tbuf[LEN_CARD+1]		# l: temp char buffer
bool	strne()				# l: string compare

begin
	# init the header
	call a3d_init(fd)
	# write essential header parameters
	call fts_putb(fd, "SIMPLE", YES, "FITS STANDARD")
	call fts_puti(fd, "BITPIX", 8, "Binary Data")
	call fts_puti(fd, "NAXIS", 0, "No image data array present")
	call fts_putb(fd, "EXTEND", YES, "There may be standard extensions")
	#Y2K. JCC(6/98)- passing LEN_DATE instead of LEN_STRING
        #                which defined in xray/lib/wfits.h
        #call wft_encode_date (tbuf, LEN_STRING)
	# call wft_encode_date (tbuf, LEN_DATE)
	call wft_encode_date (tbuf, LEN_DATE2)
	call fts_putc(fd, "DATE" , tbuf, "FITS creation date YYYY-MM-DD")
#	call fts_putc(fd, "IRAFNAME", "0_len_image", "Zero Length Dummy Image")
#	call fts_putb(fd, "QPOE", YES, "Standard QPOE A3D FITS file")
	if( strne("", event) )
	    call fts_putc(fd, "EVENT", event,
			"A3D table containing event record")
end

#
#  A3D_MAIN_END -- write last card and blank fill a header record
#
procedure a3d_main_end(fd)

int	fd				# i: fits handle
char	card[LEN_CARD+1]		# l: fits card
int	wft_last_card()			# l: encode last card
int	nrecords			# l: number of records written
int	stat				# l: return from wft_last_card

begin
	stat = wft_last_card (card)
	call wft_write_pixels (fd, card, LEN_CARD)
	call wft_write_last_record (fd, nrecords)
end

#
#  A3D_TABLE_HEADER -- write the standard part of a FITS A3D header
#
procedure a3d_table_header(fd, extname, naxis1, naxis2, tfields, extver)

int	fd				# i: FITS handle
char	extname[ARB]			# i: table name
int	naxis1				# i: width of table in bytes
int	naxis2				# i: number of entries in table
int	tfields				# i: number of fields in each row
int	extver				# i: version number of table

include "a3d.com"

begin
	# init the header
	call a3d_init(fd)
	# write general header parameters
#	call fts_putc(fd, "XTENSION", "A3DTABLE", "FITS A3D BINARY TABLE")
	call fts_putc(fd, "XTENSION", "BINTABLE", "FITS 3D BINARY TABLE")
	call fts_puti(fd, "BITPIX", 8, "Binary data")
	call fts_puti(fd, "NAXIS", 2, "Table is a matrix")
	call fts_puti(fd, "NAXIS1", naxis1, "Width of table in bytes")
	call fts_puti(fd, "NAXIS2", naxis2, "Number of entries in table")
	call fts_puti(fd, "PCOUNT", 0, "Random parameter count")
	call fts_puti(fd, "GCOUNT", 1, "Group count")
	call fts_puti(fd, "TFIELDS", tfields, "Number of fields in each row")
	call fts_putc(fd, "EXTNAME", extname, "Table name")
	call fts_puti(fd, "EXTVER", extver, "Version number of table")
	# set expected number of columns
	a3dmaxcol = tfields
	# reset column number
	a3dcol = 0
end

#
#  A3D_TABLE_ENTRY -- write a new table entry into the table
#
procedure a3d_table_entry(fd, tform, ttype, tunit)

int	fd				# i: FITS handle
char	tform[ARB]			# i: data type for field
char	ttype[ARB]			# i: label for field
char	tunit[ARB]			# i: physical units for field
char	tbuf[SZ_LINE]			# l: temp char buf
include "a3d.com"

begin
	# increment column number
	a3dcol = a3dcol + 1
	# add tform column
	call sprintf(tbuf, SZ_LINE, "TFORM%d")
	call pargi(a3dcol)
	call fts_putc(fd, tbuf, tform, "Data type for field")
	# add ttype column
	call sprintf(tbuf, SZ_LINE, "TTYPE%d")
	call pargi(a3dcol)
	call fts_putc(fd, tbuf, ttype, "Label for field")
	# add tunit column
	call sprintf(tbuf, SZ_LINE, "TUNIT%d")
	call pargi(a3dcol)
	call fts_putc(fd, tbuf, tunit, "Physical units for field")
end

#
#  A3D_TABLE_END -- write last card in a table and blank fill a header record
#
procedure a3d_table_end(fd)

int	fd				# i: fits handle
char	card[LEN_CARD+1]		# l: fits card
int	wft_last_card()			# l: encode last card
int	nrecords			# l: number of records written
int	stat				# l: return from wft_last_card
include "a3d.com"

begin
	# make sure we got the right number of fields
	if( a3dcol != a3dmaxcol )
	    call error(1, "internal A3D error: wrong number of fields")
	stat = wft_last_card (card)
	call wft_write_pixels (fd, card, LEN_CARD)
	call wft_write_last_record (fd, nrecords)
end

#
#  A3D_WRITE_DATA -- write data to FITS file, padding to 2880 byte records
#  assumes that we have already converted to MII format
#
procedure a3d_write_data(fd, buf, nshorts)

int	fd				# i: FITS handle
char	buf[ARB]			# i: buffer to write
int	nshorts				# i: number of machine shorts to write

begin
	call a3d_write(fd, buf, nshorts)
	call a3d_flush(fd)
end

#
#  a3d_write -- write a buffer full of data, no padding
#
procedure a3d_write(fd, buf, nshorts)

int	fd				# i: FITS handle
char	buf[ARB]			# i: buffer to write
int	nshorts				# i: number of machine shorts to write

int	cur				# l: current buffer offset
int	send				# l: number of SPP shorts to send
int	left				# l: number of SPP shorts left

begin
	# write the records in 2880 byte chunks
	cur = 1
	left = nshorts
	while( left >0 ){
	    send = min(1440, left)
	    call write(fd, buf[cur], send)
	    cur = cur + send
	    left = left - send
	}
end

#
#  a3d_flush -- pad to 2880 bytes
#
procedure a3d_flush(fd)

int	fd				# i: FITS handle
int	temp				# l: temp position
pointer	pad				# l: padding
long	note()				# l: get current file position

begin
	# determine where we are in SPP chars (subtract 1 to start at 0)
	# we want to write to an even 1440 char boundary
	temp = mod(note(fd)-1,1440)
	if( temp !=0 ){
	    # allocate a pad buffer
	    temp = 1440 - temp
	    call calloc(pad, temp, TY_SHORT)
	    # and write out padding
	    call write(fd, Mems[pad], temp)
	    call mfree(pad, TY_SHORT)
	}
end

