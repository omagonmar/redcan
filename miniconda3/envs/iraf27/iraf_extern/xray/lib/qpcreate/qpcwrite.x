#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcwrite.x,v 11.0 1997/11/06 16:22:12 prosb Exp $
#$Log: qpcwrite.x,v $
#Revision 11.0  1997/11/06 16:22:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:44  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:02  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:19:18  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:53:06  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:29  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:11:41  pros
#General Release 1.0
#
include <qpoe.h>
include "qpcreate.h"

#
#  QPC_WRITE -- write qpoe records (sort as necessary)
# sort information is maintained in the qpcreate.com data base
#
procedure qpc_write(getevent, eventfd, io, convert, qphead, display, argv)

pointer	getevent			# i: get event routine
int	eventfd[MAX_ICHANS]		# i: input event file channels
pointer	io				# i: qpoe event handle
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer
int	nev				# l: total number of events
int	pos				# l: current position in fits file
int	note()				# l: get file position

include "qpcreate.com"

begin
	# write a dumy header for fits -- we will re-write it later on
	# when we know the number of events
	if( otype == A3D ){
	  # note the position of the extension header
	  pos = note(io)
	  # write the event header, essentially to allocate space
	  # (we re-write it later)
	  call a3d_initev(io, qphead, display, argv, 0)
	}

	# we simply call the appropriate write routines
	if( sort == YES ){
	    if( nsort ==0 )
		call qpc_nosort(getevent, eventfd, io, convert, qphead,
				display, argv, nev)
	    else
		call qpc_sort(getevent, eventfd, io, convert, qphead,
				display, argv, nev)
	}
	else
	    call qpc_nosort(getevent, eventfd, io, convert, qphead,
				display, argv, nev)

	# for fits, re-write event header with correct number of events
	if( otype == A3D ){
	  # seek back to the header start
	  call seek(io, pos)
	  # re-write the event header with the correct event count
	  call a3d_initev(io, qphead, display, argv, nev)
	}
end

# QPC_NOSORT - read input records and write qpoe records (no sort)
#
procedure qpc_nosort(getevent, eventfd, io, convert, qphead, display, argv,
		     nev)

pointer	getevent			# i: get event routine
int	eventfd[MAX_ICHANS]		# i: input event file channels
pointer	io				# i: qpoe event handle
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer
int	nev				# o: total events read

int	i				# l: loop counter
int	get				# l: number of records to read
int	got				# l: number of records read
pointer	sindex				# l: event index pointer
pointer	buf				# l: event buffer pointer

include "qpcreate.com"

begin
	call qpc_time("nosort - start", display)

	# get as much event space as possible
	call qpc_memory(buf, get)

	# allocate space for the event index
	call calloc(sindex, get, TY_INT)
	# init the event index
	for(i=0; i<get; i=i+1)
	    Memi[sindex+i] = buf + (i*revsize)

	# read and write events
	nev = 0
	repeat{
	    # read in all of the records we can
 	    call zcall9(getevent, eventfd, oevsize, convert, buf,
			get, got, qphead, display, argv)
	    # write out the events in sorted order
	    if( got != 0 ){
	      nev = nev + got
	      if( otype == QPOE )
	        call qpio_putevents (io, Memi[sindex], got)
	      if( otype == A3D )
	        call a3d_putev(io, Memi[sindex], got)
	    }
	    call qpc_time("core sort - put", display)
	}until( got == 0 )

	# flush events
	if( otype == A3D )
	  call a3d_flush(io)

	# free space
	call mfree(buf, TY_SHORT)
	call mfree(sindex, TY_INT)
	call qpc_time("nosort  - end", display)
end

#
# QPC_SORT - sort qpc records in large batches, and write
#	      sorted batches to separate files
# the sort type is maintained in the qpcreate.com data base
#
procedure qpc_sort(getevent, eventfd, io, convert, qphead, display, argv,
		   nev)

pointer	getevent			# i: get event routine
int	eventfd[MAX_ICHANS]		# i: input event file channels
pointer	io				# i: qpoe event handle
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer
int	nev				# o: total events read

pointer	tmpfile[MAX_TEMPS]		# l: file names for temp files
int	tmpfd[MAX_TEMPS]		# l: fd's for temp files
int	i				# l: loop counter
int	nfds				# l: number of temp files used
int	get				# l: number of events to read
int	got				# l: number of events read
pointer	buf				# l: sort buffer
pointer	sindex				# l: index buffer for sort
extern	qpc_cmp()

include "qpcreate.com"

begin

	#
	# see if we can write the qpoe file without writing temp files
	#
	# if we can allocate the needed space, we just grab all records,
	# sort them, and write them out to the qpoe file.
	#
	# otherwise , we sort and write out temp files, and then merge
	#
	call qpc_time("sort - start", display)
	# get space for sorting
	call qpc_memory(buf, get)

	# if we got the entire space ...
	nev = 0
	if( get == inrecs ){
	    # read in all of the records we can
 	    call zcall9(getevent, eventfd, oevsize, convert, buf,
			get, got, qphead, display, argv)
	    nev = nev + got
	    call qpc_time("core sort - getevent", display)
	    # allocate space for the qsort index
	    call calloc(sindex, got, TY_INT)
	    # init the qsort index
	    for(i=0; i<got; i=i+1)
	        Memi[sindex+i] = buf + (i*revsize)
	    # sort the indexes of the big buffer
	    call qsort(Memi[sindex], got, qpc_cmp)
	    call qpc_time("core sort - sort", display)
	    # write out the events in sorted order
	    if( otype == QPOE )
	      call qpio_putevents (io, Memi[sindex], got)
	    if( otype == A3D )
	      call a3d_putev(io, Memi[sindex], got)
	    call qpc_time("core sort - put", display)
	    # free up space
	    call mfree(sindex, TY_INT)
	}
	# otherwise we sort, write out the temp records, and then merge
	else{
	    nfds = 0
	    # read all input records, convert, sort and write temp files
	    repeat{
		# read in the next batch
		call zcall9(getevent, eventfd, oevsize, convert, buf,
				get, got, qphead, display, argv)
		call qpc_time("tmp sort - getevent", display)
		# sort photons and write to next temp file
		if(got != 0){
		    nev = nev + got
		    call qpc_flush(tmpfd, tmpfile, nfds, buf, got, display)
		    call qpc_time("tmp sort - flush", display)
		}
	    } until(got == 0)
	    # now merge the records and write to qpoe
	    call qpc_merge(io, tmpfd, tmpfile, nfds, display)

	    call qpc_time("tmp sort  - merge", display)
	}
	# flush events
	if( otype == A3D )
	  call a3d_flush(io)

	# free space
	call mfree(buf, TY_SHORT)
	call qpc_time("sort  - end", display)
end

#
# QPC_FLUSH -- sort and flush a buffer full of photon records
#
procedure qpc_flush(tmpfd, tmpfile, nfds, buf, nrecs, display)

int	tmpfd[MAX_TEMPS] 		# i: fd's for temp files
pointer	tmpfile[MAX_TEMPS]		# i: file names for temp files
int	nfds				# i: number of temp files used
pointer	buf				# i: buffer containing photons
int	nrecs				# i: number of qpc records in input
int	display				# i: display level

pointer	sindex				# l: index for qsort
pointer	sp				# l: stack pointer
int	i				# l: loop counter
int	open()				# l: open a file
extern	qpc_cmp()

include "qpcreate.com"

begin
	# mark the stack
	call smark(sp)
	# inc number of files used
	nfds = nfds + 1
	# check against max
	if( nfds > MAX_TEMPS )
	    call error(1, "max number of temp files exceeded")
	# make a temp file
	call calloc(tmpfile[nfds], SZ_FNAME, TY_CHAR)
	call mktemp("qpc", Memc[tmpfile[nfds]], SZ_FNAME)
	# add a reasonable extension
	call addextname(Memc[tmpfile[nfds]], ".tmp", SZ_FNAME)
	# create the temp file
	tmpfd[nfds] = open(Memc[tmpfile[nfds]], NEW_FILE, BINARY_FILE)

	# allocate space for the qsort index
	call salloc(sindex, nrecs, TY_INT)
	# init the qsort index
	for(i=0; i<nrecs; i=i+1)
	    Memi[sindex+i] = buf + (i*revsize)

	# sort the indexes of the big buffer
	call qsort(Memi[sindex], nrecs, qpc_cmp)

	# write out the temp file in sorted order
	for(i=0; i<nrecs; i=i+1)
	    call write(tmpfd[nfds], Mems[Memi[sindex+i]], revsize)

	# flush and rewind
	call flush(tmpfd[nfds])
	call seek(tmpfd[nfds], BOF)
	# free up space
	call sfree(sp)
end

#
# QPC_MERGE -- merge separately sorted batches of qpc records
#	      and write them to the qpoe file
#
procedure qpc_merge(io, tmpfd, tmpfile, nfds, display)

pointer	io				# i: event handle
int	tmpfd[MAX_TEMPS]		# i: fd's for temp files
pointer	tmpfile[MAX_TEMPS]		# i: file names for temp files
int	nfds				# i: number of files opened
int	display				# i: display level

int	i				# l: loop counter
int	done				# l: number of temp files completed
int	nchars				# l: number of SPP chars just read
int	op				# l: # events in obuf
pointer xptr				# l: qpc recs from the temp files
pointer obuf				# l: buffer to hold output events
pointer	optr				# l: output pointer
pointer ev				# l: current event pointer
pointer	sp				# l: stack pointer

int	read()				# l: read data

include "qpcreate.com"

begin
	# mark the stack
	call smark(sp)
	# allocate space for qpc recs (1 per file) for merge
	call salloc(xptr, nfds*revsize, TY_SHORT)
	call salloc (obuf, LEN_EVBUF*revsize, TY_SHORT)
	call salloc (optr, LEN_EVBUF, TY_POINTER)

	# read the first record of each file
	for(i=1; i<=nfds; i=i+1){
	    nchars = read(tmpfd[i], Mems[xptr+((i-1)*revsize)], revsize)
	    # better be something there
	    if( nchars != revsize )
		call error(1, "unexpected EOF reading sorted temp file")
	}
	done = 0
	op = 0
	# process all data records in the temp files
	while( done != nfds ){
	    # find next qpc to write
	    call qpc_min(xptr, tmpfd, nfds, i, revsize)
	    # move record photon to a safe place
	    ev = obuf + (op * revsize)
	    Memi[optr+op] = ev
	    call amovs(Mems[xptr+((i-1)*revsize)], Mems[ev], revsize)
	    # bump pointer and flush output buffer when it fills
	    op = op+1
	    if( op >= LEN_EVBUF ){
		if( otype == QPOE )
		  call qpio_putevents (io, Memi[optr], op)
		if( otype == A3D )
		  call a3d_putev(io, Memi[optr], op)
		op = 0
	    }

	    # read the next record from this temp file
	    nchars = read(tmpfd[i], Mems[xptr+((i-1)*revsize)], revsize)
	    # see if this file at EOF
	    if( nchars == EOF ){
		call close(tmpfd[i])      
		call delete(Memc[tmpfile[i]])
		call mfree(tmpfile[i], TY_CHAR)
	        tmpfd[i] = -1
	        done = done + 1
	    }
	}

	# flush any unbuffered events
	if( op > 0 ){
	    if( otype == QPOE )
	      call qpio_putevents (io, Memi[optr], op)
	    if( otype == A3D )
	      call a3d_putev(io, Memi[optr], op)
	}

	# free stack space
	call sfree(sp)
end

#
# QPC_MIN - find minimum of a group of qpc records
#
procedure qpc_min(xptr, tmpfd, nfds, min, size)

pointer	xptr			# i: pointer to array of qpc recs
int	tmpfd[ARB]		# i: >0 if the assoc qpc has data
int	nfds			# i: number of qpcs with data
int	min			# o: min qpc record
int	size			# i: size of input record

int	i			# l: loop counter
int	qpc_cmp()

include "qpcreate.com"

begin
	min = 0
	# find the first valid qpc record
	for(i=1; i<=nfds; i=i+1){
	    if( tmpfd[i] >0 ){
		min = i
		break
	    }
	}
	# now look for the smallest qpc record
	for(i=min+1; i<=nfds; i=i+1){
	    if( tmpfd[i] >0 ){
		# find the minimum, based on the sort type
		if(qpc_cmp(xptr+((i-1)*size), xptr+((min-1)*size)) <0)
		    min = i
	    }
	}
	# shouldn't happen
	if( min ==0 )
	    call error(1, "no qpc records available for compare")
end


