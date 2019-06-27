#$Header: /home/pros/xray/xspectral/source/RCS/plot_utils.x,v 11.0 1997/11/06 16:43:07 prosb Exp $
#$Log: plot_utils.x,v $
#Revision 11.0  1997/11/06 16:43:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:51  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:16  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:59  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:32  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:57  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:57  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:06:45  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#   plot_utils.x   ---   plotting utilities

include  <time.h>
include  <gset.h>

define	PLTIMEX		0.65
define  PLTIMEY		0.01
define  PLFILEX		0.01
define  PLFILEY		0.01

#   -------------------------------------------------------------------------------


#   gtime_label   ---   place a time label on the graph

procedure  gtime_label (gp)

pointer	gp		# graphics structure
pointer sp                                      # stack pointer
pointer timestr                                 # string for current time
long    old_time,  cur_time

long    clktime()

begin
        call smark (sp)
        call salloc (timestr, SZ_TIME, TY_CHAR)
        old_time = 0
        cur_time = clktime(old_time)
        call cnvtime (cur_time, Memc[timestr], SZ_TIME)
        call gtext (gp, PLTIMEX, PLTIMEY, Memc[timestr], "")
        call sfree (sp)
end

#   -------------------------------------------------------------------------------


#   gfile_label   ---   place a file label on the graph

procedure  gfile_label (gp, filename)

pointer	gp		# graphics structure
char	filename[ARB]

begin
        call gtext (gp, PLFILEX, PLFILEY, filename, "")
end


#   axis transformations

procedure  gxlin (gp)

pointer	gp

begin
	call gseti (gp, G_XTRAN, GW_LINEAR)
end


procedure  gxlog (gp)

pointer	gp

begin
	call gseti (gp, G_XTRAN, GW_LOG)
end


procedure  gylin (gp)

pointer	gp

begin
	call gseti (gp, G_YTRAN, GW_LINEAR)
end


procedure  gylog (gp)

pointer	gp

begin
	call gseti (gp, G_YTRAN, GW_LOG)
end
