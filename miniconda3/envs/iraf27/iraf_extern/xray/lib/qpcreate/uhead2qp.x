#$Header: /home/pros/xray/lib/qpcreate/RCS/uhead2qp.x,v 11.1 1999/09/21 15:21:42 prosb Exp $
#$Log: uhead2qp.x,v $
#Revision 11.1  1999/09/21 15:21:42  prosb
#JCC(5/98) - no change to STARTYEAR/STOPYEAR because of einstein data
#          - change QP_DATEOBS from DD/MM/YY to YYYY-MM-DD
#
#Revision 11.0  1997/11/06 16:22:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:10  prosb
#General Release 2.4
#
#Revision 8.1  1995/08/15  21:35:28  prosb
#Added lines to set QP_INDEXX and QP_INDEXY to default values
#of 'x' and 'y'. This allows programs which read from UHEADs
#(such as xpr2qp) to have indices automatically set.  This is
#necessary for QPOE creation.
#
#Revision 8.0  1994/06/27  14:34:32  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:18:14  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:35:08  mo
#MC	10/1/93		Needed to invert the BINNED ROLL for Einstein
#
#Revision 6.0  93/05/24  15:59:36  prosb
#General Release 2.2
#
#Revision 5.1  93/01/27  18:26:47  mo
#MC	1/27/93		Added MISSION and TELESCOPE strings to header
#
#Revision 5.0  92/10/29  21:19:43  prosb
#General Release 2.1
#
#Revision 4.3  92/10/16  20:23:07  mo
#MC	10/16/92		Updated disp_qphead calling sequence
#
#Revision 4.2  92/06/22  16:02:25  jmoran
#JMORAN added call to "fix_dead_time_cf"
#
#Revision 4.1  92/06/18  18:00:39  mo
#MC	6/18/92		Add correction for LEAPSECONDS to Einstein
#			start times.
#
#Revision 4.0  92/04/27  13:53:47  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  12:15:07  mo
#MC	4/13/92		Add the port of the Einstein SCIDMM routine
#			needed to convert the BLT records.
#
#Revision 3.1  91/12/16  11:23:08  mo
#MC	12/16/91	Update the SUBINST calculation ( need to add 1)
#
#Revision 3.0  91/08/02  01:05:37  prosb
#General Release 1.1
#
#Revision 2.1  91/07/30  20:49:51  mo
#MC	no changes - just a compiler bug
#
#Revision 2.0  91/03/07  00:12:11  pros
#General Release 1.0
#
#
# Module:       UHEAD2QP.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Einstein universal header-specific routines for qpoe creation
# External:     uhd_open, uhd_get, uhd_close
# 		uda_open, uda_get, uda_close
# Local:        NONE
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm	  -- initial version 1988
#               {1} mc    -- added support for detector coords  -- 1/91
#               {n} <who> -- <does what> -- <when>

include <math.h>
include <mach.h>
include <einstein.h>
include <qpoe.h>
include <clk.h>

#
#  UHD_OPEN -- open the header file
#
procedure uhd_open(fname, fd, convert, display, argv)

char	fname[ARB]			# i: header file name
int	fd				# o: file descriptor
int	convert				# i: data conversion flag
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	open()				# l: open a file

begin
entry	uda_open(fname,fd,convert,display,argv)       # uda open is identical

	argv = argv			# avoid compile warning
	convert = convert
	if( display >=5 ){
	    call printf("opening header file:\t%s\n")
	    call pargstr(fname)
	}
	fd = open(fname, READ_ONLY, BINARY_FILE)
end

#
#  UHD_CLOSE -- open the header file
#
procedure uhd_close(fd, qphead, display, argv)

int	fd				# i: header fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
entry	uda_close(fd, qphead, display, argv)
	qphead = qphead			# avoid compile warning
	argv = argv			# avoid compile warning
	if( display >=5 )
	    call printf("closing header file\n")
	call close(fd)
end

#
# UHD_GET -- read the header
#
procedure uhd_get(fd, convert, qphead, display, argv)

int	fd				# i: header fd
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header
int	display				# i: display level
pointer	argv				# o: pointer to arg list

short	uhead[SZ_UHEAD]			# l: universal header
int	nchars				# l: SPP chars read 
int	read()				# l: read data
int	clktime()			# l: get clock time, seconds
int	tsec				# l: temp seconds
int	uda				# l: flag for input UDA file instead
					#    of UHEAD
short	mnf
long	mjf
int	dtt				# l: temporary day no of mission
int	dutc				# l: number of leap seconds
real	foo
real	aspbuf[3]			# l: aspect values
real	bsbuf[3]			# l: boresight values
double	dtemp				# l: junk double
pointer	refclk				# l: reference clock struct
pointer	sp				# l: stack pointer

short	cvti2()				# l: convert integer*2
int	cvti4()				# l: convert integer*4
real	cvtr4()				# l: convert real*4
double	cvti6()				# l: i*6 -> r*8
double	mutjd()				# l: convert ut to mjd
begin
	uda = UHEAD 
	go to 99
entry uda_get(fd, convert, qphead, display, argv)
	uda = UDA 
	# mark the stack
 99 	call smark(sp)
	# allocate space for clock conversion
	call salloc(refclk, LEN_CLK, TY_STRUCT)

	# get the DG header - the uda header is only half as long
	nchars = read(fd, uhead, SZ_UHEAD*SZ_SHORT/(1+uda))
	if( nchars != SZ_UHEAD*SZ_SHORT/(1+uda))
	    call error(1, "unexpected EOF reading universal header")

	# fill in information from the universal header
	# try to follow the order of the qpoe.h struct
	# (just to make checking easier)
	QP_MISSION(qphead) = EINSTEIN
	call strcpy("EINSTEIN",QP_MISSTR(qphead),20)
	if( uda == UHEAD){
		QP_INST(qphead) = EINSTEIN + 1 + 
				and(int(cvti2(U_DATAFORMAT(uhead),convert)),
				EINSTEIN_INSTMASK)
	}
	else if( uda == UDA){

		QP_INST(qphead) = EINSTEIN + 1 + 
				and(int(cvti2(UD_DATAFORMAT(uhead),convert)),
				EINSTEIN_INSTMASK)
	}
	if(QP_INST(qphead) == EINSTEIN_IPC)
		call strcpy("IPC",QP_INSTSTR(qphead),20)
	if(QP_INST(qphead) == EINSTEIN_HRI)
		call strcpy("HRI",QP_INSTSTR(qphead),20)
	call strcpy(RADECSYS, QP_RADECSYS(qphead), SZ_WCSSTR)
	QP_EQUINOX(qphead) = EINSTEIN_EQUINOX
	call strcpy(CTYPE1, QP_CTYPE1(qphead), SZ_WCSSTR)
	call strcpy(CTYPE2, QP_CTYPE2(qphead), SZ_WCSSTR)
	if( uda == UHEAD ){
	    QP_CRVAL1(qphead) = RADTODEG(cvtr4(U_BINNEDRA(uhead), convert))
	    QP_CRVAL2(qphead) = RADTODEG(cvtr4(U_BINNEDDEC(uhead), convert))
#	    QP_CROTA2(qphead) = RADTODEG(cvtr4(U_BINNEDROLL(uhead), convert))
# D Plummer says this needs to be negated
	    QP_CROTA2(qphead) = - RADTODEG(cvtr4(U_BINNEDROLL(uhead), convert))
	}
	else if( uda == UDA ) {
	    QP_CRVAL1(qphead) = RADTODEG(cvtr4(UD_BINNEDRA(uhead), convert))
	    QP_CRVAL2(qphead) = RADTODEG(cvtr4(UD_BINNEDDEC(uhead), convert))
# D Plummer says this needs to be negated
#	    QP_CROTA2(qphead) = RADTODEG(cvtr4(UD_BINNEDROLL(uhead), convert))
	    QP_CROTA2(qphead) = - RADTODEG(cvtr4(UD_BINNEDROLL(uhead), convert))
	}
	switch(QP_INST(qphead)){
	case EINSTEIN_IPC:
	    QP_CRPIX1(qphead) = EINSTEIN_IPC_TANGENT_X
	    QP_CRPIX2(qphead) = EINSTEIN_IPC_TANGENT_Y
# negate the cdelts to get ra, dec transformation correctly
	    QP_CDELT1(qphead) = -EINSTEIN_IPC_ARC_SEC_PER_PIXEL/3600.0
	    QP_CDELT2(qphead) = EINSTEIN_IPC_ARC_SEC_PER_PIXEL/3600.0
	case EINSTEIN_HRI:
	    QP_CRPIX1(qphead) = EINSTEIN_HRI_TANGENT_X
	    QP_CRPIX2(qphead) = EINSTEIN_HRI_TANGENT_Y
	    QP_CDELT1(qphead) = -EINSTEIN_HRI_ARC_SEC_PER_PIXEL/3600.0
	    QP_CDELT2(qphead) = EINSTEIN_HRI_ARC_SEC_PER_PIXEL/3600.0
	}

	# get modified JD of start of obs
	call aclri(Memi[refclk], LEN_CLK)
	if( uda == UHEAD){
#JCC(5/98) - this is for einstein data, so keep 1900 for STARTYEAR/STOPYEAR
	    YEAR(refclk) = cvti2(U_STARTYEAR(uhead),convert) + 1900
	    DAY(refclk) = cvti2(U_STARTDAY(uhead),convert)
	    tsec = cvti4(U_STARTTIME(uhead),convert)/1000
	    HOUR(refclk) = tsec/3600
	    MINUTE(refclk) = (tsec-HOUR(refclk)*3600)/60
	    SECOND(refclk) = tsec-(HOUR(refclk)*3600)-(MINUTE(refclk)*60)
	    FRACSEC(refclk) = (double(cvti4(U_STARTTIME(uhead),convert)) -
			   tsec*1000)/1000.D0
	}
	else if( uda == UDA){
	    YEAR(refclk) = 0
	    DAY(refclk) = 0
	    tsec = 0
	    HOUR(refclk) = 0
	    MINUTE(refclk) = 0
	    SECOND(refclk) = 0
	    FRACSEC(refclk) = 0
	}
	QP_MJDOBS(qphead) = mutjd(MJDREFYEAR, MJDREFDAY, refclk) + MJDREFOFFSET
#JCC(5/98) - change QP_DATEOBS from DD/MM/YY to YYYY-MM-DD
	#call sprintf(QP_DATEOBS(qphead), SZ_QPSTR, "%02d/%02d/%02d")
	#call pargi(MDAY(refclk))
	#call pargi(MONTH(refclk))
	#call pargi(mod(YEAR(refclk),100))
	call sprintf(QP_DATEOBS(qphead), SZ_QPSTR, "%04d/%02d/%02d")
	call pargi(YEAR(refclk))
	call pargi(MONTH(refclk))
	call pargi(MDAY(refclk))

	call sprintf(QP_TIMEOBS(qphead), SZ_QPSTR, "%02d:%02d:%02d")
	call pargi(HOUR(refclk))
	call pargi(MINUTE(refclk))
	call pargi(SECOND(refclk))
	
	# get stop time as a string
	call aclri(Memi[refclk], LEN_CLK)
	if( uda == UHEAD ){
#JCC(5/98) - this is for einstein data, so keep 1900 for STARTYEAR/STOPYEAR
	    YEAR(refclk) = cvti2(U_STOPYEAR(uhead),convert) + 1900
	    DAY(refclk) = cvti2(U_STOPDAY(uhead),convert)
	    tsec = cvti4(U_STOPTIME(uhead),convert)/1000
	    HOUR(refclk) = tsec/3600
	    MINUTE(refclk) = (tsec-HOUR(refclk)*3600)/60
	    SECOND(refclk) = tsec-(HOUR(refclk)*3600)-(MINUTE(refclk)*60)
	    FRACSEC(refclk) = (double(cvti4(U_STOPTIME(uhead),convert)) -
			   tsec*1000)/1000.D0
	}
	else if(uda == UDA){
	    YEAR(refclk) = 0
	    DAY(refclk) = 0
	    tsec = 0
	    HOUR(refclk) = 0
	    MINUTE(refclk) = 0
	    SECOND(refclk) = 0
	    FRACSEC(refclk) = 0
	}

	dtemp = mutjd(MJDREFYEAR, MJDREFDAY, refclk) + MJDREFOFFSET
#JCC(5/98) - change QP_DATEEND from DD/MM/YY to YYYY-MM-DD
	call sprintf(QP_DATEEND(qphead), SZ_QPSTR, "%04d/%02d/%02d")
	#call pargi(MDAY(refclk))
	#call pargi(MONTH(refclk))
	#call pargi(mod(YEAR(refclk),100))
	call pargi(YEAR(refclk))
	call pargi(MONTH(refclk))
	call pargi(MDAY(refclk))

	call sprintf(QP_TIMEEND(qphead), SZ_QPSTR, "%02d:%02d:%02d")
	call pargi(HOUR(refclk))
	call pargi(MINUTE(refclk))
	call pargi(SECOND(refclk))
	
	call sprintf(QP_OBSID(qphead), SZ_QPSTR, "%d")
	if( uda == UHEAD){
	    call pargs(cvti2(U_SEQNO(uhead), convert))
	    QP_SUBINST(qphead) = and(int(cvti2(U_INSTID(uhead), convert)),
			     EINSTEIN_SUBMASK)/4096 + 1
	    QP_OBSERVER(qphead) = cvti2(U_OBSERVER(uhead), convert)
	    call strcpy("USA", QP_COUNTRY(qphead), SZ_QPSTR)
	    QP_MODE(qphead) = 1 + and(int(cvti2(U_DATAFORMAT(uhead), convert)),
			     EINSTEIN_MODEMASK)/4
	    QP_FILTER(qphead) = and(int(cvti2(U_INSTID(uhead), convert)),
			     EINSTEIN_FILTMASK)/256
	    QP_DETANG(qphead) = RADTODEG(cvtr4(U_ROLL(uhead), convert))
	}
	else if( uda == UDA){
	    call pargs(cvti2(UD_SEQNO(uhead), convert))
	    QP_SUBINST(qphead) = and(int(cvti2(UD_INSTID(uhead), convert)),
			     EINSTEIN_SUBMASK)/4096 + 1
	    QP_OBSERVER(qphead) = cvti2(UD_OBSERVER(uhead), convert)
	    call strcpy("USA", QP_COUNTRY(qphead), SZ_QPSTR)
	    QP_MODE(qphead) = 1 + and(int(cvti2(UD_DATAFORMAT(uhead), convert)),
			     EINSTEIN_MODEMASK)/4
	    QP_FILTER(qphead) = and(int(cvti2(UD_INSTID(uhead), convert)),
			     EINSTEIN_FILTMASK)/256
	    QP_DETANG(qphead) = RADTODEG(cvtr4(UD_ROLL(uhead), convert))
	}
	QP_MJDRDAY(qphead) = EINSTEIN_MJDRDAY
	QP_MJDRFRAC(qphead) = EINSTEIN_MJDRFRAC
	QP_EVTREF(qphead) = EINSTEIN_EVTREF
	if( uda == UHEAD){
            dtt=cvti2(U_DAYCNT(uhead),convert)
            if (dtt <= 365) {
                dutc=1
            }
            else if (dtt <=730) {
                dutc=2
            }
            else {
                dutc=3
            }
            QP_TBASE(qphead) = double(dtt)*8.64D4 + double(dutc) +
            			cvti6(U_STARTMICRO(uhead),convert)*1.0D-6
	    QP_ONTIME(qphead) = cvtr4(U_ONTIME(uhead), convert)
	    QP_LIVETIME(qphead) = cvtr4(U_LIVETIME(uhead), convert)
	    if( QP_LIVETIME(qphead) > EPSILOND ) 
        	QP_DEADTC(qphead) = QP_ONTIME(qphead) / QP_LIVETIME(qphead)
	    else{
	        QP_DEADTC(qphead) = cvtr4(U_LIVETCOR(uhead), convert)
		foo = QP_DEADTC(qphead)
		if( abs(QP_DEADTC(qphead)) < EPSILON ){
		    QP_DEADTC(qphead) = 1.0
		}
		QP_LIVETIME(qphead) = QP_ONTIME(qphead)
	    }
	    QP_BKDEN(qphead) = 0.0
	    call scidmm(cvti4(U_STARTSCID(uhead),convert),mjf,mnf)
	    QP_HUT(qphead) = 0
	    call bitmov(mjf,1,QP_HUT(qphead),8,25)
	    aspbuf[1] = -cvtr4(U_AVGYOFF(uhead), convert)
	    aspbuf[2] = cvtr4(U_AVGZOFF(uhead), convert)
	    aspbuf[3] = -cvtr4(U_AVGROT(uhead), convert)
	}
	else if( uda == UDA){
  	    QP_TBASE(qphead) = 0
	    QP_ONTIME(qphead) = cvtr4(UD_ONTIME(uhead), convert)
	    QP_LIVETIME(qphead) = cvtr4(UD_LIVETIME(uhead), convert)
	    if( QP_LIVETIME(qphead) > 0.0 ) 
	        QP_DEADTC(qphead) = QP_ONTIME(qphead) / QP_LIVETIME(qphead)
	    else
		QP_DEADTC(qphead) = 1.0
	    QP_BKDEN(qphead) = 0.0
	    aspbuf[1] = -cvtr4(UD_AVGYOFF(uhead), convert)
	    aspbuf[2] = cvtr4(UD_AVGZOFF(uhead), convert)
	    aspbuf[3] = -cvtr4(UD_AVGROT(uhead), convert)
	}
	
# NEW
	call fix_dead_time_cf(QP_DEADTC(qphead))
# NEW

	QP_MINLTF(qphead) = 0.0
	QP_MAXLTF(qphead) = 0.0
	switch(QP_INST(qphead)){
	case EINSTEIN_IPC:
	    call aclrr(bsbuf,3)
	case EINSTEIN_HRI:
	    if( uda == UHEAD) {
	        bsbuf[1] = -cvtr4(U_BOREYOFF(uhead), convert)
	        bsbuf[2] = cvtr4(U_BOREZOFF(uhead), convert)
	        bsbuf[3] = -cvtr4(U_BOREROT(uhead), convert)
	    }
	    else if( uda == UDA){
	        bsbuf[1] = -cvtr4(UD_BOREYOFF(uhead), convert)
	        bsbuf[2] = cvtr4(UD_BOREZOFF(uhead), convert)
	        bsbuf[3] = -cvtr4(UD_BOREROT(uhead), convert)
	    }
	default:
	    call error(1, "unknown Einstein instrument type")
	}
	# apply boresights to aspect
	call asp_appbs(bsbuf,aspbuf)
	QP_XAVGOFF(qphead) = aspbuf[1] * abs(QP_CDELT1(qphead))*3600.0
	QP_YAVGOFF(qphead) = aspbuf[2] * QP_CDELT2(qphead)*3600.0
	QP_RAVGROT(qphead) = RADTODEG(aspbuf[3])
	if( uda == UHEAD){
	    QP_XASPRMS(qphead) = cvtr4(U_ASPRMSY(uhead), convert) *
			     abs(QP_CDELT1(qphead))*3600.0
	    QP_YASPRMS(qphead) = cvtr4(U_ASPRMSZ(uhead), convert) *
			     QP_CDELT2(qphead)*3600.0
	    QP_RASPRMS(qphead) = RADTODEG(cvtr4(U_ASPRMSROT(uhead), convert))
	    QP_RAPT(qphead) = RADTODEG(cvtr4(U_RA(uhead), convert))
	    QP_DECPT(qphead) = RADTODEG(cvtr4(U_DEC(uhead), convert))
	}
	else if( uda == UDA){
	    QP_XASPRMS(qphead) = -1.0
	    QP_YASPRMS(qphead) = -1.0 
	    QP_RASPRMS(qphead) = -1.0
	    QP_RAPT(qphead) = RADTODEG(cvtr4(UD_RA(uhead), convert))
	    QP_DECPT(qphead) = RADTODEG(cvtr4(UD_DEC(uhead), convert))
	}
	switch(QP_INST(qphead)){
	case EINSTEIN_IPC:
	    QP_XPT(qphead) = EINSTEIN_IPC_DIM/2
	    QP_YPT(qphead) = EINSTEIN_IPC_DIM/2
	    QP_XDET(qphead) = EINSTEIN_IPC_DIM
	    QP_YDET(qphead) = EINSTEIN_IPC_DIM
	    QP_XDIM(qphead) = EINSTEIN_IPC_DIM
	    QP_YDIM(qphead) = EINSTEIN_IPC_DIM
	    QP_FOV(qphead) = EINSTEIN_IPC_FOV
#  We must make sure this is the pixel size for the detector pixels and not 8.
#	    QP_INSTPIX(qphead) = EINSTEIN_IPC_ARC_SEC_PER_PIXEL
	    QP_INPXX(qphead) = EINSTEIN_IPC_ARC_SEC_PER_PIXEL / 3600.0E0
	    QP_INPXY(qphead) = EINSTEIN_IPC_ARC_SEC_PER_PIXEL / 3600.0E0
#  Let's leave this in units of detector pixels
	    QP_XDOPTI(qphead) = (QP_XDET(qphead)-EINSTEIN_IPC_OPTI_X) 
#				  * abs(QP_INSTPIX(qphead))*3600.0
	    QP_YDOPTI(qphead) = (QP_YDET(qphead)-EINSTEIN_IPC_OPTI_Y) 
#				  * abs(QP_INSTPIX(qphead)*3600.0
#	    QP_XDOPTI(qphead) = (QP_CRPIX1(qphead)-EINSTEIN_IPC_OPTI_X) *
#				  abs(QP_CDELT1(qphead))*3600.0
#	    QP_YDOPTI(qphead) = (QP_CRPIX2(qphead)-EINSTEIN_IPC_OPTI_Y) *
#				  QP_CDELT2(qphead)*3600.0
	    QP_CHANNELS(qphead) = EINSTEIN_IPC_PULSE_CHANNELS
	    call asp_apply(EINSTEIN_IPC_OPTI_X, EINSTEIN_IPC_OPTI_Y, aspbuf,
		       float(QP_XPT(qphead)), float(QP_YPT(qphead)),
		       DEGTORAD(QP_DETANG(qphead)),
		       QP_XAOPTI(qphead), QP_YAOPTI(qphead))
	case EINSTEIN_HRI:
	    QP_XPT(qphead) = EINSTEIN_HRI_DIM/2
	    QP_YPT(qphead) = EINSTEIN_HRI_DIM/2
	    QP_YDIM(qphead) = EINSTEIN_HRI_DIM
	    QP_XDIM(qphead) = EINSTEIN_HRI_DIM
	    QP_YDET(qphead) = EINSTEIN_HRI_DIM
	    QP_XDET(qphead) = EINSTEIN_HRI_DIM
	    QP_FOV(qphead) = EINSTEIN_HRI_FOV
#  We must make sure this is the pixel size for the detector pixels and not 8.
#	    QP_INSTPIX(qphead) = EINSTEIN_HRI_ARC_SEC_PER_PIXEL
	    QP_INPXX(qphead) = EINSTEIN_HRI_ARC_SEC_PER_PIXEL / 3600.0E0
	    QP_INPXY(qphead) = EINSTEIN_HRI_ARC_SEC_PER_PIXEL / 3600.0E0
#  Let's leave this in units of detector pixels
	    QP_XDOPTI(qphead) = (QP_XDET(qphead)-EINSTEIN_HRI_OPTI_X) 
#				  * abs(QP_INSTPIX(qphead))*3600.0
	    QP_YDOPTI(qphead) = (QP_YDET(qphead)-EINSTEIN_HRI_OPTI_Y) 
#				  * abs(QP_INSTPIX(qphead))*3600.0
#	    QP_XDOPTI(qphead) = (QP_CRPIX1(qphead)-EINSTEIN_HRI_OPTI_X) *
#				  abs(QP_CDELT1(qphead))*3600.0
#	    QP_YDOPTI(qphead) = (QP_CRPIX2(qphead)-EINSTEIN_HRI_OPTI_Y) *
#				  QP_CDELT2(qphead)*3600.0
	    QP_CHANNELS(qphead) = EINSTEIN_HRI_PULSE_CHANNELS
	    call asp_apply(EINSTEIN_HRI_OPTI_X, EINSTEIN_HRI_OPTI_Y, aspbuf,
		       float(QP_XPT(qphead)), float(QP_YPT(qphead)),
		       DEGTORAD(QP_DETANG(qphead)),
		       QP_XAOPTI(qphead), QP_YAOPTI(qphead))
	default:
	    call error(1, "unknown Einstein instrument type")
	}
	# these are out of order, but can't happen until we set the dopti's
	QP_XAOPTI(qphead) = (QP_CRPIX1(qphead)-QP_XAOPTI(qphead)) *
			     abs(QP_CDELT1(qphead))*3600.0
	QP_YAOPTI(qphead) = (QP_CRPIX2(qphead)-QP_YAOPTI(qphead)) *
			     QP_CDELT2(qphead)*3600.0

	QP_CRETIME(qphead) = clktime(0)
	QP_MODTIME(qphead) = QP_CRETIME(qphead)
	QP_LIMTIME(qphead) = 0

        # set QPOE index strings to point to "x" and "y" as default.
        call strcpy("x",QP_INDEXX(qphead),SZ_INDEXX)
        call strcpy("y",QP_INDEXY(qphead),SZ_INDEXY)
	
	# display, if necessary
	if( display >0 ){
	    call disp_qphead(qphead,"",display) # title not available here
	}

	# free up stack space
	call sfree(sp)
end

#
# UHD_CHECKHEAD -- check for a universal header on the file
#
# This is a kludge to get around the fact that production
# xpr and tgr files have a header, but public domain xpr's and tgr's don't.
# The file pointer is reset to point past the header, if there is one.
#
procedure uhd_checkhead(fd, qphead, convert, headsize)

int	fd				# i: file handle
pointer	qphead				# i: qpoe header
int	convert				# i: data conversion flag
int	headsize			# o: size of header on file

short	uhead[SZ_UHEAD]			# l: universal header
int	nchars				# l: SPP chars read 
int	junk				# l: junk return from ctoi
int	seqno				# l: sequence number
int	ip				# l: index for ctoi
int	ctoi()				# l: convert ascii to int
int	read()				# l: read data
short	cvti2()				# l: convert DG I*2

begin
    # try to read the header
    nchars = read(fd, uhead, SZ_UHEAD*SZ_SHORT)
    # if we get EOF, its a short xpr
    if( nchars < SZ_UHEAD*SZ_SHORT ){
        headsize = 0
        call seek(fd, BOF)
    }
    # we check some values in the header
    # we rely on the extremely small probability that data will have these
    # exact values
    ip = 1
    junk = ctoi(QP_OBSID(qphead), ip, seqno)
    if((QP_INST(qphead) == EINSTEIN + 1 +
		and(cvti2(U_DATAFORMAT(uhead),convert),
		EINSTEIN_INSTMASK)) &&
	     (seqno == cvti2(U_SEQNO(uhead),convert)) ) {
		headsize = SZ_UHEAD*SZ_SHORT
    }
    else{
            headsize = 0
            call seek(fd, BOF)
    }
end

#  Converted from UNIX/C SAOLIB.  The original C code is stil
#    present in single comments
procedure scidmm(scid,mjf,mnf)
long	scid		# i: input space-craft ID for this HUT
long	mjf		# o: decoded major frame number
short	mnf		# o: decoded minor frame number

long temp1,temp2
int i
begin
	mnf = and(scid,07FX)	#  The minor frame is the least sign.
				# 7 bits 
#  Shift out the least significant 4 bits
#  Shift 4 bits from the hiorder word
#  Shift out 3 more bits - that accounts for the 7 minor frame bits
#	mjf = scid >> 4
	temp1=0
	temp2=0
#	call bitmov(scid,32,temp2,28,28)
	do i=0,27
	    call bitmov(scid,32-i,temp2,28-i,1)
#	mjf = and(mjf,0x0FFFFFFF)
#	temp1 = and(0xFFFF0000,mjf) >> 4
#	call bitmov(mjf,1,temp1,5,12)
        call bitmov(temp2,21,temp1,17,12)
						 # shifted by 4
# Since there is not an unsigned type, re-clear the high order 4 bits after shift and retain only high-order 2 bytes
#	temp1 = and(0x0FFF0000,temp1)
# Get the low order 2 bytes
#	temp2 = and(mjf,0x0000FFFF)
#	mjf = or(temp1,temp2)	
	mjf = 0
	call bitmov(temp1,17,mjf,17,16)
	call bitmov(temp2,1,mjf,1,16)
#	mjf = mjf >> 3
	temp1=0
	call bitmov(mjf,4,temp1,1,29)
	mjf=temp1
#	mjf = and(mjf,0x1FFFFFFF)
end
