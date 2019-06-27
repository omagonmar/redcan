# Copyright(c) 1986 Association of Universities for Research in Astronomy Inc.

include	<error.h>
include	<evexpr.h>
include	<imset.h>
include	<ctype.h>
include	<lexnum.h>

define	LEN_USERAREA	28800		# allow for the largest possible header
define	SZ_IMAGENAME	63		# max size of an image name
define	SZ_FIELDNAME	31		# max size of a field name
define  HRECLEN         80

define	OP_EDIT		1		# hedit opcodes
define	OP_INIT		2		
define	OP_ADD		3
define	OP_DELETE	4
define  OP_DEFPAR       5
define  BEFORE		1
define  AFTER           2


# HEDIT -- Edit or view selected fields of an image header or headers.  This
# editor performs a single edit operation upon a relation, e.g., upon a set
# of fields of a set of images.  Templates and expressions may be used to 
# automatically select the images and fields to be edited, and to compute
# the new value of each field.

procedure t_nhedit()

pointer	fields			# template listing fields to be processed
pointer	valexpr			# the value expression (if op=edit|add)

bool	noupdate, quit
int	imlist, nfields, up, min_lenuserarea
pointer	sp, field, sections, s_fields, im, ip, image, buf
pointer s_comm, cmd, pkey
int	operation, verify, show, update, comfile, fd, baf
int     def_pars, dp_oper, dp_update, dp_verify, dp_show	
char    sharp

pointer	immap()
bool    streq()
int	imtopenp(), imtgetim(), getline()
int	envfind(), ctoi(), open()

begin
	call smark (sp)
	call salloc (buf,       SZ_FNAME, TY_CHAR)
	call salloc (image,     SZ_FNAME, TY_CHAR)
	call salloc (field,     SZ_FNAME, TY_CHAR)
	call salloc (fields,     SZ_FNAME, TY_CHAR)
	call salloc (pkey,      SZ_FNAME, TY_CHAR)
	call salloc (s_fields,  SZ_LINE,  TY_CHAR)
	call salloc (valexpr,   SZ_LINE,  TY_CHAR)
	call salloc (s_comm,    SZ_LINE,  TY_CHAR)
	call salloc (sections,  SZ_FNAME, TY_CHAR)
	call salloc (cmd,       SZ_LINE, TY_CHAR)

	# Get the primary operands.
	imlist = imtopenp ("images")

	# Determine type of operation to be performed.  The default operation
	# is edit.

	# Do we have a command file instead of a command line?
	comfile=NO
	fd = 0
        call clgstr ("comfile", Memc[s_fields], SZ_LINE)
        if (streq(Memc[s_fields], "NULL")) {
	    call he_getpars (operation, fields, valexpr, Memc[s_comm], 
	        Memc[pkey], baf, update, verify, show)
        } else {
	    comfile = YES
	    update=YES
            # Set default parameters
            def_pars = NO
	    dp_oper = OP_EDIT
	    dp_update = YES
            dp_verify = NO
            dp_show = NO
	    fd = open(Memc[s_fields], READ_ONLY, TEXT_FILE)
        }

	# Main processing loop.  An image is processed in each pass through
	# the loop.

	while (imtgetim (imlist, Memc[image], SZ_FNAME) != EOF) {

	    # set the length of the user area
	    if (envfind ("min_lenuserarea", Memc[sections], SZ_FNAME) > 0) {
		up = 1
		if (ctoi (Memc[sections], up, min_lenuserarea) <= 0)
		    min_lenuserarea = LEN_USERAREA
		else
		    min_lenuserarea = max (LEN_USERAREA, min_lenuserarea)
	    } else
		min_lenuserarea = LEN_USERAREA

	    # Open the image.
	    iferr {
		if (update == YES)
		    im = immap (Memc[image], READ_WRITE, min_lenuserarea)
		else
		    im = immap (Memc[image], READ_ONLY,  min_lenuserarea)
	    } then {
		call erract (EA_WARN)
		next
	    }
            
	    sharp = '#'
	    if (comfile == YES) {
	        # Open the command file and start processing each line. 
                #rewind file before  proceeding

	        call seek(fd, BOF)
                while (getline(fd, Memc[cmd]) != EOF) {
		    for (ip=cmd;  IS_WHITE(Memc[ip]);  ip=ip+1)
			    ;
		    if (Memc[cmd] == sharp || Memc[ip] == '\n')
		        next
                    #fields = s_fields
	            #valexpr = s_valexpr
                    call he_getcmdf (Memc[cmd], operation, Memc[fields],
		        Memc[valexpr], Memc[s_comm], Memc[pkey], baf, 
			update, verify, show)

                    if (operation < 0) {
                        # Set the default parameters for the rest of the
		        # command file.

                        call he_setdef (operation, dp_oper, dp_update, 
			   dp_verify, dp_show, update, verify, show)
			def_pars = YES
                        next
		    }
                    # Set the parameters for the current command, the
                    # command parameters take precedence over the defaults.

                    call he_setpar (operation, dp_oper, dp_update, 
			   dp_verify, dp_show, update, verify, show)

                    call he_doit (im, Memc[image], operation, Memc[fields],
	                Memc[valexpr], Memc[s_comm], Memc[pkey], baf, 
			update, verify, show, nfields)
                } #end while    
            } else {
                call he_doit (im, Memc[image], operation, Memc[fields],
	            Memc[valexpr], Memc[s_comm], Memc[pkey], baf, update,
		    verify, show, nfields)
            }
	    # Update the image header and unmap the image.

	    noupdate = false
	    quit = false

	    if (update == YES) {
		if (nfields == 0 && fd == 0)
		    noupdate = true
		else if (verify == YES) {
		    call eprintf ("update %s ? (yes): ")
			call pargstr (Memc[image])
		    call flush (STDERR)

		    if (getline (STDIN, Memc[buf]) == EOF)
			noupdate = true
		    else {
			# Strip leading whitespace and trailing newline.
			for (ip=buf;  IS_WHITE(Memc[ip]);  ip=ip+1)
			    ;
			if (Memc[ip] == 'q') {
			    quit = true
			    noupdate = true
			} else if (! (Memc[ip] == '\n' || Memc[ip] == 'y'))
			    noupdate = true
		    }
		}

		if (noupdate) {
		    call imseti (im, IM_WHEADER, NO)
		    call imunmap (im)
		} else {
		    call imunmap (im)
		    if (show == YES) {
			call printf ("%s updated\n")
			    call pargstr (Memc[image])
		    }
		}
	    } else {
		call imunmap (im)
	    }

	    call flush (STDOUT)
	    if (quit)
		break
	} #end of while

	# Close command file
        if (comfile == YES)
            call close(fd)
	call imtclose (imlist)
	call sfree (sp)
end


# HE_DOIT -- 

procedure he_doit (im, image, operation, keyws, exprs, comment, pkey, baf,
	                   update, verify, show, nfields)

pointer im		#I image descriptor
char    image[ARB]      #  
int	operation	#I operation code
char    keyws[ARB]      # Memc[fields]
char    exprs[ARB]	# Memc[valexpr]
char    comment[ARB]	# Memc[s_comm]
char    pkey[ARB]	# 
int	baf
int	update
int	verify
int	show
int	nfields

pointer sp, field
int	imgnfn(), imofnlu()
int	flist

begin

	call smark(sp)
	call salloc (field, SZ_FNAME, TY_CHAR)
	   
	if (operation == OP_INIT || operation == OP_ADD) {
	    # Add a field to the image header.  This cannot be done within
	    # the IMGNFN loop because template expansion on the existing
	    # fields of the image header would discard the new field name
	    # since it does not yet exist.

	    nfields = 1
	    call he_getopsetimage (im, image, Memc[field])
	    switch (operation) {
	    case OP_INIT:
	        call he_initfield (im, image, keyws, exprs, comment, 
		    pkey, baf, verify, show, update)
	    case OP_ADD:
	        call he_addfield (im, image, keyws, exprs, comment,
		    pkey, baf, verify, show, update)
	    }
	} else {
	    # Open list of fields to be processed.
	    flist = imofnlu (im, keyws)
		nfields = 0
		while (imgnfn (flist, Memc[field], SZ_FNAME) != EOF) {
		    call he_getopsetimage (im, image, Memc[field])

		    switch (operation) {
		    case OP_EDIT:
			call he_editfield (im, image, Memc[field],
			    exprs, comment, verify, show, update)
		    case OP_DELETE:
			call he_deletefield (im, image, Memc[field],
			    exprs, verify, show, update)
		    }
		    nfields = nfields + 1
		}

		call imcfnl (flist)
	    }
	call sfree(sp)
end


# HE_EDITFIELD -- Edit the value of the named field of the indicated image.
# The value expression is evaluated, interactively inspected if desired,
# and the resulting value put to the image.

procedure he_editfield (im, image, field, valexpr, comment, verify, 
    show, update)

pointer	im			# image descriptor of image to be edited
char	image[ARB]		# name of image to be edited
char	field[ARB]		# name of field to be edited
char	valexpr[ARB]		# value expression
char	comment[ARB]		# keyword comment
int	verify			# verify new value interactively
int	show			# print record of edit
int	update			# enable updating of the image

int	goahead, nl
pointer	sp, ip, oldval, newval, defval, o, fcomm, ncomm

bool	streq()
pointer	evexpr()
extern	he_getop()
int	getline(), imaccf(), strldxs(), locpr()
errchk	evexpr, getline, imaccf, he_gval

begin
	call smark (sp)
	call salloc (oldval, SZ_LINE, TY_CHAR)
	call salloc (newval, SZ_LINE, TY_CHAR)
	call salloc (defval, SZ_LINE, TY_CHAR)
	call salloc (fcomm, HRECLEN, TY_CHAR)
	call salloc (ncomm, HRECLEN, TY_CHAR)

	call strcpy (comment, Memc[ncomm], HRECLEN)

	# Verify that the named field exists before going any further.
	if (field[1] != '$')
	    if (imaccf (im, field) == NO) {
		call eprintf ("parameter %s,%s not found\n")
		    call pargstr (image)
		    call pargstr (field)
		call sfree (sp)
		return
	    }

	# Get the old value.
	call he_gval (im, image, field, Memc[oldval], SZ_LINE)

	# Evaluate the expression.  Encode the result operand as a string.
	# If the expression is not parenthesized, assume that is is already
	# a string literal.

	if (valexpr[1] == '(') {
	    o = evexpr (valexpr, locpr (he_getop), 0)
	    call he_encodeop (o, Memc[newval], SZ_LINE)
	    call xev_freeop (o)
	    call mfree (o, TY_STRUCT)
	} else
	    call strcpy (valexpr, Memc[newval], SZ_LINE)

	call imgcom (im, field, Memc[fcomm])
	if (streq (Memc[newval], ".") && streq (comment, ".")) {
	    # Merely print the value of the field.

	    if (Memc[fcomm] == EOS) {
	    	call printf ("%s,%s = %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstr (Memc[oldval])
            } else {
	        call strcpy (Memc[oldval], Memc[newval], SZ_LINE)
		call printf ("%s,%s = %s / %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstr (Memc[oldval])
		call pargstr(Memc[fcomm])
	    }

	} else if (verify == YES) {
	    # Query for new value and edit the field.  If the response is a
	    # blank line, use the default new value.  If the response is "$"
	    # or EOF, do not change the value of the parameter.

	    if (streq (Memc[newval], ".")) {
		call strcpy (Memc[oldval], Memc[newval], SZ_LINE)
	    }
	    if (streq (comment, ".")) 
	        call strcpy (Memc[fcomm], Memc[ncomm], SZ_LINE)
	    call strcpy (Memc[newval], Memc[defval], SZ_LINE)
	    call eprintf ("%s,%s (%s -> %s): ")
		call pargstr (image)
		call pargstr (field)
		call he_pargstrc (Memc[oldval], Memc[fcomm])
		call he_pargstrc (Memc[defval], Memc[ncomm]) 
	    call flush (STDERR)

	    if (getline (STDIN, Memc[newval]) != EOF) {
		# Do not skip leading whitespace; may be significant in a
		# string literal.

		ip = newval

		# Do strip trailing newline since it is an artifact of getline.
		nl = strldxs ("\n", Memc[ip]) 
		if (nl > 0)
		    Memc[ip+nl-1] = EOS

		# Decode user response.
		if (Memc[ip] == '\\') {
		    ip = ip + 1
		    goahead = YES
		} else if (streq(Memc[ip],"n") || streq(Memc[ip],"no")) {
		    goahead = NO
		} else if (streq(Memc[ip],"y") || streq(Memc[ip],"yes") ||
		    Memc[ip] == EOS) {
		    call strcpy (Memc[defval], Memc[newval], SZ_LINE)
		    goahead = YES
		} else {
		    if (ip > newval)
			call strcpy (Memc[ip], Memc[newval], SZ_LINE)
		    goahead = YES
		}

		# Edit field if so indicated.
		if (goahead == YES && update == YES)
		    call he_updatefield (im, image, field, Memc[oldval],
			Memc[newval], Memc[fcomm], Memc[ncomm], show)

		call flush (STDOUT)
	    }

	} else {
	    if (streq (Memc[newval], ".")) {
		call strcpy (Memc[oldval], Memc[newval], SZ_LINE)
	    }
	    if (streq (comment, ".")) 
	        call strcpy (Memc[fcomm], Memc[ncomm], SZ_LINE)
	    if (update == YES) {
		call he_updatefield (im, image, field, Memc[oldval],
                      Memc[newval], Memc[fcomm], Memc[ncomm], show)
            }
	}
	if (update == NO && show == YES) {
	    call printf ("%s,%s: %s -> %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstrc (Memc[oldval], Memc[fcomm])
		call he_pargstrc (Memc[newval], Memc[ncomm])
	}

	call sfree (sp)
end


# HE_INITFIELD -- Add a new field to the indicated image.  If the field already
# existsdo not set its value.  The value expression is evaluated and the
# resulting value used as the initial value in adding the field to the image.

procedure he_initfield (im, image, field, valexpr, comment, pkey, baf,
       verify, show, update)

pointer	im			# image descriptor of image to be edited
char	image[ARB]		# name of image to be edited
char	field[ARB]		# name of field to be edited
char	valexpr[ARB]		# value expression
char	comment[ARB]		# keyword comment
char	pkey[ARB]		# 
int	baf
int	verify			# verify new value interactively
int	show			# print record of edit
int	update			# enable updating of the image

bool	numeric
int	numlen, ip
pointer	sp, newval, o
pointer	evexpr()
int	imaccf(), locpr(), strlen(), lexnum()
extern	he_getop()
errchk	imaccf, evexpr, imakbc, imastrc, imakic, imakrc

begin
	call smark (sp)
	call salloc (newval, SZ_LINE, TY_CHAR)

	# If the named field already exists, this is really an edit operation
	# rather than an add.  Call editfield so that the usual verification
	# can take place.

	if (imaccf (im, field) == YES) {
	    call eprintf ("parameter %s,%s already exists\n")
	        call pargstr (image)
	        call pargstr (field)
	    call sfree (sp)
	    return
	}

	# If the expression is not parenthesized, assume that is is already
	# a string literal.  If the expression is a string check for a simple
	# numeric field.

	ip = 1
	numeric = (lexnum (valexpr, ip, numlen) != LEX_NONNUM)
	if (numeric)
	    numeric = (numlen == strlen (valexpr))

	if (numeric || valexpr[1] == '(')
	    o = evexpr (valexpr, locpr(he_getop), 0)
	else {
	    call malloc (o, LEN_OPERAND, TY_STRUCT)
	    call xev_initop (o, strlen(valexpr), TY_CHAR)
	    call strcpy (valexpr, O_VALC(o), ARB)
	}

	# Add the field to the image (or update the value).  The datatype of
	# the expression value operand determines the datatype of the new
	# parameter.

    if (update == YES) {
	switch (O_TYPE(o)) {
	case TY_BOOL:
	    if (pkey[1] != EOS && baf != 0)
	        call imakbci (im, field, O_VALB(o), comment, pkey, baf)
	    else   
	        call imakbc (im, field, O_VALB(o), comment)
	case TY_CHAR:
	    if (pkey[1] != EOS && baf != 0)
	        call imastrci (im, field, O_VALC(o), comment, pkey, baf)
	    else
	        call imastrc (im, field, O_VALC(o), comment)
	case TY_INT:
	    if (pkey[1] != EOS && baf != 0)
	        call imakici (im, field, O_VALI(o), comment, pkey, baf)
	    else
	        call imakic (im, field, O_VALI(o), comment)
	case TY_REAL:
	    if (pkey[1] != EOS && baf != 0)
	        call imakrci (im, field, O_VALR(o), comment, pkey, baf)
	    else
	        call imakrc (im, field, O_VALR(o), comment)
	default:
	    call error (1, "unknown expression datatype")
	}
     }
	if (show == YES) {
	    call he_encodeop (o, Memc[newval], SZ_LINE)
	    call printf ("add %s,%s = %s / %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstr (Memc[newval])
		call pargstr(comment)
	}

	call xev_freeop (o)
	call mfree (o, TY_STRUCT)
	call sfree (sp)
end


# HE_ADDFIELD -- Add a new field to the indicated image.  If the field already
# exists, merely set its value.  The value expression is evaluated and the
# resulting value used as the initial value in adding the field to the image.

procedure he_addfield (im, image, field, valexpr, comment, pkey, baf,
            verify, show, update)

pointer	im			# image descriptor of image to be edited
char	image[ARB]		# name of image to be edited
char	field[ARB]		# name of field to be edited
char	valexpr[ARB]		# value expression
char	comment[ARB]		# keyword comment
char	pkey[ARB]		# pivot keyword name
int	baf			# either BEFORE or AFTER value
int	verify			# verify new value interactively
int	show			# print record of edit
int	update			# enable updating of the image

bool	numeric
int	numlen, ip
pointer	sp, newval, o
pointer	evexpr()
bool    streq()
int	imaccf(), locpr(), strlen(), lexnum()
extern	he_getop()
errchk	imaccf, evexpr, imakbc, imastrc, imakic, imakrc

begin
	call smark (sp)
	call salloc (newval, SZ_LINE, TY_CHAR)

	# If the named field already exists, this is really an edit operation
	# rather than an add.  Call editfield so that the usual verification
	# can take place.
        if (!streq(field, "comment") && !streq(field, "history")) {
	    if (imaccf (im, field) == YES) {
	        call he_editfield (im, image, field, valexpr, comment,
	             verify, show, update)
	        call sfree (sp)
	        return
	    }
	}

	# If the expression is not parenthesized, assume that is is already
	# a string literal.  If the expression is a string check for a simple
	# numeric field.

	ip = 1
	numeric = (lexnum (valexpr, ip, numlen) != LEX_NONNUM)
	if (numeric)
	    numeric = (numlen == strlen (valexpr))

	if (numeric || valexpr[1] == '(')
	    o = evexpr (valexpr, locpr(he_getop), 0)
	else {
	    call malloc (o, LEN_OPERAND, TY_STRUCT)
	    call xev_initop (o, max(1,strlen(valexpr)), TY_CHAR)
	    call strcpy (valexpr, O_VALC(o), SZ_LINE)
	}

	# Add the field to the image (or update the value).  The datatype of
	# the expression value operand determines the datatype of the new
	# parameter.
    if (update == YES) {
	switch (O_TYPE(o)) {
	case TY_BOOL:
	    if (pkey[1] != EOS && baf != 0)
	        call imakbci (im, field, O_VALB(o), comment, pkey, baf)
	    else   
	        call imakbc (im, field, O_VALB(o), comment)
	case TY_CHAR:
	    if (streq(field, "comment") || 
	        streq(field, "history") ||
	        streq(field, "add_textf") ||
		streq(field, "add_blank")) {
                 if (streq(field, "add_textf")) {
	             call imputextf (im, O_VALC(o), pkey, baf) 
		 } else {
	             call imphis (im, field, O_VALC(o), pkey, baf) 
	         }
	    } else if (pkey[1] != EOS && baf != 0)
	        call imastrci (im, field, O_VALC(o), comment, pkey, baf)
	    else
	        call imastrc (im, field, O_VALC(o), comment)
	case TY_INT:
	    if (pkey[1] != EOS && baf != 0)
	        call imakici (im, field, O_VALI(o), comment, pkey, baf)
	    else
	        call imakic (im, field, O_VALI(o), comment)
	case TY_REAL:
	    if (pkey[1] != EOS && baf != 0)
	        call imakrci (im, field, O_VALR(o), comment, pkey, baf)
	    else
	        call imakrc (im, field, O_VALR(o), comment)
	default:
	    call error (1, "unknown expression datatype")
	}
    }
	if (show == YES) {
	    call he_encodeop (o, Memc[newval], SZ_LINE)
	    call printf ("add %s,%s = %s / %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstr (Memc[newval])
		call pargstr(comment)
	}

	call xev_freeop (o)
	call mfree (o, TY_STRUCT)
	call sfree (sp)
end


# HE_DELETEFIELD -- Delete a field from the indicated image.  If the field does
# not exist, print a warning message.

procedure he_deletefield (im, image, field, valexpr, verify, show, update)

pointer	im			# image descriptor of image to be edited
char	image[ARB]		# name of image to be edited
char	field[ARB]		# name of field to be edited
char	valexpr[ARB]		# not used
int	verify			# verify deletion interactively
int	show			# print record of edit
int	update			# enable updating of the image

pointer	sp, ip, newval
int	getline(), imaccf()

begin
	call smark (sp)
	call salloc (newval, SZ_LINE, TY_CHAR)

	if (imaccf (im, field) == NO) {
	    call eprintf ("nonexistent field %s,%s\n")
		call pargstr (image)
		call pargstr (field)
	    call sfree (sp)
	    return
	}
	    
	if (verify == YES) {
	    # Delete pending verification.

	    call eprintf ("delete %s,%s ? (yes): ")
		call pargstr (image)
		call pargstr (field)
	    call flush (STDERR)

	    if (getline (STDIN, Memc[newval]) != EOF) {
		# Strip leading whitespace and trailing newline.
		for (ip=newval;  IS_WHITE(Memc[ip]);  ip=ip+1)
		    ;
		if (Memc[ip] == '\n' || Memc[ip] == 'y') {
		    call imdelf (im, field)
		    if (show == YES) {
			call printf ("%s,%s deleted\n")
			    call pargstr (image)
			    call pargstr (field)
		    }
		}
	    }
	
	} else {
	    # Delete without verification.

            if (update == YES) {
	        iferr (call imdelf (im, field))
		    call erract (EA_WARN)
	        else if (show == YES) {
		    call printf ("%s,%s deleted\n")
		        call pargstr (image)
		        call pargstr (field)
	    } else if (show == YES)
		call printf ("%s,%s deleted, no update\n")
		    call pargstr (image)
		    call pargstr (field)
	    }
	}

	call sfree (sp)
end


# HE_UPDATEFIELD -- Update the value of an image header field.

procedure he_updatefield (im, image, field, oldval, newval, oldcomm,
           newcomm, show)

pointer	im			# image descriptor
char	image[ARB]		# image name
char	field[ARB]		# field name
char	oldval[ARB]		# old value, encoded as a string
char	newval[ARB]		# new value, encoded as a string
char	oldcomm[ARB]		# old keyword comment
char	newcomm[ARB]		# new keyword comment
int	show			# print record of update

begin
	iferr (call impstrc (im, field, newval, newcomm)) {
	    call eprintf ("cannot update %s,%s\n")
		call pargstr (image)
		call pargstr (field)
	    return
	}
	if (show == YES) {
	    call printf ("%s,%s: %s -> %s\n")
		call pargstr (image)
		call pargstr (field)
		call he_pargstrc (oldval, oldcomm)
		call he_pargstrc (newval, newcomm)

	}
end


# HE_GVAL -- Get the value of an image header field and return it as a string.
# The ficticious special field "$I" (the image name) is recognized in this
# context in addition to the actual header fields.

procedure he_gval (im, image, field, strval, maxch)

pointer	im			# image descriptor
char	image[ARB]		# image name
char	field[ARB]		# field whose value is to be returned
char	strval[ARB]		# string value of field (output)
int	maxch			# max chars out

begin
	if (field[1] == '$' && field[2] == 'I')
	    call strcpy (image, strval, maxch)
	else
	    call imgstr (im, field, strval, maxch)
end


# HE_GETOP -- Satisfy an operand request from EVEXPR.  In this context,
# operand names refer to the fields of the image header.  The following
# special operand names are recognized:
#
#	.		a string literal, returned as the string "."
#	$		the value of the current field
#	$F		the name of the current field
#	$I		the name of the current image
#	$T		the current time, expressed as an integer
#
# The companion procedure HE_GETOPSETIMAGE is used to pass the image pointer
# and image and field names.

procedure he_getop (operand, o)

char	operand[ARB]		# operand name
pointer	o			# operand (output)

pointer	h_im			# getop common
char	h_image[SZ_IMAGENAME]
char	h_field[SZ_FIELDNAME]
common	/hegopm/ h_im, h_image, h_field
bool	streq()
long	clktime()
errchk	he_getfield

begin
	if (streq (operand, ".")) {
	    call xev_initop (o, 1, TY_CHAR)
	    call strcpy (".", O_VALC(o), 1)

	} else if (streq (operand, "$")) {
	    call he_getfield (h_im, h_field, o)
	
	} else if (streq (operand, "$F")) {
	    call xev_initop (o, SZ_FIELDNAME, TY_CHAR)
	    call strcpy (h_field, O_VALC(o), SZ_FIELDNAME)

	} else if (streq (operand, "$I")) {
	    call xev_initop (o, SZ_IMAGENAME, TY_CHAR)
	    call strcpy (h_image, O_VALC(o), SZ_IMAGENAME)

	} else if (streq (operand, "$T")) {
	    # Assignment of long into int may fail on some systems.  Maybe
	    # should use type string and let database convert to long...

	    call xev_initop (o, 0, TY_INT)
	    O_VALI(o) = clktime (long(0))

	} else
	    call he_getfield (h_im, operand, o)
end


# HE_GETFIELD -- Return the value of the named field of the image header as
# an EVEXPR type operand structure.

procedure he_getfield (im, field, o)

pointer	im			# image descriptor
char	field[ARB]		# name of field to be returned
pointer	o			# pointer to output operand

bool	imgetb()
int	imgeti(), imgftype()
real	imgetr()

begin
	switch (imgftype (im, field)) {
	case TY_BOOL:
	    call xev_initop (o, 0, TY_BOOL)
	    O_VALB(o) = imgetb (im, field)

	case TY_SHORT, TY_INT, TY_LONG:
	    call xev_initop (o, 0, TY_INT)
	    O_VALI(o) = imgeti (im, field)

	case TY_REAL, TY_DOUBLE, TY_COMPLEX:
	    call xev_initop (o, 0, TY_REAL)
	    O_VALR(o) = imgetr (im, field)

	default:
	    call xev_initop (o, SZ_LINE, TY_CHAR)
	    call imgstr (im, field, O_VALC(o), SZ_LINE)
	}
end


# HE_GETOPSETIMAGE -- Set the image pointer, image name, and field name (context
# of getop) in preparation for a getop call by EVEXPR.

procedure he_getopsetimage (im, image, field)

pointer	im			# image descriptor of image to be edited
char	image[ARB]		# name of image to be edited
char	field[ARB]		# name of field to be edited

pointer	h_im			# getop common
char	h_image[SZ_IMAGENAME]
char	h_field[SZ_FIELDNAME]
common	/hegopm/ h_im, h_image, h_field

begin
	h_im = im
	call strcpy (image, h_image, SZ_IMAGENAME)
	call strcpy (field, h_field, SZ_FIELDNAME)
end


# HE_ENCODEOP -- Encode an operand as returned by EVEXPR as a string.  EVEXPR
# operands are restricted to the datatypes bool, int, real, and string.

procedure he_encodeop (o, outstr, maxch)

pointer	o			# operand to be encoded
char	outstr[ARB]		# output string
int	maxch			# max chars in outstr

begin
	switch (O_TYPE(o)) {
	case TY_BOOL:
	    call sprintf (outstr, maxch, "%b")
		call pargb (O_VALB(o))
	case TY_CHAR:
	    call sprintf (outstr, maxch, "%s")
		call pargstr (O_VALC(o))
	case TY_INT:
	    call sprintf (outstr, maxch, "%d")
		call pargi (O_VALI(o))
	case TY_REAL:
	    call sprintf (outstr, maxch, "%g")
		call pargr (O_VALR(o))
	default:
	    call error (1, "unknown expression datatype")
	}
end


# HE_PARGSTR -- Pass a string to a printf statement, enclosing the string
# in quotes if it contains any whitespace.

procedure he_pargstr (str)

char	str[ARB]		# string to be printed
int	ip
bool	quoteit
pointer	sp, op, buf

begin
	call smark (sp)
	call salloc (buf, SZ_LINE, TY_CHAR)

	op = buf
	Memc[op] = '"'
	op = op + 1

	# Copy string to scratch buffer, enclosed in quotes.  Check for
	# embedded whitespace.

	quoteit = false
	for (ip=1;  str[ip] != EOS;  ip=ip+1) {
	    if (IS_WHITE(str[ip])) {		# detect whitespace
		quoteit = true
		Memc[op] = str[ip]
	    } else if (str[ip] == '\n') {	# prettyprint newlines
		Memc[op] = '\\'
		op = op + 1
		Memc[op] = 'n'
	    } else				# normal characters
		Memc[op] = str[ip]

	    if (ip < SZ_LINE)
		op = op + 1
	}

	# If whitespace was seen pass the quoted string, otherwise pass the
	# original input string.

	if (quoteit) {
	    Memc[op] = '"'
	    op = op + 1
	    Memc[op] = EOS
	    call pargstr (Memc[buf])
	} else
	    call pargstr (str)

	call sfree (sp)
end

procedure he_cpstr (str, outbuf)

char    str[ARB]                # string to be printed
char    outbuf[ARB]            # comment string to be printed
                                                                                
int     ip
bool    quoteit
pointer sp, op, buf
                                                                                
begin
                                                                                
        call smark (sp)
        call salloc (buf, SZ_LINE, TY_CHAR)
                                                                                
        op = buf
        Memc[op] = '"'
        op = op + 1
                                                                                
        # Copy string to scratch buffer, enclosed in quotes.  Check for
        # embedded whitespace.
                                                                                
        quoteit = false
        for (ip=1;  str[ip] != EOS;  ip=ip+1) {
            if (IS_WHITE(str[ip])) {            # detect whitespace
                quoteit = true
                Memc[op] = str[ip]
            } else if (str[ip] == '\n') {       # prettyprint newlines
                Memc[op] = '\\'
                op = op + 1
                Memc[op] = 'n'
            } else                              # normal characters
                Memc[op] = str[ip]
                                                                                
            if (ip < SZ_LINE)
                op = op + 1
        }
                                                                                
        # If whitespace was seen pass the quoted string, otherwise pass the
        # original input string.
                                                                                
        if (quoteit) {
            Memc[op] = '"'
            op = op + 1
            Memc[op] = EOS
            call strcpy (Memc[buf], outbuf, SZ_LINE)
        } else
            call strcpy (str, outbuf, SZ_LINE)
                                                                                
        call sfree (sp)
end



# HE_PARGSTRC -- Pass a string to a printf statement plus the comment string.
										procedure he_pargstrc (str, comment)

char	str[ARB]		# string to be printed
char	comment[ARB]		# comment string to be printed

pointer	sp, buf

begin

	call smark (sp)
        call salloc (buf, SZ_LINE, TY_CHAR)
                                                                                
        call he_cpstr (str, Memc[buf])

        if (comment[1] != EOS) {
           call strcat (" / ", Memc[buf], SZ_LINE)
           call strcat (comment, Memc[buf], SZ_LINE)
        }

        call pargstr (Memc[buf])

        call sfree (sp)
end

# HE_GETPARS -- get the cl parameters for this task

procedure he_getpars (operation, fields, valexpr, comment,
	        pivot, baf, update, verify, show)
        
int	operation
pointer	fields			# template listing fields to be processed
pointer	valexpr			# the value expression (if op=edit|add)
char	comment[ARB]
char	pivot[ARB]
int	baf
int	update
int	verify
int	show
bool	clgetb(), streq()

pointer sp, ip, s_fields, s_valexpr
int	btoi()

begin
        call smark(sp)
	call salloc (s_fields,  SZ_LINE,  TY_CHAR)
	call salloc (s_valexpr,  SZ_LINE,  TY_CHAR)

	operation = OP_EDIT
	if (clgetb ("add"))
	    operation = OP_ADD
	else if (clgetb ("addonly"))
	    operation = OP_INIT
	else if (clgetb ("delete"))
	    operation = OP_DELETE

	# Get list of fields to be edited, added, or deleted.
	call clgstr ("fields", Memc[s_fields], SZ_LINE)
	for (ip=s_fields;  IS_WHITE (Memc[ip]);  ip=ip+1)
	    ;
        call strcpy (Memc[ip], Memc[fields], SZ_LINE)

	# The value expression parameter is not used for the delete operation.
	if (operation != OP_DELETE) {
	    call clgstr ("value", Memc[s_valexpr], SZ_LINE)
	    call clgstr ("comment", comment, SZ_LINE)
	       
	    if (streq(Memc[fields], "add_blank")) {
                call strcpy (Memc[s_valexpr], Memc[valexpr], SZ_LINE)
            } else {     
                # Justify value
	        for (ip=s_valexpr;  IS_WHITE (Memc[ip]);  ip=ip+1)
		    ;
                call strcpy (Memc[ip], Memc[valexpr], SZ_LINE)
	        #valexpr = ip
                ip = valexpr
	        while (Memc[ip] != EOS)
		    ip = ip + 1
	        while (ip > valexpr && IS_WHITE (Memc[ip-1]))
		    ip = ip - 1
	        Memc[ip] = EOS
            }
	} else {
	    Memc[valexpr] = EOS
	}

	# Get switches.  If the expression value is ".", meaning print value
	# rather than edit, then we do not use the switches.
	
	if (operation == OP_EDIT && streq (Memc[valexpr], ".") && 
	       streq (comment, ".")) {
	    update = NO
	    verify = NO
	    show   = NO
	} else {
	    update = btoi (clgetb ("update"))
	    verify = btoi (clgetb ("verify"))
	    show   = btoi (clgetb ("show"))
            call clgstr ("after", pivot, SZ_LINE)
            if (pivot[1] != EOS)
                baf = AFTER
            if (pivot[1] == EOS) {
                call clgstr ("before", pivot, SZ_LINE)
                if (pivot[1] != EOS)
                   baf = BEFORE
	    }
	}
        call sfree(sp)
end


# HE_DEFPAR --

procedure he_setdef (operation, dp_oper, dp_update,dp_verify, dp_show,
                      update, verify, show)

int	operation
int	dp_oper
int	dp_update
int	dp_verify
int	dp_show
int	update
int	verify
int	show

begin
	# a command line with the default parameters has been read,
	# set the default values

	dp_oper = -operation
 	dp_update = update
 	dp_verify = verify
	dp_show = show
        
end


# HE_SETPAR --

procedure he_setpar (operation, dp_oper, dp_update, dp_verify, dp_show, 
                        update, verify, show)
int     operation
int     dp_oper
int     dp_update
int     dp_verify
int     dp_show
int     update
int     verify
int     show

begin
        # If the value is positive then the parameter has been set
        # in the command line.

	if (operation == OP_DEFPAR)
            operation = dp_oper
        if (update < 0)
            update = dp_update
	if (verify < 0)
            verify = dp_verify
        if (show < 0)
            show = dp_show
end







