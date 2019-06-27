#$Header: /home/pros/xray/xdataio/upimgrdf/RCS/upimgrdf.x,v 11.0 1997/11/06 16:34:19 prosb Exp $
#$Log: upimgrdf.x,v $
#Revision 11.0  1997/11/06 16:34:19  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:58:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:19:47  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:39:17  prosb
#General Release 2.3
#
#Revision 1.1  93/12/16  09:59:53  mo
#Initial revision
#
#
# Module:       upimgrdf
# Project:      PROS -- ROSAT RSDC
# Purpose:      To add new keywords and macros to existing QPOE files
# Calls:
# Description:   
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} M. Conroy  initial version 11/04/93
#               {n} <who> -- <does what> -- <when>
#
#------------------------------------------------------------------
include <error.h>
include <ext.h>
include <qpoe.h>
include <rosat.h>
include <einstein.h>
define	SZ_BUF	1024
define	UP_FATAL 1

procedure  t_upimgrdf ()

#bool	streq()				# string equals function
#bool	ck_none()			# check none function
int     im_access()			# access file function
int	display				# display level
int	clgeti()			# get int from cl
pointer	immap()
pointer im                      	# qp file handle

pointer imhead                  	# qp header pointer
pointer sp				# Stack pointer
pointer fname			# QPOE file name 
pointer listname
#pointer keystr				# QPOE header string keyword
pointer	buf				# history buffer
int     list
int     imtopen(), imtgetim()
#pointer empty_ptr
#bool	strne()

begin
        call smark(sp)
	call salloc(fname, SZ_PATHNAME, TY_CHAR)
        call salloc(listname, SZ_PATHNAME, TY_CHAR)
#        call salloc(keystr, SZ_LINE, TY_CHAR)
        call salloc(buf, SZ_LINE, TY_CHAR)

#        call salloc(empty_ptr, SZ_LINE, TY_CHAR)
#        Memc[empty_ptr] = EOS
	
#-----------------------------------------
# Get filenames from the cl and open files
#-----------------------------------------
	call clgstr("listname", Memc[listname], SZ_PATHNAME)

#-------------------------
# Get hidden cl parameters
#-------------------------
	display = clgeti("display")
	

        list = imtopen (Memc[listname])
	while (imtgetim (list, Memc[fname], SZ_FNAME) != EOF)
        {

#------------------------------
# Open the input file as a IMAGE
#------------------------------
	if( im_access(Memc[fname],READ_WRITE) != YES)
	  call errstr(UP_FATAL,"Unable to open file for writing",Memc[fname])
        im = immap(Memc[fname], READ_WRITE, NULL)

#-----------------------
# Update the QPOE header - only if QPOE contains time
#-----------------------
#        call get_oimhead(im, imhead)
        call get_imhead(im, imhead)

	call put_imhead(im, imhead)

#---------------------------
#  Format the history record
#---------------------------
        call sprintf(Memc[buf], SZ_LINE, "%s RDF corrected")
            call pargstr(Memc[fname])
        if (display > 1)
        {
            call printf("%s\n")
            call pargstr(Memc[buf])
        }
#-------------------------
# write the history record
#-------------------------
        call put_imhistory(im, "upimgrdf", Memc[buf], "")

	call im_unmap(im)
	
	if (display >= 1)
	{
	  call printf("Writing file %s.\n")
	  call pargstr(Memc[fname])
	  call flush(STDOUT)
	}

	} # end while loop
        call imtclose (list)

	call sfree(sp)

end        # procedure upimgrdf()

