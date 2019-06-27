#$Header: /home/pros/xray/xspectral/source/RCS/nag.com,v 11.0 1997/11/06 16:42:57 prosb Exp $
#$Log: nag.com,v $
#Revision 11.0  1997/11/06 16:42:57  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:30  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:33:37  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:56:48  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:51:37  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:27  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:16:46  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:45  prosb
#General Release 1.1
#
#Revision 2.1  91/06/07  11:09:06  pros
#jso - added variable to track whether verbose has started or not 
#so that it knows whether or not to print titles.
#
#Revision 2.0  91/03/06  23:05:49  pros
#General Release 1.0
#
#
#  nag.com - common block for nag minimization
#
int     fptr                            # frame pointer
bool	verbose				# print switch
int	iteration			# iteration counter
int	nparameters			# number of parameters
int	nmodel[MAX_FREE_PARAMS]		# model number for each free param.
int	nparam[MAX_FREE_PARAMS]		# parameter pos. for each free param.
real	normalization			# some sort of normalization?!
real	pinit[MAX_FREE_PARAMS]		# initial value for free params
real	pdelt[MAX_FREE_PARAMS]		# delta to add to free params
int	nlink[MAX_LINKS*3]		# links to parameters
int	nlinks				# number of links
bool	first				# first time through with verbose

common	/nagcom/  fptr, verbose, iteration, nparameters, nmodel, nparam,
		  normalization, pinit, pdelt, nlink, nlinks, first
