#{  adass.cl
#
#  CL script task for adass package

if ( deftask("tables")) {
    if ( !defpac( "tables" )) {
            tables 
    }
}
else if ( deftask("stsdas")) {
    if( !defpac( "stsdas" )) {
        stsdas
    }
}
else {
    print("WARNING: No STSDAS or TABLES installation found!" )
    print("An STSDAS or TABLES installation is required for some tasks" )
}
# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
if ( defpac("stsdas")) {
    if ( !defpac( "ttools"))
           ttools 
}
;
# This didn't work as a nested if in the front section, so we will
#    humor IRAF CL scripts and put it here
if ( defpac("stsdas")) {
    if ( !defpac( "stplot"))
           stplot
}
;
if ( !defpac( "xplot"))
           xplot
;
if ( !defpac( "xspatial"))
           xspatial
;
if ( !defpac( "detect"))
          detect 
;

package adass

task	$spectraldemo		= "adass$spectraldemo.cl"
task	$spatialdemo		= "adass$spatialdemo.cl"
task	$timingdemo		= "adass$timingdemo.cl"
task	$lucydemo		= "adass$lucydemo.cl"
task    $broad_band             = "adass$broad_band.cl"
#task    $imsmooth               = "adass$imsmooth.cl"
#task    $kepler                 = "adass$kepler.cl"
#task    $tvimcdemo              = "adass$tvimcdemo.cl"
#task    $tvimcdemo2             = "adass$tvimcdemo2.cl"
task    $tvimcdemo              = "adass$tvimcdemo2.cl"
task    $tvproj_demo            = "adass$tvproj_demo.cl"
task    $m31disp            	= "adass$m31disp.cl"
task	$parlac_detect		= "adass$parlac_detect.cl"
task	$arlac_spectral		= "adass$arlac_spectral.cl"

# Print the opening banner.
type adass$adass_motd

clbye()
