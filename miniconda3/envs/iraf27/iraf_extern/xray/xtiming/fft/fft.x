#$Header: /home/pros/xray/xtiming/fft/RCS/fft.x,v 11.0 1997/11/06 16:44:31 prosb Exp $
#$Log: fft.x,v $
#Revision 11.0  1997/11/06 16:44:31  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:43  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:59  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:56  prosb
#General Release 2.2
#
#Revision 5.1  92/12/18  12:33:19  janet
#changed binlen to double precision.
#
#Revision 5.0  92/10/29  22:48:43  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  14:08:37  mo
#MC	10/22/92	Force closing of temp files for every pass of
#			a summed FFT
#
#Revision 4.0  92/04/27  15:32:24  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/13  14:43:46  mo
#MC	4/13/92		Move the conditional on summing inside
#			the sum subroutine
#			Always free the buffers
#
#Revision 3.3  92/02/20  17:39:05  mo
#MC	2/20/92		Add support for summed FFTS
#
#Revision 3.2  91/12/18  15:14:19  mo
#MC	12/18/91	No changes
#
#Revision 3.1  91/09/25  17:20:52  mo
#9/25/91	JD/MC	Update the calling sequences to support
#			a background file when using QPOE input as
#			well as TABLE input
#
#Revision 2.1  91/07/21  17:42:29  mo
#MC	7/21/91		Update calling sequence to get_distrib to support
#			better output table format for better plots
#
#Revision 2.0  91/03/06  22:43:36  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       fft
# Project:      PROS -- ROSAT RSDC
# Purpose:      perform a fast fourier transform on time binned xray events
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {1} JD -- Dec 92 -- changed binlen to double precision
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
#  main routine for the Fast Fourier Transform task

include	 "fft.h"


#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

procedure  t_fft ()

pointer	 critfile		# output file of significant power
pointer	 ctempfile		# temporary for critfile
pointer	 datacol		# input table data column to process
pointer	 fftfile		# output fft transform
pointer  histbuf		# pointer to history buffer
pointer	 histfile		# output power density histogram
pointer	 htempfile		# temporary for histfile
pointer	 ltcurv_file		# input light curve table file
pointer	 bkfile			# input background file
pointer	 phist			# output power density histogram
pointer	 sp			# stack pointer
#pointer	 tp			# input table pointer
pointer	 tempfile		# temporary for fft file

int	num_of_bins		# number of lightcurve input bins
int	display			# output display level
int	reflen			# number of FFT transform bins
int	len			# number of FFT transform bins
int	badseg
int	noseg			# total number of segments
int	segno
int	binsperseg
int	type
real	phistsize
int	phistno

double  binlen			# length of lightcurve bin
real	mean			# mean value for power density distribution

int	clgeti()
real	clgetr()

begin
	call smark (sp)

#	#  bin up the source photons

	call fftnames( ltcurv_file, bkfile, fftfile, critfile, histfile,
		       tempfile, htempfile, ctempfile , type)

        call salloc(datacol,SZ_PATHNAME,TY_CHAR)
        call clgstr( DATATYPE, Memc[datacol], SZ_PATHNAME)
	display = clgeti(DISPLAY)

	call salloc( histbuf, SZ_LINE, TY_CHAR)
	noseg = 1		# Set this to 1, until we find differently
	badseg = 0		# Init to 0
	segno = 1		# 
        binsperseg = 0          # jd - cause was remaining set to prev run
	reflen = 0
	num_of_bins = 0
	while( segno <= noseg )
	{	
	    call rd_ltcurv_file(Memc[ltcurv_file],Memc[bkfile],Memc[datacol],
				type,display, num_of_bins,binlen,segno,
				noseg,binsperseg,reflen,len)

		if( reflen == len ) {

#  compute the fft
	    	    call fas ( binsperseg)

	    	    if( display >= 1)
	    	    {
	        	call printf( " FFT done with %d bins!\n" )
	        	call pargi( len )
	        	call flush(STDOUT)
	    	    }


	        	call sum_transforms(len,segno)
                }
		else{
		    call printf("WARNING: Wrong number of bins - skipping segment\n")
		    call printf("refnumbins: %d current number bins: %d\n")
			call pargi(reflen)
			call pargi(len)
		    badseg = badseg + 1
		}
	    segno = segno + 1
	    if( noseg != 1 )
	        call dclose()
	}
	len = reflen
	if( segno > 2)
	    binsperseg = len
#	call mfree here for the buffers from sum_transforms, if noseg > 1
#	if( noseg > 1 ){  # Free buffers from sum_transforms
	    call sum_free()
#	}
	noseg = noseg - badseg
	phistsize = clgetr(PHISTBINSIZE)
	phistno	  = clgeti(PHISTBINNO)
	call calloc( phist, phistno, TY_INT)
	call sprintf(Memc[histbuf],SZ_LINE,"fft: %s %s %s")
	    call pargstr(Memc[ltcurv_file])
	    call pargstr(Memc[datacol])
	    call pargstr(Memc[fftfile])
	call printf("%s\n")
	    call pargstr(Memc[histbuf])
	    call flush(STDOUT)

	call inclose()

	call get_distrib ( display, Memc[histbuf], binlen, len, noseg, 
			   binsperseg, Memi[phist], phistsize, phistno, mean)
	call mfree(ltcurv_file,TY_CHAR)
	call mfree(bkfile,TY_CHAR)
	call wr_histtable( Memc[histbuf], Memc[htempfile], mean, 
			   Memi[phist], phistsize, phistno)

	call fftfinalnames(display,tempfile,fftfile,htempfile,
			   histfile,ctempfile,critfile)

	call mfree(phist,TY_INT)
#	call inclose()
	if( noseg == 1 )
	    call dclose()
	call sdclose()
	call pclose()
	call sfree (sp)
end

