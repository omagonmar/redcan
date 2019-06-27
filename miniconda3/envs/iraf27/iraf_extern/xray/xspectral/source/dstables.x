#$Header: /home/pros/xray/xspectral/source/RCS/dstables.x,v 11.0 1997/11/06 16:42:10 prosb Exp $
#$Log: dstables.x,v $
#Revision 11.0  1997/11/06 16:42:10  prosb
#General Release 2.5
#
#Revision 9.1  1997/09/18 18:10:10  prosb
#JCC(9/17/97)-change the format of "sprintf" in dos_getbal()
#             to get the string "bal_1" without a blank.
#             The blank caused an error when running bal_plot
#             and fit for EINSTEIN_IPC data.
#             [ ERROR: tbhgtr: table header parameter `bal_1 ' not found ]
#
#Revision 9.0  1995/11/16 19:29:24  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:30:53  prosb
#General Release 2.3.1
#
#Revision 7.3  94/05/18  17:58:54  dennis
#Eliminated writing and reading the now-obsolete POINT header parameter.
#
#Revision 7.2  94/04/09  00:44:34  dennis
#Changed output and input of off-axis angle, from always being the 
#off-axis angle of the center of the region, to being that except for 
#ROSAT instruments, for which it is mean off-axis angle of counted events.
#
#Revision 7.1  94/03/29  11:28:58  dennis
#Added EINSTEIN_MPC case to ds_get().
#
#Revision 7.0  93/12/27  18:54:58  prosb
#General Release 2.3
#
#Revision 6.9  93/12/21  16:23:31  dvs
#Modified ds_getbal and ds_putbal to write out (and read in) table
#entries as fractions of time, while using them internally as 
#percentages.
#
#Revision 6.8  93/12/21  01:42:00  dennis
#Added routine get_respfile(), to return name of response matrix file, 
#and made ds_append() use it to put the name in header of _prd.tab file.
#
#Revision 6.7  93/12/17  23:16:51  dennis
#Enabled processing the FITS release tape spectral table files.
#
#Revision 6.6  93/12/08  02:26:14  dennis
#"net" and "neterr" column names restored (instead of "counts" and "
#"stat_err").
#
#Revision 6.5  93/12/04  00:16:21  dennis
#Added units to column headings, and corrected title of cts_tot column.
#
#Revision 6.4  93/10/29  21:08:51  dennis
#Corrected offaxis angle units conversion: changed scale factor type, 
#take absolute value.
#
#Revision 6.3  93/10/22  16:42:23  dennis
#Added SRG_HEPC1, SRG_LEPC1 cases, for DSRI; 
#get offaxis angles from DS struct instead of hard-coding them; 
#removed absolute path to pspc.h.
#
#Revision 6.2  93/09/30  23:28:01  dennis
#Changed conditionals to test QP_FORMAT instead of QP_REVISION.
#Also corrected BAL table column headings.
#
#Revision 6.1  93/09/25  02:13:09  dennis
#Changed to accommodate the new file formats (RDF).
#
#Revision 6.0  93/05/24  16:49:40  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:43:58  prosb
#General Release 2.1
#
#Revision 4.2  92/10/06  10:28:14  prosb
#jso - added some code so that the _prd.tab file is written correctly
#      with the rebin option.  there are some problems if you use
#      predicated=append and switch between rebin+ and rebin-.
#
#Revision 4.1  92/10/01  11:49:51  prosb
#
#jso - code to change names of models that were to long to use with
#      predicated=append for more than 9 fits.  this should be backward
#      compatable.
#
#Revision 4.0  92/04/27  18:14:08  prosb
#General Release 2.0:  April 1992
#
#Revision 3.4  92/04/01  11:09:03  prosb
#jso - added off axis histogram to ROSAT HRI and default.  we should get
#      instrument dependence out of here.
#
#Revision 3.3  92/03/06  10:42:10  prosb
#jso - corrected spectral.h from qpspec upgrade.
#
#Revision 3.2  92/03/05  13:36:47  orszak
#jso - added background OAH for upgraded qpspec
#
#Revision 3.1  91/09/22  19:05:38  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:03  prosb
#General Release 1.1
#
#Revision 2.7  91/07/24  18:45:14  prosb
#jso - commented to several warning messages that seem to only appear when
#      trying to do a counts_plot of the _obs.tab, therefore polluting the
#      graphics.  
#  AND i fixed the CHAN_COL output so that stwfits and strfits would properly
#      handle it.  this meant converting the interger with a char format to
#      a true string.  i had to add a new procedure to copy string columns.
#
#Revision 2.6  91/07/12  15:56:49  prosb
#jso - made spectral.h a systemwide.  addded sub_instrument, and corrected
#sequence number
#
#Revision 2.5  91/05/24  11:34:58  pros
#jso/eric - these are erics changes to allow for multi-line io on the models
#in prd files.
#
#Revision 2.4  91/04/25  16:33:55  pros
#Fix another place with FILTER.
#
#Revision 2.3  91/04/22  19:09:08  john
#Add error check for fetch of FILTER parameter.
#
#Revision 2.2  91/04/19  11:39:57  mo
#MC	4/19/91		Added i/o for the PSPC filter parameter to/from
#			the spectral table file.  Previously, it was
#			not read, therefore defaulted to 0 = no filter.
#			And qpspec wasn't writing it anyway.
#
#Revision 2.1  91/04/15  17:43:13  john
#Fix up the indexing of the Offaxis histogram.
#
#Revision 2.0  91/03/06  23:02:35  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#  DSTABLES.X -- routines that deal with the observed data set tables
#

include <tbset.h>
include <time.h>
include <mach.h>
include <math.h>

include	<ctype.h>
include <ext.h>
include <spectral.h>
include "pspc.h"
include	"rhri.h"
include	"hepc1.h"
include	"lepc1.h"
include	"def.h"

# define character strings for channels fit table
define	SPACE		" "
define	STAR		"*"


#
# DS_PUTHEAD -- write header information into the table
#
procedure ds_puthead(tp, qphead, ds)

pointer tp					# i: table pointer
pointer	qphead					# i: QPOE header structure
pointer	ds					# i: pointer to sdf record

begin
	call put_tbhead(tp, qphead)

	# Basic spectral required parameters
	#
	call tbhadt(tp, "comment", "The following parameters are required:")
	call tbhadi(tp, "NCHANS", DS_NPHAS(ds))

	# Optional general information parameters  (output only if set)
	#
	call tbhadt(tp, "comment", "The following parameters are optional:")
	if( DS_SOURCENO(ds) !=0 )
	    call tbhadi(tp, "source_no", DS_SOURCENO(ds))
	if( (DS_OLD_Y(ds)>EPSILON) || (DS_OLD_Z(ds)>EPSILON) ){
	    call tbhadr(tp, "old_y", DS_OLD_Y(ds))
	    call tbhadr(tp, "old_z", DS_OLD_Z(ds))
	}
	if( (DS_X(ds)>EPSILON) || (DS_Y(ds)>EPSILON) ){
	    call tbhadr(tp, "x", DS_X(ds))
	    call tbhadr(tp, "y", DS_Y(ds))
	}
	if( (DS_RA(ds)>EPSILON) || (DS_DEC(ds)>EPSILON) ){
	    call tbhadr(tp, "ra", RADTODEG(DS_RA(ds)))
	    call tbhadr(tp, "dec", RADTODEG(DS_DEC(ds)))
	}
	if( (DS_GLONG(ds)>EPSILON) || (DS_GLAT(ds)>EPSILON) ){
	    call tbhadr(tp, "glong", DS_GLONG(ds))
	    call tbhadr(tp, "glat", DS_GLAT(ds))
	}
	if( DS_VIGNETTING(ds)>EPSILON )
	    call tbhadr(tp, "vigncorr", DS_VIGNETTING(ds))
	if( DS_SAREA(ds)>EPSILON || DS_BAREA(ds)> EPSILON )
	    call tbhadr(tp, "sarea", DS_SAREA(ds))
	if( DS_SAREA(ds)>EPSILON || DS_BAREA(ds)> EPSILON )
	    call tbhadr(tp, "barea", DS_BAREA(ds))

	call tbhadt(tp, "comment", "The following parameters are required for this instrument:")
	switch ( DS_INSTRUMENT(ds) ) {
	 case EINSTEIN_IPC:
	    call tbhadr(tp, "angle", DS_REGION_OFFAXIS_ANGLE(ds))
	    call tbhadr(tp, "radius", DS_SOURCE_RADIUS(ds))
#	    call tbhadi(tp, "point", DS_POINT(ds))
	    call tbhadr(tp, "arcfrac", DS_ARCFRAC(ds))
	 case EINSTEIN_HRI:
	    call tbhadr(tp, "angle", DS_REGION_OFFAXIS_ANGLE(ds))
	    call tbhadr(tp, "radius", DS_SOURCE_RADIUS(ds))
#	    call tbhadi(tp, "point", DS_POINT(ds))
	 case ROSAT_PSPC:
#	    call tbhadi(tp, "point", DS_POINT(ds))
	 case ROSAT_HRI:
#	    call tbhadi(tp, "point", DS_POINT(ds))
	 case SRG_HEPC1:
#	    call tbhadr(tp, "angle", DS_REGION_OFFAXIS_ANGLE(ds))
#	    call tbhadr(tp, "radius", DS_SOURCE_RADIUS(ds))
#	    call tbhadi(tp, "point", DS_POINT(ds))
	 case SRG_LEPC1:
	    call tbhadr(tp, "angle", DS_REGION_OFFAXIS_ANGLE(ds))
	    call tbhadr(tp, "radius", DS_SOURCE_RADIUS(ds))
#	    call tbhadi(tp, "point", DS_POINT(ds))
	 default:
	    call tbhadr(tp, "angle", DS_REGION_OFFAXIS_ANGLE(ds))
	    call tbhadr(tp, "radius", DS_SOURCE_RADIUS(ds))
#	    call tbhadi(tp, "point", DS_POINT(ds))
	}
end

		
# define max number of table columns for the off-axis histograms
define  MAX_BAL_CP 2

# define table column pointers
define	BAL_CP		Memi[($1)+0]
define	BFRAC_CP	Memi[($1)+1]

# define off-axis histogram table column names
define	BAL_COL		"bal"
define	BFRAC_COL	"frac_time"

#
#  DS_CREATE_BAL -- open the BAL histogram table file and create column headers
#
procedure ds_create_bal(table, tp, cp)

char	table[ARB]		# i: table name
pointer tp			# o: table pointer
pointer	cp			# o: column pointers
pointer tbtopn()		# l: table open routine

begin
	# allocate space for the column pointers
	call calloc(cp, MAX_BAL_CP, TY_POINTER)

	# open a new table	
	tp = tbtopn(table, NEW_FILE, 0)

	# and define columns
	call tbcdef(tp, BAL_CP(cp),  BAL_COL, "", "%14.7g", TY_REAL, 1, 1)
	call tbcdef(tp, BFRAC_CP(cp),  BFRAC_COL, "", "%14.7g", TY_REAL, 1, 1)

	# create the table
	call tbtcre(tp)
end


#
#  DS_PUTBAL -- write bal histo information into a table file
#
procedure ds_putbal(tp, cp, bh)

pointer tp					# i: table pointer
pointer	cp					# i: column pointers
pointer	bh					# i: pointer to bal record

int	i					# l: loop counter

begin
	# if bh is NULL, there is no bal info
	if( bh == NULL ){
	    call tbhadi(tp, "nbals", 0)
	    call eprintf(
	    "\nDSLIB: Warning: no bal histogram; creating empty BAL file\n")
	}
	else {
	    # enter number of bals
	    call tbhadi(tp, "nbals", BH_ENTRIES(bh))

	    # bal header information
	    # the following are mission specific:
	    call tbhadr(tp, "bal_lo", BH_START_BAL(bh))
	    call tbhadr(tp, "bal_hi", BH_END_BAL(bh))
	    call tbhadr(tp, "bal_inc", BH_BAL_INC(bh))
	    call tbhadi(tp, "bal_steps", BH_BAL_STEPS(bh))
	    call tbhadr(tp, "bal_eps", BH_BAL_EPS(bh))
	    call tbhadr(tp, "bal_mean", BH_MEAN_BAL(bh))
	    if(  BH_BAL_FLAG(bh) == PSGNI )
		call tbhadt(tp, "bal_spatial", "PSGNI")
	    else if(  BH_BAL_FLAG(bh) == DGNI )
		call tbhadt(tp, "bal_spatial", "DGNI")
	    else
		call tbhadt(tp, "bal_spatial", "UNKNOWN_GNI")
	
	    if( BH_ENTRIES(bh) ==0 ){
		call eprintf(
	       "\nDSLIB: Warning: no bal histogram; creating empty BAL file\n")
	    }
	    else {
		# now write the table rows
		do i=1, BH_ENTRIES(bh){

		    call tbrptr(tp, BAL_CP(cp), BH_BAL(bh,i), 1, i)
		    call tbrptr(tp, BFRAC_CP(cp), 0.01E0*BH_PERCENT(bh,i), 1, i)
		}
	    }
	}
end


# define max number of table columns for the off-axis histograms
define  MAX_OAH_CP 2

# define table column pointers
define	OAR_CP		Memi[($1)+0]
define	FT_CP		Memi[($1)+1]

# define off-axis histogram table column names
define	OAR_COL		"off_ax_rad"
define	FT_COL		"frac_time"

#
#  DS_CREATE_OAH -- open the source and background off-axis histogram 
#                   table files and create column headers
#
procedure ds_create_oah(stable, stp, scp, btable, btp, bcp)

char	stable[ARB]		# i: source OAH table name
pointer stp			# o: source OAH table pointer
pointer	scp			# o: source OAH column pointers
char	btable[ARB]		# i: background OAH table name
pointer btp			# o: background OAH table pointer
pointer	bcp			# o: background OAH column pointers

pointer tbtopn()		# l: table open routine

begin
	# allocate space for the column pointers
	call calloc(scp, MAX_OAH_CP, TY_POINTER)
	call calloc(bcp, MAX_OAH_CP, TY_POINTER)

	# open the new tables
	stp = tbtopn(stable, NEW_FILE, 0)
	btp = tbtopn(btable, NEW_FILE, 0)

	# and define columns
	call tbcdef(stp, OAR_CP(scp),  OAR_COL, "", "%14.7g", TY_REAL, 1, 1)
	call tbcdef(stp, FT_CP(scp),  FT_COL, "", "%14.7g", TY_REAL, 1, 1)
	call tbcdef(btp, OAR_CP(bcp),  OAR_COL, "", "%14.7g", TY_REAL, 1, 1)
	call tbcdef(btp, FT_CP(bcp),  FT_COL, "", "%14.7g", TY_REAL, 1, 1)

	# create the tables
	call tbtcre(stp)
	call tbtcre(btp)
end

#
# DS_PUTOAH -- write source offaxis histogram and background offaxis histogram
#
procedure ds_putoah(stp, scp, btp, bcp, ds, degperpix)
pointer	stp			# i: source OAH table pointer
pointer	scp			# i: source OAH column pointers
pointer	btp			# i: background OAH table pointer
pointer	bcp			# i: background OAH column pointers
pointer ds			# i: pointer to sdf record
real	degperpix		# i: pixel size (degrees/pixel)
#--
real	radius
int	ii

begin
	call tbhadt(stp, "comment", "OFFAXISA is the mean off-axis angle of source events.")
	call tbhadt(stp, "comment", "OFFAXISA is computed before binning.")
	call tbhadt(stp, "comment", "Computing from the histogram will only approximate OFFAXISA.")
	call tbhadr(stp, "offaxisa", DS_MEAN_EVENT_OFFAXIS_ANGLE(ds))

	if ( DS_NOAH(ds) == 0 || DS_OAHPTR(ds) == NULL ) {
	    call eprintf(
	 "\nDSLIB: Warning: no offaxis histograms; creating empty OAH files\n")
	}
	else {
	    for ( ii = 0;  ii < DS_NOAH(ds);  ii = ii + 1 ) {
		# convert offaxis angle (radius) from pixels to arcmin
	        radius = abs(DS_OAHAN(ds, ii) * degperpix * 60.0)
		call tbrptr(stp, OAR_CP(scp), radius, 1, ii+1)
		call tbrptr(stp, FT_CP(scp), DS_OAH(ds, ii), 1, ii+1)
		call tbrptr(btp, OAR_CP(bcp), radius, 1, ii+1)
		call tbrptr(btp, FT_CP(bcp), DS_BK_OAH(ds, ii), 1, ii+1)
	    }
	}
end

# define max number of table columns for the observed data set
define  MAX_SPEC_CP	9

# define table column pointers
define	EN1_CP		Memi[($1)+0]
define	EN2_CP		Memi[($1)+1]
define	SOURCE_CP	Memi[($1)+2]
define	BKGD_CP		Memi[($1)+3]
define	NET_CP		Memi[($1)+4]
define	ERR_CP		Memi[($1)+5]
define	PRED_CP		Memi[($1)+6]
define  CHI_CP		Memi[($1)+7]
define  CHAN_CP		Memi[($1)+8]

# define table column names
define	EN1_COL		"e_lo"
define	EN2_COL		"e_hi"
define	SOURCE_COL	"cts_tot"
define	BKGD_COL	"ccts_bkg"
define	NET_COL		"net"
define	ERR_COL		"neterr"
define  PRED_COL	"pred"
define  CHI_COL		"chisq"
define  CHAN_COL	"chans"

#define table column units
define	EN1_UNITS	"keV"
define	EN2_UNITS	"keV"
define	SOURCE_UNITS	"count"
define	BKGD_UNITS	"count"
define	NET_UNITS	"count"
define	ERR_UNITS	"count"

#
# DS_CREATE_SPEC -- open the spectral data table file and create column headers
#
procedure ds_create_spec(table, tp, cp)

char	table[ARB]		# i: table name
pointer tp			# o: table pointer
pointer	cp			# o: column pointers

pointer tbtopn()		# l: table open routine

begin
	# allocate space for the column pointers
	call calloc(cp, MAX_SPEC_CP, TY_POINTER)

	# open a new table	
	tp = tbtopn(table, NEW_FILE, 0)

	# and define columns
	call tbcdef(tp, EN1_CP(cp),  EN1_COL, EN1_UNITS, "%9.2f", TY_REAL, 
									1, 1)
	call tbcdef(tp, EN2_CP(cp),  EN2_COL, EN2_UNITS, "%9.2f", TY_REAL, 
									1, 1)
	call tbcdef(tp, SOURCE_CP(cp), SOURCE_COL, SOURCE_UNITS, "%9.2f", 
								TY_REAL, 1, 1)
	call tbcdef(tp, BKGD_CP(cp), BKGD_COL, BKGD_UNITS, "%9.2f", 
								TY_REAL, 1, 1)
	call tbcdef(tp, NET_CP(cp), NET_COL, NET_UNITS, "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, ERR_CP(cp), ERR_COL, ERR_UNITS, "%9.2f", TY_REAL, 1, 1)

	# create the table
	call tbtcre(tp)
end

#
# DS_PUTSPEC -- fill spectral data table file with spectra and errors
#
procedure ds_putspec(tp, cp, ds)

pointer tp			# i: table pointer
pointer	cp			# i: column pointers
pointer	ds			# i: pointer to sdf record
int	i			# l: temp index

begin

	# loop through the four colums
	do i=1, DS_NPHAS(ds){

	    if( DS_LO_ENERGY(ds) != NULL )
		call tbrptr(tp, EN1_CP(cp), Memr[DS_LO_ENERGY(ds)+i-1], 1, i)
	    if( DS_HI_ENERGY(ds) != NULL )
		call tbrptr(tp, EN2_CP(cp), Memr[DS_HI_ENERGY(ds)+i-1], 1, i)
	    if( DS_SOURCE(ds) != NULL )
		call tbrptr(tp, SOURCE_CP(cp), Memr[DS_SOURCE(ds)+i-1], 1, i)
	    if( DS_BKGD(ds) != NULL )
		call tbrptr(tp, BKGD_CP(cp), Memr[DS_BKGD(ds)+i-1], 1, i)
	    if( DS_OBS_DATA(ds) != NULL )
		call tbrptr(tp, NET_CP(cp), Memr[DS_OBS_DATA(ds)+i-1], 1, i)
	    if( DS_OBS_ERROR(ds) != NULL )
		call tbrptr(tp, ERR_CP(cp), Memr[DS_OBS_ERROR(ds)+i-1], 1, i)
	}
end

#
# DS_GET -- read header information and spectra from the spectral data table, 
#		and off-axis histogram tables or BAL histogram table
#
procedure ds_get(obs_table, qphead, ds)

char	obs_table[ARB]		# i: _obs.tab file spec
pointer	qphead			# o: QPOE header structure
pointer	ds			# o: pointer to sdf record

pointer	obs_tp			# l: observed spectral data table pointer
pointer	obs_cp			# l: pointer to array of OBS column pointers

begin
	# open the _obs.tab file
	call ds_open_spec(obs_table, obs_tp, obs_cp)

	# allocate space for the dataset structure
	call calloc(ds, LEN_DS, TY_STRUCT)
	# save the _obs.tab file spec in the dataset structure
	call calloc(DS_FILENAME(ds), SZ_PATHNAME, TY_CHAR)
	call strcpy(obs_table, Memc[DS_FILENAME(ds)], SZ_PATHNAME)

	# get general header info and spectra from _obs.tab file
	call ds_gethead(obs_tp, qphead, ds)
	call ds_getspec(obs_tp, obs_cp, ds)

	switch ( DS_INSTRUMENT(ds) ) {

	 case EINSTEIN_IPC:
	    if (QP_FORMAT(qphead) < 1)
		call dos_getbal(obs_tp, ds)
	    else
		call ds_getbal(ds)

	 case EINSTEIN_HRI:
	 case EINSTEIN_MPC:

	 default:
	    if (QP_FORMAT(qphead) < 1)
		call dos_getoah(obs_tp, ds)
	    else
		call ds_getoah(ds)
	}

	# now (after the possible calls to dos_getbal() and dos_getoah()) 
	#  we can close the _obs.tab file
	call tbtclo(obs_tp)
	call mfree(obs_cp, TY_POINTER)
end

# define RDF table column names (they may differ from ours)
define	EN1_COL_RDF	"E_LO"
define	EN2_COL_RDF	"E_HI"
define	SOURCE_COL_RDF	"CCTS_TOT"
define	BKGD_COL_RDF	"CCTS_BKG"
define	NET_COL_RDF	"COUNTS"
define	ERR_COL_RDF	"STAT_ERR"

# define old table column names
define	EN1_COL_OLD	"lo_energy"
define	EN2_COL_OLD	"hi_energy"
define	SOURCE_COL_OLD	"source"
define	BKGD_COL_OLD	"bkgd"
define	NET_COL_OLD	"net"
define	ERR_COL_OLD	"neterr"

#
# DS_OPEN_SPEC -- open the spectral data table file and check column headers
#
procedure ds_open_spec(table, tp, cp)

char	table[ARB]		# i: table name
pointer tp			# o: table pointer
pointer	cp			# o: column pointers
pointer tbtopn()		# l: table open routine

begin
	# allocate space for the column pointers
	if( cp == NULL )
	    call calloc(cp, MAX_SPEC_CP, TY_POINTER)

	# initialize and open the table
	tp = tbtopn (table, READ_ONLY, 0)

	# look for each column, first under new PROS name, then (if not found) 
	#  under RDF name, then (if still not found) under old name

	call tbcfnd(tp, EN1_COL, EN1_CP(cp), 1)
	if( EN1_CP(cp) == NULL ) {
	    call tbcfnd(tp, EN1_COL_RDF, EN1_CP(cp), 1)
	    if( EN1_CP(cp) == NULL )
		call tbcfnd(tp, EN1_COL_OLD, EN1_CP(cp), 1)
	}

	call tbcfnd(tp, EN2_COL, EN2_CP(cp), 1)
	if( EN2_CP(cp) == NULL ) {
	    call tbcfnd(tp, EN2_COL_RDF, EN2_CP(cp), 1)
	    if( EN2_CP(cp) == NULL )
		call tbcfnd(tp, EN2_COL_OLD, EN2_CP(cp), 1)
	}

	call tbcfnd(tp, SOURCE_COL, SOURCE_CP(cp), 1)
	if( SOURCE_CP(cp) == NULL ) {
	    call tbcfnd(tp, SOURCE_COL_RDF, SOURCE_CP(cp), 1)
	    if( SOURCE_CP(cp) == NULL )
		call tbcfnd(tp, SOURCE_COL_OLD, SOURCE_CP(cp), 1)
	}

	call tbcfnd(tp, BKGD_COL, BKGD_CP(cp), 1)
	if( BKGD_CP(cp) == NULL ) {
	    call tbcfnd(tp, BKGD_COL_RDF, BKGD_CP(cp), 1)
	    if( BKGD_CP(cp) == NULL )
		call tbcfnd(tp, BKGD_COL_OLD, BKGD_CP(cp), 1)
	}

	# we need a net (or COUNTS) and neterr (or STAT_ERR) 
	#  in order to do anything else

	call tbcfnd(tp, NET_COL, NET_CP(cp), 1)
	if( NET_CP(cp) == NULL )  {
	    call tbcfnd(tp, NET_COL_RDF, NET_CP(cp), 1)
	    if( NET_CP(cp) == NULL )  {
		call tbcfnd(tp, NET_COL_OLD, NET_CP(cp), 1)
		if( NET_CP(cp) == NULL )  {
		    call eprintf("DSLIB: File %s:\n")
		     call pargstr(table)
		    call error(1, "DSLIB:  missing 'net' (or 'COUNTS') column")
		}
	    }
	}
	call tbcfnd(tp, ERR_COL, ERR_CP(cp), 1)
	if( ERR_CP(cp) == NULL )  {
	    call tbcfnd(tp, ERR_COL_RDF, ERR_CP(cp), 1)
	    if( ERR_CP(cp) == NULL )  {
		call tbcfnd(tp, ERR_COL_OLD, ERR_CP(cp), 1)
		if( ERR_CP(cp) == NULL )  {
		    call eprintf("DSLIB: File %s:\n")
		     call pargstr(table)
		    call error(1, 
			"DSLIB:  missing 'neterr' (or 'STAT_ERR') column")
		}
	    }
	}
end

#
# DOS_OPEN -- open the _obs.tab table file for updating
#
int procedure dos_open(table, tp, cp, ok)

char	table[ARB]		# i: table name
pointer tp			# o: table pointer
pointer	cp			# o: column pointers
bool	ok			# o: whether column names seem consistent

pointer tbtopn()		# l: table open routine

begin
	# allocate space for the column pointers
	call calloc(cp, MAX_SPEC_CP, TY_POINTER)

	# initialize and open the table, first READ_ONLY, just to see 
	#  whether it really is an old-style table
	tp = tbtopn (table, READ_ONLY, 0)

#	# if net and neterr aren't here, it's probably because we have a 
#	#  new-style file (else ds_get() would have quit with an error 
#	#  earlier); at any rate, abandon the open in that case
	call tbcfnd(tp, NET_COL_OLD, NET_CP(cp), 1)
	if( NET_CP(cp) == NULL )  {
	    call tbtclo(tp)
	    call mfree(cp, TY_POINTER)
	    ok = true
	    return NO
	}
	call tbcfnd(tp, ERR_COL_OLD, ERR_CP(cp), 1)
	if( ERR_CP(cp) == NULL )  {
#	    call eprintf("DSLIB: File %s has 'net' and 'stat_err' columns.\n")
#	     call pargstr(table)
#	    call eprintf(
#		"        ('net' is old-style, 'stat_err' is new-style)\n")
	    call tbtclo(tp)
	    call mfree(cp, TY_POINTER)
	    ok = false
	    return NO
	}
	call tbtclo(tp)

	# re-open the table for updating
	tp = tbtopn (table, READ_WRITE, 0)

	# look for each column; change its name from old to new

	call tbcfnd(tp, EN1_COL_OLD, EN1_CP(cp), 1)
	if( EN1_CP(cp) != NULL )
	    call tbcnam(tp, EN1_CP(cp), EN1_COL)

	call tbcfnd(tp, EN2_COL_OLD, EN2_CP(cp), 1)
	if( EN2_CP(cp) != NULL )
	    call tbcnam(tp, EN2_CP(cp), EN2_COL)

	call tbcfnd(tp, SOURCE_COL_OLD, SOURCE_CP(cp), 1)
	if( SOURCE_CP(cp) != NULL )
	    call tbcnam(tp, SOURCE_CP(cp), SOURCE_COL)

	call tbcfnd(tp, BKGD_COL_OLD, BKGD_CP(cp), 1)
	if( BKGD_CP(cp) != NULL )
	    call tbcnam(tp, BKGD_CP(cp), BKGD_COL)

	# we already know that 'net' and 'neterr' are here

	call tbcfnd(tp, NET_COL_OLD, NET_CP(cp), 1)
	call tbcnam(tp, NET_CP(cp), NET_COL)

	call tbcfnd(tp, ERR_COL_OLD, ERR_CP(cp), 1)
	call tbcnam(tp, ERR_CP(cp), ERR_COL)

	ok = true
	return YES
end

#
# DS_GETHEAD -- read header information from the spectral data table
#
procedure ds_gethead(tp, qphead, ds)

pointer tp					# i: table pointer
pointer	qphead					# o: QPOE header structure
pointer	ds					# i: pointer to sdf record

char	cbuf[SZ_LINE]				# l: temp char buffer
int	ds_tbhgti()				# l: get int header param
real	ds_tbhgtr()				# l: get real header param
int	tbhgti()				# l: get int header param
real	tbhgtr()				# l: get real header param

begin
	call get_tbhead(tp, qphead)

	# allocate ds, if necessary
	if( ds == NULL )
	    call calloc(ds, LEN_DS, TY_STRUCT)
	# the following are required:
	DS_MISSION(ds) = QP_MISSION(qphead)
	DS_INSTRUMENT(ds) = QP_INST(qphead)
	DS_SUB_INSTRUMENT(ds) = QP_SUBINST(qphead)
	call strcpy(QP_OBSID(qphead), DS_SEQNO(ds), SZ_OBSID)
	DS_NPHAS(ds) = ds_tbhgti(tp, "NCHANS")
	if ( DS_NPHAS(ds) == 0 ) 
		DS_NPHAS(ds) = tbhgti(tp, "nphas")

	DS_LIVETIME(ds) = QP_LIVETIME(qphead)
	# make sure we have a valid live time
	if( DS_LIVETIME(ds) < 1.0e-1 ){
	    call sprintf(cbuf, SZ_LINE, 
			"DSLIB: invalid livetime: %.3f (use 'tupar' to change)")
	    call pargr(DS_LIVETIME(ds))
	    call error(1, cbuf)
	}

	# Optional informational parameters
	#
	DS_SOURCENO(ds) = ds_tbhgti(tp, "source_no")
	DS_OLD_Y(ds) 	= ds_tbhgtr(tp, "old_y")
	DS_OLD_Z(ds) 	= ds_tbhgtr(tp, "old_z")
	DS_X(ds) 	= ds_tbhgtr(tp, "x")
	DS_Y(ds) 	= ds_tbhgtr(tp, "y")
	DS_RA(ds) 	= DEGTORAD(ds_tbhgtr(tp, "ra"))
	DS_DEC(ds) 	= DEGTORAD(ds_tbhgtr(tp, "dec"))
	DS_GLONG(ds) 	= ds_tbhgtr(tp, "glong")
	DS_GLAT(ds) 	= ds_tbhgtr(tp, "glat")
	DS_VIGNETTING(ds) = ds_tbhgtr(tp, "vigncorr")
	DS_LIVECORR(ds) = QP_DEADTC(qphead)
	DS_SAREA(ds) 	= ds_tbhgtr(tp, "sarea")
	DS_BAREA(ds) 	= ds_tbhgtr(tp, "barea")

	# Instrument specific required parameters
	#
	switch ( DS_INSTRUMENT(ds) ) {
	 case EINSTEIN_IPC:
	    DS_REGION_OFFAXIS_ANGLE(ds)	= tbhgtr(tp, "angle")
	    DS_SOURCE_RADIUS(ds)	= tbhgtr(tp, "radius")
#	    DS_POINT(ds)		= tbhgti(tp, "point")
	    DS_ARCFRAC(ds)		= ds_tbhgtr(tp, "arcfrac")
	 case EINSTEIN_HRI:
	    DS_REGION_OFFAXIS_ANGLE(ds)	= tbhgtr(tp, "angle")
	    DS_SOURCE_RADIUS(ds)	= tbhgtr(tp, "radius")
#	    DS_POINT(ds)		= tbhgti(tp, "point")
	 case ROSAT_PSPC:
#	    # (Now treating "point" as optional, since it's not in RDF files 
#	    #  and we only display it to the user; default to qpspec default)
#	    call tbhfkw(tp, "point", parnum)
#	    if( parnum == 0 )
#		DS_POINT(ds)		= YES
#	    else
#		DS_POINT(ds)		= tbhgti(tp, "point")
	    DS_FILTER(ds)		= QP_FILTER(qphead)
	 case ROSAT_HRI:
#	    # (Now treating "point" as optional, since it's not in RDF files 
#	    #  and we only display it to the user; default to qpspec default)
#	    call tbhfkw(tp, "point", parnum)
#	    if( parnum == 0 )
#		DS_POINT(ds)		= YES
#	    else
#		DS_POINT(ds)		= tbhgti(tp, "point")
	 case SRG_HEPC1:
	    DS_FILTER(ds)		= QP_FILTER(qphead)
#	    DS_REGION_OFFAXIS_ANGLE(ds)	= ds_tbhgtr(tp, "angle")
#	    DS_SOURCE_RADIUS(ds)	= ds_tbhgtr(tp, "radius")
#	    DS_POINT(ds)		= ds_tbhgti(tp, "point")
	 case SRG_LEPC1:
	    DS_REGION_OFFAXIS_ANGLE(ds) = ds_tbhgtr(tp, "angle")
	    DS_SOURCE_RADIUS(ds)	= ds_tbhgtr(tp, "radius")
#	    DS_POINT(ds)		= ds_tbhgti(tp, "point")
	 default:
	    DS_REGION_OFFAXIS_ANGLE(ds) = ds_tbhgtr(tp, "angle")
	    DS_SOURCE_RADIUS(ds)	= ds_tbhgtr(tp, "radius")
#	    DS_POINT(ds)		= ds_tbhgti(tp, "point")
	}
end


# define ~RDF off-axis histogram table column names (they may differ from ours)
define	BAL_COL_RDF	"BAL"
define	BFRAC_COL_RDF	"FRAC_TIME"

# define "old" off-axis histogram table column names
#  (from during PROS 2.2.2development)
define	BAL_COL_OLD	"bal"
define	BFRAC_COL_OLD	"bfrac"

#
#  DS_GETBAL -- read bal histo information from the bal histogram table file
#
procedure ds_getbal(ds)

pointer	ds				# i: sdf record

pointer	bal_table			# l: BAL table file name
pointer tp				# l: BAL table pointer
pointer	cp				# l: column pointers
pointer	bh				# l: bal histo structure
int	i				# l: loop counter
bool	nullflag			# whether a value is undefined
pointer	tbtopn()
int	tbpsta()			# l: to get # rows in BAL table
int	ds_tbhgti()			# l: get int header param
real	ds_tbhgtr()			# l: get real header param

begin
	call calloc(bal_table, SZ_PATHNAME, TY_CHAR)
	call strcpy("", Memc[bal_table], SZ_PATHNAME)
	call rootname(Memc[DS_FILENAME(ds)], Memc[bal_table], EXT_BAL,
								SZ_PATHNAME)
	# open the BAL table
	tp = tbtopn(Memc[bal_table], READ_ONLY, 0)

	if (tp != NULL) {

	    # allocate space for the bal histo record
	    if( DS_BAL_HISTGRAM(ds) == NULL )
		call calloc(DS_BAL_HISTGRAM(ds), LEN_BH, TY_STRUCT)
	    bh = DS_BAL_HISTGRAM(ds)

	    BH_ENTRIES(bh) = tbpsta(tp, TBL_NROWS)

	    if (BH_ENTRIES(bh) != 0) {
		# bal header information
		BH_START_BAL(bh) = ds_tbhgtr(tp, "bal_lo")
		BH_END_BAL(bh) = ds_tbhgtr(tp, "bal_hi")
		BH_BAL_INC(bh) = ds_tbhgtr(tp, "bal_inc")
		BH_BAL_STEPS(bh) = ds_tbhgti(tp, "bal_steps")
		BH_BAL_EPS(bh) = ds_tbhgtr(tp, "bal_eps")
		BH_MEAN_BAL(bh) = ds_tbhgtr(tp, "bal_mean")
	
		# allocate space for the column pointers
		call calloc(cp, MAX_BAL_CP, TY_POINTER)

		# get pointers to the columns
		call tbcfnd(tp, BAL_COL, BAL_CP(cp), 1)
		if (BAL_CP(cp) == NULL) {
		    call tbcfnd(tp, BAL_COL_RDF, BAL_CP(cp), 1)
		    if (BAL_CP(cp) == NULL)
			call tbcfnd(tp, BAL_COL_OLD, BAL_CP(cp), 1)
		}
		call tbcfnd(tp, BFRAC_COL, BFRAC_CP(cp), 1)
		if (BFRAC_CP(cp) == NULL) {
		    call tbcfnd(tp, BFRAC_COL_RDF, BFRAC_CP(cp), 1)
		    if (BFRAC_CP(cp) == NULL)
			call tbcfnd(tp, BFRAC_COL_OLD, BFRAC_CP(cp), 1)
		}

		# now read in the non-zero fractions
		do i=1, BH_ENTRIES(bh){
		    call tbrgtr(tp, BAL_CP(cp), BH_BAL(bh,i), nullflag, 1, i)
		    call tbrgtr(tp, BFRAC_CP(cp), BH_PERCENT(bh,i), nullflag, 
									1, i)
		    BH_PERCENT(bh,i)=BH_PERCENT(bh,i)*100.0E0
		}
		call mfree(cp, TY_POINTER)

	    } else {	# no bals
		# we free the pointer, as this is the flag that there are bals
		call mfree(DS_BAL_HISTGRAM(ds), TY_STRUCT)
	    }
	    call tbtclo(tp)

	} else {	# no bal table
	    # we free the pointer, as this is the flag that there are bals
	    call mfree(DS_BAL_HISTGRAM(ds), TY_STRUCT)
	}
	call mfree(bal_table, TY_CHAR)
end

#		
#  DOS_GETBAL -- read bal histo information from the _obs.tab table header
#
procedure dos_getbal(tp, ds)

pointer tp					# i: table pointer
pointer	ds					# i: pointer to bal record

char	buf[SZ_LINE]				# l: temp name buffer
int	i					# l: loop counter
int	nbals					# l: number of bals
int	ds_tbhgti()				# l: get int header param
real	ds_tbhgtr()				# l: get real header param
pointer	bh					# l: bal histo structure

begin
	nbals = ds_tbhgti(tp, "nbals")

	# return if no bals
	# we free the pointer, as this is the flag that there are bals
	if( nbals ==0 ){
	    call mfree(DS_BAL_HISTGRAM(ds), TY_STRUCT)
	    return
	}

	# allocate space for the bal histo record
	if( DS_BAL_HISTGRAM(ds) == NULL )
	    call calloc(DS_BAL_HISTGRAM(ds), LEN_BH, TY_STRUCT)
	bh = DS_BAL_HISTGRAM(ds)

	# bal header information
	BH_ENTRIES(bh) = nbals
	BH_START_BAL(bh) = ds_tbhgtr(tp, "bal_lo")
	BH_END_BAL(bh) = ds_tbhgtr(tp, "bal_hi")
	BH_BAL_INC(bh) = ds_tbhgtr(tp, "bal_inc")
	BH_BAL_STEPS(bh) = ds_tbhgti(tp, "bal_steps")
	BH_BAL_EPS(bh) = ds_tbhgtr(tp, "bal_eps")
	BH_MEAN_BAL(bh) = ds_tbhgtr(tp, "bal_mean")

#JCC(9/17/97)-test xdemo/spectraldemo/bal_plot+fit for einstein-ipc 
#             make sure the parameter is "bal_1" instead of "bal_1 "
        #BH_BAL(bh, 1) = ds_tbhgtr(tp, "bal_1 ")#not
        #BH_BAL(bh, 1) = ds_tbhgtr(tp, "bal_1") #ok
        #BH_BAL(bh, 2) = ds_tbhgtr(tp, "bal_2")
        #BH_BAL(bh, 3) = ds_tbhgtr(tp, "bal_3")
        #BH_PERCENT(bh, 1) = ds_tbhgtr(tp, "bfrac_1")
        #BH_PERCENT(bh, 2) = ds_tbhgtr(tp, "bfrac_2")
        #BH_PERCENT(bh, 3) = ds_tbhgtr(tp, "bfrac_3")

	# now read the non-zero fractions from the header
	  do i=1, BH_ENTRIES(bh){
		#JCC(9/97) call sprintf(buf, SZ_LINE, "bal_%-2d") # "bal_1 "
		call sprintf(buf, SZ_LINE, "bal_%d")    # "bal_1"
		call pargi(i)
		BH_BAL(bh,i) = ds_tbhgtr(tp, buf)
		#JCC(9/97) call sprintf(buf, SZ_LINE, "bfrac_%-2d")
		call sprintf(buf, SZ_LINE, "bfrac_%d")
		call pargi(i)
		BH_PERCENT(bh,i) = ds_tbhgtr(tp, buf)
	  }
end


# define RDF off-axis histogram table column names (they may differ from ours)
define	OAR_COL_RDF	"OFF_AX_RAD"
define	FT_COL_RDF	"FRAC_TIME"

#
# DS_GETOAH -- read source (and, optionally, background) offaxis histogram(s) 
#               from auxiliary file(s)
#
procedure ds_getoah(ds)

pointer ds
#--

pointer	soh_table		# l: source OAH file spec
pointer	boh_table		# l: background OAH file spec
int	len			# l: length of observed spectral file name
pointer	stp			# l: source OAH table pointer
pointer	btp			# l: background OAH table pointer
pointer	scp			# l: source OAH column pointers
pointer	bcp			# l: background OAH column pointers
bool	nullflag		# whether a value is undefined
int	i			# loop parameter

int	strlen()
bool	streq()
pointer	tbtopn()
int	tbpsta()		# to get the number of rows in OAH table
real	ds_tbhgtr()

begin
	call calloc(soh_table, SZ_PATHNAME, TY_CHAR)
	call calloc(boh_table, SZ_PATHNAME, TY_CHAR)
	call strcpy("", Memc[soh_table], SZ_PATHNAME)
	call strcpy("", Memc[boh_table], SZ_PATHNAME)

	# get length of observed spectral file name
	len = strlen(Memc[DS_FILENAME(ds)])

	# check whether observed spectral file is direct from FITS (vs. PROS)
	if ((Memc[DS_FILENAME(ds) + len - 10] == '_') && 
	    (Memc[DS_FILENAME(ds) + len -  9] == 's') && 
	    (Memc[DS_FILENAME(ds) + len -  8] == 'p') && 
	    (IS_DIGIT(Memc[DS_FILENAME(ds) + len -  7])) && 
	    (IS_DIGIT(Memc[DS_FILENAME(ds) + len -  6])) && 
	    (IS_DIGIT(Memc[DS_FILENAME(ds) + len -  5])) && 
	    (streq(Memc[DS_FILENAME(ds) + len - 4], ".tab"))) {

	    # develop source OAH file name for the FITS case
	    call strcpy(Memc[DS_FILENAME(ds)], Memc[soh_table], SZ_PATHNAME)
	    Memc[soh_table + len - 9] = EOS
	    call strcat("oah", Memc[soh_table], SZ_PATHNAME)
	    call strcat(Memc[DS_FILENAME(ds) + len -  7], Memc[soh_table], 
								SZ_PATHNAME)
	    # there is no background OAH table
	    btp = NULL
	}
	else {
	    call rootname(Memc[DS_FILENAME(ds)], Memc[soh_table], EXT_SOH,
								SZ_PATHNAME)
	    call rootname(Memc[DS_FILENAME(ds)], Memc[boh_table], EXT_BOH,
								SZ_PATHNAME)
	    # open the background OAH table
	    btp = tbtopn(Memc[boh_table], READ_ONLY, 0)
	}
	# open the source OAH table
	stp = tbtopn(Memc[soh_table], READ_ONLY, 0)

	if (stp != NULL) {

	    DS_NOAH(ds) = tbpsta(stp, TBL_NROWS)    # (would be same from btp)

	    if ( DS_NOAH(ds) != 0 ) {

		#-----------
		# Source OAH
		#-----------

		# allocate space for the column pointers
		call calloc(scp, MAX_OAH_CP, TY_POINTER)

		# get pointer to the frac_time column
		call tbcfnd(stp, FT_COL, FT_CP(scp), 1)
		if (FT_CP(scp) == NULL)
		    call tbcfnd(stp, FT_COL_RDF, FT_CP(scp), 1)

		call malloc(DS_OAHPTR(ds), DS_NOAH(ds), TY_REAL)

		for ( i = 0;  i < DS_NOAH(ds);  i = i + 1 ) {
		    call tbrgtr(stp, FT_CP(scp), DS_OAH(ds,i), nullflag, 1, 
									i+1)
		}
		call mfree(scp, TY_POINTER)

		#---------------
		# Background OAH
		#---------------

		if (btp != NULL) {
		    # allocate space for the column pointers
		    call calloc(bcp, MAX_OAH_CP, TY_POINTER)

		    # get pointer to the frac_time column
		    call tbcfnd(btp, FT_COL, FT_CP(bcp), 1)
		    if (FT_CP(bcp) == NULL)
			call tbcfnd(btp, FT_COL_RDF, FT_CP(bcp), 1)

		    call malloc(DS_BK_OAHPTR(ds), DS_NOAH(ds), TY_REAL)

		    for ( i = 0;  i < DS_NOAH(ds);  i = i + 1 ) {
			call tbrgtr(btp, FT_CP(bcp), DS_BK_OAH(ds,i), 
							nullflag, 1, i+1)
		    }
		    call mfree(bcp, TY_POINTER)
		    call tbtclo(btp)
		}
	    }
	    DS_MEAN_EVENT_OFFAXIS_ANGLE(ds) = ds_tbhgtr(stp, "offaxisa")
	    call tbtclo(stp)
	}
	call mfree(soh_table, TY_CHAR)
	call mfree(boh_table, TY_CHAR)
end

#
# DOS_GETOAH -- read an offaxis histogram from the _obs.tab table header
#
procedure dos_getoah(tp, ds)
pointer	tp
pointer ds
#--

int	i, j, junk
int	pspcel
char	line[SZ_LINE]
char	name[SZ_LINE]

int	ds_tbhgti()				# l: get int header param
int	ds_tbhgtt()				# l: get string header param

begin
	DS_NOAH(ds) = ds_tbhgti(tp, "PSPCNOH")

	if ( DS_NOAH(ds) == 0 ) return;

	call malloc(DS_OAHPTR(ds), DS_NOAH(ds), TY_REAL)
	call malloc(DS_BK_OAHPTR(ds), DS_NOAH(ds), TY_REAL)

	pspcel = ds_tbhgti(tp, "PSPCELEM")

	#-----------
	# Source OAH
	#-----------
	i = 0
	while ( i < DS_NOAH(ds) ) {
		call sprintf(name, SZ_LINE, "PSPCOH%d")
		 call pargi(( i / pspcel ) + 1)

		junk = ds_tbhgtt(tp, name, line, SZ_LINE)

		call sscan(line)
		for ( j = 0; i < DS_NOAH(ds) && j < pspcel; j = j + 1 ) {
			call gargr(DS_OAH(ds, i))
			i = i + 1
		}
	}

	#---------------
	# background OAH
	#---------------
	i = 0
	while ( i < DS_NOAH(ds) ) {
		call sprintf(name, SZ_LINE, "BACKOH%d")
		 call pargi(( i / pspcel ) + 1)

		junk = ds_tbhgtt(tp, name, line, SZ_LINE)

		call sscan(line)
		for ( j = 0; i < DS_NOAH(ds) && j < pspcel; j = j + 1 ) {
			call gargr(DS_BK_OAH(ds, i))
			i = i + 1
		}
	}

end

#
# DS_GETSPEC -- fill data set record with spectra and errors
#
procedure ds_getspec(tp, cp, ds)

pointer tp			# i: table pointer
pointer	cp			# i: column pointers
pointer	ds			# i: pointer to sdf record
bool	nullflag		# l: flag that a value is NULL
int	i			# l: temp index
int	nphas			# l: number of pha channels

begin
	# get number of pha channels
	nphas = DS_NPHAS(ds)
	# allocate space for the input spectra
	call ds_alloc(ds, nphas)
	# loop through the four columns
	do i=1, nphas{
	    if( EN1_CP(cp) != NULL )
		call tbrgtr(tp, EN1_CP(cp), Memr[DS_LO_ENERGY(ds)+i-1],
			nullflag, 1, i)
	    if( EN2_CP(cp) != NULL )
		call tbrgtr(tp, EN2_CP(cp), Memr[DS_HI_ENERGY(ds)+i-1],
			nullflag, 1, i)
	    if( SOURCE_CP(cp) != NULL )
		call tbrgtr(tp, SOURCE_CP(cp), Memr[DS_SOURCE(ds)+i-1],
			nullflag, 1, i)
	    if( BKGD_CP(cp) != NULL )
		call tbrgtr(tp, BKGD_CP(cp), Memr[DS_BKGD(ds)+i-1],
			nullflag, 1, i)
	    if( NET_CP(cp) != NULL )
		call tbrgtr(tp, NET_CP(cp), Memr[DS_OBS_DATA(ds)+i-1],
			nullflag, 1, i)
	    if( ERR_CP(cp) != NULL )
		call tbrgtr(tp, ERR_CP(cp), Memr[DS_OBS_ERROR(ds)+i-1],
			nullflag, 1, i)
	}
end

#
#  DS_ALLOC -- allocate space for secondary spectral records
#
procedure ds_alloc(ds, nphas)

pointer	ds				# i/o: data set pointer
int	nphas				# i: number of pha channels

begin

	# allocate ds, if necessary
	if( ds == NULL )
	    call calloc(ds, LEN_DS, TY_STRUCT)
	# allocate input spectra and errors
	if( DS_SOURCE(ds) == NULL )
	    call calloc(DS_SOURCE(ds), nphas, TY_REAL)
	if( DS_BKGD(ds) == NULL )
	    call calloc(DS_BKGD(ds), nphas, TY_REAL)
	if( DS_OBS_DATA(ds) == NULL )
	    call calloc(DS_OBS_DATA(ds), nphas, TY_REAL)
	if( DS_OBS_ERROR(ds) == NULL )
	    call calloc(DS_OBS_ERROR(ds), nphas, TY_REAL)
	# allocate predicted spectrum
	if( DS_PRED_DATA(ds) == NULL )
	    call calloc(DS_PRED_DATA(ds), nphas, TY_REAL)
	# allocate chi-square contributions
	if( DS_CHISQ_CONTRIB(ds) == NULL )
	    call calloc(DS_CHISQ_CONTRIB(ds), nphas, TY_REAL)
	# allocate channels to fit
	if( DS_CHANNEL_FIT(ds) == NULL )
	    call calloc(DS_CHANNEL_FIT(ds), nphas, TY_INT)
	# allocate space for the bal histo record
	if( DS_BAL_HISTGRAM(ds) == NULL )
	    call calloc(DS_BAL_HISTGRAM(ds), LEN_BH, TY_STRUCT)
	# allocate space for the low energy bounds array
	if( DS_LO_ENERGY(ds) == NULL )
	    call calloc(DS_LO_ENERGY(ds), nphas, TY_REAL)
	# allocate space for the hi energy bounds array
	if( DS_HI_ENERGY(ds) == NULL )
	    call calloc(DS_HI_ENERGY(ds), nphas, TY_REAL)
end

#
#  DS_TBHGTT -- get table param if it exists, else return 0
#		string version
#
int procedure ds_tbhgtt(tp, keyword, value, len)

pointer tp					# i: table pointer
char	keyword[ARB]				# i: parameter name
char	value[ARB]				# o: param value
int	len					# i: len of output buffer
int	parnum					# l: parameter number

begin
	# check for existence of parameter
	call tbhfkw(tp, keyword, parnum)
	# if parnum ==0, param does not exist
	if( parnum ==0 )
	    return(0)
	# else get param value
	else{
	    call tbhgtt(tp, keyword, value, len)
	    return(1)
	}
end

#
#  DS_TBHGTI -- get table param if it exists, else return 0
#		int version
#
int procedure ds_tbhgti(tp, keyword)

pointer tp					# i: table pointer
char	keyword[ARB]				# i: parameter name
int	parnum					# l: parameter number
int	tbhgti()				# l: get param value

begin
	# check for existence of parameter
	call tbhfkw(tp, keyword, parnum)
	# if parnum ==0, param does not exist
	if( parnum ==0 )
	    return(0)
	# else get param value
	else
	    return(tbhgti(tp, keyword))
end

#
#  DS_TBHGTR -- get table param if it exists, else return 0
#		real version
#
real procedure ds_tbhgtr(tp, keyword)

pointer tp					# i: table pointer
char	keyword[ARB]				# i: parameter name
int	parnum					# l: parameter number
real	tbhgtr()				# l: get param value

begin
	# check for existence of parameter
	call tbhfkw(tp, keyword, parnum)
	# if parnum ==0, param does not exist
	if( parnum ==0 )
	    return(0.0)
	# else get param value
	else
	    return(tbhgtr(tp, keyword))
end

#
# DS_APPEND -- open a prd table file for appending
#
procedure ds_append(ds, iname, oname, chisq, comp_chi,
			absty, imodel, best, omodel, fit, len, n)

pointer	ds			# i: data set pointer
char	iname[ARB]		# i: input name
char	oname[ARB]		# i: output name
real	chisq			# i: chisquare value
real	comp_chi		# i: component chisquare
int	absty			# i: absorption type
char	imodel[ARB]		# i: input model string
char	best[ARB]		# i: best values model string
char	omodel[ARB]		# i: model string for output use
char	fit[ARB]		# i: fit type
int	len			# l: length of files param
int	n			# o: prd number in file

pointer	template		# l: template file tp
pointer tp			# l: new file tp
pointer	cp			# l: column pointers

pointer	sp			# l: stack pointer
int	parnum			# l: table header parameter number
pointer	dtmat_fname		# l: response matrix file name

int	tbtopn()		# l: open a table

begin
	# mark the top of the stack
	call smark(sp)

	# initialize and open the template table.
	template = tbtopn (iname, READ_ONLY, 0)

	# initialize a new table using template.
#	tp = tbtopn (oname, NEW_COPY, template)
	tp = tbtopn (oname, NEW_FILE, 0)

	# create standard PROS column names for as many columns as in template
	call ds_coppre(template, tp)

	# create a new predicted column
	# must come before tbtcre!
	call ds_newpre(template, tp, cp, n)

	# create the new table file
	call tbtcre (tp)

	# copy all header parameters from old to new
	call tbhcal(template, tp)

	# if there's no parameter identifying response matrix file, add one
	call tbhfkw(tp, "respfile", parnum)
	if (parnum == 0) {
	    call salloc(dtmat_fname, SZ_FNAME, TY_CHAR)
	    call get_respfile(ds, Memc[dtmat_fname])
	    call tbhadt(tp, "respfile", Memc[dtmat_fname])
	}

	# write params for new predicted col into table file
	# must come after tbtcre (and tbhcal)!
	call ds_newprepar(template, tp, chisq, comp_chi,
			  absty, imodel, best, omodel, fit, len)

	# copy the cols we know about
	call ds_copy_col(EN1_COL, template, tp, ds)
	call ds_copy_col(EN2_COL, template, tp, ds)
#	call ds_copy_col(SOURCE_COL, template, tp, ds)
#	call ds_copy_col(BKGD_COL, template, tp, ds)
	call ds_copy_col(NET_COL, template, tp, ds)
	call ds_copy_col(ERR_COL, template, tp, ds)

	# append the existing predicted data tables
	call ds_apppre(template, tp, ds)

	# write the new predicted data column
	call ds_putpre(ds, tp, cp)

	# close the template table
	call tbtclo (template)

	# close the output table
	call tbtclo (tp)

	# free up the column pointers
	call mfree(cp, TY_INT)

	# restore the stack pointer
	call sfree(sp)
end

#
# DS_COPPRE -- create column names from template
#
procedure ds_coppre(template, tp)

pointer	template		# i: template pointer
pointer tp			# i: table pointer

char	buf[SZ_LINE]		# l: temp char buf
int	icp			# l: temp column pointer
int	i			# l: loop counter
int	n			# l: number of predicted columns
int	ds_tbhgti()		# l: get header keyword

begin
	# define essential columns in new file that exist in old
	call tbcdef(tp, icp,  EN1_COL, EN1_UNITS, "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, icp,  EN2_COL, EN2_UNITS, "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, icp,  NET_COL, NET_UNITS, "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, icp,  ERR_COL, ERR_UNITS, "%9.2f", TY_REAL, 1, 1)

	# get the number of predicted columns
	n = ds_tbhgti(template, "npred")
	# create all predicted data and chi-square columns
	do i=1, n{
	    # create the name of the predicted column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(PRED_COL)
	    call pargi(i)
	    call tbcdef(tp, icp,  buf, "", "%9.2f", TY_REAL, 1, 1)

	    # create the name of the chi-square column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(CHI_COL)
	    call pargi(i)
	    call tbcdef(tp, icp,  buf, "", "%9.2f", TY_REAL, 1, 1)

	    # create the name of the channels to fit column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(CHAN_COL)
	    call pargi(i)
	    call tbcdef(tp, icp,  buf, "", "%-1s", -1, 1, 1)
	}
end

#
# DS_NEWPRE -- create a new column of predicted data
#
procedure  ds_newpre(template, tp, cp, n)

pointer	template		# i: template table pointer
pointer tp			# i: table pointer
pointer	cp			# o: column pointers
int	n			# o: number of predicted columns

char	name[SZ_LINE]		# l: predicted data
int	ds_tbhgti()		# l: get header keyword

begin
	# allocate space for the column pointers
	if( cp ==0 )
	    call calloc(cp, MAX_SPEC_CP, TY_POINTER)
	# get the number of predicted columns
	n = ds_tbhgti(template, "npred")
	# increment the number of columns
	n = n+1
	if ( n == 99 ) {
	   call eprintf("\nDSLIB: WARNING you have written 99 fits to this _prd.tab.\n")
	   call eprintf("If you run fit again with predicted=append you will overwrite\n")
	   call eprintf("previous models in this _prd.tab.\n")
	}

	# create the name of the newest predicted data column
	call sprintf(name, SZ_LINE, "%s_%d")
	call pargstr(PRED_COL)
	call pargi(n)
	# create the column
	call tbcdef(tp, PRED_CP(cp),  name, "", "%9.2f", TY_REAL, 1, 1)

	# create the name of the newest chi-square column
	call sprintf(name, SZ_LINE, "%s_%d")
	call pargstr(CHI_COL)
	call pargi(n)
	# create the column
	call tbcdef(tp, CHI_CP(cp),  name, "", "%9.2f", TY_REAL, 1, 1)

	# create the name of the newest channels to fit column
	call sprintf(name, SZ_LINE, "%s_%d")
	call pargstr(CHAN_COL)
	call pargi(n)
	# create the column
	call tbcdef(tp, CHAN_CP(cp),  name, "", "%-1s", -1, 1, 1)
end

define	MPC_RESPONSE		"mpc_response_datafile"
#
# GET_RESPFILE -- return name of response matrix file used for a data set
#
procedure get_respfile(ds, dtmat_fname)

pointer	ds			# i: pointer to spectral data set
char	dtmat_fname[ARB]	# o: name of response matrix file

begin
	switch ( DS_INSTRUMENT(ds) )  {
	    case EINSTEIN_IPC:
		call strcpy("Cf. BAL parameters", dtmat_fname, SZ_FNAME)
	    case EINSTEIN_MPC:
		call clgstr(MPC_RESPONSE, dtmat_fname, SZ_FNAME)
	    case EINSTEIN_HRI:
		call strcpy("No spectral response available", dtmat_fname, 
						SZ_FNAME)
	    case ROSAT_PSPC:
		call clgstr(ROS_DTMAT, dtmat_fname, SZ_FNAME)
	    case ROSAT_HRI:
		call clgstr(ROS_HRI_DTMAT, dtmat_fname, SZ_FNAME)
	    case SRG_HEPC1:
		call clgstr(SRG_H1_DTMAT, dtmat_fname, SZ_FNAME)
	    case SRG_LEPC1:
		call clgstr(SRG_L1_DTMAT, dtmat_fname, SZ_FNAME)
	    default:
		call clgstr(DEF_DTMAT, dtmat_fname, SZ_FNAME)
	}
end

#
# DS_NEWPREPAR -- write new predicted column params info into table
#
procedure  ds_newprepar(template, tp, chisq, comp_chi,
			absty, imodel, best, omodel, fit, len)

pointer	template		# i: template table pointer
pointer tp			# i: table pointer
real	chisq			# i: chisquare value
real	comp_chi		# i: component chisquare
int	absty			# i: absorption type
char	imodel[ARB]		# i: input model string
char	best[ARB]		# i: best values model string
char	omodel[ARB]		# i: model string for output use
char	fit[ARB]		# i: fit type
int	len			# i: length of files param

char	buf[SZ_LINE]		# l: temp char buf
int	n			# l: number of predicted columns
int	ds_tbhgti()		# l: get header keyword
pointer	dummy			# l: pointer to dummy string
pointer	sp			# l: stack pointer

begin
	# mark the stack
	call smark(sp)
	# get the number of predicted columns
	n = ds_tbhgti(template, "npred")
	# increment the number of columns
	n = n+1
	# set apart the fit results
	call tbhadt(tp, "fit_res", "The following parameters are fitting results:")
	# update the number of predicted columns	
	call tbhadi(tp, "npred", n)
	# update the "current" column param
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr(PRED_COL)
	call pargi(n)
	call tbhadt(tp, "pred_col", buf)
	# write the fit type
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("fit")
	call pargi(n)
	call tbhadt(tp, buf, fit)
	# write the absorption string
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("abs")
	call pargi(n)
	switch(absty){
	case MORRISON_MCCAMMON:
	    call tbhadt(tp, buf, "morrison_maccammon")
	case BROWN_GOULD:
	    call tbhadt(tp, buf, "brown_gould")
	default:
	    call tbhadt(tp, buf, "unknown")
	}
	# write the chisquare value
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("chisq")
	call pargi(n)
	call tbhadr(tp, buf, comp_chi)
	# write the chisquare value
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("t_chi")
	call pargi(n)
	call tbhadr(tp, buf, chisq)

	# write the best fit model string
	call ds_pmultstr(tp, "best", n, best)
	# write the imodel model string
	call ds_pmultstr(tp, "imod", n, imodel)
	# write the omodel model string
	call ds_pmultstr(tp, "omod", n, omodel)

	# write the files contributing to chisquare
	# this is a dummy place holder, to be filled in later
	# allocate space for the dummy par
	call salloc(dummy, len, TY_CHAR)
	# fill with dummy value
	call amovc("*", Memc[dummy], len)
	# save space for ifiles param
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("ifile")
	call pargi(n)
	call tbhadt(tp, buf, Memc[dummy])
	# save space for ofiles param
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr("ofile")
	call pargi(n)
	call tbhadt(tp, buf, Memc[dummy])
	call tbhadt(tp, "COMMENT", " ")
	# free up stack space
	call sfree(sp)
end

#
# DS_COPY_COL -- copy a column from one table to another
#
procedure ds_copy_col(name, template, tp, ds)

char	name[ARB]		# i: output column name
pointer	template		# i: template file tp
pointer tp			# i: new file tp
pointer	ds			# i: dataset pointer

int	nrows			# l: number of rows to copy
pointer	buf			# l: buffer for row data
pointer	nullflag		# l: nullflags
pointer	icp			# l: input column pointer
pointer	ocp			# l: output column pointer
pointer	sp			# l: stack pointer
int	tbpsta()		# l: get info from table
bool	streq()

begin

	#-------------------------------------------------------------------
	# if template column ("name" or alternative) is missing, just return
	#-------------------------------------------------------------------
	call tbcfnd (template, name, icp, 1)
	if (icp == NULL) {
	    if (streq(name, EN1_COL)) {
		call tbcfnd (template, EN1_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, EN1_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else if (streq(name, EN2_COL)) {
		call tbcfnd (template, EN2_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, EN2_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else if (streq(name, SOURCE_COL)) {
		call tbcfnd (template, SOURCE_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, SOURCE_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else if (streq(name, BKGD_COL)) {
		call tbcfnd (template, BKGD_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, BKGD_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else if (streq(name, NET_COL)) {
		call tbcfnd (template, NET_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, NET_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else if (streq(name, ERR_COL)) {
		call tbcfnd (template, ERR_COL_RDF, icp, 1)
		if (icp == NULL) {
		    call tbcfnd (template, ERR_COL_OLD, icp, 1)
		    if (icp == NULL)
			return
		}
	    } else
		return
	}

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#-----------------------------
	# get colptr for output column
	#-----------------------------
	call tbcfnd (tp, name, ocp, 1)

	if (ocp == NULL) {
	    call eprintf ("DSLIB: Warning column not found in output table.\n")
	}

	#---------------------------
	# how many rows in template?
	#---------------------------
	nrows = tbpsta (template, TBL_NROWS)

	#--------------------------------------------------------------
	# if the dataset has been rebined use that and not the obs file
	#--------------------------------------------------------------
	if ( nrows > DS_NPHAS(ds) ) {

	    nrows = DS_NPHAS(ds)
	    call salloc(buf, nrows, TY_DOUBLE)

	    if ( streq(name, EN1_COL) ) {
		Memd[buf] = double(Memr[DS_LO_ENERGY(ds)])
	    }
	    else if ( streq(name, EN2_COL) ) {
		Memd[buf] = double(Memr[DS_HI_ENERGY(ds)])
	    }
	    else if ( streq(name, SOURCE_COL) ) {
		Memd[buf] = double(Memr[DS_SOURCE(ds)])
	    }
	    else if ( streq(name, BKGD_COL) ) {
		Memd[buf] = double(Memr[DS_BKGD(ds)])
	    }
	    else if ( streq(name, NET_COL) ) {
		Memd[buf] = double(Memr[DS_OBS_DATA(ds)])
	    }
	    else if ( streq(name, ERR_COL) ) {
		Memd[buf] = double(Memr[DS_OBS_ERROR(ds)])
	    }
	    else if ( streq(name, PRED_COL) ) {
		Memd[buf] = double(Memr[DS_PRED_DATA(ds)])
	    }
	    else if ( streq(name, CHI_COL) ) {
		Memd[buf] = double(Memr[DS_CHISQ_CONTRIB(ds)])
	    }
	    else {
		#-----------
		# do nothing
		#-----------
	    }
	}
	else {

	    #--------------------------------------------------
	    # allocate space for the data and nullflag
	    # make the buf size nrows * largest sized data type
	    #--------------------------------------------------
	    call salloc(buf, nrows, TY_DOUBLE)
	    call salloc(nullflag, nrows, TY_INT)

	    #-------------------------------
	    # Copy template column to output
	    #-------------------------------
	    call tbcgtd (template, icp, Memd[buf], Memi[nullflag], 1, nrows)
	}


	call tbcptd (tp, ocp, Memd[buf], 1, nrows)

	#--------------------
	# free up stack space
	#--------------------
	call sfree(sp)

end

#
#  DS_COPY_COL_STR - copy a string column from one table to another
#

procedure ds_copy_col_str(name, template, tp, ds)

char	name[ARB]		# i: column name
pointer	template		# i: template file tp
pointer tp			# i: new file tp
pointer	ds			# i: dataset pointer

int	nrows			# l: number of rows to copy
char	buf[SZ_LINE]		# l: buffer for row data
pointer	nullflag		# l: nullflags
pointer	icp			# l: input column pointer
pointer	ocp			# l: output column pointer
pointer	sp			# l: stack pointer
int	tbpsta()		# l: get info from table

begin

	#-------------------------------------------
	# if template column is missing, just return
	#-------------------------------------------
	call tbcfnd (template, name, icp, 1)

	if (icp == NULL) {
	    return
	}

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#-----------------------------
	# get colptr for output column
	#-----------------------------
	call tbcfnd (tp, name, ocp, 1)

	if (ocp == NULL) {
	    call eprintf ("DSLIB: Warning column not found in output table.\n")
	}

	#---------------------------
	# how many rows in template?
	#---------------------------
	nrows = tbpsta (template, TBL_NROWS)

	#--------------------------------------------------------------
	# if the dataset has been rebined use that and not the obs file
	#--------------------------------------------------------------
	if ( nrows > DS_NPHAS(ds) ) {
	    nrows = DS_NPHAS(ds)
	}

	#--------------------------------------------------
	# allocate space for the data and nullflag
	# make the buf size nrows * largest sized data type
	#--------------------------------------------------
	call salloc(buf, nrows, TY_DOUBLE)
	call salloc(nullflag, nrows, TY_INT)

	#-------------------------------
	# Copy template column to output
	#-------------------------------
	call tbcgtt (template, icp, buf, Memi[nullflag], 1, 1, nrows)
	call tbcptt (tp, ocp, buf, 1, 1, nrows)

	#--------------------
	# free up stack space
	#--------------------
	call sfree(sp)

end

#
# DS_APPPRE -- append existing predicted data columns
#
procedure  ds_apppre(template, tp, ds)

pointer	template		# i: template pointer
pointer tp			# i: new table pointer
pointer	ds			# i: dataset pointer

char	buf[SZ_LINE]		# l: temp char buf
int	i			# l: loop counter
int	n			# l: number of predicted columns
int	ds_tbhgti()		# l: get header keyword

begin
	# get the number of predicted columns
	n = ds_tbhgti(template, "npred")
	# copy all predicted data and chi-square columns
	do i=1, n{
	    # create the name of the newest predicted column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(PRED_COL)
	    call pargi(i)
	    # copy the column
	    call ds_copy_col(buf, template, tp, ds)

	    # create the name of the newest chi-square column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(CHI_COL)
	    call pargi(i)
	    # copy the column
	    call ds_copy_col(buf, template, tp, ds)

	    # create the name of the newest channels to fit column
	    call sprintf(buf, SZ_LINE, "%s_%d")
	    call pargstr(CHAN_COL)
	    call pargi(i)
	    # copy the column
	    call ds_copy_col_str(buf, template, tp, ds)
	}
end

#
# DS_PUTPRE -- fill predicted and chi-square columns
#
procedure ds_putpre(ds, tp, cp)

pointer	ds			# i: pointer to sdf record
pointer tp			# i: table pointer
pointer	cp			# i: column pointers
int	i			# l: temp index

begin
	# fill the predicted data column
	do i=1, DS_NPHAS(ds){
	    if ( DS_PRED_DATA(ds) != NULL )
		call tbrptr(tp, PRED_CP(cp), Memr[DS_PRED_DATA(ds)+i-1], 1, i)

	    if ( DS_CHISQ_CONTRIB(ds) != NULL )
		call tbrptr(tp, CHI_CP(cp), Memr[DS_CHISQ_CONTRIB(ds)+i-1],1,i)

	    if ( DS_CHANNEL_FIT(ds) != NULL ) {
		# convert to a char string for table
		if ( Memi[DS_CHANNEL_FIT(ds)+i-1] == 0 ) {
		    # put a space
		    call tbrptt(tp, CHAN_CP(cp), SPACE, 1, 1, i)
		}
		else {
		    # if used in fit put a star
		    call tbrptt(tp, CHAN_CP(cp), STAR, 1, 1, i)
		}
	    }
	}
end

#
# DS_OPENPRE -- "open" a predicted data column (default is current)
#

procedure  ds_openpre(table, tp, cp, npre)

char	table[ARB]		# i: table name
pointer tp			# o: table pointer
pointer	cp			# o: column pointers
int	npre			# i: column number to open

char	buf[SZ_LINE]		# l: temp char buf
int	ds_tbhgti()		# l: get header keyword
pointer tbtopn()		# l: table open routine
int	n			# l: number of predicted columns
begin
	# allocate space for the column pointers
	if( cp ==0 )
	    call calloc(cp, MAX_SPEC_CP, TY_POINTER)
	# initialize and open the table
	tp = tbtopn (table, READ_ONLY, 0)

	# get the number of predicted columns
	if( npre==0 )
	    n = ds_tbhgti(tp, "npred")
	else
	    n = npre
	# if no predicted columns as yet, die
	if( n==0 )
	    call error(1, "DSLIB: no predicted data columns")

	# create the buf of the newest column
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr(PRED_COL)
	call pargi(n)
	# look for the column
	call tbcfnd(tp, buf, PRED_CP(cp), 1)
	# if we did not find it, die
	if( PRED_CP(cp) == NULL )
	    call errori(1, "DSLIB: missing predicted data column", n)

	# create the name of the newest chisq column
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr(CHI_COL)
	call pargi(n)
	# look for the column
	call tbcfnd(tp, buf, CHI_CP(cp), 1)
	# if we did not find it, die
	if( CHI_CP(cp) == NULL )
	    call errori(1, "DSLIB: missing chi-sq contribution column", n)

	# create the name of the newest channels fit column
	call sprintf(buf, SZ_LINE, "%s_%d")
	call pargstr(CHAN_COL)
	call pargi(n)
	# look for the column
	call tbcfnd(tp, buf, CHAN_CP(cp), 1)
	# if we did not find it, die
	if( CHAN_CP(cp) == NULL )
	    call errori(1, "DSLIB: missing channels fit column", n)
end

#
# DS_GETPRE -- fill data set record with predicted data
#

procedure ds_getpre(tp, cp, ds)

pointer tp			# i: table pointer
pointer	cp			# i: column pointers
pointer	ds			# i: pointer to sdf record
bool	nullflag		# l: flag that a value is NULL
int	i			# l: temp index
int	nphas			# l: number of pha channels
char	strbuf[SZ_LINE]
bool	streq()

begin
	# get number of pha channels
	nphas = DS_NPHAS(ds)

	# allocate space for the input spectra
	call ds_alloc(ds, nphas)
	# get predicted data and chi-square contributions
	do i = 1, nphas {

	    if ( PRED_CP(cp) != NULL )
		call tbrgtr(tp, PRED_CP(cp), Memr[DS_PRED_DATA(ds)+i-1],
			nullflag, 1, i)

	    if ( CHI_CP(cp) != NULL )
		call tbrgtr(tp, CHI_CP(cp), Memr[DS_CHISQ_CONTRIB(ds)+i-1],
			nullflag, 1, i)

	    if ( CHAN_CP(cp) != NULL ) {
		call tbrgtt(tp, CHAN_CP(cp), strbuf, nullflag, 1, 1, i)

		# convert back to a real channel flag
		if ( streq(strbuf, SPACE) )
		    Memi[DS_CHANNEL_FIT(ds)+i-1] = 0
		else
		    Memi[DS_CHANNEL_FIT(ds)+i-1] = -1
	    }
	}
end

#
# DS_CHISQUARE -- write into the chisquare data base
#
procedure ds_chisquare(fp, chiname, chisq, chibuf, clen, best, mlen)

int	fp				# i: frame pointer
char	chiname[ARB]			# i: data base name
real	chisq				# i: chi-square value
char	chibuf[ARB]			# i: prd files with chi contributions
int	clen				# i: length of chibuf
char	best[ARB]			# i: model string
int	mlen				# i: size of model string

int	nrows				# l: number of rows in the table
int	tp				# l: table pointer
int	cp[6]				# l: column pointers
int	chans				# l: number of valid channels
int	free				# l: number of free params
char	datebuf[SZ_TIME]		# l: date string

int	tbtopn()			# l: open a table
int	tbtacc()			# l: check for table file existence
int	tbpsta()			# l: table status
int	ct_params()			# l: count number of params
int	ct_chans()			# l: count number of valid channels
long	clktime()			# l: get clock time

begin
	# get current time for time stamp
	call cnvtime(clktime(0), datebuf, SZ_TIME)
	# create a new table file, if necessary
	if( tbtacc(chiname) == NO ){
	    # open a new table	
	    tp = tbtopn(chiname, NEW_FILE, 0)
	    # and define columns
	    call tbcdef(tp, cp[1],  "date", "", "", -SZ_TIME, 1, 1)
	    call tbcdef(tp, cp[2],  "chisq", "", "%9.2f", TY_REAL, 1, 1)
	    call tbcdef(tp, cp[3],  "chans", "", "%4d", TY_INT, 1, 1)
	    call tbcdef(tp, cp[4],  "free", "", "%4d", TY_INT, 1, 1)
	    call tbcdef(tp, cp[5],  "files", "", "", -clen, 1, 1)
	    call tbcdef(tp, cp[6],  "model", "", "", -mlen, 1, 1)
	    # create the table
	    call tbtcre(tp)
	    # write into first row
	    nrows = 1
	}
	else{
	    # initialize and open the table
	    tp = tbtopn (chiname, READ_WRITE, 0)
	    # look for each column
	    call tbcfnd(tp, "date", cp[1], 1)
	    if( cp[1] == NULL )
		call error(1, "DSLIB: missing 'date' column")
	    call tbcfnd(tp, "chisq", cp[2], 1)
	    if( cp[2] == NULL )
		call error(1, "DSLIB: missing 'chisq' column")
	    call tbcfnd(tp, "chans", cp[3], 1)
	    if( cp[3] == NULL )
		call error(1, "DSLIB: missing 'chans' column")
	    call tbcfnd(tp, "free", cp[4], 1)
	    if( cp[4] == NULL )
		call error(1, "DSLIB: missing 'free' column")
	    call tbcfnd(tp, "files", cp[5], 1)
	    if( cp[5] == NULL )
		call error(1, "DSLIB: missing 'files' column")
	    call tbcfnd(tp, "model", cp[6], 1)
	    if( cp[6] == NULL )
		call error(1, "DSLIB: missing 'model' column")
	    # get row number of new row
	    nrows = tbpsta(tp, TBL_NROWS) + 1
	}

	# write a new row of columns
	call tbrptt(tp, cp[1], datebuf, SZ_TIME, 1, nrows)
	call tbrptr(tp, cp[2], chisq, 1, nrows)
	chans = ct_chans(fp)
	call tbrpti(tp, cp[3], chans, 1, nrows)
	free = ct_params(fp, FREE_PARAM) + ct_params(fp, CALC_PARAM)
	call tbrpti(tp, cp[4], free, 1, nrows)
	call tbrptt(tp, cp[5], chibuf, clen, 1, nrows)
	call tbrptt(tp, cp[6], best, mlen, 1, nrows)

	# close the table
	call tbtclo(tp)
end

#
#  DS_PRDFILES -- add parameter telling output prd files
#
procedure ds_prdfiles(table, chibuf)

char	table[ARB]			# i: table name
char	chibuf[ARB]			# i: prd files with chi contributions

char	buf[SZ_LINE]			# l: temp char buf
int	tp				# l: table pointer
int	n				# l: number of predicted
int	prd				# l: flag this is prd
int	tbtopn()			# l: open a table file
int	ds_tbhgti()			# l: get header keyword

begin
	prd = YES
	goto 99

entry ds_obsfiles(table, chibuf)
	prd = NO
	goto 99


	# initialize and open the table
99      tp = tbtopn (table, READ_WRITE, 0)
	# get the number of predicted columns
	n = ds_tbhgti(tp, "npred")
	# make up the param name
	call sprintf(buf, SZ_LINE, "%s_%d")
	if( prd == YES )
	    call pargstr("ofile")
	else
	    call pargstr("ifile")
	call pargi(n)
	call tbhadt(tp, buf, chibuf)
	# close the table
	call tbtclo(tp)
end

#
#  DS_GMODSTR -- get a "current" string param from prd file
#
procedure ds_gmodstr(ds, pname, pval, len)

int	ds				# i: data set pointer
char	pname[ARB]			# i: param name
char	pval[ARB]			# o: param value
int	len				# i: length of param value string

char	prdname[SZ_PATHNAME]		# l: prd file name
int	tp				# l: table handle
int	n				# l: number of predicted
pointer	obsname				# l: obs file name

int	ds_tbhgti()			# l: get header keyword
int	tbtacc()			# l: table file existence
pointer	tbtopn()			# l: table open routine

begin
	# get name of first input file
	obsname = DS_FILENAME(ds)
	# get predicted file name from observed
	call get_prdname(Memc[obsname], prdname, SZ_PATHNAME)
	# if the prd file exists ...
	if( tbtacc(prdname) == YES ){
	    # open the prd file
	    tp = tbtopn (prdname, READ_ONLY, 0)
	    # get the number of predicted columns
	    n = ds_tbhgti(tp, "npred")
	    # get a (possibly) multi-line string
	    call ds_gmultstr(tp, pname, n, pval, len)
	    # close the table
	    call tbtclo(tp)
	}
	# return a null string
	else{
#	    call eprintf("\nDSLIB: warning: %s does not exist; can't get %s param\n")
#	    call pargstr(prdname)
#	    call pargstr(pname)
	    pval[1] = EOS
	}
end

#
#  DS_GMODR -- get a "current" real param from prd file.  John : Jan 90
#
real procedure ds_getmr(ds, pname)

int	ds				# i: data set pointer
char	pname[ARB]			# i: param name
#--

char	prdname[SZ_PATHNAME]		# l: prd file name
char	buf[SZ_LINE]			# l: temp char buf
int	tp				# l: table handle
int	n				# l: number of predicted
pointer	obsname				# l: obs file name
real	pval

int	ds_tbhgti()			# l: get header keyword
int	tbtacc()			# l: table file existence
pointer	tbtopn()			# l: table open routine
real	tbhgtr()

begin

	obsname = DS_FILENAME(ds)		# get file name

	# get predicted file name from observed
	#
	call get_prdname(Memc[obsname], prdname, SZ_PATHNAME)

	if( tbtacc(prdname) == YES ){			# Prd file exists?
	    tp = tbtopn (prdname, READ_ONLY, 0)	    	# open the prd file

	    n = ds_tbhgti(tp, "npred")		    # get the # of columns
	    call sprintf(buf, SZ_LINE, "%s_%d")	    # make up the model pname
	     call pargstr(pname)
	     call pargi(n)
	    pval = tbhgtr(tp, buf)		# get the output model param
	    call tbtclo(tp)			# close the tablep

	} else {				# return a Zero
#	    call eprintf("\nDSLIB: warning: %s does not exist; can't get %s param\n")
#	    call pargstr(prdname)
#	    call pargstr(pname)
	    pval = 0
	}

	return pval
end

#
# DS_GMULTSTR -- get a (possibly) multi-line string parameter
#
procedure ds_gmultstr(tp, pname, n, pval, len)

pointer	tp						# i: table pointer
char	pname[ARB]					# i: param name
int	n						# i: param number
char	pval[ARB]					# o: param value
int	len						# i: length of value

int	i						# l: counter
char	tname[SZ_LINE]					# l: temp name buffer
char	tval[SZ_LINE]					# l: temp value buffer
int	ds_tbhgtt()					# l: get string param

begin 
	# make up the base output model param name
	call sprintf(tname, SZ_LINE, "%s_%d")
	call pargstr(pname)
	call pargi(n)

	# get the base output model param
	iferr (	call tbhgtt(tp, tname, pval, len) ) {
	    call ds_rename(tp, pname, n, pval, len)
	}

	# check for multi-lines
	i = 0
	while( true ){
	    # create the next multi-name
	    call ds_multname(pname, n, i, tname, SZ_LINE)
	    # if the param exists ... get it and ...
	    if( ds_tbhgtt(tp, tname, tval, SZ_LINE) == YES ){
		# ... concat it to output string
		call strcat(tval, pval, len)
		# inc the multi-counter
		i = i+1
	    }
	    else
		break
	}
end

# define max size of a param string (tbset.h sets the SZ_PARREC, etc.)
# we break multi-lines up into strings of this length
define MAX_PARREC (SZ_PARREC - START_OF_VALUE)

#
#  DS_PMULTSTR -- put a (possibly) multi-line parameter
#
procedure ds_pmultstr(tp, pname, n, pval)

pointer	tp						# i: table pointer
char	pname[ARB]					# i: param name
int	n						# i: param number
char	pval[ARB]					# o: param value

int	i						# l: counter
int	got						# l: chars put so far
int	len						# l: length of string
char	tname[SZ_LINE]					# l: temp name buffer
char	tval[SZ_LINE]					# l: temp value buffer
int	strlen()					# l: string length

begin
	# get total length of string
	len = strlen(pval)
	# get first part of param to write as base
	call strcpy(pval, tval, MAX_PARREC)
	got = MAX_PARREC
	# write the base param value
	call sprintf(tname, SZ_LINE, "%s_%d")
	call pargstr(pname)
	call pargi(n)
	call tbhadt(tp, tname, tval)
	# write rest of string as multi-lines
	i = 0
	while( got < len ){
	    # create the next multi-name
	    call ds_multname(pname, n, i, tname, SZ_LINE)
	    # get next part of param
	    call strcpy(pval[got+1], tval, MAX_PARREC)
	    # write it out
	    call tbhadt(tp, tname, tval)
	    # inc the counters
	    i = i+1
	    got = got + MAX_PARREC
	}
end

#
#  DS_MULTNAME -- create a multi-name
#
procedure ds_multname(pname, n, i, tname, len)

char	pname[ARB]					# i: param name
int	n						# i: param number
int	i						# i: multi number
char	tname[SZ_LINE]					# o: muilti name
int	len						# i: length of value
char	temp[SZ_LINE]					# l: temp buffer

begin
	# copy the first 3 chars of the pname
	call strcpy(pname, tname, 3)
	# add the param number
	call strcat("_", tname, len)
	call sprintf(temp, SZ_LINE, "%d")
	call pargi(n)
	call strcat(temp, tname, len)
	# add the multi id
	temp[1] = 'a' + i
	temp[2] = EOS
	call strcat(temp, tname, len)
end


procedure ds_rename(tp, pname, n, pval, len)

pointer	tp						# i: table pointer
char	pname[ARB]					# i: param name
int	n						# i: param number
char	pval[ARB]					# o: param value
int	len						# i: length of value

pointer	sp
pointer	xname
pointer	tname

bool	streq()

begin

	call smark(sp)

	call salloc(xname, SZ_LINE, TY_CHAR)
	call salloc(tname, SZ_LINE, TY_CHAR)

	if ( streq(pname, "imod") ) {
	   call strcpy("imodel", Memc[xname], SZ_LINE)
	}
	else if ( streq(pname, "omod") ) {
	   call strcpy("omodel", Memc[xname], SZ_LINE)
	}
	else if ( streq(pname, "ifile") ) {
	   call strcpy("ifiles", Memc[xname], SZ_LINE)
	}
	else if ( streq(pname, "ofile") ) {
	   call strcpy("ofiles", Memc[xname], SZ_LINE)
	}
	else if ( streq(pname, "t_chi") ) {
	   call strcpy("totchi", Memc[xname], SZ_LINE)
	}
	else {
	   call error(1, "DSLIB: unknown parameter string")
	}


	# make up the base output model param name
	call sprintf(Memc[tname], SZ_LINE, "%s_%d")
	call pargstr(Memc[xname])
	call pargi(n)

	# get the base output model param
	iferr (	call tbhgtt(tp, Memc[tname], pval, len) ) {
	    call error(1, "DSLIB: unknown header parameter")
	}

	call strcpy(pname, Memc[xname], SZ_LINE)

	call sfree(sp)

	return

end
