#$Header: /home/pros/xray/lib/pros/RCS/qpwcs.x,v 11.0 1997/11/06 16:20:43 prosb Exp $
#$Log: qpwcs.x,v $
#Revision 11.0  1997/11/06 16:20:43  prosb
#General Release 2.5
#
#Revision 9.1  1996/03/11 15:51:36  prosb
#MO/Janet - ascds - added code to skip writing wcs when info unavailable.
#
#Revision 9.0  95/11/16  18:28:15  prosb
#General Release 2.4
#
#Revision 8.1  94/09/13  15:21:23  dvs
#(Mo's changes...something to do with WCS matrices)
#
#Revision 8.0  94/06/27  13:47:06  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:10:36  prosb
#General Release 2.3
#
#Revision 6.1  93/10/21  11:38:36  mo
#MC/DVS	9/8/93		Free a memory buffer
#
#Revision 6.0  93/05/24  15:54:04  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:03:37  mo
#JM/MC	5/20/93		Add support to handle LINEAR wcs specifiers
#
#Revision 5.0  92/10/29  21:17:26  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:49:55  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/13  14:31:47  mo
#MC	4/13/92		Add call to mw_ssystem to the QPWCS 
#			due to reference in Doug's 2.10 notes
#			Appeared to have no affect
#
#Revision 3.0  91/08/02  01:01:17  wendy
#General
#
#Revision 2.0  91/03/07  00:07:29  pros
#General Release 1.0
#

# QPWCS.X  -- QP  

include <qpoe.h>
include <imhdr.h>
include <math.h>

define SZ_KWNAME	8

#
# QPH2MW -- put a qph into an mwcs.
#

procedure qph2mw(qphead, mw)

pointer qphead
pointer mw
#--

double	r[2]			# The wcs terms
double	w[2]			#
double	arc[2]
double	roll

int	axes[2]
char	pbuf1[SZ_FNAME]		# you figure it out!
char	tbuf1[SZ_FNAME]		# you figure it out!
char	pbuf2[SZ_FNAME]		# you figure it out!
char	tbuf2[SZ_FNAME]		# you figure it out!

bool	streq()
	
begin
	r[1] = QP_CRPIX1(qphead)
	r[2] = QP_CRPIX2(qphead)

	w[1] = QP_CRVAL1(qphead)
	w[2] = QP_CRVAL2(qphead)

	arc[1] = QP_CDELT1(qphead)
	arc[2] = QP_CDELT2(qphead)
	roll = QP_CROTA2(qphead)

#   We will let mkwcs re-derive the rotation matrix from the rotation angle
#	Not sure if QP_CD always correctly updated, since it was
#	added later that the other WCS keywords
#	m[1,1] = QP_CD11(qphead)
#	m[1,2] = QP_CD12(qphead)
#	m[2,1] = QP_CD21(qphead) 
#	m[2,2] = QP_CD22(qphead)

##  Nope - don't trust the QPHEAD rotation matrix
#	If there is already a rotation matrix - use it
#	if( !fp_equald(m[1,1]) )
#	    call mkwcs2(r, w, arc, m, mw)
#	else 
	    call mkwcs(r, w, arc, roll, mw)

	# Set axis names.
	#
	call mw_swattrs(mw, 1, "system", "world")

	call enc_ctype(QP_CTYPE1(qphead), 1, pbuf1, tbuf1, SZ_FNAME)
	call enc_ctype(QP_CTYPE2(qphead), 2, pbuf2, tbuf2, SZ_FNAME)

	if ( streq(pbuf1, pbuf2) ) {		# the same projections?
	    axes[1] = 1
	    axes[2] = 2
	    call strcat(" "  , tbuf1, SZ_FNAME)
	    call strcat(tbuf2, tbuf1, SZ_FNAME)
	    call mw_swtype(mw, axes, 2, pbuf1, tbuf1)
	} else {
	    call mw_swtype(mw, 1, 1, pbuf1, tbuf1)
	    call mw_swtype(mw, 2, 1, pbuf2, tbuf2)
	}
end


#
# PUT_QPWCS -- write a new wcs from the qpoe header (physical and logical)
#
#

procedure put_qpwcs(qp, qphead)

pointer qp			# i: qp file descriptor
pointer qphead			# i: qp header struct
#--
pointer	mw, qp_loadwcs()
bool	streq()
errchk	qp_loadwcs()

begin
	# only write the wcs if none exists in the file
	# otherwise we lose the physical wcs that was in the file,
	# replacing it with the new logical wcs
#  #  For QPOE -> QPOE we will update the WCS
   #	ifnoerr ( mw = qp_loadwcs(qp) )
   #	    return
	ifnoerr ( mw = qp_loadwcs(qp) )
	    return

	# if there is no WCS info available, don't write the WCS!
	if( streq(QP_CTYPE1(qphead), "") || streq(QP_CTYPE2(qphead), "") )
	    return

	call qph2mw(qphead, mw)
	call qp_savewcs(qp, mw, 2)
	call mw_close(mw)
end


procedure put_imwcs(im, qphead)

pointer im			# i: qp file descriptor
pointer qphead			# i: qp header struct
#--

pointer	mw, mw_openim()
errchk	mw_openim()

begin
	# only write the wcs if none exists in the file
	# otherwise we lose the physical wcs that was in the file,
	# replacing it with the new logical wcs
	ifnoerr ( mw = mw_openim(im) )
	    return

	call qph2mw(qphead, mw)
	call mw_ssystem(mw, "world")
	call mw_saveim(mw, im)
end


#
#  enc_ctype -- encode the axis type from the ctype string
#
procedure enc_ctype(ctype, axis, pbuf, obuf, len)

char	ctype[ARB]			# i: ctype string
char	temp[SZ_FNAME]
int	axis				# i: axis number
char	pbuf[ARB]			# o: projection type
char	obuf[ARB]			# o: axis type
int	len				# i: length of output string

char	ch
int	index				# l: index into string
int	stridx(), strldx()		# l: string index
int	strncmp()

begin
	call strcpy(ctype, temp, SZ_FNAME)
	call strlwr(temp)

	ch = '-'

	index = strldx(ch, temp) + 1
	if (index == 0)
	{
	   if (strncmp(temp, "linear", 6) == 0)
	   {
	      call strcpy("linear", pbuf, SZ_FNAME)
	   }
	   else
	   {
	      call error(1, "Encode failed. Unknown axis type")
	   }
	}
	else
	{
           call strcpy(temp[index], pbuf, SZ_FNAME)
	}

	index = stridx(ch, temp)
	if (index == 0)
        {
           if (strncmp(temp, "linear", 6) == 0)
           {
              call strcpy("linear", pbuf, SZ_FNAME)
           }
           else
           {
              call error(1, "Encode failed. Unknown axis type")
           }
        }
        else
        {
           temp[index] = EOS
        }


	call sprintf(obuf, len, "axis %d: axtype=%s")
	call pargi(axis)
	call pargstr(temp)	


end


#
# MW2QPH  -- get the info in a mwcs into the qphead
#

procedure mw2qph(mw, qphead)

pointer	mw
pointer	qphead
#--

double	r[2]			# The WCS terms
double	w[2]			#
double	arc[2]
double	cd[2,2]
double	roll

char	ctype[SZ_KWNAME]

begin
	call bkwcs2(mw, r, w, arc, roll, cd)

	QP_CRPIX1(qphead) = r[1]
	QP_CRPIX2(qphead) = r[2]

	QP_CRVAL1(qphead) = w[1]
	QP_CRVAL2(qphead) = w[2]

	QP_CDELT1(qphead) = arc[1]
	QP_CDELT2(qphead) = arc[2]

	QP_CD11(qphead) = cd[1,1]
	QP_CD12(qphead) = cd[1,2]
	QP_CD21(qphead) = cd[2,1]
	QP_CD22(qphead) = cd[2,2]

	QP_CROTA2(qphead) = roll

	call dec_ctype(mw, 1, ctype)
	call strcpy(ctype, QP_CTYPE1(qphead), SZ_KWNAME)
	call dec_ctype(mw, 2, ctype)
	call strcpy(ctype, QP_CTYPE2(qphead), SZ_KWNAME)
end


procedure get_qpwcs(qp, qphead)

pointer	qp
pointer	qphead
#--

pointer	mw

pointer	qp_loadwcs()
errchk	qp_loadwcs()

begin
	iferr (	mw = qp_loadwcs(qp) ) {
		return 
	}
	call mw2qph(mw, qphead)
end



procedure get_iowcs(qpio, qphead)

pointer	qpio
pointer	qphead
#--

pointer	mw

pointer	qpio_lwcs()
errchk	qpio_lwcs()

begin

	iferr (	mw = qpio_lwcs(qpio) ) {
		return
	}
	call mw2qph(mw, qphead)
end



procedure get_imwcs(im, qphead)

pointer	im
pointer	qphead
#--

pointer	mw, mw_openim()
errchk	mw_openim()

begin
	iferr (	mw = mw_openim(im) ) {
		return
	}
	call mw2qph(mw, qphead)
end


procedure dec_ctype(mw, axis, obuf)

pointer	mw
int	axis
char	obuf[ARB]
#--

int	op

char	atype[SZ_KWNAME]
char	wtype[SZ_KWNAME]

int	strlen()
int	strncmp()

errchk	mw_gwattrs()

begin
       	iferr (call mw_gwattrs(mw, axis, "wtype", wtype, SZ_KWNAME)) 
	{
	    call strcpy("LINEAR  ", obuf, SZ_KWNAME)
	    return
	}

	iferr (call mw_gwattrs(mw, axis, "axtype", atype, SZ_KWNAME))
	{
	    call strcpy("", atype, SZ_KWNAME)
	}

	call strlwr(atype)
	call strlwr(wtype)

	#-------------------------------------------------------
	# if the type is "linear" copy that to the output buffer
	# else create the RA---TAN and DEC--TAN strings
	#-------------------------------------------------------
	if ((strncmp("linear", atype, 6) == 0) || 
	    (strncmp("linear", wtype, 6) == 0))
	{
	   call strcpy("LINEAR  ", obuf, SZ_KWNAME)
	}
	else
	{
	   call strcpy(atype, obuf, SZ_KWNAME)
	   call strcat("--------", obuf, SZ_KWNAME)

           op = max(1, SZ_KWNAME - strlen(wtype) + 1)
           call strcpy (wtype, obuf[op], SZ_KWNAME-op+1)
           call strupr (obuf)
	}
end
