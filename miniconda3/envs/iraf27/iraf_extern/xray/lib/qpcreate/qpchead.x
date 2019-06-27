#$Header: /home/pros/xray/lib/qpcreate/RCS/qpchead.x,v 11.0 1997/11/06 16:21:58 prosb Exp $
#$Log: qpchead.x,v $
#Revision 11.0  1997/11/06 16:21:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:29:28  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:16  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:17:00  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:25:32  mo
#MC	12/15/93		Update for qpx_addf and ensure
#				that 'defattr' keyword is written
#
#Revision 6.0  93/05/24  15:58:15  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:18:43  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:52:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:17  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:56  pros
#General Release 1.0
#
#
# Module:       QPCHEAD.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Write the standard PROS QPOE header
# External:     qpc_wrheadqp,qpc_defblock,qpc_version
# Local:        < routines which are NOT intended to be called by applications>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- initial version      1988
#               {1} mc    -- to support ROSAT/PSPC -- 1/91
#                         -- to replace qp_astr to qp_pstr -- 1/91
#               {n} <who> -- <does what> -- <when>
#

include <qpset.h>
include <time.h>
include <qpoe.h>
include "qpcreate.h"

define	SZ_PARAM	20
#
# QPC_WRHEADQP -- write standard header of output file
#
procedure qpc_wrheadqp(qp, qphead, display)

int	qp				# i: qpoe handle
pointer	qphead				# i: qpoe header
int	display				# i: display level

int	naxes				# l: number of axes
int	axlen[2]			# l: length of axes

begin
	#  get axis information from header
	naxes     = 2
	axlen[1]  = QP_XDIM(qphead)
	axlen[2]  = QP_YDIM(qphead)
	# Setup the QPOE file header with some basic information
	call qpx_addf (qp, "naxes", "i", 1, "number of qpoe axes", 0)
	call qp_puti (qp, "naxes", naxes)
	call qpx_addf (qp, "axlen", "i", 2, "length of each axis", 0)
	call qp_write (qp, "axlen", axlen, 2, 1, "i")
	if( display >=5 ){
	    call printf("axis length =%d %d\n")
	    call pargi(axlen[1])
	    call pargi(axlen[2])
	}
	call qpc_wrheadqp1(qp)
end
#
# QPC_WRHEADQP1 -- write MORE standard header of output file
#
procedure qpc_wrheadqp1(qp)
pointer	qp

pointer	sp,buf
int	qp_accessf()

begin
	call smark(sp)
	call salloc(buf,SZ_PARAM,TY_CHAR)
        call strcpy("defattr1",Memc[buf],SZ_PARAM)
        if( qp_accessf(qp, Memc[buf] ) == YES )
            call qp_deletef(qp,Memc[buf])
        call qpx_addf(qp, Memc[buf], "c", SZ_LINE,
                     "exposure time (seconds)",0)
        call qp_pstr(qp,Memc[buf], "EXPTIME = integral time:d")
	call sfree(sp)
end
#
# QPC_DEFBLOCK -- set default block factor in a qpoe file
#
procedure qpc_defblock(qp, block)

int	qp				# i: qpoe handle
int	block				# i: block factor
int	qp_accessf()			# l: parameter existence

begin
	if( qp_accessf(qp, "defblock") == NO )
	    call qpx_addf (qp, "defblock", "i", 1, "default QPOE block factor",
			  0)
	call qp_puti (qp, "defblock", block)
end

#
# QPC_VERSION -- write version of the qpoe and pros
#
procedure qpc_version(qp, display)

int	qp				# i: qpoe handle
int	display				# i: display level

int	version				# l: QPOE version
char	pversion[SZ_FNAME]		# l: pros version
int	qp_accessf()			# l: parameter existence
int	qp_stati()			# get int status

begin
	# add the QPOE version
	version = qp_stati(qp, QPOE_VERSION)
	if( qp_accessf(qp, "qp_version") == NO )
	    call qpx_addf (qp, "qp_version", "i", 1, "QPOE version", 0)
	call qp_puti (qp, "qp_version", version)
	# add the PROS version
	if( qp_accessf(qp, "pros_version") == NO )
	    call qpx_addf (qp, "pros_version", "c", SZ_LINE, "PROS version", 0)
	# get pros version from package param file
	call clgstr("version", pversion, SZ_FNAME)
	call qp_pstr (qp, "pros_version", pversion)
	if( display >= 5){
	    call printf("QPOE version: %d\n")
	    call pargi(version)
	    call printf("PROS version: %s\n")
	    call pargstr(pversion)
	}
end

