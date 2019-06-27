#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_hist.x,v 11.0 1997/11/06 16:34:38 prosb Exp $
#$Log: ft_hist.x,v $
#Revision 11.0  1997/11/06 16:34:38  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:11  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:20:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:26  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:13  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:16  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:37  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:26  jmoran
#Initial revision
#
#
# Module:	ft_hist.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#


#
# FT_HIST -- write history to qpoe file
#
procedure ft_hist(qp, fname, qpname)

pointer	qp				# i: qpoe handle
char	fname[ARB]			# i: input file name
char	qpname[ARB]			# i: output qpoe file name

int	len				# l: length of history
pointer	buf				# l: history line
pointer	sp				# l: stack pointer
int	strlen()			# l: string length

begin
	# mark the stack
	call smark(sp)
	# allocate a string long enough
	len = strlen(fname) + strlen(qpname) + SZ_LINE
	call salloc(buf, len, TY_CHAR)
	# make a history comment
	call sprintf(Memc[buf], len, "%s -> %s")
	call pargstr(fname)
	call pargstr(qpname)
	# write the history record
	call put_qphistory(qp, "fits2qp", Memc[buf], "")
	# free up stack space
	call sfree(sp)
end

