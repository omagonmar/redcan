#$Header: /home/pros/xray/xspectral/downspecrdf/RCS/downspecrdf.x,v 11.0 1997/11/06 16:43:41 prosb Exp $
#$Log: downspecrdf.x,v $
#Revision 11.0  1997/11/06 16:43:41  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:32:06  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:36:47  prosb
#General Release 2.3.1
#
#Revision 7.2  94/03/29  11:27:37  dennis
#Added EINSTEIN_MPC case.
#
#Revision 7.1  94/01/07  00:45:52  dennis
#Changed header parameter card order to improve the chance that PROSCON 
#will be able to use the output file.
#
#Revision 7.0  93/12/27  18:58:48  prosb
#General Release 2.3
#
#Revision 1.7  93/12/17  23:12:30  dennis
#Enabled processing the FITS release tape spectral table files.
#
#Revision 1.6  93/12/17  01:29:20  dennis
#Made downspecrdf accept files without FORMAT kaywords.
#
#Revision 1.5  93/12/06  21:57:26  dennis
#Display output (pre-RDF) table file name.
#
#Revision 1.4  93/12/04  03:15:54  dennis
#Restored the change to put out a SUBINST header parameter; if the RDF 
#file provides one, it is preserved, else we get one from QP_SUBINST().
#
#Revision 1.3  93/12/03  20:19:59  dennis
#Undid part of previous change:  SUBINST was already being put out, and the 
#change I made made it incorrect sometimes.
#
#Revision 1.2  93/12/03  19:31:42  dennis
#Added header parameter SUBINST, changed LIVETIME from double back to real, 
#changed FILTER from text back to int.
#
#Revision 1.1  93/11/20  04:19:18  dennis
#Initial revision
#
#
# Module:	downspecrdf.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	convert an RDF _obs.tab spectral data file to pre-RDF format, 
#		gathering off-axis histogram or BAL histogram data from 
#		auxiliary files
# Local:	skip_obs()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1993.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Dennis Schmidt, initial version, 9/24/93
#		{n} <who> -- <does what> -- <when>
#

include	<ctype.h>
include	<ext.h>
include <tbset.h>
include	<spectral.h>


procedure t_downspecrdf()

bool	clobber

int	display
int	parnum

pointer	sp			# program stack pointer
pointer	ssp			# single-pass stack pointer

pointer	fnlist_buffer
pointer	fnlist_handle

int	len			# length of observed spectral file name
pointer	rdf_obs_table
pointer	rdf_obs_tp
pointer	prdf_table
pointer	prdf_xtable
pointer	prdf_tp
pointer	prdf_cp

pointer	ds
pointer	qphead			# QPOE header struct from table

pointer	fntopnb()
int	fntgfnb()
int	strlen()
bool	clgetb()
int	clgeti()
pointer	tbtopn()

begin
	call smark(sp)
	call salloc(fnlist_buffer, SZ_PATHNAME, TY_CHAR)
	call salloc(rdf_obs_table, SZ_PATHNAME, TY_CHAR)

	clobber = clgetb("clobber")
	display	= clgeti("display")

	#----------------------------
	# get the list of table files
	#----------------------------
	call clgstr("fnlist_buffer", Memc[fnlist_buffer], SZ_PATHNAME)
	fnlist_handle = fntopnb(Memc[fnlist_buffer], NO)

	#------------------------------------------------------------
	# generate a pre-RDF _obs.tab file for each table in the list
	#------------------------------------------------------------
	while (fntgfnb(fnlist_handle, Memc[rdf_obs_table], 
						SZ_PATHNAME) != EOF) {
	    # get length of observed spectral file name
	    len = strlen(Memc[rdf_obs_table])

	    # check whether obs file is direct from FITS (vs. PROS) and 
	    #  ".tab" is omitted; if both are true it's a special case
	    if ((Memc[rdf_obs_table + len - 6] == '_') && 
		(Memc[rdf_obs_table + len - 5] == 's') && 
		(Memc[rdf_obs_table + len - 4] == 'p') && 
		(IS_DIGIT(Memc[rdf_obs_table + len - 3])) && 
		(IS_DIGIT(Memc[rdf_obs_table + len - 2])) && 
		(IS_DIGIT(Memc[rdf_obs_table + len - 1]))) {

		call strcat(".tab", Memc[rdf_obs_table], SZ_PATHNAME)
	    }
	    else {
		call rootname(Memc[rdf_obs_table], Memc[rdf_obs_table], 
							EXT_OBS, SZ_PATHNAME)
	    }

	    #-------------------------------------------------------------
	    # read everything from the RDF _obs.tab file and any auxiliary 
	    # files associated with it
	    #-------------------------------------------------------------
	    call ds_get(Memc[rdf_obs_table], qphead, ds)
	    # (It would be better to have this in an "iferr" construction, 
	    #  to allow skipping to the next file in the list if there's a 
	    #  problem; but that would require upgrading dstables.x with 
	    #  "errchk" in many routines.)

	    if (QP_FORMAT(qphead) < 1  &&  QP_REVISION(qphead) < 1)  {
		call skip_obs(Memc[rdf_obs_table], qphead, ds, true)
		next
	    }

	    #----------------------------------------------
	    # develop the name of the pre-RDF (output) file
	    #----------------------------------------------
	    call smark(ssp)

	    call salloc(prdf_table, SZ_PATHNAME, TY_CHAR)
	    call strcpy("", Memc[prdf_table], SZ_PATHNAME)
	    call rootname(Memc[rdf_obs_table], Memc[prdf_table], 
						"_prdf_obs.tab", SZ_PATHNAME)
	    call salloc(prdf_xtable, SZ_PATHNAME, TY_CHAR)
	    call strcpy("", Memc[prdf_xtable], SZ_PATHNAME)
	    call clobbername(Memc[prdf_table], Memc[prdf_xtable], clobber,
								SZ_PATHNAME)

	    #---------------------------------
	    # create the pre-RDF (output) file
	    #---------------------------------
	    call dos_create(Memc[prdf_xtable], prdf_tp, prdf_cp)

	    #--------------------------------------------------------------
	    # for each of the header parameters whose name is reverting to 
	    # an old form, put the parameter with its old name
	    #--------------------------------------------------------------
	    call tbhadt(prdf_tp, "SEQNO", QP_OBSID(qphead))
	    call tbhadr(prdf_tp, "LIVECORR", QP_DEADTC(qphead))

	    #------------------------------------------------------------
	    # if the old-style file didn't get a SUBINST header parameter 
	    # from the RDF file, give it one
	    #------------------------------------------------------------
	    call tbhadi(prdf_tp, "SUBINST", QP_SUBINST(qphead))

	    #-----------------------------------------------------------
	    # restore data from auxiliary file(s) to pre-RDF file header
	    #-----------------------------------------------------------
	    switch ( DS_INSTRUMENT(ds) ) {

	      case EINSTEIN_IPC:
		# - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# write the bal histogram data into the pre-RDF (output) 
		# file header
		# - - - - - - - - - - - - - - - - - - - - - - - - - - -
		call dos_putbal(prdf_tp, DS_BAL_HISTGRAM(ds))

	      case EINSTEIN_HRI:
	      case EINSTEIN_MPC:
		# - - - - - - - - - - - -
		# (nothing special to do)
		# - - - - - - - - - - - -

	      default:
		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		# write the offaxis histogram data into the pre-RDF (output) 
		# file header
		# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		call dos_putoah(prdf_tp, ds)
	    }

	    #----------------------------------------------------------
	    # copy the RDF _obs.tab file header into the old-style file
	    #----------------------------------------------------------
	    rdf_obs_tp = tbtopn (Memc[rdf_obs_table], READ_ONLY, 0)
	    call tbhcal(rdf_obs_tp, prdf_tp)
	    call tbtclo(rdf_obs_tp)

	    #--------------------------------------------------------------
	    # for each of the header parameters whose name is reverting to 
	    # an old form, get the parameter number, then delete it without 
	    # asking for confirmation
	    #--------------------------------------------------------------
	    call tbhfkw (prdf_tp, "OBS_ID", parnum)
	    call tbhdel (prdf_tp, parnum)

	    call tbhfkw (prdf_tp, "DTCOR", parnum)
	    call tbhdel (prdf_tp, parnum)

	    #-------------------------------------------------------------
	    # for each of the header parameters whose type is reverting to 
	    # an old type, put out the value in the old type
	    #-------------------------------------------------------------
	    call tbhadi(prdf_tp, "FILTER", QP_FILTER(qphead))
	    call tbhadr(prdf_tp, "LIVETIME", real(QP_LIVETIME(qphead)))

	    #-------------------------------------------------------------
	    # change the values of REVISION and FORMAT header parameters 
	    # to 0  (REVISION must be reset as well as FORMAT, because 
	    # get_tbhead() doesn't permit QP_REVISION to exceed QP_FORMAT)
	    #-------------------------------------------------------------
	    call tbhadi(prdf_tp, "FORMAT", 0)
	    call tbhpti(prdf_tp, "REVISION", 0)

	    #-----------------------------------------------
	    # write the spectra to the pre-RDF _obs.tab file
	    #-----------------------------------------------
	    call dos_putspec(prdf_tp, prdf_cp, ds)

	    #----------------------------------------------------------------
	    # if requested to, display this dataset and the pre-RDF file name
	    #----------------------------------------------------------------
	    call ds_disp(ds, display)
	    if ( display > 0 ) {
		call printf("Output (pre-RDF) table file:  %s\n\n")
		 call pargstr(Memc[prdf_table])
		call flush(STDOUT)
	    }

	    #--------------------------------------
	    # the pre-RDF _obs.tab file is complete
	    #--------------------------------------
	    call tbtclo(prdf_tp)
	    call mfree(prdf_cp, TY_POINTER)

	    call finalname(Memc[prdf_xtable], Memc[prdf_table])

	    call sfree(ssp)

	    #-------------------------
	    # free the data structures
	    #-------------------------
	    call mfree(qphead, TY_STRUCT)
	    call mfree(DS_FILENAME(ds), TY_CHAR)
	    call mfree(ds, TY_STRUCT)
	}

	#---------
	# clean up
	#---------
	call fntclsb(fnlist_handle)

	call sfree(sp)
end



#-----------------------------------------------------------------------
# The "dos_..." routines are copies (except for "dos" instead of "ds" in 
# the names) of routines in the old dstables.x module.
#-----------------------------------------------------------------------

include "../source/pspc.h"

# define max number of table columns for the observed data set
define  MAX_CP 6

# define table column pointers
define	EN1_CP		Memi[($1)+0]
define	EN2_CP		Memi[($1)+1]
define	SOURCE_CP	Memi[($1)+2]
define	BKGD_CP		Memi[($1)+3]
define	NET_CP		Memi[($1)+4]
define	ERR_CP		Memi[($1)+5]

# define table column names
define	EN1_COL		"lo_energy"
define	EN2_COL		"hi_energy"
define	SOURCE_COL	"source"
define	BKGD_COL	"bkgd"
define	NET_COL		"net"
define	ERR_COL		"neterr"

#
# DOS_CREATE -- open the table file and create column headers
#
procedure dos_create(table, tp, cp)

char	table[ARB]		# i: table name
pointer tp			# i: table pointer
pointer	cp			# o: column pointers
pointer tbtopn()		# l: table I/O routines

begin
	# allocate space for the column pointers
	if( cp ==0 )
	    call calloc(cp, MAX_CP, TY_POINTER)
	# open a new table	
	tp = tbtopn(table, NEW_FILE, 0)
	# and define columns
	call tbcdef(tp, EN1_CP(cp),  EN1_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, EN2_CP(cp),  EN2_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, SOURCE_CP(cp), SOURCE_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, BKGD_CP(cp), BKGD_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, NET_CP(cp), NET_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbcdef(tp, ERR_CP(cp),  ERR_COL, "", "%9.2f", TY_REAL, 1, 1)
	call tbtcre(tp)
end


#
# DOS_PUTOAH -- write an offaxis histogram 
#
procedure dos_putoah(tp, ds)
pointer	tp
pointer ds
#--

int	i, j
char	line[SZ_LINE]
char	name[SZ_LINE]

int	str, stropen()

begin
	if ( DS_NOAH(ds) == 0 || DS_OAHPTR(ds) == NULL ) {
		call eprintf("DSLIB: Warning no offaxis histogram\n")
		return
	}
	call tbhadi(tp, "PSPCNOH", DS_NOAH(ds))
	call tbhadi(tp, "PSPCELEM", PSPC_ELEM)

	#-----------
	# Source OAH
	#-----------
	i = 0
	while ( i < DS_NOAH(ds) ) {
		call sprintf(name, SZ_LINE, "PSPCOH%d")
		 call pargi(( i / PSPC_ELEM ) + 1 )

		str  = stropen(line, SZ_LINE, WRITE_ONLY)	
		for ( j = 0; i < DS_NOAH(ds) && j < PSPC_ELEM; j = j + 1 ) {
			call fprintf(str, "%g ")
			 call pargr(DS_OAH(ds, i))
			i = i + 1
		}
		call close(str)

		call tbhadt(tp, name, line, SZ_LINE)
	}

	#---------------
	# Background OAH
	#---------------
	i = 0
	while ( i < DS_NOAH(ds) ) {
		call sprintf(name, SZ_LINE, "BACKOH%d")
		 call pargi(( i / PSPC_ELEM ) + 1 )

		str  = stropen(line, SZ_LINE, WRITE_ONLY)	
		for ( j = 0; i < DS_NOAH(ds) && j < PSPC_ELEM; j = j + 1 ) {
			call fprintf(str, "%g ")
			 if (DS_BK_OAHPTR(ds) != NULL)
			    call pargr(DS_BK_OAH(ds, i))
			 else
			    call pargr(0.0)
			i = i + 1
		}
		call close(str)

		call tbhadt(tp, name, line, SZ_LINE)
	}

end


#
#  DOS_PUTBAL -- write bal histo information into the table header
#
procedure dos_putbal(tp, bh)

pointer tp					# i: table pointer
pointer	bh					# i: pointer to bal record

char	buf[SZ_LINE]				# l: temp name buffer
int	i					# l: loop counter

begin
	# if bh is 0, there is no bal info
	if( bh ==0 ){
	    call tbhadi(tp, "nbals", 0)
	    return
	}

	# enter number of bals
	call tbhadi(tp, "nbals", BH_ENTRIES(bh))
	if( BH_ENTRIES(bh) ==0 )
	    return

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
	
	# now write the non-zero fractions into the header
	do i=1, BH_ENTRIES(bh){
		call sprintf(buf, SZ_LINE, "bal_%-2d")
		call pargi(i)
		call tbhadr(tp, buf, BH_BAL(bh,i))
		call sprintf(buf, SZ_LINE, "bfrac_%-2d")
		call pargi(i)
		call tbhadr(tp, buf, BH_PERCENT(bh,i))
	}
end

#
# DOS_PUTSPEC -- fill table file with spectra and errors
#
procedure dos_putspec(tp, cp, ds)

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
