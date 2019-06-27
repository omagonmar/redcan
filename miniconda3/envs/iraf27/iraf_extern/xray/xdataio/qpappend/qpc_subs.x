#$Header: /home/pros/xray/xdataio/qpappend/RCS/qpc_subs.x,v 11.0 1997/11/06 16:37:40 prosb Exp $
#$Log: qpc_subs.x,v $
#Revision 11.0  1997/11/06 16:37:40  prosb
#General Release 2.5
#
#Revision 9.1  1997/03/27 17:40:22  prosb
#*** empty log message ***
#
# MO/JCC (10/8/96) - move "qpc_isqpoe" from qpappend/qpc_subs.x 
#                    to   lib/qpcreate/qpcisqpoe.x
#                  - remove local qpcreate.x from qpappend     
#                  - update qpappend/mkpkg
#                  - add a few lines in qpc_subs.x/mergehead for AXAF
#                    
#Revision 9.0  1995/11/16  19:02:04  prosb
#General Release 2.4
#
#Revision 8.7  1995/11/03  14:27:11  prosb
#JCC - Updated to fix the qpsim bug in iraf2.10.4.
#      (QP_MJDRFRAC=MJDREFF,QP_CDELT1,QP_CDELT2)
#
#Revision 8.6  1995/05/26  16:57:20  prosb
#JCC - add comments "QP_MJDRDAY=MJDREFI, QP_MJDRFRAC=MJDREFF"
#
#Revision 8.5  1995/05/26  16:40:17  prosb
#JCC - Converted QP_MJDRDAY from "integer" to "double" before calling
#      "fp_equald".  Also updated to use "pargi" instead of "pargd"
#      for QP_MJDRDAY output.
#
#Revision 8.1  1994/09/07  17:44:34  janet
#jd - checked for ontime=0 before divide to avoid div-by-zero error.
#
#Revision 8.0  94/06/27  17:00:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:46:29  prosb
#General Release 2.3
#
#Revision 6.2  93/12/14  18:30:19  mo
#MC	12/13/93		Make the MJDREF time check less stringent
#				Apparently a few digits differ even when
#				the values are the 'same'
#
#Revision 6.1  93/06/14  12:15:40  mo
#add header
#

include	<qpoe.h>
include	<rosat.h>
include <coords.h>
include <mach.h>

define	MR_FATAL	1

bool procedure qpc_mergehead(fileno,nofiles,newhead,qphead)
int	fileno		# i: current filenumber
int	nofiles		# i: current filenumber
pointer	newhead		# i: pointer to component QPHEAD
pointer	qphead		# i: pointer to merged QPHEAD

bool	fp_equald()
bool	fp_equalr()
bool	streq()
bool	use
begin
#        call disp_qphead(newhead,"mergenew",5)
	use = TRUE
	if( fileno == 1)
	{
#	    call amovs(Mems[newhead],Mems[qphead],SZ_QPHEAD*SZ_STRUCT)
#	    call amovs(Mems[newhead],Mems[qphead],SZ_QPHEAD)
#	    call get_qphead(qp,qphead)
#            call disp_qphead(qphead,"mergedold",5)
	    QP_DEADTC(qphead) = QP_DEADTC(qphead)*QP_ONTIME(qphead)
	    call printf("ref file:   RA: %.4H Dec: %.4h Roll: %.4f\n")
		call pargd(QP_CRVAL1(qphead))
		call pargd(QP_CRVAL2(qphead))
		call pargd(QP_CROTA2(qphead))
	}
	else
	{
#            call disp_qphead(qphead,"mergedold",5)
	    call printf("file # %d  RA: %.4H Dec: %.4h Roll: %.4f\n")
		call pargi(fileno)
		call pargd(QP_CRVAL1(newhead))
		call pargd(QP_CRVAL2(newhead))
		call pargd(QP_CROTA2(newhead))
	    call printf("offsets(arcsec):  RA: %.4f Dec: %.4f Roll: %.4f\n")
		call pargd(DEGTOSA(QP_CRVAL1(qphead)-QP_CRVAL1(newhead)))
		call pargd(DEGTOSA(QP_CRVAL2(qphead)-QP_CRVAL2(newhead)))
		call pargd(DEGTOSA(QP_CROTA2(qphead)-QP_CROTA2(newhead)))
	    call printf("file # %d  xref: %.4f yref: %.4f \n")
		call pargi(fileno)
		call pargd(QP_CRPIX1(newhead))
		call pargd(QP_CRPIX2(newhead))
	    call printf("offsets(pixels):  xoff: %.4f yoff: %.4f \n")
		call pargd(QP_CRPIX1(qphead)-QP_CRPIX1(newhead))
		call pargd(QP_CRPIX2(qphead)-QP_CRPIX2(newhead))
	    QP_ONTIME(qphead) = QP_ONTIME(qphead) + QP_ONTIME(newhead)
	    QP_DEADTC(qphead) = QP_DEADTC(qphead) + 
				QP_DEADTC(newhead)*QP_ONTIME(newhead)
	    QP_MJDOBS(qphead) = min(QP_MJDOBS(qphead),QP_MJDOBS(newhead))
#            call mjdut(MJDREFYEAR, MJDREFDAY, utclk) 
        # get obs start as a string
#        call aclri(Memi[utclk], LEN_CLK)
#        call sclk_to_ut(double(cvti4(R_SEQ_BEG(rhead),convert)),refclk,utclk)
#        call sprintf(QP_DATEOBS(qphead), SZ_QPSTR, "%02d/%02d/%02d")
#        call pargi(MDAY(utclk))
#        call pargi(MONTH(utclk))
#        call pargi(mod(YEAR(utclk),100))
#        call sprintf(QP_TIMEOBS(qphead), SZ_QPSTR, "%02d:%02d:%02d")
#        call pargi(HOUR(utclk))
#        call pargi(MINUTE(utclk))
#        call pargi(SECOND(utclk))
#JCC if( !fp_equalr(real(QP_MJDRFRAC(qphead)-QP_MJDRFRAC(newhead)),0.0E0) )
#JCC - Updated to fix the qpsim bug in iraf2.10.4. 
  if ( (abs(QP_MJDRFRAC(qphead)-QP_MJDRFRAC(newhead))) > EPSILONR)
	    {
		call eprintf("XS-MJDRF values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargd(QP_MJDRFRAC(qphead) )
		    call pargd(QP_MJDRFRAC(newhead) )
		call eprintf("Unable to merge file due to XS-MJDRF values -- skipping")
		use = FALSE
		goto 99
	    }
#JCC- if( !fp_equald(QP_MJDRDAY(qphead)-QP_MJDRDAY(newhead),0.0D0) )
#JCC- QP_MJDRDAY is MJDREFI in fits/qpoe header
#JCC- QP_MJDRFRAC is MJDREFF in fits/qpoe header
        if( !fp_equald(double(QP_MJDRDAY(qphead)-QP_MJDRDAY(newhead)),0.0D0) )
	    {
		call eprintf("XS-MJDRD values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %d   current: %d\n" )     #JCC
		    call pargi(QP_MJDRDAY(qphead) )        #JCC
		    call pargi(QP_MJDRDAY(newhead) )       #JCC
		call eprintf("Unable to merge files due to XS-MJDRD values- skipping\n")
		use = FALSE
		goto 99 
	    }
	    if( QP_FILTER(qphead) != QP_FILTER(newhead) )
	    {
		call eprintf("FILTER values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %d   current: %d\n" )
		    call pargi(QP_FILTER(qphead) )
		    call pargi(QP_FILTER(newhead) )
		call eprintf("Unable to merge files due to XS-FILTR values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( QP_XDIM(qphead) != QP_XDIM(newhead) )
	    {
		call eprintf("AXLEN 1 values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %d   current: %d\n" )
		    call pargi(QP_XDIM(qphead) )
		    call pargi(QP_XDIM(newhead) )
		call eprintf("Unable to merge files due to AXLEN1 values-- skipping")
		use = FALSE
		goto 99
	    }
	    if( QP_YDIM(qphead) != QP_YDIM(newhead) )
	    {
		call eprintf("AXLEN 2 values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargi(QP_YDIM(qphead) )
		    call pargi(QP_YDIM(newhead) )
		call eprintf("Unable to merge files due to AXLEN2 values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !streq(QP_CTYPE1(qphead),QP_CTYPE1(newhead)) )
	    {
		call eprintf("CTYPE1  values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %s   current: %s\n" )
		    call pargstr(QP_CTYPE1(qphead) )
		    call pargstr(QP_CTYPE1(newhead) )
		call eprintf("Unable to merge files due to CTYPE1 values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !streq(QP_CTYPE2(qphead),QP_CTYPE2(newhead)) )
	    {
		call eprintf("CTYPE2  values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %s   current: %s\n" )
		    call pargstr(QP_CTYPE2(qphead) )
		    call pargstr(QP_CTYPE2(newhead) )
		call eprintf("Unable to merge files due to CTYPE1 values -- skipping")
		use = FALSE
		goto 99
	    }
#JCC- if( !fp_equald(QP_CDELT1(qphead)-QP_CDELT1(newhead),0.0D0) )
#JCC - Updated to fix the qpsim bug in iraf2.10.4. 
  if ( (abs(QP_CDELT1(qphead)-QP_CDELT1(newhead))) > EPSILOND)
	    {
		call eprintf("CDELT1 values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargd(QP_CDELT1(qphead) )
		    call pargd(QP_CDELT1(newhead) )
		call eprintf("Unable to merge files due to CDELT1 values -- skipping")
		use = FALSE
		goto 99
	    }
#JCC - if( !fp_equald(QP_CDELT2(qphead)-QP_CDELT2(newhead),0.0D0) )
#JCC - Updated to fix the qpsim bug in iraf2.10.4. 
  if ( (abs(QP_CDELT2(qphead)-QP_CDELT2(newhead))) > EPSILOND)
	    {
		call eprintf("CDELT2 values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargd(QP_CDELT2(qphead) )
		    call pargd(QP_CDELT2(newhead) )
		call printf("Unable to merge files due to CDELT2 values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !fp_equalr(QP_EQUINOX(qphead)-QP_EQUINOX(newhead),0.0E0) )
	    {
		call eprintf("EQUINOX values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargd(QP_EQUINOX(qphead) )
		    call pargd(QP_EQUINOX(newhead) )
		call eprintf(MR_FATAL,"Unable to merge files due to EQUINOXvalues  -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !streq(QP_MISSTR(qphead),QP_MISSTR(newhead)) )
	    {
		call eprintf("Telescope values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %s   current: %s\n" )
		    call pargstr(QP_MISSTR(qphead) )
		    call pargstr(QP_MISSTR(newhead) )
		call eprintf("Unable to merge files due to TELESCOPE values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !streq(QP_INSTSTR(qphead),QP_INSTSTR(newhead)) )
	    {
		call eprintf("Telescope values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %s   current: %s\n" )
		    call pargstr(QP_INSTSTR(qphead) )
		    call pargstr(QP_INSTSTR(newhead) )
		call eprintf("Unable to merge files due to INSTRUMENT values -- skipping")
		use = FALSE
		goto 99
	    }
	    if( !streq(QP_RADECSYS(qphead),QP_RADECSYS(newhead)) )
	    { 
		call eprintf("RA_DEC system values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %s   current: %s\n" )
		    call pargstr(QP_RADECSYS(qphead) )
		    call pargstr(QP_RADECSYS(newhead) )
		call eprintf("Unable to merge files due to RADECSYS values -- skipping")
		use = FALSE
		goto 99
	    }

#MO/JCC (10/8/96) - add the following lines for AXAF
            if (QP_MJDOBS(newhead) < QP_MJDOBS(qphead))   
            {  
#		call printf("case 1\n")
                call strcpy(QP_DATEOBS(newhead),QP_DATEOBS(qphead),SZ_QPSTR)
                call strcpy(QP_TIMEOBS(newhead),QP_TIMEOBS(qphead),SZ_QPSTR)
#	        call printf("DATEOBS %s  TIMEOBS %s \n")
#		call pargstr(QP_DATEOBS(qphead))
#		call pargstr(QP_TIMEOBS(qphead))
            }
	    else
	    {
#		call printf("case 3\n")
                call strcpy(QP_DATEEND(newhead),QP_DATEEND(qphead),SZ_QPSTR)
                call strcpy(QP_TIMEEND(newhead),QP_TIMEEND(qphead),SZ_QPSTR)
#	        call printf("DATEEND %s  TIMEEND %s \n")
#		call pargstr(QP_DATEEND(qphead))
#		call pargstr(QP_TIMEEND(qphead))
            }
#MO/JCC (10/8/96) - end of adding  

	}   # end of "if( fileno == 1)"

	if( fileno == nofiles )
	{
#           avoid divide-by-zero error
            if ( QP_ONTIME(qphead) > EPSILOND ) {
	       QP_DEADTC(qphead) = QP_DEADTC(qphead) / QP_ONTIME(qphead)
	    } else {
	       QP_DEADTC(qphead) = 0.0d0
	    }
#	    call printf("update date/time\n")
#	    QP_DATEEND(qphead) = QP_DATEEND(newhead)
#	    QP_TIMEEND(qphead) = QP_TIMEEND(newhead)
	    if( QP_MJDOBS(qphead) < 1 )
	    {
#	        call printf("last file\n")
	        call strcpy(QP_DATEEND(newhead),QP_DATEEND(qphead),SZ_QPSTR)
	        call strcpy(QP_TIMEEND(newhead),QP_TIMEEND(qphead),SZ_QPSTR)
	    }
#	    call printf("DATEEND %s  TIMEEND %s \n")
#		call pargstr(QP_DATEEND(qphead))
#		call pargstr(QP_TIMEEND(qphead))
#	    call printf("done - update date/time\n")
	}
99	return(use)
end
#
#JCC (10/8/96) - removed "int procedure qpc_isqpoe(fname)"
#
