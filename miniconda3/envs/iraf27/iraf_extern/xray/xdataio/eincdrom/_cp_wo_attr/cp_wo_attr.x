#$Log: cp_wo_attr.x,v $
#Revision 11.0  1997/11/06 16:36:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:09  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:13  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:44:53  prosb
#General Release 2.3
#
#Revision 6.1  93/06/24  12:49:35  mo
#MC	6/24/93		Fixed clgetb to be BOOL
#			changed if(access) to if(access !=YES) or if(access==YES) for interger type
#
#Revision 6.0  93/05/24  17:11:36  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:35:29  prosb
#Initial revision
#
#Revision 1.1  93/04/12  15:41:44  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_cp_wo_attr/RCS/cp_wo_attr.x,v 11.0 1997/11/06 16:36:43 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       cp_wo_attr.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	t_cp_wo_attr
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <iraf.h>
include "../source/ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:	t_cp_wo_attr
#
# Purpose:      To copy files without copying attributes
#
# Input parameters: 
#               ifile  		input file
#               ofile  		output file
#
# Output parameters:
#               (none)
#
# Description:  This task will copy file "ifile" to "ofile", but without
#               copying the file attributes of "ifile".  (This allows the
#		user to copy read-only files, for instance.)  
#
# Algorithm:    * allocate stack space
#		* get parameters
#		* strip whitespace off input and output names
#		* check that we can read input file
#		* determine type of input file: BINARY or TEXT
#               * call clobbername to find actual output filename
#		* open input and output files
#               * copy contents of files
#               * close input and output files
# 		* call finalname to create output file 
#               * free memory stack
#
# Notes:     	This code mimics the /iraf/iraf/iraf/sys/fio/fcopy.x code.
#		I wasn't certain if NEW_FILE was the appropriate mode to
#		use to open the output file.  In the "fcopy.x" code, the
# 		output file is created first with fmkcopy, then opened with
# 		APPEND mode.  
#--------------------------------------------------------------------------

procedure t_cp_wo_attr()

### PARAMETERS ###

pointer ifile       # input file
pointer ofile       # output file
bool    clobber     # can we overwrite output file?

### LOCAL VARS ###

int     ifd         # input file descriptor
int     ofd         # output file descriptor
pointer sp          # stack pointer
pointer t_ofile     # temporary file name used for the output file.
int     type        # are these files BINARY or TEXT?

### EXTERNAL FUNCTION DECLARATIONS ###

int     access()    # returns accessibility/type of file [sys/fio]
bool     clgetb()    # returns boolean parameter [sys/clio]
int     open()      # returns file descriptor of opened file [sys/fio]

### BEGINNING OF PROCEDURE ###

begin
	# allocate stack space
	 call smark(sp)
	 call salloc( ifile, SZ_FNAME, TY_CHAR)
	 call salloc( ofile, SZ_FNAME, TY_CHAR)
	 call salloc( t_ofile, SZ_FNAME, TY_CHAR)
	 
	# get parameters
	 call clgstr("ifile",Memc[ifile], SZ_FNAME)
	 call clgstr("ofile",Memc[ofile], SZ_FNAME)
	 clobber=clgetb("clobber")

	# strip whitespace off input and output names
	 call strip_whitespace(Memc[ifile])
	 call strip_whitespace(Memc[ofile])

	# check that we can read input file
	 if (access(Memc[ifile],READ_ONLY,0)!=YES)
	 {
	   call errstr(ECD_CANTREADFILE,
	     "Can not read file",Memc[ifile])
	 }

	# determine type of input file: BINARY or TEXT
	 if (access(Memc[ifile],0,TEXT_FILE)==YES)
	 {
	   type=TEXT_FILE
	 }
	 else
	 {
	   type=BINARY_FILE
	 }
	
	# call clobbername to find actual output filename
	 call clobbername(Memc[ofile],Memc[t_ofile],clobber,SZ_FNAME)

	# open input and output files
	 ifd=open(Memc[ifile],READ_ONLY,type)
	 ofd=open(Memc[t_ofile],NEW_FILE,type)

	# copy contents of files
	 call fcopyo(ifd,ofd)

	# close input and output files
	 call close(ifd)
	 call close(ofd)

	# call finalname to create output file
	 call finalname(Memc[t_ofile],Memc[ofile])

	# Free memory stack
	 call sfree (sp)   
end
