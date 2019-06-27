#{  xdemo.cl
#
#  CL script task for xdemo package

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

package xdemo

task	$spectraldemo		= "xdemo$spectraldemo.cl"
task	$spatialdemo		= "xdemo$spatialdemo.cl"
task	$timingdemo		= "xdemo$timingdemo.cl"
task	$gtiming		= "xdemo$gtiming.cl"
task	$gspectral		= "xdemo$gspectral.cl"

# Print the opening banner.
type xdemo$xdemo_motd

clbye()
