#$Log: seq2fitsnm.x,v $
#Revision 11.0  1997/11/06 16:36:49  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:23  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:24:38  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  13:56:59  prosb
#Modified header constants (EIN_SLEW->SLEW, etc.)    
#
#Revision 7.0  93/12/27  18:45:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:12:18  prosb
#General Release 2.2
#
#Revision 1.2  93/04/18  16:20:48  prosb
#Calls new routine fg_skiplines before reading in index lines.
#Skips "*.R*" Fits files on EOSCAT, because, for now, we want
# to only allow access to *.X*" fits files.
#
#Revision 1.1  93/04/13  09:38:27  prosb
#Initial revision
#
#Revision 1.1  93/04/13  09:33:09  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_fitsnm_get/RCS/seq2fitsnm.x,v 11.0 1997/11/06 16:36:49 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       seq2fitsnm.x
# Project:      PROS -- EINSTEIN CDROM
# External:	(none)
# Local:	seq2fitsnm
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
# Procedure:	seq2fitsnm
#
# Purpose:      To convert a sequence number into a FITS name.
#
# Input variables:
#		seq         	sequence number
#               dataset     	which Einstein dataset (ipc, hri, etc.)    
#
# Output variables:
#               fitsnm    	the return fits name
#
# Description:  This routine returns a FITS file corresponding to the
#		passed in sequence number by looking up the name in
#		the appropriate sequence number index file for the dataset.
#
# Algorithm:    * allocate stack space
#		* convert dataset string to dataset index
#		* get sequence number index file for this dataset
#		* check that we can read the sequence number index file
#		* open index file
# 		* skip over introductory lines in index file
#		* for each remaining line in the index file:
#		  * read in a sequence number (index_seq) and corresponding
#		    fits file name (fitsnm) from this line 
#		  * if index_seq==seq or we're at end of file, stop the loop  
#		* close index file
#               * free memory stack
#		* give error if sequence was not found
#		* check that fitsnm is not empty string
#--------------------------------------------------------------------------

procedure fg_seq2fitsnm(seq,dataset,fitsnm,display)
int     seq	      	# sequence number
char    dataset[ARB]  	# which Einstein dataset (ipc, hri, etc.)
char	fitsnm[ARB] 	# name of FITS file
int	display		# text display level (0=none, 5=full)

### LOCAL VARS ###

pointer buff          	# buffer string - temporary use only
int 	fd            	# file descriptor for index file
int     i_dataset     	# index of dataset
int     index_seq     	# sequence read from the index file
pointer p_indexfile  	# pointer to the pathname for the index file
bool    seqfound      	# true if sequence number was found in the index file
pointer sp	      	# stack pointer
int     stat          	# status of index file

### EXTERNAL FUNCTION DECLARATIONS ###

bool	access()	# returns true if file is accessible [sys/fio]
int     fg_rdindexline()# returns status of index file after reading line
int     dataset2index() # returns dataset index
int     open()		# returns file descriptor for opened file [sys/fio]
bool	streq()		# returns true if strings are equal [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
	# allocate stack space
	 call smark(sp)
	 call salloc( buff, SZ_LINE, TY_CHAR)
	 call salloc( p_indexfile, SZ_PATHNAME, TY_CHAR)

	# convert dataset string to dataset index
	 i_dataset = dataset2index(dataset)

	# get sequence number index file for this dataset
	 call fg_indexfile_get(i_dataset,Memc[p_indexfile])

	 if (display>3)
	 {
	    call printf(" Searching for sequence %d in index file %s.\n")
	     call pargi(seq)
	     call pargstr(Memc[p_indexfile])
	    call flush(STDOUT)
	 }

	# check that we can read the sequence number index file
	 if (!access(Memc[p_indexfile],READ_ONLY,TEXT_FILE))
	 {
	    call errstr(ECD_CANTREADFILE,
		"Can not read fits name index file",Memc[p_indexfile])
	 }

	# open index file 
	 fd=open(Memc[p_indexfile],READ_ONLY,TEXT_FILE)

	# skip over introductory lines in index file
	 call fg_skiplines(i_dataset,fd,Memc[buff])

	# initialize "seqfound" to false
	 seqfound=false

	# loop on lines in index file
	 repeat
	 {
	   # read in a sequence number and corresponding fits filename from
	   # index file
	    stat = fg_rdindexline(i_dataset,fd,index_seq,fitsnm,Memc[buff],display)

	    if ((display>4) && (stat!=EOF) )
	    {
		call printf("  Read in fits name %s and sequence %d from index file.\n")
		 call pargstr(fitsnm)
		 call pargi(index_seq)
	    }

	    if ((stat!=EOF) && (index_seq==seq))
	    {
	        # SPECIAL CASE:
		# On EOSCAT, we don't want the .RE* fits files.
		 if ((i_dataset==EOSCAT) && (fitsnm[10]=='R'))
		 {
		     if (display>4)
		     {
			call printf("  Skipping %s.\n")
			 call pargstr(fitsnm)
		     }
		 }
		 else
		 {
		     seqfound=true
		 }
	    }

	 } # repeat reading in lines from index file
	 until ( (stat == EOF) || seqfound )

	 if (display>3)
	 {
	    if (seqfound)
	    {
	    	call printf(" Found fits name %s in index file.\n")
		 call pargstr(fitsnm)
	    }
	    else
	    {
		call printf(" Could not find sequence in index file.\n")
	    }
	    call flush(STDOUT)
	 }

	# close index file
	 call close(fd)

	# free memory stack
	 call sfree (sp)

	# give error if sequence was not found
	 if (!seqfound)
	 {
	     call errori(ECD_SEQNOTFOUND,
                 "File index for dataset does not contain sequence",seq)

	 }

	# check that fitsnm is not empty string
	 if (streq(fitsnm,""))
	 {
	    call error(ECD_FITSNOTEMPTY,
		"Sequence matched an empty fitsnm.")
	 }
end



