#$Header: /home/pros/xray/ximages/imcalc/RCS/xstore.x,v 11.0 1997/11/06 16:28:02 prosb Exp $
#$Log: xstore.x,v $
#Revision 11.0  1997/11/06 16:28:02  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:34:13  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  14:44:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:24:49  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:06:46  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:25:22  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  17:29:34  prosb
#General Release 2.0:  April 1992
#
#Revision 3.0  91/08/02  01:17:05  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:33:08  pros
#General Release 1.0
#
include	<imhdr.h>
include	"imcalc.h"

# XSTORE -- Store the input register in the next output line of the output
# image.  Set the global ATEOF flag (for BNEOF) when the end of the section
# is reached.  When we are called the next output line has already been
# computed and is ready to be written out.  The output buffer pointer was
# saved in the last call (or at parse time).  Move the data into the output
# buffer and get a new output buffer for the next call, checking for EOF in
# the process.  A redundant memory to memory copy is involved, but the
# alternative is too complicated to attempt at present.

procedure xstore (in, out)

pointer	in			# input register
pointer	out			# imcalc image descriptor

int	status
pointer	im, lbuf, ibuf, obuf
int	impnls(), impnli(), impnll(), impnlr(), impnld(), impnlx()
include	"imcalc.com"

begin
	# on EOF, return
	if (I_ATEOF(out) == YES) {
	    c_ateof = YES
	    return
	}

	# get image descriptor
	im   = I_IM(out)

	# set the type, if its not a section
	# (in which case we want the original type)
	if( c_section == NO )
		# fill in the type
		IM_PIXTYPE(im) = R_TYPE(in)

	# do the store of a vector
	if( R_LENGTH(in) != 0 ){

        IM_LEN(im, 1) = R_LENGTH(in)
	switch (R_TYPE(in)) {
	case TY_SHORT:
	    status = impnls (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_SHORT + 1
	    obuf = (lbuf - 1) * SZ_SHORT + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_SHORT)
	case TY_USHORT, TY_LONG:
	    status = impnll (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_LONG + 1
	    obuf = (lbuf - 1) * SZ_LONG + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_LONG)
	case TY_INT:
	    status = impnli (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_INT + 1
	    obuf = (lbuf - 1) * SZ_INT + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_INT)
	case TY_REAL:
	    status = impnlr (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_REAL + 1
	    obuf = (lbuf - 1) * SZ_REAL + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_REAL)
	case TY_DOUBLE:
	    status = impnld (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_DOUBLE + 1
	    obuf = (lbuf - 1) * SZ_DOUBLE + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_DOUBLE)
	case TY_COMPLEX:
	    status = impnlx (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    ibuf = (R_LBUF(in) - 1) * SZ_COMPLEX + 1
	    obuf = (lbuf - 1) * SZ_COMPLEX + 1
	    call amovc (Memc[ibuf], Memc[obuf], R_LENGTH(in) * SZ_COMPLEX)
	default:
	    call imc_error ("xstore: unknown image pixel datatype")
	    return
	}

	}
	else{

        IM_LEN(im, 1) = 1
	# do the store of a constant
	switch (R_TYPE(in)) {
	case TY_SHORT:
	    status = impnls (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Mems[lbuf] = R_VALS(in)
	case TY_INT:
	    status = impnli (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Memi[lbuf] = R_VALI(in)
	case TY_LONG:
	    status = impnll (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Meml[lbuf] = R_VALL(in)
	case TY_REAL:
	    status = impnlr (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Memr[lbuf] = R_VALR(in)
	case TY_DOUBLE:
	    status = impnld (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Memd[lbuf] = R_VALD(in)
	case TY_COMPLEX:
	    status = impnlx (im, lbuf, I_V(out))
	    if( status == EOF ) goto 99
	    Memx[lbuf] = R_VALX(in)
	default:
	    call imc_error ("xstore: unknown image pixel datatype")
	    return
	}

	}

	# normal return - no EOF
	I_LBUF(out) = lbuf
	return

	# EOF encountered
99	I_ATEOF(out) = YES			# on image
	c_ateof = YES				# for BNEOF
	# one less image to process
	c_imageno = c_imageno - 1

end
