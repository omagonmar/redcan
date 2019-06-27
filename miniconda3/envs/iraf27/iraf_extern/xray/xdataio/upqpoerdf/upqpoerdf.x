#$Header: /home/pros/xray/xdataio/upqpoerdf/RCS/upqpoerdf.x,v 11.0 1997/11/06 16:34:21 prosb Exp $
#$Log: upqpoerdf.x,v $
#Revision 11.0  1997/11/06 16:34:21  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:19:52  prosb
#General Release 2.3.1
#
#Revision 7.1  94/03/23  15:57:18  mo
#MC	3/22/94		Move RDF specific routine from QPCREATE lib to
#			here so that all RDF specific code lives in
#			one place and can later be NUKED
#
#Revision 7.0  93/12/27  18:39:22  prosb
#General Release 2.3
#
#Revision 6.1  93/12/16  09:58:30  mo
#New routine ( incorporates upqpoe210)
#
#
# Module:       upqpoerdf
# Project:      PROS -- ROSAT RSDC
# Purpose:      To add new keywords and macros to existing QPOE files
# Calls:
# Description:   
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M. Conroy  initial version 11/04/93
#               {n} <who> -- <does what> -- <when>
#
#------------------------------------------------------------------
include <error.h>
include <qpset.h>
include <ext.h>
include <qpc.h>
include <qpoe.h>
include <rosat.h>
include <einstein.h>
#include <bary.h>
define	SZ_BUF	1024
define	UP_FATAL 1

procedure  t_upqpoerdf ()

#bool	streq()				# string equals function
#bool	ck_none()			# check none function
int     qp_access()			# access file function
bool	notime				# bool to flag no 'time' in QPOE file
int	display				# display level
int	clgeti()			# get int from cl
int     qp_accessf()            	# access qp field
pointer qp_open()               	# qp open function
pointer qp_root                 	# qp root name
pointer evlist                  	# event list buffer
pointer qp                      	# qp file handle
pointer qphead                  	# qp header pointer
pointer sp				# Stack pointer
pointer qp_fname			# QPOE file name 
pointer listname
pointer keystr				# QPOE header string keyword
pointer	buf				# history buffer
int     list
int     imtopen(), imtgetim()
pointer empty_ptr
bool	strne()

begin
        call smark(sp)
	call salloc(qp_fname, SZ_PATHNAME, TY_CHAR)
        call salloc(listname, SZ_PATHNAME, TY_CHAR)
        call salloc(keystr, SZ_LINE, TY_CHAR)
        call salloc(buf, SZ_LINE, TY_CHAR)

        call salloc(qp_root, SZ_PATHNAME, TY_CHAR)
        call salloc(evlist,  SZ_LINE, TY_CHAR)
        call salloc(empty_ptr, SZ_LINE, TY_CHAR)
        Memc[empty_ptr] = EOS
	
#-----------------------------------------
# Get filenames from the cl and open files
#-----------------------------------------
	call clgstr("listname", Memc[listname], SZ_PATHNAME)

#-------------------------
# Get hidden cl parameters
#-------------------------
	display = clgeti("display")
	
#	call rootname(Memc[qp_fname], Memc[qp_fname], EXT_QPOE, SZ_PATHNAME)
#        if (ck_none(Memc[qp_fname]) || streq("", Memc[qp_fname])) 
#           call error(EA_FATAL, "requires *.qp file as input")

        list = imtopen (Memc[listname])
	while (imtgetim (list, Memc[qp_fname], SZ_FNAME) != EOF)
        {

	call strcpy("", Memc[evlist], SZ_LINE)
#---------------------------
# Parse the filter specifier
#---------------------------
        call qp_parse(Memc[qp_fname], Memc[qp_root], SZ_PATHNAME,
                      Memc[evlist], SZ_EXPR)

	if (strne(Memc[evlist], ""))
	   call error(1, "QPOE file has a filter. No filters allowed.")

#------------------------------
# Open the input file as a QPOE
#------------------------------
	if( qp_access(Memc[qp_root],READ_WRITE) != YES)
	  call errstr(UP_FATAL,"Unable to open file for writing",Memc[qp_root])
        qp = qp_open(Memc[qp_root], READ_WRITE, NULL)

#-----------------------
# Update the QPOE header - only if QPOE contains time
#-----------------------
#        call get_oqphead(qp, qphead)
        call get_qphead(qp, qphead)

	if( qp_accessf(qp,"time") == NO && qp_accessf(qp,"TIME") == NO){
	    call strcpy("XS-FHIST",Memc[keystr], SZ_LINE)
	    notime = TRUE
	}
	else{
	    call strcpy("deffilt",Memc[keystr], SZ_LINE)
	    notime = FALSE
	}
        
	call updeffilt(qp, qp, empty_ptr, Memc[keystr], qphead)
#---------------------------
#  Update header keywords if this was a BARYCENTER corrected QPOE File
#---------------------------
#        if( qp_accessf(qp, QP_BARCOR_PARAM) == YES )
#           call qp_upbary(qp,qphead)

	call put_qphead(qp, qphead)
#---------------------------
#  Update the event-list attribute names
#---------------------------
	call upevrdf(qp,qphead)
	
#---------------------------
# Add the keyword "defattr1" - only if QPOE contains time 
#---------------------------
        if (qp_accessf(qp, "defattr1") == NO && !notime)
	{
           call qp_addf(qp, "defattr1", "c", SZ_LINE,
                        "exposure time (seconds)",QPF_NONE)

           call qp_pstr(qp, "defattr1", "EXPTIME = integral time:d")
	}

#---------------------------
#  Format the history record
#---------------------------
        call sprintf(Memc[buf], SZ_LINE, "%s RDF corrected")
            call pargstr(Memc[qp_fname])
        if (display > 1)
        {
            call printf("%s\n")
            call pargstr(Memc[buf])
        }
#-------------------------
# write the history record
#-------------------------
        call put_qphistory(qp, "upqpoerdf", Memc[buf], "")

	call qp_close(qp)
	
	if (display >= 1)
	{
	  call printf("Writing file %s.\n")
	  call pargstr(Memc[qp_fname])
	  call flush(STDOUT)
	}

	} # end while loop
        call imtclose (list)

	call sfree(sp)

end        # procedure upqpoerdf()

#
#  UPEVRDF - update the EVENT definition string for RDF data
#               ROSAT specific - PSPC/HRI change in names
procedure upevrdf(qp,qphead)
pointer qp                      # i: pointer to QPOE file (r/w)
pointer qphead                  # i: pointer to QPOE header strucuture
 
pointer sp                      # l
pointer prosdef                 # l:
pointer msymbols                # l:
pointer mvalues                 # l:
int     nmacros                 # l
int     found                   # l
int     ev_editlist()
 
begin
        call smark(sp)
        call salloc(prosdef,SZ_BUF,TY_CHAR)
        call ev_qpget(qp, Memc[prosdef], SZ_BUF)
        call ev_crelist(Memc[prosdef],msymbols,mvalues,nmacros)
        if( QP_INST(qphead) == ROSAT_PSPC || QP_INST(qphead) == EINSTEIN_IPC)
        {
            found = ev_editlist("dx", "detx", Memc[prosdef], msymbols, mvalues,
nmacros)
            found = ev_editlist("dy", "dety", Memc[prosdef], msymbols, mvalues,
nmacros)
        }
        else if(QP_INST(qphead) == ROSAT_HRI )
        {
            found = ev_editlist("dx", "rawx", Memc[prosdef], msymbols, mvalues,
nmacros)
            found = ev_editlist("dy", "rawy", Memc[prosdef], msymbols, mvalues,
nmacros)
        }
        call ev_wrlist(qp,msymbols,mvalues,nmacros)
#       call ev_credef(msymbols,mvalues,nmacros,Memc[prosdef])
        call ev_qpput(qp,Memc[prosdef])
        call ev_destroylist(msymbols, mvalues, nmacros)
        call sfree(sp)
end

