#$Header: /home/pros/xray/xspectral/source/RCS/rebin.x,v 11.0 1997/11/06 16:43:16 prosb Exp $
#$Log: rebin.x,v $
#Revision 11.0  1997/11/06 16:43:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:02  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:42  prosb
#General Release 2.3
#
#Revision 6.2  93/12/02  13:50:41  dennis
#Checked out for vignetting correction change, but it turned out not to
#affect this file.
#
#Revision 6.1  93/07/02  14:44:33  mo
#MC	7/2/93		Enclose variable and defined values in parens
#			(RS6000 port)
#
#Revision 6.0  93/05/24  16:52:35  prosb
#General Release 2.2
#
#Revision 5.4  93/05/12  15:41:56  orszak
#jso - made changes so that 256 channels would work.
#
#Revision 5.3  93/05/08  17:33:07  orszak
#jso - fixed the rebin routines for qpspec, see comments in file.
#
#Revision 5.0  92/10/29  22:46:13  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:57  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/07  16:14:03  prosb
#jso - no change.  problem from flint, but couldn't not make easy fix
#      and it doesn't cause problem
#
#Revision 3.1  91/09/22  19:07:13  wendy
#Added
#
#Revision 3.0  91/08/02  01:59:06  prosb
#General Release 1.1
#
#Revision 2.1  91/07/12  16:43:03  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:07:17  pros
#General Release 1.0
#
#rebin.x
#
# Project:	PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1993.  You may do anything you like with this
#               file except remove this copyright
#
#	rebin(old, oedges, nold, new, nedges, nnew)
#	rebin_particles(old, oedges, nold, new, nedges, nnew)
#	rebin_eff_area(old, oedges, nold, new, nedges, nnew)
#	rebin_model(model, new, edges, n)
#	unlog_array(spectrum, unlogged, nbins)
#	areaof_model(spectrum, loedge, hiedge)
#	intplog_model(model, energy)
#
#
#	NOTE: rebin and rebin_model DO NOT "conserve flux".
#	Check that they do what you want before using.
#
include	<mach.h>
include	<spectral.h>


#-----------------------------------------------------------------
# Function:	rebin
# Purpose:	Rebin double value counts
# Description:	I am not sure what this routine does.  It DOES NOT
#		conserve the quantity that is being rebinned.
# Modified:	{0} ??? initial version ??? ??
#		{1} JSO added this comment Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

procedure rebin(old, oedges, nold, new, nedges, nnew)

double	old[nold]			# i: old bin array
real	oedges[nold+1]			# i: old edges
int	nold				# i: number of old bins
double	new[nnew]			# o: new binned spectrum
real	nedges[nnew+1]			# i: edges of the new spectrum bins
int	nnew				# i: # of new bins
#--

int	i, j				# loopers
int	lobin				# model bins that span the new bin
double	X1, X2				# flux values clipped to models[]
double	C1, C2				# interpolated flux points
double	e1, e2				# energy at points C1, C2
double	ehi, elo			# energy range of the current term
					# of the sum
double	sum				# Sum of flux from the model that 
					# belongs to 1 new bin

begin
	for ( i = 1; nedges[1] > oedges[i]; i = i + 1 );	# first old bin
	lobin = i - 1

	# for each new bin
	#
	for ( i = 1; i <= nnew; i = i + 1 ) {
		sum = 0

		# sum flux in the old bins between the new bin edges
		#
		if ( j > nold ) next

		e1 = ( oedges[lobin] + oedges[lobin + 1] ) / 2
		for ( j = lobin; nedges[i + 1] > oedges[j]; j = j + 1 ) {
				
			X1 = old[j]
			X2 = old[j + 1]

			e2 = ( oedges[j] + oedges[j + 1] ) / 2

			if ( nedges[i] > e1 ) {
				elo = nedges[i]
				C1  = X1 + ((nedges[i] - e1 ) / ( e2 - e1 )) *
					   ( X2 - X1 )
			} else {
				elo = e1
				C1  = X1
			}

			if ( nedges[i + 1] < e2 ) {
				ehi = nedges[i + 1]
				C2  = X2 - ((e2 - nedges[i + 1] )/( e2 - e1 ))*
					   ( X2 - X1 )
			} else {
				ehi = e2
				C2  = X2
			}

			sum = sum + .5 * ( C1 + C2 ) * ( ehi - elo )
			e1 = e2
		}

		lobin = j - 1;
		new[i] = sum
	}
end


#-----------------------------------------------------------------
# Function:	rebin_particles
# Purpose:	Rebin particles counts
# Description:	This procedure rebins the counts.  It was created
#		for taking 256 particle bins to 34 by summing.
#		It assumes (at least?) that the nedges are equal
#		to one of the oedges, and that nold is greater
#		than nnew.
# Modified:	{0} JSO  initial version Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

procedure rebin_particles(old, oedges, nold, new, nedges, nnew)

real	old[nold]			# i: old bin array
real	oedges[nold+1]			# i: old edges
int	nold				# i: number of old bins
real	new[nnew]			# o: new binned spectrum
real	nedges[nnew+1]			# i: edges of the new spectrum bins
int	nnew				# i: # of new bins

int	ii				# counter
int	jj				# counter
int	lobin				# model bins that span the new bin

real	flux				# counts for new bin

begin

	lobin = 1

	#------------------------------------------------
	# find the first old bin to be added to a new bin
	#------------------------------------------------
	for ( ii = 1; oedges[ii] <= nedges[1]; ii = ii + 1 ) {

	    lobin = ii

	}

	do jj = 1, nnew {

	    flux = 0.0

	    #----------------------------------------------------
	    # get the old bins that will be added to this new bin
	    #----------------------------------------------------
	    for ( ii = lobin; nedges[jj+1] >= oedges[ii+1]
			&& ii < nold+2 ; ii = ii + 1) {

		flux = flux + old[ii]

		lobin = ii + 1
	    }

	    new[jj] = flux

	}

end


#-------------------------------------------------------------------
# Function:	rebin_eff_area
# Purpose:	Rebin effective area values
# Description:	This procedure rebins the effective area.  It
#		was created to take the 729 efective area bins
#		to 34 (256) by doing sum of eff_area*width divided
#		by sum of width.  It assumes (at least?) that that
#		nold is greater than nnew, and it only handles
#		crossing boundaries approximately.  NB: the
#		first bin of offar is 0.071keV, while the first
#		bin of 34 channels is 0.07keV and of 256 PI's is
#		0.01keV; in the 34 case we just start filling
#		channel 1 at 0.71keV, in the 256 case I added the
#		if statement to prevent a floating point exception.
# Modified:	{0} JSO  initial version Apr 93
#		{n} <who> -- <does what> -- <when>
#
#--------------------------------------------------------------------

procedure rebin_eff_area(old, oedges, nold, new, nedges, nnew)

real	old[nold]			# i: old bin array
real	oedges[nold+1]			# i: old edges
int	nold				# i: number of old bins
real	new[nnew]			# o: new binned spectrum
real	nedges[nnew+1]			# i: edges of the new spectrum bins
int	nnew				# i: # of new bins

int	ii				# counter
int	jj				# counter
int	lobin				# model bins that span the new bin

real	flux				# counts for new bin
real	part_flux_a			# partial flux in overlapping bins
real	part_flux_b			# partial flux in overlapping bins
real	part_wid_a			# partial width of overlapping bins
real	part_wid_b			# partial width of overlapping bins
real 	totwid				# total width of added bins
real	width				# width of this (old) bin

begin

	part_flux_a = 0.0
	part_flux_b = 0.0
	part_wid_a  = 0.0
	part_wid_b  = 0.0

	lobin = 1

	#------------------------------------------------
	# find the first old bin to be added to a new bin
	#------------------------------------------------
	for ( ii = 1; oedges[ii] <= nedges[1]; ii = ii + 1 ) {

	    lobin = ii

	}

	do jj = 1, nnew {

	    flux = part_flux_b * part_wid_b

	    totwid = part_wid_b

	    #----------------------------------------------------
	    # get the old bins that will be added to this new bin
	    #----------------------------------------------------
	    for ( ii = lobin; nedges[jj+1] >= oedges[ii+1]
				&& ii < nold+2 ; ii = ii + 1) {

		width = oedges[ii] - oedges[ii+1]

		flux = flux + old[ii] * width

		totwid = totwid + width

		if ( oedges[ii+2] > nedges[jj+1] ) {

		    part_wid_a  = nedges[jj+1] - oedges[ii+1]
		    part_flux_a = (old[ii+1] * part_wid_a) /
					(oedges[ii+2] - oedges[ii+1])

		    part_wid_b  = oedges[ii+2] - nedges[jj+1]
		    part_flux_b = (old[ii+1] * part_wid_b) /
					(oedges[ii+2] - oedges[ii+1])

		    flux = flux + part_flux_a * part_wid_a

		    totwid = totwid + part_wid_a

		}
		else {

		    part_wid_b  = 0.0
		    part_flux_b = 0.0

		}

		lobin = ii + 1

	    }

	    #--------------------------------------------------------
	    # the if statement prevents a floating point exception
	    # for the 256 bins that are below the beginning of offar.
	    #--------------------------------------------------------
	    if ( abs(totwid) < EPSILONR ) {
		new[jj] = 1.0
	    }
	    else {
		new[jj] = flux / totwid
	    }

	}

end


#-----------------------------------------------------------------
# Function:	rebin_model
# Purpose:	Rebin spectral models.
# Description:	I am not sure what this routine does.  It DOES NOT
#		conserve the quantity that is being rebinned, but
#		spectral does seem to be working okay.
# Modified:	{0} ??? initial version ??? ??
#		{1} JSO added this comment Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

procedure rebin_model(model, new, edges, n)

double	model[SPECTRAL_BINS]		# i: model spectrum
double	new[n]				# o: new binned spectrum
real	edges[n+1]			# i: edges of the new spectrum bins
int	n				# i: # of new spectrum bins
#--

int	i, j				# loopers
int	lobin, hibin			# model bins that span the new bin
double	X1, X2				# flux values clipped to models[]
double	C1, C2				# interpolated flux points
double	e1, e2				# energy at points C1, C2
double	ehi, elo			# energy range of the current term
					# of the sum
double	sum				# Sum of flux from the model that 
					# belongs to 1 new bin
##double foo
double	bin_energy()
int	energy_low()

begin
	# for each new bin
	#
	do i = 1, n {
		sum = 0
		lobin = energy_low(edges[i]) + 1
		hibin = energy_low(edges[i + 1]) + 1

		# sum flux in the model bins between the new bin edges
		#
		e1 = bin_energy(real(lobin - 1))
		for ( j = lobin; j <= hibin; j = j + 1 ) {
			if ( j > SPECTRAL_BINS ) next
			if ( j + 1 < 1 )	 next

			if ( j < 1 ) 			X1 = 0
			else				X1 = model[j]
			if ( j + 1 > SPECTRAL_BINS ) 	X2 = 0
			else				X2 = model[j + 1]

			e2 = bin_energy(real(j))

			if ( edges[i] > e1 ) {
				elo = edges[i]
				C1  = X1 + ((edges[i] - e1 ) / ( e2 - e1 )) *
					   ( X2 - X1 )
			} else {
				elo = e1
				C1  = X1
			}

			if ( edges[i + 1] < e2 ) {
				ehi = edges[i + 1]
				C2  = X2 - ((e2 - edges[i + 1] )/( e2 - e1 )) *
					   ( X2 - X1 )
			} else {
				ehi = e2
				C2  = X2
			}

			sum = sum + .5 * ( C1 + C2 ) * ( ehi - elo )
			e1 = e2
		}

		new[i] = sum
	}

end


#-----------------------------------------------------------------
# Function:	unlog_array
# Purpose:	
# Description:	
# Modified:	{0} ??? initial version ??? ??
#		{1} JSO added this comment Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

procedure unlog_array(spectrum, unlogged, nbins)

double	spectrum[nbins]
double	unlogged[nbins]
int	nbins
#--

int	i

begin
	do i = 1, nbins 			# Unlog the spectrum
		if ( spectrum[i] > -35.0D0 )
		    unlogged[i] = 10.0D0**(spectrum[i])
		else
		    unlogged[i] = 10**(-35.0D0)
		
end


#-----------------------------------------------------------------
# Function:	areaof_model
# Purpose:	
# Description:	
# Modified:	{0} ??? initial version ??? ??
#		{1} JSO added this comment Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

double procedure areaof_model(spectrum, loedge, hiedge)

double	spectrum
real	loedge, hiedge
#--

real	edges[2]
double	sum

begin
	edges[1] = loedge
	edges[2] = hiedge

	call rebin_model(spectrum, sum, edges, 1)

	return sum
end


#-----------------------------------------------------------------
# Function:	intplog_model
# Purpose:	
# Description:	
# Modified:	{0} ??? initial version ??? ??
#		{1} JSO added this comment Apr 93
#		{n} <who> -- <does what> -- <when>
#
#-----------------------------------------------------------------

double procedure intplog_model(model, energy)

double	model[SPECTRAL_BINS]
real	energy
#--

int	bin, energy_low()
double	bin_energy()

double	X1, X2				# Flux at model points
double	e1, e2				# Energy at model points

begin
	bin = energy_low(10**energy)

	if ( bin + 1 < 1 || bin + 1 > SPECTRAL_BINS )	X1 = 0
	else						X1 = model[bin + 1]
	if ( bin + 2 < 1 || bin + 2 > SPECTRAL_BINS ) 	X2 = 0
	else						X2 = model[bin + 2]

	e1 = log10(bin_energy(real(bin)))
	e2 = log10(bin_energy(real(bin + 1)))

	return X1 + (( energy - e1 ) / ( e2 - e1 )) * ( X2 - X1 )
end
