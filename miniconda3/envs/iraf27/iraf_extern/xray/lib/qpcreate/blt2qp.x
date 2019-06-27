#$Header: /home/pros/xray/lib/qpcreate/RCS/blt2qp.x,v 11.0 1997/11/06 16:21:26 prosb Exp $
#$Log: blt2qp.x,v $
#Revision 11.0  1997/11/06 16:21:26  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:30  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:43  prosb
#General Release 2.3
#
#Revision 6.1  93/10/28  12:14:53  dvs
#Initializes BLT_QUALITY and BLT_FORMAT.  These values will not be
#used, probably, but it's safest to set these values anyway.
#
#Revision 6.0  93/05/24  15:55:25  prosb
#General Release 2.2
#
#Revision 5.1  93/04/29  17:34:37  mo
#MC	4/29/93		Fix the BLT stop time to be .32 seconds later, to
#			show that the end time is valid for the entire
#			minor frame indicated and eliminate pseudo 'gaps'
#			in the record.
#
#Revision 5.0  92/10/29  21:18:16  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/23  22:18:46  prosb
#Commented out variable declaration "ii" line 115 -- not used.
#
#Revision 3.1  92/04/13  12:08:08  mo
#MC	4/13/92		Fix the longstanding bug the BLT records had times
#			referencing the wrong start time.
#			This didn't affect the use of them since the
#			times were previously ignored.  Now SPECTRAL
#			verifies BLT times against user QPOE filter times.
#
#Revision 3.0  91/08/02  01:05:09  prosb
#General Release 1.1
#
#Revision 2.1  91/05/24  11:47:58  mo
#MC      4/18/91         Correct the record size for BLT records
#                                in FITS output files.  Needed to correct
#                                xpr2fits                                
#
#
#Revision 2.0  91/03/07  00:10:21  pros
#General Release 1.0
#
#
# Module:       BLT2QP.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines for bal temporal ( constant aspect) for qpoe creation
# External:     all
# Local:        none
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version 1989
#               {1} MC    -- for system include files  -- 12/13/90
#               {2} MC    -- To allow BLT for all Einstein files
#                            but these routines skip for HRI    -- 2/8/91
#               {n} <who> -- <does what> -- <when>
#

include <mach.h>

include <einstein.h>
include <qpoe.h>

# define the size of an input blt record
define	SZ_DG_BLT	(64/SZB_CHAR)	# 64 DG bytes

# number of blt records in a buffer increment
define BUFINC	1000

#
#  BLT_OPEN -- open the blt file
#
procedure blt_open(fname, fd, convert, qphead, display, argv)

char	fname[ARB]			# i: blt file name
int	fd				# l: file descriptor
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	headsize			# l: size of header
int	open()				# l: file open

begin
    switch( QP_INST(qphead) ){
        case EINSTEIN_IPC:
            # open the file
            fd = open(fname, READ_ONLY, BINARY_FILE)
            # check whether there is a header
            # this is a kludge to get around the fact that production
            # tgr files have a header, but public domain tgr's don't
            # the file pointer is put into the correct place
            call uhd_checkhead(fd, qphead, convert, headsize)
        case EINSTEIN_HRI:
            call eprintf("WARNING: There is no BLT for HRI - skipping\n")
        default:
            call error(1,"Unknown Einstein einstein instrument code")
    }
end

#
#  BLT_CLOSE -- open the blt file
#
procedure blt_close(fd, qphead, display, argv)

int	fd				# i: blt fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
    if( QP_INST(qphead) == EINSTEIN_IPC ){
	if( display >=5 )
	    call printf("closing blt file\n")
	call close(fd)
    }
end

#
# BLT_GET -- read the blt records from the input file
#
procedure blt_get(fd, convert, qpbal, nblt, qphead, display, argv)

int	fd				# i: blt file descriptor
int	convert				# i: data conversion flag
pointer	qpbal				# o: pointer to blt records
pointer	qphead				# i: header
int	nblt				# i: number of records read
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	size				# l: size in SPP chars of blt record
int	osize				# l: output buffer size
int	ival				# l: temp int value
#int	ii
long	hut
pointer	ibase				# l: base pointer to input blt records
pointer	obase				# l: base pointer to output blt records
pointer	optr				# l: pointer to current output blt rec
pointer	sp				# l: stack pointer

int	read()				# l: read from a file
int	cvti4()				# l: convert i*4
real	cvtr4()				# l: convert r*4

begin
    if( QP_INST(qphead) == EINSTEIN_IPC ){
	# mark the stack
	call smark(sp)

	# check instrument
	switch( QP_INST(qphead) ){
	case EINSTEIN_IPC:
	    size = SZ_DG_BLT
	case EINSTEIN_HRI:
	    call error(1, "there is no blt file for Einstein HRI")
	default:
	    call error(1, "unknown Einstein detector")
	}

	# allocate space for the blt records (I hope we have enough!)
	call salloc(ibase, size/SZ_SHORT, TY_SHORT)
	# allocate space for the output records
	osize = BUFINC
	call calloc(obase, osize*SZ_QPBLT, TY_STRUCT)

	# read in the blt records and convert
	nblt = 0
	while( read(fd, Mems[ibase], size) != EOF ){
	    nblt = nblt+1
	    if( nblt > osize ){
		osize = osize + BUFINC
		call realloc(obase, osize*SZ_QPBLT, TY_STRUCT)
	    }
	    # point to the current record
	    optr = obase + ((nblt-1)*SZ_QPBLT)
	    # convert start and stop minor frames into times
	    ival = cvti4(Mems[ibase],convert)
#	    do ii=0,24
#		call bitmov(QP_MAJOR(qphead),25-ii,hut,32-ii,1)
	    hut = QP_HUT(qphead)
#	    BLT_START(optr) = double(ival)*.32
	    BLT_START(optr) = double(ival-hut)*.32D0+QP_TBASE(qphead)
	    ival = cvti4(Mems[ibase+2],convert)
#	    BLT_STOP(optr) = double(ival)*.32
	    BLT_STOP(optr) = double(ival-hut+1)*.32D0+QP_TBASE(qphead)
	    # our x goes in same direction as einstein y
	    BLT_ASPX(optr) = cvtr4(Mems[ibase+4],convert)
	    # our y goes in opposite direction to einstein z	
	    BLT_ASPY(optr) = - cvtr4(Mems[ibase+6],convert)
	    # get roll angle
	    BLT_ROLL(optr) = cvtr4(Mems[ibase+8],convert)
	    # get bal value
	    BLT_BAL(optr) = cvtr4(Mems[ibase+10],convert)
	    # get boresight rotation
	    BLT_BOREROT(optr) = cvtr4(Mems[ibase+12],convert)
	    # get boresight x
	    BLT_BOREX(optr) = cvtr4(Mems[ibase+14],convert)
	    # get boresight y
	    BLT_BOREY(optr) = - cvtr4(Mems[ibase+16],convert)
	    # get nominal roll
	    BLT_NOMROLL(optr) = cvtr4(Mems[ibase+18],convert)
	    # get binned roll
	    BLT_BINROLL(optr) = cvtr4(Mems[ibase+20],convert)
	    BLT_QUALITY(optr) = 1   # good time, good aspect (default)
	    BLT_FORMAT(optr)  = 0   # old Einstein format
	}
	# reallocate output space
	call realloc(obase, nblt*SZ_QPBLT, TY_STRUCT)

	# display blt record if necessary
	if( display >= 4 )
	    call disp_qpbal(obase, nblt, QP_INST(qphead))

	# free up stack space
	call sfree(sp)

	# fill in return values
	qpbal = obase
    }
    else
	nblt = 0
end

#
#  BLT_PUT -- write blt records to qpoe file
#	(calls library routine put_qpbal)
#
procedure blt_put(qp, qpblt, nblt, qphead, display, argv)

int	qp				# i: qpoe file descriptor
pointer	qpblt				# i: pointer to blt records
int	nblt				# i: number of blt records
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	bytes				# l: bytes in a record
int	qpc_type()			# l: 1 == QPOE, 2 == A3D

begin
    if( QP_INST(qphead) == EINSTEIN_IPC ){
	# write blt records to qpoe file
	switch(qpc_type()){
	case 1:
	  call put_qpbal(qp, qpblt, nblt)
	case 2:
	  if( nblt ==0 )
	      return
	  # write the standard part of the table header
	  # includes alignment at end
	  bytes = (2*SZ_DOUBLE+(9*SZ_REAL)+SZ_INT)*SZB_CHAR
	  call a3d_table_header(qp, "BLT", bytes, nblt, 12, 1)
	  call a3d_table_entry(qp, "1D", "START", "seconds")
	  call a3d_table_entry(qp, "1D", "STOP", "seconds")
	  call a3d_table_entry(qp, "1E", "ASPX", "pixels")
	  call a3d_table_entry(qp, "1E", "ASPY", "pixels")
	  call a3d_table_entry(qp, "1E", "ROLL", "radians")
	  call a3d_table_entry(qp, "1E", "BAL", "bin of aluminum")
	  call a3d_table_entry(qp, "1E", "BOREROT", "radians")
	  call a3d_table_entry(qp, "1E", "BOREX", "pixels")
	  call a3d_table_entry(qp, "1E", "BOREY", "pixels")
	  call a3d_table_entry(qp, "1E", "NOMROLL", "radians")
	  call a3d_table_entry(qp, "1E", "BINROLL", "radians")
	  call a3d_table_entry(qp, "1J", "ALIGN1", "dummy for alignment")
	  call a3d_table_end(qp)
	  call miistruct(Memi[qpblt], Memi[qpblt], nblt,
			 "{d,d,r,r,r,r,r,r,r,r,r,i}")
	  call a3d_write_data(qp, Memi[qpblt], nblt*bytes/SZB_CHAR)
	default:
	    call error(1, "qpcreate error: unknown qpcreate type")
	}
    }
end
