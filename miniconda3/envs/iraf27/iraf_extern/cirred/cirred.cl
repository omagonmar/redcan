#
# CTIO IR reduction package.
#

#
# 25 may 99. RDB. 
# 13 dec 07. RDB. Add do_osiris.cl meta script, atmo_cor, extra, and spec_comb
#

noao
digiphot
digiphot.daophot
apphot
twod
long

package cirred

# set cirred = "/uwe0/blum/IRAF/scripts/"

task clearim    = cirred$clearim.cl
task maskbad    = cirred$maskbad.cl
task osiris     = cirred$osiris.cl
task do_osiris  = cirred$do_osiris.cl
task atmo_cor   = cirred$atmo_cor.cl
task spec_comb  = cirred$spec_comb.cl
task extra      = cirred$extra.cl
task shift_comb = cirred$shift_comb.cl
task sky_sub    = cirred$sky_sub.cl
task med	= cirred$med.cl
task do_wcs	= cirred$do_wcs.cl
task do_ccmap	= cirred$do_ccmap.cl
task irdiff	= cirred$irdiff.cl

# JT: These build but I'm not sure whether they're working properly on 2.15.
# In PyRAF On OSX, I get ('Not a legal IRAF pipe record', 32, 'Broken pipe').
task $fixfits   = cirred$bin/fixfits.e
#task $fixfitsMEF = cirredbin/fixfitsMEF.e
task $fixbad    = cirred$bin/fixbad.e
task $calc_off  = cirred$bin/calc_off.e

keep

clbye()
