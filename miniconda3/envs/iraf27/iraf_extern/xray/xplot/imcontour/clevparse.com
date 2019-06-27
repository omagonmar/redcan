#$Header: /home/pros/xray/xplot/imcontour/RCS/clevparse.com,v 11.0 1997/11/06 16:38:01 prosb Exp $
#$Log: clevparse.com,v $
#Revision 11.0  1997/11/06 16:38:01  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:08:42  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:01:49  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:48:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:40:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:34:51  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:32:10  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:23:55  prosb
#General Release 1.1
#
#Revision 1.1  91/07/26  03:05:31  wendy
#Initial revision
#
#Revision 2.0  91/03/06  23:20:32  pros
#General Release 1.0
#
#
# CLEVPARSE.COM -- the contour level parser common
#
pointer	clev_ptr			 	# pointer to clev records

int 	clev_fd					# current file descriptor
int	clev_fds[MAX_NESTS]			# pushed file descriptors
int	clev_fdlev				# next available fd spot

char	clev_lbuf[SZ_LINE]			# line being parsed
int	clev_lptr				# current lptr into line
pointer	clev_sbuf				# temp string buffer
pointer clev_nextch				# next char in string buffer

int	clev_debug				# global debug flag

common	/clevcom/ clev_ptr,
	clev_fd, clev_fds, clev_fdlev,
	clev_lptr, clev_lbuf, clev_sbuf, clev_nextch, 
	clev_debug
