#$Header: /home/pros/xray/lib/pros/RCS/xhead.x,v 11.3 1999/09/20 19:13:16 prosb Exp $
#$Log: xhead.x,v $
#Revision 11.3  1999/09/20 19:13:16  prosb
#JCC(9/99) - Remove 'printf' statements.
#JCC(1/99) - Remove FILETER from wqphwcs to fix the problem with EVENTS[num].
#
#
#JCC(6/30/98) 
# - FITS2QP: output DATE-END or DATE_END to QPOE will depend on the input FITS.
#   QP2FITS: always write DATE-END to the output FITS.
#
# - update get_qphead() to convert format for "DATE-OBS,DATE-END" using   (done)
#  "format_date() & rdf_procdate()"
# - update wqphwcs() to write new comment for "DATE-OBS,DATE-END"  (done)
#
# - same changes in get_qphead + wqphwcs for DATE,ZERODATE,RDF_DATE,PROCDATE, 
#   but these keywords will be updated only if they exist (see wqphwcs).
#
#   In wqphwcs(), the required keywords in pros2.5_p1 are
#       "RADECSYS" => QP_RADECSYS
#       "EQUINOX"  => QP_EQUINOX
#       "MJD-OBS"  => QP_MJDOBS
#       "TIME-OBS" => QP_TIMEOBS
#       "TIME-END", "TIME_END" => QP_TIMEEND
#       "DATE-OBS" => QP_DATEOBS (if it's YYYY-MM-DD, means not exist before)
#       "DATE-END+DATE_END" =>QP_DATEEND (if it's YYYY-MM-DD, means not exist 
#                                         before)
#   Others such as "DATE,ZERODATE,RDF_DATE,PROCDATE" will be added
#   to header ONLY they exist.
#
#Revision 11.2  1998/04/24 16:14:17  prosb
#Patch Release 2.5.p1
#
#Revision 11.1  1998/01/15 18:32:24  prosb
#JCC(1/6/98) - In rmkey_axaf(), put XS-INDXX,INDXY for ASC.
#              XEXAMINE & QPSORT do not work properly without them.
#
#Revision 11.0  1997/11/06 16:20:47  prosb
#General Release 2.5
#
#Revision 9.9  1997/08/25 18:50:41  prosb
#JCC(8/22/97)-ASC does NOT need the following keys in qpoe:
#     [ add new rmkey_axaf to delete keys except DEFATTR1   ]
#     [ rmkey_axaf called by put_qphead     ]
#     [ DEFATTR1 still exits in qpoe ? ]
#
#     ROR_NUM  OPTAXISX  OPTAXISY  PHACHANS  PICHANS  MINPI
#     MAXPI    MINPHA    MAXPHA    FILTER
#
#     STDQLMRE   NSTDQLM     NTIMES     TIMESREC   XS-TIMES  TIMES
#     *DEFATTR1  POISSERR    XS-INDXX   XS-INDXY   CHECKSUM
#     DATASUM    XS-STDQL    ALLQLM     XS-ALLQL   ALLQLMRE
#
#Revision 9.8  1997/08/05 17:58:12  prosb
#JCC(8/5/97) - get_qphead() :
#              check ROR_NUM exists before reading; else set it to 0.
#
#Revision 9.7  1997/06/11 18:12:14  prosb
##JCC(6/3/97)-commented out print statements for ONTIME & LIVETIME
#             in get_qphead() & wqph3().
#
#Revision 9.6  1996/10/22  17:39:02  prosb
#MC 10/23/96  Make the cretime/limtime/datamin/datamax header updates
#             QPOE specific. (in put_qphead())
#
#Revision 9.4  1996/09/16  21:11:39  prosb
#JCC (9/16/96) Updated wqph5/xhead.x for AXAF - When QP_XDIM/QP_YDIM
#  are both greater than 32000, we want to have "short" data type
#  following the dimension (*_evt.qp[32767,32767][short]).
#
#Revision 9.3  1996/07/02  19:50:24  prosb
########################################################################
# JCC - Updated to run fits2qp & qp2fits for AXAF data.
#
# (5/7/96) - Updated to skip some keywords for acis data :
#   wqphwcs- * Use QP_CTYPE to skip "EQUINOX & RADECSYS" for acis data.
#
#   wqph4  - * Use QP_CTYPE to skip ""RA_NOM & DEC_NOM" for acis data.
#          - * Use the combination of QP_REVISION & QP_FORMAT to skip
#                 XS-XPT     XS-YPT    XS-XDET    XS-YDET   XS-FOV
#                 XS-INPXX   XS-INPXY  ROLL_NOM   OPTAXISX  OPTAXISY
#                 PHACHANS   PICHANS   MINPI      MAXPI     MINPHA
#                 MAXPHA
#
#   wqph1  - * Use the combination of QP_REVISION & QP_FORMAT to skip
#                 ROR_NUM
#
# (6/6/96) - Updated xhead.x / wqph4() to distinguish the FORMAT label
#            between axaf and rosat qpoes. Also, the FORMAT value is
#            3(=QP_FORMAT) for axaf and is 1(=CURRENT_FORMAT) for rosat.
# (7/2/96) - Updated xhead.x / wqph4() to distinguish the label of
#            REVISION between axaf and rosat qpoes.
########################################################################
#Revision 9.2  1996/02/13  15:35:39  prosb
#JCC - get QP_MISSTR from MISSION for AXAF,
#      get QP_MISSTR from TELESCOP for Rosat/Einstein.
#      QP_MISSTR is same as as QP_TELESTR for Rosat/Einstein,
#      and they are different in AXAF.
#
#Revision 9.0  1995/11/16  18:28:44  prosb
#General Release 2.4
#
#Revision 8.2  1994/09/16  15:57:05  dvs
#Added XS-INDXX and XS-INDXY keywords for new x- and y- indexing of QPOEs.
#
#Revision 8.1  94/09/13  15:19:50  dvs
#(Mo's changes...something to do with CD matrix in header)
#
#Revision 8.0  94/06/27  13:47:56  prosb
#General Release 2.3.1
#
#Revision 7.3  94/05/09  09:53:37  mo
#MC	5/9/94		Make writin TALEN/TLMIN/TLMAX keywords conditional
#			on non-zero values for XDIM
#
#Revision 7.2  94/05/02  10:20:44  mo
#MC	5/2/94		Fix x_getb error return to be FALSE (not ZERO)
#			for correct data type
#
#Revision 7.1  94/04/14  09:46:43  mo
#MC	4/14/94		Updated put_wcs to use TLMIN/MAX rather
#			than TALEN when writing QPHEAD to FITS
#
#Revision 7.0  93/12/27  18:11:21  prosb
#General Release 2.3
#
#Revision 6.7  93/12/21  14:55:20  mo
#MC	12/22/93	Still didn't get Einstein BARYTIME header parameters
#			correct
#
#Revision 6.6  93/12/16  09:39:07  mo
#MC	12/15/93		RDF updates
#
#Revision 6.5  93/11/30  18:45:50  prosb
#MC	11/30/93		Update for TIME system RDF keywords
#
#Revision 6.4  93/11/16  11:53:03  mo
#MC	11/16/93	Fix errors with SUBINST, re-instlal the 'cretime'
#			keywords, update with qpx_addf routine and
#			use PAN01 and not ROLL_NOM
#
#Revision 6.3  93/09/30  23:35:33  dennis
#Added QP_FORMAT field, FORMAT keyword, CURRENT_FORMAT constant.
#
#Revision 6.2  93/09/30  15:31:30  dennis
#(Maureen)  New RDF header keywords.
#
#
#
# Module:       XHEAD.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      X-ray header manipulation procedures on qpoe and image files
# External:     get_qphead, get_imhead, get_tbhead, put_qphead, put_imhead, put_tbhead
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

include <ctype.h>
include <math.h>
include <mach.h>
include <wfits.h>
include <qpoe.h>   
include <missions.h>
include <einstein.h>

define	SZ_CARD 10
define	QPOE	1
define	IMAGE	2
define	FITS	3
define	TABLE	4

#
#  GET_QPHEAD -- read qpoe header into uhead struct
#
procedure get_qphead(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# o: qpoe header
int	junk				# l: return from x_gstr
bool	x_getb()
int	btoi()
int	x_geti()			# l: qpoe get routines:
real	x_getr()
double	x_getd()
int	x_gstr()
int	qp_gstr()
int	x_accessf()			# l: check for param existence
int	qp_accessf()			# l: check for param existence
int	xheadtype			# l: type of header
double	foo
int	ifoo
int	bary

int	mjdref
real 	dead_time_cf
char	card[SZ_CARD]
char	ncard[SZ_CARD]
char	ncard1[SZ_CARD]
char	clockcor[SZ_CLOCKCOR]
char    temp_str[LEN_CARD]    # LEN_CARD=80 in wfits.h

begin
	xheadtype = 1
	goto 99
entry	get_imhead(qp, qphead)
	xheadtype = 2
	goto 99
entry	get_tbhead(qp, qphead)
	xheadtype = 4
	goto 99

	# set the header type
99	call set_xhead(xheadtype)

	# allocate space for qpoe header
	call calloc(qphead, SZ_QPHEAD, TY_STRUCT)

        call strcpy("",QP_OBJECT[qphead],SZ_OBJECT)
	if( xheadtype == 1)
	{
	    if( qp_accessf(qp, "title") == YES )
                junk = qp_gstr(qp, "title", QP_OBJECT[qphead], SZ_OBJECT)
	}
	else if( xheadtype == 2)
	{
            call imgstr(qp,"i_title",QP_OBJECT[qphead],SZ_OBJECT)
	}
	else if(xheadtype == 4)
	    junk = x_gstr(qp,"OBJECT",QP_OBJECT[qphead],SZ_OBJECT)
# NEW FOR RATFITS (JMORAN)
	QP_REVISION(qphead) = x_geti(qp, "REVISION")
	QP_FORMAT(qphead) = max(x_geti(qp, "FORMAT"), QP_REVISION(qphead))

#JCC - begining of the updates  (2/96)
#JCC    # lookup the mission string
#JCC    junk = x_gstr(qp, "TELESCOP", QP_MISSTR(qphead), SZ_QPSTR)

#JCC: get QP_MISSTR from MISSION for AXAF,  
#JCC: get QP_MISSTR from TELESCOP for Rosat/Einstein
        # lookup the mission string
        if( x_accessf(qp,"MISSION") == YES )
           junk = x_gstr(qp, "MISSION", QP_MISSTR(qphead), SZ_QPSTR)
        else
           if(x_accessf(qp,"TELESCOP") == YES )
              junk = x_gstr(qp,"TELESCOP",QP_MISSTR(qphead),SZ_QPSTR)

        # convert to mission id
        call mis_ctoi(QP_MISSTR(qphead), QP_MISSION(qphead))

#JCC: QP_TELESTR is a new keyword in qpoe.h.  
#JCC: In Rosat/Einstein, QP_MISSTR is same as as QP_TELESTR.
#JCC: And they are different in AXAF.
        # lookup the telescope string
        if(x_accessf(qp,"TELESCOP") == YES )
           junk = x_gstr(qp,"TELESCOP",QP_TELESTR(qphead),SZ_QPSTR)
#JCC - convert string to id for telescope.  
        call tscope_ctoi(QP_TELESTR(qphead),QP_TELE(qphead))
#JCC- end of the update  (2/96)

        # lookup the instrument string
	junk = x_gstr(qp, "INSTRUME", QP_INSTSTR(qphead), SZ_QPSTR)
	# convert to instrument id (requires mission id)
	call inst_ctoi(QP_INSTSTR(qphead), QP_MISSION(qphead), QP_INST(qphead),QP_SUBINST(qphead))
	if( QP_SUBINST(qphead) == 0 )
	{
	    if( x_accessf(qp,"XS-SUBIN") == YES )
		QP_SUBINST(qphead) = x_geti(qp,"XS-SUBIN")
	    else
		QP_SUBINST(qphead) = x_geti(qp,"SUBINST")
	}
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

        #SZ_QPSTR=10, LEN_CARD=80
	junk = x_gstr(qp, "DATE", QP_DATE(qphead), SZ_QPSTR)         #JCC
	junk = x_gstr(qp, "ZERODATE", QP_ZERODATE(qphead), SZ_QPSTR) #JCC
	junk = x_gstr(qp, "RDF_DATE", QP_RDFDATE(qphead), LEN_CARD)  #JCC
	junk = x_gstr(qp, "PROCDATE", QP_PROCDATE(qphead), LEN_CARD) #JCC

	junk = x_gstr(qp, "DATE-OBS", QP_DATEOBS(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "TIME-OBS", QP_TIMEOBS(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "DATE-END", QP_DATEEND(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "TIME-END", QP_TIMEEND(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "DATE_END", QP_DATEEND(qphead), SZ_QPSTR)
	junk = x_gstr(qp, "TIME_END", QP_TIMEEND(qphead), SZ_QPSTR)

#JCC(6/30/98)-convert DD/MM/YY to YYYY-MM-DD for DATE-OBS,DATE-END
#            - also for DATE,ZERODATE, RDF_DATE, PROCDATE
        call strcpy("",temp_str, SZ_QPSTR)      
        call format_date(QP_DATE(qphead), temp_str)       # DATE
        call strcpy("",QP_DATE[qphead], SZ_QPSTR)
        call strcpy(temp_str[1],QP_DATE[qphead], SZ_QPSTR)

        call strcpy("",temp_str, SZ_QPSTR)
        call format_date(QP_ZERODATE(qphead), temp_str)   # ZERODATE
        call strcpy("",QP_ZERODATE[qphead], SZ_QPSTR)
        call strcpy(temp_str[1],QP_ZERODATE[qphead], SZ_QPSTR)

        call strcpy("",temp_str, LEN_CARD)     #LEN_CARD=80
        call rdf_procdate(QP_RDFDATE(qphead), temp_str)   # RDFDATE
        call strcpy("",QP_RDFDATE[qphead], LEN_CARD)
        call strcpy(temp_str[1],QP_RDFDATE[qphead], LEN_CARD)
#       call printf("      get_qphead:  temp_str=%s, QP_RDFDATE=%s\n" )
#       call pargstr(temp_str)
#       call pargstr(QP_RDFDATE(qphead) )

        call strcpy("",temp_str, LEN_CARD)     #LEN_CARD=80
        call rdf_procdate(QP_PROCDATE(qphead), temp_str)   # PROCDATE
        call strcpy("",QP_PROCDATE[qphead], LEN_CARD)
        call strcpy(temp_str[1],QP_PROCDATE[qphead], LEN_CARD)
#       call printf("      get_qphead:  temp_str=%s, QP_PROCDATE=%s\n" )
#       call pargstr(temp_str)
#       call pargstr(QP_PROCDATE(qphead) )

        call strcpy("",temp_str, SZ_QPSTR)
        call format_date(QP_DATEOBS(qphead), temp_str)    # DATEOBS
        call strcpy("",QP_DATEOBS[qphead], SZ_QPSTR)
        call strcpy(temp_str[1],QP_DATEOBS[qphead], SZ_QPSTR)
#       call printf("      get_qphead:  temp_str=%s, QP_DATEOBS=%s\n" )
#       call pargstr(temp_str)
#       call pargstr(QP_DATEOBS(qphead) )

        call strcpy("",temp_str, SZ_QPSTR)
        call format_date(QP_DATEEND(qphead), temp_str)    # DATEEND
        call strcpy("",QP_DATEEND[qphead], SZ_QPSTR)
        call strcpy(temp_str[1],QP_DATEEND[qphead], SZ_QPSTR) #update QP_DATEEND
#       call printf("      get_qphead:  temp_str=%s, QP_DATEEND=%s\n")
#       call pargstr(temp_str)
#       call pargstr(QP_DATEEND(qphead) )

#end -

	call strcpy("XS-OBSID",card,SZ_CARD)
	if( x_accessf(qp, card) == YES )
	    junk = x_gstr(qp, card, QP_OBSID(qphead), SZ_OBSID)
	else if( x_accessf(qp, "SEQNO" ) == YES )
	    junk = x_gstr(qp, "SEQNO", QP_OBSID(qphead), SZ_OBSID)
	else
	    junk = x_gstr(qp, "OBS_ID", QP_OBSID(qphead), SZ_OBSID)

	call strcpy("XS-SEQPI",card,SZ_CARD)
	if( x_accessf(qp, card) == YES )
	    junk = x_gstr(qp, card, QP_SEQPI(qphead), SZ_SEQPI)
	else 
	    junk = x_gstr(qp, "OBSERVER", QP_SEQPI(qphead), SZ_SEQPI)


# Must come AFTER the 'SUBINST and MJDOBS'
# JCC(8/5/97)- Check ROR_NUM exists before reading;
#              else set it to 0.
	call fix_pspc(qphead)
	call strcpy("XS-OBSV",card,SZ_CARD)
	call strcpy("ROR_NUM",ncard,SZ_CARD)    #JCC
	if( x_accessf(qp,card)== YES)
	    QP_OBSERVER(qphead) = x_geti(qp, card)
	else
            if (x_accessf(qp,ncard)==YES)       #JCC
	        QP_OBSERVER(qphead) = x_geti(qp, "ROR_NUM")
            else                                #JCC
                QP_OBSERVER(qphead) = 0         #JCC


	call strcpy("XS-CNTRY",card,SZ_CARD)
	if( x_accessf(qp,card)== YES)
	    junk = x_gstr(qp, card, QP_COUNTRY(qphead), SZ_QPSTR)
	else
	    junk = x_gstr(qp, "ORIGIN", QP_COUNTRY(qphead), SZ_QPSTR)

#  Oops REVISION 0 PROS/SPEC/TABLE files, used FILTER for the keyword 
#	(not XS-FILTR) and it was an INTEGER, not a string.  We must
#	be able to handle this
	call strcpy("XS-FILTR",card,SZ_CARD)
	call strcpy("FILTER",ncard,SZ_CARD)
        if( x_accessf(qp, card) == YES){
	    QP_FILTER(qphead) = x_geti(qp, card)
	    call filt_itoc(QP_FILTER(qphead),QP_FILTSTR(qphead),SZ_FILTSTR)
	}
	else if( x_accessf(qp, ncard) == YES){
	    junk = x_gstr(qp, ncard, QP_FILTSTR(qphead), SZ_FILTSTR)
#  This is the REV0 PROS/SPEC/TABLE special case (FILTER keyword is INTEGER)
	    if( IS_DIGIT(QP_FILTSTR(qphead)) )
	    {
	        QP_FILTER(qphead) = x_geti(qp, ncard)
	        call filt_itoc(QP_FILTER(qphead),QP_FILTSTR(qphead),SZ_FILTSTR)
	    }		
	    call filt_ctoi(QP_FILTSTR(qphead),QP_FILTER(qphead))
	}
	else
	{
	    QP_FILTSTR(qphead) = NULL 
	    call filt_ctoi(QP_FILTSTR(qphead),QP_FILTER(qphead))
	} 

	call strcpy("XS-MODE",card,SZ_CARD)

        if( x_accessf(qp, card) == YES)
	{
	    QP_MODE(qphead) = x_geti(qp,card)
	    call mode_itoc(QP_MODE(qphead),QP_MODESTR(qphead),SZ_MODESTR)
	}
	else
	{
	    junk=  x_gstr(qp,"OBS_MODE", QP_MODESTR(qphead), SZ_MODESTR)
	    call mode_ctoi(QP_MODESTR(qphead),QP_MODE(qphead))
	}
        if( x_accessf(qp, "XS-DANG") == YES)
	    QP_DETANG(qphead) = x_getr(qp, "XS-DANG")
	else
	    QP_DETANG(qphead) = x_getr(qp, "ROLL_NOM")


	if( x_accessf(qp, "XS-MJDRF") == YES)
	    QP_MJDRFRAC(qphead) = x_getd(qp, "XS-MJDRF")
	else
	    QP_MJDRFRAC(qphead) = x_getd(qp, "MJDREFF")

	mjdref = x_geti(qp, "XS-MJDRD")
	if( mjdref == 0 )
	    mjdref = x_geti(qp, "MJDREFI")
	if( mjdref == 0 )
	{
	    foo = x_getd(qp, "MJDREF")
	    QP_MJDRDAY(qphead) = int(foo+EPSILOND)
	    QP_MJDRFRAC(qphead) = foo - double(QP_MJDRDAY(qphead))
	}
	else
	{
	    if( QP_MISSION(qphead) == EINSTEIN )
	        call fix_mjdref(mjdref)
	    QP_MJDRDAY(qphead) = mjdref
	}

	call strcpy("POISSERR",card,SZ_CARD)
        if( x_accessf(qp, card) == YES)
	    QP_POISSERR(qphead) = btoi(x_getb(qp, card))
	else
	{
	    QP_POISSERR(qphead) = YES
	} 
	ifoo = QP_POISSERR(qphead)

	call strcpy("BARYTIME",card,SZ_CARD)
        if( x_accessf(qp, card) == YES )
	    bary = btoi(x_getb(qp, card))
	else
	    bary = NO

	if( bary == YES)
	{
           call strcpy("SOLARSYSTEM",QP_TIMEREF(qphead),SZ_TIMEREF)
	}
	else
	{
	    call strcpy("LOCAL",QP_TIMEREF(qphead),SZ_TIMEREF)
	}

	    call strcpy("TIMEREF",card,SZ_CARD)
            if( x_accessf(qp, card) == YES)
	        junk= x_gstr(qp,card,QP_TIMEREF(qphead),SZ_TIMEREF)

	    call strcpy("TIMESYS",card,SZ_CARD)
            if( x_accessf(qp, card) == YES)
	        junk= x_gstr(qp,card,QP_TIMESYS(qphead),SZ_TIMESYS)
	    else if( bary == YES )
                call strcpy("MJD",QP_TIMESYS(qphead),SZ_TIMESYS)
	    else
	        call strcpy("UNKNOWN",QP_TIMESYS(qphead),SZ_TIMESYS)

	    call strcpy("CLOCKAPP",ncard1,SZ_CARD)
	    call strcpy("CLOCKCOR",ncard,SZ_CARD)
	    call strcpy("UTTIME",card,SZ_CARD)
       	    clockcor[1] = EOS
	    if( x_accessf(qp, ncard) == YES)
	    {
	        junk= x_gstr(qp,ncard,clockcor,SZ_CLOCKCOR)
	    }
	    else if( x_accessf(qp, card) == YES)
	            QP_CLOCKCOR(qphead)  = btoi(x_getb(qp, card))
	    else if( x_accessf(qp, ncard1) == YES)
	            QP_CLOCKCOR(qphead)  = btoi(x_getb(qp, ncard1))
	    else if( bary == YES)
           	    QP_CLOCKCOR(qphead) = YES
	    else
	        call strcpy("unknown",clockcor,SZ_CLOCKCOR)
	    if( clockcor[1] != EOS )
	        call clock_ctoi(clockcor,QP_CLOCKCOR(qphead))

	QP_EVTREF(qphead) = x_geti(qp, "XS-EVREF")
	QP_TBASE(qphead) = x_getd(qp, "XS-TBASE")

#  EXPTIME only available in IMAGES, provided by QPEX interface

	  if( x_accessf(qp, "EXPTIME") == YES)
	    QP_EXPTIME(qphead) = x_getd(qp, "EXPTIME")
	  else
	    QP_EXPTIME(qphead) = -1.0D0

	foo = QP_EXPTIME(qphead)

	call strcpy("XS-ONTM",ncard,SZ_CARD)	# from an old typo 
	call strcpy("XS-ONTI",card,SZ_CARD)
	if( x_accessf(qp, card) == YES)
	    QP_ONTIME(qphead) = x_getd(qp, card)
	else if( x_accessf(qp,ncard) == YES)
	    QP_ONTIME(qphead) = x_getd(qp, ncard)
	else
	    QP_ONTIME(qphead) = x_getd(qp, "ONTIME")

#JCC (6/3/97) - print out QP_ONTIME(qphead)
        #call printf("xhead/get_qphead:  QP_ONTIME : %f \n" )
        #call pargd(QP_ONTIME(qphead) )
        #call flush (STDOUT)

	call strcpy("XS-LIVTI",card,SZ_CARD)
	if( x_accessf(qp, card) == YES)
	    QP_LIVETIME(qphead) = x_getd(qp,card)
	else
	    QP_LIVETIME(qphead) = x_getd(qp, "LIVETIME")

#JCC (6/3/97) - print out QP_LIVETIME(qphead)
        #call printf("xhead/get_qphead:  QP_LIVETIME : %f \n" )
        #call pargd(QP_LIVETIME(qphead) )
        #call flush (STDOUT)

	call strcpy("XS-DTCOR",card,SZ_CARD)
	if( x_accessf(qp, card) == YES)
	    dead_time_cf = x_getr(qp, card)
	else if( x_accessf(qp, "LIVECORR") == YES)
	    dead_time_cf = x_getr(qp, "LIVECORR")
	else
	    dead_time_cf = x_getr(qp, "DTCOR")

	call fix_dead_time_cf(dead_time_cf)

	QP_DEADTC(qphead) = dead_time_cf


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
	call strcpy("XS-XDOPT",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_XDOPTI(qphead) = x_getr(qp,card)
	else
	    QP_XDOPTI(qphead) = x_getr(qp, "OPTAXISX")

	call strcpy("XS-YDOPT",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_YDOPTI(qphead) = x_getr(qp,card)
	else
	    QP_YDOPTI(qphead) = x_getr(qp, "OPTAXISY")

	# this routine needed to be split because there were too many
	# strings for one procedure
	call get_xhead1(qp,qphead)

end

procedure get_xhead1(qp,qphead)
pointer	qp		# input file handle
pointer	qphead		# output data structure pointer
int     x_geti()                        # l: qpoe get routines:
real    x_getr()
int     x_accessf()                     # l: check for param existence
 
char    card[SZ_CARD]

int	junk		# l: output from x_gstr()
int	x_gstr()

begin
	QP_BKDEN(qphead) = x_getr(qp, "XS-BKDEN")
	QP_MINLTF(qphead) = x_getr(qp, "XS-MINLT")
	QP_MAXLTF(qphead) = x_getr(qp, "XS-MAXLT")
	QP_XAOPTI(qphead) = x_getr(qp, "XS-XAOPT")
	QP_YAOPTI(qphead) = x_getr(qp, "XS-YAOPT")
	QP_XAVGOFF(qphead) = x_getr(qp, "XS-XAOFF")
	QP_YAVGOFF(qphead) = x_getr(qp, "XS-YAOFF")
	QP_RAVGROT(qphead) = x_getr(qp, "XS-RAROT")
	QP_XASPRMS(qphead) = x_getr(qp, "XS-XARMS")
	QP_YASPRMS(qphead) = x_getr(qp, "XS-YARMS")
	QP_RASPRMS(qphead) = x_getr(qp, "XS-RARMS")

	call strcpy("XS-RAPT",card,SZ_CARD)
        if( x_accessf(qp, card) == YES)
	    QP_RAPT(qphead) = x_getr(qp, card)
	else
	    QP_RAPT(qphead) = x_getr(qp, "RA_NOM")
	call strcpy("XS-DECPT",card,SZ_CARD)
        if( x_accessf(qp, card) == YES)
	    QP_DECPT(qphead) = x_getr(qp, card)
	else
	    QP_DECPT(qphead) = x_getr(qp, "DEC_NOM")
	QP_XPT(qphead) = x_geti(qp, "XS-XPT")
	QP_YPT(qphead) = x_geti(qp, "XS-YPT")
	QP_XDET(qphead) = x_geti(qp, "XS-XDET")
	QP_YDET(qphead) = x_geti(qp, "XS-YDET")
	QP_FOV(qphead) = x_getr(qp, "XS-FOV")
	call strcpy("XS-CHANS",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_PHACHANS(qphead) = x_geti(qp,card)
	else
	    QP_PHACHANS(qphead) = x_geti(qp,"PHACHANS")

#  For compatibility with REV 0 files
        QP_CHANNELS(qphead) = QP_PHACHANS(qphead)

	call strcpy("XS-CHANS",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_PICHANS(qphead) = x_geti(qp,card)
	else
	    QP_PICHANS(qphead) = x_geti(qp,"PICHANS")

	call strcpy("XS-MINCH",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_MINPHA(qphead) = x_geti(qp,card)
	else
	    QP_MINPHA(qphead) = x_geti(qp,"MINPHA")

	call strcpy("XS-MINCH",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_MINPI(qphead) = x_geti(qp,card)
	else
	    QP_MINPI(qphead) = x_geti(qp,"MINPI")

	call strcpy("XS-MAXCH",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_MAXPHA(qphead) = x_geti(qp,card)
	else
	    QP_MAXPHA(qphead) = x_geti(qp,"MAXPHA")

	call strcpy("XS-MAXCH",card,SZ_CARD)
	if( x_accessf(qp,card) == YES )
	    QP_MAXPI(qphead) = x_geti(qp,card)
	else
	    QP_MAXPI(qphead) = x_geti(qp,"MAXPI")

	QP_CRETIME(qphead) = x_geti(qp, "cretime")
	QP_MODTIME(qphead) = x_geti(qp, "modtime")
	QP_LIMTIME(qphead) = x_geti(qp, "limtime")

	call strcpy("XS-INDXX",card,SZ_CARD)
	if ( x_accessf(qp,card) == YES )
	    junk = x_gstr(qp, card, QP_INDEXX(qphead), SZ_INDEXX)
	else
	    call strcpy("x",QP_INDEXX(qphead),SZ_INDEXX)

	call strcpy("XS-INDXY",card,SZ_CARD)
	if ( x_accessf(qp,card) == YES )
	    junk = x_gstr(qp, card, QP_INDEXY(qphead), SZ_INDEXY)
	else
	    call strcpy("y",QP_INDEXY(qphead),SZ_INDEXY)
end


define	CURRENT_FORMAT	1

#
#  PUT_QPHEAD -- write uhead params to qpoe header
#
procedure put_qphead(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
int	xheadtype			# l: type of header

begin
	xheadtype = 1
	goto 99
entry	put_imhead(qp, qphead)
	xheadtype = 2
	goto 99
entry	put_a3dhead(qp, qphead)
	xheadtype = 3
	goto 99
entry	put_tbhead(qp, qphead)
	xheadtype = 4
	goto 99

	# set the header type
99	call set_xhead(xheadtype)

	# get around "too many strings in procedure" problem
	# by calling the thing in pieces
	call wqph0(qp, qphead)
	call wqphwcs(qp, qphead, xheadtype)
	call wqph1(qp, qphead)

	call wqph2(qp, qphead)
	call wqph3(qp, qphead, xheadtype)
	call wqph4(qp, qphead)
## JCC 8/22/97 - remove some keys for axaf
        call rmkey_axaf(qp, qphead)
### MC 10/18/96 -Make the cretime/limtime/datamin/datamax header updates
### Only for QPOE files
#     if( xheadtype != 3 )
      if( xheadtype == 1 )
	    call wqph5(qp, qphead)
end   ##end of put_qphead()

#***************************************************
#JCC(8/22/97) - new code used in put_qphead to delete keys for axaf
#JCC(1/6/98)  - put XS-INDXX, INDXY back for ASC.
#***************************************************
procedure rmkey_axaf(qp, qphead)

int     qp                              # i: qpoe handle
pointer qphead                          # i: qpoe header
char    ncard[SZ_CARD]
int     x_accessf()                     # l: check for param existence
int     strncmp()           

begin
   if (strncmp(QP_MISSTR(qphead),"AXAF", 4)==0)
   {   
        call strcpy("STDQLMRE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("NSTDQLM",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("NTIMES",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("TIMESREC",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("XS-TIMES",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("TIMES",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        # DEFATTR1 can NOT be removed this way, don't know why ?
        # It was added in ft_header
        call strcpy("DEFATTR1",ncard,SZ_CARD)  
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("POISSERR",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        #(1/8/98)
        #call strcpy("XS-INDXX",ncard,SZ_CARD)
        #if( x_accessf(qp, ncard) == YES )    
        #   call x_delf(qp, ncard)

        #(1/8/98)
        #call strcpy("XS-INDXY",ncard,SZ_CARD)
        #if( x_accessf(qp, ncard) == YES )    
        #   call x_delf(qp, ncard)

        call strcpy("CHECKSUM",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("DATASUM",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("XS-STDQL",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("ALLQLM",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("XS-ALLQL",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("ALLQLMRE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        ###############
        call strcpy("ROR_NUM",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("OPTAXISX",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("OPTAXISY",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("PHACHANS",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("PICHANS",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("MINPI",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("MAXPI",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("MINPHA",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("MAXPHA",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)

        call strcpy("FILTER",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )    
            call x_delf(qp, ncard)
        ###############
   }
end    ## end of rmkey_axaf()
#***************************************************

procedure wqph0(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
char	cstr[1]				# l: ditto
#char	tbuf[SZ_LINE]			# l: temp char buffer
int	x_accessf()			# l: check for param existence

#char	ocard[SZ_CARD]
char	ncard[SZ_CARD]
begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	call strcpy("c", cstr, 1)
	call strcpy("OBJECT",ncard,SZ_CARD)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, cstr, SZ_OBJECT,
			"target object name", 0)
	call x_pstr(qp, ncard, QP_OBJECT(qphead))

#JCC    if( x_accessf(qp, "TELESCOP") == NO )
#JCC       call x_addf(qp, "TELESCOP", "c", SZ_LINE,
#JCC                   "telescope (mission) name", 0)
#JCC    # convert mission id to a string
#JCC    call x_pstr(qp, "TELESCOP", QP_MISSTR(qphead))

#JCC- put QP_MISSTR to MISSION;  put QP_TELESTR to TELESCOP. (2/96)
#JCC  MISSION will be a new keyword for Rosat/Einstein.
        if((x_accessf(qp,"MISSION")==NO))
           call x_addf(qp,"MISSION","c",SZ_LINE,"mission name", 0)
        # Add QP_MISSTR to MISSION
        call x_pstr(qp, "MISSION", QP_MISSTR(qphead))

        if( x_accessf(qp, "TELESCOP") == NO )
           call x_addf(qp,"TELESCOP","c",SZ_LINE,"telescope name",0)
        # Add QP_TELESTR to TELESCOP
        call x_pstr(qp, "TELESCOP", QP_TELESTR(qphead))

#JCC- No change below. 
	if( x_accessf(qp, "INSTRUME") == NO )
	    call x_addf(qp, "INSTRUME", "c", SZ_LINE,
			"instrument (detector) name", 0)
	# convert instrument to a string
	if( x_accessf(qp, "XS-SUBIN") == YES )  # old format
	    call inst_itoc(QP_INST(qphead), QP_SUBINST(qphead), QP_INSTSTR(qphead), SZ_QPSTR)
	call x_pstr(qp, "INSTRUME", QP_INSTSTR(qphead))

end    ## end of wqph0
#***************************************************


#***************************************************
#   JCC NOTES (7/98) :
#
#   wqphwcs: write WCS keywords for qpoe header.
#
#   In wqphwcs(), the required keywords in pros2.5_p1 are
#       "RADECSYS" => QP_RADECSYS
#       "EQUINOX"  => QP_EQUINOX
#       "MJD-OBS"  => QP_MJDOBS
#       "TIME-OBS" => QP_TIMEOBS
#       "TIME-END", "TIME_END" => QP_TIMEEND
#       "DATE-OBS" => QP_DATEOBS (if it's YYYY-MM-DD, means not exist before)
#       "DATE-END+DATE_END" =>QP_DATEEND (if it's YYYY-MM-DD, means not exist 
#                                         before)
#   Others such as "DATE,ZERODATE,RDF_DATE,PROCDATE" will be added
#   to header ONLY they exist.
#***************************************************

procedure wqphwcs(qp, qphead, xheadtype)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
int	xheadtype			# i: type of header

char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
char	dstr[1]				# l: ditto
int	x_accessf()			# l: check for param existence
char	ocard[SZ_CARD]
char	ncard[SZ_CARD]
int     strncmp()          #JCC

begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	call strcpy("d", dstr, 1)
#JCC (4/15/96) - print out QP_RADECSYS, QP_EQUINOX
#JCC    call eprintf("xhead/wqphwcs:  QP_RADECSYS : %s \n" )
#JCC    call pargstr(QP_RADECSYS(qphead) )
#JCC    call flush (STDOUT)
#JCC    call eprintf("xhead/wqphwcs: QP_EQUINOX : %f  \n" )
#JCC    call pargd(QP_EQUINOX(qphead))
#JCC    call flush (STDOUT)
#JCC (4/15/96) end


#JCC(4/17/96)- "EQUINOX + RADECSYS" are written to qpoe header
#JCC         - if it's a rosat data. (i.e. QP_CTYPE1(qphead)="RA")
#JCC         - skip "EQUINOX + RADECSYS" for acis data
     if (strncmp(QP_CTYPE1(qphead),"RA", 2) == 0)    #JCC. rosat data
     {  #call eprintf("xhead/wqphwcs: QP_CTYPE1==RA  \n")   
	if( x_accessf(qp, "RADECSYS") == NO )
	    call x_addf(qp, "RADECSYS", "c", SZ_QPSTR,
					"WCS for this file (e.g. Fk4)", 0)
	call x_pstr(qp, "RADECSYS", QP_RADECSYS(qphead))
	if( x_accessf(qp, "EQUINOX") == NO )
	    call x_addf(qp, "EQUINOX", rstr, 1, "equinox (epoch) for WCS", 0)
	call x_putr(qp, "EQUINOX", QP_EQUINOX(qphead))
     }  

	# wcs pointing params
	if( xheadtype == 1 ) {
	    call put_qpwcs(qp, qphead)
	} else if( xheadtype == 2 ) {
	    call put_imwcs(qp, qphead)
	} else if(xheadtype == 4) {
	    call put_wcs(qp,qphead,"R",1,2)
	}
	if( x_accessf(qp, "MJD-OBS") == NO )
	    call x_addf(qp, "MJD-OBS", "r", 1, "MJD of start of obs.", 0)
	call x_putr(qp, "MJD-OBS", QP_MJDOBS(qphead))

#JCC - FILTER is added by mistake
#JCC    call strcpy("FILTER",ncard,SZ_CARD)
#JCC    if( x_accessf(qp, ocard) == YES )
#JCC        call x_delf(qp, ocard)
#JCC    if( x_accessf(qp, ncard) == YES )
#JCC        call x_delf(qp, ncard)
#JCC    call x_addf(qp, ncard, "c", SZ_FILTSTR, "filter id", 0)
#JCC    call x_pstr(qp, ncard, QP_FILTSTR(qphead))

#JCC(7/2/98) - DATE has new format in get_qphead(),
#            - update DATE only if it exists
        call strcpy("DATE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )
        {   call x_delf(qp,ncard)
            call x_addf(qp,ncard,"c",SZ_QPSTR,"FITS creation date",0)
            call x_pstr(qp,ncard,QP_DATE(qphead))

#           call printf(" wqphwcs  :  QP_DATE=%s",QP_DATE(qphead))
#           call pargstr(QP_DATE(qphead))
        }

#JCC(7/2/98) - ZERODATE has new format in get_qphead(),
#            - update ZERODATE only if it exists
        call strcpy("ZERODATE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )
        {   call x_delf(qp,ncard)
            call x_addf(qp,ncard,"c",SZ_QPSTR,"UT date of SC start",0)
            call x_pstr(qp,ncard,QP_ZERODATE(qphead))
        }

#JCC(7/2/98) - RDFDATE has new format in get_qphead(),
#            - update RDFDATE only if it exists    
        call strcpy("RDF_DATE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )
        {    call x_delf(qp,ncard)
             call x_addf(qp,ncard,"c", 25 ,"RDF release date",0) #JCC
             call x_pstr(qp,ncard,QP_RDFDATE(qphead))
        }

#JCC(7/2/98) - PROCDATE has new format in get_qphead(),
#            - update PROCDATE only if it exists 
        call strcpy("PROCDATE",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )   
        {    call x_delf(qp,ncard)
             call x_addf(qp,ncard,"c", 25, "SASS SEQ processing start date",0) 
             call x_pstr(qp,ncard,QP_PROCDATE(qphead))
        }

#DATE-OBS ALWAYS in header
#JCC(7/2/98)-DATE-OBS has new format in get_qphead(),
#           -Replace it with a new comment 
	if( x_accessf(qp, "DATE-OBS") == YES )
            call x_delf(qp, "DATE-OBS")
	call x_addf(qp, "DATE-OBS", "c", SZ_QPSTR,
	           "date of observation start", 0)
	call x_pstr(qp, "DATE-OBS", QP_DATEOBS(qphead))

#end

	if( x_accessf(qp, "TIME-OBS") == NO )
	    call x_addf(qp, "TIME-OBS", "c", SZ_QPSTR,
		       "time of observation start", 0)
	call x_pstr(qp, "TIME-OBS", QP_TIMEOBS(qphead))

#DATE-END ALWAYS in header
#JCC(7/2/98)-DATE_END has new format in get_qphead(),
#           -Replace it with a new comment 
	call strcpy("DATE-END",ocard,SZ_CARD)
	call strcpy("DATE_END",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )      ## used in FITS2QP
        {  call x_delf(qp,ocard)
           ##if( x_accessf(qp, ncard) == NO )     #JCC - add
           ##{
           call x_addf(qp,ocard,"c",SZ_QPSTR,"date of observation end",0)
	   call x_pstr(qp,ocard,QP_DATEEND(qphead))
#          call printf(" wqphwcs : update DATE-END\n" )
           ##}
        }
	else if( x_accessf(qp, ncard) == YES )    ## used in FITS2QP
	{  call x_delf(qp,ncard)
           call x_addf(qp,ncard,"c",SZ_QPSTR,"date of observation end",0)
           call x_pstr(qp,ncard,QP_DATEEND(qphead))
#          call printf(" wqphwcs : update DATE_END\n" )
        }
	else     ## used in QP2FITS (always output DATE-END to FITS)
	{
	    call x_addf(qp, ocard, "c", SZ_QPSTR, "date of observation end", 0)
	    call x_pstr(qp, ocard, QP_DATEEND(qphead))
#           call printf(" wqphwcs : add DATE-END\n" )
	}
#end
	
	call strcpy("TIME-END",ocard,SZ_CARD)
	call strcpy("TIME_END",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_pstr(qp, ocard, QP_TIMEEND(qphead))
	else if( x_accessf(qp, ncard) == YES )
	    call x_pstr(qp, ncard, QP_TIMEEND(qphead))
	else
	{
	    call x_addf(qp, ocard, "c", SZ_QPSTR, "time of observation end", 0)
	    call x_pstr(qp, ocard, QP_TIMEEND(qphead))
	}

end  ## end of wqphwcs
#*******************************************

procedure wqph1(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
int	x_accessf()			# l: check for param existence
char	ocard[SZ_CARD]
char	ncard[SZ_CARD]

begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	call strcpy("XS-OBSID",ocard,SZ_CARD)
	call strcpy("OBS_ID",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp,ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "c", SZ_OBSID, "observation ID", 0)
	call x_pstr(qp, ncard, QP_OBSID(qphead))

	call strcpy("XS-SEQPI",ocard,SZ_CARD)
	call strcpy("OBSERVER",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp,ocard)
        if( x_accessf(qp, ncard) == NO )
            call x_addf(qp, ncard, "c", SZ_SEQPI, "observation PI", 0)
        call x_pstr(qp, ncard, QP_SEQPI(qphead))
	
	call strcpy("XS-SUBIN",ocard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp,ocard)

#JCC(5/6/96) - Do the following if it's a rosat data (rev0 or rev1)
#JCC         - but skip them if it's a acis data (QP_FORMAT=3)
    if (QP_FORMAT(qphead) != 3) {              #JCC added
	call strcpy("XS-OBSV",ocard,SZ_CARD)
	call strcpy("ROR_NUM",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "observation id", 0)
	call x_puti(qp, ncard, QP_OBSERVER(qphead))
    }              #JCC

	call strcpy("XS-CNTRY",ocard,SZ_CARD)
	call strcpy("ORIGIN",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp, ocard, ncard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "c", SZ_QPSTR,
		       "country where data was processed", 0)
	call x_pstr(qp, ncard, QP_COUNTRY(qphead))
	
	call strcpy("XS-FILTR",ocard,SZ_CARD)
	call strcpy("FILTER",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == YES )
	    call x_delf(qp, ncard)
	call x_addf(qp, ncard, "c", SZ_FILTSTR, "filter id", 0)
	call x_pstr(qp, ncard, QP_FILTSTR(qphead))

	call strcpy("XS-MODE",ocard,SZ_CARD)
	call strcpy("OBS_MODE",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == YES )
	    call x_delf(qp, ncard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "c", SZ_MODESTR,
			"pointing mode", 0)
	call x_pstr(qp, ncard, QP_MODESTR[qphead])
end  ## end of wqph1
#****************************************************

procedure wqph2(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
char	cstr[1]				# l: ditto
char	ocard[SZ_CARD]
char   	ncard[SZ_CARD]
#char	clockcor[SZ_CARD]
int	x_accessf()			# l: check for param existence
bool	itob()
begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	call strcpy("c", cstr, 1)
	call strcpy("BARYTIME",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == YES )
            call x_delf(qp, ncard)

	call strcpy("TIMEREF",ncard,SZ_CARD)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, cstr, SZ_TIMEREF,
			"timing reference system", 0)
	call x_pstr(qp, ncard, QP_TIMEREF[qphead])

	call strcpy("TIMESYS",ncard,SZ_CARD)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, cstr, SZ_TIMESYS,
			"time coordinate system", 0)
	call x_pstr(qp, ncard, QP_TIMESYS[qphead])

	call strcpy("CLOCKAPP",ncard,SZ_CARD)
	if( QP_CLOCKCOR[qphead] != UNKNOWN )
	{
	    if( x_accessf(qp, ncard) == NO )
	        call x_addf(qp, ncard, "b", SZ_CLOCKCOR, "clock drift corrections", 0)
	    call x_putb(qp, ncard, itob(QP_CLOCKCOR[qphead]) )
	}

	call strcpy("POISSERR",ncard,SZ_CARD)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "b", SZ_CLOCKCOR,
			"clock drift corrections", 0)
	call x_putb(qp, ncard, itob(QP_POISSERR[qphead]))

	call strcpy("XS-MJDRD",ocard,SZ_CARD)
	call strcpy("MJDREFI",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1,
			"integer portion of mjd for SC clock start", 0)
	call x_puti(qp, ncard, QP_MJDRDAY(qphead))

	call strcpy("XS-MJDRF",ocard,SZ_CARD)
	call strcpy("MJDREFF",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "d", 1,
			"fractional portion of mjd for SC clock start", 0)
	call x_putd(qp, ncard, QP_MJDRFRAC(qphead))

	if( x_accessf(qp, "XS-EVREF") == NO )
	    call x_addf(qp, "XS-EVREF", istr, 1,
			"day offset from mjdrday to event start times", 0)
	call x_puti(qp, "XS-EVREF", QP_EVTREF(qphead))
	if( x_accessf(qp, "XS-TBASE") == NO )
	    call x_addf(qp, "XS-TBASE", "d", 1,
			"seconds from s/c clock start to obs start", 0)
	call x_putd(qp, "XS-TBASE", QP_TBASE(qphead))
end  ## end of wqph2
##*****************************************************

procedure wqph3(qp, qphead, xheadtype)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
int	xheadtype			# i:
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
int	x_accessf()			# l: check for param existence
char	ocard[SZ_CARD]
char   	ncard[SZ_CARD]

begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	if( xheadtype != 1 && xheadtype != 3 && QP_EXPTIME(qphead) > 0.0D0){
	  if( x_accessf(qp, "EXPTIME") == NO )
	    call x_addf(qp, "EXPTIME", "d", 1, "exposure time (seconds)", 0)
	  call x_putd(qp, "EXPTIME", QP_EXPTIME(qphead))
	}

	call strcpy("XS-ONTI",ocard,SZ_CARD)
	call strcpy("ONTIME",ncard,SZ_CARD)
	if( x_accessf(qp, "XS-ONTI") == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "d", 1, "on time (seconds)", 0)
	call x_putd(qp, ncard, QP_ONTIME(qphead))

#JCC (6/3/97) - print out QP_ONTIME(qphead)
        #call printf("xhead/wqph3:  QP_ONTIME : %f \n" )
        #call pargd(QP_ONTIME(qphead) )
        #call flush (STDOUT)

	call strcpy("XS-LIVTI",ocard,SZ_CARD)
	call strcpy("LIVETIME",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, "d", 1, "live time (seconds)", 0)
	call x_putd(qp, ncard, QP_LIVETIME(qphead))

#JCC (6/3/97) - print out QP_LIVETIME(qphead)
        #call printf("xhead/wqph3:  QP_LIVETIME : %f \n" )
        #call pargd(QP_LIVETIME(qphead) )
        #call flush (STDOUT)

	call strcpy("XS-DTCOR",ocard,SZ_CARD)
	call strcpy("DTCOR",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1, "dead time correction", 0)
	call x_putr(qp, ncard, QP_DEADTC(qphead))

#  These are pretty obsolete, don't propagate into tables
    if( QP_REVISION(qphead) == 0 && QP_INST(qphead) == ROSAT_HRI 
	&& xheadtype < 4){
	
	if( x_accessf(qp, "XS-MINLT") == NO )
	    call x_addf(qp, "XS-MINLT", rstr, 1, "min live time factor", 0)
	call x_putr(qp, "XS-MINLT", QP_MINLTF(qphead))
	if( x_accessf(qp, "XS-MAXLT") == NO )
	    call x_addf(qp, "XS-MAXLT", rstr, 1, "max live time factor", 0)
	call x_putr(qp, "XS-MAXLT", QP_MAXLTF(qphead))
	if( x_accessf(qp, "XS-XAOPT") == NO )
	    call x_addf(qp, "XS-XAOPT", rstr, 1,
			"avg. opt. axis x offset (arcsec)", 0)
	call x_putr(qp, "XS-XAOPT", QP_XAOPTI(qphead))
	if( x_accessf(qp, "XS-YAOPT") == NO )
	    call x_addf(qp, "XS-YAOPT", rstr, 1,
			"avg. opt. axis y offset (arcsec)", 0)
	call x_putr(qp, "XS-YAOPT", QP_YAOPTI(qphead))
	if( x_accessf(qp, "XS-XAOFF") == NO )
	    call x_addf(qp, "XS-XAOFF", rstr, 1, 
			"avg x aspect offset (arcsec)", 0)
	call x_putr(qp, "XS-XAOFF", QP_XAVGOFF(qphead))
	if( x_accessf(qp, "XS-YAOFF") == NO )
	    call x_addf(qp, "XS-YAOFF", rstr, 1, 
			"avg y aspect offset (arcsec)", 0)
	call x_putr(qp, "XS-YAOFF", QP_YAVGOFF(qphead))
	if( x_accessf(qp, "XS-RAROT") == NO )
	    call x_addf(qp, "XS-RAROT", rstr, 1, 
			"avg aspect rotation (degrees)", 0)
	call x_putr(qp, "XS-RAROT", QP_RAVGROT(qphead))
	if( x_accessf(qp, "XS-XARMS") == NO )
	    call x_addf(qp, "XS-XARMS", rstr, 1, 
			"avg x aspect RMS (arcsec)", 0)
	call x_putr(qp, "XS-XARMS", QP_XASPRMS(qphead))
	if( x_accessf(qp, "XS-YARMS") == NO )
	    call x_addf(qp, "XS-YARMS", rstr, 1, 
			"avg y aspect RMS (arcsec)", 0)
	call x_putr(qp, "XS-YARMS", QP_YASPRMS(qphead))
	if( x_accessf(qp, "XS-RARMS") == NO )
	    call x_addf(qp, "XS-RARMS", rstr, 1, 
			"avg aspect rotation RMS (degrees)", 0)
	call x_putr(qp, "XS-RARMS", QP_RASPRMS(qphead))
    }  # end - REVISION == 0
end    ## end of wqph2
##*****************************************************

procedure wqph4(qp, qphead)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
int	x_accessf()			# l: check for param existence
char	ocard[SZ_CARD]
char	ncard[SZ_CARD]
int     strncmp()           #JCC
int     maxformat           #JCC

begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)

#JCC(4/17/96)- "RA_NOM + DEC_NOM" are written to qpoe header if it's
#JCC         - a rosat data. (i.e. QP_CTYPE1(qphead)="RA");
#JCC         - skip "EQUINOX + RADECSYS" for acis data
     if (strncmp(QP_CTYPE1(qphead),"RA", 2) == 0)      #JCC
     {  #call eprintf("xhead/wqph4: QP_CTYPE1==RA  \n")    
        call strcpy("XS-RAPT",ocard,SZ_CARD)
	call strcpy("RA_NOM",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1,
			"nominal right ascension (degrees)", 0)
	call x_putr(qp, ncard, QP_RAPT(qphead))

	call strcpy("XS-DECPT",ocard,SZ_CARD)
	call strcpy("DEC_NOM",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1,
			"nominal declination (degrees)", 0)
	call x_putr(qp, ncard, QP_DECPT(qphead))
     }  

#JCC(5/6/96)- Do the following if it's a rosat data (rev0 or rev1)
#JCC        - but skip them if it's a acis data (QP_FORMAT=3)
    if (QP_FORMAT(qphead) != 3) {
	call strcpy("XS-DANG",ocard,SZ_CARD)
	call strcpy("ROLL_NOM",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
	    call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1,
			"nominal roll angle (degrees)", 0)
	call x_putr(qp, ncard, QP_DETANG(qphead))
    }

    #call eprintf("xhead/wqph4: QP_REVISION= %d, QP_FORMAT=%d \n")  #JCC
    #call pargi(QP_REVISION(qphead))                                #JCC
    #call pargi(QP_FORMAT(qphead))                                  #JCC

    #JCC -  if( QP_REVISION(qphead) == 0){             #original codes
    #JCC -  QP_FORMAT()=1 as of 4/11/96
    #JCC -  need to find ONE rosat REV0 data.

#JCC(4/96)- do the following if it's a rosat rev0 data(QP_REVISION=0)
#JCC        but skip them if it's a acis data(QP_FORMAT=3) 
    if(( QP_REVISION(qphead) == 0)&&(QP_FORMAT(qphead) != 3)){  #JCC added
    #   call eprintf("xhead/wqph4: QP_REVISION=0&&QP_FORMAT!=3\n") 
	if( x_accessf(qp, "XS-XPT") == NO )
	    call x_addf(qp, "XS-XPT", istr, 1,
			"target pointing direction (pixels)", 0)
	call x_puti(qp, "XS-XPT", QP_XPT(qphead))
	if( x_accessf(qp, "XS-YPT") == NO )
	    call x_addf(qp, "XS-YPT", istr, 1,
			"target pointing direction (pixels)", 0)
	call x_puti(qp, "XS-YPT", QP_YPT(qphead))
	if( x_accessf(qp, "XS-XDET") == NO )
	    call x_addf(qp, "XS-XDET", istr, 1, "x dimen. of detector", 0)
	call x_puti(qp, "XS-XDET", QP_XDET(qphead))
	if( x_accessf(qp, "XS-YDET") == NO )
	    call x_addf(qp, "XS-YDET", istr, 1, "y dimen. of detector", 0)
	call x_puti(qp, "XS-YDET", QP_YDET(qphead))
	if( x_accessf(qp, "XS-FOV") == NO )
	    call x_addf(qp, "XS-FOV", istr, 1, "field of view (degrees)", 0)
	call x_puti(qp, "XS-FOV", QP_FOV(qphead))
    }

#JCC(5/96) - Do the following if it's a rosat data (rev0 or rev1) 
#JCC       - but skip them if it's a acis data (QP_FORMAT=3) 
    if (QP_FORMAT(qphead) != 3) {        #***JCC -begin(5/6/96)***
	if( x_accessf(qp, "XS-INPXX") == NO )
	    call x_addf(qp, "XS-INPXX", rstr, 1,
			"original degrees per pixel", 0)
	call x_putr(qp, "XS-INPXX", QP_INPXX(qphead))
	if( x_accessf(qp, "XS-INPXY") == NO )
	    call x_addf(qp, "XS-INPXY", rstr, 1,
			"original degrees per pixel", 0)
	call x_putr(qp, "XS-INPXY", QP_INPXY(qphead))
    #}                                           #JCC, added

	call strcpy("XS-XDOPT",ocard,SZ_CARD)
	call strcpy("OPTAXISX",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1,
			"detector opt. axis x in detector pixels", 0)
	call x_putr(qp, ncard, QP_XDOPTI(qphead))

	call strcpy("XS-YDOPT",ocard,SZ_CARD)
	call strcpy("OPTAXISY",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, rstr, 1,
			"detector opt. axis y in detector pixels", 0)
	call x_putr(qp, ncard, QP_YDOPTI(qphead))

	call strcpy("XS-CHANS",ocard,SZ_CARD)
	call strcpy("PHACHANS",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "number pha channels", 0)
	call x_puti(qp, ncard, QP_PHACHANS(qphead))

	call strcpy("XS-CHANS",ocard,SZ_CARD)
	call strcpy("PICHANS",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "number pi energy channels", 0)
	call x_puti(qp, ncard, QP_PICHANS(qphead))

	call strcpy("XS-MINCH",ocard,SZ_CARD)
	call strcpy("MINPI",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "min pi channels", 0)
	call x_puti(qp, ncard, QP_MINPI(qphead))
	
	call strcpy("XS-MAXCH",ocard,SZ_CARD)
	call strcpy("MAXPI",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "max pi channels", 0)
	call x_puti(qp, ncard, QP_MAXPI(qphead))

	call strcpy("XS-MINCH",ocard,SZ_CARD)
	call strcpy("MINPHA",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "min pha channels", 0)
	call x_puti(qp, ncard, QP_MINPHA(qphead))
	
	call strcpy("XS-MAXCH",ocard,SZ_CARD)
	call strcpy("MAXPHA",ncard,SZ_CARD)
	if( x_accessf(qp, ocard) == YES )
            call x_delf(qp, ocard)
	if( x_accessf(qp, ncard) == NO )
	    call x_addf(qp, ncard, istr, 1, "max pha channels", 0)
	call x_puti(qp, ncard, QP_MAXPHA(qphead))
    }           #******   JCC - end (5/6/96) ************

	call strcpy("XS-INDXX",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == NO )
            call x_addf(qp, ncard, "c", SZ_INDEXX, "internal QPOE x index", 0)
        call x_pstr(qp, ncard, QP_INDEXX(qphead))

	call strcpy("XS-INDXY",ncard,SZ_CARD)
        if( x_accessf(qp, ncard) == NO )
            call x_addf(qp, ncard, "c", SZ_INDEXY, "internal QPOE y index", 0)
        call x_pstr(qp, ncard, QP_INDEXY(qphead))

#  JCC(6/4/96)-updated to have different FORMAT-label and FORMAT-value in
#     qpoe for axaf & rosat data ; The FORMAT-value is 1(=CURRENT_FORMAT)
#     for rosat data and is 3 (=QP_FORMAT) for axaf data,
        #JCC  if( x_accessf(qp, "FORMAT") == NO )
        #JCC    call x_addf(qp, "FORMAT", istr, 1,"PROS/QPOE Format Number", 0)
        #JCC  call x_puti(qp, "FORMAT", CURRENT_FORMAT)
        if( x_accessf(qp, "FORMAT") == YES )
           call x_delf(qp, "FORMAT")
        maxformat = max(CURRENT_FORMAT, QP_FORMAT(qphead))
        if (maxformat != 3)
          call x_addf(qp,"FORMAT",istr,1,"PROS/QPOE Format Number",0)
        else
          call x_addf(qp,"FORMAT",istr,1,"AXAF lab data",0) 
        call x_puti(qp, "FORMAT", maxformat)
#JCC(7/2/96)-updated to have different REVISION-label betw axaf & rosat qpoes.
        if( x_accessf(qp, "REVISION") == NO )
          if (maxformat != 3)
             call x_addf(qp,"REVISION",istr,1,"PROS/QPOE Revision Number",0)
          else
             call x_addf(qp,"REVISION",istr,1,"AXAF lab data",0)
        call x_puti(qp, "REVISION", QP_REVISION(qphead))
	
end  ## end of wqph4
##*************************************

procedure wqph5(qp, qphead)
# JCC (9/16/96) Updated wqph5/xhead.x for AXAF data - When QP_XDIM/QP_YDIM 
#   are both greater than 32000, we want to have "short" data type 
#   following the dimension (*_evt.qp[32767,32767][short]).

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	istr[1]				# l: to get around a spp restriction
char	rstr[1]				# l: ditto
int	x_accessf()			# l: check for param existence
int     qp_accessf()                    # l: check for param existence

define  SHRT_MAX  32767
int      ii 
int      datamin[8] 
int      datamax[8] 
int      blocknum 
int      minval  
int      maxval 
int      limtime
long     clktime() 

begin
        blocknum = 1
        minval   = 1
        maxval   = SHRT_MAX
        limtime  = 0

	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	if( x_accessf(qp, "cretime") == NO )
	    call x_addf(qp, "cretime", istr, 1, "QPOE file creation time", 0)
	call x_puti(qp, "cretime", QP_CRETIME(qphead))
	if( x_accessf(qp, "modtime") == NO )
	    call x_addf(qp, "modtime", istr, 1,
		"QPOE data modification time", 0)
	call x_puti(qp, "modtime", QP_MODTIME(qphead))
	if( x_accessf(qp, "limtime") == NO )
	    call x_addf(qp, "limtime", istr, 1,
		"time QPOE file limits were calculated", 0)
	call x_puti(qp, "limtime", QP_LIMTIME(qphead))

# JCC (9/16/96)
        if((QP_XDIM(qphead) > 32000)&&(QP_YDIM(qphead) > 32000)) 
        {  
           do ii=1, blocknum 
           {   datamin[ii] = minval 
               datamax[ii] = maxval 
           }

           #call eprintf("wqph5: QP_XDIM greater than 32000 \n")

           ## Fixing datamax so that axis if of type short
           if(qp_accessf(qp, "datamax") == YES)
           {
              call qp_deletef(qp, "datamax") 
           }
           call qp_addf(qp,"datamax","i",blocknum,"from QUICKFIX", 0) 
           call qp_write(qp, "datamax", datamax, blocknum, 1, "i") 

           ## Fixing datamin so that axix is of type short
           if(qp_accessf(qp, "datamin") == YES)
           {
              call qp_deletef(qp, "datamin") 
           }
           call qp_addf (qp,"datamin","i",blocknum,"from QUICKFIX", 0) 
           call qp_write(qp,"datamin", datamin, blocknum, 1, "i") 

           ## Updating limtime 
           limtime  = clktime(long (0)) 
           call qp_addi(qp, "limtime", limtime, "from QUICKFIX") 
        }
end  ## end of wqph5
##**********************************************************

#
#  SET_XHEAD -- set the xheader type
#
procedure set_xhead(type)

int	type				# i: header type
include "xhead.com"

begin
	xheadtype = type
end


# x_renamef - rename a parameter
procedure x_renamef(fd, oname, nname)
int	fd				# i: file handle
char	oname[ARB]			# i: old param name
char	nname[ARB]			# i: new param name
char	tbuf[SZ_LINE]			# l: temp buffer
int	x_accessf()
include "xhead.com"
begin
	# move the param name to a temp buffer
	call strcpy(oname, tbuf, SZ_LINE)
	# convert to upper case first
	call strupr(tbuf)
	# if param does not exist, try lower case
	if( x_accessf(fd, tbuf) == NO ){
	    call strlwr(tbuf)	
	    if( x_accessf(fd, tbuf) == NO )
		return
	}
	# get param value
	switch(xheadtype){
	case 1:
	    call qp_renamef(fd, tbuf, nname)
	default:
	    call error(1, "unknown header type")
	}
end


# x_delf - add a param
procedure x_delf (fd, param)
 
pointer fd                      #I file descriptor
char    param[ARB]              #I parameter name
include "xhead.com"
int     num                     # l
begin
        switch(xheadtype){
        case 1:
            call qp_deletef (fd, param)
        case 2:
            call imdelf(fd, param)
        case 3:
	    ;
        case 4:
            call tbhfkw(fd,param,num)
            call tbhdel(fd,num)
        default:
            call error(1, "unknown header type")
        }
end

bool procedure x_getb (fd, param)
int     fd                              # i: file handle
char    param[ARB]                      # i: param
char    tbuf[SZ_LINE]                   # l: temp buffer
bool     qp_getb(), imgetb(), tbhgtb()
int     x_accessf()
include "xhead.com"
begin
        # move the param name to a temp buffer
        call strcpy(param, tbuf, SZ_LINE)
        # convert to upper case first
        call strupr(tbuf)
        # if param does not exist, try lower case
        if( x_accessf(fd, tbuf) == NO ){
            call strlwr(tbuf)   
            if( x_accessf(fd, tbuf) == NO )
                return(FALSE)
        }
        # get param value
        switch(xheadtype){
        case 1:
            return(qp_getb(fd, tbuf))
        case 2:
            return(imgetb(fd, tbuf))
        case 4:
            return(tbhgtb(fd, tbuf))
        default:
            call error(1, "unknown header type")
        }
end

# x_geti -- get an int param
int procedure x_geti (fd, param)
int	fd				# i: file handle
char	param[ARB]			# i: param
char	tbuf[SZ_LINE]			# l: temp buffer
int	qp_geti(), imgeti(), tbhgti()
int	x_accessf()
include "xhead.com"
begin
	# move the param name to a temp buffer
	call strcpy(param, tbuf, SZ_LINE)
	# convert to upper case first
	call strupr(tbuf)
	# if param does not exist, try lower case
	if( x_accessf(fd, tbuf) == NO ){
	    call strlwr(tbuf)	
	    if( x_accessf(fd, tbuf) == NO )
		return(0)
	}
	# get param value
	switch(xheadtype){
	case 1:
	    return(qp_geti(fd, tbuf))
	case 2:
	    return(imgeti(fd, tbuf))
	case 4:
	    return(tbhgti(fd, tbuf))
	default:
	    call error(1, "unknown header type")
	}
end

# x_getr -- get a real param
real procedure x_getr (fd, param)
int	fd				# i: file handle
char	param[ARB]			# i: param
char	tbuf[SZ_LINE]			# l: temp buffer
real	qp_getr(), imgetr(), tbhgtr()
int	x_accessf()
include "xhead.com"
begin
	# move the param name to a temp buffer
	call strcpy(param, tbuf, SZ_LINE)
	# convert to upper case first
	call strupr(tbuf)
	# if param does not exist, try lower case
	if( x_accessf(fd, tbuf) == NO ){
	    call strlwr(tbuf)	
	    if( x_accessf(fd, tbuf) == NO )
		return(0.0)
	}
	# get param value
	switch(xheadtype){
	case 1:
	    return(qp_getr(fd, tbuf))
	case 2:
	    return(imgetr(fd, tbuf))
	case 4:
	    return(tbhgtr(fd, tbuf))
	default:
	    call error(1, "unknown header type")
	}
end

# x_getd -- get a double param
double procedure x_getd (fd, param)
int	fd				# i: file handle
char	param[ARB]			# i: param
char	tbuf[SZ_LINE]			# l: temp buffer
double	qp_getd(), imgetd(), tbhgtd()
int	x_accessf()
include "xhead.com"
begin
	# move the param name to a temp buffer
	call strcpy(param, tbuf, SZ_LINE)
	# convert to upper case first
	call strupr(tbuf)
	# if param does not exist, try lower case
	if( x_accessf(fd, tbuf) == NO ){
	    call strlwr(tbuf)	
	    if( x_accessf(fd, tbuf) == NO )
		return(0.0D0)
	}
	# get param value
	switch(xheadtype){
	case 1:
	    return(qp_getd(fd, tbuf))
	case 2:
	    return(imgetd(fd, tbuf))
	case 4:
	    return(tbhgtd(fd, tbuf))
	default:
	    call error(1, "unknown header type")
	}
end

# x_gstr -- get a string param
int procedure x_gstr (fd, param, obuf, maxchar)
int	fd				# i: file handle
char	param[ARB]			# i: param
char	obuf[ARB]			# o: param value
int	maxchar				# i: max char in obuf
char	tbuf[SZ_LINE]			# l: temp buffer
int	qp_gstr(), imgstr()
int	x_accessf()
include "xhead.com"
begin
	# move the param name to a temp buffer
	call strcpy(param, tbuf, SZ_LINE)
	# convert to upper case first
	call strupr(tbuf)
	# if param does not exist, try lower case
	if( x_accessf(fd, tbuf) == NO ){
	    call strlwr(tbuf)	
	    if( x_accessf(fd, tbuf) == NO )
		return(0)
	}
	# get param value
	switch(xheadtype){
	case 1:
	    return(qp_gstr(fd, tbuf, obuf, maxchar))
	case 2:
	    return(imgstr(fd, tbuf, obuf, maxchar))
	case 4:
	    call tbhgtt(fd, tbuf, obuf, maxchar)
	    return(YES)
	default:
	    call error(1, "unknown header type")
	}
end

# x_accessf - check for existence of parameter
int procedure x_accessf (fd, param)
int	fd				# i: file handle
char	param[ARB]			# i: param
int	parnum
int	qp_accessf(), imaccf()
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    return(qp_accessf(fd, param))
	case 2:
	    return(imaccf(fd, param))
	case 3:
	    return(NO)
	case 4:
	    # check for existence of parameter
	    call tbhfkw(fd, param, parnum)
	    # if parnum ==0, param does not exist
	    if( parnum ==0 )
		return(NO)
	    else
		return(YES)
	default:
	    call error(1, "unknown header type")
	}
end

# x_addf - add a param
procedure x_addf (fd, param, datatype, maxelem, comment, flags)

pointer	fd			#I file descriptor
char	param[ARB]		#I parameter name
char	datatype[ARB]		#I parameter data type
int	maxelem			#I allocated length of parameter
char	comment[ARB]		#I comment describing parameter
int	flags			#I parameter flags
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qpx_addf (fd, param, datatype, maxelem, comment, flags)
	case 2:
	    call imaddf(fd, param, datatype)
	case 3:
	    call strcpy(param, xparam, SZ_LINE)
	    call strcpy(comment, xcomment, SZ_LINE)
	case 4:
	    ;
	default:
	    call error(1, "unknown header type")
	}
end

# x_putb -- put a boolean param
procedure x_putb (fd, param, val)
int	fd				# i: file handle
char	param[ARB]			# i: param
bool	val				# i: value to put
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qp_putb(fd, param, val)
	case 2:
	    call imputb(fd, param, val)
	case 3:
	    if( xparam[1] != EOS )
		call fts_putb(fd, xparam, val, xcomment)
	    else
		call fts_putb(fd, param, val, "")
	    xparam[1] = EOS
	case 4:
	    call tbhadb(fd, param, val)
	default:
	    call error(1, "unknown header type")
	}
end

# x_puti -- put an int param
procedure x_puti (fd, param, val)
int	fd				# i: file handle
char	param[ARB]			# i: param
int	val				# i: value to put
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qp_puti(fd, param, val)
	case 2:
	    call imputi(fd, param, val)
	case 3:
	    if( xparam[1] != EOS )
		call fts_puti(fd, xparam, val, xcomment)
	    else
		call fts_puti(fd, param, val, "")
	    xparam[1] = EOS
	case 4:
	    call tbhadi(fd, param, val)
	default:
	    call error(1, "unknown header type")
	}
end

# x_putr -- put a real param
procedure x_putr (fd, param, val)
int	fd				# i: file handle
char	param[ARB]			# i: param
real	val				# i: value to put
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qp_putr(fd, param, val)
	case 2:
	    call imputr(fd, param, val)
	case 3:
	    if( xparam[1] != EOS )
		call fts_putr(fd, xparam, val, xcomment)
	    else
		call fts_putr(fd, param, val, "")
	    xparam[1] = EOS
	case 4:
	    call tbhadr(fd, param, val)
	default:
	    call error(1, "unknown header type")
	}
end

# x_putd -- put a double param
procedure x_putd (fd, param, val)
int	fd				# i: file handle
char	param[ARB]			# i: param
double	val				# i: value to put
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qp_putd(fd, param, val)
	case 2:
	    call imputd(fd, param, val)
	case 3:
	    if( xparam[1] != EOS )
		call fts_putd(fd, xparam, val, xcomment)
	    else
		call fts_putd(fd, param, val, "")
	    xparam[1] = EOS
	case 4:
	    call tbhadd(fd, param, val)
	default:
	    call error(1, "unknown header type")
	}
end

# x_pstr -- put an int param
procedure x_pstr (fd, param, val)
int	fd				# i: file handle
char	param[ARB]			# i: param
int	val				# i: value to put
include "xhead.com"
begin
	switch(xheadtype){
	case 1:
	    call qp_pstr(fd, param, val)
	case 2:
	    call impstr(fd, param, val)
	case 3:
	    if( xparam[1] != EOS )
		call fts_putc(fd, xparam, val, xcomment)
	    else
		call fts_putc(fd, param, val, "")
	    xparam[1] = EOS
	case 4:
	    call tbhadt(fd, param, val)
	default:
	    call error(1, "unknown header type")
	}
end

procedure fix_mjdref(mjdref)

int     mjdref

begin
        #---------------------------------------------------------------
        # Original mjdref for Einstein was set too large by 1
        # Correct it here, if found
        #---------------------------------------------------------------
        if (mjdref == int(EINSTEIN_MJDRDAY + 1.0E0 + EPSILONR) )
        {
           mjdref = mjdref - 1
        }
end

procedure fix_wcsref(qphead)

pointer	qphead			# i/o
bool	fp_equalr()
#real	test1,test2,delta
real	test1,test2
begin
	    if( QP_INST(qphead) == ROSAT_HRI )
	    {
#		call printf("ROSAT PSPC - CRPIX1,2: %.9f %.9f\n")
#		    call pargd(QP_CRPIX1(qphead))
#		    call pargd(QP_CRPIX2(qphead))
		test1 = QP_CRPIX1(qphead)
		test2 = ROS_HRI_TANGENT_X
	        if( fp_equalr(test1,test2) )
		    QP_CRPIX1(qphead) = ROSAT_HRI_TANGENT_X
		test1 = QP_CRPIX2(qphead)
		test2 = ROS_HRI_TANGENT_Y
	        if( fp_equalr(test1,test2) )
		    QP_CRPIX2(qphead) = ROSAT_HRI_TANGENT_Y
	    }
	    else if( QP_INST(qphead) == ROSAT_PSPC )
	    {
#		call printf("ROSAT PSPC - CRPIX1,2: %.15f %.15f\n")
#		    call pargd(QP_CRPIX1(qphead))
#		    call pargd(QP_CRPIX2(qphead))
#		call printf("ROS PSPC - CRPIX1,2: %.15f %.15f\n")
#		    call pargd(ROS_PSPC_TANGENT_X)
# 		    call pargd(ROS_PSPC_TANGENT_Y)
		test1 = QP_CRPIX1(qphead)
		test2 = ROS_PSPC_TANGENT_X
#		delta = abs(test2-test1)
#		call printf("delta %.15f\n")
#		    call pargr(delta)
		if( fp_equalr( test1,test2) )
		    QP_CRPIX1(qphead) = ROSAT_PSPC_TANGENT_X
		test1 = QP_CRPIX2(qphead)
		test2 = ROS_PSPC_TANGENT_Y
		if( fp_equalr( test1,test2) )
		    QP_CRPIX2(qphead) = ROSAT_PSPC_TANGENT_Y
	    }
	    else if( QP_INST(qphead) == EINSTEIN_HRI )
	    {
		test1 = QP_CRPIX1(qphead)
		test2 = EIN_HRI_TANGENT_X
	        if( fp_equalr( test1,test2) )
		    QP_CRPIX1(qphead) = EINSTEIN_HRI_TANGENT_X
		test1 = QP_CRPIX2(qphead)
		test2 = EIN_HRI_TANGENT_Y
	        if( fp_equalr( test1,test2) )
		    QP_CRPIX2(qphead) = EINSTEIN_HRI_TANGENT_Y
	    }
	    else if( QP_INST(qphead) == EINSTEIN_IPC )
	    {
		test1 = QP_CRPIX1(qphead)
		test2 = EIN_IPC_TANGENT_X
		if( fp_equalr( test1,test2) )
		    QP_CRPIX1(qphead) = EINSTEIN_IPC_TANGENT_X 
		test1 = QP_CRPIX2(qphead)
		test2 = EIN_IPC_TANGENT_Y
		if( fp_equalr( test1,test2) )
		    QP_CRPIX2(qphead) = EINSTEIN_IPC_TANGENT_Y
	    }
end

procedure fix_pspc(qphead)
pointer	qphead
begin

# PSPC inst =1 died during slew survey between 9/1/90 and 3/1/91
#    There were no pointed observations during this time, so the
#    exact change date is not crucial - 200 days post launch is sufficient
	if( QP_INST(qphead) == ROSAT_PSPC )
	{
		if( QP_MJDOBS(qphead) > ROSAT_MJDRDAY + 200.0D0 )
		    QP_SUBINST(qphead) = 2
		else
		    QP_SUBINST(qphead) = 1
	}

end	

#
#  IS_QPHEAD -- determine if we have a qpoe header on this file
#
int procedure is_qphead(qp)
int	qp				# i: qpoe handle
int	is_xhead()			# l: common routines
begin
	return(is_xhead(qp,1))
end

#
#  IS_IMHEAD -- determine if we have a qpoe header on this file
#
int procedure is_imhead(im)
int	im				# i: image handle
int	is_xhead()			# l: common routines
begin
	return(is_xhead(im,2))
end

int procedure is_xhead(qp, type)

int	qp				# i: qpoe handle
int	type				# i: type of file
int	x_accessf()			# l: check for param existence

begin
	# set the xhead type
	call set_xhead(type)
	if( x_accessf(qp, "TELESCOP") == NO )
	    return(NO)
	if( x_accessf(qp, "INSTRUME") == NO )
	    return(NO)
	if( x_accessf(qp, "RADECSYS") == NO )
	    return(NO)
	if( x_accessf(qp, "EQUINOX") == NO )
	    return(NO)
	if( x_accessf(qp, "MJD-OBS") == NO )
	    return(NO)
	if( x_accessf(qp, "DATE-OBS") == NO )
	    return(NO)
	# must have a qpoe header
	return(YES)
end
#
#  CLOCK_CTOI -- convert clockcor string to ID
#
procedure clock_ctoi(clockcor, clockcorid)

char    clockcor[ARB]                    # i: mission name
int     clockcorid			# o: instrument ID
int     strdic()
char	tbuf[SZ_CLOCKCOR]
string  i_names "|YES|NO|UNKNOWN|"


begin
        # convert to upper case
        call strcpy(clockcor, tbuf, SZ_CLOCKCOR)
        call strupr(tbuf)
        # look for a match
        switch ( strdic( tbuf, tbuf, SZ_CLOCKCOR, i_names ) ) {
        case 1:
	    clockcorid = YES
        case 2:
	    clockcorid = NO
        case 3:
            clockcorid = UNKNOWN
	default:
	    clockcorid = UNKNOWN
	}
end
#
#  CLOCK_ITOC -- convert clockcor ID to a string
#
procedure clock_itoc(clockcorid, clockcor, len)

int     clockcorid			# i: clockcor ID
char    clockcor[ARB]                   # o: clockcor string
int     len                             # i: length of output string

begin
        # look for a match
        switch(clockcorid){
        case YES:
            call strcpy("YES", clockcor, len)
        case NO:
            call strcpy("NO", clockcor, len)
        case UNKNOWN:
            call strcpy("UNKNOWN", clockcor, len)
	default:
            call strcpy("UNKNOWN", clockcor, len)
	}
end


procedure put_wcs(qp, qphead, prefix, index1, index2)

int	qp				# i: qpoe handle
pointer qphead				# i: qpoe header
char	prefix[ARB]			# i: keyword PREFIX
int	index1				# i: entry number for X axis
int	index2				# i: entry number for Y axis
int	lmin

char	istr[2]				# l: to get around a spp restriction
char	rstr[2]				# l: ditto
char	dstr[2]				# l: ditto
char	dash[2]				# l: 
int	x_accessf()			# l: check for param existence
char	card[SZ_CARD]
char	ncard[SZ_CARD]
char	suffix1[4],suffix2[4]

bool	fp_equald()
begin
	call strcpy("i", istr, 1)
	call strcpy("r", rstr, 1)
	call strcpy("d", dstr, 1)
	call strcpy("_", dash, 1)

	call sprintf(suffix1,SZ_CARD,"%d")
	    call pargi(index1)
	call sprintf(suffix2,SZ_CARD,"%d")
	    call pargi(index2)

	call strcpy("CTYP",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix1,card,SZ_CARD)
	if( x_accessf(qp, card) == NO )
	    call x_addf(qp, card, "c", SZ_QPSTR,
		   "axis type for dim. 1 (e.g. RA---TAN)", 0)
	call x_pstr(qp, card, QP_CTYPE1(qphead))

	call strcpy("CTYP",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, "c", SZ_QPSTR,
			   "axis type for dim. 2 (e.g. DEC--TAN)", 0)
	    call x_pstr(qp, card, QP_CTYPE2(qphead))

	call strcpy("CRVL",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1,
			   "sky coord of 1st axis (deg.)", 0)
	    call x_putd(qp, card, QP_CRVAL1(qphead))

	call strcpy("CRVL",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1,
			   "sky coord of 2nd axis (deg.)", 0)
	    call x_putd(qp, card, QP_CRVAL2(qphead))

	if( (QP_ISCD(qphead) == YES) &&
	    !(fp_equald(QP_CD11(qphead), 0.0D0)) )
	{
	    call strcpy("CD",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    call strcat(dash,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1, "rotation matrix", 0)
	    call x_putd(qp, card, QP_CD11(qphead))

	    if( !fp_equald(QP_CD12(qphead), 0.0D0) && 
	        !fp_equald(QP_CD21(qphead), 0.0D0) )
	    {
	        call strcpy("CD",ncard,SZ_CARD)
	        call strcpy(prefix,card,SZ_CARD)
	        call strcat(ncard,card,SZ_CARD)
	        call strcat(suffix1,card,SZ_CARD)
	        call strcat(dash,card,SZ_CARD)
	        call strcat(suffix2,card,SZ_CARD)
	        if( x_accessf(qp, card) == NO )
		    call x_addf(qp, card, dstr, 1, "rotation matrix", 0)
	        call x_putd(qp, card, QP_CD12(qphead))

	        call strcpy("CD",ncard,SZ_CARD)
	        call strcpy(prefix,card,SZ_CARD)
	        call strcat(ncard,card,SZ_CARD)
	        call strcat(suffix2,card,SZ_CARD)
	        call strcat(dash,card,SZ_CARD)
	        call strcat(suffix1,card,SZ_CARD)
	        if( x_accessf(qp, card) == NO )
		    call x_addf(qp, card, dstr, 1, "rotation matrix", 0)
	        call x_putd(qp, card, QP_CD21(qphead))
	    }
	
	    call strcpy("CD",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    call strcat(dash,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1, "rotation matrix", 0)
	    call x_putd(qp, card, QP_CD22(qphead))
	}
	else # ! CD matrix
	{
	    call strcpy("CDLT",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1, "x degrees per pixel", 0)
	    call x_putd(qp, card, QP_CDELT1(qphead))

	    call strcpy("CDLT",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1, "y degrees per pixel", 0)
	    call x_putd(qp, card, QP_CDELT2(qphead))

	    call strcpy("CROT",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1,
			   "rotation angle (degrees)", 0)
	    call x_putd(qp, card, QP_CROTA2(qphead))
	} # end else (!CD matrix)

	call strcpy("CRPX",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, dstr, 1,
			   "x pixel of tangent plane direction", 0)
	    call x_putd(qp, card, QP_CRPIX1(qphead))

	call strcpy("CRPX",ncard,SZ_CARD)
	call strcpy(prefix,card,SZ_CARD)
	call strcat(ncard,card,SZ_CARD)
	call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
	        call x_addf(qp, card, dstr, 1,
			   "y pixel of tangent plane direction", 0)
	    call x_putd(qp, card, QP_CRPIX2(qphead))

	if( QP_XDIM(qphead) > 0 )
	{
	    call strcpy("ALEN",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO ) 
		call x_addf(qp, card, istr, 1,
			   "x axis dimension", 0)
	    call x_puti(qp, card, QP_XDIM(qphead))

	    call strcpy("LMIN",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, istr, 1,
			   "x axis dimension", 0)
	    lmin = 1
	    call x_puti(qp, card, lmin)

	    call strcpy("LMAX",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix1,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
	    call x_addf(qp, card, istr, 1,
			   "x axis dimension", 0)
	    call x_puti(qp, card, QP_XDIM(qphead))

	    call strcpy("ALEN",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
	        call x_addf(qp, card, istr, 1,
			   "y axis dimension", 0)
	    call x_puti(qp, card, QP_YDIM(qphead))

	    call strcpy("LMIN",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, istr, 1,
			   "x axis dimension", 0)
	    lmin = 1
	    call x_puti(qp, card, lmin)

	    call strcpy("LMAX",ncard,SZ_CARD)
	    call strcpy(prefix,card,SZ_CARD)
	    call strcat(ncard,card,SZ_CARD)
	    call strcat(suffix2,card,SZ_CARD)
	    if( x_accessf(qp, card) == NO )
		call x_addf(qp, card, istr, 1,
			   "x axis dimension", 0)
	    call x_puti(qp, card, QP_YDIM(qphead))
	}	# end QP_XDIM has valid value to propagate to output file

end
