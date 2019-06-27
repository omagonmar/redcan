#Header:
#Log:
#
# ---------------------------------------------------------------------
#
# Module:       DMRSUBS.X
# Project:      PROS -- ROSAT RSDC
# Purpose:           
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Janet DePonte -- Mar 1992 -- initial version 
#               {#} <who> -- <when> -- <does what>
#
# ---------------------------------------------------------------------
include <tbset.h>

# ---------------------------------------------------------------------
# regout:
# open and read the physical coords from a table file and output either
# a box or circle region in the logical coords of the reference image. 
# ---------------------------------------------------------------------
procedure regout (tabname, ict, optr, as_per_pix, regtype, display)

char 	tabname[ARB]	#i: input table file name with x,y,cellx,celly cols
pointer ict		#i: wcs handle for phys to log conversion
pointer optr		#i: output ascii file handle
real    as_per_pix	#i: arcseconds to pixel conversion
char    regtype[ARB]    #i: box or circle
int     display		#i: display level

bool    nullflag[10]    #l: for table input

pointer itp		#l: input table handle

int     cellx		#l: det cell size in x in arcsecs
int     celly		#l: det cell size in x in arcsecs
int     col[10]		#l: column pointer
int     i               #l: loop counter
int     num_rows        #l: number of rows in input table
int     pixx		#l: det cell size in x in pixels
int     pixy		#l: det cell size in x in pixels

real    logx		#l: x position in phys coords
real    logy		#l: y position in phys coords
real    physx		#l: x position in phys coords
real    physy		#l: y position in phys coords
real    radius          #l: half a detect cell 

bool    streq()
int     tbpsta()
pointer tbtopn()

begin

#   Open the table file so that we can read the x, y, cellx & celly columns
        itp = tbtopn (tabname, READ_ONLY, 0)
      	num_rows = tbpsta (itp, TBL_NROWS)

	if ( display >= 2 ) {
           call printf ("Processing %d rows in table %s\n")
             call pargi (num_rows)
	     call pargstr (tabname)
	}

#   Init the columns
	if ( streq (regtype,"rotbox") ) {
      	  call tbcfnd (itp, "avgx", col[1], 1)
      	  call tbcfnd (itp, "avgy", col[2], 1)
	} else {
      	  call tbcfnd (itp, "x", col[1], 1)
      	  call tbcfnd (itp, "y", col[2], 1)
	}
      	call tbcfnd (itp, "cellx", col[3], 1)
      	call tbcfnd (itp, "celly", col[4], 1)

#   Read all the table rows and write out the region
	do i = 1, num_rows {
	   call tbrgtr (itp, col[1], physx, nullflag, 1, i)
           call tbrgtr (itp, col[2], physy, nullflag, 1, i)
           call tbrgti (itp, col[3], cellx, nullflag, 1, i)
           call tbrgti (itp, col[4], celly, nullflag, 1, i)

           pixx = nint (cellx/as_per_pix)
           pixy = nint (celly/as_per_pix)

	   radius = (cellx/as_per_pix)/2.0

#   Convert from physical coords to logical coords
           call mw_c2tranr (ict, physx, physy, logx, logy)

	   if ( display >= 3 ) {
              call printf ("phys -> log: %.1f %.1f %d %d -> %.1f %.1f %d %d\n")
                 call pargr (physx)
                 call pargr (physy)
	         call pargi (cellx)
	         call pargi (celly)

                 call pargr (logx)
                 call pargr (logy)
                 call pargi (pixx)
                 call pargi (pixy)
	   }

#   Write the physical input coords in comments to the region file
           call fprintf (optr,"## %.1f %.1f %d %d\n")
              call pargr (physx)
              call pargr (physy)
	      call pargi (cellx)
	      call pargi (celly)

#   Write out a circle region in logical coords
	   if ( streq (regtype,"circle") ) {
	      call fprintf (optr, "circle %.1f %.1f %.1f\n")
                 call pargr (logx)
                 call pargr (logy)
                 call pargr (radius)

#   Write out a box region in logical coords
	   } else if ( streq (regtype,"box") ) {
              call fprintf (optr, "- box %.1f %.1f %d %d\n")
                 call pargr (logx)
                 call pargr (logy)
                 call pargi (pixx)
                 call pargi (pixy)

#   Write out a rotbox region in logical coords
	   } else if ( streq (regtype,"rotbox") ) {
              call fprintf (optr, "- box %.1f %.1f %d %d 45\n")
                 call pargr (logx)
                 call pargr (logy)
                 call pargi (pixx)
                 call pargi (pixy)
	   }
	}
        call tbtclo (itp)

        if ( display > 0 ) { 
           call flush(STDOUT)
	}

end

# ---------------------------------------------------------------------
