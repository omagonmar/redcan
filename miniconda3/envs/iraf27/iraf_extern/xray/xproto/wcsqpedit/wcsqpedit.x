# $Header: /home/pros/xray/xproto/wcsqpedit/RCS/wcsqpedit.x,v 11.1 1999/02/18 21:16:08 prosb Exp $
# $Log: wcsqpedit.x,v $
# Revision 11.1  1999/02/18 21:16:08  prosb
# JCC(2/99)-updated to allow changing to negative declinations(CRVAL2).
#
# Revision 11.0  1997/11/06 16:39:07  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:27:03  prosb
# General Release 2.4
#
#Revision 8.1  1995/04/12  15:58:44  prosb
#MC	4/11/95		Add support for additional WCS paramters:
#				CTYPE and CDELT
#
#Revision 8.0  94/06/27  17:26:35  prosb
#General Release 2.3.1
#
#Revision 7.1  94/03/25  13:43:01  mo
#MC	3/25/94		Add 'axlen' parameters
#
#Revision 7.0  93/12/27  18:51:36  prosb
#General Release 2.3
#
#Revision 6.1  93/08/19  12:18:37  mo
#MC	8/20/93		Update with new CROTA2 parameter
#
#Revision 6.0  93/05/24  16:43:59  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:41:36  prosb
#General Release 2.1
#
#Revision 1.2  92/10/23  09:53:30  mo
#new task
#
#Revision 1.1  92/10/14  11:24:10  mo
#Initial revision
#
#
# Module:       QPWCSEDIT
# Project:      PROS -- ROSAT RSDC
# Purpose:      Update the CRVAL1,2 and CRPIX1,2 WCS parameters for QPOE
# External:     t_wcsqpedit
# Local:        ds_put_qpwcs
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} DS/MC  initial version Oct 92
#               {n} <who> -- <does what> -- <when>
#
include <ext.h>
include <error.h>
include <qpc.h>
include <qpoe.h>
include <math.h>
include <wfits.h>
include <missions.h>


procedure t_wcsqpedit ()

int	display
int	len
pointer sp				# Stack pointer
pointer qp_fname			# QPOE file name 
pointer qp_root                 	# qp root name
pointer	radecsys
pointer	ctype1
pointer	ctype2
pointer evlist                  	# event list buffer
pointer	buf
bool	ck_none()			# check none function
bool	ck_empty()
bool	streq(),fp_equald()			# string equals function
int	clgeti(),qp_accessf()

pointer qp                      	# qp file handle
pointer qp_open()               	# qp open function
pointer qphead                  	# qp header pointer
double	clgetd()			# get real from cl
real	clgetr()			# get real from cl
real	equinox
int	itest
int	axlen[2]
real	testr
double	test
double	crpix1,crpix2,crval1,crval2,crota2,cdelt1,cdelt2
begin
        call smark(sp)
	call salloc(qp_fname, SZ_PATHNAME, TY_CHAR)
        call salloc(qp_root, SZ_FNAME, TY_CHAR)
        call salloc(evlist,  SZ_EXPR, TY_CHAR)
        call salloc(buf,  SZ_LINE, TY_CHAR)
        call salloc(radecsys,  SZ_QPSTR, TY_CHAR)
        call salloc(ctype1,  SZ_QPSTR, TY_CHAR)
        call salloc(ctype2,  SZ_QPSTR, TY_CHAR)

#-------------------
# Get QPOE file name
#-------------------
	call clgstr("qpfile", Memc[qp_fname], SZ_PATHNAME)
	display = clgeti("display")
	call rootname(Memc[qp_fname], Memc[qp_fname], EXT_QPOE, SZ_PATHNAME)
        if (ck_none(Memc[qp_fname]) || streq("", Memc[qp_fname])) 
           call error(EA_FATAL, "requires *.qp file as input")

#------------------------------------------------------------------------
# Parse the filter specifier into evlist and the qp rootname into qp_root
#------------------------------------------------------------------------
        call qp_parse(Memc[qp_fname], Memc[qp_root], SZ_PATHNAME,
                      Memc[evlist], SZ_EXPR)

#------------------------------
# Open the input file as a QPOE
#------------------------------
        qp = qp_open(Memc[qp_root], READ_WRITE, NULL)

#--------------------
# Get the qpoe header
#--------------------
        call get_qphead(qp, qphead)

        # work-around for qpoe bug in which we can't read and then write
        # to a qpoe file [from qpcaddaux()]:
        call qp_close(qp)
        qp = qp_open(Memc[qp_root], READ_WRITE, NULL)

#-------------------------
# Get parameters from user
#-------------------------

	if( display >= 1){
	    call printf("current CDELT1: %.12f \n")
		call pargd(QP_CDELT1(qphead))
	}
	cdelt1=QP_CDELT1(qphead)
	test = clgetd("cdelt1")
	if( !fp_equald (test, -999.9D0 ) )
	    QP_CDELT1(qphead) = test
	if( display >= 2){
	    call printf("new CDELT1: %.12f  \n")
		call pargd(QP_CDELT1(qphead))
	}

	if( display >= 1){
	    call printf("current CDELT2: %.12f \n")
		call pargd(QP_CDELT2(qphead))
	}
	cdelt2=QP_CDELT2(qphead)
	test = clgetd("cdelt2")
	if( !fp_equald (test, -999.9D0 ) )
	    QP_CDELT2(qphead) = test
	if( display >= 2){
	    call printf("new CDELT2: %.12f  \n")
		call pargd(QP_CDELT2(qphead))
	}

	if( display >= 1){
	    call printf("current CRVAL1: %.12f   (%.4H)\n")
		call pargd(QP_CRVAL1(qphead))
		call pargd(QP_CRVAL1(qphead))
	}
	crval1=QP_CRVAL1(qphead)
	test = clgetd("crval1")
	if( test > 0.0D0 )
	    QP_CRVAL1(qphead) = test
	if( display >= 2){
	    call printf("new CRVAL1: %.12f   (%.4H)\n")
		call pargd(QP_CRVAL1(qphead))
		call pargd(QP_CRVAL1(qphead))
	}

	if( display >= 1){
	    call printf("current CRVAL2: %.12f   (%.4h)\n")
		call pargd(QP_CRVAL2(qphead))
		call pargd(QP_CRVAL2(qphead))
	}
	crval2=QP_CRVAL2(qphead)
	test = clgetd("crval2")
#if( test > 0.0D0 ) 
#JCC-replace it with the following condition:  
#JCC(2/99):  -90.0 <  QP_CRVAL2=DEC < 90    
        if ((test > -90.0D0) && (test < 90.0D0))
	    QP_CRVAL2(qphead) = test
	if( display >= 2){
	    call printf("new CRVAL2: %.12f   (%.4h)\n")
		call pargd(QP_CRVAL2(qphead))
		call pargd(QP_CRVAL2(qphead))
	}
	if( display >= 1){
	    call printf("current CROTA2: %.6f\n")
		call pargd(QP_CROTA2(qphead))
	}
	crota2=QP_CROTA2(qphead)
	test = clgetd("crota2")
	if( test > -360.0D0 )
	    QP_CROTA2(qphead) = test
	if( display >= 2){
	    call printf("new CROTA2: %.6f\n")
		call pargd(QP_CROTA2(qphead))
	}

	if( display >= 1){
	    call printf("current CRPIX1: %.4f   \n")
		call pargd(QP_CRPIX1(qphead))
	}
	crpix1=QP_CRPIX1(qphead)
	test  = clgetd("crpix1")
	if( test > 0.0D0 )
	    QP_CRPIX1(qphead) = test
	if( display >= 2){
	    call printf("new CRPIX1: %.4f   \n")
		call pargd(QP_CRPIX1(qphead))
	}

	if( display >= 1){
	    call printf("current CRPIX2: %.4f   \n")
		call pargd(QP_CRPIX2(qphead))
	}
	crpix2=QP_CRPIX2(qphead)
	test = clgetd("crpix2")
	if( test > 0.0D0 )
	    QP_CRPIX2(qphead) = test
	if( display >= 2){
	    call printf("new CRPIX2: %.4f   \n")
		call pargd(QP_CRPIX2(qphead))
	}
	if( display >= 1){
	    call printf("current EQUINOX: %.4f   \n")
		call pargr(QP_EQUINOX(qphead))
	}
	equinox=QP_EQUINOX(qphead)
	testr = clgetr("equinox")
	if( testr > 0.0D0 )
	    QP_EQUINOX(qphead) = testr
	if( display >= 2){
	    call printf("new EQUINOX: %.4f   \n")
		call pargr(QP_EQUINOX(qphead))
	}

	if( display >= 1){
	    call printf("current CTYPE1: %s   \n")
		call pargstr(QP_CTYPE1(qphead))
	}
	call strcpy(QP_CTYPE1(qphead),Memc[ctype1],SZ_QPSTR)
	call clgstr("ctype1",Memc[buf],SZ_QPSTR)
	if( !ck_empty(Memc[buf]) )
	    call strcpy(Memc[buf],QP_CTYPE1(qphead),SZ_QPSTR)
	if( display >= 2){
	    call printf("new CTYPE1: %s   \n")
		call pargstr(QP_CTYPE1(qphead))
	}

	if( display >= 1){
	    call printf("current CTYPE2: %s   \n")
		call pargstr(QP_CTYPE2(qphead))
	}
	call strcpy(QP_CTYPE2(qphead),Memc[ctype2],SZ_QPSTR)
	call clgstr("ctype2",Memc[buf],SZ_QPSTR)
	if( !ck_empty(Memc[buf]) )
	    call strcpy(Memc[buf],QP_CTYPE2(qphead),SZ_QPSTR)
	if( display >= 2){
	    call printf("new CTYPE2: %s   \n")
		call pargstr(QP_CTYPE2(qphead))
	}

	if( display >= 1){
	    call printf("current RADECSYS: %s   \n")
		call pargstr(QP_RADECSYS(qphead))
	}
	call strcpy(QP_RADECSYS(qphead),Memc[radecsys],SZ_QPSTR)
	call clgstr("radecsys",Memc[buf],SZ_QPSTR)
	if( !ck_empty(Memc[buf]) )
	    call strcpy(Memc[buf],QP_RADECSYS(qphead),SZ_QPSTR)
	if( display >= 2){
	    call printf("new RADECSYS: %s   \n")
		call pargstr(QP_RADECSYS(qphead))
	}

	if( display >= 1){
	    call printf("current AXLEN1: %d   \n")
		call pargi(QP_XDIM(qphead))
	}
	axlen[1]=QP_XDIM(qphead)
	itest  = clgeti("axlen1")
	if( itest > 0 )
	{
	    QP_XDIM(qphead) = itest
	    axlen[1] = itest
	}
	if( display >= 2){
	    call printf("new AXLEN1: %d   \n")
		call pargi(QP_XDIM(qphead))
	}

	if( display >= 1){
	    call printf("current AXLEN2: %d   \n")
		call pargi(QP_YDIM(qphead))
	}
	axlen[2]=QP_YDIM(qphead)
	itest  = clgeti("axlen2")
	if( itest > 0 )
	{
	    QP_YDIM(qphead) = itest
	    axlen[2] = itest
	}
	if( display >= 2){
	    call printf("new AXLEN2: %d   \n")
		call pargi(QP_YDIM(qphead))
	}

#--------------------
# Put the qpoe header
#--------------------

	if( qp_accessf(qp,"axlen") == NO )
            call qpx_addf (qp, "axlen", "i", 2, "length of each axis", 0)
        call qp_write (qp, "axlen", axlen, 2, 1, "i")

#	call ds_put_qphead(qp, qphead)
	call put_qphead(qp, qphead)
	call ds_put_qpwcs(qp, qphead)

#---------
# Add the history record
#---------------------------
        len = SZ_LINE
        call sprintf(Memc[buf], len, "original CRVAL1:%.4f CRVAL2:%.4f")
	    call pargd(crval1)
	    call pargd(crval2)
        call put_qphistory(qp, "wcsqpedit", Memc[buf], "")
 	call sprintf(Memc[buf],len,"original CRROTA2 %.6f")
	    call pargd(crota2)
        call put_qphistory(qp, "wcsqpedit", Memc[buf], "")
 	call sprintf(Memc[buf],len,"original CRPIX1 %.4f CRPIX2: %.4f")
	    call pargd(crpix1)
	    call pargd(crpix2)
        call put_qphistory(qp, "wcsqpedit", Memc[buf], "")
	call sprintf(Memc[buf],len,"original EQUINOX: %.1f,RADECSYS: %s")
	    call pargr(equinox)
	    call pargstr(QP_RADECSYS(qphead))
        call put_qphistory(qp, "wcsqpedit", Memc[buf], "")

#---------
# Close up
#---------

	call qp_close(qp)
	call sfree(sp)

end


############################################################################
############################################################################


#
# DS_PUT_QPWCS -- write a new wcs from the qpoe header (physical and logical)
#
#	(This version, not for general use, forces the write, regardless of 
#	whether the file already contains a WCS.  For test purposes only.)
#
#

procedure ds_put_qpwcs(qp, qphead)

pointer qp			# i: qp file descriptor
pointer qphead			# i: qp header struct
#--
pointer	mw, qp_loadwcs()
errchk	qp_loadwcs()

begin
	# In this version, we lose the physical wcs that was in the file,
	# replacing it with the new logical wcs

	mw = qp_loadwcs(qp)

	call qph2mw(qphead, mw)
	call qp_savewcs(qp, mw, 2)
end
