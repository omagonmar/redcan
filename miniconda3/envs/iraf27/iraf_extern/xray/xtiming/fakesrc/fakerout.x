#$Header: /home/pros/xray/xtiming/fakesrc/RCS/fakerout.x,v 11.0 1997/11/06 16:44:20 prosb Exp $
#$Log: fakerout.x,v $
#Revision 11.0  1997/11/06 16:44:20  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:33:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:39:15  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:00:30  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:56:23  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:48:18  prosb
#General Release 2.1
#
#Revision 2.0  91/03/06  22:40:41  pros
#General Release 1.0
#
include <time.h>
include <math.h>
include <qpoe.h>
include <einstein.h>

# definitions hopefully to be used for binary file
define LEN_REC 8			# Length of one record in TY_SHORT
define REC_STAT Mems[$1]			# status word
define REC_XPOS Mems[$1+1]			# X position (short version)
define REC_YPOS Mems[$1+2]			# Y position (short version)
define REC_PHT  Mems[$1+3]			# Pulse height (only 1 byte)
define REC_TIME Memd[($1+4-1)/SZ_DOUBLE+1]	# arrival time


#
# Function:	fake_head
# Purpose:	To make a fake data header for fake data files that actually 
#		contains some real, usefull information.
	#
procedure fake_head(uhead,seqno,length)
short	uhead[SZ_UHEAD]			# header for fake data file
int	seqno				# sequence number of this 'flight'
real	length				# length of time to "get" events

long	i				# generic variable
short	ssec,sday,syear			# start time
short	esec,eday			# end time
long	clktime()			# time in 80's, if called with a zero
begin
	syear	= 0
	i	= clktime(0) + 63072000		# Time since Jan 0, 1978, not 80
	ssec	= short(i - long(i/86400) * 86400)
	sday	= (i-ssec)/86400
	while (sday > 365) {
	  sday	= sday - 365
	  syear	= syear + 1
	}
	if ((sday == 365) && (syear - int(syear/4)*4 != 3)) {
	  sday	= sday - 365
	  syear	= syear + 1
	}
	sday	= sday - int((syear+1)/4)	# all leap year calculations 
					# based on 1978 being year 0

	eday	= sday
	esec	= ssec + short(length)	# get stop time
	while (esec > 86400) {		# adjust to correct days
	  esec	= esec - 86400
	  eday	= eday + 1
	}

	for (i=1;i<=SZ_UHEAD;i=i+1) 
	  uhead[i]	= 0

	U_DATAFORMAT(uhead)	= EINSTEIN_HRI
	U_SEQNO(uhead)		= short(seqno)
	U_OBSERVER(uhead)	= 0
	U_ONTIME(uhead)		= short(length)
	U_LIVETIME(uhead)	= short(length * 1.43)
	U_STARTDAY(uhead)	= sday
	U_STARTTIME(uhead)	= ssec * 1000	# in microseconds
	U_STARTYEAR(uhead)	= syear + 78
	U_STOPDAY(uhead)	= eday
	U_STOPTIME(uhead)	= esec * 1000	# in microseconds
	U_STOPYEAR(uhead)	= syear + 78

end



#
# Function:	wrap
# Purpose:	To act as a modulus operator for wrapping around the edges of 
#		the pulse profile.
#
int procedure wrap(bin,numbins)
int numbins
int bin

int retbin
begin
	retbin	= bin
	while (retbin > numbins)
	  retbin	= retbin - numbins
	while (retbin < 1)
	  retbin	= retbin + numbins
	return (retbin)
end





#
# Function:	interval
# Purpose:	Routine to actually calculate when the next random piece of data
#		arrives.  This routine expects an array in fncbins of which the
#		first numbins entries are the rates each for the amount of time
#		given in the second numbins entries.
#

# These two are only here to make the code shorter.
define RATE fncbins[wrap(lastbin+i,numbins)]
define LENR fncbins[wrap(lastbin+i,numbins)+numbins]

double procedure interval(fncbins,numbins,lastbin,inlast,rn,display)
double	fncbins[ARB]			# Array containing source function
int	numbins				# Number of bins in function
int	lastbin				# Last bin read
double	inlast				# How much through last bin (absolute,
					# not relative, time units.)
real	rn				# Random number
int	display				# display level

double	target				# Target integral of pulse portion
double	time				# Time until next event
int	i

int	wrap()
double	dlog()				# natural logarithm funciton?
begin
	target	= - dlog(double(rn))
	time	= 0
	i	= 0

	########## Actually calculate bin in which target falls
	while (target >= (RATE * (LENR-inlast))) {	# Check exceeds this bin
	  time	= time + LENR - inlast			# Add to integration
	  target	= target - RATE*(LENR-inlast)	# Reduce integr. target
	  inlast	= 0				# Got all the way through
	  i	= i + 1					# Next bin
	}
	if (inlast != 0.0) {		# In last bin. Check to see if in first.
	  time	= target/RATE		# Yes. Time is short.
	  inlast	= inlast + time	# Did not get out yet.
	} else {
	  inlast	= target/RATE	# Record how far into this bin
	  time	= time + inlast		# And add that to total time
	}
	lastbin = wrap(lastbin + i,numbins)		# Store new bin
	return (time)
end



#
# Function:	write_event
# Purpose:	This is the procedure that actually writes the data to the file.
#
procedure write_event(time,x,y,pht,xprfl,display)
double time
short x,y,pht
int xprfl
int display

short status_word
pointer sp
pointer buffr				# buffer for file writes
pointer timeb
begin
	call smark(sp)
	call salloc(buffr,LEN_REC,TY_SHORT)
	call salloc(timeb,1,TY_DOUBLE)
	status_word	= 0
	REC_STAT(buffr)	= status_word
	REC_XPOS(buffr)	= x
	REC_YPOS(buffr)	= y
	REC_PHT(buffr)	= pht
	Memd[timeb]	= time
	call amovd(Memd[timeb],REC_TIME(buffr),1)

	call write(xprfl,Mems(buffr),LEN_REC)

	if (display > 3) {
	  call printf("Stat: %-4x    x: %-4x     y: %-4x    pht: %-4x    time: %-12.4f\n")
	   call pargs(status_word)
	   call pargs(x)
	   call pargs(y)
	   call pargs(pht)
	   call pargd(time)
	}
	call sfree(sp)
end
