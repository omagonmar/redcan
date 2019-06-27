#$Header: /home/pros/xray/lib/pros/RCS/headstr.x,v 11.0 1997/11/06 16:20:32 prosb Exp $
#$Log: headstr.x,v $
#Revision 11.0  1997/11/06 16:20:32  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:46  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:46  prosb
#General Release 2.3
#
#Revision 1.2  93/11/30  18:47:03  prosb
#MC	11/30/93		Fix NONE default for FILTER
#
#Revision 1.1  93/10/21  11:40:44  mo
#Initial revision
#
#
#  HEADSTR.X -- routines to support QPOE header STRING -> CODE, CODE-> STRING
#		format conversions
#

include <missions.h>
include <qpoe.h>
define	NO_MODE 0
#
#  MODE_ITOC -- convert mode ID to a string
#
procedure mode_itoc(mode, modestr, len)

int	mode				# i: mission id
char	modestr[ARB]			# o: mission name
int	len				# i: length of output string

begin
	# look for a match
	switch(mode){
	case POINTED:
	    call strcpy("POINTING", modestr, len)
	case SCAN:
	    call strcpy("SCANNING", modestr, len)
	case SLEW:
	    call strcpy("SLEW", modestr, len)
	case TRAUMA:
	    call strcpy("TRAUMA", modestr, len)
	case NO_MODE:
	    call strcpy("NO_MODE", modestr, len)
	default:
	    call strcpy("UNKNOWN", modestr, len)
	}
end

#
#  FILT_ITOC -- convert inst ID to a string
#
procedure filt_itoc(filt, filtstr, len)

int	filt				# i: instrument ID
char	filtstr[ARB]			# o: mission name
int	len				# i: length of output string

begin
	# look for a match
	switch(filt){
	case 0:
	    call strcpy("NONE", filtstr, len)
	case 1:
	    call strcpy("BORON", filtstr, len)
	default:
	    call strcpy("UNKNOWN", filtstr, len)
	}
end

#
#  MODE_CTOI -- convert mission string to ID
#
procedure mode_ctoi(modestr, mode)

char	modestr[ARB]			# i: mission name
int	mode				# o: mission id
char	tbuf[SZ_LINE]			# l: temp char buffer
int	strdic()
string	m_names	"|POINTED|SLEW|SCAN|TRAUMA|NOMODE|"

begin
	# convert to upper case
	call strcpy(modestr, tbuf, SZ_LINE)
	call strupr(tbuf)
	# look for a match
	switch ( strdic( tbuf, tbuf, SZ_LINE, m_names ) ) {
	case 1:
	    mode = POINTED
	case 2:
	    mode = SLEW 
	case 3:
	    mode = SCAN
	case 4:
	    mode = TRAUMA
#	case 5:
#	    mode = NO_MODE
	default:
	    mode = NO_MODE
	}
end

#
#  FILT_CTOI -- convert filter string to an id
#
procedure filt_ctoi(filtstr, filter)

char	filtstr[ARB]			# i: instrument string
int	filter				# o: instrument id
char	tbuf[SZ_LINE]			# l: temp char buffer
#int	n
int	strdic(),strlen
string	i_names	"|NONE|BORON|"

begin
	# convert to upper case
	if( strlen(filtstr) == 0 )
	    call strcpy("NONE",filtstr,5)
	call strcpy(filtstr, tbuf, SZ_LINE)
	call strupr(tbuf)
	# look for a match
	switch ( strdic( tbuf, tbuf, SZ_LINE, i_names ) ) {
	case 1:
	    filter = 0
	case 2:
	    filter = 1
	default:
	    filter = 99
	}
end
