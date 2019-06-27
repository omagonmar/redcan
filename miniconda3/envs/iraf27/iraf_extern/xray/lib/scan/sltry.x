#$Header: /home/pros/xray/lib/scan/RCS/sltry.x,v 11.0 1997/11/06 16:23:53 prosb Exp $
#$Log: sltry.x,v $
#Revision 11.0  1997/11/06 16:23:53  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:32:04  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:37:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:21:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:02:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:22:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:12:51  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/08/02  10:12:18  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:18:45  pros
#General Release 1.0
#
# Package task statement for the MODEL package.

task	rot		= sl_rot

include <scset.h>

procedure sl_rot ()

pointer sl		# handle for scan list mask
pointer sl_temp		# handle for temporary mask for oring complex regions
pointer	pl		# handle for IRAF pixel list
pointer	sl_open(), sl_pl()

begin
	# open scan list handle
	sl = sl_open (60, 60)
	# set up the region for the instrument
	call sl_circle (sl, 30.0, 30.0, 20.0, 1, SCAD)
	# add in a bad pixel
	call sl_point (sl, 30.0, 30.0, 1, 3, SCAD)
	# create a region for the ribs
	sl_temp = sl_open (60, 60)
	call sl_rotbox (sl_temp, 20.0, 20.0, 5.0, 45.0, 45.0, 3, SCOR)
	call sl_rotbox (sl_temp, 40.0, 20.0, 5.0, 45.0, 135.0, 3, SCOR)
	call sl_rotbox (sl_temp, 40.0, 40.0, 5.0, 45.0, 225.0, 3, SCOR)
	call sl_rotbox (sl_temp, 20.0, 40.0, 5.0, 45.0, 315.0, 3, SCOR)
	# display the ribs
	call sl_disp (sl_temp, 80)
	# add the ribs to the mask
	call sl_apply (sl_temp, sl, SCAD)
	call sl_close (sl_temp)
	# verify integrity and display the mask
	call sl_verify (sl, 0)
	call sl_disp (sl, 80)
	# create pl handle
	pl = sl_pl (sl)
	# close scan lists and return all space to system
	call sl_close (sl)
	call sl_reset()
	# display pixel list mask (80x80 screen, show full field of image)
	call rg_pldisp (pl, 80, 80, -1, -1, -1, -1)
end


