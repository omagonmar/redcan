#$Header: /home/pros/xray/lib/pros/RCS/plhead.x,v 11.0 1997/11/06 16:21:05 prosb Exp $
#$Log: plhead.x,v $
#Revision 11.0  1997/11/06 16:21:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:59  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:29  prosb
#General Release 2.3
#
#Revision 6.2  93/12/07  22:39:36  dennis
#Another false alarm.
#
#Revision 6.1  93/12/04  03:29:21  dennis
#Checked out unnecessarily for a change that turned out to be confined to 
#xmask.x.
#
#Revision 6.0  93/05/24  15:53:53  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:19  prosb
#General Release 2.1
#
#Revision 4.1  92/09/02  02:40:15  dennis
#Change size of .pl header line buffers to SZ_REGOUTPUTLINE; use new 
#routine getanyline() to read the lines.
#Remove extra "+1" in several allocations.
#
#Revision 4.0  92/04/27  13:49:40  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/01/28  23:25:19  dennis
#Replace 1024 with SZ_OBUF, from <printf.h>, as max length of formatted
#output string.
#
#Revision 3.0  91/08/02  01:01:14  wendy
#General
#
#Revision 2.1  91/04/12  10:03:21  mo
#MC	3/91	This was one of a series of fixes needed to allow
#		region strings > 1024 characters.  It appears that
#		1024 characters is the IRAF limit for %s printf.  So
#		multiple print statements were included to accomodate
#		larger strings.
#
#Revision 2.0  91/03/07  00:07:23  pros
#General Release 1.0
#
# Module:       PLHEAD.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to manipulate the PLIO header string
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC -- Update include afiles -- 2/91
#               {n} <who> -- <does what> -- <when>
#
#	PLHEAD.X -- routines to manipulate the PLIO header string
#

include <mach.h>
include <ctype.h>

include <plhead.h>	# defines SZ_PLHEAD
include	<regparse.h>	# defines SZ_REGOUTPUTLINE
include	<printf.h>	# defines SZ_OBUF

# define size by which we inc the region string on retrieval
define REGION_INC	1024
# define size by which we inc the notes string on retrieval
define NOTES_INC	1024

#
# ENC_PLHEAD -- encode a plio header string prior to saving it with pl_savef
# make the mask, then call this routine to create the plio string header,
# and then save the mask and the header with the usual call to pl_savef:
# call pl_savef(pl, plname, s, 0)
#
procedure enc_plhead(name, type, file, xdim, ydim, scale, regions, s, len)

char	name[ARB]			# i: mask name
char	type[ARB]			# i: mask type (region, exposure, etc.)
char	file[ARB]			# i: reference file name
int	xdim				# i: x dimension of mask
int	ydim				# i: y dimension of mask
double	scale				# i: scale factor used to make the mask
pointer	regions				# i: region summary pointer
char	s[ARB]				# o: plio string that gets stored
int	len				# i: length of output string

char	lbuf[SZ_REGOUTPUTLINE]		# l: region line buffer
int	total				# l: length of s string
int	fd				# l: region string fd
int	lineno				# l: region line number

int	strlen()			# l: string length
int	stropen()			# l: string open
int	getanyline()			# l: get a line from a file
bool	strne()				# l: string compare

begin
	# init output string length
	total = 0
	# add the mask name
	if( strne("", name) ){
	    call sprintf(s[total+1], len-total, "mask_name:\t%s\n")
	    call pargstr(name)
	}
	else
	    call sprintf(s[total+1], len-total, "mask_name:\tunknown\n")
	total = strlen(s)	    
	# add the mask type
	if( strne("", type) ){
	    call sprintf(s[total+1], len-total, "mask_type:\t%s\n")
	    call pargstr(type)
	}
	else
	    call sprintf(s[total+1], len-total, "mask_type:\tunknown\n")
	total = strlen(s)	    
	# add the reference file name to the string, if necessary
	if( strne("", file) ){
	    call sprintf(s[total+1], len-total, "ref_file:\t%s\n")
	    call pargstr(file)
	}
	else
	    call sprintf(s[total+1], len-total, "ref_file:\tnone\n")
	total = strlen(s)	    
	# add the x dimension to the string
	call sprintf(s[total+1], len-total, "xdim:\t\t%d\n")
	call pargi(xdim)
	if( xdim ==0 )
	    call printf("warning: 0 xdim for plio header\n")
	total = strlen(s)	    
	# add the y dimension to the string
	call sprintf(s[total+1], len-total, "ydim:\t\t%d\n")
	call pargi(ydim)
	if( ydim ==0 )
	    call printf("warning: 0 ydim for plio header\n")
	total = strlen(s)	    
	# add the scale to the string, if necessary
	if( scale > EPSILONR ){
	    call sprintf(s[total+1], len-total, "scale:\t\t%f\n")
	    call pargd(scale)
	}
	else
	    call sprintf(s[total+1], len-total, "scale:\t\tnone\n")
	total = strlen(s)	    
	# add the region summary to the string, if necessary
	if( regions !=0 ){
	    # see if we are about to truncate the region string
	    if( total + strlen(Memc[regions]) > len )
	        call printf("warning: regions truncated in plio header\n")
	    call sprintf(s[total+1], len-total, "regions:")
	    total = strlen(s)	    
	    # init line number
	    lineno = 0
	    # open the plio header as a string	
	    fd = stropen(Memc[regions], SZ_PLHEAD, READ_ONLY)
	    # read each line from the regions string
	    while( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) != EOF ){
		# skip blank lines
		if( lbuf[1] == '\n' )
	    	    next
		lineno = lineno + 1
		if( lineno == 1 ){
		    call sprintf(s[total+1], len-total, "\t%s")
		    call pargstr(lbuf)
		}
		else{
		    call sprintf(s[total+1], len-total, "\t\t%s")
		    call pargstr(lbuf)
		}
		total = strlen(s)	    
	    }
	    # close the string file
	    call strclose(fd)
	}
end

#
#  DEC_PLHEAD -- deccode a plio header string after loading it with pl_loadf
#
procedure dec_plhead(s, name, nlen, type, tlen, file, ilen,
			xdim, ydim, scale, regions, notes)

char	s[SZ_PLHEAD]			# i: plio string that gets read
char	name[ARB]			# o: mask name
int	nlen				# i: len of name string
char	type[ARB]			# o: mask type (region, exposure, etc.)
int	tlen				# i: len of type string
char	file[ARB]			# o: reference file name
int	ilen				# i: length of file string (for dec_pl)
int	xdim				# o: x dimension of mask
int	ydim				# o: y dimension of mask
double	scale				# o: scale factor used to make the mask
pointer	regions				# o: region summary pointer
pointer	notes				# o: notes at end of plhead string

char	lbuf[SZ_REGOUTPUTLINE]		# l: current line
char	tbuf[SZ_REGOUTPUTLINE]		# l: current token
int	fd				# l: string fd
int	rsize			# l: current size of regions or notes str
int	rline			# l: number of region lines processed
int	rmax			# l: current max size of regions or notes str
int	index			# l: index into string
pointer	sp				# l: stack pointer

int	stropen()			# l: string oen
int	getanyline()			# l: get line from file
int	strlen()			# l: string length
int	stridx()			# l: index into string
bool	streq()				# l: string compare

begin
	# mark the stack
	call smark(sp)
	# init optional variables
	file[1] = EOS
	scale = 0.0
	regions = 0 
	# open the plio header as a string	
	fd = stropen(s, SZ_PLHEAD, READ_ONLY)
	# read and decode each line from the string
	while( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) != EOF ){
	    # skip blank lines
	    if( lbuf[1] == '\n' )
	        next
	    # look for next keyword
	    index = stridx(":", lbuf)
	    if( index != 0 ){
	        call amovc(lbuf, tbuf, index)
	        tbuf[index] = EOS
		# point past the ":" in lbuf
		index = index + 1
		# skip white space
		for(;  IS_WHITE(lbuf[index]);  index=index+1 )
		;
	    }
	    else{
#	        call printf("warning: unknown plio header line - %s\n")
#		call pargstr(lbuf)
		# must have hit the notes section
		goto 98
	    }	
	    # look for regions, as they are processed specially
	    if( streq(tbuf, "regions") ){
		# allocate space for region string
		rsize = 0
		rmax = REGION_INC
		call calloc(regions, rmax, TY_CHAR)
		rline = 0
		# process the region section until we hit the notes or EOF
		while( TRUE ){
		    if( rline != 0 ){
			if( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) == EOF )
			    break
			# see if we hit the notes section
			if( !IS_WHITE(lbuf[1]) )
			    goto 98
			# skip white space
			for(index=1;  IS_WHITE(lbuf[index]);  index=index+1 )
			;
		    }
		    rline = rline + 1
		    # get size of new region string
		    rsize = rsize + strlen(lbuf[index])
		    # if we don't have enough room
		    if( rsize > rmax ){
			# increase the amount of space
			rmax = rmax + REGION_INC
			call realloc (regions, rmax, TY_CHAR)
		    }
		    # concat the latest line
		    call strcat(lbuf[index], Memc[regions], rsize)
		}
		# re-alloc to the actual size of the region string
		call realloc(regions, rsize, TY_CHAR)
	    }
	    else{
		# make sure we still have a token to deal with
		if( (lbuf[index] == '\n') || (lbuf[index] == EOS) ){
		    call printf("warning: invalid plio header line - %s\n")
		    call pargstr(lbuf)
		}
	        # Decode the value of the token
		call sscan (lbuf[index])
		# process the particular keyword
		if( streq(tbuf, "mask_name") )
		    call gargstr(name, nlen)
		else if( streq(tbuf, "mask_type") )
		    call gargstr(type, tlen)
		else if( streq(tbuf, "ref_file") )
		    call gargstr(file, ilen)
		else if( streq(tbuf, "xdim") )
		    call gargi(xdim)
		else if( streq(tbuf, "ydim") )
		    call gargi(ydim)
		else if( streq(tbuf, "scale") )
		    call gargd(scale)
		else{
#		    call printf("warning: unknown plio header keyword - %s\n")
#		    call pargstr(tbuf)
		    # must have hit the notes section
		    goto 98
		}
	    }
	}
	# skip processing of notes if we already hit EOF
	goto 99

	# process notes section until EOF
98	rsize = 0
	rmax = NOTES_INC
	call calloc(notes, rmax, TY_CHAR)
	# process the notes section until we hit EOF
	repeat{
	    # get size of new notes string
	    rsize = rsize + strlen(lbuf)
	    # if we don't have enough room
	    if( rsize > rmax ){
		# increase the amount of space
		rmax = rmax + NOTES_INC
		call realloc (notes, rmax, TY_CHAR)
	    }
	    # concat the latest line
	    call strcat(lbuf, Memc[notes], rsize)
	}
	until( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) == EOF )
	# re-alloc to the actual size of the notes string
	call realloc(notes, rsize, TY_CHAR)

99	# close the string file
	call strclose(fd)
	# and free the space
	call sfree(sp)
end

#
# DISP_PLHEAD -- make a standard display of the plio mask header
# this routine will be called by msk_display, for example
#
procedure disp_plhead(s)

char	s[SZ_PLHEAD]			# i: plio header string
int	clen				# l: length of displayed string
int	len				# l: length of complete string
int	strlen()

begin
	# this should be nice enough
	len = strlen(s)
	clen = 0
	if( s[1] != EOS ){
	    while( clen < len ){	# print in lumps of SZ_OBUF
	        call printf("%s")
	            call pargstr(s[clen+1])
	    clen = clen + SZ_OBUF       # SZ_OBUF is an IRAF string limit
	    }
	}
	else
	    call printf("No PL header available\n")
end

#
# ENC_PLNOTE -- encode a plio note to a plio header. The header string
# must already be encoded using enc_plhead.  A note can have a keyword
# and be of the form: "keyword: value" or it can just be a key-wordless
# note of the form: "value".  In the latter case, the type must be TY_CHAR,
# i.e., it must be a text note.
#
procedure enc_plnote(keyword, value, type, s, len)

char	s[ARB]			# i,o: plio header string
int	len			# i: max length of plio string
char	keyword[ARB]		# i: keyword for note
char	value[ARB]		# i: value - declared char but can be anything
int	type			# i: value type

int	tlen			# l: length of tbuf
int	index			# l: index into tbuf
pointer	tbuf			# l: temp buffer to hold new note
pointer	sp			# l: stack pointer
int	strlen()		# l: string length
bool	strne()			# l: string compare
bool	streq()			# l: string compare

begin
	# mark the stack
	call smark(sp)
	switch(type){
	# determine the length of the temp buffer
	case TY_CHAR:
	    tlen = strlen(keyword)+strlen(value)+SZ_LINE
	case TY_SHORT, TY_INT, TY_LONG, TY_REAL, TY_DOUBLE, TY_COMPLEX:
	    if( streq(keyword, "") )
		call error(1, "enc_plnote requires keyword for non-string notes")
	    tlen = strlen(keyword)+SZ_LINE
	default:
	     call error(1, "unknown data type for enc_plnote")
	}
	# allocate space for the temp buffer
	call salloc(tbuf, tlen, TY_CHAR)
	# encode the keywrod, if necessary
	if( strne(keyword, "") ){
	    call sprintf(Memc[tbuf], tlen, "%s:\t")
	    call pargstr(keyword)
	    index = strlen(Memc[tbuf])
	}
	else
	    index = 0
	tlen = tlen - index
	# encode the value
	switch(type){
	case TY_CHAR:
	    call sprintf(Memc[tbuf+index], tlen, "%s\n")
	    call pargstr(value)
	case TY_SHORT:
	    call sprintf(Memc[tbuf+index], tlen, "%d\n")
	    call pargs(value)
	case TY_INT:
	    call sprintf(Memc[tbuf+index], tlen, "%d\n")
	    call pargi(value)
	case TY_LONG:
	    call sprintf(Memc[tbuf+index], tlen, "%d\n")
	    call pargl(value)
	case TY_REAL:
	    call sprintf(Memc[tbuf+index], tlen, "%f\n")
	    call pargr(value)
	case TY_DOUBLE:
	    call sprintf(Memc[tbuf+index], tlen, "%f\n")
	    call pargd(value)
	case TY_COMPLEX:
	    call sprintf(Memc[tbuf+index], tlen, "%z\n")
	    call pargx(value)
	default:
	     call error(1, "unknown data type for enc_plnote")
	}
	# concat the note onto the plio header
	call strcat(Memc[tbuf], s, len)
	# free the stack
	call sfree(sp)
end

#
# DEC_PLNOTE -- decode a keyword note from the notes of a a plio header.
#
int procedure dec_plnote(s, keyword, value, len, type)

char	s[ARB]				# i: plio header string
char	keyword[ARB]			# i: keyword for note
char	value[ARB]			# o: value - declared char but can be anything
int	len				# i: max length of value string
int	type				# i: value type

short	stemp				# l: short temp
int	itemp				# l: int temp
long	ltemp				# l: long temp
real	rtemp				# l: real temp
double	dtemp				# l: double temp
complex	xtemp				# l: complex temp

char	lbuf[SZ_REGOUTPUTLINE]		# l: current line
char	tbuf[SZ_REGOUTPUTLINE]		# l: current token
int	fd				# l: string fd
int	index				# l: index into string
int	got				# l: got the keyword
pointer	sp				# l: stack pointer

int	stropen()			# l: string oen
int	getanyline()			# l: get line from file
int	stridx()			# l: index into string
bool	streq()				# l: string compare

begin
	# make sure we have a keyword
	if( streq(keyword, "") )
	    call error(1, "dec_plnote requires a keyword")
	# mark the stack
	call smark(sp)
	# open the note as a string	
	fd = stropen(s, SZ_PLHEAD, READ_ONLY)
	# assume the worst
	got = NO
	# read and decode each line from the string
	while( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) != EOF ){
	    # skip blank lines
	    if( lbuf[1] == '\n' )
	        next
	    # look for next keyword
	    index = stridx(":", lbuf)
	    if( index != 0 ){
	        call amovc(lbuf, tbuf, index)
	        tbuf[index] = EOS
		# point past the ":" in lbuf
		index = index + 1
		# skip white space
		for(;  IS_WHITE(lbuf[index]);  index=index+1 )
		;
	    }
	    else{
		next
	    }	
	    # process the keyword according to type
	    if( streq(tbuf, keyword) ){
		# got it!
		got = YES
		# Decode the value of the token
		call sscan (lbuf[index])
		# get the value
		switch(type){
		case TY_CHAR:
		    call gargstr(value, len)
		    break
		case TY_SHORT:
		    call gargs(stemp)
		    call amovs(stemp, value, 1)
		    break
		case TY_INT:
		    call gargi(itemp)
		    call amovi(itemp, value, 1)
		    break
		case TY_LONG:
		    call gargl(ltemp)
		    call amovl(ltemp, value, 1)
		    break
		case TY_REAL:
		    call gargr(rtemp)
		    call amovr(rtemp, value, 1)
		    break
		case TY_DOUBLE:
		    call gargd(dtemp)
		    call amovd(dtemp, value, 1)
		    break
		case TY_COMPLEX:
		    call gargx(xtemp)
		    call amovx(xtemp, value, 1)
		    break
		default:
		    call error(1, "unknown data type for dec_plnote")
		}
	    }
	}	
	# close the string file
	call strclose(fd)
	# free the stack
	call sfree(sp)
	# return the news
	return(got)
end
