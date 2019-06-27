# $Header: /home/pros/xray/lib/pros/RCS/collapse.gx,v 11.0 1997/11/06 16:20:17 prosb Exp $
# $Log: collapse.gx,v $
# Revision 11.0  1997/11/06 16:20:17  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:27:18  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:08:53  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:58  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:53  prosb
#General Release 1.1
#
#Revision 1.3  91/07/30  20:43:52  mo
#MC	7/30/91		Fix the Header and Log for RCS
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#------------------------------------------------------------------------
# COLLAPSE -> horizontally sum an input line over the summing interval
#------------------------------------------------------------------------

procedure collapses(inbuf, outbuf, factor, pixels )

# Input/Ouput Variables

short inbuf[ARB]			# input line for summing
short outbuf[ARB]			# output horizontally summed line

int  factor				# compress factor
int  pixels				# number of pixels in input line

# Local Variables

int  i, j				# array pointers

begin

	j = 1
#        pixels = factor*resolution

# Scan line over each summing interval

	for (i=1; i<=pixels; i=i+1)
	{
	   outbuf[j] = outbuf[j] + inbuf[i]

           if ( mod(i,factor) == 0 )
	      j = j + 1
	}

end
