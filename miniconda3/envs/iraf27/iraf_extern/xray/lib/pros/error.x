#$Header: /home/pros/xray/lib/pros/RCS/error.x,v 11.0 1997/11/06 16:20:22 prosb Exp $
#$Log: error.x,v $
#Revision 11.0  1997/11/06 16:20:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:27:27  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:45:46  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:09:09  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:44:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:16:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:47:26  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  00:48:57  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:06:48  pros
#General Release 1.0
#
#
#  ERROR.X -- error routines
#

define SZ_ERMES 132

procedure errstr(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
char	val[ARB]	# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %s")
	call pargstr(ermes)
	call pargstr(val)
	call error(ercode, tbuf)
end

procedure errors(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
short	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %d")
	call pargstr(ermes)
	call pargs(val)
	call error(ercode, tbuf)
end

procedure errori(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
int	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %d")
	call pargstr(ermes)
	call pargi(val)
	call error(ercode, tbuf)
end

procedure errorl(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
long	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %d")
	call pargstr(ermes)
	call pargl(val)
	call error(ercode, tbuf)
end

procedure errorr(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
real	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %g")
	call pargstr(ermes)
	call pargr(val)
	call error(ercode, tbuf)
end

procedure errord(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
double	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %g")
	call pargstr(ermes)
	call pargd(val)
	call error(ercode, tbuf)
end

procedure errorx(ercode, ermes, val)

int	ercode		# i: error code passed to error()
char	ermes[ARB]	# i: error string
complex	val		# i: error value
char	tbuf[SZ_ERMES]	# l: error string to pass to error()

begin
	call sprintf(tbuf, SZ_ERMES, "%s - %z")
	call pargstr(ermes)
	call pargx(val)
	call error(ercode, tbuf)
end

