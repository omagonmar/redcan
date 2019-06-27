#$Header: /home/pros/xray/xtiming/timlib/RCS/timing.h,v 11.0 1997/11/06 16:45:13 prosb Exp $
#$Log: timing.h,v $
#Revision 11.0  1997/11/06 16:45:13  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:42:50  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:03:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:59:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:06:04  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:37:19  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/23  17:55:48  janet
#added total counts to struct.
#
#Revision 3.0  91/08/02  02:02:33  prosb
#General Release 1.1
#
#Revision 2.1  91/04/03  18:53:35  janet
#added bknorm parameter.
#
#Revision 2.0  91/03/06  22:50:53  pros
#General Release 1.0
#
#        XTIMING.H
#
#        parameters used by the timing tasks

#  ---------------------------------------------------------------

define   LEN_EVBUF		1024
define   SZ_EXPR		1024
define   MAX_BINS		1000
#
define	 NUMOFBINS		"bins"
define	 NUMOFSECS		"bin_length"
define	 GETGOODINTV		"get_gintvs"
define   SOURCEFILENAME         "source_file"
define   BKGRDFILENAME          "background_file"
define   OUTTABLES		"out_tables"
define   CLOBBER                "clobber"
define   BKNORM			"bk_norm_fact"
define   DISPLAY                "display"
#
#  ---------------------------------------------------------------
#
define  LEN_MMM			44

define  CRMIN			Memr[$1]
define  CRMAX			Memr[$1+2]
define  CRMU			Memr[$1+4]
define  CREMIN			Memr[$1+6]
define  CREMAX			Memr[$1+8]
define  CREMU			Memr[$1+10]
define  EXPMIN			Memr[$1+12]
define  EXPMAX			Memr[$1+14]
define  EXPMU			Memr[$1+16]
define  SMIN			Memr[$1+18]
define  SMAX			Memr[$1+20]
define  SMU			Memr[$1+22]
define  BMIN			Memr[$1+24]
define  BMAX			Memr[$1+26]
define  BMU			Memr[$1+28]
define  NMIN			Memr[$1+30]
define  NMAX			Memr[$1+32]
define  NMU			Memr[$1+34]
define  NEMIN			Memr[$1+36]
define  NEMAX			Memr[$1+38]
define  NEMU			Memr[$1+40]
define  NTOT                    Memr[$1+42]
