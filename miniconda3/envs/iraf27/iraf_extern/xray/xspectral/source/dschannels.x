#$Header: /home/pros/xray/xspectral/source/RCS/dschannels.x,v 11.0 1997/11/06 16:41:59 prosb Exp $
#$Log: dschannels.x,v $
#Revision 11.0  1997/11/06 16:41:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:16  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:38  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:54:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:24  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:48  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:13:51  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/03/25  11:24:20  orszak
#jso - no change for first installation of new qpspec
#
#Revision 3.1  91/09/22  19:05:30  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:00  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:02:17  pros
#General Release 1.0
#
#
#  DS_CHANNELS.X -- change n array of channels back into a
#  bracket string, e.g., "[3-11]", etc.
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
define	NOINTERVAL	1
define	STARTINTERVAL	2
define	INTERVAL	3

define SZ_TBUF 20

procedure ds_channels(chanbuf, nphas, strbuf, len)

int	chanbuf[ARB]			# i: channel buffer
int	nphas				# i: number of channels
char	strbuf[ARB]			# o: string channel buffer
int	len				# i: length of string buffer

char	tbuf[SZ_TBUF]			# l: temp buffer
int	i				# l: current channel
int	temp				# l: temp integer
int	state				# l: current state of processing

int	strlen()			# l: string length

begin
	# init
	call strcpy("[", strbuf, len)
	state = NOINTERVAL
	# process all channels
	do i = 1, nphas{
	    switch(state){
	    case NOINTERVAL:
		if( chanbuf[i] !=0 ){
		    call sprintf(tbuf, SZ_TBUF, "%d")
		    call pargi(i)		
		    call strcat(tbuf, strbuf, len)
		    state = STARTINTERVAL
		}
	    case STARTINTERVAL:
		if( chanbuf[i] ==0 ){
		    call strcat(",", strbuf, len)
		    state = NOINTERVAL
		}
		else
		    state = INTERVAL
	    case INTERVAL:
		if( chanbuf[i] ==0 ){
		    call sprintf(tbuf, SZ_TBUF, ":%d,")
		    call pargi(i-1)
		    call strcat(tbuf, strbuf, len)
		    state = NOINTERVAL
		}
	    }
	}
	# process the final state
	switch(state){
	case NOINTERVAL:
	    # check length of string
	    temp = strlen(strbuf)
	    if( len ==1 )
		# no intervals - null out string
		strbuf[1] = EOS
	    else
		# change last "," to "]"
		strbuf[temp] = ']'
	case STARTINTERVAL:
	    # startinterval means one number, just close it up
	    call strcat("]", strbuf, len)
	case INTERVAL:
	    # in an interval - finish it with last channel
	    call sprintf(tbuf, SZ_TBUF, ":%d]")
	    call pargi(nphas)
	    call strcat(tbuf, strbuf, len)
	}
end
