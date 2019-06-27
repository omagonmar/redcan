#$Log: index.x,v $
#Revision 11.0  1997/11/06 16:36:47  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:20  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:33  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  13:56:49  prosb
#Modified header constants (EIN_SLEW->SLEW, etc.)    
#
#Revision 7.0  93/12/27  18:45:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:12:13  prosb
#General Release 2.2
#
#Revision 1.3  93/05/03  11:44:10  prosb
#Fixed minor typo.  ("suquence"--->"sequence")
#
#Revision 1.2  93/04/18  16:20:06  prosb
#Added routine fg_skiplines which skips over introductory lines in index
#file.
#Added eoscat and hriimg datasets.
#
#Revision 1.1  93/04/13  09:38:13  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:33:07  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fitsnm_get/RCS/index.x,v 11.0 1997/11/06 16:36:47 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       index.x
# Project:      PROS -- EINSTEIN CDROM
# Purpose:	Routines to deal with the sequence number index files.
# External:	(none)
# Local:	fg_indexfile_get, fg_skiplines, fg_rdindexline 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <iraf.h>
include "../source/dataset.h"
include "../source/ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:	fg_indexfile_get
# Project:      PROS -- EINSTEIN CDROM
# Purpose:      To return the sequence number index file associated
#		with the passed in dataset index
#
# Input variables:
#               i_dataset    	index of dataset
#
# Output variables:
#               indexfile  	pathname of sequence number index file
#
# Algorithm:    * open PSET
#		* find index file for specified dataset index
#		* close PSET
#--------------------------------------------------------------------------

include <iraf.h>
include "../source/dataset.h"
include "../source/ecd_err.h"

procedure fg_indexfile_get(i_dataset,indexfile)
int 	i_dataset  	# dataset index
char 	indexfile[ARB]  # file name index pathname

### LOCAL VARS ###

pointer pp		# pset pointer

### EXTERNAL FUNCTION DECLARATIONS ###

pointer clopset()     	# returns pset pointer [sys/clio]
  
### BEGINNING OF PROCEDURE ###

begin
	# open PSET 
	 pp = clopset("eincdpar")

	# find index file for specified dataset index
	 switch (i_dataset) 
	 {
	   case IPC_EVT:
	     call clgpseta(pp,"ipcevtindex",indexfile,SZ_PATHNAME)

   	   case HRI_EVT:
	     call clgpseta(pp,"hrievtindex",indexfile,SZ_PATHNAME)

   	   case EOSCAT:
	     call clgpseta(pp,"eoscatindex",indexfile,SZ_PATHNAME)

   	   case HRI_IMG:
	     call clgpseta(pp,"hriimgindex",indexfile,SZ_PATHNAME)

    	   default:
             call error(ECD_BADDATASET,
		"This dataset does not have a sequence number index file.")
   	 }

	# close PSET
	 call clcpset(pp)
end

#--------------------------------------------------------------------------
# Procedure:	fg_skiplines
# Project:      PROS -- EINSTEIN CDROM
# Purpose:      To skip over the introductory lines in an index file.
#
# Input variables:
#               i_dataset    	index of dataset
#		fd		file descript for index file
#		buff		pointer to buffer space (SZ_LINE)
#
# Return value:	returns the status of the index file
#
# Algorithm:    * set numlines
#		* skip over "numlines" lines
#		* return status of index file
#--------------------------------------------------------------------------

int procedure fg_skiplines(i_dataset,fd,buff)
int 	i_dataset  	# dataset index
int 	fd        	# file descriptor for index file
char	buff[ARB]      	# buffer space

### LOCAL VARS ###

int 	i_lines		# index of lines skipped
int 	stat		# file status
int 	numlines	# number of lines to skip

### EXTERNAL FUNCTION DECLARATIONS ###

int 	getline()	# returns file status [sys/fio]

### BEGINNING OF PROCEDURE ###

begin
	# set numlines
	 switch (i_dataset) 
	 {
     	    case IPC_EVT,HRI_EVT,HRI_IMG:
       	         numlines=0
     	    case EOSCAT:
       	         numlines=EOSCAT_LINES_TO_SKIP
     	    default:
                 call errori(ECD_BADDATASET,
                   "SKIPLINES: Do not recognize dataset index",i_dataset)
   	 }

	# skip over "numlines" lines
   	 for (i_lines=1; i_lines<= numlines; i_lines=i_lines+1)
   	 {
     	      stat=getline(fd,buff)
   	 }
	
	# return status of index file
	 return stat
end

#--------------------------------------------------------------------------
# Procedure:	fg_rdindexline
#
# Purpose:      To read in a line from an index file and parse the sequence
#		number and FITS file name from the line.
#
# Input variables:
#               i_dataset    	index of dataset
#		fd	     	file descriptor for field index
#		buff        	buffer space 
#				  (assumed to be at least SZ_LINE in size)
#
# Output variables:
#		seq         	sequence number (read from index file line)
#               fitsname    	FITS name (read from index file line)
#
# Return value:	returns the status of the index file
#
# Algorithm:    * read in line from index file and parse the line
#		* return status of index file
#
# Note:		This routine performs some format checking for more
#		complicated index files (such as the IPC index file).
#		This routine gives an error if the format is unexpected.
#
#--------------------------------------------------------------------------

int procedure fg_rdindexline(i_dataset,fd,seq,fitsname,buff,display)
int     i_dataset      	# index of dataset
int 	fd            	# file descriptor for index file
int     seq	      	# sequence number (from line)
char    fitsname[ARB] 	# name of FITS file (from line)
char    buff[ARB]     	# buffer string - temporary use only
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

char	firstchar     	# Stores first character for IPC
int     stat          	# file status

### EXTERNAL FUNCTION DECLARATIONS ###

int     fscan()       	# returns file status [sys/fmtio]
bool    streq()       	# returns true if strings are equal [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin

	# Read in line from index file and parse the line
	 switch (i_dataset) {

	  case IPC_EVT:

	   # each line of the ipc event file index is of the form:
	   # I##### ##h/fits-name
	   #    (example:   "I00610 01h/i0112s71.xpa")
	   stat= fscan(fd)
	    call gargc(firstchar)   # Reads in first character "I"
	    call gargi(seq)
	    call gargstr(buff,5)    # Reads in 5 characters: " ##h/"
	    call gargwrd(fitsname,SZ_FNAME)
	   
	   if ( (stat!=EOF) && ((firstchar != 'I') || (buff[5]!='/') ) )
	   {
		if (display>4)
		{
		    call printf("   error in reading IPC index file.\n")
		    call printf("   buff2=%c, seq=%d, buff=%s.\n")
		    call pargc(firstchar)
		    call pargi(seq)
		    call pargstr(buff)
		    call flush(STDOUT)
		}

		call error(ECD_BADFNINDEXFMT,"Index file in unexpected format.")
	   }
 
	  case HRI_EVT,HRI_IMG:
	   # each line of the hri event file index is in one of the two forms:
	   #        seq ### fits-file OTHERTEXT
	   #                   OR
	   #        seqOGS ### fits-file OTHERTEXT
	   # where seqOGS is the sequence number followed immediately by the
	   #  three characters "OGS".)
	    stat= fscan(fd)
	     call gargi(seq)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(fitsname,SZ_FNAME)

	   # In the case where "OGS" follows the filename, the buffer will now
	   # contain "OGS".  In this case, read next token for actual
	   # fits filename. 
	    if (streq(buff,"OGS"))
	      call gargwrd(fitsname,SZ_FNAME)
   
	  case EOSCAT:
	   # each line of the EOSCAT index file is of the form:
	   # ## ## ## ## ## ## seq ## fits-file
	    stat= fscan(fd)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(buff,SZ_LINE)
	     call gargi(seq)
	     call gargwrd(buff,SZ_LINE)
	     call gargwrd(fitsname,SZ_FNAME)
	

	  default:
	      call errori(ECD_BADDATASET,
		"RDINDEXLINE: Do not recognize dataset index",i_dataset)
	 }

	# return status of index file
	 return stat
end
