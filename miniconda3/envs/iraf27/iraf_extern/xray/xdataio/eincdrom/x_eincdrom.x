#$Log: x_eincdrom.x,v $
#Revision 11.0  1997/11/06 16:37:17  prosb
#General Release 2.5
#
#Revision 9.0  1995/11/16 19:00:57  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:52  prosb
#General Release 2.3.1
#
#Revision 7.1  94/05/06  16:55:25  prosb
#Added ecdinfo/_specinfo tasks to package.
#
#Revision 7.0  93/12/27  18:46:20  prosb
#General Release 2.3
#
#Revision 6.0  93/05/24  17:11:31  prosb
#General Release 2.2
#
#Revision 1.1  93/04/13  09:46:37  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/RCS/x_eincdrom.x,v 11.0 1997/11/06 16:37:17 prosb Exp $
#
# Executables for the eincdrom package.

task	cp_wo_attr =    t_cp_wo_attr,
	fits_find  =	t_fits_find,
	fitsnm_get = 	t_fitsnm_get,
	spec2root  =	t_spec2root,
	ecdinfo    =    t_ecdinfo,
        specinfo   =    t_specinfo

	
