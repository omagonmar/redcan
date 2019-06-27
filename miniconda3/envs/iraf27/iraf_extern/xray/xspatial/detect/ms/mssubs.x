# $Header: /home/pros/xray/xspatial/detect/ms/RCS/mssubs.x,v 11.0 1997/11/06 16:32:39 prosb Exp $
# $Log: mssubs.x,v $
# Revision 11.0  1997/11/06 16:32:39  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:52:03  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  15:14:31  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:35:29  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:19:59  prosb
#General Release 2.2
#
#Revision 1.1  93/05/13  12:07:02  janet
#Initial revision
#
#
# Module:	mssubs.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	Set of Utility subroutines for match srcs
# Includes:	matchit(), compute_dist(), attach_lead_node(), 
#               add_mtch_node(), never_match(), ms_results(),
#               write_ms_info(), get_node(), prnt_node()
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	{0} JD - initial version - Apr 93
#		{n} <who> -- <does what> -- <when>
#
# --------------------------------------------------------------------------

include  <tbset.h>
include  <mach.h>
include  "ms.h"

# --------------------------------------------------------------------------
# Read the next source from the source table and assign the info to a node
# --------------------------------------------------------------------------
procedure get_node (tb, icolptr, row, overide, node)

pointer tb		#i: input table pointer
pointer icolptr[ARB]    #i: input column pointers
int     row		#i: current table row for next source
bool    overide         #i: overide input errors from file

pointer node    	#o: node with data storage

int     col             #l: column pointer

bool    nullflag[25]

begin

        # allocate the new node
        call malloc (node, LEN_NODE, TY_STRUCT)

        # assign source info from table
        MS_NXT(node)  = 0
        MS_MTCH(node) = 0
        MS_ID(node)   = row

        # read source pos info from current row
        col = 1
        call tbrgtr (tb, icolptr[col], MS_POSX(node), nullflag, 1, row)
        col = col + 1
        call tbrgtr (tb, icolptr[col], MS_POSY(node), nullflag, 1, row)
        col = col + 1
        if ( overide ) {
           MS_ERR(node)  = 1.0
        } else {
           call tbrgtr (tb, icolptr[col], MS_ERR(node), nullflag, 1, row)
           # just in case the error we read is 0, 
           # lets replace it with a big number.
           if ( MS_ERR(node) < EPSILONR ) {
	        MS_ERR(node) = (real(MAX_SHORT))**0.5
	   }
        }   
        col = col + 1
        call tbrgtr (tb, icolptr[col], MS_SNR(node), nullflag, 1, row)
        col = col + 1
        call tbrgti (tb, icolptr[col], MS_CELLX(node), nullflag, 1, row)
        col = col + 1
        call tbrgti (tb, icolptr[col], MS_CELLY(node), nullflag, 1, row)

end

# --------------------------------------------------------------------------
# Main procedure to attach a new node to the match list either by matching
# to existing set or starting a new one. 
# --------------------------------------------------------------------------
procedure matchit (new, list, err_fact, rowid, max_match, overide, display)

pointer new		# i: New node to match
pointer list		# i: pointer to existing structure
real    err_fact	# i: Match tolerance
int     rowid	        # i: source number from input table
int     max_match	# i: maximum number of matches 
bool    overide         # i: indicates whether to overide errs in calc

int     display		# i: display level

int	num_mtch	# l: number of matches from 1 detection

real    dist		# l: distance between 2 sources
real    sav_dist	# l: closest of multi match distance
real    tol             # l: computed distance tolerance

bool 	done		# l: indicates whether the list has been exhausted

pointer unq		# l: unique node pointer
pointer lead		# l: lead node pointer
pointer sav_node	# l: node pointer with closest distance

#bool    never_match()

begin


   # if the list is empty, initialize it with the first node
   if ( list == 0 ) {

        call attach_lead_node (lead, new)
        list = lead

        max_match = MS_ID(lead)

   } else {
   # We have nodes ... so look through the lead nodes and determine whether
   #                   the new detection is within our tolerance distance 
   #                   with one or more sources, match with closest dist if >1.
        unq = list
        done = false
        sav_dist = MAX_REAL
        sav_node = 0
        num_mtch = 0

        # Vertical check
        while ( !done ) {

           # we want to free nodes when we know they will not be matched
           # with any more sources, check posy's for determination
#          if ( never_match (unq, new, 2.0*tol) ) {
#             call write_ms_info (unq)
#             call free_node (unq)
#          }

	   # compute the distance between the detection and the current 
           # lead node in the list
	   call compute_dist (unq, new, overide, err_fact, dist, tol)

	   # if we are within the tolerance a match is noted.
           if ( dist <= tol ) {

              num_mtch = num_mtch + 1

              # We save the node with the closest distance when >1 match occurs
              if ( dist < sav_dist ) {
                 sav_dist = dist
	         sav_node = unq 
	      }
	   }

           # Make the next node the current source
           if ( MS_NXT(unq) == 0 ) {
              done = true
           } else {
              unq = MS_NXT(unq)
           }
        }

        # If we DID NOT match ... add a Unique Source node to the
        #                         end of the list
        if ( num_mtch == 0 ) {
            call attach_lead_node (lead, new)
            MS_NXT(unq) = lead

            max_match = max (max_match, MS_ID(lead))

        } else {
	# If we DID match ... add the source to the current chain,
        #                     & update the info in the lead node.

            call add_mtch_node (sav_node, new)
            max_match = max (max_match, MS_ID(sav_node))

            # if there we're more than one match, print warning
            if ( num_mtch > 1 ) {
	       call printf ("Warning: Detection %d at (%.2f, %.2f) matches %d Sources\n")
                  call pargi (rowid)
	          call pargr (MS_POSX(new))
	          call pargr (MS_POSY(new))
                  call pargi (num_mtch)
	       call printf("         Assigning to Source with closest distance.\n")
            }
        }
   }

end

# --------------------------------------------------------------------------
# Compute the distance between the new detection and the average of the sources
# already matched.  The ra/dec sum and number of node currently matched at
# a position are kept in storage in the lead node.
# --------------------------------------------------------------------------
procedure compute_dist (unq, new, overide, err_fact, dist, tol)

pointer	unq		#i: lead node to compare
pointer	new		#i: new node looking for match
bool    overide		#i: indicates whether to overide errors in infile
real    err_fact	#i: fidge factor
real    dist		#o: computed distance
real    tol		#o: computed tolerance

real	xavg, yavg	#l: average of matched source positions
real	xnew, ynew	#l: position to match
real    eavg            #l: average error

begin

        # compute the average from the position terms saved in the lead node
        call calc_posavgs (unq, xavg, yavg, eavg)

        xnew = MS_POSX(new)
        ynew = MS_POSY(new)

	# compute the distance
        dist = ( (xnew - xavg)**2 + (ynew - yavg)**2 )*0.5


        # Compute the tolerance, 
        # if overide set we use the err_fact as the tolerance.
        if ( !overide ) {
	   tol = (MS_ERR(new) + eavg) * err_fact
        } else {
	   tol = err_fact
	}
 
end


# --------------------------------------------------------------------------
# When we add a Unique Source to our list, a Lead node with a varied version
# of node contents is prepended.  In Posx/y there is a sum of the posx/y for
# the matched sources, for id the is the sum of attached match nodes.
# --------------------------------------------------------------------------
procedure attach_lead_node (lead, new)

pointer	lead		#i: lead node with slightly altered data storage
pointer new		#i: first node in match list


begin

        # allocate the new node
        call malloc (lead, LEN_NODE, TY_STRUCT)

        # assign info to lead node
        MS_NXT(lead)  = 0
        MS_MTCH(lead) = new
        MS_ID(lead)   = 1
        MS_POSX(lead) = 0.0 
        MS_POSY(lead) = 0.0
        MS_ERR(lead)  = 0.0
        MS_SNR(lead) = 0.0

        call upd_lead_terms (lead, new)

end

# --------------------------------------------------------------------------
# Add a node to the list of detections that match a particular source.  
# Update lead node info.
# --------------------------------------------------------------------------
procedure add_mtch_node (unq, new)

pointer unq		#i: lead node for a unique source
pointer new		#i: node to add to unique list

pointer mtch		#l: pointer to list of sources that match

bool    insert_here     #l: indicates if we insert the new node at current pos

begin

	# If we DID match ... add the source to the current chain,
        #                     & update the info in the lead node.
        mtch = unq
        insert_here = false

	# Horizontal check
        # the matched detections are stored in decreasing SNR order,
        # so search the current list for the insertion place.
        while ( !insert_here && MS_MTCH(mtch) != 0 ) {

           if ( MS_SNR(new) > MS_SNR(MS_MTCH(mtch)) ) {
              insert_here = true
	   } else {
              mtch = MS_MTCH(mtch)
	   }
        }

        # we found the place, so insert the node.
        if ( insert_here ) {
           MS_MTCH(new) = MS_MTCH(mtch)
           MS_MTCH(mtch) = new

        # it belongs at the end of the list if no insertion found
	} else {
           MS_MTCH(mtch) = new
	}

        # update the lead node
        MS_ID(unq) = MS_ID(unq) + 1
        call upd_lead_terms (unq, new)
 

end

# --------------------------------------------------------------------------
# Update the lead position terms
# 	posx & y terms = sum of (x/err**2) for each src match
# 	err term       = sum of (1/err**2) for each src match
# --------------------------------------------------------------------------
procedure upd_lead_terms (lead, new)

pointer lead		#i: pointer to lead node
pointer new		#i: pointer to new node

real	errsq		#l: error squared

begin

        errsq = MS_ERR(new)**2.0

        # posx & y terms = sum of (x/err**2) for each src match
        MS_POSX(lead) = MS_POSX(lead) + ( MS_POSX(new) / errsq )
        MS_POSY(lead) = MS_POSY(lead) + ( MS_POSY(new) / errsq )

        # err term = sum of (1/err**2) for each src match
        MS_ERR(lead) = MS_ERR(lead) + ( 1.0 / errsq )

end

# --------------------------------------------------------------------------
#   Work through the linked-list and output the match results
# --------------------------------------------------------------------------
procedure ms_results (ict, lead, otp, ocolptr, display)

pointer ict		# i: wcs handle
pointer lead		# i: pointer to the first node in the list
pointer otp		# i: output table handle
pointer ocolptr[ARB]	# i: output column definition buffer
int	display		# i: display level

pointer node		# l: node pointer
bool    done		# l: indicates when finished
int     srcnum		# l: source counter

begin

	done = false
        srcnum=0

        if ( display >= 2 ) {
           call printf ("\n         Avg ra       Avg dec   Avg x     Avg y     Best x    Best y   Src ref\n")
           call printf ("                                (physical pixels)   (physical pixels)  (row #)\n")
           call printf ("-----------------------------------------------------------------------------\n")
        }

        # Loop through the Nodes in our list
        while ( !done ) {

           if ( display >= 4 ) {
	      call prnt_node (lead)
	   }

	   # write the match data to the output table
           srcnum = srcnum + 1
           call write_ms_info (lead, ict, otp, ocolptr, srcnum, display)

           # increment the lead node to the next source
           node = lead 
           if ( MS_NXT(lead) == 0 ) {
               done = true
	   } else {
	      lead = MS_NXT(lead)
           }

           # free the node when done
           call mfree(node, TY_STRUCT)
        }

end

# --------------------------------------------------------------------------
# write_ms_info - write the ms info to the table for all the matches of a 
#                 single source
# --------------------------------------------------------------------------
procedure write_ms_info (unq, ict, otp, ocolptr, srcnum, display)

pointer unq			#i: node pointer
pointer ict			#i: wcs pointer
pointer otp			#i: output table handle
pointer ocolptr[ARB]		#i: output table column pointers
int     srcnum			#i: source counter
int     display			#i: display level

int	cellx, celly		#l: det cell size of detection with highest snr

real	avgx, avgy		#l: average pixel position
real	avgra, avgdec		#l: ra & dec of avg pixel position
real    avgerr                  #l: average error
real    bestx, besty		#l: pixel position of detection with highest snr
pointer mtch	                #l: matched source pointer
pointer node			#l: free node pointer

int     num_mtch
int     col
bool    done			#l: indicates when through the list

begin

        done = false
        num_mtch = 0

        # compute avg position and write it out
        call calc_posavgs (unq, avgx, avgy, avgerr)

        if (MS_ID(unq) > NUM_MS_OUT) {
	   call printf ("Warning: Writing %d of %d matched sources for composite region %d\n")
             call pargi (NUM_MS_OUT)
             call pargi (MS_ID(unq))
             call pargi (srcnum)
        }
 
        # Convert wcs physical coords to world coords
        call mw_c2tranr (ict, avgx, avgy, avgra, avgdec)

        # loop through the matched source list and write the Src id.
        mtch = MS_MTCH(unq)
        while ( !done && num_mtch < NUM_MS_OUT ) {

           num_mtch = num_mtch + 1

           if ( num_mtch == 1 ) {
              bestx = MS_POSX(mtch)
              besty = MS_POSY(mtch)
              cellx = MS_CELLX(mtch)
              celly = MS_CELLY(mtch)

              col = 1
              call tbrptr (otp, ocolptr[col], avgra, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], avgdec, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], avgx, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], avgy, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], avgerr, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], bestx, 1, srcnum)
              col = col+1
              call tbrptr (otp, ocolptr[col], besty, 1, srcnum)
              col = col+1
              call tbrpti (otp, ocolptr[col], cellx, 1, srcnum)
              col = col+1
              call tbrpti (otp, ocolptr[col], celly, 1, srcnum)

              if ( display >= 2 ) {
                 call printf (   "%4d %12H %12h  %.3f  %.3f  %.3f  %.3f  ")
                 call pargi(srcnum)
                 call pargr(avgra)
                 call pargr(avgdec)
                 call pargr(avgx)
                 call pargr(avgy)
                 call pargr(bestx)
                 call pargr(besty)
              }
           }

           # write the row numbers that correspond to the rows in the 
           # input table to identify the detections that are matched
           # to the current source 
           call tbrpti (otp, ocolptr[col+num_mtch], MS_ID(mtch), 1, srcnum)

           if ( display >= 2 ) {
              call printf ("%d ")
                 call pargi (MS_ID(mtch))
	   }


           # increment the node and free it
           node = mtch
           if ( MS_MTCH(mtch) == 0 ) {
              done = true
	   } else {
	      mtch= MS_MTCH(mtch)
           }
           MS_MTCH(unq) = mtch
           call mfree(node, TY_STRUCT)

        }
        if ( display >= 2 ) {
           call printf ("\n")
        }

end

# --------------------------------------------------------------------------
# calc position averages from the terms saved in the lead node
# --------------------------------------------------------------------------
procedure calc_posavgs (lead, xavg, yavg, eavg)

pointer lead		# pointer to lead node of source
real    xavg		# average x pixel pos
real    yavg		# average y pixel pos
real    eavg		# average error on position


begin

        xavg = MS_POSX(lead)/MS_ERR(lead)
        yavg = MS_POSY(lead)/MS_ERR(lead)

        eavg = 1.0 / MS_ERR(lead)

end


# --------------------------------------------------------------------------
# initialize the input source positions table
# --------------------------------------------------------------------------
procedure init_srctab (tb, icolptr, num_srcs)

pointer tb			# i: input table handle
pointer icolptr[ARB]		# i: column pointer
int     num_srcs		# i: number of input ruf positions

int     col			# l: current column pointer
int     i			# l: loop counter

int     tbpsta()

begin

        # get the number of input sources
        num_srcs = tbpsta (tb, TBL_NROWS)

        # init the columns for this file
        col=1
	call tbcfnd (tb, "x",     icolptr[col], 1)
	col = col+1
	call tbcfnd (tb, "y",     icolptr[col], 1)
	col = col+1
	call tbcfnd (tb, "pconf", icolptr[col], 1)
	col = col+1
	call tbcfnd (tb, "snr",   icolptr[col], 1)
	col = col+1
	call tbcfnd (tb, "cellx", icolptr[col], 1)
	col = col+1
	call tbcfnd (tb, "celly", icolptr[col], 1)
	do i = 1, col {
           if ( icolptr[i] == NULL ) {
	     call error (1, "All Input columns (x,y,pconf,snr,cellx,celly) not found")
	   }
	}

end

# --------------------------------------------------------------------------
# initialize the output match source table
# --------------------------------------------------------------------------
procedure init_matchtab (otb, ocolptr, num_matches, display)

pointer otb			# i: input table handle
pointer ocolptr[ARB]		# i: column pointer
int     num_matches		# i: number of input ruf positions
int     display			# i: display level

char    colname[4]		# l: name of match columns

int     i			# l: loop counter
int     num_out			# l: number of output matches for each row
int     row			# l: row counter

begin

        # num_matches is the max matches in any row, 
        # we output the that num_matches columns unless it is larger than our 
        # max allowed columns, then we output NUM_MS_OUT and display warning.
        num_out = min (num_matches, NUM_MS_OUT)
        if ( display >= 3 ) {
           call printf ("\nMax matches for a Source is %d, and the max allowed is %d\n")
              call pargi(num_matches)
              call pargi(NUM_MS_OUT)
           call printf ("Writing %d match columns to output table\n")
              call pargi(num_out)
        }

        # Init the positions data columns
	row = 1
      	call tbcdef(otb,ocolptr[row],"avgra","degrees","%9.4f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"avgdec","degrees","%9.4f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"avgx","phys pixels","%7.1f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"avgy","phys pixels","%7.1f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"avgerr","phys pixels","%7.1f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"bestx","phys pixels","%7.1f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"besty","phys pixels","%7.1f",TY_REAL,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"cellx","arc seconds","%4d",TY_INT,1,1)

	row = row + 1
      	call tbcdef(otb,ocolptr[row],"celly","arc seconds","%4d",TY_INT,1,1)

        # Init the match columns based of the max matches in all of the rows
      	do i = 1, num_out {

	   call sprintf (colname, SZ_LINE, "m%d")
             call pargi(i)
           call strip_white(colname)

           row = row+1
      	   call tbcdef (otb, ocolptr[row], colname,
                        "unique row reference","%5d",TY_INT,1,1)
      	}
      	call tbtcre(otb)
end

# ---------------------------------------------------------------------
#
# Function:       WR_MHEAD
# Purpose:        write the match source table header
# Precondition:   table open
#
# ---------------------------------------------------------------------
procedure wr_mhead (otp, display, unqname, qpname)

pointer otp             # output positions table pointer
int     display         # display level
char    unqname[ARB]    # unique table filename
char    qpname[ARB]     # qpoe reference filename

begin
        call tbhadt (otp, "minfo", "--- Lmatchsrc Column description ---")
        call tbhadt (otp, "avgra",  "average ra in degrees")
        call tbhadt (otp, "avgdec", "average dec in degrees")
        call tbhadt (otp, "avgx",   "average x position in pixels")
        call tbhadt (otp, "avgy",   "average y position in pixels")
        call tbhadt (otp, "avgerr", "average position error in pixels")
        call tbhadt (otp, "bestx",  "x position in pixels of src with highest snr")
        call tbhadt (otp, "besty",  "y position in pixels of src with highest snr")
        call tbhadt (otp, "cellx",  "best x cell size in arc-seconds")
        call tbhadt (otp, "celly",  "best y cell size in arc-seconds")
        call tbhadt (otp, "mn", "match row reference of detection in _unq.tab")
	call tbhadt (otp, "RefTable", unqname)
	call tbhadt (otp, "RefQpoe", qpname)
end

# --------------------------------------------------------------------------
# Print the information in the current lead node - extreme debug info
# --------------------------------------------------------------------------
procedure prnt_node (node)

pointer node    	#i: node with data storage

begin

        call printf ("--------------------------------------------------\n")

	call printf ("     pointers: %d   %d\n")
           call pargi (MS_NXT(node))
           call pargi (MS_MTCH(node))

        call printf ("Node id: %d, Pos: %.3f, %.3f\n")
           call pargi (MS_ID(node))
           call pargr (MS_POSX(node))
           call pargr (MS_POSY(node))

        call printf ("\n")

end

# --------------------------------------------------------------------------
# Since our input sources are in y,x sort order, we can tell when we will
# never match with a source in our table again.  This enables us to clear
# our list of nodes outside the y tolerance..
# ****** not yet implemented *******
# --------------------------------------------------------------------------
bool procedure never_match (src1, src2, never_tol)

pointer src1		#i: a source to compare
pointer src2		#i: a source to compare
real	never_tol	#i: y diff when sources will never match

begin

  
  if ( MS_NXT(src1) != 0 )  {

        if ( abs ( MS_POSY(MS_NXT(src1)) - MS_POSY(src2) ) > never_tol) {
           return (true)
	}

   }
   return (false)

end

