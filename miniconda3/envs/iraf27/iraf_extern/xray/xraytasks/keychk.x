# $Header: /home/pros/xray/xraytasks/RCS/keychk.x,v 11.0 1997/11/06 16:46:32 prosb Exp $
# $Log: keychk.x,v $
# Revision 11.0  1997/11/06 16:46:32  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:37:09  prosb
# General Release 2.4
#
#Revision 8.0  1994/06/27  17:46:36  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  19:08:21  prosb
#General Release 2.3
#
#Revision 1.1  93/12/22  17:19:23  mo
#Initial revision
#
# --------------------------------------------------------------------------
# keychk -- Transfer header 'text' keyword to IRAF parameter
#        ** This routine performs the same task as 'keypar' in tables
#           but works when the parameter is not in the header.
#           If 'keypar' gets updated to work when the parameter
#           doesn't exist, this routine could be replaced with the new
#           one.
# jd - 8/93
# --------------------------------------------------------------------------

define  SZ_KEYWORD      64

procedure t_keychk()

pointer	input		# Name of file containing header keyword
pointer	keyword		# Name of header keyword
pointer	value		# IRAF parameter value

pointer sp, hd

pointer tbtopn()

begin
	# Allocate storage for character strings

	call smark (sp)
	call salloc (input, SZ_PATHNAME, TY_CHAR)
	call salloc (keyword, SZ_KEYWORD, TY_CHAR)
	call salloc (value, SZ_KEYWORD, TY_CHAR)

	# Read input parameters

	call clgstr ("input", Memc[input], SZ_PATHNAME)
	call clgstr ("keyword", Memc[keyword], SZ_KEYWORD)

	# Read table header keyword and do lookup

	hd = tbtopn (Memc[input], READ_ONLY, NULL)

 	iferr ( call tbhgtt (hd, Memc[keyword], Memc[value], SZ_KEYWORD) ) { 
 	   call clpstr ("value", "")
        } else {
 	   call clpstr ("value", Memc[value])
        }

        call flush (STDOUT)

	call tbtclo (hd)

	# Write output parameter and free string storage

	call sfree(sp)
end
