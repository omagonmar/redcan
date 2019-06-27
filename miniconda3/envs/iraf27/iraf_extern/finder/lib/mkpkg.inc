# Global MKPKG definitions for the FINDER package.

$set XFLAGS	= "$(XFLAGS) -z -p finder"
$set XVFLAGS	= "$(XVFLAGS) -z -p finder"
$set LFLAGS	= "$(LFLAGS) -z -p finder"

# Uncomment and modify the following to add special file list entries for
# various machine architectures and Fortran compilers.

# $ifeq (MACH, sparc) then
# $include "local$lib/mkpkg.sf.sun4"
# $else $ifeq (MACH, vms) then
# $include "local$lib/mkpkg.sf.vms"
# $end
