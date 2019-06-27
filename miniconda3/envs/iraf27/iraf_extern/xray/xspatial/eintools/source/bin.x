# $Header: /home/pros/xray/xspatial/eintools/source/RCS/bin.x,v 11.0 1997/11/06 16:31:31 prosb Exp $
# $Log: bin.x,v $
# Revision 11.0  1997/11/06 16:31:31  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:49:39  prosb
# General Release 2.4
#
#Revision 1.1  1994/03/15  09:13:00  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       bin.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     bin_data
# Local:        mk_cur_bin,match_cur_bin,mk_new_bin
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include "et_err.h"
include "array.h"

#--------------------------------------------------------------------------
# Procedure:    bin_data
#
# Purpose:      To bin data according to passed in resolution.
#
# Input variables:
#               n_dim		number of dimensions in each data group
#               n_data		number of data groups
#               data		2-dimensional array of data
#		resolution	resolution of output bins
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               n_bin		number of output bins
#               p_bin_table	pointer to output bins
#		p_data2bin	pointer to index between data and bins
#
# Description:  Each data group can be considered as a point in
#		N-dimensional space, where N="n_dim".  The "resolution"
#		variable describes the length of the sides of an N-cube. 
#		This routine determines how the input data (points) fall
#		into these N-cubes. The output bin values are the center
#		points of these N-cubes. 
#		
#		This is best illustrated by an example.  Let n_dim=2 and
#		resolution=(3.0,0.25).  The N-cubes are aligned with the
#		"[0,0]th" cube centered around the origin.  In our
#		example, this center cube would have boundary points:
#
#                (-1.5, 0.125)  --------- (1.5, 0.125)
#				|   +   |
#		 (-1.5,-0.125)	--------- (1.5,-0.125)
#
#		The "[1,0]th" cube would be centered about (3.0,0.0),
#		etc.  The following data points would fall into the
#		following cubes, and would have the following bin values:
#
#		    DATA             CUBE             FINAL BIN VALUE
#		  (2.0,-0.55)	    [1,-2]th            (3.0,-0.50)
#		  (3.5,-0.44)       [1,-2]th            (3.0,-0.50)
#		  (4.3,-0.33)       [1,-1]th            (3.0,-0.25)
#		  (4.6,-0.11)       [2,0]th             (6.0,0.0)
# 		  (5.8,0.04)	    [2,0]th		(6.0,0.0)
#		  (-11.0,4.4)	    [-4,18]th		(-12.0,4.5)
#
#		(If a data point lies exactly on a cube boundary, then
#		 it might fall into either cube, depending on floating
#		 point inaccuracies, etc.)
#
#		If a resolution value in a particular dimension is 0.0,
#		then the only way for two data points to fall into the
#		same bin is for them to match in that dimension.
#
#		This routine outputs the number of bins needed to describe
#		the input data, and the values of each bin.  The output
# 		map "data2bin" gives the bin index for each data group.
#
# Algorithm:    * check for illegal resolutions
#               * allocate memory for bins and index
#		* for each data element,
#		  * find bin value of the data element
#		  * check if bin value matches any previous bin value
#		  * if so, update data2bin index
#		  * if not, add new bin 
#
# Notes:        Currently, this routine only accepts data and resolutions
#		of type "double". Perhaps
#		sometime in the future it might accept a "data_type"
#		parameter which describes the data type of each dimension.
#
#--------------------------------------------------------------------------

define BIN_MEM_BATCH 50

procedure bin_data(n_dim, n_data, data, resolution, n_bin, 
			p_bin_table, p_data2bin, display)
int 	n_dim		    # i: dimension of data
int 	n_data		    # i: number of data gruops
double 	data[n_dim,n_data]  # i: input data
double 	resolution[n_dim]   # i: resolution requested
int 	n_bin		    # o: number of output bins
pointer p_bin_table         # o: output bin values
pointer p_data2bin          # o: index between data and bin
int 	display             # i: display level

### LOCAL VARS ###

int 	i_dim		# dimension index
int 	m_bin		# maximum number of bins 
int 	i_bin		# bin index
int 	i_data		# data index
pointer p_cur_bin	# pointer to current bin

### EXTERNAL FUNCTION DECLARATIONS ###

bool 	match_bin()	# returns true if bin matched [local]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # check for illegal resolutions
        #----------------------------------------------
	do i_dim=1,n_dim
	{
	    if (resolution[i_dim]<0.0)
            {
	   	call error(ET_BAD_RESOLUTION,
		      "Resolution must be non-negative.")
	    }
    	}

        #----------------------------------------------
        # allocate memory for bins and index
        #----------------------------------------------
    	m_bin=BIN_MEM_BATCH
    	call malloc (p_bin_table, m_bin*n_dim, TY_DOUBLE)
    	call malloc (p_data2bin, n_data, TY_INT)
    	call malloc (p_cur_bin, n_dim, TY_DOUBLE)

        #----------------------------------------------
        # Initialize number of bins to zero
        #----------------------------------------------
    	n_bin=0

        #----------------------------------------------
        # Loop over data elements
        #----------------------------------------------
    	do i_data=1,n_data
    	{
            #----------------------------------------------
            # Make current bin from current data element
            #----------------------------------------------
	    call mk_cur_bin(n_dim, resolution, data[1,i_data],
				Memd[p_cur_bin], display)

            #----------------------------------------------
            # Check if current bin matches previous bin
            #----------------------------------------------
	    if (match_bin(n_dim,Memd[p_cur_bin],n_bin,Memd[p_bin_table],i_bin))
	    {
            	#----------------------------------------------
            	# Update data2bin index
            	#----------------------------------------------
	    	ARRELE_I(p_data2bin,i_data)=i_bin

	    	if (display>4)
	    	{
		   call printf("Added data to bin %d.\n")
		    call pargi(i_bin)
	    	}
	    }
	    else # current bin does not match previous bin
	    {
            	#----------------------------------------------
            	# Make new bin
            	#----------------------------------------------
	   	call mk_new_bin(n_bin,n_dim,Memd[p_cur_bin],m_bin,p_bin_table)

            	#----------------------------------------------
            	# Update data2bin index
            	#----------------------------------------------
	    	ARRELE_I(p_data2bin,i_data)=n_bin

	   	if (display>4)
	   	{
		    call printf("Created bin %d.\n")	
		     call pargi(n_bin)
	   	}
	    }
    	}

        #----------------------------------------------
        # Free memory
        #----------------------------------------------
    	call mfree(p_cur_bin, TY_DOUBLE)
end

#--------------------------------------------------------------------------
# Procedure:    mk_cur_bin
#
# Purpose:      To create the current test bin from input data
#
# Input variables:
#               n_dim		number of dimensions in each data group
#		resolution	resolution of output bins
#               cur_data	current data group
#               display         text display level (0=none, 5=full)
#
# Output variables:
#               cur_bin		bin containing input data
#
# Description:  This routine uses the input resolution to calculate
#		the center of the N-cube which contains the input
#		data point.
#
#--------------------------------------------------------------------------

procedure mk_cur_bin(n_dim, resolution, cur_data, cur_bin, display)
int 	n_dim		   # i: dimension of data
double 	resolution[n_dim]  # i: resolution requested
double 	cur_data[n_dim]    # i: input data (current group)
double 	cur_bin[n_dim]     # o: bin which data falls into
int 	display            # i: display level

### LOCAL VARS ###

int 	i_dim		   # dimension index 

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equald()	   # returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # Loop over the dimensions
        #----------------------------------------------
   	do i_dim=1,n_dim
   	{
            #-------------------------------------------------
            # If resolution is zero, no binning is necessary
            #-------------------------------------------------
	    if (fp_equald(resolution[i_dim],0.0D0))
      	    {
 	   	cur_bin[i_dim]=cur_data[i_dim]
      	    }
      	    else
      	    {
                #-------------------------------------------------
                # Find center of this side of N-cube.
            	#-------------------------------------------------
	   	cur_bin[i_dim]=
		   anint(cur_data[i_dim]/resolution[i_dim])*resolution[i_dim]
      	    }

            if (display>4)
      	    {
		call printf("cur_bin[%d]:%f->%f  ")
	 	 call pargi(i_dim)
	 	 call pargd(cur_data[i_dim])
	 	 call pargd(cur_bin[i_dim])
      	    }

   	}

   	if (display>4)
   	{
      	    call printf("\n")
      	    call flush(STDOUT)
   	}
end

#--------------------------------------------------------------------------
# Procedure:    match_bin
#
# Purpose:      To test if current bin matches a previous bin
#
# Input variables:
#               n_dim		number of dimensions in each data group
#               cur_bin		bin containing input data to test
#               n_bin		number of bins created so far
#		bin_table	contents of current bins
#               cur_data	current data group
#               display         text display level (0=none, 5=full)
#
# Output variables:
#		i_bin		index of matching bin (if found)
#
# Return value: Returns true if a match was found.
#
# Description:  This routine loops through the previously created
#		bins until it finds a bin which matches the input
#		bin.  If a match is found, "i_bin" will contain the
#		index of the matching bin and the routine returns true.
#  		If no match is found, this routine returns false.
#
#--------------------------------------------------------------------------

bool procedure match_bin(n_dim,cur_bin,n_bin,bin_table,i_bin)
int 	n_dim		   	# i: dimension of data
double 	cur_bin[n_dim]		# i: bin containing input data to test
int 	n_bin			# i: number of bins created so far
double 	bin_table[n_dim,n_bin]  # i: contents of current bins
int 	i_bin			# o: index of matching bin (if found)

### LOCAL VARS ###

int 	i_dim		   # dimension index 
bool 	is_match	   # true if match has been found

### EXTERNAL FUNCTION DECLARATIONS ###

bool	fp_equald()	   # returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin

        #-------------------------------------------------
        # Loop over each bin.  Assume no match at first.
	# Stop looping if we find a match.
        #-------------------------------------------------
   	is_match=false
   	for (i_bin=1; !(is_match) && i_bin<=n_bin; i_bin=i_bin+1)
   	{	
            #----------------------------------------------
            # Loop over each dimension.  Assume that each
	    # dimension matches so far.  Stop looping if
	    # we find a dimension which doesn't match.
            #----------------------------------------------
      	    is_match=true
      	    for (i_dim=1; (is_match) && i_dim<=n_dim; i_dim=i_dim+1)
      	    {
         	is_match=fp_equald(bin_table[i_dim,i_bin],cur_bin[i_dim])
      	    }
   	}

        #-----------------------------------------------------
        # The "for" loop counter will increment i_bin before
	# testing the condition.  Thus if we found a match,
	# the i_bin counter will be set to the next bin.  We
	# must therefore decrement our index counter.
        #-----------------------------------------------------
   	i_bin=i_bin-1

        #-------------------------------------------------
        # Return true if we found a match.
        #-------------------------------------------------
   	return is_match
end

#--------------------------------------------------------------------------
# Procedure:    mk_new_bin
#
# Purpose:      To create a new bin in the bin table.
#
# Input variables:
#               n_bin		number of bins created so far
#               n_dim		number of dimensions in each data group
#               cur_bin		bin to add to table
#
# Input & Output variables:
#               m_bin		number of bins we have memory set
#				   aside for
#		p_bin_table	pointer to bin table
#
# Description:  This routine adds the current bin to the bin table,
#		setting aside extra memory if we have surpassed our
#		current maximum.
#
#--------------------------------------------------------------------------
procedure mk_new_bin(n_bin,n_dim,cur_bin,m_bin,p_bin_table)
int 	n_bin		# i: number of output bins
int 	n_dim		# i: dimension of data
double 	cur_bin[n_dim]  # i: current bin to add to bin table
int	m_bin		# io: maximum number of bins
pointer p_bin_table	# io: bin table

### LOCAL VARS ###

int 	i_dim		# dimension index
pointer c_bin_table	# current pointer to bin table

### BEGINNING OF PROCEDURE ###

begin
        #-------------------------------------------------
        # Increment number of bins.
        #-------------------------------------------------
	n_bin=n_bin+1

        #-------------------------------------------------
        # Set aside more memory, if needed.
        #-------------------------------------------------
	if (n_bin>m_bin)
	{
	    m_bin=m_bin+BIN_MEM_BATCH
	    call realloc(p_bin_table, m_bin*n_dim, TY_DOUBLE)
	}

        #-------------------------------------------------
        # Fill latest bin with current bin data.
	# (Set c_bin_table to be the "n_bin"th bin group,
	#  i.e., a pointer to the latest bin.)
        #-------------------------------------------------
	c_bin_table=p_bin_table+(n_bin-1)*n_dim
    	do i_dim=1,n_dim
	{
	    ARRELE_D[c_bin_table,i_dim]=cur_bin[i_dim]
	}
end
