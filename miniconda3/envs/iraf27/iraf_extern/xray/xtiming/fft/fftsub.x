#$Header: /home/pros/xray/xtiming/fft/RCS/fftsub.x,v 11.0 1997/11/06 16:44:33 prosb Exp $
#$Log: fftsub.x,v $
#Revision 11.0  1997/11/06 16:44:33  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:40:09  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:01:04  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:57:03  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:48  prosb
#General Release 2.1
#
#Revision 4.1  92/10/22  14:10:52  mo
#MC	10/22/92	Force a 'calloced' work space for EACH run of
#			the FFT algorithm.  This appears to be required
#
#Revision 4.0  92/04/27  15:32:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  14:45:22  mo
#MC	4/13/92		Add code to prohibit specifying a background
#			file when doing a summed fft ( force it to NONE)
#
#Revision 3.1  91/09/25  17:21:53  mo
#MC	9/25/91		Add a case for 3rd type of input file - a list
#			of input files.  This was broken when the QPOE
#			option was added.
#
#Revision 2.1  91/07/21  17:44:30  mo
#MC	7/21/91		Add calls to get full header on the _ftp output file
#			to support labels on timplot output
#
#Revision 2.0  91/03/06  22:43:44  pros
#General Release 1.0
#
# -------------------------------------------------------------------------
# Module:       fftsub
# Project:      PROS -- ROSAT RSDC
# Purpose:      support routines for the fast fourier transform
# Description:  
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1990.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Maureen Conroy initial version  August 1990
#               {1} Mc -- Allow both qpoe and table input files  -- Jan 1991 
#               {n} <who> -- <does what> -- <when>
#
# -------------------------------------------------------------------------
#  main routine for the Fast Fourier Transform task

include	 "fft.h"
include  <ext.h>

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  This routine sets up the call to some library routine to
#  compute the FFT.

procedure fas ( nbins )

int	nbins				# bins in the FFT
int	log2n[2]			# 
int	ndim				#
int	isgn				#
int	iform				#
int	ll2nel				#
int	ierr				# error code
#complex	work[2,HALFNELEM]		# work array
#real	work[4,NELEM]
pointer work
begin
#	call printf (" Computing FFT using %d bins.\n")
#	    call pargi( nbins )

#	call aclrr(work,NELEM)
	log2n[1] = nint(log(float(nbins))/log(2.0))
	log2n[2] = 0
	ndim = 1
	isgn = -1
	iform = 0
	ll2nel = L2NEL
	call calloc(work,4*NELEM,TY_REAL)
	call for2d ( log2n, ndim, isgn, iform, Memr[work], ll2nel, ierr)

	if( ierr != 0 )  {
	    call printf( " FOR2D error return = %d\n" )
	    call pargi( ierr )
	    }
	call mfree(work,TY_REAL)
end

procedure fftnames( ltcurv_file, bk_file, fftfile, critfile, histfile,
		       tempfile, htempfile, ctempfile, type)

pointer	 critfile	# i/o: output significant power filename string
pointer	 ctempfile	# i/o: temp significant power filename string
pointer	 fftfile	# i/o: output fft filename string
pointer	 histfile	# i/o: output power histogram filename string
pointer	 htempfile	# i/o: temp power histogram filename string
pointer	 ltcurv_file	# i/o: input filename string
pointer	 bk_file	# i/o: input bkgd filename string
pointer	 tempfile	# i/o: temp fft filename strig
int	index
int	type		# o: input file type: TABLE or QPOE	

bool	clobber		# l: OK to clobber?
pointer	sp
pointer	tabfile
pointer fileroot, ksection

bool	none,ck_none()
bool	clgetb()	 
bool	access()
bool	outfft
	common/outf/outfft
int	strmatch()

begin
	call smark(sp)
	call malloc(ltcurv_file,SZ_PATHNAME,TY_CHAR)
	call rootname(Memc[ltcurv_file],Memc[ltcurv_file],EXT_LTC,SZ_PATHNAME)
	call malloc(bk_file,SZ_PATHNAME,TY_CHAR)
	call malloc(fftfile,SZ_PATHNAME,TY_CHAR)
	call malloc(critfile,SZ_PATHNAME,TY_CHAR)
	call malloc(histfile,SZ_PATHNAME,TY_CHAR)
	call malloc(tempfile,SZ_PATHNAME,TY_CHAR)
	call malloc(htempfile,SZ_PATHNAME,TY_CHAR)
	call malloc(ctempfile,SZ_PATHNAME,TY_CHAR)

	call salloc(tabfile,SZ_PATHNAME,TY_CHAR)
        call salloc (fileroot, SZ_LINE,     TY_CHAR)
        call salloc (ksection, SZ_FNAME,    TY_CHAR)

	call clgstr( SOURCEFILENAME, Memc[ltcurv_file], SZ_PATHNAME)
	call clgstr( FFTFILENAME, Memc[fftfile], SZ_PATHNAME)
	call strcpy("",Memc[histfile],SZ_PATHNAME)
	call strcpy("",Memc[critfile],SZ_PATHNAME)
	call strcpy(Memc[ltcurv_file],Memc[tabfile],SZ_PATHNAME)

# Check if input is QPOE file, or lightcurve table file
	index = strmatch(Memc[ltcurv_file],"@")
	if( index == 2 ) 
	    type = LIST
	else{
	    call rootname(Memc[ltcurv_file],Memc[ltcurv_file],EXT_LTC,SZ_PATHNAME)
	    index = strmatch(Memc[ltcurv_file],".qp")
	    if( index == 0 ){
	        type = TABLE
	        call printf("Looking for TABLE input file: %s\n")
	          call pargstr(Memc[ltcurv_file])
	    }
	    else{
	        type = QPOE
	        call printf("Looking for QPOE input file: %s\n")
	          call pargstr(Memc[ltcurv_file])
	    }
	}
	if( type != LIST ){
	if( !access( Memc[ltcurv_file], READ_ONLY, BINARY_FILE) || type == QPOE){
	    call rootname(Memc[tabfile],Memc[tabfile],EXT_STI,SZ_PATHNAME)
	    if( type == TABLE )
	        call printf("TABLE file not available --- \n")
#	    call printf("   Looking for QPOE input file: %s\n")
#		call pargstr(Memc[tabfile])
#	    call strcpy(Memc[tabfile],Memc[ltcurv_file],SZ_PATHNAME)
	    call clgstr( BKGRDFILENAME, Memc[bk_file], SZ_PATHNAME)
	    none = ck_none(Memc[bk_file])
	    if( !none )
	      call rootname( Memc[bk_file], Memc[bk_file], EXT_BTI, SZ_PATHNAME)
	    type = QPOE
#  - jd added qpparse call to check if file exist without filter attached
             call qpparse(Memc[tabfile], Memc[fileroot], SZ_PATHNAME,
                          Memc[ksection], SZ_FNAME)

#           if( !access( Memc[tabfile], READ_ONLY, BINARY_FILE) ){
            if( !access( Memc[fileroot], READ_ONLY, BINARY_FILE) ){
		call eprintf("Neither TABLE nor QPOE input file exists\n")
		call eprintf("Table file: %s QPOE file: %s\n")
		    call pargstr(Memc[tabfile])
		    call pargstr(Memc[ltcurv_file])
		call error(FFT_FATAL,"Input file does not exist")
	    }
	    call strcpy(Memc[tabfile],Memc[ltcurv_file],SZ_PATHNAME)
	}
	} else{	# type is LIST
	    call clgstr( BKGRDFILENAME, Memc[bk_file], SZ_PATHNAME)
	    none = ck_none(Memc[bk_file])
	    if( !none )
	      call error(FFT_FATAL,"No background allowed for list input for summed FFT")
	}
	call rootname(Memc[ltcurv_file],Memc[fftfile],EXT_FFT,SZ_PATHNAME)
	call rootname(Memc[fftfile],Memc[histfile],EXT_FTP,SZ_PATHNAME)
	call rootname(Memc[fftfile],Memc[critfile],EXT_PWR,SZ_PATHNAME)

	clobber = clgetb(CLOBBER)
	outfft = clgetb("fftcoeff")
	if( outfft)
	    call clobbername(Memc[fftfile],Memc[tempfile],clobber,SZ_PATHNAME)
	call clobbername(Memc[histfile],Memc[htempfile],clobber,SZ_PATHNAME)
	call clobbername(Memc[critfile],Memc[ctempfile],clobber,SZ_PATHNAME)
	call fft_open(outfft,ltcurv_file,bk_file,tempfile)
	call pwr_open(ltcurv_file,bk_file,ctempfile)
	call ftp_open(ltcurv_file,bk_file,htempfile)
	call sfree(sp)
end

procedure fftfinalnames(display,tempfile,fftfile,htempfile,
			   histfile,ctempfile,critfile)
int	display		# i: output display level
pointer	tempfile
pointer	fftfile
pointer	htempfile
pointer	histfile
pointer	ctempfile
pointer	critfile

bool	outfft
	common/outf/outfft
begin
	if( display >= 1 )
	{
	    if( outfft){
	    call printf("Creating raw fft output file: %s\n")
		call pargstr(Memc[fftfile])
	    }
	    call printf("Creating histogram output file: %s\n")
		call pargstr(Memc[histfile])
	    call printf("Creating fft power output file: %s\n")
		call pargstr(Memc[critfile])
	}
	
	call finalname(Memc[htempfile],Memc[histfile])
	call finalname(Memc[ctempfile],Memc[critfile])
	call mfree(htempfile,TY_CHAR)
	call mfree(ctempfile,TY_CHAR)
	call mfree(histfile,TY_CHAR)
	call mfree(critfile,TY_CHAR)
	if( outfft )
	    call finalname(Memc[tempfile],Memc[fftfile])
	call mfree(fftfile,TY_CHAR)
	call mfree(tempfile,TY_CHAR)
end

