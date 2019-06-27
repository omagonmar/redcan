#$Header: /home/pros/xray/lib/qpcreate/RCS/eventdef.x,v 11.0 1997/11/06 16:21:28 prosb Exp $
#$Log: eventdef.x,v $
#Revision 11.0  1997/11/06 16:21:28  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:03  prosb
#General Release 2.4
#
#Revision 8.3  1995/02/23  21:52:20  mo
#MC	2/23/95		Returned evlookup(list) routine to
#			original code.  The >1 feature was
#			used by some routines.
#
#Revision 8.2  1995/02/23  20:03:35  mo
#MC	2/22/95		The evlookup routine should have returned
#			YES or NO, but in fact was returning >0 or ==0
#			Fixed this.
#
#Revision 8.1  1994/09/16  16:00:53  dvs
#Added support for x- and y- indexing (to ev_strip)
#Removed obsolete aux_padtype()
#Revised event size algorithm -- the size of an auxiliary extension
#and an event use the same algorithm.  Added support routines.
#
#Revision 8.0  94/06/27  14:32:38  prosb
#General Release 2.3.1
#
#Revision 7.2  94/05/17  09:33:12  mo
#MC	5/12/94		fixed ev_editlist routine to re-alloc the
#			symbol list to the length of the new symbol name
#			and inserted a couple missing 'Memc'
#			(Bug reported on DEC/UPQPOERDF)
#
#Revision 7.1  94/03/25  14:38:35  mo
#MC	3/25/94		Merge in evdefsubs routines
#
#Revision 7.0  93/12/27  18:11:49  prosb
#General Release 2.3
#
#Revision 6.2  93/12/16  09:30:15  mo
#MC	12/1/93		Update for 'boolean' support and for
#			padding event records (event and/or aux)
#
#Revision 6.1  93/07/02  14:16:53  mo
#MC	7/2/93		Correct data type of 'prev_char'
#
#Revision 6.0  93/05/24  15:55:28  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:25:07  mo
#MC/JM	5/20/93		Add support for converting between 2 different
#				QPOE formats
#
#Revision 5.0  92/10/29  21:18:20  prosb
#General Release 2.1
#
#Revision 4.4  92/10/23  15:43:19  mo
#MC	remove obsolete variable
#
#Revision 4.3  92/10/16  16:45:33  mo
#MC	10/17/92	put the qp_addf length back to SZ_LINE so
#			longer values can be written later
#
#Revision 4.2  92/07/08  10:13:02  jmoran
#JMORAN  1) moved PROS macro defines to <evmacro.h>
#	   2) changed SZ_LINE*2 to SZ_TYPEDEF for reading macro def
#	   3) changed "ev_qpput" routine to calc size of string instead
#	      of assuming maximum size to be SZ_LINE
#
#Revision 4.0  92/04/27  13:51:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  12:11:24  mo
#MC	4/13/92		Add new format ( FULL ) to accomodate unscreened
#			data sets coming soon for both Einstein and ROSAT
#
#Revision 3.0  91/08/02  01:05:09  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:26  pros
#General Release 1.0
#
#
# Module:       EVENTDEF.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      QPOE EVENT list definitions of record structures
# Description:	These routines create both a generic IRAF record definition:
#		e.g. {d,i,i,i} and QPOE macro definitions, e.g. {s:x,s:y}.
#		They provide conversion from ASCII to QPOE header parameter 
#		format and other utilities
# External:     ev_crelist, ev_lookuplist, ev_destroylist, ev_wrlist
#		ev_alias, ev_compile, ev_qpcompile, ev_strip, ev_qpput,
#		ev_qpget, ev_qpsize, ev_size, ev_lookup
# Local:        ev_xcomp, ev_destroycompile
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version 		1989
#               {1} MC    -- To support SLEW survey  -- 1/91
#                          -- To replace qp_astr with qp_pstr -- 1/91
#               {n} <who> -- <does what> -- <when>
#
include <mach.h>
include <ctype.h>
include <qpset.h>
include <qpoe.h>
include	<evmacro.h>

#
#  EVENTDEF.X -- routines to manipulate IRAF and PROS eventdefs
#

#
# EV_CRELIST -- create a list of macros symbols and values
# for each data in the event struct and return the number found
#
define MACALLOC	512

procedure  ev_crelist(prosdef, msymbols, mvalues, nmacros)

char	prosdef[ARB]		# i: input pros eventdef
pointer	msymbols		# o: array of sumbol name pointers
pointer	mvalues			# o: array of symbol value pointers
int	nmacros			# o: number of macros found

int	maxmacros		# l:
begin

	# init current byte offset, number of macros, and index into string
	# allocate space for a heap of macros
	maxmacros = MACALLOC
	call calloc(msymbols, maxmacros, TY_POINTER)
	call calloc(mvalues, maxmacros, TY_POINTER)
	call ev_mklist(prosdef,maxmacros,msymbols,mvalues,nmacros)
end
#
# EV_MKLIST -- create a list of macros symbols and values
# for each data in the event struct and return the number found
#     assumes MSYMBOL/MVALUE/NMACRO already alloced!
#
procedure  ev_mklist(prosdef, mlen, msymbols, mvalues, nmacros)
char	prosdef[ARB]		# i: input pros eventdef
int	mlen			# i: length of alloc arrays

pointer	msymbols		# i/o: array of sumbol name pointers
pointer	mvalues			# i/o: array of symbol value pointers
int	nmacros			# i/o: number of macros found
char	tbuf[SZ_TYPEDEF]
char	type			# l: char containing data type letter
#char	tbuf[SZ_FNAME]		# l: temp char buffer
int	index			# l: index into string of ":"
int	i			# l: current offset into string
int	j			# l: temp index
int	s			# l: remember current index
int	offset			# l: current byte offset
int	maxmacros		# l: current max macros
int	len			# l: length of macro name
int	stridx()		# l: index into string
int	strlen()		# l: string length

begin
	call strlwr(prosdef)
	maxmacros = mlen
	offset = 0
	nmacros = 0
	i = 1
99	# look for the next macro
	index = stridx(":", prosdef[i])
	# if no more, reaqlloc to the correct number of macros and return
	if( index ==0 ){
	    call realloc(msymbols, nmacros, TY_POINTER)
	    call realloc(mvalues, nmacros, TY_POINTER)
	    return
	}
	# got one more macro
	nmacros = nmacros+1
	# make sure we have room for this one
	if( nmacros >= maxmacros ){
	    maxmacros = maxmacros + MACALLOC
	    call realloc(msymbols, maxmacros, TY_POINTER)
	    call realloc(mvalues, maxmacros, TY_POINTER)
	}
	# update current
	i = i + index - 1
	# pick up the macro type, just before the ":"
	s = i-1
	type = prosdef[s]
	# pick up the macro name after ":", up to a delimiter
	i = i+1
	j = 1
	while( (prosdef[i] != ',') &&
	       (prosdef[i] != '}') &&
	       (prosdef[i] != EOS) &&
	       (!IS_WHITE(prosdef[i])) ){
	    tbuf[j] = prosdef[i]
	    i = i + 1
	    j = j+1
	}
	tbuf[j] = EOS
	# get length of macro name
	len = strlen(tbuf)
	# allocate space for the symbol name and value
	call calloc(Memi[msymbols+nmacros-1], len+1, TY_CHAR)
	# save name
	call strcpy(tbuf, Memc[Memi[msymbols+nmacros-1]], len)
	# make a value string
	call ev_uplen(type,offset)
	call sprintf(tbuf, SZ_TYPEDEF, "%c%d")
	call pargc(type)
	call pargi(offset)
	# get length of macro value
	len = strlen(tbuf)
	# allocate space for the value
	call calloc(Memi[mvalues+nmacros-1], len+1, TY_CHAR)
	# save value
	call strcpy(tbuf, Memc[Memi[mvalues+nmacros-1]], len)
	# get new offset for next macro
	switch(type){
	case 't':
	    offset = offset + SZ_SHORT * SZB_CHAR
	    prosdef[s] = 's'
	case 's':
	    offset = offset + SZ_SHORT * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_SHORT) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'i':
	    offset = offset + SZ_INT * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_INT) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'l':
	    offset = offset + SZ_LONG * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_LONG) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'r':
	    offset = offset + SZ_REAL * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_REAL) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'd':
	    offset = offset + SZ_DOUBLE * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_DOUBLE) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'x':
	    offset = offset + SZ_COMPLEX * SZB_CHAR
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_REAL) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	default:
	    call error(1, "unknown data type")
	}	
	# loop back for next macro
	goto 99
end

#  EV_CREDEF - re-construct the PROS EVENT definition string from the
#		previously compiled arrays
procedure ev_credef(msymbols,mvalues,nmacros,prosdef)
pointer	msymbols	# i: pointer to symbols
pointer	mvalues		# i: pointer to values
int	nmacros		# i: number of elements
char	prosdef		# o: new prosdef string

int	ii		# l:
char	onechar[10]	# l:

begin
	call strcpy("{",prosdef,SZ_TYPEDEF)
	do ii=1,nmacros
	{
	    call strcpy(Memc[Memi[mvalues+ii-1]],onechar,1)
	    call strcat(onechar,prosdef,SZ_TYPEDEF)
	    call strcat(":",prosdef,SZ_TYPEDEF)
	    call strcat(Memc[Memi[msymbols+ii-1]],prosdef,SZ_TYPEDEF)
	    if( ii != nmacros )
		call strcat(",",prosdef,SZ_TYPEDEF)
	}
	call strcat("}",prosdef,SZ_TYPEDEF)
end
#
#  EV_LOOKUPLIST.X -- lookup a parameter name from a list (made by ev_crelist)
#  and get type and offset
#  returns:
#	>0  if a type and offset were found
#	NO  if no type or offset were found (i.e., no macro or a macro
#	    defining something other than an event offset)
#
int procedure ev_lookuplist(macro, msymbols, mvalues, nmacros, type, offset)

char	macro[ARB]			# i: macro name
pointer	msymbols			# i: array of sumbol name pointers
pointer	mvalues				# i: array of symbol value pointers
int	nmacros				# i: number of macros found
int	type				# o: data type
int	offset				# o: offset
int	i				# l: loop counter
int	ip				# l: pointer for ctoi
int	ctoi()				# l: convert char to int
bool	streq()				# l: string compare

begin

	do i=1, nmacros{
	    if( streq(macro, Memc[Memi[msymbols+i-1]]) ){
		# get the type 
		switch(Memc[Memi[mvalues+i-1]]){
		case 's':
		    type = TY_SHORT
		case 'i':
		    type = TY_INT
		case 'l':
		    type = TY_LONG
		case 'r':
		    type = TY_REAL
		case 'd':
		    type = TY_DOUBLE
		case 'x':
		    type = TY_COMPLEX
		default:
		    call error(1, "unknown data type")
		}
		# get the offset
		ip = 2
		if( ctoi(Memc[Memi[mvalues+i-1]], ip, offset) ==0 )
		    call error(1, "illegal offset")
		# make the offset a short offset, not a byte offset
		offset = offset / (SZ_SHORT*SZB_CHAR)
		return(i)
#		return(YES)
	    }
	}
	# didn't find the macro
	return(NO)
end

#
# EV_DESTROYLIST -- destroy a list of macros symbols and values
# for each data in the event struct
#
procedure  ev_destroylist(msymbols, mvalues, nmacros)

pointer	msymbols		# i: array of sumbol name pointers
pointer	mvalues			# i: array of symbol value pointers
int	nmacros			# i: number of symbols
int	i			# l: loop counter

begin
	# free up the names and values
	do i=1, nmacros{
	    call mfree(Memi[msymbols+i-1], TY_CHAR)
	    call mfree(Memi[mvalues+i-1], TY_CHAR)
	}
	# free up the arrays of pointers
	call mfree(msymbols, TY_POINTER)
	call mfree(mvalues, TY_POINTER)

end

# EV_WRLIST write the macros for each data in the event struct
procedure  ev_wrlist(qp, msymbols, mvalues, nmacros)

pointer	qp			# i: qpoe handle
pointer	msymbols		# i: array of sumbol name pointers
pointer	mvalues			# i: array of symbol value pointers
int	nmacros			# i: number of symbols
int	i			# i: loop counter
int	qp_accessf()		# l: qpoe parameter existence
int	strlen()		# l: string length

begin

	do i=1, nmacros{
	    # define macro if necessary
	    if( qp_accessf(qp, Memc[Memi[msymbols+i-1]]) == NO )
		call qpx_addf(qp, Memc[Memi[msymbols+i-1]], "macro", SZ_TYPEDEF,
			 "macro definition", QPF_NONE)
	    # write the macro value
	    call qp_write(qp, Memc[Memi[msymbols+i-1]],
			      Memc[Memi[mvalues+i-1]],
			      strlen(Memc[Memi[mvalues+i-1]]), 1, "macro")
	}

end

#
#  EV_STRIP -- parse a PROS eventdef, stripping out the
#  pros macro definitions to make a QPOE eventdef
#
procedure ev_strip(prosdef, eventdef, len, qphead)

char	prosdef[ARB]		# i: input pros eventdef
char	eventdef[ARB]		# o: output qpoe eventdef
int	len			# i: length of output
pointer qphead			# i: pointer to QPOE header struct
char	tbuf[SZ_LINE]		# l: temp buffer
int	i, j, k			# l: loop counters
int	colons, commas		# l: counter for colons and commas
char	indexx[SZ_INDEXX]	# l: string defining x-index (e.g. ":x")
char	indexy[SZ_INDEXY]	# l: string defining y-index (e.g. ":y")
bool	streq()

begin
	if (qphead==0)
	{
	   # if we don't have QPHEAD, just use default indices
	   call strcpy("x",indexx,SZ_INDEXX)
	   call strcpy("y",indexy,SZ_INDEXY)
	}
	else
	{
	   call strcpy(QP_INDEXX(qphead),indexx,SZ_INDEXX)
	   call strcpy(QP_INDEXY(qphead),indexy,SZ_INDEXY)
	}

	colons = 0
	commas = 0
	eventdef[1] = EOS
	i = 1
	j = 1
	# loop though input characters until end of either string
	while( (prosdef[i] != EOS) && (j<=len) ){
	    # most characters just get transferred
	    if( prosdef[i] != ':' ){
		eventdef[j] =  prosdef[i]
		if( prosdef[i] == ',' )
		    commas = commas+1
		i = i+1
		j = j+1
	    }
	    # transfer :INDEX, where INDEX is either the x- or
	    # y- index string.  Transfer no other :NAME macros.
	    else{
		colons = colons+1
		k = 1

		# move past colon
		i = i + 1

		# collect ":" input up to a delimeter
		while( (prosdef[i] != ',') &&
		       (prosdef[i] != '}') &&
		       (prosdef[i] != EOS) &&
		       (!IS_WHITE(prosdef[i])) ){
		    tbuf[k] = prosdef[i]
		    i = i+1
		    k = k+1
		}
		tbuf[k] = EOS

		# see if we have one of the indices ...
		if( streq(tbuf, indexx))
		{
		    call strcpy(":x",eventdef[j],len)
		    j = j + 2
		}
		else if( streq(tbuf, indexy))
		{
		    call strcpy(":y",eventdef[j],len)
		    j = j + 2
		}
	    }
	}
	# null terminate the output string
	eventdef[j] = EOS
	# make sure everyone has a name
	if( (commas+1) != colons )
	    call errstr(1, "every event element must have a name", prosdef)

end



procedure ev_create_names(irafdef, prosdef)  

char	irafdef[ARB]
char	prosdef[ARB]

int	s_cnt, i_cnt, l_cnt
int	r_cnt, d_cnt, x_cnt
int     ii, jj, len, end_pos
int	curr_cnt
int	stridx, strlen() 
int	itoc()
int	ret_val
char 	comma, colon
char	close_brace
char	temp_str[SZ_LINE]
bool	create_name
char	prev_char


begin
	comma = ','
	colon = ':'
	close_brace = '}'

	s_cnt = 0; i_cnt = 0; l_cnt = 0
	r_cnt = 0; d_cnt = 0; x_cnt = 0

	end_pos = stridx(close_brace, irafdef)
	create_name = TRUE

	ii = 1; jj = 1
	while (ii <= end_pos)
	{
	   if (irafdef[ii] == comma || ii == end_pos)
	   {
	      if (create_name)
	      {
                 switch (prev_char)
        	 {
                     case 's':
            		s_cnt = s_cnt + 1; curr_cnt = s_cnt
			call strcpy(":short", temp_str, SZ_LINE)

          	     case 'i':
            		i_cnt = i_cnt + 1; curr_cnt = i_cnt
			call strcpy(":int", temp_str, SZ_LINE)

          	     case 'l':
		        l_cnt = l_cnt + 1; curr_cnt = l_cnt
			call strcpy(":long", temp_str, SZ_LINE)

          	     case 'r':
            		r_cnt = r_cnt + 1; curr_cnt = r_cnt
			call strcpy(":real", temp_str, SZ_LINE)

          	     case 'd':
            		d_cnt = d_cnt + 1; curr_cnt = d_cnt
			call strcpy(":doub", temp_str, SZ_LINE)

          	     case 'x':
            	        x_cnt = x_cnt + 1; curr_cnt = x_cnt
			call strcpy(":cplx", temp_str, SZ_LINE)

          	     default:
            	        call error(1, "unknown data type")
        	 } # end switch

		 len = strlen(temp_str)
		 ret_val = itoc(curr_cnt, temp_str[len + 1], 10)

        	 len = strlen(temp_str)
        	 call strcat(temp_str, prosdef[jj], len)
        	 jj = jj + len
	      }
	      else
		  create_name = TRUE
	   }
	   else
	   {
	      if (irafdef[ii] == colon)
		  create_name = FALSE

	      if (!IS_WHITE(irafdef[ii]))
		  prev_char = irafdef[ii]
	   }

           prosdef[jj] = irafdef[ii]
           ii = ii + 1; jj = jj + 1  

	} # end while

	# null terminate the output string
        prosdef[jj] = EOS
end


#
#  EV_QPPUT -- put a pros eventdef to a qpoe file
#
procedure ev_qpput(qp, prosdef)

int	qp				# i: qpoe handle
char	prosdef[ARB]			# i: pros eventdef
int	qp_accessf()			# i: qpoe param existence

#int   strlen()
int   maxlen

begin

#	Otherwise it's not possible to write a longer value
	maxlen = SZ_TYPEDEF

	# add information about the event record size
	if( qp_accessf(qp, PED) == NO )
	    call qpx_addf(qp, PED, "c", maxlen,
			 "PROS/QPOE event definition", 0)
	call qp_pstr(qp, PED, prosdef)
end

#
#  EV_QPGET -- get a pros eventdef from a qpoe file
#
procedure ev_qpget(qp, prosdef, len)

int	qp				# i: qpoe handle
char	prosdef[ARB]			# o: pros eventdef
int	len				# i: length of output
int	nchars				# l: return from qp_gstr
int	qp_accessf()			# l: qpoe param existence
int	qp_gstr()			# l: get qpoe string param

begin

	# add information about the event record size
	if( qp_accessf(qp, PED) == YES )
	    nchars = qp_gstr(qp, PED, prosdef, len)
	else
	    call strcpy("NONE", prosdef, len)

end

#
# EV_QPSIZE -- get event size of a qpoe file
#
procedure ev_qpsize(qp, evsiz)

int	qp			# i: qpoe handle
int	evsiz			# o: event size type - see qpoe.h
char	eventdef[SZ_TYPEDEF]	# l: from qp_queryf
char	comment[SZ_COMMENT]	# l: from qp_queryf
int	maxelem			# l: from qp_queryf
int	nelem			# l: from qp_query
int	flags			# l: from qp_queryf
int	nchars			# l: return from qp_gstr
int	qp_accessf()		# l: qpoe param existence
int	qp_gstr()		# l: get qpoe string param
int	qp_queryf()		# l: qp_queryf

begin

	# get information about pros eventdef or event parameter
	if( qp_accessf(qp, PED) == YES )
	    nchars = qp_gstr(qp, PED, eventdef, SZ_TYPEDEF)
	else
	    nelem = qp_queryf(qp, "event", eventdef, maxelem, comment, flags)
	call ev_osize(eventdef, evsiz)

end

#
# EV_OSIZE -- get event size of a qpoe event record in SZ_CHAR units - no
#		padding
#
procedure ev_osize(eventdef, evsiz)

char	eventdef[ARB]		# i: from qp_queryf
int	evsiz			# o: event size  in SPP char
int	i			# l: loop counter

begin
	i = 1
	evsiz = 0
	while( eventdef[i] != EOS ){
	    switch(eventdef[i]){
	    case '{', '}', ' ', ',':
		;
#	    # skip over ":x" and ":y"
	    case ':':
		repeat{
		    i = i + 1
		}until( !IS_ALNUM(eventdef[i]) && (eventdef[i] != '_'))
	    case 's':
		evsiz = evsiz + SZ_SHORT
	    case 'i':
		evsiz = evsiz + SZ_INT
	    case 'l':
		evsiz = evsiz + SZ_LONG
	    case 'r':
		evsiz = evsiz + SZ_REAL
	    case 'd':
		evsiz = evsiz + SZ_DOUBLE
	    case 'x':
		evsiz = evsiz + SZ_COMPLEX
	    default:
		call error(1, "unknown data type")
	    }
	    i = i + 1
	}	
end

#
# EV_SIZE -- get QPOE-specific size of a typedef record in SZB_CHAR units.
#     This can be either an event record or an auxiliary extension record.
#     
#     This simply calls sz_typedef.
#
procedure ev_size(eventdef, evsiz)

char	eventdef[ARB]		# i: from qp_queryf
int	evsiz			# o: event size in SZB_CHAR units
int	sz_typedef()
begin
	evsiz = sz_typedef(eventdef)
end


#
# EV_AUXSIZE -- get event size of a qpoe auxiliary record in SZB_CHAR units
#
#      Again, this just calls sz_typedef.
#

procedure ev_auxsize(eventdef, evsiz)

char	eventdef[ARB]		# i: from qp_queryf
int	evsiz			# o: event size in SZB_CHAR units
int	sz_typedef()
begin
	evsiz = sz_typedef(eventdef)
end

#
#  EV_ALIAS -- look up aliases for the pros eventdef
#
procedure ev_alias(alias, prosdef, len)

char	alias[ARB]				# i: string containing alias
char	prosdef[ARB]				# i: event definition
int	len					# i: len of prosdef
int	abbrev()				# l: look for abbrev

begin

	call strlwr(prosdef)

	# if user inputs "{...}", just pass through
	if( alias[1] == '{' )
	    return
	else if( abbrev("peewee", alias) >0 )
	    call strcpy(PROS_PEEWEE, prosdef, len)
	else if( abbrev("small", alias) >0 )
	    call strcpy(PROS_SMALL, prosdef, len)
	else if( abbrev("medium", alias) >0 )
	    call strcpy(PROS_MEDIUM, prosdef, len)
	else if( abbrev("large", alias) >0 )
	    call strcpy(PROS_LARGE, prosdef, len)
	else if( abbrev("full", alias) >0 )
	    call strcpy(PROS_FULL, prosdef, len)
	else if( abbrev("region", alias) >0 )
	    call strcpy(PROS_REGION, prosdef, len)
	else if( abbrev("slew", alias) >0 )
	    call strcpy(PROS_SLEW, prosdef, len)
	# These are the Fred aliases
	else if( abbrev("image", alias) >0 )
	    call strcpy(PROS_PEEWEE, prosdef, len)
	else if( abbrev("energy", alias) >0 )
	    call strcpy(PROS_SMALL, prosdef, len)
	else if( abbrev("time", alias) >0 )
	    call strcpy(PROS_MEDIUM, prosdef, len)
	else if( abbrev("detector", alias) >0 )
	    call strcpy(PROS_LARGE, prosdef, len)
	# ASTRO-D aliases
	else if( abbrev("faint", alias) >0 )
	    call strcpy(PROS_FAINT, prosdef, len)
	else if( abbrev("bright", alias) >0 )
	    call strcpy(PROS_BRIGHT, prosdef, len)
	else
	    call error(1, "unknown event definition")

end

#
#  EV_LOOKUP -- look up a qpoe macro and try to determine the type and offset
#  returns:
#	YES if a type and offset were found
#	NO  if no type or offset were found (i.e., no macro or a macro
#	    defining something other than an event offset)
#
int procedure ev_lookup(qp, macro, type, offset)

pointer	qp				# i: qpoe handle
char	macro[ARB]			# i: macro name
int	type				# o: data type
int	offset				# o: offset

int	ip				# l: index for ctoi()
int	nchars				# l: return from qp_expandtext
int	got				# l: return value for function
int	ctoi()				# l: convert char to int
pointer	sp				# l: stack pointer
pointer	value				# l: expanded macro
pointer	qp_expandtext()			# l: expand a macro

begin

	# mark the stack
	call smark(sp)
	# allocate a value buffer
	call salloc(value, SZ_LINE, TY_CHAR)
	# assume the worst
	got = NO
	# look for the symbol
	nchars = qp_expandtext (qp, macro, Memc[value], SZ_LINE)
	if( nchars ==0 )
	    goto 99
	# look for a type in the first character
	switch(Memc[value]){
	case 's':
	    type = TY_SHORT
	case 'i':
	    type = TY_INT
	case 'l':
	    type = TY_LONG
	case 'r':
	    type = TY_REAL
	case 'd':
	    type = TY_DOUBLE
	case 'x':
	    type = TY_COMPLEX
	default:
	    goto 99
	}
	# the string should be an integer from char 2 onwards
	ip = 2
	if( ctoi(Memc[value], ip, offset) ==0 )
	    goto 99
	# make sure there is nothing after the number
	if( ip <= nchars )
	    goto 99
	# concert offset into short offset
	offset = offset / (SZ_SHORT*SZB_CHAR)
	# we made it!
	got = YES
	# finish up
99	call sfree(sp)

	return(got)
end


#
#  EV_QPCOMPILE -- build a simple compiler of actions for elements of
#		  an event list, based on a list of names upon which to act
#  if the input string of elements is null, use the prosdef string
#
procedure ev_compile(prosdef, istr, name, comp, offset, type, ncomp,
		      s_c, i_c, l_c, r_c, d_c, x_c)

pointer	prosdef					# i: pros event definition
char	istr[ARB]				# i: string of event names
pointer	name					# o: pointer to compler names
pointer	comp					# o: pointer to compiler array
pointer	offset					# o: pointer to offset array
pointer	type					# o: pointer to type array
int	ncomp					# o: number of compiled actions
pointer	s_c, i_c, l_c, r_c, d_c, x_c		# i: compiled routines

begin

	call ev_xcomp(0, prosdef, istr, name, comp, offset, type, ncomp,
		  s_c, i_c, l_c, r_c, d_c, x_c, 0)

end

#
#  EV_QPCOMPILE -- build a simple compiler of actions for elements of
#		  an event list, based on a list of names upon which to act
# if the input string of elements is null, use the qpoe event def
#
procedure ev_qpcompile(qp, istr, name, comp, offset, type, ncomp,
		      s_c, i_c, l_c, r_c, d_c, x_c)

pointer	qp					# i: qpoe handle to get macros
char	istr[ARB]				# i: string of event names
pointer	name					# o: pointer to compler names
pointer	comp					# o: pointer to compiler array
pointer	offset					# o: pointer to offset array
pointer	type					# o: pointer to type array
int	ncomp					# o: number of compiled actions
pointer	s_c, i_c, l_c, r_c, d_c, x_c		# i: compiled routines

begin

	call ev_xcomp(qp, "", istr, name, comp, offset, type, ncomp,
		  s_c, i_c, l_c, r_c, d_c, x_c, 1)

end

#
#  EV_XCOMP -- common code for ev_qpcompile and ev_compile
#
define MAXALLOC	512
procedure ev_xcomp(qp, prosdef, istr, name, comp, offset, type, ncomp,
		  s_c, i_c, l_c, r_c, d_c, x_c, flag)

pointer	qp					# i: qpoe handle to get macros
char	prosdef[ARB]				# i: pros event def if no qpoe
char	istr[ARB]				# i: string of event names
pointer	name					# o: pointer to compler names
pointer	comp					# o: pointer to compiler array
pointer	offset					# o: pointer to offset array
pointer	type					# o: pointer to type array
int	ncomp					# o: number of compiled actions
pointer	s_c, i_c, l_c, r_c, d_c, x_c		# i: compiled routines
int	flag					# i: 0 = prosdef, 1 = qp

char	macro[SZ_LINE]				# l: temp char buffer
char	tstr[SZ_TYPEDEF]			# l: temp event element string
int	i, j					# l: loop indices
int	etype					# l: type in event struct
int	eoffset					# l: offset in event struct
int	maxcomp					# l: size of array
int	len					# l: length of macro string
int	index					# l: index into macro string
int	stridx()				# l: index into string
int	strlen()				# l: string length
int	ev_lookup()				# l: look up macro
int	ev_lookuplist()				# l: look up macro

pointer	msymbols			# l: array of sumbol name pointers
pointer	mvalues				# l: array of symbol value pointers
int	nmacros				# l: number of macros found

begin
	if( flag ==0 )
	    call  ev_crelist(prosdef, msymbols, mvalues, nmacros)
	# init some variables
	i = 1
	ncomp = 0
	# allocate space for a heap of sort routines
	maxcomp = MAXALLOC
	call calloc(name, maxcomp, TY_POINTER)
	call calloc(comp, maxcomp, TY_POINTER)
	call calloc(offset, maxcomp, TY_POINTER)
	call calloc(type, maxcomp, TY_POINTER)
	# if element string is null, get current prosdef from file
	if( istr[1] != EOS )
		call strcpy(istr, tstr, SZ_TYPEDEF)
	else{
	    if( flag ==0 )
		call strcpy(prosdef, tstr, SZ_TYPEDEF)
	    else
		call ev_qpget(qp, tstr, SZ_TYPEDEF)
	}
99	# look for next sort type
	# skip white space
	while( (tstr[i] == ',') ||
	       (tstr[i] == '{') ||
	       (tstr[i] == '}') ||
	       (tstr[i] == EOS) ||
	       (IS_WHITE(tstr[i])) ){
	    # return on EOS
	    if( tstr[i] == EOS ){
		call realloc(name, ncomp, TY_POINTER)
		call realloc(comp, ncomp, TY_POINTER)
		call realloc(offset, ncomp, TY_POINTER)
		call realloc(type, ncomp, TY_POINTER)
		if( flag ==0 )
		    call  ev_destroylist(msymbols, mvalues, nmacros)

		return
	    }
	    # bump pointer past white space
	    else
		i = i + 1
	}
	# grab sort string up to next white space
	j = 1
	while( (tstr[i] != ',') &&
	       (tstr[i] != '{') &&
	       (tstr[i] != '}') &&
	       (tstr[i] != EOS) &&
	       (!IS_WHITE(tstr[i])) ){
	    macro[j] = tstr[i]
	    i = i + 1
	    j = j + 1	
	}
	macro[j] = EOS
	# skip past type part, if necessary
	index = stridx(":", macro)
	if( index ==0 )
	    index = 1
	else
	    index = index + 1
	# get type and offset of this sort type
	if( flag ==0 ){
	    if( ev_lookuplist(macro[index], msymbols, mvalues, nmacros,
		etype, eoffset) == NO )
		call errstr(1, "macro not defined", macro[index])
	}
	if( flag ==1 ){
	    if( ev_lookup(qp, macro[index], etype, eoffset) == NO )
		call errstr(1, "macro not defined", macro[index])
	}
	# got another compare
	ncomp = ncomp + 1
	# make sure we have enough space for it
	if( ncomp >= maxcomp ){
	    maxcomp = maxcomp + MAXALLOC
	    call realloc(name, maxcomp, TY_POINTER)
	    call realloc(comp, maxcomp, TY_POINTER)
	    call realloc(offset, maxcomp, TY_POINTER)
	    call realloc(type, maxcomp, TY_POINTER)
	}
	# save the name
	len = strlen(macro[index])
	call calloc(Memi[name+ncomp-1], len+1, TY_CHAR)
	call strcpy(macro[index], Memc[Memi[name+ncomp-1]], len)
	# save the offset and type
	Memi[offset+ncomp-1] = eoffset
	Memi[type+ncomp-1] = etype
	# save the correct compare routine
	switch(etype){
	case TY_SHORT:
	    call zlocpr(s_c, Memi[comp+ncomp-1])
	case TY_INT:
	    call zlocpr(i_c, Memi[comp+ncomp-1])
	case TY_LONG:
	    call zlocpr(l_c, Memi[comp+ncomp-1])
	case TY_REAL:
	    call zlocpr(r_c, Memi[comp+ncomp-1])
	case TY_DOUBLE:
	    call zlocpr(d_c, Memi[comp+ncomp-1])
	case TY_COMPLEX:
	    call zlocpr(x_c, Memi[comp+ncomp-1])
	default:
	    call error(1, "unknown data type")
	}
	# go back for the next macro
	goto 99
end

#
#  EV_DESTROYCOMPILE -- destroy the space used by ev_compile
#
procedure ev_destroycompile(name, comp, offset, type, n)

pointer	name				# i: array of names
pointer	comp				# i: array of compare pointer
pointer	offset				# i: array of offsets
pointer	type				# i: array of types
int	n				# i: number in each array
int	i				# l: loop counter

begin
	call mfree(comp, TY_POINTER)
	call mfree(offset, TY_POINTER)
	call mfree(type, TY_POINTER)
	do i=1,n{
	    call mfree(Memi[name+i-1], TY_CHAR)
	}
	call mfree(name, TY_POINTER)

end

procedure ev_uplen(type,offset)
char	type		# i:	character for data type SILRDX, etc
int	offset		# i/o:	Corrected offset based on alignment

begin
	switch(type){
	case 's':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_SHORT) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'i':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_INT) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'l':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_LONG) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'r':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_REAL) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'd':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_DOUBLE) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	case 'x':
	    while( mod(offset/(SZ_SHORT*SZB_CHAR), SZ_REAL) !=0 )
	        offset = offset + SZ_SHORT * SZB_CHAR
	}
end		

#
#  EV_DISP - Display a buffer of event-list values, that were compiled with
#		the routine EV_COMPILE or EV_QPCOMPILE routines
#
procedure ev_disp(nev,comp,ncomp,eoffset,evc,evlen,got)
int	nev	# i: number of events to display
pointer comp	# i: from ev_compile
int     ncomp   # i: from ev_compile
pointer eoffset # i: from ev_compile
pointer evc     # i: pointer to event buffer
int	evlen   # i: length of an event
int 	got     # i: number of the event


pointer	tbuf
pointer sp
pointer evl
int	i,j
pointer tp,cp
bool	dotable
begin
	call smark(sp)
	tp = 0
	cp = 0
	dotable = FALSE
	call salloc(tbuf,SZ_LINE*2,TY_CHAR)
	do i=1,nev
	{
            Memc[tbuf]=EOS
            evl = evc+(i-1)*evlen
            do j=1,ncomp
            {
                 call zcall9(Memi[comp+j-1], Memi[eoffset+j-1],
                           tp, cp, dotable, evl, got,
                            Memc[tbuf], SZ_LINE*2, 1)
            }
            call printf("%s\n")
               call pargstr(Memc[tbuf])
	}
	call sfree(sp)
end

int procedure ev_editlist(macro, nmacro, prosdef, msymbols, mvalues, nmacros )

char    macro[ARB]                      # i: macro name
char    nmacro[ARB]                     # i: replacement macro name
char	prosdef[ARB]			# i/o: updated prosdef string
pointer msymbols                        # i: array of sumbol name pointers
pointer mvalues                         # i: array of symbol value pointers
pointer	sp
pointer	ebuf
int     nmacros                         # i: number of macros found
int     ii                               # l: loop counter
bool	streq()
int	strlen(),strmatch()
int	len,index

begin

	call smark(sp)
	call salloc(ebuf,SZ_TYPEDEF,TY_CHAR)

        do ii=1, nmacros{
            if( streq(macro, Memc[Memi[msymbols+ii-1]]) ){
		len = strlen(nmacro)
	        call realloc(Memi[msymbols+ii-1], len+1, TY_CHAR)
		call strcpy(nmacro,Memc[Memi[msymbols+ii-1]],SZ_TYPEDEF)
		index = strmatch(prosdef,macro)
		len = strlen(macro)
		if( index <= len)
		    call error(1,"Invalid string index")
		call strcpy(prosdef[index],Memc[ebuf],SZ_TYPEDEF)
		prosdef[index-len]=EOS
		call strcat(nmacro,prosdef,SZ_TYPEDEF)
		call strcat(Memc[ebuf],prosdef,SZ_TYPEDEF)
		call sfree(sp)
		return(YES)
	    }
	}
        # didn't find the macro
	call sfree(sp)
        return(NO)
end

#
#  BYTE_SIZE - returns the size (in bytes) of the specified type,
#	       one of 't', 'i', 'l', 'r', 'd', 'x', or 's'.
#

int procedure byte_size(type)
char 	type	# i: what type?

int  	size
int     sz_type()

begin
        switch(type)
        {
           case 't':
                size=1

           case 'i','l','r','d','x','s':
                size = sz_type(type)*SZB_CHAR

           default:
              call error(1, "unknown data type")
        }

        return (size)
end

#
#  SZ_TYPE - returns the size (in SZB_CHAR units) of the specified type,
#              one of 'i', 'l', 'r', 'd', 'x', or 's'.
#

int procedure sz_type(type)
char 	type 	# i: which type?

int  	size

begin
        switch(type)
        {
           case 's':
              size = SZ_SHORT

           case 'i':
              size = SZ_INT 

           case 'l':
              size = SZ_LONG

           case 'r':
              size = SZ_REAL

           case 'd':
              size = SZ_DOUBLE 

           case 'x':
              size = SZ_COMPLEX

           default:
              call error(1, "unknown data type")
        }

        return (size)
end

#
#  SZ_TYPEDEF - returns the size (in SZB_CHAR units) of the 
#		passed in typedef string, such as "{s:x,s:y,d,s,s}".
#
#		The size is appropriate for qpoe-specific tasks, in
#		that padding is expected at the end and between columns,
#		if necessary such the the following holds
#	
#		   * all columns start on a byte which is a multiple
#		     of the size of the column type.  (e.g., 'd's must
#		     fall on multiples of SZ_DOUBLE.)
#
#		   * the length of the record must be a multiple of
#		     SZ_INT or the size of the largest type in the
#		     typedef, whichever is larger.

int procedure sz_typedef(typedef)  
char    typedef[ARB]	# i: typedef string to assess.

int     recsize  # in units of SZB_CHAR
int     i
int     maxsize  # maximum size found so far.
int     typesize

int     sz_type()

begin

        recsize=0 
        i=1
        maxsize = SZ_INT

        while (typedef[i]!=EOS)
        {
           switch(typedef[i])
           {
            case '{', '}', ' ', ',':
                ;
            # skip over text after colon
            case ':':
                repeat{
                    i = i + 1
                }until( !IS_ALNUM(typedef[i]) && (typedef[i] != '_'))

            case 's','i','l','r','d','x':
                typesize=sz_type(typedef[i])
                
                if (mod(recsize,typesize)!=0)
                   recsize=recsize+typesize-mod(recsize,typesize)

                recsize=recsize+typesize

                maxsize=max(maxsize,typesize)
            default:
                call error(1, "unknown data type")
            }
            i=i+1
        }

        if (mod(recsize,maxsize)!=0)
             recsize=recsize+maxsize-mod(recsize,maxsize)
        
        return recsize
end

