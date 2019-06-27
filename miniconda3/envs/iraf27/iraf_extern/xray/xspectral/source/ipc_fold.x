#$Header: /home/pros/xray/xspectral/source/RCS/ipc_fold.x,v 11.0 1997/11/06 16:42:25 prosb Exp $
#$Log: ipc_fold.x,v $
#Revision 11.0  1997/11/06 16:42:25  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:32:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:01  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:51  prosb
#General Release 2.2
#
#Revision 5.1  93/01/22  11:08:32  orszak
#jso - this is a fix to deal with improper saves.  see bug report for more
#      details.
#
#Revision 5.0  92/10/29  22:44:50  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:44  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:25:18  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:06:20  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:28  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:16:38  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:04:08  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   ipc_fold.x   ---   fold spectrum through the detector(s)
# revision dmw Oct 1988 -- intermediate spectra are logarithmic
#                          cnv_photons_to_phas routine changes from log to linear

include	<mach.h>

include  <spectral.h>

#  parameter string definitions

define  SPATIAL_PRF_SIGMAS     "spatial_prf_sigmas"

define PHAS	16

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  create pha spectrum and correct for finite spatial resolution

procedure ipc_fold( parameters, photon_spectrum, nbins)

pointer parameters		# parameter data structure
pointer spectrum		# pha output spectrum
int     dataset,  nbins,  nphas
real	source_radius
real    chancor[MAX_PHA_BINS]
double	photon_spectrum[ARB]

# everything in SPP is save'd, so this is not necessary (and no good on vax)
# static  chancor

begin
	dataset  = FP_CURDATASET(parameters)
	nphas    = DS_NPHAS(FP_OBSERSTACK(parameters,dataset))
	spectrum = DS_PRED_DATA(FP_OBSERSTACK(parameters,dataset))
	source_radius = DS_SOURCE_RADIUS(FP_OBSERSTACK(parameters,dataset))

	call aclrr ( Memr[spectrum], nphas )
	call conv_photons_to_phas(parameters, photon_spectrum, nbins,
				  Memr[spectrum], nphas)

	# correct for counts lost due to finite spatial resolution
	#
	call fetch_chancor(source_radius, chancor)
	call amulr (Memr[spectrum], chancor, Memr[spectrum], nphas)
end



procedure  conv_photons_to_phas(parameters, photons, nbins, phas, nphas)

pointer parameters
double	photons[nbins]
int	nbins
real	phas[nphas]
int	nphas
#--

double	unlogged[SPECTRAL_BINS]


int	i, bin, pha
double	rebinned[RESPONSE_MATRIX]

bool	init
real    probab[RESPONSE_MATRIX,MAX_PHA_BINS]
real	edges[RESPONSE_MATRIX + 1]

# static  probab, edges

data	init	/ FALSE /

begin
	if ( !init ) {
		# Build a set of edges that corospond to the response matrix
		#
		do i = 1, RESPONSE_MATRIX + 1
			edges[i] = RESPONSE_MATRIX_BASE -
					RESPONSE_MATRIX_STEP / 2 +
				RESPONSE_MATRIX_STEP * ( i - 1 )
		init = TRUE
	}


	call fetch_probab(parameters, probab)

	call unlog_array(photons, unlogged, nbins)
	call rebin_model(unlogged, rebinned, edges, RESPONSE_MATRIX)

	# Rebinnned Vector x Response Matrix
	#
	do bin = 1, RESPONSE_MATRIX
		    do pha = 1, nphas
			phas[pha] = phas[pha] +
				rebinned[bin] * probab[bin,pha]
end




#  compute channel correction due to finite spatial resolution

procedure  fetch_chancor( source_radius, chancor )

bool	have_sigmas

char	fname[SZ_FNAME]
char	datafile[SZ_FNAME]

int	bin

real	x
real	source_radius
real	old_source_radius
real	chancor[ARB]
real	spatial_prf_sigmas[MAX_PHA_BINS]

# everything in SPP is save'd, so this is not necessary (and no good on vax)
# static have_sigmas,  old_source_radius,  spatial_prf_sigmas

data   have_sigmas        /FALSE/
data   old_source_radius  /-1.0/

bool	strne()

begin

	# read in the data file names; if they have changed we want to
	# reinitalize.

	call strcpy(datafile, fname, SZ_FNAME)
	call clgstr(SPATIAL_PRF_SIGMAS, datafile, SZ_FNAME)
	if ( strne(fname, datafile) )
	    have_sigmas = FALSE

	if ( !have_sigmas ) {
	    have_sigmas = TRUE
	    call rd_sps ( spatial_prf_sigmas, MAX_PHA_BINS )
#	    bin = 1
#	    while(  bin<=MAX_PHA_BINS    &&
#		clglpr(SPATIAL_PRF_SIGMAS,spatial_prf_sigmas[bin])!=EOF  )
#		bin = bin+1
	}
	if ( source_radius != old_source_radius ) {
	    old_source_radius = source_radius
	    do bin = 1, MAX_PHA_BINS {
		if ( source_radius == 0.0 ) {
		    chancor[bin] = 1.0
		}
		else {
		    x = source_radius*PIXELS_PER_ARCMIN/spatial_prf_sigmas[bin]
		    chancor[bin] = 1.0 - exp(-x*x/2.0)
		}
	    }
	}
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  fetch probabilities
#
#  return the response matrix for the Einstein IPC for a given BAL.

procedure  fetch_probab( parameters, probab )

bool	init

int	dataset				# observation data set number
int	entry				# lopping index
int	entries				# number of BAL entries

real	arcfrac				# arcing fraction
real	probab[ARB]			# matrix of probabilities
real	new_bal[2*MAX_BAL_ENTRIES+1]	#
real	old_bal[2*MAX_BAL_ENTRIES+1]	#
real	current_bal			#
real	percent				#

pointer	parameters			# parameters data structure
pointer	bal_histogram			# bal data structure

bool	compare_bal()

# everything in SPP is save'd, so this is not necessary (and no good on vax)

data	init	/ FALSE /

begin

	#-------------------------------------------------------------
	# I made old_bal and new_bal arrays because I want them to be
	# saved.  This may not be the most elegant way to do this in SPP,
	# but spectral is not elegant.
	#----------------------------------------------------------------

	dataset = FP_CURDATASET(parameters)
	bal_histogram = DS_BAL_HISTGRAM(FP_OBSERSTACK(parameters,dataset))

	#------------------------------------------------------------------
	# if we already have a bal that was used (old_bal) make the present
	# a copy of the present bal to test against
	#-------------------------------------------------------------------
	if ( init ) {
	    entries = BH_ENTRIES(bal_histogram)
	    new_bal[1] = real(entries)
	    do entry = 1, entries  {
		new_bal[entry+1] = BH_BAL(bal_histogram,entry)
		new_bal[entry+2] = BH_PERCENT(bal_histogram,entry)
	    }
	}
	    
	#-----------------------------------------------------------
	# if the bal has not been initialized or if the bals are
	# different recalculate the probability and the value of
	# old_bal (i.e., the bal that was used to calculate the probab
	#-------------------------------------------------------------
	if ( !init || !compare_bal(old_bal, new_bal) ) {
	    call aclrr(probab, RESPONSE_MATRIX*MAX_PHA_BINS)
	    arcfrac = DS_ARCFRAC(FP_OBSERSTACK(parameters,dataset))
	    entries = BH_ENTRIES(bal_histogram)
	    old_bal[1] = real(entries)
	    do entry = 1, entries  {
		current_bal = BH_BAL(bal_histogram,entry)
		percent     = BH_PERCENT(bal_histogram,entry)
		call calc_probab( current_bal, percent, probab, arcfrac)
		old_bal[entry+1] = current_bal
		old_bal[entry+2] = percent
	    }
	    init = TRUE
	}

end

bool procedure compare_bal(old_bal, new_bal)

bool	same

int	entry
int	entries

real	old_bal[ARB]
real	new_bal[ARB]

begin

	same = TRUE

	if ( int(old_bal[1]) == int(new_bal[1]) ) {
	    entries = int(old_bal[1])
	    do entry = 1, entries {
		if ( abs(old_bal[entry+1] - new_bal[entry+1]) > EPSILONR ) {
		    same = FALSE
		}
		else if ( abs(old_bal[entry+2] - new_bal[entry+2]) > EPSILONR ) {
		    same = FALSE
		}
	    }
	}
	else {
	    same = FALSE
	}

	return(same)

end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  calculate probabilities

procedure  calc_probab( bal, percent, probab, arcfrac )

real	bal						#
real	percent						#
real	arcfrac						#
real	probab[RESPONSE_MATRIX,MAX_PHA_BINS]		#
real	stable						#
real	transient					#
int	channel						#
int	bin						#
int     entries						#
int	entry						#
pointer	stable_probab					#
pointer	transient_probab				#
pointer	sp						# stack pointer

begin
	entries = RESPONSE_MATRIX * MAX_PHA_BINS

	call smark (sp)
	call salloc (stable_probab, entries, TY_REAL)
	call salloc (transient_probab, entries, TY_REAL)

	stable    = (1.-arcfrac) * 0.01*percent
	transient =   arcfrac    * 0.01*percent

	call get_bal_matrix( bal, stable_probab, transient_probab, entries)

	do channel = 1, MAX_PHA_BINS
	    do bin = 1, RESPONSE_MATRIX  {
		entry = (channel-1) * RESPONSE_MATRIX + bin - 1
		probab[bin,channel] = probab[bin,channel] +
				      stable * Memr[stable_probab+entry] +
				      transient * Memr[transient_probab+entry]
		}

	call sfree (sp)
end


# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  read in response matrix data for a given bal value

procedure  get_bal_matrix (bal, stable, transient, entries)

real	bal				#
int	entries				#
int     fd                              # file descriptor
int     stat                            # file I/O status
pointer bal_energies			# 
pointer	stable				# stable probability table
pointer	transient			# transient probability table
pointer table_name                      # name of response table file
pointer sp                              # stack pointer

int     open(),  read()

begin
        call smark (sp)
        call salloc (table_name, SZ_PATHNAME, TY_CHAR)
	call salloc (bal_energies, PHAS, TY_REAL)
        call sprintf (Memc[table_name], SZ_PATHNAME, RESPONSE_FILE_TEMPLATE)
                call pargstr (DATA_DIRECTORY)
                call pargr (bal)
        fd = open (Memc[table_name], READ_ONLY, BINARY_FILE)
	stat = read (fd, Memr[bal_energies], PHAS*SZ_REAL)	# read and forget
	stat = read (fd, Memr[stable], entries*SZ_REAL)
	stat = read (fd, Memr[transient], entries*SZ_REAL)
        call close (fd)
        call sfree (sp)
end

# 
#  ---------------------------------------------------------------------------

procedure  rd_sps ( sigmas, maxbins )

pointer	sp			# stack pointer
pointer	datafile		# file with prf sigmas
real	sigmas[ARB]		# 
int	maxbins, bin		#
int	fd			# file descriptor

bool	access()
int	open(),  fscan()

begin
	call smark (sp)
	call salloc ( datafile, SZ_FNAME, TY_CHAR )
	call amovkr ( 1.0, sigmas, maxbins )

	call clgstr ( SPATIAL_PRF_SIGMAS, Memc[datafile], SZ_FNAME )
	if( access(Memc[datafile], READ_ONLY, TEXT_FILE) )  {
	    fd = open( Memc[datafile], READ_ONLY, TEXT_FILE )
	    bin = 0
	    while( bin<maxbins && fscan(fd)!=EOF )  {
		bin = bin+1
		call gargr( sigmas[bin] )
		}
	    call close (fd)
	    }
	  else  {
	    call printf( "Could not locate %s, data file with prf sigmas.\n" )
	    call pargstr( Memc[datafile] )
	    }

	call sfree (sp)
end

#
#  IPC_ENERGY   ---   calculate the energies at the PHA boundaries
#			for Einstein IPC

procedure  ipc_energy (ds, energies, nbins)

pointer	ds				# i: data set struct
real	energies[ARB]			# o: energy bounds
int	nbins				# i: number of bounds
pointer	bh				# l: bal histo struct
int	i				# l: loop counter

begin
	# start with simple boundaries
	call aclrr(energies, nbins)
	# get bal structure
	bh = DS_BAL_HISTGRAM(ds)
	# if there are bals ...
	if( BH_ENTRIES(bh) > 0 ){
	    # for each bal entry ...
	    do i = 1, BH_ENTRIES(bh)
		# calculate the contribution to the energy bounds
		call ipc_energy1 (BH_BAL(bh,i), BH_PERCENT(bh,i),
				     energies, nbins)
	}
end

#
#  ipc_energy1 -- add in the energies from 1 bal/percent pair
#
procedure  ipc_energy1 (bal, percent, energies, nbins)

real	bal				#
real	percent				#
real	energies[ARB]			#
int	nbins				#
int	i				# index for channels
pointer	bal_energies			#
pointer	sp				# stack pointer

begin
	call smark (sp)
	call salloc (bal_energies, PHAS, TY_REAL)
	call get_bal_energy (bal, bal_energies, PHAS)
	do i = 1, nbins
	    energies[i] = energies[i] + 0.01*percent*Memr[bal_energies+i-1]
	call sfree (sp)
end

# 
#
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#
procedure  get_bal_energy (bal, bal_energies, nbins)

real	bal				#
int	nbins				# number of energies
int	fd				# file descriptor
int	stat				# file I/O status
pointer	bal_energies			#
pointer	table_name			# name of response table file
pointer	sp				# stack pointer

int	open(),  read()

begin
	call smark (sp)
	call salloc (table_name, SZ_PATHNAME, TY_CHAR)
	call sprintf (Memc[table_name], SZ_PATHNAME, RESPONSE_FILE_TEMPLATE)
		call pargstr (DATA_DIRECTORY)
		call pargr (bal)
	fd = open (Memc[table_name], READ_ONLY, BINARY_FILE)
	stat = read (fd, Memr[bal_energies], nbins*SZ_REAL)
	call close (fd)
	call sfree (sp)
end
