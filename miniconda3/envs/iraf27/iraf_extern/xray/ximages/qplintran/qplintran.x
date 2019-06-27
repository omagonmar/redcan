#$Header: /home/pros/xray/ximages/qplintran/RCS/qplintran.x,v 11.0 1997/11/06 16:29:12 prosb Exp $
#$Log: qplintran.x,v $
#Revision 11.0  1997/11/06 16:29:12  prosb
#General Release 2.5
#
#Revision 9.1  1996/04/16 16:15:52  prosb
#JCC - Updated rot_get() to fix the compiling error on LINUX.
#
#Revision 9.0  95/11/16  18:35:15  prosb
#General Release 2.4
#
#Revision 8.2  1995/06/28  18:47:40  prosb
#JCC - display xdim/ydim when >=2 and use INDEFI for XDIM/YDIM.
#
#Revision 8.1  1994/09/16  16:20:47  dvs
#Made more general: checks for QPOE indices instead of assuming "x" and "y".
#
#Revision 8.0  94/06/27  14:55:07  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/19  16:44:26  mo
#MC	5/19/94		Add options to change dimension of QPOE file
#			Allows ability to 'shrink' a QPOE.
#
#Revision 7.0  93/12/27  18:28:27  prosb
#General Release 2.3
#
#Revision 6.1  93/07/02  14:35:26  mo
#MC	7/2/93		Corrent 'RANDOM' usage from boolean to integer
#
#Revision 6.0  93/05/24  16:09:20  prosb
#General Release 2.2
#
#Revision 1.3  93/05/21  09:37:36  mo
#MC	no changes - dimension checking already in place
#
#Revision 1.2  93/05/20  08:36:39  mo
#MCC	5/20/93		Fix HEADER update typo
#
#Revision 1.1  93/05/05  15:15:53  mo
#Initial revision
#
#
# QPLINTRAN -- linearly transform a qpoe file (with possible regions and filters)
#

include <math.h>
include <qpoe.h>
include <qpc.h>

# the first part of argv is defined in qpc.h
# define the other parts of argv we will need
define	SZ_ARGV		SZ_DEFARGV+34
define	MWCS		Memi[$1+(SZ_DEFARGV)+1]
define	XOFF		Memd[P2D(($1)+(SZ_DEFARGV+2))]
define	YOFF		Memd[P2D(($1)+(SZ_DEFARGV+4))]
define	XANGLE		Memd[P2D(($1)+(SZ_DEFARGV+6))]	# new rotation angle (radians)
define	XIN		Memd[P2D(($1)+(SZ_DEFARGV+8))]
define	YIN		Memd[P2D(($1)+(SZ_DEFARGV+10))]
define	XOUT		Memd[P2D(($1)+(SZ_DEFARGV+12))]
define	YOUT		Memd[P2D(($1)+(SZ_DEFARGV+14))]
define	YANGLE		Memd[P2D(($1)+(SZ_DEFARGV+16))]	# old rotation angle (radians)
define	SINX		Memd[P2D(($1)+(SZ_DEFARGV+18))]	# sin(old-new)
define	COSX		Memd[P2D(($1)+(SZ_DEFARGV+20))]	# cos(old-new)
define	SINY		Memd[P2D(($1)+(SZ_DEFARGV+22))]	# sin(old-new)
define	COSY		Memd[P2D(($1)+(SZ_DEFARGV+24))]	# cos(old-new)
define  XMAG		Memd[P2D(($1)+(SZ_DEFARGV+26))]	# relative plate scales
define  YMAG 		Memd[P2D(($1)+(SZ_DEFARGV+28))]	# relative plate scales
define  XDIM		Memi[$1+(SZ_DEFARGV+30)]	# output x dimension
define  YDIM 		Memi[$1+(SZ_DEFARGV+31)]	# output y dimension
define	ROTINIT		Memi[$1+(SZ_DEFARGV+32)]
define	RANDOM		Memi[$1+(SZ_DEFARGV+33)]
#
#  T_QPLINTRAN -- main task to copy a qpoe file
#
procedure t_qplintran()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv, SZ_ARGV, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers and allocate argv space
	call rot_load()
	ROTINIT(argv)= NO
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  ROT_LOAD -- load driver routines
#
procedure rot_load()

extern	rot_open(), rot_get(), def_close()
extern	rot_getparam(), rot_hist()

# shared with rot_get
#int	xoffset, yoffset	# x, y offsets
#int	xtype, ytype		# x, y data type
#common/rotcom/ xoffset, yoffset, xtype, ytype

begin
	# load the event drivers
	call qpc_evload("input_qpoe", ".qp", rot_open, rot_get, def_close)
	# load getparam routine
	call qpc_parload(rot_getparam)
	# load history routine
	call qpc_histload(rot_hist)
	# flag we have no x,y offsets
end

#
# ROT_GETPARAM -- get region parameter for qplintran
#
procedure rot_getparam(ifile, argv)

char	ifile[ARB]		# input file name
pointer	argv			# argument list pointer
double	clgetd()		# get real param
int	clgeti()
bool	temp
bool	clgetb()

begin
	# get standard params
	call def_getparam(ifile, argv)
	# get special qprotate params
	XANGLE(argv) = DEGTORAD(clgetd("xrotation"))
	YANGLE(argv) = XANGLE(argv)
	XIN(argv) = clgetd("xin")
	YIN(argv) = clgetd("yin")
	XOUT(argv) = clgetd("xout")
	YOUT(argv) = clgetd("yout")
	XMAG(argv) = clgetd("xmag")
	YMAG(argv) = clgetd("ymag")
	XDIM(argv) = clgeti("xdim")
	YDIM(argv) = clgeti("ydim")
	temp = clgetb( "mwcs" )
	if( temp )
	    MWCS(argv) = YES
	else
	    MWCS(argv) = NO
	temp = clgetb( "random" )
	if( temp )
	    RANDOM(argv) = YES
	else
	    RANDOM(argv) = NO
end

#
# ROT_HIST -- write history (and a title) to qpoe file
#
procedure rot_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

double	xrot			# l: rotated x value
double	yrot			# l: rotated y value
double	xshift
double	yshift
int	axlen[7]			# l: qpoe axis dimensions
int	len				# l: length of string
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
int	strlen()			# l: string length
int	qp_accessf()
bool	streq()				# l: string compare

double	r1,r2				# l: remember the input ref points
pointer	mw

begin
	# mark the stack
	call smark(sp)
	# allocate a string long enough
	len = strlen(Memc[file[1]])+
	      strlen(Memc[REGIONS(argv)])+
	      strlen(Memc[EXPOSURE(argv)])+
	      strlen(qpname)+
	      2 * SZ_LINE
	call salloc(buf, len, TY_CHAR)

	# make a history comment
	if( streq("NONE", Memc[EXPOSURE(argv)]) ){
	    call sprintf(Memc[buf], len, "%s (%s; no exp.) -> %s (xin=%.2f yin=%.2f xrot=%.2f yrot=%.2f xout=%.2f yout=%.2f)")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(qpname)
	    call pargd(XIN(argv))
	    call pargd(YIN(argv))
	    call pargd(RADTODEG(XANGLE(argv)))
	    call pargd(RADTODEG(YANGLE(argv)))
	    call pargd(XOUT(argv))
	    call pargd(YOUT(argv))
	}
	else{
	    call sprintf(Memc[buf], len, "%s (%s; %s %.2f) -> %s (xin=%.2f yin=%.2f xrot=%.2f yrot=%.2f xout=%.2f yout=%.2f)")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(Memc[EXPOSURE(argv)])
	    call pargr(THRESH(argv))
	    call pargstr(qpname)
	    call pargd(XIN(argv))
	    call pargd(YIN(argv))
	    call pargd(RADTODEG(XANGLE(argv)))
	    call pargd(RADTODEG(YANGLE(argv)))
	    call pargd(XOUT(argv))
	    call pargd(YOUT(argv))
	}
	# display, if necessary
	if( display >0 ){
	    call printf("\n%s\n")
	    call pargstr(Memc[buf])
	}
	# write the history record
	call put_qphistory(qp, "qplintran", Memc[buf], "")

	# write the new rotation angle into the wcs

	axlen[1] = QP_XDIM(qphead)
	axlen[2] = QP_YDIM(qphead)
        if (display >=2 ) 
        {
          call printf(" x, y dimensions = %d, %d \n")
          call pargi(axlen[1])
          call pargi(axlen[2])
        }
	if( MWCS(argv) == YES )
	{
	    r1 = QP_CRPIX1(qphead)
	    r2 = QP_CRPIX2(qphead)
	    QP_CRPIX1(qphead) = XOUT(argv) + 
			(r1-XIN(argv))*XMAG(argv)*COSX(argv) - 
			(r2-YIN(argv))*YMAG(argv)*SINX(argv)
	    QP_CRPIX2(qphead) = YOUT(argv) + 
			(r1-XIN(argv))*XMAG(argv)*COSY(argv) + 
			(r2-YIN(argv))*YMAG(argv)*SINY(argv)
	    QP_CROTA2(qphead) = QP_CROTA2(qphead) + 
				RADTODEG((YANGLE(argv)))
	    QP_CDELT1(qphead) = QP_CDELT1(qphead) / XMAG(argv)
	    QP_CDELT2(qphead) = QP_CDELT2(qphead) / YMAG(argv)
	}	# end - update WCS
	    if( XDIM(argv) == INDEFI )
	        axlen[1] = QP_XDIM(qphead)
	    else if (XDIM(argv) < 0 )
	    {
    	            xshift = (QP_XDIM(qphead) - XIN(argv) )* XMAG(argv)
    	            yshift = (QP_YDIM(qphead) - YIN(argv) )* YMAG(argv)
                    xrot = XOUT(argv) + xshift*COSX(argv) - yshift*SINX(argv)
                    axlen[1] = int(xrot)+1
	    }
	    else
	        axlen[1] = XDIM(argv)
	    
	    if( YDIM(argv) == INDEFI )
	        axlen[2] = QP_YDIM(qphead)
	    else  if (YDIM(argv) < 0 )
	    {
    	            xshift = (QP_XDIM(qphead) - XIN(argv) )* XMAG(argv)
    	            yshift = (QP_YDIM(qphead) - YIN(argv) )* YMAG(argv)
                    yrot = YOUT(argv) + yshift*COSY(argv) + xshift*SINY(argv)
                    axlen[2] = int(yrot)+1
	    }
	    else
	        axlen[2] = YDIM(argv)
	    
	QP_XDIM(qphead) = axlen[1]
	QP_YDIM(qphead) = axlen[2]
        if (display >=2 ) 
        {
          call printf(" x, y dimensions = %d, %d \n")
          call pargi(axlen[1])
          call pargi(axlen[2])
        }

        if( qp_accessf(qp,"axlen") == NO )
            call qpx_addf (qp, "axlen", "i", 2, "length of each axis", 0)
        call qp_write (qp, "axlen", axlen, 2, 1, "i")
	call qph2mw(qphead, mw)
	call qp_savewcs(qp, mw, 2)

	# free up stack space
	call sfree(sp)
end

#
# ROT_OPEN -- open a qpoe file and an event list through a region
#		and determine some constant quantities for the rotate
#
procedure rot_open(fname, fd, irecs, convert, qphead, display, argv)

char	fname[ARB]			# i: header file name
int	fd[MAX_ICHANS]			# o: file descriptor
int	irecs				# o: number of records in file
int	convert				# i: data conversion flag
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

int	seed				# l: seed for urand
common/rndcom/seed

begin
	# init the seed used in urand
	seed = 1
	# first perform the usual open
	call def_open(fname, fd, irecs, convert, qphead, display, argv)
	# now calculate some quantities
	SINX(argv) = sin(XANGLE(argv))
	COSX(argv) = cos(XANGLE(argv))
	SINY(argv) = sin(YANGLE(argv))
	COSY(argv) = cos(YANGLE(argv))
	if( display >=4 ){
	    call printf("angle: %.2f -> %.2f\n")
	    call pargd(RADTODEG(XANGLE(argv)))
	    call pargd(RADTODEG(YANGLE(argv)))
	    call printf("sin(x): %.f; cos(x): %.f; sin(y): %.f; cos(y): %f\n")
	    call pargd(SINX(argv))
	    call pargd(COSX(argv))
	    call pargd(SINY(argv))
	    call pargd(COSY(argv))
	    call printf("x, y plate scale ratios: %.2f %.2f\n")
	    call pargd(XMAG(argv))
	    call pargd(YMAG(argv))
	}
end

define SZ_EVBUF	512

#
# ROT_GET -- read the next input event and create an output event
#
procedure rot_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

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
double	xrot			# l: rotated x value
double	yrot			# l: rotated y value
double	xshift
double	yshift
double	deltax			# l: delta x
double	deltay			# l: delta y
real	randx			# l: x random value
real	randy			# l: y random value

int	qpio_getevents()	# l: get qpoe events
int	qpc_lookup()		# l: look up an event element name
real	urand()			# l: random number generator

int	seed			# l: seed for urand
common/rndcom/seed

# Save in local common just to remember from call to call
int	xoffset, yoffset	# x, y offsets
int	xtype, ytype		# x, y data type
common/rotcom/xoffset, yoffset, xtype, ytype

begin
	# get x and y offsets, if necessary (but only once)
	if( ROTINIT(argv)== NO ){
	    if( qpc_lookup(QP_INDEXX(qphead), xtype, xoffset) == NO )
		call errstr(1, "x-index undefined in event struct",
				QP_INDEXX(qphead))
	    if( xtype != TY_SHORT )
		call errstr(1, "x-index must be TY_SHORT",QP_INDEXX(qphead))
	    if( qpc_lookup(QP_INDEXY(qphead), ytype, yoffset) == NO )
		call errstr(1, "y-index undefined in event struct",
				QP_INDEXX(qphead))
	    if( ytype != TY_SHORT )
#JCC-4/16/96    call errstr(1, "y-index must be TY_SHORT",QP_INDEXX(qphead),)
		call errstr(1, "y-index must be TY_SHORT",QP_INDEXX(qphead))
	    if( IS_INDEFD(XIN(argv)) )
		XIN(argv) = QP_CRPIX1(qphead)
	    if( IS_INDEFD(YIN(argv)) )
		YIN(argv) = QP_CRPIX2(qphead)
	    if( IS_INDEFD(XOUT(argv)) )
		XOUT(argv) = QP_CRPIX1(qphead)
	    if( IS_INDEFD(YOUT(argv)) )
		YOUT(argv) = QP_CRPIX2(qphead)
	    ROTINIT(argv)= YES
		    if( display > 2 )
		    {
		      call printf("xin %f xout %f yin %f yout %f \n")
			call pargd(XIN(argv))
			call pargd(XOUT(argv))
			call pargd(YIN(argv))
			call pargd(YOUT(argv))
		      call printf("sin %f cos %f mag1%f mag2%f \n")
			call pargd(SINX(argv))
			call pargd(COSX(argv))
			call pargd(XMAG(argv))
			call pargd(YMAG(argv))
		    }
	}
	# determine the number of shorts we move from input to output
	call qpc_movelen(fd[1], evsize, evlen)
	# determine the padded record size of the qpoe record
	call qpc_roundup(evsize, size)
	# get photons and shift/rotate them
	got = 0
	while( got < get ){
	    # get the next batch of events
	    try = min(SZ_EVBUF, get-got)
	    if( qpio_getevents(fd[2], evl, mval, try, nev) != EOF){
		do i=1, nev{
                    #--------------------------------
                    # point to current record in sbuf
                    #--------------------------------
                    ev = sbuf + (got*size)


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
                       call qp_movedata(SWAP_CNT(argv), SWAP_PTR(argv), 
                                        evl[i], ev)
                    }
                    #---------------------------------------------------
		    # rotate the x and y pixel values
                    #---------------------------------------------------
		    xshift = (Mems[ev+xoffset] - XIN(argv) )* XMAG(argv) 
		    yshift = (Mems[ev+yoffset] - YIN(argv) )* YMAG(argv) 
		    xrot = XOUT(argv) + xshift*COSX(argv) - yshift*SINX(argv)
		    yrot = YOUT(argv) + yshift*COSY(argv) + xshift*SINY(argv)

		    deltax = xrot - int(xrot)
		    randx = urand(seed)
		    if( randx < deltax && RANDOM(argv)==YES )
			Mems[ev+xoffset] = int(xrot)+1
		    else
			Mems[ev+xoffset] = int(xrot)

		    # randomize the y rotated value
		    deltay = yrot - int(yrot)
		    randy = urand(seed)
		    if( randy < deltay && RANDOM(argv)==YES )
			Mems[ev+yoffset] = int(yrot)+1
		    else
			Mems[ev+yoffset] = int(yrot)
		    # insert the region number, if necessary
		    call qpc_putregion(ev, mval)
                    #---------------------
                    # inc number of events if valid for current QPOE
                    #---------------------

                    if( Mems[ev+xoffset] >= 1 && 
                        Mems[ev+xoffset] <= QP_XDIM(qphead) &&  
                        Mems[ev+yoffset] >= 1 && 
                        Mems[ev+yoffset] <= QP_YDIM(qphead) )
                        got = got+1
                    else
                    {
                        call printf("** WARNING ** invalid event: %d %d - discarded\n")
                          call pargs(Mems[ev+xoffset])
                          call pargs(Mems[ev+yoffset])
                        call flush(STDOUT)
                    }

		    # randomize the x rotated value
		}
	    }
	    else
		break
	}
end






