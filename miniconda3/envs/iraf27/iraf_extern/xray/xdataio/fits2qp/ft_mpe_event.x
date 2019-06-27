#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_mpe_event.x,v 11.0 1997/11/06 16:34:40 prosb Exp $
#$Log: ft_mpe_event.x,v $
#Revision 11.0  1997/11/06 16:34:40  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:19  prosb
#General Release 2.4
#
#Revision 8.1  1994/09/16  16:37:54  dvs
#Modified code to add support for alternate qpoe indexing and
#to support reading of TSCAL/TZERO.
#
#Revision 8.0  94/06/27  15:21:02  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:31  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:19  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:21  prosb
#General Release 2.1
#
#Revision 1.5  92/10/16  20:20:14  mo
#MC	10/16/92		Made the position offset corrections instrument
#				specific
#
#Revision 1.4  92/10/15  16:25:40  jmoran
#*** empty log message ***
#
#Revision 1.3  92/10/05  14:46:09  jmoran
#JMORAN removed debug statements
#
#Revision 1.2  92/10/01  15:11:35  jmoran
#JMORAN added support for MPE HRI data
#
#Revision 1.1  92/09/23  11:34:56  jmoran
#Initial revision
#

include <ctype.h>
include <mach.h>
include <evmacro.h>
include <fset.h>
include	<rosat.h>
include "cards.h"
include "ftwcs.h"
include "fits2qp.h"
include "mpefits.h"


procedure mpe_write_events(fd, qp, io, mpe_ptr, sindex, binary_buf,
		 	   ascii_bytes, nrecs, tfields, mpe_instr)

pointer	fd				# i: FITS handle
pointer	qp				# i: QPOE file handle
pointer io
pointer	mpe_ptr
pointer sindex
pointer binary_buf
int     ascii_bytes
int	nrecs
int	tfields
int	mpe_instr

pointer ascii_buf			# l: ascii buffer for events
pointer	sp				# l: stack pointer
pointer orig_ptr
pointer new_ptr
pointer pos_ptr
pointer temp_buf
pointer mii
pointer spp
int	nch
int	curr_rec
int	stat
int	offset
int	binoff
int	idx1
int	idx2
int     left                            # l: events left to read
int     get                             # l: events to get this time
int     ch_rec
int	mii_recsz
int	len_mii
int     ip
short	sbuf
real	rbuf
double	dbuf

int	mpe_read_pixels()
int     sscan()
int     sizeof()
int	miilen()

begin

#---------------
# Mark the stack
#---------------
	call smark(sp)

#----------------------------------------------
# Allocate stack memory for ASCII string buffer
#----------------------------------------------
	call salloc (ascii_buf, ascii_bytes, TY_CHAR)
        Memc[ascii_buf + ascii_bytes] = EOS

#-------------------------------------------
# Calc size of record to read from FITS file 
#-------------------------------------------
        len_mii = miilen (FITS_BUFFER, FITS_BYTE)
	mii_recsz = len_mii * SZ_INT


        ch_rec = FITS_BUFFER * sizeof (TY_CHAR)

	ip = ch_rec
        curr_rec = 0

#----------------------------------------
# Allocate space for initial read buffers
#----------------------------------------
        call calloc (mii, len_mii, TY_INT)
        call calloc (spp, ch_rec, TY_CHAR)

	orig_ptr = mpe_ptr
	call mpe_shift_init(orig_ptr, new_ptr, pos_ptr, temp_buf, 
		            ascii_bytes, tfields, mpe_instr)

        left = nrecs
        while (left > 0)
        {
           # determine how many to read this time
           get = min(MAX_GET, left)
           binoff = 0

	   do idx1 = 1, get
	   {
              nch = mpe_read_pixels (fd, Memc[ascii_buf], ascii_bytes, 
			             curr_rec, spp, mii, ch_rec,
				     mii_recsz,  ip)

              if (nch != ascii_bytes)
                   call error (1, "Error reading FITS data\n")

	      call mpe_shift_buffer(Memc[ascii_buf], ascii_bytes, temp_buf, 
				    orig_ptr, pos_ptr, mpe_instr)

              offset = 0

              do idx2 = 1, tfields
              {
                 switch (Memi[TYPE(new_ptr) + idx2 - 1])
                 {
                 case (TY_REAL):
                    stat = sscan (Memc[ascii_buf + offset])
                    call gargr (rbuf)
		    call amovr(rbuf, Mems[binary_buf + binoff], 1)
		    binoff = binoff + SZ_REAL

                 case (TY_DOUBLE):
                    stat = sscan (Memc[ascii_buf + offset])
                    call gargd (dbuf)
		    call amovd(dbuf, Mems[binary_buf + binoff], 1)
		    binoff = binoff + SZ_DOUBLE

                 case (TY_SHORT):
                    stat = sscan (Memc[ascii_buf + offset])
                    call gargs (sbuf)

		    call mpe_add_offset(new_ptr, idx2, sbuf, mpe_instr)
    
		    call amovs(sbuf, Mems[binary_buf + binoff], 1)
		    binoff = binoff + SZ_SHORT
		    
#------------------------------------------------
# Add PHA and PI (both) zero as space holders for
# HRI 
#------------------------------------------------
	    if (mpe_instr == ROSAT_HRI && Y_POS(new_ptr) == idx2
	        && PHA_POS(orig_ptr) == -1)
	    {
                call amovs(0, Mems[binary_buf + binoff], 1)
                binoff = binoff + SZ_SHORT
			
		call amovs(0, Mems[binary_buf + binoff], 1)
                binoff = binoff + SZ_SHORT
	    }

	    if (mpe_instr == ROSAT_HRI && PHA_POS(orig_ptr) != -1 &&
	       PHA_POS(new_ptr) == idx2)
	    {
	        call amovs(0, Mems[binary_buf + binoff], 1)
                binoff = binoff + SZ_SHORT
	    }

                 default:
		    call error(1, "Illegal type in switch statement.")
                 } # end switch

                 offset = offset + Memi[SIZE(new_ptr) + idx2 - 1]

              } # end loop (1 to number of fields)

	   } # end loop (1 to get)

	   call qpio_putevents(io, Memi[sindex], get)
	   left = left - get

        } # end outer while loop

	call mpe_shift_done(new_ptr, pos_ptr, temp_buf)

	call mfree (spp, TY_CHAR)
	call mfree (mii, TY_INT)

	# free up stack space
	call sfree(sp)
end


procedure mpe_add_offset(new_ptr, idx, sbuf, mpe_instr)

pointer new_ptr				# i:
int	idx				# i:
short	sbuf				# i/o
int	mpe_instr			# i:
int	xoff,yoff,dxoff,dyoff		# l:  correction factors

begin
	if( mpe_instr == ROSAT_HRI )
	{
	    xoff = HRI_X_OFFSET
	    yoff = HRI_Y_OFFSET
	    dxoff = HRI_DX_OFFSET
	    dyoff = HRI_DY_OFFSET
	}
	else if( mpe_instr == ROSAT_PSPC )
	{
	    xoff = PSPC_X_OFFSET
	    yoff = PSPC_Y_OFFSET
	    dxoff = PSPC_DX_OFFSET
	    dyoff = PSPC_DY_OFFSET
        }
        else
        {
	    xoff = 0
	    yoff = 0
	    dxoff = 0
	    dyoff = 0
        }
    	if (X_POS(new_ptr) == idx)
        {
           sbuf = sbuf + xoff
        }
        else
        {
           if (Y_POS(new_ptr) == idx)
           {
              sbuf = yoff - sbuf
           }
           else
           {
              if (DX_POS(new_ptr) == idx)
              {
                 sbuf = sbuf - dxoff
              }
              else
              {
                 if (DY_POS(new_ptr) == idx)
                 {
                    sbuf = sbuf - dyoff
                 }
              }
           }
        }
	
end 

procedure mpe_shift_buffer(buf, bufsz, temp_buf, orig_ptr, pos_ptr, mpe_instr)

char	buf[ARB]
int	bufsz
pointer orig_ptr
pointer	pos_ptr
pointer	temp_buf
int	mpe_instr

int	idx
int	start, stop

begin

        idx = 1
        start = Memi[pos_ptr + X_POS(orig_ptr) - 1] + 1
	stop  = Memi[pos_ptr + X_POS(orig_ptr)] 
	call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])

        start = Memi[pos_ptr + Y_POS(orig_ptr) - 1] + 1
        stop  = Memi[pos_ptr + Y_POS(orig_ptr)] 
        call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])

	if (PHA_POS(orig_ptr) != -1)
	{
	   start = Memi[pos_ptr + PHA_POS(orig_ptr) - 1] + 1
           stop  = Memi[pos_ptr + PHA_POS(orig_ptr)] 
           call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])
	}

        if (PI_POS(orig_ptr) != -1)
	{
           start = Memi[pos_ptr + PI_POS(orig_ptr) - 1] + 1
           stop  = Memi[pos_ptr + PI_POS(orig_ptr)] 
           call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])
	}

        start = Memi[pos_ptr + TIME_POS(orig_ptr) - 1] + 1
        stop  = Memi[pos_ptr + TIME_POS(orig_ptr)] 
        call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])

        start = Memi[pos_ptr + DX_POS(orig_ptr) - 1] + 1
        stop  = Memi[pos_ptr + DX_POS(orig_ptr)] 
        call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])

        start = Memi[pos_ptr + DY_POS(orig_ptr) - 1] + 1
        stop  = Memi[pos_ptr + DY_POS(orig_ptr)] 
        call mpe_buf_copy(start, stop, idx, buf, Memc[temp_buf])

	call strcpy(Memc[temp_buf], buf, bufsz)

end

procedure mpe_buf_copy(start, stop, incr, buf, temp_buf)

int	start
int	stop
int	incr
char	buf[ARB]
char	temp_buf[ARB]

int	idx

begin

	do idx = start, stop
        {
          temp_buf[incr] = buf[idx]
          incr = incr + 1
        }
end


procedure mpe_shift_init(orig_ptr, new_ptr, pos_ptr, temp_buf, bufsz, 
			 tfields, mpe_instr)

pointer orig_ptr
pointer new_ptr
pointer pos_ptr
pointer temp_buf
int	bufsz
int	tfields
int	mpe_instr

int	i, j, sum
int     x_size, x_type
int     y_size, y_type
int     pha_size, pha_type
int     pi_size, pi_type
int     time_size, time_type
int     dx_size, dx_type
int     dy_size, dy_type

begin
        call calloc(new_ptr, SZ_MPE_STRUCT, TY_STRUCT)

        call calloc(SIZE(new_ptr), tfields, TY_INT)
        call calloc(TYPE(new_ptr), tfields, TY_INT)

        call calloc(pos_ptr, tfields + 1, TY_INT)
        call calloc(temp_buf, bufsz, TY_CHAR)

        Memc[temp_buf + bufsz] = EOS

	Memi[pos_ptr + 0] = 1

        do i = 1, tfields
        {
            sum = 0
            do j = 1, i
              sum = sum + Memi[SIZE(orig_ptr) + j - 1]

            Memi[pos_ptr + i] = sum
        }

	if (mpe_instr == ROSAT_PSPC)
	{
           X_POS(new_ptr)    = 1
           Y_POS(new_ptr)    = 2
           PHA_POS(new_ptr)  = 3
           PI_POS(new_ptr)   = 4 
           TIME_POS(new_ptr) = 5
           DX_POS(new_ptr)   = 6
           DY_POS(new_ptr)   = 7
	}

	if (mpe_instr == ROSAT_HRI)
	{
	   if (PHA_POS(orig_ptr) == -1 && PI_POS(orig_ptr) == -1)
	   {
	      X_POS(new_ptr)    = 1
              Y_POS(new_ptr)    = 2
              TIME_POS(new_ptr) = 3
              DX_POS(new_ptr)   = 4
              DY_POS(new_ptr)   = 5
	   }
	   else
           {
              X_POS(new_ptr)    = 1
              Y_POS(new_ptr)    = 2
	      PHA_POS(new_ptr)  = 3
              TIME_POS(new_ptr) = 4
              DX_POS(new_ptr)   = 5
              DY_POS(new_ptr)   = 6
           }
        }

        x_size = Memi[SIZE(orig_ptr) + X_POS(orig_ptr) - 1]
        x_type = Memi[TYPE(orig_ptr) + X_POS(orig_ptr) - 1]
	Memi[SIZE(new_ptr) + X_POS(new_ptr) - 1] = x_size
        Memi[TYPE(new_ptr) + X_POS(new_ptr) - 1] = x_type

        y_size = Memi[SIZE(orig_ptr) + Y_POS(orig_ptr) - 1]
        y_type = Memi[TYPE(orig_ptr) + Y_POS(orig_ptr) - 1]
        Memi[SIZE(new_ptr) + Y_POS(new_ptr) - 1] = y_size
        Memi[TYPE(new_ptr) + Y_POS(new_ptr) - 1] = y_type

	if (PHA_POS(orig_ptr) != -1)
        {
           pha_size = Memi[SIZE(orig_ptr) + PHA_POS(orig_ptr) - 1]
           pha_type = Memi[TYPE(orig_ptr) + PHA_POS(orig_ptr) - 1]
           Memi[SIZE(new_ptr) + PHA_POS(new_ptr) - 1] = pha_size
           Memi[TYPE(new_ptr) + PHA_POS(new_ptr) - 1] = pha_type
	}

	if (PI_POS(orig_ptr) != -1)
	{
           pi_size = Memi[SIZE(orig_ptr) + PI_POS(orig_ptr) - 1]
           pi_type = Memi[TYPE(orig_ptr) + PI_POS(orig_ptr) - 1]
           Memi[SIZE(new_ptr) + PI_POS(new_ptr) - 1] = pi_size
           Memi[TYPE(new_ptr) + PI_POS(new_ptr) - 1] = pi_type
	}

        time_size = Memi[SIZE(orig_ptr) + TIME_POS(orig_ptr) - 1]
        time_type = Memi[TYPE(orig_ptr) + TIME_POS(orig_ptr) - 1]
        Memi[SIZE(new_ptr) + TIME_POS(new_ptr) - 1] = time_size
        Memi[TYPE(new_ptr) + TIME_POS(new_ptr) - 1] = time_type

        dx_size = Memi[SIZE(orig_ptr) + DX_POS(orig_ptr) - 1]
        dx_type = Memi[TYPE(orig_ptr) + DX_POS(orig_ptr) - 1]
        Memi[SIZE(new_ptr) + DX_POS(new_ptr) - 1] = dx_size
        Memi[TYPE(new_ptr) + DX_POS(new_ptr) - 1] = dx_type

        dy_size = Memi[SIZE(orig_ptr) + DY_POS(orig_ptr) - 1]
        dy_type = Memi[TYPE(orig_ptr) + DY_POS(orig_ptr) - 1]
        Memi[SIZE(new_ptr) + DY_POS(new_ptr) - 1] = dy_size
        Memi[TYPE(new_ptr) + DY_POS(new_ptr) - 1] = dy_type

end

procedure mpe_shift_done(new_ptr, pos_ptr, temp_buf)

pointer new_ptr
pointer pos_ptr
pointer	temp_buf

begin
        call mfree(SIZE(new_ptr), TY_INT)
        call mfree(TYPE(new_ptr), TY_INT)
        call mfree(new_ptr, TY_STRUCT)

	call mfree(pos_ptr, TY_INT)
	call mfree(temp_buf, TY_CHAR)
end



procedure mpe_typedef(ext, tfields, key_x, key_y,
			rtype, itype, otype, ptype, mpe_ptr)

pointer	ext				# i: extension information
int	tfields				# i: number of ext records
char    key_x[SZ_LINE]    		# i: index x key
char    key_y[SZ_LINE]    		# i: index y key
int	rtype				# i: event or aux or none
char	itype[ARB]			# o: typedef string (input)
char	otype[ARB]			# o: typedef string (output)
char	ptype[ARB]			# o: pros eventdef string
pointer mpe_ptr

char	tbuf[SZ_TYPEDEF]		# l: temp char buffer
char	tform[SZ_LINE]			# l: temp tform
char	ttype[SZ_LINE]			# l: temp ttype
int	i				# l: counter
int	j				# l: counter
int	junk				# l: junk return from ctoi()
int	ctoi()				# l: convert char to int
int	strlen()			# l: string length
bool	streq()				# l: string compare
pointer cur_ext				# l: pointer to current EXT record

int	mpe_type
int 	mpe_sum
int	mpe_size

int	idx
int	ip


begin

    	call calloc(mpe_ptr, SZ_MPE_STRUCT, TY_STRUCT)

	call calloc(SIZE(mpe_ptr), tfields, TY_INT)
	call calloc(TYPE(mpe_ptr), tfields, TY_INT)

# begin with open brace
	call strcpy("{", itype, SZ_TYPEDEF)
	call strcpy("{", ptype, SZ_TYPEDEF)

# Change the column names for the MPE FITS file
	call mpe_change_colnames(ext, tfields, mpe_ptr)

	mpe_sum = 0
# loop through all columns
    do idx = 1, tfields
    {
	cur_ext=EXT(ext,idx)

	# put form and type in easier to manage arrays
	call strcpy(Memc[EXT_FORM(cur_ext)], tform, SZ_LINE)
	call strcpy(Memc[EXT_TYPE(cur_ext)], ttype, SZ_LINE)

	i = 1

	# convert FITS typedef to our typedef (QPOE)
	switch(tform[i])
	{

# All ints will be read as shorts for the MPE ASCII tables
	case 'I':
	    call strcpy("s", tbuf, SZ_TYPEDEF)
	    mpe_type = TY_SHORT
	    mpe_sum = mpe_sum + SZ_SHORT

	case 'E':
	    call strcpy("r", tbuf, SZ_TYPEDEF)
            mpe_type = TY_REAL
	    mpe_sum = mpe_sum + SZ_REAL

        case 'F':
            call strcpy("r", tbuf, SZ_TYPEDEF)
            mpe_type = TY_REAL
	    mpe_sum = mpe_sum + SZ_REAL

	case 'D':
	    call strcpy("d", tbuf, SZ_TYPEDEF)
            mpe_type = TY_DOUBLE
	    mpe_sum = mpe_sum + SZ_DOUBLE

	default:
	    call printf("unknown TFORM type (%s) - skipping\n")
	    call pargstr(tform)
	    itype[1] = EOS
	    ptype[1] = EOS
	    rtype = SKIP
	    return
	}

        call strcat(tbuf, itype, SZ_TYPEDEF)
        call strcat(tbuf, ptype, SZ_TYPEDEF)

	i = i+1
	j = 1

        while (IS_DIGIT(tform[i]))
        {
            tbuf[j] = tform[i]
            i = i+1
	    j = j+1
        }

        # null terminate
        tbuf[j] = EOS

        # convert to integer
	ip = 1
        junk = ctoi(tbuf, ip, mpe_size)

        Memi[TYPE(mpe_ptr) + idx - 1] = mpe_type
        Memi[SIZE(mpe_ptr) + idx - 1] = mpe_size

	if (streq(key_x, ttype))
	   call strcat(":x", itype, SZ_TYPEDEF)
	else if(streq(key_y, ttype))
	   call strcat(":y", itype, SZ_TYPEDEF)

	
	call strcat(":", ptype, SZ_TYPEDEF)
	call strcat(ttype, ptype, SZ_TYPEDEF)

	# add a separator
	call strcat(",", itype, SZ_TYPEDEF)
	call strcat(",", ptype, SZ_TYPEDEF)
	}


	# assign MPE sum the total number of bytes in binary of the events
	SUM(mpe_ptr) = mpe_sum * 2

    # over-write the last comma with a "}"
    call strcpy("}", itype[strlen(itype)], SZ_TYPEDEF)
    call strcpy("}", ptype[strlen(ptype)], SZ_TYPEDEF)

    # convert to lower case
    call strlwr(itype)
    call strlwr(ptype)

  # NOTE: This makes all the previous code worthless! #
    call mpe_shift_macros(itype, ptype)
    call strcpy(itype,otype,SZ_LINE)
end


procedure mpe_shift_macros(type, ptype)

char	type[ARB]
char 	ptype[ARB]

begin
	  
# GOD FORGIVE ME

        call strcpy(PROS_LARGE, ptype, SZ_LINE)

	call strcpy("{s:x,s:y,s,s,d,s,s}", type, SZ_LINE) 
end


procedure mpe_print_ptr(ptr, idx)

pointer ptr
int	idx
int	i

begin

	call printf("**********************************************\n")
	do i = 1, idx
	{
	   call printf("TYPE: *%d*  SIZE: *%d*\n")
           call pargi(Memi[TYPE(ptr) + i - 1])
           call pargi(Memi[SIZE(ptr) + i - 1])
	}
	   call printf("SUM: *%d*\n")
           call pargi(SUM(ptr))
           call printf("X_POS = %d Y_POS = %d DX_POS = %d DY_POS = %d\n")
           call pargi(X_POS(ptr))
           call pargi(Y_POS(ptr))
           call pargi(DX_POS(ptr))
           call pargi(DY_POS(ptr))
           call printf("PHA_POS = %d PI_POS = %d TIME_POS = %d\n")
           call pargi(PHA_POS(ptr))
           call pargi(PI_POS(ptr))
           call pargi(TIME_POS(ptr))

	call printf("**********************************************\n")

end


procedure mpe_change_colnames(ext, num_fields, mpe_ptr)

pointer ext
int	num_fields
pointer	mpe_ptr

char	type_str[SZ_LINE]
bool	streq()
int	idx
pointer cur_ext

begin
	X_POS(mpe_ptr)    = -1
        Y_POS(mpe_ptr)    = -1
        DX_POS(mpe_ptr)   = -1
        DY_POS(mpe_ptr)   = -1
        PI_POS(mpe_ptr)   = -1
        PHA_POS(mpe_ptr)  = -1
        TIME_POS(mpe_ptr) = -1

	do idx = 1, num_fields
	{
	   cur_ext=EXT(ext,idx)
           call strcpy(Memc[EXT_TYPE(cur_ext)], type_str, SZ_LINE)
	   
	   call strlwr(type_str)
	   
           if (streq(type_str, X_NAME))
	   {
	      call strcpy("x", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      X_POS(mpe_ptr) = idx
	   }

           if (streq(type_str, Y_NAME))
           {
              call strcpy("y", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      Y_POS(mpe_ptr) = idx
           }

           if (streq(type_str, DX_NAME))
           {
              call strcpy("dx", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      DX_POS(mpe_ptr) = idx
           }

           if (streq(type_str, DY_NAME))
           {
              call strcpy("dy", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
              DY_POS(mpe_ptr) = idx
           }

           if (streq(type_str, PI_NAME))
	   {
              call strcpy("pi", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      PI_POS(mpe_ptr) = idx
	   }

           if (streq(type_str, PHA_NAME))
	   {
              call strcpy("pha", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      PHA_POS(mpe_ptr) = idx
	   }

	   if (streq(type_str, TIME_NAME))
	   {
              call strcpy("time", Memc[EXT_TYPE(cur_ext)], SZ_LINE)
	      TIME_POS(mpe_ptr) = idx
	   }

	   type_str[1] = EOS

	}

end


# This routine is a modified version of an ST strfits routine
int procedure mpe_read_pixels (fd, buf, npix, recptr, spp, mii,
			       ch_rec, mii_recsz, ip)

int     fd              # Input file descriptor
char    buf[ARB] 	# Output buffer
int     npix            # Number of pixels to read

int     ch_rec, mii_recsz, nchars, recptr
int     i, n, ip, op
pointer mii, spp

int     read(), sizeof()
errchk  read

begin
	nchars = npix * sizeof(TY_CHAR)
	op = 0

	repeat 
	{
	   # If data is exhausted read the next record
	   if (ip == ch_rec) 
	   {
	      iferr (i = read (fd, Memi[mii], mii_recsz)) 
	      {
		  call error (1, "Error reading ASCII FITS file")
	      }

	      if (i == EOF)
		 return (EOF)

	      call miiupk (Memi[mii], Memc[spp], FITS_BUFFER, FITS_BYTE,
			   TY_CHAR)

	      ip = 0
	      recptr = recptr + 1
	   }

	   n = min (ch_rec - ip, nchars - op)
	   call amovc (Memc[spp+ip], buf[1+op], n)
	   ip = ip + n
	   op = op + n

	} until (op == nchars)

	return (npix)
end

