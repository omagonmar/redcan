#$Header: /home/pros/xray/xspectral/source/RCS/fluxtab.x,v 11.0 1997/11/06 16:42:09 prosb Exp $
#$Log: fluxtab.x,v $
#Revision 11.0  1997/11/06 16:42:09  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:36  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:23  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:18  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:06  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:15  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:39  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:05:52  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:15  prosb
#General Release 1.1
#
#Revision 2.1  91/07/19  14:37:47  orszak
#jso - changes to improve the output of xflux
#
#Revision 2.0  91/03/06  23:03:10  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
# FluxTab.x
#
# Routines for accessing the Flux Output Table
#

include <tbset.h>
include "flux.h"



procedure new_flux(name, tp, cp)

char	name[ARB]			# i: table file name
pointer	tp				# o: table pointer
pointer cp				# o: array of column pointers
#--

pointer	tbtopn()

begin
        if( cp == 0 )
            call calloc(cp, NFLUX_COLUMNS, TY_POINTER)

        tp = tbtopn(name, NEW_FILE, 0)		        # open a new table

        # Define the columns
	#
        call tbcdef(tp, Memi[cp + 0],    FLUX_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 1], UNABSFX_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 2],    LUMY_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 3], LENERGY_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 4], HENERGY_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 5], DISTKPC_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 6],   DISTZ_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 7],      H0_COL,"","%5.1f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 8],      Q0_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 9],     ABS_COL,"","%3s"   ,        -3, 1, 1)
        call tbcdef(tp, Memi[cp +10],   MODEL_COL,"","%10s"  , -MODWIDTH, 1, 1)

	call tbtcre(tp)
	call fluxheader(tp)
end



procedure opn_flux(name, tp, cp, rows)

char	name[ARB]
pointer	tp				# o: table pointer
pointer cp				# o: array of column pointers
int	rows				# o: number of rows
#--

pointer	tbtopn()
int	tbpsta()

begin
        if( cp == 0 )
            call calloc(cp, NFLUX_COLUMNS, TY_POINTER)

        tp   = tbtopn(name, READ_WRITE, 0)	        # open a new table
	rows = tbpsta(tp, TBL_NROWS)

        call tbcfnd(tp, FLUX_COL,    Memi[cp + 0], 1)
	if ( Memi[cp + 0]  == NULL ) call error(1, "flux column missing from output file")

        call tbcfnd(tp, UNABSFX_COL, Memi[cp + 1], 1)
	if ( Memi[cp + 1] == NULL ) call error(1, "unabsorbed flux column missing from output file")

        call tbcfnd(tp, LUMY_COL,    Memi[cp + 2], 1)
	if ( Memi[cp + 2] == NULL ) call error(1, "luminosity column missing from output file")

        call tbcfnd(tp, LENERGY_COL, Memi[cp + 3], 1)
	if ( Memi[cp + 3] == NULL ) call error(1, "lo energy column missing from output file")

        call tbcfnd(tp, HENERGY_COL, Memi[cp + 4], 1)
	if ( Memi[cp + 4] == NULL ) call error(1, "hi energy column missing from output file")

        call tbcfnd(tp, DISTKPC_COL, Memi[cp + 5], 1)
	if ( Memi[cp + 5] == NULL ) call error(1, "distance-kpc column missing from output file")

        call tbcfnd(tp,   DISTZ_COL, Memi[cp + 6], 1)
	if ( Memi[cp + 6] == NULL ) call error(1, "distance z column missing from output file")

        call tbcfnd(tp,      H0_COL, Memi[cp + 7], 1)
	if ( Memi[cp + 7] == NULL ) call error(1, "h zero column missing from output file")

        call tbcfnd(tp,      Q0_COL, Memi[cp + 8], 1)
	if ( Memi[cp + 8] == NULL ) call error(1, "q zero column missing from output file")

        call tbcfnd(tp,     ABS_COL, Memi[cp + 9], 1)
	if ( Memi[cp + 9] == NULL ) call error(1, "absorbtion type column missing from output file")

        call tbcfnd(tp,   MODEL_COL, Memi[cp +10], 1)
	if ( Memi[cp +10] == NULL ) call error(1, "model column missing from output file")
end



procedure new_flxd(name, tp, cp)

char	name[ARB]			# i: table file name
pointer	tp				# o: table pointer
pointer cp				# o: array of column pointers
#--

pointer	tbtopn()

begin
        if( cp == 0 )
            call calloc(cp, NFLXD_COLUMNS, TY_POINTER)

        tp = tbtopn(name, NEW_FILE, 0)		        # open a new table

        # Define the columns
	#
        call tbcdef(tp, Memi[cp + 0],    FLXD_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 1], UNABSFD_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 2],    LUMD_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 3],  ENERGY_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 4], DISTKPC_COL,"","%11.5e", TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 5],   DISTZ_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 6],      H0_COL,"","%5.1f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 7],      Q0_COL,"","%5.2f" , TY_DOUBLE, 1, 1)
        call tbcdef(tp, Memi[cp + 8],     ABS_COL,"","%3s"   ,        -3, 1, 1)
        call tbcdef(tp, Memi[cp + 9],   MODEL_COL,"","%10s"  , -MODWIDTH, 1, 1)

	call tbtcre(tp)
	call flxdheader(tp)
end



procedure opn_flxd(name, tp, cp, rows)

char	name[ARB]
pointer	tp
pointer	cp
int	rows
#--

pointer	tbtopn()
int	tbpsta()

begin
        if( cp == 0 )
            call calloc(cp, NFLXD_COLUMNS, TY_POINTER)

        tp   = tbtopn(name, READ_WRITE, 0)	        # open a new table
	rows = tbpsta(tp, TBL_NROWS)

        call tbcfnd(tp, FLXD_COL,    Memi[cp + 0], 1)
	if ( Memi[cp + 0] == NULL ) call error(1, "flux density column missing from output file")

        call tbcfnd(tp, UNABSFD_COL, Memi[cp + 1], 1)
	if ( Memi[cp + 1] == NULL ) call error(1, "unabsorbed flux density column missing from output file")

        call tbcfnd(tp, LUMD_COL,    Memi[cp + 2], 1)
	if ( Memi[cp + 2] == NULL ) call error(1, "luminosity density column missing from output file")

        call tbcfnd(tp, ENERGY_COL,  Memi[cp + 3], 1)
	if ( Memi[cp + 3] == NULL ) call error(1, "energy column missing from output file")

        call tbcfnd(tp, DISTKPC_COL, Memi[cp + 4], 1)
	if ( Memi[cp + 4] == NULL ) call error(1, "distance-kpc column missing from output file")

        call tbcfnd(tp,   DISTZ_COL, Memi[cp + 5], 1)
	if ( Memi[cp + 5] == NULL ) call error(1, "distance z column missing from output file")

        call tbcfnd(tp,      H0_COL, Memi[cp + 6], 1)
	if ( Memi[cp + 6] == NULL ) call error(1, "h zero column missing from output file")

        call tbcfnd(tp,      Q0_COL, Memi[cp + 7], 1)
	if ( Memi[cp + 7] == NULL ) call error(1, "q zero column missing from output file")

        call tbcfnd(tp,     ABS_COL, Memi[cp + 8], 1)
	if ( Memi[cp + 8] == NULL ) call error(1, "absorbtion type column missing from output file")

        call tbcfnd(tp,   MODEL_COL, Memi[cp + 9], 1)
	if ( Memi[cp + 9] == NULL ) call error(1, "model column missing from output file")
end


procedure fluxheader(tp)

pointer	tp
#--

begin
	
	call tbhadt(tp, "comment",
		"Units:")
	call tbhadt(tp, "comment",
		"flux       - ergs/cm**2/s = 10**-3 W/m**2")
	call tbhadt(tp, "comment",
		"luminosity - 10**34 ergs/s = 10**27 W = 2.614 LSolar")
	call tbhadt(tp, "comment",
		"energy     - keV")
	call tbhadt(tp, "comment",
		"absorbtion - MM (Morrison&MacCammon)  BG (Brown&Gould)")
end


procedure flxdheader(tp)

pointer	tp
#--

begin
	
	call tbhadt(tp, "comment",
		"Units:")
	call tbhadt(tp, "comment",
		"flux density       - microJy = 10**-29 ergs/cm**2/s/Hz")
	call tbhadt(tp, "comment",
		"luminosity density - 10**34 ergs/s/Hz = 10**27 W/Hz")
	call tbhadt(tp, "comment",
		"energy             - keV")
	call tbhadt(tp, "comment",
		"absorbtion         - MM (Morrison&MacCammon)  BG (Brown&Gould)")
end
