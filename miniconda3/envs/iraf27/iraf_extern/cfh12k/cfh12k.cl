#{ CFH12K.CL -- Script to set up tasks in the CFH12K package

# Dependent packages.
mscred

package	cfh12k

# CL scripts with parameters:

task	hdrcfh12k = "cfh12k$src/hdrcfh12k.cl"
task	setcfh12k = "cfh12k$src/setcfh12k.cl"

clbye()
