#$Header: /home/pros/xray/lib/pros/RCS/bal.x,v 11.0 1997/11/06 16:20:16 prosb Exp $
#$Log: bal.x,v $
#Revision 11.0  1997/11/06 16:20:16  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:28  prosb
#General Release 2.3.1
#
#Revision 7.1  94/04/13  15:58:12  mo
#MC 	12/28/93		Add check for ZERO records - don't die
#
#Revision 7.0  93/12/27  18:08:50  prosb
#General Release 2.3
#
#Revision 6.2  93/10/28  12:15:53  dvs
#Modified BLT structure to add BLT_QUALITY and BLT_FORMAT.
#If the qpoe file is revision 0, the BLT records will not have
#a quality code, so we set BLT_QUALITY to 1 (the default).
#If the qpoe file has revision >0, the BLT_QUALITY value will
#be in the qpoe file itself.
#
#Also modified PUT_QPBAL to have the correct structure which is
#in the BLT structure.  
#
#Lastly, modified the disp_qpbal routine to display the quality
#code and fixed up some of the tabbing.
#
#Revision 6.1  93/10/26  18:24:28  mo
#MC	10/26/93		Update with option to convert sign
#				convention to current ROSAT standard
#				Also add element to BLT structure
#
#Revision 6.0  93/05/24  15:43:58  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:14:55  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:04  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/02  17:27:20  mo
#4/2/92	Add the PROS format string to QPOE Files when not made from FITS
#
#Revision 3.1  92/03/30  18:14:40  mo
#MC	3/30/92		Remove double indexed pointer bug
#
#Revision 3.0  91/08/02  00:48:52  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:39  pros
#General Release 1.0
#
#
# BAL.X -- routines for handling blt (bal temporal/constant aspect) files
#

include	<mach.h>
include <math.h>
include <qpset.h>
include <qpoe.h>
include <einstein.h>
define	SZ_EXPR	1024
define	BAL_FATAL 1	

#
#  GET_QPBAL -- get the blt records from the qpoe file
#
procedure get_qpbal(qp, qpblt, nrecs)

pointer qp				# i: qpoe handle
pointer	qpblt				# o: pointer to blt records
int	nrecs				# o: number of blt records
int	got,total			# l: number of records read
int	i,temp
int	reclen,format
pointer	ip,recdef,sp
int	qp_geti()			# l: qpoe get routine
int	qp_read()			# l: qpoe read params
int	qp_accessf()			# l: existence of qpoe param
#int	defptr,deflen,cnt

begin
	call smark(sp)
	# see if param exists
	if( qp_accessf(qp, "NBLT") == NO ){
	    nrecs = 0
	    return
	}
	# get number of blt records
	nrecs = qp_geti(qp, "NBLT")

        call salloc(recdef,SZ_EXPR,TY_CHAR)
       if( qp_accessf(qp, "BLTREC") == YES)
            call qp_gstr(qp,"BLTREC", Memc[recdef], SZ_EXPR)
        else
        {
            call eprintf("WARNING - no format string: %s keyword found for BLT\n")
            call pargstr("BLTREC")
            nrecs = 0
            call sfree(sp)
            return
        }
 
#        call parse_descriptor(Memc[recdef],defptr,deflen,cnt)
#        deflen = deflen / SZB_CHAR
#        call qpc_roundup(deflen,reclen)

#	call ev_auxsize(Memc[recdef],reclen)
#        reclen = reclen /  SZ_STRUCT
	reclen = SZ_QPBLT

	# allocate space for blt records
	call calloc(qpblt, reclen*nrecs, TY_STRUCT)
	# read in the record
#	got = qp_read (qp, "BLT", Memi[qpblt], nrecs, 1, "BLTREC")
        total = 0
	ip = qpblt
        if( qp_accessf(qp, "REVISION") == YES)
	{
	    format = qp_geti(qp,"REVISION")
	}
	else
	{
            format = 0
	}
        do i=1,nrecs
        {
            temp = 1
            got = qp_read (qp, "BLT", Memi[ip], temp, i, "BLTREC")
	    # Convert to 'standard' orientation (revision >= 1)
	    if( format < 1 ) 		#  OLD REV0 files, standard intervals
	    {
	        BLT_FORMAT[ip] = 0
		BLT_QUALITY[ip]=1	# good time, good aspect (default)
	    	call bal_flip(ip)
	    }
	    else
		BLT_FORMAT[ip] = format
            total = total + got
            ip = ip + reclen
        }                
#	if( got != nrecs )
	if( total != nrecs )
	{
	    call eprintf("WARNING: wrong number of blt records read\n")
	    call eprintf("WARNING: expected: %d got: %d\n")
		call pargi(nrecs)
		call pargi(total)
	}
	call sfree(sp)
end

#
#  BAL_FLIP -- Convert BLT format to NEW REVISION 1 convention
#
procedure bal_flip(qpblt)
pointer	qpblt
begin
        BLT_ASPX[qpblt] = - BLT_ASPX[qpblt]
        BLT_ASPY[qpblt] = - BLT_ASPY[qpblt]
        BLT_ROLL[qpblt] = - BLT_ROLL[qpblt]
        BLT_BOREROT[qpblt] = - BLT_BOREROT[qpblt]
        BLT_BOREX[qpblt] = - BLT_BOREX[qpblt]
        BLT_BOREY[qpblt] = - BLT_BOREY[qpblt]
        BLT_NOMROLL[qpblt] = - BLT_NOMROLL[qpblt]
        BLT_BINROLL[qpblt] = - BLT_BINROLL[qpblt]
        BLT_FORMAT[qpblt] = mod(BLT_FORMAT[qpblt]+1,2) 
end

#  PUT_QPBAL -- store blt records in the qpoe header
#
procedure put_qpbal(qp, qpblt, nrecs)
pointer qp				# i: qpoe handle
pointer	qpblt				# i: pointer to blt records
int	nrecs				# i: number of blt records
int	qp_accessf()

begin
	# add a qpoe param telling number of blt recs
	call qpx_addf (qp, "NBLT", "i", 1, "number of blt records", 0)
	# store number of records
	call qp_puti (qp, "NBLT", nrecs)
	# Create an array "BLT" of type "BLTREC" and write to it.
	# create the blt data type - 
	# - includes room for BLT_QUAL, and two extra integers so
	#   the record size matches the structure size
	call qpx_addf (qp, "BLTREC", "{d,d,r,r,r,r,r,r,r,r,r,i,i,i}", 0,
		      "blt record type", 0)
        if( qp_accessf(qp, "XS-BLTREC") == NO )
            call qpx_addf(qp, "XS-BLTREC", "c", SZ_LINE,
                     "PROS/QPOE event definition", 0)
        call qp_pstr(qp, "XS-BLTREC", XS_BLT)
	# create the blt parameter array of type blt
	# set the inherit flag explicitly so that the records can be inherited
	call qpx_addf (qp, "BLT", "BLTREC", nrecs, "blt records", QPF_INHERIT)
	# and write the blt records
	if( nrecs > 0 )
	{
	    if( BLT_FORMAT(qpblt) != 0 )
	        call error(BAL_FATAL,"BLT data not in valid REV0 format")
	    call qp_write (qp, "BLT", Memi[qpblt], nrecs, 1, "BLTREC")
	}
end

#
#  DISP_QPBAL -- display blt records
#

procedure disp_qpbal(bptr, nrecs, inst)

pointer	bptr		# i: short pointer to blt records
int	nrecs		# i: number of blt records
int	inst		# i: instrument

int	i		# l: counter
pointer	cptr		# l: pointer to current blt record

begin
	# exit if nrecs is 0
	if( nrecs ==0 ){
	    call printf("\nNo blt records\n")
	    return
	}

	# exit if inst is not ipc
	if( inst != EINSTEIN_IPC ){
	    call printf("\nOnly Einstein IPC has blt records\n")
	    return
	}

	# output a header
	call printf("\n\t\t\tX-ray blt\n\n")
	call printf("start\t\tend\t\tduration\taspx\taspy\troll\tbal\t")
	call printf("borex\tborey\tboreroll\tnomroll\tbinroll\tqual\n")

	# process all blt records
	for(i=1; i<=nrecs; i=i+1){
		# point to the current record
		cptr = BLT(bptr, i)
		call printf("%.2f\t%.2f\t%.2f\t\t%.3f\t%.3f\t%.5f\t%.2f\t")
		call pargd(BLT_START(cptr))
		call pargd(BLT_STOP(cptr))
		call pargd(BLT_STOP(cptr)-BLT_START(cptr))
		call pargr(BLT_ASPX(cptr))
		call pargr(BLT_ASPY(cptr))
		call pargr(BLT_ROLL(cptr))
		call pargr(BLT_BAL(cptr))
		call printf("%.2f\t%.2f\t%.2f\t\t%.3f\t%.3f\t%d\n")
		call pargr(BLT_BOREX(cptr))
		call pargr(BLT_BOREY(cptr))
		call pargr(BLT_BOREROT(cptr))
		call pargr(BLT_NOMROLL(cptr))
		call pargr(BLT_BINROLL(cptr))
		call pargi(BLT_QUALITY(cptr))
	}
	call printf("\n")
end

