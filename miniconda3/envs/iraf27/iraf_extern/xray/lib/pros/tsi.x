#$Header: /home/pros/xray/lib/pros/RCS/tsi.x,v 11.0 1997/11/06 16:21:15 prosb Exp $
#$Log: tsi.x,v $
#Revision 11.0  1997/11/06 16:21:15  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:32  prosb
#General Release 2.4
#
#Revision 8.3  1994/09/21  16:46:12  dvs
#Modified disp_etsi to deal with the interobservatory gap in Einstein
#event files which have been QPAPPENDed.
#
#Revision 8.2  94/09/16  15:52:41  dvs
#Removed aux_padtype -- obsoleted.
#
#Revision 8.1  94/08/04  10:01:13  dvs
#Added routine disp_etsi which will display Einstein TSI records, either
#in Rev 0 or Rev 1 format.
#
#Revision 8.0  94/06/27  13:47:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:03  prosb
#General Release 2.3
#
#Revision 6.4  93/12/16  09:36:22  mo
#MC	12/1/93		Re-instate code to parse_descriptor for QP2FITS support
#
#Revision 6.3  93/11/30  18:43:45  prosb
#MC	11/30/93		Fix unused variables
#
#Revision 6.2  93/11/30  11:53:37  prosb
#MC	11/30/93		Update bad qp_addf routine
#
#Revision 6.1  93/11/30  11:49:39  prosb
#MC	11/30/93		Update for RDF
#
#Revision 6.0  93/05/24  15:54:33  prosb
#General Release 2.2
#
#Revision 5.3  93/05/19  17:05:03  mo
#MC	5/20/93		Add support for 'general' TSI record read and display
#
#Revision 5.2  93/04/28  15:33:10  mo
#MC	4/28/93		Add support for new EINSTEIN tsi records
#
#Revision 5.1  93/01/27  14:18:10  mo
#MC	1/28/93		Add tsi record extraction for Einstein IPC
#
#Revision 5.0  92/10/29  21:17:46  prosb
#General Release 2.1
#
#Revision 4.2  92/10/21  16:25:10  mo
#MC	10/21/92	Zero pointer at start for output records
#
#Revision 4.1  92/10/16  20:25:40  mo
#no changes.
#
#Revision 4.0  92/04/27  13:50:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/13  14:30:23  mo
#MC	no change
#
#Revision 3.2  92/03/23  10:16:00  mo
#MC	3/23/92		Fix name of PSPC status from tmb to rmb
#
#Revision 3.1  92/02/06  16:55:07  mo
#MC	2/5/92		Add routine to read TSI records with
#			arbitrary format
#			Fix the TSI record, pointer indexing
#			for the DISP routine
#
#Revision 3.0  91/08/02  01:02:22  wendy
#General
#
#Revision 2.2  91/07/30  20:37:23  mo
#MC	7/30/90		Fix the PSPC TSI display to match the HRI TIS
#			display. ( Bad structure syntax was causing seg. faults)
#
#Revision 2.1  91/07/30  20:16:45  mo
#Improve the readability of the format statements for HRI
#
#Revision 2.0  91/03/07  00:07:43  pros
#General Release 1.0
#
#
# Module:       TSI.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to access the TSI records in the PROS/QPOE file
# External:     get_(qp)tsi, put_(qp)tsi, disp_(qp)tsi 
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} mc    -- initial version 		-- 1/91
#               {n} <who> -- <does what> -- <when>

include <mach.h>
include <math.h>
include <qpset.h>
include <qpoe.h>
include <rosat.h>
include <einstein.h>
include	<qpc.h>

#
#  GET_TSI -- get the tsi records from the qpoe file
#
procedure get_tsi(qp, inst, qptsi, nrecs)
pointer qp				# i: qpoe handle
int	inst				# i: instrument type
pointer	qptsi				# o: pointer to tsi records
int	nrecs				# o: number of tsi records
int	got,total			# l: number of records read
int	reclen				# l: record length of TSI
int	qp_geti()			# l: qpoe get routine
int	qp_read()			# l: qpoe read params
int	qp_accessf()			# l: qpoe param existence
pointer	sp
pointer	defptr
pointer	tsidef
#int	deflen
int	cnt
int	temp,i
pointer	ip
begin
	call smark(sp)
	qptsi = NULL
	# return 0 if no records
	if( qp_accessf(qp, "NTSI") == NO )
	    nrecs = 0
	else
	# get number of tsi records
	    nrecs = qp_geti(qp, "NTSI")
	if( nrecs == 0)
	    return
	
	call salloc(tsidef,SZ_EXPR,TY_CHAR)
	if( qp_accessf(qp, "TSIREC") == YES)
	    call qp_gstr(qp,"TSIREC", Memc[tsidef], SZ_EXPR)
	else
	{
	    call eprintf("WARNING - no format string: %s keyword found for TSI\n")
	    call pargstr("TSIREC")
	    nrecs = 0
	    call sfree(sp)
	    return
	}

	call ev_auxsize(Memc[tsidef],reclen)

	reclen = reclen /  SZ_STRUCT
	# allocate space for tsi records
	call calloc(qptsi, reclen*nrecs, TY_STRUCT)
	# read in the record
        total = 0
        ip = qptsi
        do i=1,nrecs
        {
            temp = 1
            got = qp_read (qp, "TSI", Memi[ip], temp, i, "TSIREC")
            total = total + got
            ip = ip + reclen 
        }                

	if( total != nrecs )
	{
            call eprintf("WARNING: wrong number of blt records read\n")
            call eprintf("WARNING: expected: %d got: %d\n")
                call pargi(nrecs)
                call pargi(total)
	}
        call free_descriptor(defptr, cnt)
	call sfree(sp)
end

#
#  GET_GTSI -- get the general tsi records from the qpoe file ( not just ROSAT)
#
procedure get_gtsi(qp, tsiname, tsistr, tsiptr, tsicnt, tsisize, qptsi, tsidescp, nrecs)
pointer qp				# i: qpoe handle
char	tsiname				# i: name of TSI record
pointer	tsiptr				# o: pointer to list of elements
int	tsisize				# o: size of TSI record in TY_STRUCT units
#int	tsilen
int	tsicnt
pointer	qptsi				# o: pointer to tsi records
pointer	tsidescp			# o: structure of variables (argv)
int	nrecs				# o: number of tsi records
#int	ii
int	got,total			# l: number of records read
int	tsize
int	qp_geti()			# l: qpoe get routine
int	qp_read()			# l: qpoe read params
int	qp_accessf()			# l: qpoe param existence
int	i

pointer	sp				# l: stack pointer
pointer	number				# l: pointer to string key for number
pointer	tsidef				# l: pointer to format definition string
pointer	tsistr
pointer	tsirec
pointer	ip
#pointer	temptsi
					#     of recs
pointer	temp
#pointer	tqptsi

begin
	call smark(sp)
	call salloc(number,SZ_LINE,TY_CHAR)
	call salloc(temp,SZ_LINE,TY_CHAR)
	call salloc(tsidef,SZ_LINE,TY_CHAR)
	call salloc(tsirec,SZ_LINE,TY_CHAR)
	call calloc(tsistr,SZ_EXPR,TY_CHAR)

	call strcpy("N",Memc[number],SZ_LINE)
	call strcat(tsiname,Memc[number],SZ_LINE)
	call strcpy(tsiname,Memc[tsistr],SZ_LINE)
	call strcpy("REC",Memc[temp],SZ_LINE)
	call strcat(Memc[temp],Memc[tsistr],SZ_LINE)
# Save this guy for later
	call strcpy(Memc[tsistr],Memc[tsirec],SZ_LINE)
	call strcpy("XS-",Memc[tsidef],SZ_EXPR)
	call strcat(Memc[tsistr],Memc[tsidef],SZ_EXPR)
	# return 0 if no records
	if( qp_accessf(qp, Memc[number]) == NO )
	    nrecs = 0
	else
	# get number of tsi records
	    nrecs = qp_geti(qp, Memc[number])
	if( nrecs == 0)
	    return
		
	call qp_gstr(qp,Memc[tsidef],Memc[tsistr],SZ_EXPR)
	#---------------------------------------------------
	#  Determine length of records by parsing descriptor
	#---------------------------------------------------
        call strlwr(Memc[tsistr])

        #-------------------------
        # Check/expand the aliases
        #-------------------------
        call ev_alias(Memc[tsistr], Memc[tsistr], SZ_EXPR)
 
        #---------------------------------------------------------
        # Parse the descriptors, compare them, and assign the argv 
        # variables 
        #---------------------------------------------------------
        call parse_descriptor(Memc[tsistr],tsiptr,tsisize,tsicnt) 
	call ev_auxsize(Memc[tsistr],tsisize)
	tsize = tsisize/SZ_STRUCT

	# get number of tsi records

	# allocate space for gti records
	call calloc(qptsi, tsize*nrecs, TY_STRUCT)
	# read in the record
        total = 0
        ip = qptsi
        do i=1,nrecs
        {
            got = qp_read (qp, tsiname, Memi[ip], 1, i, Memc[tsirec])
            total = total + got
            ip = ip + tsize
        }                

	if( total != nrecs )
	    call errori(1, "wrong number of gti records read", total)

	call sfree(sp)
end

#
#  PUT_TSI -- store tsi records in the qpoe header
#
procedure put_tsi(qp, qptsi, nrecs, qphead, recdef, prostsi)
pointer qp				# i: qpoe handle
pointer	qptsi				# i: pointer to tsi records
int	nrecs				# i: number of gti records
pointer	qphead				# i: pointer to qpoe header struct
pointer	recdef,prostsi

bool	streq()
int	qp_accessf()

begin
	# add a qpoe param telling number of tsi recs
	call qpx_addf (qp, "NTSI", "i", 1, "number of tsi records", 0)
	# store number of records
	call qp_puti (qp, "NTSI", nrecs)
	
    if( !streq(Memc[recdef],NULL) )
    {
# Create an array "TSI" of type "TSIREC" and write to it.
#        # add the generic IRAF record definition entry

	call qpx_addf (qp, "TSIREC", Memc[recdef], 0, "TSI record type", 0)
#	# add the PROS macro definition string for the record definition
        if( qp_accessf(qp, "XS-TSIREC") == NO )
            call qpx_addf(qp, "XS-TSIREC", "c", SZ_EXPR,
                     "PROS/QPOE event definition", 0)
        call qp_pstr(qp, "XS-TSIREC", Memc[prostsi])
    }
#
    if( nrecs > 0 )
    {
#	# create the tsi parameter array of type tsi 
#	# set the inherit flag explicitly so that the records can be inherited
#	#    Let the record length be 0 so that it can be extended indefinitely
	call qpx_addf (qp, "TSI", "TSIREC", 0, "TSI records", QPF_INHERIT)
#	# and write the tsi records
	call qp_write (qp, "TSI", Memi[qptsi], nrecs, 1, "TSIREC")
    }
end

#
#  DISP_TSI -- display tsi records
#
procedure disp_tsi(gptr, nrecs, inst)

pointer	gptr		# i: short pointer to tsi records
int	nrecs		# i: number of tsi records
int	inst		# i: instrument

int	i		# l: counter
pointer	cptr		# l: pointer to current tsi record
pointer	nptr		# l: pointer to next tsi record

#pointer	name
#pointer	comp
#pointer	offset
#pointer	type
#pointer	tbuf
#int	ncomp
#extern	s_adisp(),i_adisp(),l_adisp(),r_adisp(),d_adisp(),x_adisp()
begin
	# exit if nrecs is 0
	if( nrecs ==0 ){
	    call printf("\nNo tsi records\n")
	    return
	}


	# output a header
	call printf("\n\t\t\tTemporal Status Intervals\n\n")
	switch(inst){
	case ROSAT_HRI:
	    call printf("\tstart\t\tduration  failed?  on/off\thibk\thvlev\tvg\taststat\tasperr\thqual\tsaadind\tsaada\tsaadb\ttemp1\ttemp2\ttemp3\t\n")

	    # process all tsi records
	    for(i=1; i<=nrecs-1; i=i+1){
	      # point to the current record
	      cptr = HTSI(gptr, i)
	      nptr = HTSI(gptr, i+1)
	      call printf("%13.2f\t%13.2f\t%8x%8x\t%3d\t%2d\t%1d\t%1d\t%2d\t%4x\t%3d\t%3d\t%3d\t%3d\t%3d\t%3d\n")
		call pargd(TSI_START(cptr))
		call pargd(TSI_START(nptr)-TSI_START(cptr))
		call pargi(TSI_FAILED(cptr))
		call pargi(TSI_LOGICALS(cptr))
		call pargi(TSI_HIBK(cptr))
		call pargi(TSI_HVLEV(cptr))
		call pargi(TSI_VG(cptr))
		call pargi(TSI_ASPSTAT(cptr))
		call pargi(TSI_ASPERR(cptr))
		call pargi(TSI_HQUAL(cptr))
		call pargi(TSI_SAADIND(cptr))
		call pargi(TSI_SAADA(cptr))
		call pargi(TSI_SAADB(cptr))
		call pargi(TSI_TEMP1(cptr))
		call pargi(TSI_TEMP2(cptr))
		call pargi(TSI_TEMP3(cptr))
	    }
	case ROSAT_PSPC:
	    call printf("start\t\tduration\tfailed?\ton/off\trmb\tdfb\n")

	    # process all tsi records
	    for(i=1; i<=nrecs-1; i=i+1){
	      # point to the current record
	      cptr = PTSI(gptr, i)
	      nptr = PTSI(gptr, i+1)
	      call printf("%.2f\t%.2f\t\t%x\t%x\t%2d\t%2d\n")
		call pargd(TSI_START(cptr))
		call pargd(TSI_START(nptr)-TSI_START(cptr))
		call pargi(TSI_FAILED(cptr))
		call pargi(TSI_LOGICALS(cptr))
		call pargi(TSI_RMB(cptr))
		call pargi(TSI_DFB(cptr))
	    }
        case EINSTEIN_IPC,EINSTEIN_HRI:
             call eprintf("Error: disp_tsi should not be displaying Einstein data.")  
	default:
	    call eprintf("No TSI format defined for this instrument")
	}
	call printf("\n")
end

#
#  DISP_ETSI -- display tsi records for Einstein QPOE files
#
procedure disp_etsi(gptr, nrecs, qphead)

pointer gptr            # i: short pointer to tsi records
int     nrecs           # i: number of tsi records
pointer qphead          # i: QPOE header

int     i               # l: counter
pointer cptr            # l: pointer to current tsi record
pointer nptr            # l: pointer to next tsi record

begin
        # exit if nrecs is 0
        if( nrecs ==0 ){
            call printf("\nNo tsi records\n")
            return
        }

        # output a header
        call printf("\n\t\t\tTemporal Status Intervals\n\n")

        # REV 0 VERSION:
        if (QP_REVISION(qphead)==0)
        {
            call printf("\ttstart       duration  failed  logicals hibk  hvlev vgflag   aspstat   asperr attcode   vg    anon\t\t\n")
            # process all tsi records
            for(i=1; i<=nrecs-1; i=i+1){
              # point to the current record
              cptr = ETSI(gptr, i)
              nptr = ETSI(gptr, i+1)
              call printf(" %13.2f  %13.2f%8x%8x   %3d    %2d      %1d")
                call pargd(TSI_START(cptr))
                call pargd(TSI_START(nptr)-TSI_START(cptr))
                call pargi(TSI_FAILED(cptr))
                call pargi(TSI_LOGICALS(cptr))
                call pargi(TSI_HIBK(cptr))
                call pargi(TSI_HVLEV(cptr))
                call pargi(TSI_VGFLAG(cptr))
      	      call printf("     %7s   %2d      %2d     %2d%8x\n")

              # display aspect information
              switch(TSI_ASPSTAT(cptr)){
                case 0,15:
                    call pargstr("     NO  ")
                case 1:
                    call pargstr(" LOCKED  ")
                case 2:
                    call pargstr("   GYRO  ")
                case 4:
                    call pargstr("MAPMODE  ")
                default:
                    call errori(1, "impossible aspect code", TSI_ASPSTAT(cptr))
               }
               call pargi(TSI_ASPERR(cptr))
               call pargi(TSI_ATTCODE(cptr))
               call pargi(TSI_VG(cptr))
               call pargi(TSI_ANOM(cptr))
            }
        }
        else  # Newer TSI records
        {
            call printf("\tstart       duration  failed logicals bkcode hvlev viewgeom aspstat asperr attcode vgcode  anom\t\t\n")

            # process all tsi records
            for(i=1; i<=nrecs-1; i=i+1){
            # point to the current record
            cptr = EREV1_TSI(gptr, i)
            nptr = EREV1_TSI(gptr, i+1)

            call printf("%13.2f  %13.2f%8x%8x   %3d    %2d      %1d")
             call pargd(TSI_EREV1_TIME(cptr))
             call pargd(TSI_EREV1_TIME(nptr)-TSI_EREV1_TIME(cptr))
             call pargi(TSI_EREV1_FAILED(cptr))
             call pargi(TSI_EREV1_LOGICALS(cptr))
             call pargs(TSI_EREV1_BKCODE(cptr))
             call pargs(TSI_EREV1_HVLEV(cptr))
             call pargs(TSI_EREV1_VIEWGEOM(cptr))

            # display aspect information
            call printf("     %7s   %2d      %2d     %2d%8x\n")
            switch(TSI_EREV1_ASPSTAT(cptr)){
                case 0:
                   call pargstr("     NO")
                case 1:
                   call pargstr(" LOCKED")
                case 2:
                   call pargstr("   GYRO")
                case 4:
                   call pargstr("MAPMODE")
                default:
                   call errori(1, "impossible aspect code", TSI_EREV1_ASPSTAT(cptr))
                }
             call pargs(TSI_EREV1_ASPERR(cptr))
             call pargs(TSI_EREV1_ATTCODE(cptr))
             call pargs(TSI_EREV1_VGCODE(cptr))
             call pargs(TSI_EREV1_ANOM(cptr))
             }
        }

        call printf("\n")
end

#
#  DISP_GTSI -- display any general format tsi records
#
procedure disp_gtsi(gptr, nrecs, inst, tsidef, tsisize)

pointer	gptr		# i: short pointer to tsi records
int	nrecs		# i: number of tsi records
int	inst		# i: instrument
char	tsidef[ARB]	# i: input definition string
int	tsisize		# i: length of data (in SZ_STRUCT)

int	ii,jj		# l: counter
pointer	cptr		# l: pointer to current tsi record
#pointer	nptr		# l: pointer to next tsi record

#pointer	sptr
pointer	name
pointer	comp
pointer	offset
pointer	type
pointer	tbuf
int	ncomp
extern	s_adisp(),i_adisp(),l_adisp(),r_adisp(),d_adisp(),x_adisp()
begin
	# exit if nrecs is 0
	if( nrecs ==0 ){
	    call printf("\nNo tsi records\n")
	    return
	}

	
	# output a header
	call printf("\n\t\t\tTemporal Status Intervals\n\n")

	    call salloc(tbuf,SZ_EXPR,TY_CHAR)
	    call ev_compile(tsidef, "", name, comp, offset, type, ncomp,
                      s_adisp, i_adisp, l_adisp, r_adisp, d_adisp, x_adisp)
	    Memc[tbuf]=EOS
	    call qp_aheader(name, type, ncomp, Memc[tbuf], SZ_EXPR)
	    call printf("%s\n")
		call pargstr(Memc[tbuf])
            for(ii=1; ii<=nrecs; ii=ii+1){
              # point to the current record
#  Convert from STRUCT units to SHORT units

		cptr = gptr + (ii-1)*(tsisize)  
		Memc[tbuf]=EOS
		do jj=1,ncomp
		{
 	            call zcall4(Memi[comp+jj-1],Memi[offset+jj-1], 
				cptr, Memc[tbuf], SZ_EXPR)
		}
	    	call printf("%s\n")
		    call pargstr(Memc[tbuf])
		call flush(STDOUT)
	    }


	call printf("\n")
	call ev_destroycompile(name, comp, offset, type, ncomp)

end

