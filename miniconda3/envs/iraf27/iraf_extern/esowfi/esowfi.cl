#{ ESOWFI.CL -- Script to set up tasks in the ESOWFI package

# Dependent packages.
mscred

package	esowfi

# Directories.

set	esodb = "esowfi$lib/esodb/"

# CL scripts with parameters:

task	esohdr = "esowfi$src/esohdr.cl"
task	esosetinst = "esowfi$src/esosetinst.cl"
#task	rmhierarch = "esowfi$src/rmhierarch.cl"
task	esohdrfix = "esowfi$src/esohdrfix.cl"

#hidetask rmhierarch
hidetask esohdrfix

clbye()
