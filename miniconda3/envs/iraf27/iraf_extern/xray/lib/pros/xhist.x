#$Header: /home/pros/xray/lib/pros/RCS/xhist.x,v 11.0 1997/11/06 16:20:34 prosb Exp $
#$Log: xhist.x,v $
#Revision 11.0  1997/11/06 16:20:34  prosb
#General Release 2.5
#
#Revision 9.5  1996/03/05 20:25:56  prosb
#Joan - Changed the calling sequence in the third case statement of the
#       put_history() routine because one of the tables routines (tbhadt)
#       was not working correctly.
#
#Revision 9.3  96/02/13  17:07:51  prosb
#Joan - Updated to make it work on table (*.tab) files too.
#
#Revision 9.0  1995/11/16  18:28:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:48:00  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:26  prosb
#General Release 2.3
#
#Revision 6.2  93/10/21  11:39:37  mo
#MC   10/21/93        Add PROS/QPIO bug fix (qpx_addf)
#
#Revision 6.1  93/07/02  14:14:53  mo
#MC	7/2/93		Correct data type of streq (RS6000 port)
#
#Revision 6.0  93/05/24  15:55:07  prosb
#General Release 2.2
#
#Revision 5.1  93/05/11  09:30:04  mo
#MC	5/11/93		Add 'delete' and 'get' routines to support
#			QPAPPEND
#
#Revision 5.0  92/10/29  21:18:03  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/02  17:26:37  mo
#MC	4/2/92		Change format to lower case with lastest IRAF2.10 patch
#
#Revision 3.0  91/08/02  01:02:30  wendy
#General
#
#Revision 2.0  91/03/07  00:07:56  pros
#General Release 1.0
#
#
# Module:       XHIST.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to access x_hist<nn> params in QPOE/IMAGE files
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- initial version      1988
#               {1} mc    -- to add TSI history type -- 1/91
#                         -- to replace qp_astr to qp_pstr -- 1/91
#		{2} joan  -- to work on table (.tab) files too -- 2/96
#               {n} <who> -- <does what> -- <when>
#
#
# XHIST.X -- routines to access x_hist<nn> params
#

include <qpset.h>
include <tbset.h>

# max history records - this limit is so that x_hist<nn> is 8 chars or less
define MAX_HIST 99

# number of extra chars required for history line
define HEXTRA	32

# define input types
define TY_QPOE	1
define TY_IM	2
define TY_FITS	3
define TY_TAB	4	# joan added table type 2/8/96

# define the max size of a history record we can display
define SZ_HLINE 1024

# define some commonly used formats
define SEE_FORMAT	"see hist: %d"
define XREF_FORMAT	" %d"
define HIST_FORMAT	"XS-HIS%02d"
define DISP_FORMAT	"%2d: %s\n"
define X_NRECS		"XS-NHIST"

#
# PUT_QPHISTORY -- add a hist<nn> record to a qpoe file
#
procedure put_qphistory(fd, task, hist, special)

pointer	fd				# i: image handle
char	task[ARB]			# i: task making history
char	hist[ARB]			# i: history record
char	special[ARB]			# i: special parameter type

begin
	call put_history(fd, task, hist, special, TY_QPOE)
end

#
# PUT_IMHISTORY -- add a hist<nn> record to a non-qpoe image file
#
procedure put_imhistory(fd, task, hist, special)

pointer	fd				# i: image handle
char	task[ARB]			# i: task making history
char	hist[ARB]			# i: history record
char	special[ARB]			# i: special parameter type

begin
	call put_history(fd, task, hist, special, TY_IM)	
end

# 				
# PUT_TABHISTORY -- add a hist<nn> record to a table file
#				(joan added 2/8/96)
procedure put_tabhistory(fd, task, hist, special)

pointer	fd				# i: file handle
char	task[ARB]			# i: task making history
char	hist[ARB]			# i: history record
char	special[ARB]			# i: special parameter type

begin
	call put_history(fd, task, hist, special, TY_TAB)
end

#
# PUT_HISTORY -- add a hist<nn> record to an image or qpoe file
#
procedure put_history(fd, task, hist, special, itype)

pointer	fd				# i: image handle
char	task[ARB]			# i: task making history
char	hist[ARB]			# i: history record
char	special[ARB]			# i: special parameter type
int	itype				# i: image type - QPOE or IM or TAB

pointer	hbuf				# l: history line with task name, etc.
pointer	name1				# l: pointer to special name in hist
pointer	name2				# l: pointer to special param name
pointer	hist1				# l: history or "no hist" string
pointer	sp				# l: stack pointer
char	tbuf[SZ_LINE]			# l: test history param name
char	sbuf[SZ_LINE]			# l: special param value
char	task1[SZ_LINE]			# l: task name or "no task" string
int	len				# l: length of history
int	i				# l: loop counter
int	nchars				# l: chars returned by qp_gstr()

bool	streq()				# l: string compare
int	qp_accessf()			# l: qp param access
int	qp_gstr()			# l: get parameter string
int	qp_geti()			# l: get integer param
int	imgeti()			# l: get integer param
int	imaccf()			# l: im param access
int	strlen()			# l: string length
int	xhlookup()			# l: look up a special history name
int	max()				# l: max function
# joan added these 2/8/96
int	tbhgti()			# l: get integer param
int	parnum				# l: holds tbhfkw() output

begin
	# mark the stack
	call smark(sp)
	# copy task name and check for NULL
	call strcpy(task, task1, SZ_LINE)
	if( streq("", task1) )
	    call strcpy("(no task)", task1, SZ_LINE)
	# copy history and check for NULL
	len = strlen(hist)
	if( len ==0 ){
		call salloc(hist1, SZ_LINE, TY_CHAR)
		call strcpy("(no history)", Memc[hist1], SZ_LINE)
	}
	else{
		call salloc(hist1, len+1, TY_CHAR)
		call strcpy(hist, Memc[hist1], len)
	}
	# allocate a buffer for final history
	len = strlen(task1) + strlen(Memc[hist1]) + strlen(special) + HEXTRA
	# may as well make it a bit bigger
	len = max(len, SZ_LINE)
	call salloc(hbuf, len, TY_CHAR)
	# get number of history records and increment
	switch(itype){
	case TY_QPOE:
	    if( qp_accessf(fd, X_NRECS) == NO ){
		i = 1
		call qpx_addf(fd, X_NRECS, "i", 1, "number of hist records", 0)
	    }
	    else
		i = qp_geti(fd, X_NRECS) + 1
	    # make sure we have room
	    if( i > MAX_HIST ){
		call printf("\nWarning: history buffer full\n")
		call sfree(sp)
		return
	    }
	    # increment the number of history records
	    call qp_puti(fd, X_NRECS, i)
	case TY_IM:
	    if( imaccf(fd, X_NRECS) == NO ){
		i = 1
		call imaddf(fd, X_NRECS, "i")
	    }
	    else
		i = imgeti(fd, X_NRECS) + 1
	    # make sure we have room
	    if( i > MAX_HIST ){
		call printf("\nWarning: history buffer full\n")
		call sfree(sp)
		return
	    }
	    # increment the number of history records
	    call imputi(fd, X_NRECS, i)
	case TY_TAB: # joan added this next block for table files 2/8/96 
	    call tbhfkw(fd, X_NRECS, parnum)
	    if( parnum == 0 )
		i = 1
	    else
		i = tbhgti(fd, X_NRECS) + 1
	    # make sure we have room
	    if( i > MAX_HIST ){
		call printf("\nWarning: history buffer full\n")
		call sfree(sp)
		return
	    }
	    # increment the number of history records
	    call tbhadi(fd, X_NRECS, i)
	}
	# make the new history record name
	call sprintf(tbuf, SZ_LINE, HIST_FORMAT)
	call pargi(i)
	# start building the history string
	# (determine if the type warrents special processing)
	if( xhlookup(special, name1, name2) == YES ){
	    call sprintf(Memc[hbuf], len, "*%s* %s: %s")
	    call pargstr(Memc[name1])
	    call pargstr(task1)
	    call pargstr(Memc[hist1])
	    call mfree(name1, TY_CHAR)
	}
	else{
	    call sprintf(Memc[hbuf], len, "%s: %s")
	    call pargstr(task1)
	    call pargstr(Memc[hist1])
	}
	# put the history value
	switch(itype){
	case TY_QPOE:
	    call qpx_addf(fd, tbuf, "c", len, "HISTORY", QPF_INHERIT)
	    call qp_pstr(fd, tbuf, Memc[hbuf])
	    # put it to the IRAF history as well
	    if( qp_accessf(fd, "history") == NO )
	        call qpx_addf(fd, "history", "c", max(len, SZ_LINE), 
			"history", QPF_INHERIT)
	    call strcat("\n", Memc[hbuf], len)
	    call qp_pstr(fd, "history", Memc[hbuf])
	case TY_IM:
	    call imaddf(fd, tbuf, "c")
	    call imastr(fd, tbuf, Memc[hbuf])
	    # put it to the IRAF history as well
	    if( imaccf(fd, "history") == NO )
	        call imaddf(fd, "history", "c")
	    call strcat("\n", Memc[hbuf], len)
	    call imastr(fd, "history", Memc[hbuf])
	case TY_TAB:	# joan added 2/8/96
	    # always do this
	    call tbhadt(fd, tbuf, Memc[hbuf])
	    # put it to the IRAF history as well
	    # only do this if we have no HISTORY parameter
	    # if parameter exists, replace it

	    call tbhfkw(fd, "HISTORY", parnum)
	    if ( parnum == 0 )
            # this function is supposed to add OR replace 
 	    # but it seems to always add ...
    	
		call tbhadt(fd, "HISTORY", Memc[hbuf])
	}
	# add or modify the special parameter, if necessary
	if( name2 !=0 ){
	    switch(itype){
	    case TY_QPOE:
		# see if special parameter exists
		if( qp_accessf(fd, Memc[name2]) == NO ){
		    # if not, create the special parameter
		    call qpx_addf(fd, Memc[name2], "c", SZ_LINE,
				"data correction", QPF_INHERIT)
		    # start building the parameter x-ref value
		    call sprintf(sbuf, SZ_LINE, SEE_FORMAT)
		    call pargi(i)
		}
		else{
		    # if so, get the current value
		    nchars = qp_gstr(fd, Memc[name2], sbuf, SZ_LINE)
		    # add another x-ref
		    call sprintf(sbuf[strlen(sbuf)+1], SZ_LINE, XREF_FORMAT)
		    call pargi(i)
		}
		# put the value of the special parameter
		call qp_pstr(fd, Memc[name2], sbuf)
	    case TY_IM:
		# see if special parameter exists
		if( imaccf(fd, Memc[name2]) == NO ){
		    # if not, create the special parameter
		    call imaddf(fd, Memc[name2], "c")
		    # start building the parameter x-ref value
		    call sprintf(sbuf, SZ_LINE, SEE_FORMAT)
		    call pargi(i)
		}
		else{
		    # if so, get the current value
		    call imgstr(fd, Memc[name2], sbuf, SZ_LINE)
		    # add another x-ref
		    call sprintf(sbuf[strlen(sbuf)+1], SZ_LINE, XREF_FORMAT)
		    call pargi(i)
		}
		# put the value of the special parameter
		call imastr(fd, Memc[name2], sbuf)
	    case TY_TAB: # joan added 2/8/96
		# see if special parameter exists
	    	call tbhfkw(fd, Memc[name2], parnum)
	    	if( parnum == 0 ){
		    # if not, create the special parameter
        	    call tbhanp(fd, Memc[name2], "c", sbuf, parnum)
		    # start building the parameter x-ref value
		    call sprintf(sbuf, SZ_LINE, SEE_FORMAT)
		    call pargi(i)
		}
		else{
		    # if so, get the current value
		    call tbhgtt(fd, Memc[name2], sbuf, SZ_LINE)
		    # add another x-ref
		    call sprintf(sbuf[strlen(sbuf)+1], SZ_LINE, XREF_FORMAT)
		    call pargi(i)
		}
		# put the value of the special parameter
		call tbhadt(fd, Memc[name2], sbuf)
	    }
	    call mfree(name2, TY_CHAR)
	}
	# free up stack space
	call sfree(sp)
end

#
# DISP_QPHISTORY -- display history records in a qpoe file
#
procedure disp_qphistory(fd, type)

pointer	fd				# i: image or qpoe  handle
char	type[ARB]			# i: type of history

begin
	call disp_history(fd, type, TY_QPOE)
end

#
# DISP_IMHISTORY -- display history records in an image file
#
procedure disp_imhistory(fd, type)

pointer	fd				# i: image or qpoe  handle
char	type[ARB]			# i: type of history

begin
	call disp_history(fd, type, TY_IM)
end

#
# DISP_TABHISTORY -- display history records in an table file
#				(joan added 2/8/96)
procedure disp_tabhistory(fd, type)

pointer	fd				# i: table or qpoe  handle
char	type[ARB]			# i: type of history

begin
	call disp_history(fd, type, TY_TAB)
end

#
# DISP_HISTORY -- display history records
#
procedure disp_history(fd, type, itype)

pointer	fd				# i: image or qpoe  handle
char	type[ARB]			# type of history
int	itype				# i: image type - QPOE or IM

pointer	name1				# l: special name in hist record
pointer	name2				# l: name of special param
int	xhlookup()			# l: look for special parma

begin
	# print out history banner
	call printf("\n\t\t\tX-ray History\n\n")
	# see if we want only a special type of history
	if( xhlookup(type, name1, name2) == YES ){
	    # name2 has the name of the param we want to investigate
	    if( name2 !=0 ){
		call disp_sphistory(fd, Memc[name1], Memc[name2], itype)
		call mfree(name2, TY_CHAR)
	    }
	    else{
		call printf("no history records of type:\t%s\n")
		call pargstr(Memc[name1])
	    }
	    call mfree(name1, TY_CHAR)
	}
	else
	    call disp_allhistory(fd, itype)
end

#
# DISP_SPHISTORY -- display history of a special parameter
#
procedure disp_sphistory(fd, name1, name2, itype)

pointer	fd				# i: image or qpoe  handle
char	name1[ARB]			# i: name in hist of special
char	name2[ARB]			# i: name of special parameter
int	itype				# i: image type - QPOE or IM

char	sbuf[SZ_HLINE]			# l: special param value
char	hist[SZ_HLINE]			# l: history record
int	i				# l: loop counter
int	nhist				# l: number of special params
int	nchars				# l: returned by ctoi()
int	ip				# l: index for ctoi()
int	hrecs[MAX_HIST]			# l: special param reference numbers
int	qp_accessf()			# l: qp param access
int	qp_gstr()			# l: get param string
int	imaccf()			# l: im param access
int	ctoi()				# l: char to int
int	stridx()			# l: index into string
# joan added parnum 2/8/96
int	parnum				# l: holds output from tbhfkw()

begin
	switch(itype){
	case TY_QPOE:
	    # see if special parameter exists
	    if( qp_accessf(fd, name2) == NO ){
		call printf("no history records of type:\t%s\n")
		call pargstr(name1)
		return
	    }
	    else{
		# if so, get the current value
		nchars = qp_gstr(fd, name2, sbuf, SZ_HLINE)
	    }
	case TY_IM:
	    # see if special parameter exists
	    if( imaccf(fd, name2) == NO ){
		call printf("no history records of type:\t%s\n")
		call pargstr(name2)
		return
	    }
	    else{
		# if so, get the current value
		call imgstr(fd, name2, sbuf, SZ_HLINE)
	    }
     	case TY_TAB:	# joan added 2/8/96
	    # see if special parameter exists
	    call tbhfkw(fd, name2, parnum)
	    if( parnum == 0 ){
		call printf("no history records of type:\t%s\n")
		call pargstr(name1)
		return
	    }
	    else{
		# if so, get the current value
		call tbhgtt(fd, name2, sbuf, SZ_HLINE)
	    }

	}
	# pick out the x-ref numbers from the special param
	nhist = 1
	# start looking for reference numbers after the ":"
	ip = stridx(":", sbuf) + 1
	while( TRUE ){
	    nchars = ctoi(sbuf, ip, hrecs[nhist])
	    if( nchars ==0 ) break
	    if( i > MAX_HIST )
		# this shouldn't happen!
		call error(1, "too many special history records")
	    nhist = nhist + 1
	}
	# display all special history records
	nhist = nhist - 1
	do i=1, nhist{
	    call sprintf(sbuf, SZ_HLINE, HIST_FORMAT)
	    call pargi(hrecs[i])
	    switch(itype){
	    case TY_QPOE:
		# this shouldn't happen
		if( qp_accessf(fd, sbuf) == NO )
		    call errors(1, "missing parameter", sbuf)
		else{
		    nchars = qp_gstr(fd, sbuf, hist, SZ_HLINE)
	    	    call printf(DISP_FORMAT)
 		    call pargi(i)
		    call pargstr(hist)
		}
	    case TY_IM:
		if( imaccf(fd, sbuf) == NO )
		    call errors(1, "missing parameter", sbuf)
		else{
		    call imgstr(fd, sbuf, hist, SZ_HLINE)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(hist)
	        }
	    case TY_TAB: # joan added 2/8/96
		call tbhfkw(fd, sbuf, parnum)
		if( parnum == 0 )
		    call errors(1, "missing parameter", sbuf)
		else{
		    call tbhgtt(fd, sbuf, hist, SZ_HLINE)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(hist)
		}
	    }
	}
end

#
# DISP_ALLHISTORY -- display all history records
#
procedure disp_allhistory(fd, itype)

pointer	fd				# i: image or qpoe  handle
int	itype				# i: image type - QPOE or IM

char	hist[SZ_HLINE]			# l: history record
char	tbuf[SZ_HLINE]			# l: test history param name
int	i				# l: loop counter
int	nrecs				# l: number of history records
int	nchars				# l: number of chars read by qp_gstr
int	qp_accessf()			# l: qp param access
int	qp_gstr()			# l: get param string
int	qp_geti()			# l: get integer param
int	imgeti()			# l: get integer param
int	imaccf()			# l: im param access
# joan added these next two 2/8/96
int	tbhgti()			# l: get integer param
int	parnum				# l: holds tbhfkw() output

begin
	# get number of history records and increment
	switch(itype){
	case TY_QPOE:
	    if( qp_accessf(fd, X_NRECS) == NO )
		nrecs = 0
	    else
		nrecs = qp_geti(fd, X_NRECS)
	case TY_IM:
	    if( imaccf(fd, X_NRECS) == NO )
		nrecs = 0
	    else
		nrecs = imgeti(fd, X_NRECS)
	case TY_TAB: # joan added 2/8/96
	    call tbhfkw(fd, X_NRECS, parnum)
	    if ( parnum == 0 )
		nrecs = 0
	    else
		nrecs = tbhgti(fd, X_NRECS)
	}
	# make sure there are records
	if( nrecs == 0 ){
	    call printf("No history records available\n")
	    return
	}
	# display all history records
	do i=1,nrecs{
	    call sprintf(tbuf, SZ_HLINE, HIST_FORMAT)
	    call pargi(i)
	    switch(itype){
	    case TY_QPOE:
		if( qp_accessf(fd, tbuf) == NO )
		    call errori(1, "can't find hist record", i)
		else{
		    nchars = qp_gstr(fd, tbuf, hist, SZ_HLINE)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(hist)
		}
	    case TY_IM:
		if( imaccf(fd, tbuf) == NO )
		    call errori(1, "can't find hist record", i)
		else{
		    call imgstr(fd, tbuf, hist, SZ_HLINE)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(hist)
		}
	    case TY_TAB: # joan added 2/8/96
		call tbhfkw(fd, tbuf, parnum)
		if( parnum == 0 )
		    call errori(1, "can't find hist record", i)
		else{
		    call tbhgtt(fd, tbuf, hist, SZ_HLINE)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(hist)
		}
	    }
	}	
end

#
# XHLOOKUP -- lookup a name to see if it warrents special param processing
#
int procedure xhlookup(special, name1, name2)

char	special[ARB]			# i: possible special name
pointer	name1				# o: string going into hist param
pointer	name2				# o: special param name (x-ref param)

int	len				# l: length of special
int	got				# l: return value
pointer	s				# l: lower case of special
pointer	sp				# l: stack pointer
bool	streq()				# l: string compare
int	strlen()			# l: stringlength
int	abbrev()			# l: look for abbrev
int	max()				# l: find max value

begin
	# mark the stack
	call smark(sp)
	# init the pointers
	name1 = 0
	name2 = 0
	# convert special to upper case
	len = max(SZ_HLINE, strlen(special))
	call salloc(s, len+1, TY_CHAR)
	call strcpy(special, Memc[s], len)
	call strlwr(Memc[s])
	# assume we have a special param
	got = YES
	# check for special params
	if( streq("", special) )
	    got = NO
	# ignore a history param
	else if( abbrev("history", Memc[s]) >0 ){
	    got = NO
	}
	else if( abbrev("vignetting", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("vign", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
	    call strcpy("XS-VIGN", Memc[name2], len)
	}
	else if( abbrev("exposure", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("exp", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
	    call strcpy("XS-EXP", Memc[name2], len)
	}
	else if( abbrev("background", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("bkgd", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
	    call strcpy("XS-BKGD", Memc[name2], len)
	}
	else if( abbrev("bkgd", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("bkgd", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
	    call strcpy("XS-BKGD", Memc[name2], len)
	}
	else if( abbrev("user", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("user", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
	    call strcpy("XS-USER", Memc[name2], len)
	}
	else if( abbrev("TSI", Memc[s]) >0 ){
	    call calloc(name1, len, TY_CHAR)
	    call strcpy("TSI", Memc[name1], len)
	    call calloc(name2, len, TY_CHAR)
#	    call strcpy("", Memc[name2], len)
	}
	else{
	    # allocate name1, but not name2 (no x-ref param here)
	    call calloc(name1, len, TY_CHAR)
	    call strcpy(special, Memc[name1], len)
	}
	# release stack space
	call sfree(sp)
	# return the news
	return(got)
end

procedure del_history(qp)
pointer	qp
int	nrecs

int	i
pointer	sp
pointer	tbuf
int	qp_accessf()
int	qp_geti()
begin
        call smark(sp)
        call salloc(tbuf,SZ_HLINE,TY_CHAR)
	if( qp_accessf(qp, X_NRECS) == NO )
	    nrecs = 0
	else{
	    nrecs = qp_geti(qp, X_NRECS)
	    call qp_puti(qp,X_NRECS,0)
	}

	do i=1,nrecs
	{
            call sprintf(Memc[tbuf], SZ_HLINE, HIST_FORMAT)
                call pargi(i)
            if( qp_accessf(qp, Memc[tbuf]) == YES )
              call qp_deletef(qp,Memc[tbuf])
	}
	call sfree(sp)
end

procedure find_history(qp,nrecs)
pointer	qp
int	nrecs
int	qp_accessf()
int	qp_geti()
begin
	if( qp_accessf(qp, X_NRECS) == NO )
	    nrecs = 0
	else
	    nrecs = qp_geti(qp, X_NRECS)
end

procedure get_history(qp,i,hist)
pointer	qp
char 	hist[ARB] 
int	i

pointer	tbuf
pointer	sp
int	nchars
int	qp_gstr()
int	qp_accessf()
begin
	call smark(sp)
	call salloc(tbuf,SZ_HLINE,TY_CHAR)
        call sprintf(Memc[tbuf], SZ_HLINE, HIST_FORMAT)
            call pargi(i)
        if( qp_accessf(qp, Memc[tbuf]) == NO )
              call errori(1, "can't find hist record", i)
        else{
             nchars = qp_gstr(qp, Memc[tbuf], hist, SZ_HLINE)
#             call sprintf(buf,DISP_FORMAT,SZ_HLINE)
#                    call pargi(i)
#                    call pargstr(hist)
       }
	call sfree(sp)
end
