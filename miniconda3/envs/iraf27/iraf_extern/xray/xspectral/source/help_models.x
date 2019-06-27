#$Header: /home/pros/xray/xspectral/source/RCS/help_models.x,v 11.0 1997/11/06 16:42:18 prosb Exp $
#$Log: help_models.x,v $
#Revision 11.0  1997/11/06 16:42:18  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:29:49  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  17:31:53  prosb
#General Release 2.3.1
#
#Revision 7.0  93/12/27  18:55:39  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  16:50:32  prosb
#General Release 2.2
#
#Revision 5.0  92/10/29  22:44:35  prosb
#General Release 2.1
#
#Revision 4.0  92/04/27  18:15:16  prosb
#General Release 2.0:  April 1992
#
#Revision 3.1  91/09/22  19:06:09  wendy
#Added
#
#Revision 3.0  91/08/02  01:58:23  prosb
#General Release 1.1
#
#Revision 2.0  91/03/06  23:03:43  pros
#General Release 1.0
#
# Project:      PROS -- ROSAT RSDC
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1989.  You may do anything you like with this
#               file except remove this copyright
#
#	HELP_MODELS -- give the user some help 'bout the model input
#
procedure help_models()

int	fd					# l: file descriptor
char	buf[SZ_LINE]				# l: temp char buffer
int	access()				# l: file access
int	open()					# l: open a file
int	getline()				# l: get a line from a file

begin
	call clgstr("model_help", buf, SZ_LINE)
	if( access(buf, 0, 0) == YES ){
	    fd = open(buf, READ_ONLY, TEXT_FILE)
	    call printf("\n")	    
	    while( getline(fd, buf) != EOF ){
		call putline(STDOUT, buf)
	    }
	    call printf("\n")
	    call close(fd)
	}
	else
	    call printf("Sorry - no help for models yet\n")
end
