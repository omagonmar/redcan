#$Log: im_tools.gx,v $
#Revision 11.0  1997/11/06 16:20:35  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:23  prosb
#General Release 2.3.1
#
#Revision 1.1  94/02/07  16:21:55  prosb
#Initial revision
#
#$Header: /home/pros/xray/lib/pros/RCS/im_tools.gx,v 11.0 1997/11/06 16:20:35 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       im_tools.gx
# Project:      PROS -- LIBRARY
# External:     im_sum_(silrd),im_cumul_(silrd),im_zero_silrd)
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 2/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <imhdr.h>
include <ercode.h>

#--------------------------------------------------------------------------
# Procedure:    im_sum_(silrd)
#
# Purpose:      To perform a weighted sum of two images
#
# Input variables:
#               ip_1            first input image
#               weight1         weight to apply to first image
#               ip_2            second input image
#               weight1         weight to apply to second image
#
# Output variables:
#               ip_sum          output image
#
# Description:  This routine creates a final image which is the
#		weighted sum of the input images:
#
#		     ip_sum = weight1*ip_1 + weight2*ip_2
#
#		The weights must be the same type as the image pixel
#		type.  The output image must already be created.
#		A sample use of this function would be to simply
#		add two real images ip_A and ip_B:
#
#	           ip_sum=immap(sum_image_name,NEW_COPY, ip_A)
#		   call im_sum_r(ip_A,1.0,ip_B,1.0,ip_sum)
#
#		(See also im_sum_gen for a generic calling routine.)
#
# Algorithm:    * check for illegal images
#               * set up position vectors
#		* set "ignore" flags if weights are 1.0
#		* For each line of the first image, do the following
#		   * Read in the line from the first & second images
#		   * Multiply the lines by the weights (if appropriate)
#		   * Add the lines together and write to output image
#
# Notes:        It seems that this routine works fine if some of the
#		input images are the same file -- i.e., if ip_2==ip_sum,
#		for instance.  This is not, however, guaranteed to work.
#--------------------------------------------------------------------------

  
procedure im_sum_l(ip_1,weight1,ip_2,weight2,ip_sum)
pointer ip_1	# i: first input image
long	weight1 # i: weight for first image
pointer ip_2    # i: second input image
long	weight2 # i: weight for second image
pointer ip_sum  # o: output image

### LOCAL VARS ###

bool	ignore_weight1	# should we ignore weight1 because it is 1.0?
bool	ignore_weight2  # should we ignore weight2 because it is 1.0?
pointer p_1row		# pointer to data in row from first image
pointer p_2row		# pointer to data in row from second image
pointer p_sumrow	# pointer to data in row from output image
int     row_length	# length of rows in images
long    v1[IM_MAXDIM]	# position vector for first image
long	v2[IM_MAXDIM]	# position vector for second image
long	vsum[IM_MAXDIM]	# position vector for final summed image

### EXTERNAL FUNCTION DECLARATIONS ###

pointer imgnll()	# returns pointer to input image data [sys/imio]
pointer impnll()	# returns pointer to output image data [sys/imio]
bool    fp_equald()	# returns true if doubles are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # Check if images have the same size.
        #----------------------------------------------
        row_length=IM_LEN(ip_1,1)
        if (row_length != IM_LEN(ip_2,1))
        {
           call error(PROS_WRONG_DIMENSION,"Adding images of unequal dimension")
        }

        #----------------------------------------------
        # Check if images have the same pixel type
        #----------------------------------------------
	if (IM_PIXTYPE(ip_1)!=IM_PIXTYPE(ip_2) ||
	    IM_PIXTYPE(ip_1)!=IM_PIXTYPE(ip_sum))
	{
           call error(PROS_WRONG_PIXTYPE,"Adding images of different pixtypes")
	}

        #----------------------------------------------
        # Initialize position vectors
        #----------------------------------------------
        call amovkl(long(1),v1,IM_MAXDIM)
        call amovkl(long(1),v2,IM_MAXDIM)
        call amovkl(long(1),vsum,IM_MAXDIM)

        #----------------------------------------------
        # Set "ignore" flags
        #----------------------------------------------
	ignore_weight1=fp_equald(double(weight1),1.0D0)
	ignore_weight2=fp_equald(double(weight2),1.0D0)

        #---------------------------------------------------
        # Loop over rows of first image.  
	# Assign p_1row to be pointer to row of first image.
        #---------------------------------------------------
        while (imgnll(ip_1,p_1row,v1)!=EOF)
        {
           #---------------------------------------------------
           # Get pointer to row of second image
           #---------------------------------------------------
           if (imgnll(ip_2,p_2row,v2)==EOF)
           {
              call error(PROS_WRONG_SIZE,
		"Second image has fewer rows than first image.")
           }

           #---------------------------------------------------
           # Get pointer to row of output image.
	   # (Note that impnl$t does not actually "put" any
	   #  data, but just points us to where the data
	   #  should go.)
           #---------------------------------------------------
           if (impnll(ip_sum,p_sumrow,vsum)==EOF)
           {
              call error(PROS_UNEXPECTED_EOF,
			"EOF reached on writing output image.")
           }

           #---------------------------------------------------
           # Multiply row from first image by weight1
           #---------------------------------------------------
            if (!ignore_weight1)
           {
              call amulkl(Meml[p_1row],weight1,Meml[p_1row],row_length)
           }

           #---------------------------------------------------
           # Multiply row from second image by weight2
           #---------------------------------------------------
           if (!ignore_weight2)
           {
             call amulkl(Meml[p_2row],weight2,Meml[p_2row],row_length)
           }

           #---------------------------------------------------
           # Add weighted rows to row from output image
           #---------------------------------------------------
           call aaddl(Meml[p_1row],Meml[p_2row],Meml[p_sumrow],row_length)
        }

        #----------------------------------------------
        # Check if second image was too long
        #----------------------------------------------
        if (imgnll(ip_2,p_2row,v2)!=EOF)
        {
              call error(PROS_WRONG_SIZE,
			"Second image has more rows than first image.")
        }
end


#--------------------------------------------------------------------------
# Procedure:    im_cumul_(silrd)
#
# Purpose:      To help perform a cumulative sum of images
#
# Input variables:
#               ip_1            first image
#
# Input and Output variables:
#               ip_sum          output image
#
# Description:  This routine creates a final image which is the
#		sum of the first and final images:
#
#		     ip_sum = ip_sum + ip_1
#
#		This routine can then be used to find the cumulative
#		sum of a series of images.
#
# Algorithm:    * check for illegal images
#               * set aside stack space
#		* set up position vectors
#		* For each line of the first image, do the following
#		   * Read in the line from the first & final images
#		   * Add the lines together 
#		   * Write the sum to output image
#
#--------------------------------------------------------------------------

procedure im_cumul_l(ip_1,ip_sum)
pointer ip_1	# i: input image
pointer ip_sum	# io: final summed image

### LOCAL VARS ###

pointer p_1row			# pointer to data in row from first image
pointer p_sumrow		# pointer to data in row from output image
pointer p_temprow		# pointer to temporary data buffer
int     row_length		# length of rows in images
pointer sp			# stack pointer
long    v1[IM_MAXDIM]		# position vector for first image
long	vsum_in[IM_MAXDIM]	# position vector for final image when
				#   being read from
long	vsum_out[IM_MAXDIM]	# position vector for final image when
				#   being written out to

### EXTERNAL FUNCTION DECLARATIONS ###

pointer imgnll()	# returns pointer to input image data [sys/imio]
pointer impnll()	# returns pointer to output image data [sys/imio]

begin
        #----------------------------------------------
        # Check if images have the same size.
        #----------------------------------------------
        row_length=IM_LEN(ip_1,1)
        if (row_length != IM_LEN(ip_sum,1))
        {
           call error(PROS_WRONG_DIMENSION,"Adding images of unequal dimension")
        }
 
        #----------------------------------------------
        # Check if images have the same pixel type
        #----------------------------------------------
	if (IM_PIXTYPE(ip_1)!=IM_PIXTYPE(ip_sum))
	{
           call error(PROS_WRONG_PIXTYPE,"Adding images of different pixtypes")
	}

        #----------------------------------------------
        # Set aside memory for temporary row space
        #----------------------------------------------
	call smark(sp)
	call salloc(p_temprow,row_length,IM_PIXTYPE(ip_1))

        #----------------------------------------------
        # Initialize position vectors
        #----------------------------------------------
        call amovkl(long(1),v1,IM_MAXDIM)
        call amovkl(long(1),vsum_in,IM_MAXDIM)
        call amovkl(long(1),vsum_out,IM_MAXDIM)

        #---------------------------------------------------
        # Loop over rows of first image.  
	# Assign p_1row to be pointer to row of first image.
        #---------------------------------------------------
        while (imgnll(ip_1,p_1row,v1)!=EOF)
        {
           #-----------------------------------------------------
           # Get pointer to row of final image (to be read from)
           #-----------------------------------------------------
           if (imgnll(ip_sum,p_sumrow,vsum_in)==EOF)
           {
              call error(PROS_WRONG_SIZE,
		"Cumulative image has fewer rows than first image.")
           }

           #---------------------------------------------------
           # Add rows into temporary buffer
           #---------------------------------------------------
           call aaddl(Meml[p_1row],Meml[p_sumrow],
					Meml[p_temprow],row_length)

           #-----------------------------------------------------
           # Get pointer to row of final image (to be written to)
           #-----------------------------------------------------
           if (impnll(ip_sum,p_sumrow,vsum_out)==EOF)
           {
              call error(PROS_UNEXPECTED_EOF,
			"EOF reached on writing output image.")
           }
	   
           #---------------------------------------------------
           # Copy temporary buffer into final row
           #---------------------------------------------------
	   call amovl(Meml[p_temprow],Meml[p_sumrow],row_length)
	}

        #----------------------------------------------
        # Check if final image was too long
        #----------------------------------------------
        if (imgnll(ip_sum,p_sumrow,vsum_in)!=EOF)
        {
              call error(PROS_WRONG_SIZE,
			"Cumulative image has more rows than first image.")
        }

        #----------------------------------------------
        # Free stack space
        #----------------------------------------------
	call sfree(sp)
end


#--------------------------------------------------------------------------
# Procedure:    im_zero_(silrd)
#
# Purpose:      Clear out an image.
#
# Input and Output variables:
#               ip              image
#
# Description:  This routine assigns zero to all of the pixels in the
#		image.
#
#--------------------------------------------------------------------------

procedure im_zero_l(ip)
pointer ip		# io: image pointer

### LOCAL VARS ###

pointer p_row		# pointer to data in row from first image
int     row_length      # length of rows in images
long	v[IM_MAXDIM]	# position vector for image

### EXTERNAL FUNCTION DECLARATIONS ###

pointer impnll()       # returns pointer to output image data [sys/imio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Find length of rows in image
        #----------------------------------------------
        row_length=IM_LEN(ip,1)

        #----------------------------------------------
        # Initialize position vectors
        #----------------------------------------------
        call amovkl(long(1),v,IM_MAXDIM)

        #---------------------------------------------------
        # Loop over rows of image.  
        # Assign p_row to be pointer to row of image.
        #---------------------------------------------------
        while (impnll(ip,p_row,v)!=EOF)
        {
           #---------------------------------------------------
           # Clear the values in the row.
           #---------------------------------------------------
           call aclrl(Meml[p_row],row_length)
        }
end     

