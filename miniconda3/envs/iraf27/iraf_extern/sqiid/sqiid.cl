# Package scripts for the SQIID package

# load necessary packages
#    noao
# artdata is loaded to get mkpattern routine used in (N)IRCOMBINE
       artdata
# imred and irred is loaded to get center routine
       imred
           irred
# iis is loaded to get frame routine for IRAF2.10EXPORT
     iis
#    utilities
#    proto
#    tv
#    local

# change sqiiddir to point to SQIID directory in target system
# set     sqiiddir       = "/u2/merrill/myprog/sqiid/"
set     sqiiddir       = "sqiid$"
#set     sqiiddir       = "home$myprog/sqiid/"

package sqiid

# set     helpdb          = "sqiiddir$sqiid.db"
 
task    chlist          = "sqiiddir$chlist.cl"
task    $cleanup        = "sqiiddir$cleanup.cl"
task    closure         = "sqiiddir$closure.cl"  
task    colorlist       = "sqiiddir$colorlist.cl"
task    expandnim       = "sqiiddir$expandnim.cl"
task    getcenters      = "sqiiddir$getcenters.cl"
task    getcoo          = "sqiiddir$getcoo.cl"
task    imclip          = "sqiiddir$imclip.cl"
task    imgraph         = "sqiiddir$imgraph.cl"  
task    invcoo          = "sqiiddir$invcoo.cl"
task    linklaps        = "sqiiddir$linklaps.cl"
task    locate          = "sqiiddir$locate.cl"  
task    mergecom        = "sqiiddir$mergecom.cl"  
task    mkmask          = "sqiiddir$mkmask.cl"
task    mkpathtbl       = "sqiiddir$mkpathtbl.cl"
task    nircombine      = "sqiiddir$nircombine.cl"  
task    show9           = "sqiiddir$show9.cl"
task    show4           = "sqiiddir$show4.cl"
task    show1           = "sqiiddir$show4.cl"
task    sqdark          = "sqiiddir$sqdark.cl"
task    sqflat          = "sqiiddir$sqflat.cl"
task    sqfocus         = "sqiiddir$sqfocus.cl"  
task    sqframe         = "sqiiddir$sqframe.cl"
task    sqmos           = "sqiiddir$sqmos.cl"  
task    sqproc          = "sqiiddir$sqproc.cl"  
task    sqnotch         = "sqiiddir$sqnotch.cl"  
task    sq9pair         = "sqiiddir$sq9pair.cl"  
task    sqtriad         = "sqiiddir$sqtriad.cl"  
task    sqremap         = "sqiiddir$sqremap.cl"  
task    sqsky           = "sqiiddir$sqsky.cl"  
task    transmat        = "sqiiddir$transmat.cl"  
task    unsqmos         = "sqiiddir$unsqmos.cl"  
task    which           = "sqiiddir$which.cl"  
task    xyadopt         = "sqiiddir$xyadopt.cl"  
task    xyget           = "sqiiddir$xyget.cl"  
task    xylap           = "sqiiddir$xylap.cl"  
task    xytrace         = "sqiiddir$xytrace.cl"  
task    xystd           = "sqiiddir$xystd.cl"  
task    zget            = "sqiiddir$zget.cl"  
task    ztrace          = "sqiiddir$ztrace.cl"  
# OUTDATED TASKS:
# task    compose         = "sqiiddir$compose.cl"  
# task    getalign        = "sqiiddir$getalign.cl"  
# task    getcombine      = "sqiiddir$getcombine.cl"  
# task    getlaps         = "sqiiddir$getlaps.cl"
# task    getmatch        = "sqiiddir$getmatch.cl"  
# task    getoffsets      = "sqiiddir$getoffsets.cl"  
# task    ircombine       = "sqiiddir$ircombine.cl"  
# task    imlinfit        = "sqiiddir$imlinfit.cl"
# task    linkalign       = "sqiiddir$linkalign.cl"  

keep
clbye()
