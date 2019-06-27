#$Header: /home/pros/xray/xtiming/timplot/RCS/timplot.h,v 11.0 1997/11/06 16:44:51 prosb Exp $
#$Log: timplot.h,v $
#Revision 11.0  1997/11/06 16:44:51  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:34:21  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:41:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:02:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:58:10  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:32:43  janet
#updated binlen to a double.
#
#Revision 5.0  92/10/29  22:49:42  prosb
#General Release 2.1
#
#Revision 4.0  92/06/26  14:23:05  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/06/17  11:24:47  janet
#added XOFFSET, XAUTO, PTYPE to structure for enhanced plot capabilities.
#
#Revision 3.0  91/08/02  02:02:42  prosb
#General Release 1.1
#
#Revision 2.1  91/08/01  22:13:34  mo
#no change
#
#Revision 2.0  91/03/06  22:51:43  prosb
#General Release 1.0
#
#  ---------------------------------------------------------------
#
# Module:	TIMPLT.H
# Project:	PROS -- ROSAT RSDC
# Purpose:	Parameter, Constants, and Structure Definition
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Janet DePonte initial version July 1989
#		{1} JD -- Dec 1991 -- define plottypes bin,sec,freq,phase
#		{n} <who> -- <does what> -- <when>
#
#
#  ---------------------------------------------------------------
#  labels used to read the parameter file

define   ERRCOLUMN           	"ecolumn"
define   LABEL_SIZE          	"label_size"
define   NUMPLOTS            	"num_plots"
define   NUMXTICS            	"x_tics"
define   NUMYTICS            	"y_tics"
define   PLOTCOLUMN          	"column"
define   PLOTTITLE              "plot_title"
define   PLOTYPE	     	"plot_type"
define   GRQUIT                 "gclose"
define	 TBLFILENAME	     	"table"
define   TIC_SIZE	     	"tlabel_size"
define   XUNITS			"x_units"
define   XLABEL			"x_title"
define   YLABEL			"y_title"
define   XCOORDS	     	"x_range"
define   YCOORDS	     	"y_range"

#  ---------------------------------------------------------------
#  Utility constants

define   TY_HISTO             	1
define   TY_BAR			2

define   BEG			1
define   END			2

#  ---------------------------------------------------------------
#  plotting parameters and constants

#define   HDR_BORDER	       .15
define   HDR_BORDER	       .20
#define   PLOT_BORDER           .10
define   XPLOT_BORDER           .15
define   YPLOT_BORDER           .10

define   PLT_WCS		1
define   XLAB_WCS		2
define   YLAB_WCS		3

define   XBIN                   0
define   XFREQ                  1
define   XPHASE                 2
define   XSEC                   3

# ---------------------------------------------------------------
# Structure for plotting constants storage;  include device X & Y
# coordinates, header and x/y axis device label space, plot and plot 
# label device space, number of plot windows, tics on x/y axis, length
# of each bin and number of bins in table, label format sizes

define  LEN_CONST		38

define  XLL			Memr[$1]
define  XUL			Memr[$1+2]
define  YLL			Memr[$1+4]
define  YUL			Memr[$1+6]
define  HLABEL			Memr[$1+8]
define  YLSPACE			Memr[$1+10]
define  XLSPACE			Memr[$1+12]
define  PSPACE			Memr[$1+14]
define  PLSPACE			Memr[$1+16]
define  NUM_PLOTS		Memr[$1+18]
define  XTICS			Memr[$1+20]
define  YTICS			Memr[$1+22]
define  BINLEN                  Memd[P2D(($1)+24)]
define  NUMBINS                 Memr[$1+26]
define  LABSIZE			Memr[$1+28]
define  TICSIZE			Memr[$1+30]
define  XOFFSET                 Memd[P2D(($1)+32)]
define  XAUTO                   Memi[$1+34]
define  PTYPE                   Memi[$1+36]
#
# ---------------------------------------------------------------
# Structure for current virtual x/y coordinates and window coordinates

define  LEN_LIMITS		16

#  Virtual device coordinates
define  XVMIN			Memr[$1]
define  XVMAX			Memr[$1+2]
define  YVMIN			Memr[$1+4]
define  YVMAX			Memr[$1+6]

#  Windo coordinates
define  XWMIN			Memr[$1+8]
define  XWMAX			Memr[$1+10]
define  YWMIN			Memr[$1+12]
define  YWMAX			Memr[$1+14]
