#$Header: /home/pros/xray/xplot/RCS/xplot.cl,v 11.0 1997/11/06 16:38:48 prosb Exp $
#$Log: xplot.cl,v $
#Revision 11.0  1997/11/06 16:38:48  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:32  prosb
#General Release 2.4
#
#Revision 8.1  1995/11/06  23:01:02  prosb
#changed name of xterm window to "XIMmonolog".
#Removed background "&"
#
#Revision 8.0  1994/06/27  17:01:33  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:47:56  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  12:53:09  janet
#*** empty log message ***
#
#Revision 6.0  93/05/24  16:40:26  prosb
#General Release 2.2
#
#Revision 5.7  93/05/20  10:03:51  mo
#MC	5/20/93		Silence the package banners
#
#Revision 5.6  93/05/10  15:51:01  janet
#jd - added tabplot task
#
#Revision 5.5  93/02/01  11:28:32  wendy
#Changed SAOmonolog window size to 80 columns.
#
#Revision 5.4  93/01/29  16:39:30  wendy
#Hid the saoimage and xterm tasks.
#
#Revision 5.3  93/01/29  12:56:48  wendy
#Defined xterm as external task for saoimage monolog window.
#
#Revision 5.2  93/01/26  17:27:44  prosb
#jso - added pspc_hrcolor.
#
#Revision 5.1  93/01/26  13:56:37  janet
#removed gidpars after imcontour/tvimcontour update (use wlpars now).
#
#Revision 5.0  92/10/29  22:34:32  prosb
#General Release 2.1
#
#Revision 4.1  92/09/02  14:33:18  mo
#MC	9/2/92		Auto-load spatial ( for PROJ ) and
#			add ximtool and xexamine tasks
#
#Revision 3.5  92/04/13  15:05:19  mo
#MC	4/13/92		Remove the STSDAS/STPLOT packages now that
#			rimcursor replaces WCSLAB for cursor readback
#			in tvlabel
#
#Revision 3.4  92/04/06  17:42:05  mo
#MC	4/6/92		Correct the checks for loading STSDAS/STPLOT
#
#Revision 3.3  92/03/02  17:01:23  mo
#MC	Feb 92		Add auto loading for TABLES a/o STSDAS
#			and add 2 new script tasks
#
#Revision 3.2  92/01/15  13:24:46  janet
#added pset param task wcspars
#
#Revision 3.1  92/01/15  10:36:36  janet
#*** empty log message ***
#
#Revision 3.0  91/08/02  01:23:33  prosb
#General Release 1.1
#
#Revision 1.2  91/08/01  22:05:59  mo
#MC	8/1/91		Update for new package structure
#
#Revision 1.1  91/07/24  09:10:39  mo
#Initial revision
#
#
#{  xplot.cl
#
#  CL script task for xplot package
 
if ( !defpac( "images" )){
            images 
}
;

if ( !defpac( "tv" )){
           tv 
}
;

if ( !defpac( "lists" )){
           lists 
}
;

if ( !defpac( "xspatial" )){
	   xspatial motd-
}
;

if ( !defpac( "detect" )){
	   detect motd-
}
;

#if ( !defpac("stsdas") ){
#	stsdas
#}
#;

#if( !defpac("stplot") ){
#	    stplot
#}
#;

if ( deftask("tables")){
    if ( !defpac( "tables" )) {
            tables motd-
    }
#else if ( deftask("stsdas")) {
#    if( !defpac( "stsdas" )) {
#        stsdas
#    }
#}
} else {
    print("WARNING: No TABLES installation found!" )
    print("An TABLES installation is required for some tasks" )
}
;

# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
#if ( defpac("stsdas")) {
#    if ( !defpac( "ttools"))
#           ttools
#}
#;

# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
#if ( defpac("stsdas")) {
#    if ( !defpac( "stplot"))
#           stplot
#}
#;


package xplot

task	imcontour	= xplot$x_xplot.e
task	pspc_hrcolor	= xplot$pspc_hrcolor.cl
task	tvimcontour	= xplot$tvimcontour.cl
task    xdisplay        = xplot$xdisplay.cl
task    tabplot         = xplot$tabplot.cl
task    tvlabel         = xplot$tvlabel.cl
task    tvproj  	= xplot$tvproj.cl
task	ximtool		= xplot$ximtool.cl
task	xexamine        = xplot$x_xplot.e
task	_gproj		= xplot$_gproj.cl
task    $_saoimage	= "$saoimage"
hide	_saoimage
task    $_x		= "$xterm -s -j -sb -rw -ut -g 80x14+202+71 -T XIMmonolog -n XIMmonolog"
hide	_x
task    $_ximtool	= "$ximtool "
hide	_ximtool	
task	$_saotng	= "$saotng "
hide	_saotng

#task    $saoimage       = "$" // osfn("xraybin$saoimage.e")
#task    gridpars 	= xplot$gridpars.par

#  Print the opening banner.
if(motd)
type xplot$xplot_motd
;

clbye()
