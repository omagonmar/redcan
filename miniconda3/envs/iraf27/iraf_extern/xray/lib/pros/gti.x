#$Header: /home/pros/xray/lib/pros/RCS/gti.x,v 11.0 1997/11/06 16:20:31 prosb Exp $
#$Log: gti.x,v $
#Revision 11.0  1997/11/06 16:20:31  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:45  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:43  prosb
#General Release 2.3
#
#Revision 6.2  93/11/30  11:53:24  prosb
#MC	11/30/93		Update bad qp_addf routine
#
#Revision 6.1  93/11/30  11:48:23  prosb
#MC	11/30/93		Update for RDF
#
#Revision 6.0  93/05/24  15:44:56  prosb
#General Release 2.2
#
#Revision 5.2  93/05/19  17:02:34  mo
#MC/JM	5/20/93		Update GTI to use 'rounded' buffer sizes 					on new GTI records to avoid SEGV.
#
#Revision 5.1  93/04/22  12:06:56  jmoran
#JMORAN - RATFITS GTI changes
#
#Revision 5.0  92/10/29  21:16:53  prosb
#General Release 2.1
#
#Revision 4.2  92/10/21  16:24:53  mo
#MC	10/21/92	Zero pointer at start for output records
#
#Revision 4.1  92/10/16  20:25:20  mo
#no changes
#
#Revision 4.0  92/04/27  13:48:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/13  14:29:19  mo
#MC	4/13/92		Parameterize the GTI record format with a
#			defined string
#
#Revision 3.1  92/01/20  15:47:52  mo
#MC	1/20/92		Modify the write QPOE/GTI code to be able
#			to update GTI as well as create
#
#Revision 3.0  91/08/02  01:00:47  wendy
#General
#
#Revision 2.0  91/03/07  00:07:04  pros
#General Release 1.0
#
#
# Module:       GTI.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to access the aux QPOE records - GTI ( good time int.)
# External:     get_qpgti, put_qpgti, disp_qpgti
# Local:        NONE
# Description:  These routines access the OPAQUE BINARY QPOE arrays defined
#		by PROS to define the GOOD TIME INTERVAL records
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} EGM   -- initial version 1989
#               {1} MC    -- Correct the structure indexing for the display
#							Jan. 1991
#               {n} <who> -- <does what> -- <when>

include <mach.h>
include <math.h>
include <qpset.h>
include <qpoe.h>
include <rosat.h>
define	SZ_EXPR	1024

#
#  GET_QPGTI -- get the gti records from the qpoe file
#

procedure get_qpgti(qp, qpgti, nrecs, gti_root)

pointer qp                              # i: qpoe handle
pointer qpgti                           # o: pointer to gti records
int     nrecs                           # o: number of gti records
char	gti_root[ARB]			# i: root string for GTI access
int     got                             # l: number of records read
int     qp_geti()                       # l: qpoe get routine
int     qp_read()                       # l: qpoe read params
int     qp_accessf()                    # l: qpoe param existence
#int	size_rec
#int	get_gti_recsize()
pointer	tbuf			# l: temp char buffer
pointer pbuf			# l: temp char buffer
int	buflen
int	round_rec_size
int	i
int	temp
int	total
#int	auxsize,auxcnt
#pointer	auxptr
pointer	ip

pointer temp_ptr,sp

begin
	call smark(sp)
	call salloc(tbuf,SZ_LINE,TY_CHAR)
	call salloc(pbuf,SZ_LINE,TY_CHAR)
	nrecs = 0
        qpgti = NULL

	call strcpy("N",Memc[tbuf],SZ_LINE)
	call strcat(gti_root,Memc[tbuf],SZ_LINE)
#	call sprintf(Memc[tbuf], SZ_LINE, "N%s")
#	call pargstr(gti_root)

       	if (qp_accessf(qp, Memc[tbuf]) == YES)
	{

	   #--------------------------
           # get number of gti records
	   #--------------------------
           nrecs = qp_geti(qp, Memc[tbuf])

           if (nrecs != 0)
	   {
              call strclr(Memc[tbuf])
              call sprintf(Memc[tbuf], SZ_LINE, "%sREC")
              call pargstr(gti_root)

#              call strclr(Memc[pbuf])
#              call strcpy("XS-",Memc[pbuf],SZ_LINE)
#	      call strcat(Memc[tbuf],Memc[pbuf],SZ_LINE)

	      #----------------------------------------------
              # calc rec size and alloc space for gti records
	      #----------------------------------------------
	      if (qp_accessf(qp, Memc[tbuf]) == YES)
       	      {
                  call qp_gstr(qp, Memc[tbuf], Memc[pbuf], SZ_EXPR)
              }
#              size_rec = get_gti_recsize(qp, gti_root)
              #--------------------------------------------------------
              # Must round-off to multiple of 8-bytes to preserve alignment
	      #--------------------------------------------------------
	      call ev_auxsize(Memc[pbuf],round_rec_size)
#	      call parse_descriptor(Memc[pbuf],auxptr,auxsize,auxcnt)
#	      auxsize = auxsize / SZB_CHAR
#	      call qpc_roundup(auxsize, round_rec_size)

	      buflen = round_rec_size*nrecs

#              call calloc(temp_ptr, buflen, TY_SHORT)
              call calloc(temp_ptr, buflen, TY_STRUCT)
              call calloc(qpgti, SZ_QPGTI*(nrecs), TY_STRUCT)

	      round_rec_size = round_rec_size / SZ_STRUCT
	      #-------------------
              # read in the record
	      #-------------------
	      total = 0
	      ip = temp_ptr
	      do i=1,nrecs
       	      {
		  temp = 1
                  got = qp_read (qp, gti_root, Memi[ip], temp, i, Memc[tbuf])
		  total = total + got
		  ip = ip + round_rec_size
	       }		
              #---------------------------------------------------------
	      # load the old gti structure with the whatever GTI type
	      # was read.  This was done to minimize changes to the
	      # other GTI routines.  Basically, what's going on here
	      # is that any info is stripped after the start/stop times,
	      # such as the OBI in the RATFITS files
	      #---------------------------------------------------------
	      call load_gti_struct(temp_ptr, qpgti, nrecs, round_rec_size)

              if (total != nrecs)
	      {
#                  call errori(1, "wrong number of gti records read", total)
            	   call eprintf("WARNING: wrong number of gti records read\n")
            	   call eprintf("WARNING: expected: %d got: %d\n")
                	call pargi(nrecs)
                	call pargi(total)
	      }
	   }
	}
	call mfree(temp_ptr,TY_STRUCT)
#	call free_descriptor(auxptr,auxcnt)
end


procedure load_gti_struct(temp_ptr, qpgti, nrecs, size_rec)

pointer	temp_ptr
pointer qpgti
int	nrecs
int	size_rec

pointer	ptr
int	idx
int	disp
int	start_offset
int	stop_offset

begin

        #-----------------------------------------------------------
	# This routine makes the somewhat kludgy assumption that
	# the order of any GTI record will be 
	#
	#   START_TIME	SZ_DOUBLE	
	#   STOP_TIME	SZ_DOUBLE
	#
	# and anything else can follow, such as:
	#
	#   OBI		SZ_SHORT
	# 
	# if this ever changes, this can be done more intelligently
	# but due to time constraints, it was done this way. 
	#
	# To do it more intelligently, the user would have to 
	# explicitly specify the names of the start and stop
	# time macros in the parameter file, the names would be 
	# parsed from the macro string, and the offset could then
	# be calculated and used here.
	#-----------------------------------------------------------

	for (idx = 1; idx <= nrecs; idx = idx + 1)
	{
	   start_offset = (idx - 1)*size_rec 
	   stop_offset  = (idx - 1)*size_rec + SZ_DOUBLE/SZ_STRUCT
	   ptr = GTI(qpgti, idx)

#	   call amovs(Mems[P2S(temp_ptr + start_offset)], GTI_START(ptr), SZ_DOUBLE)
#	   call amovs(Mems[P2S(temp_ptr + stop_offset)], GTI_STOP(ptr), SZ_DOUBLE)
	   call amovd(Memd[P2D(temp_ptr + start_offset)], GTI_START(ptr), 1)
	   call amovd(Memd[P2D(temp_ptr + stop_offset)], GTI_STOP(ptr), 1)
	   disp = 0
	   if( disp > 1)
	   {
	       call printf("start: %.4f stop: %.4f\n")
		call pargd(GTI_START(ptr))
		call pargd(GTI_STOP(ptr))
	   }
	}

#	call mfree(temp_ptr,TY_SHORT)
end


##int	procedure get_gti_recsize(qp, gti_root)
#
#pointer qp
#char 	gti_root[ARB]
#
#char	tbuf[SZ_LINE]
#char	outbuf[SZ_LINE]
#
#int	gtisize 
#int	idx
#int	qp_accessf()
#
#begin
#
##--------------------------------------------------
## This function returns the record size in shorts
##--------------------------------------------------
#        idx = 1
#        gtisize = 0
#
#	call sprintf(tbuf, SZ_LINE, "%sREC")
#        call pargstr(gti_root)
#
#	if (qp_accessf(qp, tbuf) == YES)
#	{
#	   call qp_gstr(qp, tbuf, outbuf, SZ_LINE)
#	}
#
#        while (outbuf[idx] != EOS)
#	{
#            switch (outbuf[idx])
#	    {
#            case '{', '}', ' ', ',':
#                ;
#            case 's':
#                gtisize = gtisize + (SZ_SHORT/SZ_SHORT)
#            case 'i':
#                gtisize = gtisize + (SZ_INT/SZ_SHORT)
#            case 'l':
#                gtisize = gtisize + (SZ_LONG/SZ_SHORT)
#            case 'r':
#                gtisize = gtisize + (SZ_REAL/SZ_SHORT)
#            case 'd':
#                gtisize = gtisize + (SZ_DOUBLE/SZ_SHORT)
#            case 'x':
#                gtisize = gtisize + (SZ_COMPLEX/SZ_SHORT)
#            default:
#                call error(1, "GTI RECORD PARSE: unknown data type")
#            }
#            idx = idx + 1
#        }
#
#	return (gtisize)
#end
#
#
#  PUT_QPGTI -- store gti records in the qpoe header
#
procedure put_qpgti(qp, qpgti, nrecs)
pointer qp				# i: qpoe handle
pointer	qpgti				# i: pointer to gti records
int	nrecs				# i: number of gti records
int	qp_accessf()

begin
	# add a qpoe param telling number of gti recs
	if( qp_accessf(qp, "NGTI") == NO )
	    call qpx_addf (qp, "NGTI", "i", 1, "number of gti records", 0)
	# store number of records
	call qp_puti (qp, "NGTI", nrecs)
	# Create an array "GTI" of type "GTIREC" and write to it.
	# create the gti data type
	if( qp_accessf(qp, "GTIREC") == NO )
	    call qpx_addf (qp, "GTIREC", "{d,d}", 0, "GTI record type", 0)
        if( qp_accessf(qp, "XS-GTIREC") == NO )
            call qpx_addf(qp, "XS-GTIREC", "c", SZ_LINE,
                     "PROS/QPOE event definition", 0)
        call qp_pstr(qp, "XS-GTIREC", XS_GTI)
#	if( qp_accessf(qp, "XS-GTIREC") == NO )
#	    call qp_addf (qp, "XS-GTIREC", "{d:start,d:stop}", 0, "GTI record type", 0)
	# create the gti parameter array of type gti
	# set the inherit flag explicitly so that the records can be inherited
	if( qp_accessf(qp, "GTI") == NO )
#	   call qp_addf (qp, "GTI", "GTIREC", nrecs, "GTI records", QPF_INHERIT)
	   call qpx_addf (qp, "GTI", "GTIREC", 0, "GTI records", QPF_INHERIT)
	# and write the gti records
	call qp_write (qp, "GTI", Memi[qpgti], nrecs, 1, "GTIREC")
end

#
#  DISP_QPGTI -- display gti records
#
procedure disp_qpgti(gptr, nrecs, inst)

pointer	gptr		# i: short pointer to gti records
int	nrecs		# i: number of gti records
int	inst		# i: instrument

int	i		# l: counter
pointer	cptr		# l: pointer to current gti record

begin
	# exit if nrecs is 0
	if (nrecs == 0 ){
	    call printf("\nNo gti records\n")
	    return
	}

	# output a header
	call printf("\n\t\t\tGood Time Intervals\n\n")
	call printf("start\t\tend\t\tduration\n")

	# process all gti records
	for (i=1; i<=nrecs; i=i+1)
	{
		# point to the current record
		cptr = GTI(gptr, i)
		call printf("%.2f\t%.2f\t%.2f\n")
		call pargd(GTI_START(cptr))
		call pargd(GTI_STOP(cptr))
		call pargd(GTI_STOP(cptr)-GTI_START(cptr))
	}
	call printf("\n")
end
