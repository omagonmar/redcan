#$Header: /home/pros/xray/ximages/qpsort/RCS/qpsort.x,v 11.0 1997/11/06 16:28:52 prosb Exp $
#$Log: qpsort.x,v $
#Revision 11.0  1997/11/06 16:28:52  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:35:00  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:46:08  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:27:22  prosb
#General Release 2.3
#
#Revision 6.1  93/12/22  17:10:39  mo
#MC	12/22/93	Update from SZ_FNAME to SZ_PATHNAME
#
#Revision 6.0  93/05/24  16:08:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:31:22  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:54  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:39  pros
#General Release 1.0
#
#
# QPSORT -- sort a qpoe file
#

include <math.h>
include <qpoe.h>
include <qpc.h>

#
#  T_QPSORT -- main task to copy a qpoe file
#
procedure t_qpsort()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate argv space
	call calloc(argv, SZ_DEFARGV, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers
	call srt_load()
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  SRT_LOAD -- load procs, params, and ext names
#		allocate argv space
#
procedure srt_load()

extern	def_open(), def_get(), def_close()
extern	def_getparam()
extern	srt_hist()

begin
	# use the default qpoe open, close, and get routines
	call qpc_evload("input_qpoe", ".qp", def_open, def_get, def_close)
	# load getparam routine
	call qpc_parload(def_getparam)
	# load history routine
	call qpc_histload(srt_hist)
	# do sorting
	call qpc_setsort(YES)
end

#
# SRT_HIST -- write history (and a title) to qpoe file
#
procedure srt_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_PATHNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
int	strlen()			# l: string length
bool	streq()				# l: string compare

begin
	# mark the stack
	call smark(sp)
	# allocate a string long enough
	len = strlen(Memc[file[1]])+
	      strlen(Memc[REGIONS(argv)])+
	      strlen(Memc[EXPOSURE(argv)])+
	      strlen(qpname)+
	      SZ_LINE
	call salloc(buf, len, TY_CHAR)

	# make a history comment
	if( streq("NONE", Memc[EXPOSURE(argv)]) ){
	    call sprintf(Memc[buf], len, "%s (%s; no exp.) -> %s")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(qpname)
	}
	else{
	    call sprintf(Memc[buf], len, "%s (%s; %s %.2f) -> %s")
	    call pargstr(Memc[file[1]])
	    call pargstr(Memc[REGIONS(argv)])
	    call pargstr(Memc[EXPOSURE(argv)])
	    call pargr(THRESH(argv))
	    call pargstr(qpname)
	}
	# display, if necessary
	if( display >0 ){
	    call printf("\n%s\n")
	    call pargstr(Memc[buf])
	}
	# write the history record
	call put_qphistory(qp, "qpsort", Memc[buf], "")
	# free up stack space
	call sfree(sp)
end

