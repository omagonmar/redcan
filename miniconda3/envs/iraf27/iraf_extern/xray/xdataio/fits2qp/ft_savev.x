#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_savev.x,v 11.0 1997/11/06 16:34:46 prosb Exp $
#$Log: ft_savev.x,v $
#Revision 11.0  1997/11/06 16:34:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:36  prosb
#General Release 2.4
#
#Revision 8.3  1995/02/16  21:21:14  prosb
#Modified FITS2QP to correctly apply TSCAL/TZERO on extensions with
#columns which contain an array of values.  Also modified FITS2QP to
#not be so picky as to force the final index number to match the number
#of fields in an extension.  (I.e., if an extension has 8 columns, and
#TFIELD is set to 8, we can have "TUNIT5" as the final header card.)
#
#Revision 8.2  94/09/16  17:33:24  dvs
#Removed extraneous variable.
#
#Revision 8.1  94/09/16  16:39:21  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:21:23  prosb
#General Release 2.3.1
#
#Revision 7.1  94/02/25  11:09:15  mo
#MC	2/25/94		no changes
#
#Revision 7.0  93/12/27  18:40:52  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:42  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:36  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:50  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:40  jmoran
#Initial revision
#
#
# Module:	ft_savev.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include <evmacro.h>
include "fits2qp.h"
include "cards.h"
#
#  FT_SAVEV -- save event table info - we enter the events after all aux files
#
procedure ft_savev(extname, extitype, extotype, extptype, 
			ext, nrecs, bytes, fptr, wcs)

char	extname[ARB]			# table extension name
char	extitype[ARB]			# extension type definition (input)
char	extotype[ARB]			# extension type definition (output)
char	extptype[ARB]			# pros event type definition
pointer ext				# event EXTENSION record
int	nrecs				# number of records in extension
int	bytes				# numner of bytes per extension record
int	fptr				# current pointer into FITS file
pointer	wcs

pointer cur_ev_ext
pointer cur_ext
int	i

include "fits2qp.com"

begin
	call strcpy(extname, evname, SZ_LINE)
	call strcpy(extitype, evitype, SZ_TYPEDEF)
	call strcpy(extotype, evotype, SZ_TYPEDEF)
	call strcpy(extptype, prostype, SZ_TYPEDEF)
	evnrecs = nrecs
	evbytes = bytes
	evfptr = fptr
	fitwcs = wcs
	evfields = tfields

        # allocate space for extension info records
        call malloc(evext, evfields*SZ_EXT, TY_STRUCT)

	# copy extension info record -- all we need is zero/scale/is-index stuff.
        do i=1, evfields
	{
             cur_ext=EXT(ext,i)
             cur_ev_ext=EXT(ev_ext,i)

             EXT_ZERO(cur_ev_ext)=EXT_ZERO(cur_ext)
             EXT_SCALE(cur_ev_ext)=EXT_SCALE(cur_ext)
	     EXT_IS_EV_INDEX(cur_ev_ext)=EXT_IS_EV_INDEX(cur_ext)
             EXT_REPCNT(cur_ev_ext)=EXT_REPCNT(cur_ext)
        }

end

#
#  FT_FREE_EV -- free memory set aside for saved event structure.
#

procedure ft_free_ev()
include "fits2qp.com"

begin
	# free evext 
	call mfree(evext, TY_STRUCT)
end
