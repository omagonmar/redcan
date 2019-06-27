#$Header: /home/pros/xray/lib/regions/RCS/rgcreate.x,v 11.0 1997/11/06 16:19:11 prosb Exp $
#$Log: rgcreate.x,v $
#Revision 11.0  1997/11/06 16:19:11  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:26:26  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/19  17:01:16  dennis
#Moved the functionality of rg_imcreate(), rg_qpcreate(), rg_pmcreate(),
#rg_plcreate() into new routine rg_objects(), callable directly to create
#either masks or object lists, and consolidating the setup decisions at a
#single location.  Modularized the setup functions into separate routines.
#This opened rg_create() to create object lists as well as masks, and
#simplified the interface.
#
#Revision 8.0  94/06/27  13:44:30  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/18  18:40:01  dennis
#Checked out for a change that became unnecessary.
#
#Revision 7.0  93/12/27  18:07:46  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:38:37  prosb
#General Release 2.2
#
#Revision 5.3  93/05/18  23:49:15  dennis
#Set PM_MAPXY(MASKPTR(parsing)) = NO, so rg_flush() will know it's getting 
#image-relative coordinates, not section-relative.
#
#Revision 5.2  93/04/27  00:04:11  dennis
#Regions system rewrite.
#
#Revision 5.0  92/10/29  21:14:10  prosb
#General Release 2.1
#
#Revision 4.3  92/09/29  20:59:40  dennis
#Freed coordinate transformation structs
#
#Revision 4.2  92/09/02  03:18:43  dennis
#In rg_plfile(), pass SZ_PLHEAD, not SZ_MASKTITLE, to pl_loadf().
#In rg_plstrip(), change lbuf[] and tbuf[] size to SZ_REGOUTPUTLINE, and 
#use getanyline() to read into lbuf[].
#In rg_plstrip() and rg_summaryadd(), remove extra "+1" in string (re)allocs.
#
#Revision 4.1  92/05/26  14:31:47  mo
#MC	5/26/92		Remove redundand SZ_PLHEAD declaration
#
#Revision 4.0  92/04/27  17:20:43  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/23  13:05:57  mo
#MC	4/23/92		Fix bad compare on 'rbuf'.  Its a pointer, so
#			test must be != 0, not a boolean test
#
#Revision 3.2  92/04/10  18:12:52  dennis
#Accept .pl file without ASCII region descriptor
#
#Revision 3.1  91/08/02  10:34:11  mo
#MC   8/2/91          Updated dependencies
#
#Revision 2.0  91/03/07  00:15:29  pros
#General Release 1.0
#
# Module:	rgcreate.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	hi-level routines to create pl masks or region object lists 
#			from region descriptors
# Subroutines:	rg_imcreate()	[temporary]
#		rg_qpcreate()	[temporary]
#		rg_pmcreate()	[temporary]
#		rg_plcreate()	[temporary]
#		rg_objects()	(main high-level entry point)
#		rg_imwcsset()
#		rg_qpwcsset()
#		rg_pmmasksetup()
#		rg_plmasksetup()
#		rg_create()
#		rg_wcsset()
#		rg_plfile()
#		rg_summaryadd()
#		rg_plstrip()
#		wcstype()
#		rg_wcsfree()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989,1994. You may do anything you like with this file except
#		remove this copyright.
# Modified:	{0} Michael VanHilst	initial version	     2 December 1988
#		{1} MVH	rg_pmcreate to use rg_create plio mode	  8 May 1989
# Modified:	{2} John : Nov 89
#			Add rg_imcreate and rg_qpcreate
#			add code for the MWCS
#		{n} <who> -- <does what> -- <when>


include	<ctype.h>
include <pmset.h>
include	<plio.h>
include <imhdr.h>
include <error.h>
include <regparse.h>
include <plhead.h>
include <qpoe.h>

define B_DEPTH 16

# this must match SZ_PLHEAD in plhead.h
#define SZ_PLHEAD 8192


# rg_imcreate, rg_qpcreate, rg_pmcreate, rg_plcreate 
#  are the historical entry points for creating masks; 
#  they are no longer necessary, and may be replaced by direct calls 
#  to rg_objects().


#  RG_IMCREATE -- create a plio mask, given a region descriptor and a
#			reference image; Initilize the regions WCS xformation
#
procedure rg_imcreate(parsing, s, im)

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
pointer	im			# i: reference image

int	plaxlen[2]		# l: unused array to pass to rg_objects()
int	reftyp			# l: type of reference image and/or 
				#     coordinate system

begin
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_imcreate called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_imcreate called without request to open mask")

	reftyp = REFTY_IM
	call rg_objects( parsing, s, im, plaxlen, reftyp )
end


#  RG_QPCREATE -- create a plio mask, given a region descriptor and a
#		  reference qpoe file; Initilize the regions WCS xformation
#
procedure rg_qpcreate(parsing, s, qp)

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
pointer	qp			# i: reference qpoe file
#--

int	plaxlen[2]		# l: unused array to pass to rg_objects()
				#     (axis lengths are handled locally in 
				#     rg_objects())
int	reftyp			# l: type of reference image and/or 
				#     coordinate system

begin
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_qpcreate called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_qpcreate called without request to open mask")

	reftyp = REFTY_QP
	call rg_objects( parsing, s, qp, plaxlen, reftyp )
end


#  RG_PMCREATE -- create a plio mask, given a region descriptor and a
#			reference image; Do Not utilize WCS transformations
#
procedure rg_pmcreate ( parsing, s, im )

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
pointer	im			# i: reference image

int	plaxlen[2]		# l: unused array to pass to rg_objects()
int	reftyp			# l: type of reference image and/or 
				#     coordinate system

begin	
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_pmcreate called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_pmcreate called without request to open mask")

	reftyp = REFTY_PM
	call rg_objects( parsing, s, im, plaxlen, reftyp )
end


#  RG_PLCREATE -- create a plio mask, given a region descriptor and 
#			mask dimensions
#
procedure rg_plcreate ( parsing, s, plaxlen )

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
int	plaxlen[2]		# i: mask dimensions (x, y)

pointer	im			# l: unused pointer to pass to rg_objects()
int	reftyp			# l: type of reference image and/or 
				#     coordinate system

begin
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_plcreate called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_plcreate called without request to open mask")

	im = NULL
	reftyp = REFTY_PL
	call rg_objects( parsing, s, im, plaxlen, reftyp )
end

 
#  RG_OBJECTS -- main entry to set up and create either a mask or a list 
#		 of region object structures
#
procedure rg_objects( parsing, s, im, plaxlen, reftyp )

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
pointer	im			# i: reference image or QPOE file
int	plaxlen[2]		# i: pl mask dimensions (x, y)
int	reftyp			# i: type of reference image and/or 
				#     coordinate system

pointer imh			# l: pointer to xhead or NULL
int	axlen[2]		# l: mask dimensions (x, y) (pl or qp)

bool	rg_make_mask_q()	#    whether we are making a mask

begin
	# if going to interpret WCS, get reference file header, set up WCS; 
	#  if no relative coordinates via pmio, get axis lengths
	if (reftyp == REFTY_IM) {
	    call rg_imwcsset(im, imh)
	}
	else if (reftyp == REFTY_QP) {
	    call rg_qpwcsset(im, imh, axlen)
	}
	else {
	    imh = NULL
	    if (reftyp == REFTY_PL) {
		axlen[1] = plaxlen[1]
		axlen[2] = plaxlen[2]
	    }
	}

	# if making a mask, create it now
	if (rg_make_mask_q(parsing)) {
	    if (reftyp == REFTY_IM  ||  reftyp == REFTY_PM) {
		call rg_pmmasksetup(parsing, im)
	    }
	    else {	# (reftyp == REFTY_QP  ||  reftyp == REFTY_PL)
		call rg_plmasksetup(parsing, axlen)
	    }
	}

	# fill in the mask or make the object list
	call rg_create(parsing, s, imh)

	# if we set up a WCS, free it
	if (reftyp == REFTY_IM  ||  reftyp == REFTY_QP)
	    call rg_wcsfree(imh)
end


#  RG_IMWCSSET -- initialize the regions WCS xformation for an (imio) image
#
procedure rg_imwcsset(im, imh)

pointer	im			# i: reference image
pointer	imh			# o: reference image header struct

pointer mw_openim(), mw_sctran() # l: open the image wcs

include "rgwcs.com"

begin
	call get_imhead(im, imh)

	ifnoerr ( rg_imwcs = mw_openim(im) ) {
		rg_ctwcs = mw_sctran(rg_imwcs, "world", "logical", 0)
	} else {
		call eprintf("Warning: no wcs in image file\n")
	        call mfree(imh, TY_POINTER)
		imh = NULL
	}
end


#  RG_QPWCSSET -- initilize the regions WCS xformation for a (qpio) QPOE file
#
procedure rg_qpwcsset(qp, imh, axlen)

pointer	qp			# i: reference qpoe file
pointer	imh			# o: reference QPOE file header struct
int	axlen[2]		# o: mask dimensions (x, y)
#--

pointer qp_loadwcs()		# l: open the QPOE wcs
pointer	mw_sctran()
int	err

include "rgwcs.com"

begin
	call get_qphead(qp, imh)

        axlen[1] = QP_XDIM(imh)
        axlen[2] = QP_YDIM(imh)
	err = 0
	ifnoerr ( rg_imwcs = qp_loadwcs(qp) )
		rg_ctwcs = mw_sctran(rg_imwcs, "world", "logical", 0)
	else
		err = 1

	if ( err == 1 || rg_imwcs == NULL ) {
		call eprintf("Warning: no wcs in QPOE file\n")
	        call mfree(imh, TY_POINTER)
		imh = NULL
	}
end


#  RG_PMMASKSETUP -- create a pmio mask, and 
#		     tell system it's pmio, not just plio
#
procedure rg_pmmasksetup ( parsing, im )

pointer	parsing			# i: pointer to parsing control structure
pointer	im			# i: reference image

pointer	pm_newmask()		# l: create a new mask

begin	
	if (parsing == NULL)
	    call error(EA_FATAL, 
			"rg_pmmasksetup called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_pmmasksetup called without request to open mask")
	MASKPTR(parsing) = pm_newmask (im, B_DEPTH)
	PM_MAPXY(MASKPTR(parsing)) = NO		# Coords flushed to the mask
						#  will be image-relative, 
						#  not section-relative
	SELPLPM(parsing) = MSKTY_PM		# Set pm type, so rg_add() 
						#  will refer to im for section
end

 
#  RG_PLMASKSETUP -- create a plio mask, and tell system it's plio, not pmio
#
procedure rg_plmasksetup ( parsing, axlen )

pointer	parsing			# i: pointer to parsing control structure
int	axlen[2]		# i: mask dimensions (x, y)

pointer	pl_create()		# l: create a new mask

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
			"rg_plmasksetup called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	    call error(EA_FATAL, 
			"rg_plmasksetup called without request to open mask")
	MASKPTR(parsing) = pl_create (2, axlen, B_DEPTH)
	SELPLPM(parsing) = MSKTY_PL		# Set pl/pm type
end

 
# RG_CREATE -- fill in a region mask or make a region object list
#
procedure rg_create(parsing, s, imh)

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
pointer imh			# i: pointer to xhead or NULL
#--

int	index			# l: index into string to start rg_parse()
bool	rg_parse()		# l: parse a region descriptor


include "regparse.com"

begin
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_create called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL  &&  
	    RGPARSE_OPT(OBJLIST , parsing) == NULL     )
	    call error(EA_FATAL, 
	 "rg_create called without request to open mask or create object list")

	call rg_wcsset( imh )

	# See whether the region descriptor is a .pl file spec.
	# [If we change the code later to allow both a .pl file spec and 
	#  ASCII region descriptor, this will be a check for a .pl file spec 
	#  at the beginning of the region descriptor.]
	call rg_plfile(parsing, s, index)

	if( index != 0 ) {	# region descriptor is not a .pl file spec
	    if (!rg_parse (parsing, s[index], 0)) {
		call printf("can't parse region descriptor: %s\n")
		call pargstr(s)
		call error(EA_FATAL, "region parse failure")
	    }
	}
end


#  RG_WCSSET -- set the region descriptor coordinate system equal to 
#		the image/QPOE file coordinate system
#
procedure rg_wcsset( imh )

pointer imh			# i: pointer to xhead or NULL

include	"regparse.com"
include "rgwcs.com"

begin
	if ( imh != NULL ) {
	    rg_imh     = imh
    	    call wcstype(imh, rg_imsystem, rg_imequix, rg_imepoch)
	} else
	    rg_imsystem = NONE

	rg_system  = rg_imsystem
	rg_equix   = rg_imequix
	rg_epoch   = rg_imepoch
end


# RG_PLFILE -- check for a pl file at beginning of region descriptor
#	and process the file, if found
#
procedure rg_plfile(parsing, s, index)

pointer	parsing			# i: pointer to parsing control structure
char	s[ARB]			# i: region descriptor
int	index			# o: index where rg_parse should start, or 0

int	len			# l: length of s
pointer buf			# l: temp buf for region descriptor
pointer	fullname		# l: full name of region or pl file
pointer	tbuf			# l: temp buf for plio header
pointer	rbuf			# l: temp buf for expanded region descriptor 
				#     from plio header
pointer	openmask_req_sav	# l: hiding place for OPENMASK option pointer
pointer	expdesc_req_sav		# l: hiding place for EXPDESC option pointer
pointer	sp		        # l: stack pointer

int	strlen()		#  : string length
int	stridx()		#  : index into string
int	rg_ftype()		#  : get reg file type - pl or reg
bool	rg_any_q()		#  : see if any requests in parsing structure
bool	rg_parse()		#  : entry to the parser

begin
	if (parsing == NULL)
	    call error(EA_FATAL, "rg_plfile called without parsing request")
	if (RGPARSE_OPT(OPENMASK, parsing) == NULL  &&  
	    RGPARSE_OPT(OBJLIST , parsing) == NULL     )
	    call error(EA_FATAL, 
	 "rg_plfile called without request to open mask or create object list")

	# mark the stack
	call smark (sp)
	# allocate stack space for the title string
	call salloc (tbuf, SZ_PLHEAD, TY_CHAR)
	# allocate stack space for a temp region desc.
	len = strlen(s)
	call salloc(buf, len, TY_CHAR)
	call salloc(fullname, SZ_PATHNAME, TY_CHAR)
	# move the region descriptor to the temp
	call strcpy(s, Memc[buf], len)
	# look for a ";"
	index = stridx(";", Memc[buf])
	# end the temp string at the ";"
	if( index != 0 )
	    Memc[buf+index-1] = EOS

	# check temp string for .plio file spec
	# and process the plio file if so
	if( rg_ftype(Memc[buf], Memc[fullname], SZ_PATHNAME) ==2 ){

	    # load the plio file into the mask
	    call pl_loadf (MASKPTR(parsing), Memc[fullname], 
						Memc[tbuf], SZ_PLHEAD)

	    # temporarily hide the OPENMASK option, while we attend to others
	    openmask_req_sav = RGPARSE_OPT(OPENMASK, parsing)
	    RGPARSE_OPT(OPENMASK, parsing) = NULL

	    # if any options besides OPENMASK are requested ...
	    if (rg_any_q(parsing))  {
		# pull out expanded region descriptor from the plio header
		call rg_plstrip(Memc[tbuf], rbuf)
		# if we found an expanded region descriptor ...
		if (rbuf != NULL)  {
		    # temporarily hide EXPDESC request, to attend to others
		    expdesc_req_sav = RGPARSE_OPT(EXPDESC, parsing)
		    RGPARSE_OPT(EXPDESC, parsing) = NULL

		    # if any options besides EXPDESC (& OPENMASK) requested ...
		    if (rg_any_q(parsing))  {
			# have the parser do them
			if (!rg_parse (parsing, Memc[rbuf], 0)) {
			    call printf("can't parse region descriptor: %s\n")
			    call pargstr(Memc[rbuf])
			    call error(EA_FATAL, "region parse failure")
			}
		    }
		    # bring the EXPDESC request out of hiding
		    RGPARSE_OPT(EXPDESC, parsing) = expdesc_req_sav

		    if (RGPARSE_OPT(EXPDESC, parsing) != NULL)
			EXPDESCPTR(parsing) = rbuf
		    else
			call mfree(rbuf, TY_CHAR)
		}
	    }
	    # bring the OPENMASK request out of hiding
	    RGPARSE_OPT(OPENMASK, parsing) = openmask_req_sav

### The following was to allow ASCII descriptor to follow .pl file spec;
### it was incorrectly implemented, so disabled.
#
#	    # bump the index past the ";", if there was one
#	    if( index !=0 )
#		index = index + 1
#	    # make sure we don't have an extra ";" at end
#	    if( Memc[buf+index-1] == EOS )
###
		index = 0
	}
	# no plio file - set index to first char in string
	else
	    index = 1
	# free up stack space
	call sfree(sp)
end

#
# RG_SUMMARYADD -- add a new string to the region summary
#
procedure rg_summaryadd ( newinfo, summary )
char	newinfo[ARB]
pointer	summary

int	sumlen

int	strlen()

begin
	# how big is the new string
	sumlen = strlen (newinfo)
	# if new string is empty, do nothing
	if (sumlen <= 1) return
	# if no existing summary allocate space, else reallocate bigger space
	if (summary == NULL) {
	    call malloc (summary, sumlen, TY_CHAR)
	    call strcpy (newinfo, Memc[summary], sumlen)
	} else {
	    sumlen = sumlen + strlen(Memc[summary])
	    call realloc (summary, sumlen, TY_CHAR)
	    call strcat (newinfo, Memc[summary], sumlen)
	}
end

#
#	RGPLSTRIP -- strip out region info from plio header
#	    this code is taken from dec_plhead and should match
#	    the region stripping code found in that routine
#	It is a separate routine because of problems with the order
#	of linking!
#
# define size by which we inc the region string on retrieval
define REGION_INC	1024

procedure rg_plstrip(s, regions)

char	s[ARB]				# i: .pl file header
pointer	regions				# o: expanded region descriptor

char	lbuf[SZ_REGOUTPUTLINE]		# l: current line
char	tbuf[SZ_REGOUTPUTLINE]		# l: current token
int	fd				# l: string fd
int	rsize				# l: current size of regions str
int	rline				# l: number of region lines processed
int	rmax				# l: current max size of regions str
int	index				# l: index into string

int	stropen()			# l: string open
int	getanyline()			# l: get line from file
int	strlen()			# l: string length
int	stridx()			# l: index into string
bool	streq()				# l: string compare

begin
	regions = NULL 
	# open the plio header as a string	
	fd = stropen(s, SZ_PLHEAD, READ_ONLY)
	# read and decode each line from the string
	while( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) != EOF ){
	    # skip blank lines
	    if( lbuf[1] == '\n' )
	        next
	    # look for next keyword
	    index = stridx(":", lbuf)
	    if( index != 0 ){
	        call amovc(lbuf, tbuf, index)
	        tbuf[index] = EOS
		# point past the ":" in lbuf
		index = index + 1
		# skip white space
		for(;  IS_WHITE(lbuf[index]);  index=index+1 )
		;
	    }
	    else{
#	        call printf("warning: unknown plio header line - %s\n")
#		call pargstr(lbuf)
		# must have hit the notes section
		break
	    }	
	    # look for regions, as they are processed specially
	    if( streq(tbuf, "regions") ){
		# allocate space for region string
		rsize = 0
		rmax = REGION_INC
		call calloc(regions, rmax, TY_CHAR)
		rline = 0
		# process the region section until we hit the notes or EOF
		while( TRUE ){
		    if( rline != 0 ){
			if( getanyline(fd, lbuf, SZ_REGOUTPUTLINE) == EOF )
			    break
			# see if we hit the notes section
			if( !IS_WHITE(lbuf[1]) )
			    break
			# skip white space
			for(index=1;  IS_WHITE(lbuf[index]);  index=index+1 )
			;
		    }
		    rline = rline + 1
		    # get size of new region string
		    rsize = rsize + strlen(lbuf[index])
		    # if we don't have enough room
		    if( rsize > rmax ){
			# increase the amount of space
			rmax = rmax + REGION_INC
			call realloc (regions, rmax, TY_CHAR)
		    }
		    # concat the latest line
		    call strcat(lbuf[index], Memc[regions], rsize)
		}
		# re-alloc to the actual size of the region string
		call realloc(regions, rsize, TY_CHAR)
	    }
	    # ignore all other keywords
	    else
		;
	}
	# close the string file
	call strclose(fd)
end


procedure wcstype(imh, system, equix, epoch)

pointer	imh
int	system
double	equix
double	epoch

bool 	streq()
double	cal_tbe()

begin
	# Figure out what the image WCS reference is
	#
	if ( imh != NULL ) {
	    #switch
	         if ( streq(QP_RADECSYS(imh), "FK5") )      system = FK5
	    else if ( streq(QP_RADECSYS(imh), "FK4") )      system = FK4
	    else if ( streq(QP_RADECSYS(imh), "FK4-NO-E") ) system = FK4
	    else if ( streq(QP_RADECSYS(imh), "ECL") )      system = ECL
	    else if ( streq(QP_RADECSYS(imh), "GAL") )      system = GAL
	    else					    system = FK4

	    equix = QP_EQUINOX(imh)

	    if ( system == FK5 && equix == 2000.00 ) 
		    system = J2000

	    if( system == FK4 ) {
		epoch = cal_tbe(double(QP_MJDOBS(imh)))

		if ( equix == 1950.00 ) 
		    system = B1950
	    }
	} else {
	    system = NONE
	    equix  = 0.0
	    epoch  = 0.0
	}
end


#  RG_WCSFREE -- close the MWCS structures and free the image (or QPOE) 
#		 header structure.
#
procedure rg_wcsfree( imh )

pointer	imh			# i, o: reference QPOE file header struct

include "rgwcs.com"

begin
	if ( imh != NULL ) {
	    call mw_close(rg_imwcs)
	    call mfree(imh, TY_POINTER)
	}
end


