#$Header: /home/pros/xray/lib/qpcreate/RCS/qpc_subs.x,v 11.0 1997/11/06 16:21:49 prosb Exp $
#$Log: qpc_subs.x,v $
#Revision 11.0  1997/11/06 16:21:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:32:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:41  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:57:55  prosb
#General Release 2.2
#
#Revision 1.1  93/05/19  17:22:23  mo
#Initial revision
#
include	<qpoe.h>
include	<rosat.h>
include <coords.h>

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
	    if( !fp_equald(QP_MJDRFRAC(qphead)-QP_MJDRFRAC(newhead),0.0D0) )
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
	    if( !fp_equald(QP_MJDRDAY(qphead)-QP_MJDRDAY(newhead),0.0D0) )
	    {
		call eprintf("XS-MJDRD values do not match - file: %d\n")
		    call pargi(fileno)
		call eprintf("  original: %f   current: %f\n" )
		    call pargd(QP_MJDRDAY(qphead) )
		    call pargd(QP_MJDRDAY(newhead) )
		call eprintf("Unable to merge files due to XS-MJDRD values-- skipping")
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
	    if( !fp_equald(QP_CDELT1(qphead)-QP_CDELT1(newhead),0.0D0) )
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
	    if( !fp_equald(QP_CDELT2(qphead)-QP_CDELT2(newhead),0.0D0) )
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
	}
	if( fileno == nofiles )
	{
	    QP_DEADTC(qphead) = QP_DEADTC(qphead) / QP_ONTIME(qphead)
	    QP_DATEEND(qphead) = QP_DATEEND(newhead)
	    QP_TIMEEND(qphead) = QP_TIMEEND(newhead)
	}
99	return(use)
end

#
#	QPC_ISQPOE - determine if a file is a qpoe file
#
int procedure qpc_isqpoe(fname)

char	fname[ARB]			# i: file name
int	got				# l: got a qpoe file?
int	len				# l: length of file name
int	index				# l: index for "["
pointer	temp				# l: temp file name
pointer	sp				# l: stack pointer
int	qp_access()			# l: test for qpoe existence
int	strlen()			# l: length of string
int	stridx()			# l: index into string

begin
	# mark the stack
	call smark(sp)
	call strip_whitespace(fname)
	if( fname[1] != '@' )
	{
	  # get length of string
	  len = strlen(fname)	
	  # make a copy
	  call salloc(temp, len+1, TY_CHAR)
	  call strcpy(fname, Memc[temp], len)
	  # look for a "["
	  index = stridx("[", Memc[temp])
	  # cut out any filter
	  if( index !=0 )
	    Memc[temp+index-1] = EOS
	  # now look for a qpoe file
	  got = qp_access(Memc[temp], 0)
	  # release stack space
	  call sfree(sp)
	  # and return the news
	}
	else
	  got = YES
	return(got)
end
