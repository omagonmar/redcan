#$Header: /home/pros/xray/xdataio/qpgapmap/RCS/qpgapmap.x,v 11.0 1997/11/06 16:36:03 prosb Exp $
#$Log: qpgapmap.x,v $
#Revision 11.0  1997/11/06 16:36:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:30  prosb
#General Release 2.3.1
#
#Revision 7.5  94/06/15  16:00:57  janet
#jd - added code to update the optical axis center for pre-rdf data in the
#qpoe header to reflect the recentering
#
#Revision 7.4  94/04/14  12:12:26  mo
#MC	4/14/94		Fix typo in program name for history record
#
#Revision 7.3  94/04/11  16:19:29  mo
#MC	4/11/94		Update the comments to make coordinate convention clear
#
#Revision 7.2  94/04/06  15:46:23  mo
#MC	4/6/94		Fix the typos where X was used instead of Y
#			(Default values are equal, so probably didn't
#				cause any harm)
#
#Revision 7.1  94/04/06  13:55:43  janet
#jd - moved from xproto to xdataio.
#
#Revision 7.0  93/12/27  18:52:01  prosb
#General Release 2.3
#
#Revision 1.1  93/12/17  12:53:07  mo
#Initial revision
#


## QPGAPMAP -- Apply the HRI gapmap to the the RAW coordinates of the
#		QPOE file to produce DETECTOR coordinates
#		For ROSAT, DETECTOR coordinates are equivalent to 'unaspected'
#		coordinates, and are used for storing all calibration
#		data arrays
#

include <mach.h>
include <math.h>
include <qpoe.h>
include <qpc.h>
include	<qpset.h>

define	EA_GAP	1	# error - undefined QPOE element
# the first part of argv is defined in qpc.h
# define the other parts of argv we will need
define	SZ_ARGV		(SZ_DEFARGV+25)
define 	GAPMAP		Memi[$1+(SZ_DEFARGV)+1]
define	EVENTS		Memi[$1+(SZ_DEFARGV)+2]
define	PHA		Memi[$1+(SZ_DEFARGV)+3]
define	RAWX		Memi[$1+(SZ_DEFARGV)+4]
define	RAWY		Memi[$1+(SZ_DEFARGV)+5]
define	DETX		Memi[$1+(SZ_DEFARGV)+6]
define	DETY		Memi[$1+(SZ_DEFARGV)+7]
define	PTYPE		Memi[$1+(SZ_DEFARGV)+8]
define	XTYPE		Memi[$1+(SZ_DEFARGV)+9]
define	YTYPE		Memi[$1+(SZ_DEFARGV)+10]
define	POFFSET		Memi[$1+(SZ_DEFARGV)+11]
define	XOFFSET		Memi[$1+(SZ_DEFARGV)+12]
define	YOFFSET		Memi[$1+(SZ_DEFARGV)+13]
define	RXTYPE		Memi[$1+(SZ_DEFARGV)+14]
define	RYTYPE		Memi[$1+(SZ_DEFARGV)+15]
define	RXOFFSET		Memi[$1+(SZ_DEFARGV)+16]
define	RYOFFSET		Memi[$1+(SZ_DEFARGV)+17]
define	OUTNAME		Memi[$1+(SZ_DEFARGV)+18]
define	GAPINIT		Memi[$1+(SZ_DEFARGV)+19]
define	RANDOM		Memi[$1+(SZ_DEFARGV)+20]
define  XCENOFF		Memd[P2D(($1)+(SZ_DEFARGV)+21)]
define  YCENOFF		Memd[P2D(($1)+(SZ_DEFARGV)+23)]
#
#  T_QPGAPMAP -- main task to append a list of QPOE files
#
procedure t_qpgapmap()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv, SZ_ARGV+10, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers and allocate argv space
	call gap_load()
	GAPINIT(argv) = NO
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  GAP_LOAD -- load driver routines
#
procedure gap_load()

extern	gap_open(), gap_get(), def_close()
extern	gap_getparam(), gap_hist()
# extern gap_finale()


begin
        # load the header drivers
#        call qpc_hdload("header", ".mhdr", uhd_open, uhd_get, uhd_close)
        # load the time drivers
#***        call qpc_auxload("tgr", ".tgr", qptgr_open, qptgr_get, tgr_put, tgr_close,
#***                          1)
#***     call qpc_auxload("gti", ".gti", qpgti_open, qpgti_get, gti_put, gti_close,
#***                          1)
#***        call qpc_auxload("tsi", ".tsi", qptsi_open, qptsi_get, tsi_put, tsi_close,
#***                          1)
        # load the aspect drivers
#***        call qpc_auxload("blt", ".blt", qpblt_open, qpblt_get, blt_put, blt_close,
#***                         2)
	# load the event drivers
	call qpc_evload("input_qpoe", ".qp", gap_open, gap_get, def_close)
	# load getparam routine
	call qpc_parload(gap_getparam)
#        call qpc_finaleload(gap_finale)
	# load history routine
	call qpc_histload(gap_hist)
end

#
# GAP_GETPARAM -- get region parameter for qpgapmap
#
procedure gap_getparam(ifile, argv)

char	ifile[ARB]		# input file name
pointer	argv			# argument list pointer
bool	clgetb()		# l: get real param
int	btoi()
#bool	temp			# l
double	clgetd()

begin
	# get standard params
	call def_getparam(ifile, argv)
	# get special qprotate params
	call calloc(GAPMAP(argv),SZ_PATHNAME,TY_CHAR)
	call clgstr("gapmap",Memc[GAPMAP(argv)],SZ_PATHNAME)
	call calloc(PHA(argv),SZ_LINE,TY_CHAR)
	call clgstr("pha",Memc[PHA(argv)],SZ_LINE)
	call calloc(DETX(argv),SZ_LINE,TY_CHAR)
	call clgstr("detx",Memc[DETX(argv)],SZ_LINE)
	call calloc(DETY(argv),SZ_LINE,TY_CHAR)
	call clgstr("dety",Memc[DETY(argv)],SZ_LINE)
	call calloc(RAWX(argv),SZ_LINE,TY_CHAR)
	call clgstr("rawx",Memc[RAWX(argv)],SZ_LINE)
	call calloc(RAWY(argv),SZ_LINE,TY_CHAR)
	call clgstr("rawy",Memc[RAWY(argv)],SZ_LINE)
        RANDOM(argv) = btoi( clgetb("random") )
	XCENOFF(argv)=clgetd("xoffset")
	YCENOFF(argv)=clgetd("yoffset")
end


#
#
# GAP_HIST -- write history (and a title) to qpoe file
#
procedure gap_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
#int	i
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
#pointer	fname
int	strlen()			# l: string length
bool	streq()				# l: string compare

real	clgetr()

#pointer	mw

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
            call sprintf(Memc[buf], len, "%s (%s; no exp.; gapmap=%s) -> %s" )
            call pargstr(Memc[file[1]])
            call pargstr(Memc[REGIONS(argv)])
            call pargstr(Memc[GAPMAP(argv)])
            call pargstr(qpname)
        }
        else{
            call sprintf(Memc[buf], len, "%s (%s; %s %.2f; gapmap=%s) -> %s"  )
            call pargstr(Memc[file[1]])
            call pargstr(Memc[REGIONS(argv)])
            call pargstr(Memc[EXPOSURE(argv)])
            call pargr(THRESH(argv))
            call pargstr(Memc[REGIONS(argv)])
            call pargstr(qpname)
        }
        # display, if necessary
        if( display >0 ){
           call printf("\n%s\n")
            call pargstr(Memc[buf])
        }
        # write the history record
        call put_qphistory(qp, "qpgapmap", Memc[buf], "")

        # update the optical axis center for pre-rdf data in the 
        # qpoe header to reflect the recentering
        if ( QP_REVISION(qphead) < 1 ) {
           QP_XDOPTI(qphead) = clgetr ("xoptaxis")
           QP_YDOPTI(qphead) = clgetr ("yoptaxis")

           call put_qphead (qp, qphead)
	}

        # free up stack space
        call sfree(sp)
	call mfree(PHA(argv),TY_CHAR)
	call mfree(DETX(argv),TY_CHAR)
	call mfree(DETY(argv),TY_CHAR)
	call mfree(RAWX(argv),TY_CHAR)
	call mfree(RAWY(argv),TY_CHAR)
	call mfree(GAPMAP(argv),TY_CHAR)
end
#
# GAP_OPEN -- open a qpoe file 
#
procedure gap_open(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list


begin
        # display, if necessary
        if( display >1 ){
            call printf("opening input event file:\t%s\n")
            call pargstr(fname)
        }
        # new stuff
        irecs = 0

        call def_open(fname, fd, irecs, convert, qphead, display, argv)
	call opgap(GAPMAP(argv))
end

define SZ_EVBUF	512

#
# GAP_GET -- read the next buffer of input events and create an output event
#		buffer
#
procedure gap_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

int	fd[MAX_ICHANS]		# i: file descriptor
int	evsize			# i: size of output qpoe record
int	convert			# i: data conversion flag
pointer	sbuf			# o: event pointer
int	get			# i: number of events to get
int	got			# o: number of events got
pointer	qphead			# i: header
int	display			# i: display level
pointer	argv			# i: pointer to arg list

int	i			# l: loop counter
int	mval			# l: mask from qpio_getevent
int	nev			# l: number of events returned
int	evlen			# l: number of shorts to move
int	try			# l: number of events to try this time
int	evl[SZ_EVBUF]		# l: event pointer from qpio_getevent
int	size			# l: padded size of a qpoe record
pointer	ev			# l: pointer to current output record
#double  phase,phi,exp,tref

short	posx,posy,pha
real	xpos,ypos
	
#int	trecs
# new
#char    fname[SZ_PATHNAME]
#short   head[SZ_UHEAD]
#double reftime_set()
#double  reftime
#int     start
# end new

int	qpio_getevents()	# l: get qpoe events
int	qpc_lookup()		# l: look up an event element name

# Just to remember from call to call ( save)
#int	toffset		# x, y offsets
#int	ttype		# x, y data type
#common/phscom/toffset, ttype

begin
	# get x and y offsets, if necessary (but only once)
	if( GAPINIT(argv) == NO ){
	    if( qpc_lookup(Memc[PHA(argv)], PTYPE(argv), POFFSET(argv)) == NO )
		call errstr(EA_GAP,"undefined in input event struct: ",PHA(argv))
	    if( qpc_lookup(Memc[DETX(argv)], XTYPE(argv), XOFFSET(argv)) == NO )
		call errstr(EA_GAP,"undefined in input event struct: ",DETX(argv))
	    if( qpc_lookup(Memc[DETY(argv)], YTYPE(argv), YOFFSET(argv)) == NO )
		call errstr(EA_GAP,"undefined in input event struct: ",DETY(argv))
	    if( qpc_lookup(Memc[RAWX(argv)], RXTYPE(argv), RXOFFSET(argv)) == NO )
		call errstr(EA_GAP,"undefined in input event struct: ",RAWX(argv))
	    if( qpc_lookup(Memc[RAWY(argv)], RYTYPE(argv), RYOFFSET(argv)) == NO )
		call errstr(EA_GAP,"undefined in input event struct: ",RAWY(argv))
#	    if( ttype != TY_DOUBLE)
#		call error(1, "'time' must be TY_DOUBLE")
	    GAPINIT(argv) = YES
# ***  Need to get access to these 'look-up' routines, each input file
	}
	# determine the number of shorts we move from input to output
	call qpc_movelen(fd[1], evsize, evlen)
	# determine the padded record size of the qpoe record
	call qpc_roundup(evsize, size)
	# get photons and calculate phase 
	got = 0
	while( got < get ){
	    # get the next batch of events
	    try = min(SZ_EVBUF, get-got)
	    if( qpio_getevents(fd[2], evl, mval, try, nev) != EOF){
		do i=1, nev{
		    # point to current record in sbuf
		    ev = sbuf + (got*size)
		    # inc number of events
		    got = got+1
		    # move the old record into the new one
#		    call amovs(Mems[evl[i]], Mems[ev], evlen)
#                      call amovs(Mems[evl[i]], Mems[ev], evlen)
                    call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
                                     evl[i], ev)
		    call amovs(Mems[ev+POFFSET(argv)],pha,SZ_SHORT)
		    call amovs(Mems[ev+RXOFFSET(argv)],posx,SZ_SHORT)
		    call amovs(Mems[ev+RYOFFSET(argv)],posy,SZ_SHORT)
	            call apgaps(posx,posy,pha,RANDOM(argv),xpos,ypos)
            	    if( display >= 3 )
            	    {
                	call printf("x,y: %d %d  degapped x,y %f %f\n")
                  	    call pargs( posx)
                  	    call pargs( posy)
                  	    call pargr( xpos)
                  	    call pargr( ypos)
            	    }
#		    call printf("xoffset: %f, yoffset: %f\n")
#			call pargd(XCENOFF(argv))
#			call pargd(YCENOFF(argv))
##################
#  Please note that this assignment of x,y is necessary to completely  
#       duplicate the LEVEL1,HOPR code in RDTELEM.  The Y axis was              
#       inverted to get the HRI instrument coordinates to conform to            
#       the ROSAT space-craft coordinate system as defined by MPE               
#  Please note that this is NOT the inversion that is performed to              
#       import ROSAT level 1 output coordinates into FITS and level 2           
#       processing systems, such as IRAF
#  Only the final X,Y coordinate systems are inverted to conform with
#       FITS/IRAF/AIPS conventions, the RAW and DET coordinates are not
#       changed
##################
#		    pha = QP_YDIM(qphead)
		    posx = short(xpos+XCENOFF(argv))
		    posy = short(QP_YDIM(qphead)-1.0-(ypos+YCENOFF(argv)))
#        	    ref = Mems[evl[i]+toffset] 
#		    call amovs(Mems[evl[i]+toffset],tref,SZ_DOUBLE)
#        	    tref = tref - PHSSTART(argv)
#	            call calc_phase (REFPER(argv), PDOT(argv), tref, display, 
#			phase, phi, exp)
		    call amovs(posx,Mems[ev+XOFFSET(argv)],SZ_SHORT)
		    call amovs(posy,Mems[ev+YOFFSET(argv)],SZ_SHORT)

		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
		}
           }
	else
	    break
}	# end while
end



