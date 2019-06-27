#$Header: /home/pros/xray/xinstall/RCS/xinstall.cl,v 11.0 1997/11/06 16:41:05 prosb Exp $
#$Log: xinstall.cl,v $
#Revision 11.0  1997/11/06 16:41:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:27:26  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:27:28  prosb
#General Release 2.3.1
#
#Revision 7.1  94/06/27  13:33:11  janet
#js - added new installation scripts ... fits2ein, fits2edemo.
#
#Revision 7.0  93/12/27  18:52:32  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  18:22:33  mo
#MC	remove EINBB and ROSBB dependencies
#
#Revision 6.0  93/05/24  16:46:01  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:42:02  prosb
#General Release 2.1
#
#Revision 4.2  92/10/16  14:28:08  mo
#MC	10/16/92		Change vign to spat
#
#Revision 4.1  92/10/08  09:31:38  mo
#MC	10/8/92		Addes XLOCAL for einbb and rosbb
#
#Revision 4.0  92/04/27  15:25:28  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/04/24  09:18:09  jmoran
#Initial revision
#

#  xinstall.cl
#
#  CL script task for xinstall package

if ( defpac( "images"))  
    	print("")
else
        images
;

if ( defpac( "xdataio")) 
        print("")
else
        xdataio motd-
;

#if ( defpac( "xlocal")) 
#        print("")
#else
#        xlocal motd-
#;

#if ( defpac( "rosbb")) 
#        print("")
#else
# rosbb motd-
#;

#if ( defpac( "einbb")) 
#        print("")
#else
#        einbb motd-
#;

if ( deftask( "tables")) 
{
    if ( !defpac( "tables")) 
            tables motd-
}
else 
{
    print("WARNING: No TABLES installation found!" )
    print("A TABLES installation is required for some tasks" )
}
;


package xinstall

task	$drep2cal		= "xinstall$drep2cal.cl"
task	$fits2bin		= "xinstall$fits2bin.cl"
task	$fits2edemo		= "xinstall$fits2edemo.cl"
task	$fits2ein		= "xinstall$fits2ein.cl"
task	$fits2ephem		= "xinstall$fits2ephem.cl"
task	$fits2spat		= "xinstall$fits2spat.cl"
task    $fits2snr               = "xinstall$fits2snr.cl"
task    $rh_fits2pros           = "xinstall$rh_fits2pros.cl"
task    $rp_fits2pros           = "xinstall$rp_fits2pros.cl"
task 	$cale_fits2qp		= "xinstall$cale_fits2qp.cl"
task    $calr_fits2qp           = "xinstall$calr_fits2qp.cl"
task    $calr_qp2fits           = "xinstall$calr_qp2fits.cl"

# Print the opening banner.
type xinstall$xinstall_motd

clbye()
