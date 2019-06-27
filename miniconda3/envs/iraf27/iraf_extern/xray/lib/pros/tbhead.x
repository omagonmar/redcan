#$Header: /home/pros/xray/lib/pros/RCS/tbhead.x,v 11.0 1997/11/06 16:21:12 prosb Exp $
#$Log: tbhead.x,v $
#Revision 11.0  1997/11/06 16:21:12  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:22  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:47:20  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:47  prosb
#General Release 2.3
#
#Revision 6.2  93/12/08  01:27:38  dennis
#Mo's earlier fix to remove '\n' from end of each region descriptor string 
#was also needed to do the same to each note string.
#
#Revision 6.1  93/12/07  22:40:20  dennis
#Checked out unnecessarily to correct a problem with mask summary header 
#parameters.
#
#Revision 6.0  93/05/24  15:54:16  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:04:32  mo
#MC	5/20/93		Fix TABLE files with extra <CR> in header that
#			kill the FITS writer.
#
#Revision 5.0  92/10/29  21:17:31  prosb
#General Release 2.1
#
#Revision 4.1  92/09/02  03:00:30  dennis
#In put_tbh(), changed buffer sizes of region[], note[], name[], file[].
#Now use getanyline() to read in region and note.
#
#Revision 4.0  92/04/27  13:50:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.3  92/04/14  03:31:27  dennis
#Corrected change made in Rev. 3.1
#
#Revision 3.2  92/04/13  14:36:31  mo
#MC	4/13/92		Don't die if there is no PROS/regions
#			notes info in the QPOE header
#			( Meanwhile fix qpcdefs to make sure that
#			  it does get written to the header correctly )
#
#Revision 3.1  92/04/10  18:14:07  dennis
#Accept .pl file without ASCII region descriptor
#
#Revision 3.0  91/08/02  01:02:16  wendy
#General
#
#Revision 2.0  91/03/07  00:07:33  pros
#General Release 1.0
#
# Module:       TBHEAD.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      ROutines to manipulate the table header
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC  -- Update include files  -- 2/91
#               {n} <who> -- <does what> -- <when>

include <ctype.h>

include <plhead.h>
include	<regparse.h>	# Defines SZ_REGOUTPUTLINE, SZ_2PATHNAMESPLUS

#
# PUT_TBH -- fill in header parameters in a table
#
procedure put_tbh(tp, heading, imname, plhead)

pointer	tp				# i: table pointer
char	heading[ARB]			# i: name of image parameter
char	imname[ARB] 			# i: image name
char	plhead[ARB]			# i: plio header string
#char	expname[ARB]			# i: exposure name
#real	thresh				# i: exposure threshold

char	buf[SZ_LINE]			# l: temp char buffer
char	region[SZ_REGOUTPUTLINE]	# l: temp char buffer for regions
char	note[SZ_REGOUTPUTLINE]		# l: temp char buffer for notes
char	cc				# l: temp char
int	gothead				# l: flag that we have a valid heading
int	i, j				# l: counters
int	fd				# l: string fd
pointer	sp				# l: stack pointer

# dec_plhead variables
char	name[SZ_2PATHNAMESPLUS]		# l: mask name
int	nlen				# l: len of name string
char	type[SZ_LINE]			# l: mask type (region, exposure, etc.)
int	tlen				# l: len of type string
char	file[SZ_PATHNAME]		# l: reference file name
int	ilen				# l: length of file string (for dec_pl)
int	xdim				# l: x dimension of mask
int	ydim				# l: y dimension of mask
real	scale				# l: scale factor used to make the mask
pointer	regions				# l: region summary pointer
pointer	notes				# l: notes at end of plio header string

int	stropen()			# l: string oen
int	strlen()			# l: string oen
int	getanyline()			# l: get line from file
bool	streq()				# l: string compare

begin
	# mark the stack
	call smark(sp)

	# we use the heading in certain param names if, it is non-null
	if( streq(heading, "") )
	    gothead = NO
	else
	    gothead = YES

	# add a comment at the beginning
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "The following is information about the %s mask:")
	    call pargstr(heading)
	    call tbhadt(tp, "comment", buf)
	}

	# add the image name
	if( gothead == YES )
	    call tbhadt(tp, heading, imname)
	else
	    call tbhadt(tp, "image", imname)

	# decode the plio header string
	nlen = SZ_2PATHNAMESPLUS
	tlen = SZ_LINE
	ilen = SZ_PATHNAME
	call dec_plhead(plhead, name, nlen, type, tlen, file, ilen,
			xdim, ydim, scale, regions, notes)

	# add plio image to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_plna")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_name", buf, SZ_LINE)
	}
	call tbhadt(tp, buf, name)

	# add plio type to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_plty")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_type", buf, SZ_LINE)
	}
	call tbhadt(tp, buf, type)

	# add plio aux files to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_plfi")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_files", buf, SZ_LINE)
	}
	call tbhadt(tp, buf, file)

	# add plio xdim to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_plx")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_xdim", buf, SZ_LINE)
	}
	call tbhadi(tp, buf, xdim)

	# add plio ydim to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_ply")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_ydim", buf, SZ_LINE)
	}
	call tbhadi(tp, buf, xdim)

	# add plio scale to table header
	if( gothead == YES ){
	    call sprintf(buf, SZ_LINE, "%.3s_plsc")
	    call pargstr(heading)
	}
	else{
	    call strcpy("pl_scale", buf, SZ_LINE)
	}
	call tbhadr(tp, buf, scale)

	if (regions != NULL) {
	    # add the regions
	    call tbhadt(tp, "comment", "Regions:")
	    # open the regions as a string	
	    fd = stropen(Memc[regions], SZ_PLHEAD, READ_ONLY)
	    # add each one to header ...
	    # read each line from the string
	    i = 0
	    j = 0
	    # add each one to header ...
	    while( getanyline(fd, region, SZ_REGOUTPUTLINE) != EOF ){
#  Mo's fix - the '\n' should not be put in table header
		ilen = strlen(region)
		if( region[ilen] == '\n')
		    region[ilen] = NULL
# end Mo's fix
		if( region[1] != '-' ){
		    if( gothead == YES ){
			call sprintf(buf, SZ_LINE, "%.3s_%c")
			call pargstr(heading)
			cc = 'A' + i
			call pargc(cc)
		    }
		    else{
			call sprintf(buf, SZ_LINE, "reg_%c")
			cc = 'A' + i
			call pargc(cc)
		    }
		    i = i+1
		}
		else{
		    if( gothead == YES ){
			call sprintf(buf, SZ_LINE, "-%.3s_%c")
			call pargstr(heading)
			cc = 'A' + j
			call pargc(cc)
		    }
		    else{
			call sprintf(buf, SZ_LINE, "-reg_%c")
			cc = 'A' + j
			call pargc(cc)
		    }
		    j = j+1
		}
		call tbhadt(tp, buf, region)
	    }
#	    while( getline(fd, region) != EOF )
#		call tbhadt(tp, "comment", region)
	    # close the string file
	    call strclose(fd)
	}

	# add the notes
	call tbhadt(tp, "comment", "Notes:")
	# open the notes as a string - if notes not allocated ( =0 ) there
	#   are no notes	
	if( notes != 0 ){
	    fd = stropen(Memc[notes], SZ_PLHEAD, READ_ONLY)
	    # add each one to header ...
	    while( getanyline(fd, note, SZ_REGOUTPUTLINE) != EOF ) {
#  Dennis's fix, copying Mo's  - the '\n' should not be put in table header
		ilen = strlen(note)
		if( note[ilen] == '\n')
		    note[ilen] = NULL
# end Dennis's fix
	        call tbhadt(tp, "comment", note)
	    }
	    # close the string file
	    call strclose(fd)
	}

	# and free the space
	call mfree(regions, TY_CHAR)
	call mfree(notes, TY_CHAR)
	call sfree(sp)
end

