#$Header: /home/pros/xray/lib/pros/RCS/tgr.x,v 11.0 1997/11/06 16:21:12 prosb Exp $
#$Log: tgr.x,v $
#Revision 11.0  1997/11/06 16:21:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:50  prosb
#General Release 2.3
#
#Revision 6.2  93/11/30  18:43:21  prosb
#MC		11/30/93		Update for bad qp_addf call
#
#Revision 6.1  93/11/30  11:50:24  prosb
#MC	11/30/93		Update for RDF
#
#Revision 6.0  93/05/24  15:54:19  prosb
#General Release 2.2
#
#Revision 5.2  93/05/19  17:09:29  mo
#no changes
#
#Revision 5.1  93/01/28  10:23:27  mo
#no changes
#
#Revision 5.0  92/10/29  21:17:33  prosb
#General Release 2.1
#
#Revision 4.1  92/10/21  16:25:36  mo
#MC	10/19/92	Zero pointer at start for output records
#
#Revision 4.0  92/04/27  13:50:07  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/02  17:27:44  mo
#MC	4/2/92	Add the PROS format string to QPOE/TGR when not made from FITS
#
#Revision 3.3  91/12/18  12:12:14  mo
#MC	12/18/91	Add check for interobi gap routine
#			and change the logic to check for
#			exactly 8000X in the first status word
#
#Revision 3.2  91/12/16  18:01:18  mo
#MC	12/16/91	Correct the check for INTER-OBI GAP
#			and make the INTER_OBI GAP and the END_F
#			OBSERVATION use conditional instrument code
#			since the IPC has an extra word
#
#Revision 3.1  91/12/11  19:23:18  mo
#MC	12/11/91	Remove the extra tabs in the IPC/TGR listing
#
#Revision 3.0  91/08/02  01:02:17  wendy
#General
#
#Revision 2.0  91/03/07  00:07:35  pros
#General Release 1.0
#
#
#	tgr.x -- tgr-handling routines
#

include <math.h>
include <qpset.h>
include <qpoe.h>
include <einstein.h>

#
#  GET_QPTGR -- get the tgr records from the qpoe file
#
procedure get_qptgr(qp, qptgr, nrecs)

pointer qp				# i: qpoe handle
pointer	qptgr				# o: pointer to tgr records
int	nrecs				# o: number of tgr records
int	got,total			# l: number of records read
int	temp,i
int	qp_geti()			# l: qpoe get routine
int	qp_read()			# l: qpoe read params
int	qp_accessf()			# l: qpoe param existence
pointer	ip

begin
	# return 0 if no records
	qptgr = NULL
	if( qp_accessf(qp, "NTGR") == NO ){
	    nrecs = 0
	    return
	}
	# get number of tgr records
	nrecs = qp_geti(qp, "NTGR")
	if( nrecs == 0 )
	    return
	# allocate space for tgr records
	call calloc(qptgr, SZ_QPTGR*nrecs, TY_STRUCT)
	# read in the record
#	got = qp_read (qp, "TGR", Memi[qptgr], nrecs, 1, "TGRREC")
        total = 0
        ip = qptgr
        do i=1,nrecs
        {
            temp = 1
            got = qp_read (qp, "TGR", Memi[ip], temp, i, "TGRREC")
            total = total + got
            ip = ip + SZ_QPTGR
        }                

#	if( got != nrecs )
	if( total != nrecs )
	{
            call eprintf("WARNING: wrong number of blt records read\n")
            call eprintf("WARNING: expected: %d got: %d\n")
                call pargi(nrecs)
                call pargi(total)
#	    call errori(1, "wrong number of tgr records read", total)
	}
end

#
#  PUT_QPTGR -- store tgr records in the qpoe header
#
procedure put_qptgr(qp, qptgr, nrecs)
pointer qp				# i: qpoe handle
pointer	qptgr				# i: pointer to tgr records
int	nrecs				# i: number of tgr records
int	qp_accessf()

begin
	# add a qpoe param telling number of tgr recs
	call qpx_addf (qp, "NTGR", "i", 1, "number of tgr records", 0)
	# store number of records
	call qp_puti (qp, "NTGR", nrecs)
	# Create an array "TGR" of type "TGRREC" and write to it.
	# create the tgr data type - includes alignment at end
	call qpx_addf (qp, "TGRREC", "{d,i,i,i,i,i,i}", 0, "TGR record type", 0)
	# create the tgr record descriptor for PROS- includes alignment at end
        if( qp_accessf(qp, "XS-TGRREC") == NO )
            call qpx_addf(qp, "XS-TGRREC", "c", SZ_LINE,
                     "PROS/QPOE event definition", 0)
        call qp_pstr(qp, "XS-TGRREC", XS_TGR)
#	call qpx_addf (qp, "XS-TGRREC", "{d:time,i:hut,i:stat1,i:stat2,i:stat3,i:stat4,i:align1}", 0, "TGR record type", 0)
	# create the tgr parameter array of type tgr
	# set the inherit flag explicitly so that the records can be inherited
	call qpx_addf (qp, "TGR", "TGRREC", nrecs, "TGR records", QPF_INHERIT)
	# and write the tgr records
	call qp_write (qp, "TGR", Memi[qptgr], nrecs, 1, "TGRREC")
end

#
#  DISP_QPTGR -- display tgr records
#

procedure disp_qptgr(pp, nrecs, inst)

pointer	pp		# i: short pointer to tgr records
int	nrecs		# i: number of tgr records
int	inst		# i: instrument

int	i, j, k		# l: counters
int	major		# l: major frame
int	minor		# l: minor frame
int	aqual		# l: aspect quality
int	asep		# l: aspect separation
int	mode		# l: pointing mode
int	bk_status	# l: bkgd status
int	vg_flag		# l: viewing geometry flag
int	hv_status	# l: high voltage status
int	vg_code		# l: viewing geometry code
int	pflags		# l: acd conditions flag
int	mask		# l: boolean mask
double	duration	# l: interval duration
pointer	cptr		# l: pointer to current tgr record
pointer	nptr		# l: pointer to next tgr record
int	and()		# l: boolean and
bool	interobi()	# l: routine to check interobi gaps

#short	foo1,foo2,foo3
begin
	# exit if nrecs is 0
	if( nrecs ==0 ){
	    call printf("\nNo TGR records\n")
	    return
	}

	# output a header
	call printf("\n\t\t\tX-ray TGR\n\n")
	call printf("time\t\tdur.\tmajor\tminor")
	call printf("\tmode aspect    asp-sep")
	if( inst == EINSTEIN_IPC)
	    call printf("\tbk   vgfl vgcd hv")
	else
#	    call printf("\t\t\t ")
	    call printf("")
	call printf("\tacd conditions")
	call printf("\tused\treasons\n\n")

	# process all tgr records
#	for(i=1; i<nrecs; i=i+1){
#	Don't forget to process the last record.  It must be
#	handled specially
	for(i=1; i<=nrecs; i=i+1){
		# point to the current record
		cptr = TGR(pp, i)
		nptr = TGR(pp, i+1)

		# display start time, duration, major and minor frame
		if( i == nrecs ) 	#  The last record is just EOF marker
		    duration = 0.0D0
		else
		    duration = TGR_TIME(nptr) - TGR_TIME(cptr)
		major = TGR_HUT(cptr)/128
		minor = and(TGR_HUT(cptr), 127)
		call printf("%-.2f\t%-.2f\t%-d\t%-d\t")
		call pargd(TGR_TIME(cptr))
		call pargd(duration)
		call pargi(major)
		call pargi(minor)

		# check for inter-observation gap
		if( interobi(cptr) ){
			call printf("\t\t\t\t\t\t\t\tInter-observation gap\n")
			next
		}

		# check for end of observation
		if( inst == EINSTEIN_IPC ){
		    if( TGR_STAT1(cptr) == -1 && TGR_STAT2(cptr) == -1 &&
		        TGR_STAT3(cptr) == -1 && TGR_STAT4(cptr) == -1 ){
			    call printf("\t\t\t\t\t\t\t\tEnd of data\n")
			    break
		    }
		}
		else if( inst == EINSTEIN_HRI){
#		    foo1 = TGR_STAT1(cptr)
#		    foo2 = TGR_STAT2(cptr)
#		    foo3 = TGR_STAT3(cptr)
		    if( TGR_STAT1(cptr) == -1 && TGR_STAT2(cptr) == -1 &&
		        TGR_STAT3(cptr) == -1 ){
			    call printf("\t\t\t\t\t\t\t\tEnd of data\n")
			    break
		    }
		}
		else
		    call error(1,"Unknown instrument\n")

		# display point mode
		mode = and(TGR_STAT3(cptr), 3)
		switch(mode){
		case 1:
		    call printf("P    ")
		case 2:
		    call printf("S    ")
		default:
		    call printf("U    ")
		}

		# display aspect information
		aqual = and(TGR_STAT1(cptr), 0FX)
		switch(aqual){
		case 0:
		    call printf("     NO  ")
		case 1:
		    call printf(" LOCKED  ")
		case 2:
		    call printf("   GYRO  ")
		case 4:
		    call printf("MAPMODE  ")
		default:
		    call errori(1, "impossible aspect code", aqual)
		}

		# display aspect separation
		if( aqual !=0 ){
		    asep = and(and(TGR_STAT1(cptr), 0FFX)/16, 0FX)*2
		    if( asep ==0 )
			call printf(" = 0\t")
		    else if( asep < 10 ){
			call printf("%2d-%1d\t")
			call pargi(asep-2)
			call pargi(asep)
		    }
		    else if( asep >= 10 ){
			call printf("%2d-%2d\t")
			call pargi(asep-2)
			call pargi(asep)
		    }
		}
		else
		    call printf("    \t")

		# display IPC information
		if( inst == EINSTEIN_IPC ){
		    bk_status = and(and(TGR_STAT3(cptr), 0FFFFX)/8192, 7X)
		    call printf("%-3d  ")
		    call pargi(bk_status)
		    vg_flag   = and(and(TGR_STAT3(cptr), 0FFFFX)/1024, 7X)
		    call printf("%-3d  ")
		    call pargi(vg_flag)
		    vg_code   = and(and(TGR_STAT4(cptr), 0FFFFX)/4096, 0FX)
		    call printf("%-3d  ")
		    call pargi(vg_code)
		    hv_status = and(and(TGR_STAT3(cptr), 0FFFFX)/64, 0FX)
		    call printf("%-3d\t")
		    call pargi(hv_status)

		}

		# display acd conditions
		pflags = and(TGR_STAT2(cptr), 0FFFFX)
		if( pflags !=0 ){
		    mask = 2
		    k = 0
		    do j=0,15{
			if( and(pflags, 2**j) !=0 ){
			    k = k+1
			    call printf("%c")
			    call pargi('p'-j)
			}
		    }
		    if( k < 8 )
			call printf("\t\t")
		    else
			call printf("\t")
		}
		else
		    call printf("\t\t")
		# display rejection information
		if( and(TGR_STAT1(cptr), 8000X) !=0 ){
		    call printf("N\t")
		}
		else
		    call printf("Y\t")

		# display reasons for data deletion
		if( and(TGR_STAT1(cptr), 4000X ) !=0 )
		    call printf("TLMDRP ")
		if( and(TGR_STAT1(cptr), 2000X ) !=0 ){
		    if( inst == EINSTEIN_HRI )
			call printf("EARBLK ")
		    else{
			if( vg_flag == 5 )
			    call printf("EARBLK ")
			else if( vg_flag == 4 )
			    call printf("BVWGEO ")
			else
			    call printf("?????? ")
		    }
		}
		if( and(TGR_STAT1(cptr), 1000X ) !=0 )
		    call printf("HIBKGD ")
		if( and(TGR_STAT1(cptr), 800X ) !=0 )
		    call printf("ASPECT ")
		if( and(TGR_STAT1(cptr), 200X ) !=0 )
		    call printf("HVOFF  ")
		if( and(TGR_STAT1(cptr), 100X ) !=0 )
		    call printf("USER  ")
		if( and(TGR_STAT1(cptr), 400X ) !=0 )
		    call printf("ACD ")

		# finish line
		call printf("\n")
	}

	# display the notes
	call tgr_notes()
end

#
# TGR_NOTES -- dispaly notes to the tgr records
#
procedure tgr_notes()

begin

call printf("\nNotes to the log:\n")
call printf("\tReasons for data deletion are:\n")
call printf("\t\tTLMDRP = telemetry dropout\n")
call printf("\t\tEARBLK = earth blocked\n")
call printf("\t\tBVWGEO = bad viewing geometry\n")
call printf("\t\tHIBKGD = high background count rate\n")
call printf("\t\tASPECT = aspect solution was not acceptable\n")
call printf("\t\tHVOFF = high voltage was off\n")
call printf("\t\tUSER = data was rejected manually by user\n")
call printf("\t\tACD/a = bad data, manually set from PCG editor (BAD)\n")
call printf("\t\tACD/b = earth blocked (EARBLK)\n")
call printf("\t\tACD/c = day light (SUN)\n")
call printf("\t\tACD/d = south atlantic anomaly, detector A (SAA-A)\n")
call printf("\t\tACD/e = south atlantic anomaly, detector B (SAA-B)\n")
call printf("\t\tACD/f = filter in place (FILTER)\n")
call printf("\t\tACD/g = OGS or heater 1 (HTR-1)\n")
call printf("\t\tACD/h = scan (FPCSCAN)\n")
call printf("\t\tACD/i = reserved (USER0)\n")
call printf("\t\tACD/j = reserved (USER1)\n")
call printf("\t\tACD/k = reserved (USER2)\n")
call printf("\t\tACD/l = reserved (USER3)\n")
call printf("\t\tACD/m = high voltage off (BIT14)\n")
call printf("\t\tACD/n = MPC calibration (MPCCAL)\n")
call printf("\t\tACD/o = instrument calibration (INSTCAL)\n")
call printf("\t\tACD/p = fiducial calibration (FIDCAL)\n")
call printf("\tAspect categories are:\n")
call printf("\t\tLOCKED = star trackers locked on guide stars\n")
call printf("\t\tGYRO = extrapolated solution using gyro data\n")
call printf("\t\tMAPMODE = star trackers not locked on guide stars\n")
call printf("\t\tbut stars observed and solution calculated\n")
call printf("\t\tNO = no aspect\n")
call printf("\tAverage separation error between guide stars is given in arcseconds.\n")
call printf("\tIn the case of map mode, this is an average over all stars observed during the segment.\n")
call printf("\tA major frame is 40.96 seconds long, and a minor frame is 0.32 seconds long.\n")
call printf("\tTime 0.0 is at minor frame 0 of the first major frame of this observation.\n")
call printf("\tInformational fields are:\n")
call printf("\t\tM = operation mode (P = pointing, S = slewing, U = unknown)\n")
call printf("\t\tBK = background level\n")
call printf("\t\tVGFL = viewing geometry flag\n")
call printf("\t\tVGCD = viewing geometry code\n")
call printf("\t\tHV = high voltage setting\n")
#call printf("\t\tAnom = anomalous conditions\n")

end

#
#  GOOD_QPTGR -- return a list of good intervals (start and stop times)
#

# increment size of returned list
define LISTINC 1024

procedure good_qptgr(pp, nrecs, inst, list, nlist, duration)

pointer	pp		# i: short pointer to tgr records
int	nrecs		# i: number of tgr records
int	inst		# i: instrument
pointer	list		# o: list of good intervals
int	nlist		# o: number of intervals in good list
double	duration	# o: total duration of good times (sec.)

int	i		# l: counters
int	listsize	# l: current size of list
pointer	cptr		# l: pointer to current tgr record
pointer	nptr		# l: pointer to next tgr record

bool	interobi()	# l: ck for interobi gap
int	and()		# l: boolean and

begin
	# allocate an initial buffer for intervals
	listsize = LISTINC*2
	call calloc(list, listsize, TY_DOUBLE)

	# start with 0 duration and no good intevals
	duration = 0.0D0
	nlist = 0

	# look for good intervals
	for(i=1; i<nrecs; i=i+1){
		# point to the current record
		cptr = TGR(pp, i)
		nptr = TGR(pp, i+1)

		# check for end of observation
		if( TGR_STAT1(cptr) == -1 && TGR_STAT2(cptr) == -1 &&
		     TGR_STAT3(cptr) == -1 && TGR_STAT4(cptr) == -1 )
			break

		# check for inter-observation gap
# Wrong logic, STAT1 must be exactly 8000x
#		if( and(TGR_STAT1(cptr), 8000X) == 8000X &&
		if( interobi(cptr) )
			next

		# check for rejected data
		if( and(TGR_STAT1(cptr), 8000X) !=0 )
		    next

		# if we can't get rid if it, this must be a good interval
		nlist = nlist + 1
		# add duration to the total
		duration = duration + (TGR_TIME(nptr) - TGR_TIME(cptr))

		# make sure we have enough space for this interval
		if( nlist > listsize ){
		    listsize = listsize + (LISTINC*2)
		    call realloc(list, listsize, TY_DOUBLE)
		}
		# and add the interval to the list
		Memd[list+((nlist-1)*2)]   = TGR_TIME(cptr)
		Memd[list+((nlist-1)*2)+1] = TGR_TIME(nptr)
	}
	# make the allocated space match the number of intervals
	call realloc(list, nlist*2, TY_DOUBLE)
end

bool procedure interobi(record)
pointer	record
#short foo1,foo2,foo3,foo4

begin
#	foo1 = TGR_STAT1(record)
#	foo2 = TGR_STAT2(record)
#	foo3 = TGR_STAT3(record)
#	foo4 = TGR_STAT4(record)
#  The and is tricky since this is now a long and we need an `unsigned' check
        if( and(TGR_STAT1(record), 0000FFFFX) == 8000X &&
  	    TGR_STAT2(record) ==0 && TGR_STAT3(record) ==0 &&
	    TGR_STAT4(record) ==0 )
		return(TRUE)
	else
		return(FALSE)
end	
