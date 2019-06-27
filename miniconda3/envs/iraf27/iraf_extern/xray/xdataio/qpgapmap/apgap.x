#$Header: /home/pros/xray/xdataio/qpgapmap/RCS/apgap.x,v 11.0 1997/11/06 16:36:01 prosb Exp $
#$Log: apgap.x,v $
#Revision 11.0  1997/11/06 16:36:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:22:25  prosb
#General Release 2.3.1
#
#Revision 7.2  94/04/06  14:34:42  mo
#MC	4/6/94		Remove extraneous print statements, fix problems
#			with 0 indexing, and with 0 index values
#			(This only shows when x,y==0, so probably
#			didn't do much harm)
#
#Revision 7.1  94/04/06  13:55:21  janet
#moved from xproto to xdataio.
#
#Revision 7.0  93/12/27  18:51:40  prosb
#General Release 2.3
#
#Revision 1.1  93/12/17  12:53:39  mo
#Initial revision
#
#Revision 6.0  93/05/24  17:08:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:13:38  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:59:35  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:14:42  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:39:37  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       apgap
# Project:      PROS -- ROSAT RSDC
# Purpose:      Gapmap application routines for tm2qp
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include	 	<error.h>	
define 		PREAMPSPERTAP	3
define		DIMX		4096
define		DIMY		4096
define		SEGWIDTH	256
define		GAPPOS		128
define		SZ_XGAPMAP	4096
define		SZ_YGAPMAP	4096
define		SZ_PHACORR	2*PREAMPSPERTAP
define		GAPMAPSCALE	16.0

procedure opgap(gname)
pointer	gname		# i: input gapmap file name
pointer	fd		# l: file pointer
pointer open()
short	temp[SZ_PHACORR*2]
int	read()
int	display
int	stat
short	gapmapx[0:DIMX-1]
short	gapmapy[0:DIMY-1]
real	phamean
real	xphacorr[2,PREAMPSPERTAP]
real	yphacorr[2,PREAMPSPERTAP]
common	/gapmap/gapmapx,gapmapy,phamean,xphacorr,yphacorr
begin
	display=0
	fd = open(Memc[gname],READ_ONLY,BINARY_FILE)
    	stat=read(fd,gapmapx[0],SZ_XGAPMAP*SZ_SHORT)
	if( stat != SZ_XGAPMAP*SZ_SHORT )
	    call error(0,"Error reading x gapmap file")
    	stat=read(fd,gapmapy[0],SZ_YGAPMAP*SZ_SHORT)
	if( stat != SZ_YGAPMAP*SZ_SHORT )
	    call error(0,"Error reading y gapmap file")
	stat=read(fd,temp[1],1*2)
	if( stat != 2)
	    call error(0,"Error reading pha gapmap file")
	call amovr(temp[1],phamean,1)
	if( display > 4 )
	{
	    call printf("phamean: %f\n")
	        call pargr(phamean)
	}
	stat=read(fd,temp[1],SZ_PHACORR*SZ_REAL)
	if( stat != SZ_PHACORR*SZ_REAL)
	    call error(0,"Error reading pha gapmap file")
	call amovr(temp[1],xphacorr[1,1],SZ_PHACORR)
	if( display > 4 )
	{
	    call printf("xphacorr %f %f %f %f %f %f\n")
	      call pargr(xphacorr[1,1])
	      call pargr(xphacorr[2,1])
	      call pargr(xphacorr[1,2])
	      call pargr(xphacorr[2,2])
	      call pargr(xphacorr[1,3])
	      call pargr(xphacorr[2,3])
	}
	stat=read(fd,temp[1],SZ_PHACORR*SZ_REAL)
	if( stat != SZ_PHACORR*SZ_REAL)
	       call error(0,"Error reading pha gapmap file")
	call amovr(temp[1],yphacorr[1,1],SZ_PHACORR)
	if( display > 4 )
	{
	    call printf("yphacorr %f %f %f %f %f %f\n")
	      call pargr(yphacorr[1,1])
	      call pargr(yphacorr[2,1])
	      call pargr(yphacorr[1,2])
	      call pargr(yphacorr[2,2])
	      call pargr(yphacorr[1,3])
	      call pargr(yphacorr[2,3])
	}
	call close(fd)
end


#procedure opimgap(gname)
#pointer gname           # i: input gapmap file name
#pointer fd              # l: file pointer
#pointer open()
#short   temp[SZ_PHACORR*2]
#int     read()
#int     stat
#short   gapmapx[0:DIMX-1]
#short   gapmapy[0:DIMY-1]
#real    phamean
#real    xphacorr[2,PREAMPSPERTAP]
#real    yphacorr[2,PREAMPSPERTAP]
#common  /gapmap/gapmapx,gapmapy,phamean,xphacorr,yphacorr
#begin
#	im = immap(Memc[gname],READ_ONLY,0)
#        stat=read(fd,gapmapx[1],SZ_XGAPMAP*SZ_SHORT)
#        if( stat != SZ_XGAPMAP*SZ_SHORT )
#            call error(0,"Error reading x gapmap file")
#        stat=read(fd,gapmapy[1],SZ_YGAPMAP*SZ_SHORT)
#        if( stat != SZ_YGAPMAP*SZ_SHORT )
#            call error(0,"Error reading y gapmap file")
#        stat=read(fd,temp[1],1*2)
#        if( stat != 2)
#            call error(0,"Error reading pha gapmap file")
#        call amovr(temp[1],phamean,1)
#        call printf("phamean: %f\n")
#          call pargr(phamean)
#        stat=read(fd,temp[1],SZ_PHACORR*SZ_REAL)
#        if( stat != SZ_PHACORR*SZ_REAL)
#            call error(0,"Error reading pha gapmap file")
#        call amovr(temp[1],xphacorr[1,1],SZ_PHACORR)
#        call printf("xphacorr %f %f %f %f %f %f\n")
#          call pargr(xphacorr[1,1])
#          call pargr(xphacorr[2,1])
#          call pargr(xphacorr[1,2])
#          call pargr(xphacorr[2,2])
#          call pargr(xphacorr[1,3])
#          call pargr(xphacorr[2,3])
#        stat=read(fd,temp[1],SZ_PHACORR*SZ_REAL)
#        if( stat != SZ_PHACORR*SZ_REAL)
#            call error(0,"Error reading pha gapmap file")
#        call amovr(temp[1],yphacorr[1,1],SZ_PHACORR)
#        call printf("yphacorr %f %f %f %f %f %f\n")
#          call pargr(yphacorr[1,1])
#          call pargr(yphacorr[2,1])
#          call pargr(yphacorr[1,2])
#          call pargr(yphacorr[2,2])
#          call pargr(yphacorr[1,3])
#          call pargr(yphacorr[2,3])
#        call close(fd)
#end
#
procedure apgaps(sxpos,sypos,spha,rnd,fxpos,fypos)
short	sxpos
short	sypos
short	spha
int	rnd
real	fxpos
real	fypos

int	x,y
int	xpos,ypos,pha
real	xcorr,ycorr

short	gapmapx[0:DIMX-1]
short	gapmapy[0:DIMY-1]
real	phamean
real	xphacorr[2,PREAMPSPERTAP]
real	yphacorr[2,PREAMPSPERTAP]
real	urand()
long	seed
data	seed/1/
common	/gapmap/gapmapx,gapmapy,phamean,xphacorr,yphacorr
begin
	xpos = sxpos
	ypos = sypos
	pha = spha
	fxpos = xpos - SEGWIDTH*((xpos+GAPPOS)/SEGWIDTH);
	fypos = ypos - SEGWIDTH*((ypos+GAPPOS)/SEGWIDTH);
	x=mod((xpos+GAPPOS)/SEGWIDTH,3)+1
	y=mod((ypos+GAPPOS)/SEGWIDTH,3)+1
	xcorr = (pha - phamean) * (xphacorr[1,x] + xphacorr[2,x]*fxpos)
	ycorr = (pha - phamean) * (yphacorr[1,y] + yphacorr[2,y]*fypos)
	if( abs( xcorr ) > 5.0 || abs( ycorr ) > 5.0 )
	{
	  call printf("pha: %d xphacorr %f yphacorr %f\n")
	  call pargi( pha )
	  call pargr( xcorr )
	  call pargr( ycorr )
	}
	x = max(0.0E0,xpos + xcorr + .5 )
	y = max(0.0E0,ypos + ycorr + .5 )
	fxpos = real(xpos) + xcorr + gapmapx[x]/GAPMAPSCALE +.5
	fypos = real(ypos) + ycorr + gapmapy[y]/GAPMAPSCALE +.5
	if( rnd == 1 )
	{
	    fxpos = fxpos + urand( seed ) - 0.5
	    fypos = fypos + urand( seed ) - 0.5
	}
#	if( abs( fxpos - real(xpos)) > 75.0 || abs( fypos - real(ypos) ) > 75.0 )
#	{
#	    call printf( "WARNING: old pos: %d new pos: %f \n")
#		call pargi( xpos )
#		call pargr( fxpos )
#	    call printf( "WARNING: old pos: %d new pos: %f \n")
#		call pargi( ypos )
#		call pargr( fypos )
#	}
	end

procedure t_degap()
short	sxpos
short	sypos
short	spha
int	rnd

pointer	sp
pointer	gname
real	fxpos,fypos
bool	clgetb()
short	clgets()

begin
	call smark(sp)
	call salloc( gname , SZ_PATHNAME , TY_CHAR )
	call clgstr("gapmapname",Memc[gname],SZ_PATHNAME)
	call opgap( gname )
	rnd = 1
	while( clgetb("more") )
	{
	    sxpos = clgets("x_position")
	    sypos = clgets("y_position")
	    spha = 7
	    call apgaps(sxpos,sypos,spha,rnd,fxpos,fypos)
	    call printf("det pos: %d %d Degapped pos: %.1f %.1f qp pos: %.1f %.1f\n\n")
	      call pargs( sxpos )
	      call pargs( sypos )
	      call pargr( fxpos )
	      call pargr( fypos )
	      call pargr( fxpos )
	      call pargr( 8192.0 - fypos )
	}
	call sfree(sp)
end

procedure t_prgmap()
short	sxpos
short	sypos
short	spha
int	rnd

int	i
pointer	sp
pointer	gname
real	fxpos,fypos

begin
	rnd = 1
	call smark(sp)
	call salloc( gname , SZ_PATHNAME , TY_CHAR )
	call clgstr("gapmapname",Memc[gname],SZ_PATHNAME)
	call printf("gapmapname %s\n")
	    call pargstr(Memc[gname])
	call opgap( gname )
#	while( clgetb("more") )
	call printf("det pos\t\t inst x\t inst y\t iraf x\t iraf y\n\n")
	do i=0,4095
	{
#	    sxpos = clgets("x_position")
#	    sypos = clgets("y_position")
	    sxpos = i
	    sypos = i
	    spha = 7
	    call apgaps(sxpos,sypos,spha,rnd,fxpos,fypos)
	    call printf("%d \t\t %.1f \t%.1f \t %.1f\t %.1f\n")
	      call pargs( sxpos )
#	      call pargs( sypos )
	      call pargr( fxpos )
	      call pargr( fypos )
	      call pargr( fxpos+1.0 )
	      call pargr( 8192.0 - fypos )
	}
	call sfree(sp)
end

procedure t_testrand()
real	rand,urand()
long	seed
bool	tend
begin
	seed = 1
	tend = FALSE
	while( !tend )
	{
	    rand = urand( seed )
	    call printf("rand: %f\n")
	      call pargr( rand )
	 }
end
