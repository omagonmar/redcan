#$Header: /home/pros/xray/xproto/RCS/xproto.cl,v 11.3 1998/04/24 16:14:23 prosb Exp $
#$Log: xproto.cl,v $
#Revision 11.3  1998/04/24 16:14:23  prosb
#Patch Release 2.5.p1
#
#Revision 11.2  1998/02/25 18:38:04  prosb
#JCC(1/27/98) - add 2 new tasks: marx2qpoe & xexamine_r.
#
#Revision 11.0  1997/11/06 16:39:14  prosb
#General Release 2.5
#
#Revision 9.1  1997/09/26 20:32:16  prosb
#JCC(9/97) - move imdetect from xspatial to xproto.
#
#Revision 9.0  1995/11/16 19:26:25  prosb
#General Release 2.4
#
#Revision 8.2  1994/07/15  14:22:32  chen
#jchen - add the task "evalvg"
#
#Revision 8.1  94/07/13  16:07:01  janet
#jd - added evalvg to cl.
#
#Revision 8.0  94/06/27  17:25:38  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/20  13:52:41  janet
#jd - moved qpgapmap from xproto to xdataio.
#
#Revision 7.0  93/12/27  18:50:42  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  13:22:55  janet
#jd - moved qpappend, hkfilter to xdataio
#
#Revision 6.1  93/08/24  11:12:23  mo
#MC	8/24/93		Add qpgapmap task
#
#Revision 6.0  93/05/24  16:43:20  prosb
#General Release 2.2
#
#Revision 5.1  93/05/21  18:34:56  mo
#MC	5/21/93		Add support for EUV loading
#
#Revision 5.0  92/10/29  22:39:24  prosb
#General Release 2.1
#
#Revision 4.1  92/10/23  09:51:49  mo
#MC	10/24/92	Add new tasks
#
#Revision 4.0  92/04/27  15:18:45  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/04/24  15:11:40  mo
#Initial revision
#
#
#{  xproto.cl
#
#  CL script task for xproto package
if ( deftask("images")) {
    if ( !defpac( "images" )) {
            images } } ;

if ( deftask("euv")) {
    if ( !defpac( "euv" )) 
	 euv } ;

if ( deftask("euvred")) {
    if ( !defpac( "euvred" )) 
	 euvred } ;

#JCC(1/98) - for marx2qpoe
if ( !defpac( "xdataio" )) {
	 xdataio } ;


package xproto


task    qpcalc          = xproto$x_xproto.e
task    qpcreate        = xproto$qpcreate.cl
task    wcsqpedit      	= xproto$x_xproto.e
task    tabfilter      	= xproto$tabfilter.cl
task    _evlvg          = xproto$x_xproto.e

task    evalvg          = xproto$evalvg.cl
task    imdetect        = xproto$x_xproto.e
task    marx2qpoe       = xproto$marx2qpoe.cl
task    xexamine_r      = xproto$x_xproto.e

#  Print the opening banner.
if(motd)
type xproto$xproto_motd
;

#JCC(1/98) - xexamine_r requires "xspatial.detect" and "xplot.xdisplay" 
#          - load xplot after xproto gets loaded ; 
#          - (xplot will load xspatial.detect in xplot.cl )
#if ( !defpac( "xplot" )){
#  print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
#  print("\n     Require to load the xplot package for xexamine_r")
#  print("\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n")
#} 
#;

clbye()
