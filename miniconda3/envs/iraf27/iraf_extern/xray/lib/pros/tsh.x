#$Header: /home/pros/xray/lib/pros/RCS/tsh.x,v 11.0 1997/11/06 16:21:14 prosb Exp $
#$Log: tsh.x,v $
#Revision 11.0  1997/11/06 16:21:14  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:34  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:00  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:54:30  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:17:43  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:50:23  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:02:21  wendy
#General
#
#Revision 2.0  91/03/07  00:07:41  pros
#General Release 1.0
#
#
#	TSH.X -- ROSAT HRI temporal status routines
#

include <math.h>
include <qpset.h>
include <qpoe.h>
include <rosat.h>

#
#  GET_QPTSH -- get the tsh records from the qpoe file
#
procedure get_qptsh(qp, qptsh, nrecs)

pointer qp				# i: qpoe handle
pointer	qptsh				# o: pointer to tsh records
int	nrecs				# o: number of tsh records
int	got				# l: number of records read
int	qp_geti()			# l: qpoe get routine
int	qp_read()			# l: qpoe read params
int	qp_accessf()			# l: qpoe param existence

begin
	# return 0 if no records
	if( qp_accessf(qp, "NTSH") == NO ){
	    nrecs = 0
	    return
	}
	# get number of tsh records
	nrecs = qp_geti(qp, "NTSH")
	# allocate space for tsh records
	call calloc(qptsh, SZ_QPTSH*nrecs, TY_STRUCT)
	# read in the record
	got = qp_read (qp, "TSH", Memi[qptsh], nrecs, 1, "TSHREC")
	if( got != nrecs )
	    call errori(1, "wrong number of tsh records read", got)
end

#
#  PUT_QPTSH -- store tsh records in the qpoe header
#
procedure put_qptsh(qp, qptsh, nrecs)
pointer qp				# i: qpoe handle
pointer	qptsh				# i: pointer to tsh records
int	nrecs				# i: number of tsh records

begin
	# add a qpoe param telling number of tsh recs
	call qp_addf (qp, "NTSH", "i", 1, "number of tsh records", 0)
	# store number of records
	call qp_puti (qp, "NTSH", nrecs)
	# Create an array "TSH" of type "TSHREC" and write to it.
	# create the tsh data type
	call qp_addf (qp, "TSHREC", "{d,s,s}", 0, "TSH record type", 0)
	# create the tsh parameter array of type tsh
	# set the inherit flag explicitly so that the records can be inherited
	call qp_addf (qp, "TSH", "TSHREC", nrecs, "TSH records", QPF_INHERIT)
	# and write the tsh records
	call qp_write (qp, "TSH", Memi[qptsh], nrecs, 1, "TSHREC")
end

# Define general stuff for status record
define	SZ_TSH_STAT	20
define	TS_EOF		0
define	TS_INTOBI	1
define	TS_HIBK		2
define	TS_HVLEV	3
define	TS_VG		4
define	TS_ASPSTAT	5
define	TS_ASPERR	6
define	TS_HQUAL	7
define	TS_HV		8
define	TS_DROP		9
define	TS_BADTEL	10
define	TS_BADTIME	11
define	TS_SAAIND	12
define	TS_SAADA	13
define	TS_SAADB	14
define	TS_TEMP1	15
define	TS_TEMP2	16
define	TS_TEMP3	17
define	TS_UV		18
define	TS_HREVD	19

# define record type for status limits -- short array, with three entries per
#	status ID
define	SZ_STATLIM	SZ_TSH_STAT * 3
define	SL_TYPE		Memi[$1 + $2 * 3]		# 0-19, not 1-20
define	SL_MIN		Memi[$1 + $2 * 3 + 1]
define	SL_MAX		Memi[$1 + $2 * 3 + 2]

# possible types
define	OFF			0
define	ON			1
define	KNOWN			2
define	UNKNOWN			3
define	BOTH			4

#
#  DISP_QPTSH -- Display tsh records
#
procedure disp_qptsh(pp,nrecs,inst)

pointer	pp			# i: short pointer to tsh records
int	nrecs			# i: number of tsh records
int	inst			# i: instrument

int	i
int	place			# place in tsh record list
int	gnum			# group number
pointer	sp			# stack pointer
pointer	group			# pointer to group records
double	startime		# start time of current group
double	stoptime		# stop time of current group
double	duration		# duration of cur. group (stoptime - startime)
double	reftime			# ref. time (so that others are all sane #'s)

int	get_tgroup()		# get the next tsh group

begin
	# exit if nrecs is 0
	if (nrecs == 0) {
	  call printf("\nNo TSH records\n")
	  return
	}

	call smark(sp)
	# Allocate space for group stats
	call salloc(group,SZ_TSH_STAT,TY_SHORT)

	# initialization
	place	= 1
	gnum	= 0
	# initialize each status unknown
	for (i=0;i<SZ_TSH_STAT;i=i+1)
	    Mems[group+i]	= -1

	# Output a header
	call printf("\n						X-ray TSH\n\n")
	call printf("                         E O   D B B   H \n")
	call printf("                         O B H R T T U V               ASP")
	call printf("  ASP       SAAD SAAD SAAD TEMP TEMP TEMP\n")
	call printf("Int# start     duration  F I V P L M V R HIBK HVLEV VG STA")
	call printf("T ERR HQUAL IND  A    B    1    2    3\n")

	while (get_tgroup(pp,place,nrecs,Mems[group],startime,stoptime) == YES) {
	  gnum	= gnum + 1
	  if (gnum == 1) {			# If this si the first time,
	    reftime	= startime		# store the reference time.
	    call printf("     All times below are relative to the observation ")
	    call printf("start time of %25.1f\n")
	     call pargd(reftime)
	  }
	  startime	= startime - reftime
	  duration	= stoptime - reftime - startime	  

	  # start printing
	  call printf("%-4d %-9.2f %-9.2f")
	   call pargi(gnum)
	   call pargd(startime)
	   call pargd(duration)

	  # print boolean stati
	  if (Mems[group+0] == 1)		# EOF
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+1] == 1)		# INTER-OBI
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+8] == 1)		# HV
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+9] == 1)		# DROPOUT
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+10] == 1)		# BADTEL
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+11] == 1)		# BADTIME
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+18] == 1)		# UV
	    call printf(" X")
	  else
	    call printf("  ")
	  if (Mems[group+19] == 1)		# HVRED
	    call printf(" X")
	  else
	    call printf("  ")
	  call printf(" ")

	  # print non-boolean stati
	  call printf("%-4d ")			# HIBK
	   call pargs(Mems[group+2])
	  call printf("%-5d ")			# HVLEV
	   call pargs(Mems[group+3])
	  call printf("%-2d ")			# VG
	   call pargs(Mems[group+4])
	  call printf("%-4d ")			# ASPSTAT
	   call pargs(Mems[group+5])
	  call printf("%-3d ")			# ASPERR
	   call pargs(Mems[group+6])
	  call printf("%-5d ")			# HQUAL
	   call pargs(Mems[group+7])
	  call printf("%-4d ")			# SAADIND
	   call pargs(Mems[group+12])
	  call printf("%-4d ")			# SAADA
	   call pargs(Mems[group+13])
	  call printf("%-4d ")			# SAADB
	   call pargs(Mems[group+14])
	  call printf("%-4d ")			# TEMP1
	   call pargs(Mems[group+15])
	  call printf("%-4d ")			# TEMP2
	   call pargs(Mems[group+16])
	  call printf("%-4d ")			# TEMP2
	   call pargs(Mems[group+17])
	  call printf("\n")
	}
end


#
#  GET_tgroup -- get one tsh record group,
#  where a group is defined as a bunch of records with the same start time.
#
int procedure get_tgroup(tshlist,place,nrec,stat,start,stop)

pointer	tshlist			# i: pointer to a list of shorts which contain
				# the list of tsh records
int	place			# i/o: place within tsh record list
int	nrec			# i: length of list
short	stat[SZ_TSH_STAT]	# o: status of instrument before current group
double	start			# o: start time of current group
double	stop			# o: stop time of current group

int	i
int	rdnxt			# read next group?
int	rec			# got a record?
pointer	sp			# stack pointer
pointer	name			# name of status record currently being changed
pointer	record			# current record

begin
	call smark(sp)
	call salloc(name,SZ_LINE,TY_CHAR)

	# assume haven't got one
	rdnxt	= NO

	# see if beyond list
	if (place > nrec) {
	  for (i=1;i<=SZ_TSH_STAT;i=i+1) 
	    if (i != TS_EOF+1)
	      stat[i]	= -1
	} else {
	  # get the next record
	  record	= TSH(tshlist,place)

	  rdnxt	= YES
	  if ((TSH_ID(record) < SZ_TSH_STAT) && (TSH_ID(record) >= 0))
	    stat[TSH_ID(record)+1]	= TSH_STATUS(record)
	  else
	    call printf("Warning - unknown status ID\n")

	  start	= TSH_TIME(record)
	  place	= place + 1
	  rec	= YES

	  while ((place <= nrec) && (rec == YES)) {
	    rec	= NO
	    record	= TSH(tshlist,place)
	    if (TSH_TIME(record) == start) {
	      if ((TSH_ID(record) < SZ_TSH_STAT) && (TSH_ID(record) >= 0))
	        stat[TSH_ID(record)+1]	= TSH_STATUS(record)
	      else
	        call printf("Warning - unknown status ID\n")
	      rec	= YES
	      place	= place + 1
	    } else 
	      stop	= TSH_TIME(record)
	  }
	}
	return(rdnxt)
end
