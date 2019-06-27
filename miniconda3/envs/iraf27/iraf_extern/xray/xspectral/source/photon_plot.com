#$Header: /home/pros/xray/xspectral/source/RCS/photon_plot.com,v 11.0 1997/11/06 16:43:03 prosb Exp $
#$Log: photon_plot.com,v $
#Revision 11.0  1997/11/06 16:43:03  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:04  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:02  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:47  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:13  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/06  15:11:42  jmoran
#JMORAN
#no changes
#
#Revision 3.0  91/08/02  01:58:53  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:06:25  pros
#General Release 1.0
#
#
#  photon_plot.com -- common block for photon plot
#
int	c_label			# label axes?
int	c_mode			# plotting mode
pointer	c_title			# plot title
pointer	c_xtitle		# x axis title
pointer	c_ytitle		# y axis title

common/cplotcom/c_label, c_mode, c_title, c_xtitle, c_ytitle
