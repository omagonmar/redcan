#$Header: /home/pros/xray/xtiming/RCS/xtiming.cl,v 11.0 1997/11/06 16:46:08 prosb Exp $
#$Log: xtiming.cl,v $
#Revision 11.0  1997/11/06 16:46:08  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:38:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:04:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:55:20  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  10:11:38  mo
#MC/JD	5/20/93		Add new tasks/ Silenece TABLES banner
#
#Revision 5.0  92/10/29  23:06:56  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:30:41  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/24  14:41:11  mo
#MC	4/24/92		Juggle CL syntax due to errors when ximages already loaded
#
#Revision 3.3  92/04/15  15:12:28  mo
#MC	4/15/92		Remove addsine and fakesrc, add timcor package
#
#Revision 3.2  92/03/25  17:20:31  mo
#MC	3/25/92		Remove the STSDAS auto-load option
#
#Revision 3.1  92/03/18  10:06:35  mo
#MC/JD	Fall 91		Add new timplot macros to task list
#
#Revision 3.0  91/08/02  02:00:04  prosb
#General Release 1.1
#
#Revision 2.1  91/07/21  18:05:00  mo
#MC	7/21/91		Update for new package structure and auto-loading
#
#;;; Revision 1.2  91/07/21  18:01:33  mo
#;;; MC	7/21/91			Update for new package structure and auto-
#;;; 				loading
#;;; 
#;;; Revision 1.1  91/07/03  17:07:56  mo
#;;; Initial revision
#;;; 
#Revision 2.0  91/03/06  22:32:18  pros
#General Release 1.0
#
#{  xtiming.cl
#
#  CL script task for xtiming package
 
#if( !defpac( "ximages" )) {
#	ximages
#}
#;

if( defpac( "ximages" )) {
	print("")
} else {
   ximages
}
;

# load necessary packages
if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
        tables motd-
    }
#else if ( deftask("stsdas")) {
#    if( !defpac( "stsdas" )) {
#        stsdas 
#    }
#}
}else {
    print("WARNING: No TABLES installation found!" )
    print("A TABLES installation is required for some tasks" )
}
;

# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
#if ( defpac("stsdas")) {
#   if ( !defpac( "ttools"))
#       ttools  
#   }
#;


package xtiming

task    _kspltab    	= xtiming$x_xtiming.e
task    _timplot    	= xtiming$x_xtiming.e
task    fft     	= xtiming$x_xtiming.e
task    fold    	= xtiming$x_xtiming.e
task    ltcurv  	= xtiming$x_xtiming.e
task    period  	= xtiming$x_xtiming.e
task    qpphase		= xtiming$x_xtiming.e
task    timfilter   	= xtiming$x_xtiming.e
task    vartst		= xtiming$x_xtiming.e
#task   addsine 	= xtiming$x_xtiming.e
#task   fakesrc 	= xtiming$x_xtiming.e

task	timcor.pkg	= timcor$timcor.cl

task	timsort		= xtiming$timsort.cl
task	timplot		= xtiming$timplot.cl
task    timprint	= xtiming$timprint.cl

task	chiplot		= xtiming$chiplot.cl
task	fftplot		= xtiming$fftplot.cl
task	fldplot		= xtiming$fldplot.cl
task	ftpplot		= xtiming$ftpplot.cl
task	ksplot		= xtiming$ksplot.cl
task	ltcplot		= xtiming$ltcplot.cl

#  Print the opening banner.
#type xtiming$xtiming_motd

clbye()
