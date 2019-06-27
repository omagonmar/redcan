#$Log: im_tools_gen.x,v $
#Revision 11.0  1997/11/06 16:20:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:25  prosb
#General Release 2.3.1
#
#Revision 1.1  94/02/07  16:21:33  prosb
#Initial revision
#
#$Header: /home/pros/xray/lib/pros/RCS/im_tools_gen.x,v 11.0 1997/11/06 16:20:36 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       im_sum_gen.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     im_sum_gen,im_cumul_gen,im_zero_gen
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 9/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
# call generic im_sum routines
include <imhdr.h>
include <ercode.h>

#--------------------------------------------------------------------------
# Procedure:    im_sum_gen
#
# Purpose:      To perform a weighted sum of two generic images
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
#		Unlike the specific im_sum_* routines, the
#		programmer does not have to specify the image pixel
#		type.  This routine finds the pixel type and calls
#		the appropriate im_sum_* routine.  This routine
#		expects the input weights to be of type "double" --
#		they are converted to the appropriate type when
#		calling im_sum_*.  (If the image is an integral type,
#		the weights will be rounded to their nearest integer.)
#		
#		As in im_sum_*, the output image must already be
#		created.  A sample calling routine would be:
#
#                  ip_sum=immap(sum_image_name,NEW_COPY, ip_A)
#                  call im_sum_gen(ip_A,1.0D0,ip_B,1.0D0,ip_sum)
#
#--------------------------------------------------------------------------

procedure im_sum_gen(ip_1,weight1,ip_2,weight2,ip_sum)
pointer ip_1    # i: first input image
double	weight1 # i: weight for first image
pointer ip_2    # i: second input image
double	weight2 # i: weight for second image
pointer ip_sum  # o: output image

### LOCAL VARS ###

long	l_w1    # temporary "long" copy of weight 1
long	l_w2    # temporary "long" copy of weight 2
short   s_w1    # temporary "short" copy of weight 1
short	s_w2    # temporary "short" copy of weight 2

#real	real()

begin
        #-------------------------------------------------
        # Switch on pixel type of image.
	# (If other images have different pixel types, the
	#  im_sum_* routine will catch this as an error.)
        #-------------------------------------------------
	switch(IM_PIXTYPE(ip_1))
	{
	   case TY_SHORT:
           	#---------------------------------------------------
           	# Note: intrinsic function "short" gets replaced by 
		# "int", so we must use a temporary variable.
           	#---------------------------------------------------
		s_w1=nint(weight1)
		s_w2=nint(weight2)
		call im_sum_s(ip_1,s_w1,ip_2,s_w2,ip_sum)
	   case TY_INT:
		call im_sum_i(ip_1,nint(weight1),ip_2,nint(weight2),ip_sum)
	   case TY_LONG:
           	#---------------------------------------------------
           	# Note: intrinsic function "long" gets replaced by 
		# "int", so we must use a temporary variable.
           	#---------------------------------------------------
		l_w1=nint(weight1)
		l_w2=nint(weight2)
		call im_sum_l(ip_1,l_w1,ip_2,l_w2,ip_sum)
	   case TY_REAL:
		call im_sum_r(ip_1,real(weight1),ip_2,real(weight2),ip_sum)
	   case TY_DOUBLE:
		call im_sum_d(ip_1,weight1,ip_2,weight2,ip_sum)
	   default:
	        call errori(PROS_UNKNOWN_TYPE,"IM_SUM_GEN: unknown pixtype",
			IM_PIXTYPE(ip_1))
	}

end

#--------------------------------------------------------------------------
# Procedure:    im_cumul_gen
#
# Purpose:      To help perform a cumulative sum of generic images
#
# Input variables:
#               ip_1            first image
#
# Input and Output variables:
#               ip_sum          output image
#
# Description:  This routine creates a final image which is the
#               sum of the first and final images:
#
#                    ip_sum = ip_sum + ip_1
#
#               This routine can then be used to find the cumulative
#               sum of a series of images.  This routine differs from
#		im_cumul_* by being callable generically -- this routine
#		finds the pixel type and calls the appropriate im_cumul_* 
#		routine. 
#--------------------------------------------------------------------------

procedure im_cumul_gen(ip_1,ip_sum)
pointer ip_1    # i: input image
pointer ip_sum  # io: final summed image

### EXTERNAL FUNCTION DECLARATIONS ###

begin
        #-------------------------------------------------
        # Switch on pixel type of image.
	# (If ip_sum has a different pixel type, the
	#  im_cumul_* routine will catch this as an error.)
        #-------------------------------------------------
	switch(IM_PIXTYPE(ip_1))
	{
	   case TY_SHORT:
		call im_cumul_s(ip_1,ip_sum)
	   case TY_INT:
		call im_cumul_i(ip_1,ip_sum)
	   case TY_LONG:
		call im_cumul_l(ip_1,ip_sum)
	   case TY_REAL:
		call im_cumul_r(ip_1,ip_sum)
	   case TY_DOUBLE:
		call im_cumul_d(ip_1,ip_sum)
	   default:
	        call errori(PROS_UNKNOWN_TYPE,"IM_CUMUL_GEN: unknown pixtype",
			IM_PIXTYPE(ip_1))
	}

end


#--------------------------------------------------------------------------
# Procedure:    im_zero_gen
#
# Purpose:      To clear out a generic image.
#
# Input and Output variables:
#               ip              image
#
# Description:  This routine assigns zero to all of the pixels in the
#               image.  This routine differs from im_zero_* in that
#		the programmer does not need to know the pixel type of
#		the image.  This routine finds the pixel type and calls
#		the appropriate im_zero_* routine. 
#--------------------------------------------------------------------------

procedure im_zero_gen(ip)
pointer ip      # io: image

### BEGINNING OF PROCEDURE ###

begin
        #-------------------------------------------------
        # Switch on pixel type of image.
        #-------------------------------------------------
	switch(IM_PIXTYPE(ip))
	{
	   case TY_SHORT:
		call im_zero_s(ip)
	   case TY_INT:
		call im_zero_i(ip)
	   case TY_LONG:
		call im_zero_l(ip)
	   case TY_REAL:
		call im_zero_r(ip)
	   case TY_DOUBLE:
		call im_zero_d(ip)
	   default:
	        call errori(PROS_UNKNOWN_TYPE,"IM_ZERO_GEN: unknown pixtype",
			IM_PIXTYPE(ip))
	}
end
