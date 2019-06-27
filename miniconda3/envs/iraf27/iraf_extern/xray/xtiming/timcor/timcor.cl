#$Header: /home/pros/xray/xtiming/timcor/RCS/timcor.cl,v 11.1 1999/01/28 21:37:26 prosb Exp $
#JCC(1/26/99) - change apply_bary task to a script. apply_bary_spp 
#               is the original SPP code. 
#
#Revision 11.0  1997/11/06 16:45:54  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:35:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:43:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:06:07  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:09:17  janet
#*** empty log message ***
#
#Revision 6.0  93/05/24  17:00:21  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  23:07:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:39:16  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/04/23  13:10:02  mo
#Initial revision
#
#
#{  detect.cl
#
#  CL script task for detect package

#if ( !defpac("ximages")) {
#    ximages
#}
#;

package timcor

task    apply_bary      = timcor$apply_bary.cl
task    _abary          = timcor$x_timcor.e
task    _clc_bary	= timcor$x_timcor.e
task    scc_to_utc	= timcor$x_timcor.e
task    _utmjd		= timcor$x_timcor.e

task    calc_bary       = timcor$calc_bary.cl
task    _upephrdf       = timcor$_upephrdf.cl

type	timcor$timcor_motd

clbye()
