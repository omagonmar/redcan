#$Log: eci_tools.x,v $
#Revision 11.0  1997/11/06 16:37:06  prosb
#General Release 2.5
#
#Revision 9.2  1996/04/16 17:53:35  prosb
#JCC - Replaced "bool strncmp()" with "int strncmp()" in
#      find_row_by_fits() to fix the problem on LINUX.
#
#Revision 9.0  95/11/16  19:01:56  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:11:48  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:53  prosb
#General Release 2.3.1
#
#Revision 1.4  94/06/15  11:37:46  dvs
#Fixed minor bug needed for VAX installation.  There was an
#extra declaration of the find_row() routine.
#
#Revision 1.3  94/05/18  17:18:32  prosb
#Fixed minor bug; find_row_by_fits wasn't setting is_found to be false,
#so it would find the wrong fits file!
#
#Revision 1.2  94/05/13  17:09:45  prosb
#Moved eci_get_params and display routines into ecdinfo.x.
#Revised routine names, added purposes, broke find_row into
#two routines find_row_by_seq and find_row_by_fits.
#
#Revision 1.1  94/05/06  17:27:13  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/ecdinfo/RCS/eci_tools.x,v 11.0 1997/11/06 16:37:06 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       eci_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     eci_get_params, ecdinfo
# Internal:	get_eci_name, find_row, find_row_by_seq, find_row_by_fits,
#		interpret_row, get_dir
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "../source/dataset.h"
include "../source/ecd_err.h"
include "eci.h"


#--------------------------------------------------------------------------
# Procedure:    ecdinfo
#
# Purpose:  Looks up information on Einstein datasets
#
# Input variables:
#		spec		specifier: FITS file or sequence no.
#		inst		instrument
#               datatype        Type of data (event, unscreened, etc.)
#		seq		sequence
#		is_fits		is the specifier a FITS file?
#		display		display level
#
# Input & Output variables:
#		is_valid	were input parameters valid?
#
# Output variables:
#               fits_root       FITS root (e.g., "i0026n12")
#               fits_ext        FITS extension (i.e. 'a', 'b', etc.)
#               ra,dec          RA and DEC of sequence (in degrees)
#		hour            Sequence hour (e.g., "00h")
#		seq_str		Sequence, in string format (e.g., "i2060")
#               dir             Directory containing the CD with
#                                  sequence data
#               evt_off         Event time offset correction
#               livetime        Livetime of sequence
#               title           Sequence title
#		dataset		Index for dataset (see dataset.h).
#
# Description:  Main routine for ecdinfo task.  (See "help ecdinfo".)
#		Given a specifier, instrument, and datatype, looks up
#		information about this data in info tables and returns
#		the data.
#
# Note: The is_valid variable is TRUE as long as we still think the
# input values are valid.  As soon as we discover something wrong
# (such as an invalid sequence number or a bad combination of instrument
# and dataset), this boolean is set FALSE.  An error message is displayed
# to the user, but the program doesn't crash.  If we were to give an
# actual error, scripts running this task would crash as well.
#--------------------------------------------------------------------------


procedure ecdinfo(spec,inst,datatype,seq,is_fits,is_valid,
		fits_root,fits_ext,ra,dec,hour,
		seq_str,dir,evt_off,livetime,title,
		dataset,display)
char	spec[SZ_LINE]	  # i: specifier
char	inst[SZ_LINE] 	  # i: instrument
char	datatype[SZ_LINE] # i: type of data
int	seq		  # i: sequence number
bool	is_fits		  # i: is specifier a FITS file?
bool	is_valid	  # io: was input data valid?
char	fits_root[SZ_LINE] # o: FITS root
char	fits_ext	  # o: FITS extension
double	ra,dec		  # o: RA & DEC of sequence
char	hour[SZ_LINE]	  # o: Hour (e.g. "00h")
char	seq_str[SZ_LINE]  # o: Sequence, in string format
char	dir[SZ_PATHNAME]  # o: Directory containing CD with data
double	evt_off		  # o: Event time offset correction
double	livetime	  # o: Seq. livetime
char	title[SZ_LINE]    # o: Seq. title
int	dataset		  # o: Index for dataset
int	display		  # i: display level

### LOCAL VARS ###

pointer	col_ptr[N_COL_ECI]# column pointers for ECI tables
int	instid		  # ID for instrument (see dataset.h)
int	i_eci		  # ECI row index
int	n_eci		  # Number of rows in ECI table
pointer	p_eci		  # pointer to ECI data
pointer p_eci_info	  # pointer to specific ECI info structure
pointer p_eci_name	  # name of ECI table (e.g., "slew_info.tab")
pointer	sp		  # stack pointer
pointer tp		  # table pointer

### EXTERNAL FUNCTION DECLARATIONS ###

bool	find_dataset()	# TRUE if input values are valid [local]
bool	find_instid()	# TRUE if input values are valid [local]
bool	find_row()	# TRUE if input values are valid [local]
int	gt_open()	# returns number of rows [libgentab]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # Set aside space for ecdinfo table name
        #----------------------------------------------
	call smark(sp)
        call salloc( p_eci_name, SZ_LINE, TY_CHAR)

        #----------------------------------------------
        # Initialize return data
        #----------------------------------------------
	call strcpy("unknown",seq_str,SZ_LINE)
	call strcpy("unknown",fits_root,SZ_LINE)
	fits_ext=' '
	ra=0.0d0
	dec=0.0d0
	livetime=0.0d0
	call strcpy("unknown",hour,SZ_LINE)
	call strcpy("unknown",dir,SZ_PATHNAME)
	call strcpy("unknown",title,SZ_LINE)
	evt_off=0.0d0

        #----------------------------------------------
        # Find instrument ID
        #----------------------------------------------
	if (is_valid)
	{
	    is_valid=find_instid(inst,instid)
	}

        #----------------------------------------------
        # Find dataset index from instrument & datatype
        #----------------------------------------------
	if (is_valid)
	{
	    is_valid=find_dataset(instid,datatype,dataset)
	}

        #----------------------------------------------
        # Everything is clear so far...open ECI table!
        #----------------------------------------------
	if (is_valid)
	{

            call eci_setup(p_eci_info)
	    call get_eci_name(dataset,Memc[p_eci_name])
	    n_eci=gt_open(Memc[p_eci_name],READ_ONLY,tp,col_ptr,p_eci_info)

            #------------------------------------------------
            # Find row which contains sequence or FITS name
            #------------------------------------------------
	    is_valid=find_row(dataset,tp,col_ptr,p_eci_info,n_eci,
			    is_fits,seq,spec,i_eci)

	    if (is_valid)
	    {
	        #----------------------------------------------
        	# Read row from ECI
	        #----------------------------------------------
	        call malloc(p_eci,SZ_ECI,TY_STRUCT)
	        call gt_get_row(tp,p_eci_info,col_ptr,i_eci,
				true,p_eci)

	        #----------------------------------------------
        	# Convert row contents into return variables.
	        #----------------------------------------------
		call interpret_row(p_eci,instid,dataset,seq,
		   fits_root,fits_ext,ra,dec,hour,
		   seq_str,dir,evt_off,livetime,title)

	        #----------------------------------------------
        	# Free contents of row
	        #----------------------------------------------
	        call gt_free_rows(p_eci,p_eci_info,1)
	    }

            #------------------------------------------------
            # Close table and free table info
            #------------------------------------------------
	    call tbtclo(tp)
            call gt_free_info(p_eci_info)
	}

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
	call sfree(sp)	
end

#--------------------------------------------------------------------------
# Procedure:    get_eci_name
#
# Purpose: Returns the eincdrom info table path for the passed-in dataset.
#
# Input variables:
#		dataset		Index for dataset (see dataset.h)
#
# Output variables:
#               eci_name	Name of table containing dataset data
#
# Description:  This routine will look up (in the PSET pointed to by 
#		"eincdpar") the name of the table which contains the
#		information for the passed in dataset.
#		
#--------------------------------------------------------------------------

procedure get_eci_name(dataset,eci_name)
int	dataset		  # i: dataset
char	eci_name[SZ_LINE] # o: name of ECI table

pointer	pp  		# PSET pointer

pointer clopset()	# returns PSET pointer [sys/clio]

begin
        #----------------------------------------------
        # open PSET
        #----------------------------------------------
        pp = clopset("eincdpar")

        #----------------------------------------------
        # Read info table name from parameter file
        #----------------------------------------------
	switch(dataset)
	{
	    case IPC_EVT:
		call clgstr("ipcevt_info",eci_name,SZ_LINE)
	    case HRI_EVT:
		call clgstr("hrievt_info",eci_name,SZ_LINE)
	    case EOSCAT:
		call clgstr("eoscat_info",eci_name,SZ_LINE)
	    case HRI_IMG:
		call clgstr("hriimg_info",eci_name,SZ_LINE)
	    case SLEW:
		call clgstr("slew_info",eci_name,SZ_LINE)
	    case IPCU:
		call clgstr("ipcu_info",eci_name,SZ_LINE)
	    default:
		call errori(ECD_UNKNOWN_TYPE,
			"FIND_EC_NAME: Unknown dataset",dataset)
	}

        #----------------------------------------------
        # close PSET
        #----------------------------------------------
        call clcpset(pp)
end

#--------------------------------------------------------------------------
# Procedure:    find_row
#
# Purpose: Finds the appropriate row within the info table for this data.
#
# Input variables:
#		dataset		which type of data (see dataset.h)
#		tp		ECI table pointer
#		col_ptr		Column pointers
#		p_eci_info	ECI table info
#		n_eci		Number of rows in ECI table
#		is_fits		Is the specifier a FITS file?
#		seq		input sequence number (if above is false)
#		spec		specifier
#
# Output variables:
#		i_eci		which row of table is specified row?
#
# Return value: Returns TRUE if input data is valid.
#
# Description: This routine will either call find_row_by_fits or 
# find_row_by_seq, depending on whether the specifier is a FITS file or
# not.  It will return the row number in i_eci.
#--------------------------------------------------------------------------

bool procedure find_row(dataset,tp,col_ptr,p_eci_info,n_eci,
			    is_fits,seq,spec,i_eci)
int	dataset		  # i: dataset (e.g. ipcevt, hrievt, etc.) index
pointer tp		  # i: table pointer
pointer	col_ptr[N_COL_ECI]# i: column pointers
pointer	p_eci_info	  # i: ECI table info
int	n_eci		  # i: number of rows in table
bool	is_fits		  # i: Is the specifier a FITS file?
int	seq		  # i: input sequence number (if is_fits is FALSE)
char    spec[SZ_LINE]	  # i: specifier
int	i_eci		  # o: row containing specified data

### LOCAL VARS ###

bool	is_found	# Was the requested row found in the table?

### EXTERNAL FUNCTION DECLARATIONS ###

bool	find_row_by_fits() # returns TRUE if input is valid [local]
bool	find_row_by_seq()  # returns TRUE if input is valid [local]

### BEGINNING OF PROCEDURE ###

begin
	if (is_fits)
	{
	    is_found=find_row_by_fits(dataset,tp,col_ptr,p_eci_info,n_eci,
                             spec,i_eci)	
	}
	else
	{
	    is_found=find_row_by_seq(dataset,tp,col_ptr,p_eci_info,n_eci,
                                    seq,i_eci)
	}	

	return is_found
end

#--------------------------------------------------------------------------
# Procedure:    find_row_by_fits
#
# Purpose: Finds the appropriate row within the info table for this data;
#	   searches by FITS file name.
#
# Input variables:
#		dataset		which type of data (see dataset.h)
#		tp		ECI table pointer
#		col_ptr		Column pointers
#		p_eci_info	ECI table info
#		n_eci		Number of rows in ECI table
#		fitsname	FITS name to search for
#
# Output variables:
#		i_eci		which row of table is specified row?
#
# Return value: Returns TRUE if input data is valid.
#
# Description: This routine will search the ECI info table for the
# passed in FITS file.  The ECI table stores both the FITS root and
# the FITS extension, and both will have to agree for this routine to
# return a success.  (For SLEW data, however, only the FITS root needs
# to match.)
#
# Here, a FITS extension is considered to be characters 1 through 
# ECI_FITSROOT_LEN, and the extension is character 12 of the FITS name.
#
# (For example, in the FITS name "i2109s68.xpa", "i2109s68" is the
# FITS root, while "a" is the FITS extension.)
#
# The row number is returned in "i_eci".
#--------------------------------------------------------------------------

bool procedure find_row_by_fits(dataset,tp,col_ptr,p_eci_info,n_eci,
                                fitsname,i_eci)
int	dataset		  # i: dataset (e.g. ipcevt, hrievt, etc.) index
pointer tp		  # i: table pointer
pointer	col_ptr[N_COL_ECI]# i: column pointers
pointer	p_eci_info	  # i: ECI table info
int	n_eci		  # i: number of rows in table
char    fitsname[SZ_LINE] # i: FITS name
int	i_eci		  # o: row containing specified data

### LOCAL VARS ###

char    row_root[ECI_FITSROOT_LEN]  # FITS root of current row
char    row_ext[ECI_EXT_LEN]	    # FITS extension of current row
bool    is_found		    # Was match found?
bool    col_empty		    # Is the column empty?

### EXTERNAL FUNCTION DECLARATIONS ###

#bool  strncmp()  #JCC - This caused problems on LINUX.
int    strncmp()  #strncmp(s1,s2): returns negative if s1<s2, 
                  #0 if s1==s2, # and positive if s1>s2.  [sys/fmtio]
 
### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Loop through ECI rows until we find match or
	# run out of rows.
        #----------------------------------------------
	is_found=false
	i_eci=1
	while (i_eci<=n_eci && !is_found)
	{
            #--------------------------------------------------
	    # Read extension from row (unless dataset is slew)
            #--------------------------------------------------
	    if (dataset!=SLEW)
	    {
	        call tbcgtt(tp,col_ptr[ECI_EXT_COL],row_ext,col_empty,
		       ECI_EXT_LEN,i_eci,i_eci)
		if (col_empty)
		{
                    call errori(ECD_MISSING_ROWVAL,
		      "Missing FITS extension from table in row",i_eci)
		}
	    }

            #--------------------------------------------------
	    # Read FITS root from row
            #--------------------------------------------------
	    call tbcgtt(tp,col_ptr[ECI_FITSROOT_COL],row_root,col_empty,
			ECI_FITSROOT_LEN,i_eci,i_eci)
	    if (col_empty)
	    {
                call errori(ECD_MISSING_ROWVAL,
			"Missing FITSROOT from table in row",i_eci)
	    }

            #----------------------------------------------
            # Compare root & extension: if match, we are
	    # done; if not, continue to next row.
            #----------------------------------------------
	    if (strncmp(row_root,fitsname,ECI_FITSROOT_LEN)==0 &&
		    (row_ext[1]==fitsname[12] || dataset==SLEW))
	    {
		is_found=true
	    }
	    else
	    {
		i_eci=i_eci+1
	    }
	}

        #----------------------------------------------
        # Return status
        #----------------------------------------------
	if (!is_found)
	{
	    call printf("ERROR: could not find FITS file in dataset.\n");
	}

        return is_found
end

#--------------------------------------------------------------------------
# Procedure:    find_row_by_seq
#
# Purpose: Finds the appropriate row within the info table for this data;
#	   searches by sequence number.
#
# Input variables:
#		dataset		which type of data (see dataset.h)
#		tp		ECI table pointer
#		col_ptr		Column pointers
#		p_eci_info	ECI table info
#		n_eci		Number of rows in ECI table
#		seq		input sequence number (if above is false)
#
# Output variables:
#		i_eci		which row of table is specified row?
#
# Return value: Returns TRUE if input sequence is valid.
#
# Description: This routine will search the ECI info table for the
# passed in sequence number.  If a match is found, i_eci will be
# filled with the row number.
#--------------------------------------------------------------------------

bool procedure find_row_by_seq(dataset,tp,col_ptr,p_eci_info,n_eci,
			         seq,i_eci)
int	dataset		  # i: dataset (e.g. ipcevt, hrievt, etc.) index
pointer tp		  # i: table pointer
pointer	col_ptr[N_COL_ECI]# i: column pointers
pointer	p_eci_info	  # i: ECI table info
int	n_eci		  # i: number of rows in table
int	seq		  # i: input sequence number (if is_fits is FALSE)
int	i_eci		  # o: row containing specified data

### LOCAL VARS ###

bool    is_found	# Was match found?
bool    col_empty	# Is the column empty?
int	rowseq		# Sequence number of current row

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Assume that we won't find the sequence.
        #----------------------------------------------
	is_found=false

        #----------------------------------------------
        # SLEW datasets don't have sequence numbers, so
	# return an error.
        #----------------------------------------------
	if (dataset==SLEW)
	{
	    call printf("ERROR: slew data do not have sequence numbers.\n");
	}
	else
	{
            #----------------------------------------------
            # Loop through ECI rows until we find match or
	    # run out of rows.
            #----------------------------------------------
	    i_eci=1
	    while (i_eci<=n_eci && !is_found)
	    {
                #----------------------------------------------
	        # Read sequence number from current row
                #----------------------------------------------
	        call tbcgti(tp,col_ptr[ECI_SEQ_COL],rowseq,col_empty,
			i_eci,i_eci)

		if (col_empty)
		{
                    call errori(ECD_MISSING_ROWVAL,
			"Missing sequence number from table in row",i_eci)
		}

                #----------------------------------------------
		# Did we find a match?  If not, go to next row.
                #----------------------------------------------

		if (rowseq==seq)
		{
		    is_found=true
		}
		else
		{
		    i_eci=i_eci+1
		}
	    }

            #----------------------------------------------
            # report status
            #----------------------------------------------
	    if (!is_found)
	    {
		call printf("ERROR: could not find sequence %d in dataset.\n");
		 call pargi(seq)
	    }
	}

	return is_found
end

#--------------------------------------------------------------------------
# Procedure:    interpret_row
#
# Purpose: converts a row of the info table into seq/dataset/etc.
#
# Input variables:
#		p_eci		Row of ECI table to interpret
#		instid		Type of instrument (see dataset.h)
#		dataset		Dataset (see dataset.h)
#
# Output variables:
#		seq		Sequence number
#               fits_root       FITS root (e.g., "i0026n12")
#               fits_ext        FITS extension (i.e. 'a', 'b', etc.)
#               ra,dec          RA and DEC of sequence (in degrees)
#               hour            Sequence hour (e.g., "00h")
#               seq_str         Sequence, in string format (e.g., "i2060")
#               dir             Directory containing the CD with
#                                  sequence data
#               evt_off         Event time offset correction
#               livetime        Livetime of sequence
#               title           Sequence title
#
# Description:  Converts row of ECI table into variables.  See eci.h for
# a description of the ECI columns.
#
#--------------------------------------------------------------------------


procedure interpret_row(p_eci,instid,dataset,seq,fits_root,fits_ext,ra,
		dec,hour,seq_str,dir,evt_off,livetime,title)
pointer p_eci		  # i: pointer to ECI row
int	instid		  # i: instrument ID 
int	dataset		  # i: dataset index
int     seq               # o: sequence number
char    fits_root[SZ_LINE]# o: FITS root
char    fits_ext          # o: FITS extension
double  ra,dec            # o: RA & DEC of sequence
char    hour[SZ_LINE]     # o: Hour (e.g. "00h")
char    seq_str[SZ_LINE]  # o: Sequence, in string format
char    dir[SZ_PATHNAME]  # o: Directory containing CD with data
double  evt_off           # o: Event time offset correction
double  livetime          # o: Seq. livetime
char    title[SZ_LINE]    # o: Seq. title

int	cd  # CD number containing data. 

begin
        #----------------------------------------------
        # Read sequence number from row.
        #----------------------------------------------
	seq=ECI_SEQ(p_eci)

        #----------------------------------------------
        # Copy FITS root from row.
        #----------------------------------------------
	call strcpy(ECI_FITSROOT(p_eci),fits_root,ECI_FITSROOT_LEN)

        #----------------------------------------------
        # Copy FITS extension.  (For SLEW data, there
	# is no extension.)
        #----------------------------------------------
	if (dataset==SLEW)
	{
	    fits_ext=' '
	}
	else
	{
	    call strcpy(ECI_EXT(p_eci),fits_ext,1)
	}

        #-------------------------------------------------------
        # Read ra, dec, hour, title, event offset, and livetime
        #-------------------------------------------------------
	ra=ECI_RA(p_eci)
	dec=ECI_DEC(p_eci)
	call strcpy(ECI_HOUR(p_eci),hour,ECI_HOUR_LEN)	
	call strcpy(ECI_TITLE(p_eci),title,ECI_TITLE_LEN)	
	evt_off=ECI_EVTOFF(p_eci)
	livetime=ECI_LIVETIME(p_eci)

        #----------------------------------------------
        # Create sequence string from sequence number.
        #----------------------------------------------
	switch(dataset)
	{
	    case IPC_EVT,EOSCAT,IPCU:
		call sprintf(seq_str,SZ_LINE,"i%d")
		 call pargi(seq)
	    case HRI_EVT,HRI_IMG:
		call sprintf(seq_str,SZ_LINE,"h%d")
		 call pargi(seq)
	    case SLEW:
		call sprintf(seq_str,SZ_LINE,"none") # no sequence no.
		 call pargi(seq)
	    default:
	        call error(ECD_UNKNOWN_INST_ID,
		    "Unexpected instrument id")
	}

        #----------------------------------------------
        # Read cd number from row, then create pathname
	# of CD containing this data.
        #----------------------------------------------
	cd=ECI_CD(p_eci)
	call get_dir(cd,dataset,dir)
end

#--------------------------------------------------------------------------
# Procedure:    get_dir
#
# Purpose: Finds the directory containing the CDROM holding the data.
#
# Input variables:
#		cd		Which cd in set contains the data?
#		dataset		Which dataset is it?  (See dataset.h)
#
# Output variables:
#               dir             Directory containing the CD with
#                                  sequence data
#
# Description:  Read the pathname of the correct CD from the EINCDROM
# parameter set, "eincdpar".  We first contain the name of the 
# parameter by concatinating the dataset name with the CD number.
#--------------------------------------------------------------------------

procedure get_dir(cd,dataset,dir)
int	cd		# i: CD number containing data
int	dataset		# i: which dataset?
char	dir[SZ_PATHNAME]# o: pathname of directory containing CD

char	param[SZ_LINE]  # parameter name to look up in PSET
pointer	pp  		# PSET pointer

pointer clopset()       # returns PSET pointer [sys/clio]

begin
        #----------------------------------------------
        # open PSET
        #----------------------------------------------
        pp = clopset("eincdpar")

        #----------------------------------------------
        # For the appropriate dataset, create parameter
	# and read in value from PSET.  
        #----------------------------------------------
	switch(dataset)
	{
	    case IPC_EVT:
		call sprintf(param,SZ_LINE,"ipcevt%d")
		 call pargi(cd)
		call clgpseta(pp,param,dir,SZ_PATHNAME)
	    case HRI_EVT:
		call sprintf(param,SZ_LINE,"hrievt%d")
		 call pargi(cd)
		call clgpseta(pp,param,dir,SZ_PATHNAME)
	    case EOSCAT:
		call sprintf(param,SZ_LINE,"eoscat%d")
		 call pargi(cd)
		call clgpseta(pp,param,dir,SZ_PATHNAME)
		
	    case HRI_IMG:
		call sprintf(param,SZ_LINE,"hriimg%d")
		 call pargi(cd)
		call clgpseta(pp,param,dir,SZ_PATHNAME)

	    case SLEW:
		call sprintf(param,SZ_LINE,"slewcd")
		call clgpseta(pp,param,dir,SZ_PATHNAME)

	    case IPCU:
		call sprintf(param,SZ_LINE,"ipcu%d")
		 call pargi(cd)
		call clgpseta(pp,param,dir,SZ_PATHNAME)

	    default:
	        call error(ECD_UNKNOWN_TYPE,
		    "GET_DIR: Unexpected dataset")
	}

        #----------------------------------------------
        # close PSET
        #----------------------------------------------
        call clcpset(pp)
end
