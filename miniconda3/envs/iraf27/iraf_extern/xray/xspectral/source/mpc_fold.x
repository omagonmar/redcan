#$Header: /home/pros/xray/xspectral/source/RCS/mpc_fold.x,v 11.0 1997/11/06 16:42:56 prosb Exp $
#$Log: mpc_fold.x,v $
#Revision 11.0  1997/11/06 16:42:56  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:29  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:32  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:34  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:25  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:42  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:25:41  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:06:42  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:42  prosb
#General Release 1.1
#
#Revision 2.2  91/07/19  15:49:09  orszak
#jso - spelling correction
#
#Revision 2.1  91/07/12  16:27:58  prosb
#jso - made spectral.h system wide
#
#Revision 2.0  91/03/06  23:05:44  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#    mpc_fold.x   ---   fold spectrum through the MPC


include  <spectral.h>


#    local parameter definitions

define	 MPC_RESPONSE		"mpc_response_datafile"
define   LEN_COMMENT		 (72)

define  MPC_AREA                667		# MPC area in cm**2
define  ENERGY_CHNS_MPC         0.025		# width of MPC response energy channels
define	MPC_NBINS		1024		# # of mpc response bins



procedure mpc_fold(parameters, iphotons, nbins)

pointer parameters              # parameter data structure
double  iphotons[ARB]		# input incident spectrum
int	nbins			# number of bins
#--

double  photons[SPECTRAL_BINS]		# input incident spectrum + arealog
pointer spectrum			# pha output spectrum
int	dataset, nphas

begin
        dataset  = FP_CURDATASET(parameters)
        nphas    = DS_NPHAS(FP_OBSERSTACK(parameters,dataset))
        spectrum = DS_PRED_DATA(FP_OBSERSTACK(parameters,dataset))
        call aclrr(Memr[spectrum], nphas)

	
	call aaddkd(iphotons, double(alog10(real(MPC_AREA))), photons, nbins)
	call mpc_pha_conv(parameters, photons, nbins, 
			       Memr[spectrum], nphas )
end


#  return energy bounds of MPC PHA channels
#
procedure mpc_energy (energies, nbins)

real    energies[ARB]           #
int     nbins                   #
int	fd
int	maxgrp			# maximum number of groups
int	nin, nout		# number of input and output bins
real	minE			# minimum energy

bool	get_mpc_response()

begin
        if( get_mpc_response(fd) ) {
	    call mpc_hdr (fd, energies, nbins, nin, nout, minE, maxgrp)
            call close( fd )
	}
end



procedure  mpc_pha_conv(parameters, photons, nbins, phas, nphas)


pointer	parameters		# parameter data structure
double	photons[ARB]		# 
int	nbins			# number of bins in photon spectrum
real	phas[ARB]		#
int	nphas			# number of phas in pha spectrum
#--

pointer	energies		# Lots of energy tables
pointer	probab
pointer	unlogged
pointer	rebinned
pointer	edges

int	fd			# file descriptor
int	maxgrp			# maximum number of groups
int	bin,  pha		# loop indices
int	nin, nout		# number of input and output bins

real	minE			# minimum energy

bool	junk, get_mpc_response()

pointer	sp			# stack pointer

begin
	call smark (sp)
	call salloc(probab, MPC_NBINS * nphas, TY_REAL )
	call salloc(energies, nphas + 1, TY_REAL )
	call salloc(unlogged, nbins, TY_DOUBLE)
	call salloc(rebinned, MPC_NBINS, TY_DOUBLE)
	call salloc(edges, MPC_NBINS + 1, TY_REAL)

	junk = get_mpc_response(fd)
	
	call mpc_hdr(fd, Memr[energies], nphas + 1, nin, nout, minE, maxgrp)
	call mpc_eff(fd, minE, nphas, Memr[probab], Memr[edges])
	call close(fd)

	call unlog_array(photons,  Memd[unlogged], nbins)
	call rebin_model(Memd[unlogged],
			 Memd[rebinned], Memr[edges], MPC_NBINS)

	do bin = 0, MPC_NBINS - 1 {
	    do pha = 0, nphas - 1 {
                    phas[pha + 1] = phas[pha + 1] +
		        Memd[rebinned + bin] * Memr[probab + bin * nphas + pha]
	    }
	}

	call sfree (sp)
end


#  fetch the MPC efficiencies
#
procedure  mpc_eff(fd, minE, nphas, probab, edges)

int	fd
real	minE
int	nphas
real	probab[ARB]
real	edges[MPC_NBINS + 1]
#--

int	i
int	grps, is, ie				# junk left over from rec5

begin
	edges[1] = minE

	do i = 0, MPC_NBINS - 1
		call mpc_rec5(fd, edges[i + 2], grps, is, ie,
			     probab[i * nphas + 1])
end



#  open the MPC response file
#
bool  procedure  get_mpc_response( fd )

pointer sp                      # stack pointer
pointer datafile                # data file name
int	fd
bool	stat			# return status for file access

int	open()
bool	access()

begin
	call smark (sp)
        call salloc ( datafile, SZ_FNAME, TY_CHAR)
        call clgstr ( MPC_RESPONSE, Memc[datafile], SZ_FNAME)

	stat = access(Memc[datafile],0,0)
        if ( stat )
		fd = open( Memc[datafile], READ_ONLY, BINARY_FILE )
	else {		
            call printf("Could not access file: %s \n" )
            call pargstr(Memc[datafile])
	    call error(1, "spectral: can't get response file")
	}

	call sfree (sp)
	return (stat)
end

# 
#  ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
#  returns MPC header information

procedure mpc_hdr (fd, energies, nbins, nin, nout, minE, maxgrp)

pointer sp                      # stack pointer
pointer comment			#
pointer	binminE,  binmaxE	# bin energy boundaries
real    energies[ARB]           #
int     nbins                   #
int	fd,  i
int	nin, nout		# number of input and output bins
int	maxgrp			# max number of groups
real	minE			# minimum energy
real	gain			#

begin
	call smark (sp)
	call salloc ( comment, LEN_COMMENT, TY_CHAR)
	call salloc ( binminE, nbins, TY_REAL)
	call salloc ( binmaxE, nbins, TY_REAL)

	call mpc_rec1 ( fd, Memc[comment], LEN_COMMENT )
	call mpc_rec2 ( fd, nin, nout, maxgrp, minE )
	call mpc_rec3 ( fd, gain )
	call mpc_rec4 ( fd, Memr[binminE], Memr[binmaxE], nout )
	do i = 1, nout  {
	    if( i < nbins )  {
		energies[i]   = Memr[binminE+i-1]
		energies[i+1] = Memr[binmaxE+i-1]
		}
	    }	    

	call sfree (sp)
end




#  -------------------------------------------------------------------
#     The next five routines read in the five different types
#     of records in the MPC response file.
#  -------------------------------------------------------------------

procedure  mpc_rec1 ( fd, comment, len )

int	 fd,  stat,  reclen
int	 len
char	 comment[ARB]

int	 read()

begin
	stat = read( fd, reclen, SZ_INT )
	stat = read( fd, comment, (len*SZ_CHAR)/2 )
	stat = read( fd, reclen, SZ_INT )
end


procedure  mpc_rec2 ( fd, nin, nout, maxgrp, minE )

int      fd,  stat,  reclen
int	 nin,  nout,  maxgrp
real	 minE

int	 read()

begin
        stat = read( fd, reclen, SZ_INT )
	stat = read( fd, nin, SZ_INT )
	stat = read( fd, nout, SZ_INT )
	stat = read( fd, maxgrp, SZ_INT )
	stat = read( fd, minE, SZ_REAL )
        stat = read( fd, reclen, SZ_INT )
end


procedure  mpc_rec3 ( fd, gain )

int	 fd,  stat,  reclen
real	 gain

int	 read()

begin
        stat = read( fd, reclen, SZ_INT )
	stat = read( fd, gain,   SZ_REAL )
        stat = read( fd, reclen, SZ_INT )
end

procedure  mpc_rec4 ( fd, binminE, binmaxE, nbins )

int      fd,  stat,  reclen
int	 nbins,  i
real	 binminE[ARB],  binmaxE[ARB]

int	 read()

begin
        stat = read( fd, reclen, SZ_INT )
	do i = 1, nbins  {
	    stat = read( fd, binminE[i], SZ_REAL )
	    stat = read( fd, binmaxE[i], SZ_REAL )
	    }
        stat = read( fd, reclen, SZ_INT )
end


procedure  mpc_rec5(fd, Ebound, grps, is, ie, ele)

int      fd,  stat,  reclen
int      ncht,  grps,  g
int	 is[ARB],  ie[ARB]
real     Ebound,  ele[ARB]

int      read()

begin
	stat = read( fd, reclen, SZ_INT )
	stat = read( fd, EBound, SZ_REAL )
	stat = read( fd, grps,   SZ_INT )
	stat = read( fd, ncht,   SZ_INT )
	do g = 1, grps  {
	    stat = read( fd, is[g], SZ_INT )
	    stat = read( fd, ie[g], SZ_INT )
	    }
	do g = 1, grps  {
	    stat = read( fd, ele[is[g]], (ie[g]-is[g]+1)*SZ_REAL )
	    }
	stat = read( fd, reclen, SZ_INT )
end          
