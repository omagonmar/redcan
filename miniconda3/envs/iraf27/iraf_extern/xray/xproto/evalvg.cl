# $Header: /home/pros/xray/xproto/RCS/evalvg.cl,v 11.0 1997/11/06 16:39:08 prosb Exp $
# $Log: evalvg.cl,v $
# Revision 11.0  1997/11/06 16:39:08  prosb
# General Release 2.5
#
# Revision 9.0  1995/11/16 19:26:14  prosb
# General Release 2.4
#
#Revision 1.2  1994/07/25  14:21:28  janet
#jd - include filenames with input table prompt (eph.tab,obi.tab)
#
#Revision 1.1  94/07/20  11:50:41  chen
#Initial revision
#
#
# -----------------------------------------------------------------------
# Module:       evalvg.cl
# Description:  
# Initial version:  jc - 7/94
# -----------------------------------------------------------------------

procedure evalvg(tab_root, otb_name)

file tab_root  {"",prompt="Input table root name (_eph.tab,_obi.tab)", mode="a"}
file otb_name  {"",prompt="output orbit angles table name", mode="a"}
int  display {1,prompt="0=no disp, 1=header", mode="h"}
bool clobber {no,prompt="delete old copy of output file",mode="h"}

begin

file tabfile
file ephfile

        tabfile = tab_root

# check the ephemeris table is REV0 or RDF
        _rtname (tabfile, ephfile, "_eph.tab")
        ephfile= s1       

	_keychk (ephfile, "RDF_VERS")
        if( _keychk.value == "" ) {

       #  ---------------------------------------------------
       #  Rev0 eph file - Only RDF data accepted in this task
       #  ---------------------------------------------------
          print ("")
	  error (0, "Rev0 data found - Evalvg accepts RDF data only!!")

	} else {

       #  --------------------------------------------------
       #  RDF eph file - run evalvg
       #  --------------------------------------------------
	  _evlvg (tabfile, otb_name, display=display, clobber=clobber)
 
	}
end
