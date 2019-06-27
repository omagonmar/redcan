#$Header: /home/pros/xray/lib/pros/RCS/xmask.x,v 11.0 1997/11/06 16:21:22 prosb Exp $
#$Log: xmask.x,v $
#Revision 11.0  1997/11/06 16:21:22  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:28:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  13:48:03  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:11:29  prosb
#General Release 2.3
#
#Revision 6.4  93/12/08  01:30:27  dennis
#Restored the earlier change to replace '\n's, but now with '\\'s (to 
#allow for directory paths).
#
#Revision 6.2  93/11/01  23:51:02  dennis
#Replace newlines with slashes and tabs with spaces in mask parameter card.
#
#Revision 6.1  93/10/21  11:39:49  mo
#MC   10/21/93        Add PROS/QPIO bug fix (qpx_addf)
#
#Revision 6.0  93/05/24  15:55:10  prosb
#General Release 2.2
#
#Revision 5.1  93/05/19  17:07:59  mo
#MC	5/20/93		Add routine to DELETE mask info (for QPAPPEND)
#
#Revision 5.0  92/10/29  21:18:06  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  13:51:03  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  92/04/02  17:26:59  mo
#MC	4/2/92		Change format to lower case with latest IRAF2.10 patch
#
#Revision 3.0  91/08/02  01:02:31  wendy
#General
#
#Revision 2.1  91/05/24  11:48:53  mo
#
#        MC      4/16/91         Update the include files to eliminate
#                                "../.." notation
#
#Revision 2.0  91/03/07  00:07:59  pros
#General Release 1.0
#
# Module:       XMASK.X
# Project:      PROS -- ROSAT RSDC
# Purpose:      Routines to access x_mask<nn> params
# External:     < routines which can be called by applications>
# Local:        < routines which are NOT intended to be called by applications>
# Description:  < opt, if sophisticated family>
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} <author>  initial version <when>    
#               {1} MC -- Update include files  -- 2/91
#               {n} <who> -- <does what> -- <when>
#

include <qpset.h>
include <plhead.h>

# max mask records - this limit is so that x_mask<nn> is 8 chars or less
define MAX_MASK 99

# define input types
define TY_QPOE	1
define TY_IM	2

# define some commonly used formats
define MASK_FORMAT	"XS-MSK%02d"
define DISP_FORMAT	"%2d: %s\n"
define X_NRECS		"XS-NMASK"
define	X_CMASK		"XS-CMASK"
define	X_NAREA		"XS-NAREA"
define	X_AREA		"XS-AREA"
define	X_NCMSK		"XS-NCMSK"
#
# PUT_QPMASK -- add a x_mask<nn> record to a qpoe file
#
procedure put_qpmask(fd, mask)

pointer	fd				# i: image handle
char	mask[ARB]			# i: mask record

begin
	call put_mask(fd, mask, TY_QPOE)
end

#
# PUT_IMMASK -- add a x_mask<nn> record to a non-qpoe image file
#
procedure put_immask(fd, mask)

pointer	fd				# i: image handle
char	mask[ARB]			# i: mask record

begin
	call put_mask(fd, mask, TY_IM)
end

#
# PUT_MASK -- add a x_mask<nn> record to an image or qpoe file
#
procedure put_mask(fd, mask, type)

pointer	fd				# i: image handle
char	mask[ARB]			# i: mask record
int	type				# i: image type - QPOE or IM

char	tbuf[SZ_LINE]			# i: temp buffer
int	len				# l: length of mask
int	i				# l: loop counter
pointer	sp				# l: stack pointer
pointer	maskbuf				# l: buffer for mask with '\n's out

int	qp_accessf()			# l: qp param access
int	qp_geti()			# l: get integer param
int	imgeti()			# l: get integer param
int	imaccf()			# l: im param access
int	strlen()			# l: string length
int	max()				# l: max function

begin
	# mark the stack
	call smark(sp)
	# get length of mask
	len = strlen(mask)
	# may as well make it a bit bigger
	len = max(len, SZ_LINE)
	# allocate and initialize buffer for mask with '\n's removed
	call salloc(maskbuf, len, TY_CHAR)
	call strcpy(mask, Memc[maskbuf], len)
	# replace each '\n' with '\', each '\t' with ' '
	for (i = 0;  (i < len) && (Memc[maskbuf + i] != EOS);  i = i + 1)  {
	    if (Memc[maskbuf + i] == '\n')
		Memc[maskbuf + i] = '\\'
	    else if (Memc[maskbuf + i] == '\t')
		Memc[maskbuf + i] = ' '
	}
	# get number of mask records and increment
	switch(type){
	case TY_QPOE:
	    if( qp_accessf(fd, X_NRECS) == NO ){
		i = 1
		call qpx_addf(fd, X_NRECS, "i", 1, "number of x_mask records", 0)
	    }
	    else
		i = qp_geti(fd, X_NRECS) + 1
	    # make sure we have room
	    if( i > MAX_MASK ){
		call printf("\nWarning: mask buffer full\n")
		return
	    }
	    # increment the number of mask records
	    call qp_puti(fd, X_NRECS, i)
	case TY_IM:
	    if( imaccf(fd, X_NRECS) == NO ){
		i = 1
		call imaddf(fd, X_NRECS, "i")
	    }
	    else
		i = imgeti(fd, X_NRECS) + 1
	    # make sure we have room
	    if( i > MAX_MASK ){
		call printf("\nWarning: mask buffer full\n")
		return
	    }
	    # increment the number of mask records
	    call imputi(fd, X_NRECS, i)
	}
	# make the new mask record name
	call sprintf(tbuf, SZ_LINE, MASK_FORMAT)
	call pargi(i)
	# put the mask value
	switch(type){
	case TY_QPOE:
	    call qpx_addf(fd, tbuf, "c", len, "mask descriptor", QPF_INHERIT)
	    call qp_pstr(fd, tbuf, Memc[maskbuf])
	case TY_IM:
	    call imaddf(fd, tbuf, "c")
	    call imastr(fd, tbuf, Memc[maskbuf])
	}
	# free up stack space
	call sfree(sp)
end

#
# DISP_QPMASK -- display mask records in a qpoe file
#
procedure disp_qpmask(fd, n)

pointer	fd				# i: image or qpoe  handle
int	n				# i: mask # or 0 for all

begin
	call disp_mask(fd, n, TY_QPOE)
end

#
# DISP_IMMASK -- display mask records in an image file
#
procedure disp_immask(fd, n)

pointer	fd				# i: image or qpoe  handle
int	n				# i: mask # or 0 for all

begin
	call disp_mask(fd, n, TY_IM)
end

#
# DISP_MASK -- display mask records
#
procedure disp_mask(fd, n, type)

pointer	fd				# i: image or qpoe  handle
int	n				# i: mask # or 0 for all
int	type				# i: image type - QPOE or IM

char	mask[SZ_PLHEAD]			# l: mask record
char	tbuf[SZ_LINE]			# l: test mask param name
int	i				# l: loop counter
int	mmin				# l: loop min
int	mmax				# l: loop max
int	nrecs				# l: total number of mask records
int	nchars				# l: number of chars read by qp_gstr
int	qp_accessf()			# l: qp param access
int	qp_gstr()			# l: get param string
int	qp_geti()			# l: get integer param
int	imgeti()			# l: get integer param
int	imaccf()			# l: im param access

begin
	# print out mask banner
	call printf("\n\t\t\tX-ray masks\n\n")
	# get number of mask records and increment
	switch(type){
	case TY_QPOE:
	    if( qp_accessf(fd, X_NRECS) == NO )
		nrecs = 0
	    else
		nrecs = qp_geti(fd, X_NRECS)
	case TY_IM:
	    if( imaccf(fd, X_NRECS) == NO )
		nrecs = 0
	    else
		nrecs = imgeti(fd, X_NRECS)
	}
	# make sure there are records
	if( nrecs == 0 ){
	    call printf("No mask records available\n")
	    return
	}
	# get limits of mask display
	if( n ==0 ){
	    mmin = 1
	    mmax = nrecs
	}
	else{
	    if( n > nrecs ){
		call printf("Mask record %d not available\n")
		call pargi(n)
		return
	    }
	    else{
		mmin = n
		mmax = n
	    }
	}
	# display all mask records
	do i=mmin, mmax{
	    call sprintf(tbuf, SZ_LINE, MASK_FORMAT)
	    call pargi(i)
	    switch(type){
	    case TY_QPOE:
		if( qp_accessf(fd, tbuf) == NO )
		    call errori(1, "can't find x_mask record", i)
		else{
		    nchars = qp_gstr(fd, tbuf, mask, SZ_PLHEAD)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(mask)
		}
	    case TY_IM:
		if( imaccf(fd, tbuf) == NO )
		    call errori(1, "can't find x_mask record", i)
		else{
		    call imgstr(fd, tbuf, mask, SZ_PLHEAD)
		    call printf(DISP_FORMAT)
	 	    call pargi(i)
		    call pargstr(mask)
		}
	    }		
	}	
end

procedure del_masks(qp)
pointer	qp

int	nrecs
int	i
int	qp_accessf()
int	qp_geti()
pointer	tbuf
pointer sp
begin
	call smark(sp)
	call salloc(tbuf,SZ_LINE,TY_CHAR)
	if( qp_accessf(qp, X_NRECS) == NO )
	    nrecs = 0
	else
	{
	    nrecs = qp_geti(qp, X_NRECS)
	    call qp_deletef(qp, X_NRECS )
	}
	do i = 1, nrecs
	{
            call sprintf(tbuf, SZ_LINE, MASK_FORMAT)
               call pargi(i)
            if( qp_accessf(qp, tbuf) == YES )
	    {
#                nchars = qp_gstr(fd, tbuf, mask, SZ_PLHEAD)
	        call qp_deletef(qp,tbuf)
            }
	}
	if( qp_accessf(qp,X_NAREA) == YES)
	    call qp_deletef(qp,X_NAREA)
	if( qp_accessf(qp,X_AREA) == YES)
	    call qp_deletef(qp,X_AREA)
	if( qp_accessf(qp,X_CMASK) == YES)
	    call qp_deletef(qp,X_CMASK)
	if( qp_accessf(qp,X_NCMSK) == YES)
	    call qp_deletef(qp,X_NCMSK)
call sfree(sp)
end

