# $Header: /home/pros/xray/lib/regions/RCS/regcontrol.x,v 11.0 1997/11/06 16:19:01 prosb Exp $
# $Log: regcontrol.x,v $
# Revision 11.0  1997/11/06 16:19:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:26:01  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  13:43:56  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:07:12  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  15:37:52  prosb
#General Release 2.2
#
#Revision 1.2  93/05/05  00:37:48  dennis
#In rg_objlist_rel(), corrected handling of shape (FIELD) with no arguments.
#
#Revision 1.1  93/04/26  23:58:47  dennis
#Initial revision
#
#
# Module:	regcontrol.x
# Project:	PROS -- ROSAT RSDC
#
# Purpose:	library of routines for setting up, inquiring about, and 
#		releasing region descriptor parsing requests
#
# External:	to initiate and terminate use of the parser:
#		rg_open_parser(), rg_close_parser();
#
#		to set up and release requests for specific services:
#		rg_expdesc_req(), rg_expdesc_rel();
#		rg_objlist_req(), rg_objlist_rel();
#		rg_newcoords_req(), rg_newcoords_rel();
#		rg_oneregnotes_req(), rg_oneregnotes_rel();
#		rg_openmask_req(), rg_openmask_rel();
#
#		to allocate request-specific structures:
#		rg_alloc_obj(), rg_alloc_note();
#
#		to query what kinds of requests are in effect:
#		rg_make_mask_q(), rg_execute_q(), rg_compile_q(), 
#		rg_coords_q(), rg_any_q().
#
# Description:	The conventions for using these routines are described in a 
#		separate document.
#
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
#


include	<pmset.h>
include	<error.h>
include	<regparse.h>

#
# RG_OPEN_PARSER -- allocate and initialize parsing control structure
#
pointer procedure rg_open_parser()

pointer	parsing		# l: returned: pointer to parsing control structure
int	i		# l: option index

begin
	call malloc(parsing, N_RGPARSE_OPTIONS, TY_STRUCT)
	for (i = 1;  i <= N_RGPARSE_OPTIONS;  i = i + 1)
	    RGPARSE_OPT(i, parsing) = NULL
	return(parsing)
end

#
# RG_EXPDESC_REQ -- allocate and initialize request for expanded region 
#		    descriptor
#
bool procedure rg_expdesc_req(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	new_expdesc_req		# l: returned: true if no higher level routine 
				#    has already requested expanded descriptor

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
		"rg_expdesc_req() called with no parsing control structure\n")

	new_expdesc_req = (RGPARSE_OPT(EXPDESC, parsing) == NULL)
	if (new_expdesc_req) {
	    call malloc(RGPARSE_OPT(EXPDESC, parsing), LEN_EXPDESC_STRUCT,
			TY_STRUCT)
	}
	# We will allocate space for the resultant string as we make it ...
	EXPDESCPTR(parsing) = NULL

	# ... but set up a working buffer (for 1 command at a time) now
	call malloc(EXPDESCLPTR(parsing), SZ_REGOUTPUTLINE, TY_CHAR)
	call strcpy("", EXPDESCLBUF(parsing), SZ_REGOUTPUTLINE)

	return(new_expdesc_req)
end

#
# RG_EXPDESC_REL -- free expanded region descriptor buffers, and the structure 
#                   that controlled the request for it
#
procedure rg_expdesc_rel(parsing)

pointer	parsing			# i: pointer to parsing control structure

begin
	if (parsing != NULL) {
	    if (RGPARSE_OPT(EXPDESC, parsing) != NULL) {
		call mfree(EXPDESCLPTR(parsing), TY_CHAR)
		call mfree(EXPDESCPTR(parsing), TY_CHAR)
		call mfree(RGPARSE_OPT(EXPDESC, parsing), TY_STRUCT)
	    }
	}
end

#
# RG_OBJLIST_REQ -- allocate and initialize request for region object list
#
bool procedure rg_objlist_req(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	new_objlist_req		# l: returned: true if no higher level routine 
				#    has already requested object list

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
		"rg_objlist_req() called with no parsing control structure\n")

	new_objlist_req = (RGPARSE_OPT(OBJLIST, parsing) == NULL)
	if (new_objlist_req) {
	    call malloc(RGPARSE_OPT(OBJLIST, parsing), LEN_OBJLIST_STRUCT,
			TY_STRUCT)
	}
	OBJLISTPTR(parsing) = NULL
	LASTOBJPTR(parsing) = NULL
	return(new_objlist_req)
end

#
# RG_ALLOC_OBJ -- allocate and initialize a new region object structure, and 
#                 append it to the object list attached to a parsing control 
#                 structure
#
pointer procedure rg_alloc_obj(parsing)

pointer	parsing			# i: pointer to parsing control structure

pointer	obj			# l: pointer to new object structure

begin
	if (parsing == NULL)
	    return (NULL)

	if (RGPARSE_OPT(OBJLIST, parsing) == NULL)
	    return (NULL)

	call malloc(obj, LEN_VOBJ, TY_STRUCT)

	# initialize pointer to next object
	V_NEXT(obj)           = NULL

	# append the new object to the list
	if (OBJLISTPTR(parsing) == NULL)
	    OBJLISTPTR(parsing) = obj
	else
	    V_NEXT(LASTOBJPTR(parsing)) = obj
	LASTOBJPTR(parsing) = obj

	# initialize values

	V_INCL(obj)           = INCLUDE

	# multi region control structures
	M_ITER(V_SLICES(obj)) = 1
	M_INST(V_SLICES(obj)) = 0
	M_ITER(V_ANNULI(obj)) = 1
	M_INST(V_ANNULI(obj)) = 0

	# the virtual CPU program
	V_NINSTS(obj)         = 0
	V_METAPTR(obj)        = NULL

	return (obj)
end

#
# RG_OBJLIST_REL -- free region object list, and the structure that controlled 
#                   the request for it
#
procedure rg_objlist_rel(parsing)

pointer	parsing			# i: pointer to parsing control structure

pointer	obj			# l: pointer to current object structure
pointer	next_obj		# l: pointer to next object structure
int	vpc			# l: virtual CPU program counter

begin
	if (parsing != NULL) {
	    if (RGPARSE_OPT(OBJLIST, parsing) != NULL) {
		# turn to the first object structure
		obj = OBJLISTPTR(parsing)
		# free the object structures, one by one
		while (obj != NULL) {
		    # go through the metacode instructions, one by one
		    for (vpc = 1;  vpc <= V_NINSTS(obj);  vpc = vpc + 1) {
			# check for an associated reg structure
			if (V_INST(vpc, obj) == OP_NEW) {
			    if (R_ARGC(V_ARG1(vpc, obj)) > 0) {
				# free the processed arg list for this reg
				call mfree(R_ARGV(V_ARG1(vpc, obj)), TY_REAL)
			    }
			    # free the reg structure
			    call mfree(V_ARG1(vpc, obj), TY_STRUCT)
			}
		    }
		    # free the virtual CPU program
		    call mfree(V_METAPTR(obj), TY_INT)
		    # get pointer to next object before releasing this one
		    next_obj = V_NEXT(obj)
		    # free this obj structure
		    call mfree(obj, TY_STRUCT)
		    # turn to the next one
		    obj = next_obj
		}
		call mfree(RGPARSE_OPT(OBJLIST, parsing), TY_STRUCT)
	    }
	}
end

#
# RG_NEWCOORDS_REQ -- allocate and initialize request for region descriptor 
#		      with transformed coordinates
#
### NOTE:  This option has not been implemented yet; the final form of the 
###        request structure is uncertain.

bool procedure rg_newcoords_req(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	new_newcoords_req	# l: returned: true if no higher level routine 
				#    has already requested transformed coords

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
		"rg_newcoords_req() called with no parsing control structure\n")

	new_newcoords_req = (RGPARSE_OPT(NEWCOORDS, parsing) == NULL)
	if (new_newcoords_req) {
	    call malloc(RGPARSE_OPT(NEWCOORDS, parsing), LEN_NEWCOORDS_STRUCT,
			TY_STRUCT)
	}
	### SELCOORDS(parsing), MWCSDESC(parsing) initialized here?

	# We will allocate space for the resultant string as we make it ...
	NEWCOORDSPTR(parsing) = NULL

	# ... but set up a working buffer (for 1 command at a time) now
	call malloc(NEWCOORDSLPTR(parsing), SZ_REGOUTPUTLINE, TY_CHAR)
	call strcpy("", NEWCOORDSLBUF(parsing), SZ_REGOUTPUTLINE)
	return(new_newcoords_req)
end

#
# RG_NEWCOORDS_REL -- free buffers for region descriptor with transformed 
#                     coordinates, and the structure that controlled the 
#                     request for it
#
procedure rg_newcoords_rel(parsing)

pointer	parsing			# i: pointer to parsing control structure

begin
	if (parsing != NULL) {
	    if (RGPARSE_OPT(NEWCOORDS, parsing) != NULL) {
		call mfree(NEWCOORDSLPTR(parsing), TY_CHAR)
		call mfree(NEWCOORDSPTR(parsing), TY_CHAR)
		### Be sure MWCSDESC(parsing) isn't abandoned
		call mfree(RGPARSE_OPT(NEWCOORDS, parsing), TY_STRUCT)
	    }
	}
end

#
# RG_ONEREGNOTES_REQ -- allocate and initialize request for region-by-region 
#                       notes
#
bool procedure rg_oneregnotes_req(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	new_oneregnotes_req	# l: returned: true if no higher level routine 
				#  has already requested region-by-region notes

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
		"rg_oneregnotes_req() called with no parsing control structure\n")

	new_oneregnotes_req = (RGPARSE_OPT(ONEREGNOTES, parsing) == NULL)
	if (new_oneregnotes_req) {
	    call malloc(RGPARSE_OPT(ONEREGNOTES, parsing), 
					LEN_ONEREGNOTES_STRUCT, TY_STRUCT)
	}
	ONEREGNOTESPTR(parsing) = NULL
	LASTONEREGNOTEPTR(parsing) = NULL
	ANNPIEFLAGS(parsing) = 0
	return(new_oneregnotes_req)
end

#
# RG_ALLOC_NOTE -- allocate and initialize a new 1-region note structure, 
#                  and append it to the list of single-region notes 
#                  attached to a parsing control structure
#
pointer procedure rg_alloc_note(parsing)

pointer	parsing			# i: pointer to parsing control structure

pointer	note			# l: pointer to new note structure

begin
	if (parsing == NULL)
	    return (NULL)

	if (RGPARSE_OPT(ONEREGNOTES, parsing) == NULL)
	    return (NULL)

	call malloc(note, LEN_ONEREGNOTE, TY_STRUCT)

	# initialize pointer to the next note structure
	ORN_NEXT(note) = NULL

	# append the new note structure to the list
	if (ONEREGNOTESPTR(parsing) == NULL)
	    ONEREGNOTESPTR(parsing) = note
	else
	    ORN_NEXT(LASTONEREGNOTEPTR(parsing)) = note
	LASTONEREGNOTEPTR(parsing) = note

	# allocate descriptor string buffer and initialize it to an 
	#  empty string
	call malloc(ORN_DESCPTR(note), SZ_ONEREGDESC, TY_CHAR)
	call strcpy("", ORN_DESCBUF(note), SZ_ONEREGDESC)

	# initialize annulus and pie limits
	ORN_BEGANN(note) = 0.
	ORN_ENDANN(note) = 0.
	ORN_BEGPIE(note) = 0.
	ORN_ENDPIE(note) = 0.

	return (note)
end

#
# RG_ONEREGNOTES_REL -- free region-by-region notes buffers, and the structure 
#                       that controlled the request for them
#
procedure rg_oneregnotes_rel(parsing)

pointer	parsing			# i: pointer to parsing control structure

pointer	note			# l: pointer to current note structure
pointer	next_note		# l: pointer to next note structure

begin
	if (parsing != NULL) {
	    if (RGPARSE_OPT(ONEREGNOTES, parsing) != NULL) {
		# turn to the first note structure
		note = ONEREGNOTESPTR(parsing)
		# free the notes, one by one
		while (note != NULL) {
		    # free the descriptor string buffer
		    call mfree(ORN_DESCPTR(note), TY_CHAR)
		    # get pointer to next note before releasing this one
		    next_note = ORN_NEXT(note)
		    # free this note structure
		    call mfree(note, TY_STRUCT)
		    # turn to the next one
		    note = next_note
		}
		call mfree(RGPARSE_OPT(ONEREGNOTES, parsing), TY_STRUCT)
	    }
	}
end

#
# RG_OPENMASK_REQ -- allocate and initialize request to open a mask
#
bool procedure rg_openmask_req(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	new_openmask_req	# l: returned: true if no higher level routine 
				#    has already requested opening a mask

begin
	if (parsing == NULL)
	    call error(EA_FATAL, 
		"rg_openmask_req() called with no parsing control structure\n")

	new_openmask_req = (RGPARSE_OPT(OPENMASK, parsing) == NULL)
	if (new_openmask_req) {
	    call malloc(RGPARSE_OPT(OPENMASK, parsing), LEN_OPENMASK_STRUCT,
			TY_STRUCT)
	}
	SELPLPM(parsing) = MSKTY_PL
	MASKPTR(parsing) = NULL
	REGNUM(parsing) = 1
	return(new_openmask_req)
end

#
# RG_OPENMASK_REL -- close mask, and free the structure that controlled 
#                    the request to open it
#
procedure rg_openmask_rel(parsing)

pointer	parsing			# i: pointer to parsing control structure

begin
	if (parsing != NULL) {
	    if (RGPARSE_OPT(OPENMASK, parsing) != NULL) {
		if (SELPLPM(parsing) == MSKTY_PL)
		    call pl_close(MASKPTR(parsing))
		else if (SELPLPM(parsing) == MSKTY_PM)
		    call pm_close(MASKPTR(parsing))
		else
		    call error(EA_FATAL, 
			"OPENMASK request contained invalid file type\n")
		call mfree(RGPARSE_OPT(OPENMASK, parsing), TY_STRUCT)
	    }
	}
end

#
# RG_MAKE_MASK_Q -- return whether creating a mask; i.e., whether OPENMASK 
#                   is requested
#
bool procedure rg_make_mask_q(parsing)

pointer	parsing			# i: pointer to parsing control structure

begin
	if (parsing == NULL)
	    return(false)

	return( RGPARSE_OPT(OPENMASK, parsing) != NULL )
end

#
# RG_EXECUTE_Q -- return whether to execute virtual CPU programs, 
#                 according to which parsing options are selected
#
bool procedure rg_execute_q(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	rg_make_mask_q()	#  : whether creating a mask

begin
	if (parsing == NULL)
	    return(false)

	return( rg_make_mask_q(parsing) || 
	        (RGPARSE_OPT(ONEREGNOTES, parsing) != NULL) )
end

#
# RG_COMPILE_Q -- return whether to set up virtual CPU programs, 
#                 according to which parsing options are selected
#
bool procedure rg_compile_q(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	rg_execute_q()		#  : whether executing virtual CPU programs

begin
	if (parsing == NULL)
	    return(false)

	return( rg_execute_q(parsing) || 
	        (RGPARSE_OPT(OBJLIST, parsing) != NULL) )
end

#
# RG_COORDS_Q -- return whether to interpret coordinate system information 
#                in the region descriptor
#
bool procedure rg_coords_q(parsing)

pointer	parsing			# i: pointer to parsing control structure

bool	rg_compile_q()		#  : whether compiling virtual CPU programs

begin
	if (parsing == NULL)
	    return(false)

	return( rg_compile_q(parsing) || 
	        (RGPARSE_OPT(NEWCOORDS, parsing) != NULL) )
end

#
# RG_ANY_Q -- return whether the parsing control structure has any options set
#
bool procedure rg_any_q(parsing)

pointer	parsing			# i: pointer to parsing control structure

int	optnum			# l: option number (loop index)

begin
	if (parsing == NULL)
	    return(false)

	for (optnum = 1;  optnum <= N_RGPARSE_OPTIONS;  optnum = optnum + 1)
	    if (RGPARSE_OPT(optnum, parsing) != NULL)
		return (true)
	return (false)
end

#
# RG_CLOSE_PARSER -- release any structures and buffers attached to the 
#		     parsing control structure, and the control structure 
#		     itself
#
procedure rg_close_parser(parsing)

pointer	parsing			# i,o: pointer to parsing control structure

begin
	# Go through each option (don't use a loop), releasing everything
	call rg_expdesc_rel(parsing)
	call rg_objlist_rel(parsing)
	call rg_newcoords_rel(parsing)
	call rg_oneregnotes_rel(parsing)
	call rg_openmask_rel(parsing)

	# Free the parsing control structure itself
	call mfree(parsing, TY_STRUCT)
end
