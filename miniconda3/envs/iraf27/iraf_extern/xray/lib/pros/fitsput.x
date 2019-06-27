#$Header: /home/pros/xray/lib/pros/RCS/fitsput.x,v 11.0 1997/11/06 16:20:27 prosb Exp $
#$Log: fitsput.x,v $
#Revision 11.0  1997/11/06 16:20:27  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:46:01  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:28  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:39  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:41  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:48:38  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:49:01  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:56  pros
#General Release 1.0
#
include <wfits.h>

#
#  FTS_PUTB -- put a boolean param to fits header
#
procedure fts_putb(fd, pname, pval, comment)

int	fd				# i: fits handle
char	pname[ARB]			# i: param name
int	pval				# i: param value
char	comment[ARB]			# i: comment
char	card[LEN_CARD+1]		# l: fits param card

begin
	call wft_encodeb (pname, pval, card, comment)
	call wft_write_pixels (fd, card, LEN_CARD)
end

#
#  FTS_PUTI -- put an int param to fits header
#
procedure fts_puti(fd, pname, pval, comment)

int	fd				# i: fits handle
char	pname[ARB]			# i: param name
int	pval				# i: param value
char	comment[ARB]			# i: comment
char	card[LEN_CARD+1]		# l: fits param card

begin
	call wft_encodei(pname, pval, card, comment)
	call wft_write_pixels (fd, card, LEN_CARD)
end

#
#  FTS_PUTR -- put a real param to fits header
#
procedure fts_putr(fd, pname, pval, comment)

int	fd				# i: fits handle
char	pname[ARB]			# i: param name
real	pval				# i: param value
char	comment[ARB]			# i: comment
char	card[LEN_CARD+1]		# l: fits param card

begin
	call wft_encoder(pname, pval, card, comment, 7)
	call wft_write_pixels (fd, card, LEN_CARD)
end

#
#  FTS_PUTD -- put a double param to fits header
#
procedure fts_putd(fd, pname, pval, comment)

int	fd				# i: fits handle
char	pname[ARB]			# i: param name
double	pval				# i: param value
char	comment[ARB]			# i: comment
char	card[LEN_CARD+1]		# l: fits param card

begin
	call wft_encoded(pname, pval, card, comment, 16)
	call wft_write_pixels (fd, card, LEN_CARD)
end

#
#  FTS_PUTC -- put a string param to fits header
#
procedure fts_putc(fd, pname, pval, comment)

int	fd				# i: fits handle
char	pname[ARB]			# i: param name
char	pval[ARB]			# i: param value
char	comment[ARB]			# i: comment
char	card[LEN_CARD+1]		# l: fits param card
int	len				# l: max len
int	strlen()			# l: length of pval

begin
	len = max(min(LEN_OBJECT, strlen(pval)), LEN_STRING)
	call wft_encodec(pname, pval, len, card, comment)
	call wft_write_pixels (fd, card, LEN_CARD)
end

