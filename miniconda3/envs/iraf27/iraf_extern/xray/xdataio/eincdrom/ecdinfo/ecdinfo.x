#$Log: ecdinfo.x,v $
#Revision 11.0  1997/11/06 16:37:07  prosb
#General Release 2.5
#
#Revision 9.1  1997/03/13 14:33:58  prosb
#JCC(3/13/97) - Rename check_datatype to ckein_datatype to avoid
#               "checke" multiply defined.
#
#Revision 9.0  1995/11/16  19:01:52  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:11:45  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:45  prosb
#General Release 2.3.1
#
#Revision 1.2  94/05/13  17:08:56  prosb
#Added routines eci_get_params and eci_disp.
#
#Revision 1.1  94/05/06  17:26:57  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/ecdinfo/RCS/ecdinfo.x,v 11.0 1997/11/06 16:37:07 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       ecdinfo.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_ecdinfo
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
include "../source/dataset.h"

#--------------------------------------------------------------------------
# Procedure:    t_ecdinfo()
#
# Purpose:      Main procedure call for the task ecdinfo
#
# Input parameters:
#		specifier	FITS file name or sequence number of data
#		inst		instrument type (ipc/hri)
#		datatype	Type of data (event, unscreened, etc.)
#               display         display level
#		eincdpar        Eincdrom package parameters
#
# Output parameters:
#		is_valid        Were the input parameters valid?
#		seq 		Sequence number of data (e.g., "i5417")
#		fits_root       FITS root (e.g., "i0026n12")
#		fits_ext        FITS extension (i.e. 'a', 'b', etc.)
#		ra,dec          RA and DEC of sequence (in degrees)
#		hour            Sequence hour (e.g., "00h")
#		dir             Directory containing the CD with 
#				   sequence data
#		evt_off         Event time offset correction
#		livetime        Livetime of sequence
#		title 		Sequence title
#
# Description:  This procedure reads in the parameters and calls the
#		routine ecdinfo().  The user uses this task by 
#		requesting information about Einstein data; this task
#		will display it to the screen (if display>0) as well
#		as to the output parameters.
#
# Note: Though inst and datatype are input parameters, they are also
#	written out to as output parameters.  This task tries to read
#	as much information as possible from the specifier, so if it
#	already knows the instrument and datatype, it won't bother to
#	read those parameters.  But it will still write out the new
#	values.
#
#       The output parameter "seq" includes the instrument initial ("i"
#	or "h"), although it is the integral value which is displayed.
#	This is for the convenience of the ECD2PROS task.
#	
#--------------------------------------------------------------------------
procedure t_ecdinfo()
pointer p_spec		# pointer to specifier string
pointer p_inst		# pointer to instrument string
pointer p_datatype	# pointer to datatype string
bool	is_valid	# Were the input parameters valid?
pointer	p_seq_str	# Sequence number of data
pointer	p_fits_root	# pointer to FITS root
char	fits_ext	# FITS extension
double	ra,dec		# RA and DEC of sequence
pointer	p_hour		# pointer to sequence hour
pointer p_dir		# pointer to directory name containing CD with 
			#  sequence data
double	evt_off		# Event time offset correction
double	livetime	# Livetime of sequence
pointer	p_title		# pointer to sequence title
int	display		# display level

### LOCAL VARS ###

int	dataset		# dataset index (ipcevt, hriimg, etc.)
bool	is_fits		# is specifier a FITS file name?
int	seq		# sequence number of data, as an integer
pointer sp        	# stack pointer

### BEGINNING OF PROCEDURE ###

int	clgeti()	# returns integer CL parameter [sys/clio]
bool    eci_get_params() # returns true if params are valid so far [local]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_spec, SZ_LINE, TY_CHAR)
        call salloc( p_inst, SZ_LINE, TY_CHAR)
        call salloc( p_datatype, SZ_LINE, TY_CHAR)
	call salloc( p_fits_root, SZ_LINE, TY_CHAR)
        call salloc( p_dir, SZ_PATHNAME, TY_CHAR)
        call salloc( p_hour, SZ_LINE, TY_CHAR)
        call salloc( p_seq_str, SZ_LINE, TY_CHAR)
        call salloc( p_title, SZ_LINE, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
	display=clgeti("display")
        call clgstr("specifier",Memc[p_spec],SZ_LINE)

        #----------------------------------------------
        # remove white space around specifier and 
	# force specifier to be lowercase
        #----------------------------------------------
        call strip_whitespace(Memc[p_spec])
	call strlwr(Memc[p_spec])

        #----------------------------------------------
        # get remaining parameters.
        #----------------------------------------------
	is_valid=eci_get_params(Memc[p_spec],Memc[p_inst],
			Memc[p_datatype],seq,is_fits,display)

	if (display>4)
	{
            call printf("Get_params:  Inst=%s, datatype=%s, seq=%d.\n")
             call pargstr(Memc[p_inst])
             call pargstr(Memc[p_datatype])
             call pargi(seq)
	    call flush(STDOUT)
	}

        #----------------------------------------------
	# put inst & datatype back out to parameter file
        #----------------------------------------------
	call clpstr("inst",Memc[p_inst],SZ_LINE)
	call clpstr("datatype",Memc[p_datatype],SZ_LINE)

        #----------------------------------------------
        # get specifier info
        #----------------------------------------------
	call ecdinfo(Memc[p_spec],Memc[p_inst],
		Memc[p_datatype],seq,is_fits,is_valid,
		Memc[p_fits_root],fits_ext,ra,dec,Memc[p_hour],
		Memc[p_seq_str],Memc[p_dir],evt_off,
		livetime,Memc[p_title],dataset,display)

        #----------------------------------------------
        # display information
        #----------------------------------------------
	if (is_valid && display>0)
	{
	    call eci_disp(dataset,seq,Memc[p_fits_root],
		fits_ext,ra,dec,Memc[p_dir],evt_off,
                livetime,Memc[p_title])
	}

        #----------------------------------------------
        # put info in parameters
        #----------------------------------------------
	call clputb("is_valid",is_valid)
	call clpstr("seq",Memc[p_seq_str])
	call clpstr("fits_root",Memc[p_fits_root])
	call clputc("fits_ext",fits_ext)
	call clputd("ra",ra)
	call clputd("dec",dec)
	call clpstr("hour",Memc[p_hour])
	call clpstr("dir",Memc[p_dir])
	call clputd("evt_off",evt_off)
	call clputd("livetime",livetime)
	call clpstr("title",Memc[p_title])

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end

#--------------------------------------------------------------------------
# Procedure:    eci_get_params
#
# Purpose:	Determines what parameters are still needed to read from
#		for ecdinfo task.
#
# Input variables:
#		spec		input specifier
#               display         display level
#
# Output variables:
#		inst		instrument (ipc/hri)
#		datatype	datatype (event, unscreened, etc.)
#		seq		sequence number (if known)
#		is_fits		is specifier a FITS file?
#
# Return value:
#		Returns true if parameters are valid so far.
#
# Description:  After the specifier has been read, this routine can
#		be called.  It will determine which of the remaining
#		two parameters (instrument, datatype) needs to be
#		read, and reads them.
#		
#--------------------------------------------------------------------------

bool procedure eci_get_params(spec,inst,datatype,seq,is_fits,display)
char    spec[SZ_LINE]	  # i: specifier
char    inst[SZ_LINE]	  # o: instrument
char    datatype[SZ_LINE] # o: datatype (event, image, unscreened, etc.)
int	seq		  # o: sequence number (if known)
bool	is_fits		  # o: is specifier a FITS file?
int     display		  # i: display level

### LOCAL VARS ###

bool	is_list		# is specifier a list?
bool	is_valid	# is specifier valid?
pointer	p_fname		# pointer to file name (if list)
pointer	sp		# stack pointer

### EXTERNAL FUNCTION DECLARATIONS ###

bool	streq()		# TRUE if strings are equal [sys/fmtio]
bool	ckein_datatype()# TRUE if datatype is consistent with instrument
#bool	check_datatype()# TRUE if datatype is consistent with instrument
			#   [../source/spectools.x]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for filename.  (Even though
	# the filename is never used, we need it just
	# in case the user enters a file list. We will
	# then give emit an error.)
        #----------------------------------------------
        call smark(sp)
        call salloc( p_fname, SZ_PATHNAME, TY_CHAR)

        #-------------------------------------------------
        # Determine, from specifier, as much information
	# we can: is it valid? a fits file? a list? etc.
        #------------------------------------------------
	call specinfo(spec,is_valid,is_fits,seq,
		inst,datatype,is_list,Memc[p_fname],display)

        #-------------------------------------------------
        # If it's a list, display error and consider the
        # specifier invalid.
        #------------------------------------------------
	if (is_list)
	{	
	    is_valid=false
	    if (display>0)
	    {
	       call printf("ERROR: ecdinfo can not be run with a list.\n")
 	    }
	}

	if (is_valid)
	{
            #-------------------------------------------------
            # Read in instrument and datatype, if needed.
            #------------------------------------------------
	    if (streq("unknown",inst))
	    {
		call clgstr("inst",inst,SZ_LINE)
	    }

	    if (streq("unknown",datatype))
	    {
		call clgstr("datatype",datatype,SZ_LINE)
	    }

            #-------------------------------------------------
            # Check consistency of datatype with instrument.
            #------------------------------------------------
	    ##is_valid=check_datatype(inst,datatype,display)
	    is_valid=ckein_datatype(inst,datatype,display)
	}

	call sfree(sp)

	return is_valid
end

#--------------------------------------------------------------------------
# Procedure:    eci_disp
#
# Purpose:      Displays output information about data to stdout.
#
# Input parameters:
#		dataset		dataset index (hrievt, ipcu, etc.)
#               seq             Sequence number of data (integer value)
#               fits_root       FITS root (e.g., "i0026n12")
#               fits_ext        FITS extension (i.e. 'a', 'b', etc.)
#               ra,dec          RA and DEC of sequence (in degrees)
#               dir             Directory containing the CD with
#                                  sequence data
#               evt_off         Event time offset correction
#               livetime        Livetime of sequence
#               title           Sequence title
#
# Description:  Displays the data information to the user.
#--------------------------------------------------------------------------

procedure eci_disp(dataset,seq,fits_root,fits_ext,ra,dec,
		dir,evt_off,livetime,title)
int	dataset		   # i: dataset index
int	seq		   # i: sequence number
char	fits_root[SZ_LINE] # i: FITS root
char	fits_ext	   # i: FITS extension
double	ra,dec		   # i: RA and DEC of sequence
char	dir[SZ_PATHNAME]   # i: directory name containing CD with
                           #      sequence data
double  evt_off            # i: Event time offset correction
double  livetime           # i: Livetime of sequence
char	title[SZ_LINE]	   # i: sequence title

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equald()	# returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Display FITS root.
        #----------------------------------------------
	call printf("\nFITS root: %s")
	 call pargstr(fits_root)

        #----------------------------------------------
        # SLEW dataset has no extension or sequence #
        #----------------------------------------------
	if (dataset==SLEW)
	{
	    call printf(".\n")
	}
   	else
	{
	    call printf(", extension: %c, sequence %d.\n")
	     call pargc(fits_ext)
	     call pargi(seq)
	}

        #----------------------------------------------
        # Print title, RA, and DEC.
        #----------------------------------------------
	call printf("\nTitle: %s.\n")
	 call pargstr(title)
	call printf("\nRa=%10H, Dec=%10h")
	 call pargd(ra)
	 call pargd(dec)

        #----------------------------------------------
        # SLEW dataset has no livetime.
        #----------------------------------------------
	if (dataset==SLEW)
	{
	    call printf(".\n")
	}
	else
	{
	    call printf(", livetime: %.2f seconds.\n")
	     call pargd(livetime)
	}

        #----------------------------------------------
        # Only display event offset if non-zero.
        #----------------------------------------------
	if (!fp_equald(evt_off,0.0D0))
	{
	    call printf("\nAll photon arrival times and TGR records should")
	    call printf(" have the offset of\n")
	    if (evt_off>0.0D0)
	    {
	       call printf("+")
	    }
	    call printf("%.6f seconds applied.\n")
	     call pargd(evt_off)
	}

        #----------------------------------------------
        # Display directory.
        #----------------------------------------------
	call printf("\nThis sequence should be on the CDROM in the directory %s.\n")
	 call pargstr(dir)
end
