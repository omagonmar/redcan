#$Header: /home/pros/xray/xspectral/RCS/xspectral.cl,v 11.0 1997/11/06 16:43:53 prosb Exp $
#$Log: xspectral.cl,v $
#Revision 11.0  1997/11/06 16:43:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:28:01  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:28:33  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  14:11:02  janet
#jd - added hxflux.
#
#Revision 7.0  93/12/27  18:59:36  prosb
#General Release 2.3
#
#Revision 6.1  93/11/22  23:24:10  dennis
#Added tasks upspecrdf, downspecrdf.
#
#Revision 6.0  93/05/24  16:47:07  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:05:04  mo
#MC	5/20/93		Silence the TABLES banner
#
#Revision 5.0  92/10/29  22:47:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:26:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/10  10:45:21  orszak
#jso - add motd and maureen? commented out stsdas.
#
#Revision 3.1  92/03/05  13:07:15  orszak
#jso - show motd
#
#Revision 3.0  91/08/02  01:53:01  prosb
#General Release 1.1
#
#Revision 2.9  91/08/01  19:14:09  prosb
#jso - for release
#
#Revision 2.8  91/07/25  18:59:12  prosb
#jso - show_models needs to have a parameter file.
#
#Revision 2.7  91/07/25  10:21:33  prosb
#jso - checking in for mo: changes to add new scripts to package.
#
#Revision 2.6  91/07/21  16:15:56  mo
#MC	7/21/91		Let's make the TABLES first choice and STSDAS
#			second choice.
#
#Revision 2.5  91/07/19  15:33:53  orszak
#jso - change the name from flux to xflux
#
#Revision 2.4  91/07/12  18:48:57  prosb
#jso - bug fix
#
#Revision 2.3  91/07/12  14:58:42  prosb
#jso - change for pset implementation
#
#Revision 2.1  91/05/28  11:48:10  pros
#jso - lets look at the motd
#
#Revision 2.0  91/03/06  22:54:46  pros
#General Release 1.0
#
#{  xspectral.cl
#
#  CL script task for the X-ray xspectral package

if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
	    tables  motd-
    }
}
#else if ( deftask("stsdas")) {
#    if( !defpac( "stsdas" )) {
#        stsdas
#    }
#}
else {
    print("WARNING: No STSDAS or TABLES installation found!" )
    print("An STSDAS or TABLES installation is required for some tasks" )
}
;

# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
#if ( defpac("stsdas")) {
#    if ( !defpac( "ttools"))
#	   ttools 
#}
#;

package xspectral

task	fit		        = xspectral$x_xspectral.e
task	search_grid		= xspectral$x_xspectral.e
task	bal_plot		= xspectral$x_xspectral.e
task	counts_plot		= xspectral$x_xspectral.e
task	grid_plot		= xspectral$x_xspectral.e
task	qpspec		        = xspectral$x_xspectral.e
task	singlefit		= xspectral$x_xspectral.e
task	upspecrdf	        = xspectral$x_xspectral.e
task	downspecrdf		= xspectral$x_xspectral.e
task	xflux		        = xspectral$x_xspectral.e
task	show_models 	        = xspectral$x_xspectral.e

task	pkgpars = xspectral$pkgpars.par

task	dofitplot		= xspectral$dofitplot.cl
task	intrinsicspecplot	= xspectral$intrinsicspecplot.cl
task	hxflux			= xspectral$hxflux.cl

#  Print the opening banner.
type xspectral$xspectral_motd

clbye()
