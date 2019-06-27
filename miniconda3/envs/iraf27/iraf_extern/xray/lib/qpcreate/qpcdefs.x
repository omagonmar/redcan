#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcdefs.x,v 11.0 1997/11/06 16:21:54 prosb Exp $
#$Log: qpcdefs.x,v $
#Revision 11.0  1997/11/06 16:21:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:04  prosb
#General Release 2.2
#
#Revision 5.3  93/04/26  23:57:00  dennis
#Regions system rewrite.
#
#Revision 5.1  93/04/19  23:38:40  dennis
#*** empty log message ***
#
#Revision 5.0  92/10/29  21:18:34  prosb
#General Release 2.1
#
#Revision 4.1  92/10/05  14:52:13  jmoran
#JMORAN  big changes:  shift buffer changes to accomodate FULL event
#>>      definintion..
#
#Revision 4.0  92/04/27  13:51:54  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  12:06:17  mo
#MC	4/13/92		Separate the uses of TITLE.  TITLE should
#			be only for QPOE file TITLE, new REGSUM will
#			be for the so-called 'title' string retrieved
#			from a region mask - the ascii region descriptor
#			This ripples through the other 'qpcreate' type
#			tasks
#
#Revision 3.1  92/04/09  19:41:13  mo
#MC	4/9/92		Skip set_qpmask code if input region is NONE or NULL
#			to get around the IRAF bug that can't do PL files
#			on unsorted PSPC qpoe files ( 15360 x 15360 )
#
#Revision 3.0  91/08/02  01:05:14  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  21:52:16  mo
#MC	8/1/91		Temporary work-around for 2.9.2 now eliminated
#
#Revision 2.0  91/03/07  00:10:43  pros
#General Release 1.0
#
#
#	QPCDEFS.X -- default procedures for qpoe to qpoe tasks
#

include <qpset.h>
include <qpioset.h>
include <qpoe.h>
include <ext.h>
include <qpc.h>

include "qpcreate.h"

# define number of events we read at once
define SZ_EVBUF	512
#  This stollen form ../qpcreate/rgcreate for now
define SZ_PLHEAD 8192	

#
# DEF_ALLOC -- allocate def arrays
#
procedure def_alloc(argv)

pointer	argv			# i: argument list

begin
	call calloc(REGIONS(argv), SZ_LINE, TY_CHAR)
	call calloc(TITLE(argv), SZ_EXPR, TY_CHAR)
	call calloc(EXPOSURE(argv), SZ_PATHNAME, TY_CHAR)
	# REGSUM(argv) is alloced in setmask()
	call calloc(REGSUM(argv), SZ_EXPR, TY_CHAR)

end

#
# DEF_FREE -- allocate def arrays
#
procedure def_free(argv)

pointer	argv			# i: argument list

begin

	call mfree(REGIONS(argv), TY_CHAR)
	call mfree(TITLE(argv), TY_CHAR)
	call mfree(EXPOSURE(argv), TY_CHAR)
	call mfree(REGSUM(argv), TY_CHAR)

end

#
# DEF_GETPARAM -- get region and exposure parameters
#
procedure def_getparam(ifile, argv)

char	ifile[ARB]		# i: input file name
pointer	argv			# o: argument list pointer
bool	strne()			# l: string compare
real	clgetr()		# l: get real param

begin

	# get region
	call clgstr("region", Memc[REGIONS(argv)], SZ_LINE)
	# get exposure information
	call clgstr("exposure", Memc[EXPOSURE(argv)], SZ_PATHNAME)
        call rootname(ifile, Memc[EXPOSURE(argv)], EXT_EXPOSURE, SZ_PATHNAME)
	# get exposure threshold, if necessary
	if( strne(Memc[EXPOSURE(argv)], "NONE") ){
	    THRESH(argv) = clgetr("expthresh")
	    if( (THRESH(argv) < 0.0) || (THRESH(argv) > 100.0) )
	        call error(1, "exposure threshold must be 0.0 <= t <= 100.0")
	}

end

#
# DEF_OPEN -- open a qpoe file and an event list through a region and
#		an exposure file
#
procedure def_open(fname, fd, inrecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	inrecs				# o: number of events in qpoe file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

char	poeroot[SZ_PATHNAME]		# l: root data file name
char	evlist[SZ_EXPR]			# l: event list expression
char	datatype[SZ_DATATYPE]		# l: from qp_queryf
char	comment[SZ_COMMENT]		# l: from qp_queryf
int	maxelem				# l: from qp_queryf
int	flags				# l: from qp_queryf

bool    ck_none()               # test for NONE in file name
int     rg_none()               # test for NULL (none or field ) region
int	qp_queryf()			# l: qp_queryf
pointer	qp_open()			# l: open a qpoe file
pointer	qpio_open()			# l: open a qpio event list

begin
	# separate input poefile into a root file and an event list spec
	call qpparse(fname, poeroot, SZ_PATHNAME, evlist, SZ_EXPR)
	# open the input qpoe file
	fd[1] = qp_open(poeroot, READ_ONLY, NULL)
	# open the event list - the "events" list defaults to "event" type
	fd[2] = qpio_open(fd[1], evlist, READ_ONLY)
	# set up new mask, if necessary -- but
        #     Don't set a mask of region is not specified
        if( rg_none( Memc[REGIONS(argv)] ) == NO || 
 	   !ck_none( Memc[EXPOSURE(argv)] ) ){
	    call set_qpmask(fd[1], fd[2], NULL, Memc[REGIONS(argv)], 
			    Memc[EXPOSURE(argv)], THRESH(argv), fd[3], 
			    REGSUM(argv))
	}
	else
	    fd[3] = -1
	# display the header, if necessary
	if( display >1 )
	  call msk_disp("", fname, Memc[REGSUM(argv)])
	# we set inrecs to the total number of photons in the file
	# but we may get less through the filter/mask
	inrecs = qp_queryf(fd[1], "events", datatype, maxelem, comment, flags)
	# get the qpoe header
	call get_qphead(fd[1], qphead)
end

#
#  DEF_CLOSE -- close the plio, qpio and qp "files"
#  we just call reg_close
#
procedure def_close(fd, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	# close the plio, qpio and qp "files"
	call reg_close(fd, qphead, display, argv)
end

#
# DEF_GET -- read the input events and create an output events
#
procedure def_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
int	evsize				# i: size of output qpoe record
int	convert				# i: data conversion flag
pointer	sbuf				# o: event pointer
int	get				# i: number of events to get
int	got				# o: number of events got
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	i				# l: loop counter
int	mval				# l: mask from qpio_getevent
int	nev				# l: number of events returned
int	evlen				# l: number of shorts to move
int	try				# l: number of events to try this time
int	size				# l: padded size of a qpoe record
pointer	evl[SZ_EVBUF]			# l: event pointer from qpio_getevent
pointer	ev				# l: pointer to current output record

int	qpio_getevents()		# l: get qpoe events

begin
	#------------------------------------------------------------
	# determine the number of shorts we move from input to output
	#------------------------------------------------------------
	call qpc_movelen(fd[1], evsize, evlen)
	
	#----------------------------------------------------
	# determine the padded record size of the qpoe record
	#----------------------------------------------------
	call qpc_roundup(evsize, size)

	#----------------------------------------------
	# get photons until we have enough or until EOF
	#----------------------------------------------
	got = 0
	while (got < get)
	{
	    #-----------------------------
	    # get the next batch of events
	    #-----------------------------
	    try = min(SZ_EVBUF, get-got)

	    if (qpio_getevents(fd[2], evl, mval, try, nev) != EOF)
	    {
	        #-----------------------
		# move the event records
		#-----------------------
		do i = 1, nev 
		{
		    #--------------------------------
		    # point to current record in sbuf
		    #--------------------------------
		    ev = sbuf + (got*size)

		    #---------------------
		    # inc number of events
                    #---------------------
		    got = got+1

	            #---------------------------------------------------
		    # if instrument is PSPC and events are large_to_full
		    # or full_to_large, shift the events
		    #---------------------------------------------------
		    if (IN_L_TO_F(argv) || IN_F_TO_L(argv))
		    {
		       call def_shift(evl[i], ev, argv)
		    }
		    else
		    {
#		       call amovs(Mems[evl[i]], Mems[ev], evlen)
		       call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
					evl[i], ev)
		    }


		    #---------------------------------------
		    # insert the region number, if necessary
		    #---------------------------------------
		    call qpc_putregion(ev, mval)
		}
	    }
	    else
		break
	}
end


procedure def_shift(in_buf, out_buf, argv)

pointer	in_buf
pointer out_buf
pointer argv

begin

#---------------------------------------------------------------------
# Move from the input buffer to the output buffer the number of shorts
# up till the dx/dy or detx/dety  value in the event structure
#---------------------------------------------------------------------
	call amovs(Mems[in_buf], Mems[out_buf], IB_START(argv))
	
#-----------------------------------------------------------------
# Move from input buffer (at the input buffer start offset) to the
# output buffer (at the output buffer start offset) the number
# of shorts contained in the variable SWAP_LEN
#-----------------------------------------------------------------
	call amovs(Mems[in_buf  + IB_START(argv)], 
		   Mems[out_buf + OB_START(argv)], SWAP_LEN(argv))
end


#----------------------
# called from qp_create
#----------------------
procedure def_init_shift(out_msym, out_mval, out_mnum, argv)

pointer	out_msym
pointer out_mval
pointer	out_mnum
pointer argv
int	type
int	status

int	ev_lookuplist()
int	sizeof()

begin
	
#-----------------------------------------
# if shifting from PROS_LARGE to PROS_FULL
#-----------------------------------------
	if (IN_L_TO_F(argv))
	{
           #------------------------------------------------------------
           # Get the offset of the "DX" value from the INPUT event
           # macros and store it in INPUT buffer start variable IB_START
           #------------------------------------------------------------
	   status = ev_lookuplist("dx", IN_MSYM(argv), IN_MVAL(argv), 
			          IN_MNUM(argv), type, IB_START(argv))

           #-------------------------------------------------------------
           # Get the offset of the "DETX" value from the OUTPUT event
           # macros and store it in OUTPUT buffer start variable OB_START
           #-------------------------------------------------------------
	   status = ev_lookuplist("detx", out_msym, out_mval,
                                  out_mnum, type, OB_START(argv))
	}

#-----------------------------------------
# if shifting from PROS_FULL to PROS_LARGE
#-----------------------------------------
        if (IN_F_TO_L(argv))
        {
	   #------------------------------------------------------------
	   # Get the offset of the "DETX" value from the INPUT event
	   # macros and store it in INPUT buffer start variable IB_START
           #------------------------------------------------------------
           status = ev_lookuplist("detx", IN_MSYM(argv), IN_MVAL(argv),
                                  IN_MNUM(argv), type, IB_START(argv))

           #-------------------------------------------------------------
           # Get the offset of the "DX" value from the OUTPUT event
           # macros and store it in OUTPUT buffer start variable OB_START
           #-------------------------------------------------------------
           status = ev_lookuplist("dx", out_msym, out_mval,
                                  out_mnum, type, OB_START(argv))
        }

#-----------------------------------------------------------------
# The number of shorts that "dx and dy" or "detx and dety" take up
#-----------------------------------------------------------------	
	SWAP_LEN(argv) = (2 * sizeof(type))/SZ_SHORT
end

#
#  DEF_FINALE -- final procedure for qpcreate
#	add x_mask param
#
procedure def_finale(fd, qp, io, convert, qphead, display, argv)

int	fd[MAX_ICHANS]			# i: file descriptor
pointer	qp				# o: qpoe handle
pointer	io				# i: pointer to event list
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

include "qpcreate.com"

begin
	# put the mask header to the qpoe file
	# update the composite mask ( if fd[3] == 0, then no mask set)
	if( REGSUM(argv) !=0 && fd[3] >= 0 ){
	    call put_qpmask(qp, Memc[REGSUM(argv)])	
	    call update_qpcomposite(qp, fd[3], Memc[REGIONS(argv)])
	}
end

#
#  DEF_NOPUT -- a default routine to do a no-op for a put
#
procedure def_noput()

begin
	return
end
