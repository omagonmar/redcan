# $Header
# $Log
# Description : common block for simevt program
#
long seed               # sed for random number generator
common/rndcom/seed
