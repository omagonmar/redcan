# $Header: /home/pros/xray/xspatial/detect/RCS/detect.cl,v 11.0 1997/11/06 16:32:35 prosb Exp $
# $Log: detect.cl,v $
# Revision 11.0  1997/11/06 16:32:35  prosb
# General Release 2.5
#
# Revision 9.2  1997/09/26 20:06:18  prosb
# JCC(9/97) - move imdetect to xproto.
#
# Revision 9.1  1996/11/15 17:08:50  prosb
# JCC (11/4/96) - add a new task imdetect
#
#Revision 9.0  1995/11/16  18:50:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:11:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:34:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:13:05  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:08:25  mo
#MC/Jd	5/20/93		Add new tasks and silence banner
#
#Revision 5.0  92/10/29  21:33:24  prosb
#General Release 2.1
#
#Revision 4.1  92/10/07  11:13:02  janet
#added ldetect & lbmap defs
#
#Revision 4.0  92/04/27  14:37:54  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  18:09:10  janet
#added detmkreg.
#
#
#{  detect.cl
#
#  CL script task for detect package

if ( !defpac("ximages")) {
    ximages
}
;

package detect

task    bepos,
        bkden,
        lpeaks,
        _fixvar,
        _ms,
	detmkreg        = detect$x_detect.e

task    snrmap          = detect$snrmap.cl
task    cellmap         = detect$cellmap.cl
task    lbmap		= detect$lbmap.cl
task    ldetect		= detect$ldetect.cl
task    lmatchsrc	= detect$lmatchsrc.cl

if (motd)
    type	detect$detect_motd
;

clbye()
