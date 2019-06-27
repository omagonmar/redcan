# $Header: /home/pros/xray/xtiming/timcor/apply_bary/RCS/apply_bary_spp.x,v 1.2 1999/01/28 21:28:09 prosb Exp $
#JCC(1/99) - rename apply_bary to apply_bary_spp
#
#Revision 7.0  93/12/27  19:05:10  prosb
#General Release 2.3
#
#Revision 6.2  93/12/22  17:10:07  janet
#jd - updated keywords to rdf names.
#
#Revision 6.1  93/11/23  16:20:38  mo
#MC	6/28/93		Fix some bug with the DEFFILT
#
#Revision 6.0  93/05/24  17:00:45  prosb
#General Release 2.2
#
#Revision 5.2  93/05/20  10:15:38  mo
#MC	5/20/93		Replace tim_cktim routine which has changed
#
#Revision 5.1  92/12/15  17:04:49  jmoran
#JMORAN changed printf
#
#Revision 5.0  92/10/29  23:07:15  prosb
#General Release 2.1
#
#Revision 4.2  92/10/15  16:19:42  jmoran
#JMORAN fixed code to adjust for new GTI library code
#
#Revision 4.1  92/06/16  12:19:42  jmoran
#JMORAN added code to delete the param "deffilt" from the output qpoe
#file if it exists.  
#
#Revision 4.0  92/04/27  15:39:54  prosb
#General Release 2.0:  April 1992
#
#Revision 1.8  92/04/24  13:35:58  mo
#MC	4/23/92		Had to move 'updeffilt' from 'close' to 'hist'
#			to prevent overwrite by QPCREATE.
#
#Revision 1.7  92/04/20  11:27:54  prosb
#JMORAN - changed the output format of the RA and DEC to utilize the 
#IRAF formats %H and %h
#
#Revision 1.6  92/04/13  16:06:16  jmoran
#JMORAN changed char strings in common block to pointer w/ calloc'ed space
#
#Revision 1.5  92/04/09  11:06:08  jmoran
#JMORAN QP_MJDRDAY changes
#
#Revision 1.4  92/04/08  15:33:44  jmoran
#JMORAN - restored to original condition- added second MJD magic number
#
#Revision 1.1  92/03/26  13:26:20  prosb
#Initial revision
#
#
# Module:       apply_bary.x
# Project:      PROS -- ROSAT RSDC
# Purpose:      < opt, brief description of whole family, if many routines>
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} MPE  initial version 02/01/92
#               {n} <who> -- <does what> -- <when>
# ---------------------------------------------------------------------------

include <math.h>
include <mach.h>
include <qpoe.h>
include <qpc.h>
include <qpset.h>
include <error.h>
include <ext.h>
include <tbset.h>
include <clk.h>
include <bary.h>

procedure apply_bary_spp()

pointer	argv				# user argument list

begin

#-----------------------
# Init the driver arrays
#-----------------------
	call qpc_alloc(0)

#--------------------
# Allocate argv space
#--------------------
	call calloc(argv, SZ_DEFARGV, TY_INT)

#--------------------
# Allocate def arrays
#--------------------
	call def_alloc(argv)

#-----------------
# Load the drivers
#-----------------
	call bar_load()

#--------------------------------
# Call the QPOE create subroutine
#--------------------------------
	call qp_create(argv)

#-----------------------
# Free the driver arrays
#-----------------------
	call qpc_free()

#--------------------
# Free the argv space
#--------------------
	call def_free(argv)

	call mfree(argv, TY_INT)

	call printf("\n\nNOTE: The output QPOE times are in seconds from noon of the MJD\n")
	call printf("of the start of the first OBI.\n\n")
	call printf("To convert the times to MJD use the following formula:\n\n")

	call printf("        MJDREFI + MJDREFF + (photon_time / 86400)\n\n")

	call printf("The values MJDREFI and MJDREFF can be found in the header of the\n")

	call printf("output QPOE file. (MJDREFF should be 0.5)\n")

	call flush(STDOUT)
end


# ---------------------------------------------------------------------------
#  BAR_LOAD -- load driver routines
# ---------------------------------------------------------------------------
procedure bar_load()

extern	bar_open(), bar_get(), bar_close()
extern	bar_getparam(), bar_hist()

begin

#-----------------------
# Load the event drivers
#-----------------------
	call qpc_evload("input_qpoe", ".qp", bar_open, bar_get, bar_close)

#----------------------
# Load getparam routine
#----------------------
	call qpc_parload(bar_getparam)

#---------------------
# Load history routine
#---------------------
	call qpc_histload(bar_hist)

end


# --------------------------------------------------------------------------
procedure bar_getparam(ifile, argv)

char    ifile[ARB]              # input file name
pointer argv                    # argument list pointer

#double  clgetd()                
bool	streq()
bool 	ck_none()

include "apply_bary.com"

begin

#-------------------------------
# Call default get param routine
#-------------------------------
        call def_getparam(ifile, argv)

#--------------------------------------------------------------------
# Calloc the memory for the table column names and file names used in 
# the common block
#--------------------------------------------------------------------
	call calloc(tbl_r1, SZ_LINE, TY_CHAR)
        call calloc(tbl_r2, SZ_LINE, TY_CHAR)
        call calloc(tbl_i1, SZ_LINE, TY_CHAR)
        call calloc(tbl_i2, SZ_LINE, TY_CHAR)
        call calloc(tbl_fname, SZ_PATHNAME, TY_CHAR)
        call calloc(s2u_fname, SZ_PATHNAME, TY_CHAR)

#------------------
# Get CL parameters
#------------------
        call clgstr("tblfile", Memc[tbl_fname], SZ_PATHNAME)
	call clgstr("scc_to_ut", Memc[s2u_fname], SZ_PATHNAME)

#-----------------------------------------
# Set up for correction table input 
#-----------------------------------------
        call clgstr("tbl_r1", Memc[tbl_r1], SZ_LINE)
        call clgstr("tbl_r2", Memc[tbl_r2], SZ_LINE)
        call clgstr("tbl_i1", Memc[tbl_i1], SZ_LINE)
        call clgstr("tbl_i2", Memc[tbl_i2], SZ_LINE)

        if (ck_none(Memc[tbl_r1]) || streq("", Memc[tbl_r1]))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(Memc[tbl_r2]) || streq("", Memc[tbl_r2]))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(Memc[tbl_i1]) || streq("", Memc[tbl_i1]))
           call error(EA_FATAL, "Table is missing column name in param file")

        if (ck_none(Memc[tbl_i2]) || streq("", Memc[tbl_i2]))
           call error(EA_FATAL, "Table is missing column name in param file")

end

# ---------------------------------------------------------------------------
# BAR_OPEN -- open a qpoe file and an event list through a region
#               and determine some constant quantities for the rotate
# ---------------------------------------------------------------------------
procedure bar_open(fname, fd, irecs, convert, qphead, display, argv)

char    fname[ARB]                      # i: header file name
int	fd[MAX_ICHANS]                  # o: file descriptor
int     irecs                           # o: number of records in file
int     convert                         # i: data conversion flag
pointer qphead                          # i: header
int     display                         # i: display level
pointer argv                            # i: pointer to arg list

int     i
char    evlist[SZ_EXPR]
char    poeroot[SZ_PATHNAME]

begin

       do i = 1, MAX_ICHANS {
         fd[i] = 0
       }
#----------------------------------
# initialize common block
#----------------------------------
        call init_common()

#-------------------------
# Perform the default open
#-------------------------
        call def_open(fname, fd, irecs, convert, qphead, display, argv)

#---------------------------------------------------------------
# Here we must call qp_parse again since evlist is used below in 
# the code and def_open doesn't return it.  
#---------------------------------------------------------------
        call qp_parse(fname, poeroot, SZ_PATHNAME, evlist, SZ_EXPR)

#------------
# Open tables
#------------
	call open_tables(display)

#---------------------------------
# Call the initialization routines        
#---------------------------------
	call apply_bary_init(fd, qphead, evlist, display)

end

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------
procedure apply_bary_init(fd, qphead, evlist, display)

int	fd[ARB]		                # o: file descriptor
pointer qphead
char    evlist[ARB]
int     display                         # i: display level


include "apply_bary.com"

#double  d_tet
double  duration
bool    times_compatible()
bool    qp_time_sorted()
#bool   is_corr_table()
bool    already_corrected()
bool    timoff, get_timeoff()
#double  angle_sep()

begin


#----------------------------------
# Check whether QPOE is time sorted
#----------------------------------
        if (!qp_time_sorted(fd[1]))
           call error(EA_FATAL, "Input QPOE must be sorted in time.")

#---------------------------------------------------
# Check whether the table has already been corrected
#---------------------------------------------------
        if (already_corrected(fd[1]))
           call error(EA_FATAL, "Input QPOE already barycentric corrected.")

#------------------------
# Get good time intervals
#------------------------
        call get_goodtimes(fd[1], evlist, display, blist, elist, ngti, duration)
	call realloc (blist,ngti+2,TY_DOUBLE)
	call realloc (elist,ngti+2,TY_DOUBLE)

#--------------------------------------------
# Convert the column names to column pointers
#--------------------------------------------
        call col_pointers(tp, Memc[tbl_i1], Memc[tbl_r1],
			  Memc[tbl_i2], Memc[tbl_r2], cp)

#---------------------------------------------------
# Check whether the two tables are compatible.
# The first and last accepted times must be included
# in the correction range.
#---------------------------------------------------
        if (!times_compatible(tp, blist, elist, ngti, nrows, cp[1], cp[2]))
        {
          call eprintf(
	       "\n** Warning! Times in qpoe and correction table are incompatible!!\n")
          call flush(STDERR)
        }


#---------------------------------------------------------------------------
# jd - tried to put this code into this task in 4/94.  The problem is that
#      the qpoe center and source center are often quite a distance appart
#      and the warning is misleading.  If the qpoe center was the center
#      of the region instead of the field center, this check would make
#      more sense.
#----------------------------------------------------------------------------
# Check if alpha and delta are compatible
#----------------------------------------
#        d_tet = angle_sep(tp, qphead, display, alpha, delta)
#        if (d_tet < EPSILOND) {
#          call eprintf("\n** Warning! Unable to find reference position in correction table hdr -\n")
#          call eprintf("              ** No distance check performed **\n")
#        } else if (d_tet > DEVIAT) {
#          call eprintf("\n** Warning! Correction table & QPOE center are\n")
#          call eprintf("              a distance of %.2f arcsecs **\n")
#             call pargd(d_tet)
#	}
#	call flush(STDERR)

#----------------------------------------
# Get the time offset for the QPOE events
#----------------------------------------
        call get_first_interval()
	timoff = get_timeoff(fd[1],"Source",toffset)

end

# --------------------------------------------------------------------------
# --------------------------------------------------------------------------
procedure open_tables(display)

int	display

bool    ck_none()                       # check none function
bool    streq()                         # string equals function
int     tbtacc()
int     tbpsta()
pointer tbtopn()

include "apply_bary.com"

begin

#----------------------
# Open correction table
#----------------------
        call rootname("", Memc[tbl_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[tbl_fname]) | streq("", Memc[tbl_fname]))
           call error (EA_FATAL, "Requires *.tab file as input.")

        if (tbtacc(Memc[tbl_fname]) == YES)
           tp = tbtopn (Memc[tbl_fname], READ_ONLY, 0)
        else
           call error(EA_FATAL, "Correction table not found.")
        if (display >= 2)
        {
          call printf("Opening file: %s\n")
          call pargstr(Memc[tbl_fname])
          call flush(STDOUT)
        }

#----------------------
# Check for empty table
#----------------------
        nrows = tbpsta (tp, TBL_NROWS)

        if (nrows <= 0)
           call error (EA_FATAL, "Table file empty.")

#---------------------
# Open SCC to UT table
#---------------------
        call rootname("", Memc[s2u_fname], EXT_TABLE, SZ_PATHNAME)
        if (ck_none(Memc[s2u_fname]) | streq("", Memc[s2u_fname]))
           call error (EA_FATAL, "Requires *.tab file as input.")

        if (tbtacc(Memc[s2u_fname]) == YES)
           call sccut2_init(Memc[s2u_fname])
        else
           call error(EA_FATAL, "SCC to UT table not found.")

end

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
procedure get_first_interval()

include "apply_bary.com"

begin

#-----------------------------
# read in first orbit interval
#-----------------------------
        row = 1
        call orb_interval(tp, cp, orb_int[1], orb_real[1],
                          corr_int[1], corr_real[1], row)

        row = row + 1 
        call orb_interval(tp, cp, orb_int[2], orb_real[2],
                          corr_int[2], corr_real[2], row)

#----------------------------------
# save the integer parts as offsets
#----------------------------------
        orb_offset = orb_int[1]
        corr_offset = corr_int[1]

#-----------------------
# subtract actual offset
#-----------------------
        orb_real[2] = orb_real[2] + (orb_int[2] - orb_offset)
        corr_real[2] = corr_real[2] + (corr_int[2] - corr_offset)

#-------------------------------
# get corresponding coefficients
#-------------------------------
        call lin_interpol(orb_real, corr_real, a, b)

end

#------------------------------------------------------------------
# BAR_HIST -- write history (and a title) to qpoe file
#------------------------------------------------------------------
procedure bar_hist(qp, qpname, file, qphead, display, argv)

pointer	qp				# i: qpoe handle
char	qpname[SZ_FNAME]		# i: output qpoe file
int	file[ARB]			# i: array of file name ptrs
pointer	qphead				# i: qpoe header pointer
int	display				# i: display level
pointer	argv				# i: argument pointer

pointer buf1				# l: history line
pointer buf2                            # l: history line
pointer	sp				# l: stack pointer

int 	qp_accessf()

double  temp_doub
int     temp_int
pointer	filtkey
pointer	filtstr
int	len,strlen()
double  ra,dec
double  tbhgtd()

include "apply_bary.com"

begin

	call smark(sp)
	
        call salloc(buf1, SZ_LINE, TY_CHAR)
        call salloc(buf2, SZ_LINE, TY_CHAR)
	call salloc(filtkey,SZ_FNAME,TY_CHAR)

#------------------------------------------------------------------
# Assign the qp file pointer to the variable qp_out which is in the
# common block.  This is a real kludge that MUST be fixed because it
# depends on a certain procedure call order in qp_create. (i.e. It
# depends on the fact that the close routine is called BEFORE the 
# close call on the output QPOE in qp_create.)  It is used in the 
# bar_close routine to write out the GTI records after they've been
# corrected
#-------------------------------------------------------------------
	qp_out = qp

#----------------------------------
# make and write the history record
#----------------------------------
        call sprintf(Memc[buf1], SZ_LINE, "%s barycenter corrected using %s")
          call pargstr(qpname)
          call pargstr(Memc[tbl_fname])
 	call put_qphistory(qp, "apply_bary", Memc[buf1], "")
 	if (display > 0) {
 	  call printf("\nBarycenter Corrections applied to event times in %s\n")
 	    call pargstr(qpname)
 	  call printf("using correction table %s \n")
            call pargstr(Memc[tbl_fname])
        }

        iferr (ra = tbhgtd(tp, "ALPHA_SOURCE")) { 
        } else {
           # convert degrees to hours
           ra = ra * 15.0
	   iferr (dec = tbhgtd(tp, "DELTA_SOURCE")) {
           } else {
             call sprintf(Memc[buf2], SZ_LINE, "at RA = %12.2H, DEC = %12.2h")
               call pargd(ra)
               call pargd(dec)
             call put_qphistory(qp, "apply_bary", Memc[buf2], "")
 	     if (display > 0) {
 	        call printf("with reference position %s\n")
                call pargstr(Memc[buf2])
	     }
          }
        }

#---------------------------------------------------------------------------
# write out the modified Julian day and fraction of day to the header of the
# output QPOE file
#
# subtract magic number MJD_OFFSET (defined in bary.h) then add the second
# magic number MJDREFOFFSET defined in clk.h.  Since the 0.5 is subtracted
# from the int part of the number, it must be added to "QP_MJDRFRAC"
#---------------------------------------------------------------------------
        temp_doub =  MJDREFOFFSET - 0.5D0
        temp_int  = int(temp_doub)

        QP_MJDRDAY(qphead) = orb_offset - MJD_OFFSET + temp_int
	QP_MJDRFRAC(qphead) = 0.5D0

#-----------------------------------------------------------------
# write out bary correction boolean parameter to the header of the 
# output QPOE file
#-----------------------------------------------------------------
#	if( qp_accessf(qp, QP_BARCOR_PARAM) == NO )
#	{
#            call qpx_addf (qp, QP_BARCOR_PARAM, "b", 1, "bary corrected",0)
#	}
#       call qp_putb(qp, QP_BARCOR_PARAM, "true")
	call qp_upbary(qp,qphead)
#	call strcpy("MJD",QP_TIMESYS(qphead),SZ_TIMESYS)
#	call strcpy("SOLARSYSTEM",QP_TIMEREF(qphead),SZ_TIMEREF)
# 	QP_CLOCKCOR(qphead) = YES
	call put_qphead(qp, qphead)

#-----------------
# Correct the GTIs
#-----------------
        call gti_correct()

#----------------
# Update the GTIs
#----------------
        call gti_update(qp_out, qphead, blist, elist, ngti)

#------------------------------------------------------------------
# Check if the qpoe param "deffilt" exists in the OUTPUT qpoe, 
# if it does, delete it.  When "updeffilt" is called, the param
# will be recreated from the corrected gtis.  If this parameter 
# exists when updeffilt is called, the data in it will override the
# corrected gtis.  Apparently, "deffilt" is inherited from the
# input qpoe file.
#------------------------------------------------------------------
	if (qp_accessf(qp_out,"deffilt") == YES)
	{
	   call qp_deletef(qp_out, "deffilt")
	   call strcpy("deffilt",Memc[filtkey],SZ_FNAME)
	}
	else
	   call strcpy("XS-FHIST",Memc[filtkey],SZ_FNAME)

#-------------------------------------------------------------------
# Call "updeffilt" and then set the param "QPOE_NODEFFILT" so that
# "qpcreate" won't write over the changes to the filter and the GTIs
#-------------------------------------------------------------------
#	call updeffilt(qp_out, qp_out, empty_ptr, "deffilt", qphead)
        call put_gtifilt(blist,elist,ngti,filtstr)
        len=strlen(Memc[filtstr])
        if( qp_accessf(qp, Memc[filtkey]) == NO ){
             call qpx_addf (qp, Memc[filtkey], "c", len+SZ_LINE,
                           "standard time filter", QPF_INHERIT)
        }
        call qp_pstr(qp, Memc[filtkey], Memc[filtstr])

	call qp_seti(qp_out, QPOE_NODEFFILT, YES)

	call sfree(sp)

end


# ---------------------------------------------------------------------------
# BAR_GET -- read the next input event and create an output event
# ---------------------------------------------------------------------------
procedure bar_get(fd, evsize, convert, sbuf, get, got, qphead, display, argv)

int     fd[MAX_ICHANS]		# i: file descriptor
int	evsize			# i: size of output qpoe record
int	convert			# i: data conversion flag
pointer	sbuf			# o: event pointer
int	get			# i: number of events to get
int	got			# o: number of events got
pointer	qphead			# i: header
int	display			# i: display level
pointer	argv			# i: pointer to arg list

int	i			# l: loop counter
int	mval			# l: mask from qpio_getevent
int	nev			# l: number of events returned
int	evlen			# l: number of shorts to move
int	try			# l: number of events to try this time
int	size			# l: padded size of a qpoe record
pointer evl[SZ_EVBUF]		# l: event pointer from qpio_getevent
pointer	ev			# l: pointer to current output record

int	qpio_getevents()	# l: get qpoe events

double	photon
double  corr_photon
double  utc_photon
bool 	end_of_file
long	utci
bool	outside_range

bool    first
int     outcnt

include "apply_bary.com"

begin

#------------------------------------------------------------
# determine the number of shorts we move from input to output
#------------------------------------------------------------
	call qpc_movelen(fd[1], evsize, evlen)

#----------------------------------------------------
# determine the padded record size of the qpoe record
#----------------------------------------------------
	call qpc_roundup(evsize, size)

	got = 0
	end_of_file = false

        corr_photon = 0.0D0
        photon = 0.0D0
        utc_photon = 0.0D0

        first=true
        outcnt=0

	while ((got < get) && (!end_of_file))
	{
	   #-----------------------------
	   # get the next batch of events
	   #-----------------------------
	   try = min(SZ_EVBUF, get-got)

	   if (qpio_getevents(fd[2], evl, mval, try, nev) != EOF)
	   { 
	      do i=1, nev
	      {
	  	 #--------------------------------
		 # point to current record in sbuf
		 #--------------------------------
		 ev = sbuf + (got*size)

		 #---------------------------
		 # increment number of events
                 #---------------------------
		 got = got+1

		 #-------------------------------------
		 # move the old record into the new one
                 #-------------------------------------
                 call qp_movedata (SWAP_CNT(argv), SWAP_PTR(argv),
 		                   evl[i], ev)

                 #--------------------
                 # read in next photon
                 #--------------------
                 photon = Memd[((ev + toffset - 1)/SZ_DOUBLE) + 1]

                 #------------------
                 # convert it to utc
                 #------------------
                 call sccut2(photon,utci,utc_photon)

                 #----------------
                 # subtract offset
                 #----------------
                 utc_photon = utc_photon + (utci - orb_offset)

                 #-----------------------------------
                 # check whether the photon is inside
                 # the current interval
                 #-----------------------------------
                 if (utc_photon > orb_real[2])

                    call find_interval(tp, cp, orb_real, corr_real, orb_int, 
				    corr_int, utc_photon,
                                    a, b, orb_offset, corr_offset, row,
				    nrows, outside_range)

                 #---------------
                 # Correct photon
                 #---------------
                 corr_photon = a*utc_photon + b

                 #----------------------
                 # convert it to seconds
                 #----------------------
                 corr_photon = corr_photon * SECS_IN_DAY
		 
		 # --------------------------------------------------
                 # give user a summary when we're outside the orb tab
		 # --------------------------------------------------
		 if (outside_range) {
                    if (first) {
		       call eprintf(
		      "\n** Warning! EVENT: SCC %.6f is outside range of correction table -\n")
		          call pargd(photon)
                       call eprintf(
		      "            Extrapolating from last two orbit records. **\n")
		          call flush(STDERR)
		       first = false
                    } else {
		       outcnt = outcnt+1
		    }
		 } else {
		    if (!outside_range && !first) {
		       call eprintf("            -- Repeated for %d event records!!\n\n")
		          call pargi(outcnt)
		          call flush(STDERR)
		       first = true
		       outcnt = 0
		    }
		 }
                 #------------------------------------------------
		 # assign the corr_photon to the the memory buffer
		 #------------------------------------------------
                 Memd[((ev + toffset - 1)/SZ_DOUBLE) + 1] = corr_photon

		 #---------------------------------------
		 # insert the region number, if necessary
		 #---------------------------------------
		 call qpc_putregion(ev, mval)
	      }
	   }
	   else
	      end_of_file = true
	}

	if (outside_range && !first){
	   call eprintf("            -- Repeated for %d event records!!\n\n")
	      call pargi(outcnt)
	      call flush(STDERR)
	}
end

# ------------------------------------------------------------------
# ------------------------------------------------------------------
procedure bar_close(fd, qphead, display, argv)

int	fd[MAX_ICHANS]                  # i: file descriptor
pointer qphead                          # i: header
int     display                         # i: display level
pointer argv                            # i: pointer to arg list
#pointer sp

include	"apply_bary.com"

begin


#---------
# Close up
#---------
        call tbtclo(tp)

#--------------------------------------------------------
# Free the space allocated in the call to "get_goodtimes"
#--------------------------------------------------------
       call def_close(fd, qphead, display, argv)

        call mfree(blist, TY_DOUBLE)
        call mfree(elist, TY_DOUBLE)

#-------------------------------------------
# Free all the common block calloc'ed memory
#-------------------------------------------
	call mfree(tbl_r1, TY_CHAR)
	call mfree(tbl_i1, TY_CHAR)
	call mfree(tbl_r2, TY_CHAR)
	call mfree(tbl_i2, TY_CHAR)
	call mfree(tbl_fname, TY_CHAR)
	call mfree(s2u_fname, TY_CHAR)

end
