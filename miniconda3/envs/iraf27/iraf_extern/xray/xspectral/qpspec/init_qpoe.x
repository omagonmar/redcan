# $Header: /home/pros/xray/xspectral/qpspec/RCS/init_qpoe.x,v 11.0 1997/11/06 16:43:32 prosb Exp $
# $Log: init_qpoe.x,v $
# Revision 11.0  1997/11/06 16:43:32  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:50  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/10  14:06:46  dvs
#Passes gtf (good time filter) to get_inst_pars.
#
#Revision 7.1  94/05/18  18:17:11  dennis
#Installed region syntax precheck, for rapid feedback.  Also put main 
#parser setup here (formerly in t_qpspec()) and extraction of radius 
#and position of region (formerly in bin_qpoe()).
#
#Revision 7.0  93/12/27  18:58:25  prosb
#General Release 2.3
#
#Revision 6.1  93/06/17  13:39:39  orszak
#jso - changed the string comparison on the check of unsorted qpoe
#      files.  i was not using strcmp() correctly [and i had the wrong
#      logic].  the incorrect use of strcmp made the logic work on the
#      Suns, but it never worked on the DECStation.  Also, changed to ann
#      warning message.
#
#Revision 6.0  93/05/24  16:53:54  prosb
#General Release 2.2
#
#Revision 5.5  93/05/20  03:31:18  dennis
#Expanded region parameter buffers to SZ_LINE chars.
#
#Revision 5.4  93/05/12  15:45:34  orszak
#jso - freed the stack and corrected a flint warning.
#
#Revision 5.3  93/05/05  10:44:08  orszak
#jso - corrected check for unsorted qpoe files.  it is important to check
#      for the index, because qpoe could have proper SORT header parameters
#      even if the index was not made, in this case the PLIO bug still occurs.
#
#Revision 5.1  93/04/27  00:23:47  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  22:46:53  prosb
#General Release 2.1
#
#Revision 4.1  92/10/06  16:46:10  mo
#MC	10/6/92		Update get_goodtimes calling sequence for 2
#			time arrays instead of 1 2-D array
#
#Revision 4.0  92/04/27  15:29:16  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/05  13:02:36  orszak
#Initial revision
#
#
# Function:	init_qpoe
# Purpose:	To open source and background qpoe files and region masks.
# Pre-cond:	
# Post-cond:	Source qpoe file is open.
#		If background, qpoe file is open.
#		qpoe io events assigned.
#		pl masks defined.
#		dobkgd flag set.
# Method:	
# Description:	
# Notes:	
#

include	<qpioset.h>

include <ext.h>

include	<regparse.h>
include	<error.h>
include <spectral.h>
include "qpspec.h"

define SZ_BUF  1024

procedure init_qpoe(simage, sim, sio, spm, shead, stitle, sbn, 
		    bimage, bim, bio, bpm, bhead, btitle, bbn,
		    dobkgd, ds, display, 
		    np, balstr, bh, gtf, system, systemstr, macro)

bool	bjunk			# l: unneeded rtn from parser request routine

char	bimage[ARB]		# o: background qpoe name
char	simage[ARB]		# o: source qpoe name

int	display			# i: display level
int	dobkgd			# o: TRUE if we have background
int	nintvals		# l: number of good time intervals

pointer	bbn			# background instrument binning parameters
pointer	bevlist			# l: background event list expression
pointer	bexposure		# o: background exposure file
pointer	bhead			# o: background X-ray header
pointer	bim			# o: background qpoe pointer
pointer	bio			# o: background event pointer
pointer	bpm			# o: background pixel mask pointer
pointer	bregion			# o: background region descr
pointer	broot			# l: background qpoe root name
pointer	btitle			# o: background region summary pointer
pointer	ds			# i: data set record pointer
pointer	gbegs			# l: pointer to good time intervals
pointer	gends			# l: pointer to good time intervals
pointer	sbn			# source instrument binning parameters
pointer	sevlist			# l: source event list expression
pointer	sexposure		# o: source exposure file
pointer	shead			# o: source X-ray header
pointer	sim 			# o: source qpoe pointer
pointer	sio			# o: source event pointer
pointer	sp			# l: stack pointer
pointer	spm			# o: source pixel mask pointer
pointer	sregion			# l: source region descr
pointer	srg_parsing		# l: pointer to parsing control structure 
				#     for source regions
pointer	sroot			# l: source qpoe root name
pointer	stitle			# o: source region summary pointer

real	bthresh			# o: background threshold for exposure
real	pix_size		# l: size of pixel in arcs per pixel
real	sthresh			# o: source threshold for exposure

# parameters for call to get_inst_pars()
pointer	np			# i: pset parameter pointer
char	balstr[ARB]		# o: bal histo string
pointer	bh			# o: BAL histogram pointer
pointer gtf			# o: Good time filter
pointer	system			# o: systematic errors
char	systemstr[ARB]		# o: string for systematic error
char	macro[ARB]		# o: macro name of event element


bool	clgetb()		# get boolean parameter
bool	ck_none()		# check for NONE in any case
bool	reg_precheck()		# preliminary region descriptor syntax check
bool	rg_objlist_req()	# request parser to return object list
bool	streq()			# string compare

int	btoi()			# convert boolean to int

pointer	qp_open()		# open a qpoe file
pointer	qpio_open()		# open an event list
pointer	rg_open_parser()	# open the region descriptor parser

real	clgetr()		# get real parameter

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#---------------------
	# allocate stack space
	#---------------------

	#---------------------------------
	# background event list expression
	#---------------------------------
	call salloc(bevlist, SZ_BUF, TY_CHAR)

	#-------------------------
	# background exposure file
	#-------------------------
	call salloc(bexposure, SZ_PATHNAME, TY_CHAR)

	#-----------------------------
	# background region descriptor
	#-----------------------------
	call salloc(bregion, SZ_LINE, TY_CHAR)

	#--------------------------
	# background qpoe root name
	#--------------------------
	call salloc(broot, SZ_PATHNAME, TY_CHAR)

	#-----------------------------
	# source event list expression
	#-----------------------------
	call salloc(sevlist, SZ_BUF, TY_CHAR)

	#---------------------
	# source exposure file
	#---------------------
	call salloc(sexposure, SZ_PATHNAME, TY_CHAR)

	#-------------------------
	# source region descriptor
	#-------------------------
	call salloc(sregion, SZ_LINE, TY_CHAR)

	#----------------------
	# source qpoe root name
	#----------------------
	call salloc(sroot, SZ_PATHNAME, TY_CHAR)

	#--------------------------
	# initialize some variables
	#--------------------------
	stitle = 0
	btitle = 0

	#-----------------------
	# get source information
	#-----------------------
	call clgstr("source", simage, SZ_PATHNAME)
	if ( ck_none( simage) || streq(simage, "") )
	    call error(1, "QPSPEC requires a source qpoe file as input.")
	call rootname("", simage, EXT_QPOE, SZ_PATHNAME)

	#--------------------------------------------------------
	# open the source QPOE file, get header, set up filtering
	#--------------------------------------------------------
	call qp_parse(simage, Memc[sroot], SZ_PATHNAME, Memc[sevlist], SZ_BUF)
	sim = qp_open(Memc[sroot], READ_ONLY, 0)
	call get_qphead(sim, shead)
	sio = qpio_open(sim, Memc[sevlist], READ_ONLY)

	#----------------------
	# get the source region
	#----------------------
	call clgstr("region", Memc[sregion], SZ_LINE)
	if (!reg_precheck(Memc[sregion], sim, shead, sio))
	    call error(1, "QPSPEC: can't parse region descriptor.")

	#-------------------------------
	# check for source exposure file
	#-------------------------------
	call clgstr("exposure", Memc[sexposure], SZ_PATHNAME)
	call rootname(simage, Memc[sexposure], EXT_EXPOSURE, SZ_PATHNAME)
	if ( !ck_none( Memc[sexposure] ) ) {
	    sthresh = clgetr("expthresh")
	    if ( sthresh < 0.0 ) {
		call error(1, "QPSPEC: exposure threshold must be >= 0.")
	    }
	}
	else {
	    sthresh = -1.0
	}


	#--------------------------------------------------------------
	# open region descriptor parser for source regions, and set up
	#  request for region object list
	#--------------------------------------------------------------
	# (This is an unusual use of the parser.  msk_open() (called by 
	#  msk_qpopen(), which is called by set_qpmask()) receives a region 
	#  descriptor, exposure mask spec, and exposure threshold; it sets up 
	#  a parser request to get a region mask and expanded descriptor; 
	#  it then filters the resulting region mask through a boolean mask 
	#  made from the exposure mask, according to the exposure threshold; 
	#  it also incorporates the expanded region descriptor into the header 
	#  (title) for this filtered region mask; it doesn't, except as 
	#  requested through the parsing structure, return anything directly 
	#  from the parsing of the region descriptor.  This, then, is a 
	#  request to pass back the region object list from the parsing of 
	#  the region descriptor.)

	srg_parsing = rg_open_parser()
	bjunk = rg_objlist_req(srg_parsing)

	#----------------------------------------------------------
	# set up spatial masking; check that QPOE is sorted on y, x
	#----------------------------------------------------------
	call set_qpmask(sim, sio, srg_parsing, Memc[sregion], 
				Memc[sexposure], sthresh, spm, stitle)
	call chk_sorted(sio, sim)

	#----------------------------------------
	# set up the source binning record 
	#  [must precede call to get_inst_pars()]
	#----------------------------------------
	BN_INST(sbn) = QP_INST(shead)
	BN_NOAH(sbn) = 0
	BN_FULL(sbn) = btoi(clgetb("full"))
	BN_INDICES(sbn) = QP_CHANNELS(shead)

	#---------------------------------------
	# get instrument specific parameters
	#  [must precede call to bn_getradius()]
	#---------------------------------------
	call get_inst_pars(np, sim, Memc[sevlist], shead, 
		sbn, bbn, balstr, bh, gtf, system, systemstr, macro, display)

	#----------------------------------------------
	# save region radius in sbn and position in ds; 
	#  then close parser, releasing the object list
	#----------------------------------------------
	# size of pixel in arcsec per pixel
	pix_size = real( abs(QP_CDELT1(shead)) ) * 3600.0
	call bn_getradius(OBJLISTPTR(srg_parsing), sbn, BN_RADIUS(sbn), 
								pix_size)
	call bn_getxy(OBJLISTPTR(srg_parsing), DS_X(ds), DS_Y(ds))

	call rg_close_parser(srg_parsing)

	#-------------------------
	# Get the source good time
	#-------------------------
	call get_goodtimes(sim, Memc[sevlist], display, gbegs, gends,
			nintvals, BN_GOODTIME(sbn))
	call mfree(gbegs, TY_DOUBLE)
	call mfree(gends, TY_DOUBLE)


	#-------------------------------
	# get the background information
	#-------------------------------
	call clgstr("bkgd", bimage, SZ_PATHNAME)

	dobkgd = btoi(!ck_none( bimage))

	if ( dobkgd == YES ) {
	    #----------------------------------------------------------
	    # if the background file is a null string use source file.
	    #----------------------------------------------------------
	    if ( streq(bimage, "") ) {
		call strcpy(simage, bimage, SZ_PATHNAME)
	    }
	    call rootname(simage, bimage, EXT_QPOE, SZ_PATHNAME)

	    #------------------------------------------------------------
	    # open the background QPOE file, get header, set up filtering
	    #------------------------------------------------------------
	    call qp_parse(bimage, Memc[broot], SZ_PATHNAME,
				Memc[bevlist], SZ_BUF)
	    bim = qp_open(Memc[broot], READ_ONLY, 0)
	    call get_qphead(bim, bhead)
	    bio = qpio_open(bim, Memc[bevlist], READ_ONLY)

	    #---------------------------------------
	    # check that the background file is okay
	    #---------------------------------------
	    if ( QP_INST(shead) != QP_INST(bhead) )
		call error(1, 
 "QPSPEC: the source instrument is not the same as the background instrument.")
	    if ( QP_CHANNELS(shead) != QP_CHANNELS(bhead) )
		call error(1, 
 "QPSPEC: the number of source channels does not equal the number of background channels.")

	    #--------------------------
	    # get the background region
	    #--------------------------
	    call clgstr("bkgdregion", Memc[bregion], SZ_LINE)
	    if (!reg_precheck(Memc[bregion], bim, bhead, bio))
		call error(1, "QPSPEC: can't parse region descriptor.")

	    #-----------------------------------
	    # check for background exposure file
	    #-----------------------------------
	    call clgstr("bkgdexposure", Memc[bexposure], SZ_PATHNAME)
	    call rootname(bimage, Memc[bexposure], EXT_EXPOSURE, SZ_PATHNAME)
	    if ( !ck_none(Memc[bexposure]) ) {
		bthresh = clgetr("bkgdthresh")
		if( bthresh < 0.0 ) {
		    call error(1, "QPSPEC: exposure threshold must be >= 0.")
		}
	    }
	    else {
		bthresh = -1.0
	    }


	    #----------------------------------------------------------
	    # set up spatial masking; check that QPOE is sorted on y, x
	    #----------------------------------------------------------
	    call set_qpmask(bim, bio, NULL, Memc[bregion], 
				Memc[bexposure], bthresh, bpm, btitle)
	    call chk_sorted(bio, bim)

	    #-----------------------------
	    # Get the background good time
	    #-----------------------------
	    call get_goodtimes(bim, Memc[bevlist], display, gbegs, gends,
			nintvals, BN_GOODTIME(bbn))
	    call mfree(gbegs, TY_DOUBLE)
	    call mfree(gends, TY_DOUBLE)
	}

	#---------------
	# free the stack
	#---------------
	call sfree(sp)

end


#-----------------------------------------------------------------------
#
#	chk_sorted - check that the qpoe file is sorted on y-x
#		     (This prevents the PLIO stack overflow bug.)
#
#-----------------------------------------------------------------------
procedure chk_sorted(qpio, qp)

pointer	qpio				# i: qpoe event pointer
pointer	qp				# i: qpoe handle

bool	problem				# l: do we want the error message

int	junk				# l: return from qp_gstr
int	lowcase				# l: is it a lower "y"
int	upcase				# l: is it a upper "Y"

pointer	sp				# l: stack pointer
pointer	sortstr				# l: value of XS-SORT

bool	qp_ckindex()
int	qp_accessf()			# l: qpoe param existence
int	qp_gstr()			# l: get string parameter
int	strncmp()

begin

	#---------------
	# mark the stack
	#---------------
	call smark(sp)

	#---------------------------------
	# background event list expression
	#---------------------------------
	call salloc(sortstr, SZ_LINE, TY_CHAR)

	#-----------------
	# initialize error
	#-----------------
	problem = FALSE

	#--------------------
	# check for the index
	#--------------------
	problem = !qp_ckindex(qpio)

	#--------------------------------
	# make sure the sort param exists
	#--------------------------------
	if ( qp_accessf(qp, "XS-SORT") == NO) {
	    if ( qp_accessf(qp, "xs-sort") == NO ) {
		problem = TRUE
	    }
	    else {
		junk = qp_gstr(qp, "xs-sort", Memc[sortstr], SZ_LINE)
	    }
	}
	else {
	    junk = qp_gstr(qp, "XS-SORT", Memc[sortstr], SZ_LINE)
	}

	#-------------------------------------------------
	# if we have XS-SORT check that it begins with "y"
	#-------------------------------------------------
	upcase  = strncmp("Y", Memc[sortstr], 1)
	lowcase = strncmp("y", Memc[sortstr], 1)
	if ( upcase != 0 && lowcase != 0 ) {
	    problem = TRUE
	}

	if ( problem ) {
	    call eprintf("\n*--------------------------------------------------------*\n")
	    call eprintf("* QPSPEC: WARNING: qpoe file is not sorted on y, x  and  *\n")
	    call eprintf("* is likely to have problems.                            *\n")
	    call eprintf("* Use 'qpsort' to sort.                                  *\n")
	    call eprintf("*--------------------------------------------------------*\n")
	    call flush(STDERR)
	}

	#---------------
	# free the stack
	#---------------
	call sfree(sp)

end

bool procedure qp_ckindex(qpio)

pointer	qpio

bool	useindex

int	indexlen
int	nlines
int	evyoff
int	ixyoff
int	noindex

int	qpio_stati()

begin

	indexlen = qpio_stati(qpio, QPIO_INDEXLEN)
	nlines   = qpio_stati(qpio, QPIO_NLINES)
	evyoff   = qpio_stati(qpio, QPIO_EVYOFF)
	ixyoff   = qpio_stati(qpio, QPIO_IXYOFF)
	noindex  = qpio_stati(qpio, QPIO_NOINDEX)

	useindex = ( (indexlen == nlines) &&
		     (evyoff   == ixyoff) &&
		     (noindex  == NO) )

	return(useindex)

end
