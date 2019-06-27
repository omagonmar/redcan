#$Header: /home/pros/xray/lib/qpcreate/RCS/qpcdriver.x,v 11.0 1997/11/06 16:21:55 prosb Exp $
#$Log: qpcdriver.x,v $
#Revision 11.0  1997/11/06 16:21:55  prosb
#General Release 2.5
#
#Revision 9.1  1996/08/21 15:16:21  prosb
#*** empty log message ***
#
#JCC (8/20/96) - replace SZ_LINE with SZ_TYPEDEF for prosdef_in/out,
#                irafdef_in/out.
#Revision 9.0  1995/11/16  18:29:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:33:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:16:51  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:58:07  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:19:35  mo
#MC/JM	5/20/93		Add support for converting between
#				2 different QPOE formats
#
#Revision 5.0  92/10/29  21:18:36  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:59  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:05:15  prosb
#General Release 1.1
#
#Revision 2.0  91/03/07  00:10:47  pros
#General Release 1.0
#
#
#	QPC_DRIVER.X -- routines to manipulate driver space
#
include "qpcreate.h"
include <evmacro.h>     #JCC (8/20/96) - SZ_TYPEDEF
#
# QPC_ALLOC -- allocate the driver arrays
#
procedure qpc_alloc(n)

int	n				# i: number of aux files to allocate
int	i				# l: loop counter
include "qpcreate.com"

begin
	# clear the data base
	call aclri(qpcdb, QPC_LENDB)
	# set total number of files to process
	nfiles = n + F_MAX
	# allocate and clear diver space
	call calloc(file, nfiles*QPC_LENFILE, TY_STRUCT)
	# allocate space for each of the strings
	do i=1, nfiles{
	    call calloc(QPC_FPTR(file, i), SZ_LINE, TY_CHAR)
	    call calloc(QPC_PPTR(file, i), SZ_LINE, TY_CHAR)
	    call calloc(QPC_EPTR(file, i), SZ_LINE, TY_CHAR)
	}
	# allocate some strings in the data base
	call calloc(sortstr, SZ_LINE, TY_CHAR)

#JCC (8/20/96) - replace SZ_LINE with SZ_TYPEDEF for the following.
	call calloc(prosdef_in, SZ_TYPEDEF, TY_CHAR)
        call calloc(prosdef_out, SZ_TYPEDEF, TY_CHAR)
	call calloc(irafdef_in, SZ_TYPEDEF, TY_CHAR)
        call calloc(irafdef_out, SZ_TYPEDEF, TY_CHAR)

	# init sort to MAYBE, so that we prompt for sorting
	sort = MAYBE
end

#
#  QPC_FREE -- free up allocate proc, param, ext and argv space
#
procedure qpc_free()

int	i					# l: loop counter
include "qpcreate.com"

begin
	# free up the file strcture char arrays
	do i=1, nfiles{
	    call mfree(QPC_FPTR(file, i), TY_CHAR)
	    call mfree(QPC_PPTR(file, i), TY_CHAR)
	    call mfree(QPC_EPTR(file, i), TY_CHAR)
	}
	# free some strings in the data base
	call mfree(sortstr, TY_CHAR)
	call mfree(prosdef_in, TY_CHAR)
        call mfree(prosdef_out, TY_CHAR)
	call mfree(irafdef_in, TY_CHAR)
        call mfree(irafdef_out, TY_CHAR)
	# free up the file strcture itself
	call mfree(file, TY_STRUCT)
end

#
#  QPC_LOAD -- load strings and procedures into a qpc file record
#
procedure qpc_load(s_param, s_ext, r_open, r_get, r_put, r_close, n)

char	s_param[ARB]				# i: param name
char	s_ext[ARB]				# i: extension
pointer	r_open					# i: open routine
pointer r_get					# i: get routine
pointer r_put					# i: put routine
pointer r_close					# i: close routine
int	n					# i: file number
include "qpcreate.com"

begin
	# only enter routines and strings if non-null
	if( s_param[1] != EOS )
	    call strcpy(s_param, QPC_PARAM(file, n), SZ_LINE)
	if( s_ext[1] != EOS )
	    call strcpy(s_ext, QPC_EXT(file, n), SZ_LINE)
	if( r_open !=0 )
	    call zlocpr(r_open, QPC_OPEN(file, n))
	if( r_get !=0 )
	    call zlocpr(r_get, QPC_GET(file, n))
	if( r_put !=0 )
	    call zlocpr(r_put, QPC_PUT(file, n))
	if( r_close !=0 )
	    call zlocpr(r_close, QPC_CLOSE(file, n))
end

#
#  QPC_EVLOAD -- load strings and procedures into the event file record
#
procedure qpc_evload(s_param, s_ext, r_open, r_get, r_close)

char	s_param[ARB]				# i: param name
char	s_ext[ARB]				# i: extension
pointer	r_open					# i: open routine
pointer r_get					# i: get routine
pointer r_close					# i: close routine
int	n					# l: file number

extern	def_noput()

include "qpcreate.com"

begin
	n = F_IN
	goto 99

# QPC_HDLOAD -- load the header strings and drivers
entry qpc_hdload(s_param, s_ext, r_open, r_get, r_close)
	n = F_HD
	goto 99

99	call qpc_load(s_param, s_ext, r_open, r_get, def_noput, r_close, n)
end


#
# QPC_AUXLOAD -- load the aux file strings and drivers for 1 aux file
#
procedure qpc_auxload(s_param, s_ext, r_open, r_get, r_put, r_close, aux)

char	s_param[ARB]				# i: param name
char	s_ext[ARB]				# i: extension
pointer	r_open					# i: open routine
pointer r_get					# i: get routine
pointer	r_put					# i: put routine
pointer r_close					# i: close routine
int	aux					# i: aux file number
int	n					# i: file struct number

include "qpcreate.com"

begin
	# load strings and drivers into correct struct
	n = aux + F_MAX
	call qpc_load(s_param, s_ext, r_open, r_get, r_put, r_close, n)
end

#
#  QPC_PARLOAD -- load param routine
#
procedure qpc_parload(r_getparam)
pointer	r_getparam				# i: get param routine
include "qpcreate.com"
begin
	call zlocpr(r_getparam, getparam)
end

#
#  QPC_HISTLOAD -- load hist routine
#
procedure qpc_histload(r_hist)
pointer	r_hist				# i: write history routine
include "qpcreate.com"
begin
	call zlocpr(r_hist, hist)
end

#
#  QPC_FINALELOAD -- load finale routine
#
procedure qpc_finaleload(r_finale)
pointer	r_finale				# i: grand finale routine
include "qpcreate.com"
begin
	call zlocpr(r_finale, grand_finale)
end

#
#  QPC_SETSORT -- flag if we don't sort, or do without prompting for sort
#  (the first case is qpcopy, the second is qpsort)
#
procedure qpc_setsort(flag)

int	flag
include "qpcreate.com"

begin
	sort = flag
end

#
#  QPC_CHECK -- make sure everything is loaded consistently
#
procedure qpc_loadcheck()

int	i
include "qpcreate.com"

begin
	call qpc_check(QPC_OPEN(file,F_IN), QPC_CLOSE(file,F_IN),
		       QPC_GET(file,F_IN), 0, 3, 3, F_IN)
	call qpc_check(QPC_OPEN(file,F_HD), QPC_CLOSE(file,F_HD),
		       QPC_GET(file,F_HD), 0, 0, 3, F_HD)
	do i=(F_MAX+1), nfiles{
	    call qpc_check(QPC_OPEN(file,i), QPC_CLOSE(file,i),
			   QPC_GET(file,i), QPC_PUT(file,i), 4, 4, i)
	}
end

#
#  QPC_CHECK -- checksum a set of numbers
#
procedure qpc_check(n1, n2, n3, n4, a, b, i)

int	n1, n2, n3, n4			# ints to check
int	a, b				# permissible values
int	i				# driver number
int	total				# total no-zero pointers
begin
	# determine the number of non-zero values
	total = 0
	if( n1 != 0 ) total = total + 1
	if( n2 != 0 ) total = total + 1
	if( n3 != 0 ) total = total + 1
	if( n4 != 0 ) total = total + 1
	if( (total != a) && (total != b) )
	    call errori(1, "I/O drivers not set up correctly", i)	
end

