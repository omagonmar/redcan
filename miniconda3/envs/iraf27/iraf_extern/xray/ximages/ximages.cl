#$Header: /home/pros/xray/ximages/RCS/ximages.cl,v 11.0 1997/11/06 16:29:23 prosb Exp $
#$Log: ximages.cl,v $
#Revision 11.0  1997/11/06 16:29:23  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:58  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:42:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:04:21  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  09:28:49  mo
#MC	5/20/93		Add newtasks and suppress other package login msgs
#
#Revision 5.0  92/10/29  21:26:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:15:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/24  14:33:20  mo
#MC	4/24/92		Remove the STSDAS load
#
#Revision 3.0  91/08/02  01:15:37  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  16:24:48  mo
#MC	7/21/91		Let's autoload IMAGES and also make TABLES
#			1st choice over STSDAS.
#
#Revision 2.0  91/03/06  23:48:54  pros
#General Release 1.0
#
#{  nimages.cl
#
# Load necessary packages

if ( !defpac( "images")) {
	    images
}
;

if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
	    tables motd-
    }
#} else if ( deftask("stsdas")) {
#    if( !defpac( "stsdas" )) {
#	    stsdas
#   } 
} else {
    print("WARNING: No TABLES installation found!" )
    print("An TABLES installation is required for some tasks" )
}
;

# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
#if ( defpac("stsdas")) {
#    if ( !defpac( "ttools"))
#	    ttools
#} 
#;

#  CL script task for ximages package
#
 
package ximages  
  
task    _imcompress             = ximages$x_ximages.e
task    _imreplicate            = ximages$x_ximages.e
   
    
task    imcreate		= ximages$x_ximages.e
task	imnode			= ximages$x_ximages.e
task	plcreate			= ximages$x_ximages.e
task	pllist			= ximages$x_ximages.e
task	qpcopy			= ximages$x_ximages.e
task	qplist         			= ximages$x_ximages.e
task	qphedit			= ximages$x_ximages.e
task	qplintran		= ximages$x_ximages.e
task	qpsort			= ximages$x_ximages.e
task	xhadd			= ximages$x_ximages.e
task	xhdisp			= ximages$x_ximages.e

task    imcompress              = ximages$imcompress.cl
task    imreplicate             = ximages$imreplicate.cl
task	qprotate		= ximages$qprotate.cl
task	qpshift			= ximages$qpshift.cl

task    imcalc          = ximages$x_imcalc.e

#  Print the opening banner.
#type ximages$ximages_motd 
      
clbye()  
