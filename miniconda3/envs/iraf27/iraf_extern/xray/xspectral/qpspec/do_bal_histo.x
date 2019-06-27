# $Header: /home/pros/xray/xspectral/qpspec/RCS/do_bal_histo.x,v 11.0 1997/11/06 16:43:29 prosb Exp $
# $Log: do_bal_histo.x,v $
# Revision 11.0  1997/11/06 16:43:29  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:31:45  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/10  14:07:11  dvs
#Passes gtf and sim [i.e., qp] into bal_histo.  No longer
#passes in goodtime.  These changes are to make the bal histogram
#code sensitive to the qpoe deffilt.
#
#Revision 7.0  93/12/27  18:58:17  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:53:42  prosb
#General Release 2.2
#
#Revision 5.2  93/05/12  15:44:51  orszak
#jso - freed some memory.
#
#Revision 5.1  93/05/08  17:56:06  orszak
#jso - changed display levels.
#
#Revision 5.0  92/10/29  22:46:46  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  15:29:02  prosb
#General Release 2.0:  April 1992
#
#Revision 1.1  92/03/05  12:59:12  orszak
#Initial revision
#
#
# Function:	do_bal_histo
# Purpose:	Get the BAL histogram and fill the structure.
# Pre-cond:	1) BAL histogram structure allocated
#		2) DS_X and DS_Y must be set (to sky coordinate), to get
#		the BAL histrogram from qpoe file.
#
# Post-cond:	
#		
# Method:	
# Description:	
# Notes:	1) This routine expects the balstr to be set to 15.2 if
#		extract is from PI channels.
#		2) If balstr is a space (" ") it converted back into a
#		NULL, and BAL histogram is taken from qpoe file.
#

include <ctype.h>

include <spectral.h>

include "qpspec.h"

procedure do_bal_histo(balstr, bh, gtf, ds, sim, sbn, display)

char	balstr[ARB]		# i: bal histo string

int	debug			# l: bal debug level calculated from display
int	display			# i: display level
int	nblt			# l: number of blt records in qpoe file

pointer	bh			# io: bal histo pointer
pointer	blt			# l: pointer to blt records
pointer	ds			# i: data set record pointer
pointer gtf			# i: good time filter
pointer	sbn			# i: instrument-specific binning parameters
pointer	sim 			# i: source qpoe pointer

bool	streq()			# string compare

begin

	switch ( BN_INST(sbn) ) {

	#----------------------------------------------
	# First lets make sure this is the Einstein IPC
	#----------------------------------------------
	case EINSTEIN_IPC:

	    #--------------------------------------------------------
	    # If balstr is null get temporal BAL from qpoe file.
	    # If balstr has been set to a space, which has no meaning
	    # and which asc_bal_histo does not handle well, I will 
	    # get the temporal BAL from qpoe file.
	    #--------------------------------------------------------
	    if ( streq("", balstr) || streq(" ", balstr) ) {

		call get_qpbal( sim, blt, nblt)

		#-----------------------------
		# We must get at least one BAL
		#-----------------------------
		if ( nblt == 0 ) {
		    call error( 1,
			"QPSPEC: No BAL records in qpoe file for BAL histo")
		}

		#----------------------------------
		# Set the debug level for bal_histo
		#----------------------------------
		if ( display >= 5 )
		    debug = 1
		else
		    debug = 0

		#--------------------------
		# Extract the BAL histogram
		#--------------------------
		call bal_histo(DS_X(ds), DS_Y(ds), sim, blt, nblt, bh, gtf,
				 YES, debug)
	    }

	    #-----------------------------------------------------------
	    # If balstr has been set use that to calculate BAL histogram
	    #-----------------------------------------------------------
	    else {
		call asc_bal_histo(balstr, bh)
	    } # end ascii

	#-------------------------------
	# Another instrument is an error
	#-------------------------------
	default:
	    call error( 1,
		"QPSPEC: Cannot calculate BAL histogram for this instrument")
	}

	#-----------------------
	# deallocate BLT pointer
	#-----------------------
	call mfree(blt, TY_STRUCT)

end
