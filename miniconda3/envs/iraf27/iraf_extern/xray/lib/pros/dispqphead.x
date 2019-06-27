#$Header: /home/pros/xray/lib/pros/RCS/dispqphead.x,v 11.0 1997/11/06 16:20:21 prosb Exp $
#$Log: dispqphead.x,v $
#Revision 11.0  1997/11/06 16:20:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:25  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:06  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:38:04  mo
#no changes
#
#Revision 6.0  93/05/24  15:44:16  prosb
#General Release 2.2
#
#Revision 5.1  93/01/27  18:30:15  mo
#MC	1/27/93		Fix the MISSION and TELESCOPE string display`
#
#Revision 5.0  92/10/29  21:16:25  prosb
#General Release 2.1
#
#Revision 4.2  92/10/16  20:26:14  mo
#MC	10/16/92		Update for double precision WCS paramters
#
#Revision 4.1  92/10/08  09:19:49  mo
#MC	10/8/92		Improved the QPHEAD display with more
#			levels and better units
#
#Revision 4.0  92/04/27  13:47:22  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  14:37:46  mo
#No changes
#
#Revision 3.0  91/08/02  00:48:56  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:46  pros
#General Release 1.0
#
#
# Module:       DISP_QPHEAD
# Project:      PROS -- ROSAT RSDC
# Purpose:      Create an ASCII Display of an IRAF/PROS QPOE header
# External:     disp_qphead, disp_imhead
# Local:        < routines which are NOT intended to be called by applications>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- initial version 		       -- 1988
#               {1} mc    -- updated for detector coordinates  -- 1/91
#               {n} <who> -- <does what> -- <when>
#
include <math.h>
include <wfits.h>
include <qpoe.h>
include <missions.h>

procedure disp_qphead(qphead,title,display)

pointer qphead				# i: header pointer
char	title[ARB]
int	display				# i: display level
int	strlen()
begin

entry disp_imhead(qphead,title,display)

	call printf("\n\t\t\tQPOE Header\n")

	call printf("Mission:\t\t%s\nInst:\t\t\t%s\n")
	switch(QP_MISSION(qphead)){
	case EINSTEIN:
	    call pargstr("EINSTEIN")
	    switch(QP_INST(qphead)){
	    case EINSTEIN_HRI:
		call pargstr("HRI")
	    case EINSTEIN_IPC:
		call pargstr("IPC")
	    default:
		call pargstr("Unknown")
	    }
	case ROSAT:
	    call pargstr("ROSAT")
	    switch(QP_INST(qphead)){
	    case ROSAT_HRI:
		call pargstr("HRI")
	    case ROSAT_PSPC:
		call pargstr("PSPC")
	    default:
		call pargstr("Unknown")
	    }
	case ASTROD:
	    call pargstr("ASTRO-D")
	    switch(QP_INST(qphead)){
	    case ASTROD_SIS:
		call pargstr("SIS")
	    case ASTROD_GIS:
		call pargstr("GIS")
	    default:
		call pargstr("Unknown")
	    }
	default:
	    if( strlen(QP_MISSTR(qphead)) != 0 )
		call pargstr(QP_MISSTR(qphead))
	    else
		call pargstr("Unknown")
	    if( strlen(QP_INSTSTR(qphead)) != 0 )
		call pargstr(QP_INSTSTR(qphead))
	    else
		call pargstr("Unknown")
	    call pargstr("Unknown")
	}
	call printf("Filter:\t\t\t%-d\n")
	  call pargi(QP_FILTER(qphead))
	call printf("Object:\t\t%-s\n")
	    call pargstr(title)
	call printf("PI:\t\t%-s\n")
	    call pargstr(QP_SEQPI(qphead))
	call flush(STDOUT)

	call printf("\nWCS Pointing Information:\n")
#	if( display > 2 ) {
#	call printf("RADECSYS:\t\t%-s\n")
#	  call pargstr(QP_RADECSYS(qphead))
#	}
	call printf("EQUINOX:\t\t%-g\t\tSYSTEM:\t%-s\t(FK4=B,FK5=J)\n")
	  call pargr(QP_EQUINOX(qphead))
	  call pargstr(QP_RADECSYS(qphead))
	if( display > 2 ) {
	call printf("CTYPE1:\t\t\t%-s\tCTYPE2:\t\t\t%-s\n")
	  call pargstr(QP_CTYPE1(qphead))
	  call pargstr(QP_CTYPE2(qphead))
	}
	call printf("RA, Dec:\t\t%.4H\t%.4h\n")
	  call pargd(QP_CRVAL1(qphead))
	  call pargd(QP_CRVAL2(qphead))
	if( display > 1) {
	call printf("Reference pixel:\t%-g\t\t%-g\n")
	  call pargd(QP_CRPIX1(qphead))
	  call pargd(QP_CRPIX2(qphead))
	call printf("Pixel size:\t\t%-g\t%-g\t(degrees) \n")
	  call pargd(QP_CDELT1(qphead))
	  call pargd(QP_CDELT2(qphead))
	call printf("Pixel size:\t\t%-g\t%-g\t(arcsec) \n")
	  call pargd(QP_CDELT1(qphead)*3600.0E0)
	  call pargd(QP_CDELT2(qphead)*3600.0E0)
	call printf("Rotation angle:\t\t\t%-g\t(degrees)\n")
	  call pargr(QP_CROTA2(qphead))
	}
	call flush(STDOUT)

	call printf("\nObs Start/End Information:\n")
	call printf("MJD-OBS:\t\t%-g\n")
	  call pargr(QP_MJDOBS(qphead))
	call printf("DATE-OBS:\t\t%-s\tTIME-OBS:\t%-s\n")
	  call pargstr(QP_DATEOBS(qphead))
	  call pargstr(QP_TIMEOBS(qphead))
	call printf("DATE-END:\t\t%-s\tTIME-END:\t%-s\n")
	  call pargstr(QP_DATEEND(qphead))
	  call pargstr(QP_TIMEEND(qphead))
	call printf("Exposure Time:\t\t%-g\n")
	  call pargd(QP_EXPTIME(qphead))
	call flush(STDOUT)

	call printf("\nObs Identification Information:\n")
	if( display > 2 ){
	call printf("Obs ID:\t\t\t%-s\n")
	  call pargstr(QP_OBSID(qphead))
	call printf("Subinstrument:\t\t%d\n")
	  call pargi(QP_SUBINST(qphead))
	call printf("Mode:\t\t\t%-d\n")
	  call pargi(QP_MODE(qphead))
	call printf("Obsv:\t\t\t%-d\n")
	  call pargi(QP_OBSERVER(qphead))
	}
	if( display > 1){
	call printf("Country:\t\t%-s\n")
	call pargstr(QP_COUNTRY(qphead))
	}
	call flush(STDOUT)

	call printf("\nEvent/Image Reference Information:\n")
	call printf("Detector Angle:\t\t%-g\t(degrees)\n")
	  call pargr(QP_DETANG(qphead))
	if( display > 2 ){
	call printf("S/C start MJD:\t\t%-g\n")
	  call pargd(double(QP_MJDRDAY(qphead))+QP_MJDRFRAC(qphead))
	call printf("Event offset:\t\t%-g\n")
	  call pargr(QP_EVTREF(qphead))
	}
	call flush(STDOUT)

	call printf("\nStandard Processing Results:\n")
	if( display > 1 ){
	call printf("On Time:\t\t%-g\n")
	  call pargd(QP_ONTIME(qphead))
	}
	call printf("Live Time:\t\t%-g\nDead Time corr:\t\t%-g\n")
	  call pargd(QP_LIVETIME(qphead))
	  call pargr(QP_DEADTC(qphead))
#	call printf("Total events:\t\t%-d\n")
#	  call pargi(QP_TOTEV(qphead))
	if( display > 2 ){
	call printf("Bkgd Density:\t\t%-g\n")
	  call pargr(QP_BKDEN(qphead))
	call printf("Live Time fac (min,max):%-g %-g\n")
	  call pargr(QP_MINLTF(qphead))
	  call pargr(QP_MAXLTF(qphead))
	}
	if( display > 3 ){
	call printf("Avg Optical off (x,y):\t%-g %-g\n")
	  call pargr(QP_XAOPTI(qphead))
	  call pargr(QP_YAOPTI(qphead))
	call printf("Avg Asp off (x,y):\t%-g %-g\n")
	  call pargr(QP_XAVGOFF(qphead))
	  call pargr(QP_YAVGOFF(qphead))
	call printf("Avg Asp Rot:\t\t%-g\n")
	  call pargr(QP_RAVGROT(qphead))
	call printf("Avg Asp RMS (x,y,rot):\t%-g %-g %-g\n")
	  call pargr(QP_XASPRMS(qphead))
	  call pargr(QP_YASPRMS(qphead))
	  call pargr(QP_RASPRMS(qphead))
	}
	call flush(STDOUT)

	if( display > 2 ){
	call printf("\nStatic Instrument Parameters:\n")
	call printf("Target (RA,Dec):\t\t%-g %-g\n")
	  call pargr(QP_RAPT(qphead))
	  call pargr(QP_DECPT(qphead))
	call printf("Orig det center (x,y):\t\t%-d %-d\n")
	  call pargi(QP_XPT(qphead))
	  call pargi(QP_YPT(qphead))
	}
	call printf("Detector Size:\t\t%-d \t\t%-d\t\t( x,y instument pixels )\n")
	  call pargi(QP_XDET(qphead))
	  call pargi(QP_YDET(qphead))
	call printf("Detector Pixel Size:\t%-g \t%-g\t( x,y arcsec)\n")
	  call pargr(QP_INPXX(qphead)*3600)  # degrees -> arcsec
	  call pargr(QP_INPXY(qphead)*3600)  # degrees -> arcsec
	if( display > 2 ){
	call printf("Field of View:\t\t\t%-g\n")
	  call pargr(QP_FOV(qphead))
	call printf("Channels:\t\t\t%-d\n")
	  call pargi(QP_CHANNELS(qphead))
	}
	call printf("Optical axis:\t\t %-g\t\t%-g\t\t( x,y detector pixels )\n")
	  call pargr(QP_XDOPTI(qphead))
	  call pargr(QP_YDOPTI(qphead))
	call flush(STDOUT)

#	call printf("\n(All angles are in degrees)\n")
	call flush(STDOUT)
end
