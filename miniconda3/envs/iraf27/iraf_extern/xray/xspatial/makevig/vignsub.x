#$Header: /home/pros/xray/xspatial/makevig/RCS/vignsub.x,v 11.0 1997/11/06 16:31:47 prosb Exp $
#$Log: vignsub.x,v $
#Revision 11.0  1997/11/06 16:31:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:50:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:09  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/15  15:45:24  janet
#*** empty log message ***
#
#Revision 7.0  93/12/27  18:31:43  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:12:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:31:04  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  17:08:09  dennis
#Cast all refs to QP_CDELT1,2, QP_CRVAL1,2, QP_CRPIX1,2 to type real
#(to avoid ill-understood problem since those macros became double precision)
#
#Revision 4.0  92/04/27  14:37:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:52:17  prosb
#General Release 1.1
#
#Revision 2.3  91/08/01  22:08:23  mo
#MC	8/1/91		Correct for change in QPHEAD detector coord units
#
#Revision 2.2  91/07/21  18:30:25  mo
#MC	7/21/91		Updated for general ROSAT 2nd order vignetting
#			for any energy, but only within 20'
#
#Revision 2.1  91/07/08  20:15:05  prosb
#made VMS compatible by changing 20.0 to 20.0D00 in min function
#
#Revision 2.0  91/03/06  23:13:28  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       vignsub
# Project:      PROS -- ROSAT RSDC
# Purpose:      support functions for makevig ( vignetting corrections )
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {1} MC  -- Corrected the ROSAT vignetting code to
#			   reflect current calibration            -- 2/8/91
#               {2} MC  -- Correct the failure of the WCS test
#			   on nom, vs. wcs target positions       -- 2/26/91
#               {3} MC  -- Correct the ROSAT coeff to double precision
#			   Fix the 24 arcminute ROSAT FOV         -- 2/28/91
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
include <math.h>  
include	<mach.h>
include <error.h>		# error messages
include <einstein.h>
include <rosat.h>
include <ext.h>
include <qpoe.h>
include <imhdr.h>
include "vign.h"
include "inst.h"

define	ROSAT_HRI_ARC_SEC_PER_PIXEL	0.5E0
define  ROSAT_PSPC_ARC_SEC_PER_PIXEL	0.5E0

define	VIGN_FATAL	1	# fatal error code from vignmask

#define 	EHRI	0	
#define	IPC	2
#define	PSPC	1
#define  RHRI	4
#define	HRI	0
#define 	ROSAT	2

#define	MAXVIGN	20.0E0
#define	FOV	56.0E0		# field of einstein view in arc-minutes

#
#     Generate an IRAF PMIO mask from the Einstein vignetting function
#
############################################################################
#
# Generate an IRAF PMIO mask
#  It will produce a mask with the dimensions of the instrument.
#  The output maskfile name will match the reference image name with a -.vign
#    extension if the maskfile is not specified
#
############################################################################

double procedure solve_off_axis(tvign,vignrec)
double	tvign			# i: test vignetting value
pointer	vignrec			# i: vignetting record including function coeffs

double	lvign			# l: vignetting value derived from linear fnc
double	r			# l: intermediate answers for radius( off-axis)
double	vcubic(),vquad()
begin
	switch(SAT(vignrec)){
# ROSAT vignetting function is exponential with linear or quadratic theta
	case ROSAT:
#	    if( ORDER(vignrec) == 1)
#	        r = ( log(tvign) - COEFF0(vignrec) ) / COEFF1(vignrec) 
#	    else if( ORDER(vignrec) == 2)
#		r=vquad(vignrec,log(double(tvign)))
	    if( ORDER(vignrec) == 1)
	        r = ( log(tvign) - COEFF0(vignrec) ) / COEFF1(vignrec) 
	    else if( ORDER(vignrec) == 2){
	        lvign = (1.0D0/tvign)*EVNORM(vignrec)
		r=vquad(vignrec,double(lvign))
	    }
# Einstein vignetting function is quadratic in the center and linear outside
	case EINSTEIN:
	    lvign = (1.0D0/tvign)*EVNORM(vignrec)
#	    lvign = (1.0D0/tvign)*136.0D0
	    if(ORDER(vignrec) == 2)
		r=vquad(vignrec,lvign)
	    else if( ORDER(vignrec) == 3)
		r=vcubic(vignrec,lvign)
	    DEFAULT:
	    call error( EA_ERROR,"Error - unknown satellite type")
	}
#	r=min(FOV(vignrec),r)
	return(r)
end

double procedure calc_vign(vignrec,theta)
pointer vignrec		# i: vignetting record ( including function coeffs )
double theta		# i: off-axis angle in arc-minutes

#double	vtemp,atemp	# l: 
double vign		# l: intermediate and final vignetting value
#real exp()

begin
#	switch (SAT[vignrec]){
#	case EINSTEIN:
	    if( ORDER(vignrec) == 1 )
		vign = COEFF1(vignrec)*theta+COEFF0(vignrec)
	    else if( ORDER(vignrec) == 2)
		vign = COEFF2(vignrec)*theta**2 + COEFF1(vignrec)*theta+ 
			COEFF0(vignrec)
	    else if( ORDER(vignrec)== 3)
	    {
		vign=((COEFF3(vignrec)*theta+COEFF2(vignrec))*theta+
			COEFF1(vignrec))*theta+COEFF0(vignrec)
#		vign = COEFF3(vignrec)*theta**3+COEFF2(vignrec)*theta**2+
#		       COEFF1(vignrec)*theta + COEFF0(vignrec)
	    }
	    else if( ORDER(vignrec) == 4 )
		vign = COEFF4(vignrec)*theta**4+COEFF3(vignrec)*theta**3+
			COEFF2(vignrec)*theta**2+COEFF1(vignrec)*theta+
			COEFF0(vignrec)
	    if( vign <= 0.0E0 || vign >= 1.1E0 || theta > FOV(vignrec)+ EPSILON)
#		vign = MAXVIGN(vignrec)
		vign = 20.0
#		vign = 99.0D0
	    else
		vign = 1.0D0 / vign 
#	case ROSAT:
#	    if( abs( COEFF2(vignrec) - 0.0E0 ) > EPSILON )
# 		atemp = COEFF2(vignrec)*theta**2
#	    else
#	        atemp = 0.0
#	    vtemp = atemp+COEFF1(vignrec)*theta+COEFF0(vignrec)
#	    vign = exp(vtemp)
#	DEFAULT:
#	    call error(EA_ERROR,"invalid satellite type for vignetting")
#	}
#	vign = min( vign , MAXVIGN(vignrec) )
	vign = min( vign , 20.0D00 )
	return( vign )
end

procedure read_vign_par(display,im,vignrec,instrec)
int	display		# i: display level
pointer	im		# i: image i/o pointer

pointer vignrec		# o: updated vignetting record
pointer	instrec		# o: updated instrument record

pointer	einvignfile	# l: calibration file name
pointer	energy
#real	clgetr()
int	is_imhead()
int	xray
int	blockfactor,blockfactory
real	physical
#real	xcenter,ycenter
double	renergy,re2	# l: rosat energy in Kev and renergy**2
double	clgetd(),solve_off_axis,calc_vign()
double  testvign
double	test1,test2,test3

pointer imhead
pointer	sp
#bool	fp_equalr()
#real	get_imblk()
double	b[3,3]
data	b / 1.0017D0,  -0.00146D0,     -0.00030D0,
	   -0.00283D0,	0.00152D0,	0.000133D0,
	    0.00226D0, -0.00155D0,     -0.000140D0/
	
begin
	call smark(sp)
	call salloc(einvignfile,SZ_PATHNAME,TY_CHAR)
	call salloc(energy,SZ_FNAME,TY_CHAR)
	xray = is_imhead(im)
	if( xray == NO )
	    call error(VIGN_FATAL,
		"reference image does not contain X-RAY header information")
	call get_imhead(im,imhead)
	if( display >= 2 )
	{
	    call printf("mission: %d instrument: %d\n\n")
	      call pargi(QP_MISSION(imhead))
	      call pargi(QP_INST(imhead))
	}
	if( QP_MISSION(imhead) == ROSAT )
	{
	    SAT(vignrec) = ROSAT
	    renergy = clgetd("rosenergy")
#	    call readcaltab(Memc[einvignfile],Memc[energy],vignrec)
	    re2 = renergy*renergy
	    COEFF2(vignrec) = b(3,1) + b(3,2)*renergy + b(3,3)*re2
	    COEFF1(vignrec) = b(2,1) + b(2,2)*renergy + b(2,3)*re2
	    COEFF0(vignrec) = b(1,1) + b(1,2)*renergy + b(1,3)*re2
	    test3 = COEFF2(vignrec) 
	    test2 = COEFF1(vignrec) 
	    test1 = COEFF0(vignrec) 
#	    COEFF2(vignrec) = clgetd("rquadxsq")
#	    COEFF1(vignrec) = clgetd("rquadx")
#	    COEFF0(vignrec) = clgetd("rquad")
	    ORDER(vignrec) = 2
#	    switch( QP_INST(imhead)){
#	        case PSPC:
#	            INST(vignrec) = PSPC
#		case HRI:
		    INST(vignrec) = QP_INST(imhead)
#		DEFAULT:
#	    	    call error( EA_ERROR,"Error - unknown instrument type")
#	    }
	}
	else if( QP_MISSION(imhead) == EINSTEIN )
	{
	    SAT(vignrec) = EINSTEIN
#	    switch( QP_INST(imhead)){
#	        case IPC:
#	            INST(vignrec) = IPC
#		case HRI:
		    INST(vignrec) = QP_INST(imhead)
#		DEFAULT:
#	    	    call error( EA_ERROR,"Error - unknown instrument type")
#	    }
	    call clgstr("einvignfile",Memc[einvignfile],SZ_PATHNAME)
	    SAT(vignrec) = EINSTEIN
	    call clgstr("energy",Memc[energy],SZ_PATHNAME)
	    call readcaltab(Memc[einvignfile],Memc[energy],vignrec)
#	    EVNORM(vignrec)=clgetd("norm")
#	    FOV(vignrec) = QP_FOV(imhead)
#	    if( FOV(vignrec) == 0.0D0 )
#	        FOV(vignrec) = 56.0D0
#	    MAXVIGN(vignrec) = 1000.0	# initialize too high 
#	    MAXVIGN(vignrec) = calc_vign(vignrec,FOV(vignrec))
#	    testvign = 20.0D0
#	    if( MAXVIGN(vignrec) > testvign )
#	    {
#	        FOV(vignrec) = solve_off_axis(testvign,vignrec)
#		MAXVIGN(vignrec)=calc_vign(vignrec,FOV(vignrec))
#	    }
	}
	    EVNORM(vignrec)=clgetd("norm")
	    FOV(vignrec) = QP_FOV(imhead)
	    if( FOV(vignrec) == 0.0D0 ){
	      if( QP_MISSION(imhead) == ROSAT )
		FOV(vignrec) = 24.0D0
	      else 
		FOV(vignrec) = 56.0D0
	    }
	    else
	        FOV(vignrec) = 56.0D0
	    MAXVIGN(vignrec) = 1000.0	# initialize too high 
	    MAXVIGN(vignrec) = 20.0
#	    MAXVIGN(vignrec) = calc_vign(vignrec,FOV(vignrec))
#	    if( QP_MISSION(imhead) == ROSAT )
#		MAXVIGN(vignrec) = 2.5
	    testvign = 20.0D0
	    if( MAXVIGN(vignrec) > testvign )
	    {
	        FOV(vignrec) = solve_off_axis(testvign,vignrec)
		MAXVIGN(vignrec)=calc_vign(vignrec,FOV(vignrec))
	    }
	XDIM(instrec) = QP_XDIM(imhead)
	YDIM(instrec) = QP_YDIM(imhead)
	blockfactor = DEGTOAS(real(abs(QP_CDELT1(imhead))))
	blockfactory = DEGTOAS(real(abs(QP_CDELT1(imhead))))
#	blockfactor = int( get_imblk(im,1)+.5)
#	blockfactory = int( get_imblk(im,2)+.5)
	if( blockfactor != blockfactory)
	{
	    call eprintf("x arcsec per pixel: %d y arcsec per pixel: %d\n")
	    call pargi(blockfactor)
	    call pargi(blockfactory)
	    call error( VIGN_FATAL,"inconsistent pixel size")
	}
	PIXSCALE(instrec) = DEGTOAS(real(abs(QP_CDELT1(imhead))))
#	blockfactor = PIXSCALE(instrec) / DEGTOAS(QP_INSTPIX(imhead)) + EPSILON
#       Try to determine the block factor by comparing the pixel size
#	with the nominal pixel size  
	switch (QP_INST(imhead)){
	case EINSTEIN_HRI:
	    physical = EINSTEIN_HRI_ARC_SEC_PER_PIXEL
	case EINSTEIN_IPC:
	    physical = EINSTEIN_IPC_ARC_SEC_PER_PIXEL
	case ROSAT_HRI:
	    physical = ROSAT_HRI_ARC_SEC_PER_PIXEL
	case ROSAT_PSPC:
	    physical = ROSAT_PSPC_ARC_SEC_PER_PIXEL
	default:
	    physical = QP_INSTPIX(imhead)
	}
	if( display >= 2){
	    call printf("blockfactor: %d instpix: %f\n")
	       call pargi(blockfactor)
	       call pargr(physical)
	}
	blockfactor = PIXSCALE(instrec) / physical + EPSILON
	if( blockfactor == 0 )
        {
                call eprintf("current pixel: %f original pixel: %f\n")
                call pargr(DEGTOAS(real(abs(QP_CDELT1(imhead)))))
                call pargr(physical)
                call error( VIGN_FATAL,"Block factors less than 1 not supported")
        }
#	XCENTER(instrec) = double(QP_XDET(imhead))/(2.0D0*double(blockfactor))
#	YCENTER(instrec) = double(QP_YDET(imhead))/(2.0D0*double(blockfactor))
	XCENTER(instrec) = real(QP_CRPIX1(imhead))
	YCENTER(instrec) = real(QP_CRPIX2(imhead))

#	XOPTICAL_CENTER(instrec) = int(QP_AVGXOPTI(imhead)/blockfactor+.5E0)
#	YOPTICAL_CENTER(instrec) = int(QP_AVGYOPTI(imhead)/blockfactor+.5E0)
#	XOPTICAL_CENTER(instrec) = int(QP_CRPIX1(imhead)+QP_XAOPTI(imhead)/
#					abs(QP_CDELT1(imhead))/
#					3600.0E0/blockfactor+.5E0)
#	YOPTICAL_CENTER(instrec) = int(QP_CRPIX2(imhead)+QP_YAOPTI(imhead)/
#					abs(QP_CDELT2(imhead))/
#					3600.0E0/blockfactor+.5E0)
	XOPTICAL_CENTER(instrec) = int(real(QP_CRPIX1(imhead))+QP_XAOPTI(imhead)/
					DEGTOAS(real(abs(QP_CDELT1(imhead))))/
					blockfactor+.5E0)
	YOPTICAL_CENTER(instrec) = int(real(QP_CRPIX2(imhead))+QP_YAOPTI(imhead)/
					DEGTOAS(real(abs(QP_CDELT2(imhead))))/
					blockfactor+.5E0)
# no longer used
#	XCORNER(instrec) = XCENTER(instrec)- XDIM(instrec)/(2.0*blockfactor)+1.0
#	YCORNER(instrec) = YCENTER(instrec)- YDIM(instrec)/(2.0*blockfactor)+1.0
#	call skypix_im(im,QP_CRVAL1(imhead),QP_CRVAL2(imhead),xcenter,ycenter) 
#	if( int(QP_CRPIX1(imhead)+EPSILON) != IM_LEN(im,1)/2  ||
#	    int(QP_CRPIX2(imhead)+EPSILON) != IM_LEN(im,2)/2  ||
	XCORNER(instrec) = 1
	YCORNER(instrec) = 1
#  This test failed due to loss of precision during WCS matrix conversions
#    etc.  So we'll give a little extra room 
#	if( !fp_equalr(QP_CRVAL1(imhead),QP_RAPT(imhead)) ||
#	    !fp_equalr(QP_CRVAL2(imhead),QP_DECPT(imhead))   )
	if( abs(real(QP_CRVAL1(imhead))-QP_RAPT(imhead)) > .0005 ||
	    abs(real(QP_CRVAL2(imhead))-QP_DECPT(imhead)) > .0005   )
	{
		call eprintf("image reference different from original pointing direction\n")
		call eprintf("image ref: %f %f pointing pos: %f %f\n")
		    call pargr( real(QP_CRVAL1(imhead)) )
		    call pargr( real(QP_CRVAL2(imhead)) )
		    call pargr( QP_RAPT(imhead) )
		    call pargr( QP_DECPT(imhead) )
	   call error(VIGN_FATAL,"re-referenced vignetting not yet supported\n")
	}

	if( display >= 2 )
	{
	      call printf("arcsec: %f xcenter: %f\n")
		call pargd(PIXSCALE(instrec))
#		call pargi(XCORNER(instrec))
		call pargd(XCENTER(instrec))
	      call printf("fov: %f xopt: %d yopt: %d\n")
	      call pargd(FOV(vignrec))
	      call pargi(XOPTICAL_CENTER(instrec))
	      call pargi(YOPTICAL_CENTER(instrec))
	}
	call mfree(imhead,TY_STRUCT)
	call sfree(sp)
end

double	procedure calc_theta(instrec,x,y,ysq)
pointer instrec
int	x,y
int	ysq			# o: secondary output for convenience
double	theta
begin
	ysq = (y-YOPTICAL_CENTER(instrec))**2
	theta = ysq + (x-XOPTICAL_CENTER(instrec))**2
	if( theta < 0.0D0 )
	    call error(EA_ERROR,"square of off-axis angle < 0")
	theta = sqrt(theta) * PIXSCALE(instrec) / 60.0D0
#	call printf("y: %d theta: %f\n")
#	    call pargi(y)
#	    call pargd(theta)
	return( theta )
end

procedure calc_left(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,x,mirrorx,
		    ysq,vignline)
pointer	instrec
pointer	vignrec
long	axlen[ARB]
short	vignbin
double	vbinres
double	vbinscale
int	x
int	mirrorx
int	ysq
short	vignline[ARB] # input line from exposure file

short	maskvignbin
double	s
double	tvign
int	xsq
int	xrun
int	mxrun,tmxrun
int	mstart

double	solve_off_axis(),calc_vign()

int	temp,itemp,itest
double	calc_theta(),testtheta,test

begin
#	if( x <= XOPTICAL_CENTER(instrec))
	while( x <= XOPTICAL_CENTER(instrec))
	{
#	    tvign = (vignbin-vignbin*vbinres-.5D0) * 
#			vbinscale + vbinscale/2.0D0
	    tvign = (vignbin-vignbin*vbinscale-.5D0) * 
			vbinscale + vbinscale/2.0D0
	    s = solve_off_axis(tvign,vignrec)
	    if( s > FOV(vignrec) )
		s = FOV(vignrec)
	    xsq = int((s*60.0D0/PIXSCALE(instrec))**2-ysq+.5D0)
#  If xsq < 0.0, then we have passed the midpt ( xcenter ), terminate the run
#	at the midpt and continue in the second half for points to the 'right'
#	of center
	    if( xsq <= 0 )
		xrun = XOPTICAL_CENTER(instrec)-x+1
	    else
	    {
		xrun=int(-sqrt(double(xsq))+.5E0)+XOPTICAL_CENTER(instrec)-x+1
		if( xrun <= 0 )
		{
#		    if( x > XCORNER(instrec) || vignbin*vbinres < 1.20E0 )
#		    if( vignbin*vbinres < 1.50E0 )
		    if( xrun < -1 )
		        xrun = XOPTICAL_CENTER(instrec)-x+1
		    else
		    {
		        itemp = YOPTICAL_CENTER(instrec)-sqrt(real(ysq))+.1
		        testtheta = calc_theta(instrec,
				    XOPTICAL_CENTER(instrec),
				    itemp,temp)
		        test = calc_vign(vignrec,testtheta)
		        itest = test / vbinscale + .5D0
		        if( itest  >=  vignbin - 
				       max(1,2*int(tvign)-1))
		            xrun = XOPTICAL_CENTER(instrec)-x+1
		        else
		            xrun = 0
		    }
		}	
	    }
	    xrun = min(axlen[1]-x+1,xrun)
#	    xrun = min(axlen[1]-x,xrun)
	    xrun = max(xrun,0)
	    if( vignbin < 0 )
		maskvignbin = 0
	    else if ( vignbin > int( MAXVIGN(vignrec) /  vbinscale +.1))
#		maskvignbin = 0
		maskvignbin = int( MAXVIGN(vignrec) / vbinscale + .1)
	    else if( vignbin*vbinscale < 1.0D0 )
		maskvignbin = 1.0D0 * vbinscale
	    else
		maskvignbin = vignbin
	    mxrun = min(xrun,mirrorx-XOPTICAL_CENTER(instrec))
	    mstart = mirrorx-mxrun+1
	    if( mstart <= axlen[1]) 
	        tmxrun = mxrun
	    else
		tmxrun = 0
 	    call amovks(maskvignbin,vignline[x],xrun)
	    call amovks(maskvignbin,vignline[mstart],tmxrun)
	    x = x + xrun
	    mirrorx = mirrorx - mxrun 
	    vignbin = vignbin - max(1,2*int(tvign)-1)
	}
end


procedure calc_right(instrec,vignrec,axlen,vignbin,vbinres,vbinscale,x,
		     ysq,vignline)
pointer	instrec
pointer	vignrec
long	axlen[ARB]
short	vignbin
double	vbinres
double	vbinscale
int	x
int	ysq
short	vignline[ARB] # input line from exposure file

short	maskvignbin
double	s
double	tvign
int	xsq
int	xrun
int	temp,itemp,itest

double	solve_off_axis(),calc_vign()
double	calc_theta(),testtheta,test
begin
#	    if( x > XOPTICAL_CENTER(instrec))
	while( x > XOPTICAL_CENTER(instrec) && x <= axlen[1] )
	{
#	    tvign = (vignbin+vignbin*vbinres+.5D0) * vbinscale + vbinscale/2.0D0
	    tvign = (vignbin+vignbin*vbinscale+.5D0) * vbinscale + vbinscale/2.0D0
	    s = solve_off_axis(tvign,vignrec)
	    if( s > FOV(vignrec) )
		s = FOV(vignrec)
	    xsq = int((s*60.0D0/PIXSCALE(instrec))**2-ysq+.5D0)
	    if( xsq < 0 )
	        xrun = int(axlen[1]+.5E0)-x+1
	    else
	    {
	        xrun = int(sqrt(real(xsq))+.5E0)+XOPTICAL_CENTER(instrec)-x+1
		if( xrun <= 0 )
		{
#		    if( x > XCORNER(instrec) || vignbin*vbinres < 1.20E0 )
#		    if( vignbin*vbinres < 1.50E0 )
		    if( xrun < -1 )
		        xrun = int(axlen[1]+.5E0)-x+1
		    else
		    {
		        itemp = YOPTICAL_CENTER(instrec)-sqrt(real(ysq))+.1
		        testtheta = calc_theta(instrec,
				    axlen[1],
				    itemp,temp)
		        test = calc_vign(vignrec,testtheta)
		        itest = test / vbinscale + .5D0
		        if( itest  >=  vignbin - 
				       max(1,2*int(tvign)-1))
		            xrun = int(axlen[1]+.5E0)-x+1
		        else
		            xrun = 0
		    }
		}	
	    }
	    if( vignbin >= int( MAXVIGN(vignrec) /  vbinscale +.1))
	  	xrun = axlen[1]-x+1
	    xrun = min(axlen[1]-x+1,xrun)
	    xrun = max(xrun,0)
	    vignbin = vignbin + max(1,2*int(tvign+.5)-1)
	    if( vignbin < 0 )
	        maskvignbin = 0
	    else if ( vignbin > int( MAXVIGN(vignrec) /  vbinscale +.1))
	        maskvignbin = int( MAXVIGN(vignrec) / vbinscale +.1)
	    else if( vignbin*vbinscale < 1.0E0 )
		maskvignbin = 1.0E0 * vbinscale
	    else
	        maskvignbin = vignbin
	    call amovks(maskvignbin,vignline[x],xrun)
	    x = x + xrun
	}
end

procedure dbdisp(line,vignbin,vignline,instrec,axlen)
int line
int vignbin
short vignline[ARB]

pointer instrec
long	axlen[ARB]
int	foo

begin
        foo = axlen[1]/2
        call printf("line: %d vignbin: %d\n")
          call pargi(line)
          call pargs(vignbin)
        call printf("vignline: %d %d %d\n")
          call pargs(vignline[1])
          call pargs(vignline[foo])
          call pargs(vignline[axlen[1]])
end

procedure dblinedisp(line,vignline,instrec,axlen)
int line
short vignline[ARB]

pointer instrec
long	axlen[ARB]

int i
begin
	for(i=1;i<=axlen[1];i=i+1)
	{
	    if( vignline[i] == 100 )
	    {
	        call printf("WARNING: line: %d entry: %d value: %d\n")
		  call pargi(line)
		  call pargi(i)
		  call pargs(vignline[i])
	    }
	}
end

procedure readcaltab(calfile,energy,vignrec)
char	calfile[ARB]	# i: cal correction file name
char	energy[ARB]	# i: requested energy
pointer	vignrec		# o: calibration values

pointer	colptr		# l: table column pointer
pointer tb		# l: table descriptor

bool	nullflag[10]	# l: undefined data flag

int	first		# l: row index
int	last		# l: row index
int	num

double	chisq		# l: chisq of polynomial fit
double	coeff[10]	# l: cal fit coefficients
double	order		# l: polynomial order
pointer	tbtopn()

begin
	tb=tbtopn(calfile,READ_ONLY,0)
	num=1
	call tbcfnd(tb,energy,colptr,num)
	first = 1
	last = 6
	call tbcgtd(tb,colptr,coeff,nullflag,first,last)
	COEFF0(vignrec)=coeff[1]
	COEFF1(vignrec)=coeff[2]
	COEFF2(vignrec)=coeff[3]
	COEFF3(vignrec)=coeff[4]
	COEFF4(vignrec)=coeff[5]
	COEFF5(vignrec)=coeff[6]
	first = 7
	last = 7
	call tbcgtd(tb,colptr,chisq,nullflag,first,last)
	first = 8
	last = 8
	call tbcgtd(tb,colptr,order,nullflag,first,last)
	ORDER(vignrec)=int(order+.5)
	call tbtclo(tb)
	if( ORDER(vignrec) == 3 )  # precompute useful cubic solution constants
	{
	    A1(vignrec)=COEFF2(vignrec)/COEFF3(vignrec)
	    A2(vignrec)=COEFF1(vignrec)/COEFF3(vignrec)
	    QQ(vignrec)=(A1(vignrec)*A1(vignrec)-3.0D0*A2(vignrec))/9.0D0
	    RR(vignrec)=2.0D0*A1(vignrec)**3-9.0D0*A1(vignrec)*A2(vignrec)
	    QQ3(vignrec)=QQ(vignrec)**3
	    THIRDA1(vignrec)=A1(vignrec)/3.0D0
	}
	end

double	procedure vquad(vignrec,lvign)
pointer vignrec
double	lvign

double	deter
double	r1
double	r2
double	r
double	q
double	one

begin
	one=1.0D0
	deter = COEFF1(vignrec)**2-
		        4.0D0*COEFF2(vignrec)*(COEFF0(vignrec)-lvign)
        if( deter > 0.0E0 )
	    deter = sqrt(deter)
        else
	    deter = 1.0E0
	q  =-.5D0*(COEFF1(vignrec)+sign(one,COEFF1(vignrec))*deter)
	r1 = q/COEFF2(vignrec)
        r2 = (COEFF0(vignrec)-lvign)/q
        r  = max(r1,r2)
	return(r)
end

#double	procedure ovcubic(vignrec,lvign)
#pointer vignrec
#double	lvign

#double	r1
#double	r2
#double	r3
#double	r

#double	p,q,psq
#double	a,b,power
#double	aa,bb,temp
#complex	root,halfb
#begin
#	p=COEFF2(vignrec)/COEFF3(vignrec)
#	q=COEFF1(vignrec)/COEFF3(vignrec)
#	r=(COEFF0(vignrec)-lvign)/COEFF3(vignrec)
#	psq=p*p
#	a=(q-psq/3.0D0)	
#	b=(2.0D0*psq*p-9.0D0*p*q)/27.0D0 + r
#	temp=b*b/4.0D0+(a*a*a)/27.0D0
#	if( temp < 0.0D0 ) 
#	    call printf("Warning negative root\n")
#	root=sqrt(complex(temp))
#	halfb=-(b/2.0D0)
#	power=1.0E0/3.0E0
#	aa=(complex(halfb)+root)**power
#	bb=(complex(halfb)-root)**power
#	r1=aa+bb
#	r2= -r1/2.0D0+(aa-bb)/2.0D0*sqrt(complex(-3.0D0))
#	r3= -r1/2.0D0-(aa-bb)/2.0D0*sqrt(complex(-3.0D0))
#	return(r)
#end

double	procedure vcubic(vignrec,lvign)
pointer vignrec
double	lvign

double	minusone
double	one
double	r1
double	r2
double	r3
double	r
double	foo

#double	a1,a2,a3,qq,rr
double	a3,rr
double	rr2
double	theta,rootq
begin
#	1=COEFF2(vignrec)/COEFF3(vignrec)
#	a2=COEFF1(vignrec)/COEFF3(vignrec)
	a3=(COEFF0(vignrec)-lvign)/COEFF3(vignrec)
#	qq=(a1*a1-3.0D0*a2)/9.0D0
	rr=(RR(vignrec)+27.0D0*a3)/54.0D0
#	rr=(2.0D0*a1**3-9.0D0*a1*a2+27.0D0*a3)/54.0D0
#	qq3=qq**3
	rr2=rr*rr

#	thirda1=a1/3.0D0
#	call printf("QQ %f rr2 %f\n")
#	  call pargd(QQ3(vignrec))
#	  call pargd(rr2)
	if( QQ3(vignrec)-rr2 >= 0.0E0 )
	{
	    theta=acos(rr/sqrt(QQ3(vignrec)))
	    rootq=-2.0D0*sqrt(QQ(vignrec))
	    r1=rootq*cos(theta/3.0D0)-THIRDA1(vignrec)
	    r2=rootq*cos((theta+2.0D0*PI)/3.0D0)-THIRDA1(vignrec)
	    r3=rootq*cos((theta+4.0D0*PI)/3.0D0)-THIRDA1(vignrec)
	    if( r1 <0.0D0 )
		r1=1000.0
	    if( r2 < 0.0D0)
		r2=1000.0
	    if( r3 < 0.0D0 )
		r3=1000.0
	    r=min(r1,r2,r3)
	}
	else
	{
	    r1=(sqrt(rr2-QQ3(vignrec))+abs(rr))**(1.0D0/3.0D0)
	    minusone=-1.0D0
	    one=1.0D0
	    foo=(r1+QQ(vignrec)/r1)
	    r=-sign(one,rr)*(r1+QQ(vignrec)/r1)-THIRDA1(vignrec)
	    if( r <= 0.0 )
		r=100.0D0
	}
	return(r)
end

###############################################################################
#
#	vigngetoutfile
#
#	Check the options for the output file and apply the necessary
#	    extensions.  The file will be written to temp and renamed
#	    to maskfile later.
#	Error generated if file exists and clobber is no
#	Vignetting mask extension will be "_vign.pl"
#
###############################################################################

procedure vigngetoutfile(ref_image,maskfile,clobber,len,temp)
char	ref_image[ARB]	# i:	name of reference image
char	maskfile[ARB]	# i:	user request for output mask name

bool	clobber		# i:	can existing file be deleted flag

int	len		# i:	length of temp file

char	temp[ARB] 	# o:	temporary name for output mask file

bool streq()		# l:	routine

begin
#  Create a maskfile name from the reference image if desired
	call rootname(ref_image,maskfile,EXT_VIGNETTING,len)
#  Check if NO output file is specified
	if( streq(maskfile,"NONE"))
	    call error(VIGN_FATAL,"Output file required for this task (not NONE)")
#     Check if the file already exists - if so store the file in a tempfile
	call clobbername(maskfile,temp,clobber,len)
end


