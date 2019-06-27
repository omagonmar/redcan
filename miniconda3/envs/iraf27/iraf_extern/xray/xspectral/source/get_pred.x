#$Header: /home/pros/xray/xspectral/source/RCS/get_pred.x,v 11.0 1997/11/06 16:42:14 prosb Exp $
#$Log: get_pred.x,v $
#Revision 11.0  1997/11/06 16:42:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:40  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:24  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:00  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:19  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:03:25  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  GET_PRED   ---   retrieves the spectrum and its associated errors

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----
#
procedure  get_pred (fd, predicted, nbins)

int     nbins					# number of bins (PHAS)
int     bin					# PHA index
int	fd					# file descriptor
real	predicted[ARB]				# predicted spectrum

int	fscan()

begin
	call aclrr ( predicted, nbins)			# clear the array
	bin = 0
	while( bin < nbins )  {
	    bin = bin+1
	    if( fscan (fd) != EOF )  {
		call gargr (predicted[bin])
		}
	    }
end
