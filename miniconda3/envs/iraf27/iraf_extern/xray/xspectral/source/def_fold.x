#$Header: /home/pros/xray/xspectral/source/RCS/def_fold.x,v 11.0 1997/11/06 16:41:58 prosb Exp $
#$Log: def_fold.x,v $
#Revision 11.0  1997/11/06 16:41:58  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:14  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:44  prosb
#General Release 2.3
#
#Revision 1.1  93/10/22  19:56:39  dennis
#Initial revision
#
#
# Module:	def_fold.x
# Project:	PROS -- ROSAT RSDC
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
#
# DEF_FOLD.X
#

include <mach.h>

include <spectral.h>
include "def.h"

# Redefined pspc to def: (14/5/93,AH)
procedure def_fold(fp, model, nbins)

pointer	fp
double	model[nbins]
int	nbins
#--

int	fd			# file descriptor for io

real	matrix[DEF_RSPBINS * DEF_CHANNELS]	# detector response matrix
real	center[DEF_RSPBINS]			# detector response bins
real	widths[DEF_RSPBINS]
real	edges[DEF_RSPBINS + 1]			# computed bin edges
real	filter[DEF_RSPBINS]			# filter effective area
real	offar[( DEF_RSPBINS + 1 ) * DEF_OFFAR]# offaxis angle effective area 

pointer unlogged		# model unlogged
pointer	rebinned		# model in DEF_RSPBINS
pointer	efftarea
pointer	response


bool	init

char	dtmat_fname[SZ_FNAME]
char    filter_fname[SZ_FNAME]
char    offar_fname[SZ_FNAME]
char    egrid_fname[SZ_FNAME]
char	fname[SZ_FNAME]

int	ii, jj
int	bytes

data	init	/ FALSE /

pointer dataset
pointer	sp
pointer spectrum

bool	strne()
int	open()
int	read()

begin
	call smark(sp)

	dataset = FP_OBSERSTACK(fp,FP_CURDATASET(fp))

	if ( DS_NPHAS(dataset) != DEF_CHANNELS )
		call error(1, "Number of channels does not match instrument response");
	if ( DS_NOAH(dataset) != DEF_OFFAR )
		call error(1, "Number of offaxis histogram bins does not match instrument response");

#	read in def data file names; if they have changed we want to
#	reinitalize.

#	response matrix file
	call strcpy(dtmat_fname, fname, SZ_FNAME)
	call clgstr(DEF_DTMAT, dtmat_fname, SZ_FNAME)
	if ( strne(fname, dtmat_fname) )
		init = FALSE

#	filter file
        call strcpy(filter_fname, fname, SZ_FNAME)
	call clgstr(DEF_FILTE, filter_fname, SZ_FNAME)
        if ( strne(fname, filter_fname) )
                init = FALSE

#	off axis coefficients
        call strcpy(offar_fname, fname, SZ_FNAME)
	call clgstr(DEF_OFFAR_FILE, offar_fname, SZ_FNAME)
        if ( strne(fname, offar_fname) )
                init = FALSE

#	response bin centers and widths
        call strcpy(egrid_fname, fname, SZ_FNAME)
	call clgstr(DEF_EGRID, egrid_fname, SZ_FNAME)
        if ( strne(fname, egrid_fname) )
                init = FALSE

	if ( !init ) {

		# read in response matrix (  DEF_RSPBINS x DEF_CHANNELS )
		#
		fd = open(dtmat_fname, READ_ONLY, BINARY_FILE)
		bytes = read(fd, matrix, DEF_RSPBINS*DEF_CHANNELS*SZ_REAL)
		call close(fd)
	
		# read in filter
		#
		fd = open(filter_fname, READ_ONLY, BINARY_FILE)
		bytes = read(fd, filter, DEF_RSPBINS * SZ_REAL) 
		call close(fd)
	
		# read in off axis coefficients (DEF_RSPBINS +1) x DEF_OFFAR
		#
		fd = open(offar_fname, READ_ONLY, BINARY_FILE)
		bytes = read(fd, offar, (DEF_RSPBINS + 1)*DEF_OFFAR*SZ_REAL)
		call close(fd)

		# read in response bin centers and widths
		#
		fd = open(egrid_fname, READ_ONLY, BINARY_FILE)
		bytes = read(fd, center, DEF_RSPBINS * SZ_REAL)
		bytes = read(fd, widths, DEF_RSPBINS * SZ_REAL)
		call close(fd)

		# Build a set of edges that correspond to the response matrix
		#
		do ii = 1, DEF_RSPBINS
			edges[ii] = center[ii] - widths[ii] /2
		
		edges[DEF_RSPBINS + 1] = 
			center[DEF_RSPBINS] + widths[DEF_RSPBINS] /2

		# convert edges in eV to KeV
		#		
#		call amulkr(edges, .001, edges, DEF_RSPBINS + 1) 

		init = TRUE
	}

	call salloc(response, DEF_RSPBINS * DEF_CHANNELS, TY_REAL)
	call salloc(efftarea, DEF_RSPBINS, TY_REAL)
	call aclrr (Memr[efftarea], DEF_RSPBINS)


	# Sum the contributed areas from the offaxis histogram
	# this index runs from 1 to RSPBINS, the first location
	# in the caliberation file is the angle for this line.
	#
	do ii = 1, DEF_RSPBINS
	    do jj = 0, DEF_OFFAR - 1
		Memr[efftarea + ii - 1] = Memr[efftarea + ii - 1] +
		    DS_OAH(dataset, jj) * offar[jj * (DEF_RSPBINS+1) + ii + 1]

	if ( DS_FILTER(dataset) == 1 )
		# Apply the filter
		#
		do ii = 0, DEF_RSPBINS - 1
			Memr[efftarea + ii] = 
				Memr[efftarea + ii] * filter[ii + 1]

	# Apply the computed effective area to the response matrix
	#
	do ii = 0, DEF_RSPBINS - 1
	    do jj = 0, DEF_CHANNELS - 1
		Memr[response + ii + jj * DEF_RSPBINS] = 
		 matrix[ii + jj * DEF_RSPBINS + 1] * Memr[efftarea + ii]


	call salloc(unlogged, SPECTRAL_BINS, TY_DOUBLE)
	call salloc(rebinned, DEF_RSPBINS, TY_DOUBLE)

#	do ii = 1, nbins {
#	    call printf("mod: %f  ")
#	    call pargd(model[ii])
#	}
#	call printf("\n")
	call unlog_array(model, Memd[unlogged], SPECTRAL_BINS)

#	do ii = 1, nbins {
#	    call printf("unlog: %f ")
#	    call pargd(Memd[unlogged + ii - 1])
#	}
#	call printf("\n")
#	fd = open("/u3/john/model.sin", WRITE_ONLY, TEXT_FILE)
#	do i = 0, SPECTRAL_BINS - 1 {
#		call fprintf(fd, "%f %f\n")
#		 call pargd(bin_energy(real(i)))
#		 call pargd(Memd[unlogged + i])
#	}
#	call close(fd)

	call rebin_model(Memd[unlogged], Memd[rebinned], edges,
		DEF_RSPBINS)

#	do ii = 1, DEF_RSPBINS {
#	    call printf("reb: %f  ")
#	    call pargd(Memd[rebinned + ii - 1])
#	}
#	call printf("\n")

#	fd = open("/u3/john/rebinned.sin", WRITE_ONLY, TEXT_FILE)
#	do i = 0, DEF_RSPBINS -1 {
#		call fprintf(fd, "%f %f %f\n")
#		 call  pargr(Memr[center + i])
#		 call  pargr(Memr[widths + i])
#		 call  pargd(Memd[rebinned + i])
#	}
#	call close(fd)

	spectrum = DS_PRED_DATA(dataset)
	call aclrr(Memr[spectrum], DEF_CHANNELS)


	# Apply the detector response to the rebinned model spectrum
	#
	do ii = 0, DEF_RSPBINS - 1 {
	    do jj = 0, DEF_CHANNELS - 1 {
#		call printf("i: %d j: %d spec: %f reb: %f res: %f\n")
#		call pargi(ii)
#		call pargi(jj)
#		call pargr(Memr[spectrum + jj])
#		call pargd(Memd[rebinned + ii])
#		call pargr(Memr[response + ii + jj*DEF_RSPBINS])
		Memr[spectrum + jj]  = Memr[spectrum + jj] +
		    Memd[rebinned + ii] * Memr[response + ii + jj*DEF_RSPBINS]
	
#			call fprintf(fd, "%f ")
#			 call  pargr(Memr[response + ii + jj * DEF_RSPBINS])

	    }
#	    call fprintf(fd, "\n")
	}
#	call close(fd)

#	do ii = 0, 34 - 1 {
#		call fprintf(fd, "%f %f %f \n")
#		call pargr(Memr[DS_LO_ENERGY(dataset) + ii] +
#			   (Memr[DS_HI_ENERGY(dataset) + ii] -
#			    Memr[DS_LO_ENERGY(dataset) + ii])/2)
#		call pargr(Memr[DS_HI_ENERGY(dataset) + ii] -
#			   Memr[DS_LO_ENERGY(dataset) + ii]/2)
#		call pargr(Memr[spectrum + ii])
#	}
#	call close(fd)

	call sfree(sp)
end



procedure def_energy(energies, nbounds)


real	energies[nbounds]
int	nbounds

real	low_en
real	high_en
real	increment

int	ii

real	clgetr()
begin

	low_en = clgetr("def_low_energy")
	high_en = clgetr("def_high_energy")

	increment = (high_en - low_en) / ( nbounds - 1 )

	do ii = 1, nbounds  {
	    energies[ii] = low_en + increment*(ii-1)
	}

end


int procedure def_pi(n)

int	n
#--

int	i, bin
int	compr[DEF_PITCH]

pointer	e34
pointer	e256
pointer	sp

bool	init
data	init / FALSE /

begin
	if ( !init ) {
		call smark(sp)

		call salloc(e34, DEF_CHANNELS + 1, TY_REAL)
		call salloc(e256, DEF_PITCH + 1, TY_REAL)
	
		call def_energy(Memr[e34], DEF_CHANNELS + 1)
		call def_energy(Memr[e256], DEF_PITCH + 1)

		bin = 1
		do i = 0, DEF_HITHRESH {
			if ( Memr[e256 + i] >= Memr[e34 + bin] ) bin = bin + 1

			compr[i + 1] = bin
		}
		call sfree(sp)
		init = TRUE
	}

	if ( n < DEF_LOTHRESH ) return 0
	if ( n > DEF_HITHRESH ) return 35

	return compr[n]
end

