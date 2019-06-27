# RV_CORREL -  Computes the correlation of two real data sets DATA1 and DATA2,
# each of length N including any user supplied zero padding.  N must be an
# integer power of two.  The answer is returned as the first N points in ANS
# stored in wraparound order, i.e. correlations at increasingly negative lags
# are in ANS(N) down to ANS(N/2+1), while correlations at increasingly pos-
# itive lags are in ANS(1) (zero lag) on up to ANS(N/2).  Note that ANS must
# be supplied in the calling program with length at least 2*N since it is also
# used as a working space.  Sign convention of this routine, if DATA1 lags 
# DATA2, i.e. is shifted to the right of it, then ANS will show a peak at 
# positive lags.
# Referece:  Numerical Recipes in C, ch 12, Press, et al.
# RV_ANTISYM -- Compute antisymmetric part of correlation function.
# RV_NORMALIZE -- Normalize data for correlation by dividing by the rms
# of the data.

###  Proprietary source code removed  ###
