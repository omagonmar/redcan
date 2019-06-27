#$Log: specinfo.x,v $
#Revision 11.0  1997/11/06 16:37:05  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:01:49  prosb
#General Release 2.4
#
#Revision 8.1  1994/08/01  11:11:21  dvs
#Added documentation.
#
#Revision 8.0  94/06/27  16:59:41  prosb
#General Release 2.3.1
#
#Revision 1.1  94/05/06  17:08:04  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/_specinfo/RCS/specinfo.x,v 11.0 1997/11/06 16:37:05 prosb Exp $
#
#--------------------------------------------------------------------------
# Module:       specinfo.x
# Project:      PROS -- EINSTEIN TOOLS
# External:     t_specinfo
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1994.  You may do anything you like with this
#               file except remove this copyright.
# Modified:     {0} David Van Stone -- 5/94 -- initial version 
#               {n} <who> -- <when> -- <does what>
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Procedure:    t_specinfo()
#
# Purpose:      Main procedure call for the task specinfo
#
# Input parameters:
#		specifier	data set specifier
#		display		display level 
#
# Output parameters:
#		is_valid	Is specifier valid so far?
#		is_fits		Is specifier a FITS file?
#               seq             What is the sequence number, if it's a
#                               sequence?
#               inst            What is the instrument name, if we
#                               can read it from the specifier?
#               datatype        What is the datatype, if we can tell?
#               is_list         Is the specifier actually a list instead?
#               filename        If so, what is the filename containing the
#                               list?
#
# Description:  This procedure reads in the appropriate parameters and
# calls the routine "specinfo" which generates as much information about
# the specifier as possible.  This routine then returns this information
# back to the parameter file.  See specinfo() for more details.
#--------------------------------------------------------------------------
procedure t_specinfo()
pointer p_spec		# pointer to specifier string
bool	is_valid	# is specifier valid?
bool	is_fits		# is it a FITS file?
int	seq		# if not, what is the sequence number?
pointer p_inst		# pointer to returning instrument string
pointer p_datatype	# pointer to returning datatype
bool	is_list		# is specifier a list file?
pointer p_filename	# if so, this is a pointer to the filename
int	display		# display level

### LOCAL VARS ###

pointer sp        	# stack pointer

int     clgeti() 	# returns integer CL parameter [sys/clio]

### BEGINNING OF PROCEDURE ###

begin
        #----------------------------------------------
        # allocate space on stack & set aside memory
        #   for strings
        #----------------------------------------------
        call smark(sp)
        call salloc( p_spec, SZ_LINE, TY_CHAR)
        call salloc( p_inst, SZ_LINE, TY_CHAR)
        call salloc( p_datatype, SZ_LINE, TY_CHAR)
        call salloc( p_filename, SZ_PATHNAME, TY_CHAR)
	
        #----------------------------------------------
        # read in parameters
        #----------------------------------------------
        call clgstr("specifier",Memc[p_spec],SZ_LINE)
	display=clgeti("display")

        #----------------------------------------------
        # remove white space around specifier
        #----------------------------------------------
        call strip_whitespace(Memc[p_spec])
	call strlwr(Memc[p_spec])

        #----------------------------------------------
        # get specifier info
        #----------------------------------------------
	call specinfo(Memc[p_spec],is_valid,is_fits,
		seq,Memc[p_inst],Memc[p_datatype],is_list,
		Memc[p_filename],display)

        #----------------------------------------------
        # put output parameters into parameter file
        #----------------------------------------------
	call clputb("is_valid",is_valid)
	call clputb("is_fits",is_fits)
	call clputi("seq",seq)
	call clpstr("inst",Memc[p_inst])
	call clpstr("datatype",Memc[p_datatype])
	call clputb("is_list",is_list)
	call clpstr("filename",Memc[p_filename])

        #----------------------------------------------
        # free stack
        #----------------------------------------------
        call sfree (sp)
end
