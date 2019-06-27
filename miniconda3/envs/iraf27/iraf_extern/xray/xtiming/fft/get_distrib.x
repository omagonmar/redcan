#$Header: /home/pros/xray/xtiming/fft/RCS/get_distrib.x,v 11.0 1997/11/06 16:44:37 prosb Exp $
#$Log: get_distrib.x,v $
#Revision 11.0  1997/11/06 16:44:37  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:54  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:22  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/19  17:18:49  mo
#MC	5/19/94		Fix bug that 'unnormalized' the user-power threshold
#			after it had been correctly normalized (sigh)
#
#Revision 7.0  93/12/27  19:01:18  prosb
#General Release 2.3
#
#Revision 6.1  93/12/17  10:38:29  mo
#MC	11/10/93	Fix the PWRCUT header parameter to output
#			normalized units
#
#Revision 6.0  93/05/24  16:57:19  prosb
#General Release 2.2
#
#Revision 5.3  93/05/20  08:49:24  mo
#MC	5/20/93		Fix NYQUIST FREQ calculation and fix SUMMED
#			FFT for < 512 bins
#
#Revision 5.2  93/02/04  17:59:31  mo
#MC	1/1/93		add normalized power cutoff calculations
#			Make some variables Double Precision
#
#Revision 5.1  92/12/18  12:37:13  janet
#changed binlen to double, added temp equation and took calc out of pwr_write subroutine call line.
#
#Revision 5.0  92/10/29  22:48:59  prosb
#General Release 2.1
#
#Revision 4.2  92/10/22  14:14:03  mo
#MC	10/22/92	Fix the 'nf' power bin for short transforms just
#			as the coefficients have already been done.
#
#Revision 4.1  92/08/27  11:19:24  mo
#MC		8/27/92		Made fix to find the highest frequency bin
#				for FFT with fewer than 1024 bins.
#
#Revision 4.0  92/04/27  15:32:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  14:53:49  mo
#MC	4/13/92		Change code because the power was calculated
#			previously from the fft coefficients, so don't
#			need to do it here.
#
#Revision 3.1  91/12/18  15:16:07  mo
#MC	12/18/91	Add the NUMBINS and NUMCOEFFS output
#			for the TABLE File
#
#Revision 3.0  91/08/02  02:01:32  prosb
#General Release 1.1
#
#Revision 2.2  91/07/21  17:46:14  mo
#MC	7/21/91		Update to calculate normalized power for
#			all output tables and produce better table headers
#
#Revision 2.1  91/06/10  11:07:17  mo
#MC	3/91		Remove significance calculation for summed FFTS
#			for now til we understand better - its very slow
#			and noone seems to be using it.
#
#Revision 2.0  91/03/06  22:43:59  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       get_distrib
# Project:      PROS -- ROSAT RSDC
# Purpose:      support routines for the fast fourier transform
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
#########################################################################

include	<mach.h>
include	"fft.h"

procedure  get_distrib ( display, histbuf, binlen, nbins, noseg, binsperseg, 
                         phist, phistsize, phistno, mean)

int	display			# i: output display level
#char	critfile[ARB]		# i: output file for critical powers
char	histbuf[ARB]		# i: history buffer
#char	fftfile[ARB]		# i: output fft result file
int	binsperseg		# i: number of bins per fft segment
int	lastrec			# l: counter for LAST record
int	currec			# l: current internal fft record counter
int	nbins			# i: number of bins for FFT ( power of 2)
int	noseg			# i: total number of segments
int	nf			# l: nyquist frequency
int	j			# l: loop indices
double  binlen			# i: no secs per bin

real	phistsize		# i: 
int	phistno			# i:
real	mean			# o: fft power mean
int	phist[ARB]	        # o: output fft power histogram	

int	binno			# l: current fft ( power ) bin number
#int	cts			# l: number of counts in distribution
int	valid			# l: count of valid values
real	hmean			# l: diff mean normalization for power histogram
real	ffactor			# l: freq factor for header
real	norm			# l: power normalization factor
double	ptest			# l: power test value for significance
pointer	transform		# l: temp storage for fft transform
pointer	temptran		# l: temp storage for fft transform
pointer powerdist		# l: fft output power distribution
#pointer	ptr,get_intab()
#int	type

begin
	call malloc (powerdist, HALFNELEM , TY_REAL)
	call malloc (transform, NELEM , TY_REAL)
# Counting from zero and not 1
#	nf = nbins/2+1
## new	
	nf = nbins/2
	currec = 1
# Only the first half of the FFT result is meaningful
#   ( Not that for small FFT's, a minimum of 3 records will be used. The
#	first record for the first N/2 values and record 3 for N/2+1)
#		See notes in for2d.f
## new	
	while( HALFNELEM*(currec-1) <= nf )
#	while( HALFNELEM*(currec-1) < nf )
	{
#       Read the next buffer full of FFT results
	    call aclrr (Memr[transform], NELEM)
	    call aclrr (Memr[powerdist], HALFNELEM)
#  Power is now calculated before this routine and saved in TEMP file using 
#	pread/write
	    call pread( currec, Memr[powerdist], 1, HALFNELEM)
	    if( noseg == 1)
	        call dread( currec, Memr[transform], 1, HALFNELEM)
	    else
	        call sdread( currec, Memr[transform], 1, HALFNELEM)
	    valid = 0
	    do j = 1, HALFNELEM
	    {
	        if( currec == 1 && j == 1 )
	        {
#		Determine power normalization and significant power 
#		critical values
		    ffactor = 1.0D0 / (binlen * double(nbins))
		    call init_power(display, Memr[powerdist], nbins, noseg, 
				    mean, hmean, norm, ptest)
		    call pwr_cheader("XHISTF",histbuf)
	            call fft_cheader("XHISTF",histbuf)
		    call gap_cheader()
#		    cts = sqrt(nbins*hmean) + 0.5E0
#		    call printf("hmean: %f cts: %d\n")
#			call pargr(hmean)
#			call pargi(cts)
	        }
# FORCE binno's to start from 0
#  11/29/89
	        binno = ( currec-1) * HALFNELEM + j - 1
### Move this to sum_trans
#  Special index for the LAST value 
## new
		if( binno == nf ){
#		if( binno == nf-1 ){
		    lastrec = max(currec,(binno-1) / NELEM + 1 + NELEM/HALFNELEM)
		    if( lastrec != currec ){
			call calloc (temptran, NELEM , TY_REAL)
			if( noseg == 1 )
		            call dread( lastrec, Memr[temptran], 1, HALFNELEM )
			else
		            call sdread( lastrec, Memr[temptran], 1, HALFNELEM )
			Memr[transform+2*(j-1)] = Memr[temptran]
			Memr[transform+2*(j-1)+1] = Memr[temptran+1]
			call mfree(temptran,TY_REAL)
		    }
		}
### moved to sum_trans
## new	        
		if( binno <= nf )
#	        if( binno <=  nf-1 )
		{
#		Calculate the power and save the significant power bins
		    call calc_power( hmean, mean, binno, nbins, noseg, binlen, 
				     ptest, j, Memr[powerdist], phist,
				     phistsize, phistno, norm)
		    valid = valid+1
		}
	     }
#       Save the fft transform and power density distribution
	     call fft_write( Memr[transform], Memr[powerdist], valid, 
                             ffactor, norm)
	     currec = currec + 1
	}
#	Save the output headers and free the buffers
	call fft_rheader("FREQFAC",ffactor)
#	totcnts = N/norm
#	cts = nbins/norm + 0.5E0
#	ptr = get_intab(type)
#	if( TYPE != TABLE){
#	    call fft_iheader("TOTCNTS",cts)
#	    call pwr_iheader("TOTCNTS",cts)
#	    call ftp_iheader("TOTCNTS",cts)
#	}
## new	
	call fft_iheader("NUMCOEFFS",nf+1)
#	call fft_iheader("NUMCOEFFS",nf)
	call fft_iheader("NUMBINS",nbins)
	call ftp_iheader("NUMBINS",nbins)
	call pwr_iheader("NUMBINS",nbins)
	call fft_close(no_seg)
	call pwr_close()
	#call close_bin()
#	call inclose()
	call mfree (transform, TY_REAL)
	call mfree (powerdist, TY_REAL)
#	call mfree (transform, TY_REAL)
end

#########################################################################

procedure  wr_histtable( histbuf,histfile,mean,phist,phistsize,nbins )

char	histbuf[ARB]		# i: history buffer
char	histfile[ARB]		# i: histogram file name
int	nbins			# i: number of histogram bins
int	phist[ARB]		# i: power distribution
real	mean			# i: mean of power density
real	phistsize		# i: size of histogram bin

begin
	call ftp_write(phist,phistsize,nbins,mean)
	call ftp_close()
end

procedure init_power(  display, powerdist, nbins, noseg 
		      mean, hmean, norm, ptest )
int	display			# i: output display level
#char	fftfile[ARB]		# i: requested fft output file
#char	critfile[ARB]		# i: requested critical power output file
real	powerdist 		# i: FFT array
int	nbins			# i: number of bins in transform
int	noseg			# i: number of summed segments

real	mean			# o: distribution mean
real	hmean			# o: histogram mean
real	norm		        # o: power normalization factor
double	ptest			# o: critical value for significant power test

int	nf			# l: nyquist frequency bin no
double	utest			# l: user requested threshold
double	conf			# l: requested confidence levels

double	clgetd()
double	calc_crit()

begin
#  We're counting from zero
##new	nf = nbins / 2 
	nf = nbins / 2 + 1
#	mean =  transform[1] * transform[1] + transform[2] * transform[2] 
	mean =  powerdist
	if( mean == 0.0 )
	    mean = 1.0
	norm = sqrt(float(nbins)/mean)
#    mean normalization for power histogram
#	hmean = sqrt(mean)		# obsolete
#    use FAP's normalization
#	hmean = sqrt(nbins/mean)
#    use POWER0
	hmean = mean
#    mean normalization for power density distribution
	mean  = sqrt( mean / real(nbins) )
#    initialize output files
#	call pwr_open(critfile)
#	call fft_open(fftfile)
	ptest = clgetd(POWERTHRESH)
#  ALWAYS calculate the statistical levels, but don't use
#  them if the use specifies his own value ( > 0 )
#	if( ptest < 0.0 ){
#    Compute 5 predetermined significant values
	utest = ptest
	    conf = .995D0
	    ptest = calc_crit( display, conf, nf, mean, noseg)
	    call pwr_dheader("CONFID5",conf)
	    call pwr_dheader("PWRCUT5",ptest)
	    ptest = ptest * norm
	    call pwr_dheader("NPWRCUT5",ptest)
	    conf = .95D0
	    ptest = calc_crit( display, conf, nf, mean, noseg)
	    call pwr_dheader("CONFID4",conf)
	    call pwr_dheader("PWRCUT4",ptest)
	    ptest = ptest * norm
	    call pwr_dheader("NPWRCUT4",ptest)
	    conf = .90D0
	    ptest = calc_crit( display, conf, nf, mean, noseg)
	    call pwr_dheader("CONFID3",conf)
	    call pwr_dheader("PWRCUT3",ptest)
	    ptest = ptest * norm
	    call pwr_dheader("NPWRCUT3",ptest)
	    conf = .80D0
	    ptest = calc_crit( display, conf, nf, mean, noseg)
	    call pwr_dheader("CONFID2",conf)
	    call pwr_dheader("PWRCUT2",ptest)
	    ptest = ptest * norm
	    call pwr_dheader("NPWRCUT2",ptest)
	    conf = .50D0
	    ptest = calc_crit( display, conf, nf, mean, noseg)
	    call pwr_dheader("CONFID",conf)
	    call pwr_dheader("PWRCUT1",ptest)
	    ptest = ptest * norm
	    call pwr_dheader("NPWRCUT1",ptest)
	if( utest > 0.0 )
	{
	    ptest = utest 
	    call pwr_dheader("NPWRCUT",ptest)
	    utest = utest /  norm
	    call pwr_dheader("PWRCUT",utest)
	}
#	}
#########	else
end


procedure calc_power( hmean, mean, binno, nbins, noseg, binlen, ptest, index, 
		      powerdist, phist, phistsize, phistno, norm)
real	hmean		# i: histogram mean
real	mean		# i: fft transform mean
int	binno		# i: current bin no
int	nbins		# i: number of bins
int	noseg		# i: number of segments
double  binlen		# i: length of input ltcurv bin
double	ptest		# i/o: critical value for significant power
int	index		# i: current index
real	powerdist[ARB]	# i: power 
int	phist[ARB]	# o: power histogram
real	phistsize	# i:
int 	phistno		# i 
real	norm		# i: power normalization factor

#int	i
#int	ifact		# l: computation of factorial
int	pindex		# l: phist index
int	nf		# l: nyquist frequency
double	pd		# l: power density
real	normpower	# l: normalized power density
real    temp 
#double  pd1		# l: power density with alternate normalization
#real	p0
#double  sum		# l: temp summation
#double  pdmean		# l: pd/mean
#double	dexp()
#double  temp

begin
	nf = nbins/2 + 1
	pd = powerdist[index]
#	pd = transform[1,index] * transform[1,index] + 
#	         transform[2,index] * transform[2,index]
#	powerdist[index] = pd 
#	if( binno == 0 ){
#	    norm = sqrt(float(nbins)/pd)
#	    if( ptest < 0.0D0 )
#		ptest = abs(ptest) * dble(norm)
#	}
	normpower = pd * dble(norm)
#	pd1 = sqrt( pd ) / hmean
#	pd1 = sqrt( pd ) / mean
#        pindex = pd1*pd1*nf + 1 
	pindex = dble(normpower) / dble(phistsize) + 1
        if( (pindex > 0) && (pindex <= phistno ) )
	    phist[pindex] = phist[pindex] + 1
#	if( noseg == 1){
	    if( normpower > ptest ) {
                temp = double(binno) / (binlen*double(nbins))
		call pwr_write(binno,temp,powerdist[index],normpower)
            }
#	}
#	else{
#	    ifact= 1
#	    sum = 0.0D0
#	    pdmean = pd/mean
#	    do i=0,noseg-1
#	    {
#	        if( i >= 1)
#		    ifact = ifact * i
#	        sum = sum + (pdmean**i)/dble(ifact) 
#	    }
#	    temp = dexp(-pdmean)*sum 
#	    if( 1.0D0 - temp > ptest )
#	    if( 1.0D0 - dexp(double(-pdmean))*sum  > ptest )
# 	        call pwr_write(binno,binno/(binlen*nbins),powerdist[index])
#	}
end

double procedure calc_crit( display, conf, nf, pzero, noseg)
int	display		# i: output display level
double	conf		# i: confidence value for power significance
int	nf		# i: nyquist frequency
real	pzero		# i: mean power density
int	noseg		# i: number of summed segments

double	ptest		# o: output critical power value for specified 
			#     confidence

begin
	if( noseg == 1)
	    ptest = - pzero * log( 1.0D0 - dexp(dlog(conf)/dble(nf)) )
	else{
	    ptest = (conf) ** (1.0D0/double(nf))
#	    ptest = dexp(dlog(conf)/dble(nf))
	}
	if( display >= 2 )
	{
	    call printf("conf: %f crit power density: %f\n")
	    call pargd(conf)
	    call pargd(ptest)
	}
	return( ptest )
end

