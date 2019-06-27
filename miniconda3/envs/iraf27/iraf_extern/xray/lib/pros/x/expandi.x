# $Header: /home/pros/xray/lib/pros/RCS/expand.gx,v 11.0 1997/11/06 16:20:23 prosb Exp $
# $Log: expand.gx,v $
# Revision 11.0  1997/11/06 16:20:23  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:28  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:48  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:29  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:30  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:58  prosb
#General Release 1.1
#
#Revision 1.3  91/07/30  20:45:41  mo
#MC	7/30/91		Update the RCS log and header
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#------------------------------------------------------------------------
# EXPAND - expand 1 row by replicating data 
#------------------------------------------------------------------------

procedure expandi(iline, oline, pixels, factor)

# Input/Ouput Variables

int iline[ARB]			# input line 
int oline[ARB]			# output line
int  pixels 				# number of pixels in input line
int  factor				# replication factor

# Local Variables

int  l  				# array pointers
int  num_out                            # data value replication tally
int  rptr  				# pointer to out buf
					
begin

	rptr = 0

        for (l=1; l<=pixels; l=l+1)     # iter over elements in row
        {
           num_out = 0
	   while ( num_out < factor )   # replicate element factor many times
	   {
	     rptr = rptr + 1            # incr output buffer pointer
             oline[rptr] = iline[l]     # copy data
	     num_out = num_out + 1      
	   }
	}

end
