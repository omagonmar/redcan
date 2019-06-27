#$Header: /home/pros/xray/RCS/xray.cl,v 11.0 1997/11/06 16:46:36 prosb Exp $
#$Log: xray.cl,v $
#Revision 11.0  1997/11/06 16:46:36  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:24:17  prosb
#General Release 2.4
#
#Revision 8.2  1995/09/28  21:25:26  prosb
#jcc - comment out "adass" for the release.
#
#Revision 8.1  1995/08/07  20:44:46  prosb
#jcc - ci for pros2.4.
#
#Revision 8.0  94/06/27  13:41:13  prosb
#General Release 2.3.1
#
#Revision 7.3  94/06/20  10:25:28  janet
#jd - xlocal stays in when pros is released.
#
#Revision 7.2  94/06/17  17:59:17  wendy
#commented out xlocal for release
#
#Revision 7.1  94/01/26  13:33:23  janet
#jd - updated with _keychk task.
#
#Revision 7.0  93/12/27  18:50:14  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:35:05  prosb
#General Release 2.2
#
#Revision 5.1  93/05/21  18:48:21  mo
#MC	 remove ADASS For release
#
#Revision 5.0  92/10/29  22:39:03  prosb
#General Release 2.1
#
#Revision 4.1  92/10/21  16:14:35  mo
#MC	10/21/92		Add new tasks
#
#Revision 4.0  92/04/27  14:05:50  prosb
#General Release 2.0:  April 1992
#
#Revision 2.6  92/04/21  13:32:18  jmoran
#JMORAN added xinstall package
#
#Revision 2.5  92/03/30  12:03:45  mo
#MC	3/30/92		Change the 'demo' directory to 'xdemo' for consistency
#
#Revision 2.4  92/03/30  11:56:10  mo
#MC	3/5/92		Add new tasks - xapropos and _imgimage
#
#Revision 2.3  92/03/05  13:12:42  mo
#Jmoran	91	Add the _clobname and _fnlname utility
#			hidden tasks
#.`
#
#
#Revision 2.2  91/07/30  20:35:10  mo
#MC	no changes
#
#Revision 2.1  91/07/21  19:15:58  mo
# MC   7/21/91         Updated for package restructuring
#
#Revision 2.0  91/03/07  02:17:40  pros
#General Release 1.0
#
# load "outside" packages - this should be done before defining
# the xray packages, to avoid possible redefinitions

#images
#stsdas
#ttools
#stplot

if ( deftask("ctio")) {
    if ( !defpac( "ctio" )){
        ctio
    }   
}
;
 
#{  XRAY == The PROS X-ray astronomy suite of packages

cl < "xray$lib/zzsetenv.def"

package xray, bin = xraybin$

# xray packages
task	xdataio.pkg	= "xdataio$xdataio.cl"
task	xproto.pkg	= "xproto$xproto.cl"
task	xobsolete.pkg	= "xobsolete$xobsolete.cl"
task	xlocal.pkg	= "xlocal$xlocal.cl"
task	ximages.pkg	= "ximages$ximages.cl"
task	xplot.pkg	= "xplot$xplot.cl"
task	xspatial.pkg	= "xspatial$xspatial.cl"
task	xspectral.pkg	= "xspectral$xspectral.cl"
task	xtiming.pkg	= "xtiming$xtiming.cl"
task	_rtname		= "xraytasks$x_xray.e"
task	_clobname	= "xraytasks$x_xray.e"
task	_fnlname	= "xraytasks$x_xray.e"
task	_imgimage	= "xraytasks$x_xray.e"
task	_imgclust	= "xraytasks$x_xray.e"
task	_getdevdim	= "xraytasks$x_xray.e"
task    _keychk         = "xraytasks$x_xray.e"
task	xapropos	= "xraytasks$xapropos.cl"

task   $xdemo    = "xdemo$xdemo.cl"
#task   $adass    = "adass$adass.cl"
task   $xinstall = "xinstall$xinstall.cl"


#  Print the opening banner.
if (motd)
type xray$xray_motd
;

clbye()
