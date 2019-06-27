#$Header: /home/pros/xray/xproto/imdetect/RCS/log2phy.x,v 11.2 1998/04/24 16:14:08 prosb Exp $
#$Log: log2phy.x,v $
#Revision 11.2  1998/04/24 16:14:08  prosb
#Patch Release 2.5.p1
#
#Revision 11.1  1997/12/10 15:11:28  prosb
#JCC(12/10/97) - add xshift/yshift for diaplay.
#
#Revision 11.0  1997/11/06 16:40:02  prosb
#General Release 2.5
#
#Revision 1.1  1997/10/06 15:19:00  prosb
#Initial revision
#
#Revision 1.1  1997/10/06 15:12:23  prosb
#Initial revision
#
#Revision 1.4  1997/02/19  15:13:58  prosb
#*** empty log message ***
#
#JCC(2/18/97) - add and pass new parameters : xshift & yshift
#
#Revision 1.3  1997/02/10  21:57:41  prosb
#JCC(2/10/97) - display "debug"
#
#Revision 1.2  1997/01/24  15:44:34  prosb
#JCC(1/23/97) - add "debug"
#
#Revision 1.1  1996/11/04  21:53:07  prosb
#Initial revision
#
# -------------------------------------------------------------------------
# Module:       log2phy.x
# Description:  convert logical coord. to physical coord. 
# Copyright:    Property of Smithsonian Astrophysical Observatory
#               1996.  You may do anything you like with this
#               file except remove this copyright
# Modified:     {0} Judy Chen - initial spp version 1996
#               {n} <who> -- <does what> -- <when>
# -------------------------------------------------------------------------

procedure log2phy(debug,sim,xlog,ylog,xphy,yphy,xcomp_fact_src,ycomp_fact_src,
xshift, yshift)

pointer  sim                #i:  source image pointer
real     xlog, ylog         #i:  xy logical coord
real     xphy, yphy         #o:  xy physical coord
int      xcomp_fact_src     #i:  compress factor for source
int      ycomp_fact_src     #i:  compress factor for source
real     xphy1, yphy1       #l:  xy physical coord
real     xshift,yshift      #l:  xy shift coord. 

int      debug              #i:  debug level

pointer  mw_sctran()
pointer  mw_openim()
pointer  omw, oct

begin
        omw = mw_openim(sim)

        oct = mw_sctran(omw, "logical", "physical", 3B)
        call mw_c2tranr(oct, xlog, ylog, xphy1, yphy1)  

#JCC (2/4/97) - need xshift/yshift to get the physical coord
        #xphy = xphy1 * xcomp_fact_src     # comp_fact_src from imcomp
        #yphy = yphy1 * ycomp_fact_src  
        xphy = (xphy1-xshift) * xcomp_fact_src + xshift
        yphy = (yphy1-yshift) * ycomp_fact_src + yshift

        if (debug >= 5 ) {
           call flush(STDOUT)
           call printf("log2phy:   debug = %d  \n")
           call pargi(debug)

           call flush(STDOUT)
           call printf("log2phy:   xlog,ylog(input) = %f  %f \n")
           call pargr(xlog)
           call pargr(ylog)

           call flush(STDOUT)
           call printf("log2phy:   xphy,yphy(output)= %f  %f \n")
           call pargr(xphy)
           call pargr(yphy)

           call flush(STDOUT)
           call printf("log2phy:   xphy1,yphy1(local)= %f  %f \n")
           call pargr(xphy1)
           call pargr(yphy1)

           call flush(STDOUT)
           call printf("log2phy:   xshift,yshift(inp)= %f %f\n")
           call pargr(xshift)
           call pargr(yshift)
        }

        call mw_close(omw)
end
