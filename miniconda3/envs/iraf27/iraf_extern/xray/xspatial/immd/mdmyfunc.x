#$Header: /home/pros/xray/xspatial/immd/RCS/mdmyfunc.x,v 11.3 2000/01/04 22:28:58 prosb Exp $
#$Log: mdmyfunc.x,v $
#Revision 11.3  2000/01/04 22:28:58  prosb
# copy from pros_2.5 (or pros_2.5_p1)
#
#Revision 9.0  1995/11/16  18:52:32  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:15:22  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:36:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:20:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:34:31  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:42:21  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:28:14  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:17:01  pros
#General Release 1.0
#
#
# Module:	MDMYFUNC.X
# Project:	PROS -- ROSAT RSDC
# Purpose:	Dummy routine to resolve link when user routine is not linked
# External:	mymodel(), mykmodel()
# Local:
# Description:	
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} M.VanHilst	5 Dec 1988 	initial version
#		{n} <who> -- <when> -- <does what>
#
# Archive header
#


include <error.h>


#
# Function:	my_model
# Purpose:	perform user function to add data to a model
# Parameters:	See argument declarations
# Returns:	
# Uses:		
# Pre-cond:
# Post-cond:	data from file is added to existing data in buffer
# Exceptions:
# Method:	No data is added if this is the linked procedure
# Notes:
procedure my_model (buf, width, height, xcen, ycen, radius, power, val, cmplx)

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of function
real	radius		# i: base radius of power function
real	power		# i: power to raise
real	val		# i: value by which to multiply function
int	cmplx		# i: fill real part of array of complex elements

begin
	call error(EA_ERROR, "Your my_model routine has not been linked\n")
end


#
# Function:	my_kmodel
# Purpose:	perform user function to add data to a model in fft k space
# Parameters:	See argument declarations
# Returns:	
# Uses:		
# Pre-cond:
# Post-cond:	data from file is added to existing data in buffer
# Exceptions:
# Method:	No data is added if this is the linked procedure
# Notes:
procedure my_kmodel (buf, width, height, xcen, ycen, radius, power, val, cmplx)

real	buf[ARB]	# i: image buffer
int	width, height	# i: image dimensions
real	xcen, ycen	# i: center of function
real	radius		# i: base radius of power function
real	power		# i: power to raise
real	val		# i: value by which to multiply function
int	cmplx		# i: fill real part of array of complex elements

begin
	call error(EA_ERROR, "Your my_kmodel routine has not been linked\n")
end
