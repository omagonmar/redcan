#$Header: /home/pros/xray/xspatial/RCS/xspatial.cl,v 11.1 1999/10/13 16:25:47 prosb Exp $
#$Log: xspatial.cl,v $
#Revision 11.1  1999/10/13 16:25:47  prosb
#add the task "offaxisprf"
#
#Revision 11.0  1997/11/06 16:33:43  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:37:15  prosb
#General Release 2.4
#
#Revision 8.5  1995/09/27  18:05:23  prosb
#JCC - Added to load the package "xspectral".
#
#Revision 8.4  1995/06/12  20:02:03  prosb
#JCC - added srcinten.
#
#Revision 8.3  1995/05/16  20:47:07  prosb
#JCC - remove SIMTAB for fap.
#
#Revision 8.2  1994/09/13  11:01:33  janet
#jd - added qpsim, simtab.
#
#Revision 8.1  94/07/07  16:37:18  dvs
#Added eintools subpackage
#
#Revision 8.0  94/06/27  14:56:05  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:31:19  prosb
#General Release 2.3
#
#Revision 6.1  93/12/15  11:38:32  mo
#MC	12/15/93	Add ERRCREATE task
#
#Revision 6.0  93/05/24  16:10:24  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  09:35:25  mo
#MC	5/20/93		Silence extra package banners
#
#Revision 5.1  93/05/06  17:36:00  orszak
#jso - added rosprf
#
#Revision 5.0  92/10/29  21:30:44  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  09:44:13  mo
#MC	10/24/92	Add WCSCOORDS task
#
#Revision 4.0  92/04/27  14:34:12  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/24  14:34:42  mo
#MC	4/24/92		Add new tasks
#
#Revision 3.3  92/04/21  17:21:52  mo
#MC	4/21/92		Add fixsaoreg task
#
#Revision 3.2  92/03/25  11:14:57  mo
#MC	3/25/92		Remove STSDAS as an allowed 'auto-load' option
#
#Revision 3.1  92/02/13  12:22:40  janet
#added task isoreg.
#
#Revision 3.0  91/08/02  01:26:46  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  18:14:55  mo
#MC	7/21/91		No changes
#
#Revision 2.1  91/07/21  16:22:09  mo
#MC	7/21/91		Let's auto-load TABLES so that we can
#			do table output. - TABLES takes precedence
#			over STSDAS
#
#Revision 2.0  91/03/06  23:11:11  pros
#General Release 1.0
#
#{  xspatial.cl
#
#  CL script task for xspatial package
 
if ( !defpac( "ximages")) {
            ximages
}
;

if ( !deftask("ximages")) {
            ximages
}

if ( !defpac( "xproto")) {
            xproto
}
;
if ( !defpac( "xspectral")) {
            xspectral
}
;

if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
            tables motd-
    }
}
else {
    print("WARNING: No  TABLES installation found!" )
    print("An  TABLES installation is required for some tasks" )
}
 
package xspatial

task	offaxisprf      = xspatial$offaxisprf.cl
task	rosprf		= xspatial$rosprf.cl
task	vigdata 	= xspatial$vigdata.cl
task	vigmodel	= xspatial$vigmodel.cl
task	wcscoords	= xspatial$wcscoords.cl
task	srcinten	= xspatial$srcinten.cl
task    qpsim           = xspatial$qpsim.cl
#task    simtab          = xspatial$simtab.cl

task	fixsaoreg	= xspatial$x_xspatial.e
task	imcnts		= xspatial$x_xspatial.e
task	imdisp		= xspatial$x_xspatial.e
task	improj		= xspatial$x_xspatial.e
task    isoreg		= xspatial$x_xspatial.e
task    errcreate	= xspatial$x_xspatial.e
task	makevig		= xspatial$x_xspatial.e
task	skypix	 	= xspatial$x_xspatial.e
task    _simevt         = xspatial$x_xspatial.e
task    _srcechk        = xspatial$x_xspatial.e

task	immodel		= xspatial$x_immodel.e
task	imsmooth	= xspatial$x_immodel.e

#task	improj		= xspatial$x_improj.e

task    detect.pkg      = detect$detect.cl

task    eintools.pkg      = eintools$eintools.cl

#  Print the opening banner.
if( motd )
    type xspatial$xspatial_motd
;

clbye()
