# Global MKPKG definitions for the package.

$set XFLAGS	= "$(XFLAGS) -p esowfi"
$set XVFLAGS	= "$(XVFLAGS) -p esowfi"
$set LFLAGS	= "$(LFLAGS) -p esowfi"

#$ifeq (MACH, sparc) then
#    $include "esowfi$lib/mkpkg.sf.SUN4"
#$else $ifeq (MACH, i386) then
#    $include "esowfi$lib/mkpkg.sf.I386"
#$else $ifeq (MACH, f68881) then
#    $include "esowfi$lib/mkpkg.sf.SUN3"
#$else $ifeq (MACH, ffpa) then
#    $include "esowfi$lib/mkpkg.sf.SUN3"
#$else $ifeq (MACH, vms) then
#    $include "esowfi$lib/mkpkg.sf.VMS"
#$else $ifeq (MACH, ddec) then
#    $include "esowfi$lib/mkpkg.sf.DDEC"
#$else $ifeq (MACH, dmip) then
#    $include "esowfi$lib/mkpkg.sf.DMIP"
#$else $ifeq (MACH, rs6000) then
#    $include "esowfi$lib/mkpkg.sf.AIX3"
#$else $ifeq (MACH, mips) then
#    $include "esowfi$lib/mkpkg.sf.MIPS"
#$end
