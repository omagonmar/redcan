#!/bin/csh
#
# This script has been created to get and install dfits and fitsort for MAC
# users

set your_software_path = $1 
cd ${your_software_path}
wget http://archive.eso.org/saft/dfits/dfits.c 
wget http://archive.eso.org/saft/fitsort/fitsort.c 
gcc -o dfits dfits.c 
gcc -o fitsort fitsort.c 
sudo cp dfits fitsort /usr/local/bin 
