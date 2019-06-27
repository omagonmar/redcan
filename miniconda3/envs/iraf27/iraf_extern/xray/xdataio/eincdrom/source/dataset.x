#$Log: dataset.x,v $
#Revision 11.0  1997/11/06 16:36:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:32  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:03  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  18:28:46  prosb
#General Release 2.3.1
#
#Revision 1.2  94/05/13  17:07:13  prosb
#Broke find_dataset into two routines; added actual error values to
#error().
#
#Revision 1.1  94/05/06  17:31:41  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/dataset.x,v 11.0 1997/11/06 16:36:52 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       dataset.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     find_instid, find_dataset
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
include "dataset.h"
include "ecd_err.h"

#--------------------------------------------------------------------------
# Procedure:    find_instid
#
# Purpose:	Converts instrument string into instrument ID.
#
# Input variables:
#		inst		instrument string
#
# Output variables:
#		instid		instrument ID (see dataset.h)
#
# Return value:  Returns TRUE if instrument string is valid
#
#--------------------------------------------------------------------------

bool procedure find_instid (inst,instid)
char    inst[SZ_LINE]
int     instid

bool    is_valid

bool    streq()
begin
	is_valid=TRUE

	instid=0
	if (streq(inst,"hri"))
	{
	    instid=HRI_ID
	}
	else if(streq(inst,"ipc"))
	{
	    instid=IPC_ID
	}
	else
	{
	    call error(ECD_UNKNOWN_INST_ID,
		"FIND_INSTID: Unexpected instrument")
	}

	return is_valid
end

#--------------------------------------------------------------------------
# Procedure:    find_dataset
#
# Purpose:	Converts datatype string and instrument ID into dataset.
#
# Input variables:
#		instid		Instrument ID
#		datatype	Type of data (event, image, etc.)
#
# Output variables:
#               dataset		Dataset index (see dataset.h)
#
# Return value: returns TRUE if input instid & datatype are valid.
#
# Description:  This routine figures out which dataset is determined
# by the instrument and datatype.  If there is none (for instance, there
# is no "slew" "hri" dataset), the routine returns FALSE.
#--------------------------------------------------------------------------


bool procedure find_dataset(instid,datatype,dataset)
int	instid
char	datatype[SZ_LINE]
int	dataset

bool	is_valid

bool	streq()
begin
	is_valid=TRUE

	if (streq(datatype,"event"))
	{
	    if (instid==HRI_ID)
	    {
		dataset=HRI_EVT
 	    }
	    else
	    {
		dataset=IPC_EVT
	    }
	}
	else if (streq(datatype,"image"))
	{
	    if (instid==HRI_ID)
	    {
		dataset=HRI_IMG
 	    }
	    else
	    {
		dataset=EOSCAT
	    }
	}
	else if (streq(datatype,"slew"))
	{
	    if (instid==HRI_ID)
	    {
		is_valid=FALSE
		dataset=UNKNOWN_DATASET
 	    }
	    else
	    {
		dataset=SLEW
	    }
	}
	else if (streq(datatype,"unscreened"))
	{
	    if (instid==HRI_ID)
	    {
		is_valid=FALSE
		dataset=UNKNOWN_DATASET
 	    }
	    else
	    {
		dataset=IPCU
	    }
	}
	else
	{
	    call error(ECD_UNKNOWN_TYPE,
		"FIND_DATASET: Unexpected datatype")
	}

	return is_valid
end

