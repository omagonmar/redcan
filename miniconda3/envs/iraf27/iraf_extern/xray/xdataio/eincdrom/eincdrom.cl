#$Log: eincdrom.cl,v $
#Revision 11.0  1997/11/06 16:37:13  prosb
#General Release 2.5
#
#Revision 9.1  1997/10/03 21:43:29  prosb
#no change.
#
#Revision 9.0  1995/11/16 19:00:47  prosb
#General Release 2.4
#
#Revision 8.0  1994/06/27  15:23:33  prosb
#General Release 2.3.1
#
#Revision 7.3  94/06/01  12:13:58  prosb
#Moved _fits_get to _fits_get_obs and _qp_get to _qp_get_obs.
#(This fixed an annoying name conflict bug between _fits_get
# and _fitsnm_get.)
#
#Revision 7.2  94/06/01  11:44:14  prosb
#Added "eindatademo" to demonstrate Einstein unscreened IPC data.
#
#Revision 7.1  94/05/06  17:05:24  prosb
#Added tasks for ecd2pros and ecdinfo.  Made qp_get/fits_get hidden.
#
#Revision 7.0  93/12/27  18:45:54  prosb
#General Release 2.3
#
#Revision 6.1  93/12/01  09:04:46  dvs
#Moved definitions of CDROM locations to lib/zzsetenv.def.
#
#Revision 6.0  93/05/24  17:11:05  prosb
#General Release 2.2
#
#Revision 1.2  93/04/18  16:18:29  prosb
#Added definitions used for new datasets eoscat and hriimg.
#
#Revision 1.1  93/04/13  13:03:03  prosb
#Initial revision
#
#$Header: /home/pros/xray/xdataio/eincdrom/RCS/eincdrom.cl,v 11.0 1997/11/06 16:37:13 prosb Exp $
#  eincdrom.cl
#
#  CL script task for eincdrom package

# Load necessary packages

print("")

if ( !defpac( "xdataio" ))
  {
    # package used by ecd2pros
    xdataio
  }
;

if ( !defpac( "tables" ))
  {
    # package used by ecd2pros (to load in fitsio)
    tables
  }
;

if ( !defpac( "fitsio" ))
  {
    # package used by ecd2pros (strfits, for instance)
    fitsio
  }
;


# Define eincdrom package

package eincdrom

task	_specinfo	= "eincdrom$x_eincdrom.e"
task	ecdinfo		= "eincdrom$x_eincdrom.e"


task	_ein_copy	= "eincdrom$_ein_copy.cl"
task	_ein_strfits	= "eincdrom$_ein_strfits.cl"
task 	_fileinfo	= "eincdrom$_fileinfo.cl"
task	_get_ein_files	= "eincdrom$_get_ein_files.cl"
task 	ecd2pros	= "eincdrom$ecd2pros.cl"

task    eincdpar        = "eincdrom$eincdpar.par"

# demo task

task	$eindatademo	= "eincdrom$eindatademo.cl"

# six hidden tasks which should be obsoleted and removed by October
# release...(except, perhaps, _cp_wo_attr)
task    _cp_wo_attr	= "eincdrom$x_eincdrom.e"
task    _fits_find	= "eincdrom$x_eincdrom.e"
task    _fitsnm_get	= "eincdrom$x_eincdrom.e"
task    _spec2root	= "eincdrom$x_eincdrom.e"
task	_qp_get_obs	= "eincdrom$_qp_get_obs.cl"
task	_fits_get_obs	= "eincdrom$_fits_get_obs.cl"

type eincdrom$eincdrom_motd

clbye()

