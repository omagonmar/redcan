#$Header: /home/pros/xray/ximages/qplist/RCS/qplist.x,v 11.0 1997/11/06 16:28:49 prosb Exp $
#$Log: qplist.x,v $
#Revision 11.0  1997/11/06 16:28:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:56  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/04  10:02:27  dvs
#Separated Einstein-specific TSI displaying routine.  (We should be
#calling disp_etsi instead of disp_tsi.)
#
#Revision 8.0  94/06/27  14:46:02  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/01  18:40:55  mo
#MC	2/1/94		Fix bug # 744 - move the event-destroy-compile
#			code INSIDE the if-display-events conditional
#
#Revision 7.0  93/12/27  18:27:15  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  17:09:57  mo
#MC	12/22/93	Fix bug that QPLIST can't count the correct
#			number of events requested (all gives 1 too many)
#
#Revision 6.1  93/07/02  14:34:33  mo
#MC	7/2/93		Fix boolean initializations to use FALSE (not NO)
#
#Revision 6.0  93/05/24  16:07:58  prosb
#General Release 2.2
#
#Revision 5.5  93/05/20  08:22:34  mo
#MC	5/20/93		Support OLD as well as NEW TSI formats, extend
#			REGIONS length to SZ_LINE
#
#Revision 5.4  93/05/13  15:30:48  mo
#MC	5/13/92		Update with GENERAL TSI display formats
#
#Revision 5.3  93/04/27  00:14:00  dennis
#Regions system rewrite.
#
#Revision 5.2  93/04/23  14:55:24  jmoran
#JMORAN - RATFITS GTI changes
#
#Revision 5.1  92/12/09  10:38:19  mo
#MC	11/10/92	Check for 'title' string before retrieving it
#			to prevent fatal error.
#
#Revision 5.0  92/10/29  21:27:30  prosb
#General Release 2.1
#
#Revision 4.2  92/10/16  20:27:35  mo
#MC	10/16/92		Fixed MAX_LONG overflow problems
#
#Revision 4.1  92/10/08  09:13:59  mo
#MC	10/8/92		Added first and last parameter for QPLIST 
#			event display and better qphead display
#
#Revision 4.0  92/04/27  14:31:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/10/02  14:01:32  mo
#MC	no changes
#
#Revision 3.0  91/08/02  01:17:47  prosb
#General Release 1.1
#
#Revision 2.3  91/07/21  19:05:14  mo
#MC	7/21/91		Remove special coded needed for 2.9.2 bug
#
#Revision 2.2  91/05/24  15:07:19  mo
#5/24/91	MC	Temporary fix to bypass setting a new mask if
#			FIELD or NONE was requested.  THis speeds things
#			up a lot, but needs to be done in a general
#			library way in set_Qpmask so all benefit.
#			This is prompted by the annoying propery that
#			this mask fails for PSPC timesorted QPOE files.
#
#Revision 2.1  91/03/22  15:50:40  pros
#No changes needed - error found in a library subroutine.  (MC)
#
#Revision 2.0  91/03/06  23:27:35  pros
#General Release 1.0
#
#
# Module:       QPLIST.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routine to display the contents of a PROS/QPOE file
# External:     qplist ( formerly qpdisp )
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version   1988
#               {1} MC    -- Updated for TSI records and name change -- 1/91
#               {2} MC    -- Added a call to destroycompile -- 2/91
#               {n} <who> -- <does what> -- <when>
#

include <qpset.h>
include <qpioset.h>
include <qpoe.h>
include <ext.h>
include <plhead.h>
include <mach.h>
include <einstein.h>

define SZ_EXPR 1024
define LEN_EVBUF 1024

procedure t_qplst()

char	poefile[SZ_PATHNAME]	# name of data file + event list
char	poeroot[SZ_PATHNAME]	# root data file name
char	region[SZ_LINE]		# region descriptor
char	expname[SZ_PATHNAME]	# exposure file name
char	table[SZ_PATHNAME]		# table name
char	temp[SZ_PATHNAME]		# temp table name
char	evlist[SZ_EXPR]		# event list specification
char	dmode[SZ_LINE]		# mode of plio display (zoom, etc.)
char	elements[SZ_LINE]	# elements of the event struct to display
char	tbuf[SZ_LINE*2]		# output buffer line

int	display
int	i, j			# loop counters
int	mval			# mask value returned by qpio_getevent
int	nev			# number of events returned by qpio_getevent
int	total      		# total photons
int	nodisp      		# number displayed
int	ntgr			# number of tgr records
int	ngti			# number of gti records
int	nblt			# number of blt records
int	ntsi			# number of tsi records
int	nchars
int	ncols			# number of columns to display
int	nrows			# rows to display
int	x1, y1, x2, y2		# rg_pldisp parameters
#int	nmacros			# list of event macros
int	ncomp			# number of compiled actions
int	qp_accessf()
int	tsisize
int	tsicnt

real	thresh			# exposure threshold
double	duration

pointer	qp			# qpoe handle
pointer io			# event list handle
pointer	pl			# pixel list handle (exposure-filtered region 
				#					mask)
pointer	qphead			# qpoe header pointer
pointer	qptgr			# qpoe tgr pointer
pointer	qpgti			# qpoe gti pointer
pointer filt
pointer	blist			# qpoe gti pointer
pointer	elist			# qpoe gti pointer
#pointer	range_list
pointer	qptsi			# qpoe tsi pointer
pointer	qpblt			# qpoe blt pointer
pointer	evl[LEN_EVBUF]		# event list buffer
pointer	sp
pointer	title			# (exposure-filtered region) mask title 
pointer	tsidescp
pointer	tsiptr
pointer tsistr
				#			from set_qpmask
#pointer	msymbols		# pointer to array of macro names
#pointer	mvalues			# pointer to array of macro values
pointer	name			# array of names of elements to display
pointer	comp			# array of action routines for display
pointer	offset			# array of offsets for elements
pointer	type			# array of types for elements

bool	dodisp			# display?
bool	doheader		# display header?
bool	doevents		# display events?
bool	domask			# display mask?
bool	docmask			# display composite mask?
bool	dotgr			# display tgr recs?
bool	dogti			# display gti recs?
bool	dotsi			# display tsi recs?
bool	doblt			# display blt recs?
bool	dohist			# display history?
bool	merge
bool	mklst

# table variables
bool	clobber			# clobber old table file
int	dotable			# flag that a table file is required
pointer tp			# table pointer
pointer	cp

# action routines for the event compiler
extern s_disp(), i_disp(), l_disp(), r_disp(), d_disp(), x_disp()

bool	streq()			# string compare
bool	strne()			# string compare
bool	clgetb()		# get boolean
bool	ck_none()		# test for NONE in file name
int	qpio_getevents()	# get qpoe events
int	clgeti()		# get int param
int	rg_none()		# test for NULL (none or field ) region
int	first,bloop
int	last,eloop
real	clgetr()		# get real cl param
pointer	qp_open()		# open a qpoe file
pointer	qpio_open()		# open a qpio event list
int     qp_gstr()               #  get param string

bool	answer
char    stdgti_str[SZ_LINE]
char    allgti_str[SZ_LINE]
char    oldgti_str[SZ_LINE]

begin
	# get parameters
	call smark(sp)
#	call salloc(range_string,SZ_PATHNAME,TY_CHAR)
	call clgstr("qpoe", poefile, SZ_PATHNAME)
	call clgstr("region",region, SZ_LINE)
	call clgstr("elements", elements, SZ_PATHNAME)
	first = clgeti("firstevent")
	if( first <= 0 )
	     first = 1
	last = clgeti("lastevent")
	if( last <= 0 )
	    last = MAX_LONG - 1  #  so adding a 1 later won't cause overflow 
#				    to negative numbers
#	call clgstr("rows",Memc[range_string],SZ_PATHNAME)
#        if (decode_ranges (Memc[range_string], ranges, MAX_RANGES, nvalues) 
#		!= OK)
#	     call error (1, "bad range of row numbers (event numbers)")
	call clgstr("exposure", expname, SZ_PATHNAME)
	call rootname(poefile, expname, EXT_EXPOSURE, SZ_PATHNAME)
	if( strne(expname, "NONE") ){
	    thresh = clgetr("expthresh")
	    if( thresh < 0.0 )
	        call error(1, "exposure threshold must be >=0")
	}
	else
	    thresh = -1.0

	# get display parameter
	display = clgeti("display") 
	if( display >0 )
	    dodisp = true
	else
	    dodisp = false

	doevents = clgetb("events")
	if( dodisp ){
	    doheader = clgetb("header")
	    dohist = clgetb("history")
	    dotgr = clgetb("tgr")
	    dogti = clgetb("gti")
	    dotsi = clgetb("tsi")
	    doblt = clgetb("blt")
	    domask = clgetb("mask_headers")
	    docmask = clgetb("composite_mask")
	    if( docmask  ){
	        call clgstr("disp_mode", dmode, SZ_LINE)
	        ncols = clgeti("ncols")
	        nrows = clgeti("nrows")
	        # get the plio display limits
	        call get_plims(dmode, x1, x2, y1, y2)
	    }
	}

	# if we do events, get the output table file
	if( doevents )
	    call clgstr("table", table, SZ_PATHNAME)
	else
	    call strcpy("NONE", table, SZ_PATHNAME)

	# make sure we are doing something!
	if( !dodisp && streq(table, "NONE") )
	    call error(1, "cannot have no display and no table")

	# see if we are making a table file
	call rootname(poefile, table, EXT_QPDISP, SZ_PATHNAME)
	if( streq("NONE", table) )
		dotable = NO
	else{
		clobber = clgetb ("clobber")
		dotable = YES
	}
	call clobbername(table, temp, clobber, SZ_PATHNAME)

	# separate poefile into a root file and an event list spec
	call qpparse(poefile, poeroot, SZ_PATHNAME, evlist, SZ_EXPR)

	# open the qpoe file
	qp = qp_open(poeroot, READ_ONLY, NULL)

	# read qpoe header
        call get_qphead(qp, qphead)

	if( doheader || dogti ){
	    call get_qpexp(qp,evlist,display,blist,elist,ngti,duration)
	    QP_EXPTIME(qphead) = duration
	}

	# display header, if necessary
	if( dodisp && doheader ){
	    call calloc(title,SZ_LINE,TY_CHAR)
            if( qp_accessf(qp, "title") == NO )
		call strcpy("NO TITLE",Memc[title],SZ_LINE)
	    else
                nchars = qp_gstr(qp, "title", Memc[title], SZ_LINE)
	    call disp_qphead(qphead,Memc[title],display)
	    call mfree(title,TY_CHAR)
	}

	# display history, if necessary
	if( dodisp && dohist )
	    call disp_qphistory(qp, "hist")

	# display all plio mask headers, if necessary
	if( dodisp && domask )
	    call disp_qpmask(qp, 0)

	# display composite mask, if necessary
	if( dodisp && docmask )
	    call disp_qpcomposite(qp, ncols, nrows, x1, x2, y1, y2)

	# display tgr, if necessary
	if( dodisp && dotgr ){
	    call get_qptgr(qp, qptgr, ntgr)
	    call disp_qptgr(qptgr, ntgr, QP_INST(qphead))
	}

	# display gti, if necessary
	if( dodisp && dogti ){
	    merge=FALSE
	    mklst=FALSE
	    call output_timfilt (Memd[blist], Memd[elist], ngti, "%.7f", 
				 1,filt, merge, mklst)
	    call mfree(filt,TY_CHAR)
	}

	# display gti, if necessary
	if (dodisp)
	{
           call clgstr("stdgti_name", stdgti_str, SZ_LINE)
           call clgstr("allgti_name", allgti_str, SZ_LINE)
           call clgstr("oldgti_name", oldgti_str, SZ_LINE)

	   answer = false
	   answer = clgetb("stdgti_bool")
	   if (answer)
	   {
              if (qp_accessf(qp, stdgti_str) == YES)
	      {
	         call printf("\nSELECTION: STANDARD GTI\n\n")
	         call get_qpgti(qp, qpgti, ngti, stdgti_str)
	         call disp_qpgti(qpgti, ngti, QP_INST(qphead))
	         call mfree(qpgti, TY_STRUCT)
	      }
	      else
	      {
	         call printf("No standard GTIs found\n")
	      }
	   }

           answer = false
           answer = clgetb("allgti_bool")
           if (answer)
           {
              if (qp_accessf(qp, allgti_str) == YES)
              {
                 call printf("\nSELECTION: ALL GTI\n\n")
                 call get_qpgti(qp, qpgti, ngti, allgti_str)
                 call disp_qpgti(qpgti, ngti, QP_INST(qphead))
                 call mfree(qpgti, TY_STRUCT)
              }
              else
              {
                 call printf("No all GTIs found\n")
              }
           }

           answer = false
           answer = clgetb("oldgti_bool")
           if (answer)
           {
              if (qp_accessf(qp, oldgti_str) == YES)
              {
                 call printf("\nSELECTION: OLD GTI\n\n")
                 call get_qpgti(qp, qpgti, ngti, oldgti_str)
                 call disp_qpgti(qpgti, ngti, QP_INST(qphead))
                 call mfree(qpgti, TY_STRUCT)
              }
              else
              {
                 call printf("No old GTIs found\n")
              }
           }



	}

	# display tsi, if necessary
	if( dodisp && dotsi ){

            # special case Einstein
            if ( QP_MISSION(qphead) == EINSTEIN)
            {
                call get_tsi(qp, QP_INST(qphead), qptsi, ntsi) 
                call disp_etsi(qptsi, ntsi, qphead)
                call mfree(qptsi,TY_STRUCT)
            }
	    else # non-Einstein, Rev >=1 or unknown mission
	    if( QP_REVISION(qphead) >= 1 || QP_MISSION(qphead) == 0 )
	    {
	        call get_gtsi(qp, "TSI", tsistr, tsiptr, tsicnt, tsisize, 
			      qptsi, tsidescp, ntsi)
	       	call disp_gtsi(P2S(qptsi), ntsi, QP_INST(qphead),Memc[tsistr],tsisize)
#	       	call disp_gtsi(qptsi, ntsi, QP_INST(qphead),Memc[tsistr],tsisize)
		call mfree(qptsi,TY_STRUCT)

	    }
	    else # non-Einstein, Rev==0 
	    {
	        call get_tsi(qp, QP_INST(qphead), qptsi, ntsi) 
	        call disp_tsi(qptsi, ntsi, QP_INST(qphead))
		call mfree(qptsi,TY_STRUCT)
	    }
	    call mfree(tsistr,TY_CHAR)
#	    call mfree(tsidescp,TY_STRUCT)
	    call mfree(tsiptr,TY_STRUCT)
	}

	# display blt, if necessary
	if( dodisp && doblt ){
	    call get_qpbal(qp, qpblt, nblt)
	    call disp_qpbal(qpblt, nblt, QP_INST(qphead))
	}

	# display events, if necessary
	if( doevents ){

	# compile display actions for the event elements we want to display
	call ev_qpcompile(qp, elements, name, comp, offset, type, ncomp,
		      s_disp, i_disp, l_disp, r_disp, d_disp, x_disp)

	# open the event list
	io = qpio_open(qp, evlist, READ_ONLY)

	# reset the event mask if a mask specified
	if( rg_none(region) == NO || !ck_none( expname) ){
	    call set_qpmask(qp, io, NULL, region, expname, thresh, pl, title)

	# display the header
	    if( dodisp )
	        call msk_disp("qplist mask", poefile, Memc[title])
#           call rg_pldisp(pl, 80, 80, -1, -1, -1, -1)
#  This is duplicated from set_qpmask, due to some obscure bug that causes
#	it to be forgotten
#	    call qpio_seti(io,QPIO_PL,pl)
	}

	# open the table file, if necessary
	if( dotable == YES ){
	    # and fill in the columns
	    call qpd_inittable(temp, tp, cp, name, type, ncomp)
	    # write header into table
	    call put_tbhead(tp, qphead)
	}

	# print out a nice header
	if( dodisp ){
	    tbuf[1] = EOS
	    call qpd_header(name, type, ncomp, tbuf, SZ_LINE*2)
	    call printf("\n%s\n")
	    call pargstr(tbuf)
	    call flush(STDOUT)
	}

	# get all photons through the region mask	
	total = 0
	nodisp = 0
	nev = 0

#         stat = get_next_number (ranges, rownum)     # get first row number
#         done = (stat == EOF) || (total > nev)
	while (qpio_getevents (io, evl, mval, LEN_EVBUF, nev) != EOF && 
		total < last) {
	    # display this batch of photons
	    bloop = max( 1, first - total )    
#	    eloop = min( nev, last - total +1)    
	    eloop = min( nev, last - total)    
	    if( eloop >= bloop) {
	    do j = bloop, eloop{
		# clear the display string
		tbuf[1] = EOS
		# loop through elements, adding to string and
		# outputting to table
		do i=1, ncomp{
		    call zcall9(Memi[comp+i-1], Memi[offset+i-1],
				tp, Memi[cp+i-1], dotable, evl[j], total+j,
				tbuf, SZ_LINE*2, dodisp)
#         	    stat = get_next_number (ranges, rownum)
# 	            done = (stat == EOF) || (total > nev)
		}
		if( dodisp ){
		    # print string we just made
		    call printf("%s\n")
		    call pargstr(tbuf)
		    call flush(STDOUT)
		}
		nodisp = nodisp + 1
	    }
	    }
	    # inc the total
	    total = total + nev
	}
	if( dodisp ){
	    # print out total number of photons
	    call printf("\ntotal:\t%d\n")
	    call pargl(nodisp)
	}

	# close (and rename) table file, if necessary
	if( dotable == YES ){
	    call tbtclo(tp)
	    call finalname(temp, table)
	}

	# close the event list and pl
	call pl_close(pl)
	call qpio_close(io)
#	call  ev_destroylist(msymbols, mvalues, nmacros)
        call ev_destroycompile(name, comp, offset, type, ncomp) 

	}	# if( doevents ) ...

	# close the qpoe file
	call qp_close(qp)

	# and free all space
	call mfree(title, TY_CHAR)
	call mfree(qphead, TY_STRUCT)
	call mfree(cp, TY_POINTER)
	if( dotgr )
	    call mfree(qptgr, TY_STRUCT)
	if( dogti || doheader){
	    call mfree(blist, TY_DOUBLE)
	    call mfree(elist, TY_DOUBLE)
	}
	if( doblt )
	    call mfree(qpblt, TY_STRUCT)
	call sfree(sp)
end

