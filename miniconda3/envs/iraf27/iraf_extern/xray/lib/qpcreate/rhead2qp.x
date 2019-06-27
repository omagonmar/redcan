#$Header: /home/pros/xray/lib/qpcreate/RCS/rhead2qp.x,v 11.1 1999/09/21 15:22:28 prosb Exp $
#$Log: rhead2qp.x,v $
#Revision 11.1  1999/09/21 15:22:28  prosb
#JCC(5/98) - add comments.
#          - change QP_DATEOBS from DD/MM/YY to YYYY-MM-DD
#          - change QP_DATEEND from DD/MM/YY to YYYY-MM-DD
#
#Revision 11.0  1997/11/06 16:22:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:30:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:34:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:56  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:59:16  prosb
#General Release 2.2
#
#Revision 5.3  93/04/30  02:38:46  dennis
#Changed defined constant POINT (from qpoe.h) to POINTED, to avoid 
#collision (in other programs) with POINT defined in regions.h.
#
#Revision 5.2  93/04/22  12:15:14  mo
#MC	22 Apr 93	Update include file for correct 'argv' definitions
#
#Revision 5.1  93/01/27  18:26:09  mo
#MC	1/27/93		Added MISSION and TELESCOPE strings to header
#
#Revision 5.0  92/10/29  21:19:30  prosb
#General Release 2.1
#
#Revision 4.3  92/10/23  10:45:46  mo
#no changes
#
#Revision 4.2  92/10/16  20:21:34  mo
#MC	10/16/92	Added disp_qphead parameters to calling sequence
#
#Revision 4.1  92/06/22  16:01:51  jmoran
#JMORAN added call to "fix_dead_time_cf"
#
#Revision 4.0  92/04/27  13:53:26  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:32  prosb
#General Release 1.1
#
#Revision 2.3  91/08/01  21:53:37  mo
#MC	8/1/91		Add support for the min and max energy channels
#			Fix type in the ROSAT year that caused year
#			to be stuck at 1990
#
#Revision 2.2  91/06/03  15:36:49  mo
#**      4/18 change did NOT get checked into RCS  **
#
#        MC      4/18/91         Update to support min and max pha channels
#                                in the QPHEADer.
#
#        MC      5/23/91         Update the header to support PSPC 
#                                instrument 2.  Either inst 1 or 2 will
#                                be recognised as ROSAT_PSPC and the SUBINST
#                                will be recorded.  This will allow all
#                                PROS code to function as before.
#                                HRI will continue to have SUBINST = 0
#
#
#Revision 2.1  91/04/16  16:19:34  mo
#MC	4/16/91		Added code to hardwire the PSPC pointed mode, extract
#the FILTER parameter from header as well as the SEQ_PI string.
#
#Revision 2.0  91/03/07  00:11:51  pros
#General Release 1.0
#
#
# Module:       RHEAD2QP.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      ROSAT header-specific routines for QPOE creation
# External:     Used by toe2qp - rhd_open,rhd_get,rhd_close
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM initial version 1989
#               {1} MC  -- Correct MJD to add the MJDOFFSET
#                          Correct Binned RA and DEC for PSPC  -- 12/11/90
#			   Correct PSPC for 1/2 arcsec units   -- 1/91 
#			   Add detector coordinate support for PSPC -- 1/91
#               {2} MC  -- Add support for BIAS and SCALE factors -- 2/1/91
#               {3} MC  -- Remove old debug prints -- 2/25/91
#               {n} <who> -- <does what> -- <when>
#

include <mach.h>
include <math.h>
include <qpc.h>
include <rosat.h>
include <qpoe.h>
include <clk.h>

# define conversion factor to convert RA,DEC in 1/10 arc sec to degrees for HRI
define H_2DEG	(10.0*60.0*60.0)
# define conversion factor to convert RA,DEC in 1/2 arc sec to degrees for PSPC 
# define P_2DEG	(2.0*60.0*60.0)
# define offset of daycount at which we start the S/C
define R_BASEDAY 1

define SZ_RHEAD (512/SZB_CHAR)*2	# expand this to 2 VMS blocks

#
#  RHD_OPEN -- open the header file
#
procedure rhd_open(fname, fd, convert, display, argv)

char	fname[ARB]			# i: header file name
int	fd				# o: file descriptor
int	convert				# i: data conversion flag
int	display				# i: display level
pointer	argv				# i: pointer to arg list
int	open()				# l: open a file

begin
	fd = open(fname, READ_ONLY, BINARY_FILE)
end

#
#  RHD_CLOSE -- open the header file
#
procedure rhd_close(fd, qphead, display, argv)

int	fd				# i: header fd
pointer	qphead				# i: header
int	display				# i: display level
pointer	argv				# i: pointer to arg list

begin
	call close(fd)
end

#
# RHD_GET -- read the header
#
procedure rhd_get(fd, convert, qphead, display, argv)

int	fd				# i: header fd
int	convert				# i: data conversion flag
pointer	qphead				# i: qpoe header
int	display				# i: display level
pointer	argv				# o: pointer to arg list

pointer	rhead				# l: rosat header
pointer	sp				# l: stack pointer
pointer	refclk				# l: reference clock struct
pointer	utclk				# l: ut clock struct
int	nchars				# l: SPP chars read 

int	read()				# l: read data
int	clktime()			# l: get clock time, seconds
int	cvti4()				# l: convert integer*4
real	cvtr4()				# l: convert real*4
double	cvtr8()				# l: convert real*8
double	dtemp
double	mutjd()				# l: ut -> jd conversion

begin
	# mark the stack
	call smark(sp)
	# allocate space for a the rosat header
	call salloc(rhead, SZ_RHEAD/SZ_INT, TY_STRUCT)
	# allocate space for clock conversion
	call salloc(refclk, LEN_CLK, TY_STRUCT)
	call salloc(utclk, LEN_CLK, TY_STRUCT)

	# read in the header
	nchars = read(fd, Memi[rhead], SZ_RHEAD)
	if( nchars != SZ_RHEAD )
	    call error(1, "unexpected EOF reading ROSAT HRI header")

	# fill in information from the ROSAT header
	QP_MISSION(qphead) = ROSAT
        call strcpy("ROSAT",QP_MISSTR(qphead),20)
 	if( cvti4(R_DETECTOR(rhead),convert) == HRI_CODE ) {
 	    QP_INST(qphead) = ROSAT_HRI
            call strcpy("HRI",QP_INSTSTR(qphead),20)
 	} else if( cvti4(R_DETECTOR(rhead),convert) == PSPC_CODE ) {
 	    QP_INST(qphead) = ROSAT_PSPC
            call strcpy("PSPC",QP_INSTSTR(qphead),20)
 	} else if( cvti4(R_DETECTOR(rhead),convert) == PSPC2_CODE ) {
 	    QP_INST(qphead) = ROSAT_PSPC
            call strcpy("PSPC",QP_INSTSTR(qphead),20)
 	} else {
 	    call error(1, "unknown ROSAT instrument ID", 
                       cvti4(R_DETECTOR(rhead),convert))
 	}
	QP_FILTER(qphead) = cvti4(R_FILTER(rhead),convert)
#  We have to hardwire ROSAT to POINTing mode
	QP_MODE(qphead) = POINTED

	call strcpy(RADECSYS, QP_RADECSYS(qphead), SZ_WCSSTR)
	QP_EQUINOX(qphead) = ROSAT_EQUINOX

	call strcpy(CTYPE1, QP_CTYPE1(qphead), SZ_WCSSTR)
	call strcpy(CTYPE2, QP_CTYPE2(qphead), SZ_WCSSTR)
	switch(QP_INST(qphead)){
	case ROSAT_HRI:  #  HRI 
	   QP_CRVAL1(qphead) = RADTODEG(cvtr4(R_BINNED_RA(rhead),convert))
	   QP_CRVAL2(qphead) = RADTODEG(cvtr4(R_BINNED_DEC(rhead),convert))
	   QP_CROTA2(qphead) = -RADTODEG(cvtr4(R_BINNED_ROLL(rhead),convert))
	   QP_CRPIX1(qphead) = INT(cvtr8(R_POE_CENTER(rhead),convert) + 1.0)
	   QP_CRPIX2(qphead) = cvti4(R_Y_POE_SIZE(rhead),convert) - 
                               INT(cvtr8(R_POE_CENTER(rhead),convert) + 1.0)
	case ROSAT_PSPC:  # PSPC 
#	   QP_CRVAL1(qphead) = RADTODEG(cvtr4(R_BINNED_RA(rhead),convert))
#	   QP_CRVAL2(qphead) = RADTODEG(cvtr4(R_BINNED_DEC(rhead),convert))
	   QP_CRVAL1(qphead) = cvtr4(R_BINNED_RA(rhead),convert)
	   QP_CRVAL2(qphead) = cvtr4(R_BINNED_DEC(rhead),convert)
	   QP_CROTA2(qphead) = -RADTODEG(cvtr4(R_BINNED_ROLL(rhead),convert))
#	   # For PSPC we just know the size - take 1/2 the size for the center
	   QP_CRPIX1(qphead) = INT(cvtr8(R_POE_CENTER(rhead),convert))
	   QP_CRPIX2(qphead) = cvti4(R_Y_POE_SIZE(rhead),convert) - 
                               INT((cvtr8(R_POE_CENTER(rhead),convert)) )
#        default:
#	    call error(1, "unknown ROSAT instrument type")
        }
#  Moved to above instrument sensitive code to accomodate PSPC   12/18/90
#	QP_CRPIX1(qphead) = INT(cvtr8(R_POE_CENTER(rhead),convert) + 1.0)
#	QP_CRPIX2(qphead) = cvti4(R_Y_POE_SIZE(rhead),convert) - 
#                            INT(cvtr8(R_POE_CENTER(rhead),convert) + 1.0)
	QP_CDELT1(qphead) = -cvtr4(R_ARCSECS_PER_PIXEL(rhead),convert)/3600.0
	QP_CDELT2(qphead) = cvtr4(R_ARCSECS_PER_PIXEL(rhead),convert)/3600.0

	# get modified JD of start of obs
	call aclri(Memi[refclk], LEN_CLK)
	YEAR(refclk) = cvti4(R_SC_CLOCK_YEAR(rhead),convert) #jcc-eg. 1998
	DAY(refclk) = cvti4(R_SC_CLOCK_DAY(rhead),convert)
	HOUR(refclk) = cvti4(R_SC_CLOCK_HOUR(rhead),convert)
	MINUTE(refclk) = cvti4(R_SC_CLOCK_MINUTE(rhead),convert)
	dtemp = cvtr8(R_SC_CLOCK_SECOND(rhead),convert)
	SECOND(refclk) = INT(dtemp)
	FRACSEC(refclk) = dtemp - SECOND(refclk)
	call sclk_to_ut(double(cvti4(R_SEQ_BEG(rhead),convert)),refclk,utclk)
	QP_MJDOBS(qphead) = mutjd(MJDREFYEAR, MJDREFDAY, utclk) + MJDREFOFFSET
	# get obs start as a string
	call aclri(Memi[utclk], LEN_CLK)
	call sclk_to_ut(double(cvti4(R_SEQ_BEG(rhead),convert)),refclk,utclk)

#JCC(5/98) - change QP_DATEOBS from DD/MM/YY to YYYY-MM-DD

	#jcc-call sprintf(QP_DATEOBS(qphead), SZ_QPSTR, "%02d/%02d/%02d")
	#jcc-call pargi(MDAY(utclk))
	#jcc-call pargi(MONTH(utclk))
	#jcc-call pargi(mod(YEAR(utclk),100))
	call sprintf(QP_DATEOBS(qphead), SZ_QPSTR, "%04d-%02d-%02d")
	call pargi(YEAR(utclk))
	call pargi(MONTH(utclk))
	call pargi(MDAY(utclk))
	call sprintf(QP_TIMEOBS(qphead), SZ_QPSTR, "%02d:%02d:%02d")
	call pargi(HOUR(utclk))
	call pargi(MINUTE(utclk))
	call pargi(SECOND(utclk))
	# get obs end as a string
	call aclri(Memi[utclk], LEN_CLK)
	call sclk_to_ut(double(cvti4(R_SEQ_END(rhead),convert)),refclk,utclk)

#JCC(5/98) - change QP_DATEEND from DD/MM/YY to YYYY-MM-DD
	#jcc-call sprintf(QP_DATEEND(qphead), SZ_QPSTR, "%02d/%02d/%02d")
	#jcc-call pargi(MDAY(utclk))
	#jcc-call pargi(MONTH(utclk))
	#jcc-call pargi(mod(YEAR(utclk),100))
	call sprintf(QP_DATEEND(qphead), SZ_QPSTR, "%04d-%02d-%02d")
	call pargi(YEAR(utclk))
	call pargi(MONTH(utclk))
	call pargi(MDAY(utclk))

	call sprintf(QP_TIMEEND(qphead), SZ_QPSTR, "%02d:%02d:%02d")
	call pargi(HOUR(utclk))
	call pargi(MINUTE(utclk))
	call pargi(SECOND(utclk))
	
	# unpack the string into an SPP char array
	call chrupk(R_KEYNO(rhead), 1, QP_OBSID(qphead), 1, 16)
	# unpack the string into an SPP char array
        call chrupk(R_SEQ_PI(rhead), 1, QP_SEQPI(qphead), 1, 80)

	if( QP_INST(qphead) == ROSAT_PSPC )
	    QP_SUBINST(qphead) = cvti4(R_DETECTOR(rhead),convert) 
	QP_OBSERVER(qphead) = cvti4(R_PROP_ID(rhead),convert)
	call strcpy(COUNTRY, QP_COUNTRY(qphead), SZ_QPSTR)
#	switch(QP_INST(qphead)){
#	case ROSAT_HRI:  #  HRI stores as 10ths of arcsec
	   QP_DETANG(qphead) = -cvti4(R_NOM_ROLL(rhead),convert)/H_2DEG
#	case ROSAT_PSPC:  # PSPC stores as 1/2 of an arcsec ( integer)
#	   QP_DETANG(qphead) = -cvti4(R_NOM_ROLL(rhead),convert)/P_2DEG
#        default:
#	    call error(1, "unknown ROSAT instrument type")
#        }

#  If refclk has been correctly set, the sclk_to_ut should work, otherwise
#      a static version of MJD of SC start in saved in ROSAT_MJDRDAY and RFRAC
	call sclk_to_ut(0.0D0, refclk, utclk)
	dtemp = mutjd(MJDREFYEAR, MJDREFDAY, utclk)+MJDREFOFFSET
	QP_MJDRDAY(qphead) = dtemp
#	QP_MJDRDAY(qphead) = ROSAT_MJDRDAY
#	QP_MJDRFRAC(qphead) = ROSAT_MJDRFRAC
	QP_MJDRFRAC(qphead) = dtemp - QP_MJDRDAY(qphead)

	QP_EVTREF(qphead) = ROSAT_EVTREF
	QP_ONTIME(qphead) = cvtr4(R_ONTIME_FOR_LIVETIME(rhead),convert)
	QP_LIVETIME(qphead) = cvtr4(R_LIVE_TIME(rhead),convert)
	QP_DEADTC(qphead) = cvtr4(R_LIVE_TIME_CORR(rhead),convert)

# NEW
	call fix_dead_time_cf(QP_DEADTC(qphead))
# NEW

 	QP_BKDEN(qphead) = cvtr4(R_BKDEN(rhead),convert)
	QP_MINLTF(qphead) = cvtr4(R_MIN_LTF(rhead),convert)
	QP_MAXLTF(qphead) = cvtr4(R_MAX_LTF(rhead),convert)
#  I think we only know these for Einstein
#	QP_XAOPTI(qphead) = cvtr8(R_OPTICAL_AXIS_X(rhead),convert) *
#			      abs(QP_CDELT1(qphead))
#	QP_YAOPTI(qphead) = cvtr8(R_OPTICAL_AXIS_Y(rhead),convert) *
#			      QP_CDELT2(qphead)
#	QP_XAVGOFF(qphead) = cvtr8(R_AVG_ASP_X_OFF(rhead),convert) *
#			      abs(QP_CDELT1(qphead))
#	QP_YAVGOFF(qphead) = -cvtr8(R_AVG_ASP_Y_OFF(rhead),convert) *
#			      QP_CDELT2(qphead)
#	QP_RAVGROT(qphead) = -RADTODEG(cvtr8(R_AVG_ASP_ROLL(rhead),convert))
	QP_TBASE(qphead) = 0.0D0
	QP_XAOPTI(qphead) = 0.0
	QP_YAOPTI(qphead) = 0.0
	QP_XAVGOFF(qphead) = 0.0
	QP_YAVGOFF(qphead) = 0.0
	QP_RAVGROT(qphead) = 0.0
	QP_XASPRMS(qphead) = 0.0
	QP_YASPRMS(qphead) = 0.0
	QP_RASPRMS(qphead) = 0.0
#  Change BlackBox to force PSPC units to conform to HRI units  12/18/90
#	switch(QP_INST(qphead)){
#	case ROSAT_HRI:  #  HRI stores as 10ths of arcsec
	   QP_RAPT(qphead) = cvti4(R_NOM_RA(rhead),convert)/H_2DEG
	   QP_DECPT(qphead) = cvti4(R_NOM_DEC(rhead),convert)/H_2DEG
#	case ROSAT_PSPC:  # PSPC stores as 1/2 of an arcsec ( integer)
#	   QP_RAPT(qphead) = cvti4(R_NOM_RA(rhead),convert)/P_2DEG
#	   QP_DECPT(qphead) = cvti4(R_NOM_DEC(rhead),convert)/P_2DEG
#        default:
#	    call error(1, "unknown ROSAT instrument type")
#        }
	QP_XPT(qphead) = cvti4(R_X_DETECTOR_SIZE(rhead),convert)/2
	QP_YPT(qphead) = cvti4(R_Y_DETECTOR_SIZE(rhead),convert)/2
	QP_XDET(qphead) = cvti4(R_X_DETECTOR_SIZE(rhead),convert)
	QP_YDET(qphead) = cvti4(R_Y_DETECTOR_SIZE(rhead),convert)
	QP_XDIM(qphead) = cvti4(R_X_POE_SIZE(rhead),convert)
	QP_YDIM(qphead) = cvti4(R_Y_POE_SIZE(rhead),convert)
	QP_INPXX(qphead) = cvtr4(R_INSTPXX(rhead),convert)/3600.0E0
	QP_INPXY(qphead) = cvtr4(R_INSTPXY(rhead),convert)/3600.0E0
	QP_XDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS_DX(rhead),convert) 
#			 	* abs(QP_INPXX(qphead))
	QP_YDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS_DY(rhead),convert)
#				* abs(QP_INPXY(qphead))
	switch(QP_INST(qphead)){
	case ROSAT_HRI:
	    QP_FOV(qphead) = ROSAT_HRI_FOV
#	    QP_XDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS(rhead),convert) *
#			 	abs(QP_CDELT1(qphead))
#	    QP_YDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS(rhead),convert) *
#				QP_CDELT2(qphead)
	    QP_MINCHANS(qphead) = cvti4(R_MIN_CHAN(rhead),convert)
	    QP_MAXCHANS(qphead) = cvti4(R_MAX_CHAN(rhead),convert)
	    QP_CHANNELS(qphead) = QP_MAXCHANS(qphead) - QP_MINCHANS(qphead) + 1
	case ROSAT_PSPC:
	    QP_FOV(qphead) = ROSAT_PSPC_FOV
#	    QP_XDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS(rhead),convert) *
#			 	abs(QP_CDELT1(qphead))
#	    QP_YDOPTI(qphead) = cvtr8(R_OPTICAL_AXIS(rhead),convert) *
#				QP_CDELT2(qphead)
	    QP_MINCHANS(qphead) = cvti4(R_MIN_CHAN(rhead),convert)
	    QP_MAXCHANS(qphead) = cvti4(R_MAX_CHAN(rhead),convert)
	    QP_CHANNELS(qphead) = QP_MAXCHANS(qphead) - QP_MINCHANS(qphead) + 1
	default:
	    call error(1, "unknown ROSAT instrument type")
	}
        QP_BZERO(qphead) = cvtr4(R_BZERO(rhead),convert)
        QP_BSCALE(qphead) = cvtr4(R_BSCALE(rhead),convert)
	QP_CRETIME(qphead) = clktime(0)
	QP_MODTIME(qphead) = QP_CRETIME(qphead)
	QP_LIMTIME(qphead) = 0

	# if the user title is the null string, get title from header
	if( Memc[TITLE(argv)] == EOS )
	    call chrupk(R_SEQ_TIT(rhead), 1, Memc[TITLE(argv)], 1, 80)
#	call printf("R_TIT: %s QP_TIT: %s \n")
#	    call pargstr(R_SEQ_TIT(rhead))
#	    call pargstr(Memc[TITLE(argv)])

	# display, if necessary
	if( display >0 ){
	    call disp_qphead(qphead,Memc[TITLE(argv)],display)
	}

end
