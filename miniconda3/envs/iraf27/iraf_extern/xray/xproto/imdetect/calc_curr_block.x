#$Header: /home/pros/xray/xproto/imdetect/RCS/calc_curr_block.x,v 11.0 1997/11/06 16:39:57 prosb Exp $
#$Log: calc_curr_block.x,v $
#Revision 11.0  1997/11/06 16:39:57  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:18:57  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:19  prosb
#Initial revision
#
#Revision 1.2  1997/02/19  15:14:02  prosb
#*** empty log message ***
#
#JCC(2/18/97) - add and pass new parameters : xshift & yshift
#
#Revision 1.1  1996/11/04  21:49:39  prosb
#Initial revision
#
# -------------------------------------------------------------------------
# Module:       calc_curr_block.x 
# Description:  calculate the current block
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1996.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen - initial spp version 1996
#               {n} <who> -- <does what> -- <when>
# -------------------------------------------------------------------------
procedure calc_curr_block(sbim,display,curr_blx,curr_bly,xshift,yshift)

pointer mw_sctran()
pointer mw_openim()
pointer omw, oct
pointer sbim                      # i: source or bkgd images 

real    outx1, outy1              # l: output from mwcs code
real    outx2, outy2              # l: output from mwcs code

#current block for imcomp
int    curr_blx, curr_bly         # o: current block of x, y
int    display                    # i: display level
real   xshift, yshift             # o: x,y shifting coord.

begin
        omw = mw_openim(sbim) 
        oct = mw_sctran(omw, "logical", "physical", 3B)
        call mw_c2tranr(oct, 1., 1., outx1, outy1)
        call mw_c2tranr(oct, 2., 2., outx2, outy2)
        curr_blx = int(outx2) - int(outx1)
        curr_bly = int(outy2) - int(outy1)

        xshift = 2.0 * outx1 - outx2
        yshift = 2.0 * outy1 - outy2

        if (display >= 3 ) 
        {
           call eprintf ("\ncalc_curr_block : outx2/1= %f  %f ")
           call pargr( outx2)
           call pargr( outx1)
           call eprintf ("\ncalc_curr_block : outy2/1= %f  %f ")
           call pargr( outy2)
           call pargr( outy1)
           call eprintf ("\ncalc_curr_block : curr_blx/y= %d  %d ")
           call pargi( curr_blx)
           call pargi( curr_bly)
        }

        call mw_close(omw)
end
