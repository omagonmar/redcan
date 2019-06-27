#$Header: /home/pros/xray/xspectral/source/RCS/flux.h,v 11.0 1997/11/06 16:42:06 prosb Exp $
#$Log: flux.h,v $
#Revision 11.0  1997/11/06 16:42:06  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:31  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:12  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:11  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:49:57  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:09  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:14:27  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:58:09  prosb
#General Release 1.1
#
#Revision 2.1  91/07/19  14:32:48  orszak
#jso - change to improve output of xflux
#
#Revision 2.0  91/03/06  23:02:55  pros
#General Release 1.0
#
#
# Flux definitions
#

define NFLUX_COLUMNS	11
define NFLXD_COLUMNS	10

# Column names
#
define FLUX_COL		"flux"
define FLXD_COL		"flux_den"
define UNABSFX_COL	"unabs_f"
define UNABSFD_COL	"unabs_fd"
define LUMY_COL		"luminosity"
define LUMD_COL		"lum_den"

define DISTKPC_COL	"D_kpc"
define DISTZ_COL	"D_z"
define H0_COL		"H_o"
define Q0_COL		"q_o"
define ABS_COL		"abs"

define ENERGY_COL  "energy"
define HENERGY_COL "hi_energy"
define LENERGY_COL "lo_energy"
define UNITS_COL   "units"
define MODEL_COL   "model"

# constants for unit conversion
#
define Kev2Hz17		2.417965
define Kev2Erg9		1.602192
define Kpc2cm21		3.085678

define Kev2Hz		2.417965d17
define Kev2Erg		1.602192d-9

# constants for dunits
#
define KPC	1
define RED	2

define MODWIDTH		60

define C     299792.458


