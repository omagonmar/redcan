#$Header: /home/pros/xray/xspectral/source/RCS/photoncolon.x,v 11.0 1997/11/06 16:43:07 prosb Exp $
#$Log: photoncolon.x,v $
#Revision 11.0  1997/11/06 16:43:07  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:30:50  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:34:18  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:57:22  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:52:14  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:45:57  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:17:29  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:55  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:57  prosb
#General Release 1.1
#
#Revision 2.3  91/07/12  16:34:32  prosb
#jso - made spectral.h system wide
#
#Revision 2.2  91/05/20  13:03:07  dmm
#changed back to original.  Bug fix now occurs in photon_plot.x
#
#Revision 2.1  91/03/28  03:38:45  dmm
#fixed bug 82 by making initial :ymin = 0.1 so :ylog does not crash program.
#
#Revision 2.0  91/03/06  23:06:41  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  PHOTONCOLON.X   ---   process a colon command for the photon plot

include  <gset.h>
include  <spectral.h>


#  --------------------------------------------------------------------------
#
procedure  photoncolon (pl, cmdstr)

pointer	pl				# plot structure
char	cmdstr[ARB]			# command string
char	cmd[SZ_LINE]			# extracted command word
int	ncmd				# command numerical index
real	cursor_pos			# cursor position

int	strdic(),  nscan()

begin
	# get the command
	call sscan (cmdstr)
	call gargwrd (cmd, SZ_LINE)
	if( cmd[1] == EOS )
	    return

	# process the command
	ncmd = strdic (cmd, cmd, SZ_LINE, PHOTON_CMD_KEYS)
	switch (ncmd)  {
	case PHOTON_CMD_XLOG:
		PL_XTRAN[pl] = GW_LOG
	case PHOTON_CMD_XLINEAR:
		PL_XTRAN[pl] = GW_LINEAR
	case PHOTON_CMD_YLOG:
		PL_YTRAN[pl] = GW_LOG
	case PHOTON_CMD_YLINEAR:
		PL_YTRAN[pl] = GW_LINEAR
	case PHOTON_CMD_XMIN:
		call gargr (cursor_pos)
		if( nscan() == 1 )
			PL_XMIN[pl] = PL_CURSORX[pl]
		else
			PL_XMIN[pl] = cursor_pos
	case PHOTON_CMD_XMAX:
		call gargr (cursor_pos)
		if( nscan() == 1 )
			PL_XMAX[pl] = PL_CURSORX[pl]
		else
			PL_XMAX[pl] = cursor_pos
	case PHOTON_CMD_YMIN:
		call gargr (cursor_pos)
		if( nscan() == 1 )
			PL_YMIN[pl] = PL_CURSORY[pl]
		else
			PL_YMIN[pl] = cursor_pos
	case PHOTON_CMD_YMAX:
		call gargr (cursor_pos)
		if( nscan() == 1 )
			PL_YMAX[pl] = PL_CURSORY[pl]
		else
			PL_YMAX[pl] = cursor_pos
	case PHOTON_CMD_XUNITS:
	case PHOTON_CMD_YUNITS:
	default:
		# do nothing gracefully
	}
end

