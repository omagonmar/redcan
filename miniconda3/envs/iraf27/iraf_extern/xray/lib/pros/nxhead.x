#$Header: /home/pros/xray/lib/pros/RCS/nxhead.x,v 11.0 1997/11/06 16:20:44 prosb Exp $
#$Log: nxhead.x,v $
#Revision 11.0  1997/11/06 16:20:44  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:05  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:50  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/18  10:18:02  mo
#MC	5/5/94		Fix the 'get_genwcs' task to handle input TABLE/WCS
#			header keywords, RCRPX,SCRPX,BCRPX, etc.
#
#Revision 7.0  93/12/27  18:10:14  prosb
#General Release 2.3
#
#Revision 1.1  93/12/16  09:42:00  mo
#Initial revision
#
#Revision 6.1  93/07/02  14:15:34  mo
#MC(JD)	7/2/93		Update new parameter in calling sequence
#				and add new 'fix_pspc' routine for archive
#
#Revision 6.0  93/05/24  15:55:02  prosb
#General Release 2.2
#
#Revision 5.3  93/05/19  17:06:50  mo
#MC	5/20/93		Clean up 'not used' messages
#
#Revision 5.2  93/04/26  16:37:47  jmoran
#JMORAN added QP_REVISION to get and put qphead
#
#Revision 5.1  93/01/27  14:17:09  mo
#MC	1/28/93		Fix bug that did not encode MISSION and TELECOPE
#			strings for 'unknown' entries.
#
#Revision 5.0  92/10/29  21:18:00  prosb
#General Release 2.1
#
#Revision 4.4  92/10/23  15:42:01  mo
#MC	remove unused variable
#.`
#
#Revision 4.3  92/10/16  20:24:29  mo
#MC	10/16/92	Changed WCS parameters to double precision
#			Added fix for ROSAT and EINSTEIN WCS corrections
#			in CRPIX1,2
#
#Revision 4.2  92/07/31  13:56:30  prosb
#7/31/92	MC	Add code to automatically fix the MJDREF in 
#			headers for old Einstein files, where it was
#			set exactly 1 day too high
#
#Revision 4.1  92/06/08  14:14:56  jmoran
#JMORAN added code to "get_qphead" to call routine "fix_dead_time_cf" which
#fixes the dead time correction factor in the qpoe header
#
#Revision 4.0  92/04/27  13:50:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.5  92/04/23  13:02:17  mo
#MC	4/23/92		Added proper lengths for OBSID and SEQPI so they
#			don't get truncated in QPCOPY
#
#Revision 3.4  92/04/13  12:31:10  mo
#MC	4/13/92		Add code to handle EXPTIME keywork only available
#			in IMAGE files
#
#Revision 3.3  92/03/09  15:39:31  mo
#*** empty log message ***
#
#Revision 3.2  92/02/06  16:56:05  mo
#MC	2/5/92		Restore code that sets qpheader XDIM and YDIM
#			from axis length to support lab data where
#			there is no input header to get this info from
#
#Revision 3.1  91/12/16  10:04:33  mo
#MC	12/16/91	Update the HEADER comments to reflect the
#			correct units for average aspect and average 
#			optical axis.
#
#Revision 3.0  91/08/02  01:02:27  wendy
#General
#
#Revision 2.2  91/05/24  11:49:46  mo
#   MC      4/18/91         Update QPHEADer to include ROSAT 
#                                a hardwired pointing parameter and min and
#                                max pha channels
#
#
#Revision 2.1  91/04/16  16:09:48  mo
#MC	4/16/91		Fixed the labels for the optical axis entries in the QPOE 
#header
#
#        Added support for the SEQ_PI string, ROSAT pointing mode -
#hard-wired and to set the FILTER parameter for ROSAT..
#
#
#Revision 2.0  91/03/07  00:07:52  pros
#General Release 1.0
#
#
# Module:       XHEAD.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      X-ray header manipulation procedures on qpoe and image files
# External:     is_qphead, is_imhead, get_nqphead, get_nimhead
# 		x_get<x>, x_put<x>, x_accessf, x_rename, x_add, set_xhead
# Local:        wqp*
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- Original version	1988
#               {1} MC    -- add detector coordinate support for PSPC -- 1/91
#               {2} MC    -- correct the unit labels for detector stuff -- 2/91
#               {n} <who> -- <does what> -- <when>
#
#

include <math.h>
include <mach.h>
include <wfits.h>
include <qpoe.h>
include <missions.h>
include <einstein.h>
define	SZ_CARD 10

#
#  GET_NQPHEAD -- read qpoe header into uhead struct
#
procedure get_nqphead(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# o: qpoe header
int	junk				# l: return from x_gstr
int	x_geti()			# l: qpoe get routines:
real	x_getr()
double	x_getd()
int	x_gstr()
int	x_accessf()			# l: check for param existence
int	xheadtype			# l: type of header
double	foo

int	mjdref
real 	dead_time_cf

begin
	xheadtype = 1
	goto 99
entry	get_nimhead(qp, qphead)
	xheadtype = 2
	goto 99
entry	get_ntbhead(qp, qphead)
	xheadtype = 4
	goto 99

	# set the header type
99	call set_xhead(xheadtype)

	# allocate space for qpoe header
	call calloc(qphead, SZ_QPHEAD, TY_STRUCT)

	# lookup the mission string
#	QP_MISSION(qphead) = x_geti(qp, "TELESCOP")
	junk = x_gstr(qp, "TELESCOP", QP_MISSTR(qphead), SZ_QPSTR)
	# convert to mission id
	call mis_ctoi(QP_MISSTR(qphead), QP_MISSION(qphead))
#	QP_INST(qphead) = x_geti(qp, "INSTRUME")
	junk = x_gstr(qp, "INSTRUME", QP_INSTSTR(qphead), SZ_QPSTR)
	# convert to instrument (requires mission id)
	call inst_ctoi(QP_INSTSTR(qphead), QP_MISSION(qphead), QP_INST(qphead),
			QP_SUBINST(qphead))
	QP_EQUINOX(qphead) = x_getr(qp, "EQUINOX")
	junk = x_gstr(qp, "RADECSYS", QP_RADECSYS(qphead), SZ_QPSTR)

	if( (xheadtype == 1) && (x_accessf(qp, "qpwcs") == YES) ) {
	    call get_qpwcs(qp, qphead)
	    call get_qpaxlen(qp, qphead)
	} else if ( xheadtype == 2 ) {
	    call get_imwcs(qp, qphead)
	    call get_imaxlen(qp, qphead)
	} else {
		call get_genwcs(qp, qphead)
	}
	call fix_wcsref(qphead)
	QP_MJDOBS(qphead) = x_getr(qp, "MJD-OBS")
	junk = x_gstr(qp, "DATE-OBS", QP_DATEOBS(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "TIME-OBS", QP_TIMEOBS(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "DATE_END", QP_DATEEND(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "TIME_END", QP_TIMEEND(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "OBSID", QP_OBSID(qphead), SZ_OBSID)
	junk = x_gstr(qp, "OBSERVER", QP_SEQPI(qphead), SZ_SEQPI)
	QP_SUBINST(qphead) = x_geti(qp, "XS-SUBIN")
# Must come AFTER the 'SUBINST and MJDOBS'
	call fix_pspc(qphead)
	QP_OBSERVER(qphead) = x_geti(qp, "ROR_NUM")
	junk = x_gstr(qp, "ORIGIN", QP_COUNTRY(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "FILTER", QP_FILTSTR(qphead), SZ_FILTSTR)
        call filt_ctoi(QP_FILTSTR(qphead),QP_FILTER(qphead))
	junk = x_gstr(qp, "OBS_MODE", QP_MODESTR(qphead), SZ_MODESTR)
        call mode_ctoi(QP_MODESTR(qphead),QP_MODE(qphead))
	QP_DETANG(qphead) = x_getr(qp, "PAN01")
	QP_MJDRFRAC(qphead) = x_getd(qp, "MJDREFF")
############################################################
# NEW 
############################################################

	mjdref = x_geti(qp, "MJDREFI")

	if( QP_MISSION(qphead) == EINSTEIN )
	    call fix_mjdref(mjdref)

	QP_MJDRDAY(qphead) = mjdref
############################################################
# NEW
############################################################
	QP_EVTREF(qphead) = x_geti(qp, "XS-EVREF")
	QP_TBASE(qphead) = x_getd(qp, "XS-TBASE")
#  EXPTIME only available in IMAGES, provided by QPEX interface
	if( xheadtype == 2 || xheadtype == 4 ){ 
	  if( x_accessf(qp, "EXPTIME") == YES)
	    QP_EXPTIME(qphead) = x_getd(qp, "EXPTIME")
	  else
	    QP_EXPTIME(qphead) = -1.0D0
	}
	foo = QP_EXPTIME(qphead)
	QP_ONTIME(qphead) = x_getd(qp, "ONTIME")
	QP_LIVETIME(qphead) = x_getd(qp, "LIVETIME")

############################################################
# NEW 
############################################################
	dead_time_cf = x_getr(qp, "DTCOR")

	call fix_dead_time_cf(dead_time_cf)

	QP_DEADTC(qphead) = dead_time_cf
############################################################
# NEW
############################################################

	QP_BKDEN(qphead) = x_getr(qp, "XS-BKDEN")
#	QP_MINLTF(qphead) = x_getr(qp, "XS-MINLT")
#	QP_MAXLTF(qphead) = x_getr(qp, "XS-MAXLT")
#	QP_XAOPTI(qphead) = x_getr(qp, "XS-XAOPT")
#	QP_YAOPTI(qphead) = x_getr(qp, "XS-YAOPT")
#	QP_XAVGOFF(qphead) = x_getr(qp, "XS-XAOFF")
#	QP_YAVGOFF(qphead) = x_getr(qp, "XS-YAOFF")
#	QP_RAVGROT(qphead) = x_getr(qp, "XS-RAROT")
#	QP_XASPRMS(qphead) = x_getr(qp, "XS-XARMS")
#	QP_YASPRMS(qphead) = x_getr(qp, "XS-YARMS")
#	QP_RASPRMS(qphead) = x_getr(qp, "XS-RARMS")
	QP_RAPT(qphead) = x_getr(qp, "RA_NOM")
	QP_DECPT(qphead) = x_getr(qp, "DEC_NOM")
#	QP_XPT(qphead) = x_geti(qp, "XS-XPT")
#	QP_YPT(qphead) = x_geti(qp, "XS-YPT")
	QP_XDET(qphead) = x_geti(qp, "XS-XDET")
	QP_YDET(qphead) = x_geti(qp, "XS-YDET")
#	QP_FOV(qphead) = x_getr(qp, "XS-FOV")
#  Pre-1991 qphead format had only one entry for instrument pixel size
#       and was in units of arcsecs per pixel.  Now in units of degress/pixel
	if( x_accessf(qp,"XS-INPIX") == YES ){
	    QP_INPXX(qphead) = x_getr(qp, "XS-INPIX")*3600.0E0
	    QP_INPXY(qphead) = x_getr(qp, "XS-INPIX")*3600.0E0
	}
	else{
	    if( x_accessf(qp,"XS-INPXX") == YES)
	        QP_INPXX(qphead) = x_getr(qp, "XS-INPXX")
	    if( x_accessf(qp,"XS-INPXY") == YES)
	        QP_INPXY(qphead) = x_getr(qp, "XS-INPXY")
	}
	QP_XDOPTI(qphead) = x_getr(qp, "OPTAXISX")
	QP_YDOPTI(qphead) = x_getr(qp, "OPTAXISY")
	QP_PHACHANS(qphead) = x_geti(qp, "PHACHANS")
	QP_CHANNELS(qphead) = QP_PHACHANS(qphead)
	QP_PICHANS(qphead) = x_geti(qp, "PICHANS")
	QP_MINPHA(qphead) = x_geti(qp, "MINPHA")
	QP_MINCHANS(qphead) = QP_MINPHA(qphead)
	QP_MAXPHA(qphead) = x_geti(qp, "MAXPHA")
	QP_MAXCHANS(qphead) = QP_MAXPHA(qphead)
	QP_MINPI(qphead) = x_geti(qp, "MINPI")
	QP_MAXPI(qphead) = x_geti(qp, "MAXPI")
#	QP_MAXCHANS(qphead) = x_geti(qp, "XS-MAXCH")
	QP_CRETIME(qphead) = x_geti(qp, "cretime")
	QP_MODTIME(qphead) = x_geti(qp, "modtime")
	QP_LIMTIME(qphead) = x_geti(qp, "limtime")

# NEW FOR RATFITS (JMORAN)
	QP_REVISION(qphead) = x_geti(qp, "REVISION")
end

procedure get_genwcs(qp,qphead)
pointer qp		# i
pointer qphead		# i
int	ii
#bool	get_ikey
char	root[SZ_CARD]
char	suffix[SZ_CARD]
char	key[SZ_CARD]
char	prefix[2]
char	plist[4]
#data	plist/'R','S','B',EOS/
#int	type
bool	ck_dkey()
bool	found
begin
	call strcpy("RSB",plist,4)
	call strcpy("CRPIX",root,SZ_CARD)
	call strcpy("1",suffix,SZ_CARD)
	call build_key(prefix,root,suffix,key,SZ_CARD)
	if( !ck_dkey(qp,key) )
	{
	    ii = 1
	    prefix[2]=EOS
	    call strcpy("CRPX",root,SZ_CARD)
	    while(!found && ii<=3) 
	    {
	        prefix[1] = plist[ii]
		call build_key(prefix,root,suffix,key,SZ_CARD)
		found = ck_dkey(qp,key)
	        ii= ii+1
	    }
	    call get_newgenwcs(qp,qphead,prefix,1,2)
	}
	else
	    call get_oldgenwcs(qp,qphead)
end

procedure build_key(prefix,root,suffix,key,maxlen)
char	prefix[ARB]	# i:
char	root[ARB]	# i:
char    suffix[ARB]	# i:
char	key[ARB]	# o:
int	maxlen		# i:

begin
	call strcpy(prefix,key,maxlen)
	call strcat(root,key,maxlen)
	call strcat(suffix,key,maxlen)
end

bool procedure ck_dkey(qp,key)
pointer	qp
char	key
bool	found
int	x_accessf()
begin
        if( x_accessf(qp, key) == NO )
	    found = FALSE
	else
	    found = TRUE
	return(found)
end
	
procedure get_oldgenwcs(qp, qphead)
pointer	qp
pointer	qphead
double	x_getd()
int	junk
int	x_gstr()
int	x_geti()
begin
            QP_CRVAL1(qphead) = x_getd(qp, "CRVAL1")
            QP_CRVAL2(qphead) = x_getd(qp, "CRVAL2")
            QP_CRPIX1(qphead) = x_getd(qp, "CRPIX1")
            QP_CRPIX2(qphead) = x_getd(qp, "CRPIX2")
            QP_CDELT1(qphead) = x_getd(qp, "CDELT1")
            QP_CDELT2(qphead) = x_getd(qp, "CDELT2")
            QP_CROTA2(qphead)   = x_getd(qp, "CROTA2")
            junk = x_gstr(qp, "CTYPE1", QP_CTYPE1(qphead), SZ_QPSTR)
            junk = x_gstr(qp, "CTYPE2", QP_CTYPE2(qphead), SZ_QPSTR)
#  XDIM and YDIM are needed for all the region stuff
#		Not needed for tables
            QP_XDIM(qphead) = x_geti(qp, "AXLEN1")
            QP_YDIM(qphead) = x_geti(qp, "AXLEN2")
end

procedure get_newgenwcs(qp,qphead,prefix,index1,index2)
pointer     qp                              # i: qpoe handle
pointer qphead                          # i: qpoe header
char    prefix[ARB]                     # i: keyword PREFIX
int     index1                          # i: entry number for X axis
int     index2                          # i: entry number for Y axis
 
#int     x_accessf()                     # l: check for param existence
int	junk
char    card[SZ_CARD]
char    ncard[SZ_CARD]
char    suffix1[SZ_CARD],suffix2[SZ_CARD]
 
int	x_gstr()
double	x_getd()
begin
        call sprintf(suffix1,SZ_CARD,"%d")
            call pargi(index1)
        call sprintf(suffix2,SZ_CARD,"%d")
            call pargi(index2)
 
        call strcpy("CTYP",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix1,card,SZ_CARD)
        junk = x_gstr(qp, card, QP_CTYPE1(qphead),SZ_QPSTR)
 
        call strcpy("CTYP",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix2,card,SZ_CARD)
        junk = x_gstr(qp, card, QP_CTYPE2(qphead),SZ_QPSTR)
 
        call strcpy("CRVL",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix1,card,SZ_CARD)
        QP_CRVAL1(qphead) = x_getd(qp, card)
 
        call strcpy("CRVL",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix2,card,SZ_CARD)
        QP_CRVAL2(qphead) = x_getd(qp, card)
 
        call strcpy("CDLT",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix1,card,SZ_CARD)
        QP_CDELT1(qphead) = x_getd(qp, card)
 
        call strcpy("CDLT",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix2,card,SZ_CARD)
        QP_CDELT2(qphead) = x_getd(qp, card)
 
        call strcpy("CRPX",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix1,card,SZ_CARD)
        QP_CRPIX1(qphead) = x_getd(qp, card)
 
        call strcpy("CRPX",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix2,card,SZ_CARD)
        QP_CRPIX2(qphead) = x_getd(qp, card)

#        call strcpy("LMIN",ncard,SZ_CARD)
#        call strcpy(prefix,card,SZ_CARD)
#        call strcat(ncard,card,SZ_CARD)
#        call strcat(suffix1,card,SZ_CARD)
 
        call strcpy("CROT",ncard,SZ_CARD)
        call strcpy(prefix,card,SZ_CARD)
        call strcat(ncard,card,SZ_CARD)
        call strcat(suffix2,card,SZ_CARD)
        QP_CROTA2(qphead) = x_getd(qp, card)
end
#
#  PUT_NQPHEAD -- write uhead params to qpoe header
#
#procedure put_nqphead(qp, qphead)

##int	qp				# i: qpoe handle
#pointer qphead				# i: qpoe header
#int	xheadtype			# l: type of header
#
#begin
#	xheadtype = 1
#	goto 99
#entry	put_nimhead(qp, qphead)
#	xheadtype = 2
#	goto 99
#entry	put_na3dhead(qp, qphead)
#	xheadtype = 3
#	goto 99
#entry	put_ntbhead(qp, qphead)
#	xheadtype = 4
#	goto 99
#
#	# set the header type
#99	call set_xhead(xheadtype)
#
#	# get around "too many strings in procedure" problem
#	# by calling the thing in pieces
#	call nwqph0(qp, qphead)
#	call nwqphwcs(qp, qphead, xheadtype)
#	call nwqph1(qp, qphead)
#	call nwqph2(qp, qphead)
#	call nwqph3(qp, qphead, xheadtype)
#	call nwqph4(qp, qphead)
#	if( xheadtype != 3 )
#	    call nwqph5(qp, qphead)
#end
#
