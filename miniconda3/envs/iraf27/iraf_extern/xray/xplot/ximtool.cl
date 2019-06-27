#$Header: /home/pros/xray/xplot/RCS/ximtool.cl,v 11.1 2001/04/11 23:29:54 prosb Exp $
# $Log: ximtool.cl,v $
# Revision 11.1  2001/04/11 23:29:54  prosb
# Add ds9 to the image display options
#
#Revision 9.0  1995/11/16  19:08:30  prosb
#General Release 2.4
#
#Revision 8.2  1995/11/06  23:00:18  prosb
#removed obsolete display definition;
#remove check for "HOME$" (unix)
#
#Revision 8.1  1995/11/03  22:29:26  prosb
#updated to include choices between saoimage, ximtool or saotng.
#
#Revision 8.0  1994/06/27  17:01:31  prosb
#General Release 2.3.1
#
#Revision 7.3  94/06/27  13:29:29  wendy
#Changed imt1 pipe location back to HOME$dev for local 
#implementation.
#
#Revision 7.2  94/06/19  17:45:43  prosb
#Changed "pipename" from home$dev/imt1 to /dev/imt1 for release
#
#Revision 7.1  94/02/02  11:57:07  mo
#MC	2/1/94		Simplify terminal type check to just require
#			FIRST CHARACTER == x.  There are now 2
#			different ACCEPTABLE terminal types, xterm and xgterm
#			Unacceptable types are:
#				e.g. gterm, vt100, vt440, etc
#			So this should work
#
#Revision 7.0  93/12/27  18:47:52  prosb
#General Release 2.3
#
#Revision 6.3  93/12/22  19:17:57  wendy
#Corrected imt1 location for release
#
#Revision 6.2  93/12/22  18:47:43  wendy
#Changed home$dev/imt1 to dev$imt1 for release
#
#Revision 6.1  93/09/01  12:25:07  wendy
#Changed "-d <display>" location on resultant command line to ensure
#that both the SAOimage and SAOmonolog windows appear on same machine.
#(This seems to have become a problem only with OS 4.1.3.)
#
#Also appended an option separating space when either of the userpar
#variables are used.
#
#Revision 6.0  93/05/24  16:40:22  prosb
#General Release 2.2
#
#Revision 5.3  93/05/05  13:13:47  wendy
#Reinstated display variable (for remote display use)
#Removed geometry to keep command line length down.
#(Default SAOimage geometry will be used)
#
#Revision 5.2  93/01/29  16:38:47  wendy
#Cleaned up some of the code.
#
#Revision 5.1  93/01/29  13:01:27  wendy
#Implemented saoimage from xterm using Doug Mink's code;
#Modified to stop interrupt from IRAF window killing saoimage window.
#(xterm with options now defined as external task in xplot.cl.)
#
#Revision 1.4  92/07/30  16:30:48  mo
#MC	7/30/92		Write the tempfiles to home$ NOT tmp$ so
#			that each user has a private copy and control
#			of them.
#
#Revision 1.3  92/07/13  17:28:07  mo
#MC	7/13/92		Add space for user parameters and make the
#			check for XTERM less strict.  Just need
#			a 'terminal' with a string containing 'xterm'
#
#Revision 1.2  92/06/30  10:06:17  prosb
#Tool to set up saoimage to use tv$display
#
# XIMTOOL --- Set up ximage to use tv$display
# By Doug Mink, Center for Astrophysics
# December 2, 1991

procedure ximtool (display_type)

char display_type="ximtool"	{prompt="Display Type - saoimage/ximtool/ds9/saotng"}
#char udisplay=":0"		{prompt="X display node"}
char geometry="516x704-2-2"	{prompt="window geometry (xdim x ydim + xoff + yoff"}
#char pipename="home$dev/imt1"	{prompt="name of imtool pipe"}
char pipename="/dev/imt1"	{prompt="name of imtool pipe"}
char userpar1=""		{prompt="User switches"}
char userpar2=""		{prompt="User switches"}
bool background=yes		{prompt="run in background"}
struct *list

begin
    char arg,pn,pn1,pn2,arg1,arglist,arg2,dtype,progarg,pname,gname
    bool bk
    int idx

    dtype = display_type
#    display = udisplay

    arglist = ""
    progarg = ""
    arg1 = envget("terminal")
    print (arg1,>> "home$term")
    idx = stridx("x", arg1 )
    if( idx == 1){

    if( substr(dtype,1,8) == "saoimage" ){
       pname = pipename
       gname = envget("graphcap")
       if( substr(pname,1,5) == "home$" ){
          if( substr(gname,1,5) != "home$" ){
	    print("graphcap setting, ", gname, ", inconsistent with pipename setting, ", pname) 
	    error(1,"Please reset pipename=/dev/imt<n>") 
	  }
        }
    }

    if( substr(dtype,1,7) == "ximtool"){
         print ("using IRAF's ximtool")
         progarg = " -e ximtool "
    }
    else if( substr(dtype,1,8) == "saoimage" )
    {
        print ("using SAOimage") 
        # Display for X
#        arglist = " -d "//display

        progarg = " -e saoimage -pros"
    }
    else if( substr(dtype,1,6) == "saotng" )
     {
      print ("using SAOtng") 
      progarg = " -e saotng "
     }
    else if( substr(dtype,1,3) == "ds9" )
     {
      print ("using DS9") 
      progarg = " -e ds9 -fifo "
      progarg = progarg // pipename
     }


    arglist = arglist // progarg

    # User parameters
    if (userpar1 !=""){
        arglist = arglist // " " // userpar1
    }
    if (userpar2 !=""){
        arglist = arglist // " " // userpar2
    }
    
# Personal Pipe stuff for SAOimage 
    if( dtype == "saoimage"){
         delete("home$xidev", ver-, >& "dev$null")
         delete("home$xodev", ver-, >& "dev$null")
 
         pn = osfn (pipename)
         #  Don't put the continuation on the test string
         arg1 = " -idev " // pn //"o " 
         print (arg1,>> "home$xidev")
         arg2 = " -odev " // pn //"i "
         arglist = arglist // arg1 // arg2

         pn1 = osfn("home$xidev")
         pn2 = osfn("home$xodev")

## the xterm probably doesn't show, but why chance it...
         print("!ps guwax | grep saoimage | grep -v SAO | fgrep -f ", pn1, "> ", pn2 ) | cl
         list = pn2
         if( fscan(list,arg) != EOF )
	    error ( 1,"SAOIMAGE already running with this device " // arg1)

         delete("home$xidev", ver-, >& "dev$null")
         delete("home$xodev", ver-, >& "dev$null")
     }


#      # Run in background if requested
      bk = background
      if (bk)
        arg = " &"

      arglist = arglist // arg

# Execute IMAGE display

      print ("xterm" //  arglist)
      print ("Attempting Display on: ", envget("DISPLAY") )
      _x (arglist)
     }
     else
     error(1,"ximtool is only for use in Xwindows - you need 'stty xterm' or 'stty xgterm'")
end
