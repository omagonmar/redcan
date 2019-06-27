# $Header: /home/pros/xray/xspatial/eintools/cat2exp/RCS/exp_tools.x,v 11.0 1997/11/06 16:31:05 prosb Exp $
# $Log: exp_tools.x,v $
# Revision 11.0  1997/11/06 16:31:05  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 18:48:55  prosb
# General Release 2.4
#
#Revision 1.2  1994/08/04  13:58:44  dvs
#No change.
#
#Revision 1.1  94/03/15  09:09:59  prosb
#Initial revision
#
#
#--------------------------------------------------------------------------
# Module:       exp_tools.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     cat2exp
# Internal:     exp_setup,exp_check,mk_exp,mk_cell_row,in_geom,
#		put_cell_row_i,put_cell_row_r,exp_header,exp_hist
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 3/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------
 
include "../tables/geom.h"
include "../tables/cat.h"
include "../source/et_err.h"
include <imhdr.h>
include <qpoe.h>
include <math.h>

#--------------------------------------------------------------------------
# Procedure:    cat2exp()
#
# Purpose:      Make exposure mask from CAT
#
# Input variables:
#               qpoe_name       input qpoe file name
#               cat_name        input constant aspect table name
#		exp_name	output exposure mask name
#		final_exp_name	name of final exposure mask [for history]
#		geom_name	name of IPC geometry file
#		full_exp	are we making full exposure?
#		cell_size	exposure cell size
#		exp_max		(for PL files) integer max
#               display         display level
#
# Description:  This is the main routine for the task cat2exp.  It 
#		will create an exposure mask from a constant aspect
#		by applying each row of aspect to the IPC geometry
#		(as defined in the IPC geometry file).  The parameter
#		full_exp determines which row from the IPC geometry
#		file to use.  The parameter cell_size indicates how
#		fine the resulution of the exposure mask should be --
#		for instance, if cell_size is 4, then the mask will
#		consist of 4x4 pixels, each with the same value.
#		(The most previce exposure mask will be cell_size=1.)
#
#		If the output exposure mask is a PL mask, the
#		exposure of the image will be rescaled to be between
#		0 and exp_max.  If the output exposure file is an
#		image file (it can't be a QPOE file), the exposure
#		is not scaled (and exp_max is ignored).
#
#		Note that the total exposure used in constructing the
#		exposure mask will probably be close to the exposure
#		time of the QPOE file times the dead time correction.
#		These values might differ due to minor discrepencies
#		between GTIs and BLT records or because the user
#		included a time filter when making the CAT.
#
# Algorithm:    * Open image, QPOE, and tables
#		* Perform some dummy checking
#		* Read in CAT data
#		* Read in IPC geometry data
#		* Make exposure mask
#		* Write out header and history to exposure mask
#               * Release memory
#--------------------------------------------------------------------------

procedure cat2exp(qpoe_name,cat_name,exp_name,final_exp_name,geom_name,
		      full_exp,cell_size,exp_max,display )
char    qpoe_name[ARB]      # i: name of input QPOE file
char    cat_name[ARB]       # i: name for CAT
char	exp_name[ARB]	    # i: name for output exposure mask
char	final_exp_name[ARB] # i: ACTUAL final exposure mask name
char	geom_name[ARB]	    # i: IPC geometry table name
bool	full_exp	    # i: are we using full exposure
int	cell_size	    # i: cell size of exposure mask
int	exp_max		    # i: maximum value of exposure mask
int     display             # i: display level (0-5)

### LOCAL VARS ###

int	n_cat		# number of rows in CAT
pointer tp_cat		# pointer to constant aspect table
pointer cat_col_ptr[N_COL_CAT]  # column pointers for CAT
pointer p_cat_info	# pointer to CAT info (see gt_info.x)
pointer p_cat_data	# pointer to data read from CAT
int	n_geom		# number of rows in GEOM
pointer tp_geom		# pointer to GEOM table
pointer geom_col_ptr[N_COL_GEOM] # column pointers for GEOM
pointer p_geom_info	# pointer to GEOM info (see gt_info.x)
pointer p_geom_data	# pointer to data read from GEOM
int	geom_row	# which row to read from GEOM
pointer ip		# image pointer
pointer qp		# QPOE file pointer
pointer	qphead		# QPOE header
double	total_exp	# total exposure found from CAT

### EXTERNAL FUNCTION DECLARATIONS ###

int	gt_open()  # returns number of rows in table [../tables/gt_file.x]
pointer immap()    # returns pointer to image [sys/imio]
pointer qp_open()  # returns pointer to QPOE [sys/qpoe]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
	# open image file
        #----------------------------------------------
	ip=immap(exp_name,NEW_IMAGE,0)

        #----------------------------------------------
	# open qpoe file and read in header
        #----------------------------------------------

	qp=qp_open(qpoe_name,READ_ONLY,0)
	call get_qphead(qp,qphead)

        #----------------------------------------------
	# open tables
        #----------------------------------------------
	call cat_setup(p_cat_info)
	n_cat=gt_open(cat_name,READ_ONLY,tp_cat,cat_col_ptr,p_cat_info)
	call geom_setup(p_geom_info)
	n_geom=gt_open(geom_name,READ_ONLY,tp_geom,geom_col_ptr,p_geom_info)
	
	if (n_geom!=2)
	{
	    call error(ET_WRONG_NUM_ROW,
	      "Geometry bounds file must have two rows.")
	}

        #----------------------------------------------
	# check CAT & GEOM keywords against QPOE file
        #----------------------------------------------
	call exp_check(qphead,tp_cat,tp_geom,display)

        #----------------------------------------------
	# read in cat data
        #----------------------------------------------
	call malloc(p_cat_data,n_cat*SZ_CAT,TY_STRUCT)
	call gt_get_rows(tp_cat,p_cat_info,cat_col_ptr,1,n_cat,true,p_cat_data)

        #----------------------------------------------
	# read in geometry data
        #----------------------------------------------
	call malloc(p_geom_data,SZ_GEOM,TY_STRUCT)
	if (full_exp)
	{
	    geom_row=2
	}
	else
	{
	    geom_row=1
	}
	call gt_get_row(tp_geom,p_geom_info,geom_col_ptr,
					geom_row,true,p_geom_data)


        #----------------------------------------------
	# make exposure mask!
        #----------------------------------------------
	call exp_setup(exp_name,ip,qphead)
	call mk_exp(ip,qp,qphead,p_geom_data,n_cat,p_cat_data,
				cell_size,exp_max,total_exp,display)

        #----------------------------------------------
	# write exposure header
        #----------------------------------------------
	call exp_header(qp,qphead,ip,total_exp)

        #----------------------------------------------
	# make history
        #----------------------------------------------
	call exp_hist(ip,cat_name,final_exp_name)

        #----------------------------------------------
	# free some memory
        #----------------------------------------------
	call mfree(p_cat_data,TY_STRUCT)
	call mfree(p_geom_data,TY_STRUCT)
	call mfree(qphead,TY_STRUCT)

        #----------------------------------------------
	# close tables and release table info from memory
        #----------------------------------------------
	call tbtclo(tp_cat)
	call tbtclo(tp_geom)
	call gt_free_info(p_geom_info)
	call gt_free_info(p_cat_info)
	
        #----------------------------------------------
	# close QPOE and image files
        #----------------------------------------------
	call qp_close(qp)
	call imunmap(ip)
end


#--------------------------------------------------------------------------
# Procedure:    exp_check
#
# Purpose:      Check certain properties of CAT, GEOM, and QPOE
#
# Input variables:
#               qphead		QPOE header
#		tp_cat		table pointer to CAT
#		tp_geom		table pointer to IPC geometry
#		display		display level
#
# Description:  This routine is used to give warning or error
#		messages if the user passed in the wrong QPOE or
#		CAT file.  It checks the following:
#
#		*  Nominal RA & DEC match between CAT and QPOE
#
#		*  QPOE dimensions match IPC geometry dimensions
#
#		Only the latter is considered an error.
#
# Note:		The nominal RA & DEC are compared as REALs, since
#		this is how they are stored in the QPOE header.
#--------------------------------------------------------------------------

procedure exp_check(qphead,tp_cat,tp_geom,display)
pointer	qphead		# i: QPOE header
pointer	tp_cat		# i: table pointer to CAT
pointer	tp_geom		# i: table pointer to GEOM
int	display		# i: display level

### LOCAL VARS ###

real	nomra	    	# nominal RA from CAT
real	nomdec		# nominal DEC from CAT
int	x_geom_dim	# X dimension of IPC geometry table
int	y_geom_dim	# Y dimension of IPC geometry table

### EXTERNAL FUNCTION DECLARATIONS ###

real	tbhgtr()	# returns real table header [tables]
int	tbhgti()	# returns integer table header [tables]
bool	fp_equalr()	# returns TRUE if reals are equal [sys/gio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Check nominal RA & DEC
        #----------------------------------------------
	nomra=tbhgtr(tp_cat,CAT_NOMRA)
	nomdec=tbhgtr(tp_cat,CAT_NOMDEC)

	if (display>0 && !(fp_equalr(nomra,QP_RAPT(qphead)) &&
		           fp_equalr(nomdec,QP_DECPT(qphead))) )
	{
	    call printf("\nWARNING: Nominal RA & DEC don't match between CAT and QPOE files.\n")
	    call flush(STDOUT)
	}	

        #----------------------------------------------
        # Check geometry dimensions
        #----------------------------------------------
	x_geom_dim=tbhgti(tp_geom,XDIM)
	y_geom_dim=tbhgti(tp_geom,YDIM)

	if (x_geom_dim!=QP_XDIM(qphead) || y_geom_dim!=QP_YDIM(qphead))
	{
	    call error(ET_WRONG_SIZE,
	      "QPOE dimensions do not match geometry table dimensions")
	}
end


#--------------------------------------------------------------------------
# Procedure:    exp_setup
#
# Purpose:      Set up the output exposure image
#
# Input variables:
#               exp_name	name of exposure image 
#		ip		image pointer to exposure file
#		qphead		QPOE header
#
# Description:  Fills in certain records in the image pointer for
#		the exposure file.  Specifically, this sets the
#		pixel type (integer or real), the number of
#		dimensions (2) and the length of the axes (which
#		will match the QPOE dimensions).
#
# Note:		There should be some way to detect if the file
#		name refers to a PL mask (as opposed to something
#		else??), but I couldn't find any such routine.
#
#		There probably is a better way to do this routine.
#--------------------------------------------------------------------------

procedure exp_setup(exp_name,ip,qphead)
char	exp_name[ARB]	# i: exposure file name
pointer	ip		# io: image pointer
pointer	qphead		# i: QPOE header

int	qp_access()     # returns TRUE if file exists and is QPOE [sys/qpio]
int	imaccess()	# returns TRUE if file exists and is IMH [sys/imio]
begin
        #----------------------------------------------
        # Set IM_PIXTYPE.  Depends on type of file.
        #----------------------------------------------
	if (qp_access(exp_name, 0) == YES )
	{
	    call error(ET_WRONG_FILETYPE,
		"Can not create a qpoe exposure file.")
	}
	else if( imaccess(exp_name, 0) == YES )
 	{
            IM_PIXTYPE(ip)=TY_REAL
	}
	else  #??? Is there some way to check if it is a PL mask???
	{
            IM_PIXTYPE(ip)=TY_INT
	}

        #----------------------------------------------
        # Set IM_NDIM and IM_LEN.
        #----------------------------------------------
        IM_NDIM(ip)=2
        IM_LEN(ip,1)=QP_XDIM(qphead)
        IM_LEN(ip,2)=QP_YDIM(qphead)
end

#--------------------------------------------------------------------------
# Procedure:    mk_exp
#
# Purpose:      The main routine which actually makes the exposure mask
#
# Input variables:
#               ip		image pointer [exposure image]
#		qp		qpoe file
#		qphead		qpoe header
#		p_geom_data	IPC geometry data [format in geom.h]
#		n_cat		number of rows in CAT
#		p_cat_data	CAT data [format in cat.h]
#		cell_size	exposure cell size
#		exp_max		PLIO value for maximum exposure
#		display		display level
#
# Output variables:
#		total_exp	total exposure [sum of CAT livetimes]
#
# Description:  Here is where we actually take the rows of the CAT
#		and produce the exposure mask.  
#
#		The exposure mask is broken up into cells, each of
#		size cell_size by cell_size.  Each cell is filled
#		with the same value, row by row, then written out
#		to the image file.
#
#		If display > 1, then we print out our progress
#		every 10 rows of cells.
#
#		What is the difference between exp_max and total_exp?
#		Good question!  The value exp_max is the integer
#		maximum in the output exposure mask ONLY IF IT IS
#		A PLIO MASK which will correspond to total_exp,
#		which is the actual total exposure of the QPOE.
#		
#		For instance, if total_exp=10300.0 seconds and
#		exp_max=32767, then in the final image values of
#		32767 will correspond to 10300.0 seconds.  Image
#		values of 16383 will correspond to about 5150.0
#		seconds.  And so on.
#
# Algorithm:
#		* Check that the cell size is legal
#		* Set aside memory for each row	
#		* Calculate total exposure
#		* Load MW info from QPOE 
#		* Loop through each cell row:
#		  * Fill cell row with data
#		  * Write cell row to image pointer
#		* Clear memory
#
# Note:		We have made a trade-off in this algorithm.  We
#		chose to fill in the image row by row.  For each
#		cell row, we must loop through all the CAT rows to
#		calculate the exposure level for each cell.  For
#		each CAT row, we must do some recalculations.  It
#		would be faster if we would loop on each CAT, then
#		loop on each cell row.  However, this would
#		necessitate setting aside potentially a 1024x1024
#		array of doubles, which is possibly too much 
#		memory.
#--------------------------------------------------------------------------

procedure mk_exp(ip,qp,qphead,p_geom_data,n_cat,p_cat_data,
				cell_size,exp_max,total_exp,display)
pointer	ip		# io: image pointer
pointer	qp		# i: QPOE
pointer	qphead		# i: QPOE header
pointer p_geom_data	# i: IPC geometry data
int	n_cat		# i: number of CAT rows
pointer p_cat_data	# i: pointer to CAT data
int	cell_size	# i: size of exposure cells
int	exp_max		# i: exposure maximum integer for PL masks
double  total_exp	# o: total exposure in image
int	display		# i: display level

### LOCAL VARS ###

int	i_cat		# index into CAT
pointer p_cell_row	# pointer to cell row data [array of doubles]
int	n_x_cell	# number of cells in the X dimension
int	n_y_cell	# number of cells in the Y dimension
int	i_y_cell	# index into the Y dimension cells
pointer ct		# coordinate transformation descriptor
pointer p_full_row	# pointer to data [array of doubles] for a
			# full row of data (not broken into cells).
			# This is used by the put_cell_row routines,
			# and we set aside memory here to save time.
pointer mw		# MWCS descriptor (for QPOE)
double  r_qp[2]  	# reference point for QPOE
double  w_qp[2]  	# world reference point (unused)
double  arc_qp[2] 	# scale factors for X&Y (unused)
double  roll_qp   	# QPOE roll (unused)

### EXTERNAL FUNCTION DECLARATIONS ###

pointer qp_loadwcs()    # pointer to MWCS descriptor [sys/qpoe]
pointer mw_sctran()     # pointer to CT descriptor [sys/mwcs]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Check cell sizes
        #----------------------------------------------
	if (mod(QP_XDIM(qphead),cell_size)!=0 || 
		mod(QP_YDIM(qphead),cell_size)!=0)
	{
	    call eprintf("Geometry dimensions: %d by %d\n")
	     call pargi(QP_XDIM(qphead))
	     call pargi(QP_YDIM(qphead))
	    call errori(ET_BAD_CELL_SIZE,
	         "Cell size must be a divisor of both dimensions",cell_size)
	}

        #----------------------------------------------
        # Find number of cells in X & Y dimensions
        #----------------------------------------------
	n_x_cell=QP_XDIM(qphead)/cell_size
	n_y_cell=QP_YDIM(qphead)/cell_size

        #----------------------------------------------
	# set aside space for each row.
        #----------------------------------------------
	call malloc(p_cell_row,n_x_cell,TY_DOUBLE)
	call malloc(p_full_row,QP_XDIM(qphead),IM_PIXTYPE(ip))

        #----------------------------------------------
	# calculate total exposure
        #----------------------------------------------
	total_exp=0.0D0
	do i_cat=1,n_cat
	{
	    total_exp = total_exp + CAT_LIVETIME(CAT(p_cat_data,i_cat))
	}

        #----------------------------------------------
	# open mw info (to translate ra & dec to image pixels)
        #----------------------------------------------
        mw=qp_loadwcs(qp)
        call bkwcs(mw,r_qp,w_qp,arc_qp,roll_qp)
        ct=mw_sctran(mw,"world","logical",3B)

        #----------------------------------------------
	# loop through each row.
        #----------------------------------------------
	do i_y_cell= 1,n_y_cell
	{
            #----------------------------------------------
	    # fill in cell_row data
            #----------------------------------------------
	    call mk_cell_row(r_qp,ct,cell_size,n_x_cell,i_y_cell,p_geom_data,
			   n_cat,p_cat_data,Memd[p_cell_row],display)
	   
            #----------------------------------------------
	    # write cell_row data to image pointer
            #----------------------------------------------
	    switch (IM_PIXTYPE(ip))
	    {
		case TY_INT:
		    call put_cell_row_i(n_x_cell,i_y_cell,Memd[p_cell_row],
	                        cell_size,Memi[p_full_row],ip,
        	                exp_max, total_exp,display)
		case TY_REAL:
	 	    call put_cell_row_r(n_x_cell,i_y_cell,Memd[p_cell_row],
		      		cell_size,Memr[p_full_row],ip,display)

		default:
                    call errori(ET_UNKNOWN_TYPE,
                      "MK_EXP: Unexpected pixtype",IM_PIXTYPE(ip))
	    }


	    if (display>1 && mod(i_y_cell,10)==0)
	    {
	      	call printf("Row # %d finished.\n")
		 call pargi(i_y_cell*cell_size)
	      	call flush(STDOUT)
	    }
	}

        #----------------------------------------------
        # free memory
        #----------------------------------------------
	call mfree(p_full_row,IM_PIXTYPE(ip))
	call mfree(p_cell_row,TY_DOUBLE)
        call mw_ctfree(ct)
        call mw_close(mw)
end

#--------------------------------------------------------------------------
# Procedure:    mk_cell_row
#
# Purpose:      Fill in a row of exposure cells with exposure values
#
# Input variables:
#		r_qp		reference point for QPOE
#		ct		coordinate transformation descriptor
#				(from "world" to "logical")
#		cell_size	number of pixels in each cell
#		n_x_cell	number of cells in a row
#		i_y_cell	which column of cells we're working on
#		p_geom_data	IPC geometry data [format in geom.h]
#				(these values are in PROS detector coords)
#               n_cat           number of rows in CAT
#               p_cat_data      CAT data [format in cat.h]
#               display         display level
#
# Output variables:
#               cell_row	array of doubles holding cell values
#
# Description:  This routine will fill in the array cell_row with the
#		values of each exposure cell with the appropriate
#		exposure value.  This value is calculated as follows.
#
#		We find the center point of the cell (image_x,image_y),
#		then for each row of the constant aspect table we find
#		the corresponding point in the detector, (geom_x,geom_y).
#		If this point falls within the IPC detector, we add the
#		livetime of this row of the CAT to this cell.
#
#		If, for example, a particular cell always maps back
#		into the IPC detector, its final value will be the
#		full exposure of the image.
#
#		In theory, we should be able to use the WCS information
#		in the CAT to our advantage.  The linear tranformation
#		in a row of the CAT maps from PROS detector coordinates
#		to sky coordinates.  We should be able to map the center
#		of the cell into sky coordinates (using the QPOE WCS),
#		then map backwards (via the CAT) into PROS detector
#		coordinates.
#
#		For some reason, I couldn't get this to work -- the
#		WCS transformations didn't work correctly.  As a
#		workaround, I have recalculated the aspect offsets from
#		the CAT data and used the routines in 
#		pros/lib/pros/asp.x to create a transformation matrix
#		"trmat" which maps from the QPOE image coordinates to
#		PROS detector coordinates.  Note that we lose precision
#		by using these routines.
#
# Algorithm:	* Find y-coordinate of the center of the cell row
#		* Clear cell row (and binning offsets)
#		* For each row of the CAT, do the following
#		  * Map sky coordinates RCRVL# back to image coordinates.
#		    (These were the sky reference points -- they map back
#		     via "ct" to the image tangent points, i.e., the 
#		     point which the image gets shifted to before
#		     being rotated.)
#		  * From these, recalculate the original aspect offsets
#		  * Find the transformation matrix which applies this
#		    aspect
#		  * Find the *inverse* of this matrix, since we want
#		    to deapply aspect
#		  * For each cell in the row, do the following.
#		    * Find x-coordinate of the cell center
#		    * Deaspect the cell center to PROS detector coords
#		    * If these coords fall within the IPC geometry,
#		      add CAT livetime to the cell row.
#
# Note:		See the routine get_wld_center in eintools/source for
#		the conversion from aspect offsets into WCS.
#--------------------------------------------------------------------------

procedure mk_cell_row(r_qp,ct,cell_size,n_x_cell,i_y_cell,p_geom_data,n_cat,
			p_cat_data,cell_row,display)
double  r_qp[2]         # i: reference point of QPOE file
pointer ct              # i: coordinate transformation descriptor
int	cell_size	# i: exposure cell size
int 	n_x_cell	# i: number of cells in a row
int	i_y_cell	# i: which cell row are we working on?
pointer p_geom_data	# i: IPC geometry data
int	n_cat		# i: number of CAT rows
pointer p_cat_data	# i: pointer to CAT data
double	cell_row[n_x_cell] # o: cell exposures
int	display		# i: display level

### LOCAL VARS ###

real	asp_offsets[3]  # recovered aspect offsets
real    bin_offsets[3]  # "bin offsets" -- always zero for Einstein IPC
			# (only used in asp_transmatx)
int	i_cat		# which CAT row?
pointer c_cat_data	# current CAT record
real	geom_x,geom_y	# cell center mapped into PROS detector coords
real	image_x,image_y # cell centers
int	i_x_cell	# which cell column are we working on?
double  im_tang_x,im_tang_y # image coords corresponding to RCRVL#
real    rmat[4]		# transformation matrix which applies aspect
real    trmat[4]	# transformation matrix which de-applies aspect
real	roll		# temporary value of roll, set to 0.0

### EXTERNAL FUNCTION DECLARATIONS ###

bool	in_geom()	# returns TRUE if point is in IPC geom [local]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # set geometry y coordinate to the center of the cell.
        #----------------------------------------------

	image_y= cell_size*i_y_cell - (cell_size/2)+0.5

        #----------------------------------------------
	# clear cell row and bin offsets
        #----------------------------------------------
	call aclrd(cell_row,n_x_cell)
	call aclrr(bin_offsets,3)

        #----------------------------------------------
	# loop through CAT rows
        #----------------------------------------------
	do i_cat=1,n_cat
	{
            #------------------------------------------------
 	    # Find image coords which map to RCRVL1 & RCRVL2
            #------------------------------------------------
	    c_cat_data=CAT(p_cat_data,i_cat)

            call mw_c2trand(ct,CAT_RCRVL1(c_cat_data),
                              CAT_RCRVL2(c_cat_data),
                              im_tang_x,im_tang_y)

            #----------------------------------------------
	    # make aspect offsets again 
            #----------------------------------------------
	    asp_offsets[1]=im_tang_x-r_qp[1]
	    asp_offsets[2]=im_tang_y-r_qp[2]
	    asp_offsets[3]=DEGTORAD(CAT_RCROT2(c_cat_data))

            #----------------------------------------------
	    # create RMAT transformation matrix
	    # (We use roll=0.0 because we've already
	    #  incorporated the roll in the aspect roll
	    #  offset.  No need to separate the two.)
            #----------------------------------------------
	    roll=0.0
	    call asp_transmatx(asp_offsets,bin_offsets,
			      roll,
			      real(r_qp[1]),real(r_qp[2]),rmat)

            #----------------------------------------------
	    # invert RMAT
            #----------------------------------------------
            call asp_invmatrix(rmat,trmat)

            #----------------------------------------------
	    # loop through each cell in the row
            #----------------------------------------------
	    do i_x_cell=1,n_x_cell
	    {
                #----------------------------------------------
		# find center of cell column
                #----------------------------------------------
	      	image_x = cell_size*i_x_cell - (cell_size/2)+0.5

                #----------------------------------------------
		# map cell center to PROS detector coords
                #----------------------------------------------
              	call asp_tranrot(trmat,image_x,image_y,geom_x,geom_y)

                #----------------------------------------------
		# is deaspected cell center in IPC geometry?
                #----------------------------------------------
	      	if (in_geom(geom_x,geom_y,p_geom_data))
	      	{
                    #----------------------------------------------
		    # Add CAT livetime (exposure) to this cell.
                    #----------------------------------------------
		    cell_row[i_x_cell]=cell_row[i_x_cell] +
				CAT_LIVETIME(c_cat_data)
	      	}
	    }	
	}

end


#--------------------------------------------------------------------------
# Procedure:    in_geom
#
# Purpose:      returns true if passed in point falls in IPC geometry
#
# Input variables:
#		geom_x,geom_y   point to check (in PROS det. coords)
#		p_geom_data	IPC geometry data
#
# Return Value: true if point is in IPC geometry
#
# Description:  This routine interprets the IPC geometry data to
#		determine if a passed in point falls inside the 
#		geometry.  See the table header in the geometry
#		table file for a description of the IPC geometry.
#--------------------------------------------------------------------------
bool procedure in_geom(geom_x,geom_y,p_geom_data)
real	geom_x
real	geom_y
pointer p_geom_data

bool 	is_in_geom
double	rib_width

begin
	is_in_geom=false

        #------------------------------------------------
	# First check that point is within main geometry
        #------------------------------------------------
      	if ((geom_x>=GEOM_XMIN(p_geom_data))&&
	    (geom_x<=GEOM_XMAX(p_geom_data))&&
	    (geom_y>=GEOM_YMIN(p_geom_data))&&
	    (geom_y<=GEOM_YMAX(p_geom_data)))
      	{  
            #----------------------------------------------
            # check that point doesn't fall on ribs
            #----------------------------------------------
	    rib_width=GEOM_RIBWID(p_geom_data)
	    if ((abs(geom_x-GEOM_XRIB1(p_geom_data))>=rib_width) &&
                (abs(geom_x-GEOM_XRIB2(p_geom_data))>=rib_width) &&
                (abs(geom_y-GEOM_YRIB1(p_geom_data))>=rib_width) &&
                (abs(geom_y-GEOM_YRIB2(p_geom_data))>=rib_width))
            {
		is_in_geom=true
	    }
	}
	return is_in_geom
end

#--------------------------------------------------------------------------
# Procedure:    put_cell_row_i
#
# Purpose:      This routine writes a cell row to an image file as 
#		integers
#
# Input variables:
#               n_x_cell	number of cells in row
#		i_y_cell	which row we are writing
#		cell_row	cell row data
#		cell_size	size of cell (in pixels)
#		full_row	buffer to use to store row data
#		ip		image pointer to write to
#		exp_max		integer value which should map to...
#		total_exp	total exposure in image
#               display         display level
#
# Description:  This routine writes the cell exposure data into the
#		final exposure mask.  It will convert the data
#		(stored as doubles) into integers by scaling the
#		value to be between 0 and exp_max.
#
#		This routine expands the individual cells into
#		the full cell_size by cell_size pixels before
#		writing it to the image.
#
#		The variable full_row must have its memory 
#		allocated before calling this routine.
#
# Algorithm:	* Calculate exposure weighting factor
#		* Fill in full row of data, expanding cells into pixels
#		* Write out row into image pointer cell_size times
#--------------------------------------------------------------------------

procedure put_cell_row_i(n_x_cell,i_y_cell,cell_row,cell_size,full_row,
				ip,exp_max,total_exp,display)
int	n_x_cell	# i: number of cells in row
int	i_y_cell	# i: which row we are writing
double  cell_row[n_x_cell] # i: cell row data
int	cell_size	# i: size of cell (in pixels)
int	full_row[n_x_cell*cell_size] # i: buffer for storing data to write
pointer ip		# io: image pointer
int	exp_max		# i: maximum integer value for total_exp
double  total_exp	# i: total exposure
int	display		# i: display level

### LOCAL VARS ###

double	exp_weight	# scale factor to multiply data by (exp_max/total_exp)
int	cell_start	# index into full_row where this cell data starts
int	i_pix		# counts number of pixels written into full_row
int     row_length	# length of row in image, in pixels
int	row_start	# where in image the rows start
int	i_row		# which row we're writing
int	i_x_cell	# which cell we're considering
pointer p_row		# pointer to where row is stored in image

### EXTERNAL FUNCTION DECLARATIONS ###

pointer impl2i()	# returns pointer to where data will be stored 
			# [sys/imio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # calculate exp_weight
        #----------------------------------------------
	if (total_exp>0.0D0)
	{
	    exp_weight=exp_max/total_exp
	}
	else
	{
	    exp_weight=0.0D0
	}

        #----------------------------------------------
	# make full row.
        #----------------------------------------------
	do i_x_cell=1,n_x_cell
	{
	    cell_start=(i_x_cell-1)*cell_size
	    do i_pix=1,cell_size
	    {
	        full_row[cell_start+i_pix]=nint(cell_row[i_x_cell]*exp_weight)
	    }
  	}

        #----------------------------------------------
	# fill in rows of image
        #----------------------------------------------
        row_length=IM_LEN(ip,1)
	row_start=(i_y_cell-1)*cell_size
	do i_row=1,cell_size
	{
            p_row=impl2i(ip,i_row+row_start)

	    if (p_row==EOF)
	    {
	      	call error(ET_UNEXPECTED_EOF,
	          "Output exposure file reached an unexpected end of file")
	    }
	    call amovi(full_row,Memi[p_row],row_length)
	}
end


#--------------------------------------------------------------------------
# Procedure:    put_cell_row_r
#
# Purpose:      This routine writes a cell row to an image file as
#               reals
#
# Input variables:
#               n_x_cell        number of cells in row
#               i_y_cell        which row we are writing
#               cell_row        cell row data
#               cell_size       size of cell (in pixels)
#               full_row        buffer to use to store row data
#               ip              image pointer to write to
#               display         display level
#
# Description:  This routine writes the cell exposure data into the
#               final exposure image.  The image is expected to
#		be of type real
#
#               This routine expands the individual cells into
#               the full cell_size by cell_size pixels before
#               writing it to the image.
#
#               The variable full_row must have its memory
#               allocated before calling this routine.
#
# Algorithm:    * Fill in full row of data, expanding cells into pixels
#               * Write out row into image pointer cell_size times
#--------------------------------------------------------------------------
procedure put_cell_row_r(n_x_cell,i_y_cell,cell_row,cell_size,full_row,
				ip,display)
int     n_x_cell        # i: number of cells in row
int     i_y_cell        # i: which row we are writing
double  cell_row[n_x_cell] # i: cell row data
int     cell_size       # i: size of cell (in pixels)
real    full_row[n_x_cell*cell_size] # i: buffer for storing data to write
pointer ip              # io: image pointer
int     display         # i: display level

### LOCAL VARS ###

int     cell_start      # index into full_row where this cell data starts
int     i_pix           # counts number of pixels written into full_row
int     row_length      # length of row in image, in pixels
int     row_start       # where in image the rows start
int     i_row           # which row we're writing
int     i_x_cell        # which cell we're considering
pointer p_row           # pointer to where row is stored in image

### EXTERNAL FUNCTION DECLARATIONS ###

pointer impl2r()        # returns pointer to where data will be stored
                        # [sys/imio]

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # make full row.
        #----------------------------------------------
 	do i_x_cell=1,n_x_cell
	{
	    cell_start=(i_x_cell-1)*cell_size
	    do i_pix=1,cell_size
	    {
	      	full_row[cell_start+i_pix]=(cell_row[i_x_cell])
	    }
	}
	
        #----------------------------------------------
        # fill in rows of image (as reals)
        #----------------------------------------------
        row_length=IM_LEN(ip,1)
	row_start=(i_y_cell-1)*cell_size
	do i_row=1,cell_size
	{
            p_row=impl2r(ip,i_row+row_start)

	    if (p_row==EOF)
	    {
	      	call error(ET_UNEXPECTED_EOF,
	          "Output exposure file reached an unexpected end of file")
	    }
	    call amovr(full_row,Memr[p_row],row_length)
	}
end

#--------------------------------------------------------------------------
# Procedure:    exp_header
#
# Purpose:      Fill in header keywords in exposure file
#
# Input variables:
#               qp              input QPOE
#               qphead          QPOE header
#               ip              image pointer
#		total_exp	total exposure of image
#
# Description:  Fills in the following header keywords in the CAT:
#
#	WCS information from QPHEAD
#	all header keywords from QPHEAD
#	TOT_EXP: total exposure
#               
#               Also writes out comments to exposure file.
#
# Note:		For some reason, using just put_imhead does not
#		write out the WCS information -- we have to do 
#		that separately.
#--------------------------------------------------------------------------

procedure exp_header(qp,qphead,ip,total_exp)
pointer	qp	   # i: QPOE
pointer	qphead 	   # i: QPOE header
pointer	ip	   # io: image pointer
double	total_exp  # i: total exposure

pointer	mw	   # MWCS descriptor (for QPOE)

begin
        #------------------------------------------------
	# put wcs info
        #------------------------------------------------
        call qph2mw(qphead, mw)
        call mw_ssystem(mw, "world")
        call mw_saveim(mw, ip)
        call mw_close(mw)

        #------------------------------------------------
	# put qphead information
        #------------------------------------------------
	call put_imhead(ip,qphead)

        #------------------------------------------------
	# put total exposure time with comments.
        #------------------------------------------------
	call imastr(ip,"COMMENT1",
	   "The following keyword, TOT_EXP, is the total amount of exposure")
	call imastr(ip,"COMMENT2",
	   "time used to make this exposure map.  This value should be close")
	call imastr(ip,"COMMENT3",
	   "to the QPOE exposure time times the dead time correction.  There")
 	call imastr(ip,"COMMENT4",
	   "might be differences due to temporal screening, or due to minor")
	call imastr(ip,"COMMENT5",
	   "discrepencies between the good time records and the BLT records")
	call imastr(ip,"COMMENT6",
	   "of the original QPOE file.  See the help page for the CAT_MAKE")
	call imastr(ip,"COMMENT7",
	   "task in EINTOOLS for more information.")
	call imaddd(ip,"TOT_EXP",total_exp)
end


#--------------------------------------------------------------------------
# Procedure:    exp_hist
#
# Purpose:      Fill in history header keywords in exposure image
#
# Input variables:
#		ip		image pointer
#               cat_name        file name of input CAT
#               exp_name        file name of output exposure file
#
# Description:  Writes history to exposure file.
#--------------------------------------------------------------------------
procedure  exp_hist(ip,cat_name,exp_name)
pointer ip		# io: image pointer
char	cat_name[ARB]	# i: CAT name
char	exp_name[ARB]	# i: exposure file name

### LOCAL VARS ###

pointer	sp	 # stack pointer
pointer p_hist   # pointer to history string
int	len	 # length of history string

### EXTERNAL FUNCTION DECLARATIONS ###

int     strlen() # returns length of string [sys/fmtio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # Set aside space for filter string
        #----------------------------------------------
        call smark(sp)
        len = strlen(cat_name)+
              strlen(exp_name)+
              SZ_LINE
        call salloc(p_hist, len, TY_CHAR)

        #----------------------------------------------
        # Create main history string
        #----------------------------------------------
         call sprintf(Memc[p_hist], len, "%s -> %s")
         call pargstr(cat_name)
         call pargstr(exp_name)

        #----------------------------------------------
        # Write history string to file
        #----------------------------------------------
        call put_imhistory(ip, "cat2exp", Memc[p_hist], "")

        #----------------------------------------------
        # Free up memory
        #----------------------------------------------
        call sfree(sp)
end

