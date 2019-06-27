# $Header: /home/pros/xray/xdataio/hkfilter/RCS/hkfilter.x,v 11.0 1997/11/06 16:37:42 prosb Exp $
# $Log: hkfilter.x,v $
# Revision 11.0  1997/11/06 16:37:42  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:04:02  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:00:11  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/15  11:33:26  janet
#jd - added more precision to gti output format.
#
#Revision 7.0  93/12/27  18:46:35  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:22:03  mo
#MC	12/22/93	Reverse rootnmae arguments
#
#Revision 6.0  93/05/24  16:43:37  prosb
#General Release 2.2
#
#Revision 5.1  93/05/20  09:02:09  mo
#MC	5/20/93	Add support for 'general' TSI records
#
#Revision 5.0  92/10/29  22:39:34  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:24:31  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  16:24:08  mo
#MC	4/24/92		Correct order for qpparse and rootname calls
#			Check that the input QPOE exists ( otherwise
#			segmentation violation )
#
#Revision 1.1  92/03/23  10:08:25  mo
#Initial revision
#
#
# Module:       HKFILTER
# Project:      PROS -- ROSAT RSDC
# Purpose:      Create a TIME filter list from an TSI (HK) filter list
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1992.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MC	initial version Jan 92
#               {n} <who> -- <does what> -- <when>
#

include	<qpoe.h>
include	<rosat.h>
define	SZ_EXPR	1024
define	HK_FATAL	1

procedure t_hkfilter()

pointer	hkname
pointer	hkstring
pointer	qpoename
pointer	poeroot
pointer	tempname
pointer	filtname
pointer	tsidef
pointer	bgintvs
pointer	egintvs
pointer	filter
pointer	timsp
pointer	tsiptr
pointer	tsidescp

int	i
int	tsisize		# l: size of input tsi record
int	nrecs
int	numints
int	tsicnt
int	totints
int		nmacros
int		display
#int	junk
int	slen
bool	merge
bool	mklst
bool	clobber

pointer	qp
pointer	sp
pointer	fd
pointer	flt
pointer	msymbols
pointer	mvalues
#pointer	ip
pointer	iptr
pointer	nptr
pointer	qptsi
pointer	qphead
pointer	qp_open()
pointer	open()
pointer	flt_open()
    
#int	x_gstr()
int	clgeti()
int	flt_evaluate()
int	qp_access()
int	strlen()
bool	clgetb()

begin
	call smark(sp)
	call salloc( qpoename, SZ_PATHNAME, TY_CHAR)
	call salloc( tempname, SZ_PATHNAME, TY_CHAR)
	call salloc( poeroot, SZ_PATHNAME, TY_CHAR)
	call salloc( filtname, SZ_PATHNAME, TY_CHAR)
	call salloc( hkname, SZ_EXPR, TY_CHAR)
	call salloc( hkstring, SZ_EXPR, TY_CHAR)
#	call salloc( tsidef, SZ_EXPR, TY_CHAR)
	call salloc( filter, SZ_EXPR, TY_CHAR)
	call salloc( timsp, SZ_EXPR, TY_CHAR)

	call clgstr("qpoefile",Memc[qpoename],SZ_PATHNAME)
	clobber = clgetb("clobber")
	call clgstr("filtname",Memc[filtname],SZ_PATHNAME)
	call clgstr("hkformat",Memc[hkstring],SZ_EXPR)
	call clgstr("hkparam",Memc[hkname],SZ_EXPR)
	display = clgeti("display")

        # separate poefile into a root file and an event list spec
        # check the qpoe file existence
        call qpparse(Memc[qpoename], Memc[poeroot], SZ_PATHNAME,
                        Memc[filter], SZ_EXPR)
	if( qp_access (Memc[poeroot], READ_ONLY) == NO){
	    call eprintf("Cannot access QPOE file: %s\n")
		call pargstr(Memc[poeroot])
	    call error(HK_FATAL,"QPOE file does not exist")
	}
	call rootname(Memc[poeroot],Memc[filtname],".flt",SZ_PATHNAME)
	call clobbername(Memc[filtname],Memc[tempname],clobber,SZ_PATHNAME)
        qp = qp_open(Memc[poeroot], READ_ONLY, NULL)
	call get_qphead(qp,qphead)
	flt = flt_open(qp)
#        junk = x_gstr(qp, Memc[hkstring], Memc[tsidef], SZ_EXPR)
#        junk = x_gstr(qp, "TSIREC", Memc[tsidef], SZ_EXPR)
#	call get_tsi(qp, QP_INST(qphead), qptsi, nrecs)
#	call get_gtsi(qp, Memc[hkname], tsisize, qptsi, nrecs)
        call get_gtsi(qp, Memc[hkname], tsidef, tsiptr, tsicnt, tsisize, 
                              qptsi, tsidescp, nrecs)
	call mfree(tsiptr,TY_STRUCT)
	call mfree(tsidescp,TY_STRUCT)
#	call mfree(tsidef,TY_CHAR)

	call ev_crelist(Memc[tsidef],msymbols,mvalues,nmacros)
	do i=1,nmacros{
	    call flt_addmacro(flt,Memc[Memi[msymbols+i-1]],
				   Memc[Memi[mvalues+i-1]])
	}
       # get the size of the eventdef
#        call ev_size(Memc[tsidef], tsisize)
#        tsisize = tsisize/SZ_SHORT
#        # set size of record we are dealing with, padded for alignment
#        call qpc_roundup(tsisize, tsisize)
#	# get size in units of TY_STRUCT
#        tsisize = (tsisize*SZ_SHORT)/SZ_STRUCT
#        # Strip off the leading and trailing []
        slen = strlen(Memc[filter])
        if( slen >= 2 ){
            call strcpy( Memc[filter+1],Memc[timsp], SZ_EXPR)
            Memc[timsp+slen-2]=NULL
        }
# If the filter is the Null string no need to strip the []`s
	call strcpy(Memc[timsp],Memc[filter],SZ_EXPR)

	call flt_compile(flt,Memc[filter])
	call calloc(bgintvs,(nrecs+1),TY_DOUBLE)
	call calloc(egintvs,(nrecs+1),TY_DOUBLE)

#	Get the 'standard' pre-defined good time intervals
	totints = 0

#	Check all the TSI records against the current filter
	do i=1,nrecs-1{
#	    switch(QP_INST(qphead)){
#	    case ROSAT_HRI:
                iptr = P2S(qptsi) + (i-1)*tsisize
                nptr = P2S(qptsi) + i*tsisize
#	    case ROSAT_PSPC:
#                iptr = PTSI(qptsi, i)
#                nptr = PTSI(qptsi, i+1)
#	    default:
#		call error(0,"No TSI records for this instrument")
#  	    }
	    numints = flt_evaluate(flt,iptr)
	    if( numints > 0 ){
#	        If the TSI record 'passed' extract its start and stop time
#		( stop = start of succeeding record) and save in the 
#		GINTVS array for later
                call amovs(Mems[iptr],Memd[bgintvs+(totints)],SZ_DOUBLE)
                call amovs(Mems[nptr],Memd[egintvs+(totints)],SZ_DOUBLE)
#                Memd[bgintvs+(totints)]   = (TSI_START(iptr))
#                Memd[egintvs+(totints)] = (TSI_START(nptr))
	    }
	    totints = totints + numints
	}
	call printf("number of ints: %d number accepted: %d\n")
		call pargi(nrecs)
		call pargi(totints)
#	Write out the GINTVs ( array of start and stop) in format of
#	a qpoe timefilter
	merge=TRUE
	mklst=TRUE
        fd = open (Memc[tempname], WRITE_ONLY, TEXT_FILE)
	call output_gtis (Memd[bgintvs], Memd[egintvs],totints, "%.7f", display, fd, merge, mklst)
	call flt_close(flt)
	if( display >= 1)
	    call printf("Writing output file - %s\n")
		call pargstr(Memc[filtname])
	call finalname(Memc[tempname],Memc[filtname])
	call close(fd)
	call ev_destroylist(msymbols,mvalues,nmacros)
	call mfree(bgintvs,TY_DOUBLE)
	call mfree(egintvs,TY_DOUBLE)
	call mfree(qptsi,TY_STRUCT)
	call sfree(sp)
end

