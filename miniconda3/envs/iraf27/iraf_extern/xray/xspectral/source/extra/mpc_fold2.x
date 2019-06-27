#$Header: /home/pros/xray/xspectral/source/extra/RCS/mpc_fold2.x,v 11.0 1997/11/06 16:41:42 prosb Exp $
#$Log: mpc_fold2.x,v $
#Revision 11.0  1997/11/06 16:41:42  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:31:35  prosb
#General Release 2.4
#
Revision 8.0  1994/06/27  17:35:45  prosb
General Release 2.3.1

Revision 7.0  93/12/27  18:53:54  prosb
General Release 2.3

Revision 6.0  93/05/24  16:53:27  prosb
General Release 2.2

Revision 5.0  92/10/29  22:43:09  prosb
General Release 2.1

Revision 3.0  91/08/02  01:59:31  prosb
General Release 1.1

#Revision 2.0  91/03/06  23:05:47  pros
#General Release 1.0
#
#    mpc_fold.x   ---   fold spectrum through the MPC
# revision dmw Oct 1988 --- intermediate spectra logarithmic
#                           mpc_pha_conv changes log to linear.
#                   also,      Add log of MPC area to spectrum.
#                   also,      multiply photon bins by delta E
#                               (this is done by adding probabilities
#                                for all response bins within photon bin
#                                in mpc_eff, and multiplying by the
#                                delta E of the response bin in mpc_fold)

include  "spectral.h"

#    local parameter definitions

define	 MPC_RESPONSE		"mpc_response_datafile"
define   LEN_COMMENT		 (72)
# begin revision dmw Oct 1988
define	 ENERGY_MIN_MPC		 0.0
define   ENERGY_MAX_MPC          25.0            #max energy of MPC response
define   MPC_AREA                667      # MPC area in cm**2
define   ENERGY_CHNS_MPC         0.025     # width of MPC response energy channels
# end revision dmw

#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  create pha spectrum 

procedure mpc_fold2( parameters, iphoton_spectrum, nbins)

pointer parameters              # parameter data structure
double  iphoton_spectrum[ARB]	# input incident spectrum
int	nbins			# number of bins

double  photon_spectrum[SPECTRAL_BINS]	# input incident spectrum + arealog
pointer spectrum                # pha output spectrum
int	dataset, nphas
int	fd
double  arealog

bool	get_mpc_response()

begin
        dataset  = FP_CURDATASET(parameters)
        nphas    = DS_NPHAS(FP_OBSERSTACK(parameters,dataset))
        spectrum = DS_PRED_DATA(FP_OBSERSTACK(parameters,dataset))
        call aclrr ( Memr[spectrum], nphas )

	if( get_mpc_response(fd) )  {
# begin revision dmw Oct 1988
#   multiply by MPC area and step size of response = add log of area and step size
#                                                     of response bin to log of spectrum
            arealog=double(alog10(real(MPC_AREA)) + alog10(ENERGY_CHNS_MPC))
#    debug
#            call printf(" %10.3f \n")
#            call pargd(arealog)
#   end debug
	    call aaddkd( iphoton_spectrum, arealog, photon_spectrum, nbins )
# end revision dmw
	    call mpc_pha_conv2 (fd, parameters, photon_spectrum, nbins, 
			       Memr[spectrum], nphas )
            call close( fd )
            }
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# begin revision dmw Oct 1988
#procedure  mpc_pha_conv (fd, parameters, photons, nbins, phas, nphas )
procedure  mpc_pha_conv2( fd, parameters, photons, nbins, pha_spectrum, nphas )
# end revision dmw

pointer	parameters		# parameter data structure
pointer	sp			# stack pointer
pointer	probab			# PHA efficiencies
pointer	energies		# pha channel energies
int	fd			# file descriptor
int	maxgrp			# maximum number of groups
int	nbins			# number of bins in photon spectrum
int	nphas			# number of phas in pha spectrum
int	bin,  pha		# loop indices
int	nin, nout		# number of input and output bins
# begin revision dmw Oct 1988
int     ncalls			# number of calls of mpc_eff (debug)
#real    psd_eff[6]              # values of PSD efficiencies for first 6 channels
# end revision dmw
real	minE			# minimum energy
real	pha_spectrum[ARB]		#
double	photons[ARB]		# 
#begin revision dmw Oct 1988
real    Ebound
double	energy			# energy of photon spectrum bin
#double	energy_l		# lower energy of photon spectrum bin
#double	energy_u		# upper energy of photon spectrum bin
# end revision dmw
double  cntrte
double	bin_energy()

# begin revision dmw Oct 1988
#data    psd_eff/0.54,0.76,0.85,0.82,0.91,0.97/
# end revision dmw

begin
	call smark (sp)
	call salloc ( probab, (nphas+1), TY_REAL )
	call salloc ( energies, (nphas+1), TY_REAL )
# begin revision dmw Oct 1988
#	call aclrr ( Memr[probab], (nphas+1) )

	call mpc_hdr (fd, Memr[energies], (nphas+1), nin, nout, minE, maxgrp)
        Ebound=0.
	ncalls=0
	do bin = 1, nbins  {
	call aclrr ( Memr[probab], (nphas+1) )
	    energy = bin_energy( real(bin-1) )
#	    energy_l = bin_energy( real(bin)-1.5 )
#	    energy_u = bin_energy( real(bin)-0.5 )
#	    call mpc_eff( fd, maxgrp, energy, Memr[probab], nphas )
#	    call mpc_eff( fd, maxgrp, energy_l, energy_u, Memr[probab], nphas, ncalls, Ebound )
# REPLACEMENT
	    call mpc_eff2(fd, maxgrp, energy, Memr[probab], nphas, Ebound)
	    do pha = 1, nphas{
                if (photons[bin] <= -20.0d0){
			cntrte=0.0d0
                        }
		else{
			cntrte=10.0d0**photons[bin]
                    }
                    cntrte =  cntrte * double(Memr[probab+pha])
                    cntrte = double(pha_spectrum[pha]) + cntrte
                    pha_spectrum[pha] = real(cntrte)
#		phas[pha] = phas[pha] + photons[bin]*Memr[probab+pha]
                }
	}
#  It turns out that response on SUN has psd efficiencies folded in (unlike
#                that on the M600) --- so following commented out
#	    do pha = 1, 6{
#                    pha_spectrum[pha] = psd_eff[pha]*pha_spectrum[pha]
#                    }
# end revision dmw
	call sfree (sp)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  fetch the MPC efficiencies

# begin dmw revision Oct 1988
#    -  note that now the probabilities will be summed so that we have
#       a multiplication by bin width
#procedure  mpc_eff ( fd, maxgrp, energy, probab, nphas )
#procedure  mpc_eff ( fd, maxgrp, energy_l, energy_u, probab, nphas, ncalls, Ebound )
procedure  mpc_eff2 ( fd, maxgrp, energy, probab, nphas, Ebound ) # REPLACEMENT
# end dmw revision

pointer	sp		# stack pointer
pointer	is, ie, ele	# record elements
int	fd		# file descriptor
int	maxgrp		# maximum number of groups
int	nphas		# number of pha bins
int	grps		# number of groups
int	pha,  offset	# loop index and offset
# begin dmw revision Oct 1988
int     ncalls          # debug
#double	energy_l	# lower energy of current bin
#double	energy_u	# upper energy of current bin
# end dmw revision
double	energy		# current energy
real	probab[ARB]	# array of efficiencies and corr. energy
real	Ebound		#

begin
	call smark (sp)
	call salloc ( is, maxgrp, TY_INT )
	call salloc ( ie, maxgrp, TY_INT )
	call salloc ( ele, maxgrp*nphas, TY_REAL )
# begin dmw revision Oct 1988
#  debug
#	    call printf(" El:Eu   %7.4f    %7.4f \n")
#            call pargd(energy_l)
#            call pargd(energy_u)
#   end debug
# %%	energy=energy_l
# %%    while (energy < energy_u){
#	while ( energy >= probab[1] )  {
          while ( energy >= double(Ebound) && energy <=double(ENERGY_MAX_MPC))
	{
	    call mpc_rec5( fd, Ebound, grps, Memi[is], Memi[ie], Memr[ele] )
	} # REPLACEMENT
#   debug 
#	    ncalls = ncalls+1
#	    call printf(" %d")
#            call pargi(ncalls)
#            for (pha=1; pha<=8; pha=pha+1){
#		call printf(" %5.1f")
#		call pargr(Memr[ele+Memi[is]-2+pha])
#                }
#             call printf(" \n")
#  end debug
	    do pha = 1, nphas  {
		offset = Memi[is]+pha-2
		probab[pha+1] = Memr[ele+offset]	# REPLACEMENT
# %%		probab[pha+1] = Memr[ele+offset] + probab[pha+1]
	    }
# %%	}
# %%	energy=energy+double(ENERGY_CHNS_MPC)
# %%	}
# end dmw revision
	call sfree (sp)
end

