#$Header: /home/pros/xray/ximages/qpcopy/RCS/qpcopy.x,v 11.0 1997/11/06 16:28:38 prosb Exp $
#$Log: qpcopy.x,v $
#Revision 11.0  1997/11/06 16:28:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:44  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:45:41  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:26:53  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:07:38  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:27:10  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:30:24  prosb
#General Release 2.0:  April 1992
#
#Revision 3.2  92/04/23  22:28:21  prosb
#Commented out variable definition "qpaccessf" line 95 -- not used.
#
#Revision 3.1  92/04/13  14:55:10  mo
#MC	4/13/92		Remove code that tried to write a TITLE
#			string ( forgetting the MEMC ) from a
#			variable that contains the region summary
#			Not needed since the TITLE string was copied
#			automatically from the input QPOE File
#			This corrects bug that always destroyed the
#			title during QPCOPY
#
#Revision 3.0  91/08/02  01:17:34  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:27:17  pros
#General Release 1.0
#
#
# Module:       QPCCOPY.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Copy 1 QPOE file to another (with possible regions and filters)
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} egm   -- initial version      1988
#               {1} mc    -- to replace qp_astr with qp_pstr
#               {n} <who> -- <does what> -- <when>
#
#
# QPCOPY -- copy a qpoe file to another (with possible regions and filters)
#

include <qpoe.h>
include <qpc.h>

#
#  T_QPCOPY -- main task to copy a qpoe file
#
procedure t_qpcopy()

pointer	argv				# user argument list

begin
	# init the driver arrays
	call qpc_alloc(0)
	# allocate default argv space - defined in qpc.h
	call calloc(argv, SZ_DEFARGV, TY_INT)
	# allocate def arrays
	call def_alloc(argv)
	# load the drivers
	call cop_load()
	# call the convert task
	call qp_create(argv)
	# free the driver arrays and argv
	call qpc_free()
	# free the argv space
	call def_free(argv)
	call mfree(argv, TY_INT)
end

#
#  COP_LOAD -- load driver routines
#
procedure cop_load()

extern	cop_hist()
extern	def_open(), def_get(), def_close(), def_getparam()

begin
	# use the default qpoe open, close, and get routines
	call qpc_evload("input_qpoe", ".qp", def_open, def_get, def_close)
	# load getparam routine
	call qpc_parload(def_getparam)
	# load history routine
	call qpc_histload(cop_hist)
	# no sorting - don't even prompt the user
	call qpc_setsort(NO)
end

#
# COP_HIST -- write history (and a title) to qpoe file
#
procedure cop_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

int	len				# l: length of string
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
#int	qp_accessf()			# l: existence of qp param
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
	call put_qphistory(qp, "qpcopy", Memc[buf], "")
	# write the title to the file
##  THis doesn't belong here - the program doesn't get a TITLE string
##    and what's more, it was missing an MEMC
#	if( qp_accessf(qp, "title") == NO )
#	    call qp_addf (qp, "title", "c", len, "qpoe title", 0)
#	call qp_pstr (qp, "title", Memc[TITLE(argv)])
	# free up stack space
	call sfree(sp)
end
