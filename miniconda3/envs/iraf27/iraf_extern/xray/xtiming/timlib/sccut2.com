#JCC(1/99)- add comments
double  matrix[NCOMP, PCOEFF]   #NCOMP=50, PCOEFF=10 (lib/bary.h)
double  startt[NCOMP]
double  endt[NCOMP]
double  reftim[NCOMP]
double	sccadd[NCOMP]
long    ncoeff[NCOMP]
long	sc_nrows
common/sccut2_com/matrix,startt,endt,reftim,sccadd,ncoeff,sc_nrows
