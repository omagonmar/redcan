# $Header: /home/pros/xray/xdataio/eincdrom/tables/RCS/gt_file.x,v 11.0 1997/11/06 16:37:01 prosb Exp $
# $Log: gt_file.x,v $
# Revision 11.0  1997/11/06 16:37:01  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:01:43  prosb
# General Release 2.4
#
#Revision 8.1  1994/08/01  11:12:46  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:29  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/06  17:34:35  prosb
#Initial revision
#
#
#
#--------------------------------------------------------------------------
# Module:       gt_file.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     gt_new, gt_open, gt_get_row, gt_get_rows,
#		gt_put_row, gt_put_rows, gt_print_row, gt_print_rows,
#		gt_free_rows
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/93 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

include <tbset.h>
include "../source/ecd_err.h"
include "gen_tab.h"

#--------------------------------------------------------------------------
# Procedure:    gt_new
#
# Purpose:      To create a new table file.
#
# Input variables:
#               tab_name        name of table file to create
#               p_gt_info       pointer to table info structure
#
# Output variables:
#               tp		output table pointer
#		col_ptr		output column pointer
#
# Description:  After creating the table info structure (see gt_info.x),
#		the programmer uses gt_new to create a new table file.
#		This routine will use the column names, units,
#		format, and type defined in the table info structure.
#--------------------------------------------------------------------------

procedure gt_new(tab_name,tp,col_ptr,p_gt_info)
char    tab_name[ARB]   # i: file name of table to create
pointer tp		# o: pointer to created table
pointer col_ptr[ARB]    # o: column pointer of created table
pointer p_gt_info       # i: pointer to generic table info structure

### LOCAL VARS ###

int	i_col		# column index

### EXTERNAL FUNCTION DECLARATIONS ###

pointer	tbtopn()	# open table file and returns pointer [tables]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # open new table file
        #----------------------------------------------
        tp=tbtopn(tab_name,NEW_FILE,0)

        #----------------------------------------------
        # define each column, using info from p_gt_info
        #----------------------------------------------
        do i_col=1,GT_NCOL(p_gt_info)
        {
            call tbcdef(tp,col_ptr[i_col],GT_COLNAME(p_gt_info,i_col),
                      	GT_UNITS(p_gt_info,i_col),
		      	GT_FMT(p_gt_info,i_col),
                      	GT_TYPE(p_gt_info,i_col),1,1)
        }

        #----------------------------------------------
        # create table
        #----------------------------------------------
        call tbtcre(tp)
end

#--------------------------------------------------------------------------
# Procedure:    gt_open
#
# Purpose:      To open a previously created table file.
#
# Input variables:
#               tab_name        name of table file to open
#               p_gt_info       pointer to table info structure
#		mode		mode of file to open	
#
# Output variables:
#               tp		output table pointer
#		col_ptr		output column pointer
#
# Return value:
#		Returns the number of rows in the table
#
# Description:  After creating the table info structure (see gt_info.x),
#		the programmer can use gt_open to open a table file.
#		The mode should be set to either READ_ONLY or READ_WRITE,
#		depending on what the programmer wishes to do.
#		This routine will use the column name in the info structure
#		to create the column pointers.  If a column is missing,
#		this routine will give an error. 
#
#--------------------------------------------------------------------------
int procedure gt_open(tab_name,mode,tp,col_ptr,p_gt_info)
char    tab_name[ARB]   # i: file name of table to open
int	mode		# i: mode of file to open
pointer tp		# o: pointer to opened table
pointer col_ptr[ARB]    # o: column pointer of opened table
pointer p_gt_info       # i: pointer to generic table info structure

### LOCAL VARS ###

int	i_col		# column index
int     n_row		# number of rows in table (returned value)

### EXTERNAL FUNCTION DECLARATIONS ###

int     tbpsta()	# returns the value of a header param [tables]
pointer tbtopn()	# open table file and returns pointer [tables]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # open table file with appropriate mode
        #----------------------------------------------
        tp=tbtopn(tab_name,mode,0)

        #----------------------------------------------
        # find each column in the table.  Give error
	# if any column is missing.
        #----------------------------------------------
        do i_col=1,GT_NCOL(p_gt_info)
        {
            call tbcfnd(tp,GT_COLNAME(p_gt_info,i_col),col_ptr[i_col],1)
            if (col_ptr[i_col]==NULL)
            {
              	call errstr(ECD_MISSING_COL,
                  "Missing column from table",GT_COLNAME(p_gt_info,i_col))
            }
        }

        #----------------------------------------------
        # find number of rows in column and return it.
        #----------------------------------------------
        n_row=tbpsta(tp, TBL_NROWS)
        return n_row
end

#--------------------------------------------------------------------------
# Procedure:    gt_get_row
#
# Purpose:      To return a row from a table
#
# Input variables:
#               tp		table pointer
#               p_gt_info       pointer to table info structure
#		col_ptr		column pointer
#               i_row		index of row to retrieve data from
#		do_indef_error	flag: should we give error if value in 
#				row is undefined?
#
# Output variables:
#		row_data_ptr	pointer to where row contents should go
#
# Description:  This routine reads in the contents of a row and places
#		it in the memory location pointed to by row_data_ptr.
#		It is assumed that space has been set aside for the
#		row.  (The programmer can use GT_SZROW(p_gt_info) to get
#		the size of a row, in units of SZ_CHAR.)  Each column
#		in the row is read in and placed in memory consecutively,
#		in the same order that the columns were defined when
#		the info structure was defined.  (See gt_info.x)  
#		
#		Probably the easiest way to access the data is to set
#		up a data structure which matches the order defined
#		in the info structure.
#
#		If a column contains a string, this routine will set
#		aside memory for that string and place a pointer in
#		the row_data_ptr data.
#
#		This routine will give an error if the contents of a
#		column is undefined (INDEF) and the "do_indef_error" flag
#		is true.  If the programmer wants to allow indefinite
#		values in the table, this flag should be set false.
#
# Notes:	This routine does not check for memory boundary conditions.
#
#		The routine gt_free_rows should be called to dispose of
#		the memory in a row.  This is especially important if the
#		row contains strings, which will not be disposed by simply
#		freeing the data pointer.
#
#--------------------------------------------------------------------------

procedure gt_get_row(tp,p_gt_info,col_ptr,i_row,do_indef_error,row_data_ptr)
pointer tp		# i: pointer to table
pointer p_gt_info       # i: pointer to generic table info structure
pointer col_ptr[ARB]    # i: column pointer
int     i_row		# i: index of row to read
bool	do_indef_error  # i: flag: should we give error if INDEF found?
pointer row_data_ptr    # o: pointer to retrieved data

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
bool    indef_flag	# flag: has INDEF been found in this row?
int     i_col		# column index
int	type		# column type

### BEGINNING OF PROCEDURE ###

begin

        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=row_data_ptr

        #----------------------------------------------
        # loop through each column:
	#    read in data from table into cur_data_ptr
	#    update cur_data_ptr
	#    give error if INDEF found and 
	#        do_indef_error is true
        #----------------------------------------------
        do i_col=1,GT_NCOL(p_gt_info)
        {
	    type = GT_TYPE(p_gt_info,i_col)
	    if (type<0)
	    {
	        #----------------------------------------------
		# Read in string.  
		# Note that abs(type) indicates string length.
	        #----------------------------------------------
		call malloc(Memi[cur_data_ptr],abs(type),TY_CHAR)
		call tbrgtt(tp,col_ptr[i_col],Memc[Memi[cur_data_ptr]],
			     indef_flag,abs(type),1,i_row)
		cur_data_ptr=cur_data_ptr+SZ_POINTER/SZ_INT
	    }
            else switch(type)
            {
             	case TY_REAL:
                    call tbrgtr(tp,col_ptr[i_col],Memr[cur_data_ptr],
                                indef_flag,1,i_row)
                    cur_data_ptr=cur_data_ptr+SZ_REAL/SZ_INT
            	case TY_DOUBLE:
                    call tbrgtd(tp,col_ptr[i_col],Memd[P2D(cur_data_ptr)],
                                indef_flag,1,i_row)
                    cur_data_ptr=cur_data_ptr+SZ_DOUBLE/SZ_INT
             	case TY_INT:
                    call tbrgti(tp,col_ptr[i_col],Memi[cur_data_ptr],
                                indef_flag,1,i_row)
                    cur_data_ptr=cur_data_ptr+1
             	case TY_BOOL:
                    call tbrgtb(tp,col_ptr[i_col],Memb[cur_data_ptr],
                                indef_flag,1,i_row)
                    cur_data_ptr=cur_data_ptr+SZ_BOOL/SZ_INT
             	default:
                    call errori(ECD_UNKNOWN_TYPE,
                      "GT_GET_ROW: Unknown type",GT_TYPE(p_gt_info,i_col))
            }
 
            #----------------------------------------------
	    #    give error if INDEF was found and 
	    #        do_indef_error is true
            #----------------------------------------------
            if (indef_flag && do_indef_error)
            {
               	call eprintf("Missing value from row %d, column %s.\n")
                 call pargi(i_row)
                 call pargstr( GT_COLNAME(p_gt_info,i_col))
                call error(ECD_MISSING_ROWVAL,"Missing value from table")
            }
        }  # end do loop
end


#--------------------------------------------------------------------------
# Procedure:    gt_get_rows
#
# Purpose:      To return several rows from a table
#
# Input variables:
#               tp		table pointer
#               p_gt_info       pointer to table info structure
#		col_ptr		column pointer
#               start_row	index of row to start retrieving data from
#               n_row		number of rows to retrieve
#		do_indef_error	flag: should we give error if value in 
#				row is undefined?
#
# Output variables:
#		data_ptr	pointer to where table contents should go
#
# Description:  This routine reads in the contents of a table and places
#		it in the memory location pointed to by data_ptr.
#		It is assumed that space has been set aside for the
#		data.  This routine calls gt_get_row "n_row" times,
#		starting with "start_row".  See comments to gt_get_row
#		above for more details of reading in rows.
#
# Notes:        The routine gt_free_rows should be called to dispose of
#               the memory in the rows.  This is especially important if the
#               rows contain strings, which will not be disposed by simply
#               freeing the data pointer.
#
#--------------------------------------------------------------------------

procedure gt_get_rows(tp,p_gt_info,col_ptr,start_row,n_row,
			do_indef_error,data_ptr)
pointer tp		# i: pointer to table
pointer p_gt_info       # i: pointer to generic table info structure
pointer col_ptr[ARB]    # i: column pointer
int     start_row	# i: index of row to start reading from
int     n_row		# i: number of rows to read
bool	do_indef_error  # i: flag: should we give error if INDEF found?
pointer data_ptr    	# o: pointer to retrieved data

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
int     i_row		# row index

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=data_ptr

        #----------------------------------------------
        # loop through each row:
	#    read in row
	#    update cur_data_ptr
        #----------------------------------------------
        do i_row=start_row,start_row+n_row-1
        {
            call gt_get_row(tp,p_gt_info,col_ptr,i_row,
				do_indef_error,cur_data_ptr)
	    cur_data_ptr=cur_data_ptr+GT_SZROW(p_gt_info)
        }
end

#--------------------------------------------------------------------------
# Procedure:    gt_put_row
#
# Purpose:      To put data from memory into a row in a table
#
# Input variables:
#		row_data_ptr	pointer to data to put into table
#               tp		table pointer
#               p_gt_info       pointer to table info structure
#		col_ptr		column pointer
#               i_row		index of row to put data into
#
# Description:  This routine puts the data in row_data_ptr into the
#		row of the passed in table.  The data should be stored
#		in the same order as the columns were defined in the
#		info structure, using just as much memory as is
#		appropriate for the data type of each column.
#
#		For columns containing strings, the data should contain
#		a pointer to the location of the string.  
#
# Notes:	This routine does not check for memory boundary conditions.
#
#--------------------------------------------------------------------------

procedure gt_put_row(row_data_ptr,tp,p_gt_info,col_ptr,i_row)
pointer row_data_ptr    # i: pointer to data to put into table
pointer tp		# i: pointer to table
pointer p_gt_info       # i: pointer to generic table info structure
pointer col_ptr[ARB]    # i: column pointer
int     i_row		# i: index of row to write

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
int     i_col		# column index
int	type		# column type

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=row_data_ptr

        #----------------------------------------------
        # loop through each column:
	#    write to table the data in cur_data_ptr
	#    update cur_data_ptr
        #----------------------------------------------
        do i_col=1,GT_NCOL(p_gt_info)
        {
	    type = GT_TYPE(p_gt_info,i_col)
	    if (type<0)
	    {
                #----------------------------------------------
                # Write out string.
                # Note that abs(type) indicates string length.
                #----------------------------------------------
		call tbrptt(tp,col_ptr[i_col],Memc[Memi[cur_data_ptr]],
				abs(type),1,i_row)
		cur_data_ptr=cur_data_ptr+SZ_POINTER/SZ_INT
	    }
            else switch(type)
            {
             case TY_REAL:
                call tbrptr(tp,col_ptr[i_col],Memr[cur_data_ptr],1,i_row)
                cur_data_ptr=cur_data_ptr+SZ_REAL/SZ_INT
             case TY_DOUBLE:
                call tbrptd(tp,col_ptr[i_col],Memd[P2D(cur_data_ptr)],1,i_row)
                cur_data_ptr=cur_data_ptr+SZ_DOUBLE/SZ_INT
             case TY_INT:
                call tbrpti(tp,col_ptr[i_col],Memi[cur_data_ptr],1,i_row)
                cur_data_ptr=cur_data_ptr+1
             case TY_BOOL:
                call tbrptb(tp,col_ptr[i_col],Memb[cur_data_ptr],1,i_row)
                cur_data_ptr=cur_data_ptr+SZ_BOOL/SZ_INT
             default:
                call errori(ECD_UNKNOWN_TYPE,
                   "GT_PUT_ROW: Unknown type",GT_TYPE(p_gt_info,i_col))
           }
        }
end

#--------------------------------------------------------------------------
# Procedure:    gt_put_rows
#
# Purpose:      To put data from memory into several rows of a table
#
# Input variables:
#		data_ptr	pointer to data to put into table
#               tp		table pointer
#               p_gt_info       pointer to table info structure
#		col_ptr		column pointer
#               start_row	index of row to start writing data to
#               n_row		number of rows to write
#
# Description:  This routine puts the data in data_ptr into the
#		row of the passed in table.  As in gt_put_row, the
#		data should be stored in the same order as the columns
#		were defined in the info structure.  Each row must
#		be exactly GT_SZROW(p_gt_info) long (in SZ_CHAR units).
#--------------------------------------------------------------------------

procedure gt_put_rows(data_ptr,tp,p_gt_info,col_ptr,start_row,n_row)
pointer data_ptr    	# i: pointer to data to put into table
pointer tp		# i: pointer to table
pointer p_gt_info       # i: pointer to generic table info structure
pointer col_ptr[ARB]    # i: column pointer
int     start_row	# i: index of row to start reading from
int     n_row		# i: number of rows to read

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
int     i_row		# row index

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=data_ptr

        #----------------------------------------------
        # loop through each row:
	#    write row
	#    update cur_data_ptr
        #----------------------------------------------
        do i_row=start_row,start_row+n_row-1
        {
           call gt_put_row(cur_data_ptr,tp,p_gt_info,col_ptr,i_row)
	   cur_data_ptr=cur_data_ptr+GT_SZROW(p_gt_info)
        }
end

#--------------------------------------------------------------------------
# Procedure:    gt_print_row
#
# Purpose:      To print the contents of data from a table row
#
# Input variables:
#		row_data_ptr	pointer to row contents
#               p_gt_info       pointer to table info structure
#
# Description:  This routine uses the column format information in
#		the info structure to print out the contents of one
#		row.  The row must have already been read (via gt_get_row)
#		before this routine is called.
#
#		The row is displayed as a series of "COL_NAME=VALUE" 
#		strings, separated by tabs, and ended with an
#		end-of-line marker.  
#
# Note:		No effort is made to ensure that the line fits within
#		the window -- it will most likely wraparound, perhaps at
#		an inconvenient place.
#--------------------------------------------------------------------------
procedure gt_print_row(row_data_ptr,p_gt_info)
pointer row_data_ptr    # i: pointer to data 
pointer p_gt_info       # i: pointer to generic table info structure

### LOCAL VARS ###

pointer cur_data_ptr	    # current pointer to data
int     i_col		    # column index
char    print_buf[SZ_LINE]  # temporary buffer for format information
int	type		    # column type

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=row_data_ptr

        #----------------------------------------------
        # loop through each column
        #----------------------------------------------
        do i_col=1,GT_NCOL(p_gt_info)
        {
            #----------------------------------------------
            # Set up print_buf to contain "COLNAME=FMT\t"
            #----------------------------------------------
            call sprintf(print_buf,SZ_LINE,"%s=%s \t")
             call pargstr(GT_COLNAME(p_gt_info,i_col))
             call pargstr(GT_FMT(p_gt_info,i_col))

            #----------------------------------------------
            # Display print_buf
            #----------------------------------------------
            call printf(print_buf)

            #----------------------------------------------
            # Display column contents, then update
	    #    cur_data_ptr
            #----------------------------------------------
	    type = GT_TYPE(p_gt_info,i_col)
	    if (type<0)
	    {
		call pargstr(Memc[Memi[cur_data_ptr]])
		cur_data_ptr=cur_data_ptr+SZ_POINTER/SZ_INT
	    }
            else switch(type)
            {
             	case TY_REAL:
                    call pargr(Memr[cur_data_ptr])
                    cur_data_ptr=cur_data_ptr+SZ_REAL/SZ_INT
             	case TY_DOUBLE:
                    call pargd(Memd[P2D(cur_data_ptr)])
                    cur_data_ptr=cur_data_ptr+SZ_DOUBLE/SZ_INT
             	case TY_INT:
                    call pargi(Memi[cur_data_ptr])
                    cur_data_ptr=cur_data_ptr+1
             	case TY_BOOL:
                    call pargb(Memb[cur_data_ptr])
                    cur_data_ptr=cur_data_ptr+SZ_BOOL/SZ_INT
             	default:
                    call errori(ECD_UNKNOWN_TYPE,
                   	"GT_PRINT_ROW: Unknown type",GT_TYPE(p_gt_info,i_col))
            }
        }

        #----------------------------------------------
        # print end-of-line marker
        #----------------------------------------------
        call printf("\n")

end

#--------------------------------------------------------------------------
# Procedure:    gt_print_rows
#
# Purpose:      To print the contents of data from a series of rows
#
# Input variables:
#		row_data_ptr	pointer to row contents
#               p_gt_info       pointer to table info structure
#               n_row	        number of rows to display
#
# Description:  This routine uses the column format information in
#		the info structure to print out the contents of several
#		rows.  (See gt_print_row above for format.)
#
#		Each row is preceded by its row number.
#
# Note: 	The indexing of the display rows will differ from the
#		rows in the table if one uses gt_print_rows to display,
#		say, the third through eighth rows.  This routine will
#		call them rows "1-6".  
#--------------------------------------------------------------------------

procedure gt_print_rows(data_ptr,p_gt_info,n_row)
pointer data_ptr    	# i: pointer to data 
pointer p_gt_info       # i: pointer to generic table info structure
int     n_row		# i: number of rows to print

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
int     i_row		# row index

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=data_ptr

        #----------------------------------------------
        # loop through each row:
	#    display row number
	#    display row
	#    update cur_data_ptr
        #----------------------------------------------
         do i_row=1,n_row
        {
           call printf("Row %d:")
            call pargi(i_row)
	   call gt_print_row(cur_data_ptr,p_gt_info)
	   cur_data_ptr=cur_data_ptr+GT_SZROW(p_gt_info)
        }
end


#--------------------------------------------------------------------------
# Procedure:    gt_free_rows
#
# Purpose:      To free the memory contained in rows read from a table
#
# Input variables:
#               data_ptr    	pointer to data contents
#               p_gt_info       pointer to table info structure
#               n_row           number of rows in data to be freed
#
# Description:  This routine will free the memory set aside for the rows
#		of data read in from (or created to write out to) a table.
#		
#		It will loop through each row and free any memory set 
#		aside for strings, then free the main data pointer.
#
#--------------------------------------------------------------------------
procedure gt_free_rows(data_ptr,p_gt_info,n_row)
pointer data_ptr    	# i: pointer to data 
pointer p_gt_info       # i: pointer to generic table info structure
int     n_row		# i: number of rows to print

### LOCAL VARS ###

pointer cur_data_ptr	# current pointer to data
pointer cur_col_ptr	# current pointer to column data
int     i_row		# row index
int	i_col		# column index
int	type		# column type

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # initialize cur_data_ptr
        #----------------------------------------------
        cur_data_ptr=data_ptr

        #----------------------------------------------
        # loop through each row:
	#    if column type is string, delete string
        #----------------------------------------------
         do i_row=1,n_row
        {
            #----------------------------------------------
            # initialize cur_data_ptr
            #----------------------------------------------
            cur_col_ptr=cur_data_ptr

            #----------------------------------------------
            # loop through each column
            #----------------------------------------------
            do i_col=1,GT_NCOL(p_gt_info)
            {
            	#----------------------------------------------
            	# Delete column if it is string.
		# Increment column pointer.
            	#----------------------------------------------
	    	type = GT_TYPE(p_gt_info,i_col)
	    	if (type<0)
	    	{
		    call mfree(Memi[cur_col_ptr],TY_CHAR)
		    cur_col_ptr=cur_col_ptr+SZ_POINTER/SZ_INT
	        }
                else switch(type)
                {
             	    case TY_REAL:
                    	cur_col_ptr=cur_col_ptr+SZ_REAL/SZ_INT
             	    case TY_DOUBLE:
                        cur_col_ptr=cur_col_ptr+SZ_DOUBLE/SZ_INT
             	    case TY_INT:
                        cur_col_ptr=cur_col_ptr+1
             	    case TY_BOOL:
                        cur_col_ptr=cur_col_ptr+SZ_BOOL/SZ_INT
             	    default:
                        call errori(ECD_UNKNOWN_TYPE,
                   	"GT_PRINT_ROW: Unknown type",GT_TYPE(p_gt_info,i_col))
                }
	    }
	    cur_data_ptr=cur_data_ptr+GT_SZROW(p_gt_info)
        }

	# delete main data
	call mfree(data_ptr,TY_STRUCT)
end
