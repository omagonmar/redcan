# $Header: /home/pros/xray/xspatial/fixsaoreg/RCS/fixsaoreg.x,v 11.0 1997/11/06 16:33:24 prosb Exp $
# $Log: fixsaoreg.x,v $
# Revision 11.0  1997/11/06 16:33:24  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:56:03  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:16:29  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:37:25  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:22:11  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:35:36  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  14:45:41  prosb
#General Release 2.0:  April 1992
#
#Revision 1.2  92/04/23  16:22:09  dennis
#Initial version
#
#
# Module:	fixsaoreg
# Project:	PROS -- ROSAT RSDC
# Purpose:	To export an SAOimage cursor region file to PROS, or import 
#		a PROS region file to SAOimage.
# Description:	This task enables exporting a region file made with SAOimage 
#		cursors, for use in PROS tasks.  It also enables importing a 
#		region file made by a PROS task, for display within SAOimage. 
#		In the former use, the task converts the logical coordinates 
#		put out by SAOimage into the physical coordinates required 
#		for other tasks.  In the latter use, this task converts 
#		physical coordinates into logical coordinates foruse in 
#		SAOimage.
#
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} Dennis Schmidt -- initial version -- 3/92
#		{n} <who> -- <does what> -- <when>
#
#---------------------------------------------------------------------------

include	<error.h>
include <ctype.h>
include <regions.h>		# defines SZ_MASKTITLE (8192)

# 5 mutually exclusive values for state:
define	START		0
define	NORMAL		1
define	BRACKET_OPEN	2
define	DONE		3
define	ERROR		-3


procedure t_fixsaoreg()

pointer regi_fname              # l: regions input file name (cl param)
pointer rego_fname              # l: regions output file name (cl param)
pointer	tempname		# l: name for temp output file (to not clobber)
pointer regi_buf                # l: regions input line buffer
pointer img_fname_w_sect	# l: image file spec (with section) buffer
pointer img_fname		# l: image file spec (no section) buffer
bool	clobber			# l: may overwrite file (cl hidden param)
int	display			# l: display level
pointer sp                      # l: stack pointer
int     reg_ifd                 # l: regions input file handle
int     state                   # l: image file spec parser state
int     clos_bracket_count      # l: # ']'s in image file spec so far
int     regi_buf_i              # l: increment into regi_buf
int     img_fname_i             # l: increment into img_fname_w_sect
pointer im                      # l: image descriptor
pointer imw                     # l: mwcs descriptor on image
int     reg_ofd                 # l: regions output file handle

bool	clgetb()
int	clgeti()
int	strlen()
bool	streq()
int 	getline()		# l: input line from regions file
int	open()			# l: open regions input and output files
pointer immap()			# l: open image file
errchk	immap
pointer mw_openim()		# l: open mwcs descriptor on image file


begin

        call smark (sp)
        call salloc (regi_fname, SZ_PATHNAME, TY_CHAR)
        call salloc (rego_fname, SZ_PATHNAME, TY_CHAR)
	call salloc (tempname, SZ_PATHNAME, TY_CHAR)
	call salloc (regi_buf, SZ_MASKTITLE + SZ_LINE, TY_CHAR)
        call salloc (img_fname_w_sect, SZ_PATHNAME, TY_CHAR)
        call salloc (img_fname, SZ_PATHNAME, TY_CHAR)

	# Get regions input file name
	call clgstr("regions_input", Memc[regi_fname], SZ_PATHNAME)
	call rootname("", Memc[regi_fname], ".reg", SZ_PATHNAME)
	if (streq("NONE", Memc[regi_fname]) || streq("", Memc[regi_fname])) {
	    call error(EA_FATAL, "requires *.reg file as input")
	}

	# Get regions output file name
	call clgstr("regions_output", Memc[rego_fname], SZ_PATHNAME)
	call rootname(Memc[regi_fname], Memc[rego_fname], "_phy.reg", 
								SZ_PATHNAME)
	if (streq("NONE", Memc[rego_fname]) || streq("", Memc[rego_fname])) {
	    call error(EA_FATAL, "requires *.reg file as output")
	}

	# Get permission or prohibition for output to overwrite existing file
	clobber = clgetb("clobber")

	# Get display level
	display = clgeti("display")

	# Open regions input file
	reg_ifd = open(Memc[regi_fname], READ_ONLY, TEXT_FILE)
	if (reg_ifd == ERR) {
	    call error(EA_FATAL, "can't open regions input file")
	}

	if (getline (reg_ifd, Memc[regi_buf]) == EOF) {
	    call error(EA_FATAL, "regions input file is empty")
	}
	# At start of first line of regions file, look for "# <char>".

	else if (!(strlen(Memc[regi_buf]) > 3 && Memc[regi_buf] == '#' && 
		Memc[regi_buf + 1] == ' ' && !IS_WHITE(Memc[regi_buf + 2]))) {
	    call error(EA_FATAL, "regions input file isn't in SAOimage format")
	}

	# Could be SAOimage-compatible regions file;
	# Scan for image file name, starting with 3rd char on line.

	state = START
	clos_bracket_count = 0
	regi_buf_i = 2
	img_fname_i = 0

	repeat {
	    switch (Memc[regi_buf + regi_buf_i]) {
	        case '[':
	            if (state != START && state != BRACKET_OPEN && 
	                                  clos_bracket_count < 2) {
	                state = BRACKET_OPEN
	            } else {
	                state = ERROR
	            }
	        case ']':
	            if (state == BRACKET_OPEN) {
	                clos_bracket_count = clos_bracket_count + 1
	                state = NORMAL
	            } else {
	                state = ERROR
	            }
	        case ' ', '\t':
	            if (state == START) {
	                state = ERROR
	            } else if (state != BRACKET_OPEN) {
	                state = DONE
	            }
	        case '\n':
	            if (state == START || state == BRACKET_OPEN) {
	                state = ERROR
	            } else {
	                state = DONE
	            }
	        default:
	            if (state == START) {
	                state = NORMAL
	            } else if (clos_bracket_count >= 2) {
	                state = DONE
	            }
	    }
	    if (state != ERROR && state != DONE) {
	        Memc[img_fname_w_sect + img_fname_i] = 
						Memc[regi_buf + regi_buf_i]
	        img_fname_i = img_fname_i + 1
	        if (img_fname_i >= SZ_PATHNAME) {
	            state = ERROR
	        }
	        regi_buf_i = regi_buf_i + 1
	    }
	} until (state == ERROR || state == DONE)

	if (state == ERROR) {
	    call error(EA_FATAL, 
			"invalid image file name in regions input file")
	}

	Memc[img_fname_w_sect + img_fname_i] = EOS

	# Strip off image section info, if any
	call imgimage(Memc[img_fname_w_sect], Memc[img_fname], SZ_PATHNAME)

	# Develop image file name [Is this necessary?]
	call rootname ("", Memc[img_fname],"", SZ_PATHNAME)

	# Open image file
	im = immap (Memc[img_fname], READ_ONLY, 0)

	# Open MWCS descriptor on image
	imw = mw_openim(im)


	# Open output regions file reg_ofd
	call clobbername(Memc[rego_fname], Memc[tempname], clobber, 
								SZ_PATHNAME)
	reg_ofd = open(Memc[tempname], NEW_FILE, TEXT_FILE)
	if (reg_ofd == ERR) {
	    call error(EA_FATAL, "can't open regions output file")
	}

	# Put out 1st line to regions output file:  1st line of input file, 
	#	except image file name has section spec stripped off
	call fprintf(reg_ofd, "# %s%s")
	call pargstr(Memc[img_fname])
	call pargstr(Memc[regi_buf + regi_buf_i])

	# Scan the rest of the regions file, applying the transformation
	call cscan_saoreg(reg_ifd, reg_ofd, Memc[regi_buf], imw)


	# Clean up.

	if( display >= 1){
	    call printf("Writing regions output file: %s\n")
	    call pargstr(Memc[rego_fname])
	}
	call finalname(Memc[tempname], Memc[rego_fname])

	call close(reg_ofd)
	call mw_close(imw)
	call imunmap(im)
	call close(reg_ifd)
	call sfree(sp)

end
