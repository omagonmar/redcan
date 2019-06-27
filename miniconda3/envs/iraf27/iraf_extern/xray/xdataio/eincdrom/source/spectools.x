#$Log: spectools.x,v $
#Revision 11.0  1997/11/06 16:36:55  prosb
#General Release 2.5
#
#Revision 9.1  1997/03/13 14:38:54  prosb
#JCC(3/13/97) - Rename check_datatype to ckein_datatype to avoid
#               "checke" multiply defined.
#
#Revision 9.0  1995/11/16  19:01:39  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:09  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  18:28:58  prosb
#General Release 2.3.1
#
#Revision 1.2  94/05/13  17:07:51  prosb
#Revised routine names, added purposes to most descriptions.
#
#Revision 1.1  94/05/06  17:31:50  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/source/RCS/spectools.x,v 11.0 1997/11/06 16:36:55 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       spectools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     ckein_datatype, specinfo
# Internal:     spec_is_list, spec_is_fits, spec2inst, spec2datatype,
#		spec2seq
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
include <ctype.h>

#--------------------------------------------------------------------------
# Procedure:	ckein_datatype
#
# Purpose:	Checks that datatype isn't inconsistent with instrument.
#
# Input variables:
#		inst		instrument name
#		datatype	datatype (e.g., "slew", "event", etc.)
#		display		display level
#
# Return value:  Returns TRUE if the datatype & instrument are consistent.
#
# Description:  A high-level check that the instrument & datatype are
# a possible pair.  The only impossible pairs are HRI unscreened and
# HRI slew.  This routine does NOT check if there is an unknown datatype
# or instrument.  This routine deals with strings, as opposed to the
# routine find_datatype which does the same action but with indices.
#--------------------------------------------------------------------------
# JCC - rename  check_datatype to ckein_datatype
###bool procedure check_datatype(inst,datatype,display)
bool procedure ckein_datatype(inst,datatype,display)
char	inst[SZ_LINE]	  # i: instrument name
char	datatype[SZ_LINE] # i: datatype
int	display		  # i: display level

bool 	is_valid	# is still valid?

bool	streq()		# TRUE if strings are equal [sys/fmtio]

begin
	is_valid=true

        #----------------------------------------------
	# invalid: hri & unscreened, hri & slew
        #----------------------------------------------

	if (streq(inst,"hri"))
	{
	    is_valid = !(streq(datatype,"unscreened") ||
		        streq(datatype,"slew"))
	    if (!is_valid && display>0)
	    {
	  	call printf("ERROR: There is no HRI %s data.\n")
	   	 call pargstr(datatype)
	    }
	}

	return is_valid
end

#--------------------------------------------------------------------------
# Procedure:    specinfo
#
# Purpose: 	Returns all possible information about specifier.
#
# Input variables:
#		spec		specifier string
#		display		Display level
#
# Output variables:
#		is_valid	Is it valid?
#		is_fits		Is specifier a FITS file name?
#		seq		What is the sequence number, if it's a
#				sequence?
#		inst		What is the instrument name, if we
#				can read it from the specifier?
#		datatype	What is the datatype, if we can tell?
#		is_list		Is the specifier actually a list instead?
#		filename	If so, what is the filename containing the
#				list?
#
# Description:  Given a specifier, returns all possible information about
# it.  For instance:
#
#    * Is it a list?  A list would be in the form "@listfile".  This
#      routine will return the name of the listfile in the variable 
#      filename.
#
#    * Is it a FITS file name?  If so, is_fits is set true and the 
#      instrument and datatype are determined from the file name.
#
#    * Otherise, it must be a sequence.  The sequence number is returned
#      in the variable "seq".  The instrument is also returned if the
#      sequence begins with "i" (for IPC) or "h" (for HRI).
#
# Variables which can not be determined are set to "unknown" (for strings).
#
# The is_valid flag is set FALSE if the instrument and datatype turn out
# to be invalid, such as "hri" "unscreened".  This flag can also be set
# false if the instrument is unknown or if the FITS file extension is
# unrecognized.
#
# Examples:
# * specifier="9004"
#   Here is_fits and is_list would both be false, inst and datatype would
#   be "unknown" and the sequence number would be 9004.
#
# * specifier="h1043"
#   Again, is_fits and is_list are false, but we now the instrument is
#   "hri" and the sequence is 1043.  The datatype is still "unknown".
#
# * specifier="i2109s68.upa"          
#   This is a FITS file, so is_fits would be true, while is_list would
#   be false.  We can generate the instrument ("ipc") and the datatype
#   ("unscreened").  We don't know the sequence number.
#
# * specifier="@seqlist"
#   Here is_fits is false and is_list is true.  The variable filename
#   would be returned with "seqlist".
#--------------------------------------------------------------------------

procedure specinfo(spec,is_valid,is_fits,seq,inst,datatype,is_list,
		filename,display)

char	spec[SZ_LINE]		# i: specifier
bool    is_valid		# o: Is it valid?
bool    is_fits			# o: Is it a FITS file?
int     seq			# o: If not, what is sequence number?
char	inst[SZ_LINE]		# o: What is instrument name?
char	datatype[SZ_LINE]	# o: What is datatype?
bool    is_list			# o: Is specifier a listfile?
char	filename[SZ_PATHNAME]	# o: If so, what is the filename?
int	display			# i: display level

### LOCAL VARS ###

int	spec_len	# Length of specifier

### EXTERNAL FUNCTION DECLARATIONS ###

bool	spec_is_list()	# returns TRUE if specifier is a listfile. [local]
bool	spec_is_fits()  # returns TRUE if specifier is valid. [local]
bool	spec2seq()	# returns TRUE if specifier is valid. [local]
int	strlen()	# returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # Initialize variables
        #----------------------------------------------
	is_valid=true
	is_fits=false
	seq=0
	call strcpy("NONE",filename,SZ_PATHNAME)
	call strcpy("unknown",inst,SZ_LINE)
	call strcpy("unknown",datatype,SZ_LINE)


        #----------------------------------------------
        # Deal with case of empty string.
        #----------------------------------------------
	spec_len=strlen(spec)
	if (spec_len==0)
	{
	    is_valid=false
	    if (display>0)
	    {
	    	call printf("ERROR: specifier must be non-empty.\n")
	    }
	}	
	else
	{
            #----------------------------------------------
            # Is specifier a list?
            #----------------------------------------------
	    is_list = spec_is_list(spec,filename)

	    if (!is_list)
	    {
                #----------------------------------------------
                # Is specifier a FITS file?
                #----------------------------------------------
		is_valid = spec_is_fits(spec,spec_len,inst,datatype,is_fits,
					display)

		if (is_valid && !is_fits )
		{
        	    #----------------------------------------------
	            # must be sequence number!
	            #----------------------------------------------
		    is_valid=spec2seq(spec,spec_len,inst,seq,display)
		}
	    }
	}
end


#--------------------------------------------------------------------------
# Procedure:    spec_is_list
#
# Purpose: 	Returns TRUE if specifier is in listfile format ("@file")
#
# Input variables:
#		spec		specifier
#
# Output variables:
#               filename	if so, what is the name of the file?
#
# Note: Specifier is assumed to be at least one character long!
#--------------------------------------------------------------------------

bool procedure spec_is_list(spec,filename)

char	spec[SZ_LINE]		# i: specifier
char	filename[SZ_PATHNAME]	# o: filename of listfile

bool	is_list		# TRUE if specifier is listfile

begin
	is_list=false

	if (spec[1]=='@')
	{
	    is_list=true
	    call strcpy(spec[2],filename,SZ_PATHNAME)
	}

	return is_list
end

#--------------------------------------------------------------------------
# Procedure:	spec_is_fits
#
# Purpose:	Returns true if specifier is FITS file.
#
# Input variables:
#		spec		specifier
#		spec_len	length of specifier
#		display		display level
#
# Output variables:
#               inst		Instrument of data
#		datatype	Type of data ("event", "unscreened", etc.)
#		is_fits		Is it a FITS file?
#
# Return value: Returns TRUE if specifier is still considered valid.
#
# Description:  The specifier is considered a FITS file if it is 12 
# characters long, with character 9 a period.  (E.g., "i00n0000.upa".)
# If so, the routines spec2inst and spec2datatype are called to read
# the instrument and datatype from the FITS file, and the routine
# ckein_datatype is called to make sure it's valid.
#--------------------------------------------------------------------------

bool procedure spec_is_fits(spec,spec_len,inst,datatype,is_fits,display)

char	spec[SZ_LINE]	 # i: specifier
int	spec_len	 # i: specifier length
char	inst[SZ_LINE]	 # o: instrument
char	datatype[SZ_LINE]# o: datatype (e.g., "event", "image", etc.)
bool	is_fits		 # o: is it a FITS file?
int	display		 # i: display level

### LOCAL VARS ###

bool	is_valid	# Is specifier still considered valid?

### EXTERNAL FUNCTION DECLARATIONS ###

bool	spec2inst()	# returns TRUE if specifier is valid [local]
bool	spec2datatype() # returns TRUE if specifier is valid [local]
bool	ckein_datatype()# returns TRUE if instrument & datatype are
			#  consistent [local]

### BEGINNING OF PROCEDURE ###

begin
	is_valid=true
	is_fits=false

	if (spec_len==12 && spec[9]=='.')
	{
	   is_fits=true
	   is_valid=spec2inst(spec,inst,display)
	   is_valid = is_valid && spec2datatype(spec,datatype,display)
	   is_valid = is_valid && ckein_datatype(inst,datatype,display)
	}

	return is_valid

end

#--------------------------------------------------------------------------
# Procedure:	spec2inst
#
# Purpose:	Reads instrument from specifier.
#
# Input variables:
#		spec		specifier
#               display		display level
#		
# Output variables:
#               inst            Instrument of data
#
# Return value: Returns TRUE if specifier is still considered valid.
#
# Description:  Figures out the instrument from the specifier by 
# looking at the first letter: 
#
#         'i', 'm', 's' are all IPC instrument names
#         'h' is HRI.
#
# (The 'm' comes from the merged IPC sequences in the IPC event CDROM.)
#
# If the first letter is none of these, the specifier is considered
# to be invalid.  
#
# It is assumed that the specifier is at least one character long.
# 
#--------------------------------------------------------------------------

bool procedure spec2inst(spec,inst,display)

char	spec[SZ_LINE]  # i: specifier
char	inst[SZ_LINE]  # o: instrument ("ipc", "hri")
int	display	       # i: display level

bool	is_valid    # is specifier still considered valid?
char	spec_char   # initial character of specifier

begin
	spec_char=spec[1]
	is_valid=true	

	switch (spec_char)
	{
	    case 'i','m','s':
	    	call strcpy("ipc",inst,SZ_LINE)
	    case 'h':
	    	call strcpy("hri",inst,SZ_LINE)
	    default:
	    	is_valid=false
		if (display>0)
		{
	    	    call printf("ERROR: invalid instrument '%s'.\n")
	    	     call pargstr(spec_char)
		}
	}

	if (display>4)
	{
	    call printf("Found instrument to be %s.\n")
	     call pargstr(inst)
	}
	return is_valid
end

#--------------------------------------------------------------------------
# Procedure:	spec2datatype
#
# Purpose:	Reads datatype from specifier.
#
# Input variables:
#		spec		specifier
#               display		display level
#		
# Output variables:
#               datatype	type of data ("event", "unscreened", etc.)
#
# Return value: Returns TRUE if specifier is still considered valid.
#
# Description:  Reads the datatype from the specifier.  The specifier
# is assumed to be a FITS file at this point, with characters 10-12
# being the extension, e.g., "upb", "xia", etc.  If the extension is
# not recognized, the specifier is considered to be invalid.
#
# Only the first two characters of the extension identify the datatype.
# They are:
#            'xp'    HRI or IPC event files
#            'xi'    HRI or IPC image files
#            'f3'    IPC slew files ("f3d" is the full extension)
#            'up'    unscreened photon list (IPC only for now).
#--------------------------------------------------------------------------

bool procedure spec2datatype(spec,datatype,display)

char	spec[SZ_LINE]	 # i: specifier
char	datatype[SZ_LINE]# o: datatype
int	display		 # i: display level

char	ext[2]		# first two characters of extension
char	full_ext[3]     # full extension
bool	is_valid	# is speicifer still considered valid?
string  extensions "|xp|xi|f3|up|"  # list of known extensions

int     strdic()        # returns where the input word appear in a
                        # dictionary of words [sys/fmtio]

begin
        #----------------------------------------------
        # Read in ext and full_ext from specifier
        #----------------------------------------------
   	call strcpy(spec[10],ext,2)
	call strcpy(spec[10],full_ext,3)

	is_valid=true

        #----------------------------------------------
        # Use strdic to match extensions.
        #----------------------------------------------
	switch (strdic(ext,ext,2,extensions))
	{
	    case 1:  # xp
	  	call strcpy("event",datatype,SZ_LINE)
	    case 2:  # xi
	  	call strcpy("image",datatype,SZ_LINE)
	    case 3:  # f3
	  	call strcpy("slew",datatype,SZ_LINE)
	    case 4:  # up
	  	call strcpy("unscreened",datatype,SZ_LINE)
	    default:
	  	is_valid=false
		if (display>0)
		{
	  	    call printf("ERROR: '%s' is not a valid Einstein FITS event file extension.\n")
		     call pargstr(full_ext)
		}
	}

	if (display>4)
	{
	    call printf("Found datatype to be %s.\n")
	     call pargstr(datatype)
	}
	return is_valid
end


#--------------------------------------------------------------------------
# Procedure:	spec2seq
#
# Purpose:	Reads sequence from specifier
#
# Input variables:
#		spec		specifier
#		spec_len	length of specifier
#               display         Display level
#
# Output variables:
#               inst		instrument (if it can be read from spec.)
#		seq		sequence number
#
# Return value: Returns TRUE if specifier is still considered valid.
#
# Description:  The specifier is assumed to be a sequence number at
# this point. The specifier is expected to be in one of two forms:
# all digits (e.g., "1043") or one character [describing the instrument]
# followed by digits (e.g., "i9004").
#
# This routine will return the sequence number and the instrument, if
# it was included in the specifier.  
#
# The specifier is expected to be at least one character long.
#
#--------------------------------------------------------------------------

bool procedure spec2seq(spec,spec_len,inst,seq,display)
char	spec[SZ_LINE]	# i: specifier
int	spec_len	# i: specifier length
char	inst[SZ_LINE]	# o: instrument (if it can be figured out)
int	seq		# o: sequence number
int	display		# i: display level

### LOCAL VARS ###

bool	is_valid	# Is specifier still considered valid?
int     spec_seq_start  # Where in the specifier string the sequence
			#  number begins.

### EXTERNAL FUNCTION DECLARATIONS ###

bool	spec2inst()	# returns TRUE if specifier is valid [local]
bool	isalldigits()   # returns TRUE if string is all digits [../source]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Initialize variables
        #----------------------------------------------
	is_valid=true
	spec_seq_start=1

        #----------------------------------------------
	# read instrument, if it's there!
        #----------------------------------------------
	if (! IS_DIGIT(spec[1]))
	{
	    if (spec_len==1)
	    {
		is_valid=false
		if (display>0)
		{
		    call printf("ERROR: missing sequence number,'%s'.\n")
		     call pargstr(spec)
		}
	    }
	    else
	    {
	    	spec_seq_start=2
	    	is_valid = spec2inst(spec,inst,display)
	    }
	}

        #----------------------------------------------
	# Convert specifier to sequence number
        #----------------------------------------------
	if (is_valid)
	{
	    #----------------------------------------------
	    # Check that the specifier is all digits.
	    #----------------------------------------------
	    is_valid = isalldigits(spec[spec_seq_start])
	    if (!is_valid)
	    {
	        if (display>0)
	        {
	            call printf("ERROR: invalid sequence number, '%s'.\n")
		     call pargstr(spec[spec_seq_start])
		}
	    }
	    else
	    {
		call sscan(spec[spec_seq_start])
		 call gargi(seq)
	    }
	}

	return is_valid
end
