include <fset.h>

define	DEF_SZBUF	28800


# T_NDWFSGET -- Wrapper for cutout task which supports user file naming and
# the full set of cutout task cutout mode parameters. This is a quick and
# dirty task. There was no attempt to be efficient in coding. Much of the 
# code is duplicated in the two branches of the task, the single cutout
# branch, and the input file branch.

procedure t_ndwfsget()

pointer	sp, output, outname, ra, dec, rawidth, decwidth, fcsystem, ufcsystem
pointer	filters, ufilters, filname, regions, blank, address, cmdfmt, cmd, str1
pointer	buf
int	imlist, strfd, ndfd, outfd, cl 
int	i, ip, op, nchars, index, nindex
bool	done, verbose

int	stropen(), sk_wrdstr(), ndopen(), strlen(), imtopen(), imtgetim()
int	strmatch(), open(), read(), fscan(), nscan(), getline()
bool	streq(), clgetb()
errchk	ndopen()

begin
	# Get working space.
	call smark (sp)
	call salloc (output, SZ_FNAME, TY_CHAR)
	call salloc (outname, SZ_FNAME, TY_CHAR)
	call salloc (ra, SZ_FNAME, TY_CHAR)
	call salloc (dec, SZ_FNAME, TY_CHAR)
	call salloc (rawidth, SZ_FNAME, TY_CHAR)
	call salloc (decwidth, SZ_FNAME, TY_CHAR)
	call salloc (fcsystem, SZ_FNAME, TY_CHAR)
	call salloc (ufcsystem, SZ_FNAME, TY_CHAR)
	call salloc (filters, SZ_FNAME, TY_CHAR)
	call salloc (ufilters, SZ_FNAME, TY_CHAR)
	call salloc (filname, SZ_FNAME, TY_CHAR)
	call salloc (regions, SZ_FNAME, TY_CHAR)
	call salloc (blank, SZ_FNAME, TY_CHAR)
	call salloc (address, SZ_FNAME, TY_CHAR)
	call salloc (cmdfmt, SZ_LINE, TY_CHAR)
	call salloc (cmd, SZ_LINE, TY_CHAR)
	call salloc (str1, SZ_FNAME, TY_CHAR)

	# Get parameters.
	call clgstr ("output", Memc[output], SZ_FNAME)
	call clgstr ("regions", Memc[regions], SZ_FNAME)
	if (streq (Memc[regions], "none")) {
	    call clgstr ("ra", Memc[ra], SZ_FNAME)
	    call clgstr ("dec", Memc[dec], SZ_FNAME)
	    call clgstr ("rawidth", Memc[rawidth], SZ_FNAME)
	    call clgstr ("decwidth", Memc[decwidth], SZ_FNAME)
	}
	call clgstr ("fcsystem", Memc[fcsystem], SZ_FNAME)
	call clgstr ("filters", Memc[filters], SZ_FNAME)
	call clgstr ("blank", Memc[blank], SZ_FNAME)
	verbose = clgetb ("verbose")

	# Create the address. This is a constant at the moment.
	call strcpy ("inet:80:archive.noao.edu:text", Memc[address], SZ_FNAME)

	# Remove internal blanks from the filter string and prepend a comma
	# to create a filter dictionary.
	Memc[str1] = ','
	op = 2
	for (ip = 1; Memc[filters+ip-1] != EOS; ip = ip + 1) {
	    Memc[str1+op-1] = Memc[filters+ip-1]
	    op = op + 1
	}
	Memc[str1+op-1] = EOS
	call strcpy (Memc[str1], Memc[filters], SZ_FNAME)

	# Open the output image name list.
	imlist = imtopen (Memc[output])

	# Allocate space for the output buffer.
	call malloc (buf, 2 * DEF_SZBUF, TY_CHAR)

	# The regions file is undefined.
	if (streq (Memc[regions], "none")) {

	    # Open command string.
	    strfd = stropen (Memc[cmdfmt], SZ_LINE, NEW_FILE)
	    call fprintf (strfd, "GET /ndwfs/cutout.php")

	    # Format the command string leaving the output image name, the
	    # filter id, and regions file undefined.
	    call fprintf (strfd, "?output=%%-s")
	    call fprintf (strfd, "&ra=%s")
	        call pargstr (Memc[ra])
	    call fprintf (strfd, "&dec=%s")
	        call pargstr (Memc[dec])
	    call fprintf (strfd, "&rawidth=%s")
	        call pargstr (Memc[rawidth])
	    call fprintf (strfd, "&decwidth=%s")
	        call pargstr (Memc[decwidth])
	    call fprintf (strfd, "&fcsystem=%s")
	        call pargstr (Memc[fcsystem])
	    call fprintf (strfd, "&filters=%%-s")
	    call fprintf (strfd, "&regions=none")
	    call fprintf (strfd, "&cutmode=largest")
	    call fprintf (strfd, "&trim=no")
	    call fprintf (strfd, "&blank=%s")
	        call pargstr (Memc[blank])
	    call fprintf (strfd, "&opmode=cutout")
	    call fprintf (strfd, "&kwfilter=FILTER")
	    call fprintf (strfd, "&imroot=NDWFS")
	    call fprintf (strfd, "&update=yes")
	    call fprintf (strfd, "&listout=no")
	    call fprintf (strfd, "&verbose=no")

	    # Close command string
	    call fprintf (strfd, " HTTP/1.0\n\n")
	    call close (strfd)

	    # Loop over the filters.
	    for (i = 1; sk_wrdstr (i, Memc[filname], SZ_FNAME,
	        Memc[filters]) > 0; i = i + 1) {

		# Construct the output file name.
		if (imtgetim (imlist, Memc[outname], SZ_FNAME) != EOF) {
                    if (streq ("default", Memc[outname]))
                        call ct_smkfname ("NDWFS", Memc[ra], Memc[dec],
			    Memc[fcsystem], Memc[filname], Memc[outname],
			    SZ_FNAME)
		} else {
		    call ct_smkfname ("NDWFS", Memc[ra], Memc[dec],
		        Memc[fcsystem], Memc[filname], Memc[outname], SZ_FNAME)
		}

                # Make sure the ".fits" extension is present.
                if (strmatch (Memc[outname], ".fits$") == 0)
                    call strcat (".fits", Memc[outname], SZ_FNAME)

		# Format the command string. Worry about the SZ_LINE limit ?
		call sprintf (Memc[cmd], SZ_LINE, Memc[cmdfmt])
		    call pargstr (Memc[outname])
		    call pargstr (Memc[filname])

		# Open the network driver.
        	iferr (ndfd = ndopen (Memc[address], READ_WRITE)) {
            	    call eprintf ("Cannot access image server %s\n")
                    call pargstr (Memc[address])
		    break
		}

		# Send the command. The cancel command clears the network
		# buffers between writing and reading. This will not be
		# necessary with the new improved network driver.
		nchars = strlen (Memc[cmd])
		call write (ndfd, Memc[cmd], nchars)
		call flush (ndfd)
          	call fseti (ndfd, F_CANCEL, OK)

		# Skip the HTTP header which is assumed to be present.
		# Decode the output file name as well which is also assumed
		# to be present.
		nindex = 0
		repeat {
		    nchars = getline (ndfd, Memc[buf])
		    if (nchars <= 0)
			break
		    Memc[buf+nchars] = EOS
		    index = strmatch (Memc[buf], "filename=")
		    if (index > 0) {
		        op = 1
		        for (ip = index + 1; Memc[buf+ip-1] != '\n';
			    ip = ip + 1) {
			    if (Memc[buf+ip-1] == '\'')
			        break
			    Memc[str1+op-1] = Memc[buf+ip-1]
			    op = op + 1
		        }
		        Memc[str1+op-1] = EOS
			nindex = index
		        if (op > 1)
			    call strcpy (Memc[str1], Memc[outname], SZ_FNAME)
		        #call eprintf ("filename='%s'\n")
			    #call pargstr (Memc[str1])
		    }
		} until ((Memc[buf] == '\r' && Memc[buf+1] == '\n') ||
		    (Memc[buf] == '\n'))

		# If the output file name was not found close the network
		# driver and move to the next file.
		if (nindex <= 0) {
		    if (verbose) {
		        call printf ("Error writing output image %s ...\n")
			    call pargstr (Memc[outname])
		        call flush (STDOUT)
		    }
		    call close (ndfd)
		    next
		}

		if (verbose) {
		    call printf ("Writing output image %s ...\n")
			call pargstr (Memc[outname])
		    call flush (STDOUT)
		}

		# Open the output filename
		outfd = open (Memc[outname], NEW_FILE, TEXT_FILE)

		# Get the results
        	repeat {
                    nchars = read (ndfd, Memc[buf], DEF_SZBUF)
                    if (nchars > 0) {
                        Memc[buf+nchars] = EOS
                        call write (outfd, Memc[buf], nchars)
                        done = false
                    } else {
                        done = true
                    }
                } until (done)
                call flush (outfd)

		# Close the output file.
		call close (outfd)

		# Close the network driver. 
		call close (ndfd)
	    }

        } else {

	    # Open command string.
	    strfd = stropen (Memc[cmdfmt], SZ_LINE, NEW_FILE)
	    call fprintf (strfd, "GET /ndwfs/cutout.php")

	    # Format the command string leaving the output image name, the
	    # right ascension, the declination, the right ascensions width,
	    # the declination width, the coordinate system, the filter list
	    # undefined.
	    call fprintf (strfd, "?output=%%-s")
	    call fprintf (strfd, "&ra=%%-s")
	    call fprintf (strfd, "&dec=%%-s")
	    call fprintf (strfd, "&rawidth=%%-s")
	    call fprintf (strfd, "&decwidth=%%-s")
	    call fprintf (strfd, "&fcsystem=%%-s")
	    call fprintf (strfd, "&filters=%%-s")
	    call fprintf (strfd, "&regions=none")
	    call fprintf (strfd, "&cutmode=largest")
	    call fprintf (strfd, "&trim=no")
	    call fprintf (strfd, "&blank=%s")
	        call pargstr (Memc[blank])
	    call fprintf (strfd, "&opmode=cutout")
	    call fprintf (strfd, "&kwfilter=FILTER")
	    call fprintf (strfd, "&imroot=NDWFS")
	    call fprintf (strfd, "&update=yes")
	    call fprintf (strfd, "&listout=no")
	    call fprintf (strfd, "&verbose=no")

	    # Close command string
	    call fprintf (strfd, " HTTP/1.0\n\n")
	    call close (strfd)

	    # Loop over the regions file.
	    cl = open (Memc[regions], READ_ONLY, TEXT_FILE)
	    while (fscan (cl) != EOF) {

		# Get the field parameters from the regions file.
		call gargwrd (Memc[ra], SZ_FNAME)
		call gargwrd (Memc[dec], SZ_FNAME)
		call gargwrd (Memc[rawidth], SZ_FNAME)
		if (nscan() < 3)
		    next
		call gargwrd (Memc[decwidth], SZ_FNAME)
		if (nscan() < 4) {
		    call strcpy (Memc[rawidth], Memc[decwidth], SZ_FNAME)
		    call strcpy (Memc[fcsystem], Memc[ufcsystem], SZ_FNAME)
		    call strcpy (Memc[filters], Memc[ufilters], SZ_FNAME)
		} else {
		    call gargwrd (Memc[ufcsystem], SZ_FNAME)
		    call gargwrd (Memc[ufilters], SZ_FNAME)
		    if (nscan() < 5) {
			call strcpy (Memc[fcsystem], Memc[ufcsystem], SZ_FNAME)
			call strcpy (Memc[filters], Memc[ufilters], SZ_FNAME)
		    } else if (nscan() < 6) {
			call strcpy (Memc[filters], Memc[ufilters], SZ_FNAME)
		    }
		}

	        # Loop over the filters.
	        for (i = 1; sk_wrdstr (i, Memc[filname], SZ_FNAME,
	            Memc[ufilters]) > 0; i = i + 1) {

		    # Construct the output file name.
		    if (imtgetim (imlist, Memc[outname], SZ_FNAME) != EOF) {
                        if (streq ("default", Memc[outname]))
                            call ct_smkfname ("NDWFS", Memc[ra], Memc[dec],
			        Memc[fcsystem], Memc[filname], Memc[outname],
			        SZ_FNAME)
		    } else {
		        call ct_smkfname ("NDWFS", Memc[ra], Memc[dec],
		            Memc[fcsystem], Memc[filname], Memc[outname],
			    SZ_FNAME)
		    }

                    # Make sure the ".fits" extension is present.
                    if (strmatch (Memc[outname], ".fits$") == 0)
                        call strcat (".fits", Memc[outname], SZ_FNAME)

		    # Format the command string. Worry about the SZ_LINE limit ?
		    call sprintf (Memc[cmd], SZ_LINE, Memc[cmdfmt])
		        call pargstr (Memc[outname])
			call pargstr (Memc[ra])
			call pargstr (Memc[dec])
			call pargstr (Memc[rawidth])
			call pargstr (Memc[decwidth])
			call pargstr (Memc[ufcsystem])
		        call pargstr (Memc[filname])

		    # Open the network driver.
        	    iferr (ndfd = ndopen (Memc[address], READ_WRITE)) {
            	        call eprintf ("Cannot access image server %s\n")
                        call pargstr (Memc[address])
		        break
		    }

		    # Send the command. The cancel command clears the network
		    # buffers between writing and reading. This will not be
		    # necessary with the new improved network driver.
		    nchars = strlen (Memc[cmd])
		    call write (ndfd, Memc[cmd], nchars)
		    call flush (ndfd)
                    call fseti (ndfd, F_CANCEL, OK)

		    # Skip the HTTP header which is assumed to be present.
		    # Decode the output file name as well which is also assumed
		    # to be present.
		    nindex = 0
		    repeat {
		        nchars = getline (ndfd, Memc[buf])
		        if (nchars <= 0)
			    break
		        Memc[buf+nchars] = EOS
		        index = strmatch (Memc[buf], "filename=")
		        if (index > 0) {
		            op = 1
		            for (ip = index + 1; Memc[buf+ip-1] != '\n';
			        ip = ip + 1) {
			        if (Memc[buf+ip-1] == '\'')
			            break
			        Memc[str1+op-1] = Memc[buf+ip-1]
			        op = op + 1
		            }
		            Memc[str1+op-1] = EOS
			    nindex = index
		            if (op > 1)
			        call strcpy (Memc[str1], Memc[outname],
				    SZ_FNAME)
		            #call eprintf ("filename='%s'\n")
			        #call pargstr (Memc[str1])
		        }
		    } until ((Memc[buf] == '\r' && Memc[buf+1] == '\n') ||
		        (Memc[buf] == '\n'))

		    # If the output file name was not found close the network
		    # driver and move to the next file.
		    if (nindex <= 0) {
		        if (verbose) {
		            call printf ("Error writing output image %s ...\n")
			        call pargstr (Memc[outname])
		            call flush (STDOUT)
		        }
		        call close (ndfd)
		        next
		    }

		    if (verbose) {
		        call printf ("Writing output image %s ...\n")
			    call pargstr (Memc[outname])
			call flush (STDOUT)
		    }

		    # Open the output filename.
		    outfd = open (Memc[outname], NEW_FILE, TEXT_FILE)

		    # Get the results
        	    repeat {
                        nchars = read (ndfd, Memc[buf], DEF_SZBUF)
                        if (nchars > 0) {
                            Memc[buf+nchars] = EOS
                            call write (outfd, Memc[buf], nchars)
                            done = false
                        } else {
                            done = true
                        }
                    } until (done)
                    call flush (outfd)

		    call close (outfd)

		    # Close the network driver. 
		    call close (ndfd)

		}

	    }

	    call close (cl)
	}


	# Cleanup.
	call mfree (buf, TY_CHAR)
	call imtclose (imlist)
	call sfree (sp)
end


# CT_SMKFNAME -- Create a default output name.

procedure ct_smkfname (imroot, ra, dec, fsystem, filter, output, maxch)

char	imroot[ARB]			#I the root output image name
char	ra[ARB]				#I the ra string
char	dec[ARB]			#I the dec string
char	fsystem[ARB]			#I the input coordinate system
char	filter[ARB]			#I the filter name
char	output[ARB]			#O the output file name
int	maxch				#I the maximum number of characters

pointer	sp, str
int	fnldir()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	if (fnldir (imroot, output, maxch) <= 0)
	    output[1] = EOS
	call ct_sfname (imroot, ra, dec, fsystem, filter, Memc[str], SZ_FNAME)
	call ct_oimname (Memc[str], output, "", output, maxch)

	call sfree (sp)
end


# CT_SFNAME -- Create an pseudo IAU style image root name from the field
# center parameters.

procedure ct_sfname (class, ra, dec, system, filter, objname, maxch)

char	class[ARB]		#I the input class string.
char	ra[ARB]			#I the right ascension in hours
char	dec[ARB]		#I the declination in degrees
char	system[ARB]		#I the equatorial system
char	filter[ARB]		#I the filter name
char	objname[ARB]		#O the output object name
int	maxch			#I maximum size of the object name

double	dra, ddec
pointer	sp, str
int	i, op, slen
int	gstrcpy (), strlen(), ctod()
bool	streq()

begin
	call smark (sp)
	call salloc (str, SZ_FNAME, TY_CHAR)

	# Copy in the class name.
	op = 1
	op = op + gstrcpy (class, objname[op], maxch)

	# Add an underscore.
	op = op + gstrcpy ("_", objname[op], maxch - op + 1)

	# Add the coordinate type letter. The system options are B1950,
	# J2000, and ICRS.
	if (streq (system, "B1950")) {
	    op = op + gstrcpy ("B", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("J", objname[op], maxch - op + 1)
	}

	# Decode the input ra string into decimial degrees.
	i = 1
	if (ctod (ra, i, dra) <= 0.0)
	    dra = INDEFD
	else
	    dra = dra * 15.0d0

	# Encode the RA string. Remove the ':' delimiters and the period
	# and chop off the last digit of precision.
	call sprintf (Memc[str], SZ_FNAME, "%011.2H")
	    call pargd (dra)
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':' || Memc[str+i-1] == '.')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	# Decode the input dec string into decimial degrees.
	i = 1
	if (ctod (dec, i, ddec) <= 0.0)
	    ddec = INDEFD

	# Encode the dec sign as a p or n.
	if (ddec >= 0.0d0) {
	    op = op + gstrcpy ("p", objname[op], maxch - op + 1)
	} else {
	    op = op + gstrcpy ("n", objname[op], maxch - op + 1)
	}

	# Encode the DEC string. Remove the ':' delimiters and the period
	# the last digit of precision.
	call sprintf (Memc[str], SZ_FNAME, "%010.1h")
	    call pargd (abs(ddec))
	slen = strlen (Memc[str])
	do i = 1, slen - 1 {
	    if (Memc[str+i-1] == ':' || Memc[str+i-1] == '.')
		next
	    objname[op] = Memc[str+i-1]
	    op = op + 1
	}
	objname[op] = EOS

	# Add the filter name.
	op = op + gstrcpy ("_", objname[op], maxch - op + 1)
	op = op + gstrcpy (filter, objname[op], maxch - op + 1)

	call sfree (sp)
end
