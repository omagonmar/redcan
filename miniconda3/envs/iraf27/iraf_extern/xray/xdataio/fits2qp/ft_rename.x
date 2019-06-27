#$Header: /home/pros/xray/xdataio/fits2qp/RCS/ft_rename.x,v 11.0 1997/11/06 16:34:46 prosb Exp $
#$Log: ft_rename.x,v $
#Revision 11.0  1997/11/06 16:34:46  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 18:59:34  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:21:21  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:40:50  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:25:40  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  21:37:34  prosb
#General Release 2.1
#
#Revision 1.2  92/09/23  11:40:47  jmoran
#JMORAN - no changes
#
#Revision 1.1  92/07/13  14:10:37  jmoran
#Initial revision
#
#
# Module:	ft_standard.x
# Project:	PROS -- ROSAT RSDC
# Purpose:	
# Description:	< opt, if sophisticated family>
# Copyright:	Property of Smithsonian Astrophysical Observatory
#		1989.  You may do anything you like with this
#		file except remove this copyright
# Modified:	
#		{n} <who> -- <does what> -- <when>
#
include "fits2qp.h"


####################
#	FOLLOWING Courtesy of ST's fits_write.x module
###################
procedure fits_rename(irafname,tempfile)
char	irafname[ARB]		# i/o: updated FITS IRAFNAME with PATH
char	tempfile[ARB]		# i: user qp name

pointer	bf			# l: pointer to hold the input path
pointer	sp			# l: stack pointer
char	nroot[SZ_LINE]		# l: QPOENAME root
char	nextn[SZ_LINE]		# l: QPOENAME extension
int	k
int	fnroot(),fnextn(),fnldir()
begin
	call smark(sp)
	call salloc(bf,SZ_LINE,TY_CHAR)
#           if (old_name == YES && strlen (irafname) != 0 &&
#               strncmp (IRAFNAME(fits), "null_image", 10) != 0) {
# Get the input path
              k = fnldir (tempfile, Memc[bf], SZ_LINE)
#              call pesc_dash (irafname)
# Get the QPOENAME root
              k = fnroot (irafname, nroot, SZ_LINE)
              k = fnextn (irafname, nextn, SZ_EXT)
# Get the QPOENAME extension
#              if (gkey == TO_MG)
#                 if (strmatch (nroot, "_cvt") != 0)
#                    nroot[strlen(nroot)-3] = EOS 
#  Build the new QPOENAME with the user input PATH
              call strcat (nroot, Memc[bf], SZ_LINE)
              call iki_mkfname (Memc[bf], nextn, irafname, SZ_LINE)
#              call cesc_dash (irafname)
	call sfree(sp)
end

#  Deal with -,+ in filenames
procedure pesc_dash (name)
 
char name[SZ_FNAME]
 
pointer sp, pp
int     i,j, np, stridx()
char   dash , plus
 
begin
 
        dash = '-'
        np = stridx(dash, name)
        plus = '+'
        if (np == 0)
           np = stridx(plus, name)

        if (np != 0) {
           call smark(sp)
           call salloc(pp,SZ_FNAME,TY_CHAR)
           j = 0
           for (i=1; i<= SZ_FNAME ||name[i] == EOS; i=i+1) {

               if (name[i] != '-' && name[i] != '+')
                  Memc[pp+j] = name[i]
               else {
                  Memc[pp+j] = '\\'
                  j=j+1
                  Memc[pp+j] = name[i] 
               }
               j = j+ 1
           }
           call strcpy (Memc[pp], name, SZ_FNAME)
           call sfree(sp)
        }
end

# Deal with \\ in filenames
procedure cesc_dash (name)

char name[SZ_FNAME]

pointer sp, pp, np
int     i,j, stridx()
char   esc 

begin

        esc= '\\'
        np = stridx(esc, name)
        if (np != 0) {
           call smark(sp)
           call salloc(pp,SZ_FNAME,TY_CHAR)
           j = 0
           for (i=1; i<= SZ_FNAME ||name[i] == EOS; i=i+1) {

               if (name[i] != '\\')
                  Memc[pp+j] = name[i]
               else {
                  if (name[i+1] == '-' || name[i+1] == '+') {
                     Memc[pp+j] = name[i+1]
                     i = i + 1
                  }
               }
               j = j+ 1
           }
           call strcpy (Memc[pp], name, SZ_FNAME)
           call sfree(sp)
        }
end

