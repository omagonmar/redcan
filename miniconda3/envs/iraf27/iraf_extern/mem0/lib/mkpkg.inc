# Global MKPKG definitions for the MEM0 package, vesion C.

$set XFLAGS	= "$(XFLAGS) -p mem0"

# Special file lists

$ifeq (MACH, f68881) then
    $include "mem0$lib/mkpkg.sf.SUN3"
$else $ifeq (MACH, ffpa) then
    $include "mem0$lib/mkpkg.sf.SUN3"
$end
