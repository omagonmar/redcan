# Global MKPKG definitions for the GMISC package.

$set XFLAGS	= "$(XFLAGS) -p gmisc"
$set XVFLAGS	= "$(XVFLAGS) -p gmisc"
$set LFLAGS	= "$(LFLAGS) -p gmisc"

$ifeq (MACH, ssun) then
    $include "gmisc$lib/mkpkg.sf.SSUN"
$end
