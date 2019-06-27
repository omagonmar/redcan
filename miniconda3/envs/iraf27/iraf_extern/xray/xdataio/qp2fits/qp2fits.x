# $Header: /home/pros/xray/xdataio/qp2fits/RCS/qp2fits.x,v 11.0 1997/11/06 16:35:54 prosb Exp $
# Revision 9.1  1997/07/16 16:04:50  prosb
# JCC(7/16/97) - keep the output "diff.out" if display > 1.
#
# Revision 9.0  1995/11/16 19:00:08  prosb
# General Release 2.4
#
#Revision 8.1  1994/06/30  16:57:19  mo
#MC	6/30/94		Add paramter for WCD format
#
#Revision 8.0  94/06/27  15:22:17  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/14  09:47:33  mo
#MC	4/14/94		Add the ASCA 'HOT_PIXELS' extension name
#
#Revision 7.0  93/12/27  18:44:31  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:56:10  mo
#MC	12/1/93		Update for generic QPOE extension reader (and add
#			new Einstein BLT_WCS extension name)
#
#Revision 6.0  93/05/24  16:26:41  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:33:24  prosb
#General Release 2.1
#
#Revision 4.1  92/10/16  20:20:54  mo
#MC	10/16/92		Added updates for DEFFILT from GTI
#
#Revision 4.0  92/04/27  15:02:19  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/01  16:31:22  prosb
#*** empty log message ***
#
#Revision 1.1  92/02/06  18:02:10  mo
#Initial revision
#
#Revision 1.1  92/02/06  18:00:24  mo
#Initial revision
#
#Revision 1.1  92/02/06  17:58:49  mo
#Initial revision
#
#Revision 1.1  92/02/06  17:56:37  mo
#Initial revision
#
#
# Module:       qp2fits
# Project:      PROS -- ROSAT RSDC
# Purpose:      To convert a QPOE file to a FITS file 
# Calls:
#               make_lookup
#               get_head_info
#               get_qphead
#               a3d_main_header
#               put_difference
#               a3d_main_end
#               gti_out
#               tsi_out
#               blt_out
#               tgr_out
#               events_out
# Description:  This task takes a QPOE file as input and translates
#   it into a FITS file.  Currently it will recognize the following
#   QPOE data:          GTI
#                       TSI
#                       BLT
#                       BLT_WCS
#                       TGR
#			ALLGTI
#			STDGTI
#			STDQLM
#			ALLQLM
#                       events
#
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} John Moran  initial version 01/23/92
#               {n} <who> -- <does what> -- <when>
#
#------------------------------------------------------------------
include <error.h>
include <ext.h>
include <qpc.h>
include <qpoe.h>
include "qp2fits.h"


procedure  t_qp2fits ()

bool	clobber				# clobber old file
bool	clgetb()			# get bool from cl
bool	newwcs				# new-style WCS?
bool	streq()				# string equals function
bool	ck_none()			# check none function
int     open()                          # file open
int     access()			# access file function
int	display				# display level
int	clgeti()			# get int from cl
int     qp_accessf()            	# access qp field
int     sz_lookup                       # lookup table size
pointer qp_open()               	# qp open function
pointer qpio_open()             	# qp i/o open function
pointer qp_root                 	# qp root name
pointer evlist                  	# event list buffer
pointer qp                      	# qp file handle
pointer io                      	# qpio handle
pointer qphead                  	# qp header pointer
pointer sp				# Stack pointer
pointer qp_fname			# QPOE file name 
pointer fits_fname			# FITS file name
pointer tempname			# temp name of output file
pointer diff_fp				# outfile handle
pointer	fits_fp				# output FITS handle
pointer table				# lookup table

bool     isAXAF        #true for QP_MISSTR=AXAF
int      strncmp()
pointer  qp_tmp, qphead_tmp, immap()
#bool    isHRI         #tru for QP_INSTSTR/INSTRUME="HRI"

begin
        call smark(sp)
	call salloc(qp_fname, SZ_PATHNAME, TY_CHAR)
	call salloc(fits_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (tempname, SZ_PATHNAME, TY_CHAR)
        call salloc(qp_root, SZ_FNAME, TY_CHAR)
        call salloc(evlist,  SZ_EXPR, TY_CHAR)

#-----------------------------------------------------------------------
# Allocate space for the lookup table.  One (1) must be added to KEY_MAX
# to account for the extra space for the EOS character that the 
# called procedures will allocate for the table when it is received  
# as a 2-dimensional char array.
#-----------------------------------------------------------------------
	sz_lookup = (KEY_MAX + 1) * MAX_LOOKUP
	call calloc(table, sz_lookup, TY_CHAR)

#-------------------------
# Get hidden cl parameters
#-------------------------
	newwcs = clgetb("wcscd")
	clobber = clgetb("clobber")
	display = clgeti("display")
	
#-----------------------------------------
# Get filenames from the cl and open files
#-----------------------------------------
	call clgstr("qpfile", Memc[qp_fname], SZ_PATHNAME)
	call rootname(Memc[qp_fname], Memc[qp_fname], EXT_QPOE, SZ_PATHNAME)
        if (ck_none(Memc[qp_fname])) 
           call error(EA_FATAL, "requires *.qp file as input")

        if (streq("", Memc[qp_fname])) 
           call error(EA_FATAL, "requires *.qp file as input")

	call clgstr("fitsfile", Memc[fits_fname], SZ_PATHNAME)
	call rootname(Memc[qp_fname], Memc[fits_fname], ".fits", 
		      SZ_PATHNAME)

	call clobbername(Memc[fits_fname],Memc[tempname],clobber,
		         SZ_PATHNAME)
        fits_fp = open(Memc[tempname], NEW_FILE, BINARY_FILE)

##############
#JCC(9/18/97) - get the flag isAXAF
        qp_tmp = immap( Memc[qp_fname], READ_ONLY, 0 )
        call get_imhead (qp_tmp, qphead_tmp)
        call printf("QP_MISSTR= %sJCC\n") 
        call pargstr(QP_MISSTR(qphead_tmp))
        if (strncmp(QP_MISSTR(qphead_tmp),"AXAF",4) ==0)
           isAXAF = true
        else   
           isAXAF = false
        call imunmap( qp_tmp )
##############

#-------------------------------------
# Make the known keywords lookup table
#-------------------------------------
        call make_lookup(Memc[table], isAXAF)  # JCC- add isAXAF

#----------------------------------------------------------------
# Call the get header information routine which does the following:
#
# 	1) Gets all QPOE header data by accessing qp file as an 
#	   image file 
# 	2) Builds a temporary file with all the qp keywords that 
#	   aren't in the lookup table
#----------------------------------------------------------------
        diff_fp = open(DIFF_FNAME, WRITE_ONLY, TEXT_FILE)
        call get_head_info(Memc[qp_fname], diff_fp, Memc[table]) 
	call close(diff_fp)
	
#------------------------------------------------------------------------
# Parse the filter specifier into evlist and the qp rootname into qp_root
#------------------------------------------------------------------------
        call qp_parse(Memc[qp_fname], Memc[qp_root], SZ_PATHNAME,
                      Memc[evlist], SZ_EXPR)

#--------------------------------------------------------------
# Open the input file as a QPOE and re-open the difference file
#--------------------------------------------------------------
        qp = qp_open(Memc[qp_root], READ_ONLY, NULL)
        diff_fp  = open(DIFF_FNAME, READ_ONLY, TEXT_FILE)

#--------------------
# Open the event list
#--------------------
        io = qpio_open(qp, Memc[evlist], READ_ONLY)

#--------------------
# Get the qpoe header
#--------------------
        call get_qphead(qp, qphead)
	if( newwcs || (QP_ISCD(qphead) == YES))
	    QP_ISCD(qphead) = YES
	else
	    QP_ISCD(qphead) = NO

####delete (9/18/97)
        #JCC (8/18/97)  - begin
        #call printf("..QP_INSTSTR(qphead)/INSTRUME==%s\n")
        #call pargstr(QP_INSTSTR(qphead))
        #if (strncmp(QP_INSTSTR(qphead),"HRI",3) ==0)
              #isHRI = true
        #else
              #isHRI = false
        #JCC (8/18/97)  - end

#-----------------------------
# Write out the initial header
#-----------------------------
        call a3d_main_header(fits_fp, "EVENTS")
        #call put_difference(qp, Memc[qp_root], diff_fp, fits_fp, isHRI)
        call put_difference(qp, Memc[qp_root], diff_fp, fits_fp, isAXAF)
        call a3d_main_end(fits_fp)

#---------------------------------------------------------
# Write out the good time interval (GTI) header and data
#---------------------------------------------------------
        if (qp_accessf(qp, "deffilt") == YES)
           call gti_out(qp, fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (TSI) header and data
#-------------------------------------------------------------
        if (qp_accessf(qp, "TSI") == YES)
           call ext_out(qp, "TSI", fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (GTI) header and data
#-------------------------------------------------------------
#        if (qp_accessf(qp, "GTI") == YES)
#           call ext_out(qp, "GTI", fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (TSI) header and data
#-------------------------------------------------------------
        if (qp_accessf(qp, "ALLGTI") == YES)
           call ext_out(qp, "ALLGTI", fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (TSI) header and data
#-------------------------------------------------------------
        if (qp_accessf(qp, "STDGTI") == YES)
           call ext_out(qp, "STDGTI", fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (TSI) header and data
#-------------------------------------------------------------
        if (qp_accessf(qp, "STDQLM") == YES)
           call ext_out(qp, "STDQLM", fits_fp, qphead, display)

#-------------------------------------------------------------
# Write out the temporal status interval (TSI) header and data
#-------------------------------------------------------------
        if (qp_accessf(qp, "ALLQLM") == YES)
           call ext_out(qp, "ALLQLM", fits_fp, qphead, display)

#------------------------------
# Write out BLT header and data
#------------------------------
        if (qp_accessf(qp, "BLT") == YES)
           call ext_out(qp, "BLT", fits_fp, qphead, display)

#------------------------------
# Write out BLT_WCS header and data
#------------------------------
        if (qp_accessf(qp, "BLT_WCS") == YES)
           call ext_out(qp, "BLT_WCS", fits_fp, qphead, display)

#------------------------------
# Write out TGR header and data
#------------------------------
        if (qp_accessf(qp, "TGR") == YES)
           call ext_out(qp, "TGR", fits_fp, qphead, display)

#------------------------------
# Write out HOT_PIX header and data
#------------------------------
        if (qp_accessf(qp, "HOT_PIXELS") == YES)
           call ext_out(qp, "HOT_PIXELS", fits_fp, qphead, display)

#------------------------------------------
# Write out the event header and the events
#------------------------------------------
        call events_out(qp, io, fits_fp, qphead, display)

#---------
# Close up
#---------
	call close(diff_fp)
        call qpio_close(io)
	call qp_close(qp)
	
	if (display >= 1)
	{
	  call printf("Writing file %s.\n")
	  call pargstr(Memc[fits_fname])
	  call flush(STDOUT)
	}

	call finalname(Memc[tempname], Memc[fits_fname])

 	call close(fits_fp)

#JCC - don't delete "diff.out" if (display > 1)
	if ((access(DIFF_FNAME, 0, 0)== YES)&&(display<=1))
	   call delete(DIFF_FNAME)

	call mfree(table, TY_CHAR)
	call sfree(sp)

end        # procedure qp2fits ()
