#$Header: /home/pros/xray/xspectral/source/RCS/obsparse.com,v 11.0 1997/11/06 16:42:59 prosb Exp $
#$Log: obsparse.com,v $
#Revision 11.0  1997/11/06 16:42:59  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:33  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:44  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:54  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:32  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:53  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:47  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:05:59  pros
#General Release 1.0
#
#
# OBSPARSE.COM -- the observation data set parser common
#
pointer	obs_fp					# pointer to frame pointer

int 	obs_fd					# current file descriptor
int	obs_fds[MAX_NESTS]			# pushed file descriptors
int	obs_fdlev				# next available fd spot

char	obs_lbuf[SZ_LINE]			# line being parsed
int	obs_lptr				# current lptr into line
pointer	obs_sbuf				# temp string buffer
pointer obs_nextch				# next char in string buffer

int	obs_debug				# global debug flag

common	/obscom/ obs_fp,
	obs_fd, obs_fds, obs_fdlev,
	obs_lptr, obs_lbuf, obs_sbuf, obs_nextch,
	obs_debug
