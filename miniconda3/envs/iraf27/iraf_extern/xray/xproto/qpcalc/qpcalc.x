#$Header: /home/pros/xray/xproto/qpcalc/RCS/qpcalc.x,v 11.0 1997/11/06 16:38:56 prosb Exp $
#$Log: qpcalc.x,v $
#Revision 11.0  1997/11/06 16:38:56  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:26:38  prosb
#General Release 2.4
#
#Revision 8.1  1995/02/24  14:28:31  mo
#MC	2/24/95		Fixed to call evsize rather than evosize
#			(based on DVS's earlier changes to
#			 eventdef code)
#
#Revision 8.0  1994/06/27  17:26:06  prosb
#General Release 2.3.1
#
#Revision 7.2  94/03/30  11:18:07  mo
#MC	3/30/94		Add error trap for case of NEW datatype which
#			is too big for specified eventdef
#
#Revision 7.1  94/03/25  12:34:16  mo
#MC	3/25/94		Updated to work for all datatypes, write history
#			and update GTI's
#
#Revision 7.0  93/12/27  18:50:59  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:11:49  mo
#Initial revision
#
#
#
# QPCALC -- calculate a qpoe event-element attribute 
#

include <iraf.h>
include <mach.h>
include <math.h>
include <qpoe.h>
include <qpc.h>
include	<fset.h>
include <fset.h>
 
#define	SZ_BUF	1024
define QPC_FATAL 1

# the first part of argv is defined in qpc.h
# define the other parts of argv we will need
define	SZ_ARGV		SZ_DEFARGV+12
define	EQUALS		Memi[$1+SZ_DEFARGV+1]	# equation for calcuation
define	OUTNAME		Memi[$1+SZ_DEFARGV+2]	# output column name
define	CLC_INIT	Memi[$1+SZ_DEFARGV+3]   # initialization flag
define	PROSDEF		Memi[$1+SZ_DEFARGV+5]	# PROS event definition string
define	PCODE		Memi[$1+SZ_DEFARGV+6]	# pointer to comilation
define	CTYPE		Memi[$1+SZ_DEFARGV+7]   # requested output column type
define	INCTYPE		Memi[$1+SZ_DEFARGV+8]   # internal output column type
define	BLIST		Memi[$1+SZ_DEFARGV+9]
define  ELIST 		Memi[$1+SZ_DEFARGV+10]
define  EVLIST		Memi[$1+SZ_DEFARGV+11]
#
#  T_QPCALC-- main task to copy a qpoe file
#
procedure t_qpcalc()

pointer	argv				# user argument list
int	fstati()

begin
	# init the driver arrays
        if (fstati (STDOUT, F_REDIR) != YES)
            call fseti(STDOUT, F_FLUSHNL, YES)
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv, SZ_ARGV, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	call clc_alloc(argv)
	# load the drivers and allocate argv space
	call clc_load()
	# call the convert task
	call qp_create(argv)
	call pclc_free(argv)
	# free the driver arrays and argv
	call qpc_free()
	call def_free(argv)
	# free the argv space
	call mfree(argv, TY_INT)
end

#
#  CLC_ALLOC -- Allocate additional special QPCALC ARGV space
#
procedure clc_alloc(argv)
pointer	argv
begin
	call calloc(EQUALS(argv),SZ_LINE,TY_CHAR)
	call calloc(OUTNAME(argv),SZ_LINE,TY_CHAR)
	call calloc(PROSDEF(argv),SZ_LINE,TY_CHAR)
end
#
#  CLC_FREE -- Free additional special QPCALC ARGV space
#
procedure pclc_free(argv)
pointer	argv
begin
	call mfree(EQUALS(argv),TY_CHAR)
	call mfree(OUTNAME(argv),TY_CHAR)
	call mfree(PROSDEF(argv),TY_CHAR)
	call vex_free(PCODE(argv))
end
#
#  CALC_LOAD -- load driver routines
#
procedure clc_load()

extern	clc_open(), clc_get(), def_close()
extern	clc_getparam(), clc_hist()

# shared with clc_get
#int	xoffset, yoffset	# x, y offsets
#int	xtype, ytype		# x, y data type
# int	rotinit			# flag we have determined the x, y offsets
#common/rotcom/rotinit, xoffset, yoffset, xtype, ytype

begin
	# load the event drivers
	call qpc_evload("input_qpoe", ".qp", clc_open, clc_get, def_close)
	# load getparam routine
	call qpc_parload(clc_getparam)
	# load history routine
	call qpc_histload(clc_hist)
	# flag we have no x,y offsets
#	rotinit = NO
end

#
# CLC_GETPARAM -- get region parameter for qprotate
#
procedure clc_getparam(ifile, argv)

char	ifile[ARB]		# input file name
pointer	argv			# argument list pointer

begin
	# get standard params
	call def_getparam(ifile, argv)
	# get special qprotate params
	call clgstr("outname",Memc[OUTNAME(argv)],SZ_LINE)
	call strlwr(Memc[OUTNAME(argv)])
	call clgstr("equals",Memc[EQUALS(argv)],SZ_LINE)
	CLC_INIT(argv) = NO
end

#
# CLC_HIST -- write history (and a title) to qpoe file
#
procedure clc_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
int	nmacros
int	ngti
pointer	buf				# l: history line
pointer	msymbols
pointer mvalues
pointer	sp				# l: stack pointer
int	strlen()			# l: string length
bool	streq()				# l: string compare

begin
	# mark the stack
	call smark(sp)
	# allocate a string long enough
	len = strlen(Memc[file[1]])+
	      strlen(Memc[REGIONS(argv)])+
	      strlen(Memc[EXPOSURE(argv)])+
	      strlen(qpname)+
	      SZ_LINE
	call salloc(buf, len, TY_CHAR)

	# make a history comment
	if( streq("NONE", Memc[EXPOSURE(argv)]) ){
#	    call sprintf(Memc[buf], len, "%s (%s; no exp.; angle=%.2f) -> %s (angle=%.2f)")
	    call sprintf(Memc[buf], len, "%s (%s; no exp.) -> %s")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(qpname)
	}
	else{
#	    call sprintf(Memc[buf], len, "%s (%s; %s %.2f; angle=%.2f) -> %s (angle=%.2f)")
	    call sprintf(Memc[buf], len, "%s (%s; %s ) -> %s ")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(Memc[EXPOSURE(argv)])
	    call pargr(THRESH(argv))
	    call pargstr(qpname)
	}
	# display, if necessary
	if( display >0 ){
	    call printf("\n%s\n")
	    call pargstr(Memc[buf])
	}
	# write the history record
	call put_qphistory(qp, "qpcalc", Memc[buf], "")
	    call sprintf(Memc[buf], len, "%s = %s")
	    call pargstr(Memc[OUTNAME(argv)])
	    call pargstr(Memc[EQUALS(argv)])
	call put_qphistory(qp, "qpcalc", Memc[buf], "")

	# Get the new EVENT definition
	#  If this string is empty, we can build it from the 
	#	msymbols/mvalues that QPCREATE stored in common
	#  If we've modified it ourselves, we have all we need
	if( Memc[PROSDEF(argv)] == EOS )
	    call qpc_mklst(Memc[PROSDEF(argv)])
        call ev_crelist(Memc[PROSDEF(argv)],msymbols,mvalues,nmacros)
        call ev_wrlist(qp,msymbols,mvalues,nmacros)
        call ev_qpput(qp,Memc[PROSDEF(argv)])
        call ev_destroylist(msymbols, mvalues, nmacros)

	if( streq(Memc[OUTNAME(argv)],"time") )
  	    call vex_evalflt(qp,Memc[EVLIST(argv)],qphead,display,PCODE(argv),
			 BLIST(argv),ELIST(argv),ngti)
	call mfree(EVLIST(argv),TY_CHAR)
	call mfree(BLIST(argv),TY_DOUBLE)
	call mfree(ELIST(argv),TY_DOUBLE)
	# free up stack space
	call sfree(sp)
end

#
# CLC_OPEN -- open a qpoe file and an event list through a region
#		and determine some constant quantities for the qpcalc
#
procedure clc_open(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list
pointer	poeroot

begin
	# first perform the usual open
	call def_open(fname, fd, irecs, convert, qphead, display, argv)
# Here we must call qp_parse again since evlist is used below in 
# the code and def_open doesn't return it.  
#---------------------------------------------------------------
	call calloc(EVLIST(argv),SZ_EXPR,TY_CHAR)
	call calloc(poeroot,SZ_PATHNAME,TY_CHAR)
        call qp_parse(fname, Memc[poeroot], SZ_PATHNAME, Memc[EVLIST(argv)], SZ_EXPR)
	call mfree(poeroot,TY_CHAR)
end

define SZ_EVBUF	1024

#
# CLC_GET -- read the next input event and create an output event
#
procedure clc_get(fd, size, convert, sbuf, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]		# i: file descriptor
int	size			# i: size of output qpoe record
int	convert			# i: data conversion flag
pointer	sbuf			# o: event pointer
int	get			# i: number of events to get
int	got			# o: number of events got
pointer	qphead			# i: header
int	display			# i: display level
pointer	argv			# i: pointer to arg list

bool	new

int	coltype
int	i			# l: loop counter
int	ievlen,ievsize
int	exptype
int	offset
int	mval			# l: mask from qpio_getevent
int	ncomp
int	nev			# l: number of events returned
#int	evlen			# l: number of shorts to move
int	try			# l: number of events to try this time
# array of addresses of QPIO events
int	evl[SZ_EVBUF]		# l: event pointer from qpio_getevent

char	scoltype[10]

pointer	ev			# l: pointer to current output record
pointer evv			# l: pointer to new column values

int	qpio_getevents()	# l: get qpoe events
int	qpc_lookup()		# l: look up an event element name
pointer	vex_compile()

include	"qpcalc.com"
extern	qpevvar
pointer name,comp,eoffset,etype
extern  s_disp, i_disp, l_disp, r_disp, d_disp, x_disp

begin
	if( CLC_INIT(argv) == NO )
	{
	# get new output file event attribute list
	    call qpc_mklst(Memc[PROSDEF(argv)])
	    if( qpc_lookup(Memc[OUTNAME(argv)], coltype, offset) == NO )
	    {
		new = TRUE
		call clgstr("datatype",scoltype[1],10)
		call ev_adddef(Memc[OUTNAME(argv)],scoltype,Memc[PROSDEF(argv)],				coltype,offset,display)
	    }
	    else
	    {
		new = FALSE   # column already specified in output format
	    }
	    PCODE(argv) = vex_compile(Memc[EQUALS(argv)])
	    CTYPE(argv) = coltype
	    # determine the number of shorts we move from input to output
	    ievsize = 0   #  force full input len
	    call qpc_movelen(fd[1], ievsize, ievlen)
	    call qpc_roundup(ievlen, ievlen)
	    call ev_size(Memc[PROSDEF(argv)], size)
	    #  Readjust 'get' if output format is BIGGER that earlier 
	    #		thought - set evsize - to send back to caller
	    evlen = size
	    if( evlen > ievlen && new)
	    {
		call eprintf("Please rerun with this eventdef: \n\t%s\n")
		    call pargstr(Memc[PROSDEF(argv)])
		call error(QPC_FATAL,"current eventdef does not have sufficient room for requested calculation")
	    }
	    CLC_INIT(argv) = YES
	    nullval=0.0D0
	    switch (CTYPE(argv)){
	    case TY_SHORT,TY_INT:
	        INCTYPE(argv) = TY_INT
	    case TY_LONG:
	        INCTYPE(argv)= TY_LONG
	    case TY_REAL,TY_DOUBLE:
	        INCTYPE(argv)= TY_DOUBLE
	    default:
	        INCTYPE(argv)= CTYPE(argv)
	    }
	}	# end of initializations
        # compile display actions for the event elements we want to display
        call ev_compile(Memc[PROSDEF(argv)], "", name, comp, eoffset, 
		etype, ncomp, s_disp, i_disp, l_disp, r_disp, 
		d_disp, x_disp)
#        nevc = min(SZ_EVBUF, get)  #force this to always be maximum buffer size
	got = 0
	while( got < get ){
	    # get the next batch of events
	    try = min(SZ_EVBUF, get-got)
	    #  Update NEVC to be actual number of events in buffer
	    nevc=try
	    call calloc(evv,SZ_EVBUF,INCTYPE(argv))
	    if( qpio_getevents(fd[2], evl, mval, try, nev) != EOF)
	    {
		# move the old record into the new one
		evc = sbuf + (got*evlen)
		do i=1,nev
		{
		    ev = sbuf + (got*evlen)
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
#                       call amovs(Mems[evl[i]], Mems[ev], ievlen)
                       call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
                                        evl[i], ev)
 		     }
		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
		    got = got + 1
		    # QPOE event structure display code
		    if( display > 4 )
		    {
			call printf("Input EVENT data\n")
		        call ev_disp(1,comp,ncomp,eoffset,evl[i],evlen,got)
		    }
 		}
	        # point to FIRST record in sbuf for vex_eval
		#  evc is pointer to BEGINNING of all events in buffer
		#   ev is pointer to CURRENT event in buffer
		#  evl is an array of pointers to each event
#		if( display > 4 )
#		{
#		     call printf("Before CALCULATION\n")
#		    call ev_disp(nev,comp,ncomp,eoffset,evc,evlen,got)
#		}
		call vex_eval(PCODE(argv),qpevvar,nullval,exptype)
		#  Fill a buffer with the new values
		switch(INCTYPE(argv))
		{
		case TY_SHORT,TY_INT:
            	    call vex_copyi(PCODE(argv), INDEFI, Memi[evv], nevc)
		case TY_LONG:
            	    call vex_copyi(PCODE(argv), INDEFL, Meml[evv], nevc)
		case TY_REAL,TY_DOUBLE:
            	    call vex_copyd(PCODE(argv), INDEFD, Memd[evv], nevc)
		default:
		    call error(QPC_FATAL,"Unknown output column data type")
		}
		#  Stuff the new values into the output event list
		do i=1,nev
		{
		    switch( CTYPE(argv) ){
		    case TY_SHORT:
		        Mems[evc+(i-1)*evlen+offset]=Memi[evv+i-1]
		    case TY_INT:
		        Memi[(evc+(i-1)*evlen+offset-1)/SZ_INT+1]=Memi[evv+i-1]
		    case TY_LONG:
		        Meml[(evc+(i-1)*evlen+offset-1)/SZ_LONG+1]=Meml[evv+i-1]
		    case TY_REAL:
		        Memr[(evc+(i-1)*evlen+offset-1)/SZ_REAL+1]=Memd[evv+i-1]
		    case TY_DOUBLE:
		        Memd[(evc+(i-1)*evlen+offset-1)/SZ_DOUBLE+1]=
					Memd[evv+i-1]
		    default:
		        call error(QPC_FATAL,"Unknown output column data type")
		    }
		}
	        if( display > 3 )
		{
		    call printf("OUTPUT EVENT list\n")
		    call ev_disp(nev,comp,ncomp,eoffset,evc,evlen,nevc)
		}
		call mfree(evv,INCTYPE(argv))
	    }
	    else
	    {
#	        if( display > 2 )
#	        {	
#	            call printf("SBUF EVENT list\n")
#		    call ev_disp(got,comp,ncomp,eoffset,sbuf,evlen,got)
#	        }
##		call ev_destroycompile(name, comp, eoffset, etype,ncomp)
		break
	    }
	}
#	if( display > 2 )
#	{	
#	        call printf("SBUF EVENT list\n")
#		call ev_disp(got,comp,ncomp,eoffset,sbuf,evlen,got)
#	}
	call ev_destroycompile(name, comp, eoffset, etype,ncomp)
end




