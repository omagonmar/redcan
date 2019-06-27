#$Header: /home/pros/xray/xproto/qpcalc/RCS/qpcalc.com,v 11.0 1997/11/06 16:38:55 prosb Exp $
#$Log: qpcalc.com,v $
#Revision 11.0  1997/11/06 16:38:55  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:26:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:26:03  prosb
#General Release 2.3.1
#
#Revision 7.1  94/03/25  12:37:08  mo
#MC	remove unneeded common variables
#

pointer	evc		# pointer to output event buffer
int	nevc		# number of events in buffer
int	evlen		# length of event record
double	nullval
common	/evvar/	nullval,evc,nevc,evlen

