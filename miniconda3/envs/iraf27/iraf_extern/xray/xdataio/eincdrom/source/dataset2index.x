#$Log: dataset2index.x,v $
#Revision 11.0  1997/11/06 16:36:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:33  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:06  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  18:28:48  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/06  17:32:23  prosb
#This routine will be obsolete soon...revised header keywords
#
#Revision 7.0  93/12/27  18:45:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:45  prosb
#General Release 2.2
#
#Revision 1.2  93/04/18  16:22:46  prosb
#Added eoscat and hriimg.
#
#Revision 1.1  93/04/13  09:39:55  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/dataset2index.x,v 11.0 1997/11/06 16:36:53 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       dataset2index.x
# Project:      PROS -- EINSTEIN CDROM
# External:	dataset2index
# Local:	(none)
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 4/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "dataset.h"
include "ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:	dataset2index
#
# Purpose:      To return the index corresponding to a dataset, as
#		defined in "dataset.h"
#
# Input variables:
#               dataset:     Einstein dataset (ipc, hri, etc.)    
#
# Return value:	returns the index of the dataset
#
# NOTE: THIS ROUTINE IS ONLY USED BY OBSOLETED TASKS IN EINCDROM!
#--------------------------------------------------------------------------

int procedure dataset2index(dataset)
char    dataset[SZ_DATASET]  	# which Einstein dataset 

### LOCAL VARS ###

int     i_dataset             	# returning dataset index.

### EXTERNAL FUNCTION DECLARATIONS ###

bool    streq()              	# true if strings are equal [sys/ftmio]
  
### BEGINNING OF PROCEDURE ###

begin

	# find index corresponding to dataset
	 if (streq(dataset,"ipcevt"))
	   i_dataset=IPC_EVT 
	 else if (streq(dataset,"hrievt"))    
	   i_dataset=HRI_EVT 
	 else if (streq(dataset,"eoscat"))    
	   i_dataset=EOSCAT 
	 else if (streq(dataset,"hriimg"))    
	   i_dataset=HRI_IMG 
	 else if (streq(dataset,"slew"))    
	   i_dataset=SLEW 
	 else 
	   call errstr (ECD_UNKDATASET, "Do not recognize dataset",dataset)

	# return dataset index
	 return i_dataset
end
